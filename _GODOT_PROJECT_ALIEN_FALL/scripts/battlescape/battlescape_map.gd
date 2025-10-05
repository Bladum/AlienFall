class_name BattlescapeMap
extends Node

# BattlescapeMap - Represents the tactical battlefield
# Handles map generation, terrain, and spatial queries

var width: int = 20
var height: int = 20
var tiles: Array = []  # 2D array of tile data
var units: Array[Unit] = []  # Units on the map

signal tile_changed(x: int, y: int, tile_data: Dictionary)
signal unit_moved(unit: Unit, from_pos: Vector2, to_pos: Vector2)
signal unit_added(unit: Unit)
signal unit_removed(unit: Unit)

func _init(map_width: int = 20, map_height: int = 20):
    width = map_width
    height = map_height
    _initialize_map()

func _initialize_map():
    print("BattlescapeMap: Initializing ", width, "x", height, " map")
    
    # Initialize empty tiles
    tiles.resize(width)
    for x in range(width):
        tiles[x] = []
        tiles[x].resize(height)
        for y in range(height):
            tiles[x][y] = _create_default_tile(x, y)

func _create_default_tile(x: int, y: int) -> Dictionary:
    return {
        "terrain": "floor",
        "elevation": 0,
        "cover": 0,  # 0-100, cover bonus for defense
        "blocks_los": false,
        "blocks_movement": false,
        "flammable": false,
        "destructible": false,
        "health": 100,
        "max_health": 100,
        "walkable": true,
        "flyable": true
    }

func generate_random_map(seed_value: int = 0):
    print("BattlescapeMap: Generating random map with seed ", seed_value)
    
    var rng = RandomNumberGenerator.new()
    if seed_value != 0:
        rng.seed = seed_value
    else:
        rng.randomize()
    
    # Generate terrain features
    for x in range(width):
        for y in range(height):
            var tile = tiles[x][y]
            
            # Random terrain variation
            var terrain_roll = rng.randf()
            if terrain_roll < 0.7:
                tile.terrain = "floor"
            elif terrain_roll < 0.85:
                tile.terrain = "wall"
                tile.blocks_los = true
                tile.blocks_movement = true
                tile.walkable = false
                tile.flyable = false
            elif terrain_roll < 0.95:
                tile.terrain = "crate"
                tile.cover = 20
                tile.blocks_los = true
                tile.destructible = true
            else:
                tile.terrain = "pillar"
                tile.blocks_los = true
                tile.blocks_movement = false
                tile.walkable = true
                tile.flyable = true
            
            # Random elevation (0-2)
            tile.elevation = rng.randi_range(0, 2)
            
            tiles[x][y] = tile

func get_tile(x: int, y: int) -> Dictionary:
    if _is_valid_position(x, y):
        return tiles[x][y].duplicate()
    return {}

func set_tile(x: int, y: int, tile_data: Dictionary):
    if _is_valid_position(x, y):
        tiles[x][y] = tile_data.duplicate()
        emit_signal("tile_changed", x, y, tile_data)

func is_walkable(x: int, y: int) -> bool:
    if not _is_valid_position(x, y):
        return false
    return tiles[x][y].walkable

func is_flyable(x: int, y: int) -> bool:
    if not _is_valid_position(x, y):
        return false
    return tiles[x][y].flyable

func get_cover_bonus(x: int, y: int) -> int:
    if not _is_valid_position(x, y):
        return 0
    return tiles[x][y].cover

func get_elevation(x: int, y: int) -> int:
    if not _is_valid_position(x, y):
        return 0
    return tiles[x][y].elevation

func add_unit(unit: Unit, position: Vector2):
    if not _is_valid_position(int(position.x), int(position.y)):
        return false
    
    unit.position = position
    units.append(unit)
    emit_signal("unit_added", unit)
    return true

func remove_unit(unit: Unit):
    if units.has(unit):
        units.erase(unit)
        emit_signal("unit_removed", unit)
        return true
    return false

func get_unit_at_position(position: Vector2) -> Unit:
    for unit in units:
        if unit.position == position:
            return unit
    return null

func get_units_in_area(center: Vector2, radius: int) -> Array[Unit]:
    var result = []
    for unit in units:
        if center.distance_to(unit.position) <= radius:
            result.append(unit)
    return result

