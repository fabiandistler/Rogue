# ============================================================================
# Auto-Explore System
# ============================================================================
# Automatically explores the dungeon until an enemy or item is found

# ============================================================================
# Auto-Explore Main Function
# ============================================================================

auto_explore <- function(state) {
  # Initialize auto-explore state
  max_steps <- 1000  # Prevent infinite loops
  steps_taken <- 0

  while (steps_taken < max_steps && state$running) {
    # Check if there are enemies nearby
    if (has_nearby_enemies(state, detection_range = 8)) {
      state$message_log <- c(state$message_log, "Auto-explore stopped: Enemy detected!")
      break
    }

    # Check if there's an unexplored item nearby
    if (has_nearby_items(state)) {
      state$message_log <- c(state$message_log, "Auto-explore stopped: Item found!")
      break
    }

    # Check if stairs are visible
    if (can_see_stairs(state)) {
      state$message_log <- c(state$message_log, "Auto-explore stopped: Stairs visible!")
      break
    }

    # Find next unexplored tile
    next_target <- find_nearest_unexplored(state)

    if (is.null(next_target)) {
      state$message_log <- c(state$message_log, "Auto-explore complete: All areas explored!")
      break
    }

    # Move towards target
    state <- move_towards_target(state, next_target)

    steps_taken <- steps_taken + 1

    # Update game state (enemies, FOV, etc.)
    state <- update_game_state_after_move(state)

    # Small delay for visualization (optional)
    # Sys.sleep(0.05)
  }

  if (steps_taken >= max_steps) {
    state$message_log <- c(state$message_log, "Auto-explore aborted: Too many steps!")
  }

  return(state)
}

# ============================================================================
# Helper Functions
# ============================================================================

has_nearby_enemies <- function(state, detection_range = 8) {
  player_x <- state$player$x
  player_y <- state$player$y

  for (enemy in state$enemies) {
    if (!enemy$alive) next

    dist <- manhattan_distance(player_x, player_y, enemy$x, enemy$y)
    if (dist <= detection_range) {
      return(TRUE)
    }
  }

  return(FALSE)
}

has_nearby_items <- function(state) {
  player_x <- state$player$x
  player_y <- state$player$y

  for (item in state$items) {
    if (item$picked) next

    # Check if item is visible
    if (is_visible(state, item$x, item$y)) {
      return(TRUE)
    }
  }

  return(FALSE)
}

can_see_stairs <- function(state) {
  return(is_visible(state, state$stairs_pos$x, state$stairs_pos$y))
}

# ============================================================================
# Pathfinding
# ============================================================================

find_nearest_unexplored <- function(state) {
  player_x <- state$player$x
  player_y <- state$player$y

  # Find all unexplored tiles within reasonable range
  search_range <- 50
  min_x <- max(1, player_x - search_range)
  max_x <- min(ncol(state$map), player_x + search_range)
  min_y <- max(1, player_y - search_range)
  max_y <- min(nrow(state$map), player_y + search_range)

  unexplored_tiles <- list()

  for (y in min_y:max_y) {
    for (x in min_x:max_x) {
      # Check if tile is walkable and not explored
      if (state$map[y, x] == "." && !is_explored(state, x, y)) {
        dist <- manhattan_distance(player_x, player_y, x, y)
        unexplored_tiles[[length(unexplored_tiles) + 1]] <- list(
          x = x,
          y = y,
          distance = dist
        )
      }
    }
  }

  if (length(unexplored_tiles) == 0) {
    return(NULL)
  }

  # Sort by distance and return closest
  unexplored_tiles <- unexplored_tiles[order(sapply(unexplored_tiles, function(t) t$distance))]
  return(unexplored_tiles[[1]])
}

move_towards_target <- function(state, target) {
  player_x <- state$player$x
  player_y <- state$player$y

  dx <- target$x - player_x
  dy <- target$y - player_y

  # Determine primary direction
  move_x <- 0
  move_y <- 0

  if (abs(dx) > abs(dy)) {
    # Move horizontally first
    move_x <- sign(dx)
  } else if (abs(dy) > 0) {
    # Move vertically
    move_y <- sign(dy)
  } else {
    # Already at target
    return(state)
  }

  # Try primary direction
  new_x <- player_x + move_x
  new_y <- player_y + move_y

  if (is_walkable(state, new_x, new_y)) {
    state$player$x <- new_x
    state$player$y <- new_y
    return(state)
  }

  # If blocked, try alternative direction
  if (move_x != 0) {
    # Try vertical instead
    move_x <- 0
    move_y <- sign(dy)
  } else {
    # Try horizontal instead
    move_y <- 0
    move_x <- sign(dx)
  }

  new_x <- player_x + move_x
  new_y <- player_y + move_y

  if (is_walkable(state, new_x, new_y)) {
    state$player$x <- new_x
    state$player$y <- new_y
  }

  return(state)
}

