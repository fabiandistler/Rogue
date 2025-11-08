# ============================================================================
# Combat System
# ============================================================================
# Handles combat between player and enemies

# Player attacks enemy
player_attack <- function(state, enemy) {
  # Calculate base damage
  damage <- max(1, state$player$attack + state$player$weapon$damage - enemy$defense)
  damage <- damage + sample(-2:2, 1)  # Random variance

  # Apply status effect bonuses (if available)
  if (exists("get_status_attack_bonus") && !is.null(state$player$status_effects)) {
    damage <- damage + get_status_attack_bonus(state$player$status_effects)
  }

  # Apply power strike bonus
  if (!is.null(state$abilities$power_strike_active) && state$abilities$power_strike_active) {
    damage <- damage * 2
    state$abilities$power_strike_active <- FALSE
    state <- add_message(state, "POWER STRIKE!")
  }

  # Apply boss slayer bonus
  if (!is.null(state$meta) && "boss_slayer" %in% state$meta$active_bonuses && enemy$is_boss) {
    damage <- ceiling(damage * 1.2)
  }

  # Check for critical hit (if player has crit from item)
  crit_chance <- 0
  if (!is.null(state$player$weapon$prefix) && !is.null(state$player$weapon$prefix$crit_chance)) {
    crit_chance <- state$player$weapon$prefix$crit_chance
  }
  if (!is.null(state$player$weapon$suffix) && !is.null(state$player$weapon$suffix$crit_chance)) {
    crit_chance <- crit_chance + state$player$weapon$suffix$crit_chance
  }

  if (crit_chance > 0 && runif(1) < crit_chance) {
    damage <- damage * 2
    state <- add_message(state, "CRITICAL HIT!")
  }

  # Find enemy index
  enemy_idx <- which(sapply(state$enemies, function(e) e$id == enemy$id))

  # Apply damage
  state$enemies[[enemy_idx]]$hp <- state$enemies[[enemy_idx]]$hp - damage
  state$stats$damage_dealt <- state$stats$damage_dealt + damage

  state <- add_message(state, sprintf(
    "You hit %s for %d damage!",
    enemy$name, damage
  ))

  # Try to apply status effects from weapon
  if (exists("try_apply_status_on_hit")) {
    state <- try_apply_status_on_hit(state, "enemy", enemy$id, state$player$weapon)
  }

  # Check if enemy died
  if (state$enemies[[enemy_idx]]$hp <= 0) {
    state$enemies[[enemy_idx]]$alive <- FALSE
    state$stats$kills <- state$stats$kills + 1

    if (enemy$is_boss) {
      state <- add_message(state, sprintf("*** YOU DEFEATED %s! ***", toupper(enemy$name)))
    } else {
      state <- add_message(state, sprintf("You killed %s!", enemy$name))
    }

    # Drop gold (more for bosses, and treasure hunter bonus)
    gold_multiplier <- ifelse(enemy$is_boss, 5, 1)

    # Apply treasure hunter bonus
    if (!is.null(state$meta) && "treasure_hunter" %in% state$meta$active_bonuses) {
      gold_multiplier <- gold_multiplier * 1.5
    }

    gold_drop <- ceiling(sample(5:15, 1) * state$level * gold_multiplier)
    state$player$gold <- state$player$gold + gold_drop
    state <- add_message(state, sprintf("You gained %d gold!", gold_drop))

    # Gain skill point from bosses
    if (enemy$is_boss) {
      state <- gain_skill_point(state)
    }

    # Drop items
    if (enemy$is_boss) {
      # Bosses always drop good loot
      state <- drop_boss_loot(state, enemy)
    } else {
      # Regular enemies have 30% chance
      if (runif(1) < 0.3) {
        state <- drop_item(state, enemy)
      }
    }
  }

  return(state)
}

