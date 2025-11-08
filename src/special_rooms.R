# ============================================================================
# Special Rooms System
# ============================================================================
# Implements Shop, Shrine, Treasure, Challenge, and other special rooms

# ============================================================================
# Room Type Definitions
# ============================================================================

get_special_room_types <- function() {
  list(
    shop = list(
      name = "Shop",
      char = "$",
      color = "yellow",
      icon = "🛒",
      spawn_chance = 0.15,
      description = "A traveling merchant's stall"
    ),
    shrine = list(
      name = "Shrine",
      char = "†",
      color = "blue",
      icon = "⛪",
      spawn_chance = 0.10,
      description = "An ancient shrine"
    ),
    treasure = list(
      name = "Treasure Room",
      char = "T",
      color = "magenta",
      icon = "💎",
      spawn_chance = 0.08,
      description = "A room filled with treasure"
    ),
    challenge = list(
      name = "Challenge Room",
      char = "!",
      color = "red",
      icon = "⚔️",
      spawn_chance = 0.10,
      description = "A dangerous challenge awaits"
    ),
    altar = list(
      name = "Altar",
      char = "A",
      color = "cyan",
      icon = "🔮",
      spawn_chance = 0.08,
      description = "A mystical altar"
    ),
    fountain = list(
      name = "Fountain",
      char = "~",
      color = "blue",
      icon = "⛲",
      spawn_chance = 0.12,
      description = "A healing fountain"
    ),
    library = list(
      name = "Library",
      char = "L",
      color = "gray",
      icon = "📚",
      spawn_chance = 0.07,
      description = "Ancient knowledge lies here"
    )
  )
}

# ============================================================================
# Generate Special Rooms
# ============================================================================

generate_special_rooms <- function(state) {
  # Chance to have 1-2 special rooms per level
  num_rooms <- sample(0:2, 1, prob = c(0.3, 0.5, 0.2))

  if (num_rooms == 0 || length(state$rooms) < 2) {
    return(list())
  }

  special_rooms <- list()
  room_types <- get_special_room_types()
  available_rooms <- state$rooms

  # Remove first room (spawn room) and last room (stairs room)
  if (length(available_rooms) > 2) {
    available_rooms <- available_rooms[2:(length(available_rooms) - 1)]
  }

  for (i in 1:num_rooms) {
    if (length(available_rooms) == 0) break

    # Select room type based on spawn chances
    room_type <- sample_room_type(room_types)
    room_def <- room_types[[room_type]]

    # Select random available room
    room_idx <- sample(1:length(available_rooms), 1)
    room <- available_rooms[[room_idx]]
    available_rooms <- available_rooms[-room_idx]

    # Place special room marker at room center
    special_room <- list(
      type = room_type,
      name = room_def$name,
      char = room_def$char,
      color = room_def$color,
      icon = room_def$icon,
      x = room$center_x,
      y = room$center_y,
      visited = FALSE,
      description = room_def$description,
      data = init_room_data(room_type, state$level)
    )

    special_rooms[[length(special_rooms) + 1]] <- special_room
  }

  return(special_rooms)
}

sample_room_type <- function(room_types) {
  type_names <- names(room_types)
  chances <- sapply(room_types, function(r) r$spawn_chance)

  return(sample(type_names, 1, prob = chances))
}

# ============================================================================
# Initialize Room Data
# ============================================================================

init_room_data <- function(room_type, level) {
  switch(room_type,
    shop = init_shop_data(level),
    shrine = init_shrine_data(level),
    treasure = init_treasure_data(level),
    challenge = init_challenge_data(level),
    altar = init_altar_data(level),
    fountain = init_fountain_data(level),
    library = init_library_data(level),
    list()
  )
}

# ============================================================================
# Shop Room
# ============================================================================

init_shop_data <- function(level) {
  # Generate 3-5 items for sale
  num_items <- sample(3:5, 1)
  items <- list()

  for (i in 1:num_items) {
    # Use extended item generation if available
    if (exists("generate_random_item")) {
      item <- generate_random_item(level)
    } else {
      item <- generate_basic_item(level)
    }

    # Add price (2x value)
    item$price <- round(item$value * 2)
    items[[i]] <- item
  }

  return(list(
    items = items,
    purchases = 0
  ))
}

