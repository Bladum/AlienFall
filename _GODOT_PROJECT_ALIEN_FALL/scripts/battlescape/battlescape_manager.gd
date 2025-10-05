extends Node
class_name BattlescapeManager

# BattlescapeManager - Central coordinator for battlescape systems
# Manages the tactical combat session

var battlescape_map: BattlescapeMap = null
var line_of_sight_system: LineOfSightSystem = null
var turn_manager: TurnManager = null
var combat_system: CombatSystem = null
var destructible_terrain_system: DestructibleTerrain = null
var multi_unit_action_system: MultiUnitActionSystem = null
var save_load_system: SaveLoadSystem = null

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []
var mission_objective: String = ""
var turn_count: int = 0

signal battlescape_ready()
signal turn_changed(active_unit: Unit)
signal unit_selected(unit: Unit)
signal combat_started()
signal combat_ended(winner: String)
signal mission_completed(success: bool)

func _ready():
    print("BattlescapeManager: Initializing battlescape systems")
    
    # Initialize map
    battlescape_map = BattlescapeMap.new(20, 20)
    battlescape_map.generate_random_map()
    
    # Initialize systems
    line_of_sight_system = LineOfSightSystem.new(battlescape_map)
    destructible_terrain_system = DestructibleTerrain.new(battlescape_map)
    combat_system = CombatSystem.new(line_of_sight_system, destructible_terrain_system)
    turn_manager = TurnManager.new()
    multi_unit_action_system = MultiUnitActionSystem.new()
    save_load_system = SaveLoadSystem.new()
    
    # Connect signals
    _connect_signals()
    
    emit_signal("battlescape_ready")

func _connect_signals():
    # Turn manager signals
    turn_manager.connect("turn_started", Callable(self, "_on_turn_started"))
    turn_manager.connect("turn_ended", Callable(self, "_on_turn_ended"))
    turn_manager.connect("phase_changed", Callable(self, "_on_phase_changed"))
    turn_manager.connect("combat_ended", Callable(self, "_on_combat_ended"))
    
    # Combat system signals
    combat_system.connect("attack_resolved", Callable(self, "_on_attack_resolved"))
    combat_system.connect("unit_damaged", Callable(self, "_on_unit_damaged"))
    combat_system.connect("unit_killed", Callable(self, "_on_unit_killed"))
    
    # Destructible terrain signals
    destructible_terrain_system.connect("terrain_destroyed", Callable(self, "_on_terrain_destroyed"))
    destructible_terrain_system.connect("terrain_damaged", Callable(self, "_on_terrain_damaged"))
    
    # Multi-unit action signals
    multi_unit_action_system.connect("squad_command_executed", Callable(self, "_on_squad_command_executed"))
    multi_unit_action_system.connect("formation_changed", Callable(self, "_on_formation_changed"))
    multi_unit_action_system.connect("squad_leader_changed", Callable(self, "_on_squad_leader_changed"))
    
    # Save/Load signals
    save_load_system.connect("save_completed", Callable(self, "_on_save_completed"))
    save_load_system.connect("load_completed", Callable(self, "_on_load_completed"))
    save_load_system.connect("save_deleted", Callable(self, "_on_save_deleted"))
    save_load_system.connect("auto_save_created", Callable(self, "_on_auto_save_created"))
    
    # Map signals
    battlescape_map.connect("unit_moved", Callable(self, "_on_unit_moved"))

func start_mission(mission_data: Dictionary):
    print("BattlescapeManager: Starting mission: ", mission_data.get("name", "Unknown"))
    
    mission_objective = mission_data.get("objective", "Eliminate all enemies")
    
    # Load player units
    player_units = mission_data.get("player_units", [])
    for unit in player_units:
        var start_pos = _find_valid_start_position("human")
        battlescape_map.add_unit(unit, start_pos)
    
    # Load enemy units
    enemy_units = mission_data.get("enemy_units", [])
    for unit in enemy_units:
        var start_pos = _find_valid_start_position("alien")
        battlescape_map.add_unit(unit, start_pos)
    
    # Start combat
    var all_units = player_units + enemy_units
    turn_manager.start_combat(all_units)
    
    emit_signal("combat_started")

func _find_valid_start_position(faction: String) -> Vector2:
    # Find a valid starting position for a unit
    var attempts = 0
    var max_attempts = 100
    
    while attempts < max_attempts:
        var x = RNGService.randi_range(0, battlescape_map.width - 1)
        var y = RNGService.randi_range(0, battlescape_map.height - 1)
        var pos = Vector2(x, y)
        
        if battlescape_map.is_walkable(x, y) and not battlescape_map.get_unit_at_position(pos):
            # Check distance from other units of same faction
            var min_distance = 3
            var too_close = false
            
            for unit in battlescape_map.units:
                if unit.race == faction and unit.position.distance_to(pos) < min_distance:
                    too_close = true
                    break
            
            if not too_close:
                return pos
        
        attempts += 1
    
    # Fallback position
    return Vector2(5, 5)

