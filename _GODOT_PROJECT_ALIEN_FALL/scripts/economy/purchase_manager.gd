extends Node

# PurchaseManager - Manages purchase orders and delivery scheduling
# Integrates with EventBus for deterministic economy operations

var active_orders = {}  # base_id -> Array[PurchaseOrder]
var completed_orders = []
var monthly_purchases = {}  # month_year -> {entry_id: quantity}

signal order_placed(order: PurchaseOrder)
signal order_delivered(order: PurchaseOrder)
signal monthly_restock_occurred

func _ready():
    # Subscribe to TimeService events
    if TimeService:
        TimeService.connect("daily_tick", Callable(self, "_on_daily_tick"))
        TimeService.connect("monthly_tick", Callable(self, "_on_monthly_tick"))

func place_order(base_id: String, entry_id: String, quantity: int,
                total_cost: int, delivery_time: int,
                supplier: String = "", delivery_contents = null) -> PurchaseOrder:
    """Place a new purchase order"""
    var order = PurchaseOrder.new(base_id, entry_id, quantity,
                                 total_cost, delivery_time, supplier, delivery_contents)

    if not active_orders.has(base_id):
        active_orders[base_id] = []

    active_orders[base_id].append(order)

    # Track monthly purchases for limits
    var current_month = TimeService.get_current_month_string()
    if not monthly_purchases.has(current_month):
        monthly_purchases[current_month] = {}

    if monthly_purchases[current_month].has(entry_id):
        monthly_purchases[current_month][entry_id] += quantity
    else:
        monthly_purchases[current_month][entry_id] = quantity

    # Publish event
    EventBus.publish("purchase_order_placed", {
        "order_id": order.id,
        "base_id": base_id,
        "entry_id": entry_id,
        "quantity": quantity,
        "total_cost": total_cost,
        "delivery_time": delivery_time
    })

    emit_signal("order_placed", order)
    return order

func _on_daily_tick():
    """Process daily delivery progression"""
    for base_id in active_orders.keys():
        var orders_to_remove = []
        for order in active_orders[base_id]:
            order.days_remaining -= 1

            if order.days_remaining <= 0:
                _deliver_order(order)
                orders_to_remove.append(order)

        # Remove delivered orders
        for order in orders_to_remove:
            active_orders[base_id].erase(order)

func _on_monthly_tick():
    """Handle monthly restocking"""
    # Clear monthly purchase tracking for new month
    var current_month = TimeService.get_current_month_string()
    monthly_purchases[current_month] = {}

    # Publish restock event
    EventBus.publish("monthly_restock", {
        "month": current_month
    })

    emit_signal("monthly_restock_occurred")

func _deliver_order(order: PurchaseOrder):
    """Deliver a completed order"""
    completed_orders.append(order)

    # Publish delivery event
    EventBus.publish("purchase_order_delivered", {
        "order_id": order.id,
        "base_id": order.base_id,
        "entry_id": order.entry_id,
        "quantity": order.quantity,
        "actual_delivery_time": order.original_delivery_time - order.days_remaining
    })

    emit_signal("order_delivered", order)

func get_active_orders_for_base(base_id: String) -> Array:
    """Get all active orders for a specific base"""
    if active_orders.has(base_id):
        return active_orders[base_id]
    return []

func get_monthly_purchase_count(entry_id: String, month: String = "") -> int:
    """Get purchase count for an entry in a specific month"""
    if month == "":
        month = TimeService.get_current_month_string()

    if monthly_purchases.has(month) and monthly_purchases[month].has(entry_id):
        return monthly_purchases[month][entry_id]
    return 0

func cancel_order(base_id: String, order_id: String) -> bool:
    """Cancel an active order"""
    if not active_orders.has(base_id):
        return false

    for i in range(active_orders[base_id].size()):
        if active_orders[base_id][i].id == order_id:
            var order = active_orders[base_id][i]
            active_orders[base_id].remove_at(i)

            # Publish cancellation event
            EventBus.publish("purchase_order_cancelled", {
                "order_id": order_id,
                "base_id": base_id,
                "refund_amount": order.total_cost * 0.5  # 50% refund
            })

            return true

    return false
