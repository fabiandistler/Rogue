# ============================================================================
# Field of View (FOV) System
# ============================================================================
# Implements line-of-sight calculation for the player

# Initialize FOV state
init_fov_state <- function(map) {
  explored <- matrix(FALSE, nrow = nrow(map), ncol = ncol(map))
  visible <- matrix(FALSE, nrow = nrow(map), ncol = ncol(map))

  list(
    explored = explored,
    visible = visible
  )
}

# Calculate FOV using raycasting
calculate_fov <- function(state, radius = 7) {
  # Reset visible tiles
  state$fov$visible <- matrix(FALSE, nrow = nrow(state$map), ncol = ncol(state$map))

  px <- state$player$x
  py <- state$player$y

  # Player position is always visible
  if (px >= 1 && px <= ncol(state$map) && py >= 1 && py <= nrow(state$map)) {
    state$fov$visible[py, px] <- TRUE
    state$fov$explored[py, px] <- TRUE
  }

  # Cast rays in multiple directions (360 degrees)
  num_rays <- 360
  for (i in 1:num_rays) {
    angle <- (i / num_rays) * 2 * pi
    dx <- cos(angle)
    dy <- sin(angle)

    # Cast ray from player position
    state <- cast_ray(state, px, py, dx, dy, radius)
  }

  return(state)
}

# Cast a single ray and mark visible tiles
cast_ray <- function(state, start_x, start_y, dx, dy, max_distance) {
  x <- start_x
  y <- start_y

  for (dist in seq(0, max_distance, by = 0.5)) {
    x <- start_x + dx * dist
    y <- start_y + dy * dist

    # Round to grid position
    grid_x <- round(x)
    grid_y <- round(y)

    # Check bounds
    if (grid_x < 1 || grid_x > ncol(state$map) ||
        grid_y < 1 || grid_y > nrow(state$map)) {
      break
    }

    # Mark as visible and explored
    state$fov$visible[grid_y, grid_x] <- TRUE
    state$fov$explored[grid_y, grid_x] <- TRUE

    # Stop at walls
    if (state$map[grid_y, grid_x] == "#") {
      break
    }
  }

  return(state)
}

# Check if a position is visible to the player
is_visible <- function(state, x, y) {
  if (x < 1 || x > ncol(state$map) || y < 1 || y > nrow(state$map)) {
    return(FALSE)
  }
  return(state$fov$visible[y, x])
}

# Check if a position has been explored
is_explored <- function(state, x, y) {
  if (x < 1 || x > ncol(state$map) || y < 1 || y > nrow(state$map)) {
    return(FALSE)
  }
  return(state$fov$explored[y, x])
}