func move_unit(unit: Unit, target_position: Vector2) -> bool:
    if not turn_manager.get_active_unit() == unit:
        return false
    
    if not turn_manager.is_player_turn():
        return false
    
    var path = battlescape_map.get_path(unit.position, target_position)
    if path.size() == 0:
        return false
    
    var cost = combat_system.calculate_movement_cost(unit.position, target_position, unit)
    if not turn_manager.spend_time_units(cost):
        return false
    
    return battlescape_map.move_unit(unit, target_position)

func attack_unit(attacker: Unit, target: Unit) -> bool:
    if not turn_manager.get_active_unit() == attacker:
        return false
    
    if not turn_manager.is_player_turn():
        return false
    
    # Check if target is visible
    if not line_of_sight_system.can_see_unit(attacker, target):
        return false
    
    # Calculate attack cost (simplified)
    var attack_cost = 20  # TU cost for attacking
    if not turn_manager.spend_time_units(attack_cost):
        return false
    
    # Perform attack
    combat_system.perform_attack(attacker, target)
    return true

func end_turn():
    turn_manager.end_turn()

func get_visible_units(unit: Unit) -> Array[Unit]:
    return line_of_sight_system.get_visible_units_from_position(unit.position)

func get_attack_options(unit: Unit) -> Array[Unit]:
    return combat_system.get_attack_options(unit)

func get_movement_options(unit: Unit) -> Array[Vector2]:
    return combat_system.get_movement_options(unit)

func get_map_data() -> Dictionary:
    return {
        "width": battlescape_map.width,
        "height": battlescape_map.height,
        "tiles": battlescape_map.tiles,
        "units": battlescape_map.units
    }

func get_game_state() -> Dictionary:
    return {
        "active_unit": turn_manager.get_active_unit(),
        "current_phase": turn_manager.current_phase,
        "turn_count": turn_count,
        "player_units": player_units,
        "enemy_units": enemy_units,
        "mission_objective": mission_objective
    }

# Multi-Unit Action Methods
func add_unit_to_squad(unit: Unit) -> bool:
    return multi_unit_action_system.add_unit_to_squad(unit)

func remove_unit_from_squad(unit: Unit) -> bool:
    return multi_unit_action_system.remove_unit_from_squad(unit)

func set_squad_leader(unit: Unit) -> bool:
    return multi_unit_action_system.set_squad_leader(unit)

func set_squad_formation(formation: int) -> bool:
    return multi_unit_action_system.set_formation(formation)

func execute_squad_command(command: int, target = null) -> bool:
    return multi_unit_action_system.execute_squad_command(command, target)

func get_squad_units() -> Array[Unit]:
    return multi_unit_action_system.squad_units

func get_squad_leader() -> Unit:
    return multi_unit_action_system.squad_leader

func get_current_formation() -> int:
    return multi_unit_action_system.current_formation

# Save/Load Methods
func save_battlescape_to_slot(slot_id: int, description: String = "") -> bool:
    var game_state = save_battlescape()
    return save_load_system.save_game(slot_id, game_state, description)

func load_battlescape_from_slot(slot_id: int) -> bool:
    var game_state = save_load_system.load_game(slot_id)
    if game_state.is_empty():
        return false

    return load_battlescape(game_state)

func quick_save_battlescape() -> bool:
    var game_state = save_battlescape()
    return save_load_system.quick_save(game_state)

func quick_load_battlescape() -> bool:
    var game_state = save_load_system.quick_load()
    if game_state.is_empty():
        return false

    return load_battlescape(game_state)

func auto_save_battlescape() -> bool:
    var game_state = save_battlescape()
    return save_load_system.auto_save(game_state)

func delete_save_slot(slot_id: int) -> bool:
    return save_load_system.delete_save_slot(slot_id)

func get_save_slot_info(slot_id: int) -> Dictionary:
    return save_load_system.get_save_slot_info(slot_id)

func get_all_save_slots() -> Array:
    return save_load_system.get_all_save_slots()

func has_save_slot(slot_id: int) -> bool:
    return save_load_system.has_save_slot(slot_id)

func get_save_slot_count() -> int:
    return save_load_system.get_save_slot_count()

func _on_turn_started(unit: Unit):
    print("BattlescapeManager: Turn started for: ", unit.name)
    turn_count += 1
    
    # Update visibility for the active unit
    line_of_sight_system.update_unit_visibility(unit)
    
    emit_signal("turn_changed", unit)

func _on_turn_ended(unit: Unit):
    print("BattlescapeManager: Turn ended for: ", unit.name)

func _on_phase_changed(new_phase):
    print("BattlescapeManager: Phase changed to: ", new_phase)

func _on_combat_ended(winner: String):
    print("BattlescapeManager: Combat ended, winner: ", winner)
    
    var success = (winner == "humans")
    emit_signal("combat_ended", winner)
    emit_signal("mission_completed", success)

