# Design Document - ROGUE

## Vision

Build a complete Rogue-lite game in **pure R** to prove that R can do more than just data science.

## Core Pillars

1. **Pure R** - No external dependencies
2. **True Rogue-lite** - Procedural generation, permadeath, meta-progression ready
3. **Turn-based** - Perfect fit for R's execution model
4. **Terminal-first** - Classic roguelike feeling

## Architecture

### Module Overview

```
┌─────────────┐
│   rogue.R   │  Main game loop
└──────┬──────┘
       │
       ├──────────────┬──────────────┬──────────────┬──────────────┐
       │              │              │              │              │
┌──────▼──────┐ ┌────▼─────┐ ┌──────▼──────┐┌──────▼──────┐┌──────▼──────┐
│ game_state  │ │ dungeon  │ │   combat    ││  renderer   ││   input     │
│             │ │   _gen   │ │             ││             ││             │
└─────────────┘ └──────────┘ └─────────────┘└─────────────┘└─────────────┘
```

### Data Structures

**Game State** (nested list):
```r
state <- list(
  player = list(x, y, hp, max_hp, attack, defense, gold, inventory, weapon, armor),
  enemies = list(list(x, y, hp, attack, defense, type, alive, id), ...),
  items = list(list(x, y, type, effect, value, picked, id), ...),
  map = matrix("#", nrow, ncol),
  rooms = list(list(x1, y1, x2, y2, center_x, center_y), ...),
  stairs_pos = list(x, y),
  level = integer,
  running = logical,
  player_acted = logical,
  message_log = character(),
  stats = list(kills, items_collected, damage_dealt, damage_taken),
  seed = integer
)
```

## Game Loop

```
┌─────────────────────────────────────┐
│  Initialize game state              │
│  - Generate dungeon (BSP)           │
│  - Spawn player, enemies, items     │
└──────────────┬──────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ while (state$running)                │
│ ┌────────────────────────────────┐   │
│ │ 1. Render game                 │   │
│ │ 2. Get player input            │   │
│ │ 3. Process player action       │   │
│ │ 4. Process enemy turns         │   │
│ │ 5. Check win/lose conditions   │   │
│ └────────────────────────────────┘   │
└──────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Game Over - Show stats              │
└──────────────────────────────────────┘
```

## Algorithms

### Dungeon Generation - Binary Space Partitioning (BSP)

1. Start with full map as root container
2. Recursively split container:
   - Choose random split direction (horizontal/vertical)
   - Prefer split that keeps containers roughly square
   - Stop when container too small or max depth reached
3. Create room in each leaf container:
   - Random size within container bounds
   - Random position within container
4. Connect rooms with L-shaped corridors

**Complexity**: O(n) where n = number of rooms (max 2^depth)

### Enemy AI

**Decision Tree**:
```
Distance to player = Manhattan(enemy, player)

if distance == 1:
    ATTACK
else if distance <= 8:
    MOVE_TOWARDS_PLAYER
        - Try primary direction (larger axis)
        - If blocked, try secondary direction
else:
    MOVE_RANDOM
```

**Pathfinding**: Simple greedy (could be upgraded to A*)

### Combat System

```
damage = base_attack + weapon_bonus - enemy_defense + random(-2, 2)
damage = max(1, damage)  # Always at least 1 damage
```

## Rendering

### Field of View
- Current: Simple radius-based (10 tiles)
- Future: Could implement ray-casting FOV

### Color Scheme
- Player: Cyan (`\033[1;36m`)
- Enemies: Red (`\033[1;31m`)
- Items: Yellow (`\033[1;33m`)
- Stairs: Green (`\033[1;32m`)
- Walls: Gray (`\033[0;37m`)
- Floor: Dark gray (`\033[0;90m`)

### UI Layout
```
=== ROGUE - Level X ===

[Visible map 21x21 centered on player]

HP: [====================] 100/100
ATK: 10 (+5 weapon)  DEF: 5 (+2 armor)  Gold: 50
Enemies: 5  Level: 3  Kills: 12

--- Messages ---
You hit Goblin for 8 damage!
You killed Goblin!
You gained 15 gold!

> [Input prompt]
```

## Balance

### Player Progression
- Base stats: 100 HP, 10 ATK, 5 DEF
- HP heal per level: +20
- Enemy count per level: 5 + level
- Item count per level: 3 + floor(level/2)

