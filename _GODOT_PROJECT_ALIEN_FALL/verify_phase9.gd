#!/usr/bin/env -S godot --headless --script

# Simple test script to verify Phase 9 implementation
extends SceneTree

func _init():
    print("\n=== Phase 9 Verification Test ===")

    # Test 1: Check if autoloads are available
    print("Testing autoload availability...")
    if get_root().has_node("/root/BaseManager"):
        print("✓ BaseManager autoload found")
    else:
        print("✗ BaseManager autoload not found")

    if get_root().has_node("/root/GameState"):
        print("✓ GameState autoload found")
    else:
        print("✗ GameState autoload not found")

    if get_root().has_node("/root/TimeService"):
        print("✓ TimeService autoload found")
    else:
        print("✗ TimeService autoload not found")

    # Test 2: Check if we can access BaseManager methods
    print("\nTesting BaseManager methods...")
    if get_root().has_node("/root/BaseManager"):
        var base_manager = get_root().get_node("/root/BaseManager")
        if base_manager.has_method("get_main_base"):
            print("✓ get_main_base method available")
            var main_base = base_manager.get_main_base()
            if main_base:
                print("✓ Main base retrieved successfully")
                print("  Base name: ", main_base.name)
                print("  Facilities: ", main_base.facilities.size())
                print("  Construction queue: ", main_base.construction_queue.size())
            else:
                print("✗ Main base is null")
        else:
            print("✗ get_main_base method not found")

    # Test 3: Check TimeService
    print("\nTesting TimeService...")
    if get_root().has_node("/root/TimeService"):
        var time_service = get_root().get_node("/root/TimeService")
        if time_service.has_method("advance_day"):
            print("✓ advance_day method available")
        else:
            print("✗ advance_day method not found")

    print("\n=== Test Complete ===")
    quit()
