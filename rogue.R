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

# Source new systems (with error handling)
tryCatch(source("src/status_effects.R"), error = function(e) cat(""))
tryCatch(source("src/items_extended.R"), error = function(e) cat(""))
tryCatch(source("src/auto_explore.R"), error = function(e) cat(""))
tryCatch(source("src/achievements.R"), error = function(e) cat(""))
tryCatch(source("src/leaderboard.R"), error = function(e) cat(""))
tryCatch(source("src/special_rooms.R"), error = function(e) cat(""))
tryCatch(source("src/traps.R"), error = function(e) cat(""))
tryCatch(source("src/minimap.R"), error = function(e) cat(""))
tryCatch(source("src/renderer_new.R"), error = function(e) cat(""))
tryCatch(source("src/daily_challenges.R"), error = function(e) cat(""))
tryCatch(source("src/character_classes.R"), error = function(e) cat(""))
tryCatch(source("src/souls_shop.R"), error = function(e) cat(""))

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

  # Main menu
  repeat {
    cat("\033[2J\033[H")  # Clear screen
    cat("═══════════════════════════════════════════════════════\n")
    cat("         🎮 ROGUE - The R Dungeon Crawler 🎮\n")
    cat("═══════════════════════════════════════════════════════\n\n")

    show_meta_stats(meta)

    cat("\n═══════════════════════════════════════════════════════\n")
    cat("MAIN MENU:\n\n")
    cat("  [1] Start New Run\n")
    cat("  [2] Daily Challenge\n")
    cat(sprintf("  [3] Souls Shop (%d souls)\n", meta$souls))
    cat("  [4] View Leaderboard\n")
    cat("  [5] View Achievements\n")
    cat("  [Q] Quit\n\n")
    cat("═══════════════════════════════════════════════════════\n")
    cat("\nSelect option: ")

    choice <- tolower(trimws(readline()))

    if (choice == "q") {
      cat("\nThanks for playing!\n")
      return(invisible())
    } else if (choice == "1") {
      # Normal run
      game_mode <- "normal"
      break
    } else if (choice == "2") {
      # Daily challenge
      if (exists("start_daily_challenge")) {
        game_mode <- "daily"
        break
      } else {
        cat("\nDaily challenges not available.\n")
        readline()
      }
    } else if (choice == "3") {
      # Souls shop
      if (exists("display_souls_shop")) {
        meta <- display_souls_shop(meta)
        save_meta_progression(meta)
      } else {
        cat("\nSouls shop not available.\n")
        readline()
      }
    } else if (choice == "4") {
      # Leaderboard
      if (exists("display_leaderboard")) {
        cat("\033[2J\033[H")
        display_leaderboard()
        cat("\nPress ENTER...")
        readline()
      }
    } else if (choice == "5") {
      # Achievements
      if (exists("display_achievements")) {
        # Need to create a temp state for achievements
        temp_state <- list(achievements = if (exists("init_achievements")) init_achievements() else list())
        cat("\033[2J\033[H")
        display_achievements(temp_state)
        cat("\nPress ENTER...")
        readline()
      }
    }
  }

  # Select bonuses (for normal runs)
  if (game_mode == "normal" && any(sapply(meta$unlocks, isTRUE))) {
    meta <- select_bonuses(meta)
  }

  # Handle game mode
  if (game_mode == "daily") {
    # Start daily challenge
    state <- start_daily_challenge(meta)
  } else {
    # Normal run - select class if available
    selected_class <- NULL

    if (exists("select_character_class")) {
      selected_class <- select_character_class()
    }

    # Initialize
    cat("\033[2J\033[H")  # Clear screen
    cat("═══════════════════════════════════════════════════════\n")
    cat("         ROGUE - The Ultimate R Dungeon Crawler\n")
    cat("═══════════════════════════════════════════════════════\n\n")
    cat("You awaken in a dark dungeon...\n")
    cat("Find the stairs (>) to descend deeper!\n\n")
    cat("Quick Controls:\n")
    cat("  w/a/s/d - Move | o - Auto-explore | e - Interact\n")
    cat("  m - Minimap    | ? - Full Help    | q - Quit\n\n")
    cat("NEW FEATURES:\n")
    cat("  • 8 Character Classes\n")
    cat("  • Status Effects (Poison, Burn, Freeze)\n")
    cat("  • Item Rarities (Legendary loot!)\n")
    cat("  • Special Rooms (Shop, Shrine, Treasure)\n")
    cat("  • 25+ Achievements\n")
    cat("  • Leaderboard & Daily Challenges\n")
    cat("  • Souls Shop (Permanent Upgrades)\n\n")
    cat("Press ENTER to begin your adventure...")
    readline()

    # Create initial game state
    state <- init_game_state(meta = meta)

    # Apply character class
    if (!is.null(selected_class) && exists("apply_character_class")) {
      state <- apply_character_class(state, selected_class)
    }

    # Apply soul shop upgrades
    if (exists("apply_soul_shop_upgrades")) {
      state <- apply_soul_shop_upgrades(state)
    }
  }

  # Main game loop
  while (state$running) {
    # Render the game
    render_game(state)

    # Show minimap if enabled
    if (!is.null(state$ui$minimap_enabled) && state$ui$minimap_enabled && exists("render_minimap")) {
      render_minimap(state)
    }

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

          # Process status effects
          if (exists("process_status_effects")) {
            state <- process_status_effects(state)
          }

          # Increment turn counter
          state$stats$turns <- state$stats$turns + 1

          state$player_acted <- FALSE
        }

        # Check win/lose conditions
        state <- check_conditions(state)

        # Check achievements
        if (exists("check_achievements")) {
          state <- check_achievements(state)
        }

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

        # Process status effects
        if (exists("process_status_effects")) {
          state <- process_status_effects(state)
        }

        # Increment turn counter
        state$stats$turns <- state$stats$turns + 1

        state$player_acted <- FALSE
      }

      # Check win/lose conditions
      state <- check_conditions(state)

      # Check achievements
      if (exists("check_achievements")) {
        state <- check_achievements(state)
      }
    }
  }

  # Update meta progression
  meta <- update_meta_progression(meta, state)
  save_meta_progression(meta)

  # Add to leaderboard
  if (exists("add_leaderboard_entry")) {
    leaderboard <- add_leaderboard_entry(state)
  }

  # Add to daily leaderboard (if daily challenge)
  if (!is.null(state$is_daily_challenge) && state$is_daily_challenge && exists("add_daily_leaderboard_entry")) {
    add_daily_leaderboard_entry(state)
  }

  # Game over
  cat("\033[2J\033[H")  # Clear screen
  if (state$player$hp <= 0) {
    cat("\n╔══════════════════════════════════════════════════╗\n")
    cat("║              💀 GAME OVER 💀                     ║\n")
    cat("╚══════════════════════════════════════════════════╝\n\n")
    cat("You have died in the dungeon...\n")
  } else {
    cat("\n╔══════════════════════════════════════════════════╗\n")
    cat("║              🎉 VICTORY! 🎉                      ║\n")
    cat("╚══════════════════════════════════════════════════╝\n\n")
    cat("You escaped the dungeon!\n")
  }

  cat("\n")
  cat("═══════════════════════════════════════════════════════\n")
  cat("                   FINAL STATS\n")
  cat("═══════════════════════════════════════════════════════\n\n")
  cat(sprintf("Level reached:      %d\n", state$level))
  cat(sprintf("Enemies slain:      %d\n", state$stats$kills))
  cat(sprintf("Gold collected:     %d\n", state$player$gold))
  cat(sprintf("Damage dealt:       %d\n", state$stats$damage_dealt))
  cat(sprintf("Turns taken:        %d\n", state$stats$turns))

  # Calculate and show score
  if (exists("calculate_score")) {
    entry <- list(
      level_reached = state$level,
      kills = state$stats$kills,
      gold_collected = state$player$gold,
      damage_dealt = state$stats$damage_dealt,
      turns = state$stats$turns,
      won = state$level >= 10
    )
    score <- calculate_score(entry)
    cat(sprintf("\nFinal Score:        %s\n", format(score, big.mark = ",")))
  }

  # Show newly unlocked bonuses
  if (!is.null(meta$newly_unlocked) && length(meta$newly_unlocked) > 0) {
    cat("\n═══════════════════════════════════════════════════════\n")
    cat("                  🎁 NEW UNLOCKS 🎁\n")
    cat("═══════════════════════════════════════════════════════\n")
    for (unlock in meta$newly_unlocked) {
      cat(sprintf("  ✓ %s\n", unlock))
    }
  }

  # Show soul rewards
  if (!is.null(state$meta$souls)) {
    cat(sprintf("\n💎 Total Souls: %d\n", state$meta$souls))
  }

  cat("\n═══════════════════════════════════════════════════════\n")
  cat("\nThanks for playing ROGUE!\n")
  cat("Press 'b' to view leaderboard or ENTER to exit...")
  choice <- readline()

  if (tolower(choice) == "b" && exists("display_leaderboard")) {
    cat("\033[2J\033[H")
    display_leaderboard()
    cat("\nPress ENTER to exit...")
    readline()
  }
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
