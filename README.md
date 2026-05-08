# 🜂 **Aporia Heaven**

> *"Entre o caos e a ordem, sobreviver não é certeza — é contradição."*

**Aporia Survivors** é um roguelike minimalista e frenético inspirado em jogos como Vampire Survivors, mesclando temas filosóficos com mecânicas de sobrevivência.
Cada run é um confronto entre entropia e controle — onde o jogador evolui, se adapta e inevitavelmente cai.

---

# 🎮 Visão Geral

Aporia Survivors é um **roguelike de sobrevivência 2D top-down** construído com:

* Flutter
* Flame
* Isar

O loop central de gameplay gira em torno de:

* Sobreviver a ondas de inimigos cada vez mais difíceis
* Coletar experiência e evoluir o personagem
* Subir de nível e escolher melhorias
* Desbloquear progressão permanente

Cada run dura até **~20 minutos**, escalando em intensidade ao longo do tempo.

---

# 🧠 Conceito Central

Inspirado na ideia filosófica de **aporia** (um estado de perplexidade ou impasse), o jogo explora:

* A ilusão de controle
* Progressão infinita vs derrota inevitável
* O caos como sistema

Mecanicamente, isso se traduz em:

* Dificuldade com escala infinita
* Builds emergentes
* Cenários de sobrevivência imprevisíveis

---

# ⚙️ Implementação Atual (Protótipo)

A versão atual é um **protótipo inicial de gameplay**, focado em validar o loop central.

### ✅ Funcionalidades Implementadas

* Loop de jogo funcional com Flame
* Movimento do jogador (WASD / Teclas de direção / Joystick virtual)
* IA de inimigos (comportamento de perseguição simples)
* Câmera seguindo o jogador com limites de mapa
* Mapa procedural baseado em grid (sistema tipo tile)
* Sistema de spawn de inimigos em ondas (3 iniciais + 3 a cada 3 segundos)
* Inimigos com cores e formas variadas (retângulo, círculo, triângulo)
* Sistema de colisão (jogador vs inimigos, projéteis vs inimigos)
* Sistema de vida do jogador com barra de HP no HUD
* Auto-ataque: projéteis disparados automaticamente ao inimigo mais próximo
* Suporte a múltiplos projéteis paralelos (desbloqueado ao evoluir)
* Detecção contínua de colisão (CCD) via raycast para evitar tunneling
* Sistema de XP com barra de progresso e levelup
* Poças de sangue ao matar inimigos
* Orbs de XP dropados pelos inimigos (70% de chance)
* Drop de vida (coração) com 10% de chance — recupera 4 HP
* Tela de seleção de habilidade ao subir de nível (3 cartas)
* Habilidade: **Velocidade de Projétil** — reduz cooldown e adiciona projéteis a cada 3 níveis
* HUD com nível, barra de HP e barra de XP
* Tela de menu, pause, game over e levelup
* Jogo inicia pausado — motor só começa quando o jogador pressiona "Jogar"
* Saída do jogo pausa corretamente o motor antes de reiniciar

---

# 🚧 Roadmap

## Fase 1 — Gameplay Central ✅ (em andamento)

* [x] Sistema de colisão (jogador vs inimigos)
* [x] Sistema de vida
* [x] Mecânicas de auto-ataque
* [x] Sistema de experiência (XP)
* [x] Level-up com seleção de melhoria
* [ ] Mais habilidades e variações de builds
* [ ] Escala de dificuldade ao longo do tempo

## Fase 2 — Progressão

* [ ] Meta progressão (ouro, desbloqueios)
* [ ] Sistema de habilidades orientado a dados
* [ ] Sistema de equipamentos
* [ ] Sistema de save usando Isar

## Fase 3 — Mundo & Conteúdo

* [ ] Integração real de tilemaps (via Tiled)
* [ ] Múltiplos mapas / biomas
* [ ] Variedade de inimigos e comportamentos
* [ ] Encontros com chefões (boss)

## Fase 4 — Polimento & UX

* [ ] Efeitos visuais (partículas, feedback)
* [ ] Som e música
* [ ] Melhorias de UI/UX (menus, HUD)
* [ ] Otimização de performance (object pooling, particionamento espacial)

## Fase 5 — Funcionalidades Online (Opcional)

* [ ] Cloud save (via Firebase)
* [ ] Placar de líderes
* [ ] Analytics e relatório de erros

---

# 🏗️ Arquitetura

O projeto segue uma **estrutura modular e escalável**, inspirada nos princípios de ECS (Entity Component System):

