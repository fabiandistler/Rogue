# ============================================================================
# Extended Item System
# ============================================================================
# Adds rarities, prefixes, suffixes, and procedural item generation

# ============================================================================
# Item Rarities
# ============================================================================

get_rarity_definitions <- function() {
  list(
    common = list(
      name = "Common",
      color = "gray",
      stat_multiplier = 1.0,
      prefix_chance = 0.0,
      suffix_chance = 0.0,
      drop_weight = 70
    ),
    uncommon = list(
      name = "Uncommon",
      color = "green",
      stat_multiplier = 1.3,
      prefix_chance = 0.3,
      suffix_chance = 0.2,
      drop_weight = 20
    ),
    rare = list(
      name = "Rare",
      color = "blue",
      stat_multiplier = 1.6,
      prefix_chance = 0.6,
      suffix_chance = 0.5,
      drop_weight = 8
    ),
    legendary = list(
      name = "Legendary",
      color = "magenta",
      stat_multiplier = 2.0,
      prefix_chance = 1.0,
      suffix_chance = 1.0,
      drop_weight = 2
    )
  )
}

# ============================================================================
# Item Prefixes (Modify primary stat)
# ============================================================================

get_item_prefixes <- function() {
  list(
    weapon = list(
      heavy = list(name = "Heavy", damage_bonus = 5, description = "Deals extra damage"),
      sharp = list(name = "Sharp", damage_bonus = 3, crit_chance = 0.1, description = "Sharp and deadly"),
      flaming = list(name = "Flaming", damage_bonus = 4, status_effect = list(type = "burn", chance = 0.3),
                    description = "Burns enemies"),
      freezing = list(name = "Freezing", damage_bonus = 2, status_effect = list(type = "freeze", chance = 0.4),
                     description = "Freezes enemies"),
      venomous = list(name = "Venomous", damage_bonus = 2, status_effect = list(type = "poison", chance = 0.5),
                     description = "Poisons enemies"),
      blessed = list(name = "Blessed", damage_bonus = 6, description = "Blessed by the gods"),
      cursed = list(name = "Cursed", damage_bonus = 10, hp_cost = 2, description = "Powerful but drains life"),
      vampiric = list(name = "Vampiric", damage_bonus = 3, lifesteal = 0.2, description = "Steals life"),
      thundering = list(name = "Thundering", damage_bonus = 5, status_effect = list(type = "stun", chance = 0.15),
                       description = "Stuns enemies"),
      giant = list(name = "Giant", damage_bonus = 8, speed_penalty = 0.1, description = "Massive damage, slow"),
      quick = list(name = "Quick", damage_bonus = 2, speed_bonus = 0.2, description = "Fast attacks")
    ),
    armor = list(
      sturdy = list(name = "Sturdy", defense_bonus = 3, description = "Extra protection"),
      light = list(name = "Light", defense_bonus = 1, speed_bonus = 0.15, description = "Light and mobile"),
      heavy = list(name = "Heavy", defense_bonus = 5, speed_penalty = 0.1, description = "Heavy protection"),
      enchanted = list(name = "Enchanted", defense_bonus = 4, magic_resist = 0.2, description = "Magic resistance"),
      spiked = list(name = "Spiked", defense_bonus = 2, reflect_damage = 3, description = "Reflects damage"),
      blessed = list(name = "Blessed", defense_bonus = 4, description = "Blessed protection"),
      living = list(name = "Living", defense_bonus = 2, regeneration = 2, description = "Regenerates health"),
      dragon = list(name = "Dragon", defense_bonus = 6, fire_resist = 0.3, description = "Dragon scales"),
      shadowy = list(name = "Shadowy", defense_bonus = 2, dodge_chance = 0.15, description = "Easier to dodge"),
      fortified = list(name = "Fortified", defense_bonus = 7, description = "Maximum protection")
    )
  )
}

# ============================================================================
# Item Suffixes (Add secondary bonus)
# ============================================================================

