#!/usr/bin/env Rscript
# ============================================================================
# ROGUE - A Rogue-lite Game in Pure R
# ============================================================================
# Main entry point for the game

# Source all game modules
source("src/game_state.R")
source("src/dungeon_gen.R")
source("src/fov.R")
source("src/themes.R")
source("src/abilities.R")
source("src/meta_progression.R")
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

  # Load meta progression
  meta <- load_meta_progression()

  # Show meta progression stats
  cat("\033[2J\033[H")  # Clear screen
  cat("=== ROGUE - The R Dungeon Crawler ===\n\n")
  show_meta_stats(meta)
  cat("\nPress ENTER to continue...")
  readline()

  # Select bonuses
  if (any(sapply(meta$unlocks, isTRUE))) {
    meta <- select_bonuses(meta)
  }

  # Initialize
  cat("\033[2J\033[H")  # Clear screen
  cat("=== ROGUE - The R Dungeon Crawler ===\n\n")
  cat("You awaken in a dark dungeon...\n")
  cat("Find the stairs (>) to descend deeper!\n\n")
  cat("Controls:\n")
  cat("  w/a/s/d - Move\n")
  cat("  q - Quit\n")
  cat("  i - Inventory\n")
  cat("  k - Abilities\n")
  cat("  m - Meta Stats\n\n")
  cat("Press ENTER to begin...")
  readline()

  # Create initial game state
  state <- init_game_state(meta = meta)

  # Main game loop
  while (state$running) {
    # Render the game
    render_game(state)

    # Get player input
    action <- get_input()

    # Handle multi-move commands
    if (is.list(action) && !is.null(action$type) && action$type == "multi_move") {
      # Execute multiple moves
      for (i in 1:action$count) {
        # Process single move
        state <- process_action(state, action$direction)

        # Process enemies turn
        if (state$player_acted) {
          state <- process_enemies(state)
          state <- update_cooldowns(state)
          state$player_acted <- FALSE
        }

        # Check win/lose conditions
        state <- check_conditions(state)

        # Stop if game ended or combat occurred
        if (!state$running || any(sapply(state$enemies, function(e) {
          e$alive && abs(e$x - state$player$x) + abs(e$y - state$player$y) <= 1
        }))) {
          break
        }

        # Brief render update for visual feedback
        if (i < action$count) {
          render_game(state)
          Sys.sleep(0.1)  # Small delay for visual feedback
        }
      }
    } else {
      # Process single action
      state <- process_action(state, action)

      # Process enemies turn
      if (state$player_acted) {
        state <- process_enemies(state)
        state <- update_cooldowns(state)
        state$player_acted <- FALSE
      }

      # Check win/lose conditions
      state <- check_conditions(state)
    }
  }

  # Update meta progression
  meta <- update_meta_progression(meta, state)
  save_meta_progression(meta)

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

  # Show newly unlocked bonuses
  if (!is.null(meta$newly_unlocked) && length(meta$newly_unlocked) > 0) {
    cat("\n*** NEW UNLOCKS ***\n")
    for (unlock in meta$newly_unlocked) {
      cat(sprintf("  - %s\n", unlock))
    }
  }

  cat("\nThanks for playing!\n")
  cat("Press ENTER to exit...")
  readline()
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
