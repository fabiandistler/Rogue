# ============================================================================
# Rendering System
# ============================================================================
# Renders the game state to the terminal

render_game <- function(state) {
  # Clear screen
  cat("\033[2J\033[H")

  # Render title
  cat("=== ROGUE - Level", state$level, "===\n\n")

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

  # Overlay entities
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
        # Check for player
        if (world_x == player_x && world_y == player_y) {
          char <- "@"
          color <- "\033[1;36m"  # Cyan
        }
        # Check for enemies
        else if (!is.null(enemy <- get_enemy_at(state, world_x, world_y))) {
          char <- enemy$char
          if (enemy$is_boss) {
            color <- "\033[1;35m"  # Magenta for bosses
          } else {
            color <- "\033[1;31m"  # Red for regular enemies
          }
        }
        # Check for items
        else if (!is.null(item <- get_item_at(state, world_x, world_y))) {
          char <- item$char
          color <- "\033[1;33m"  # Yellow
        }
        # Check for stairs
        else if (world_x == state$stairs_pos$x && world_y == state$stairs_pos$y) {
          char <- ">"
          color <- "\033[1;32m"  # Green
        }
        # Map tiles
        else {
          char <- visible_map[y, x]
          if (char == "#") {
            color <- "\033[0;37m"  # Gray
          } else {
            color <- "\033[0;90m"  # Dark gray
          }
        }
        cat(color, char, "\033[0m", sep = "")
      } else {
        # Explored but not visible - show dimmed map only
        char <- visible_map[y, x]
        if (char == "#") {
          color <- "\033[0;30m"  # Very dark gray
        } else {
          color <- "\033[0;30m"  # Very dark gray
        }
        cat(color, char, "\033[0m", sep = "")
      }
    }
    cat("\n")
  }

  # Render UI
  cat("\n")
  render_ui(state)

  # Render message log
  cat("\n--- Messages ---\n")
  for (msg in state$message_log) {
    cat(msg, "\n")
  }
}

render_ui <- function(state) {
  # Player stats
  hp_bar <- create_bar(state$player$hp, state$player$max_hp, 20, "HP")
  cat(sprintf("HP: %s %d/%d\n", hp_bar, state$player$hp, state$player$max_hp))

  # Player info
  cat(sprintf("ATK: %d (+%d weapon)  DEF: %d (+%d armor)  Gold: %d\n",
              state$player$attack,
              state$player$weapon$damage,
              state$player$defense,
              state$player$armor$defense,
              state$player$gold))

  # Enemy count and boss indicator
  alive_enemies <- sum(sapply(state$enemies, function(e) e$alive))
  boss_alive <- any(sapply(state$enemies, function(e) e$alive && e$is_boss))

  boss_indicator <- if (boss_alive) "\033[1;35m[BOSS]\033[0m" else ""
  cat(sprintf("Enemies: %d %s Level: %d  Kills: %d\n",
              alive_enemies,
              boss_indicator,
              state$level,
              state$stats$kills))
}

# Create a simple progress bar
create_bar <- function(current, maximum, length = 20, label = "") {
  filled <- round(current / maximum * length)
  empty <- length - filled

  bar <- paste0(
    "\033[1;32m",  # Green
    paste(rep("=", max(0, filled)), collapse = ""),
    "\033[0;31m",  # Red
    paste(rep("-", max(0, empty)), collapse = ""),
    "\033[0m"
  )

  return(bar)
}
