# Player — Sertão 50 (Pessoa 1)

Movimentação e controle do jogador: movimento 2D, colisões, câmera, vida, ataque e interação.
Testado no **Godot 4.7**.

## Como rodar
Abra o projeto no Godot e aperte **F6** com `player/teste/TestePlayer.tscn` aberta
(ou F5, se ela for a cena principal).

| Tecla | Ação |
|---|---|
| WASD / Setas | andar (8 direções, sprite em 4) |
| Shift | correr |
| J / Z / clique esquerdo | atacar (facão) |
| Espaço / E | interagir (sistema da Pessoa 3) |

As ações de input são criadas **automaticamente** pelo `player.gd` se não existirem
no `project.godot`. Ninguém precisa configurar nada.

## Arquivos
```
player/
├── Player.tscn             ← cena do jogador (é só instanciar no mapa)
├── player.gd               ← todo o código do player
├── sprites/protagonista.png  ← spritesheet 96×96 (9 frames de 32×32)
├── sprites/golpe.png       ← efeito do golpe
└── teste/                  ← cena de teste (pode ser apagada no jogo final)
```

### Spritesheet (`protagonista.png`, 3 colunas × 3 linhas de 32×32)
| Linha | Coluna 1 | Coluna 2 | Coluna 3 |
|---|---|---|---|
| Frente | parado | passo 1 | passo 2 |
| Lado (direita) | parado | passo 1 | passo 2 |
| Costas | parado | passo 1 | passo 2 |

Esquerda = lado espelhado (`flip_h`). Animações: `parado_baixo`, `andar_baixo`,
`parado_lado`, `andar_lado`, `parado_cima`, `andar_cima` (ciclo passo1 → parado → passo2 → parado, 8 fps).

## Montagem da cena
```
Player (CharacterBody2D)  ← origem nos PÉS (funciona com Y-Sort)
├── AnimatedSprite2D      (y = -16)
├── CollisionShape2D      14×8, só nos pés (estilo Zelda/Pokémon)
├── Hitbox (Area2D)       área do golpe, ligada só durante o ataque
│   └── EfeitoGolpe
└── Camera2D              zoom 2, suavizada
```

## Contrato com o resto da equipe
**Grupos:** `player` (usado por NPCs e Mobs) e `jogador` (usado pelos Interactables).
O código do repositório usa os dois nomes, então o Player entra nos dois.

**Métodos que os outros podem chamar:**
- `receber_dano(quantidade, origem = Vector2.INF)` — mob_hostil / mob_venenoso já chamam
- `receber_cura(quantidade)` — npc_base já chama
- `aplicar_veneno(dano, duracao, intervalo)` — mob_venenoso já chama
- `curar_veneno()`, `esta_envenenado()`
- `bloquear_controle(true/false)` — cutscenes, menus, viagem de trem, montaria
- `definir_ponto_renascer(posicao)` — checkpoints / estações
- `definir_limites_camera(Rect2i)` — Pessoa 4: limites do mapa
- `ponto_a_frente(distancia)` — posição na frente do player

**Sinais (para o HUD da Pessoa 5):** `vida_alterada(atual, maxima)`, `morreu`, `renasceu`,
`atacou(direcao)`, `envenenado(ativo)`.

O ataque chama `receber_dano(dano)` em qualquer corpo que tenha esse método (os mobs já têm).
O movimento fica travado sozinho enquanto a caixa de diálogo dos NPCs (`dialogue_ui`) estiver aberta.

## Configuração do projeto
- `rendering/textures/canvas_textures/default_texture_filter = Nearest` → pixel art nítido (sem borrão).
- Para mapas: coloque o Player dentro de um nó com **Y Sort Enabled** junto dos objetos/NPCs,
  com a origem deles também nos pés.

## Próximos passos (Parte 4 em diante)
- [ ] Sprite de ataque (4 direções) e de dano/morte
- [ ] Montaria (jumento/cavalo): trocar `velocidade` e SpriteFrames
- [ ] Som de passos e golpe
- [ ] Integrar com o HUD definitivo e com o mapa do Tiled
