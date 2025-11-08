# ============================================================================
# Character Class System
# ============================================================================
# Different starting classes with unique stats, abilities, and playstyles

# ============================================================================
# Class Definitions
# ============================================================================

get_character_classes <- function() {
  list(
    warrior = list(
      name = "Warrior",
      icon = "⚔️",
      description = "High HP and attack, moderate defense",
      flavor = "A battle-hardened fighter who excels in direct combat",
      stats = list(
        hp = 120,
        attack = 15,
        defense = 7
      ),
      starting_weapon = list(
        name = "Warrior's Blade",
        damage = 8,
        type = "weapon"
      ),
      starting_armor = list(
        name = "Iron Armor",
        defense = 4,
        type = "armor"
      ),
      passive_ability = list(
        name = "Battle Rage",
        description = "Deal 20% more damage when below 50% HP"
      ),
      starting_gold = 50
    ),

    rogue = list(
      name = "Rogue",
      icon = "🗡️",
      description = "High damage, low HP, bonus critical hits",
      flavor = "A swift assassin who strikes from the shadows",
      stats = list(
        hp = 80,
        attack = 18,
        defense = 3
      ),
      starting_weapon = list(
        name = "Assassin's Dagger",
        damage = 10,
        crit_chance = 0.2,  # 20% crit
        type = "weapon"
      ),
      starting_armor = list(
        name = "Leather Vest",
        defense = 2,
        dodge_chance = 0.15,  # 15% dodge
        type = "armor"
      ),
      passive_ability = list(
        name = "Backstab",
        description = "30% chance to deal double damage"
      ),
      starting_gold = 75
    ),

    mage = list(
      name = "Mage",
      icon = "🔮",
      description = "Low HP, high ability power, extra skill points",
      flavor = "A master of arcane arts with devastating spells",
      stats = list(
        hp = 70,
        attack = 8,
        defense = 3
      ),
      starting_weapon = list(
        name = "Arcane Staff",
        damage = 5,
        status_effect = list(type = "burn", chance = 0.3),
        type = "weapon"
      ),
      starting_armor = list(
        name = "Mage Robe",
        defense = 1,
        magic_resist = 0.3,
        type = "armor"
      ),
      passive_ability = list(
        name = "Arcane Mastery",
        description = "+2 skill points at start, abilities cost -1 cooldown"
      ),
      starting_gold = 100,
      bonus_skill_points = 2
    ),

    tank = list(
      name = "Tank",
      icon = "🛡️",
      description = "Massive HP and defense, low damage",
      flavor = "An immovable fortress that protects and endures",
      stats = list(
        hp = 150,
        attack = 8,
        defense = 12
      ),
      starting_weapon = list(
        name = "Heavy Mace",
        damage = 4,
        type = "weapon"
      ),
      starting_armor = list(
        name = "Plate Armor",
        defense = 8,
        reflect_damage = 5,
        type = "armor"
      ),
      passive_ability = list(
        name = "Iron Will",
        description = "Regenerate 2 HP per turn"
      ),
      starting_gold = 30
    ),

    ranger = list(
      name = "Ranger",
      icon = "🏹",
      description = "Balanced stats, bonus gold finding",
      flavor = "A versatile adventurer skilled in survival",
      stats = list(
        hp = 100,
        attack = 12,
        defense = 6
      ),
      starting_weapon = list(
        name = "Hunter's Bow",
        damage = 7,
        type = "weapon"
      ),
      starting_armor = list(
        name = "Ranger's Cloak",
        defense = 3,
        type = "armor"
      ),
      passive_ability = list(
        name = "Treasure Hunter",
        description = "+100% gold drops, can detect traps better"
      ),
      starting_gold = 100,
      gold_bonus = 2.0
    ),

    paladin = list(
      name = "Paladin",
      icon = "✨",
      description = "Healing abilities, balanced stats, righteous power",
      flavor = "A holy knight blessed with divine powers",
      stats = list(
        hp = 110,
        attack = 13,
        defense = 8
      ),
      starting_weapon = list(
        name = "Holy Sword",
        damage = 7,
        lifesteal = 0.15,  # 15% lifesteal
        type = "weapon"
      ),
      starting_armor = list(
        name = "Blessed Armor",
        defense = 5,
        type = "armor"
      ),
      passive_ability = list(
        name = "Divine Grace",
        description = "Heal 5 HP when killing enemies"
      ),
      starting_gold = 50
    ),

    berserker = list(
      name = "Berserker",
      icon = "💥",
      description = "Insane damage, very low HP, risky playstyle",
      flavor = "A wild warrior who trades safety for raw power",
      stats = list(
        hp = 60,
        attack = 25,
        defense = 2
      ),
      starting_weapon = list(
        name = "Executioner's Axe",
        damage = 15,
        type = "weapon"
      ),
      starting_armor = list(
        name = "Tattered Cloth",
        defense = 1,
        type = "armor"
      ),
      passive_ability = list(
        name = "Blood Frenzy",
        description = "Gain +5 ATK for each enemy killed (stacks up to 5)"
      ),
      starting_gold = 25
    ),

    necromancer = list(
      name = "Necromancer",
      icon = "💀",
      description = "Drain life from enemies, cursed items synergy",
      flavor = "A dark sorcerer who commands death itself",
      stats = list(
        hp = 75,
        attack = 10,
        defense = 4
      ),
      starting_weapon = list(
        name = "Soul Reaver",
        damage = 6,
        lifesteal = 0.25,
        status_effect = list(type = "poison", chance = 0.4),
        type = "weapon"
      ),
      starting_armor = list(
        name = "Cursed Robes",
        defense = 2,
        regeneration = 1,
        type = "armor"
      ),
      passive_ability = list(
        name = "Dark Pact",
        description = "Cursed items grant +50% stats instead of penalties"
      ),
      starting_gold = 50
    )
  )
}

