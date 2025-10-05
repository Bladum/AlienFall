extends "res://scripts/tests/test_base.gd"

# TestEconomySystem - Tests for purchase and transfer system
# Ensures deterministic behavior and proper event publishing

class_name TestEconomySystem

var event_received = false
var received_event_data = {}

func _ready():
    """Run all tests when the scene is ready"""
    run_all_tests()
    get_tree().quit()  # Exit after tests complete

func test_purchase_order_lifecycle():
    """Test complete purchase order lifecycle"""
    # Setup
    var base_id = "test_base_1"
    var entry_id = "test_item_1"
    var quantity = 5
    var total_cost = 1000
    var delivery_time = 3

    # Mock marketplace data
    var marketplace_data = {
        "test_item_1": {
            "price": 200,
            "delivery_time": 3,
            "monthly_stock": 10
        }
    }

    PurchaseSystem.load_marketplace_data(marketplace_data)

    # Ensure sufficient funds
    GameState.add_funding(2000)

    # Place order
    var success = PurchaseSystem.make_purchase(base_id, entry_id, quantity)
    assert_true(success, "Purchase should succeed")

    # Verify order was created
    var orders = PurchaseSystem.get_purchase_manager().get_active_orders_for_base(base_id)
    assert_eq(orders.size(), 1, "Should have one active order")

    var order = orders[0]
    assert_eq(order.entry_id, entry_id, "Order should have correct entry ID")
    assert_eq(order.quantity, quantity, "Order should have correct quantity")
    assert_eq(order.total_cost, total_cost, "Order should have correct total cost")
    assert_eq(order.days_remaining, delivery_time, "Order should have correct delivery time")

    # Advance time to deliver order
    for i in range(delivery_time):
        TimeService.advance_day()

    # Verify order was delivered
    orders = PurchaseSystem.get_purchase_manager().get_active_orders_for_base(base_id)
    assert_eq(orders.size(), 0, "Order should be delivered")

func test_transfer_creation_and_delivery():
    """Test transfer creation and delivery"""
    # Setup
    var origin_base = "base_a"
    var destination_base = "base_b"
    var payload = [
        {"type": "item", "id": "alloy", "quantity": 10, "volume": 5},
        {"type": "unit", "id": "soldier", "size": 2}
    ]

    # Create transfer
    var transfer = PurchaseSystem.create_transfer(origin_base, destination_base, payload)

    assert_not_null(transfer, "Transfer should be created successfully")
    assert_eq(transfer.origin_base, origin_base, "Transfer should have correct origin")
    assert_eq(transfer.destination_base, destination_base, "Transfer should have correct destination")
    assert_eq(transfer.payload.size(), payload.size(), "Transfer should have correct payload size")

    # Verify transfer is active
    var active_transfers = PurchaseSystem.get_transfer_manager().get_active_transfers_for_base(destination_base)
    assert_eq(active_transfers.size(), 1, "Should have one active transfer")

    # Advance time to deliver transfer
    var transit_days = transfer.original_transit_days
    for i in range(transit_days):
        TimeService.advance_day()

    # Verify transfer was delivered
    active_transfers = PurchaseSystem.get_transfer_manager().get_active_transfers_for_base(destination_base)
    assert_eq(active_transfers.size(), 0, "Transfer should be delivered")

func test_deterministic_behavior():
    """Test that same inputs produce same results"""
    # Setup
    RNGService.set_seed(12345)
    var base_id = "test_base"
    var entry_id = "test_item"

    var marketplace_data = {
        "test_item": {
            "price": 100,
            "delivery_time": 2,
            "monthly_stock": 5
        }
    }

    PurchaseSystem.load_marketplace_data(marketplace_data)
    GameState.add_funding(1000)

    # First run
    var success1 = PurchaseSystem.make_purchase(base_id, entry_id, 2)
    var orders1 = PurchaseSystem.get_purchase_manager().get_active_orders_for_base(base_id)
    var order_id1 = orders1[0].id if orders1.size() > 0 else ""

    # Reset and run again with same seed
    PurchaseSystem.get_purchase_manager().active_orders.clear()
    RNGService.set_seed(12345)
    GameState.add_funding(1000)

    var success2 = PurchaseSystem.make_purchase(base_id, entry_id, 2)
    var orders2 = PurchaseSystem.get_purchase_manager().get_active_orders_for_base(base_id)
    var order_id2 = orders2[0].id if orders2.size() > 0 else ""

    # Results should be identical
    assert_eq(success1, success2, "Purchase results should be identical")
    assert_eq(order_id1, order_id2, "Order IDs should be identical")

func test_stock_limits():
    """Test monthly stock limits"""
    var marketplace_data = {
        "limited_item": {
            "price": 50,
            "delivery_time": 1,
            "monthly_stock": 3
        }
    }

    PurchaseSystem.load_marketplace_data(marketplace_data)
    GameState.add_funding(1000)

    # First purchase should succeed
    var success1 = PurchaseSystem.make_purchase("base1", "limited_item", 2)
    assert_true(success1, "First purchase should succeed")

    # Second purchase should fail (exceeds stock)
    var success2 = PurchaseSystem.make_purchase("base1", "limited_item", 2)
    assert_false(success2, "Second purchase should fail due to stock limit")

func test_event_publishing():
    """Test that events are properly published"""
    event_received = false
    received_event_data = {}

    # Subscribe to purchase event
    var callable = Callable(self, "_on_purchase_event")
    EventBus.subscribe("purchase_order_placed", callable)

    # Make purchase
    var marketplace_data = {"test": {"price": 100, "delivery_time": 1}}
    PurchaseSystem.load_marketplace_data(marketplace_data)
    GameState.add_funding(200)

    PurchaseSystem.make_purchase("base1", "test", 1)

    # Verify event was received
    assert_true(event_received, "Purchase event should be published")
    if event_received and received_event_data.has("entry_id"):
        assert_eq(received_event_data.entry_id, "test", "Event should contain correct entry ID")

    # Clean up
    EventBus.unsubscribe("purchase_order_placed", callable)

func _on_purchase_event(data):
    """Event handler for testing"""
    event_received = true
    received_event_data = data

func run_all_tests():
    """Run all economy system tests"""
    print("\n=== Running Economy System Tests ===")

    test_purchase_order_lifecycle()
    print("✓ Purchase order lifecycle test passed")

    test_transfer_creation_and_delivery()
    print("✓ Transfer creation and delivery test passed")

    test_deterministic_behavior()
    print("✓ Deterministic behavior test passed")

    test_stock_limits()
    print("✓ Stock limits test passed")

    test_event_publishing()
    print("✓ Event publishing test passed")

    print("=== All Economy System Tests Passed ===")
