extends Resource
class_name Facility

# Facility - Represents base buildings and installations
# Core domain class for base construction and management

@export var id: String = ""
@export var facility_id: String = ""  # Alias for id for compatibility
@export var name: String = ""
@export var type: String = ""  # living, science, engineering, etc.

# Physical properties
@export var footprint: Dictionary = {
    "width": 1,
    "height": 1
}

# Capacities provided
@export var capacities: Dictionary = {}  # capacity_name -> amount

# Services provided
@export var services: Dictionary = {}  # service_name -> amount

# Build requirements
@export var build_cost: int = 0
@export var build_time: int = 1  # in days
@export var maintenance_cost: int = 0  # per month

# Operational requirements
@export var power_required: int = 0
@export var staff_required: Dictionary = {}  # staff_type -> count

# Power generation (for power plants)
@export var power_generation: int = 0

# Storage capacity (for storage facilities)
@export var storage_capacity: int = 0

# Living quarters (for living facilities)
@export var living_quarters: int = 0

# Research requirements
@export var research_required: Array = []

# Special properties
@export var special_properties: Array = []
@export var description: String = ""

# Visual
@export var sprite_path: String = ""
@export var icon_path: String = ""

func _init(facility_id: String = "", facility_name: String = ""):
    id = facility_id
    self.facility_id = facility_id
    name = facility_name

# Create facility from data dictionary
static func from_data(data: Dictionary) -> Facility:
    var facility = Facility.new(data.get("id", ""), data.get("name", ""))
    facility.facility_id = data.get("id", "")  # Ensure facility_id is set
    
    facility.type = data.get("type", "")
    
    if data.has("footprint"):
        facility.footprint = data.footprint.duplicate()
    
    if data.has("capacities"):
        facility.capacities = data.capacities.duplicate()
    
    if data.has("services"):
        facility.services = data.services.duplicate()
    
    facility.build_cost = data.get("build_cost", 0)
    facility.build_time = data.get("build_time", 1)
    facility.maintenance_cost = data.get("maintenance_cost", 0)
    
    facility.power_required = data.get("power_required", 0)
    facility.power_generation = data.get("power_generation", 0)
    facility.storage_capacity = data.get("storage_capacity", 0)
    facility.living_quarters = data.get("living_quarters", 0)
    
    if data.has("staff_required"):
        facility.staff_required = data.staff_required.duplicate()
    
    if data.has("research_required"):
        facility.research_required = data.research_required.duplicate()
    
    if data.has("special_properties"):
        facility.special_properties = data.special_properties.duplicate()
    
    facility.description = data.get("description", "")
    facility.sprite_path = data.get("sprite_path", "")
    facility.icon_path = data.get("icon_path", "")
    
    return facility

# Convert facility to dictionary
func to_dict() -> Dictionary:
    return {
        "id": id,
        "facility_id": facility_id,
        "name": name,
        "type": type,
        "footprint": footprint.duplicate(),
        "capacities": capacities.duplicate(),
        "services": services.duplicate(),
        "build_cost": build_cost,
        "build_time": build_time,
        "maintenance_cost": maintenance_cost,
        "power_required": power_required,
        "power_generation": power_generation,
        "storage_capacity": storage_capacity,
        "living_quarters": living_quarters,
        "staff_required": staff_required.duplicate(),
        "research_required": research_required.duplicate(),
        "special_properties": special_properties.duplicate(),
        "description": description,
        "sprite_path": sprite_path,
        "icon_path": icon_path
    }

# Get footprint size
func get_width() -> int:
    return footprint.get("width", 1)

func get_height() -> int:
    return footprint.get("height", 1)

func get_area() -> int:
    return get_width() * get_height()

# Get capacity amount
func get_capacity(capacity_name: String) -> int:
    return capacities.get(capacity_name, 0)

# Get service amount
func get_service(service_name: String) -> int:
    return services.get(service_name, 0)

# Check if facility provides specific capacity
func provides_capacity(capacity_name: String) -> bool:
    return capacity_name in capacities

# Check if facility provides specific service
func provides_service(service_name: String) -> bool:
    return service_name in services

# Get total capacity value (sum of all capacities)
func get_total_capacity_value() -> int:
    var total = 0
    for amount in capacities.values():
        total += amount
    return total

# Get total service value (sum of all services)
func get_total_service_value() -> int:
    var total = 0
    for amount in services.values():
        total += amount
    return total

# Check if facility has a specific property
func has_property(property_name: String) -> bool:
    return property_name in special_properties

# Get staff requirement for specific type
func get_staff_requirement(staff_type: String) -> int:
    return staff_required.get(staff_type, 0)

# Get total staff required
func get_total_staff_required() -> int:
    var total = 0
    for count in staff_required.values():
        total += count
    return total

# Check if facility is operational (has required staff and power)
func is_operational(available_staff: Dictionary, available_power: int) -> bool:
    # Check power requirement
    if power_required > available_power:
        return false
    
    # Check staff requirements
    for staff_type in staff_required:
        var required = staff_required[staff_type]
        var available = available_staff.get(staff_type, 0)
        if available < required:
            return false
    
    return true

# Get operational efficiency (0.0 to 1.0)
func get_operational_efficiency(available_staff: Dictionary, available_power: int) -> float:
    if power_required == 0 and staff_required.is_empty():
        return 1.0  # No requirements = always operational
    
    var power_efficiency = 1.0
    if power_required > 0:
        power_efficiency = min(1.0, float(available_power) / power_required)
    
    var staff_efficiency = 1.0
    if not staff_required.is_empty():
        var total_required = get_total_staff_required()
        var total_available = 0
        
        for staff_type in staff_required:
            var required = staff_required[staff_type]
            var available = available_staff.get(staff_type, 0)
            total_available += min(available, required)
        
        if total_required > 0:
            staff_efficiency = float(total_available) / total_required
    
    return min(power_efficiency, staff_efficiency)

# Get build progress (for construction)
func get_build_progress(current_days: int) -> float:
    if build_time <= 0:
        return 1.0
    return min(1.0, float(current_days) / build_time)

# Check if construction is complete
func is_construction_complete(current_days: int) -> bool:
    return current_days >= build_time

# Get remaining build time
func get_remaining_build_time(current_days: int) -> int:
    return max(0, build_time - current_days)

# Calculate monthly operational cost
func get_monthly_cost() -> int:
    return maintenance_cost

# Check if facility can be built (research requirements met)
func can_build(completed_research: Array) -> bool:
    for research_id in research_required:
        if not (research_id in completed_research):
            return false
    return true

# Get list of missing research requirements
func get_missing_research(completed_research: Array) -> Array:
    var missing = []
    for research_id in research_required:
        if not (research_id in completed_research):
            missing.append(research_id)
    return missing
