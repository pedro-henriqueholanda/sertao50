class_name Interactable
extends Area2D


signal interagiu(jogador: Node2D)
signal coletado(item_id: String)
signal evento_disparado(evento_id: String)

enum Tipo { EXAMINAR, COLETAR, ATIVAR, NPC }

@export var tipo: Tipo = Tipo.EXAMINAR
@export var nome_objeto: String = ""
@export var mensagens: Array[String] = []
@export var item_id: String = ""
@export var evento_id: String = ""
@export var uma_vez: bool = false
@export var cor: Color = Color.WHITE

static var _em_alcance: Array[Interactable] = []

var _jogador: Node2D = null
var _indice_mensagem: int = 0
var _usado: bool = false

@onready var _prompt: Sprite2D = $Prompt
@onready var _visual: Sprite2D = $Visual
@onready var _nome: Label = $Nome


func _ready() -> void:
	_prompt.hide()
	_visual.modulate = cor
	_nome.text = nome_objeto
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _exit_tree() -> void:
	_em_alcance.erase(self)
	_atualizar_prompts()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interagir"):
		return
	if _em_alcance.is_empty() or _em_alcance.back() != self:
		return
	get_viewport().set_input_as_handled()
	interagir(_jogador)


func interagir(jogador: Node2D = null) -> void:
	if _usado:
		return
	interagiu.emit(jogador)
	match tipo:
		Tipo.COLETAR:
			_coletar()
		Tipo.ATIVAR:
			_ativar()
		_:
			_falar()
	_ao_interagir(jogador)
	if tipo == Tipo.COLETAR or uma_vez:
		_consumir()


func _ao_interagir(_jogador_: Node2D) -> void:
	pass


func _falar() -> void:
	if mensagens.is_empty():
		return
	var i: int = mini(_indice_mensagem, mensagens.size() - 1)
	Eventos.mostrar_mensagem(mensagens[i])
	_indice_mensagem += 1


func _coletar() -> void:
	if item_id == "":
		push_warning("Interactable '%s' é COLETAR mas item_id está vazio." % name)
	Eventos.adicionar_item(item_id, nome_objeto)
	coletado.emit(item_id)
	if mensagens.is_empty():
		Eventos.mostrar_mensagem("Você pegou: %s" % (nome_objeto if nome_objeto != "" else item_id))
	else:
		Eventos.mostrar_mensagem(mensagens[0])


func _ativar() -> void:
	if evento_id == "":
		push_warning("Interactable '%s' é ATIVAR mas evento_id está vazio." % name)
	Eventos.disparar_evento(evento_id)
	evento_disparado.emit(evento_id)
	if not mensagens.is_empty():
		Eventos.mostrar_mensagem(mensagens[0])


func _consumir() -> void:
	_usado = true
	_prompt.hide()
	_em_alcance.erase(self)
	_atualizar_prompts()
	if tipo == Tipo.COLETAR:
		queue_free()
	else:
		set_deferred("monitoring", false)
		_visual.modulate.a = 0.5


func _on_body_entered(body: Node2D) -> void:
	if _usado or not body.is_in_group("jogador"):
		return
	_jogador = body
	if not _em_alcance.has(self):
		_em_alcance.append(self)
	_atualizar_prompts()


func _on_body_exited(body: Node2D) -> void:
	if body != _jogador:
		return
	_jogador = null
	_em_alcance.erase(self)
	_prompt.hide()
	_atualizar_prompts()


static func _atualizar_prompts() -> void:
	for i in _em_alcance.size():
		var obj: Interactable = _em_alcance[i]
		if is_instance_valid(obj):
			obj._prompt.visible = (i == _em_alcance.size() - 1)
