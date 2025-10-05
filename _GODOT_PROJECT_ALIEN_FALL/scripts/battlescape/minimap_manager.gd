extends Control
class_name MinimapManager

# MinimapManager - Manages the minimap display with enhanced features
# Handles unit icons, fog of war, camera controls, and tactical overlays

signal unit_selected(unit)
signal camera_focus_unit(unit)
signal minimap_clicked(position)

@onready var viewport: SubViewport = $SubViewport
@onready var camera: Camera2D = $SubViewport/Camera2D
@onready var unit_container: Control = $UnitContainer
@onready var fog_container: Control = $FogContainer
@onready var overlay_container: Control = $OverlayContainer

# Configuration
var minimap_scale: float = 0.1
var show_fog_of_war: bool = true
var show_unit_paths: bool = true
var group_nearby_units: bool = true
var unit_group_distance: float = 50.0

# Data
var unit_icons: Dictionary = {}  # Unit -> Icon mapping
var fog_tiles: Dictionary = {}   # Position -> Fog tile mapping
var explored_areas: Array = []   # Array of explored Rect2 areas
var main_camera: Camera2D = null

func _ready():
    """Initialize the minimap manager"""
    _setup_minimap()
    _connect_signals()

func _setup_minimap():
    """Set up the minimap viewport and camera"""
    if viewport:
        viewport.size = size

    if camera:
        camera.zoom = Vector2(minimap_scale, minimap_scale)
        camera.position = Vector2.ZERO

func _connect_signals():
    """Connect to game systems"""
    # Connect to battle manager for unit updates
    var battle_manager = get_node("/root/BattleService")
    if battle_manager:
        battle_manager.connect("unit_moved", Callable(self, "_on_unit_moved"))
        battle_manager.connect("unit_damaged", Callable(self, "_on_unit_damaged"))
        battle_manager.connect("unit_added", Callable(self, "_on_unit_added"))
        battle_manager.connect("unit_removed", Callable(self, "_on_unit_removed"))

func set_main_camera(camera_node: Camera2D):
    """Set the main game camera for synchronization"""
    main_camera = camera_node
    if main_camera:
        main_camera.connect("position_changed", Callable(self, "_on_main_camera_moved"))

func add_unit(unit: Unit, world_position: Vector2):
    """Add a unit to the minimap"""
    if unit_icons.has(unit):
        return  # Unit already on minimap

    var icon_scene = preload("res://scenes/minimap_unit_icon.tscn")
    var icon = icon_scene.instantiate()

    icon.set_unit(unit)
    icon.connect("unit_selected", Callable(self, "_on_unit_icon_selected"))
    icon.connect("camera_focus_unit", Callable(self, "_on_unit_icon_camera_focus"))

    unit_container.add_child(icon)
    unit_icons[unit] = icon

    _update_unit_position(unit, world_position)
    _update_unit_fog_state(unit)

func remove_unit(unit: Unit):
    """Remove a unit from the minimap"""
    if unit_icons.has(unit):
        var icon = unit_icons[unit]
        unit_container.remove_child(icon)
        icon.queue_free()
        unit_icons.erase(unit)

func update_unit_position(unit: Unit, world_position: Vector2):
    """Update a unit's position on the minimap"""
    _update_unit_position(unit, world_position)

func _update_unit_position(unit: Unit, world_position: Vector2):
    """Internal method to update unit position"""
    if not unit_icons.has(unit):
        return

    var icon = unit_icons[unit]
    var minimap_position = world_position * minimap_scale

    # Center the icon on the minimap
    minimap_position -= icon.size / 2

    icon.update_position(world_position, minimap_scale)

func _on_unit_moved(unit: Unit, new_position: Vector2):
    """Handle unit movement"""
    update_unit_position(unit, new_position)

    if show_unit_paths and unit_icons.has(unit):
        var icon = unit_icons[unit]
        # Update path visualization
        icon.set_movement_path([new_position])

func _on_unit_damaged(unit: Unit, damage: int, new_health: int):
    """Handle unit taking damage"""
    if unit_icons.has(unit):
        var icon = unit_icons[unit]
        icon.highlight_temporarily(0.5)

        # Show health bar if damaged
        if new_health < unit.stats.max_health:
            icon.show_health_bar(true)

