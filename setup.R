#!/usr/bin/env Rscript
# Setup script for Rogue CLI game
# Installs required dependencies

cat("╔══════════════════════════════════════════════════╗\n")
cat("║      🎮 ROGUE - Dependency Setup 🎮             ║\n")
cat("╚══════════════════════════════════════════════════╝\n\n")

# Required packages (game works without these but degraded experience)
required_packages <- c("cli", "crayon", "jsonlite")

# Optional packages (highly recommended)
optional_packages <- list(
  keypress = "Real-time input (no Enter key required)"
)

install_if_missing <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    cat(sprintf("  Installing %s...\n", package_name))
    install.packages(package_name, repos = "https://cran.rstudio.com/")
    return(TRUE)
  } else {
    cat(sprintf("  \033[32m✓\033[0m %s already installed\n", package_name))
    return(FALSE)
  }
}

cat("\033[1mCore Packages:\033[0m\n")
cat("(Enhanced UI and save file support)\n\n")
for (pkg in required_packages) {
  install_if_missing(pkg)
}

cat("\n\033[1mOptional Packages:\033[0m\n")
cat("(Highly recommended for best experience)\n\n")
for (pkg in names(optional_packages)) {
  desc <- optional_packages[[pkg]]
  cat(sprintf("\033[1m%s\033[0m - %s\n", pkg, desc))

  result <- tryCatch({
    installed <- install_if_missing(pkg)
    if (installed) {
      cat(sprintf("  \033[32m✓\033[0m Successfully installed!\n"))
    }
    TRUE
  }, error = function(e) {
    cat(sprintf("  \033[33m⚠\033[0m Installation failed (optional)\n"))
    cat(sprintf("  Error: %s\n", e$message))
    FALSE
  })
  cat("\n")
}

cat("╔══════════════════════════════════════════════════╗\n")
cat("║              Setup Complete! ✓                   ║\n")
cat("╚══════════════════════════════════════════════════╝\n\n")

cat("\033[1mStart the game:\033[0m\n")
cat("  R\n")
cat("  > source('rogue.R')\n")
cat("  > main()\n\n")

cat("\033[1mFeatures enabled:\033[0m\n")
if (requireNamespace("keypress", quietly = TRUE)) {
  cat("  \033[32m✓\033[0m Real-time input (keypress)\n")
} else {
  cat("  \033[33m⚠\033[0m Readline mode (requires Enter key)\n")
  cat("    Install keypress for better experience: install.packages('keypress')\n")
}

if (requireNamespace("cli", quietly = TRUE)) {
  cat("  \033[32m✓\033[0m Enhanced terminal UI\n")
}

if (requireNamespace("crayon", quietly = TRUE)) {
  cat("  \033[32m✓\033[0m Rich color support\n")
}

if (requireNamespace("jsonlite", quietly = TRUE)) {
  cat("  \033[32m✓\033[0m Human-readable save files\n")
}

cat("\n\033[1mReady to descend into the dungeon! 💀🎮\033[0m\n")
