extends Node

# BaseManager - Manages all player bases and their operations
# Autoload singleton for base management

var bases: Array[Base] = []
var base_templates: Dictionary = {}  # facility_id -> Facility template

signal base_added(base: Base)
signal base_removed(base: Base)
signal facility_constructed(base: Base, facility: Facility)
signal personnel_assigned(base: Base, unit: Unit, facility: Facility)
signal personnel_unassigned(base: Base, unit: Unit, facility: Facility)

func _ready():
    print("BaseManager: Initializing...")
    _load_base_templates()
    _create_initial_base()
    print("BaseManager: Ready")

func _load_base_templates():
    print("BaseManager: Loading facility templates...")
    
    # Load facility templates from data registry
    var facilities_data = DataRegistry.get_all_data("facilities")
    if facilities_data:
        for facility_id in facilities_data:
            var facility_data = facilities_data[facility_id]
            var facility = Facility.from_data(facility_data)
            base_templates[facility.facility_id] = facility
            print("BaseManager: Loaded facility template: ", facility.name)
    
    print("BaseManager: Loaded ", base_templates.size(), " facility templates")

func _create_initial_base():
    print("BaseManager: Creating initial base...")
    
    var initial_base = Base.new("Command Center", Vector2(400, 300))
    
    # Add basic facilities to initial base
    var living_quarters = _create_facility_from_template("living_quarters")
    var power_plant = _create_facility_from_template("power_plant")
    var command_center = _create_facility_from_template("command_center")
    
    if living_quarters:
        initial_base.add_facility(living_quarters)
    if power_plant:
        initial_base.add_facility(power_plant)
    if command_center:
        initial_base.add_facility(command_center)
    
    # Add initial personnel
    _add_initial_personnel(initial_base)
    
    add_base(initial_base)
    print("BaseManager: Initial base created with ", initial_base.facilities.size(), " facilities")

func _create_facility_from_template(template_id: String) -> Facility:
    if base_templates.has(template_id):
        var template = base_templates[template_id]
        var facility = Facility.new(template.id, template.name)
        facility.type = template.type
        facility.build_cost = template.build_cost
        facility.build_time = template.build_time
        facility.maintenance_cost = template.maintenance_cost
        facility.power_required = template.power_required
        facility.power_generation = template.power_generation
        facility.storage_capacity = template.storage_capacity
        facility.living_quarters = template.living_quarters
        facility.staff_required = template.staff_required.duplicate()
        facility.capacities = template.capacities.duplicate()
        facility.services = template.services.duplicate()
        facility.description = template.description
        return facility
    return null

func _add_initial_personnel(base: Base):
    # Add some initial personnel
    var scientist = Unit.new("scientist_001", "Dr. Sarah Chen")
    scientist.role = "scientist"
    scientist.race = "human"
    scientist.unit_class = "scientist"
    
    var engineer = Unit.new("engineer_001", "Tech Sgt. Mike Johnson")
    engineer.role = "engineer"
    engineer.race = "human"
    engineer.unit_class = "engineer"
    
    var soldier1 = Unit.new("soldier_001", "Sgt. Elena Rodriguez")
    soldier1.role = "soldier"
    soldier1.race = "human"
    soldier1.unit_class = "sniper"
    
    var soldier2 = Unit.new("soldier_002", "Cpl. David Kim")
    soldier2.role = "soldier"
    soldier2.race = "human"
    soldier2.unit_class = "assault"
    
    base.add_personnel(scientist)
    base.add_personnel(engineer)
    base.add_personnel(soldier1)
    base.add_personnel(soldier2)

func add_base(base: Base) -> bool:
    if bases.has(base):
        return false
    
    bases.append(base)
    emit_signal("base_added", base)
    print("BaseManager: Added base: ", base.name)
    return true

func remove_base(base: Base) -> bool:
    if bases.has(base):
        bases.erase(base)
        emit_signal("base_removed", base)
        print("BaseManager: Removed base: ", base.name)
        return true
    return false

func get_base_by_id(base_id: String) -> Base:
    for base in bases:
        if base.base_id == base_id:
            return base
    return null

func get_all_bases() -> Array[Base]:
    return bases.duplicate()

