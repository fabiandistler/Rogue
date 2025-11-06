# ============================================================================
# Procedural Dungeon Generation
# ============================================================================
# Uses Binary Space Partitioning (BSP) to create random dungeons

generate_dungeon <- function(width = 40, height = 20, difficulty = 1) {
  # Create empty map filled with walls
  map <- matrix("#", nrow = height, ncol = width)

  # Create root container for BSP
  root <- list(
    x = 1,
    y = 1,
    width = width,
    height = height,
    left = NULL,
    right = NULL,
    room = NULL
  )

  # Split the space recursively
  root <- split_container(root, min_size = 6, max_depth = 4)

  # Create rooms in leaf nodes
  rooms <- list()
  rooms <- create_rooms(root, rooms)

  # Carve rooms into map
  for (room in rooms) {
    for (x in room$x1:room$x2) {
      for (y in room$y1:room$y2) {
        if (x > 0 && x <= width && y > 0 && y <= height) {
          map[y, x] <- "."
        }
      }
    }
  }

  # Connect rooms with corridors
  map <- connect_rooms(map, rooms)

  # Place stairs in the last room
  last_room <- rooms[[length(rooms)]]
  stairs_x <- floor((last_room$x1 + last_room$x2) / 2)
  stairs_y <- floor((last_room$y1 + last_room$y2) / 2)
  map[stairs_y, stairs_x] <- ">"

  # Starting position is center of first room
  first_room <- rooms[[1]]
  start_x <- floor((first_room$x1 + first_room$x2) / 2)
  start_y <- floor((first_room$y1 + first_room$y2) / 2)

  return(list(
    map = map,
    rooms = rooms,
    start_pos = list(x = start_x, y = start_y),
    stairs_pos = list(x = stairs_x, y = stairs_y)
  ))
}

# Recursively split containers using BSP
split_container <- function(container, min_size = 6, max_depth = 4, current_depth = 0) {
  # Stop splitting if max depth reached or container too small
  if (current_depth >= max_depth ||
      container$width < min_size * 2 ||
      container$height < min_size * 2) {
    return(container)
  }

  # Decide split direction
  split_horizontal <- runif(1) > 0.5

  if (container$width > container$height && container$width / container$height >= 1.25) {
    split_horizontal <- FALSE
  } else if (container$height > container$width && container$height / container$width >= 1.25) {
    split_horizontal <- TRUE
  }

  if (split_horizontal) {
    # Split horizontally
    split_pos <- sample(
      (container$y + min_size):(container$y + container$height - min_size),
      1
    )

    container$left <- list(
      x = container$x,
      y = container$y,
      width = container$width,
      height = split_pos - container$y,
      left = NULL,
      right = NULL,
      room = NULL
    )

    container$right <- list(
      x = container$x,
      y = split_pos,
      width = container$width,
      height = container$y + container$height - split_pos,
      left = NULL,
      right = NULL,
      room = NULL
    )
  } else {
    # Split vertically
    split_pos <- sample(
      (container$x + min_size):(container$x + container$width - min_size),
      1
    )

    container$left <- list(
      x = container$x,
      y = container$y,
      width = split_pos - container$x,
      height = container$height,
      left = NULL,
      right = NULL,
      room = NULL
    )

    container$right <- list(
      x = split_pos,
      y = container$y,
      width = container$x + container$width - split_pos,
      height = container$height,
      left = NULL,
      right = NULL,
      room = NULL
    )
  }

  # Recursively split children
  container$left <- split_container(container$left, min_size, max_depth, current_depth + 1)
  container$right <- split_container(container$right, min_size, max_depth, current_depth + 1)

  return(container)
}

# Create rooms in leaf nodes
create_rooms <- function(container, rooms) {
  # If leaf node, create room
  if (is.null(container$left) && is.null(container$right)) {
    # Room size is random within container
    room_width <- max(3, sample(3:(container$width - 2), 1))
    room_height <- max(3, sample(3:(container$height - 2), 1))

    # Random position within container
    room_x <- container$x + sample(1:(container$width - room_width), 1)
    room_y <- container$y + sample(1:(container$height - room_height), 1)

    room <- list(
      x1 = room_x,
      y1 = room_y,
      x2 = room_x + room_width - 1,
      y2 = room_y + room_height - 1,
      center_x = floor(room_x + room_width / 2),
      center_y = floor(room_y + room_height / 2)
    )

    container$room <- room
    rooms <- c(rooms, list(room))
  } else {
    # Recurse into children
    if (!is.null(container$left)) {
      rooms <- create_rooms(container$left, rooms)
    }
    if (!is.null(container$right)) {
      rooms <- create_rooms(container$right, rooms)
    }
  }

  return(rooms)
}

# Connect rooms with corridors
connect_rooms <- function(map, rooms) {
  for (i in 1:(length(rooms) - 1)) {
    room1 <- rooms[[i]]
    room2 <- rooms[[i + 1]]

    # Create L-shaped corridor
    if (runif(1) > 0.5) {
      # Horizontal then vertical
      map <- create_h_corridor(map, room1$center_x, room2$center_x, room1$center_y)
      map <- create_v_corridor(map, room1$center_y, room2$center_y, room2$center_x)
    } else {
      # Vertical then horizontal
      map <- create_v_corridor(map, room1$center_y, room2$center_y, room1$center_x)
      map <- create_h_corridor(map, room1$center_x, room2$center_x, room2$center_y)
    }
  }

  return(map)
}

# Create horizontal corridor
create_h_corridor <- function(map, x1, x2, y) {
  for (x in min(x1, x2):max(x1, x2)) {
    if (x > 0 && x <= ncol(map) && y > 0 && y <= nrow(map)) {
      map[y, x] <- "."
    }
  }
  return(map)
}

# Create vertical corridor
create_v_corridor <- function(map, y1, y2, x) {
  for (y in min(y1, y2):max(y1, y2)) {
    if (x > 0 && x <= ncol(map) && y > 0 && y <= nrow(map)) {
      map[y, x] <- "."
    }
  }
  return(map)
}
