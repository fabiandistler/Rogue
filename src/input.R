# ============================================================================
# Input Handling
# ============================================================================
# Handles user input for game controls

get_input <- function() {
  # Prompt for input
  cat("\n> ")

  # Get input
  input <- tolower(trimws(readline()))

  # Parse input - check for multiple steps (e.g., "5w", "3a")
  if (grepl("^[0-9]+[wasd]$", input)) {
    # Extract number and direction
    count <- as.integer(gsub("[^0-9]", "", input))
    direction <- gsub("[^wasd]", "", input)

    # Return as a list with count and direction
    return(list(type = "multi_move", count = count, direction = direction))
  }

  # Single character commands
  if (input == "w" || input == "a" || input == "s" || input == "d") {
    return(input)
  } else if (input == "q") {
    return("quit")
  } else if (input == "i") {
    return("inventory")
  } else if (input == "k") {
    return("abilities")
  } else if (input == "m") {
    return("meta")
  } else {
    return("invalid")
  }
}
