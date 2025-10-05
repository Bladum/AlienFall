extends Control
class_name MinimapUnitIcon

# MinimapUnitIcon - Enhanced visual representation of units on the minimap
# Shows unit position, health, selection state, paths, and fog of war

@onready var icon: TextureRect = $Icon
@onready var selection_indicator: TextureRect = $SelectionIndicator
@onready var health_bar: Control = $HealthBar
@onready var health_fill: ColorRect = $HealthFill
@onready var path_indicator: Line2D = $PathIndicator
@onready var fog_overlay: ColorRect = $FogOverlay
@onready var particle_effect: CPUParticles2D = $ParticleEffect

var unit: Unit = null
var is_selected: bool = false
var is_in_fog: bool = false
var movement_path: Array = []
var tween: Tween = null

func _ready():
    # Initially hide optional elements
    health_bar.visible = false
    path_indicator.visible = false
    fog_overlay.visible = false

    # Set up initial appearance
    _setup_initial_appearance()

func _setup_initial_appearance():
    """Set up the initial visual appearance with smooth animations"""
    if tween:
        tween.kill()

    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)

    # Fade in animation
    modulate.a = 0.0
    tween.tween_property(self, "modulate:a", 1.0, 0.3)

    # Slight scale animation for "pop" effect
    scale = Vector2(0.8, 0.8)
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)

func set_unit(new_unit: Unit):
    unit = new_unit
    _update_appearance()

func set_color(color: Color):
    """Set the icon color with smooth transition"""
    if icon:
        if tween:
            tween.kill()
        tween = create_tween()
        tween.set_ease(Tween.EASE_OUT)
        tween.set_trans(Tween.TRANS_SINE)
        tween.tween_property(icon, "modulate", color, 0.2)

func set_selected(selected: bool):
    """Set selection state with smooth animation"""
    is_selected = selected

    if selection_indicator:
        if selected:
            selection_indicator.visible = true
            # Animate selection ring
            if tween:
                tween.kill()
            tween = create_tween()
            tween.set_loops()
            tween.tween_property(selection_indicator, "modulate:a", 0.3, 0.5)
            tween.tween_property(selection_indicator, "modulate:a", 1.0, 0.5)
        else:
            # Fade out selection
            if tween:
                tween.kill()
            tween = create_tween()
            tween.set_ease(Tween.EASE_OUT)
            tween.set_trans(Tween.TRANS_SINE)
            tween.tween_property(selection_indicator, "modulate:a", 0.0, 0.3)
            tween.tween_callback(func(): selection_indicator.visible = false)

func set_fog_state(in_fog: bool):
    """Set fog of war state"""
    is_in_fog = in_fog
    if fog_overlay:
        fog_overlay.visible = in_fog

func set_movement_path(path: Array):
    """Set and display movement path"""
    movement_path = path
    _update_path_display()

func _update_path_display():
    """Update the visual path indicator"""
    if not path_indicator:
        return

    if movement_path.size() > 1:
        path_indicator.visible = true
        var points = PackedVector2Array()

        # Convert world positions to local minimap positions
        for i in range(movement_path.size()):
            var point = movement_path[i]
            # This would need to be converted from world to minimap coordinates
            # For now, just use relative positions
            points.append(Vector2(i * 8, 0))

        path_indicator.points = points
    else:
        path_indicator.visible = false

func _update_appearance():
    if not unit:
        return

    # Update size based on unit type with smooth scaling
    var target_size = Vector2(12, 12)
    match unit.unit_class:
        "sniper":
            target_size = Vector2(10, 10)
        "heavy":
            target_size = Vector2(18, 18)
        "scout":
            target_size = Vector2(8, 8)
        _:
            target_size = Vector2(12, 12)

    if tween:
        tween.kill()
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "custom_minimum_size", target_size, 0.3)

    # Update health bar if unit is damaged
    if unit.stats and unit.stats.health < unit.stats.max_health:
        _update_health_bar()

func _update_health_bar():
    if not health_bar or not health_fill or not unit or not unit.stats:
        return

    health_bar.visible = true

    var health_percent = float(unit.stats.health) / float(unit.stats.max_health)

    # Animate health bar changes
    if tween:
        tween.kill()
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_SINE)

    var target_width = 24 * health_percent
    tween.tween_property(health_fill, "size:x", target_width, 0.5)

    # Color transition based on health percentage
    var target_color = Color.GREEN
    if health_percent > 0.6:
        target_color = Color.GREEN
    elif health_percent > 0.3:
        target_color = Color.YELLOW
    else:
        target_color = Color.RED

    tween.parallel().tween_property(health_fill, "color", target_color, 0.5)

