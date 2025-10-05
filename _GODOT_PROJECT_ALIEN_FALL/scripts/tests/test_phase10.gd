extends "res://scripts/tests/test_base.gd"

# TestPhase10 - Tests for Phase 10: Battlescape integration

class_name TestPhase10

func _ready():
    """Run all tests when the scene is ready"""
    run_all_tests()
    get_tree().quit()  # Exit after tests complete

func test_battle_service_creation():
    """Test that BattleService can be accessed"""
    assert_not_null(BattleService, "BattleService should be available")
    print("✓ BattleService autoload found")

func test_deterministic_battle_generation():
    """Test that same inputs produce identical battle topology"""
    var test_seed = 12345
    var terrain_id = "urban"

    # Create deployment data
    var deployment = {
        "player_units": [
            {"id": "soldier_1", "type": "human_soldier", "position": [5, 10]},
            {"id": "soldier_2", "type": "human_soldier", "position": [7, 10]}
        ],
        "enemy_units": [
            {"id": "sectoid_1", "type": "sectoid_warrior", "position": [15, 15]},
            {"id": "sectoid_2", "type": "sectoid_warrior", "position": [17, 15]}
        ],
        "objectives": ["eliminate_all_enemies"]
    }

    # Generate battle twice with same inputs
    var battle1_id = BattleService.create_battle(test_seed, terrain_id, deployment)
    assert_false(battle1_id.is_empty(), "First battle should be created successfully")

    var battle1_data = BattleService.get_battle_data(battle1_id)
    assert_false(battle1_data.is_empty(), "Should be able to retrieve first battle data")

    var battle2_id = BattleService.create_battle(test_seed, terrain_id, deployment)
    assert_false(battle2_id.is_empty(), "Second battle should be created successfully")

    var battle2_data = BattleService.get_battle_data(battle2_id)
    assert_false(battle2_data.is_empty(), "Should be able to retrieve second battle data")

    # Compare key properties
    assert_eq(battle1_data.map_width, battle2_data.map_width, "Map width should be identical")
    assert_eq(battle1_data.map_height, battle2_data.map_height, "Map height should be identical")
    assert_eq(battle1_data.terrain_id, battle2_data.terrain_id, "Terrain ID should be identical")
    assert_eq(battle1_data.topology_hash, battle2_data.topology_hash, "Topology hash should be identical")

    # Verify topology structure
    assert_eq(battle1_data.topology.size(), battle2_data.topology.size(), "Topology levels should match")
    if battle1_data.topology.size() > 0:
        assert_eq(battle1_data.topology[0].size(), battle2_data.topology[0].size(), "Topology rows should match")
        if battle1_data.topology[0].size() > 0:
            assert_eq(battle1_data.topology[0][0].size(), battle2_data.topology[0][0].size(), "Topology columns should match")

    print("✓ Deterministic battle generation test passed")
    print("  Battle 1 ID: ", battle1_id)
    print("  Battle 2 ID: ", battle2_id)
    print("  Topology hash: ", battle1_data.topology_hash)

    # Clean up
    BattleService.destroy_battle(battle1_id)
    BattleService.destroy_battle(battle2_id)

func test_battle_service_smoke_test():
    """Test the built-in smoke test function"""
    var test_seed = 98765
    var terrain_id = "forest"

    var result = BattleService.smoke_test_deterministic_generation(test_seed, terrain_id)
    assert_true(result, "Smoke test should pass for deterministic generation")

    print("✓ BattleService smoke test passed")

func test_battle_data_structure():
    """Test that generated battle data has correct structure"""
    var test_seed = 55555
    var terrain_id = "desert"

    var deployment = {
        "player_units": [{"id": "test_unit", "type": "soldier"}],
        "enemy_units": [{"id": "test_enemy", "type": "sectoid"}],
        "objectives": ["test_objective"]
    }

    var battle_id = BattleService.create_battle(test_seed, terrain_id, deployment)
    assert_false(battle_id.is_empty(), "Battle should be created")

    var battle_data = BattleService.get_battle_data(battle_id)

    # Check required fields
    assert_true(battle_data.has("battle_id"), "Should have battle_id")
    assert_true(battle_data.has("terrain_id"), "Should have terrain_id")
    assert_true(battle_data.has("map_width"), "Should have map_width")
    assert_true(battle_data.has("map_height"), "Should have map_height")
    assert_true(battle_data.has("topology"), "Should have topology")
    assert_true(battle_data.has("topology_hash"), "Should have topology_hash")
    assert_true(battle_data.has("player_units"), "Should have player_units")
    assert_true(battle_data.has("enemy_units"), "Should have enemy_units")
    assert_true(battle_data.has("objectives"), "Should have objectives")
    assert_true(battle_data.has("seed"), "Should have seed")
    assert_true(battle_data.has("created_at"), "Should have created_at")

    # Check data types
    assert_true(typeof(battle_data.map_width) == TYPE_INT, "map_width should be int")
    assert_true(typeof(battle_data.map_height) == TYPE_INT, "map_height should be int")
    assert_true(typeof(battle_data.topology) == TYPE_ARRAY, "topology should be array")
    assert_true(typeof(battle_data.topology_hash) == TYPE_STRING, "topology_hash should be string")

    print("✓ Battle data structure test passed")
    print("  Map size: ", battle_data.map_width, "x", battle_data.map_height)
    print("  Topology levels: ", battle_data.topology.size())

    # Clean up
    BattleService.destroy_battle(battle_id)

func test_invalid_terrain_handling():
    """Test that invalid terrain IDs are handled properly"""
    var test_seed = 11111
    var invalid_terrain = "nonexistent_terrain"

    var deployment = {
        "player_units": [],
        "enemy_units": [],
        "objectives": []
    }

    # This should fail gracefully
    var battle_id = BattleService.create_battle(test_seed, invalid_terrain, deployment)
    assert_true(battle_id.is_empty(), "Should return empty ID for invalid terrain")

    print("✓ Invalid terrain handling test passed")

func run_all_tests():
    """Run all Phase 10 tests"""
    print("\n=== Running Phase 10: Battlescape Integration Tests ===")

    test_battle_service_creation()
    test_deterministic_battle_generation()
    test_battle_service_smoke_test()
    test_battle_data_structure()
    test_invalid_terrain_handling()

    print("=== All Phase 10 Tests Passed ===")
