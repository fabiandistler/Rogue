# ============================================================================
# Input Handling
# ============================================================================
# Handles user input for game controls with real-time input support

# Global variable to track if keypress is available
.keypress_available <- NULL

# Check if keypress package is available
check_keypress <- function() {
  if (is.null(.keypress_available)) {
    .keypress_available <<- requireNamespace("keypress", quietly = TRUE)
    if (.keypress_available) {
      cat("\033[32m✓\033[0m Real-time input enabled (keypress)\n")
    } else {
      cat("\033[33m⚠\033[0m Using readline mode (press Enter after input)\n")
      cat("  Install keypress for real-time input: install.packages('keypress')\n")
    }
  }
  return(.keypress_available)
}

# Get single keypress (real-time input)
get_keypress <- function() {
  if (!check_keypress()) {
    # Fallback to readline
    cat("\n> ")
    return(tolower(trimws(readline())))
  }

  # Use keypress for real-time input
  cat("\n> ")
  key <- keypress::keypress(block = TRUE)

  # Handle special keys
  if (is.null(key) || key == "") {
    return("invalid")
  }

  # Echo the key (since keypress doesn't echo)
  cat(key, "\n")

  return(tolower(key))
}

# Main input function
get_input <- function() {
  # Check if we should use keypress or readline
  use_keypress <- check_keypress()

  if (use_keypress) {
    # Real-time input mode with keypress
    return(get_input_keypress())
  } else {
    # Traditional readline mode
    return(get_input_readline())
  }
}

# Keypress-based input (real-time)
get_input_keypress <- function() {
  key <- get_keypress()

  # Check if it's a number (for multi-move)
  if (grepl("^[0-9]$", key)) {
    # Enter multi-move mode
    count_str <- key
    cat("  Count: ", count_str, " - Enter direction (w/a/s/d): ", sep = "")

    # Keep reading digits
    while (TRUE) {
      next_key <- keypress::keypress(block = TRUE)

      if (is.null(next_key) || next_key == "") {
        next
      }

      next_key <- tolower(next_key)

      # If another digit, append to count
      if (grepl("^[0-9]$", next_key)) {
        count_str <- paste0(count_str, next_key)
        cat(next_key)
      } else if (next_key %in% c("w", "a", "s", "d")) {
        # Direction key pressed
        cat(next_key, "\n")
        count <- as.integer(count_str)
        return(list(type = "multi_move", count = count, direction = next_key))
      } else {
        # Invalid key, cancel multi-move
        cat("\n  Cancelled.\n")
        return("invalid")
      }
    }
  }

  # Single character commands
  return(parse_input_key(key))
}

# Readline-based input (traditional, requires Enter)
get_input_readline <- function() {
  cat("\n> ")
  input <- tolower(trimws(readline()))

  # Parse input - check for multiple steps (e.g., "5w", "3a")
  if (grepl("^[0-9]+[wasd]$", input)) {
    # Extract number and direction
    count <- as.integer(gsub("[^0-9]", "", input))
    direction <- gsub("[^wasd]", "", input)

    # Return as a list with count and direction
    return(list(type = "multi_move", count = count, direction = direction))
  }

  return(parse_input_key(input))
}

# Parse single input key/command
parse_input_key <- function(input) {
  if (input == "w" || input == "a" || input == "s" || input == "d") {
    return(input)
  } else if (input == "q") {
    return("quit")
  } else if (input == "i") {
    return("inventory")
  } else if (input == "k") {
    return("abilities")
  } else if (input == "m") {
    return("minimap")
  } else if (input == "p") {
    return("meta")
  } else if (input == "o") {
    return("auto_explore")
  } else if (input == "f") {
    return("search")
  } else if (input == "e") {
    return("interact")
  } else if (input == "v") {
    return("achievements")
  } else if (input == "b") {
    return("leaderboard")
  } else if (input == "?") {
    return("help")
  } else {
    return("invalid")
  }
}
