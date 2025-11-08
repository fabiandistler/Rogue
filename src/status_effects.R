# ============================================================================
# Status Effects System
# ============================================================================
# Implements Poison, Burn, Freeze, and other status effects

# ============================================================================
# Status Effect Definitions
# ============================================================================

get_status_effect_definitions <- function() {
  list(
    poison = list(
      name = "Poison",
      duration = 3,
      damage_per_turn = 5,
      color = "green",
      icon = "☠",
      description = "Takes damage over time"
    ),
    burn = list(
      name = "Burn",
      duration = 3,
      damage_per_turn = 8,
      color = "red",
      icon = "🔥",
      description = "Burns for high damage"
    ),
    freeze = list(
      name = "Freeze",
      duration = 2,
      slow_chance = 0.5,
      color = "cyan",
      icon = "❄",
      description = "50% chance to skip turn"
    ),
    bleed = list(
      name = "Bleed",
      duration = 4,
      damage_per_turn = 3,
      color = "red",
      icon = "💉",
      description = "Bleeding damage over time"
    ),
    stun = list(
      name = "Stun",
      duration = 1,
      skip_turn = TRUE,
      color = "yellow",
      icon = "⚡",
      description = "Cannot act for 1 turn"
    ),
    regeneration = list(
      name = "Regeneration",
      duration = 5,
      heal_per_turn = 5,
      color = "green",
      icon = "💚",
      description = "Heals over time"
    ),
    strength = list(
      name = "Strength",
      duration = 3,
      attack_bonus = 10,
      color = "red",
      icon = "💪",
      description = "Increased attack damage"
    ),
    protection = list(
      name = "Protection",
      duration = 3,
      defense_bonus = 5,
      color = "blue",
      icon = "🛡",
      description = "Increased defense"
    )
  )
}

# ============================================================================
# Initialize Status Effects
# ============================================================================

init_status_effects <- function() {
  list()
}

# ============================================================================
# Apply Status Effect
# ============================================================================

apply_status_effect <- function(state, target_type = "player", target_id = NULL, effect_name) {
  effect_defs <- get_status_effect_definitions()

  if (!effect_name %in% names(effect_defs)) {
    return(state)
  }

  effect_def <- effect_defs[[effect_name]]

  # Create effect instance
  effect <- list(
    name = effect_def$name,
    duration = effect_def$duration,
    icon = effect_def$icon,
    definition = effect_def
  )

  # Apply to player
  if (target_type == "player") {
    if (is.null(state$player$status_effects)) {
      state$player$status_effects <- list()
    }

    # Add or refresh effect
    state$player$status_effects[[effect_name]] <- effect

    # Add message
    state$message_log <- c(state$message_log,
                          sprintf("You are affected by %s! (%s)",
                                effect_def$name,
                                effect_def$description))
  }
  # Apply to enemy
  else if (target_type == "enemy" && !is.null(target_id)) {
    enemy_idx <- which(sapply(state$enemies, function(e) e$id == target_id))
    if (length(enemy_idx) > 0) {
      enemy <- state$enemies[[enemy_idx[1]]]

      if (is.null(enemy$status_effects)) {
        enemy$status_effects <- list()
      }

      enemy$status_effects[[effect_name]] <- effect
      state$enemies[[enemy_idx[1]]] <- enemy

      # Add message
      state$message_log <- c(state$message_log,
                            sprintf("%s is affected by %s!",
                                  enemy$name,
                                  effect_def$name))
    }
  }

  return(state)
}

# ============================================================================
# Process Status Effects (called each turn)
# ============================================================================

process_status_effects <- function(state) {
  # Process player status effects
  state <- process_player_status_effects(state)

  # Process enemy status effects
  state <- process_enemy_status_effects(state)

  return(state)
}

