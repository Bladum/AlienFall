extends Node

# PurchaseSystem - Main interface for the economy system
# Integrates purchases, transfers, and marketplace functionality

var purchase_manager: PurchaseManager
var transfer_manager: TransferManager
var marketplace_entries = {}  # entry_id -> marketplace data

signal purchase_completed(order: PurchaseOrder)
signal transfer_completed(transfer: Transfer)

func _ready():
    # Initialize subsystems
    purchase_manager = PurchaseManager.new()
    transfer_manager = TransferManager.new()

    add_child(purchase_manager)
    add_child(transfer_manager)

    # Connect signals
    purchase_manager.connect("order_delivered", Callable(self, "_on_purchase_delivered"))
    transfer_manager.connect("transfer_delivered", Callable(self, "_on_transfer_delivered"))

    # Subscribe to TimeService events
    if TimeService:
        TimeService.connect("monthly_tick", Callable(self, "_on_monthly_tick"))

    print("PurchaseSystem initialized")

func load_marketplace_data(data: Dictionary):
    """Load marketplace configuration data"""
    marketplace_entries = data
    print("Loaded ", marketplace_entries.size(), " marketplace entries")

func make_purchase(base_id: String, entry_id: String, quantity: int) -> bool:
    """Make a purchase from the marketplace"""
    if not marketplace_entries.has(entry_id):
        push_error("Purchase entry not found: " + entry_id)
        return false

    var entry = marketplace_entries[entry_id]

    # Check prerequisites
    if not _check_prerequisites(entry, base_id):
        push_error("Prerequisites not met for purchase: " + entry_id)
        return false

    # Check stock limits
    if not _check_stock_limits(entry, quantity):
        push_error("Stock limit exceeded for purchase: " + entry_id)
        return false

    # Check funding
    var total_cost = entry.price * quantity
    if GameState.get_funding() < total_cost:
        push_error("Insufficient funds for purchase: " + entry_id)
        return false

    # Deduct cost
    GameState.modify_funding(-total_cost)

    # Create purchase order
    var delivery_time = entry.delivery_time if entry.has("delivery_time") else 7
    var order = purchase_manager.place_order(
        base_id, entry_id, quantity, total_cost, delivery_time, "market"
    )

    if order:
        # Update stock
        if entry.has("monthly_stock"):
            entry.current_stock = max(0, entry.current_stock - quantity)

        # Publish purchase event
        EventBus.publish("purchase_made", {
            "base_id": base_id,
            "entry_id": entry_id,
            "quantity": quantity,
            "total_cost": total_cost,
            "delivery_time": delivery_time
        })

        return true

    return false

func create_transfer(origin_base: String, destination_base: String,
                    payload: Array, transport_craft_id: String = "") -> Transfer:
    """Create a transfer between bases"""
    return transfer_manager.create_transfer(
        origin_base, destination_base, payload, transport_craft_id
    )

func sell_item(base_id: String, item_id: String, quantity: int) -> bool:
    """Sell items from base inventory"""
    # TODO: Implement selling logic
    # This would check base inventory, calculate sell price, add funds, etc.

    EventBus.publish("item_sold", {
        "base_id": base_id,
        "item_id": item_id,
        "quantity": quantity
    })

    return true

func get_available_entries(base_id: String = "") -> Array:
    """Get marketplace entries available to a base"""
    var available = []

    for entry_id in marketplace_entries.keys():
        var entry = marketplace_entries[entry_id]

        if _check_prerequisites(entry, base_id) and _check_stock_limits(entry, 1):
            available.append(entry)

    return available

func _check_prerequisites(entry: Dictionary, base_id: String) -> bool:
    """Check if prerequisites are met for an entry"""
    if not entry.has("prerequisites"):
        return true

    var prereqs = entry.prerequisites

    # Check research requirements
    if prereqs.has("research"):
        for research_id in prereqs.research:
            if not GameState.is_research_completed(research_id):
                return false

    # Check region restrictions
    if prereqs.has("regions") and base_id != "":
        var base_region = _get_base_region(base_id)
        if not prereqs.regions.has(base_region):
            return false

    return true

func _check_stock_limits(entry: Dictionary, quantity: int) -> bool:
    """Check if stock limits allow the purchase"""
    if not entry.has("monthly_stock"):
        return true

    if not entry.has("current_stock"):
        entry.current_stock = entry.monthly_stock

    return entry.current_stock >= quantity

func _get_base_region(base_id: String) -> String:
    """Get the region a base is located in"""
    # TODO: Implement actual base region lookup
    return "north_america"

func _on_purchase_delivered(order: PurchaseOrder):
    """Handle purchase delivery"""
    emit_signal("purchase_completed", order)

func _on_transfer_delivered(transfer: Transfer):
    """Handle transfer delivery"""
    emit_signal("transfer_completed", transfer)

func _on_monthly_tick():
    """Handle monthly restocking"""
    # Restock marketplace entries
    for entry_id in marketplace_entries.keys():
        var entry = marketplace_entries[entry_id]
        if entry.has("monthly_stock"):
            entry.current_stock = entry.monthly_stock

    EventBus.publish("marketplace_restocked", {
        "entries_restocked": marketplace_entries.size()
    })

# Helper methods for testing
func get_purchase_manager() -> PurchaseManager:
    """Get the purchase manager (for testing)"""
    return purchase_manager

func get_transfer_manager() -> TransferManager:
    """Get the transfer manager (for testing)"""
    return transfer_manager
