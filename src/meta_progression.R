# ============================================================================
# Meta-progression System
# ============================================================================
# Handles persistent progression between runs

# Path to save file
get_save_path <- function() {
  save_dir <- path.expand("~/.rogue")
  if (!dir.exists(save_dir)) {
    dir.create(save_dir, recursive = TRUE)
  }
  file.path(save_dir, "meta_progress.rds")
}

# Initialize meta progression data
init_meta_progression <- function() {
  list(
    total_runs = 0,
    total_kills = 0,
    total_gold = 0,
    highest_level = 0,
    total_deaths = 0,
    victories = 0,
    bosses_defeated = 0,

    # Unlockable bonuses
    unlocks = list(
      warrior_start = FALSE,      # Start with +20 HP, +5 ATK
      treasure_hunter = FALSE,    # +50% gold drops
      survivor = FALSE,           # Start with 2 health potions
      weapon_master = FALSE,      # Start with better weapon
      armor_expert = FALSE,       # Start with better armor
      dungeon_mapper = FALSE,     # Increased FOV range
      boss_slayer = FALSE         # +20% damage to bosses
    ),

    # Unlock requirements (kills needed)
    unlock_requirements = list(
      warrior_start = 50,
      treasure_hunter = 100,
      survivor = 30,
      weapon_master = 75,
      armor_expert = 75,
      dungeon_mapper = 150,
      boss_slayer = 10  # boss kills
    ),

    # Active bonuses (player can choose which to activate)
    active_bonuses = list()
  )
}

# Load meta progression
load_meta_progression <- function() {
  save_path <- get_save_path()

  if (file.exists(save_path)) {
    tryCatch({
      data <- readRDS(save_path)
      # Ensure all fields exist (for backwards compatibility)
      default <- init_meta_progression()
      for (field in names(default)) {
        if (is.null(data[[field]])) {
          data[[field]] <- default[[field]]
        }
      }
      return(data)
    }, error = function(e) {
      message("Could not load meta progression, starting fresh")
      return(init_meta_progression())
    })
  } else {
    return(init_meta_progression())
  }
}

# Save meta progression
save_meta_progression <- function(meta) {
  save_path <- get_save_path()
  tryCatch({
    saveRDS(meta, save_path)
    return(TRUE)
  }, error = function(e) {
    message("Failed to save meta progression: ", e$message)
    return(FALSE)
  })
}

# Update meta progression after a run
update_meta_progression <- function(meta, state) {
  meta$total_runs <- meta$total_runs + 1
  meta$total_kills <- meta$total_kills + state$stats$kills
  meta$total_gold <- meta$total_gold + state$player$gold
  meta$highest_level <- max(meta$highest_level, state$level)

  # Count boss kills
  boss_kills <- sum(sapply(state$enemies, function(e) !e$alive && e$is_boss))
  meta$bosses_defeated <- meta$bosses_defeated + boss_kills

  # Check victory or death
  if (state$player$hp <= 0) {
    meta$total_deaths <- meta$total_deaths + 1
  } else if (state$level >= 10) {
    meta$victories <- meta$victories + 1
  }

  # Check for new unlocks
  meta <- check_unlocks(meta)

  return(meta)
}

# Check if any new unlocks are available
check_unlocks <- function(meta) {
  newly_unlocked <- character(0)

  # Warrior start
  if (!meta$unlocks$warrior_start && meta$total_kills >= meta$unlock_requirements$warrior_start) {
    meta$unlocks$warrior_start <- TRUE
    newly_unlocked <- c(newly_unlocked, "Warrior Start")
  }

  # Treasure hunter
  if (!meta$unlocks$treasure_hunter && meta$total_kills >= meta$unlock_requirements$treasure_hunter) {
    meta$unlocks$treasure_hunter <- TRUE
    newly_unlocked <- c(newly_unlocked, "Treasure Hunter")
  }

  # Survivor
  if (!meta$unlocks$survivor && meta$total_kills >= meta$unlock_requirements$survivor) {
    meta$unlocks$survivor <- TRUE
    newly_unlocked <- c(newly_unlocked, "Survivor")
  }

  # Weapon master
  if (!meta$unlocks$weapon_master && meta$total_kills >= meta$unlock_requirements$weapon_master) {
    meta$unlocks$weapon_master <- TRUE
    newly_unlocked <- c(newly_unlocked, "Weapon Master")
  }

  # Armor expert
  if (!meta$unlocks$armor_expert && meta$total_kills >= meta$unlock_requirements$armor_expert) {
    meta$unlocks$armor_expert <- TRUE
    newly_unlocked <- c(newly_unlocked, "Armor Expert")
  }

  # Dungeon mapper
  if (!meta$unlocks$dungeon_mapper && meta$total_kills >= meta$unlock_requirements$dungeon_mapper) {
    meta$unlocks$dungeon_mapper <- TRUE
    newly_unlocked <- c(newly_unlocked, "Dungeon Mapper")
  }

  # Boss slayer
  if (!meta$unlocks$boss_slayer && meta$bosses_defeated >= meta$unlock_requirements$boss_slayer) {
    meta$unlocks$boss_slayer <- TRUE
    newly_unlocked <- c(newly_unlocked, "Boss Slayer")
  }

  # Store newly unlocked for display
  if (length(newly_unlocked) > 0) {
    meta$newly_unlocked <- newly_unlocked
  }

  return(meta)
}

