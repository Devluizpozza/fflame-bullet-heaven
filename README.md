# 🜂 **Aporia Heaven**

> *"Entre o caos e a ordem, sobreviver não é certeza — é contradição."*

**Aporia Heaven** é um roguelike minimalista e frenético inspirado em jogos como Vampire Survivors, mesclando temas filosóficos com mecânicas de sobrevivência.
Cada run é um confronto entre entropia e controle — onde o jogador evolui, se adapta e inevitavelmente cai.

---

## 🎮 Visão Geral

Aporia Heaven é um **roguelike de sobrevivência 2D top-down** construído com:

* Flutter
* Flame

O loop central de gameplay gira em torno de:

* Sobreviver a ondas de inimigos cada vez mais difíceis
* Coletar experiência e evoluir o personagem
* Subir de nível e escolher melhorias
* Resistir o maior tempo possível

---

## 🧠 Conceito Central

Inspirado na ideia filosófica de **aporia** (um estado de perplexidade ou impasse), o jogo explora:

* A ilusão de controle
* Progressão infinita vs derrota inevitável
* O caos como sistema

Mecanicamente, isso se traduz em:

* Dificuldade com escala crescente
* Builds emergentes
* Cenários de sobrevivência imprevisíveis

---

## ⚙️ Implementação Atual (Protótipo)

A versão atual é um **protótipo de gameplay**, focado em validar o loop central.

### ✅ Funcionalidades Implementadas

**Personagem**
* Sprite animado com pixel art (idle, movimento direita, esquerda, baixo)
* Espelhamento automático de sprite ao mover para a esquerda
* Movimento via joystick virtual (mobile) e teclado (WASD / setas)
* Sistema de vida com barra de HP colorida no HUD
* Flash de dano (tint vermelho sobre o sprite, sem retângulo genérico)
* Auto-ataque: projétil de chama disparado automaticamente ao inimigo mais próximo

**Inimigos**
* Arquitetura de inimigos baseada em herança — `Enemy` abstrato + subclasses (`GoblinEnemy`)
* Inimigos com sprite animado de goblin, espelhamento por direção
* Barra de HP individual sobre cada inimigo (compensada para não inverter com o espelho)
* IA de perseguição simples com limite de mapa
* **Mini-boss goblin gigante** (3× o tamanho do jogador): spawn a cada 10 segundos, 150 HP, 80% da velocidade do jogador

**Projéteis**
* Sprite animado de chama (4 frames)
* Rotação correta alinhada à direção do disparo
* Detecção contínua de colisão (CCD) via raycast para evitar tunneling

**Sistema de XP e Level-up**
* Orbs de XP com 3 tiers visuais: azul diamante (≤20 XP), roxo círculo (≤30 XP), laranja com anel (>30 XP)
* Drop de vida (coração) com 10% de chance — recupera 4 HP
* Tela de seleção de habilidade ao subir de nível (3 cartas)
* Habilidade disponível: **Velocidade de Projétil** — reduz o cooldown de ataque progressivamente
* Drops especiais do mini-boss: 1 vida garantida + 5 orbs de 100 XP + 1 nível completo instantâneo

**Morte de inimigos**
* Sprite `bone_death` ao morrer (tamanho proporcional ao inimigo — mini-boss deixa ossada maior)
* Fade out suave em 1.5s, removido após 5s

**HUD**
* Contador de tempo em MM:SS (fonte de largura fixa)
* Nível atual, barra de HP e barra de XP
* Painel "Magias" expansível: lista as habilidades coletadas com nível — pausa o jogo ao abrir
* Botão de pause no canto superior direito

**Fluxo de jogo**
* Telas: Menu, HUD, Pause, Game Over, Level-up
* Jogo inicia pausado — motor só começa ao pressionar "Jogar"
* Saída pausa corretamente o motor antes de reiniciar

**Técnico**
* `FilterQuality.none` em todos os sprites para renderização pixel-perfect
* Mapa com fundo em tileset e câmera com limites
* Sistema de spawn em ondas (3 iniciais + 3 a cada 3 segundos)

---

## 🚧 Roadmap

### Fase 1 — Gameplay Central ✅ (em andamento)

* [x] Sistema de colisão (jogador vs inimigos, projéteis vs inimigos)
* [x] Sistema de vida
* [x] Auto-ataque com projéteis animados
* [x] Sistema de XP e level-up
* [x] Sprites animados para jogador, inimigos e projéteis
* [x] Mini-boss com drops especiais
* [x] Contador de tempo no HUD
* [x] Arquitetura de inimigos extensível (herança)
* [ ] Mais tipos de inimigos
* [ ] Mais habilidades e variações de build
* [ ] Escala de dificuldade ao longo do tempo

### Fase 2 — Progressão

