# ============================================================================
# Game State Management
# ============================================================================
# Manages the core game state including player, enemies, map, and items

init_game_state <- function(seed = NULL) {
  if (is.null(seed)) {
    seed <- sample.int(.Machine$integer.max, 1)
  }
  set.seed(seed)

  # Generate initial dungeon
  dungeon <- generate_dungeon(width = 40, height = 20)

  # Find starting position (first room center)
  start_pos <- dungeon$start_pos

  # Initialize player
  player <- list(
    x = start_pos$x,
    y = start_pos$y,
    hp = 100,
    max_hp = 100,
    attack = 10,
    defense = 5,
    gold = 0,
    inventory = list(),
    weapon = list(name = "Rusty Sword", damage = 5),
    armor = list(name = "Cloth Armor", defense = 2)
  )

  # Spawn enemies
  enemies <- spawn_enemies(dungeon, start_pos, count = 5)

  # Spawn items
  items <- spawn_items(dungeon, start_pos, count = 3)

  # Create state
  state <- list(
    player = player,
    enemies = enemies,
    items = items,
    map = dungeon$map,
    rooms = dungeon$rooms,
    stairs_pos = dungeon$stairs_pos,
    level = 1,
    running = TRUE,
    player_acted = FALSE,
    message_log = character(0),
    stats = list(
      kills = 0,
      items_collected = 0,
      damage_dealt = 0,
      damage_taken = 0
    ),
    seed = seed
  )

  add_message(state, "Welcome to the dungeon!")
  return(state)
}

# Spawn enemies in random positions
spawn_enemies <- function(dungeon, start_pos, count = 5) {
  enemies <- list()
  map <- dungeon$map

  enemy_types <- list(
    list(name = "Goblin", hp = 20, attack = 5, defense = 2, xp = 10, char = "g"),
    list(name = "Orc", hp = 40, attack = 8, defense = 4, xp = 20, char = "o"),
    list(name = "Troll", hp = 60, attack = 12, defense = 6, xp = 30, char = "T")
  )

  for (i in 1:count) {
    # Find random walkable position
    repeat {
      x <- sample(2:(ncol(map) - 1), 1)
      y <- sample(2:(nrow(map) - 1), 1)

      # Check if walkable and not too close to start
      if (map[y, x] == "." &&
          abs(x - start_pos$x) + abs(y - start_pos$y) > 5) {
        break
      }
    }

    # Select enemy type based on level
    enemy_type <- sample(enemy_types, 1)[[1]]

    enemies[[i]] <- c(
      enemy_type,
      list(
        x = x,
        y = y,
        id = i,
        alive = TRUE
      )
    )
  }

  return(enemies)
}

# Spawn items in random positions
spawn_items <- function(dungeon, start_pos, count = 3) {
  items <- list()
  map <- dungeon$map

  item_types <- list(
    list(name = "Health Potion", type = "potion", effect = "heal", value = 30, char = "!"),
    list(name = "Gold Coin", type = "gold", effect = "gold", value = 10, char = "$"),
    list(name = "Steel Sword", type = "weapon", effect = "weapon", value = 15, char = "/"),
    list(name = "Leather Armor", type = "armor", effect = "armor", value = 5, char = "[")
  )

  for (i in 1:count) {
    # Find random walkable position
    repeat {
      x <- sample(2:(ncol(map) - 1), 1)
      y <- sample(2:(nrow(map) - 1), 1)

      if (map[y, x] == ".") {
        break
      }
    }

    item_type <- sample(item_types, 1)[[1]]

    items[[i]] <- c(
      item_type,
      list(
        x = x,
        y = y,
        id = i,
        picked = FALSE
      )
    )
  }

  return(items)
}

# Add message to log
add_message <- function(state, msg) {
  state$message_log <- c(state$message_log, msg)
  # Keep only last 5 messages
  if (length(state$message_log) > 5) {
    state$message_log <- tail(state$message_log, 5)
  }
  return(state)
}