interact_shop <- function(state, room) {
  cat("\n")
  cat("🛒 ═════════════════════════════════════════\n")
  cat("           TRAVELING MERCHANT\n")
  cat("═════════════════════════════════════════\n\n")
  cat(sprintf("Your Gold: %d\n\n", state$player$gold))

  if (length(room$data$items) == 0) {
    cat("The merchant has no more items for sale.\n")
    return(state)
  }

  cat("Items for sale:\n")
  for (i in seq_along(room$data$items)) {
    item <- room$data$items[[i]]
    cat(sprintf("[%d] %s - %d gold\n", i, item$name, item$price))
    if (!is.null(item$description)) {
      cat(sprintf("    %s\n", item$description))
    }
  }

  cat("\n[0] Leave\n")
  choice <- readline("Enter choice: ")
  choice_num <- suppressWarnings(as.integer(choice))

  if (is.na(choice_num) || choice_num == 0) {
    return(state)
  }

  if (choice_num > 0 && choice_num <= length(room$data$items)) {
    item <- room$data$items[[choice_num]]

    if (state$player$gold >= item$price) {
      # Purchase item
      state$player$gold <- state$player$gold - item$price
      state$message_log <- c(state$message_log,
                            sprintf("Purchased %s for %d gold!", item$name, item$price))

      # Equip item
      if (item$type == "weapon") {
        state$player$weapon <- item
      } else if (item$type == "armor") {
        state$player$armor <- item
      } else if (item$type == "potion") {
        # Add to inventory
        state$player$potions <- c(state$player$potions, list(item))
      }

      # Remove from shop
      room$data$items <- room$data$items[-choice_num]
      room$data$purchases <- room$data$purchases + 1

    } else {
      cat("Not enough gold!\n")
      Sys.sleep(1)
    }
  }

  return(state)
}

# ============================================================================
# Shrine Room
# ============================================================================

init_shrine_data <- function(level) {
  # Random blessing
  blessings <- c("health", "strength", "protection", "skill")
  blessing <- sample(blessings, 1)

  return(list(
    blessing = blessing,
    used = FALSE
  ))
}

interact_shrine <- function(state, room) {
  if (room$data$used) {
    state$message_log <- c(state$message_log, "The shrine has been used.")
    return(state)
  }

  blessing <- room$data$blessing

  cat("\n⛪ You approach the ancient shrine...\n")
  cat("A divine presence fills the air.\n\n")

  state <- apply_blessing(state, blessing)
  room$data$used <- TRUE

  return(state)
}

apply_blessing <- function(state, blessing) {
  switch(blessing,
    health = {
      heal_amount <- round(state$player$max_hp * 0.5)
      state$player$hp <- min(state$player$max_hp, state$player$hp + heal_amount)
      state$message_log <- c(state$message_log,
                            sprintf("✨ Blessing of Health: Restored %d HP!", heal_amount))
    },
    strength = {
      state$player$attack <- state$player$attack + 5
      state$message_log <- c(state$message_log,
                            "✨ Blessing of Strength: +5 Attack!")
    },
    protection = {
      state$player$defense <- state$player$defense + 3
      state$message_log <- c(state$message_log,
                            "✨ Blessing of Protection: +3 Defense!")
    },
    skill = {
      if (!is.null(state$abilities)) {
        state$abilities$skill_points <- state$abilities$skill_points + 1
        state$message_log <- c(state$message_log,
                              "✨ Blessing of Skill: +1 Skill Point!")
      }
    }
  )

  return(state)
}

# ============================================================================
# Treasure Room
# ============================================================================

init_treasure_data <- function(level) {
  # Guaranteed rare+ items
  num_items <- sample(2:4, 1)
  items <- list()

  for (i in 1:num_items) {
    rarity <- sample(c("rare", "legendary"), 1, prob = c(0.7, 0.3))
    if (exists("generate_random_item")) {
      item <- generate_random_item(level, forced_rarity = rarity)
    } else {
      item <- generate_basic_item(level)
    }
    items[[i]] <- item
  }

  return(list(
    items = items,
    looted = FALSE
  ))
}

interact_treasure <- function(state, room) {
  if (room$data$looted) {
    state$message_log <- c(state$message_log, "The treasure room has been looted.")
    return(state)
  }

  cat("\n💎 ═════════════════════════════════════════\n")
  cat("           TREASURE ROOM\n")
  cat("═════════════════════════════════════════\n\n")
  cat("You found:\n")

  for (item in room$data$items) {
    cat(sprintf("- %s\n", item$name))

    # Auto-pickup items
    if (item$type == "weapon") {
      state$player$weapon <- item
    } else if (item$type == "armor") {
      state$player$armor <- item
    }
  }

  room$data$looted <- TRUE
  state$message_log <- c(state$message_log, "Looted the treasure room!")

  return(state)
}

# ============================================================================
# Challenge Room
# ============================================================================

init_challenge_data <- function(level) {
  challenge_types <- c("survival", "boss_rush", "time_trial")
  challenge <- sample(challenge_types, 1)

  return(list(
    challenge_type = challenge,
    completed = FALSE,
    reward_claimed = FALSE
  ))
}

