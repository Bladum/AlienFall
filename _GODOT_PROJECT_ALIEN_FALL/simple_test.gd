extends Node

# Simple Phase 9 Test - Tests the core functionality without complex dependencies

func _ready():
    print("\n=== Simple Phase 9 Test ===")

    # Test 1: Check if TimeService has the daily_tick signal
    print("Testing TimeService signal availability...")
    if TimeService and TimeService.has_signal("daily_tick"):
        print("✓ TimeService has daily_tick signal")
    else:
        print("✗ TimeService missing daily_tick signal")

    # Test 2: Check if BaseManager has build_facility method
    print("\nTesting BaseManager method availability...")
    if BaseManager and BaseManager.has_method("build_facility"):
        print("✓ BaseManager has build_facility method")
    else:
        print("✗ BaseManager missing build_facility method")

    if BaseManager and BaseManager.has_method("get_main_base"):
        print("✓ BaseManager has get_main_base method")
    else:
        print("✗ BaseManager missing get_main_base method")

    # Test 3: Check if GameState has add_funding method
    print("\nTesting GameState method availability...")
    if GameState and GameState.has_method("add_funding"):
        print("✓ GameState has add_funding method")
    else:
        print("✗ GameState missing add_funding method")

    print("\n=== Test Complete ===")
    get_tree().quit()