# ============================================================================
# Class Selection
# ============================================================================

select_character_class <- function() {
  classes <- get_character_classes()

  cat("\033[2J\033[H")
  cat("═══════════════════════════════════════════════════════\n")
  cat("              ⚔️  SELECT YOUR CLASS ⚔️\n")
  cat("═══════════════════════════════════════════════════════\n\n")

  class_names <- names(classes)

  # Display classes
  for (i in seq_along(class_names)) {
    class_name <- class_names[[i]]
    class_data <- classes[[class_name]]

    cat(sprintf("[%d] %s %s\n", i, class_data$icon, class_data$name))
    cat(sprintf("    %s\n", class_data$description))
    cat(sprintf("    Stats: %d HP | %d ATK | %d DEF\n",
                class_data$stats$hp,
                class_data$stats$attack,
                class_data$stats$defense))
    cat(sprintf("    Passive: %s\n", class_data$passive_ability$name))
    cat("\n")
  }

  cat("Enter class number (or press ENTER for Warrior): ")
  choice <- readline()

  if (choice == "" || !grepl("^[0-9]+$", choice)) {
    return(classes$warrior)
  }

  choice_num <- as.integer(choice)

  if (choice_num < 1 || choice_num > length(class_names)) {
    return(classes$warrior)
  }

  selected_class <- classes[[class_names[choice_num]]]

  # Show selected class details
  cat("\033[2J\033[H")
  cat("═══════════════════════════════════════════════════════\n")
  cat(sprintf("         %s %s SELECTED\n", selected_class$icon, toupper(selected_class$name)))
  cat("═══════════════════════════════════════════════════════\n\n")

  cat(sprintf("%s\n\n", selected_class$flavor))

  cat("STARTING STATS:\n")
  cat(sprintf("  HP:      %d\n", selected_class$stats$hp))
  cat(sprintf("  Attack:  %d\n", selected_class$stats$attack))
  cat(sprintf("  Defense: %d\n", selected_class$stats$defense))
  cat(sprintf("  Gold:    %d\n\n", selected_class$starting_gold))

  cat("STARTING EQUIPMENT:\n")
  cat(sprintf("  Weapon: %s (+%d DMG)\n",
              selected_class$starting_weapon$name,
              selected_class$starting_weapon$damage))
  cat(sprintf("  Armor:  %s (+%d DEF)\n\n",
              selected_class$starting_armor$name,
              selected_class$starting_armor$defense))

  cat("PASSIVE ABILITY:\n")
  cat(sprintf("  %s\n", selected_class$passive_ability$name))
  cat(sprintf("  %s\n\n", selected_class$passive_ability$description))

  cat("Press ENTER to begin your adventure...")
  readline()

  return(selected_class)
}