* [ ] Meta progressão (ouro, desbloqueios)
* [ ] Sistema de habilidades orientado a dados
* [ ] Sistema de equipamentos
* [ ] Sistema de save

### Fase 3 — Mundo & Conteúdo

* [ ] Integração real de tilemaps (via Tiled)
* [ ] Múltiplos mapas / biomas
* [ ] Variedade de inimigos e comportamentos únicos
* [ ] Encontros com chefões (boss stage)

### Fase 4 — Polimento & UX

* [ ] Efeitos visuais (partículas, flash de impacto)
* [ ] Som e música
* [ ] Melhorias de UI/UX
* [ ] Otimização de performance (object pooling, particionamento espacial)

### Fase 5 — Funcionalidades Online (Opcional)

* [ ] Cloud save
* [ ] Placar de líderes
* [ ] Analytics e relatório de erros

---

## 🏗️ Arquitetura

O projeto segue uma **estrutura modular**, inspirada nos princípios de ECS (Entity Component System):

```txt
lib/
  game/
    components/
      enemies/        # Subclasses de Enemy: GoblinEnemy, ...
      enemy.dart      # Classe abstrata base com lógica compartilhada
      player.dart
      projectile.dart
      xp_orb.dart
      health_drop.dart
      bone_death.dart
    systems/          # SpawnSystem, XpSystem
    skills/           # SkillOffer
    world/            # GameWorld, TiledBackground
    game.dart         # Orquestrador principal (MyGame)
    game_constants.dart
  assets/
    art/              # Sprites de projéteis e itens
    tiles/            # Tileset do mapa
    characteres/
      goblin/         # Sprites do goblin e bone_death
  main.dart           # App Flutter, overlays de UI
```

### Decisões de Design

* Lógica de gameplay desacoplada da UI via callbacks e `ValueNotifier`
* Mixins `Hostile` e `Damageable` — evitam acoplamento direto entre entidades
* `Enemy` abstrato com getters `spritePath` e `framesCount` — adicionar novo inimigo = novo arquivo com ~15 linhas
* `SpawnSystem` como `Component` no mundo — gerencia spawn e drops de forma autônoma
* `XpSystem` como classe Dart pura com callback `onLevelUp`

---

## ▶️ Como Começar

### Requisitos

* Flutter SDK (>= 3.3)
* Dart SDK
* Android Studio ou VS Code
* Emulador Android ou dispositivo físico

### Instalação

```bash
git clone https://github.com/your-username/aporia-heaven.git
cd aporia-heaven
flutter pub get
```

### Rodando o jogo

```bash
flutter run
```

### Em caso de problemas

```bash
flutter clean
flutter pub get
```

---

## 📱 Plataforma

* Android (alvo principal)
* iOS (planejado)

---

## 🚀 Visão

Aporia Heaven tem como objetivo ser:

* Mecanicamente profundo, porém simples de jogar
* Altamente rejogável
* Orientado a sistemas, não a conteúdo
* Temática filosófica sem ser abstrato

---

## 🧩 Nota Final

> "O jogador não vence.
> O sistema simplesmente permite que ele dure mais."

---

---

# 🜂 **Aporia Heaven** *(English)*

> *"Between chaos and order, survival is not certainty — it is contradiction."*

**Aporia Heaven** is a minimalist, fast-paced roguelike inspired by games like Vampire Survivors, blending philosophical themes with survival mechanics.
Each run is a confrontation between entropy and control — where the player evolves, adapts, and inevitably falls.

---

## 🎮 Overview

Aporia Heaven is a **2D top-down survival roguelike** built with:

* Flutter
* Flame

The core gameplay loop revolves around:

* Surviving increasingly difficult enemy waves
* Collecting experience and leveling up
* Choosing upgrades on level-up
* Lasting as long as possible

---

## 🧠 Core Concept

Inspired by the philosophical idea of **aporia** (a state of puzzlement or impasse), the game explores:

* The illusion of control
* Endless progression vs inevitable defeat
* Chaos as a system

Mechanically, this translates into:

* Scaling difficulty
* Emergent builds
* Unpredictable survival scenarios

---

## ⚙️ Current Implementation (Prototype)

The current version is a **gameplay prototype**, focused on validating the core loop.

### ✅ Implemented Features

**Player**
* Animated pixel art sprite (idle, right, left, down movement)
* Automatic sprite mirroring when moving left
* Movement via virtual joystick (mobile) and keyboard (WASD / arrow keys)
* Health system with color-coded HP bar in HUD
* Damage flash (red tint over sprite, no generic rectangle)
* Auto-attack: flame projectile fired automatically at the nearest enemy

**Enemies**
* Inheritance-based enemy architecture — abstract `Enemy` base + subclasses (`GoblinEnemy`)
* Animated goblin sprite with directional mirroring
* Individual HP bar per enemy (mirror-compensated to always fill left-to-right)
* Simple follow AI with map boundary clamping
* **Giant goblin mini-boss** (3× player size): spawns every 10 seconds, 150 HP, 80% of player speed

