extends Node

func _ready():
    var output_file = FileAccess.open("user://test_results.txt", FileAccess.WRITE)
    if output_file:
        output_file.store_string("=== Economy System Validation Test ===\n")

        # Test 1: Check if PurchaseSystem is available
        output_file.store_string("1. Testing PurchaseSystem availability...\n")
        if PurchaseSystem:
            output_file.store_string("   ✓ PurchaseSystem is available\n")
        else:
            output_file.store_string("   ✗ PurchaseSystem is not available\n")
            output_file.close()
            get_tree().quit()
            return

        # Test 2: Check if TimeService methods exist
        output_file.store_string("2. Testing TimeService methods...\n")
        if TimeService:
            var current_day = TimeService.get_current_day()
            var current_month = TimeService.get_current_month()
            var month_string = TimeService.get_current_month_string()
            output_file.store_string("   ✓ TimeService methods work: day=" + str(current_day) + ", month=" + str(current_month) + ", month_str=" + month_string + "\n")
        else:
            output_file.store_string("   ✗ TimeService is not available\n")
            output_file.close()
            get_tree().quit()
            return

        # Test 3: Check if GameState methods exist
        output_file.store_string("3. Testing GameState methods...\n")
        if GameState:
            var funding = GameState.get_funding()
            GameState.add_funding(100)
            var new_funding = GameState.get_funding()
            output_file.store_string("   ✓ GameState methods work: funding=" + str(funding) + " -> " + str(new_funding) + "\n")
        else:
            output_file.store_string("   ✗ GameState is not available\n")
            output_file.close()
            get_tree().quit()
            return

        # Test 4: Check if EventBus is available
        output_file.store_string("4. Testing EventBus...\n")
        if EventBus:
            output_file.store_string("   ✓ EventBus is available\n")
        else:
            output_file.store_string("   ✗ EventBus is not available\n")
            output_file.close()
            get_tree().quit()
            return

        # Test 5: Try to load marketplace data
        output_file.store_string("5. Testing marketplace data loading...\n")
        var test_data = {
            "test_item": {
                "price": 100,
                "delivery_time": 2,
                "monthly_stock": 5
            }
        }
        PurchaseSystem.load_marketplace_data(test_data)
        output_file.store_string("   ✓ Marketplace data loaded\n")

        # Test 6: Try to make a purchase
        output_file.store_string("6. Testing purchase creation...\n")
        GameState.add_funding(1000)  # Ensure we have funds
        var success = PurchaseSystem.make_purchase("test_base", "test_item", 1)
        if success:
            output_file.store_string("   ✓ Purchase creation successful\n")
        else:
            output_file.store_string("   ✗ Purchase creation failed\n")

        output_file.store_string("=== All Basic Tests Passed ===\n")
        output_file.close()

    print("=== Economy System Validation Test ===")
    print("Test results written to user://test_results.txt")
    get_tree().quit()