is_walkable <- function(state, x, y) {
  # Check bounds
  if (x < 1 || x > ncol(state$map) || y < 1 || y > nrow(state$map)) {
    return(FALSE)
  }

  # Check if floor or stairs
  if (state$map[y, x] != "." && state$map[y, x] != ">") {
    return(FALSE)
  }

  # Check if enemy is there
  for (enemy in state$enemies) {
    if (enemy$alive && enemy$x == x && enemy$y == y) {
      return(FALSE)
    }
  }

  return(TRUE)
}

update_game_state_after_move <- function(state) {
  # Update FOV
  state <- calculate_fov(state)

  # Process enemies (they get a turn)
  state <- process_enemies(state)

  # Process status effects
  if (exists("process_status_effects")) {
    state <- process_status_effects(state)
  }

  # Check for items at current position
  item <- get_item_at(state, state$player$x, state$player$y)
  if (!is.null(item) && !item$picked) {
    # Auto-pickup items during exploration
    state <- pickup_item(state, item)
  }

  return(state)
}

# ============================================================================
# Utility Functions
# ============================================================================

manhattan_distance <- function(x1, y1, x2, y2) {
  return(abs(x2 - x1) + abs(y2 - y1))
}

# ============================================================================
# Smart Auto-Explore (Advanced)
# ============================================================================

auto_explore_smart <- function(state) {
  # This version uses BFS to find optimal paths
  # and can navigate around obstacles more intelligently

  max_iterations <- 1000
  iterations <- 0

  while (iterations < max_iterations && state$running) {
    # Check stop conditions
    if (has_nearby_enemies(state, 8) || has_nearby_items(state) || can_see_stairs(state)) {
      break
    }

    # Use BFS to find path to nearest unexplored
    target <- find_nearest_unexplored_bfs(state)

    if (is.null(target)) {
      state$message_log <- c(state$message_log, "Auto-explore complete!")
      break
    }

    # Move one step along path
    state <- move_along_path(state, target$path)

    iterations <- iterations + 1
  }

  return(state)
}

find_nearest_unexplored_bfs <- function(state) {
  # Breadth-First Search to find nearest unexplored tile
  player_x <- state$player$x
  player_y <- state$player$y

  queue <- list(list(x = player_x, y = player_y, path = list()))
  visited <- matrix(FALSE, nrow = nrow(state$map), ncol = ncol(state$map))
  visited[player_y, player_x] <- TRUE

  directions <- list(
    list(dx = 0, dy = -1),  # Up
    list(dx = 0, dy = 1),   # Down
    list(dx = -1, dy = 0),  # Left
    list(dx = 1, dy = 0)    # Right
  )

  while (length(queue) > 0) {
    current <- queue[[1]]
    queue <- queue[-1]

    # Check if current tile is unexplored
    if (!is_explored(state, current$x, current$y) && state$map[current$y, current$x] == ".") {
      return(list(x = current$x, y = current$y, path = current$path))
    }

    # Explore neighbors
    for (dir in directions) {
      new_x <- current$x + dir$dx
      new_y <- current$y + dir$dy

      if (is_walkable(state, new_x, new_y) && !visited[new_y, new_x]) {
        visited[new_y, new_x] <- TRUE
        new_path <- c(current$path, list(list(x = new_x, y = new_y)))
        queue[[length(queue) + 1]] <- list(x = new_x, y = new_y, path = new_path)
      }
    }

    # Limit search depth
    if (length(queue) > 1000) break
  }

  return(NULL)
}

move_along_path <- function(state, path) {
  if (length(path) == 0) return(state)

  # Move to first step in path
  next_step <- path[[1]]
  state$player$x <- next_step$x
  state$player$y <- next_step$y

  # Update game state
  state <- update_game_state_after_move(state)

  return(state)
}
