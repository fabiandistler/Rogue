# ============================================================================
# Modern CLI Rendering System
# ============================================================================
# Uses cli and crayon for better terminal UX

# Check if packages are available, fallback to base R
USE_CLI <- requireNamespace("cli", quietly = TRUE)
USE_CRAYON <- requireNamespace("crayon", quietly = TRUE)

if (USE_CRAYON) library(crayon)

# ============================================================================
# Color Utilities
# ============================================================================

color_text <- function(text, color_name) {
  if (!USE_CRAYON) {
    # Fallback to ANSI
    colors <- list(
      cyan = "\033[1;36m",
      red = "\033[1;31m",
      yellow = "\033[1;33m",
      green = "\033[1;32m",
      magenta = "\033[1;35m",
      blue = "\033[1;34m",
      gray = "\033[0;37m",
      darkgray = "\033[0;30m",
      reset = "\033[0m"
    )
    return(paste0(colors[[color_name]], text, colors$reset))
  }

  # Use crayon
  switch(color_name,
    cyan = cyan$bold(text),
    red = red$bold(text),
    yellow = yellow$bold(text),
    green = green$bold(text),
    magenta = magenta$bold(text),
    blue = blue$bold(text),
    gray = silver(text),
    darkgray = black(text),
    text
  )
}

# ============================================================================
# Screen Management
# ============================================================================

clear_screen <- function() {
  # Use a more efficient clear method to reduce flickering
  # Move cursor to home and clear from cursor to end of screen
  cat("\033[H\033[J")
}

# ============================================================================
# Main Render Function
# ============================================================================

render_game <- function(state, previous_state = NULL) {
  # Clear screen
  clear_screen()

  # Render title with cli if available
  if (USE_CLI) {
    cli::cli_h1(sprintf("ROGUE - Level %d", state$level))
  } else {
    cat(color_text(sprintf("=== ROGUE - Level %d ===\n", state$level), "cyan"))
  }

  # Show theme info
  show_theme_info(state)
  cat("\n")

  # Calculate visible area (field of view)
  view_range <- 80
  player_x <- state$player$x
  player_y <- state$player$y

  min_x <- max(1, player_x - view_range)
  max_x <- min(ncol(state$map), player_x + view_range)
  min_y <- max(1, player_y - view_range)
  max_y <- min(nrow(state$map), player_y + view_range)

  # Create visible map
  visible_map <- state$map[min_y:max_y, min_x:max_x, drop = FALSE]

  # Get theme colors
  theme_colors <- get_theme_colors(state$theme)

  # Render map
  render_map(state, visible_map, min_x, min_y, max_x, max_y, theme_colors)

  # Render UI
  cat("\n")
  render_ui(state)

  # Render message log
  render_messages(state)

  # Render particle effects if any
  if (!is.null(state$particles) && length(state$particles) > 0) {
    render_particles(state$particles)
  }
}

# ============================================================================
# Map Rendering
# ============================================================================

render_map <- function(state, visible_map, min_x, min_y, max_x, max_y, theme_colors) {
  player_x <- state$player$x
  player_y <- state$player$y

  for (y in 1:nrow(visible_map)) {
    for (x in 1:ncol(visible_map)) {
      world_x <- min_x + x - 1
      world_y <- min_y + y - 1

      # Check if tile is visible or explored
      visible <- is_visible(state, world_x, world_y)
      explored <- is_explored(state, world_x, world_y)

      if (!explored) {
        # Unexplored tiles are dark
        cat(" ")
      } else if (visible) {
        # Visible tiles show in full color
        render_visible_tile(state, world_x, world_y, player_x, player_y, visible_map[y, x], theme_colors)
      } else {
        # Explored but not visible - show dimmed
        render_explored_tile(visible_map[y, x])
      }
    }
    cat("\n")
  }
}

