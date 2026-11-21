extends Node
## Autoload "Eventos": barramento global do jogo (Pessoa 3).
## Qualquer sistema (HUD, diálogos, mapa, inimigos...) pode ouvir estes sinais
## sem precisar conhecer os objetos interativos.

signal item_coletado(item_id: String, nome: String)
signal evento_disparado(evento_id: String)
signal mensagem_solicitada(texto: String)

## item_id -> quantidade
var inventario: Dictionary = {}
## item_id -> nome para exibição
var nomes_itens: Dictionary = {}
## evento_id -> true (eventos que já aconteceram)
var eventos_ocorridos: Dictionary = {}


func adicionar_item(item_id: String, nome: String = "", quantidade: int = 1) -> void:
	inventario[item_id] = inventario.get(item_id, 0) + quantidade
	nomes_itens[item_id] = nome if nome != "" else item_id
	item_coletado.emit(item_id, nomes_itens[item_id])


func tem_item(item_id: String) -> bool:
	return inventario.get(item_id, 0) > 0


func disparar_evento(evento_id: String) -> void:
	eventos_ocorridos[evento_id] = true
	evento_disparado.emit(evento_id)


func evento_ocorreu(evento_id: String) -> bool:
	return eventos_ocorridos.has(evento_id)


func mostrar_mensagem(texto: String) -> void:
	mensagem_solicitada.emit(texto)
