extends RefCounted

# Transfer - Represents a transfer of items, crafts, or units between bases

var id: String
var origin_base: String
var destination_base: String
var payload: Array  # Array of payload items
var transport_craft_id: String
var transfer_cost: int
var original_transit_days: int
var days_remaining: int
var priority: int
var status: String = "in_transit"  # in_transit, delivered, cancelled
var created_at: int

func _init(origin_base: String, destination_base: String, payload: Array,
          transport_craft_id: String = "", transfer_cost: int = 0,
          transit_days: int = 1, priority: int = 0):
    self.id = generate_transfer_id()
    self.origin_base = origin_base
    self.destination_base = destination_base
    self.payload = payload
    self.transport_craft_id = transport_craft_id
    self.transfer_cost = transfer_cost
    self.original_transit_days = transit_days
    self.days_remaining = transit_days
    self.priority = priority
    self.created_at = Time.get_unix_time_from_system()

func generate_transfer_id() -> String:
    """Generate a unique transfer ID"""
    var timestamp = str(Time.get_unix_time_from_system())
    var random_part = str(randi() % 10000).pad_zeros(4)
    return "TR_" + timestamp + "_" + random_part

func is_delivered() -> bool:
    """Check if transfer has been delivered"""
    return status == "delivered"

func is_overdue() -> bool:
    """Check if transfer is overdue"""
    return days_remaining < 0 and status == "in_transit"

func get_progress_percentage() -> float:
    """Get delivery progress as percentage"""
    if original_transit_days <= 0:
        return 100.0
    var elapsed = original_transit_days - days_remaining
    return clamp((elapsed / float(original_transit_days)) * 100.0, 0.0, 100.0)

func get_total_units() -> int:
    """Get total unit size of payload"""
    var total = 0
    for item in payload:
        if item.has("size"):
            total += item.size
        elif item.has("quantity"):
            total += item.quantity
    return total

func get_total_volume() -> int:
    """Get total volume of payload"""
    var total = 0
    for item in payload:
        if item.has("volume"):
            total += item.volume * (item.quantity if item.has("quantity") else 1)
    return total

func to_dict() -> Dictionary:
    """Convert transfer to dictionary for serialization"""
    return {
        "id": id,
        "origin_base": origin_base,
        "destination_base": destination_base,
        "payload": payload,
        "transport_craft_id": transport_craft_id,
        "transfer_cost": transfer_cost,
        "original_transit_days": original_transit_days,
        "days_remaining": days_remaining,
        "priority": priority,
        "status": status,
        "created_at": created_at
    }

static func from_dict(data: Dictionary) -> Transfer:
    """Create transfer from dictionary"""
    var transfer = Transfer.new(
        data.origin_base,
        data.destination_base,
        data.payload,
        data.transport_craft_id,
        data.transfer_cost,
        data.original_transit_days,
        data.priority
    )
    transfer.id = data.id
    transfer.days_remaining = data.days_remaining
    transfer.status = data.status
    transfer.created_at = data.created_at
    return transfer
