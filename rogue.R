#!/usr/bin/env Rscript
# ============================================================================
# ROGUE - A Rogue-lite Game in Pure R
# ============================================================================
# Main entry point for the game

# Source all game modules
source("src/game_state.R")
source("src/dungeon_gen.R")
source("src/fov.R")
source("src/renderer.R")
source("src/combat.R")
source("src/input.R")

# ============================================================================
# Main Game Function
# ============================================================================

main <- function() {
  # Check if running in interactive mode
  if (!interactive()) {
    cat("ERROR: This game requires an interactive R session.\n")
    cat("Please run the game using one of these methods:\n\n")
    cat("  Method 1: R console\n")
    cat("    R\n")
    cat("    > source('rogue.R')\n")
    cat("    > main()\n\n")
    cat("  Method 2: RStudio\n")
    cat("    Open rogue.R and run: source('rogue.R'); main()\n\n")
    cat("Rscript mode is not supported due to readline() limitations.\n")
    return(invisible())
  }

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
# Note: Automatically runs main() when sourced
if (interactive()) {
  cat("Game loaded! Run: main()\n")
} else {
  cat("ERROR: Rscript mode is not supported.\n")
  cat("Please run in interactive R session:\n")
  cat("  R\n")
  cat("  > source('rogue.R')\n")
  cat("  > main()\n")
}