func _on_unit_added(unit: Unit, position: Vector2):
    """Handle new unit added to battle"""
    add_unit(unit, position)

func _on_unit_removed(unit: Unit):
    """Handle unit removed from battle"""
    remove_unit(unit)

func _on_main_camera_moved():
    """Update minimap camera to follow main camera"""
    if main_camera and camera:
        camera.position = main_camera.position * minimap_scale

func _on_unit_icon_selected(unit: Unit):
    """Handle unit selection from minimap"""
    emit_signal("unit_selected", unit)

func _on_unit_icon_camera_focus(unit: Unit):
    """Handle camera focus request from minimap"""
    emit_signal("camera_focus_unit", unit)

func _update_unit_fog_state(unit: Unit):
    """Update fog of war state for a unit"""
    if not show_fog_of_war or not unit_icons.has(unit):
        return

    var icon = unit_icons[unit]
    var is_visible = _is_unit_visible(unit)

    icon.set_fog_state(not is_visible)

func _is_unit_visible(unit: Unit) -> bool:
    """Check if a unit is visible (not in fog of war)"""
    # This would integrate with the game's line of sight system
    # For now, return true for all units
    return true

func reveal_area(center: Vector2, radius: float):
    """Reveal an area on the minimap (remove fog of war)"""
    if not show_fog_of_war:
        return

    var reveal_rect = Rect2(center - Vector2(radius, radius), Vector2(radius * 2, radius * 2))
    explored_areas.append(reveal_rect)

    # Update fog for all units in the area
    for unit in unit_icons.keys():
        if reveal_rect.has_point(unit.position):
            _update_unit_fog_state(unit)

func set_fog_of_war_enabled(enabled: bool):
    """Enable or disable fog of war"""
    show_fog_of_war = enabled

    # Update all units
    for unit in unit_icons.keys():
        _update_unit_fog_state(unit)

func set_unit_paths_visible(visible: bool):
    """Show or hide unit movement paths"""
    show_unit_paths = visible

    # Update all unit icons
    for icon in unit_icons.values():
        icon.path_indicator.visible = visible and not icon.movement_path.is_empty()

func center_on_unit(unit: Unit):
    """Center the minimap camera on a specific unit"""
    if camera and unit_icons.has(unit):
        var icon = unit_icons[unit]
        camera.position = icon.position

func zoom_in():
    """Zoom in the minimap"""
    if camera:
        camera.zoom *= 0.8
        camera.zoom = camera.zoom.clamp(Vector2(0.05, 0.05), Vector2(0.5, 0.5))

func zoom_out():
    """Zoom out the minimap"""
    if camera:
        camera.zoom *= 1.25
        camera.zoom = camera.zoom.clamp(Vector2(0.05, 0.05), Vector2(0.5, 0.5))

func _gui_input(event):
    """Handle minimap input"""
    if event is InputEventMouseButton and event.pressed:
        match event.button_index:
            MOUSE_BUTTON_LEFT:
                _on_minimap_left_click(event.position)
            MOUSE_BUTTON_RIGHT:
                _on_minimap_right_click(event.position)

func _on_minimap_left_click(position: Vector2):
    """Handle left click on minimap"""
    var world_position = position / minimap_scale
    emit_signal("minimap_clicked", world_position)

func _on_minimap_right_click(position: Vector2):
    """Handle right click on minimap - could be used for camera movement"""
    var world_position = position / minimap_scale

    if main_camera:
        # Move main camera to clicked position
        var tween = create_tween()
        tween.set_ease(Tween.EASE_OUT)
        tween.set_trans(Tween.TRANS_SINE)
        tween.tween_property(main_camera, "position", world_position, 0.5)

func get_units_in_area(center: Vector2, radius: float) -> Array:
    """Get all units within a radius of a point"""
    var units_in_area = []

    for unit in unit_icons.keys():
        if unit.position.distance_to(center) <= radius:
            units_in_area.append(unit)

    return units_in_area

func highlight_units(units: Array, duration: float = 2.0):
    """Highlight multiple units temporarily"""
    for unit in units:
        if unit_icons.has(unit):
            unit_icons[unit].highlight_temporarily(duration)