### Enemy Types
| Type   | HP | ATK | DEF | XP | Gold Drop |
|--------|----|----|-----|-----|-----------|
| Goblin | 20 | 5  | 2   | 10  | 5-15      |
| Orc    | 40 | 8  | 4   | 20  | 10-25     |
| Troll  | 60 | 12 | 6   | 30  | 15-35     |

### Items
| Item          | Effect      | Value |
|---------------|-------------|-------|
| Health Potion | Heal        | +30   |
| Gold Coin     | Currency    | +10   |
| Steel Sword   | Weapon      | +15   |
| Leather Armor | Defense     | +5    |

## Future Enhancements

### Phase 2 - Core Features
- [ ] Save/Load system (serialize state to RDS)
- [ ] More enemy types with special abilities
- [ ] Equipment slots (rings, amulets)
- [ ] Magic/Spell system
- [ ] Hunger mechanic
- [ ] Traps and secrets

### Phase 3 - Meta-Progression
- [ ] Persistent unlocks between runs
- [ ] Character classes (Warrior, Mage, Rogue)
- [ ] Achievement system
- [ ] Leaderboard (SQLite)

### Phase 4 - Advanced
- [ ] Shiny-based GUI
- [ ] Multiplayer (async, shared leaderboard)
- [ ] Boss fights
- [ ] Special themed levels
- [ ] Music/Sound (system() calls)

### Phase 5 - Polish
- [ ] Better AI (A* pathfinding)
- [ ] Field-of-View algorithm
- [ ] Particle effects (ASCII art)
- [ ] Better procedural generation (cellular automata for caves)
- [ ] Biomes (ice, fire, poison levels)

## Technical Challenges

### Solved
- **Non-blocking input**: Using readline() in turn-based mode (interactive R only)
- **Terminal rendering**: ANSI escape codes
- **State management**: Nested lists work well
- **Procedural generation**: BSP is simple and effective

### Remaining
- **Performance**: Lists are slow for large numbers of entities
  - Solution: Use data.table or matrices for entities
- **Input handling**: Can't get single keypress without external packages
  - Current: readline() requires Enter AND interactive mode
  - Rscript mode not supported due to readline() limitations
  - Future: Could use system() call to stty for single-key input
- **Save/Load**: Need to serialize complex nested lists
  - Solution: saveRDS/readRDS works well

## Testing Strategy

### Manual Testing
- [ ] Can player move in all directions?
- [ ] Do walls block movement?
- [ ] Does combat work correctly?
- [ ] Do items spawn and can be picked up?
- [ ] Do stairs work?
- [ ] Does game end on death?
- [ ] Does game end on victory (level 10)?
- [ ] Does interactive mode detection work?
- [ ] Does Rscript mode show proper error message?

### Unit Testing (Future)
- BSP dungeon generation (all rooms connected?)
- Combat calculations (damage formula)
- Enemy AI (pathfinding correctness)
- Item effects (do they apply correctly?)

## Performance Targets

- **Render time**: < 100ms per frame
- **Memory**: < 50MB total
- **Dungeon gen**: < 1s per level
- **Enemy AI**: < 10ms for all enemies

Current performance on modern hardware: ✅ All targets met

## Code Style

- **Functions**: snake_case
- **Lists**: Named elements
- **Comments**: Clean and descriptive
- **Line length**: ~80 characters
- **No global variables** (except functions)
- **Language**: English for all code and comments

## Known Limitations

1. **Rscript mode not supported**: The game requires an interactive R session because `readline()` doesn't work properly in non-interactive scripts. Users must run via R console or RStudio.

2. **No single-key input**: Players must press Enter after each command (w/a/s/d) because R's `readline()` is line-buffered. True single-key input would require external packages or system calls.

3. **ANSI color requirement**: The game uses ANSI escape codes for colors, which may not work in all terminals (though most modern terminals support them).

## References

- [RogueBasin](http://roguebasin.com/) - Roguelike development wiki
- [BSP Dungeon Generation](http://www.roguebasin.com/index.php?title=Basic_BSP_Dungeon_generation)
- [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code)
- [R readline() documentation](https://stat.ethz.ch/R-manual/R-devel/library/base/html/readline.html)
