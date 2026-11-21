# Sistema de Interações (Pessoa 3)

## Como usar um objeto interativo
1. Instancie `interactions/Interactable.tscn` na cena.
2. Configure no Inspetor: `tipo`, `nome_objeto`, `mensagens`, `item_id` / `evento_id`, `uma_vez`, `cor`.
3. O jogador chega perto -> aparece o prompt "SPACE" -> Espaço (ação `interagir`) -> interação.

| Tipo | O que faz |
|---|---|
| EXAMINAR | mostra a mensagem (repetível) |
| COLETAR | guarda `item_id` em `Eventos.inventario` e o objeto some |
| ATIVAR | dispara `evento_id` via `Eventos.disparar_evento()` |
| NPC | mostra as mensagens em sequência (base p/ diálogos) |

## Requisitos para integrar
- O personagem final precisa estar no **grupo `jogador`** (Player.tscn já está).
- O autoload **`Eventos`** (project.godot) precisa existir no projeto final.
- Ação de input **`interagir`** = Espaço.

## Como os outros sistemas se conectam
- `Eventos.item_coletado(item_id, nome)` -> HUD/inventário
- `Eventos.evento_disparado(evento_id)` -> portas, cutscenes, navegação, inimigos...
- `Eventos.mensagem_solicitada(texto)` -> caixa de mensagem / diálogo
- `Eventos.tem_item("cantil")`, `Eventos.evento_ocorreu("abrir_portao")` para condições
- Cada Interactable também tem os sinais `interagiu`, `coletado`, `evento_disparado`.

## Arquivos de teste (podem ser trocados na integração)
`interactions/player.gd` (movimento com setas), `ui/CaixaMensagem.tscn`, `objetos/Portao.tscn`, `TesteInteracao.tscn`.