func _process(delta):
    """Update minimap every frame"""
    # Update camera position to follow main camera
    if main_camera and camera:
        var target_position = main_camera.position * minimap_scale
        camera.position = camera.position.lerp(target_position, delta * 2.0)

    # Update unit grouping if enabled
    if group_nearby_units:
        _update_unit_grouping()

func _update_unit_grouping():
    """Group nearby units to reduce clutter"""
    var processed_units = []

    for unit in unit_icons.keys():
        if processed_units.has(unit):
            continue

        var nearby_units = []
        var center_position = unit.position

        # Find nearby units
        for other_unit in unit_icons.keys():
            if other_unit != unit and unit.position.distance_to(other_unit.position) <= unit_group_distance:
                nearby_units.append(other_unit)
                processed_units.append(other_unit)

        if nearby_units.size() >= 2:
            # Create a group indicator
            _create_unit_group(center_position, [unit] + nearby_units)

        processed_units.append(unit)

func _create_unit_group(center: Vector2, units: Array):
    """Create a visual group indicator for nearby units"""
    # This would create a special group icon
    # For now, just highlight the units
    for unit in units:
        if unit_icons.has(unit):
            unit_icons[unit].pulse_animation()

func _on_zoom_in_pressed():
    """Handle zoom in button press"""
    zoom_in()

func _on_zoom_out_pressed():
    """Handle zoom out button press"""
    zoom_out()

func update_tactical_info(turn: int, time_string: String):
    """Update tactical information display"""
    $TacticalInfo/TurnLabel.text = "Turn: " + str(turn)
    $TacticalInfo/TimeLabel.text = time_string

func add_objective_marker(position: Vector2, objective_type: String = "primary"):
    """Add an objective marker to the minimap"""
    var marker_color = Color.YELLOW
    match objective_type:
        "secondary":
            marker_color = Color.CYAN
        "extraction":
            marker_color = Color.GREEN
        "defend":
            marker_color = Color.ORANGE

    add_tactical_overlay("objective", position, {"color": marker_color})

func show_threat_zones(threat_positions: Array, threat_levels: Array):
    """Show threat zones on the minimap"""
    for i in range(threat_positions.size()):
        var position = threat_positions[i]
        var level = threat_levels[i] if i < threat_levels.size() else 1
        add_tactical_overlay("threat", position, {"level": level})

func show_cover_positions(cover_positions: Array):
    """Show cover positions on the minimap"""
    for position in cover_positions:
        add_tactical_overlay("cover", position, {})

func enable_grouping(enabled: bool):
    """Enable or disable unit grouping"""
    group_nearby_units = enabled

func set_group_distance(distance: float):
    """Set the distance for unit grouping"""
    unit_group_distance = distance

func get_minimap_bounds() -> Rect2:
    """Get the world bounds visible on the minimap"""
    if camera:
        var camera_size = viewport.size / camera.zoom
        return Rect2(camera.position - camera_size / 2, camera_size)
    return Rect2()

func is_position_visible(world_position: Vector2) -> bool:
    """Check if a world position is visible on the minimap"""
    var bounds = get_minimap_bounds()
    return bounds.has_point(world_position)

func get_units_in_viewport() -> Array:
    """Get all units currently visible in the minimap viewport"""
    var visible_units = []
    var bounds = get_minimap_bounds()

    for unit in unit_icons.keys():
        if bounds.has_point(unit.position):
            visible_units.append(unit)

    return visible_units

func flash_area(center: Vector2, radius: float, color: Color = Color.WHITE, duration: float = 0.5):
    """Create a flashing effect in an area"""
    var flash_overlay = ColorRect.new()
    flash_overlay.size = Vector2(radius * 2 * minimap_scale, radius * 2 * minimap_scale)
    flash_overlay.color = color
    flash_overlay.modulate.a = 0.0
    flash_overlay.position = (center * minimap_scale) - flash_overlay.size / 2

    overlay_container.add_child(flash_overlay)

    # Animate the flash
    var tween = create_tween()
    tween.tween_property(flash_overlay, "modulate:a", 0.5, duration / 2)
    tween.tween_property(flash_overlay, "modulate:a", 0.0, duration / 2)
    tween.tween_callback(func(): flash_overlay.queue_free())

