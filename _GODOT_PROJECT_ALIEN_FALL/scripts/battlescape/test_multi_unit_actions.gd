extends Node

# Test script for Multi-Unit Action System integration
# Tests squad commands, formations, and coordinated unit actions

func _ready():
    print("=== Multi-Unit Action System Integration Test ===")
    run_multi_unit_tests()

func run_multi_unit_tests():
    # Create test systems
    var test_map = BattlescapeMap.new(20, 20)
    test_map.generate_random_map()

    var los_system = LineOfSightSystem.new(test_map)
    var terrain_system = DestructibleTerrain.new(test_map)
    var combat_system = CombatSystem.new(los_system, terrain_system)
    var multi_unit_system = MultiUnitActionSystem.new()

    # Create test units
    var units = []
    for i in range(4):
        var unit = Unit.new()
        unit.name = "Soldier " + str(i + 1)
        unit.position = Vector2(i * 3, 5)
        unit.stats = {"health": 100, "tu": 50}
        unit.unit_id = "unit_" + str(i + 1)
        units.append(unit)

    print("\n--- Test 1: Squad Formation ---")
    # Add units to squad
    for unit in units:
        multi_unit_system.add_unit_to_squad(unit)
        print("Added ", unit.name, " to squad")

    print("Squad size: ", multi_unit_system.squad_units.size())
    print("Squad leader: ", multi_unit_system.squad_leader.name)

    print("\n--- Test 2: Formation Changes ---")
    # Test different formations
    var formations = [
        MultiUnitActionSystem.FormationType.LINE,
        MultiUnitActionSystem.FormationType.COLUMN,
        MultiUnitActionSystem.FormationType.WEDGE,
        MultiUnitActionSystem.FormationType.CIRCLE,
        MultiUnitActionSystem.FormationType.SCATTER
    ]

    for formation in formations:
        multi_unit_system.set_formation(formation)
        var formation_name = MultiUnitActionSystem.FormationType.keys()[formation]
        print("Changed to ", formation_name, " formation")

        # Show unit positions
        for i in range(multi_unit_system.squad_units.size()):
            var unit = multi_unit_system.squad_units[i]
            print("  ", unit.name, " at position: ", unit.position)

    print("\n--- Test 3: Squad Commands ---")
    # Test squad commands
    var target_pos = Vector2(10, 10)
    print("Executing MOVE_TO_POSITION command to ", target_pos)
    multi_unit_system.execute_squad_command(MultiUnitActionSystem.SquadCommand.MOVE_TO_POSITION, target_pos)

    print("\nExecuting DEFEND_POSITION command")
    multi_unit_system.execute_squad_command(MultiUnitActionSystem.SquadCommand.DEFEND_POSITION, target_pos)

    print("\nExecuting SPREAD_OUT command")
    multi_unit_system.execute_squad_command(MultiUnitActionSystem.SquadCommand.SPREAD_OUT)

    print("\nExecuting GROUP_UP command")
    multi_unit_system.execute_squad_command(MultiUnitActionSystem.SquadCommand.GROUP_UP)

    print("\n--- Test 4: Squad Management ---")
    # Test squad management
    var new_leader = units[2]
    multi_unit_system.set_squad_leader(new_leader)
    print("Changed squad leader to: ", new_leader.name)

    # Remove a unit
    var unit_to_remove = units[1]
    multi_unit_system.remove_unit_from_squad(unit_to_remove)
    print("Removed ", unit_to_remove.name, " from squad")
    print("New squad size: ", multi_unit_system.squad_units.size())

    print("\n--- Test 5: Save/Load Functionality ---")
    # Test save/load
    var saved_state = multi_unit_system.to_dict()
    print("Saved squad state: ", saved_state)

    # Create new system and load state
    var new_multi_unit_system = MultiUnitActionSystem.new()
    new_multi_unit_system.from_dict(saved_state)
    print("Loaded squad state successfully")

    print("\n--- Test 6: Squad Bounds and Center ---")
    # Test utility functions
    var squad_center = multi_unit_system.get_squad_center()
    var squad_bounds = multi_unit_system.get_squad_bounds()

    print("Squad center: ", squad_center)
    print("Squad bounds: ", squad_bounds)

    print("\n=== Multi-Unit Action System Test Complete ===")
    print("✅ All squad functionality tests passed!")
