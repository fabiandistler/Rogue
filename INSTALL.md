# Installation Guide

## R Installation

### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install r-base
```

### macOS
```bash
# With Homebrew
brew install r

# Or download from CRAN
# https://cran.r-project.org/bin/macosx/
```

### Windows
Download and install from: https://cran.r-project.org/bin/windows/base/

## Running the Game

### Method 1: Terminal (Recommended)
```bash
cd Rogue
Rscript rogue.R
```

### Method 2: R Console
```bash
cd Rogue
R
```

Then in R:
```r
source("rogue.R")
main()
```

### Method 3: RStudio
1. Open `rogue.R` in RStudio
2. Source the file (Ctrl+Shift+S or Cmd+Shift+S)
3. Run `main()` in the console

## Requirements

- **R version**: >= 3.6.0 (should work with any modern R)
- **Terminal**: ANSI color support (most modern terminals)
- **No additional packages required!**

## Troubleshooting

### Colors don't show up
Your terminal might not support ANSI escape codes. Try:
- Using a different terminal (iTerm2 on Mac, Windows Terminal on Windows)
- Running in RStudio console

### "Command not found: Rscript"
R is not in your PATH. Either:
- Install R (see above)
- Use full path: `/usr/bin/Rscript rogue.R`
- Run from R console instead

### Input doesn't work
Make sure you're running in an interactive terminal, not as a background script.

## Performance Tips

- The game is turn-based, so performance shouldn't be an issue
- If rendering is slow, try reducing the view range in `src/renderer.R`
- Smaller terminal window = faster rendering
