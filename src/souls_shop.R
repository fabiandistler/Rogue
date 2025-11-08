# ============================================================================
# Souls Shop System
# ============================================================================
# Spend souls (earned from achievements) on permanent upgrades

# ============================================================================
# Shop Items Definitions
# ============================================================================

get_souls_shop_items <- function() {
  list(
    # Stat Upgrades
    max_hp_boost = list(
      id = "max_hp_boost",
      name = "+10 Max HP",
      description = "Permanently increase starting max HP by 10",
      cost = 50,
      max_purchases = 10,
      category = "stats",
      apply = function(state, purchases) {
        bonus_hp <- 10 * purchases
        state$player$max_hp <- state$player$max_hp + bonus_hp
        state$player$hp <- state$player$hp + bonus_hp
        state
      }
    ),

    attack_boost = list(
      id = "attack_boost",
      name = "+2 Attack",
      description = "Permanently increase starting attack by 2",
      cost = 75,
      max_purchases = 10,
      category = "stats",
      apply = function(state, purchases) {
        state$player$attack <- state$player$attack + (2 * purchases)
        state
      }
    ),

    defense_boost = list(
      id = "defense_boost",
      name = "+1 Defense",
      description = "Permanently increase starting defense by 1",
      cost = 60,
      max_purchases = 10,
      category = "stats",
      apply = function(state, purchases) {
        state$player$defense <- state$player$defense + purchases
        state
      }
    ),

    # Starting Resources
    starting_gold = list(
      id = "starting_gold",
      name = "+50 Starting Gold",
      description = "Start each run with 50 more gold",
      cost = 100,
      max_purchases = 5,
      category = "resources",
      apply = function(state, purchases) {
        state$player$gold <- state$player$gold + (50 * purchases)
        state
      }
    ),

    starting_potions = list(
      id = "starting_potions",
      name = "+1 Starting Potion",
      description = "Start each run with an extra health potion",
      cost = 120,
      max_purchases = 3,
      category = "resources",
      apply = function(state, purchases) {
        # Add potions (implementation depends on potion system)
        state$player$starting_potions <- purchases
        state
      }
    ),

    # Ability Upgrades
    extra_skill_point = list(
      id = "extra_skill_point",
      name = "+1 Starting Skill Point",
      description = "Start each run with an extra skill point",
      cost = 200,
      max_purchases = 5,
      category = "abilities",
      apply = function(state, purchases) {
        state$abilities$skill_points <- state$abilities$skill_points + purchases
        state
      }
    ),

    cooldown_reduction = list(
      id = "cooldown_reduction",
      name = "Cooldown Reduction",
      description = "Reduce all ability cooldowns by 1 turn",
      cost = 300,
      max_purchases = 2,
      category = "abilities",
      apply = function(state, purchases) {
        # Would reduce cooldowns globally
        state$cooldown_reduction <- purchases
        state
      }
    ),

    # Passive Upgrades
    life_steal = list(
      id = "life_steal",
      name = "Life Steal",
      description = "Heal 10% of damage dealt",
      cost = 400,
      max_purchases = 1,
      category = "passive",
      apply = function(state, purchases) {
        state$player$lifesteal <- 0.10
        state
      }
    ),

    crit_chance = list(
      id = "crit_chance",
      name = "Critical Strikes",
      description = "10% chance to deal double damage",
      cost = 350,
      max_purchases = 1,
      category = "passive",
      apply = function(state, purchases) {
        state$player$crit_chance <- 0.10
        state
      }
    ),

    thorns = list(
      id = "thorns",
      name = "Thorns",
      description = "Reflect 10 damage when hit",
      cost = 250,
      max_purchases = 1,
      category = "passive",
      apply = function(state, purchases) {
        state$player$thorns_damage <- 10
        state
      }
    ),

    dodge_chance = list(
      id = "dodge_chance",
      name = "Evasion",
      description = "10% chance to dodge attacks",
      cost = 300,
      max_purchases = 1,
      category = "passive",
      apply = function(state, purchases) {
        state$player$dodge_chance <- 0.10
        state
      }
    ),

    # Special Upgrades
    gold_magnet = list(
      id = "gold_magnet",
      name = "Gold Magnet",
      description = "+50% gold from all sources",
      cost = 500,
      max_purchases = 1,
      category = "special",
      apply = function(state, purchases) {
        state$player$gold_multiplier <- 1.5
        state
      }
    ),

    better_loot = list(
      id = "better_loot",
      name = "Better Loot",
      description = "Increase item rarity chances",
      cost = 600,
      max_purchases = 1,
      category = "special",
      apply = function(state, purchases) {
        state$player$loot_quality_bonus <- 1
        state
      }
    ),

    trap_immunity = list(
      id = "trap_immunity",
      name = "Trap Immunity",
      description = "Take 50% less damage from traps",
      cost = 400,
      max_purchases = 1,
      category = "special",
      apply = function(state, purchases) {
        state$player$trap_resistance <- 0.5
        state
      }
    ),

    fast_explore = list(
      id = "fast_explore",
      name = "Swift Explorer",
      description = "Auto-explore is 50% faster",
      cost = 300,
      max_purchases = 1,
      category = "special",
      apply = function(state, purchases) {
        state$player$explore_speed_bonus <- 0.5
        state
      }
    ),

    # Ultimate Upgrades
    second_chance = list(
      id = "second_chance",
      name = "Second Chance",
      description = "Revive once per run with 50% HP",
      cost = 1000,
      max_purchases = 1,
      category = "ultimate",
      apply = function(state, purchases) {
        state$player$second_chance <- TRUE
        state
      }
    ),

    berserker_mode = list(
      id = "berserker_mode",
      name = "Berserker Mode",
      description = "Deal 50% more damage, take 25% more damage",
      cost = 800,
      max_purchases = 1,
      category = "ultimate",
      apply = function(state, purchases) {
        state$player$berserker_mode <- TRUE
        state$player$damage_bonus <- 1.5
        state$player$damage_taken_multiplier <- 1.25
        state
      }
    ),

    legendary_start = list(
      id = "legendary_start",
      name = "Legendary Start",
      description = "Start with a random legendary weapon AND armor",
      cost = 1500,
      max_purchases = 1,
      category = "ultimate",
      apply = function(state, purchases) {
        # Generate legendary items if item system available
        if (exists("generate_random_item")) {
          state$player$weapon <- generate_random_item(1, "weapon", "legendary")
          state$player$armor <- generate_random_item(1, "armor", "legendary")
        }
        state
      }
    )
  )
}

