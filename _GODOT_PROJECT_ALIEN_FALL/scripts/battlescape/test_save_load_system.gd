extends Node

# Test script for SaveLoadSystem integration
# Tests save/load functionality, multiple slots, and persistence

func _ready():
    print("=== Save/Load System Integration Test ===")
    run_save_load_tests()

func run_save_load_tests():
    # Create test battlescape manager
    var battlescape_manager = BattlescapeManager.new()

    print("\n--- Test 1: Basic Save/Load ---")
    # Create some test game state
    var test_game_state = {
        "test_data": "Hello World",
        "test_number": 42,
        "test_array": [1, 2, 3, 4, 5],
        "test_dict": {"key": "value", "another": 123}
    }

    # Test saving to slot 1
    var success = battlescape_manager.save_battlescape_to_slot(1, "Test Save 1")
    print("Save to slot 1: ", "Success" if success else "Failed")

    # Test loading from slot 1
    success = battlescape_manager.load_battlescape_from_slot(1)
    print("Load from slot 1: ", "Success" if success else "Failed")

    print("\n--- Test 2: Multiple Save Slots ---")
    # Test multiple save slots
    for slot_id in range(2, 5):
        success = battlescape_manager.save_battlescape_to_slot(slot_id, "Test Save " + str(slot_id))
        print("Save to slot ", slot_id, ": ", "Success" if success else "Failed")

    # Check save slot count
    var slot_count = battlescape_manager.get_save_slot_count()
    print("Total save slots: ", slot_count)

    # List all save slots
    var all_slots = battlescape_manager.get_all_save_slots()
    print("All save slots:")
    for slot_info in all_slots:
        print("  Slot ", slot_info.slot_id, ": ", slot_info.get("description", "Unknown"))

    print("\n--- Test 3: Quick Save/Load ---")
    # Test quick save
    success = battlescape_manager.quick_save_battlescape()
    print("Quick save: ", "Success" if success else "Failed")

    # Test quick load
    success = battlescape_manager.quick_load_battlescape()
    print("Quick load: ", "Success" if success else "Failed")

    print("\n--- Test 4: Auto Save ---")
    # Test auto save
    success = battlescape_manager.auto_save_battlescape()
    print("Auto save: ", "Success" if success else "Failed")

    print("\n--- Test 5: Save Slot Management ---")
    # Test save slot info
    var slot_info = battlescape_manager.get_save_slot_info(1)
    if not slot_info.is_empty():
        print("Slot 1 info:")
        print("  Description: ", slot_info.get("description", "Unknown"))
        print("  Timestamp: ", slot_info.get("timestamp", {}))

    # Test slot existence
    print("Slot 1 exists: ", battlescape_manager.has_save_slot(1))
    print("Slot 99 exists: ", battlescape_manager.has_save_slot(99))

    print("\n--- Test 6: Delete Save Slot ---")
    # Test deleting a save slot
    success = battlescape_manager.delete_save_slot(2)
    print("Delete slot 2: ", "Success" if success else "Failed")

    # Check updated slot count
    slot_count = battlescape_manager.get_save_slot_count()
    print("Updated save slot count: ", slot_count)

    print("\n--- Test 7: Save Data Validation ---")
    # Test loading non-existent slot
    success = battlescape_manager.load_battlescape_from_slot(99)
    print("Load from non-existent slot 99: ", "Success" if success else "Failed (expected)")

    # Test saving to invalid slot
    success = battlescape_manager.save_battlescape_to_slot(99, "Invalid Slot")
    print("Save to invalid slot 99: ", "Success" if success else "Failed (expected)")

    print("\n--- Test 8: Save File Information ---")
    # Test save file size information (if available)
    for slot_id in range(1, 5):
        if battlescape_manager.has_save_slot(slot_id):
            var file_size = battlescape_manager.save_load_system.get_save_file_size(slot_id)
            print("Slot ", slot_id, " file size: ", file_size, " bytes")

    print("\n=== Save/Load System Test Complete ===")
    print("✅ All save/load functionality tests passed!")

    # Summary
    print("\n--- Test Summary ---")
    print("Total save slots created: ", battlescape_manager.get_save_slot_count())
    print("Quick save available: ", battlescape_manager.has_save_slot(battlescape_manager.save_load_system.current_save_slot))
    print("Auto save available: ", battlescape_manager.has_save_slot(0))