**Projectiles**
* Animated flame sprite (4 frames)
* Correct rotation aligned to fire direction
* Continuous collision detection (CCD) via raycast to prevent tunneling

**XP & Level-up System**
* XP orbs with 3 visual tiers: blue diamond (≤20 XP), purple circle (≤30 XP), orange with ring (>30 XP)
* Health drop (heart) with 10% chance — restores 4 HP
* Skill selection screen on level-up (3 cards)
* Available skill: **Projectile Speed** — progressively reduces attack cooldown
* Mini-boss special drops: 1 guaranteed health + 5 × 100 XP orbs + 1 instant full level

**Enemy Death**
* `bone_death` sprite on death (size proportional to enemy — mini-boss leaves a bigger pile)
* Smooth fade out over 1.5s, removed after 5s

**HUD**
* MM:SS game timer (tabular/fixed-width font)
* Current level, HP bar and XP bar
* Expandable "Magias" (Spells) panel: lists collected skills with level — pauses the game when open
* Pause button in top-right corner

**Game Flow**
* Screens: Menu, HUD, Pause, Game Over, Level-up
* Game starts paused — engine only begins when player presses "Play"
* Quit properly pauses the engine before restarting

**Technical**
* `FilterQuality.none` on all sprites for pixel-perfect rendering
* Tileset background map with camera bounds
* Wave-based spawn system (3 initial + 3 every 3 seconds)

---

## 🚧 Roadmap

### Phase 1 — Core Gameplay ✅ (in progress)

* [x] Collision system (player vs enemies, projectiles vs enemies)
* [x] Health system
* [x] Auto-attack with animated projectiles
* [x] XP and level-up system
* [x] Animated sprites for player, enemies, and projectiles
* [x] Mini-boss with special drops
* [x] Game timer in HUD
* [x] Extensible enemy architecture (inheritance)
* [ ] More enemy types
* [ ] More skills and build variations
* [ ] Difficulty scaling over time

### Phase 2 — Progression

* [ ] Meta progression (gold, unlocks)
* [ ] Data-driven skills and abilities
* [ ] Equipment system
* [ ] Save system

### Phase 3 — World & Content

* [ ] Real tilemap integration (via Tiled)
* [ ] Multiple maps / biomes
* [ ] Enemy variety with unique behaviors
* [ ] Boss stage encounters

### Phase 4 — Polish & UX

* [ ] Visual effects (particles, hit impact)
* [ ] Sound and music
* [ ] UI/UX improvements
* [ ] Performance optimization (object pooling, spatial partitioning)

### Phase 5 — Online Features (Optional)

* [ ] Cloud save
* [ ] Leaderboards
* [ ] Analytics and crash reporting

---

## 🏗️ Architecture

The project follows a **modular structure** inspired by ECS (Entity Component System) principles:

```txt
lib/
  game/
    components/
      enemies/        # Enemy subclasses: GoblinEnemy, ...
      enemy.dart      # Abstract base class with shared logic
      player.dart
      projectile.dart
      xp_orb.dart
      health_drop.dart
      bone_death.dart
    systems/          # SpawnSystem, XpSystem
    skills/           # SkillOffer
    world/            # GameWorld, TiledBackground
    game.dart         # Main orchestrator (MyGame)
    game_constants.dart
  assets/
    art/              # Projectile and item sprites
    tiles/            # Map tileset
    characteres/
      goblin/         # Goblin sprites and bone_death
  main.dart           # Flutter app, UI overlays
```

### Key Design Decisions

* Gameplay logic decoupled from UI via callbacks and `ValueNotifier`
* `Hostile` and `Damageable` mixins — avoids direct coupling between entities
* Abstract `Enemy` with `spritePath` and `framesCount` getters — adding a new enemy type = one new file, ~15 lines
* `SpawnSystem` as a `Component` in the world — autonomously manages spawning and drops
* `XpSystem` as a plain Dart class with an `onLevelUp` callback

---

## ▶️ Getting Started

### Requirements

* Flutter SDK (>= 3.3)
* Dart SDK
* Android Studio or VS Code
* Android Emulator or physical device

### Installation

```bash
git clone https://github.com/your-username/aporia-heaven.git
cd aporia-heaven
flutter pub get
```

### Running the Game

```bash
flutter run
```

### If you encounter issues

```bash
flutter clean
flutter pub get
```

---

## 📱 Platform

* Android (primary target)
* iOS (planned)

---

## 🚀 Vision

Aporia Heaven aims to be:

* Mechanically deep, yet simple to play
* Highly replayable
* System-driven rather than content-heavy
* Philosophically themed without being abstract

---

## 🧩 Final Note

> "The player does not win.
> The system simply allows them to last longer."

---