func create_ping_effect(position: Vector2, color: Color = Color.WHITE):
    """Create a ping effect at a position"""
    var ping = ColorRect.new()
    ping.size = Vector2(4, 4)
    ping.color = color
    ping.position = position * minimap_scale - ping.size / 2

    overlay_container.add_child(ping)

    # Animate the ping
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(ping, "scale", Vector2(3, 3), 1.0)
    tween.tween_property(ping, "modulate:a", 0.0, 1.0)
    tween.tween_callback(func(): ping.queue_free())

func set_minimap_style(style: String):
    """Set the visual style of the minimap"""
    match style:
        "classic":
            $Background.modulate = Color(0.1, 0.2, 0.1, 1)
        "modern":
            $Background.modulate = Color(0.05, 0.05, 0.1, 1)
        "dark":
            $Background.modulate = Color(0.02, 0.02, 0.02, 1)

func toggle_legend(visible: bool):
    """Show or hide the minimap legend"""
    $Legend.visible = visible

func toggle_zoom_controls(visible: bool):
    """Show or hide zoom controls"""
    $ZoomControls.visible = visible

func toggle_tactical_info(visible: bool):
    """Show or hide tactical information"""
    $TacticalInfo.visible = visible

func export_minimap_image() -> Image:
    """Export the current minimap as an image"""
    if viewport:
        return viewport.get_texture().get_image()
    return null

func get_unit_at_position(minimap_position: Vector2) -> Unit:
    """Get the unit at a specific minimap position"""
    for unit in unit_icons.keys():
        var icon = unit_icons[unit]
        if icon.get_rect().has_point(minimap_position):
            return unit
    return null

func highlight_path(path: Array, color: Color = Color.CYAN, duration: float = 3.0):
    """Highlight a path on the minimap"""
    var path_line = Line2D.new()
    path_line.width = 3.0
    path_line.default_color = color

    var points = PackedVector2Array()
    for point in path:
        points.append(point * minimap_scale)

    path_line.points = points
    overlay_container.add_child(path_line)

    # Auto-remove after duration
    get_tree().create_timer(duration).timeout.connect(func(): path_line.queue_free())

func add_area_marker(center: Vector2, radius: float, color: Color, label: String = ""):
    """Add an area marker with optional label"""
    var marker = ColorRect.new()
    marker.size = Vector2(radius * 2 * minimap_scale, radius * 2 * minimap_scale)
    marker.color = color
    marker.modulate.a = 0.3
    marker.position = (center * minimap_scale) - marker.size / 2

    overlay_container.add_child(marker)

    if label:
        var label_node = Label.new()
        label_node.text = label
        label_node.position = marker.position + Vector2(0, -15)
        label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        overlay_container.add_child(label_node)

        # Remove both after some time
        get_tree().create_timer(10.0).timeout.connect(func():
            marker.queue_free()
            label_node.queue_free()
        )
    else:
        # Remove marker after some time
        get_tree().create_timer(10.0).timeout.connect(func(): marker.queue_free())

func set_opacity(opacity: float):
    """Set the overall opacity of the minimap"""
    modulate.a = clamp(opacity, 0.0, 1.0)

func animate_to_position(target_position: Vector2, duration: float = 1.0):
    """Smoothly animate the minimap camera to a position"""
    if camera:
        var tween = create_tween()
        tween.set_ease(Tween.EASE_OUT)
        tween.set_trans(Tween.TRANS_SINE)
        tween.tween_property(camera, "position", target_position * minimap_scale, duration)

func shake(intensity: float = 5.0, duration: float = 0.5):
    """Shake the minimap for emphasis"""
    var original_position = position
    var tween = create_tween()
    tween.set_loops(int(duration / 0.05))

    for i in range(int(duration / 0.05)):
        var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
        tween.tween_property(self, "position", original_position + offset, 0.025)
        tween.tween_property(self, "position", original_position, 0.025)

func pulse_border(color: Color = Color.WHITE, duration: float = 1.0):
    """Create a pulsing border effect"""
    var border = Panel.new()
    border.size = size
    border.modulate = color
    border.modulate.a = 0.0

    add_child(border)

    var tween = create_tween()
    tween.tween_property(border, "modulate:a", 0.8, duration / 2)
    tween.tween_property(border, "modulate:a", 0.0, duration / 2)
    tween.tween_callback(func(): border.queue_free())
