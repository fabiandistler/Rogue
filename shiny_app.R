# ============================================================================
# ROGUE - Shiny GUI Version
# ============================================================================
# Web-based graphical interface for the game

library(shiny)

# Source all game modules
source("src/game_state.R")
source("src/dungeon_gen.R")
source("src/fov.R")
source("src/themes.R")
source("src/abilities.R")
source("src/meta_progression.R")
source("src/renderer.R")
source("src/combat.R")
source("src/input.R")

# ============================================================================
# UI Definition
# ============================================================================

ui <- fluidPage(
  # Custom CSS for styling
  tags$head(
    tags$style(HTML("
      body {
        background-color: #1a1a1a;
        color: #ffffff;
        font-family: 'Courier New', monospace;
      }
      .game-container {
        background-color: #000000;
        border: 2px solid #00ff00;
        padding: 20px;
        margin: 20px;
        border-radius: 5px;
      }
      .dungeon-map {
        font-family: 'Courier New', monospace;
        font-size: 16px;
        line-height: 1.2;
        letter-spacing: 2px;
        background-color: #000000;
        padding: 10px;
        border: 1px solid #333;
      }
      .player { color: #00ffff; font-weight: bold; }
      .enemy { color: #ff0000; font-weight: bold; }
      .boss { color: #ff00ff; font-weight: bold; }
      .item { color: #ffff00; }
      .stairs { color: #00ff00; }
      .wall { color: #888888; }
      .floor { color: #333333; }
      .unexplored { color: #000000; }
      .explored { color: #222222; }

      .stat-box {
        background-color: #2a2a2a;
        padding: 10px;
        margin: 5px;
        border-radius: 5px;
        border: 1px solid #444;
      }

      .message-log {
        background-color: #1a1a1a;
        padding: 10px;
        margin-top: 10px;
        border: 1px solid #444;
        max-height: 150px;
        overflow-y: auto;
      }

      .btn-game {
        background-color: #2a4a2a;
        color: #00ff00;
        border: 1px solid #00ff00;
        font-family: 'Courier New', monospace;
        padding: 10px 20px;
        margin: 5px;
      }

      .btn-game:hover {
        background-color: #3a5a3a;
      }

      .ability-btn {
        background-color: #2a2a4a;
        color: #00ffff;
        border: 1px solid #00ffff;
        margin: 3px;
        padding: 5px 10px;
      }

      .ability-btn:disabled {
        background-color: #1a1a1a;
        color: #666666;
        border: 1px solid #333;
      }
    "))
  ),

  # Title
  titlePanel(
    div(
      style = "color: #00ff00; text-shadow: 0 0 10px #00ff00;",
      "⚔ ROGUE - The R Dungeon Crawler ⚔"
    )
  ),

  # Main game interface
  div(class = "game-container",
    fluidRow(
      # Left panel - Game display
      column(8,
        # Meta stats and controls
        fluidRow(
          column(6,
            actionButton("new_game", "New Game", class = "btn-game"),
            actionButton("show_meta", "Meta Progress", class = "btn-game")
          ),
          column(6,
            textOutput("game_status", inline = TRUE)
          )
        ),

        # Theme info
        div(class = "stat-box",
          uiOutput("theme_info")
        ),

        # Dungeon map
        div(class = "dungeon-map",
          uiOutput("game_map")
        ),

        # Player stats
        div(class = "stat-box",
          uiOutput("player_stats")
        ),

        # Message log
        div(class = "message-log",
          uiOutput("message_log")
        )
      ),

      # Right panel - Controls and abilities
      column(4,
        # Movement controls
        div(class = "stat-box",
          h4("Movement"),
          fluidRow(
            column(12, align = "center",
              actionButton("move_w", "↑ W", class = "btn-game"),
              br(),
              actionButton("move_a", "← A", class = "btn-game"),
              actionButton("move_s", "↓ S", class = "btn-game"),
              actionButton("move_d", "→ D", class = "btn-game")
            )
          )
        ),

        # Abilities
        div(class = "stat-box",
          h4("Abilities"),
          uiOutput("abilities_ui")
        ),

        # Other actions
        div(class = "stat-box",
          h4("Actions"),
          actionButton("show_inventory", "Inventory", class = "btn-game"),
          actionButton("show_abilities", "Skill Tree", class = "btn-game")
        ),

        # Enemy info
        div(class = "stat-box",
          h4("Nearby Enemies"),
          uiOutput("enemy_list")
        )
      )
    )
  )
)

# ============================================================================
# Server Logic
# ============================================================================

server <- function(input, output, session) {

  # Reactive values
  game_state <- reactiveVal(NULL)
  meta_data <- reactiveVal(NULL)

  # Initialize
  observe({
    meta_data(load_meta_progression())
  })

  # New game
  observeEvent(input$new_game, {
    meta <- meta_data()

    # Show meta stats in modal
    showModal(modalDialog(
      title = "Meta Progression",
      renderPrint({
        show_meta_stats(meta)
      }),
      footer = tagList(
        modalButton("Start Game")
      )
    ))

    # Initialize game
    state <- init_game_state(meta = meta)
    game_state(state)
  })

  # Movement handlers
  observeEvent(input$move_w, { handle_action("w") })
  observeEvent(input$move_a, { handle_action("a") })
  observeEvent(input$move_s, { handle_action("s") })
  observeEvent(input$move_d, { handle_action("d") })

  # Ability handlers
  observeEvent(input$use_heal, { handle_ability("heal") })
  observeEvent(input$use_power, { handle_ability("power_strike") })
  observeEvent(input$use_shield, { handle_ability("shield_wall") })
  observeEvent(input$use_whirlwind, { handle_ability("whirlwind") })
  observeEvent(input$use_teleport, { handle_ability("teleport") })

  # Handle action
  handle_action <- function(action) {
    state <- game_state()
    if (is.null(state) || !state$running) return()

    # Process action
    state <- process_action(state, action)

    # Process enemy turns if player acted
    if (state$player_acted) {
      state <- process_enemies(state)
      state <- update_cooldowns(state)
      state$player_acted <- FALSE
    }

    # Check win/lose
    state <- check_conditions(state)

    # Check if game ended
    if (!state$running) {
      meta <- update_meta_progression(meta_data(), state)
      save_meta_progression(meta)
      meta_data(meta)

      if (state$player$hp <= 0) {
        showNotification("Game Over! You died.", type = "error", duration = NULL)
      } else {
        showNotification("Victory! You escaped the dungeon!", type = "message", duration = NULL)
      }
    }

    game_state(state)
  }

  # Handle ability
  handle_ability <- function(ability_id) {
    state <- game_state()
    if (is.null(state)) return()

    state <- use_ability(state, ability_id)
    game_state(state)
  }

  # Render game map
  output$game_map <- renderUI({
    state <- game_state()
    if (is.null(state)) return(HTML("<p>Click 'New Game' to start!</p>"))

    # Render dungeon
    map_html <- render_map_html(state)
    HTML(map_html)
  })

  # Render player stats
  output$player_stats <- renderUI({
    state <- game_state()
    if (is.null(state)) return(NULL)

    HTML(sprintf(
      "<strong>HP:</strong> %d/%d | <strong>ATK:</strong> %d (+%d) | <strong>DEF:</strong> %d (+%d) | <strong>Gold:</strong> %d | <strong>SP:</strong> %d<br>
       <strong>Weapon:</strong> %s | <strong>Armor:</strong> %s<br>
       <strong>Level:</strong> %d | <strong>Enemies:</strong> %d | <strong>Kills:</strong> %d",
      state$player$hp, state$player$max_hp,
      state$player$attack, state$player$weapon$damage,
      state$player$defense, state$player$armor$defense,
      state$player$gold,
      state$abilities$skill_points,
      state$player$weapon$name,
      state$player$armor$name,
      state$level,
      sum(sapply(state$enemies, function(e) e$alive)),
      state$stats$kills
    ))
  })

  # Render theme info
  output$theme_info <- renderUI({
    state <- game_state()
    if (is.null(state) || is.null(state$theme)) return(NULL)

    HTML(sprintf(
      "<h4 style='color: #ffaa00;'>%s</h4><p>%s</p>",
      state$theme$data$name,
      state$theme$data$description
    ))
  })

  # Render message log
  output$message_log <- renderUI({
    state <- game_state()
    if (is.null(state)) return(NULL)

    messages <- rev(tail(state$message_log, 10))
    HTML(paste0("<p>", paste(messages, collapse = "</p><p>"), "</p>"))
  })

  # Render abilities
  output$abilities_ui <- renderUI({
    state <- game_state()
    if (is.null(state)) return(NULL)

    abilities <- state$abilities$abilities

    tagList(
      actionButton("use_heal",
        sprintf("Heal (%d)", abilities$heal$current_cooldown),
        class = "ability-btn",
        disabled = abilities$heal$current_cooldown > 0 || !abilities$heal$unlocked
      ),
      actionButton("use_power",
        sprintf("Power Strike (%d)", abilities$power_strike$current_cooldown),
        class = "ability-btn",
        disabled = abilities$power_strike$current_cooldown > 0 || !abilities$power_strike$unlocked
      ),
      actionButton("use_shield",
        sprintf("Shield (%d)", abilities$shield_wall$current_cooldown),
        class = "ability-btn",
        disabled = abilities$shield_wall$current_cooldown > 0 || !abilities$shield_wall$unlocked
      ),
      actionButton("use_whirlwind",
        sprintf("Whirlwind (%d)", abilities$whirlwind$current_cooldown),
        class = "ability-btn",
        disabled = abilities$whirlwind$current_cooldown > 0 || !abilities$whirlwind$unlocked
      ),
      actionButton("use_teleport",
        sprintf("Teleport (%d)", abilities$teleport$current_cooldown),
        class = "ability-btn",
        disabled = abilities$teleport$current_cooldown > 0 || !abilities$teleport$unlocked
      )
    )
  })

  # Render enemy list
  output$enemy_list <- renderUI({
    state <- game_state()
    if (is.null(state)) return(NULL)

    # Get visible enemies
    visible_enemies <- Filter(function(e) {
      e$alive && is_visible(state, e$x, e$y)
    }, state$enemies)

    if (length(visible_enemies) == 0) {
      return(HTML("<p>No enemies in sight</p>"))
    }

    enemy_html <- sapply(visible_enemies, function(e) {
      color <- if (e$is_boss) "#ff00ff" else "#ff0000"
      sprintf("<p style='color: %s;'>%s - HP: %d</p>", color, e$name, e$hp)
    })

    HTML(paste(enemy_html, collapse = ""))
  })
}

# Helper function to render map as HTML
render_map_html <- function(state) {
  # Create a simple grid representation
  view_range <- 20
  px <- state$player$x
  py <- state$player$y

  min_x <- max(1, px - view_range)
  max_x <- min(ncol(state$map), px + view_range)
  min_y <- max(1, py - view_range)
  max_y <- min(nrow(state$map), py + view_range)

  html_lines <- character(0)

  for (y in min_y:max_y) {
    line <- ""
    for (x in min_x:max_x) {
      visible <- is_visible(state, x, y)
      explored <- is_explored(state, x, y)

      if (!explored) {
        line <- paste0(line, "<span class='unexplored'> </span>")
      } else if (visible) {
        # Check entities
        if (x == px && y == py) {
          line <- paste0(line, "<span class='player'>@</span>")
        } else if (!is.null(enemy <- get_enemy_at(state, x, y))) {
          class <- if (enemy$is_boss) "boss" else "enemy"
          line <- paste0(line, sprintf("<span class='%s'>%s</span>", class, enemy$char))
        } else if (!is.null(item <- get_item_at(state, x, y))) {
          line <- paste0(line, sprintf("<span class='item'>%s</span>", item$char))
        } else if (x == state$stairs_pos$x && y == state$stairs_pos$y) {
          line <- paste0(line, "<span class='stairs'>></span>")
        } else {
          char <- state$map[y, x]
          class <- if (char == "#") "wall" else "floor"
          line <- paste0(line, sprintf("<span class='%s'>%s</span>", class, char))
        }
      } else {
        # Explored but not visible
        char <- state$map[y, x]
        line <- paste0(line, sprintf("<span class='explored'>%s</span>", char))
      }
    }
    html_lines <- c(html_lines, line)
  }

  paste(html_lines, collapse = "<br>")
}

# Run the app
shinyApp(ui = ui, server = server)
