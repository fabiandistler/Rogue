# ============================================================================
# Random Events System
# ============================================================================
# Adds rare interactive events (?) on the dungeon floor that present the
# player with a small choice menu. Mid-run flavor + agency, hooks into the
# existing souls / item / status systems.

# ============================================================================
# Event Definitions
# ============================================================================

get_event_definitions <- function() {
  list(
    cursed_shrine = list(
      name = "Cursed Shrine",
      description = "A shrine pulses with dark energy. Sacrifice 25% HP for 50 souls?",
      char = "?",
      color = "magenta"
    ),
    wandering_merchant = list(
      name = "Wandering Merchant",
      description = "A hooded figure offers a single rare item.",
      char = "?",
      color = "yellow"
    ),
    mystery_chest = list(
      name = "Mystery Chest",
      description = "An ornate chest. It might be a trap...",
      char = "?",
      color = "cyan"
    ),
    wounded_adventurer = list(
      name = "Wounded Adventurer",
      description = "A dying adventurer asks for help.",
      char = "?",
      color = "green"
    )
  )
}

# ============================================================================
# Generate Events for a Level
# ============================================================================

generate_dungeon_events <- function(state) {
  # 0-2 events per level, weighted toward 1
  num_events <- sample(0:2, 1, prob = c(0.4, 0.45, 0.15))

  # Daily challenge modifier "event_hunter" doubles the count
  if (identical(state$challenge_modifier, "event_hunter")) {
    num_events <- num_events * 2
  }

  if (num_events == 0 || length(state$rooms) < 2) {
    return(list())
  }

  defs <- get_event_definitions()
  type_names <- names(defs)
  events <- list()

  # Use rooms (excluding spawn + stairs) as candidate areas
  available_rooms <- state$rooms
  if (length(available_rooms) > 2) {
    available_rooms <- available_rooms[2:(length(available_rooms) - 1)]
  }

  for (i in seq_len(num_events)) {
    if (length(available_rooms) == 0) break

    room_idx <- sample.int(length(available_rooms), 1)
    room <- available_rooms[[room_idx]]
    available_rooms <- available_rooms[-room_idx]

    type <- sample(type_names, 1)
    def <- defs[[type]]

    events[[length(events) + 1]] <- list(
      type = type,
      name = def$name,
      char = def$char,
      color = def$color,
      x = room$center_x,
      y = room$center_y,
      consumed = FALSE
    )
  }

  return(events)
}

# ============================================================================
# Lookup
# ============================================================================

get_event_at <- function(state, x, y) {
  if (is.null(state$events)) return(NULL)
  for (i in seq_along(state$events)) {
    ev <- state$events[[i]]
    if (!ev$consumed && ev$x == x && ev$y == y) {
      return(list(event = ev, index = i))
    }
  }
  return(NULL)
}

# ============================================================================
# Interaction
# ============================================================================

interact_event <- function(state, event_index) {
  ev <- state$events[[event_index]]
  if (ev$consumed) return(state)

  cat("\n")
  cat("? ═════════════════════════════════════════\n")
  cat(sprintf("            %s\n", toupper(ev$name)))
  cat("═════════════════════════════════════════\n\n")

  defs <- get_event_definitions()
  cat(defs[[ev$type]]$description, "\n\n")

  state <- switch(ev$type,
    cursed_shrine     = handle_cursed_shrine(state),
    wandering_merchant = handle_wandering_merchant(state),
    mystery_chest     = handle_mystery_chest(state),
    wounded_adventurer = handle_wounded_adventurer(state),
    state
  )

  state$events[[event_index]]$consumed <- TRUE

  # Achievement hook (best-effort, only if container already exists)
  if (is.list(state$achievements) && is.list(state$achievements$counters)) {
    prev <- state$achievements$counters$events_triggered
    state$achievements$counters$events_triggered <-
      (if (is.null(prev)) 0 else prev) + 1
  }

  Sys.sleep(0.6)
  return(state)
}

# Null-coalesce helper (if not already defined elsewhere)
`%||%` <- function(a, b) if (is.null(a)) b else a