interact_challenge <- function(state, room) {
  if (room$data$completed) {
    if (!room$data$reward_claimed) {
      # Grant reward
      state <- grant_challenge_reward(state, room$data$challenge_type, state$level)
      room$data$reward_claimed <- TRUE
    } else {
      state$message_log <- c(state$message_log, "Challenge already completed.")
    }
    return(state)
  }

  cat("\n⚔️ ═════════════════════════════════════════\n")
  cat("           CHALLENGE ROOM\n")
  cat("═════════════════════════════════════════\n\n")
  cat("A dangerous challenge awaits!\n")
  cat("Complete it for a great reward.\n\n")

  # For now, just spawn extra enemies
  state <- spawn_challenge_enemies(state, state$level)
  room$data$completed <- TRUE

  return(state)
}

spawn_challenge_enemies <- function(state, level) {
  # Spawn 3-5 tough enemies
  num_enemies <- sample(3:5, 1)

  for (i in 1:num_enemies) {
    enemy <- create_enemy(level + 2, state)  # Stronger enemies
    state$enemies[[length(state$enemies) + 1]] <- enemy
  }

  state$message_log <- c(state$message_log,
                        sprintf("Challenge started! %d enemies appeared!", num_enemies))

  return(state)
}

grant_challenge_reward <- function(state, challenge_type, level) {
  # Grant legendary item + souls
  if (exists("generate_random_item")) {
    item <- generate_random_item(level, forced_rarity = "legendary")
  } else {
    item <- generate_basic_item(level)
  }

  if (item$type == "weapon") {
    state$player$weapon <- item
  } else if (item$type == "armor") {
    state$player$armor <- item
  }

  souls_reward <- 100
  if (!is.null(state$meta$souls)) {
    state$meta$souls <- state$meta$souls + souls_reward
  }

  state$message_log <- c(state$message_log,
                        sprintf("🏆 Challenge completed! Received %s and %d souls!",
                              item$name, souls_reward))

  return(state)
}

# ============================================================================
# Fountain Room
# ============================================================================

init_fountain_data <- function(level) {
  return(list(used = FALSE))
}

interact_fountain <- function(state, room) {
  if (room$data$used) {
    state$message_log <- c(state$message_log, "The fountain is dry.")
    return(state)
  }

  # Full heal
  old_hp <- state$player$hp
  state$player$hp <- state$player$max_hp
  heal_amount <- state$player$hp - old_hp

  # Remove status effects
  state$player$status_effects <- list()

  state$message_log <- c(state$message_log,
                        sprintf("⛲ The fountain's waters restore you! Healed %d HP!", heal_amount))

  room$data$used <- TRUE

  return(state)
}

# ============================================================================
# Altar & Library (Simplified)
# ============================================================================

init_altar_data <- function(level) {
  return(list(used = FALSE))
}

interact_altar <- function(state, room) {
  if (room$data$used) return(state)

  # Trade HP for power
  hp_cost <- round(state$player$max_hp * 0.2)
  state$player$hp <- max(1, state$player$hp - hp_cost)
  state$player$attack <- state$player$attack + 10

  state$message_log <- c(state$message_log,
                        sprintf("🔮 Sacrificed %d HP for +10 Attack!", hp_cost))

  room$data$used <- TRUE
  return(state)
}

init_library_data <- function(level) {
  return(list(used = FALSE))
}

interact_library <- function(state, room) {
  if (room$data$used) return(state)

  # Grant skill point
  if (!is.null(state$abilities)) {
    state$abilities$skill_points <- state$abilities$skill_points + 2
    state$message_log <- c(state$message_log, "📚 You gained knowledge! +2 Skill Points!")
  }

  room$data$used <- TRUE
  return(state)
}

# ============================================================================
# Helper Functions
# ============================================================================

generate_basic_item <- function(level) {
  # Fallback if extended item system not available
  item_type <- sample(c("weapon", "armor"), 1)

  if (item_type == "weapon") {
    return(list(
      name = "Sword",
      type = "weapon",
      damage = 10 + level * 2,
      char = "/",
      value = 50
    ))
  } else {
    return(list(
      name = "Armor",
      type = "armor",
      defense = 5 + level,
      char = "[",
      value = 50
    ))
  }
}

create_enemy <- function(level, state) {
  # Simplified enemy creation
  return(list(
    name = "Enemy",
    x = state$player$x + sample(-5:5, 1),
    y = state$player$y + sample(-5:5, 1),
    hp = 30 + level * 10,
    max_hp = 30 + level * 10,
    attack = 5 + level * 2,
    defense = 2 + level,
    alive = TRUE,
    is_boss = FALSE,
    char = "E",
    id = paste0("enemy_", runif(1))
  ))
}
