# ============================================================================
# Traps System
# ============================================================================
# Implements various trap types for dungeon hazards

# ============================================================================
# Trap Type Definitions
# ============================================================================

get_trap_definitions <- function() {
  list(
    spike = list(
      name = "Spike Trap",
      char = "^",
      color = "red",
      icon = "▲",
      damage = 15,
      damage_scaling = 0.5,  # Per level
      description = "Sharp spikes emerge from the floor",
      trigger_chance = 1.0,
      visible_when_searched = TRUE
    ),
    arrow = list(
      name = "Arrow Trap",
      char = "►",
      color = "yellow",
      icon = "→",
      damage = 20,
      damage_scaling = 0.6,
      description = "Arrows shoot from the wall",
      trigger_chance = 0.8,
      visible_when_searched = TRUE
    ),
    poison = list(
      name = "Poison Gas Trap",
      char = "☁",
      color = "green",
      icon = "☠",
      damage = 10,
      damage_scaling = 0.3,
      status_effect = "poison",
      description = "Releases poisonous gas",
      trigger_chance = 1.0,
      visible_when_searched = TRUE
    ),
    fire = list(
      name = "Fire Trap",
      char = "~",
      color = "red",
      icon = "🔥",
      damage = 25,
      damage_scaling = 0.7,
      status_effect = "burn",
      description = "Erupts in flames",
      trigger_chance = 1.0,
      visible_when_searched = TRUE
    ),
    teleport = list(
      name = "Teleport Trap",
      char = "◈",
      color = "magenta",
      icon = "🌀",
      damage = 0,
      description = "Teleports you to a random location",
      trigger_chance = 1.0,
      visible_when_searched = TRUE
    ),
    alarm = list(
      name = "Alarm Trap",
      char = "!",
      color = "yellow",
      icon = "🔔",
      damage = 0,
      description = "Alerts all enemies to your location",
      trigger_chance = 1.0,
      visible_when_searched = FALSE
    ),
    freeze = list(
      name = "Ice Trap",
      char = "*",
      color = "cyan",
      icon = "❄",
      damage = 10,
      damage_scaling = 0.4,
      status_effect = "freeze",
      description = "Freezes you in place",
      trigger_chance = 1.0,
      visible_when_searched = TRUE
    ),
    net = list(
      name = "Net Trap",
      char = "#",
      color = "gray",
      icon = "🕸",
      damage = 0,
      status_effect = "stun",
      description = "Entangles you in a net",
      trigger_chance = 1.0,
      visible_when_searched = TRUE
    )
  )
}

# ============================================================================
# Generate Traps
# ============================================================================

generate_traps <- function(state) {
  # Number of traps scales with level
  base_traps <- 2
  level_traps <- floor(state$level * 0.5)
  num_traps <- base_traps + level_traps + sample(0:2, 1)

  traps <- list()
  trap_defs <- get_trap_definitions()

  # Find valid trap locations (floor tiles not near player/stairs)
  valid_locations <- find_valid_trap_locations(state)

  if (length(valid_locations) == 0) {
    return(list())
  }

  # Place traps
  for (i in 1:min(num_traps, length(valid_locations))) {
    # Select random trap type
    trap_type <- sample(names(trap_defs), 1)
    trap_def <- trap_defs[[trap_type]]

    # Select location
    location <- valid_locations[[i]]

    # Create trap
    trap <- list(
      type = trap_type,
      name = trap_def$name,
      char = trap_def$char,
      color = trap_def$color,
      icon = trap_def$icon,
      x = location$x,
      y = location$y,
      triggered = FALSE,
      discovered = FALSE,
      damage = calculate_trap_damage(trap_def, state$level),
      description = trap_def$description,
      definition = trap_def
    )

    traps[[length(traps) + 1]] <- trap
  }

  return(traps)
}

# ============================================================================
# Find Valid Trap Locations
# ============================================================================

find_valid_trap_locations <- function(state) {
  locations <- list()

  # Iterate through map
  for (y in 1:nrow(state$map)) {
    for (x in 1:ncol(state$map)) {
      # Must be floor tile
      if (state$map[y, x] != ".") next

      # Not near player start
      if (abs(x - state$player$x) < 3 && abs(y - state$player$y) < 3) next

      # Not near stairs
      if (abs(x - state$stairs_pos$x) < 2 && abs(y - state$stairs_pos$y) < 2) next

      # Not on enemy
      enemy_here <- FALSE
      for (enemy in state$enemies) {
        if (enemy$x == x && enemy$y == y) {
          enemy_here <- TRUE
          break
        }
      }
      if (enemy_here) next

      # Not on item
      item_here <- FALSE
      for (item in state$items) {
        if (item$x == x && item$y == y && !item$picked) {
          item_here <- TRUE
          break
        }
      }
      if (item_here) next

      # Valid location
      locations[[length(locations) + 1]] <- list(x = x, y = y)
    }
  }

  # Shuffle locations
  if (length(locations) > 0) {
    locations <- locations[sample(1:length(locations))]
  }

  return(locations)
}

# ============================================================================
# Calculate Trap Damage
# ============================================================================

calculate_trap_damage <- function(trap_def, level) {
  if (is.null(trap_def$damage) || trap_def$damage == 0) {
    return(0)
  }

  base_damage <- trap_def$damage
  scaling <- if (!is.null(trap_def$damage_scaling)) trap_def$damage_scaling else 0.5

  damage <- round(base_damage + level * scaling)
  return(damage)
}

# ============================================================================
# Trigger Trap
# ============================================================================

