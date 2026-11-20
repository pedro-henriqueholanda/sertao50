extends "res://Scripts/Mobs/mob_hostil.gd"

@export var dano_veneno: int = 5
@export var duracao_veneno: float = 4.0
@export var intervalo_veneno: float = 1.0

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

        if jogador.has_method("aplicar_veneno"):
            jogador.aplicar_veneno(
                dano_veneno,
                duracao_veneno,
                intervalo_veneno
            )

        tempo_ataque = intervalo_ataque