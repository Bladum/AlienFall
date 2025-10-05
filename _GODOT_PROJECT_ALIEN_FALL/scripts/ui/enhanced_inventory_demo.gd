extends Control

# Enhanced Inventory Demo UI
# Demonstrates the new inventory system with weapons, armor, and equipment

@onready var sample_data = $SampleWeaponData
@onready var weapon_list = $WeaponPanel/WeaponList
@onready var inventory_list = $InventoryPanel/InventoryList
@onready var stats_text = $StatsPanel/StatsText
@onready var equip_button = $InventoryPanel/EquipButton
@onready var add_weapon_button = $WeaponPanel/AddWeaponButton

var current_unit = null
var available_weapons = []

func _ready():
	print("Enhanced Inventory Demo Ready")

	# Create a demo unit
	create_demo_unit()

	# Populate available weapons
	populate_weapon_list()

	# Connect signals
	weapon_list.item_selected.connect(_on_weapon_selected)
	inventory_list.item_selected.connect(_on_inventory_selected)
	equip_button.pressed.connect(_on_equip_pressed)
	add_weapon_button.pressed.connect(_on_add_weapon_pressed)

	update_ui()

func create_demo_unit():
	# Create a demo unit with inventory
	current_unit = Node.new()
	current_unit.name = "DemoSoldier"

	# Add basic unit properties
	current_unit.stats = {
		"health": 100,
		"tu": 60,
		"strength": 40,
		"accuracy": 65
	}
	current_unit.unit_class = "soldier"

	# Add inventory manager
	var inventory_manager = preload("res://scripts/battlescape/inventory_manager.gd").new()
	current_unit.add_child(inventory_manager)

	print("Created demo unit: ", current_unit.name)

func populate_weapon_list():
	available_weapons = sample_data.get_all_sample_items()

	for weapon in available_weapons:
		var display_name = weapon.name
		if weapon.type == weapon.ItemType.WEAPON:
			display_name += " (DMG: " + str(weapon.base_damage) + ")"
		elif weapon.type == weapon.ItemType.ARMOR:
			display_name += " (ARMOR: " + str(weapon.armor_rating) + ")"

		weapon_list.add_item(display_name)

	print("Populated weapon list with ", available_weapons.size(), " items")

func _on_weapon_selected(index: int):
	if index >= 0 and index < available_weapons.size():
		var weapon = available_weapons[index]
		print("Selected weapon: ", weapon.name)

func _on_inventory_selected(index: int):
	var inventory_manager = current_unit.get_child(0)  # InventoryManager
	var items = inventory_manager.get_inventory_items()

	if index >= 0 and index < items.size():
		var item = items[index]
		print("Selected inventory item: ", item.name)

func _on_add_weapon_pressed():
	var selected_indices = weapon_list.get_selected_items()
	if selected_indices.size() > 0:
		var index = selected_indices[0]
		if index >= 0 and index < available_weapons.size():
			var weapon = available_weapons[index]
			var inventory_manager = current_unit.get_child(0)

			if inventory_manager.add_item(weapon):
				print("Added ", weapon.name, " to inventory")
				update_ui()
			else:
				print("Failed to add ", weapon.name, " to inventory")

func _on_equip_pressed():
	var selected_indices = inventory_list.get_selected_items()
	if selected_indices.size() > 0:
		var index = selected_indices[0]
		var inventory_manager = current_unit.get_child(0)
		var items = inventory_manager.get_inventory_items()

		if index >= 0 and index < items.size():
			var item = items[index]

			# Determine appropriate slot
			var slot = get_appropriate_slot(item)
			if slot != -1:
				if inventory_manager.equip_item(item, slot):
					print("Equipped ", item.name, " to ", get_slot_name(slot))
					update_ui()
				else:
					print("Failed to equip ", item.name)
			else:
				print("No appropriate slot for ", item.name)

func get_appropriate_slot(item):
	var inventory_manager = current_unit.get_child(0)

	if item.type == item.ItemType.WEAPON:
		# Check if primary weapon slot is free
		if not inventory_manager.equipped_items[inventory_manager.SlotType.PRIMARY_WEAPON]:
			return inventory_manager.SlotType.PRIMARY_WEAPON
		elif not inventory_manager.equipped_items[inventory_manager.SlotType.SECONDARY_WEAPON]:
			return inventory_manager.SlotType.SECONDARY_WEAPON
	elif item.type == item.ItemType.ARMOR:
		return inventory_manager.SlotType.ARMOR
	elif item.type == item.ItemType.EQUIPMENT:
		return inventory_manager.SlotType.BELT

	return -1

func get_slot_name(slot):
	var inventory_manager = current_unit.get_child(0)
	return inventory_manager.get_slot_name(slot)

func update_ui():
	if not current_unit:
		return

	var inventory_manager = current_unit.get_child(0)

	# Update inventory list
	inventory_list.clear()
	var inventory_items = inventory_manager.get_inventory_items()
	for item in inventory_items:
		var display_name = item.name
		if item.type == item.ItemType.WEAPON:
			display_name += " (DMG: " + str(item.base_damage) + ", AMMO: " + str(item.current_ammo) + "/" + str(item.ammo_capacity) + ")"
		elif item.type == item.ItemType.ARMOR:
			display_name += " (ARMOR: " + str(item.armor_rating) + ")"
		inventory_list.add_item(display_name)

	# Update stats display
	var stats_info = "Unit: " + current_unit.name + "\n"
	stats_info += "Class: " + current_unit.unit_class + "\n\n"
	stats_info += "Base Stats:\n"
	for stat in current_unit.stats:
		stats_info += "  " + stat + ": " + str(current_unit.stats[stat]) + "\n"

	stats_info += "\nEquipped Items:\n"
	var equipped_items = inventory_manager.get_equipped_items()
	if equipped_items.size() > 0:
		for item in equipped_items:
			stats_info += "  " + item.name + "\n"
	else:
		stats_info += "  None\n"

	stats_info += "\nTotal Armor Rating: " + str(inventory_manager.get_total_armor_rating())
	stats_info += "\nTotal Weight: " + str(inventory_manager.get_total_weight())

	stats_text.text = stats_info

func _process(delta):
	# Update UI periodically
	if Time.get_ticks_msec() % 1000 < 50:  # Update every second
		update_ui()