func move_unit(unit: Unit, new_position: Vector2) -> bool:
    if not units.has(unit):
        return false
    
    if not _is_valid_position(int(new_position.x), int(new_position.y)):
        return false
    
    if not is_walkable(int(new_position.x), int(new_position.y)):
        return false
    
    # Check if destination is occupied
    var occupying_unit = get_unit_at_position(new_position)
    if occupying_unit and occupying_unit != unit:
        return false
    
    var old_position = unit.position
    unit.position = new_position
    emit_signal("unit_moved", unit, old_position, new_position)
    return true

func get_neighbors(x: int, y: int, include_diagonals: bool = true) -> Array[Vector2]:
    var neighbors = []
    
    # Orthogonal neighbors
    neighbors.append(Vector2(x, y - 1))  # North
    neighbors.append(Vector2(x + 1, y))  # East
    neighbors.append(Vector2(x, y + 1))  # South
    neighbors.append(Vector2(x - 1, y))  # West
    
    if include_diagonals:
        neighbors.append(Vector2(x + 1, y - 1))  # Northeast
        neighbors.append(Vector2(x + 1, y + 1))  # Southeast
        neighbors.append(Vector2(x - 1, y + 1))  # Southwest
        neighbors.append(Vector2(x - 1, y - 1))  # Northwest
    
    # Filter valid positions
    var valid_neighbors = []
    for neighbor in neighbors:
        if _is_valid_position(int(neighbor.x), int(neighbor.y)):
            valid_neighbors.append(neighbor)
    
    return valid_neighbors

func get_path(start: Vector2, end: Vector2) -> Array[Vector2]:
    # Simple A* pathfinding implementation
    var open_set = []
    var closed_set = []
    var came_from = {}
    var g_score = {}
    var f_score = {}
    
    open_set.append(start)
    g_score[start] = 0
    f_score[start] = start.distance_to(end)
    
    while open_set.size() > 0:
        # Find node with lowest f_score
        var current = open_set[0]
        var lowest_f = f_score[current]
        
        for node in open_set:
            if f_score[node] < lowest_f:
                current = node
                lowest_f = f_score[node]
        
        if current == end:
            return _reconstruct_path(came_from, current)
        
        open_set.erase(current)
        closed_set.append(current)
        
        for neighbor in get_neighbors(int(current.x), int(current.y), false):
            if closed_set.has(neighbor):
                continue
            
            if not is_walkable(int(neighbor.x), int(neighbor.y)):
                continue
            
            var tentative_g_score = g_score[current] + 1  # Assume cost of 1 for each step
            
            if not open_set.has(neighbor):
                open_set.append(neighbor)
            elif tentative_g_score >= g_score.get(neighbor, INF):
                continue
            
            came_from[neighbor] = current
            g_score[neighbor] = tentative_g_score
            f_score[neighbor] = g_score[neighbor] + neighbor.distance_to(end)
    
    return []  # No path found

func _reconstruct_path(came_from: Dictionary, current: Vector2) -> Array[Vector2]:
    var path = [current]
    while came_from.has(current):
        current = came_from[current]
        path.push_front(current)
    return path

func has_line_of_sight(start: Vector2, end: Vector2) -> bool:
    # Bresenham's line algorithm for LOS
    var x0 = int(start.x)
    var y0 = int(start.y)
    var x1 = int(end.x)
    var y1 = int(end.y)
    
    var dx = abs(x1 - x0)
    var dy = abs(y1 - y0)
    var sx = 1 if x0 < x1 else -1
    var sy = 1 if y0 < y1 else -1
    var err = dx - dy
    
    while true:
        # Check if current tile blocks LOS
        if tiles[x0][y0].blocks_los:
            return false
        
        if x0 == x1 and y0 == y1:
            break
        
        var e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy
    
    return true

func _is_valid_position(x: int, y: int) -> bool:
    return x >= 0 and x < width and y >= 0 and y < height

func to_dict() -> Dictionary:
    var tiles_data = []
    for x in range(width):
        tiles_data.append([])
        for y in range(height):
            tiles_data[x].append(tiles[x][y].duplicate())
    
    var units_data = []
    for unit in units:
        units_data.append({
            "unit_id": unit.unit_id,
            "position": {"x": unit.position.x, "y": unit.position.y}
        })
    
    return {
        "width": width,
        "height": height,
        "tiles": tiles_data,
        "units": units_data
    }

static func from_dict(data: Dictionary) -> BattlescapeMap:
    var map = BattlescapeMap.new(data.width, data.height)
    
    # Load tiles
    for x in range(data.width):
        for y in range(data.height):
            map.tiles[x][y] = data.tiles[x][y].duplicate()
    
    # Note: Units would need to be loaded separately and added to the map
    return map
