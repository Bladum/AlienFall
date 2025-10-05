class_name Base
extends Node

# Base - Represents a player base with facilities and personnel

var base_id: String
var name: String
var location: Vector2  # World coordinates
var facilities: Array[Facility] = []
var personnel: Array[Unit] = []
var construction_queue: Array = []  # Facilities being built

# Base stats
var power_generation: int = 0
var power_consumption: int = 0
var storage_capacity: int = 0
var living_quarters: int = 0

func _init(base_name: String = "Base", base_location: Vector2 = Vector2.ZERO):
    base_id = "base_" + str(randi())
    name = base_name
    location = base_location

func add_facility(facility: Facility) -> bool:
    # Check if we have space and resources
    if facilities.size() >= 6:  # Max 6 facilities per base
        return false
    
    facilities.append(facility)
    _update_base_stats()
    return true

func remove_facility(facility: Facility) -> bool:
    if facilities.has(facility):
        facilities.erase(facility)
        _update_base_stats()
        return true
    return false

func add_personnel(unit: Unit) -> bool:
    # Check living quarters capacity
    if personnel.size() >= living_quarters:
        return false
    
    personnel.append(unit)
    return true

func remove_personnel(unit: Unit) -> bool:
    if personnel.has(unit):
        personnel.erase(unit)
        return true
    return false

func get_scientists() -> Array[Unit]:
    return personnel.filter(func(unit): return unit.role == "scientist")

func get_engineers() -> Array[Unit]:
    return personnel.filter(func(unit): return unit.role == "engineer")

func get_soldiers() -> Array[Unit]:
    return personnel.filter(func(unit): return unit.role == "soldier")

func get_available_personnel() -> Array[Unit]:
    return personnel.filter(func(unit): return unit.assigned_facility == null)

func get_power_status() -> Dictionary:
    return {
        "generation": power_generation,
        "consumption": power_consumption,
        "surplus": power_generation - power_consumption,
        "has_power": power_generation >= power_consumption
    }

func get_storage_status() -> Dictionary:
    var used_storage = 0
    # Calculate used storage from items (would need inventory system)
    return {
        "capacity": storage_capacity,
        "used": used_storage,
        "available": storage_capacity - used_storage
    }

func _update_base_stats():
    power_generation = 0
    power_consumption = 0
    storage_capacity = 0
    living_quarters = 0
    
    for facility in facilities:
        power_generation += facility.power_generation
        power_consumption += facility.power_consumption
        storage_capacity += facility.storage_capacity
        living_quarters += facility.living_quarters

func to_dict() -> Dictionary:
    var facility_ids = []
    for facility in facilities:
        facility_ids.append(facility.facility_id)
    
    var personnel_ids = []
    for unit in personnel:
        personnel_ids.append(unit.unit_id)
    
    return {
        "base_id": base_id,
        "name": name,
        "location": {"x": location.x, "y": location.y},
        "facilities": facility_ids,
        "personnel": personnel_ids,
        "construction_queue": construction_queue
    }

static func from_dict(data: Dictionary) -> Base:
    var base = Base.new(data.name, Vector2(data.location.x, data.location.y))
    base.base_id = data.base_id
    base.construction_queue = data.get("construction_queue", [])
    return base