# Enemy attacks player
enemy_attack <- function(state, enemy) {
  # Check for dodge (from armor suffix/prefix)
  dodge_chance <- 0
  if (!is.null(state$player$armor$prefix) && !is.null(state$player$armor$prefix$dodge_chance)) {
    dodge_chance <- state$player$armor$prefix$dodge_chance
  }
  if (!is.null(state$player$armor$suffix) && !is.null(state$player$armor$suffix$dodge_chance)) {
    dodge_chance <- dodge_chance + state$player$armor$suffix$dodge_chance
  }

  if (dodge_chance > 0 && runif(1) < dodge_chance) {
    state <- add_message(state, sprintf("You dodge %s's attack!", enemy$name))
    return(state)
  }

  # Calculate damage
  damage <- max(1, enemy$attack - state$player$defense - state$player$armor$defense)
  damage <- damage + sample(-1:1, 1)  # Random variance

  # Apply status effect defense bonus (if available)
  if (exists("get_status_defense_bonus") && !is.null(state$player$status_effects)) {
    damage <- max(1, damage - get_status_defense_bonus(state$player$status_effects))
  }

  # Apply shield wall reduction
  if (!is.null(state$abilities$abilities$shield_wall$active) && state$abilities$abilities$shield_wall$active) {
    damage <- ceiling(damage * 0.5)
    state <- add_message(state, "Shield Wall blocks damage!")
  }

  # Apply spiked armor reflection (if available)
  if (!is.null(state$player$armor$prefix) && !is.null(state$player$armor$prefix$reflect_damage)) {
    reflect_damage <- state$player$armor$prefix$reflect_damage
    enemy_idx <- which(sapply(state$enemies, function(e) e$id == enemy$id))
    if (length(enemy_idx) > 0) {
      state$enemies[[enemy_idx]]$hp <- state$enemies[[enemy_idx]]$hp - reflect_damage
      state <- add_message(state, sprintf("Your armor reflects %d damage!", reflect_damage))
    }
  }

  # Apply damage to player
  state$player$hp <- state$player$hp - damage
  state$stats$damage_taken <- state$stats$damage_taken + damage

  state <- add_message(state, sprintf(
    "%s hits you for %d damage!",
    enemy$name, damage
  ))

  return(state)
}

# Process all enemy turns
process_enemies <- function(state) {
  for (i in seq_along(state$enemies)) {
    enemy <- state$enemies[[i]]

    if (!enemy$alive) next

    # Simple AI: move towards player if close, otherwise random
    dist <- abs(enemy$x - state$player$x) + abs(enemy$y - state$player$y)

    if (dist == 1) {
      # Adjacent to player - attack!
      state <- enemy_attack(state, enemy)
    } else if (dist <= 8) {
      # Close to player - move towards
      state <- move_enemy_towards_player(state, i)
    } else {
      # Far from player - random movement
      state <- move_enemy_random(state, i)
    }
  }

  return(state)
}

# Move enemy towards player
move_enemy_towards_player <- function(state, enemy_idx) {
  enemy <- state$enemies[[enemy_idx]]

  # Calculate direction
  dx <- sign(state$player$x - enemy$x)
  dy <- sign(state$player$y - enemy$y)

  # Try to move in preferred direction
  if (abs(state$player$x - enemy$x) > abs(state$player$y - enemy$y)) {
    # Prefer horizontal movement
    new_x <- enemy$x + dx
    new_y <- enemy$y

    if (!is_walkable(state, new_x, new_y) || !is.null(get_enemy_at(state, new_x, new_y))) {
      # Try vertical
      new_x <- enemy$x
      new_y <- enemy$y + dy
    }
  } else {
    # Prefer vertical movement
    new_x <- enemy$x
    new_y <- enemy$y + dy

    if (!is_walkable(state, new_x, new_y) || !is.null(get_enemy_at(state, new_x, new_y))) {
      # Try horizontal
      new_x <- enemy$x + dx
      new_y <- enemy$y
    }
  }

  # Move if valid
  if (is_walkable(state, new_x, new_y) && is.null(get_enemy_at(state, new_x, new_y))) {
    state$enemies[[enemy_idx]]$x <- new_x
    state$enemies[[enemy_idx]]$y <- new_y
  }

  return(state)
}

