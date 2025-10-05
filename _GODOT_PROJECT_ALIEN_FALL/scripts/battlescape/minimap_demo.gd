extends Control

# MinimapDemo - Demonstrates all enhanced minimap features
# This scene shows off the new minimap capabilities

@onready var minimap: Control = $Minimap
@onready var demo_unit: Control = $DemoUnit

var demo_units = []
var current_style = 0
var styles = ["classic", "modern", "dark"]

func _ready():
    """Initialize the demo"""
    print("Minimap Demo Ready!")
    print("Use the control buttons to test different minimap features")

    # Set up some initial demo units
    _create_demo_units()

    # Connect minimap signals
    minimap.connect("unit_selected", Callable(self, "_on_unit_selected"))
    minimap.connect("camera_focus_unit", Callable(self, "_on_camera_focus_unit"))
    minimap.connect("minimap_clicked", Callable(self, "_on_minimap_clicked"))

func _create_demo_units():
    """Create some demo units for testing"""
    for i in range(5):
        var unit = {
            "id": "demo_unit_" + str(i),
            "position": Vector2(randf_range(100, 900), randf_range(100, 900)),
            "faction": "player" if i < 3 else "enemy",
            "unit_class": ["sniper", "heavy", "scout", "rifleman", "medic"][i % 5],
            "stats": {
                "health": randi_range(50, 100),
                "max_health": 100
            }
        }
        demo_units.append(unit)

        # Add to minimap
        minimap.add_unit(unit, unit.position)

func _on_add_unit_pressed():
    """Add a new random unit"""
    var unit = {
        "id": "new_unit_" + str(demo_units.size()),
        "position": Vector2(randf_range(100, 900), randf_range(100, 900)),
        "faction": "player" if randf() > 0.5 else "enemy",
        "unit_class": ["sniper", "heavy", "scout", "rifleman", "medic"][randi() % 5],
        "stats": {
            "health": randi_range(50, 100),
            "max_health": 100
        }
    }
    demo_units.append(unit)
    minimap.add_unit(unit, unit.position)

    print("Added new unit: ", unit.id, " at position ", unit.position)

func _on_remove_unit_pressed():
    """Remove a random unit"""
    if demo_units.is_empty():
        print("No units to remove")
        return

    var unit_to_remove = demo_units[randi() % demo_units.size()]
    demo_units.erase(unit_to_remove)
    minimap.remove_unit(unit_to_remove)

    print("Removed unit: ", unit_to_remove.id)

func _on_move_units_pressed():
    """Move all units to new random positions"""
    for unit in demo_units:
        var new_position = Vector2(randf_range(100, 900), randf_range(100, 900))
        unit.position = new_position
        minimap.update_unit_position(unit, new_position)

    print("Moved all units to new positions")

func _on_toggle_fog_pressed():
    """Toggle fog of war"""
    var current_state = minimap.show_fog_of_war
    minimap.set_fog_of_war_enabled(!current_state)
    print("Fog of war: ", "ENABLED" if !current_state else "DISABLED")

func _on_add_objective_pressed():
    """Add a random objective marker"""
    var position = Vector2(randf_range(200, 800), randf_range(200, 800))
    var objective_types = ["primary", "secondary", "extraction", "defend"]
    var objective_type = objective_types[randi() % objective_types.size()]

    minimap.add_objective_marker(position, objective_type)
    print("Added ", objective_type, " objective at ", position)

func _on_show_threat_pressed():
    """Show threat zones"""
    var threat_positions = []
    var threat_levels = []

    for i in range(3):
        threat_positions.append(Vector2(randf_range(300, 700), randf_range(300, 700)))
        threat_levels.append(randi_range(1, 3))

    minimap.show_threat_zones(threat_positions, threat_levels)
    print("Added threat zones at ", threat_positions.size(), " locations")

