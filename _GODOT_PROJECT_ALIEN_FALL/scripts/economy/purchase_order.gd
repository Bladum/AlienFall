extends RefCounted

# PurchaseOrder - Represents a single purchase order
# Tracks delivery progress and order details

var id: String
var base_id: String
var entry_id: String
var quantity: int
var total_cost: int
var original_delivery_time: int
var days_remaining: int
var supplier: String
var delivery_contents
var status: String = "pending"  # pending, in_transit, delivered, cancelled
var placed_at: int  # timestamp

func _init(base_id: String, entry_id: String, quantity: int,
          total_cost: int, delivery_time: int,
          supplier: String = "", delivery_contents = null):
    self.id = generate_order_id()
    self.base_id = base_id
    self.entry_id = entry_id
    self.quantity = quantity
    self.total_cost = total_cost
    self.original_delivery_time = delivery_time
    self.days_remaining = delivery_time
    self.supplier = supplier
    self.delivery_contents = delivery_contents
    self.placed_at = Time.get_unix_time_from_system()

func generate_order_id() -> String:
    """Generate a unique order ID"""
    var timestamp = str(Time.get_unix_time_from_system())
    var random_part = str(randi() % 10000).pad_zeros(4)
    return "PO_" + timestamp + "_" + random_part

func is_delivered() -> bool:
    """Check if order has been delivered"""
    return status == "delivered"

func is_overdue() -> bool:
    """Check if order is overdue"""
    return days_remaining < 0 and status == "in_transit"

func get_progress_percentage() -> float:
    """Get delivery progress as percentage"""
    if original_delivery_time <= 0:
        return 100.0
    var elapsed = original_delivery_time - days_remaining
    return clamp((elapsed / float(original_delivery_time)) * 100.0, 0.0, 100.0)

func to_dict() -> Dictionary:
    """Convert order to dictionary for serialization"""
    return {
        "id": id,
        "base_id": base_id,
        "entry_id": entry_id,
        "quantity": quantity,
        "total_cost": total_cost,
        "original_delivery_time": original_delivery_time,
        "days_remaining": days_remaining,
        "supplier": supplier,
        "status": status,
        "placed_at": placed_at
    }

static func from_dict(data: Dictionary) -> PurchaseOrder:
    """Create order from dictionary"""
    var order = PurchaseOrder.new(
        data.base_id,
        data.entry_id,
        data.quantity,
        data.total_cost,
        data.original_delivery_time,
        data.supplier,
        data.delivery_contents
    )
    order.id = data.id
    order.days_remaining = data.days_remaining
    order.status = data.status
    order.placed_at = data.placed_at
    return order
