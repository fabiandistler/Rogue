#!/usr/bin/env Rscript
# Setup script for Rogue CLI game
# Installs required dependencies

cat("=== Rogue CLI - Dependency Setup ===\n\n")

# Required packages
required_packages <- c("cli", "crayon", "jsonlite")
optional_packages <- c("keypress")

install_if_missing <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    cat(sprintf("Installing %s...\n", package_name))
    install.packages(package_name, repos = "https://cran.rstudio.com/")
    return(TRUE)
  } else {
    cat(sprintf("✓ %s already installed\n", package_name))
    return(FALSE)
  }
}

cat("Checking required packages:\n")
for (pkg in required_packages) {
  install_if_missing(pkg)
}

cat("\nChecking optional packages:\n")
for (pkg in optional_packages) {
  result <- tryCatch({
    install_if_missing(pkg)
  }, error = function(e) {
    cat(sprintf("⚠ %s not available (optional)\n", pkg))
    FALSE
  })
}

cat("\n=== Setup Complete! ===\n")
cat("Run the game with: R -e \"source('rogue.R'); main()\"\n")
