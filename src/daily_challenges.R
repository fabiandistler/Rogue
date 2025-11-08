# ============================================================================
# Daily Challenge System
# ============================================================================
# Generates a daily seeded run with special modifiers

# ============================================================================
# Get Daily Seed
# ============================================================================

get_daily_seed <- function() {
  # Generate seed based on current date
  date_str <- format(Sys.Date(), "%Y%m%d")
  seed <- as.integer(charToRaw(date_str))
  seed <- sum(seed * (1:length(seed)))
  return(seed)
}

get_daily_challenge_name <- function() {
  date_str <- format(Sys.Date(), "%B %d, %Y")
  return(paste("Daily Challenge:", date_str))
}

# ============================================================================
# Challenge Modifiers
# ============================================================================

get_challenge_modifiers <- function() {
  list(
    glass_cannon = list(
      name = "Glass Cannon",
      description = "50% HP, 200% damage",
      apply = function(state) {
        state$player$max_hp <- round(state$player$max_hp * 0.5)
        state$player$hp <- state$player$max_hp
        state$player$attack <- round(state$player$attack * 2)
        state$challenge_modifier <- "glass_cannon"
        state
      }
    ),
    tank_mode = list(
      name = "Tank Mode",
      description = "200% HP, 200% defense, 50% damage",
      apply = function(state) {
        state$player$max_hp <- round(state$player$max_hp * 2)
        state$player$hp <- state$player$max_hp
        state$player$defense <- round(state$player$defense * 2)
        state$player$attack <- round(state$player$attack * 0.5)
        state$challenge_modifier <- "tank_mode"
        state
      }
    ),
    speed_run = list(
      name = "Speed Run",
      description = "100 turn limit, bonus souls for completing",
      apply = function(state) {
        state$challenge_turn_limit <- 100
        state$challenge_bonus_souls <- 500
        state$challenge_modifier <- "speed_run"
        state
      }
    ),
    hoarder = list(
      name = "Hoarder",
      description = "500% gold drops, items cost 10x gold",
      apply = function(state) {
        state$challenge_gold_multiplier <- 5.0
        state$challenge_cost_multiplier <- 10.0
        state$challenge_modifier <- "hoarder"
        state
      }
    ),
    minimalist = list(
      name = "Minimalist",
      description = "No equipment allowed, +100 base stats",
      apply = function(state) {
        state$player$attack <- state$player$attack + 100
        state$player$defense <- state$player$defense + 50
        state$challenge_no_equipment <- TRUE
        state$challenge_modifier <- "minimalist"
        state
      }
    ),
    trap_master = list(
      name = "Trap Master",
      description = "3x traps, can disarm for bonus gold",
      apply = function(state) {
        state$challenge_trap_multiplier <- 3
        state$challenge_disarm_bonus <- 50
        state$challenge_modifier <- "trap_master"
        state
      }
    ),
    boss_rush = list(
      name = "Boss Rush",
      description = "Boss on every level, huge rewards",
      apply = function(state) {
        state$challenge_all_boss_levels <- TRUE
        state$challenge_boss_reward_multiplier <- 3
        state$challenge_modifier <- "boss_rush"
        state
      }
    ),
    cursed_run = list(
      name = "Cursed Run",
      description = "All items are cursed (negative effects), 3x souls",
      apply = function(state) {
        state$challenge_cursed_items <- TRUE
        state$challenge_soul_multiplier <- 3
        state$challenge_modifier <- "cursed_run"
        state
      }
    ),
    pacifist = list(
      name = "Pacifist",
      description = "Can't attack, must avoid enemies, huge souls reward",
      apply = function(state) {
        state$challenge_pacifist <- TRUE
        state$challenge_bonus_souls <- 1000
        state$challenge_modifier <- "pacifist"
        state
      }
    ),
    lucky = list(
      name = "Lucky Day",
      description = "Only legendary items drop",
      apply = function(state) {
        state$challenge_only_legendary <- TRUE
        state$challenge_modifier <- "lucky"
        state
      }
    )
  )
}

# ============================================================================
# Select Daily Modifier
# ============================================================================

select_daily_modifier <- function(seed) {
  modifiers <- get_challenge_modifiers()
  modifier_names <- names(modifiers)

  # Use seed to select modifier
  set.seed(seed)
  selected_name <- sample(modifier_names, 1)

  return(modifiers[[selected_name]])
}

# ============================================================================
# Initialize Daily Challenge
# ============================================================================

init_daily_challenge <- function() {
  seed <- get_daily_seed()
  modifier <- select_daily_modifier(seed)

  challenge <- list(
    seed = seed,
    name = get_daily_challenge_name(),
    modifier = modifier,
    completed = FALSE,
    best_score = 0
  )

  return(challenge)
}

# ============================================================================
# Start Daily Challenge
# ============================================================================

start_daily_challenge <- function(meta) {
  daily <- init_daily_challenge()

  cat("\033[2J\033[H")
  cat("═══════════════════════════════════════════════════════\n")
  cat("             ⭐ DAILY CHALLENGE ⭐\n")
  cat("═══════════════════════════════════════════════════════\n\n")

  cat(sprintf("Challenge: %s\n", daily$name))
  cat(sprintf("Modifier:  %s\n", daily$modifier$name))
  cat(sprintf("Effect:    %s\n\n", daily$modifier$description))

  cat("Daily challenges use a fixed seed - everyone gets the\n")
  cat("same dungeon layout! Compete for the best score!\n\n")

  # Load daily challenge stats
  daily_stats <- load_daily_stats()

  if (!is.null(daily_stats) && daily_stats$date == as.character(Sys.Date())) {
    cat(sprintf("Your best today: %s\n", format(daily_stats$best_score, big.mark = ",")))
    cat(sprintf("Attempts today: %d\n\n", daily_stats$attempts))
  }

  cat("Press ENTER to start the challenge...")
  readline()

  # Initialize game with daily seed and modifier
  state <- init_game_state(seed = daily$seed, meta = meta)

  # Apply modifier
  state <- daily$modifier$apply(state)

  # Mark as daily challenge
  state$is_daily_challenge <- TRUE
  state$daily_challenge <- daily

  return(state)
}