func _on_attack_resolved(attacker: Unit, target: Unit, hit: bool, damage: int, critical: bool):
    print("BattlescapeManager: Attack resolved - ", attacker.name, " -> ", target.name, ": ", "Hit" if hit else "Miss", " for ", damage, " damage")

func _on_unit_damaged(unit: Unit, damage: int, new_health: int):
    print("BattlescapeManager: Unit damaged - ", unit.name, " took ", damage, " damage, health: ", new_health)

func _on_unit_killed(unit: Unit, killer: Unit):
    print("BattlescapeManager: Unit killed - ", unit.name, " killed by ", killer.name)
    
    # Remove from appropriate array
    if unit in player_units:
        player_units.erase(unit)
    elif unit in enemy_units:
        enemy_units.erase(unit)

func _on_terrain_destroyed(position: Vector2, terrain_type: int):
    print("BattlescapeManager: Terrain destroyed at ", position, " (type: ", terrain_type, ")")
    # Could trigger additional effects like collapsing structures or revealing hidden areas

func _on_terrain_damaged(position: Vector2, damage: int, remaining_health: int):
    print("BattlescapeManager: Terrain damaged at ", position, " for ", damage, " damage, remaining health: ", remaining_health)

func _on_squad_command_executed(command: int, success: bool):
    var command_name = MultiUnitActionSystem.SquadCommand.keys()[command]
    print("BattlescapeManager: Squad command executed - ", command_name, ": ", "Success" if success else "Failed")

func _on_formation_changed(new_formation: int):
    var formation_name = MultiUnitActionSystem.FormationType.keys()[new_formation]
    print("BattlescapeManager: Formation changed to: ", formation_name)

func _on_squad_leader_changed(new_leader: Unit):
    print("BattlescapeManager: New squad leader: ", new_leader.name if new_leader else "None")

func _on_save_completed(slot_id: int, success: bool):
    var status = "Success" if success else "Failed"
    print("BattlescapeManager: Save to slot ", slot_id, " - ", status)

func _on_load_completed(slot_id: int, success: bool):
    var status = "Success" if success else "Failed"
    print("BattlescapeManager: Load from slot ", slot_id, " - ", status)

func _on_save_deleted(slot_id: int):
    print("BattlescapeManager: Save slot ", slot_id, " deleted")

func _on_auto_save_created():
    print("BattlescapeManager: Auto save created")

func _on_unit_moved(unit: Unit, from_pos: Vector2, to_pos: Vector2):
    print("BattlescapeManager: Unit moved - ", unit.name, " from ", from_pos, " to ", to_pos)

func save_battlescape():
    return {
        "map": battlescape_map.to_dict(),
        "destructible_terrain": destructible_terrain_system.to_dict(),
        "multi_unit_actions": multi_unit_action_system.to_dict(),
        "player_units": player_units,
        "enemy_units": enemy_units,
        "mission_objective": mission_objective,
        "turn_count": turn_count,
        "turn_manager_state": {
            "current_phase": turn_manager.current_phase,
            "current_turn": turn_manager.current_turn,
            "active_unit_id": turn_manager.active_unit.unit_id if turn_manager.active_unit else "",
            "time_units_remaining": turn_manager.time_units_remaining
        }
    }

func load_battlescape(save_data: Dictionary):
    # Load map
    battlescape_map = BattlescapeMap.from_dict(save_data.map)
    
    # Reinitialize systems with loaded map
    line_of_sight_system = LineOfSightSystem.new(battlescape_map)
    destructible_terrain_system = DestructibleTerrain.new(battlescape_map)
    if save_data.has("destructible_terrain"):
        destructible_terrain_system.from_dict(save_data.destructible_terrain)
    combat_system = CombatSystem.new(line_of_sight_system, destructible_terrain_system)
    turn_manager = TurnManager.new()
    multi_unit_action_system = MultiUnitActionSystem.new()
    if save_data.has("multi_unit_actions"):
        multi_unit_action_system.from_dict(save_data.multi_unit_actions)
    save_load_system = SaveLoadSystem.new()
    
    # Load units
    player_units = save_data.player_units
    enemy_units = save_data.enemy_units
    
    # Add units back to map
    for unit in player_units + enemy_units:
        battlescape_map.add_unit(unit, unit.position)
    
    mission_objective = save_data.mission_objective
    turn_count = save_data.turn_count
    
    # Restore turn manager state
    var tm_state = save_data.turn_manager_state
    turn_manager.current_phase = tm_state.current_phase
    turn_manager.current_turn = tm_state.current_turn
    turn_manager.time_units_remaining = tm_state.time_units_remaining
    
    # Find active unit
    if tm_state.active_unit_id:
        for unit in player_units + enemy_units:
            if unit.unit_id == tm_state.active_unit_id:
                turn_manager.active_unit = unit
                break
