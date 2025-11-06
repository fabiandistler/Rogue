# ============================================================================
# Special Abilities & Skill Tree System
# ============================================================================
# Player abilities that can be used in combat

# Initialize player abilities
init_abilities <- function() {
  list(
    # Available abilities
    abilities = list(
      heal = list(
        name = "Healing Surge",
        description = "Restore 30 HP",
        cooldown = 5,
        current_cooldown = 0,
        level = 1,
        unlocked = TRUE
      ),
      power_strike = list(
        name = "Power Strike",
        description = "Deal double damage on next attack",
        cooldown = 4,
        current_cooldown = 0,
        level = 1,
        unlocked = FALSE
      ),
      shield_wall = list(
        name = "Shield Wall",
        description = "Block 50% damage for 3 turns",
        cooldown = 6,
        current_cooldown = 0,
        duration = 3,
        active = FALSE,
        turns_remaining = 0,
        level = 1,
        unlocked = FALSE
      ),
      whirlwind = list(
        name = "Whirlwind",
        description = "Attack all adjacent enemies",
        cooldown = 7,
        current_cooldown = 0,
        level = 1,
        unlocked = FALSE
      ),
      teleport = list(
        name = "Tactical Retreat",
        description = "Teleport to random nearby location",
        cooldown = 10,
        current_cooldown = 0,
        level = 1,
        unlocked = FALSE
      )
    ),

    # Skill points
    skill_points = 0,
    total_skill_points = 0,

    # Passive buffs
    passive_bonuses = list(
      extra_hp = 0,
      extra_attack = 0,
      extra_defense = 0,
      crit_chance = 0
    )
  )
}

# Gain skill point (every level or from bosses)
gain_skill_point <- function(state) {
  state$abilities$skill_points <- state$abilities$skill_points + 1
  state$abilities$total_skill_points <- state$abilities$total_skill_points + 1
  state <- add_message(state, "You gained a skill point!")
  return(state)
}

# Use ability
use_ability <- function(state, ability_id) {
  ability <- state$abilities$abilities[[ability_id]]

  # Check if unlocked
  if (!ability$unlocked) {
    state <- add_message(state, "Ability not unlocked!")
    return(state)
  }

  # Check cooldown
  if (ability$current_cooldown > 0) {
    state <- add_message(state, sprintf("%s on cooldown! (%d turns)", ability$name, ability$current_cooldown))
    return(state)
  }

  # Use ability
  if (ability_id == "heal") {
    state <- use_heal(state, ability)
  } else if (ability_id == "power_strike") {
    state <- use_power_strike(state, ability)
  } else if (ability_id == "shield_wall") {
    state <- use_shield_wall(state, ability)
  } else if (ability_id == "whirlwind") {
    state <- use_whirlwind(state, ability)
  } else if (ability_id == "teleport") {
    state <- use_teleport(state, ability)
  }

  return(state)
}

# Heal ability
use_heal <- function(state, ability) {
  heal_amount <- 30 + (ability$level * 10)
  old_hp <- state$player$hp
  state$player$hp <- min(state$player$max_hp, state$player$hp + heal_amount)
  actual_heal <- state$player$hp - old_hp

  state <- add_message(state, sprintf("Healing Surge! Restored %d HP!", actual_heal))
  state$abilities$abilities$heal$current_cooldown <- ability$cooldown
  state$player_acted <- TRUE

  return(state)
}

# Power strike ability
use_power_strike <- function(state, ability) {
  state$abilities$power_strike_active <- TRUE
  state <- add_message(state, "Power Strike ready! Next attack deals double damage!")
  state$abilities$abilities$power_strike$current_cooldown <- ability$cooldown
  state$player_acted <- TRUE

  return(state)
}

# Shield wall ability
use_shield_wall <- function(state, ability) {
  state$abilities$abilities$shield_wall$active <- TRUE
  state$abilities$abilities$shield_wall$turns_remaining <- ability$duration
  state <- add_message(state, "Shield Wall activated! Blocking 50% damage!")
  state$abilities$abilities$shield_wall$current_cooldown <- ability$cooldown
  state$player_acted <- TRUE

  return(state)
}