func get_main_base() -> Base:
    return bases[0] if bases.size() > 0 else null

func can_build_facility(base: Base, facility_template_id: String) -> bool:
    if not base_templates.has(facility_template_id):
        return false
    
    var template = base_templates[facility_template_id]
    
    # Check if base has space
    if base.facilities.size() >= 6:
        return false
    
    # Check build cost
    if template.build_cost > GameState.get_funding():
        return false
    
    # Check research requirements
    var completed_research = ResearchManager.get_completed_research()
    if not template.can_build(completed_research):
        return false
    
    return true

func build_facility(base: Base, facility_template_id: String) -> bool:
    if not can_build_facility(base, facility_template_id):
        return false
    
    var template = base_templates[facility_template_id]
    
    # Deduct cost
    GameState.modify_funding(-template.build_cost)
    
    # Create facility
    var facility = _create_facility_from_template(facility_template_id)
    
    # Add to construction queue
    base.construction_queue.append({
        "facility": facility,
        "remaining_days": template.build_time,
        "total_days": template.build_time
    })
    
    print("BaseManager: Started construction of ", facility.name, " in ", base.name)
    return true

func process_construction():
    for base in bases:
        var completed_facilities = []
        
        for construction in base.construction_queue:
            construction.remaining_days -= 1
            
            if construction.remaining_days <= 0:
                var facility = construction.facility
                base.add_facility(facility)
                completed_facilities.append(construction)
                emit_signal("facility_constructed", base, facility)
                print("BaseManager: Completed construction of ", facility.name, " in ", base.name)
        
        # Remove completed constructions
        for completed in completed_facilities:
            base.construction_queue.erase(completed)

func assign_personnel_to_facility(base: Base, unit: Unit, facility: Facility) -> bool:
    if not base.personnel.has(unit) or not base.facilities.has(facility):
        return false
    
    # Check if facility needs this type of personnel
    var required_staff = facility.get_staff_requirement(unit.role)
    if required_staff <= 0:
        return false
    
    # Check if facility already has enough staff
    var current_staff = 0
    for assigned_unit in base.personnel:
        if assigned_unit.assigned_facility == facility and assigned_unit.role == unit.role:
            current_staff += 1
    
    if current_staff >= required_staff:
        return false
    
    # Assign personnel
    unit.assigned_facility = facility
    emit_signal("personnel_assigned", base, unit, facility)
    print("BaseManager: Assigned ", unit.name, " to ", facility.name)
    return true

func unassign_personnel_from_facility(base: Base, unit: Unit) -> bool:
    if not base.personnel.has(unit) or unit.assigned_facility == null:
        return false
    
    var facility = unit.assigned_facility
    unit.assigned_facility = null
    emit_signal("personnel_unassigned", base, unit, facility)
    print("BaseManager: Unassigned ", unit.name, " from ", facility.name)
    return true

func get_total_personnel_count() -> int:
    var total = 0
    for base in bases:
        total += base.personnel.size()
    return total

func get_personnel_by_role(role: String) -> Array[Unit]:
    var personnel = []
    for base in bases:
        if role == "scientist":
            personnel.append_array(base.get_scientists())
        elif role == "engineer":
            personnel.append_array(base.get_engineers())
        elif role == "soldier":
            personnel.append_array(base.get_soldiers())
    return personnel

func get_available_personnel() -> Array[Unit]:
    var available = []
    for base in bases:
        available.append_array(base.get_available_personnel())
    return available

func get_facility_template(facility_id: String) -> Facility:
    return base_templates.get(facility_id)

func get_all_facility_templates() -> Array[Facility]:
    return base_templates.values()

func get_facility_templates_by_type(facility_type: String) -> Array[Facility]:
    var templates = []
    for template in base_templates.values():
        if template.type == facility_type:
            templates.append(template)
    return templates

func save_game():
    var save_data = {
        "bases": []
    }
    
    for base in bases:
        save_data.bases.append(base.to_dict())
    
    return save_data

func load_game(save_data: Dictionary):
    bases.clear()
    
    for base_data in save_data.get("bases", []):
        var base = Base.from_dict(base_data)
        bases.append(base)
    
    print("BaseManager: Loaded ", bases.size(), " bases from save")
