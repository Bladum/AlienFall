extends Node

# TransferManager - Manages item, craft, and unit transfers between bases
# Handles delivery scheduling, capacity validation, and cost calculation

var active_transfers = {}  # base_id -> Array[Transfer]
var completed_transfers = []

signal transfer_started(transfer: Transfer)
signal transfer_delivered(transfer: Transfer)
signal transfer_cancelled(transfer: Transfer)

func _ready():
    # Subscribe to TimeService events
    if TimeService:
        TimeService.connect("daily_tick", Callable(self, "_on_daily_tick"))

func create_transfer(origin_base: String, destination_base: String,
                    payload: Array, transport_craft_id: String = "",
                    priority: int = 0) -> Transfer:
    """Create a new transfer between bases"""

    # Calculate transfer cost and time
    var transfer_cost = _calculate_transfer_cost(origin_base, destination_base, payload)
    var transit_days = _calculate_transit_time(origin_base, destination_base)

    var transfer = Transfer.new(origin_base, destination_base, payload,
                               transport_craft_id, transfer_cost, transit_days, priority)

    # Validate capacity if transport is specified
    if transport_craft_id != "":
        if not _validate_transport_capacity(transport_craft_id, payload):
            push_error("Transfer validation failed: Transport capacity exceeded")
            return null

    # Add to active transfers
    if not active_transfers.has(destination_base):
        active_transfers[destination_base] = []

    active_transfers[destination_base].append(transfer)

    # Publish event
    EventBus.publish("transfer_created", {
        "transfer_id": transfer.id,
        "origin_base": origin_base,
        "destination_base": destination_base,
        "payload_count": payload.size(),
        "transfer_cost": transfer_cost,
        "transit_days": transit_days
    })

    emit_signal("transfer_started", transfer)
    return transfer

func _on_daily_tick():
    """Process daily transfer progression"""
    for base_id in active_transfers.keys():
        var transfers_to_remove = []
        for transfer in active_transfers[base_id]:
            transfer.days_remaining -= 1

            if transfer.days_remaining <= 0:
                _deliver_transfer(transfer)
                transfers_to_remove.append(transfer)

        # Remove delivered transfers
        for transfer in transfers_to_remove:
            active_transfers[base_id].erase(transfer)

func _deliver_transfer(transfer: Transfer):
    """Deliver a completed transfer"""
    transfer.status = "delivered"
    completed_transfers.append(transfer)

    # Publish delivery event
    EventBus.publish("transfer_delivered", {
        "transfer_id": transfer.id,
        "origin_base": transfer.origin_base,
        "destination_base": transfer.destination_base,
        "payload_count": transfer.payload.size(),
        "actual_delivery_time": transfer.original_transit_days - transfer.days_remaining
    })

    emit_signal("transfer_delivered", transfer)

func _calculate_transfer_cost(origin_base: String, destination_base: String, payload: Array) -> int:
    """Calculate transfer cost based on distance and payload"""
    var distance = _get_distance_between_bases(origin_base, destination_base)

    var unit_cost = 0
    var item_cost = 0

    for item in payload:
        if item.type == "unit":
            unit_cost += item.size * 100  # Configurable cost factor
        elif item.type == "item":
            item_cost += item.volume * 10  # Configurable cost factor

    var base_cost = 500  # Base fixed cost
    return distance * (unit_cost + item_cost) + base_cost

func _calculate_transit_time(origin_base: String, destination_base: String) -> int:
    """Calculate transit time based on distance"""
    var distance = _get_distance_between_bases(origin_base, destination_base)
    var days_per_province = 2  # Configurable
    var fixed_overhead = 1  # Fixed overhead days

    return distance * days_per_province + fixed_overhead

func _get_distance_between_bases(base_a: String, base_b: String) -> int:
    """Get distance between two bases in provinces"""
    # TODO: Implement actual distance calculation based on base locations
    # For now, return a default distance
    return 3

func _validate_transport_capacity(transport_id: String, payload: Array) -> bool:
    """Validate that transport can carry the payload"""
    # TODO: Implement actual capacity validation
    # For now, assume capacity is sufficient
    return true

func get_active_transfers_for_base(base_id: String) -> Array:
    """Get all active transfers for a specific base"""
    if active_transfers.has(base_id):
        return active_transfers[base_id]
    return []

func cancel_transfer(base_id: String, transfer_id: String) -> bool:
    """Cancel an active transfer"""
    if not active_transfers.has(base_id):
        return false

    for i in range(active_transfers[base_id].size()):
        if active_transfers[base_id][i].id == transfer_id:
            var transfer = active_transfers[base_id][i]
            active_transfers[base_id].remove_at(i)

            transfer.status = "cancelled"

            # Publish cancellation event
            EventBus.publish("transfer_cancelled", {
                "transfer_id": transfer_id,
                "origin_base": base_id,
                "refund_amount": transfer.transfer_cost * 0.3  # 30% refund
            })

            emit_signal("transfer_cancelled", transfer)
            return true

    return false