process_player_status_effects <- function(state) {
  if (is.null(state$player$status_effects) || length(state$player$status_effects) == 0) {
    return(state)
  }

  effects_to_remove <- character(0)

  for (effect_name in names(state$player$status_effects)) {
    effect <- state$player$status_effects[[effect_name]]
    effect_def <- effect$definition

    # Apply effect
    if (!is.null(effect_def$damage_per_turn)) {
      damage <- effect_def$damage_per_turn
      state$player$hp <- max(0, state$player$hp - damage)
      state$message_log <- c(state$message_log,
                            sprintf("You take %d damage from %s!", damage, effect_def$name))
    }

    if (!is.null(effect_def$heal_per_turn)) {
      heal <- effect_def$heal_per_turn
      old_hp <- state$player$hp
      state$player$hp <- min(state$player$max_hp, state$player$hp + heal)
      actual_heal <- state$player$hp - old_hp
      if (actual_heal > 0) {
        state$message_log <- c(state$message_log,
                              sprintf("You regenerate %d HP!", actual_heal))
      }
    }

    if (!is.null(effect_def$skip_turn) && effect_def$skip_turn) {
      state$player_skips_turn <- TRUE
      state$message_log <- c(state$message_log, "You are stunned and cannot act!")
    }

    # Decrease duration
    effect$duration <- effect$duration - 1
    state$player$status_effects[[effect_name]] <- effect

    # Mark for removal if expired
    if (effect$duration <= 0) {
      effects_to_remove <- c(effects_to_remove, effect_name)
      state$message_log <- c(state$message_log,
                            sprintf("%s has worn off.", effect_def$name))
    }
  }

  # Remove expired effects
  for (effect_name in effects_to_remove) {
    state$player$status_effects[[effect_name]] <- NULL
  }

  return(state)
}

process_enemy_status_effects <- function(state) {
  for (i in seq_along(state$enemies)) {
    enemy <- state$enemies[[i]]

    if (!enemy$alive || is.null(enemy$status_effects) || length(enemy$status_effects) == 0) {
      next
    }

    effects_to_remove <- character(0)

    for (effect_name in names(enemy$status_effects)) {
      effect <- enemy$status_effects[[effect_name]]
      effect_def <- effect$definition

      # Apply effect
      if (!is.null(effect_def$damage_per_turn)) {
        damage <- effect_def$damage_per_turn
        enemy$hp <- max(0, enemy$hp - damage)
        state$message_log <- c(state$message_log,
                              sprintf("%s takes %d damage from %s!",
                                    enemy$name, damage, effect_def$name))

        # Check if enemy died
        if (enemy$hp <= 0) {
          enemy$alive <- FALSE
          state$message_log <- c(state$message_log,
                                sprintf("%s died from %s!", enemy$name, effect_def$name))
        }
      }

      if (!is.null(effect_def$skip_turn) && effect_def$skip_turn) {
        enemy$skips_turn <- TRUE
      }

      # Decrease duration
      effect$duration <- effect$duration - 1
      enemy$status_effects[[effect_name]] <- effect

      # Mark for removal if expired
      if (effect$duration <= 0) {
        effects_to_remove <- c(effects_to_remove, effect_name)
      }
    }

    # Remove expired effects
    for (effect_name in effects_to_remove) {
      enemy$status_effects[[effect_name]] <- NULL
    }

    state$enemies[[i]] <- enemy
  }

  return(state)
}

# ============================================================================
# Get Status Effect Bonuses
# ============================================================================

get_status_attack_bonus <- function(status_effects) {
  if (is.null(status_effects) || length(status_effects) == 0) {
    return(0)
  }

  bonus <- 0
  for (effect in status_effects) {
    if (!is.null(effect$definition$attack_bonus)) {
      bonus <- bonus + effect$definition$attack_bonus
    }
  }
  return(bonus)
}

get_status_defense_bonus <- function(status_effects) {
  if (is.null(status_effects) || length(status_effects) == 0) {
    return(0)
  }

  bonus <- 0
  for (effect in status_effects) {
    if (!is.null(effect$definition$defense_bonus)) {
      bonus <- bonus + effect$definition$defense_bonus
    }
  }
  return(bonus)
}

# ============================================================================
# Random Status Effect Application
# ============================================================================

# Chance to apply status effect on hit
try_apply_status_on_hit <- function(state, target_type, target_id = NULL, weapon = NULL) {
  # Weapons can have status effect properties
  if (!is.null(weapon) && !is.null(weapon$status_effect)) {
    effect_name <- weapon$status_effect$type
    chance <- weapon$status_effect$chance

    if (runif(1) < chance) {
      state <- apply_status_effect(state, target_type, target_id, effect_name)
    }
  }

  return(state)
}
