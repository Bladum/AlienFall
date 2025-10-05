extends Control
class_name BattlescapeState

# BattlescapeState - Handles the tactical battlescape screen
# Manages unit selection, movement, combat, and UI updates

@onready var battlescape_manager = $BattlescapeManager
@onready var tile_container = $MapContainer/TileContainer
@onready var turn_label = $SidePanel/TurnInfo/TurnLabel
@onready var active_unit_label = $SidePanel/TurnInfo/ActiveUnitLabel
@onready var time_units_label = $SidePanel/TurnInfo/TimeUnitsLabel
@onready var unit_stats_label = $SidePanel/UnitInfo/UnitStatsLabel
@onready var move_button = $SidePanel/ActionsPanel/MoveButton
@onready var attack_button = $SidePanel/ActionsPanel/AttackButton
@onready var end_turn_button = $SidePanel/ActionsPanel/EndTurnButton
@onready var back_button = $SidePanel/ActionsPanel/BackButton
@onready var status_label = $BottomPanel/StatusLabel
@onready var objective_label = $BottomPanel/ObjectiveLabel

var selected_unit: Unit = null
var selected_position: Vector2 = Vector2(-1, -1)
var tile_size: int = 15
var map_offset: Vector2 = Vector2(0, 0)

var tile_buttons: Array = []
var unit_sprites: Dictionary = {}

func _ready():
    print("BattlescapeState: Initializing...")
    
    # Connect UI signals
    move_button.connect("pressed", Callable(self, "_on_move_pressed"))
    attack_button.connect("pressed", Callable(self, "_on_attack_pressed"))
    end_turn_button.connect("pressed", Callable(self, "_on_end_turn_pressed"))
    back_button.connect("pressed", Callable(self, "_on_back_pressed"))
    
    # Connect battlescape manager signals
    battlescape_manager.connect("battlescape_ready", Callable(self, "_on_battlescape_ready"))
    battlescape_manager.connect("turn_changed", Callable(self, "_on_turn_changed"))
    battlescape_manager.connect("combat_started", Callable(self, "_on_combat_started"))
    battlescape_manager.connect("combat_ended", Callable(self, "_on_combat_ended"))
    battlescape_manager.connect("mission_completed", Callable(self, "_on_mission_completed"))
    
    # Initialize map display
    _initialize_map_display()
    
    # Start a test mission
    _start_test_mission()
    
    print("BattlescapeState: Ready")

func _initialize_map_display():
    print("BattlescapeState: Initializing map display")
    
    var map_data = battlescape_manager.get_map_data()
    var width = map_data.width
    var height = map_data.height
    
    # Create tile buttons
    for x in range(width):
        tile_buttons.append([])
        for y in range(height):
            var button = Button.new()
            button.size = Vector2(tile_size, tile_size)
            button.position = Vector2(x * tile_size, y * tile_size)
            button.connect("pressed", Callable(self, "_on_tile_pressed").bind(Vector2(x, y)))
            
            tile_container.add_child(button)
            tile_buttons[x].append(button)
    
    _update_map_display()

func _update_map_display():
    var map_data = battlescape_manager.get_map_data()
    
    # Update tile appearances
    for x in range(map_data.width):
        for y in range(map_data.height):
            var button = tile_buttons[x][y]
            var tile = map_data.tiles[x][y]
            
            # Set tile color based on terrain
            var color = Color(0.3, 0.3, 0.3)  # Default gray
            match tile.terrain:
                "floor":
                    color = Color(0.4, 0.4, 0.4)
                "wall":
                    color = Color(0.2, 0.2, 0.2)
                "crate":
                    color = Color(0.6, 0.4, 0.2)
                "pillar":
                    color = Color(0.5, 0.5, 0.5)
            
            button.modulate = color
    
    # Update unit positions
    _clear_unit_sprites()
    for unit in map_data.units:
        _create_unit_sprite(unit)

func _clear_unit_sprites():
    for sprite in unit_sprites.values():
        if sprite:
            sprite.queue_free()
    unit_sprites.clear()

func _create_unit_sprite(unit: Unit):
    var sprite = ColorRect.new()
    sprite.size = Vector2(tile_size - 2, tile_size - 2)
    sprite.position = Vector2(unit.position.x * tile_size + 1, unit.position.y * tile_size + 1)
    
    # Color based on faction
    if unit.race == "human":
        sprite.color = Color(0.2, 0.6, 1.0)  # Blue for humans
    else:
        sprite.color = Color(1.0, 0.2, 0.2)  # Red for aliens
    
    tile_container.add_child(sprite)
    unit_sprites[unit] = sprite

func _start_test_mission():
    print("BattlescapeState: Starting test mission")
    
    # Create test units
    var player_unit = Unit.new("player_1", "Soldier")
    player_unit.race = "human"
    player_unit.unit_class = "assault"
    player_unit.stats.tu = 60
    player_unit.stats.health = 35
    
    var enemy_unit = Unit.new("enemy_1", "Alien")
    enemy_unit.race = "sectoid"
    enemy_unit.unit_class = "warrior"
    enemy_unit.stats.tu = 50
    enemy_unit.stats.health = 25
    
    var mission_data = {
        "name": "Test Mission",
        "objective": "Eliminate all enemies",
        "player_units": [player_unit],
        "enemy_units": [enemy_unit]
    }
    
    battlescape_manager.start_mission(mission_data)

