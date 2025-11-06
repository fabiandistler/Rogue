# ROGUE - A Rogue-lite Game in Pure R

Ein prozedural generierter Dungeon-Crawler komplett in R implementiert!

## Features

### Core Rogue-lite Mechanics
- **Prozedurales Level-Design**: BSP-Algorithmus generiert unique Dungeons
- **Permadeath**: Jeder Tod ist endgültig
- **Level-Progression**: Erreiche Level 10 um zu gewinnen
- **Turn-based Combat**: Taktische Kämpfe gegen verschiedene Gegner

### Gameplay-Features
- **Dungeon-Exploration**: Erkunde prozedural generierte Räume und Korridore
- **Combat-System**: Kämpfe gegen Goblins, Orks und Trolle
- **Loot-System**: Sammle Gold, Waffen, Rüstungen und Tränke
- **Enemy AI**: Gegner verfolgen dich oder bewegen sich zufällig
- **Item-Management**: Rüste bessere Ausrüstung aus
- **Progressive Difficulty**: Mehr Gegner in tieferen Leveln

### Technische Features
- **Pure R**: Keine externen Dependencies außer base R
- **Terminal-basiert**: Läuft in jedem Terminal mit ANSI-Farbunterstützung
- **Seed-basiert**: Reproduzierbare Runs möglich
- **Modulare Architektur**: Sauber getrennte Komponenten

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/Rogue.git
cd Rogue

# Keine weiteren Dependencies nötig - pure R!
```

## Wie man spielt

### Start
```bash
# Aus dem Terminal
Rscript rogue.R

# Oder in R
source("rogue.R")
main()
```

### Steuerung
- `w` - Nach oben bewegen
- `s` - Nach unten bewegen
- `a` - Nach links bewegen
- `d` - Nach rechts bewegen
- `i` - Inventar anzeigen
- `q` - Spiel beenden

### Spielziel
- Erreiche Level 10 um zu gewinnen
- Überlebe gegen zunehmend schwierigere Gegnerwellen
- Sammle Gold und bessere Ausrüstung

### Spielelemente
- `@` - Du (Spieler)
- `g` - Goblin (20 HP, 5 ATK)
- `o` - Orc (40 HP, 8 ATK)
- `T` - Troll (60 HP, 12 ATK)
- `!` - Heiltrank (+30 HP)
- `$` - Gold
- `/` - Waffe
- `[` - Rüstung
- `>` - Treppe zum nächsten Level
- `#` - Wand
- `.` - Boden

## Architektur

```
rogue.R           # Main entry point & game loop
src/
  ├── game_state.R   # State management, player, items
  ├── dungeon_gen.R  # BSP-based procedural generation
  ├── combat.R       # Combat system & enemy AI
  ├── renderer.R     # Terminal rendering with colors
  └── input.R        # Input handling
```

### Technische Details

**Dungeon-Generierung**:
- Binary Space Partitioning (BSP) für natürliche Raumaufteilung
- Rekursive Container-Splits für organische Level
- L-förmige Korridore verbinden alle Räume

**Combat-System**:
- Damage = ATK + Weapon - Enemy Defense ± Random(2)
- Enemy AI: Verfolge Spieler wenn Distanz ≤ 8, sonst zufällige Bewegung
- 30% Chance auf Item-Drop bei Enemy-Tod

**State Management**:
- Alle Game-State in nested lists
- Seed-basiert für reproduzierbare Runs
- Message-Log für Kampf-Feedback

## Erweiterungsmöglichkeiten

### Easy Wins
- [ ] Mehr Enemy-Typen
- [ ] Mehr Item-Varianten
- [ ] Sound-Effekte (via `system("afplay")` on Mac)
- [ ] Highscore-Persistierung

### Medium Challenges
- [ ] Field-of-View (FOV) Algorithmus
- [ ] Hunger-System
- [ ] Zauber/Magic-System
- [ ] Boss-Fights

### Hard Mode
- [ ] Shiny-basierte GUI
- [ ] Multiplayer (asynchron)
- [ ] Save/Load-System
- [ ] Meta-Progression (Unlocks zwischen Runs)

## Performance

- Optimiert für Terminals bis 80x24
- < 100ms Render-Zeit pro Frame
- Minimale Memory-Footprint
- Keine externe Dependencies

## Entwickelt mit

- **R** - Die einzige Programmiersprache die du brauchst
- **ANSI Escape Codes** - Für Terminal-Farben
- **Algorithmen**:
  - BSP (Binary Space Partitioning) für Dungeons
  - A* könnte für bessere Enemy AI genutzt werden
  - Breadth-First Search für Korridore

## Lizenz

MIT License - Do whatever you want!

## Credits

Entwickelt als Beweis dass R nicht nur für Data Science ist.

Inspiriert von klassischen Roguelikes wie:
- Rogue (1980)
- NetHack
- Dungeon Crawl Stone Soup

---

**Pro-Tip**: Nutze `set.seed()` in `init_game_state()` für reproduzierbare Challenge-Runs!
