# ============================================================================
# Achievement System
# ============================================================================
# Tracks player achievements and provides long-term goals

# ============================================================================
# Achievement Definitions
# ============================================================================

get_achievement_definitions <- function() {
  list(
    # Combat Achievements
    first_kill = list(
      id = "first_kill",
      name = "First Blood",
      description = "Kill your first enemy",
      icon = "⚔️",
      requirement = list(type = "kills", value = 1),
      reward = list(type = "souls", value = 10)
    ),
    slayer = list(
      id = "slayer",
      name = "Slayer",
      description = "Kill 50 enemies",
      icon = "💀",
      requirement = list(type = "kills", value = 50),
      reward = list(type = "souls", value = 50)
    ),
    executioner = list(
      id = "executioner",
      name = "Executioner",
      description = "Kill 200 enemies",
      icon = "⚰️",
      requirement = list(type = "kills", value = 200),
      reward = list(type = "souls", value = 200)
    ),
    boss_hunter = list(
      id = "boss_hunter",
      name = "Boss Hunter",
      description = "Defeat 5 bosses",
      icon = "👑",
      requirement = list(type = "boss_kills", value = 5),
      reward = list(type = "souls", value = 100)
    ),
    boss_master = list(
      id = "boss_master",
      name = "Boss Master",
      description = "Defeat 20 bosses",
      icon = "🏆",
      requirement = list(type = "boss_kills", value = 20),
      reward = list(type = "souls", value = 300)
    ),

    # Progression Achievements
    first_win = list(
      id = "first_win",
      name = "First Victory",
      description = "Reach level 10",
      icon = "🎉",
      requirement = list(type = "max_level", value = 10),
      reward = list(type = "souls", value = 500)
    ),
    speedrunner = list(
      id = "speedrunner",
      name = "Speedrunner",
      description = "Win in under 100 turns",
      icon = "⚡",
      requirement = list(type = "win_turns", value = 100, compare = "<="),
      reward = list(type = "souls", value = 300)
    ),
    survivor = list(
      id = "survivor",
      name = "Survivor",
      description = "Reach level 5 without taking damage",
      icon = "🛡️",
      requirement = list(type = "no_damage_level", value = 5),
      reward = list(type = "souls", value = 200)
    ),

    # Exploration Achievements
    explorer = list(
      id = "explorer",
      name = "Explorer",
      description = "Explore 50% of a level",
      icon = "🗺️",
      requirement = list(type = "exploration_percent", value = 50),
      reward = list(type = "souls", value = 50)
    ),
    cartographer = list(
      id = "cartographer",
      name = "Cartographer",
      description = "Fully explore 5 levels",
      icon = "🧭",
      requirement = list(type = "full_exploration_count", value = 5),
      reward = list(type = "souls", value = 150)
    ),

    # Loot Achievements
    treasure_hunter = list(
      id = "treasure_hunter",
      name = "Treasure Hunter",
      description = "Collect 1000 gold",
      icon = "💰",
      requirement = list(type = "total_gold", value = 1000),
      reward = list(type = "souls", value = 100)
    ),
    hoarder = list(
      id = "hoarder",
      name = "Hoarder",
      description = "Collect 5000 gold across all runs",
      icon = "💎",
      requirement = list(type = "cumulative_gold", value = 5000),
      reward = list(type = "souls", value = 300)
    ),
    legendary_finder = list(
      id = "legendary_finder",
      name = "Legendary Finder",
      description = "Find a legendary item",
      icon = "✨",
      requirement = list(type = "legendary_items", value = 1),
      reward = list(type = "souls", value = 150)
    ),

    # Skill Achievements
    master_of_abilities = list(
      id = "master_of_abilities",
      name = "Master of Abilities",
      description = "Unlock all 5 abilities",
      icon = "🔮",
      requirement = list(type = "abilities_unlocked", value = 5),
      reward = list(type = "souls", value = 200)
    ),
    ability_spammer = list(
      id = "ability_spammer",
      name = "Ability Spammer",
      description = "Use abilities 50 times",
      icon = "✴️",
      requirement = list(type = "abilities_used", value = 50),
      reward = list(type = "souls", value = 100)
    ),

    # Challenge Achievements
    glass_cannon = list(
      id = "glass_cannon",
      name = "Glass Cannon",
      description = "Win with less than 20 max HP",
      icon = "🔥",
      requirement = list(type = "win_low_hp", value = 20, compare = "<"),
      reward = list(type = "souls", value = 400)
    ),
    pacifist = list(
      id = "pacifist",
      name = "Pacifist",
      description = "Reach level 3 without killing enemies",
      icon = "☮️",
      requirement = list(type = "pacifist_level", value = 3),
      reward = list(type = "souls", value = 250)
    ),
    no_items = list(
      id = "no_items",
      name = "Minimalist",
      description = "Win without equipping any items",
      icon = "🎖️",
      requirement = list(type = "win_no_items", value = 1),
      reward = list(type = "souls", value = 500)
    ),

    # Death Achievements
    persistent = list(
      id = "persistent",
      name = "Persistent",
      description = "Die 10 times",
      icon = "💀",
      requirement = list(type = "deaths", value = 10),
      reward = list(type = "souls", value = 50)
    ),
    masochist = list(
      id = "masochist",
      name = "Masochist",
      description = "Die 100 times",
      icon = "☠️",
      requirement = list(type = "deaths", value = 100),
      reward = list(type = "souls", value = 300)
    ),

    # Special Achievements
    lucky = list(
      id = "lucky",
      name = "Lucky",
      description = "Find 3 legendary items in one run",
      icon = "🍀",
      requirement = list(type = "legendaries_in_run", value = 3),
      reward = list(type = "souls", value = 200)
    ),
    completionist = list(
      id = "completionist",
      name = "Completionist",
      description = "Unlock all achievements",
      icon = "🌟",
      requirement = list(type = "all_achievements", value = 1),
      reward = list(type = "souls", value = 1000)
    )
  )
}