func _on_tile_pressed(position: Vector2):
    print("BattlescapeState: Tile pressed at ", position)
    
    selected_position = position
    
    # Check if there's a unit at this position
    var unit = battlescape_manager.battlescape_map.get_unit_at_position(position)
    if unit:
        _select_unit(unit)
    else:
        selected_unit = null
        _update_ui()

func _select_unit(unit: Unit):
    selected_unit = unit
    _update_ui()
    print("BattlescapeState: Selected unit: ", unit.name)

func _on_move_pressed():
    if not selected_unit or not battlescape_manager.turn_manager.is_player_turn():
        return
    
    if selected_position == Vector2(-1, -1):
        status_label.text = "Status: Select a destination tile"
        return
    
    if battlescape_manager.move_unit(selected_unit, selected_position):
        status_label.text = "Status: Unit moved successfully"
        _update_map_display()
        _update_ui()
    else:
        status_label.text = "Status: Cannot move to that position"

func _on_attack_pressed():
    if not selected_unit or not battlescape_manager.turn_manager.is_player_turn():
        return
    
    if selected_position == Vector2(-1, -1):
        status_label.text = "Status: Select a target unit"
        return
    
    var target = battlescape_manager.battlescape_map.get_unit_at_position(selected_position)
    if not target or target.race == selected_unit.race:
        status_label.text = "Status: Invalid target"
        return
    
    if battlescape_manager.attack_unit(selected_unit, target):
        status_label.text = "Status: Attack executed"
        _update_ui()
    else:
        status_label.text = "Status: Cannot attack target"

func _on_end_turn_pressed():
    battlescape_manager.end_turn()
    status_label.text = "Status: Turn ended"

func _on_back_pressed():
    print("BattlescapeState: Back to geoscape requested")
    
    # Return to geoscape
    get_tree().change_scene_to_file("res://scenes/geoscape.tscn")

func _update_ui():
    var game_state = battlescape_manager.get_game_state()
    
    # Update turn info
    turn_label.text = "TURN: " + str(game_state.turn_count)
    
    var active_unit = game_state.active_unit
    if active_unit:
        active_unit_label.text = "ACTIVE UNIT: " + active_unit.name
        time_units_label.text = "TIME UNITS: " + str(battlescape_manager.turn_manager.get_remaining_time_units())
        
        # Update unit stats
        unit_stats_label.text = "Health: " + str(active_unit.stats.health) + "/35\nTU: " + str(active_unit.stats.tu) + "/60\nPosition: (" + str(int(active_unit.position.x)) + "," + str(int(active_unit.position.y)) + ")"
    else:
        active_unit_label.text = "ACTIVE UNIT: None"
        time_units_label.text = "TIME UNITS: 0"
        unit_stats_label.text = "No unit selected"
    
    # Update objective
    objective_label.text = "Objective: " + game_state.mission_objective

func _on_battlescape_ready():
    print("BattlescapeState: Battlescape ready")
    _update_map_display()
    _update_ui()

func _on_turn_changed(active_unit: Unit):
    print("BattlescapeState: Turn changed to: ", active_unit.name)
    _update_ui()
    
    if active_unit.race != "human":
        # AI turn - simple implementation
        _perform_ai_turn(active_unit)

func _on_combat_started():
    print("BattlescapeState: Combat started")
    status_label.text = "Status: Combat started"

func _on_combat_ended(winner: String):
    print("BattlescapeState: Combat ended, winner: ", winner)
    status_label.text = "Status: Combat ended - " + winner + " win!"

func _on_mission_completed(success: bool):
    print("BattlescapeState: Mission completed: ", success)
    if success:
        status_label.text = "Status: Mission completed successfully!"
    else:
        status_label.text = "Status: Mission failed!"

func _perform_ai_turn(unit: Unit):
    print("BattlescapeState: Performing AI turn for: ", unit.name)
    
    # Simple AI: move towards nearest enemy, then attack if possible
    var visible_enemies = battlescape_manager.line_of_sight_system.get_visible_enemies(unit)
    
    if visible_enemies.size() > 0:
        var target = visible_enemies[0]  # Target closest enemy
        
        # Try to attack first
        if battlescape_manager.line_of_sight_system.can_see_unit(unit, target):
            battlescape_manager.attack_unit(unit, target)
        else:
            # Move towards target
            var path = battlescape_manager.battlescape_map.get_path(unit.position, target.position)
            if path.size() > 1:
                # Move as far as possible along the path
                var move_distance = min(3, path.size() - 1)  # Move up to 3 tiles
                var target_pos = path[move_distance]
                battlescape_manager.move_unit(unit, target_pos)
    
    # End turn
    await get_tree().create_timer(1.0).timeout  # Small delay for AI
    battlescape_manager.end_turn()