# Process player action
process_action <- function(state, action) {
  if (action == "quit") {
    state$running <- FALSE
    return(state)
  }

  if (action == "inventory") {
    show_inventory(state)
    return(state)
  }

  # Handle movement
  if (action %in% c("w", "a", "s", "d")) {
    new_pos <- calculate_new_position(state$player, action)

    # Check if valid move
    if (is_walkable(state, new_pos$x, new_pos$y)) {
      # Check for enemy collision
      enemy <- get_enemy_at(state, new_pos$x, new_pos$y)

      if (!is.null(enemy)) {
        # Attack enemy
        state <- player_attack(state, enemy)
        state$player_acted <- TRUE
      } else {
        # Move player
        state$player$x <- new_pos$x
        state$player$y <- new_pos$y
        state$player_acted <- TRUE

        # Check for item pickup
        item <- get_item_at(state, new_pos$x, new_pos$y)
        if (!is.null(item)) {
          state <- pickup_item(state, item)
        }

        # Check for stairs
        if (new_pos$x == state$stairs_pos$x && new_pos$y == state$stairs_pos$y) {
          state <- descend_stairs(state)
        }
      }
    } else {
      state <- add_message(state, "You bump into a wall.")
    }
  }

  return(state)
}

# Calculate new position based on direction
calculate_new_position <- function(player, direction) {
  x <- player$x
  y <- player$y

  if (direction == "w") y <- y - 1
  if (direction == "s") y <- y + 1
  if (direction == "a") x <- x - 1
  if (direction == "d") x <- x + 1

  return(list(x = x, y = y))
}

# Check if position is walkable
is_walkable <- function(state, x, y) {
  if (x < 1 || x > ncol(state$map) || y < 1 || y > nrow(state$map)) {
    return(FALSE)
  }
  return(state$map[y, x] != "#")
}

# Get enemy at position
get_enemy_at <- function(state, x, y) {
  for (enemy in state$enemies) {
    if (enemy$alive && enemy$x == x && enemy$y == y) {
      return(enemy)
    }
  }
  return(NULL)
}

# Get item at position
get_item_at <- function(state, x, y) {
  for (item in state$items) {
    if (!item$picked && item$x == x && item$y == y) {
      return(item)
    }
  }
  return(NULL)
}

# Pickup item
pickup_item <- function(state, item) {
  item_idx <- which(sapply(state$items, function(i) i$id == item$id))
  state$items[[item_idx]]$picked <- TRUE

  if (item$effect == "heal") {
    state$player$hp <- min(state$player$max_hp, state$player$hp + item$value)
    state <- add_message(state, sprintf("You drink a %s. (+%d HP)", item$name, item$value))
  } else if (item$effect == "gold") {
    state$player$gold <- state$player$gold + item$value
    state <- add_message(state, sprintf("You collect %d gold!", item$value))
  } else if (item$effect == "weapon") {
    old_weapon <- state$player$weapon$name
    state$player$weapon <- list(name = item$name, damage = item$value)
    state <- add_message(state, sprintf("You equip %s. (was: %s)", item$name, old_weapon))
  } else if (item$effect == "armor") {
    old_armor <- state$player$armor$name
    state$player$armor <- list(name = item$name, defense = item$value)
    state <- add_message(state, sprintf("You equip %s. (was: %s)", item$name, old_armor))
  }

  state$stats$items_collected <- state$stats$items_collected + 1
  return(state)
}

# Descend stairs
descend_stairs <- function(state) {
  state$level <- state$level + 1
  state <- add_message(state, sprintf("You descend to level %d!", state$level))

  # Generate new dungeon
  dungeon <- generate_dungeon(width = 40, height = 20, difficulty = state$level)
  state$map <- dungeon$map
  state$rooms <- dungeon$rooms
  state$stairs_pos <- dungeon$stairs_pos

  # Place player at start
  state$player$x <- dungeon$start_pos$x
  state$player$y <- dungeon$start_pos$y

  # Heal player slightly
  state$player$hp <- min(state$player$max_hp, state$player$hp + 20)

  # Spawn more enemies
  enemy_count <- 5 + state$level
  state$enemies <- spawn_enemies(dungeon, dungeon$start_pos, count = enemy_count)

  # Spawn more items
  item_count <- 3 + floor(state$level / 2)
  state$items <- spawn_items(dungeon, dungeon$start_pos, count = item_count)

  return(state)
}

# Show inventory
show_inventory <- function(state) {
  cat("\n=== INVENTORY ===\n")
  cat(sprintf("Weapon: %s (Damage: +%d)\n", state$player$weapon$name, state$player$weapon$damage))
  cat(sprintf("Armor: %s (Defense: +%d)\n", state$player$armor$name, state$player$armor$defense))
  cat(sprintf("Gold: %d\n", state$player$gold))
  cat("\nPress ENTER to continue...")
  readline()
}

# Check win/lose conditions
check_conditions <- function(state) {
  if (state$player$hp <= 0) {
    state$running <- FALSE
  }

  # Win condition: reach level 10
  if (state$level >= 10) {
    state$running <- FALSE
  }

  return(state)
}