# Apply meta progression bonuses to player
apply_meta_bonuses <- function(player, meta) {
  # Warrior start
  if ("warrior_start" %in% meta$active_bonuses) {
    player$hp <- player$hp + 20
    player$max_hp <- player$max_hp + 20
    player$attack <- player$attack + 5
  }

  # Survivor
  if ("survivor" %in% meta$active_bonuses) {
    # Add 2 health potions to inventory at start (handled in init)
  }

  # Weapon master
  if ("weapon_master" %in% meta$active_bonuses) {
    player$weapon <- list(name = "Veteran's Blade", damage = 10)
  }

  # Armor expert
  if ("armor_expert" %in% meta$active_bonuses) {
    player$armor <- list(name = "Veteran's Mail", defense = 5)
  }

  return(player)
}

# Display meta progression stats
show_meta_stats <- function(meta) {
  cat("\n=== META PROGRESSION ===\n")
  cat(sprintf("Total Runs: %d\n", meta$total_runs))
  cat(sprintf("Victories: %d\n", meta$victories))
  cat(sprintf("Total Kills: %d\n", meta$total_kills))
  cat(sprintf("Bosses Defeated: %d\n", meta$bosses_defeated))
  cat(sprintf("Total Gold: %d\n", meta$total_gold))
  cat(sprintf("Highest Level: %d\n", meta$highest_level))
  cat(sprintf("Deaths: %d\n", meta$total_deaths))

  cat("\n=== UNLOCKS ===\n")
  display_unlock_status(meta, "warrior_start", "Warrior Start", "+20 HP, +5 ATK at start")
  display_unlock_status(meta, "treasure_hunter", "Treasure Hunter", "+50% gold drops")
  display_unlock_status(meta, "survivor", "Survivor", "Start with 2 health potions")
  display_unlock_status(meta, "weapon_master", "Weapon Master", "Better starting weapon")
  display_unlock_status(meta, "armor_expert", "Armor Expert", "Better starting armor")
  display_unlock_status(meta, "dungeon_mapper", "Dungeon Mapper", "Increased FOV range")
  display_unlock_status(meta, "boss_slayer", "Boss Slayer", "+20% damage vs bosses")
}

# Display individual unlock status
display_unlock_status <- function(meta, unlock_id, name, description) {
  if (meta$unlocks[[unlock_id]]) {
    active <- if (unlock_id %in% meta$active_bonuses) " [ACTIVE]" else ""
    cat(sprintf("  [X] %s: %s%s\n", name, description, active))
  } else {
    # Show progress
    if (unlock_id == "boss_slayer") {
      progress <- meta$bosses_defeated
      required <- meta$unlock_requirements[[unlock_id]]
      cat(sprintf("  [ ] %s: %s (%d/%d bosses)\n", name, description, progress, required))
    } else {
      progress <- meta$total_kills
      required <- meta$unlock_requirements[[unlock_id]]
      cat(sprintf("  [ ] %s: %s (%d/%d kills)\n", name, description, progress, required))
    }
  }
}

# Select active bonuses
select_bonuses <- function(meta) {
  cat("\n=== SELECT ACTIVE BONUSES ===\n")
  cat("Choose which unlocked bonuses to activate for this run.\n")
  cat("(You can activate multiple bonuses!)\n\n")

  available_bonuses <- names(meta$unlocks)[sapply(meta$unlocks, isTRUE)]

  if (length(available_bonuses) == 0) {
    cat("No bonuses unlocked yet. Keep playing to unlock them!\n")
    return(meta)
  }

  bonus_names <- list(
    warrior_start = "Warrior Start (+20 HP, +5 ATK)",
    treasure_hunter = "Treasure Hunter (+50% gold)",
    survivor = "Survivor (Start with 2 potions)",
    weapon_master = "Weapon Master (Better weapon)",
    armor_expert = "Armor Expert (Better armor)",
    dungeon_mapper = "Dungeon Mapper (Larger FOV)",
    boss_slayer = "Boss Slayer (+20% boss damage)"
  )

  for (i in seq_along(available_bonuses)) {
    bonus_id <- available_bonuses[i]
    cat(sprintf("%d. %s\n", i, bonus_names[[bonus_id]]))
  }

  cat("\nEnter bonus numbers separated by spaces (or press ENTER for none): ")
  input <- readline()

  if (nchar(trimws(input)) > 0) {
    selections <- as.integer(strsplit(trimws(input), "\\s+")[[1]])
    selections <- selections[!is.na(selections) & selections > 0 & selections <= length(available_bonuses)]
    meta$active_bonuses <- available_bonuses[selections]
  } else {
    meta$active_bonuses <- character(0)
  }

  return(meta)
}
