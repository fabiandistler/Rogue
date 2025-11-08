# 🎮 Rogue CLI - Feature Map v1.0

## Release Vision
Ein professionelles, Terminal-basiertes Rogue-Like mit moderner CLI-UX, starkem Gameplay-Loop und Langzeitmotivation durch Meta-Progression.

---

## 🎯 Core Philosophy

1. **Terminal First** - Keine GUI, nur Terminal-Excellence
2. **Fast & Responsive** - Jede Aktion <100ms
3. **Deep but Accessible** - 5 Minuten zu lernen, 50 Stunden zu meistern
4. **Modern CLI** - Nutze beste R-Packages für Terminal-UX

---

## 📦 Technology Stack

### Core Packages
- **cli** (v3.6.2) - Terminal UI, Formatierung, Spinner, Progress
- **crayon** (v1.5.2) - Farb-Management (Ersatz für raw ANSI)
- **keypress** (v1.3.0) - Direkte Tastatur-Eingabe ohne Enter
- **R6** (v2.5.1) - OOP für Game State Management (optional)

### Storage
- **jsonlite** (v1.8.8) - Für human-readable Save Files (statt RDS)
- Base R für kritische Performance-Pfade

---

## ✨ Feature Categories

### 🏗️ TIER 0: Foundation (Must Have - Week 1)

#### Package Integration
- [ ] Integriere `cli` Package für alle Ausgaben
- [ ] Ersetze ANSI-Codes durch `crayon` für bessere Kompatibilität
- [ ] Implementiere `keypress` für Echtzeit-Steuerung
- [ ] Entferne alle Shiny-Abhängigkeiten (löschen shiny_app.R)

#### Refactoring für CLI Excellence
- [ ] Ersetze `cat()` durch `cli::cli_*()` Funktionen
- [ ] Implementiere `cli_progress_bar()` für Ladebildschirme
- [ ] Füge `cli_alert_*()` für wichtige Events hinzu
- [ ] Erstelle schöne Boxen mit `cli::boxx()` für Menüs

#### Core Game Loop Optimierung
- [ ] Reduziere Terminal-Flicker (Single Frame Buffer)
- [ ] Implementiere Delta-Rendering (nur Updates, nicht alles)
- [ ] Füge Frame-Rate Limiting hinzu (30 FPS)
- [ ] Optimiere Map-Rendering (nur sichtbare Tiles)

---

### 🎮 TIER 1: Enhanced Gameplay (Must Have - Week 2)

#### Advanced Movement
- [x] Multi-Step Movement (5w, 10d) - **BEREITS IMPLEMENTIERT**
- [ ] Auto-Explore (Taste 'o') - Automatisch erkunden bis Feind
- [ ] Pathfinding-Anzeige (zeige geplanten Pfad)
- [ ] Run-Modus (Shift+Richtung läuft bis Hindernis)

#### Improved Combat
- [x] Turn-based System - **BEREITS IMPLEMENTIERT**
- [x] Enemy AI - **BEREITS IMPLEMENTIERT**
- [ ] Damage Numbers als Animation (floating text)
- [ ] Critical Hits (10% chance, 2x damage)
- [ ] Status Effects (Poison, Burn, Freeze - 3 turns)
- [ ] Combat Log (zeige letzte 5 Combat-Events)

#### Better Items
- [x] Auto-Equip wenn besser - **BEREITS IMPLEMENTIERT**
- [ ] Item Comparison (rot/grün für schlechter/besser)
- [ ] Item Rarities (Common, Uncommon, Rare, Legendary)
- [ ] Item Prefixes/Suffixes (z.B. "Flaming Sword", "Shield of Protection")
- [ ] Consumables (Health Potions, Buff Potions)
- [ ] Inventory UI mit cli::tree()

---

### 🎨 TIER 2: Polish & Feel (Should Have - Week 3)

#### Visual Excellence
- [x] 6 Dungeon Themes - **BEREITS IMPLEMENTIERT**
- [ ] Minimap (10x10 overview in Ecke)
- [ ] Animated Transitions (smooth movement mit cli::cli_progress_step)
- [ ] Particle Effects (ASCII-basiert: *, +, ·)
- [ ] Screen Shake bei Hits (Terminal-Offset)
- [ ] Better FOV-Visualization (Gradient-Darkening)

#### Audio (ASCII-basiert)
- [ ] ASCII Sound Effects (CLANG!, WHOOSH!, *click*)
- [ ] Event Notifications mit cli::cli_alert_*
- [ ] Boss Encounter-Fanfare (große ASCII-Box)