render_visible_tile <- function(state, world_x, world_y, player_x, player_y, map_char, theme_colors) {
  # Check for player
  if (world_x == player_x && world_y == player_y) {
    cat(color_text("@", "cyan"))
  }
  # Check for enemies
  else if (!is.null(enemy <- get_enemy_at(state, world_x, world_y))) {
    if (enemy$is_boss) {
      cat(color_text(enemy$char, "magenta"))
    } else {
      cat(color_text(enemy$char, "red"))
    }
  }
  # Check for items
  else if (!is.null(item <- get_item_at(state, world_x, world_y))) {
    # Color by rarity if available
    if (!is.null(item$rarity)) {
      color <- switch(item$rarity,
        legendary = "magenta",
        rare = "blue",
        uncommon = "green",
        "yellow"  # common
      )
    } else {
      color <- "yellow"
    }
    cat(color_text(item$char, color))
  }
  # Check for stairs
  else if (world_x == state$stairs_pos$x && world_y == state$stairs_pos$y) {
    cat(color_text(">", "green"))
  }
  # Check for special room markers
  else if (!is.null(state$special_rooms)) {
    room <- get_special_room_at(state, world_x, world_y)
    if (!is.null(room)) {
      cat(color_text(room$char, room$color))
    } else {
      render_map_tile(map_char, theme_colors)
    }
  }
  # Map tiles
  else {
    render_map_tile(map_char, theme_colors)
  }
}

render_map_tile <- function(char, theme_colors) {
  if (char == "#") {
    cat(theme_colors$wall, char, "\033[0m", sep = "")
  } else {
    cat(theme_colors$floor, char, "\033[0m", sep = "")
  }
}

render_explored_tile <- function(char) {
  cat(color_text(char, "darkgray"))
}

# ============================================================================
# UI Rendering
# ============================================================================

render_ui <- function(state) {
  # Health bar
  if (USE_CLI) {
    render_cli_health_bar(state)
  } else {
    render_basic_health_bar(state)
  }

  # Player stats
  render_player_stats(state)

  # Enemy info
  render_enemy_info(state)

  # Active effects
  render_active_effects(state)

  # Status effects (if any)
  if (!is.null(state$player$status_effects) && length(state$player$status_effects) > 0) {
    render_status_effects(state)
  }
}

render_cli_health_bar <- function(state) {
  # Don't use cli progress bar, it causes rendering issues
  # Fall back to basic health bar
  render_basic_health_bar(state)
}

render_basic_health_bar <- function(state) {
  hp_bar <- create_bar(state$player$hp, state$player$max_hp, 20, "HP")
  cat(sprintf("HP: %s %d/%d\n", hp_bar, state$player$hp, state$player$max_hp))
}

render_player_stats <- function(state) {
  atk <- state$player$attack
  weapon_bonus <- if (!is.null(state$player$weapon)) state$player$weapon$damage else 0
  def <- state$player$defense
  armor_bonus <- if (!is.null(state$player$armor)) state$player$armor$defense else 0
  gold <- state$player$gold
  sp <- if (!is.null(state$abilities)) state$abilities$skill_points else 0

  stats_line <- sprintf("ATK: %d ", atk)
  if (weapon_bonus > 0) {
    stats_line <- paste0(stats_line, color_text(sprintf("(+%d)", weapon_bonus), "green"), " ")
  }
  stats_line <- paste0(stats_line, sprintf(" DEF: %d ", def))
  if (armor_bonus > 0) {
    stats_line <- paste0(stats_line, color_text(sprintf("(+%d)", armor_bonus), "blue"), " ")
  }
  stats_line <- paste0(stats_line, sprintf(" Gold: %s  SP: %s",
                                           color_text(as.character(gold), "yellow"),
                                           color_text(as.character(sp), "magenta")))
  cat(stats_line, "\n")
}

