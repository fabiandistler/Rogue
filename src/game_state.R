# ============================================================================
# Game State Management
# ============================================================================
# Manages the core game state including player, enemies, map, and items

init_game_state <- function(seed = NULL, meta = NULL) {
  if (is.null(seed)) {
    seed <- sample.int(.Machine$integer.max, 1)
  }
  set.seed(seed)

  # Generate initial dungeon
  dungeon <- generate_dungeon(width = 40, height = 20)

  # Find starting position (first room center)
  start_pos <- dungeon$start_pos

  # Select theme for level 1
  theme <- select_theme_for_level(1)

  # Initialize player
  player <- list(
    x = start_pos$x,
    y = start_pos$y,
    hp = 120,
    max_hp = 120,
    attack = 12,
    defense = 6,
    gold = 25,
    inventory = list(),
    weapon = list(name = "Iron Sword", damage = 8),
    armor = list(name = "Leather Armor", defense = 4)
  )

  # Apply meta progression bonuses
  if (!is.null(meta)) {
    player <- apply_meta_bonuses(player, meta)

    # Add starting potions if survivor bonus
    if ("survivor" %in% meta$active_bonuses) {
      # Will add potions as items later
    }
  }

  # Spawn enemies (fewer at start for easier beginning)
  enemies <- spawn_enemies(dungeon, start_pos, count = 3, level = 1)

  # Apply theme to enemies
  enemies <- apply_theme_to_enemies(enemies, theme, 1)

  # Spawn items
  items <- spawn_items(dungeon, start_pos, count = 3)

  # Add 2 starting health potions for easier early game
  for (i in 1:2) {
    potion <- list(
      name = "Health Potion",
      type = "potion",
      effect = "heal",
      value = 30,
      char = "!",
      x = start_pos$x,
      y = start_pos$y,
      id = length(items) + 1,
      picked = FALSE
    )
    items <- c(items, list(potion))
  }

  # Add extra starting potions if survivor bonus
  if (!is.null(meta) && "survivor" %in% meta$active_bonuses) {
    for (i in 1:2) {
      potion <- list(
        name = "Health Potion",
        type = "potion",
        effect = "heal",
        value = 30,
        char = "!",
        x = start_pos$x,
        y = start_pos$y,
        id = length(items) + 1,
        picked = FALSE
      )
      items <- c(items, list(potion))
    }
  }

  # Initialize new systems (if available)
  traps <- if (exists("generate_traps")) generate_traps(list(map = dungeon$map, level = 1, rooms = dungeon$rooms, player = list(x = start_pos$x, y = start_pos$y), stairs_pos = dungeon$stairs_pos, enemies = enemies, items = items)) else list()
  special_rooms <- if (exists("generate_special_rooms")) generate_special_rooms(list(level = 1, rooms = dungeon$rooms)) else list()
  achievements <- if (exists("init_achievements")) init_achievements() else list()

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
      damage_taken = 0,
      turns = 0,
      max_level_reached = 1,
      legendary_items_found = 0,
      legendaries_this_run = 0,
      abilities_used = 0
    ),
    seed = seed,
    fov = init_fov_state(dungeon$map),
    theme = theme,
    abilities = init_abilities(),
    meta = meta,
    # New systems
    traps = traps,
    special_rooms = special_rooms,
    achievements = achievements,
    ui = list(
      minimap_enabled = FALSE,
      show_particles = TRUE
    ),
    particles = list()
  )

  # Initialize player status effects
  state$player$status_effects <- if (exists("init_status_effects")) init_status_effects() else list()
  state$player$potions <- list()

  # Calculate initial FOV
  state <- calculate_fov(state)

  add_message(state, "Welcome to the dungeon!")
  return(state)
}

