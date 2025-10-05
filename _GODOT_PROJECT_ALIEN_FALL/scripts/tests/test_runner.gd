extends Node

# TestRunner - Runs all unit tests

func _ready():
    print("\n=== AlienFall Test Runner ===\n")

    # Load and run Phase 9 tests
    var test_phase9 = load("res://scripts/tests/test_phase9.gd").new()
    add_child(test_phase9)

    # Load and run Phase 10 tests
    var test_phase10 = load("res://scripts/tests/test_phase10.gd").new()
    add_child(test_phase10)

    # Load and run Phase 10B tests
    var test_phase10b = load("res://scripts/tests/test_phase10b.gd").new()
    add_child(test_phase10b)

    # Load and run Phase 12 tests
    var test_phase12 = load("res://scripts/tests/test_phase12.gd").new()
    add_child(test_phase12)

    # Wait a frame for tests to complete
    await get_tree().process_frame

    print("\n=== Test Runner Complete ===")
    get_tree().quit()