trigger_trap <- function(state, trap_idx) {
  trap <- state$traps[[trap_idx]]

  if (trap$triggered) {
    return(state)
  }

  # Check trigger chance
  if (runif(1) > trap$definition$trigger_chance) {
    return(state)
  }

  # Mark as triggered
  state$traps[[trap_idx]]$triggered <- TRUE

  # Add message
  state$message_log <- c(state$message_log,
                        sprintf("⚠️ You triggered a %s!", trap$name))

  # Apply trap effects
  state <- apply_trap_effects(state, trap)

  return(state)
}

# ============================================================================
# Apply Trap Effects
# ============================================================================

apply_trap_effects <- function(state, trap) {
  # Damage
  if (trap$damage > 0) {
    state$player$hp <- max(0, state$player$hp - trap$damage)
    state$message_log <- c(state$message_log,
                          sprintf("The trap deals %d damage!", trap$damage))

    # Track damage taken
    if (!is.null(state$stats$damage_taken)) {
      state$stats$damage_taken <- state$stats$damage_taken + trap$damage
    }
  }

  # Status effect
  if (!is.null(trap$definition$status_effect)) {
    if (exists("apply_status_effect")) {
      state <- apply_status_effect(state, "player", NULL, trap$definition$status_effect)
    }
  }

  # Special effects
  if (trap$type == "teleport") {
    state <- teleport_player_random(state)
  } else if (trap$type == "alarm") {
    state <- alert_all_enemies(state)
  }

  return(state)
}

# ============================================================================
# Teleport Player
# ============================================================================

teleport_player_random <- function(state) {
  # Find random floor tile
  attempts <- 0
  max_attempts <- 100

  while (attempts < max_attempts) {
    x <- sample(1:ncol(state$map), 1)
    y <- sample(1:nrow(state$map), 1)

    # Check if valid
    if (state$map[y, x] == ".") {
      # Check no enemy
      enemy_here <- any(sapply(state$enemies, function(e) e$alive && e$x == x && e$y == y))

      if (!enemy_here) {
        state$player$x <- x
        state$player$y <- y
        state$message_log <- c(state$message_log,
                              "You are teleported to a random location!")

        # Update FOV
        if (exists("calculate_fov")) {
          state$fov <- calculate_fov(state$map, state$player$x, state$player$y,
                                    state$fov$explored, state$meta$unlocks)
        }
        break
      }
    }

    attempts <- attempts + 1
  }

  return(state)
}

# ============================================================================
# Alert Enemies
# ============================================================================

alert_all_enemies <- function(state) {
  state$message_log <- c(state$message_log,
                        "The alarm alerts all enemies to your presence!")

  # Set all enemies to chase player
  for (i in seq_along(state$enemies)) {
    if (state$enemies[[i]]$alive) {
      state$enemies[[i]]$alerted <- TRUE
      state$enemies[[i]]$target_x <- state$player$x
      state$enemies[[i]]$target_y <- state$player$y
    }
  }

  return(state)
}

# ============================================================================
# Search for Traps
# ============================================================================

search_for_traps <- function(state, radius = 2) {
  player_x <- state$player$x
  player_y <- state$player$y

  discovered_count <- 0

  for (i in seq_along(state$traps)) {
    trap <- state$traps[[i]]

    if (trap$discovered || trap$triggered) next

    # Check if in range
    dist <- abs(trap$x - player_x) + abs(trap$y - player_y)

    if (dist <= radius) {
      # Chance to discover based on distance
      discover_chance <- 1.0 - (dist / radius) * 0.5

      if (runif(1) < discover_chance) {
        state$traps[[i]]$discovered <- TRUE
        discovered_count <- discovered_count + 1
      }
    }
  }

  if (discovered_count > 0) {
    state$message_log <- c(state$message_log,
                          sprintf("You discovered %d trap%s nearby!",
                                discovered_count,
                                if (discovered_count > 1) "s" else ""))
  } else {
    state$message_log <- c(state$message_log, "You found no traps nearby.")
  }

  return(state)
}

# ============================================================================
# Disarm Trap
# ============================================================================

disarm_trap <- function(state, trap_idx) {
  trap <- state$traps[[trap_idx]]

  if (!trap$discovered) {
    state$message_log <- c(state$message_log, "You must discover the trap first!")
    return(state)
  }

  if (trap$triggered) {
    state$message_log <- c(state$message_log, "This trap has already been triggered!")
    return(state)
  }

  # Disarm chance (50% base)
  disarm_chance <- 0.5

  if (runif(1) < disarm_chance) {
    # Success
    state$traps[[trap_idx]]$triggered <- TRUE  # Mark as safe
    state$message_log <- c(state$message_log,
                          sprintf("Successfully disarmed the %s!", trap$name))

    # Small XP/gold reward?
    reward_gold <- 10
    state$player$gold <- state$player$gold + reward_gold
    state$message_log <- c(state$message_log,
                          sprintf("You gained %d gold!", reward_gold))
  } else {
    # Failure - trigger trap
    state$message_log <- c(state$message_log, "Failed to disarm! The trap triggers!")
    state <- apply_trap_effects(state, trap)
    state$traps[[trap_idx]]$triggered <- TRUE
  }

  return(state)
}

# ============================================================================
# Check for Trap
# ============================================================================

get_trap_at <- function(state, x, y) {
  if (is.null(state$traps)) return(NULL)

  for (i in seq_along(state$traps)) {
    trap <- state$traps[[i]]
    if (trap$x == x && trap$y == y && !trap$triggered) {
      return(list(trap = trap, index = i))
    }
  }

  return(NULL)
}