# Move enemy randomly
move_enemy_random <- function(state, enemy_idx) {
  enemy <- state$enemies[[enemy_idx]]

  # Random direction
  directions <- list(
    list(dx = 0, dy = -1),
    list(dx = 0, dy = 1),
    list(dx = -1, dy = 0),
    list(dx = 1, dy = 0)
  )

  dir <- sample(directions, 1)[[1]]
  new_x <- enemy$x + dir$dx
  new_y <- enemy$y + dir$dy

  # Move if valid
  if (is_walkable(state, new_x, new_y) && is.null(get_enemy_at(state, new_x, new_y))) {
    state$enemies[[enemy_idx]]$x <- new_x
    state$enemies[[enemy_idx]]$y <- new_y
  }

  return(state)
}

# Drop item when enemy dies
drop_item <- function(state, enemy) {
  item_types <- list(
    list(name = "Health Potion", type = "potion", effect = "heal", value = 30, char = "!"),
    list(name = "Gold Pile", type = "gold", effect = "gold", value = 20, char = "$")
  )

  item_type <- sample(item_types, 1)[[1]]
  new_item <- c(
    item_type,
    list(
      x = enemy$x,
      y = enemy$y,
      id = length(state$items) + 1,
      picked = FALSE
    )
  )

  state$items <- c(state$items, list(new_item))
  state <- add_message(state, sprintf("%s dropped %s!", enemy$name, item_type$name))

  return(state)
}

# Drop boss loot (guaranteed good items)
drop_boss_loot <- function(state, boss) {
  # Boss weapons (scaled to level)
  boss_weapons <- list(
    list(name = "Enchanted Blade", type = "weapon", effect = "weapon", value = 20 + state$level * 3, char = "/"),
    list(name = "Dragon Slayer", type = "weapon", effect = "weapon", value = 25 + state$level * 4, char = "/"),
    list(name = "Legendary Sword", type = "weapon", effect = "weapon", value = 30 + state$level * 5, char = "/")
  )

  # Boss armor (scaled to level)
  boss_armor <- list(
    list(name = "Plate Mail", type = "armor", effect = "armor", value = 8 + state$level * 2, char = "["),
    list(name = "Dragon Scale Armor", type = "armor", effect = "armor", value = 10 + state$level * 3, char = "["),
    list(name = "Legendary Armor", type = "armor", effect = "armor", value = 12 + state$level * 4, char = "[")
  )

  # Drop a weapon
  weapon_type <- sample(boss_weapons, 1)[[1]]
  new_weapon <- c(
    weapon_type,
    list(
      x = boss$x,
      y = boss$y,
      id = length(state$items) + 1,
      picked = FALSE
    )
  )
  state$items <- c(state$items, list(new_weapon))
  state <- add_message(state, sprintf("%s dropped %s!", boss$name, weapon_type$name))

  # Drop armor
  armor_type <- sample(boss_armor, 1)[[1]]
  new_armor <- c(
    armor_type,
    list(
      x = boss$x,
      y = boss$y,
      id = length(state$items) + 1,
      picked = FALSE
    )
  )
  state$items <- c(state$items, list(new_armor))
  state <- add_message(state, sprintf("%s also dropped %s!", boss$name, armor_type$name))

  # Also drop health potions
  for (i in 1:2) {
    potion <- list(
      name = "Greater Health Potion",
      type = "potion",
      effect = "heal",
      value = 50,
      char = "!",
      x = boss$x,
      y = boss$y,
      id = length(state$items) + 1,
      picked = FALSE
    )
    state$items <- c(state$items, list(potion))
  }

  return(state)
}