func show_health_bar(show: bool = true):
    """Show or hide health bar with animation"""
    if health_bar:
        if tween:
            tween.kill()
        tween = create_tween()
        tween.set_ease(Tween.EASE_OUT)
        tween.set_trans(Tween.TRANS_SINE)

        if show:
            health_bar.visible = true
            health_bar.modulate.a = 0.0
            tween.tween_property(health_bar, "modulate:a", 1.0, 0.3)
        else:
            tween.tween_property(health_bar, "modulate:a", 0.0, 0.3)
            tween.tween_callback(func(): health_bar.visible = false)

func highlight_temporarily(duration: float = 1.0):
    """Temporarily highlight the unit with particle effect"""
    if particle_effect:
        particle_effect.emitting = true

    # Brighten the icon temporarily
    var original_modulate = icon.modulate
    if tween:
        tween.kill()
    tween = create_tween()

    tween.tween_property(icon, "modulate", Color.WHITE, 0.1)
    tween.tween_interval(duration - 0.2)
    tween.tween_property(icon, "modulate", original_modulate, 0.1)

func pulse_animation():
    """Create a pulsing animation for special states"""
    if tween:
        tween.kill()

    tween = create_tween()
    tween.set_loops()

    tween.tween_property(icon, "modulate:a", 0.3, 0.5)
    tween.tween_property(icon, "modulate:a", 1.0, 0.5)

func stop_pulse():
    """Stop pulsing animation"""
    if tween:
        tween.kill()

    tween = create_tween()
    tween.tween_property(icon, "modulate:a", 1.0, 0.2)

func set_status_effect(effect_type: String):
    """Add visual indicators for status effects with animations"""
    if tween:
        tween.kill()
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BOUNCE)

    match effect_type:
        "stunned":
            tween.tween_property(icon, "modulate", Color.GRAY, 0.3)
            tween.tween_property(icon, "rotation", 0.1, 0.2)
        "poisoned":
            tween.tween_property(icon, "modulate", Color.PURPLE, 0.3)
        "on_fire":
            tween.tween_property(icon, "modulate", Color.ORANGE, 0.3)
            # Add fire particle effect
            if particle_effect:
                particle_effect.color = Color.ORANGE
                particle_effect.emitting = true
        "frozen":
            tween.tween_property(icon, "modulate", Color.CYAN, 0.3)
        "berserk":
            tween.tween_property(icon, "modulate", Color.RED, 0.3)
            pulse_animation()
        _:
            # Reset to normal color
            var normal_color = Color.BLUE if _is_player_unit() else Color.RED
            tween.tween_property(icon, "modulate", normal_color, 0.3)

func clear_status_effect():
    """Clear status effect visual with animation"""
    if tween:
        tween.kill()
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_SINE)

    var normal_color = Color.BLUE if _is_player_unit() else Color.RED
    tween.tween_property(icon, "modulate", normal_color, 0.3)
    tween.tween_property(icon, "rotation", 0.0, 0.2)

    # Stop particle effects
    if particle_effect:
        particle_effect.emitting = false

    stop_pulse()

func _is_player_unit() -> bool:
    """Check if this is a player unit (placeholder - would integrate with game state)"""
    # This would be replaced with actual game state integration
    return unit != null and unit.faction == "player"

func play_sound_effect(sound_type: String):
    """Play sound effect for minimap interactions"""
    # This would integrate with the audio system
    match sound_type:
        "select":
            # Play selection sound
            pass
        "move":
            # Play movement sound
            pass
        "damage":
            # Play damage sound
            pass
        "death":
            # Play death sound
            pass

# Input handling for click interactions
func _gui_input(event):
    """Handle mouse input for minimap interactions"""
    if event is InputEventMouseButton and event.pressed:
        match event.button_index:
            MOUSE_BUTTON_LEFT:
                _on_left_click()
            MOUSE_BUTTON_RIGHT:
                _on_right_click()

func _on_left_click():
    """Handle left click - select unit"""
    if unit:
        play_sound_effect("select")
        # Emit signal to select this unit
        get_parent().emit_signal("unit_selected", unit)

func _on_right_click():
    """Handle right click - move camera to unit"""
    if unit:
        play_sound_effect("move")
        # Emit signal to center camera on this unit
        get_parent().emit_signal("camera_focus_unit", unit)

func update_position(world_position: Vector2, minimap_scale: float):
    """Update unit position on minimap with smooth movement"""
    var minimap_position = world_position * minimap_scale

    if tween:
        tween.kill()
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_SINE)
    tween.tween_property(self, "position", minimap_position, 0.2)
