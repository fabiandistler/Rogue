# ============================================================================
# Leaderboard System
# ============================================================================
# Tracks and displays high scores

# ============================================================================
# Leaderboard Storage
# ============================================================================

get_leaderboard_file <- function() {
  home_dir <- path.expand("~")
  rogue_dir <- file.path(home_dir, ".rogue")

  if (!dir.exists(rogue_dir)) {
    dir.create(rogue_dir, recursive = TRUE)
  }

  return(file.path(rogue_dir, "leaderboard.rds"))
}

# ============================================================================
# Load Leaderboard
# ============================================================================

load_leaderboard <- function() {
  file_path <- get_leaderboard_file()

  if (!file.exists(file_path)) {
    return(list(
      entries = list(),
      version = "1.0"
    ))
  }

  tryCatch({
    leaderboard <- readRDS(file_path)
    return(leaderboard)
  }, error = function(e) {
    warning("Failed to load leaderboard: ", e$message)
    return(list(entries = list(), version = "1.0"))
  })
}

# ============================================================================
# Save Leaderboard
# ============================================================================

save_leaderboard <- function(leaderboard) {
  file_path <- get_leaderboard_file()

  tryCatch({
    saveRDS(leaderboard, file_path)
    return(TRUE)
  }, error = function(e) {
    warning("Failed to save leaderboard: ", e$message)
    return(FALSE)
  })
}

# ============================================================================
# Add Entry
# ============================================================================

add_leaderboard_entry <- function(state) {
  leaderboard <- load_leaderboard()

  # Create entry
  entry <- list(
    player_name = get_player_name(),
    level_reached = state$level,
    kills = state$stats$kills,
    gold_collected = state$player$gold,
    damage_dealt = if (!is.null(state$stats$damage_dealt)) state$stats$damage_dealt else 0,
    turns = if (!is.null(state$stats$turns)) state$stats$turns else 0,
    won = state$level >= 10,
    timestamp = Sys.time(),
    seed = if (!is.null(state$seed)) state$seed else NA,
    theme = if (!is.null(state$theme$name)) state$theme$name else "Unknown"
  )

  # Calculate score
  entry$score <- calculate_score(entry)

  # Add to leaderboard
  leaderboard$entries[[length(leaderboard$entries) + 1]] <- entry

  # Sort by score (descending)
  leaderboard$entries <- leaderboard$entries[order(sapply(leaderboard$entries, function(e) e$score), decreasing = TRUE)]

  # Keep top 100
  if (length(leaderboard$entries) > 100) {
    leaderboard$entries <- leaderboard$entries[1:100]
  }

  # Save
  save_leaderboard(leaderboard)

  return(leaderboard)
}

# ============================================================================
# Calculate Score
# ============================================================================

calculate_score <- function(entry) {
  score <- 0

  # Level reached (1000 points per level)
  score <- score + entry$level_reached * 1000

  # Win bonus
  if (entry$won) {
    score <- score + 10000
  }

  # Kills (10 points each)
  score <- score + entry$kills * 10

  # Gold (1 point per gold)
  score <- score + entry$gold_collected

  # Damage dealt (1 point per 10 damage)
  score <- score + round(entry$damage_dealt / 10)

  # Speed bonus (fewer turns = higher score)
  if (entry$won && entry$turns > 0) {
    speed_bonus <- max(0, 5000 - entry$turns * 10)
    score <- score + speed_bonus
  }

  return(round(score))
}

# ============================================================================
# Display Leaderboard
# ============================================================================

display_leaderboard <- function(top_n = 10) {
  leaderboard <- load_leaderboard()

  if (length(leaderboard$entries) == 0) {
    cat("\nNo entries in leaderboard yet!\n")
    return()
  }

  cat("\n")
  cat("═══════════════════════════════════════════════════════════════════════\n")
  cat("                           HIGH SCORES\n")
  cat("═══════════════════════════════════════════════════════════════════════\n\n")

  # Show top N entries
  entries_to_show <- min(top_n, length(leaderboard$entries))

  cat(sprintf("%-4s %-15s %-8s %-6s %-6s %-8s %s\n",
              "Rank", "Name", "Score", "Level", "Kills", "Gold", "Status"))
  cat("───────────────────────────────────────────────────────────────────────\n")

  for (i in 1:entries_to_show) {
    entry <- leaderboard$entries[[i]]

    rank_str <- sprintf("#%d", i)
    name_str <- substr(entry$player_name, 1, 15)
    score_str <- format(entry$score, big.mark = ",")
    level_str <- sprintf("L%d", entry$level_reached)
    kills_str <- as.character(entry$kills)
    gold_str <- as.character(entry$gold_collected)
    status_str <- if (entry$won) "✓ WIN" else "✗ Lost"

    # Color code by rank
    if (i == 1 && exists("color_text")) {
      rank_str <- color_text(rank_str, "yellow")
    } else if (i <= 3 && exists("color_text")) {
      rank_str <- color_text(rank_str, "cyan")
    }

    cat(sprintf("%-4s %-15s %-8s %-6s %-6s %-8s %s\n",
                rank_str, name_str, score_str, level_str, kills_str, gold_str, status_str))
  }

  cat("═══════════════════════════════════════════════════════════════════════\n")

  # Show player's best entry
  player_name <- get_player_name()
  player_entries <- Filter(function(e) e$player_name == player_name, leaderboard$entries)

  if (length(player_entries) > 0) {
    best_entry <- player_entries[[1]]
    rank <- which(sapply(leaderboard$entries, function(e) identical(e, best_entry)))

    cat(sprintf("\nYour Best: Rank #%d - Score: %s\n",
                rank, format(best_entry$score, big.mark = ",")))
  }
}

# ============================================================================
# Get Player Name
# ============================================================================

get_player_name <- function() {
  # Try to get system username
  name <- Sys.info()["user"]

  if (is.na(name) || name == "") {
    name <- "Player"
  }

  return(as.character(name))
}

# ============================================================================
# Display Personal Stats
# ============================================================================

display_personal_stats <- function() {
  leaderboard <- load_leaderboard()
  player_name <- get_player_name()

  player_entries <- Filter(function(e) e$player_name == player_name, leaderboard$entries)

  if (length(player_entries) == 0) {
    cat("\nNo personal stats yet!\n")
    return()
  }

  cat("\n")
  cat("═══════════════════════════════════════════════════════\n")
  cat("               YOUR STATISTICS\n")
  cat("═══════════════════════════════════════════════════════\n\n")

  # Calculate aggregated stats
  total_runs <- length(player_entries)
  total_wins <- sum(sapply(player_entries, function(e) e$won))
  win_rate <- if (total_runs > 0) round(total_wins / total_runs * 100, 1) else 0

  best_score <- max(sapply(player_entries, function(e) e$score))
  total_kills <- sum(sapply(player_entries, function(e) e$kills))
  total_gold <- sum(sapply(player_entries, function(e) e$gold_collected))

  highest_level <- max(sapply(player_entries, function(e) e$level_reached))

  cat(sprintf("Total Runs: %d\n", total_runs))
  cat(sprintf("Wins: %d (%.1f%%)\n", total_wins, win_rate))
  cat(sprintf("Best Score: %s\n", format(best_score, big.mark = ",")))
  cat(sprintf("Highest Level: %d\n", highest_level))
  cat(sprintf("Total Kills: %s\n", format(total_kills, big.mark = ",")))
  cat(sprintf("Total Gold: %s\n", format(total_gold, big.mark = ",")))

  cat("\n═══════════════════════════════════════════════════════\n")
}
