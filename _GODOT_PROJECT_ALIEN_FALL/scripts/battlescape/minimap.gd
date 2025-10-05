extends Control
class_name Minimap

# Minimap - Tactical battlefield overview
# Shows unit positions, terrain features, and tactical information

@onready var viewport_texture: TextureRect = $ViewportTexture
@onready var unit_icons: Control = $UnitIcons
@onready var terrain_overlay: Control = $TerrainOverlay

var battlescape_manager: BattlescapeManager = null
var minimap_size: Vector2 = Vector2(200, 200)
var world_size: Vector2 = Vector2(20, 20)  # Battlescape dimensions
var zoom_level: float = 1.0

var unit_icon_scene = preload("res://scenes/minimap_unit_icon.tscn")
var unit_icons_dict = {}  # unit_id -> icon node

signal minimap_clicked(position: Vector2)

func _ready():
    print("Minimap initialized")
    _setup_minimap()
    _connect_signals()

func _setup_minimap():
    # Set up the minimap viewport and texture
    if viewport_texture:
        viewport_texture.custom_minimum_size = minimap_size

    # Create a viewport for rendering the minimap
    var minimap_viewport = SubViewport.new()
    minimap_viewport.size = minimap_size
    minimap_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

    # Create a camera for the minimap
    var minimap_camera = Camera2D.new()
    minimap_camera.zoom = Vector2(zoom_level, zoom_level)
    minimap_viewport.add_child(minimap_camera)

    # Add the viewport as a texture
    if viewport_texture:
        viewport_texture.texture = minimap_viewport.get_texture()

func _connect_signals():
    # Connect to battlescape manager signals
    if battlescape_manager:
        battlescape_manager.connect("unit_selected", Callable(self, "_on_unit_selected"))
        battlescape_manager.connect("unit_moved", Callable(self, "_on_unit_moved"))

func set_battlescape_manager(manager: BattlescapeManager):
    battlescape_manager = manager
    _connect_signals()
    _update_minimap()

func _update_minimap():
    if not battlescape_manager:
        return

    # Clear existing unit icons
    _clear_unit_icons()

    # Add unit icons for all units
    var all_units = battlescape_manager.player_units + battlescape_manager.enemy_units
    for unit in all_units:
        _add_unit_icon(unit)

    # Update terrain overlay
    _update_terrain_overlay()

func _clear_unit_icons():
    for icon in unit_icons_dict.values():
        if icon:
            icon.queue_free()
    unit_icons_dict.clear()

func _add_unit_icon(unit: Unit):
    if not unit_icon_scene:
        return

    var icon = unit_icon_scene.instantiate()
    unit_icons.add_child(icon)

    # Position the icon based on unit position
    var icon_pos = _world_to_minimap_position(unit.position)
    icon.position = icon_pos

    # Set icon properties based on unit type
    _configure_unit_icon(icon, unit)

    # Store reference
    unit_icons_dict[unit.unit_id] = icon

func _configure_unit_icon(icon: Control, unit: Unit):
    # Configure the icon based on unit properties
    if icon.has_method("set_unit"):
        icon.set_unit(unit)

    # Set color based on faction
    var icon_color = Color.BLUE if unit in battlescape_manager.player_units else Color.RED
    if icon.has_method("set_color"):
        icon.set_color(icon_color)

func _world_to_minimap_position(world_pos: Vector2) -> Vector2:
    # Convert world coordinates to minimap coordinates
    var normalized_pos = world_pos / world_size
    return normalized_pos * minimap_size

func _minimap_to_world_position(minimap_pos: Vector2) -> Vector2:
    # Convert minimap coordinates to world coordinates
    var normalized_pos = minimap_pos / minimap_size
    return normalized_pos * world_size

func _update_terrain_overlay():
    # Update terrain features on the minimap
    if not battlescape_manager or not terrain_overlay:
        return

    # Clear existing terrain markers
    for child in terrain_overlay.get_children():
        child.queue_free()

    # Add terrain features (walls, destructible objects, etc.)
    var map_data = battlescape_manager.get_map_data()
    if map_data.has("tiles"):
        for tile in map_data.tiles:
            if tile.terrain in ["wall", "crate", "debris"]:
                _add_terrain_marker(tile.position, tile.terrain)

func _add_terrain_marker(position: Vector2, terrain_type: String):
    var marker = ColorRect.new()
    marker.size = Vector2(4, 4)

    # Set color based on terrain type
    match terrain_type:
        "wall":
            marker.color = Color.DARK_GRAY
        "crate":
            marker.color = Color.SADDLE_BROWN
        "debris":
            marker.color = Color.DIM_GRAY

    marker.position = _world_to_minimap_position(position)
    terrain_overlay.add_child(marker)

func _on_unit_selected(unit: Unit):
    # Highlight selected unit on minimap
    if unit_icons_dict.has(unit.unit_id):
        var icon = unit_icons_dict[unit.unit_id]
        if icon.has_method("set_selected"):
            icon.set_selected(true)

func _on_unit_moved(unit: Unit, from_pos: Vector2, to_pos: Vector2):
    # Update unit position on minimap
    if unit_icons_dict.has(unit.unit_id):
        var icon = unit_icons_dict[unit.unit_id]
        var new_pos = _world_to_minimap_position(to_pos)
        icon.position = new_pos

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        var local_pos = get_local_mouse_position()
        if _is_position_on_minimap(local_pos):
            var world_pos = _minimap_to_world_position(local_pos)
            emit_signal("minimap_clicked", world_pos)

func _is_position_on_minimap(position: Vector2) -> bool:
    return position.x >= 0 and position.x <= minimap_size.x and \
           position.y >= 0 and position.y <= minimap_size.y

func set_zoom(zoom: float):
    zoom_level = clamp(zoom, 0.5, 2.0)
    if viewport_texture and viewport_texture.texture:
        # Update camera zoom if we have a viewport
        pass

func center_on_position(position: Vector2):
    # Center the minimap view on a specific position
    var minimap_center = _world_to_minimap_position(position)
    # Adjust viewport to center on this position
    pass

func highlight_area(center: Vector2, radius: float):
    # Highlight an area on the minimap (e.g., explosion radius, ability range)
    var highlight = ColorRect.new()
    highlight.size = Vector2(radius * 2, radius * 2) / (world_size / minimap_size)
    highlight.position = _world_to_minimap_position(center) - highlight.size / 2
    highlight.color = Color.YELLOW
    highlight.modulate.a = 0.3

    # Add to a temporary highlights layer
    var highlights_layer = $Highlights
    if not highlights_layer:
        highlights_layer = Control.new()
        highlights_layer.name = "Highlights"
        add_child(highlights_layer)

    highlights_layer.add_child(highlight)

    # Auto-remove after a few seconds
    await get_tree().create_timer(2.0).timeout
    highlight.queue_free()

func show_unit_paths(paths: Array):
    # Show movement paths on the minimap
    var path_layer = $Paths
    if not path_layer:
        path_layer = Control.new()
        path_layer.name = "Paths"
        add_child(path_layer)

    # Clear existing paths
    for child in path_layer.get_children():
        child.queue_free()

    # Draw new paths
    for path in paths:
        var line = Line2D.new()
        line.width = 2
        line.default_color = Color.GREEN

        for point in path:
            line.add_point(_world_to_minimap_position(point))

        path_layer.add_child(line)

func clear_paths():
    # Clear movement path indicators
    var path_layer = $Paths
    if path_layer:
        for child in path_layer.get_children():
            child.queue_free()
