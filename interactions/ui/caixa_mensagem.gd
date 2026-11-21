extends CanvasLayer
## Caixa de mensagem + lista de itens mínima, só para dar feedback às interações.
## Ouve o autoload Eventos. O HUD/diálogo definitivo é de outra pessoa e pode
## substituir esta cena ouvindo os mesmos sinais.

@export var duracao: float = 3.5

var _painel: PanelContainer
var _texto: Label
var _itens: Label
var _timer: Timer


func _ready() -> void:
	layer = 10

	_painel = PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.1, 0.07, 0.05, 0.9)
	estilo.set_content_margin_all(16)
	estilo.set_corner_radius_all(6)
	_painel.add_theme_stylebox_override("panel", estilo)
	_painel.custom_minimum_size = Vector2(0, 90)
	add_child(_painel)
	_painel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE, Control.PRESET_MODE_MINSIZE, 20)
	_painel.hide()

	_texto = Label.new()
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_texto.add_theme_font_size_override("font_size", 22)
	_painel.add_child(_texto)

	_itens = Label.new()
	_itens.position = Vector2(16, 12)
	_itens.add_theme_font_size_override("font_size", 18)
	add_child(_itens)

	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_painel.hide)
	add_child(_timer)

	Eventos.mensagem_solicitada.connect(_mostrar)
	Eventos.item_coletado.connect(func(_id, _nome): _atualizar_itens())


func _mostrar(texto: String) -> void:
	_texto.text = texto
	_painel.show()
	_timer.start(duracao)


func _atualizar_itens() -> void:
	var linhas: PackedStringArray = ["Itens:"]
	for id in Eventos.inventario:
		linhas.append("- %s x%d" % [Eventos.nomes_itens[id], Eventos.inventario[id]])
	_itens.text = "\n".join(linhas)
