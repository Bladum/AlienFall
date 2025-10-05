extends Control

@onready var minimap: Control = $UIPanel/MinimapPanel/Minimap

var battlescape_manager: BattlescapeManager
var test_units = []

func _ready():
    $UIPanel/BuildButton.connect("pressed", Callable(self, "_on_build_pressed"))
    $UIPanel/TrainButton.connect("pressed", Callable(self, "_on_train_pressed"))
    $UIPanel/MoveButton.connect("pressed", Callable(self, "_on_move_pressed"))
    $UIPanel/AttackButton.connect("pressed", Callable(self, "_on_attack_pressed"))
    $UIPanel/TestTerrainButton.connect("pressed", Callable(self, "_on_test_terrain_pressed"))
    $UIPanel/TestSquadButton.connect("pressed", Callable(self, "_on_test_squad_pressed"))
    $UIPanel/TestMinimapButton.connect("pressed", Callable(self, "_on_test_minimap_pressed"))
    $UIPanel/SaveLoadButton.connect("pressed", Callable(self, "_on_save_load_pressed"))
    $UIPanel/TestSaveLoadButton.connect("pressed", Callable(self, "_on_test_save_load_pressed"))
    $UIPanel/BackButton.connect("pressed", Callable(self, "_on_back_pressed"))

    # Initialize battlescape systems
    _initialize_battlescape_systems()

    # Initialize minimap
    _initialize_minimap()

func _initialize_battlescape_systems():
    # Create battlescape manager
    battlescape_manager = BattlescapeManager.new()

    # Create test map
    var test_map = BattlescapeMap.new(20, 20)
    test_map.generate_random_map()

    # Create test units
    for i in range(3):
        var unit = Unit.new()
        unit.name = "Soldier " + str(i + 1)
        unit.position = Vector2(i * 5 + 5, 10)
        unit.stats = {"health": 100, "tu": 50}
        unit.unit_id = "player_unit_" + str(i + 1)
        test_units.append(unit)
        test_map.add_unit(unit, unit.position)

    # Create enemy units
    for i in range(2):
        var unit = Unit.new()
        unit.name = "Alien " + str(i + 1)
        unit.position = Vector2(i * 7 + 8, 15)
        unit.stats = {"health": 80, "tu": 40}
        unit.unit_id = "enemy_unit_" + str(i + 1)
        test_units.append(unit)
        test_map.add_unit(unit, unit.position)

    # Set up battlescape manager
    battlescape_manager.map = test_map
    battlescape_manager.player_units = test_units.slice(0, 3)
    battlescape_manager.enemy_units = test_units.slice(3, 5)

func _initialize_minimap():
    if minimap:
        minimap.set_battlescape_manager(battlescape_manager)
        minimap.initialize_minimap()
        print("Minimap initialized successfully")
    else:
        print("Warning: Minimap not found in scene")

func _on_build_pressed():
    print("Build mode activated")

func _on_train_pressed():
    print("Train mode activated")

func _on_move_pressed():
    print("Move mode activated")

func _on_attack_pressed():
    print("Attack mode activated")

