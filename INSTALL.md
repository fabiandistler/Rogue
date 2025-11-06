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

**IMPORTANT**: Rscript mode is NOT supported due to `readline()` limitations. You must use an interactive R session.

### Method 1: R Console (Recommended)
```bash
cd Rogue
R
```

Then in R:
```r
source("rogue.R")
main()
```

### Method 2: RStudio
1. Open `rogue.R` in RStudio
2. Source the file (Ctrl+Shift+S or Cmd+Shift+S)
3. Run `main()` in the console

### Method 3: One-liner from shell
```bash
cd Rogue
R -e "source('rogue.R'); main()"
```
Note: This works because `-e` runs in interactive mode.

## Requirements

- **R version**: >= 3.6.0 (should work with any modern R)
- **Terminal**: ANSI color support (most modern terminals)
- **No additional packages required!**

## Troubleshooting

### Colors don't show up
Your terminal might not support ANSI escape codes. Try:
- Using a different terminal (iTerm2 on Mac, Windows Terminal on Windows)
- Running in RStudio console

### "Command not found: R"
R is not in your PATH. Either:
- Install R (see above)
- Use full path: `/usr/bin/R`

### Input doesn't work / Game loops infinitely
**This happens when using Rscript mode.** The game requires an interactive R session because it uses `readline()` for input. Solutions:
- Run from R console: `R`, then `source('rogue.R'); main()`
- Run from RStudio
- Use: `R -e "source('rogue.R'); main()"`
- Do NOT use: `Rscript rogue.R` (not supported)

## Performance Tips

- The game is turn-based, so performance shouldn't be an issue
- If rendering is slow, try reducing the view range in `src/renderer.R`
- Smaller terminal window = faster rendering
