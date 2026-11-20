extends CharacterBody2D

enum Estado {
    PATRULHA,
    PERSEGUINDO,
    ATACANDO
}

@export var nome_mob: String = "Inimigo"
@export var vida_maxima: int = 100
@export var dano: int = 10
@export var velocidade: float = 65.0
@export var distancia_deteccao: float = 150.0
@export var distancia_ataque: float = 25.0
@export var intervalo_ataque: float = 1.5
@export var alcance_patrulha: float = 80.0

var vida_atual: int
var estado_atual: Estado = Estado.PATRULHA
var jogador: Node2D
var direcao_patrulha: Vector2 = Vector2.ZERO
var posicao_inicial: Vector2
var tempo_ataque: float = 0.0
var tempo_patrulha: float = 0.0

func _ready():
    add_to_group("mobs_hostis")
    vida_atual = vida_maxima
    posicao_inicial = global_position
    escolher_direcao_patrulha()

func _physics_process(delta):
    tempo_ataque = maxf(tempo_ataque - delta, 0.0)

    procurar_jogador()

    match estado_atual:
        Estado.PATRULHA:
            patrulhar(delta)

        Estado.PERSEGUINDO:
            perseguir()

        Estado.ATACANDO:
            atacar()

    move_and_slide()

func procurar_jogador():
    var jogadores = get_tree().get_nodes_in_group("player")

    if jogadores.is_empty():
        jogador = null
        estado_atual = Estado.PATRULHA
        return

    var alvo = jogadores[0]

    if not is_instance_valid(alvo):
        jogador = null
        estado_atual = Estado.PATRULHA
        return

    jogador = alvo

    var distancia = global_position.distance_to(jogador.global_position)

    if distancia <= distancia_ataque:
        estado_atual = Estado.ATACANDO
    elif distancia <= distancia_deteccao:
        estado_atual = Estado.PERSEGUINDO
    else:
        estado_atual = Estado.PATRULHA

func patrulhar(delta):
    tempo_patrulha -= delta

    if tempo_patrulha <= 0:
        escolher_direcao_patrulha()

    if global_position.distance_to(posicao_inicial) > alcance_patrulha:
        direcao_patrulha = (posicao_inicial - global_position).normalized()

    velocity = direcao_patrulha * velocidade

func escolher_direcao_patrulha():
    if randf() < 0.3:
        direcao_patrulha = Vector2.ZERO
    else:
        direcao_patrulha = Vector2.RIGHT.rotated(randf_range(0.0, TAU))

    tempo_patrulha = randf_range(1.0, 3.0)

func perseguir():
    if not is_instance_valid(jogador):
        estado_atual = Estado.PATRULHA
        velocity = Vector2.ZERO
        return

    var direcao = global_position.direction_to(jogador.global_position)
    velocity = direcao * velocidade

func atacar():
    velocity = Vector2.ZERO

    if not is_instance_valid(jogador):
        return

    var distancia = global_position.distance_to(jogador.global_position)

    if distancia > distancia_ataque:
        estado_atual = Estado.PERSEGUINDO
        return

    if tempo_ataque <= 0:
        if jogador.has_method("receber_dano"):
            jogador.receber_dano(dano)

        tempo_ataque = intervalo_ataque

func receber_dano(quantidade: int):
    vida_atual -= quantidade

    if vida_atual <= 0:
        morrer()

func morrer():
    queue_free()