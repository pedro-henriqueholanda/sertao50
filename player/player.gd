class_name Player
extends CharacterBody2D
## Sertão 50 — Player (Pessoa 1: movimentação e controle do jogador)
##
## Responsável por: movimento 2D top-down, colisão, câmera, vida, ataque e
## a "ponte" de interação com os sistemas dos colegas.
##
## CONTRATO COM OS OUTROS SISTEMAS (não renomear sem avisar a equipe):
##   Grupos:  "player" (NPCs/Mobs)  e  "jogador" (Interactables)
##   Métodos chamados de fora:
##     receber_dano(quantidade, origem = Vector2.INF)   <- mob_hostil / mob_venenoso
##     receber_cura(quantidade)                         <- npc_base
##     aplicar_veneno(dano, duracao, intervalo)         <- mob_venenoso
##     bloquear_controle(bool)                          <- cutscenes, menus, viagem de trem
##   Sinais para o HUD (Pessoa 5):
##     vida_alterada(atual, maxima), morreu, renasceu, atacou(direcao), envenenado(ativo)

signal vida_alterada(atual: int, maxima: int)
signal morreu
signal renasceu
signal atacou(direcao: Vector2)
signal envenenado(ativo: bool)

# ------------------------------------------------------------------ Movimento
@export_group("Movimento")
## Velocidade andando, em pixels/segundo (1 tile = 32 px).
@export var velocidade: float = 90.0
## Multiplicador ao segurar Shift (ação "correr").
@export var multiplicador_corrida: float = 1.6
## Quão rápido chega na velocidade máxima (maior = mais "seco", estilo Zelda).
@export var aceleracao: float = 1200.0
@export var desaceleracao: float = 1600.0

# ------------------------------------------------------------------ Vida
@export_group("Vida")
@export var vida_maxima: int = 100
## Tempo invencível depois de levar dano (o sprite pisca).
@export var tempo_invencivel: float = 0.8
@export var forca_empurrao: float = 180.0
## Segundos até renascer depois de morrer (0 = não renasce sozinho).
@export var tempo_para_renascer: float = 2.0

# ------------------------------------------------------------------ Ataque
@export_group("Ataque")
@export var dano_ataque: int = 25
@export var duracao_ataque: float = 0.18
@export var recarga_ataque: float = 0.35
## Distância do centro do golpe até o player.
@export var alcance_ataque: float = 18.0

# ------------------------------------------------------------------ Câmera
@export_group("Câmera")
@export var zoom_camera: float = 2.0
## Limites do mapa para a câmera não mostrar o "vazio". Deixe 0 para ignorar.
@export var limite_camera: Rect2i = Rect2i()

var vida_atual: int
var direcao_olhar: Vector2 = Vector2.DOWN
var esta_vivo: bool = true

var _controle_bloqueado: bool = false
var _atacando: bool = false
var _tempo_recarga: float = 0.0
var _tempo_invencivel: float = 0.0
var _empurrao: Vector2 = Vector2.ZERO
var _velocidade_mov: Vector2 = Vector2.ZERO
var _veneno_restante: float = 0.0
var _veneno_dano: int = 0
var _veneno_intervalo: float = 1.0
var _veneno_acumulado: float = 0.0
var _posicao_renascer: Vector2
var _atingidos_no_golpe: Array[Node] = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_forma: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var efeito_golpe: Sprite2D = $Hitbox/EfeitoGolpe


func _ready() -> void:
	add_to_group("player")
	add_to_group("jogador")
	_garantir_inputs()

	vida_atual = vida_maxima
	_posicao_renascer = global_position

	camera.zoom = Vector2(zoom_camera, zoom_camera)
	if limite_camera.size != Vector2i.ZERO:
		definir_limites_camera(limite_camera)

	hitbox.monitoring = false
	efeito_golpe.hide()
	hitbox.body_entered.connect(_on_hitbox_body_entered)

	_atualizar_animacao(false)
	vida_alterada.emit.call_deferred(vida_atual, vida_maxima)


func _physics_process(delta: float) -> void:
	_tempo_recarga = maxf(_tempo_recarga - delta, 0.0)
	_processar_invencibilidade(delta)
	_processar_veneno(delta)

	if not esta_vivo:
		velocity = Vector2.ZERO
		_velocidade_mov = Vector2.ZERO
		return

	var entrada := Vector2.ZERO
	if _pode_controlar():
		entrada = Input.get_vector("mover_esquerda", "mover_direita", "mover_cima", "mover_baixo")
		if Input.is_action_just_pressed("atacar"):
			atacar()

	if _atacando:
		entrada = Vector2.ZERO  # fica parado durante o golpe (estilo Zelda)

	var alvo := entrada * velocidade
	if Input.is_action_pressed("correr") and entrada != Vector2.ZERO:
		alvo *= multiplicador_corrida

	var taxa := aceleracao if entrada != Vector2.ZERO else desaceleracao
	_velocidade_mov = _velocidade_mov.move_toward(alvo, taxa * delta)

	# empurrão ao levar dano (somado ao movimento normal)
	velocity = _velocidade_mov + _empurrao
	_empurrao = _empurrao.move_toward(Vector2.ZERO, 900.0 * delta)

	move_and_slide()

	if entrada != Vector2.ZERO:
		direcao_olhar = _direcao_cardinal(entrada)
	if not _atacando:
		_atualizar_animacao(entrada != Vector2.ZERO)