get_item_suffixes <- function() {
  list(
    weapon = list(
      of_power = list(name = "of Power", damage_bonus = 3, description = "+3 damage"),
      of_speed = list(name = "of Speed", attack_speed_bonus = 0.2, description = "Faster attacks"),
      of_life = list(name = "of Life", max_hp_bonus = 10, description = "+10 max HP"),
      of_the_warrior = list(name = "of the Warrior", damage_bonus = 2, defense_bonus = 1,
                           description = "+2 damage, +1 defense"),
      of_slaying = list(name = "of Slaying", damage_bonus = 5, description = "+5 damage"),
      of_precision = list(name = "of Precision", crit_chance = 0.15, description = "15% crit chance"),
      of_the_bear = list(name = "of the Bear", damage_bonus = 3, max_hp_bonus = 15,
                        description = "+3 damage, +15 HP"),
      of_mastery = list(name = "of Mastery", skill_point_bonus = 1, description = "+1 skill point")
    ),
    armor = list(
      of_protection = list(name = "of Protection", defense_bonus = 2, description = "+2 defense"),
      of_vitality = list(name = "of Vitality", max_hp_bonus = 20, description = "+20 max HP"),
      of_the_titan = list(name = "of the Titan", defense_bonus = 3, max_hp_bonus = 15,
                         description = "+3 defense, +15 HP"),
      of_regeneration = list(name = "of Regeneration", regen_per_turn = 1, description = "Regenerate 1 HP/turn"),
      of_the_guardian = list(name = "of the Guardian", defense_bonus = 4, description = "+4 defense"),
      of_evasion = list(name = "of Evasion", dodge_chance = 0.1, description = "10% dodge chance"),
      of_fortitude = list(name = "of Fortitude", max_hp_bonus = 30, description = "+30 max HP"),
      of_resilience = list(name = "of Resilience", defense_bonus = 2, status_resist = 0.2,
                          description = "+2 defense, resist status")
    )
  )
}

# ============================================================================
# Generate Random Item
# ============================================================================

generate_random_item <- function(level, type = NULL, forced_rarity = NULL) {
  # Determine type
  if (is.null(type)) {
    type <- sample(c("weapon", "armor", "potion", "gold"), 1,
                  prob = c(0.3, 0.3, 0.2, 0.2))
  }

  # Determine rarity
  rarity <- if (!is.null(forced_rarity)) {
    forced_rarity
  } else {
    determine_rarity(level)
  }

  # Generate item based on type
  if (type == "weapon") {
    return(generate_weapon(level, rarity))
  } else if (type == "armor") {
    return(generate_armor(level, rarity))
  } else if (type == "potion") {
    return(generate_potion(level, rarity))
  } else if (type == "gold") {
    return(generate_gold(level, rarity))
  }
}

# ============================================================================
# Determine Rarity
# ============================================================================

determine_rarity <- function(level) {
  rarities <- get_rarity_definitions()

  # Adjust weights based on level
  weights <- sapply(rarities, function(r) r$drop_weight)

  # Higher levels increase rare item chances
  level_factor <- min(level / 10, 1)  # Max at level 10
  weights["rare"] <- weights["rare"] * (1 + level_factor)
  weights["legendary"] <- weights["legendary"] * (1 + level_factor * 2)

  # Sample rarity
  rarity_name <- sample(names(weights), 1, prob = weights)
  return(rarity_name)
}

# ============================================================================
# Generate Weapon
# ============================================================================