# ============================================================================
# Load/Save Soul Shop Purchases
# ============================================================================

load_soul_shop_data <- function() {
  home_dir <- path.expand("~")
  rogue_dir <- file.path(home_dir, ".rogue")
  shop_file <- file.path(rogue_dir, "soul_shop.rds")

  if (!file.exists(shop_file)) {
    return(list(
      purchases = list()
    ))
  }

  tryCatch({
    readRDS(shop_file)
  }, error = function(e) {
    list(purchases = list())
  })
}

save_soul_shop_data <- function(shop_data) {
  home_dir <- path.expand("~")
  rogue_dir <- file.path(home_dir, ".rogue")

  if (!dir.exists(rogue_dir)) {
    dir.create(rogue_dir, recursive = TRUE)
  }

  shop_file <- file.path(rogue_dir, "soul_shop.rds")
  saveRDS(shop_data, shop_file)
}

# ============================================================================
# Display Souls Shop
# ============================================================================

display_souls_shop <- function(meta) {
  if (is.null(meta$souls)) {
    meta$souls <- 0
  }

  shop_data <- load_soul_shop_data()
  items <- get_souls_shop_items()

  repeat {
    cat("\033[2J\033[H")
    cat("═══════════════════════════════════════════════════════\n")
    cat("                 💎 SOULS SHOP 💎\n")
    cat("═══════════════════════════════════════════════════════\n\n")

    cat(sprintf("Your Souls: %d\n\n", meta$souls))

    # Group by category
    categories <- unique(sapply(items, function(i) i$category))

    for (category in categories) {
      cat(sprintf("--- %s ---\n", toupper(category)))

      category_items <- Filter(function(i) i$category == category, items)

      for (item_id in names(category_items)) {
        item <- category_items[[item_id]]

        # Get current purchases
        current_purchases <- if (!is.null(shop_data$purchases[[item_id]])) {
          shop_data$purchases[[item_id]]
        } else {
          0
        }

        # Check if maxed
        maxed <- current_purchases >= item$max_purchases

        if (maxed) {
          cat(sprintf("  [MAXED] %s\n", item$name))
        } else {
          can_afford <- meta$souls >= item$cost
          afford_str <- if (can_afford) "✓" else "✗"
          cat(sprintf("  [%s] %s - %d souls (%d/%d)\n",
                      afford_str, item$name, item$cost,
                      current_purchases, item$max_purchases))
        }

        cat(sprintf("      %s\n", item$description))
      }

      cat("\n")
    }

    cat("═══════════════════════════════════════════════════════\n")
    cat("\nEnter item name to purchase, or 'q' to exit: ")

    choice <- tolower(trimws(readline()))

    if (choice == "q" || choice == "") {
      break
    }

    # Find matching item
    matching_item <- NULL
    matching_id <- NULL

    for (item_id in names(items)) {
      item <- items[[item_id]]
      if (tolower(item$name) == choice || item_id == choice) {
        matching_item <- item
        matching_id <- item_id
        break
      }
    }

    if (is.null(matching_item)) {
      cat("\nItem not found. Press ENTER to continue...")
      readline()
      next
    }

    # Check if can purchase
    current_purchases <- if (!is.null(shop_data$purchases[[matching_id]])) {
      shop_data$purchases[[matching_id]]
    } else {
      0
    }

    if (current_purchases >= matching_item$max_purchases) {
      cat("\nThis upgrade is already maxed out! Press ENTER...")
      readline()
      next
    }

    if (meta$souls < matching_item$cost) {
      cat("\nNot enough souls! Press ENTER...")
      readline()
      next
    }

    # Purchase
    meta$souls <- meta$souls - matching_item$cost
    shop_data$purchases[[matching_id]] <- current_purchases + 1

    # Save
    save_soul_shop_data(shop_data)

    cat(sprintf("\n✓ Purchased %s!\n", matching_item$name))
    cat("Press ENTER to continue...")
    readline()
  }

  return(meta)
}

# ============================================================================
# Apply Soul Shop Upgrades to Game State
# ============================================================================

apply_soul_shop_upgrades <- function(state) {
  shop_data <- load_soul_shop_data()

  if (length(shop_data$purchases) == 0) {
    return(state)
  }

  items <- get_souls_shop_items()

  for (item_id in names(shop_data$purchases)) {
    purchases <- shop_data$purchases[[item_id]]

    if (purchases > 0 && !is.null(items[[item_id]])) {
      item <- items[[item_id]]
      state <- item$apply(state, purchases)
    }
  }

  return(state)
}