# ============================================================================
# Load/Save Daily Stats
# ============================================================================

load_daily_stats <- function() {
  home_dir <- path.expand("~")
  rogue_dir <- file.path(home_dir, ".rogue")
  stats_file <- file.path(rogue_dir, "daily_stats.rds")

  if (!file.exists(stats_file)) {
    return(NULL)
  }

  tryCatch({
    stats <- readRDS(stats_file)

    # Check if today's stats
    if (stats$date != as.character(Sys.Date())) {
      return(NULL)
    }

    return(stats)
  }, error = function(e) {
    return(NULL)
  })
}

save_daily_stats <- function(score, won) {
  home_dir <- path.expand("~")
  rogue_dir <- file.path(home_dir, ".rogue")

  if (!dir.exists(rogue_dir)) {
    dir.create(rogue_dir, recursive = TRUE)
  }

  stats_file <- file.path(rogue_dir, "daily_stats.rds")

  # Load existing stats
  existing_stats <- load_daily_stats()

  if (is.null(existing_stats) || existing_stats$date != as.character(Sys.Date())) {
    # New day
    stats <- list(
      date = as.character(Sys.Date()),
      attempts = 1,
      best_score = score,
      won = won
    )
  } else {
    # Update existing
    stats <- existing_stats
    stats$attempts <- stats$attempts + 1

    if (score > stats$best_score) {
      stats$best_score <- score
    }

    if (won) {
      stats$won <- TRUE
    }
  }

  saveRDS(stats, stats_file)
  return(stats)
}

# ============================================================================
# Daily Challenge Leaderboard
# ============================================================================

get_daily_leaderboard_file <- function() {
  home_dir <- path.expand("~")
  rogue_dir <- file.path(home_dir, ".rogue")

  if (!dir.exists(rogue_dir)) {
    dir.create(rogue_dir, recursive = TRUE)
  }

  # One leaderboard file per day
  date_str <- format(Sys.Date(), "%Y%m%d")
  return(file.path(rogue_dir, paste0("daily_leaderboard_", date_str, ".rds")))
}

add_daily_leaderboard_entry <- function(state) {
  if (!state$is_daily_challenge) {
    return(NULL)
  }

  leaderboard_file <- get_daily_leaderboard_file()

  # Calculate score
  entry <- list(
    player_name = if (exists("get_player_name")) get_player_name() else "Player",
    level_reached = state$level,
    kills = state$stats$kills,
    gold_collected = state$player$gold,
    turns = state$stats$turns,
    won = state$level >= 10,
    modifier = state$daily_challenge$modifier$name,
    timestamp = Sys.time()
  )

  if (exists("calculate_score")) {
    entry$score <- calculate_score(entry)
  } else {
    entry$score <- entry$level_reached * 1000 + entry$kills * 10 + entry$gold_collected
  }

  # Load existing leaderboard
  if (file.exists(leaderboard_file)) {
    leaderboard <- readRDS(leaderboard_file)
  } else {
    leaderboard <- list(
      date = as.character(Sys.Date()),
      modifier = state$daily_challenge$modifier$name,
      entries = list()
    )
  }

  # Add entry
  leaderboard$entries[[length(leaderboard$entries) + 1]] <- entry

  # Sort by score
  leaderboard$entries <- leaderboard$entries[order(sapply(leaderboard$entries, function(e) e$score), decreasing = TRUE)]

  # Save
  saveRDS(leaderboard, leaderboard_file)

  # Also save daily stats
  save_daily_stats(entry$score, entry$won)

  return(leaderboard)
}

display_daily_leaderboard <- function() {
  leaderboard_file <- get_daily_leaderboard_file()

  if (!file.exists(leaderboard_file)) {
    cat("\nNo daily leaderboard entries yet!\n")
    return()
  }

  leaderboard <- readRDS(leaderboard_file)

  cat("\n")
  cat("═══════════════════════════════════════════════════════\n")
  cat(sprintf("     DAILY CHALLENGE LEADERBOARD - %s\n", leaderboard$date))
  cat("═══════════════════════════════════════════════════════\n")
  cat(sprintf("Modifier: %s\n\n", leaderboard$modifier))

  if (length(leaderboard$entries) == 0) {
    cat("No entries yet. Be the first!\n")
    return()
  }

  cat(sprintf("%-4s %-15s %-10s %-6s %-6s %s\n",
              "Rank", "Player", "Score", "Level", "Turns", "Status"))
  cat("───────────────────────────────────────────────────────\n")

  entries_to_show <- min(10, length(leaderboard$entries))

  for (i in 1:entries_to_show) {
    entry <- leaderboard$entries[[i]]

    rank_str <- sprintf("#%d", i)
    name_str <- substr(entry$player_name, 1, 15)
    score_str <- format(entry$score, big.mark = ",")
    level_str <- sprintf("L%d", entry$level_reached)
    turns_str <- as.character(entry$turns)
    status_str <- if (entry$won) "✓ WIN" else "✗"

    cat(sprintf("%-4s %-15s %-10s %-6s %-6s %s\n",
                rank_str, name_str, score_str, level_str, turns_str, status_str))
  }

  cat("═══════════════════════════════════════════════════════\n")
}
