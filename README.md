# ROGUE - A Rogue-lite Game in Pure R

A procedurally generated dungeon crawler completely implemented in R!

## Features

### Core Rogue-lite Mechanics
- **Procedural Level Design**: BSP algorithm generates unique dungeons
- **Permadeath**: Every death is final
- **Level Progression**: Reach level 10 to win
- **Turn-based Combat**: Tactical battles against various enemies

### Gameplay Features
- **Dungeon Exploration**: Explore procedurally generated rooms and corridors
- **Combat System**: Fight against Goblins, Orcs, and Trolls
- **Loot System**: Collect gold, weapons, armor, and potions
- **Enemy AI**: Enemies chase you or move randomly
- **Item Management**: Equip better gear
- **Progressive Difficulty**: More enemies in deeper levels

### Technical Features
- **Pure R**: No external dependencies except base R
- **Terminal-based**: Runs in any terminal with ANSI color support
- **Seed-based**: Reproducible runs possible
- **Modular Architecture**: Cleanly separated components

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/Rogue.git
cd Rogue

# No further dependencies needed - pure R!
```

## How to Play

### Starting the Game
```bash
# In R console (RECOMMENDED)
R
> source("rogue.R")
> main()

# In RStudio
# Open rogue.R and run: source("rogue.R"); main()
```

**Note**: Rscript mode is not supported due to `readline()` limitations. Use interactive R session.

### Controls
- `w` - Move up
- `s` - Move down
- `a` - Move left
- `d` - Move right
- `i` - Show inventory
- `q` - Quit game

### Objective
- Reach level 10 to win
- Survive against increasingly difficult enemy waves
- Collect gold and better equipment

### Game Elements
- `@` - You (Player)
- `g` - Goblin (20 HP, 5 ATK)
- `o` - Orc (40 HP, 8 ATK)
- `T` - Troll (60 HP, 12 ATK)
- `!` - Health Potion (+30 HP)
- `$` - Gold
- `/` - Weapon
- `[` - Armor
- `>` - Stairs to next level
- `#` - Wall
- `.` - Floor

## Architecture

```
rogue.R           # Main entry point & game loop
src/
  ├── game_state.R   # State management, player, items
  ├── dungeon_gen.R  # BSP-based procedural generation
  ├── combat.R       # Combat system & enemy AI
  ├── renderer.R     # Terminal rendering with colors
  └── input.R        # Input handling
```

### Technical Details

**Dungeon Generation**:
- Binary Space Partitioning (BSP) for natural room layout
- Recursive container splits for organic levels
- L-shaped corridors connect all rooms

**Combat System**:
- Damage = ATK + Weapon - Enemy Defense ± Random(2)
- Enemy AI: Chase player if distance ≤ 8, otherwise random movement
- 30% chance for item drop on enemy death

**State Management**:
- All game state in nested lists
- Seed-based for reproducible runs
- Message log for combat feedback

## Extension Possibilities

### Easy Wins
- [ ] More enemy types
- [ ] More item variants
- [ ] Sound effects (via `system("afplay")` on Mac)
- [ ] Highscore persistence

### Medium Challenges
- [ ] Field-of-View (FOV) algorithm
- [ ] Hunger system
- [ ] Magic/Spell system
- [ ] Boss fights

### Hard Mode
- [ ] Shiny-based GUI
- [ ] Multiplayer (async)
- [ ] Save/Load system
- [ ] Meta-progression (unlocks between runs)

## Performance

- Optimized for terminals up to 80x24
- < 100ms render time per frame
- Minimal memory footprint
- No external dependencies

## Built With

- **R** - The only programming language you need
- **ANSI Escape Codes** - For terminal colors
- **Algorithms**:
  - BSP (Binary Space Partitioning) for dungeons
  - A* could be used for better enemy AI
  - Breadth-First Search for corridors

## License

MIT License - Do whatever you want!

## Credits

Developed as proof that R is not just for data science.

Inspired by classic roguelikes such as:
- Rogue (1980)
- NetHack
- Dungeon Crawl Stone Soup

---

**Pro-Tip**: Use `set.seed()` in `init_game_state()` for reproducible challenge runs!