#### UI/UX Improvements
- [ ] Menü-System mit cli::cli_menu()
- [ ] Keyboard Shortcuts Overlay (Taste '?')
- [ ] Tutorial-Modus für neue Spieler
- [ ] Pause-Menü (ESC)
- [ ] Quick-Save/Load (F5/F9)
- [ ] Statistics Screen (Taste 'C')
- [ ] Message Log Review (Taste 'L')

---

### 🏆 TIER 3: Meta-Progression (Should Have - Week 4)

#### Current System (KEEP)
- [x] 7 Permanent Unlocks - **BEREITS IMPLEMENTIERT**
- [x] Persistent Save mit RDS - **BEREITS IMPLEMENTIERT**
- [x] Kill/Boss Counter - **BEREITS IMPLEMENTIERT**

#### Enhancements
- [ ] Upgrade zu JSON-basiertem Save (human-readable)
- [ ] Achievement System (20+ Achievements)
- [ ] Leaderboard (lokale High Scores)
- [ ] Daily Challenge Mode (seeded run)
- [ ] Streak Counter (aufeinanderfolgende Wins)
- [ ] Meta-Currency (Souls) für permanente Upgrades
- [ ] Unlock-Screen mit cli::boxx() Animation

---

### 🔧 TIER 4: Advanced Systems (Nice to Have - Week 5+)

#### Procedural Generation Improvements
- [x] BSP Dungeon Generation - **BEREITS IMPLEMENTIERT**
- [ ] Alternative Layouts (Circular, Cavern, Maze)
- [ ] Special Rooms (Shop, Shrine, Treasure, Challenge)
- [ ] Traps (Spike, Arrow, Teleport)
- [ ] Secret Rooms (Hidden walls)

#### Advanced Combat
- [x] 5 Special Abilities - **BEREITS IMPLEMENTIERT**
- [ ] Combo System (Verkettung von Abilities)
- [ ] Enemy Behaviors (Ranged, Healer, Tank, Assassin)
- [ ] Boss Patterns (Phase-based Attacks)
- [ ] Parry/Dodge Mechanic (Timed Button Press)

#### Character Progression
- [ ] Class System (Warrior, Mage, Rogue)
- [ ] Skill Tree (statt linear unlocks)
- [ ] Perks pro Run (wähle 1 von 3 nach jedem Level)
- [ ] Curse System (Negative Effekte für Vorteile)

#### Content Expansion
- [x] 6 Themes - **BEREITS IMPLEMENTIERT**
- [ ] Erweitere auf 10 Themes
- [ ] 20+ einzigartige Enemies
- [ ] 10+ Boss-Varianten
- [ ] 50+ Items
- [ ] 10+ Ability-Varianten

---

## 🚀 Release Milestones

### Alpha 0.1 - "CLI Foundation" (Week 1)
**Ziel**: Moderne CLI-Experience ohne Shiny
- Alle CLI-Packages integriert
- Shiny vollständig entfernt
- Flicker-freies Rendering
- keypress-basierte Steuerung

**Deliverables**:
- Spielbar in Terminal mit modernen Packages
- Performance: <50ms pro Frame
- Keine Abhängigkeiten zu Shiny

---

### Alpha 0.2 - "Enhanced Gameplay" (Week 2)
**Ziel**: Core Gameplay verbessert
- Auto-Explore
- Status Effects
- Item Rarities
- Consumables

**Deliverables**:
- 2x mehr Gameplay-Depth
- 5+ neue Mechaniken
- Bessere Item-Progression

---

### Beta 0.5 - "Polish & Feel" (Week 3)
**Ziel**: Game Feels Great
- Minimap
- Particle Effects
- Screen Shake
- Menü-System mit cli

**Deliverables**:
- Professionelle UI
- Smooth Animations
- Responsive Menüs

---

### Release Candidate 0.9 - "Meta-Progression" (Week 4)
**Ziel**: Langzeitmotivation
- Achievement System
- Leaderboard
- Daily Challenges
- Meta-Currency

**Deliverables**:
- 20+ Hours Replayability
- Motivierende Progression
- Competitive Element

---

### Release 1.0 - "The Rogue CLI" (Week 5)
**Ziel**: Polished, Complete Game
- Bug Fixes
- Balance Tweaks
- Documentation
- Package für CRAN-Submission vorbereiten

**Deliverables**:
- Production-Ready
- Full Documentation
- Installation Guide
- Marketing Materials (README, Screenshots)

