# ============================================================================
# Input Handling
# ============================================================================
# Handles user input for game controls

get_input <- function() {
  # Prompt for input
  cat("\n> ")

  # Get single character input
  input <- tolower(readline())

  # Parse input
  if (input == "w" || input == "a" || input == "s" || input == "d") {
    return(input)
  } else if (input == "q") {
    return("quit")
  } else if (input == "i") {
    return("inventory")
  } else {
    return("invalid")
  }
}