# Spawn enemies in random positions
spawn_enemies <- function(dungeon, start_pos, count = 5, level = 1) {
  enemies <- list()
  map <- dungeon$map

  enemy_types <- list(
    list(name = "Goblin", hp = 15, attack = 4, defense = 1, xp = 10, char = "g", is_boss = FALSE),
    list(name = "Orc", hp = 35, attack = 7, defense = 3, xp = 20, char = "o", is_boss = FALSE),
    list(name = "Troll", hp = 55, attack = 10, defense = 5, xp = 30, char = "T", is_boss = FALSE)
  )

  # Boss types
  boss_types <- list(
    list(name = "Goblin King", hp = 100, attack = 15, defense = 8, xp = 100, char = "G", is_boss = TRUE),
    list(name = "Orc Chieftain", hp = 150, attack = 20, defense = 12, xp = 150, char = "O", is_boss = TRUE),
    list(name = "Troll Warlord", hp = 200, attack = 25, defense = 15, xp = 200, char = "W", is_boss = TRUE),
    list(name = "Ancient Dragon", hp = 300, attack = 35, defense = 20, xp = 300, char = "D", is_boss = TRUE)
  )

  # Check if this is a boss level (every 3 levels)
  is_boss_level <- (level %% 3 == 0)

  if (is_boss_level) {
    # Spawn a boss
    boss_idx <- min(ceiling(level / 3), length(boss_types))
    boss_type <- boss_types[[boss_idx]]

    # Find position for boss (far from start)
    repeat {
      x <- sample(2:(ncol(map) - 1), 1)
      y <- sample(2:(nrow(map) - 1), 1)

      if (map[y, x] == "." &&
          abs(x - start_pos$x) + abs(y - start_pos$y) > 10) {
        break
      }
    }

    enemies[[1]] <- c(
      boss_type,
      list(
        x = x,
        y = y,
        id = 1,
        alive = TRUE
      )
    )

    # Reduce regular enemy count on boss levels
    count <- ceiling(count * 0.6)
    start_idx <- 2
  } else {
    start_idx <- 1
  }

  # Spawn regular enemies
  for (i in start_idx:(start_idx + count - 1)) {
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

  if (action == "abilities") {
    state <- show_abilities(state)
    return(state)
  }

  if (action == "meta") {
    if (!is.null(state$meta)) {
      cat("\033[2J\033[H")
      show_meta_stats(state$meta)
      cat("\nPress ENTER to continue...")
      readline()
    }
    return(state)
  }

  # Auto-explore
  if (action == "auto_explore" || action == "o") {
    if (exists("auto_explore")) {
      state <- auto_explore(state)
      state$player_acted <- TRUE
    } else {
      state <- add_message(state, "Auto-explore not available.")
    }
    return(state)
  }

  # Toggle minimap
  if (action == "minimap" || action == "m") {
    if (exists("toggle_minimap")) {
      state <- toggle_minimap(state)
    } else {
      state <- add_message(state, "Minimap not available.")
    }
    return(state)
  }

  # Search for traps
  if (action == "search" || action == "f") {
    if (exists("search_for_traps")) {
      state <- search_for_traps(state)
      state$player_acted <- TRUE
    } else {
      state <- add_message(state, "Search not available.")
    }
    return(state)
  }

  # View achievements
  if (action == "achievements" || action == "v") {
    if (exists("display_achievements")) {
      cat("\033[2J\033[H")
      display_achievements(state)
      cat("\nPress ENTER to continue...")
      readline()
    } else {
      state <- add_message(state, "Achievements not available.")
    }
    return(state)
  }

  # View leaderboard
  if (action == "leaderboard" || action == "b") {
    if (exists("display_leaderboard")) {
      cat("\033[2J\033[H")
      display_leaderboard()
      cat("\nPress ENTER to continue...")
      readline()
    } else {
      state <- add_message(state, "Leaderboard not available.")
    }
    return(state)
  }

  # Show help
  if (action == "help" || action == "?") {
    cat("\033[2J\033[H")
    show_help()
    cat("\nPress ENTER to continue...")
    readline()
    return(state)
  }

  # Interact with special room
  if (action == "interact" || action == "e") {
    if (!is.null(state$special_rooms)) {
      for (i in seq_along(state$special_rooms)) {
        room <- state$special_rooms[[i]]
        if (room$x == state$player$x && room$y == state$player$y && !room$visited) {
          # Interact with room
          interact_func <- paste0("interact_", room$type)
          if (exists(interact_func)) {
            state <- do.call(interact_func, list(state, room))
            state$special_rooms[[i]]$visited <- TRUE
          } else {
            state <- add_message(state, sprintf("You explore the %s.", room$name))
            state$special_rooms[[i]]$visited <- TRUE
          }
          state$player_acted <- TRUE
          return(state)
        }
      }
      state <- add_message(state, "Nothing to interact with here.")
    }
    return(state)
  }

  # Handle movement
  if (action %in% c("w", "a", "s", "d")) {
    new_pos <- calculate_new_position(state$player, action)

    # Check for enemy FIRST (before walkability check)
    # This ensures combat always works even if there are edge cases
    enemy <- get_enemy_at(state, new_pos$x, new_pos$y)

    if (!is.null(enemy)) {
      # Attack enemy
      state <- player_attack(state, enemy)
      state$player_acted <- TRUE
    } else if (is_walkable(state, new_pos$x, new_pos$y)) {
      # No enemy, check if we can move
      # Move player
      state$player$x <- new_pos$x
      state$player$y <- new_pos$y
      state$player_acted <- TRUE

      # Recalculate FOV after movement
      state <- calculate_fov(state)

      # Check for traps
      if (exists("get_trap_at") && !is.null(state$traps)) {
        trap_result <- get_trap_at(state, new_pos$x, new_pos$y)
        if (!is.null(trap_result)) {
          state <- trigger_trap(state, trap_result$index)
        }
      }

      # Check for special rooms
      if (exists("get_special_room_at") && !is.null(state$special_rooms)) {
        for (i in seq_along(state$special_rooms)) {
          room <- state$special_rooms[[i]]
          if (room$x == new_pos$x && room$y == new_pos$y && !room$visited) {
            state$message_log <- c(state$message_log,
                                  sprintf("You found a %s! Press 'e' to interact.", room$name))
          }
        }
      }

      # Check for item pickup
      item <- get_item_at(state, new_pos$x, new_pos$y)
      if (!is.null(item)) {
        state <- pickup_item(state, item)
      }

      # Check for stairs
      if (new_pos$x == state$stairs_pos$x && new_pos$y == state$stairs_pos$y) {
        state <- descend_stairs(state)
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
    state$stats$items_collected <- state$stats$items_collected + 1
  } else if (item$effect == "gold") {
    state$player$gold <- state$player$gold + item$value
    state <- add_message(state, sprintf("You collect %d gold!", item$value))
    state$stats$items_collected <- state$stats$items_collected + 1
  } else if (item$effect == "weapon") {
    # Only equip if better
    if (item$value > state$player$weapon$damage) {
      old_weapon <- state$player$weapon$name
      old_damage <- state$player$weapon$damage
      state$player$weapon <- list(name = item$name, damage = item$value)
      state <- add_message(state, sprintf("You equip %s (+%d DMG, was: %s +%d)!",
                                          item$name, item$value, old_weapon, old_damage))
      state$stats$items_collected <- state$stats$items_collected + 1
    } else {
      state <- add_message(state, sprintf("You ignore %s (worse than %s)",
                                          item$name, state$player$weapon$name))
    }
  } else if (item$effect == "armor") {
    # Only equip if better
    if (item$value > state$player$armor$defense) {
      old_armor <- state$player$armor$name
      old_defense <- state$player$armor$defense
      state$player$armor <- list(name = item$name, defense = item$value)
      state <- add_message(state, sprintf("You equip %s (+%d DEF, was: %s +%d)!",
                                          item$name, item$value, old_armor, old_defense))
      state$stats$items_collected <- state$stats$items_collected + 1
    } else {
      state <- add_message(state, sprintf("You ignore %s (worse than %s)",
                                          item$name, state$player$armor$name))
    }
  }

  return(state)
}

# Descend stairs
descend_stairs <- function(state) {
  state$level <- state$level + 1

  # Gain skill point
  state <- gain_skill_point(state)

  # Check if this is a boss level
  if (state$level %% 3 == 0) {
    state <- add_message(state, sprintf("*** BOSS LEVEL %d ***", state$level))
    state <- add_message(state, "You sense a powerful presence...")
  } else {
    state <- add_message(state, sprintf("You descend to level %d!", state$level))
  }

  # Select new theme
  state$theme <- select_theme_for_level(state$level)

  # Generate new dungeon
  dungeon <- generate_dungeon(width = 40, height = 20, difficulty = state$level)
  state$map <- dungeon$map
  state$rooms <- dungeon$rooms
  state$stairs_pos <- dungeon$stairs_pos

  # Place player at start
  state$player$x <- dungeon$start_pos$x
  state$player$y <- dungeon$start_pos$y

  # Reinitialize FOV for new level
  state$fov <- init_fov_state(dungeon$map)

  # Apply dungeon mapper bonus (increased FOV)
  if (!is.null(state$meta) && "dungeon_mapper" %in% state$meta$active_bonuses) {
    state <- calculate_fov(state, radius = 10)
  } else {
    state <- calculate_fov(state)
  }

  # Heal player slightly
  state$player$hp <- min(state$player$max_hp, state$player$hp + 20)

  # Spawn more enemies
  enemy_count <- 5 + state$level
  state$enemies <- spawn_enemies(dungeon, dungeon$start_pos, count = enemy_count, level = state$level)

  # Apply theme to enemies
  state$enemies <- apply_theme_to_enemies(state$enemies, state$theme, state$level)

  # Spawn more items
  item_count <- 3 + floor(state$level / 2)
  state$items <- spawn_items(dungeon, dungeon$start_pos, count = item_count)

  # Generate new traps and special rooms
  if (exists("generate_traps")) {
    state$traps <- generate_traps(state)
  }

  if (exists("generate_special_rooms")) {
    state$special_rooms <- generate_special_rooms(state)
  }

  # Update max level reached
  if (state$level > state$stats$max_level_reached) {
    state$stats$max_level_reached <- state$level
  }

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

# Show help screen
show_help <- function() {
  cat("═══════════════════════════════════════════════════════\n")
  cat("                    ROGUE - HELP\n")
  cat("═══════════════════════════════════════════════════════\n\n")

  cat("MOVEMENT:\n")
  cat("  w/a/s/d - Move up/left/down/right\n")
  cat("  5w, 10d - Multi-step movement (stops at enemies)\n\n")

  cat("ACTIONS:\n")
  cat("  e - Interact with special rooms/items\n")
  cat("  f - Search for nearby traps\n")
  cat("  o - Auto-explore (finds unexplored areas)\n")
  cat("  1-5 - Use abilities\n\n")

  cat("MENUS:\n")
  cat("  i - Inventory\n")
  cat("  k - Abilities menu\n")
  cat("  m - Toggle minimap\n")
  cat("  p - Meta-progression stats\n")
  cat("  v - View achievements\n")
  cat("  b - View leaderboard\n")
  cat("  ? - This help screen\n")
  cat("  q - Quit game\n\n")

  cat("OBJECTIVES:\n")
  cat("  - Reach level 10 to win\n")
  cat("  - Defeat bosses every 3 levels\n")
  cat("  - Collect loot and upgrade equipment\n")
  cat("  - Complete achievements for soul rewards\n\n")

  cat("SPECIAL FEATURES:\n")
  cat("  - Status Effects: Poison, Burn, Freeze, etc.\n")
  cat("  - Item Rarities: Common, Uncommon, Rare, Legendary\n")
  cat("  - Special Rooms: Shop, Shrine, Treasure, Challenge\n")
  cat("  - Traps: Search and disarm to avoid damage\n")
  cat("  - Achievements: 25+ unique achievements\n")
  cat("  - Leaderboard: Compete for high scores\n\n")

  cat("═══════════════════════════════════════════════════════\n")
}