# ============================================================================
# Initialize Achievements
# ============================================================================

init_achievements <- function() {
  definitions <- get_achievement_definitions()

  achievements <- list()
  for (id in names(definitions)) {
    achievements[[id]] <- list(
      unlocked = FALSE,
      progress = 0,
      unlocked_at = NULL
    )
  }

  return(achievements)
}

# ============================================================================
# Check Achievements
# ============================================================================

check_achievements <- function(state) {
  definitions <- get_achievement_definitions()
  newly_unlocked <- character(0)

  for (id in names(definitions)) {
    achievement_def <- definitions[[id]]

    # Skip if already unlocked
    if (!is.null(state$achievements[[id]]) && state$achievements[[id]]$unlocked) {
      next
    }

    # Check requirement
    req <- achievement_def$requirement
    met <- check_requirement(state, req)

    if (met) {
      # Unlock achievement
      state$achievements[[id]]$unlocked <- TRUE
      state$achievements[[id]]$unlocked_at <- Sys.time()

      # Grant reward
      if (!is.null(achievement_def$reward)) {
        state <- grant_reward(state, achievement_def$reward)
      }

      newly_unlocked <- c(newly_unlocked, id)

      # Add message
      state$message_log <- c(state$message_log,
                            sprintf("🏆 Achievement Unlocked: %s - %s",
                                  achievement_def$name,
                                  achievement_def$description))
    }
  }

  # Check completionist achievement
  if (length(newly_unlocked) > 0) {
    state <- check_completionist(state)
  }

  return(state)
}

# ============================================================================
# Check Requirements
# ============================================================================

check_requirement <- function(state, req) {
  type <- req$type
  value <- req$value
  compare <- if (!is.null(req$compare)) req$compare else ">="

  # Get actual value from state
  actual_value <- get_stat_value(state, type)

  # Compare
  result <- switch(compare,
    ">=" = actual_value >= value,
    "<=" = actual_value <= value,
    "<" = actual_value < value,
    ">" = actual_value > value,
    "==" = actual_value == value,
    FALSE
  )

  return(result)
}

