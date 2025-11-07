# ROGUE - A Rogue-lite Game in Pure R

A fully-featured procedurally generated dungeon crawler with meta-progression, abilities, and terminal-native experience - all implemented in R!

**Pure CLI Excellence!** 🎮

## Features

### Core Rogue-lite Mechanics
- **Procedural Level Design**: BSP algorithm generates unique dungeons
- **Permadeath**: Every death is final
- **Level Progression**: Reach level 10 to win
- **Turn-based Combat**: Tactical battles against various enemies

### Gameplay Features
- **Dungeon Exploration**: Explore procedurally generated rooms and corridors
- **Field of View**: Only see what's in your line of sight - unexplored areas remain dark
- **Combat System**: Fight against themed enemies across multiple biomes
- **Boss Fights**: Face powerful bosses every 3 levels with guaranteed legendary loot
- **Special Abilities**: Unlock and use powerful abilities (Heal, Power Strike, Shield Wall, Whirlwind, Teleport)
- **Skill Tree**: Earn skill points and unlock new abilities
- **Dungeon Themes**: Experience 6 unique dungeon environments (Crypt, Volcano, Ice Cave, Forest, Dungeon, Temple)
- **Meta-Progression**: Persistent unlocks and bonuses that carry between runs
- **Smart Loot System**: Collect gold, weapons, armor, and potions
  - Automatic stat comparison - only equips items if they're better than current gear
  - Clear feedback showing stat improvements
  - No need to manually check equipment stats!
- **Enemy AI**: Enemies chase you or move randomly
- **Item Management**: Equipment is auto-managed intelligently
- **Progressive Difficulty**: More enemies in deeper levels

### Technical Features
- **Pure R**: No external dependencies - just base R
- **Terminal-Native**: Designed for CLI from the ground up
- **ANSI Colors**: Beautiful terminal rendering with color support
- **Seed-based**: Reproducible runs possible
- **Modular Architecture**: Cleanly separated components
- **Persistent Save System**: Meta-progression saved between runs

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/Rogue.git
cd Rogue

# No dependencies needed - pure R!
# Just run the game in an interactive R session
```

## How to Play

```bash
# In R console
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
- **`5w`** - Move 5 steps up (multi-step movement - works with any number!)
- **`10d`** - Move 10 steps right (automatically stops at enemies)
- `i` - Show inventory
- `k` - Open abilities menu
- `m` - View meta-progression stats
- `q` - Quit game

**Pro tip**: Use multi-step movement like `10w` or `5d` to quickly traverse empty corridors!

### Objective
- Reach level 10 to win
- Survive against increasingly difficult enemy waves
- Collect gold and better equipment

### Game Elements
- `@` - You (Player) - Cyan
- Enemy types vary by dungeon theme:
  - **Dark Dungeon**: Goblin, Orc, Troll
  - **Ancient Crypt**: Skeleton, Ghost, Wraith
  - **Volcanic Depths**: Fire Imp, Magma Beast, Ifrit
  - **Frozen Caverns**: Ice Sprite, Frost Giant, Wendigo
  - **Twisted Grove**: Wild Boar, Treant, Dryad
  - **Cursed Temple**: Cultist, Gargoyle, Demon
- Boss characters: `G`, `O`, `W`, `D`, `L`, `F`, `Y`, `E`, `A` (Magenta)
- `!` - Health Potion (+30 HP) - Yellow
- `$` - Gold - Yellow
- `/` - Weapon - Yellow
- `[` - Armor - Yellow
- `>` - Stairs to next level - Green
- `#` - Wall (themed colors)
- `.` - Floor (themed colors)

**Note**: Bosses appear in magenta color and drop legendary weapons and armor!

## Architecture

```
rogue.R              # Main entry point & terminal game loop
src/
  ├── game_state.R         # State management, player, items, bosses
  ├── dungeon_gen.R        # BSP-based procedural generation
  ├── fov.R                # Field of View (FOV) calculation
  ├── themes.R             # Dungeon themes and visual styles
  ├── abilities.R          # Special abilities and skill tree
  ├── meta_progression.R   # Persistent unlocks and bonuses
  ├── combat.R             # Combat system, enemy AI, boss loot
  ├── renderer.R           # Terminal rendering with colors and FOV
  └── input.R              # Input handling
```

### Technical Details

**Dungeon Generation**:
- Binary Space Partitioning (BSP) for natural room layout
- Recursive container splits for organic levels
- L-shaped corridors connect all rooms

