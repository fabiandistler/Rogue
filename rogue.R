#!/usr/bin/env Rscript
# ============================================================================
# ROGUE - A Rogue-lite Game in Pure R
# ============================================================================
# Main entry point for the game

# Source all game modules
source("src/game_state.R")
source("src/dungeon_gen.R")
source("src/renderer.R")
source("src/combat.R")
source("src/input.R")

# ============================================================================
# Main Game Function
# ============================================================================

main <- function() {
  # Initialize
  cat("\033[2J\033[H")  # Clear screen
  cat("=== ROGUE - The R Dungeon Crawler ===\n\n")
  cat("You awaken in a dark dungeon...\n")
  cat("Find the stairs (>) to descend deeper!\n\n")
  cat("Controls:\n")
  cat("  w/a/s/d - Move\n")
  cat("  q - Quit\n")
  cat("  i - Inventory\n\n")
  cat("Press ENTER to begin...")
  readline()

  # Create initial game state
  state <- init_game_state()

  # Main game loop
  while (state$running) {
    # Render the game
    render_game(state)

    # Get player input
    action <- get_input()

    # Process action
    state <- process_action(state, action)

    # Process enemies turn
    if (state$player_acted) {
      state <- process_enemies(state)
      state$player_acted <- FALSE
    }

    # Check win/lose conditions
    state <- check_conditions(state)
  }

  # Game over
  cat("\033[2J\033[H")  # Clear screen
  if (state$player$hp <= 0) {
    cat("\n=== GAME OVER ===\n")
    cat("You have died in the dungeon...\n")
  } else {
    cat("\n=== VICTORY ===\n")
    cat("You escaped the dungeon!\n")
  }

  cat(sprintf("\nLevel reached: %d\n", state$level))
  cat(sprintf("Enemies slain: %d\n", state$stats$kills))
  cat(sprintf("Gold collected: %d\n", state$player$gold))
  cat("\nThanks for playing!\n")
}

# Run the game
if (!interactive()) {
  main()
} else {
  cat("Run the game with: Rscript rogue.R\n")
  cat("Or in R console: source('rogue.R'); main()\n")
}
