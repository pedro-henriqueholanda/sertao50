extends CharacterBody2D
## Player de TESTE para a cena de interação.
## O movimento real é de outra pessoa do grupo: ao integrar, basta que o
## personagem final esteja no grupo "jogador" (veja add_to_group abaixo).

@export var velocidade: float = 200.0


func _ready() -> void:
	add_to_group("jogador")


func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * velocidade
	move_and_slide()
