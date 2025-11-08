# 🎮 ROGUE - The Ultimate R Dungeon Crawler

**A feature-complete, terminal-native roguelike game written entirely in R!**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/Made%20with-R-blue.svg)](https://www.r-project.org/)

---

## 🌟 Overview

**ROGUE** is a fully-featured procedurally generated dungeon crawler that proves R can create deep, engaging games. With **50+ gameplay systems**, **6000+ lines of code**, and **8 character classes**, this is the most comprehensive CLI game ever built in R.

✨ **NEW:** Real-time input support! No Enter key required with `keypress` package.

**Core Features:**
- ⚔️ **8 Character Classes** with unique abilities
- 🎯 **Daily Challenges** with 10 modifiers & global leaderboard
- 💎 **Souls Shop** - 20+ permanent upgrades
- 🏆 **25+ Achievements** with soul rewards
- 🔥 **8 Status Effects** (Poison, Burn, Freeze, Bleed, etc.)
- ✨ **Item Rarities** (Common → Legendary) with procedural generation
- 🏠 **7 Special Rooms** (Shop, Shrine, Treasure, Challenge, etc.)
- 🪤 **8 Trap Types** with search/disarm mechanics
- 🗺️ **Minimap** & Auto-Explore
- 🎨 **6 Dungeon Themes** with unique enemies/bosses
- 👁️ **Field of View** with raycasting
- 💀 **Permadeath** roguelite mechanics with meta-progression

---

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/fabiandistler/Rogue.git
cd Rogue

# Install dependencies (optional but recommended)
make setup
# OR: R -e "source('setup.R')"

# Start game - pick your favorite method:

# Option 1: Simplest - using Makefile
make play

# Option 2: Using start script
./start.sh

# Option 3: Manual R console
R
> source("rogue.R")
> main()
```

**Requirements:** R >= 3.6.0, ANSI-capable terminal, interactive R session

**Recommended:** Install `keypress` package for real-time input (no Enter key needed!)
```r
install.packages("keypress")
```

---

## 🎮 Game Modes

### 🗡️ Normal Run
- Choose from 8 character classes
- Earn souls through achievements
- Unlock permanent meta-progression bonuses
- Compete on global leaderboard

### 🎯 Daily Challenge
- Seeded dungeon (same for everyone)
- Random modifier (10 types: Glass Cannon, Tank Mode, Speed Run, etc.)
- Separate daily leaderboard
- Extra soul rewards
- Resets every 24 hours

---

## ⚔️ Character Classes

| Class | Icon | HP | ATK | DEF | Special Ability |
|-------|------|----|----|-----|-----------------|
| **Warrior** | ⚔️ | 120 | 15 | 7 | Battle Rage (double damage) |
| **Rogue** | 🗡️ | 80 | 18 | 3 | Backstab (guaranteed crit) |
| **Mage** | 🔮 | 70 | 8 | 3 | +2 starting skill points |
| **Tank** | 🛡️ | 150 | 8 | 12 | HP regeneration |
| **Ranger** | 🏹 | 100 | 12 | 6 | +100% gold drops |
| **Paladin** | ✨ | 110 | 13 | 8 | Lifesteal 15% |
| **Berserker** | 💥 | 60 | 25 | 2 | Blood Frenzy (low HP = high damage) |
| **Necromancer** | 💀 | 75 | 10 | 4 | Life drain attacks |

---

## 🔥 Core Systems

### Status Effects (8 Types)
- **Poison** ☠ - 5 DMG/turn, 3 turns
- **Burn** 🔥 - 8 DMG/turn, 3 turns
- **Freeze** ❄ - 50% skip turn, 2 turns
- **Bleed** 💉 - 3 DMG/turn, 4 turns
- **Stun** ⚡ - Cannot act, 1 turn
- **Regeneration** 💚 - +5 HP/turn, 5 turns
- **Strength** 💪 - +10 ATK, 3 turns
- **Protection** 🛡 - +5 DEF, 3 turns

### Item Rarities & Procedural Generation
**Rarity System:**
- Common (70%) - Base stats
- Uncommon (20%) - 1.3x stats
- Rare (8%) - 1.6x stats
- Legendary (2%) - 2.0x stats

**Procedural Names:**
- 21 weapon prefixes (Flaming, Freezing, Vampiric, etc.)
- 16 armor prefixes (Sturdy, Enchanted, Spiked, etc.)
- 16 suffixes per type (of Power, of the Warrior, etc.)
- Example: "Flaming Dragon Sword of the Titan" (+22 DMG, burn proc)

### Special Rooms (7 Types)

| Room | Icon | Effect |
|------|------|--------|
| **Shop** | 🛒 | Buy equipment & potions |
| **Shrine** | ⛪ | Random blessing (HP/ATK/skills) |
| **Treasure** | 💎 | Guaranteed rare+ loot |
| **Challenge** | ⚔️ | Wave fight → legendary reward |
| **Fountain** | ⛲ | Full heal + cleanse status |
| **Altar** | 🔮 | Trade HP for power |
| **Library** | 📚 | +2 skill points |

### Traps (8 Types)
Spike ^, Arrow →, Poison Gas ☁, Fire 🔥, Ice ❄, Net 🕸, Teleport 🌀, Alarm 🔔
- Search (f) to detect
- 50% disarm chance
- Density increases with level

---

## 🏆 Meta-Progression

### 💎 Souls Shop (20+ Upgrades)
Earn souls from achievements, spend on permanent upgrades:

**Stats (Stackable, max 10):**
- +10 Max HP (50 souls)
- +2 Attack (75 souls)
- +1 Defense (60 souls)

**Passive Abilities:**
- Life Steal 10% (400 souls)
- Critical Strikes 10% (350 souls)
- Thorns 10 DMG (250 souls)
- Evasion 10% (300 souls)
- Gold Magnet +50% (500 souls)

**Ultimate:**
- Second Chance (revive once) - 1000 souls
- Berserker Mode (+50% DMG) - 800 souls
- Legendary Start - 1500 souls

### 🎯 Achievements (25+)
Complete challenges for soul rewards:
- First Blood (1 kill) - 10 souls
- Slayer (50 kills) - 50 souls
- Boss Hunter (5 bosses) - 100 souls
- First Victory - 500 souls
- Glass Cannon (win <20 HP) - 400 souls
- Speedrunner (win <100 turns) - 300 souls
- Completionist (all achievements) - 1000 souls

### 📈 Classic Meta-Progression (7 Unlocks)
Earned through gameplay:
1. **Warrior Start** (50 kills) - +20 HP, +5 ATK
2. **Treasure Hunter** (100 kills) - +50% gold
3. **Survivor** (30 kills) - Start with 2 potions
4. **Weapon Master** (75 kills) - Better starting weapon
5. **Armor Expert** (75 kills) - Better starting armor
6. **Dungeon Mapper** (150 kills) - Increased FOV
7. **Boss Slayer** (10 bosses) - +20% boss damage

---

## 🎲 Dungeon Features

### Themes (6 Types)
Themes change every 2 levels, each with unique enemies and bosses:

| Theme | Enemies | Boss |
|-------|---------|------|
| Dark Dungeon | Goblin, Orc, Troll | Dragon |
| Ancient Crypt | Skeleton, Ghost, Wraith | Lich |
| Volcanic Depths | Fire Imp, Magma Beast, Ifrit | Fire Lord |
| Frozen Caverns | Ice Sprite, Frost Giant, Wendigo | Yeti King |
| Twisted Grove | Boar, Treant, Dryad | Elder Treant |
| Cursed Temple | Cultist, Gargoyle, Demon | Archfiend |

### Generation
- **BSP Algorithm** for organic layouts
- **FOV System** with raycasting (7-tile radius)
- **Boss Levels** every 3 levels
- **Dynamic Difficulty** scaling

---

## 🕹️ Controls

**Real-time Input:** With `keypress` package installed, enjoy instant response - no Enter key needed!

**Movement:** `w/a/s/d` | Multi-step: `5w`, `10d` | Auto-explore: `o`
**Actions:** `e` interact | `f` search traps | `1-5` abilities
**Menus:** `i` inventory | `m` minimap | `k` abilities | `?` help | `q` quit

**Note:** Without keypress, game falls back to readline mode (press Enter after each command)

---

## 🏅 Leaderboards

### Global Leaderboard
- Top 100 all-time scores
- Score = Level×1000 + Kills×10 + Gold + Speed Bonus
- Tracks: Level, Kills, Gold, Turns, Win/Loss

### Daily Leaderboard
- Per-day ranking with same seed
- Challenge modifier displayed
- Fair competition

---

## 🛠️ Technical Details

**Architecture:** 22 modules, 6000+ lines, 200+ functions
**Algorithms:** BSP dungeon gen, raycasting FOV, BFS pathfinding
**Dependencies:** Zero! Runs on pure base R
**Optional packages:**
- `keypress` - Real-time input (NEW!)
- `cli` - Enhanced terminal UI
- `crayon` - Rich color support
- `jsonlite` - Human-readable save files
**Performance:** <50ms per frame

```
src/
  ├── game_state.R            # Core state management
  ├── dungeon_gen.R           # BSP generation
  ├── combat.R                # Combat & AI
  ├── fov.R                   # Raycasting FOV
  ├── character_classes.R     # 8 classes
  ├── daily_challenges.R      # Daily mode
  ├── souls_shop.R            # Meta-currency shop
  ├── achievements.R          # Achievement system
  ├── leaderboard.R           # High scores
  ├── items_extended.R        # Procedural items
  ├── status_effects.R        # Status system
  ├── special_rooms.R         # Special rooms
  ├── traps.R                 # Trap system
  └── ... (9 more modules)
```

---

## 💡 Pro Tips

**Early Game:** Unlock Treasure Hunter first (+50% gold), use auto-explore (o), search for traps (f)
**Mid Game:** Save abilities for bosses, visit all special rooms, prioritize legendary items
**Late Game:** Stack meta-progression + soul shop upgrades, experiment with classes
**Meta:** Complete achievements for souls, combine class + unlocks + shop for max power

---

## 🚀 Future Enhancements

- [x] **Real-time input with `keypress` package** ✨ NEW!
- [ ] Animated transitions
- [ ] Additional character classes
- [ ] Multiplayer co-op mode
- [ ] ASCII sound effects
- [ ] CRAN package submission
- [ ] WebAssembly port for web play
- [ ] Mod support (custom themes/items)

---

## 📄 License

**MIT License** - Copyright (c) 2025 Fabian Distler

---

## 🎉 Stats

- 📝 **6000+ lines of code**
- 🎮 **50+ gameplay features**
- ⚔️ **8 character classes**
- 🎯 **10 daily challenge modifiers**
- 💎 **20+ soul shop upgrades**
- 🏆 **25+ achievements**
- 🎨 **6 dungeon themes**
- 🔥 **8 status effects**
- 🏠 **7 special room types**
- 🎲 **Infinite replayability**

**Proof that R is not just for data science!** 📊➡️🎮

---

**Ready to descend?**

```bash
# Quick start:
make play

# Or:
./start.sh
```

**Every death makes you stronger. Good luck, adventurer!** 💀🎮