# ======================================================================
#  ANIMAÇÃO
# ======================================================================
func _direcao_cardinal(v: Vector2) -> Vector2:
	# Escolhe a direção dominante (os sprites têm 4 direções).
	# Em diagonal, mantém a direção atual se ela ainda fizer parte do movimento,
	# para o personagem não "tremer" entre lado e frente.
	if absf(absf(v.x) - absf(v.y)) < 0.1:
		if (direcao_olhar.x != 0 and signf(direcao_olhar.x) == signf(v.x)) \
				or (direcao_olhar.y != 0 and signf(direcao_olhar.y) == signf(v.y)):
			return direcao_olhar
	if absf(v.x) > absf(v.y):
		return Vector2.RIGHT if v.x > 0 else Vector2.LEFT
	return Vector2.DOWN if v.y > 0 else Vector2.UP


func _nome_direcao() -> String:
	if direcao_olhar == Vector2.UP:
		return "cima"
	if direcao_olhar == Vector2.DOWN:
		return "baixo"
	return "lado"


func _atualizar_animacao(andando: bool) -> void:
	sprite.flip_h = direcao_olhar == Vector2.LEFT
	var anim := ("andar_" if andando else "parado_") + _nome_direcao()
	if sprite.animation != anim:
		sprite.play(anim)
	var correndo := andando and Input.is_action_pressed("correr")
	sprite.speed_scale = multiplicador_corrida if correndo else 1.0


# ======================================================================
#  ATAQUE
# ======================================================================
func atacar() -> void:
	if _atacando or _tempo_recarga > 0.0 or not esta_vivo:
		return
	_atacando = true
	_tempo_recarga = recarga_ataque
	_atingidos_no_golpe.clear()

	# posiciona a hitbox e o efeito na direção que o player está olhando
	hitbox.position = direcao_olhar * alcance_ataque + Vector2(0, -12)
	hitbox.rotation = direcao_olhar.angle()
	efeito_golpe.show()
	efeito_golpe.modulate.a = 1.0
	sprite.play("parado_" + _nome_direcao())
	hitbox.set_deferred("monitoring", true)
	atacou.emit(direcao_olhar)

	# corpos que já estavam dentro da área quando o golpe começou
	await get_tree().physics_frame
	await get_tree().physics_frame
	for corpo in hitbox.get_overlapping_bodies():
		_acertar(corpo)

	var t := create_tween()
	t.tween_property(efeito_golpe, "modulate:a", 0.0, duracao_ataque)
	await t.finished

	hitbox.set_deferred("monitoring", false)
	efeito_golpe.hide()
	_atacando = false


func _on_hitbox_body_entered(corpo: Node2D) -> void:
	_acertar(corpo)


func _acertar(corpo: Node) -> void:
	if corpo == self or corpo in _atingidos_no_golpe:
		return
	if not corpo.has_method("receber_dano"):
		return
	_atingidos_no_golpe.append(corpo)
	corpo.receber_dano(dano_ataque)
	# empurra o inimigo um pouco, se ele usar velocity
	if corpo is CharacterBody2D:
		corpo.velocity += direcao_olhar * 220.0


# ======================================================================
#  VIDA / DANO / CURA / VENENO
# ======================================================================
func receber_dano(quantidade: int, origem: Vector2 = Vector2.INF) -> void:
	if not esta_vivo or _tempo_invencivel > 0.0 or quantidade <= 0:
		return
	_alterar_vida(-quantidade)
	_tempo_invencivel = tempo_invencivel

	# empurrão: para longe da origem do dano ou do inimigo mais próximo
	var de := origem
	if de == Vector2.INF:
		de = _inimigo_mais_proximo()
	if de != Vector2.INF and de != global_position:
		_empurrao = de.direction_to(global_position) * forca_empurrao


func receber_cura(quantidade: int) -> void:
	if not esta_vivo or quantidade <= 0:
		return
	_alterar_vida(quantidade)
	_piscar_cor(Color(0.6, 1.0, 0.6))


func aplicar_veneno(dano: int, duracao: float, intervalo: float) -> void:
	if not esta_vivo:
		return
	_veneno_dano = dano
	_veneno_intervalo = maxf(intervalo, 0.05)
	_veneno_restante = duracao
	_veneno_acumulado = 0.0
	envenenado.emit(true)


func esta_envenenado() -> bool:
	return _veneno_restante > 0.0


func curar_veneno() -> void:
	if _veneno_restante > 0.0:
		_veneno_restante = 0.0
		sprite.modulate = Color.WHITE
		envenenado.emit(false)


func _processar_veneno(delta: float) -> void:
	if _veneno_restante <= 0.0:
		return
	_veneno_restante -= delta
	_veneno_acumulado += delta
	sprite.modulate = Color(0.75, 1.0, 0.65)
	if _veneno_acumulado >= _veneno_intervalo:
		_veneno_acumulado -= _veneno_intervalo
		_alterar_vida(-_veneno_dano)  # veneno ignora invencibilidade
	if _veneno_restante <= 0.0:
		curar_veneno()


