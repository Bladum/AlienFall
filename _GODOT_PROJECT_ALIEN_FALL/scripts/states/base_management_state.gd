extends Control
class_name BaseManagementState

# BaseManagementState - Handles the base management screen
# Shows base information, facilities, personnel, and construction

@onready var base_dropdown = $BaseSelector/BaseDropdown
@onready var power_label = $MainContainer/LeftPanel/BaseInfoPanel/BaseStats/PowerLabel
@onready var personnel_label = $MainContainer/LeftPanel/BaseInfoPanel/BaseStats/PersonnelLabel
@onready var storage_label = $MainContainer/LeftPanel/BaseInfoPanel/BaseStats/StorageLabel
@onready var facilities_list = $MainContainer/LeftPanel/FacilitiesPanel/FacilitiesList
@onready var personnel_list = $MainContainer/RightPanel/PersonnelPanel/PersonnelList
@onready var construction_list = $MainContainer/RightPanel/ConstructionPanel/ConstructionList
@onready var build_facility_button = $BottomPanel/BuildFacilityButton
@onready var assign_personnel_button = $BottomPanel/AssignPersonnelButton
@onready var back_button = $BottomPanel/BackButton

var current_base: Base = null

func _ready():
    print("BaseManagementState: Initializing...")
    
    # Connect UI signals
    base_dropdown.connect("item_selected", Callable(self, "_on_base_selected"))
    build_facility_button.connect("pressed", Callable(self, "_on_build_facility_pressed"))
    assign_personnel_button.connect("pressed", Callable(self, "_on_assign_personnel_pressed"))
    back_button.connect("pressed", Callable(self, "_on_back_pressed"))
    
    # Connect to base manager signals
    BaseManager.connect("base_added", Callable(self, "_on_base_added"))
    BaseManager.connect("facility_constructed", Callable(self, "_on_facility_constructed"))
    BaseManager.connect("personnel_assigned", Callable(self, "_on_personnel_assigned"))
    BaseManager.connect("personnel_unassigned", Callable(self, "_on_personnel_unassigned"))
    
    # Connect to TimeService for construction progress updates
    TimeService.connect("daily_tick", Callable(self, "_on_daily_tick"))
    
    # Initialize UI
    _populate_base_dropdown()
    _select_first_base()
    
    print("BaseManagementState: Ready")

func _populate_base_dropdown():
    base_dropdown.clear()
    
    var bases = BaseManager.get_all_bases()
    for i in range(bases.size()):
        var base = bases[i]
        base_dropdown.add_item(base.name, i)
    
    if bases.size() == 0:
        base_dropdown.add_item("No bases available", 0)
        base_dropdown.disabled = true

func _select_first_base():
    if base_dropdown.item_count > 0 and not base_dropdown.disabled:
        base_dropdown.select(0)
        _on_base_selected(0)

func _on_base_selected(index: int):
    var bases = BaseManager.get_all_bases()
    if index >= 0 and index < bases.size():
        current_base = bases[index]
        _update_display()
        print("BaseManagementState: Selected base: ", current_base.name)

func _update_display():
    if not current_base:
        return
    
    # Update base stats
    var power_status = current_base.get_power_status()
    power_label.text = "Power: %d/%d MW" % [power_status.generation, power_status.consumption]
    
    var personnel_count = current_base.personnel.size()
    personnel_label.text = "Personnel: %d/%d" % [personnel_count, current_base.living_quarters]
    
    var storage_status = current_base.get_storage_status()
    storage_label.text = "Storage: %d/%d" % [storage_status.used, storage_status.capacity]
    
    # Update facilities list
    _update_facilities_list()
    
    # Update personnel list
    _update_personnel_list()
    
    # Update construction list
    _update_construction_list()

func _update_facilities_list():
    # Clear existing facilities
    for child in facilities_list.get_children():
        child.queue_free()
    
    if not current_base:
        return
    
    for facility in current_base.facilities:
        var facility_label = Label.new()
        facility_label.text = "%s (%s)" % [facility.name, facility.type]
        facilities_list.add_child(facility_label)

func _update_personnel_list():
    # Clear existing personnel
    for child in personnel_list.get_children():
        child.queue_free()
    
    if not current_base:
        return
    
    for unit in current_base.personnel:
        var personnel_label = Label.new()
        var assignment_text = ""
        if unit.assigned_facility:
            assignment_text = " -> %s" % unit.assigned_facility.name
        personnel_label.text = "%s (%s)%s" % [unit.name, unit.role, assignment_text]
        personnel_list.add_child(personnel_label)

func _update_construction_list():
    # Clear existing construction items
    for child in construction_list.get_children():
        child.queue_free()
    
    if not current_base:
        return
    
    if current_base.construction_queue.size() == 0:
        var no_construction_label = Label.new()
        no_construction_label.text = "No facilities under construction"
        construction_list.add_child(no_construction_label)
        return
    
    for construction in current_base.construction_queue:
        var facility = construction.facility
        var progress = (construction.total_days - construction.remaining_days) / float(construction.total_days)
        var construction_label = Label.new()
        construction_label.text = "%s (%d%%)" % [facility.name, progress * 100]
        construction_list.add_child(construction_label)