generate_weapon <- function(level, rarity) {
  rarities <- get_rarity_definitions()
  rarity_def <- rarities[[rarity]]

  # Base weapon types
  weapon_types <- list(
    sword = list(name = "Sword", base_damage = 10, char = "/"),
    axe = list(name = "Axe", base_damage = 12, char = "/"),
    mace = list(name = "Mace", base_damage = 11, char = "/"),
    dagger = list(name = "Dagger", base_damage = 8, char = "/"),
    spear = list(name = "Spear", base_damage = 9, char = "/"),
    hammer = list(name = "Hammer", base_damage = 13, char = "/"),
    staff = list(name = "Staff", base_damage = 7, char = "/"),
    bow = list(name = "Bow", base_damage = 9, char = "/")
  )

  weapon_type <- sample(weapon_types, 1)[[1]]

  # Calculate base damage (scaled by level and rarity)
  base_damage <- round(weapon_type$base_damage * (1 + level * 0.1) * rarity_def$stat_multiplier)

  # Generate prefix and suffix
  prefix <- NULL
  suffix <- NULL
  prefixes <- get_item_prefixes()$weapon
  suffixes <- get_item_suffixes()$weapon

  if (runif(1) < rarity_def$prefix_chance && length(prefixes) > 0) {
    prefix <- sample(prefixes, 1)[[1]]
  }

  if (runif(1) < rarity_def$suffix_chance && length(suffixes) > 0) {
    suffix <- sample(suffixes, 1)[[1]]
  }

  # Build weapon name
  weapon_name <- build_item_name(weapon_type$name, prefix, suffix)

  # Calculate total stats
  total_damage <- base_damage
  if (!is.null(prefix) && !is.null(prefix$damage_bonus)) {
    total_damage <- total_damage + prefix$damage_bonus
  }
  if (!is.null(suffix) && !is.null(suffix$damage_bonus)) {
    total_damage <- total_damage + suffix$damage_bonus
  }

  # Create weapon object
  weapon <- list(
    name = weapon_name,
    type = "weapon",
    weapon_type = weapon_type$name,
    damage = total_damage,
    rarity = rarity,
    char = weapon_type$char,
    prefix = prefix,
    suffix = suffix,
    level = level,
    value = calculate_item_value(total_damage, rarity),
    description = build_item_description(weapon_type$name, prefix, suffix, rarity_def)
  )

  return(weapon)
}

# ============================================================================
# Generate Armor
# ============================================================================

generate_armor <- function(level, rarity) {
  rarities <- get_rarity_definitions()
  rarity_def <- rarities[[rarity]]

  # Base armor types
  armor_types <- list(
    leather = list(name = "Leather Armor", base_defense = 5, char = "["),
    chainmail = list(name = "Chainmail", base_defense = 7, char = "["),
    plate = list(name = "Plate Armor", base_defense = 10, char = "["),
    scale = list(name = "Scale Mail", base_defense = 8, char = "["),
    robe = list(name = "Robe", base_defense = 3, char = "["),
    cloak = list(name = "Cloak", base_defense = 4, char = "[")
  )

  armor_type <- sample(armor_types, 1)[[1]]

  # Calculate base defense
  base_defense <- round(armor_type$base_defense * (1 + level * 0.1) * rarity_def$stat_multiplier)

  # Generate prefix and suffix
  prefix <- NULL
  suffix <- NULL
  prefixes <- get_item_prefixes()$armor
  suffixes <- get_item_suffixes()$armor

  if (runif(1) < rarity_def$prefix_chance && length(prefixes) > 0) {
    prefix <- sample(prefixes, 1)[[1]]
  }

  if (runif(1) < rarity_def$suffix_chance && length(suffixes) > 0) {
    suffix <- sample(suffixes, 1)[[1]]
  }

  # Build armor name
  armor_name <- build_item_name(armor_type$name, prefix, suffix)

  # Calculate total stats
  total_defense <- base_defense
  if (!is.null(prefix) && !is.null(prefix$defense_bonus)) {
    total_defense <- total_defense + prefix$defense_bonus
  }
  if (!is.null(suffix) && !is.null(suffix$defense_bonus)) {
    total_defense <- total_defense + suffix$defense_bonus
  }

  # Create armor object
  armor <- list(
    name = armor_name,
    type = "armor",
    armor_type = armor_type$name,
    defense = total_defense,
    rarity = rarity,
    char = armor_type$char,
    prefix = prefix,
    suffix = suffix,
    level = level,
    value = calculate_item_value(total_defense, rarity),
    description = build_item_description(armor_type$name, prefix, suffix, rarity_def)
  )

  return(armor)
}

