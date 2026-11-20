extends CharacterBody2D

@export var nome_mob: String = "Animal"
@export_multiline var informacoes: Array[String] = []
@export var velocidade: float = 35.0
@export var distancia_movimento: float = 100.0

@onready var area_interacao = $AreaInteracao

var direcao: Vector2 = Vector2.ZERO
var jogador_proximo: bool = false
var posicao_inicial: Vector2
var tempo_movimento: float = 0.0
var tempo_espera: float = 0.0
var caixa_dialogo: Node

func _ready():
    add_to_group("mobs_pacificos")
    posicao_inicial = global_position

    area_interacao.body_entered.connect(_ao_entrar_na_area)
    area_interacao.body_exited.connect(_ao_sair_da_area)

func _physics_process(delta):
    if tempo_espera > 0:
        tempo_espera -= delta
        velocity = Vector2.ZERO
        move_and_slide()
        return

    tempo_movimento -= delta

    if tempo_movimento <= 0:
        escolher_direcao()

    if global_position.distance_to(posicao_inicial) >= distancia_movimento:
        direcao = (posicao_inicial - global_position).normalized()

    velocity = direcao * velocidade
    move_and_slide()

func escolher_direcao():
    if randf() < 0.4:
        direcao = Vector2.ZERO
        tempo_espera = randf_range(1.0, 3.0)
    else:
        direcao = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
        tempo_movimento = randf_range(2.0, 4.0)

func _process(_delta):
    if jogador_proximo and Input.is_action_just_pressed("interagir"):
        interagir()

func _ao_entrar_na_area(body):
    if body.is_in_group("player"):
        jogador_proximo = true

func _ao_sair_da_area(body):
    if body.is_in_group("player"):
        jogador_proximo = false

func interagir():
    caixa_dialogo = get_tree().get_first_node_in_group("dialogue_ui")

    if caixa_dialogo:
        caixa_dialogo.mostrar_dialogo(nome_mob, informacoes)