func _on_build_facility_pressed():
    print("BaseManagementState: Build facility requested")
    
    if not current_base:
        _show_error("No base selected")
        return
    
    # Show facility selection dialog
    var dialog = _create_facility_selection_dialog()
    add_child(dialog)
    dialog.popup_centered()

func _create_facility_selection_dialog() -> Window:
    var dialog = Window.new()
    dialog.title = "Build Facility"
    dialog.size = Vector2(400, 300)
    dialog.exclusive = true
    
    var container = VBoxContainer.new()
    container.set_anchors_preset(LayoutPreset.FULL_RECT)
    dialog.add_child(container)
    
    var scroll = ScrollContainer.new()
    container.add_child(scroll)
    
    var facility_list = VBoxContainer.new()
    scroll.add_child(facility_list)
    
    # Add available facilities
    var templates = BaseManager.get_all_facility_templates()
    for template in templates:
        if BaseManager.can_build_facility(current_base, template.facility_id):
            var button = Button.new()
            button.text = "%s ($%s, %d days)" % [template.name, _format_number(template.build_cost), template.build_time]
            button.connect("pressed", Callable(self, "_on_facility_selected").bind(template.facility_id, dialog))
            facility_list.add_child(button)
    
    var cancel_button = Button.new()
    cancel_button.text = "Cancel"
    cancel_button.connect("pressed", Callable(dialog, "queue_free"))
    container.add_child(cancel_button)
    
    return dialog

func _on_facility_selected(facility_id: String, dialog: Window):
    dialog.queue_free()
    
    if BaseManager.build_facility(current_base, facility_id):
        _update_display()
        _show_message("Started construction of facility")
    else:
        _show_error("Failed to start construction")

func _on_assign_personnel_pressed():
    print("BaseManagementState: Assign personnel requested")
    
    if not current_base:
        _show_error("No base selected")
        return
    
    # Show personnel assignment dialog
    var dialog = _create_personnel_assignment_dialog()
    add_child(dialog)
    dialog.popup_centered()

func _create_personnel_assignment_dialog() -> Window:
    var dialog = Window.new()
    dialog.title = "Assign Personnel"
    dialog.size = Vector2(500, 400)
    dialog.exclusive = true
    
    var container = VBoxContainer.new()
    container.set_anchors_preset(LayoutPreset.FULL_RECT)
    dialog.add_child(container)
    
    var scroll = ScrollContainer.new()
    container.add_child(scroll)
    
    var assignment_list = VBoxContainer.new()
    scroll.add_child(assignment_list)
    
    # Add available personnel and facilities
    var available_personnel = current_base.get_available_personnel()
    
    for unit in available_personnel:
        var personnel_container = HBoxContainer.new()
        assignment_list.add_child(personnel_container)
        
        var name_label = Label.new()
        name_label.text = "%s (%s)" % [unit.name, unit.role]
        name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        personnel_container.add_child(name_label)
        
        # Add assignment buttons for each facility that needs this role
        for facility in current_base.facilities:
            var required = facility.get_staff_requirement(unit.role)
            if required > 0:
                var assign_button = Button.new()
                assign_button.text = "-> %s" % facility.name
                assign_button.connect("pressed", Callable(self, "_on_personnel_assigned_to_facility").bind(unit, facility, dialog))
                personnel_container.add_child(assign_button)
    
    var cancel_button = Button.new()
    cancel_button.text = "Cancel"
    cancel_button.connect("pressed", Callable(dialog, "queue_free"))
    container.add_child(cancel_button)
    
    return dialog

func _on_personnel_assigned_to_facility(unit: Unit, facility: Facility, dialog: Window):
    dialog.queue_free()
    
    if BaseManager.assign_personnel_to_facility(current_base, unit, facility):
        _update_display()
        _show_message("Assigned %s to %s" % [unit.name, facility.name])
    else:
        _show_error("Failed to assign personnel")

func _on_back_pressed():
    print("BaseManagementState: Back to geoscape requested")
    
    # Return to geoscape
    get_tree().change_scene_to_file("res://scenes/geoscape.tscn")

func _on_base_added(base: Base):
    _populate_base_dropdown()

func _on_facility_constructed(base: Base, facility: Facility):
    if base == current_base:
        _update_display()

func _on_daily_tick():
    """Update construction progress display when time advances"""
    if current_base and current_base.construction_queue.size() > 0:
        _update_construction_list()

func _on_personnel_assigned(base: Base, unit: Unit, facility: Facility):
    if base == current_base:
        _update_display()

func _on_personnel_unassigned(base: Base, unit: Unit, facility: Facility):
    if base == current_base:
        _update_display()

func _show_message(message: String):
    var dialog = AcceptDialog.new()
    dialog.title = "Information"
    dialog.dialog_text = message
    add_child(dialog)
    dialog.popup_centered()

func _show_error(message: String):
    var dialog = AcceptDialog.new()
    dialog.title = "Error"
    dialog.dialog_text = message
    add_child(dialog)
    dialog.popup_centered()

func _format_number(num: int) -> String:
    if num >= 1000000:
        return str(num / 1000000) + "M"
    elif num >= 1000:
        return str(num / 1000) + "K"
    else:
        return str(num)
