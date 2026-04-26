# ============================================================================
# Crafting / Anvil System
# ============================================================================
# Implements a Blacksmith / Anvil special room that lets the player:
#   1. Reroll the suffix of an equipped weapon or armor
#   2. Upgrade the rarity of an equipped item one tier
#   3. Salvage a potion for souls + gold
# Costs are paid in souls (meta currency from souls_shop.R).

# Order of rarity tiers (lowest to highest)
get_rarity_order <- function() {
  c("common", "uncommon", "rare", "legendary")
}

next_rarity <- function(rarity) {
  order <- get_rarity_order()
  idx <- match(rarity, order)
  if (is.na(idx) || idx >= length(order)) return(NULL)
  order[idx + 1]
}

# ============================================================================
# Anvil Room Initialization
# ============================================================================

init_anvil_data <- function(level) {
  list(
    used_count = 0,
    cost_reroll = 30,
    cost_upgrade = 50,
    salvage_gold = sample(10:25, 1),
    salvage_souls = 5
  )
}

# ============================================================================
# Anvil Room Interaction
# ============================================================================

interact_anvil <- function(state, room) {
  data <- room$data
  cat("\n")
  cat("& ═════════════════════════════════════════\n")
  cat("           BLACKSMITH'S ANVIL\n")
  cat("═════════════════════════════════════════\n\n")

  souls <- if (!is.null(state$meta) && !is.null(state$meta$souls)) state$meta$souls else 0
  cat(sprintf("Your Gold: %d   Your Souls: %d\n\n", state$player$gold, souls))

  cat(sprintf("[1] Reroll suffix on equipped item     (cost: %d souls)\n", data$cost_reroll))
  cat(sprintf("[2] Upgrade rarity of equipped item    (cost: %d souls)\n", data$cost_upgrade))
  cat(sprintf("[3] Salvage a potion (+%d gold, +%d souls)\n",
              data$salvage_gold, data$salvage_souls))
  cat("[0] Leave\n")

  choice <- suppressWarnings(as.integer(readline("Enter choice: ")))
  if (is.na(choice) || choice == 0) return(state)

  state <- switch(as.character(choice),
    "1" = craft_reroll_suffix(state, data$cost_reroll),
    "2" = craft_upgrade_rarity(state, data$cost_upgrade),
    "3" = craft_salvage(state, data$salvage_gold, data$salvage_souls),
    state
  )

  Sys.sleep(0.6)
  return(state)
}

# ============================================================================
# Helpers
# ============================================================================

select_equipment_slot <- function(state) {
  cat("\n[1] Weapon  [2] Armor  [0] Cancel\n")
  c <- suppressWarnings(as.integer(readline("Pick slot: ")))
  if (is.na(c) || !(c %in% c(1, 2))) return(NULL)
  if (c == 1) "weapon" else "armor"
}

charge_souls <- function(state, cost) {
  if (is.null(state$meta)) state$meta <- list()
  if (is.null(state$meta$souls)) state$meta$souls <- 0
  if (state$meta$souls < cost) {
    state <- add_message(state, "Not enough souls.")
    return(list(state = state, ok = FALSE))
  }
  state$meta$souls <- state$meta$souls - cost
  list(state = state, ok = TRUE)
}

# ============================================================================
# Craft: Reroll Suffix
# ============================================================================

craft_reroll_suffix <- function(state, cost) {
  slot <- select_equipment_slot(state)
  if (is.null(slot)) return(state)

  item <- state$player[[slot]]
  if (is.null(item) || is.null(item$type)) {
    state <- add_message(state, "No suitable item equipped.")
    return(state)
  }

  charged <- charge_souls(state, cost)
  state <- charged$state
  if (!charged$ok) return(state)

  if (!exists("get_item_suffixes")) {
    state <- add_message(state, "The blacksmith shrugs — no suffix lore here.")
    return(state)
  }

  suffix_pool <- get_item_suffixes()[[item$type]]
  if (is.null(suffix_pool) || length(suffix_pool) == 0) {
    state <- add_message(state, "No suffixes available for this item type.")
    return(state)
  }

  new_suffix <- sample(suffix_pool, 1)[[1]]
  state$player[[slot]]$suffix <- new_suffix
  state <- add_message(state, sprintf("Reforged: %s now has suffix '%s'.",
                                      item$name, new_suffix$name))
  return(state)
}

# ============================================================================
# Craft: Upgrade Rarity
# ============================================================================

craft_upgrade_rarity <- function(state, cost) {
  slot <- select_equipment_slot(state)
  if (is.null(slot)) return(state)

  item <- state$player[[slot]]
  if (is.null(item) || is.null(item$type)) {
    state <- add_message(state, "No suitable item equipped.")
    return(state)
  }

  current_rarity <- if (!is.null(item$rarity)) item$rarity else "common"
  upgraded <- next_rarity(current_rarity)
  if (is.null(upgraded)) {
    state <- add_message(state, sprintf("%s is already at the highest rarity.", item$name))
    return(state)
  }

  if (!exists("generate_random_item")) {
    state <- add_message(state, "The blacksmith lacks the means to upgrade.")
    return(state)
  }

  charged <- charge_souls(state, cost)
  state <- charged$state
  if (!charged$ok) return(state)

  new_item <- generate_random_item(state$level, type = item$type, forced_rarity = upgraded)
  state$player[[slot]] <- new_item
  state <- add_message(state, sprintf("Upgraded to %s (%s rarity).",
                                      new_item$name, upgraded))
  return(state)
}

# ============================================================================
# Craft: Salvage a Potion
# ============================================================================

craft_salvage <- function(state, gold_reward, souls_reward) {
  potions <- state$player$potions
  if (is.null(potions) || length(potions) == 0) {
    state <- add_message(state, "You have no potions to salvage.")
    return(state)
  }

  cat("\nSelect potion to salvage:\n")
  for (i in seq_along(potions)) {
    cat(sprintf("[%d] %s\n", i, potions[[i]]$name))
  }
  cat("[0] Cancel\n")

  c <- suppressWarnings(as.integer(readline("Enter choice: ")))
  if (is.na(c) || c < 1 || c > length(potions)) return(state)

  salvaged <- potions[[c]]
  state$player$potions <- potions[-c]
  state$player$gold <- state$player$gold + gold_reward
  if (is.null(state$meta)) state$meta <- list()
  state$meta$souls <- (if (is.null(state$meta$souls)) 0 else state$meta$souls) + souls_reward

  state <- add_message(state, sprintf("Salvaged %s: +%d gold, +%d souls.",
                                      salvaged$name, gold_reward, souls_reward))
  return(state)
}