```txt
lib/
  game/
    components/       # Entidades: Player, Enemy, Projectile, XpOrb, HealthDrop, Puddle
    systems/          # Lógica: SpawnSystem, XpSystem
    skills/           # Dados de habilidades: SkillOffer
    world/            # Mundo: GameWorld (HasCollisionDetection), TiledBackground
    game.dart         # Orquestrador principal (MyGame)
    game_constants.dart
  assets/
    art/              # Sprites (ex: hearth_life.png)
  main.dart           # App Flutter, overlays de UI (Menu, HUD, Pause, GameOver, LevelUp)
```

### Decisões de Design

* Lógica de gameplay desacoplada da UI via callbacks e `ValueNotifier`
* Interfaces `Hostile` e `Damageable` como mixins — evitam acoplamento direto entre entidades
* `SpawnSystem` como `Component` no mundo — gerencia spawn e drops de forma autônoma
* `XpSystem` como classe Dart pura com callback `onLevelUp`
* Persistência offline com Isar (planejado)
* Sistemas orientados a dados (habilidades, inimigos, itens)

---

# 💾 Estratégia de Persistência

* **Armazenamento local** usando Isar
* Sincronização opcional na nuvem via Firebase

Isso garante:

* Gameplay offline
* Acesso rápido ao estado
* Sistema de progressão escalável

---

# 🎨 Direção de Arte (Planejado)

* Pixel art (grade base 32x32)
* Mapas baseados em tilesets consistentes
* Sprite sheets para animações
* Estilo visual minimalista e legível

Assets iniciais serão obtidos de:

* Kenney
* OpenGameArt

---

# ▶️ Como Começar

## Requisitos

* Flutter SDK (>= 3.3)
* Dart SDK
* Android Studio ou VS Code
* Emulador Android ou dispositivo físico

---

## 📦 Instalação

```bash
git clone https://github.com/your-username/aporia-survivors.git
cd aporia-survivors
flutter pub get
```

---

## ▶️ Rodando o Jogo

```bash
flutter run
```

---

## 🧹 Em caso de problemas

```bash
flutter clean
flutter pub get
```

---

# 📱 Plataforma

* Android (alvo principal)
* iOS (planejado)

---

# 🚀 Visão

Aporia Survivors tem como objetivo ser:

* Mecanicamente profundo, porém simples de jogar
* Altamente rejogável
* Orientado a sistemas, não a conteúdo
* Temática filosófica sem ser abstrato

---

# 🤝 Contribuindo

Contribuições, ideias e feedbacks são bem-vindos.

Sinta-se à vontade para abrir:

* Issues
* Pull requests
* Discussions

---

# 📜 Licença

Este projeto está em desenvolvimento.
A licença será definida em iterações futuras.

---

# 🧩 Nota Final

> "O jogador não vence.
> O sistema simplesmente permite que ele dure mais."

---

---

# 🜂 **Aporia Heaven** *(English)*

> *"Between chaos and order, survival is not certainty — it is contradiction."*

**Aporia Survivors** is a minimalist, fast-paced roguelike inspired by games like Vampire Survivors, blending philosophical themes with survival mechanics.
Each run is a confrontation between entropy and control — where the player evolves, adapts, and inevitably falls.

---

# 🎮 Overview

Aporia Survivors is a **2D top-down survival roguelike** built with:

* Flutter
* Flame
* Isar

The core gameplay loop revolves around:

* Surviving increasingly difficult enemy waves
* Collecting experience and leveling up
* Choosing upgrades on level-up
* Unlocking permanent progression

Each run lasts up to **~20 minutes**, scaling in intensity over time.

---

# 🧠 Core Concept

Inspired by the philosophical idea of **aporia** (a state of puzzlement or impasse), the game explores:

* The illusion of control
* Endless progression vs inevitable defeat
* Chaos as a system

Mechanically, this translates into:

* Infinite scaling difficulty
* Emergent builds
* Unpredictable survival scenarios

---

# ⚙️ Current Implementation (Prototype)

The current version is an **early gameplay prototype**, focused on validating the core loop.

### ✅ Implemented Features