# Whirlwind ability
use_whirlwind <- function(state, ability) {
  state <- add_message(state, "Whirlwind Attack!")

  # Attack all adjacent enemies
  adjacent_enemies <- get_adjacent_enemies(state)

  if (length(adjacent_enemies) == 0) {
    state <- add_message(state, "No enemies nearby!")
  } else {
    for (enemy in adjacent_enemies) {
      damage <- max(1, state$player$attack + state$player$weapon$damage - enemy$defense)
      damage <- damage + sample(-1:1, 1)

      # Apply damage
      enemy_idx <- which(sapply(state$enemies, function(e) e$id == enemy$id))
      state$enemies[[enemy_idx]]$hp <- state$enemies[[enemy_idx]]$hp - damage

      state <- add_message(state, sprintf("Hit %s for %d damage!", enemy$name, damage))

      # Check death
      if (state$enemies[[enemy_idx]]$hp <= 0) {
        state$enemies[[enemy_idx]]$alive <- FALSE
        state$stats$kills <- state$stats$kills + 1
        state <- add_message(state, sprintf("%s defeated!", enemy$name))
      }
    }
  }

  state$abilities$abilities$whirlwind$current_cooldown <- ability$cooldown
  state$player_acted <- TRUE

  return(state)
}

# Teleport ability
use_teleport <- function(state, ability) {
  # Find random nearby walkable position
  attempts <- 0
  while (attempts < 50) {
    new_x <- state$player$x + sample(-5:5, 1)
    new_y <- state$player$y + sample(-5:5, 1)

    if (is_walkable(state, new_x, new_y) && is.null(get_enemy_at(state, new_x, new_y))) {
      state$player$x <- new_x
      state$player$y <- new_y
      state <- calculate_fov(state)
      state <- add_message(state, "Tactical Retreat successful!")
      state$abilities$abilities$teleport$current_cooldown <- ability$cooldown
      state$player_acted <- TRUE
      return(state)
    }
    attempts <- attempts + 1
  }

  state <- add_message(state, "Cannot teleport - no valid location!")
  return(state)
}

# Get adjacent enemies
get_adjacent_enemies <- function(state) {
  adjacent <- list()
  px <- state$player$x
  py <- state$player$y

  for (enemy in state$enemies) {
    if (enemy$alive) {
      dist <- abs(enemy$x - px) + abs(enemy$y - py)
      if (dist == 1) {
        adjacent <- c(adjacent, list(enemy))
      }
    }
  }

  return(adjacent)
}

# Update cooldowns (call each turn)
update_cooldowns <- function(state) {
  for (ability_id in names(state$abilities$abilities)) {
    ability <- state$abilities$abilities[[ability_id]]

    if (ability$current_cooldown > 0) {
      state$abilities$abilities[[ability_id]]$current_cooldown <- ability$current_cooldown - 1
    }

    # Update shield wall duration
    if (ability_id == "shield_wall" && ability$active) {
      state$abilities$abilities$shield_wall$turns_remaining <- ability$turns_remaining - 1
      if (state$abilities$abilities$shield_wall$turns_remaining <= 0) {
        state$abilities$abilities$shield_wall$active <- FALSE
        state <- add_message(state, "Shield Wall faded.")
      }
    }
  }

  return(state)
}

# Show abilities menu
show_abilities <- function(state) {
  cat("\n=== ABILITIES ===\n")
  cat(sprintf("Skill Points: %d\n\n", state$abilities$skill_points))

  ability_keys <- c("1" = "heal", "2" = "power_strike", "3" = "shield_wall", "4" = "whirlwind", "5" = "teleport")

  for (i in 1:length(ability_keys)) {
    ability_id <- ability_keys[i]
    ability <- state$abilities$abilities[[ability_id]]

    status <- if (!ability$unlocked) {
      "[LOCKED - Costs 1 SP]"
    } else if (ability$current_cooldown > 0) {
      sprintf("[Cooldown: %d]", ability$current_cooldown)
    } else {
      "[READY]"
    }

    if (ability_id == "shield_wall" && ability$active) {
      status <- sprintf("%s [ACTIVE: %d turns]", status, ability$turns_remaining)
    }

    cat(sprintf("%d. %s (Lv%d): %s %s\n", i, ability$name, ability$level, ability$description, status))
  }

  cat("\nPress 1-5 to use/unlock ability, or ENTER to cancel: ")
  input <- readline()

  if (input %in% names(ability_keys)) {
    ability_id <- ability_keys[input]
    ability <- state$abilities$abilities[[ability_id]]

    if (!ability$unlocked) {
      # Unlock ability
      if (state$abilities$skill_points > 0) {
        state$abilities$abilities[[ability_id]]$unlocked <- TRUE
        state$abilities$skill_points <- state$abilities$skill_points - 1
        cat(sprintf("\nUnlocked %s!\n", ability$name))
        Sys.sleep(1)
      } else {
        cat("\nNot enough skill points!\n")
        Sys.sleep(1)
      }
    } else {
      # Use ability
      state <- use_ability(state, ability_id)
      Sys.sleep(1)
    }
  }

  return(state)
}