# ============================================================================
# Event Handlers
# ============================================================================

handle_cursed_shrine <- function(state) {
  cat("[1] Sacrifice 25% HP for 50 souls\n")
  cat("[0] Walk away\n")
  choice <- suppressWarnings(as.integer(readline("Enter choice: ")))
  if (is.na(choice) || choice != 1) return(state)

  cost <- max(1, ceiling(state$player$max_hp * 0.25))
  state$player$hp <- max(1, state$player$hp - cost)
  if (is.null(state$meta)) state$meta <- list()
  state$meta$souls <- (state$meta$souls %||% 0) + 50
  state$message_log <- c(state$message_log,
                         sprintf("The shrine drains %d HP and grants 50 souls.", cost))
  return(state)
}

handle_wandering_merchant <- function(state) {
  if (!exists("generate_random_item")) {
    state$message_log <- c(state$message_log, "The merchant has nothing to sell today.")
    return(state)
  }
  type <- sample(c("weapon", "armor", "potion"), 1)
  item <- generate_random_item(state$level, type = type, forced_rarity = "rare")
  price <- max(20, round((item$value %||% 20) * 1.5))
  cat(sprintf("[1] Buy %s for %d gold\n", item$name, price))
  cat(sprintf("[0] Walk away (Your gold: %d)\n", state$player$gold))
  choice <- suppressWarnings(as.integer(readline("Enter choice: ")))
  if (is.na(choice) || choice != 1) return(state)

  if (state$player$gold < price) {
    state$message_log <- c(state$message_log, "Not enough gold!")
    return(state)
  }

  state$player$gold <- state$player$gold - price
  if (identical(item$type, "weapon")) {
    state$player$weapon <- item
  } else if (identical(item$type, "armor")) {
    state$player$armor <- item
  } else {
    state$player$potions <- c(state$player$potions, list(item))
  }
  state$message_log <- c(state$message_log,
                         sprintf("Bought %s for %d gold.", item$name, price))
  return(state)
}

handle_mystery_chest <- function(state) {
  cat("[1] Open the chest\n")
  cat("[0] Leave it alone\n")
  choice <- suppressWarnings(as.integer(readline("Enter choice: ")))
  if (is.na(choice) || choice != 1) return(state)

  # 50/50: legendary item or trap damage
  if (runif(1) < 0.5 && exists("generate_random_item")) {
    type <- sample(c("weapon", "armor", "potion"), 1)
    item <- generate_random_item(state$level, type = type, forced_rarity = "legendary")
    if (identical(item$type, "weapon")) {
      state$player$weapon <- item
    } else if (identical(item$type, "armor")) {
      state$player$armor <- item
    } else {
      state$player$potions <- c(state$player$potions, list(item))
    }
    state$message_log <- c(state$message_log,
                           sprintf("The chest contained %s!", item$name))
  } else {
    dmg <- max(1, ceiling(state$player$max_hp * 0.20))
    state$player$hp <- max(1, state$player$hp - dmg)
    state$message_log <- c(state$message_log,
                           sprintf("It was trapped! You take %d damage.", dmg))
  }
  return(state)
}

handle_wounded_adventurer <- function(state) {
  cat("[1] Give a healing potion (heals adventurer, +30 gold reward)\n")
  cat("[2] Refuse and loot them (+50 gold, -1 karma)\n")
  cat("[0] Walk away\n")
  choice <- suppressWarnings(as.integer(readline("Enter choice: ")))
  if (is.na(choice) || !(choice %in% c(1, 2))) return(state)

  if (choice == 1) {
    if (length(state$player$potions) == 0) {
      state$message_log <- c(state$message_log, "You have no potions to give.")
      return(state)
    }
    state$player$potions <- state$player$potions[-1]
    state$player$gold <- state$player$gold + 30
    state$message_log <- c(state$message_log,
                           "The adventurer recovers and rewards you with 30 gold.")
  } else {
    state$player$gold <- state$player$gold + 50
    state$message_log <- c(state$message_log,
                           "You loot the dying adventurer. (+50 gold)")
  }
  return(state)
}