# ============================================================================
# Apply Class to Game State
# ============================================================================

apply_character_class <- function(state, class_data) {
  # Apply base stats
  state$player$hp <- class_data$stats$hp
  state$player$max_hp <- class_data$stats$hp
  state$player$attack <- class_data$stats$attack
  state$player$defense <- class_data$stats$defense
  state$player$gold <- class_data$starting_gold

  # Apply starting equipment
  state$player$weapon <- class_data$starting_weapon
  state$player$armor <- class_data$starting_armor

  # Apply bonus skill points (if any)
  if (!is.null(class_data$bonus_skill_points)) {
    state$abilities$skill_points <- state$abilities$skill_points + class_data$bonus_skill_points
  }

  # Store class info
  state$player$class <- class_data$name
  state$player$class_icon <- class_data$icon
  state$player$passive_ability <- class_data$passive_ability

  # Store class-specific multipliers
  if (!is.null(class_data$gold_bonus)) {
    state$player$gold_bonus <- class_data$gold_bonus
  }

  return(state)
}

# ============================================================================
# Apply Passive Abilities During Gameplay
# ============================================================================

apply_passive_ability <- function(state, trigger) {
  if (is.null(state$player$class) || is.null(state$player$passive_ability)) {
    return(state)
  }

  class_name <- tolower(state$player$class)

  # Warrior - Battle Rage (deal 20% more damage when below 50% HP)
  if (class_name == "warrior" && trigger == "calculate_damage") {
    if (state$player$hp < state$player$max_hp * 0.5) {
      # This would be applied in combat.R
      state$temp_damage_bonus <- 1.2
    }
  }

  # Rogue - Backstab (30% chance to deal double damage)
  if (class_name == "rogue" && trigger == "attack") {
    if (runif(1) < 0.3) {
      state$temp_damage_bonus <- 2.0
      state <- add_message(state, "BACKSTAB!")
    }
  }

  # Mage - Arcane Mastery (already applied at init - reduced cooldowns)

  # Tank - Iron Will (regenerate 2 HP per turn)
  if (class_name == "tank" && trigger == "turn_end") {
    old_hp <- state$player$hp
    state$player$hp <- min(state$player$max_hp, state$player$hp + 2)
    if (state$player$hp > old_hp) {
      state <- add_message(state, sprintf("Iron Will: +%d HP", state$player$hp - old_hp))
    }
  }

  # Ranger - Treasure Hunter (handled in combat.R for gold drops)

  # Paladin - Divine Grace (heal 5 HP on kill)
  if (class_name == "paladin" && trigger == "enemy_killed") {
    old_hp <- state$player$hp
    state$player$hp <- min(state$player$max_hp, state$player$hp + 5)
    if (state$player$hp > old_hp) {
      state <- add_message(state, sprintf("Divine Grace: +%d HP", state$player$hp - old_hp))
    }
  }

  # Berserker - Blood Frenzy (gain +5 ATK per kill, up to 5 stacks)
  if (class_name == "berserker" && trigger == "enemy_killed") {
    if (is.null(state$player$blood_frenzy_stacks)) {
      state$player$blood_frenzy_stacks <- 0
    }

    if (state$player$blood_frenzy_stacks < 5) {
      state$player$blood_frenzy_stacks <- state$player$blood_frenzy_stacks + 1
      state$player$attack <- state$player$attack + 5
      state <- add_message(state, sprintf("Blood Frenzy: +5 ATK (Stack %d/5)",
                                         state$player$blood_frenzy_stacks))
    }
  }

  # Necromancer - Dark Pact (handled in item pickup for cursed items)

  return(state)
}