get_stat_value <- function(state, stat_type) {
  switch(stat_type,
    kills = if (!is.null(state$stats$kills)) state$stats$kills else 0,
    boss_kills = if (!is.null(state$meta$boss_kills)) state$meta$boss_kills else 0,
    max_level = if (!is.null(state$stats$max_level_reached)) state$stats$max_level_reached else 0,
    total_gold = if (!is.null(state$player$gold)) state$player$gold else 0,
    cumulative_gold = if (!is.null(state$meta$total_gold_earned)) state$meta$total_gold_earned else 0,
    legendary_items = if (!is.null(state$stats$legendary_items_found)) state$stats$legendary_items_found else 0,
    abilities_unlocked = count_unlocked_abilities(state),
    abilities_used = if (!is.null(state$stats$abilities_used)) state$stats$abilities_used else 0,
    deaths = if (!is.null(state$meta$deaths)) state$meta$deaths else 0,
    win_turns = if (!is.null(state$stats$turns)) state$stats$turns else 9999,
    legendaries_in_run = if (!is.null(state$stats$legendaries_this_run)) state$stats$legendaries_this_run else 0,
    0
  )
}

count_unlocked_abilities <- function(state) {
  if (is.null(state$abilities) || is.null(state$abilities$abilities)) return(0)

  count <- 0
  for (ability in state$abilities$abilities) {
    if (!is.null(ability$unlocked) && ability$unlocked) {
      count <- count + 1
    }
  }
  return(count)
}

# ============================================================================
# Grant Rewards
# ============================================================================

grant_reward <- function(state, reward) {
  if (reward$type == "souls") {
    if (is.null(state$meta$souls)) {
      state$meta$souls <- 0
    }
    state$meta$souls <- state$meta$souls + reward$value
    state$message_log <- c(state$message_log,
                          sprintf("💎 Gained %d souls!", reward$value))
  }

  return(state)
}

# ============================================================================
# Check Completionist
# ============================================================================

check_completionist <- function(state) {
  definitions <- get_achievement_definitions()

  # Count unlocked (excluding completionist itself)
  total_count <- length(definitions) - 1  # -1 for completionist
  unlocked_count <- 0

  for (id in names(definitions)) {
    if (id == "completionist") next

    if (!is.null(state$achievements[[id]]) && state$achievements[[id]]$unlocked) {
      unlocked_count <- unlocked_count + 1
    }
  }

  # If all unlocked, grant completionist
  if (unlocked_count >= total_count && !state$achievements$completionist$unlocked) {
    state$achievements$completionist$unlocked <- TRUE
    state$achievements$completionist$unlocked_at <- Sys.time()

    comp_def <- definitions$completionist
    state <- grant_reward(state, comp_def$reward)

    state$message_log <- c(state$message_log,
                          "🌟 COMPLETIONIST ACHIEVEMENT UNLOCKED! 🌟")
  }

  return(state)
}

# ============================================================================
# Display Achievements
# ============================================================================

display_achievements <- function(state) {
  definitions <- get_achievement_definitions()

  cat("\n")
  cat("═══════════════════════════════════════════════════════\n")
  cat("                    ACHIEVEMENTS\n")
  cat("═══════════════════════════════════════════════════════\n\n")

  unlocked_count <- 0
  total_count <- length(definitions)

  for (id in names(definitions)) {
    achievement_def <- definitions[[id]]
    achievement_state <- state$achievements[[id]]

    is_unlocked <- !is.null(achievement_state) && achievement_state$unlocked

    if (is_unlocked) {
      unlocked_count <- unlocked_count + 1
    }

    # Display format
    status <- if (is_unlocked) "✓" else "✗"
    icon <- achievement_def$icon

    cat(sprintf("[%s] %s %s\n", status, icon, achievement_def$name))
    cat(sprintf("    %s\n", achievement_def$description))

    if (is_unlocked) {
      cat(sprintf("    Reward: %d souls\n", achievement_def$reward$value))
    }

    cat("\n")
  }

  cat("═══════════════════════════════════════════════════════\n")
  cat(sprintf("Progress: %d / %d (%d%%)\n",
              unlocked_count, total_count,
              round(unlocked_count / total_count * 100)))
  cat("═══════════════════════════════════════════════════════\n")
}
