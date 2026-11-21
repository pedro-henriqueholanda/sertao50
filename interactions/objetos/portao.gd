extends StaticBody2D
## Exemplo de objeto que REAGE a um evento disparado por um Interactable.

@export var evento_abrir: String = "abrir_portao"


func _ready() -> void:
	Eventos.evento_disparado.connect(_on_evento)


func _on_evento(id: String) -> void:
	if id == evento_abrir:
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