func _on_test_terrain_pressed():
    print("=== Running Destructible Terrain Integration Test ===")
    
    # Create test systems
    var test_map = BattlescapeMap.new(10, 10)
    test_map.generate_random_map()
    
    var los_system = LineOfSightSystem.new(test_map)
    var terrain_system = DestructibleTerrain.new(test_map)
    var combat_system = CombatSystem.new(los_system, terrain_system)
    
    # Create test units
    var attacker = Unit.new()
    attacker.name = "Test Soldier"
    attacker.position = Vector2(2, 2)
    attacker.stats = {"health": 100, "tu": 50}
    
    var target = Unit.new()
    target.name = "Test Alien"
    target.position = Vector2(5, 5)
    target.stats = {"health": 100, "tu": 50}
    
    # Add units to map
    test_map.add_unit(attacker, attacker.position)
    test_map.add_unit(target, target.position)
    
    # Add destructible terrain
    terrain_system.add_terrain_at(Vector2i(5, 5), DestructibleTerrain.TerrainType.SOFT_COVER, 50)
    print("Added soft cover terrain at (5,5) with 50 health")
    
    # Test weapon
    var weapon = {
        "name": "Test Rifle",
        "damage": 25,
        "accuracy": 80,
        "current_ammo": 30,
        "weapon_type": "bullet"
    }
    
    print("\n--- Before Attack ---")
    var terrain_before = terrain_system.get_terrain_at(Vector2i(5, 5))
    print("Terrain at target: health =", terrain_before.get("health", 0))
    
    # Perform attack
    print("\n--- Performing Attack ---")
    var result = combat_system.perform_attack_enhanced(attacker, target, weapon, "single")
    print("Attack result: ", result.message)
    print("Target health: ", target.stats.health)
    
    print("\n--- After Attack ---")
    var terrain_after = terrain_system.get_terrain_at(Vector2i(5, 5))
    print("Terrain at target: health =", terrain_after.get("health", 0))
    
    if terrain_after.get("health", 0) <= 0:
        print("Terrain was destroyed!")
    else:
        print("Terrain was damaged but not destroyed")
    
    print("\n=== Test Complete ===")

func _on_test_squad_pressed():
    print("=== Running Multi-Unit Action System Test ===")
    
    # Create test systems
    var test_map = BattlescapeMap.new(15, 15)
    test_map.generate_random_map()
    
    var multi_unit_system = MultiUnitActionSystem.new()
    
    # Create test units
    var units = []
    for i in range(3):
        var unit = Unit.new()
        unit.name = "Soldier " + str(i + 1)
        unit.position = Vector2(i * 3, 5)
        unit.stats = {"health": 100, "tu": 50}
        unit.unit_id = "unit_" + str(i + 1)
        units.append(unit)
    
    print("\n--- Squad Formation Test ---")
    # Add units to squad
    for unit in units:
        multi_unit_system.add_unit_to_squad(unit)
        print("Added ", unit.name, " to squad at ", unit.position)
    
    print("Squad leader: ", multi_unit_system.squad_leader.name)
    print("Squad size: ", multi_unit_system.squad_units.size())
    
    print("\n--- Formation Test ---")
    # Test line formation
    multi_unit_system.set_formation(MultiUnitActionSystem.FormationType.LINE)
    print("Set formation to LINE")
    for unit in multi_unit_system.squad_units:
        print("  ", unit.name, " position: ", unit.position)
    
    # Test wedge formation
    multi_unit_system.set_formation(MultiUnitActionSystem.FormationType.WEDGE)
    print("\nSet formation to WEDGE")
    for unit in multi_unit_system.squad_units:
        print("  ", unit.name, " position: ", unit.position)
    
    print("\n--- Squad Command Test ---")
    # Test move command
    var target_pos = Vector2(10, 8)
    print("Executing MOVE_TO_POSITION to ", target_pos)
    multi_unit_system.execute_squad_command(MultiUnitActionSystem.SquadCommand.MOVE_TO_POSITION, target_pos)
    
    print("\nFinal positions after move:")
    for unit in multi_unit_system.squad_units:
        print("  ", unit.name, " at ", unit.position)
    
    # Test spread command
    print("\nExecuting SPREAD_OUT command")
    multi_unit_system.execute_squad_command(MultiUnitActionSystem.SquadCommand.SPREAD_OUT)
    
    print("\nPositions after spread:")
    for unit in multi_unit_system.squad_units:
        print("  ", unit.name, " at ", unit.position)
    
    print("\n--- Squad Management Test ---")
    # Change leader
    var new_leader = units[1]
    multi_unit_system.set_squad_leader(new_leader)
    print("Changed squad leader to: ", new_leader.name)
    
    # Remove unit
    var unit_to_remove = units[2]
    multi_unit_system.remove_unit_from_squad(unit_to_remove)
    print("Removed ", unit_to_remove.name, " from squad")
    print("New squad size: ", multi_unit_system.squad_units.size())
    
    print("\n=== Multi-Unit Action System Test Complete ===")

