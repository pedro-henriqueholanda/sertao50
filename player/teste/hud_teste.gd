extends CanvasLayer
## HUD SIMPLES só para testar o Player. O HUD definitivo é da Pessoa 5:
## basta conectar nos mesmos sinais do Player (vida_alterada, morreu, envenenado...).

var _label: Label


func _ready() -> void:
	_label = Label.new()
	_label.position = Vector2(12, 8)
	_label.add_theme_font_size_override("font_size", 20)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 6)
	add_child(_label)

	var ajuda := Label.new()
	ajuda.text = "WASD/Setas: andar   Shift: correr   J/Z/Clique: atacar   Espaço/E: interagir"
	ajuda.add_theme_font_size_override("font_size", 14)
	ajuda.add_theme_color_override("font_outline_color", Color.BLACK)
	ajuda.add_theme_constant_override("outline_size", 5)
	ajuda.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 10)
	add_child(ajuda)

	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.vida_alterada.connect(_on_vida)
		player.morreu.connect(func(): _label.text = "Você desmaiou no sertão..." )
		player.envenenado.connect(func(ativo): _label.modulate = Color(0.6, 1, 0.5) if ativo else Color.WHITE)


func _on_vida(atual: int, maxima: int) -> void:
	_label.text = "Vida: %d / %d" % [atual, maxima]