* Functional game loop using Flame
* Player movement (WASD / Arrow keys / Virtual joystick)
* Enemy AI (simple follow behavior)
* Camera following player with map bounds
* Procedural grid-based map (tile-like system)
* Enemy wave spawning (3 initial + 3 every 3 seconds)
* Enemies with varied colors and shapes (rectangle, circle, triangle)
* Collision system (player vs enemies, projectiles vs enemies)
* Player health system with HP bar in HUD
* Auto-attack: projectiles fired automatically at nearest enemy
* Multi-projectile spread support (unlocked on level-up)
* Continuous collision detection (CCD) via raycast to prevent tunneling
* XP system with progress bar and level-up
* Blood puddles on enemy death
* XP orbs dropped by enemies (70% chance)
* Health drop (heart) with 10% chance — restores 4 HP
* Skill selection screen on level-up (3 cards)
* Skill: **Projectile Speed** — reduces cooldown and adds projectiles every 3 levels
* HUD with level, HP bar and XP bar
* Menu, pause, game over and level-up screens
* Game starts paused — engine only begins when player presses "Play"
* Quitting properly pauses the engine before restarting

---

# 🚧 Roadmap

## Phase 1 — Core Gameplay ✅ (in progress)

* [x] Collision system (player vs enemies)
* [x] Health system
* [x] Auto-attack mechanics
* [x] Experience (XP) system
* [x] Level-up with upgrade selection
* [ ] More skills and build variations
* [ ] Difficulty scaling over time

## Phase 2 — Progression

* [ ] Meta progression (gold, unlocks)
* [ ] Skills and abilities system (data-driven)
* [ ] Equipment system
* [ ] Save system using Isar

## Phase 3 — World & Content

* [ ] Real tilemaps integration (via Tiled)
* [ ] Multiple maps / biomes
* [ ] Enemy variety and behaviors
* [ ] Boss encounters

## Phase 4 — Polish & UX

* [ ] Visual effects (particles, feedback)
* [ ] Sound and music
* [ ] UI/UX improvements (menus, HUD)
* [ ] Performance optimization (object pooling, spatial partitioning)

## Phase 5 — Online Features (Optional)

* [ ] Cloud save (via Firebase)
* [ ] Leaderboards
* [ ] Analytics and crash reporting

---

# 🏗️ Architecture

The project follows a **modular and scalable structure**, inspired by ECS (Entity Component System) principles:

```txt
lib/
  game/
    components/       # Entities: Player, Enemy, Projectile, XpOrb, HealthDrop, Puddle
    systems/          # Logic: SpawnSystem, XpSystem
    skills/           # Skill data: SkillOffer
    world/            # World: GameWorld (HasCollisionDetection), TiledBackground
    game.dart         # Main orchestrator (MyGame)
    game_constants.dart
  assets/
    art/              # Sprites (e.g. hearth_life.png)
  main.dart           # Flutter app, UI overlays (Menu, HUD, Pause, GameOver, LevelUp)
```

### Key Design Decisions

* Gameplay logic decoupled from UI via callbacks and `ValueNotifier`
* `Hostile` and `Damageable` as mixins — avoids direct coupling between entities
* `SpawnSystem` as a `Component` in the world — autonomously manages spawning and drops
* `XpSystem` as a plain Dart class with `onLevelUp` callback
* Offline-first persistence with Isar (planned)
* Data-driven systems (skills, enemies, items)

---

# 💾 Persistence Strategy

* **Local-first storage** using Isar
* Optional cloud sync using Firebase

This ensures:

* Offline gameplay
* Fast state access
* Scalable progression system

---

# 🎨 Art Direction (Planned)

* Pixel art (32x32 base grid)
* Consistent tileset-based maps
* Sprite sheets for animations
* Minimalist but readable visual style

Initial assets will be sourced from:

* Kenney
* OpenGameArt

---

# ▶️ Getting Started

## Requirements

* Flutter SDK (>= 3.3)
* Dart SDK
* Android Studio or VS Code
* Android Emulator or physical device

---

## 📦 Installation

```bash
git clone https://github.com/your-username/aporia-survivors.git
cd aporia-survivors
flutter pub get
```

---

## ▶️ Running the Game

```bash
flutter run
```

---

## 🧹 If you encounter issues

```bash
flutter clean
flutter pub get
```

---

# 📱 Platform

* Android (primary target)
* iOS (planned)

---

# 🚀 Vision

Aporia Survivors aims to be:

* Mechanically deep, yet simple to play
* Highly replayable
* System-driven rather than content-heavy
* Philosophically themed without being abstract

---

# 🤝 Contributing

Contributions, ideas, and feedback are welcome.

Feel free to open:

* Issues
* Pull requests
* Discussions

---

# 📜 License

This project is currently under development.
License will be defined in future iterations.

---

# 🧩 Final Note

> "The player does not win.
> The system simply allows them to last longer."

---
