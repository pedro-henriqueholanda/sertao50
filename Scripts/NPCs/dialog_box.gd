extends CanvasLayer

@onready var painel = $Panel
@onready var nome_label = $Panel/NameLabel
@onready var dialogo_label = $Panel/DialogLabel

var falas: Array[String] = []
var indice_atual: int = 0
var dialogo_ativo: bool = false

func _ready():
    painel.hide()
    add_to_group("dialogue_ui")

func mostrar_dialogo(nome: String, novas_falas: Array[String]):
    if novas_falas.is_empty():
        return

    falas = novas_falas
    indice_atual = 0
    dialogo_ativo = true

    nome_label.text = nome
    dialogo_label.text = falas[indice_atual]

    painel.show()

func _unhandled_input(event):
    if dialogo_ativo and event.is_action_pressed("interagir"):
        avancar_dialogo()
        get_viewport().set_input_as_handled()

func avancar_dialogo():
    indice_atual += 1

    if indice_atual >= falas.size():
        fechar_dialogo()
        return

    dialogo_label.text = falas[indice_atual]

func fechar_dialogo():
    painel.hide()
    dialogo_ativo = false
    falas.clear()
    indice_atual = 0