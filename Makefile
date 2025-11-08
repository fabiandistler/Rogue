# ============================================================================
# ROGUE - Makefile
# ============================================================================

.PHONY: play start run setup install clean help

# Default target - show help
.DEFAULT_GOAL := help

# Start the game
play: ## Start the game (alias: start, run)
	@echo "🎮 Starting ROGUE..."
	@R --quiet --no-save -e "source('rogue.R'); main()"

start: play
run: play

# Setup dependencies
setup: ## Install R package dependencies
	@echo "📦 Installing dependencies..."
	@R -e "source('setup.R')"

install: setup

# Clean temporary files
clean: ## Remove temporary files and caches
	@echo "🧹 Cleaning up..."
	@rm -f .RData .Rhistory
	@rm -rf .Rproj.user
	@echo "✓ Clean complete"

# Show help
help: ## Show this help message
	@echo "═══════════════════════════════════════════════════════"
	@echo "         🎮 ROGUE - Make Commands 🎮"
	@echo "═══════════════════════════════════════════════════════"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "═══════════════════════════════════════════════════════"
	@echo ""
	@echo "Quick start: make play"
	@echo ""