render_enemy_info <- function(state) {
  alive_enemies <- sum(sapply(state$enemies, function(e) e$alive))
  boss_alive <- any(sapply(state$enemies, function(e) e$alive && e$is_boss))

  boss_indicator <- if (boss_alive) color_text("[BOSS]", "magenta") else ""
  cat(sprintf("Enemies: %d %s  Level: %d  Kills: %d\n",
              alive_enemies,
              boss_indicator,
              state$level,
              state$stats$kills))
}

render_active_effects <- function(state) {
  active_effects <- character(0)

  if (!is.null(state$abilities$abilities$shield_wall$active) && state$abilities$abilities$shield_wall$active) {
    effect_text <- sprintf("[Shield Wall: %d]", state$abilities$abilities$shield_wall$turns_remaining)
    active_effects <- c(active_effects, color_text(effect_text, "blue"))
  }

  if (!is.null(state$abilities$power_strike_active) && state$abilities$power_strike_active) {
    active_effects <- c(active_effects, color_text("[Power Strike Ready]", "red"))
  }

  if (length(active_effects) > 0) {
    cat(paste(active_effects, collapse = " "), "\n")
  }
}

render_status_effects <- function(state) {
  effects <- state$player$status_effects
  effect_strings <- character(0)

  for (effect_name in names(effects)) {
    effect <- effects[[effect_name]]
    if (effect$duration > 0) {
      color <- switch(effect_name,
        poison = "green",
        burn = "red",
        freeze = "cyan",
        "yellow"
      )
      text <- sprintf("[%s: %d]", toupper(effect_name), effect$duration)
      effect_strings <- c(effect_strings, color_text(text, color))
    }
  }

  if (length(effect_strings) > 0) {
    cat("Status: ", paste(effect_strings, collapse = " "), "\n", sep = "")
  }
}

# ============================================================================
# Message Log
# ============================================================================

render_messages <- function(state) {
  if (USE_CLI) {
    cli::cli_rule("Messages")
  } else {
    cat("\n", color_text("--- Messages ---", "cyan"), "\n", sep = "")
  }

  # Show last 5 messages
  messages <- tail(state$message_log, 5)
  for (msg in messages) {
    # Color-code important messages
    if (grepl("killed", msg, ignore.case = TRUE)) {
      cat(color_text(msg, "green"), "\n")
    } else if (grepl("hit|damage", msg, ignore.case = TRUE)) {
      cat(color_text(msg, "red"), "\n")
    } else if (grepl("found|gained|picked", msg, ignore.case = TRUE)) {
      cat(color_text(msg, "yellow"), "\n")
    } else {
      cat(msg, "\n")
    }
  }
}

# ============================================================================
# Particle Effects
# ============================================================================

render_particles <- function(particles) {
  # ASCII particle effects for visual feedback
  for (particle in particles) {
    # This would be rendered on top of the map in a real implementation
    # For now, just show as a message
    if (particle$type == "damage") {
      cat(color_text(sprintf("  [%s %d!]", particle$char, particle$value), "red"), "\n")
    } else if (particle$type == "heal") {
      cat(color_text(sprintf("  [%s %d!]", particle$char, particle$value), "green"), "\n")
    }
  }
}

# ============================================================================
# Helper Functions
# ============================================================================

# Create a simple progress bar
create_bar <- function(current, maximum, length = 20, label = "") {
  filled <- round(current / maximum * length)
  empty <- length - filled

  filled_char <- if (USE_CRAYON) green("=") else "\033[1;32m=\033[0m"
  empty_char <- if (USE_CRAYON) red("-") else "\033[0;31m-\033[0m"

  bar <- paste0(
    paste(rep(filled_char, max(0, filled)), collapse = ""),
    paste(rep(empty_char, max(0, empty)), collapse = "")
  )

  return(bar)
}

# Get special room at position (for TIER 4)
get_special_room_at <- function(state, x, y) {
  if (is.null(state$special_rooms)) return(NULL)

  for (room in state$special_rooms) {
    if (room$x == x && room$y == y && !room$visited) {
      return(room)
    }
  }
  return(NULL)
}
