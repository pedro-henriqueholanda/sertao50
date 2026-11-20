extends CharacterBody2D

@export var nome_personagem: String = "Morador"
@export var tipo_personagem: String = "Aldeão"
@export_multiline var dialogos: Array[String] = []
@export var quantidade_cura: int = 0
@export var pode_interagir: bool = true

@onready var area_interacao = $AreaInteracao

var jogador_proximo: bool = false
var caixa_dialogo: Node = null

func _ready():
    add_to_group("npcs_pacificos")
    area_interacao.body_entered.connect(_ao_entrar_na_area)
    area_interacao.body_exited.connect(_ao_sair_da_area)

func _process(_delta):
    if jogador_proximo and pode_interagir:
        if Input.is_action_just_pressed("interagir"):
            interagir()

func _ao_entrar_na_area(body):
    if body.is_in_group("player"):
        jogador_proximo = true

func _ao_sair_da_area(body):
    if body.is_in_group("player"):
        jogador_proximo = false

func interagir():
    if not pode_interagir:
        return

    caixa_dialogo = get_tree().get_first_node_in_group("dialogue_ui")

    if caixa_dialogo == null:
        return

    caixa_dialogo.mostrar_dialogo(nome_personagem, dialogos)

    if quantidade_cura > 0:
        curar_jogador()

func curar_jogador():
    var jogador = get_tree().get_first_node_in_group("player")

    if jogador and jogador.has_method("receber_cura"):
        jogador.receber_cura(quantidade_cura)