# 🌵 Game Design Document (GDD) - Template: Sertão 50

> **Dica para a equipe:** Este documento deve ser vivo. Atualizem este arquivo no GitHub sempre que uma nova decisão for tomada. Ele servirá como a "Bíblia" do jogo para que todos (programadores, artistas e designers) estejam na mesma página.

---

## 📋 1. Visão Geral (O "Elevator Pitch")
*Definam a essência do jogo em poucas palavras.*
- **Título:** Sertão 50: Os Caminhos da Seca
- **Gênero:** RPG 2D de Exploração / Aventura (Top-down)
- **Estilo Visual:** Pixel Art (Inspirado em *Zelda: A Link to the Past* e *Pokémon*)
- **Público-Alvo:** Jovens, estudantes, entusiastas de história e cultura nordestina.
- **Engine:** Godot Engine (GDScript)

### 1.1. Passo a Passo de Decisões (Checklist Inicial)
- [ ] Definir a paleta de cores (tons terrosos da Caatinga, contraste com o verde em áreas de oásis/chuva).
- [ ] Escolher a resolução base do pixel art (ex: 16x16 ou 32x32).
- [ ] Mapear as 3 primeiras missões principais do MVP.
- [ ] Definir a estrutura de diretórios no repositório GitHub.

---

## 🎮 2. Jogabilidade e Mecânicas (Gameplay)
*Como o jogador interage com o mundo?*

### 2.1. Câmera e Movimentação
- **Visão:** Top-down (câmera vista de cima).
- **Movimentação:** O personagem se move em 4 ou 8 direções? (Definir).
- **Controles Básicos:** (Ex: WASD para mover, Espaço para interagir, 'I' para inventário).

### 2.2. Sistemas Principais
- **Interação:** Como funcionam os diálogos? (Caixas de texto estilo RPG clássico, com retratos dos personagens?).
- **Combate/Ação:** Será combate em tempo real (ação) ou por turnos? Quais as armas/ferramentas do sertanejo (ex: facão, baladeira, foice)?
- **Montaria e Viagem Rápida:** Como o jogador adquire uma montaria (ex: cavalo, jumento)? Como funciona a malha ferroviária para *fast travel*?
- **Inventário e Coleta:** Quais itens podem ser coletados? (Recursos naturais, água, itens históricos, chaves).

---

## 📖 3. História e Narrativa (Lore)
*O coração cultural do jogo.*

### 3.1. Premissa
*Descreva o contexto do Sertão Central nos anos 1950/60. O que motiva o protagonista a sair de casa?*

### 3.2. Personagens Principais
- **Protagonista:** (Nome, idade, motivação, background).
- **NPCs Históricos / Importantes:** (Descrever personalidades de Senador Pompeu e região que aparecerão no jogo).
- **Inimigos / Mobs:** (Animais selvagens, bandoleiros, forças da natureza?).

---

## 🗺️ 4. Categorias de Fases e Level Design
*Como o mundo está dividido?*

### 4.1. Estrutura do Mapa Aberto
O mundo será dividido em instâncias/cenários interligados.
- **Zonas Seguras (Cidades/Vilas):** Locais para interagir com NPCs, pegar *quests*, comprar suprimentos. (Ex: Senador Pompeu, Estações de Trem).
- **Zonas de Exploração (Caatinga/Sertão):** Áreas abertas com mobs, itens escondidos e perigos naturais (ex: sol escaldante, vegetação espinhosa).
- **Dungeons (Desafios):** Cavernas, fazendas abandonadas ou ruínas históricas onde o jogador precisa resolver puzzles para avançar na história.

### 4.2. Passo a Passo do MVP (Primeira Fase)
1. **Ponto de Partida:** Casa do protagonista (tutorial de movimentação e interação).
2. **Primeiro Objetivo:** Falar com um ancião da vila para receber a primeira missão.
3. **Desafio Inicial:** Atravessar uma pequena área de Caatinga para recuperar um item ou coletar água.

---

## 🎨 5. Arte e Áudio
### 5.1. Direção de Arte
- **Estilo:** Pixel art retrô.
- **Animações:** *Idle* (parado), *Walk* (andando), *Attack* (atacando), *Interact* (interagindo).
- **Tilesets:** Criar no Tiled. Quais serão os principais? (Chão de terra seca, mandacarus, trilhos de trem, casas de taipa/alvenaria).

### 5.2. Design de Som (Soundscape)
- **Efeitos Sonoros (SFX):** Passos na terra seca, som do vento, apito do trem, som de coleta.
- **Trilha Sonora (OST):** Músicas inspiradas na cultura nordestina (baião, xote) utilizando instrumentos como sanfona, zabumba e triângulo. (Definir fontes de domínio público ou IA).

---

## 💻 6. Detalhamento Técnico
*Arquitetura do projeto na Godot para a equipe de programação.*

- **Padrão de Arquitetura Godot:** Uso de `State Machines` (Máquina de Estados) para controle do jogador e IA dos mobs.
- **Gerenciamento de Dados:** Como salvar o jogo? (Uso de arquivos `.json` ou `ConfigFile` no Godot para o inventário e progresso de missões).
- **Guia de Contribuição (Git):**
  - Todo o código GDScript deve ser em inglês ou português? (Definir padrão, ex: variáveis em inglês `player_health`, textos do jogo em português).
  - Padrão de Commits: Ex: `feat: adiciona sistema de dialogo`, `fix: corrige bug de colisao`.

---

## 📅 7. Cronograma e Metas
*(Alinhado com o documento do DIGITECH)*
- **[27/08 - 27/09]:** Planejamento e Escopo (Preenchimento completo deste GDD).
- **[28/09 - 18/10]:** Protótipo Inicial (Movimentação, câmera e colisões).
- **[19/10 - 23/11]:** Desenvolvimento (Sistemas de quests, combate e integração da arte).
- **[24/11 - 07/12]:** Testes, Polimento e Finalização do MVP.
