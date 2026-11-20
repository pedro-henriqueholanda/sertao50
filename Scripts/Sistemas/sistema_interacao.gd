extends Node

var dialogo_aberto: bool = false

func pode_interagir() -> bool:
    var caixa = get_tree().get_first_node_in_group("dialogue_ui")

    if caixa == null:
        return false

    return not caixa.dialogo_ativo

func iniciar_interacao(alvo: Node):
    if not pode_interagir():
        return

    if alvo.has_method("interagir"):
        alvo.interagir()