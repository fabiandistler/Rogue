# ============================================================================
# Minimap System
# ============================================================================
# Renders a small overview map in the corner of the screen

# ============================================================================
# Render Minimap
# ============================================================================

render_minimap <- function(state, size = 20) {
  # Create minimap matrix
  map_height <- nrow(state$map)
  map_width <- ncol(state$map)

  # Calculate scale factor
  scale_y <- map_height / size
  scale_x <- map_width / size

  minimap <- matrix(" ", nrow = size, ncol = size)

  # Downsample map
  for (y in 1:size) {
    for (x in 1:size) {
      # Map minimap coords to world coords
      world_x <- round(x * scale_x)
      world_y <- round(y * scale_y)

      # Clamp to valid coords
      world_x <- max(1, min(map_width, world_x))
      world_y <- max(1, min(map_height, world_y))

      # Check if explored
      if (!is_explored(state, world_x, world_y)) {
        minimap[y, x] <- " "
      } else {
        # Sample tile
        tile <- state$map[world_y, world_x]
        minimap[y, x] <- if (tile == "#") "█" else "·"
      }
    }
  }

  # Mark player position
  player_minimap_x <- round(state$player$x / scale_x)
  player_minimap_y <- round(state$player$y / scale_y)
  player_minimap_x <- max(1, min(size, player_minimap_x))
  player_minimap_y <- max(1, min(size, player_minimap_y))
  minimap[player_minimap_y, player_minimap_x] <- "@"

  # Mark stairs
  stairs_minimap_x <- round(state$stairs_pos$x / scale_x)
  stairs_minimap_y <- round(state$stairs_pos$y / scale_y)
  stairs_minimap_x <- max(1, min(size, stairs_minimap_x))
  stairs_minimap_y <- max(1, min(size, stairs_minimap_y))

  if (is_explored(state, state$stairs_pos$x, state$stairs_pos$y)) {
    minimap[stairs_minimap_y, stairs_minimap_x] <- ">"
  }

  # Mark special rooms if available
  if (!is.null(state$special_rooms)) {
    for (room in state$special_rooms) {
      if (!room$visited && is_explored(state, room$x, room$y)) {
        room_minimap_x <- round(room$x / scale_x)
        room_minimap_y <- round(room$y / scale_y)
        room_minimap_x <- max(1, min(size, room_minimap_x))
        room_minimap_y <- max(1, min(size, room_minimap_y))
        minimap[room_minimap_y, room_minimap_x] <- "?"
      }
    }
  }

  # Render minimap
  cat("\n┌", paste(rep("─", size), collapse = ""), "┐\n", sep = "")
  for (y in 1:size) {
    cat("│")
    for (x in 1:size) {
      char <- minimap[y, x]

      # Color code
      if (char == "@") {
        if (exists("color_text")) {
          cat(color_text("@", "cyan"))
        } else {
          cat("\033[1;36m@\033[0m")
        }
      } else if (char == ">") {
        if (exists("color_text")) {
          cat(color_text(">", "green"))
        } else {
          cat("\033[1;32m>\033[0m")
        }
      } else if (char == "?") {
        if (exists("color_text")) {
          cat(color_text("?", "yellow"))
        } else {
          cat("\033[1;33m?\033[0m")
        }
      } else {
        cat(char)
      }
    }
    cat("│\n")
  }
  cat("└", paste(rep("─", size), collapse = ""), "┘\n", sep = "")
}

# ============================================================================
# Minimap Toggle
# ============================================================================

toggle_minimap <- function(state) {
  if (is.null(state$ui$minimap_enabled)) {
    state$ui$minimap_enabled <- TRUE
  } else {
    state$ui$minimap_enabled <- !state$ui$minimap_enabled
  }

  status <- if (state$ui$minimap_enabled) "ON" else "OFF"
  state$message_log <- c(state$message_log, sprintf("Minimap: %s", status))

  return(state)
}