func _on_flash_area_pressed():
    """Flash a random area"""
    var center = Vector2(randf_range(300, 700), randf_range(300, 700))
    var colors = [Color.WHITE, Color.RED, Color.YELLOW, Color.CYAN]
    var color = colors[randi() % colors.size()]

    minimap.flash_area(center, 100.0, color, 0.8)
    print("Flashed area at ", center, " with color ", color)

func _on_ping_effect_pressed():
    """Create a ping effect"""
    var position = Vector2(randf_range(200, 800), randf_range(200, 800))
    var colors = [Color.WHITE, Color.RED, Color.GREEN, Color.BLUE]
    var color = colors[randi() % colors.size()]

    minimap.create_ping_effect(position, color)
    print("Created ping effect at ", position)

func _on_highlight_path_pressed():
    """Highlight a random path"""
    var path = []
    var start_pos = Vector2(randf_range(200, 800), randf_range(200, 800))

    # Create a winding path
    for i in range(5):
        var next_pos = start_pos + Vector2(randf_range(-100, 100), randf_range(-100, 100))
        path.append(next_pos)
        start_pos = next_pos

    var colors = [Color.CYAN, Color.YELLOW, Color.MAGENTA]
    var color = colors[randi() % colors.size()]

    minimap.highlight_path(path, color, 5.0)
    print("Highlighted path with ", path.size(), " points")

func _on_shake_minimap_pressed():
    """Shake the minimap"""
    minimap.shake(8.0, 0.8)
    print("Shaking minimap")

func _on_change_style_pressed():
    """Change minimap style"""
    current_style = (current_style + 1) % styles.size()
    var style = styles[current_style]
    minimap.set_minimap_style(style)
    print("Changed minimap style to: ", style)

func _on_toggle_legend_pressed():
    """Toggle minimap legend"""
    var current_visible = $Minimap/Legend.visible
    minimap.toggle_legend(!current_visible)
    print("Legend: ", "SHOWN" if !current_visible else "HIDDEN")

func _on_unit_selected(unit):
    """Handle unit selection from minimap"""
    print("Unit selected from minimap: ", unit.id)
    minimap.center_on_unit(unit)

func _on_camera_focus_unit(unit):
    """Handle camera focus request"""
    print("Camera focus requested for unit: ", unit.id)
    # In a real game, this would move the main camera

func _on_minimap_clicked(position):
    """Handle minimap click"""
    print("Minimap clicked at world position: ", position)

    # Create a temporary marker
    minimap.add_area_marker(position, 20.0, Color.YELLOW, "Click!")

func _input(event):
    """Handle global input"""
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_SPACE:
                # Quick demo of multiple effects
                _quick_demo()
            KEY_R:
                # Reset demo
                _reset_demo()

func _quick_demo():
    """Quick demonstration of multiple features"""
    print("Starting quick demo...")

    # Add some objectives
    for i in range(3):
        var pos = Vector2(randf_range(200, 800), randf_range(200, 800))
        minimap.add_objective_marker(pos, "primary")

    # Flash some areas
    for i in range(2):
        var pos = Vector2(randf_range(300, 700), randf_range(300, 700))
        minimap.flash_area(pos, 80.0, Color.CYAN, 1.0)

    # Shake minimap
    minimap.shake(5.0, 0.6)

    print("Quick demo complete!")

func _reset_demo():
    """Reset the demo to initial state"""
    print("Resetting demo...")

    # Clear all units
    for unit in demo_units:
        minimap.remove_unit(unit)
    demo_units.clear()

    # Recreate demo units
    _create_demo_units()

    # Reset style
    current_style = 0
    minimap.set_minimap_style(styles[0])

    # Reset fog
    minimap.set_fog_of_war_enabled(true)

    print("Demo reset complete!")

func _process(delta):
    """Update demo information"""
    # Update tactical info periodically
    if Engine.get_frames_drawn() % 300 == 0:  # Every 5 seconds at 60 FPS
        var turn = randi_range(1, 20)
        var hour = randi_range(0, 23)
        var minute = randi_range(0, 59)
        var time_string = "%02d:%02d" % [hour, minute]

        minimap.update_tactical_info(turn, time_string)
