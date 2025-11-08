#!/bin/bash
# ============================================================================
# ROGUE - Quick Start Script
# ============================================================================
# Simple script to start the game with one command

echo "🎮 Starting ROGUE..."
echo ""

# Check if R is installed
if ! command -v R &> /dev/null; then
    echo "❌ Error: R is not installed!"
    echo "Please install R first: https://www.r-project.org/"
    exit 1
fi

# Start the game
R --quiet --no-save <<EOF
source("rogue.R")
main()
EOF
