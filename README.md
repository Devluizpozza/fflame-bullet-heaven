# 🜂 **Aporia Heaven**

> *“Between chaos and order, survival is not certainty — it is contradiction.”*

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
* Collecting experience and gold
* Leveling up and choosing upgrades
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

* Basic game loop using Flame
* Player movement (WASD / Arrow keys)
* Enemy AI (simple follow behavior)
* Fixed camera and resolution
* Procedural grid-based map (tile-like system)
* Initial enemy spawning (3 enemies)

---

# 🚧 Roadmap

## Phase 1 — Core Gameplay

* [ ] Collision system (player vs enemies)
* [ ] Health system
* [ ] Auto-attack mechanics
* [ ] Experience (XP) system
* [ ] Level-up with upgrade selection

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
/lib
  /game
    /components
    /entities
    /systems
    /maps
    /ui
  /data
    /local
    /models
  /services
```

### Key Design Decisions

* Gameplay logic decoupled from UI
* Offline-first persistence
* Data-driven systems (skills, enemies, items)
* Performance-focused (pooling, optimized updates)

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

* Flutter SDK (>= 3.x)
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

> “The player does not win.
> The system simply allows them to last longer.”

---