# ============================================================================
# Generate Potion
# ============================================================================

generate_potion <- function(level, rarity) {
  rarities <- get_rarity_definitions()
  rarity_def <- rarities[[rarity]]

  potion_types <- list(
    health = list(name = "Health Potion", base_heal = 30, char = "!"),
    greater_health = list(name = "Greater Health Potion", base_heal = 50, char = "!"),
    strength = list(name = "Strength Potion", effect = "strength", duration = 3, char = "!"),
    protection = list(name = "Protection Potion", effect = "protection", duration = 3, char = "!"),
    regeneration = list(name = "Regeneration Potion", effect = "regeneration", duration = 5, char = "!")
  )

  potion_type <- sample(potion_types, 1)[[1]]

  # Scale by level and rarity
  if (!is.null(potion_type$base_heal)) {
    heal_amount <- round(potion_type$base_heal * (1 + level * 0.05) * rarity_def$stat_multiplier)
  } else {
    heal_amount <- NULL
  }

  potion <- list(
    name = potion_type$name,
    type = "potion",
    heal = heal_amount,
    effect = potion_type$effect,
    duration = potion_type$duration,
    rarity = rarity,
    char = potion_type$char,
    value = 20 * rarity_def$stat_multiplier
  )

  return(potion)
}

# ============================================================================
# Generate Gold
# ============================================================================

generate_gold <- function(level, rarity) {
  rarities <- get_rarity_definitions()
  rarity_def <- rarities[[rarity]]

  base_gold <- 10
  amount <- round(base_gold * (1 + level * 0.2) * rarity_def$stat_multiplier)

  gold <- list(
    name = "Gold",
    type = "gold",
    amount = amount,
    char = "$",
    rarity = "common"
  )

  return(gold)
}

# ============================================================================
# Helper Functions
# ============================================================================

build_item_name <- function(base_name, prefix, suffix) {
  name_parts <- character(0)

  if (!is.null(prefix)) {
    name_parts <- c(name_parts, prefix$name)
  }

  name_parts <- c(name_parts, base_name)

  if (!is.null(suffix)) {
    name_parts <- c(name_parts, suffix$name)
  }

  return(paste(name_parts, collapse = " "))
}

build_item_description <- function(base_name, prefix, suffix, rarity_def) {
  desc_parts <- character(0)

  desc_parts <- c(desc_parts, sprintf("%s %s", rarity_def$name, base_name))

  if (!is.null(prefix) && !is.null(prefix$description)) {
    desc_parts <- c(desc_parts, prefix$description)
  }

  if (!is.null(suffix) && !is.null(suffix$description)) {
    desc_parts <- c(desc_parts, suffix$description)
  }

  return(paste(desc_parts, collapse = " - "))
}

calculate_item_value <- function(stat_value, rarity) {
  rarities <- get_rarity_definitions()
  multiplier <- rarities[[rarity]]$stat_multiplier

  return(round(stat_value * 10 * multiplier))
}

# ============================================================================
# Item Comparison
# ============================================================================

compare_items <- function(item1, item2, comparison_stat = "damage") {
  # Returns: 1 if item1 better, -1 if item2 better, 0 if equal

  if (is.null(item1)) return(-1)
  if (is.null(item2)) return(1)

  stat1 <- if (!is.null(item1[[comparison_stat]])) item1[[comparison_stat]] else 0
  stat2 <- if (!is.null(item2[[comparison_stat]])) item2[[comparison_stat]] else 0

  if (stat1 > stat2) return(1)
  if (stat1 < stat2) return(-1)
  return(0)
}