**Field of View**:
- Raycasting algorithm reveals only visible tiles
- Explored areas remain dimly visible
- Unexplored areas are completely dark
- 7-tile vision radius (10 tiles with Dungeon Mapper unlock)

**Dungeon Themes**:
- 6 unique themes that rotate every 2 levels
- Each theme has custom colors and enemy types
- Bosses adapt to the current theme

**Abilities System**:
- 5 unlockable abilities with cooldowns:
  - **Healing Surge**: Restore 30+ HP (5 turn cooldown)
  - **Power Strike**: Deal double damage (4 turn cooldown)
  - **Shield Wall**: Block 50% damage for 3 turns (6 turn cooldown)
  - **Whirlwind**: Attack all adjacent enemies (7 turn cooldown)
  - **Tactical Retreat**: Teleport to safety (10 turn cooldown)
- Earn skill points by leveling up and defeating bosses
- Spend points to unlock new abilities

**Meta-Progression**:
- Stats persist between runs (kills, gold, highest level)
- Unlock permanent bonuses by achieving milestones:
  - **Warrior Start**: +20 HP, +5 ATK at start (50 kills)
  - **Treasure Hunter**: +50% gold drops (100 kills)
  - **Survivor**: Start with 2 health potions (30 kills)
  - **Weapon Master**: Better starting weapon (75 kills)
  - **Armor Expert**: Better starting armor (75 kills)
  - **Dungeon Mapper**: Increased FOV range (150 kills)
  - **Boss Slayer**: +20% damage vs bosses (10 boss kills)
- Save file stored at `~/.rogue/meta_progress.rds`

**Combat System**:
- Damage = ATK + Weapon - Enemy Defense ± Random(2)
- Enemy AI: Chase player if distance ≤ 8, otherwise random movement
- 30% chance for item drop on enemy death
- Boss fights every 3 levels with guaranteed legendary loot
- Abilities can dramatically change combat tactics

**State Management**:
- All game state in nested lists
- Seed-based for reproducible runs
- Message log for combat feedback
- Persistent meta-progression across runs

## Feature Status

### ✅ Completed Features
- [x] Field-of-View (FOV) algorithm with raycasting
- [x] Boss fights with themed bosses
- [x] Meta-progression with 7 unlockable bonuses
- [x] Special abilities and skill tree (5 abilities)
- [x] Multiple dungeon themes (6 unique environments)
- [x] Pure R implementation with zero dependencies

### 🚀 Future Enhancements
See `FEATURE_MAP_v1.0.md` for detailed roadmap:
- [ ] Modern CLI packages (cli, crayon, keypress)
- [ ] Enhanced terminal UX with delta-rendering
- [ ] Achievement system and leaderboards
- [ ] More ability types and passive skills
- [ ] Character classes with different starting stats
- [ ] Equipment enchantments and upgrades
- [ ] Advanced procedural generation (special rooms, traps)

## Performance

- Optimized for terminals up to 80x24
- < 100ms render time per frame
- Minimal memory footprint
- No external dependencies

## Built With

- **Pure R** - The only programming language you need
- **ANSI Escape Codes** - For beautiful terminal colors
- **Algorithms**:
  - BSP (Binary Space Partitioning) for dungeons
  - Raycasting for field of view
  - Breadth-First Search for corridors
  - Persistent data storage with RDS files

## License

MIT License - Do whatever you want!

## Credits

Developed as proof that R is not just for data science.

Inspired by classic roguelikes such as:
- Rogue (1980)
- NetHack
- Dungeon Crawl Stone Soup

---

## Pro Tips

- **Multi-Step Movement**: Use commands like `10w` or `5d` to quickly move through empty areas
- **Smart Auto-Equip**: The game automatically compares stats - no need to manually check if items are better!
- **Fast Travel Safety**: Multi-step movement stops automatically when enemies are nearby - safe to use!
- **Unlock Synergies**: Combine Warrior Start + Weapon Master for a powerful early game
- **Save Abilities**: Use abilities strategically - they're most valuable in boss fights
- **Explore Thoroughly**: More exploration = more loot and experience
- **Meta Grinding**: Focus on unlocking Treasure Hunter early for faster progression
- **Boss Strategy**: Use Shield Wall when fighting bosses to survive longer
- **Reproducible Runs**: Use `set.seed()` in `init_game_state()` for challenge runs
- **Terminal Excellence**: Pure CLI experience optimized for keyboard warriors

## Screenshots

Classic roguelike experience with ANSI colors, atmospheric FOV lighting, and pure terminal excellence.

---

**Remember**: Every death makes you stronger through meta-progression!