func _on_save_load_pressed():
    print("Opening Save/Load UI")
    
    # Create and show the save/load UI
    var save_load_ui = load("res://scenes/save_load_ui.tscn").instantiate()
    add_child(save_load_ui)
    
    # Set up the battlescape manager reference (we'll need to get this from somewhere)
    # For now, create a test battlescape manager
    var test_manager = BattlescapeManager.new()
    save_load_ui.set_battlescape_manager(test_manager)
    
    save_load_ui.connect("ui_closed", Callable(self, "_on_save_load_ui_closed"))

func _on_save_load_ui_closed():
    print("Save/Load UI closed")

func _on_test_save_load_pressed():
    print("=== Running Save/Load System Test ===")

    # Create test battlescape manager
    var battlescape_manager = BattlescapeManager.new()

    print("\n--- Basic Save/Load Test ---")
    # Test saving to slot 1
    var success = battlescape_manager.save_battlescape_to_slot(1, "Test Save Slot 1")
    print("Save to slot 1: ", "Success" if success else "Failed")

    # Test loading from slot 1
    success = battlescape_manager.load_battlescape_from_slot(1)
    print("Load from slot 1: ", "Success" if success else "Failed")

    print("\n--- Multiple Slots Test ---")
    # Test multiple save slots
    for slot_id in range(2, 4):
        success = battlescape_manager.save_battlescape_to_slot(slot_id, "Test Save " + str(slot_id))
        print("Save to slot ", slot_id, ": ", "Success" if success else "Failed")

    var slot_count = battlescape_manager.get_save_slot_count()
    print("Total save slots: ", slot_count)

    print("\n--- Quick Save/Load Test ---")
    # Test quick save
    success = battlescape_manager.quick_save_battlescape()
    print("Quick save: ", "Success" if success else "Failed")

    # Test quick load
    success = battlescape_manager.quick_load_battlescape()
    print("Quick load: ", "Success" if success else "Failed")

    print("\n--- Save Slot Management Test ---")
    # Test save slot info
    var slot_info = battlescape_manager.get_save_slot_info(1)
    if not slot_info.is_empty():
        print("Slot 1 description: ", slot_info.get("description", "Unknown"))

    # Test deleting a save slot
    success = battlescape_manager.delete_save_slot(2)
    print("Delete slot 2: ", "Success" if success else "Failed")

    print("Updated save slot count: ", battlescape_manager.get_save_slot_count())

    print("\n=== Save/Load System Test Complete ===")

func _on_test_minimap_pressed():
    print("=== Running Minimap System Test ===")

    if not minimap:
        print("Error: Minimap not found")
        return

    print("Minimap found, testing functionality...")

    # Test minimap initialization
    print("Testing minimap initialization...")
    minimap.initialize_minimap()

    # Test unit tracking
    print("Testing unit tracking...")
    print("Player units on minimap: ", minimap.get_unit_count("player"))
    print("Enemy units on minimap: ", minimap.get_unit_count("enemy"))

    # Test zoom functionality
    print("Testing zoom controls...")
    minimap.set_zoom_level(2.0)
    print("Zoom level set to 2.0")

    # Test terrain overlay
    print("Testing terrain overlay...")
    minimap.show_terrain_overlay(true)
    print("Terrain overlay enabled")

    # Test fog of war
    print("Testing fog of war...")
    minimap.show_fog_of_war(true)
    print("Fog of war enabled")

    print("\n=== Minimap System Test Complete ===")

func _on_back_pressed():
    get_tree().change_scene_to_file("res://menu.tscn")
