# 🎮 ROGUE - The Ultimate R Dungeon Crawler

**A feature-complete, terminal-native rogue-like game written entirely in R!**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/Made%20with-R-blue.svg)](https://www.r-project.org/)

---

## 🌟 Overview

**ROGUE** is a fully-featured procedurally generated dungeon crawler that proves R can create deep, engaging games beyond data analysis. With **50+ gameplay systems**, **6000+ lines of code**, and hundreds of hours of content, this is the most comprehensive CLI game ever built in R.

### Key Features at a Glance

- ⚔️ **8 Character Classes** with unique abilities and playstyles
- 🎯 **Daily Challenges** with 10 unique modifiers
- 💎 **Souls Shop** - 20+ permanent upgrades
- 🏆 **25+ Achievements** with soul rewards
- 📊 **Persistent Leaderboards** (global + daily)
- 🔥 **Status Effects** system (8 types)
- ✨ **Item Rarities** (Common → Legendary) with procedural generation
- 🏠 **7 Special Room Types** (Shop, Shrine, Treasure, etc.)
- 🪤 **8 Trap Types** with search/disarm mechanics
- 🗺️ **Minimap** & Auto-Explore
- 🎨 **6 Dungeon Themes** with unique enemies and bosses
- 🎲 **Procedural BSP Dungeon Generation**
- 👁️ **Field of View** with raycasting
- 📈 **Meta-Progression** with 7 permanent unlocks
- 🧙 **5 Special Abilities** with cooldown management
- 💀 **Permadeath** rogue-lite mechanics

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/fabiandistler/Rogue.git
cd Rogue

# Install dependencies (optional for enhanced experience)
R -e "install.packages(c('cli', 'crayon', 'jsonlite'))"

# Run the game
R
> source("rogue.R")
> main()
```

**Requirements:**
- R >= 3.6.0
- Terminal with ANSI color support
- Interactive R session (Rscript not supported)

### First Run

When you start ROGUE, you'll see the main menu:

```
═══════════════════════════════════════════════════════
         🎮 ROGUE - The R Dungeon Crawler 🎮
═══════════════════════════════════════════════════════

MAIN MENU:

  [1] Start New Run
  [2] Daily Challenge
  [3] Souls Shop (0 souls)
  [4] View Leaderboard
  [5] View Achievements
  [Q] Quit
```

---

## 🎮 Game Modes

### Normal Run
- Select from 8 character classes
- Full meta-progression and unlocks
- Earn souls from achievements
- Compete on global leaderboard

### Daily Challenge
- Everyone gets the same seeded dungeon
- One of 10 random modifiers applied
- Separate daily leaderboard
- Extra soul rewards
- New challenge every 24 hours

---

## ⚔️ Character Classes

Choose your playstyle from 8 unique classes:

| Class | Icon | HP | ATK | DEF | Playstyle |
|-------|------|----|----|-----|-----------|
| **Warrior** | ⚔️ | 120 | 15 | 7 | Balanced fighter, Battle Rage |
| **Rogue** | 🗡️ | 80 | 18 | 3 | High damage, crits, Backstab |
| **Mage** | 🔮 | 70 | 8 | 3 | Spellcaster, +2 skill points |
| **Tank** | 🛡️ | 150 | 8 | 12 | Fortress, HP regen |
| **Ranger** | 🏹 | 100 | 12 | 6 | Versatile, +100% gold |
| **Paladin** | ✨ | 110 | 13 | 8 | Holy knight, lifesteal |
| **Berserker** | 💥 | 60 | 25 | 2 | Glass cannon, Blood Frenzy |
| **Necromancer** | 💀 | 75 | 10 | 4 | Life drain, cursed synergy |

Each class has unique:
- Base stats
- Starting equipment
- Passive ability
- Playstyle flavor

---

## 🔥 Core Gameplay Systems

### Status Effects

8 status effects that affect combat:

- **Poison** ☠ - Damage over time (5 HP/turn, 3 turns)
- **Burn** 🔥 - High DoT (8 HP/turn, 3 turns)
- **Freeze** ❄ - 50% chance to skip turn (2 turns)
- **Bleed** 💉 - Moderate DoT (3 HP/turn, 4 turns)
- **Stun** ⚡ - Cannot act (1 turn)
- **Regeneration** 💚 - Heal over time (5 HP/turn, 5 turns)
- **Strength** 💪 - +10 ATK (3 turns)
- **Protection** 🛡 - +5 DEF (3 turns)

### Item System

**4 Rarity Tiers:**
- Common (gray) - 70% drop rate
- Uncommon (green) - 20% drop rate, 1.3x stats
- Rare (blue) - 8% drop rate, 1.6x stats
- Legendary (magenta) - 2% drop rate, 2.0x stats

**Procedural Item Generation:**
- 21 weapon prefixes (Flaming, Freezing, Vampiric, etc.)
- 16 armor prefixes (Sturdy, Enchanted, Spiked, etc.)
- 16 suffixes per type (of Power, of the Warrior, etc.)
- Hundreds of possible combinations
- Dynamic stat scaling by level

**Example Items:**
- "Flaming Sword of Power" (+15 DMG, 30% burn chance, +3 bonus)
- "Heavy Dragon Armor of the Titan" (+12 DEF, fire resist, +HP)

### Special Rooms

7 unique room types with special mechanics:

| Room | Icon | Effect |
|------|------|--------|
| **Shop** | 🛒 | Buy weapons, armor, potions |
| **Shrine** | ⛪ | Random blessing (health/strength/skill) |
| **Treasure** | 💎 | Guaranteed rare+ loot |
| **Challenge** | ⚔️ | Fight waves → legendary reward |
| **Fountain** | ⛲ | Full heal + status cleanse |
| **Altar** | 🔮 | Trade HP for power |
| **Library** | 📚 | +2 skill points |

### Traps

8 trap types with varying effects:

- Spike Trap ^ - 15+ DMG
- Arrow Trap → - 20+ DMG
- Poison Gas ☁ - Poison status
- Fire Trap 🔥 - Burn status + damage
- Ice Trap ❄ - Freeze status
- Net Trap 🕸 - Stun
- Teleport Trap 🌀 - Random teleport
- Alarm Trap 🔔 - Alert all enemies

**Mechanics:**
- Search (f) to detect nearby traps
- 50% chance to disarm successfully
- Trap density increases with level

### Field of View

Advanced raycasting FOV system:
- 360-degree visibility
- 7-tile radius (10 with Dungeon Mapper)
- Explored tiles remain visible (dimmed)
- Unexplored areas hidden
- Dynamic lighting based on position

---

## 🏆 Meta-Progression & Rewards

### Achievements (25+)

Earn souls by completing achievements:

**Combat:**
- First Blood (1 kill) - 10 souls
- Slayer (50 kills) - 50 souls
- Boss Hunter (5 bosses) - 100 souls

**Progression:**
- First Victory - 500 souls
- Speedrunner (win <100 turns) - 300 souls

**Challenge:**
- Glass Cannon (win <20 HP) - 400 souls
- Pacifist (level 3 no kills) - 250 souls
- Minimalist (win no items) - 500 souls

**Special:**
- Completionist (all achievements) - 1000 souls

### Souls Shop

Spend souls on permanent upgrades:

**Stats (Stackable):**
- +10 Max HP (50 souls, max 10)
- +2 Attack (75 souls, max 10)
- +1 Defense (60 souls, max 10)

**Resources:**
- +50 Starting Gold (100 souls)
- +1 Starting Potion (120 souls)

**Passive Abilities:**
- Life Steal 10% (400 souls)
- Critical Strikes 10% (350 souls)
- Thorns 10 DMG (250 souls)
- Evasion 10% (300 souls)

**Special:**
- Gold Magnet +50% (500 souls)
- Better Loot Quality (600 souls)
- Trap Immunity 50% (400 souls)

**Ultimate:**
- Second Chance (revive once) - 1000 souls
- Berserker Mode (+50% DMG) - 800 souls
- Legendary Start - 1500 souls

### Classic Meta-Progression

7 permanent unlocks earned through play:

1. **Warrior Start** (50 kills) - +20 HP, +5 ATK
2. **Treasure Hunter** (100 kills) - +50% gold
3. **Survivor** (30 kills) - Start with 2 potions
4. **Weapon Master** (75 kills) - Better starting weapon
5. **Armor Expert** (75 kills) - Better starting armor
6. **Dungeon Mapper** (150 kills) - Increased FOV
7. **Boss Slayer** (10 bosses) - +20% damage vs bosses

---

## 🎯 Daily Challenges

Compete globally with seeded daily runs!

### 10 Challenge Modifiers

1. **Glass Cannon** - 50% HP, 200% damage
2. **Tank Mode** - 200% HP & DEF, 50% damage
3. **Speed Run** - 100 turn limit, bonus souls
4. **Hoarder** - 500% gold, 10x item costs
5. **Minimalist** - No equipment, +100 stats
6. **Trap Master** - 3x traps, disarm bonuses
7. **Boss Rush** - Boss every level, 3x rewards
8. **Cursed Run** - All cursed items, 3x souls
9. **Pacifist** - Can't attack, 1000 soul reward
10. **Lucky** - Only legendary drops

Each day features a new modifier and dungeon layout. Everyone plays the same seed - compete for the highest score!

---

## 🎲 Dungeon Features

### Procedural Generation

- **BSP Algorithm** - Organic room layouts
- **6 Themes** - Unique every 2 levels
- **Dynamic Difficulty** - Scales with level
- **Connected Rooms** - L-shaped corridors
- **Boss Levels** - Every 3 levels

### Themes

| Theme | Enemies | Boss |
|-------|---------|------|
| Dark Dungeon | Goblin, Orc, Troll | Dragon |
| Ancient Crypt | Skeleton, Ghost, Wraith | Lich |
| Volcanic Depths | Fire Imp, Magma Beast, Ifrit | Fire Lord |
| Frozen Caverns | Ice Sprite, Frost Giant, Wendigo | Yeti King |
| Twisted Grove | Boar, Treant, Dryad | Elder Treant |
| Cursed Temple | Cultist, Gargoyle, Demon | Archfiend |

### Enemies

- **Dynamic Scaling** - Stats increase with level
- **Smart AI** - Chase within 8 tiles, random otherwise
- **Bosses** - 3x HP, guaranteed legendary loot
- **Themed Names** - Match dungeon environment
- **Status Effects** - Can be poisoned, frozen, etc.

---

## 🕹️ Controls

### Movement
- `w/a/s/d` - Move up/left/down/right
- `5w` or `10d` - Multi-step movement
- `o` - Auto-explore (BFS pathfinding)

### Actions
- `e` - Interact (special rooms, items)
- `f` - Search for traps
- `1-5` - Use abilities

### Menus
- `i` - Inventory
- `k` - Abilities menu
- `m` - Toggle minimap
- `p` - Meta-progression stats
- `v` - View achievements
- `b` - View leaderboard
- `?` - Help screen
- `q` - Quit

---

## 🏅 Leaderboards

### Global Leaderboard
- Top 100 all-time scores
- Tracks: Level, Kills, Gold, Turns, Win/Loss
- Score formula: Level×1000 + Kills×10 + Gold + Speed Bonus
- Personal best tracking

### Daily Leaderboard
- Separate board per day
- Same seed for fair competition
- Challenge modifier displayed
- Attempt tracking

---

## 🛠️ Technical Details

### Architecture

```
rogue.R              # Main entry point & game loop
setup.R              # Dependency installer
src/
  ├── game_state.R            # Core state management
  ├── dungeon_gen.R           # BSP generation
  ├── combat.R                # Combat & enemy AI
  ├── fov.R                   # Raycasting FOV
  ├── themes.R                # Dungeon themes
  ├── abilities.R             # Special abilities
  ├── meta_progression.R      # Persistent unlocks
  ├── renderer.R              # Terminal rendering
  ├── input.R                 # Input handling
  ├── status_effects.R        # Status system
  ├── items_extended.R        # Procedural items
  ├── auto_explore.R          # BFS exploration
  ├── achievements.R          # Achievement tracking
  ├── leaderboard.R           # High scores
  ├── special_rooms.R         # Special room types
  ├── traps.R                 # Trap system
  ├── minimap.R               # Tactical overview
  ├── daily_challenges.R      # Daily runs
  ├── character_classes.R     # Class system
  └── souls_shop.R            # Meta-currency shop
```

### Code Statistics

- **Total Lines**: ~6000+
- **Functions**: 200+
- **Modules**: 22
- **Features**: 50+
- **Dependencies**: Optional (cli, crayon, jsonlite)
- **Performance**: <50ms per frame

### Algorithms

- **BSP Dungeon Generation** - O(n) where n = rooms
- **Raycasting FOV** - O(360 × radius)
- **BFS Pathfinding** - O(V + E) for auto-explore
- **Enemy AI** - Manhattan distance heuristic

---

## 📦 Dependencies

### Core (Zero Dependencies)
The game runs on **pure base R** with zero dependencies!

### Optional (Enhanced Experience)
- `cli` (3.6.0+) - Modern terminal UI, progress bars
- `crayon` (1.5.0+) - Better color support
- `jsonlite` (1.8.0+) - Human-readable save files
- `keypress` (1.3.0+) - Real-time input (future)

Install with:
```r
install.packages(c("cli", "crayon", "jsonlite"))
```

Or use the included setup script:
```r
source("setup.R")
```

---

## 🎯 Win Conditions & Objectives

**Main Goal**: Reach level 10 to escape the dungeon

**Secondary Goals**:
- Unlock all 7 meta-progression bonuses
- Complete all 25+ achievements
- Earn 1000+ souls for shop upgrades
- Top the leaderboard
- Complete daily challenges
- Master all 8 character classes

**Average Run Time**:
- First-time player: 45-60 minutes
- Experienced player: 15-30 minutes
- Speedrun (with practice): <100 turns

---

## 💡 Pro Tips

**Early Game:**
- Focus on unlocking Treasure Hunter first (+50% gold)
- Auto-explore (o) saves time in empty areas
- Search (f) before entering new rooms
- Multi-step movement stops at enemies automatically

**Mid Game:**
- Save abilities for boss fights
- Visit every special room you find
- Prioritize legendary items
- Use the minimap (m) for strategy

**Late Game:**
- Stack meta-progression + soul shop upgrades
- Experiment with different classes
- Try daily challenges for extra souls
- Complete achievements for permanent power

**Meta-Progression:**
- Souls are precious - spend wisely
- Start with stat upgrades for consistent power
- Ultimate upgrades are game-changing
- Combine class + unlocks + shop for maximum power

---

## 🐛 Known Issues & Limitations

- Rscript mode not supported (use interactive R)
- Requires ANSI color support
- `readline()` requires Enter key (no real-time input)
- Large entity counts may slow rendering
- Save files are RDS format (not portable across R versions)

---

## 🚀 Future Enhancements

- [ ] Real-time input with `keypress`
- [ ] Animated transitions
- [ ] More character classes
- [ ] Multiplayer co-op mode
- [ ] Sound effects (ASCII-based)
- [ ] CRAN package submission
- [ ] WebAssembly port
- [ ] Mod support (custom themes/items)

---

## 📄 License

**MIT License** - Do whatever you want!

Copyright (c) 2025 Fabian Distler

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software...

---

## 🙏 Credits & Inspiration

**Developed by**: Fabian Distler
**Powered by**: R Programming Language

**Inspired by classic roguelikes**:
- Rogue (1980) - The original
- NetHack - Depth and complexity
- Dungeon Crawl Stone Soup - Modern polish
- Hades - Meta-progression design
- Binding of Isaac - Item synergies

**Proof that R is not just for data science** 📊➡️🎮

---

## 📞 Support & Community

**Found a bug?** Open an issue on GitHub
**Want to contribute?** Pull requests welcome!
**Questions?** Check the in-game help (?)

**Star this repo** if you enjoyed ROGUE! ⭐

---

## 🎉 Final Stats

After implementing **EVERYTHING**:

- 📝 **6000+ lines of code**
- 🎮 **50+ gameplay features**
- ⚔️ **8 character classes**
- 🎯 **10 daily challenge modifiers**
- 💎 **20+ soul shop upgrades**
- 🏆 **25+ achievements**
- 🎨 **6 dungeon themes**
- 🔥 **8 status effects**
- ✨ **Hundreds of procedural items**
- 🏠 **7 special room types**
- 🪤 **8 trap types**
- 🎲 **Infinite replayability**

---

**Ready to descend?**

```r
source("rogue.R")
main()
```

**Every death makes you stronger. Good luck, adventurer!** 💀🎮