func _alterar_vida(delta_vida: int) -> void:
	if not esta_vivo:
		return
	vida_atual = clampi(vida_atual + delta_vida, 0, vida_maxima)
	vida_alterada.emit(vida_atual, vida_maxima)
	if vida_atual <= 0:
		_morrer()


func _processar_invencibilidade(delta: float) -> void:
	if _tempo_invencivel <= 0.0:
		return
	_tempo_invencivel -= delta
	# pisca a cada 0.08s
	sprite.visible = int(_tempo_invencivel / 0.08) % 2 == 0
	if _tempo_invencivel <= 0.0:
		sprite.visible = true


func _morrer() -> void:
	esta_vivo = false
	curar_veneno()
	_tempo_invencivel = 0.0
	sprite.visible = true
	sprite.stop()
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1, 0.3, 0.3, 0.0), 0.6)
	morreu.emit()
	if tempo_para_renascer > 0.0:
		await get_tree().create_timer(tempo_para_renascer).timeout
		renascer()


## Volta à vida no último ponto salvo (veja definir_ponto_renascer).
func renascer() -> void:
	global_position = _posicao_renascer
	velocity = Vector2.ZERO
	_empurrao = Vector2.ZERO
	vida_atual = vida_maxima
	esta_vivo = true
	sprite.modulate = Color.WHITE
	direcao_olhar = Vector2.DOWN
	_atualizar_animacao(false)
	_tempo_invencivel = tempo_invencivel
	vida_alterada.emit(vida_atual, vida_maxima)
	renasceu.emit()


func definir_ponto_renascer(posicao: Vector2) -> void:
	_posicao_renascer = posicao


func _piscar_cor(cor: Color) -> void:
	var t := create_tween()
	sprite.modulate = cor
	t.tween_property(sprite, "modulate", Color.WHITE, 0.3)


func _inimigo_mais_proximo() -> Vector2:
	var melhor := Vector2.INF
	var menor := INF
	for grupo in ["mobs_hostis", "mobs"]:
		for m in get_tree().get_nodes_in_group(grupo):
			if m is Node2D:
				var d := global_position.distance_squared_to(m.global_position)
				if d < menor:
					menor = d
					melhor = m.global_position
	return melhor


# ======================================================================
#  CONTROLE / INTERAÇÃO
# ======================================================================
## Use para travar o player em cutscenes, menus, viagem de trem etc.
func bloquear_controle(bloquear: bool) -> void:
	_controle_bloqueado = bloquear
	if bloquear:
		velocity = Vector2.ZERO
		_velocidade_mov = Vector2.ZERO
		_atualizar_animacao(false)


func _pode_controlar() -> bool:
	if _controle_bloqueado:
		return false
	# trava o movimento enquanto a caixa de diálogo dos NPCs (Pessoa 2) está aberta
	var dialogo := get_tree().get_first_node_in_group("dialogue_ui")
	if dialogo != null and dialogo.get("dialogo_ativo") == true:
		return false
	return true


## Ponto à frente do player (útil para quem quiser checar o que está na frente).
func ponto_a_frente(distancia: float = 16.0) -> Vector2:
	return global_position + direcao_olhar * distancia


# ======================================================================
#  CÂMERA
# ======================================================================
func definir_limites_camera(r: Rect2i) -> void:
	camera.limit_left = r.position.x
	camera.limit_top = r.position.y
	camera.limit_right = r.end.x
	camera.limit_bottom = r.end.y


# ======================================================================
#  INPUTS
# ======================================================================
## Registra as ações de input caso ainda não existam no project.godot.
## Assim o Player funciona em qualquer cena sem ninguém precisar configurar nada.
static func _garantir_inputs() -> void:
	var mapa := {
		"mover_cima": [KEY_W, KEY_UP],
		"mover_baixo": [KEY_S, KEY_DOWN],
		"mover_esquerda": [KEY_A, KEY_LEFT],
		"mover_direita": [KEY_D, KEY_RIGHT],
		"atacar": [KEY_J, KEY_Z],
		"correr": [KEY_SHIFT],
		"interagir": [KEY_SPACE, KEY_E],
	}
	for acao in mapa:
		if not InputMap.has_action(acao):
			InputMap.add_action(acao, 0.2)
		var existentes := InputMap.action_get_events(acao)
		for tecla in mapa[acao]:
			var ja_tem := false
			for e in existentes:
				if e is InputEventKey and (e.physical_keycode == tecla or e.keycode == tecla):
					ja_tem = true
			if not ja_tem:
				var ev := InputEventKey.new()
				ev.physical_keycode = tecla
				InputMap.action_add_event(acao, ev)
	# botão esquerdo do mouse também ataca
	var tem_mouse := false
	for e in InputMap.action_get_events("atacar"):
		if e is InputEventMouseButton:
			tem_mouse = true
	if not tem_mouse:
		var m := InputEventMouseButton.new()
		m.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("atacar", m)
