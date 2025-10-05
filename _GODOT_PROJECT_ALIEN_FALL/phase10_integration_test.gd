extends Node

# Phase 10 Integration Test - Tests BattleService with BattlescapeManager

func _ready():
    print("\n=== Phase 10 Integration Test ===")

    # Test 1: Create battle via BattleService
    var test_seed = 77777
    var terrain_id = "urban"

    var deployment = {
        "player_units": [
            {"id": "soldier_1", "type": "human_soldier", "position": [5, 5]},
            {"id": "soldier_2", "type": "human_soldier", "position": [6, 5]}
        ],
        "enemy_units": [
            {"id": "sectoid_1", "type": "sectoid_warrior", "position": [15, 15]},
            {"id": "sectoid_2", "type": "sectoid_warrior", "position": [16, 15]}
        ],
        "objectives": ["eliminate_all_enemies"]
    }

    print("Creating battle with BattleService...")
    var battle_id = BattleService.create_battle(test_seed, terrain_id, deployment)

    if battle_id.is_empty():
        print("✗ Failed to create battle")
        get_tree().quit()
        return

    print("✓ Battle created: ", battle_id)

    # Test 2: Get battle data
    var battle_data = BattleService.get_battle_data(battle_id)
    if battle_data.is_empty():
        print("✗ Failed to get battle data")
        get_tree().quit()
        return

    print("✓ Battle data retrieved")
    print("  Map size: ", battle_data.map_width, "x", battle_data.map_height)
    print("  Topology hash: ", battle_data.topology_hash)

    # Test 3: Create BattlescapeManager and initialize with battle data
    print("\nInitializing BattlescapeManager...")
    var battlescape_manager = BattlescapeManager.new()

    # Set up the battle data in the manager
    battlescape_manager.battlescape_map = BattlescapeMap.new(battle_data.map_width, battle_data.map_height)

    # Generate map from topology data
    var topology = battle_data.topology
    if topology.size() > 0 and topology[0].size() > 0:
        for y in range(battle_data.map_height):
            for x in range(battle_data.map_width):
                if y < topology[0].size() and x < topology[0][y].size():
                    var tile_data = topology[0][y][x]
                    var tile_type = tile_data.get("type", "floor")
                    battlescape_manager.battlescape_map.set_tile(x, y, tile_type)

    print("✓ BattlescapeManager initialized with battle data")

    # Test 4: Add units to the battlescape
    print("\nAdding units to battlescape...")

    # Add player units
    for unit_data in battle_data.player_units:
        var unit = Unit.new()
        unit.id = unit_data.id
        unit.name = unit_data.id
        unit.unit_id = unit_data.id
        unit.race = "human"
        unit.unit_class = "soldier"

        var position = unit_data.get("position", [0, 0])
        unit.position = Vector2(position[0], position[1])

        battlescape_manager.player_units.append(unit)
        battlescape_manager.battlescape_map.add_unit(unit, unit.position)
        print("  Added player unit: ", unit.name, " at ", unit.position)

    # Add enemy units
    for unit_data in battle_data.enemy_units:
        var unit = Unit.new()
        unit.id = unit_data.id
        unit.name = unit_data.id
        unit.unit_id = unit_data.id
        unit.race = "sectoid"
        unit.unit_class = "warrior"

        var position = unit_data.get("position", [0, 0])
        unit.position = Vector2(position[0], position[1])

        battlescape_manager.enemy_units.append(unit)
        battlescape_manager.battlescape_map.add_unit(unit, unit.position)
        print("  Added enemy unit: ", unit.name, " at ", unit.position)

    print("✓ Units added to battlescape")

    # Test 5: Verify deterministic generation
    print("\nTesting deterministic regeneration...")
    var battle2_id = BattleService.create_battle(test_seed, terrain_id, deployment)
    var battle2_data = BattleService.get_battle_data(battle2_id)

    var hash1 = battle_data.get("topology_hash", "")
    var hash2 = battle2_data.get("topology_hash", "")

    if hash1 == hash2 and not hash1.is_empty():
        print("✓ Deterministic generation confirmed")
        print("  Hash: ", hash1)
    else:
        print("✗ Deterministic generation failed")
        print("  Hash 1: ", hash1)
        print("  Hash 2: ", hash2)

    # Clean up
    BattleService.destroy_battle(battle_id)
    BattleService.destroy_battle(battle2_id)

    print("\n=== Phase 10 Integration Test Complete ===")
    get_tree().quit()