---

## 📊 Success Metrics

### Technical
- [ ] Terminal Render: <50ms per frame
- [ ] Memory: <100MB total
- [ ] Zero dependencies außer: cli, crayon, keypress
- [ ] Cross-platform: Windows, macOS, Linux

### Gameplay
- [ ] First Win: ~30 minutes für erfahrene Spieler
- [ ] Average Run: 10-15 minutes
- [ ] Meta-Unlock: 1-2 unlocks pro Stunde
- [ ] Content: 10+ Stunden bis alle Unlocks

### Quality
- [ ] Zero game-breaking bugs
- [ ] Smooth 30 FPS in Terminal
- [ ] Intuitive controls (5 min Lernzeit)
- [ ] Professional CLI-UX

---

## 🎯 Core Loop (1 Run)

```
Start → Spawn (with Meta-Bonuses)
  ↓
Explore → Fight → Loot → Level Up
  ↓       ↓       ↓       ↓
  └───────┴───────┴───────┘
           ↓
      Boss Fight (every 3 levels)
           ↓
      Descend Stairs
           ↓
      Repeat until Level 10
           ↓
      Win → Meta-Progression++
           ↓
      Restart (stronger)
```

---

## 🔥 Unique Selling Points

1. **Pure R** - Keine Frameworks, nur moderne CLI-Packages
2. **Terminal Native** - Designed für CLI von Grund auf
3. **Fast & Lightweight** - <50ms Frames, <100MB Memory
4. **Deep Meta-Progression** - Stunden von Unlocks
5. **Modern CLI UX** - Nutzt cli/crayon/keypress für beste Experience
6. **Open Source** - MIT License, Community-Beiträge willkommen

---

## 📝 Technical Architecture (Post-Refactor)

### Package Structure
```
Rogue/
├── DESCRIPTION          # Package metadata
├── NAMESPACE           # Exported functions
├── R/
│   ├── main.R         # Entry point: rogue_play()
│   ├── state.R        # R6 Game State Class
│   ├── dungeon.R      # Dungeon Generation
│   ├── combat.R       # Combat System
│   ├── fov.R          # Field of View
│   ├── abilities.R    # Ability System
│   ├── progression.R  # Meta-Progression
│   ├── themes.R       # Dungeon Themes
│   ├── renderer.R     # CLI Renderer (cli + crayon)
│   ├── input.R        # Input Handler (keypress)
│   └── utils.R        # Helper Functions
├── inst/
│   └── themes/        # Theme Definitions (JSON)
└── README.md          # Installation & Usage
```

### Data Flow
```
Input (keypress) → Process Action (state.R)
                         ↓
                   Update State (R6)
                         ↓
                   Render (cli/crayon)
                         ↓
                   Display Terminal
                         ↓
                   Await Input
```

---

## 🛠️ Development Workflow

### Setup
```r
# Install dependencies
install.packages(c("cli", "crayon", "keypress", "jsonlite"))

# Run game
source("rogue.R")
main()
```

### Testing
```r
# Manual testing in terminal
# Later: testthat unit tests
```

### Packaging
```r
# Build package
devtools::build()

# Check package
devtools::check()

# Install locally
devtools::install()

# Then run
library(Rogue)
rogue_play()
```

---

## 🎮 Controls (Final)

### Movement
- `w/a/s/d` - Single step
- `5w`, `10d` - Multi-step
- `o` - Auto-explore
- `Shift+Dir` - Run mode

### Actions
- `e` - Pick up item
- `>` - Descend stairs
- `1-5` - Use ability

### UI
- `?` - Help
- `c` - Character stats
- `i` - Inventory
- `l` - Message log
- `m` - Minimap toggle
- `ESC` - Pause menu
- `F5/F9` - Quick save/load

---

## 📦 Installation (Post-Release)

```r
# From GitHub
devtools::install_github("username/Rogue")

# Or from CRAN (future)
install.packages("Rogue")

# Run
library(Rogue)
rogue_play()
```

---

## 🎉 Post-Release (v1.1+)

### Community Features
- [ ] Mod Support (Custom Themes via JSON)
- [ ] Seed Sharing (Share interesting runs)
- [ ] Replay System (Watch recorded runs)
- [ ] Multiplayer (Async turn-based)

### Content DLC
- [ ] New Classes
- [ ] New Themes
- [ ] New Bosses
- [ ] New Abilities

---

**Last Updated**: 2025-11-07
**Version**: 1.0 Specification
**Status**: Planning Phase
