# ============================================================================
# Dungeon Themes System
# ============================================================================
# Different visual themes and environmental effects for dungeons

# Define dungeon themes
get_dungeon_themes <- function() {
  list(
    crypt = list(
      name = "Ancient Crypt",
      wall_color = "\033[0;34m",      # Dark blue
      floor_color = "\033[0;90m",     # Dark gray
      description = "Musty air and crumbling stonework",
      enemies = c("Skeleton", "Ghost", "Wraith"),
      enemy_chars = c("s", "G", "W"),
      boss_char = "L"  # Lich
    ),

    volcano = list(
      name = "Volcanic Depths",
      wall_color = "\033[0;31m",      # Red
      floor_color = "\033[0;33m",     # Dark yellow
      description = "Intense heat radiates from molten rocks",
      enemies = c("Fire Imp", "Magma Beast", "Ifrit"),
      enemy_chars = c("i", "M", "I"),
      boss_char = "F"  # Fire Lord
    ),

    ice_cave = list(
      name = "Frozen Caverns",
      wall_color = "\033[1;36m",      # Bright cyan
      floor_color = "\033[0;96m",     # Light cyan
      description = "Freezing wind cuts through your armor",
      enemies = c("Ice Sprite", "Frost Giant", "Wendigo"),
      enemy_chars = c("i", "F", "W"),
      boss_char = "Y"  # Yeti King
    ),

    forest = list(
      name = "Twisted Grove",
      wall_color = "\033[0;32m",      # Green
      floor_color = "\033[0;33m",     # Dark yellow/brown
      description = "Gnarled roots and poisonous thorns",
      enemies = c("Wild Boar", "Treant", "Dryad"),
      enemy_chars = c("b", "T", "d"),
      boss_char = "E"  # Elder Treant
    ),

    dungeon = list(
      name = "Dark Dungeon",
      wall_color = "\033[0;37m",      # Gray
      floor_color = "\033[0;90m",     # Dark gray
      description = "Classic dungeon corridors",
      enemies = c("Goblin", "Orc", "Troll"),
      enemy_chars = c("g", "o", "T"),
      boss_char = "D"  # Dragon
    ),

    temple = list(
      name = "Cursed Temple",
      wall_color = "\033[0;33m",      # Yellow/gold
      floor_color = "\033[0;37m",     # Light gray
      description = "Ancient evil lingers in these halls",
      enemies = c("Cultist", "Gargoyle", "Demon"),
      enemy_chars = c("c", "G", "D"),
      boss_char = "A"  # Archfiend
    )
  )
}

# Select theme based on level
select_theme_for_level <- function(level) {
  themes <- get_dungeon_themes()
  theme_names <- names(themes)

  # Rotate through themes every 2 levels
  theme_idx <- ((level - 1) %/% 2) %% length(theme_names) + 1
  theme_name <- theme_names[theme_idx]

  return(list(
    id = theme_name,
    data = themes[[theme_name]]
  ))
}

# Apply theme to enemies
apply_theme_to_enemies <- function(enemies, theme, level) {
  # Replace enemy names and chars with themed versions
  for (i in seq_along(enemies)) {
    if (!enemies[[i]]$is_boss) {
      # Select themed enemy based on original enemy strength
      enemy_idx <- min(ceiling(enemies[[i]]$hp / 30), length(theme$data$enemies))

      enemies[[i]]$name <- theme$data$enemies[enemy_idx]
      enemies[[i]]$char <- theme$data$enemy_chars[enemy_idx]
    } else {
      # Themed boss
      enemies[[i]]$char <- theme$data$boss_char
    }
  }

  return(enemies)
}

# Get theme colors for rendering
get_theme_colors <- function(theme) {
  if (is.null(theme) || is.null(theme$data)) {
    # Default colors
    return(list(
      wall = "\033[0;37m",
      floor = "\033[0;90m"
    ))
  }

  return(list(
    wall = theme$data$wall_color,
    floor = theme$data$floor_color
  ))
}

# Display theme info
show_theme_info <- function(state) {
  if (!is.null(state$theme)) {
    cat("\033[1;33m")  # Yellow
    cat(sprintf("=== %s ===\n", state$theme$data$name))
    cat(state$theme$data$description)
    cat("\033[0m\n")
  }
}
