extends Node

# Simple test runner for enhanced inventory system
# Can be run from within Godot editor

@onready var sample_data = preload("res://scripts/battlescape/sample_weapon_data.gd").new()

func _ready():
	print("=== Enhanced Inventory Test Runner ===")
	print("Running tests...")

	run_weapon_tests()
	run_inventory_tests()
	run_combat_tests()

	print("=== All Tests Complete ===")

func run_weapon_tests():
	print("\n--- Weapon Tests ---")

	var pistol = sample_data.create_pistol()
	print("Created pistol: ", pistol.name)
	print("  Damage: ", pistol.base_damage)
	print("  Modes: ", pistol.get_weapon_mode_names())
	print("  Ammo: ", pistol.current_ammo, "/", pistol.ammo_capacity)

	var rifle = sample_data.create_assault_rifle()
	print("Created rifle: ", rifle.name)
	print("  Damage: ", rifle.base_damage)
	print("  Modes: ", rifle.get_weapon_mode_names())

	print("✓ Weapon tests passed")

func run_inventory_tests():
	print("\n--- Inventory Tests ---")

	var inventory = preload("res://scripts/battlescape/inventory_manager.gd").new()

	var pistol = sample_data.create_pistol()
	var armor = sample_data.create_combat_armor()

	# Test adding items
	assert(inventory.add_item(pistol))
	assert(inventory.add_item(armor))
	print("Added 2 items to inventory")

	# Test equipping
	assert(inventory.equip_item(pistol, inventory.SlotType.PRIMARY_WEAPON))
	assert(inventory.equip_item(armor, inventory.SlotType.ARMOR))
	print("Equipped weapon and armor")

	# Test inventory summary
	var summary = inventory.get_inventory_summary()
	print("Inventory summary: ", summary)

	print("✓ Inventory tests passed")

func run_combat_tests():
	print("\n--- Combat Tests ---")

	var rifle = sample_data.create_assault_rifle()

	# Test weapon modes
	for mode in rifle.weapon_modes:
		var mode_name = rifle.get_weapon_mode_names()[rifle.weapon_modes.find(mode)]
		var damage = rifle.get_damage_for_mode(mode)
		var accuracy = rifle.get_accuracy_for_mode(mode)
		print("  ", mode_name, ": DMG=", damage, ", ACC=", accuracy)

	print("✓ Combat tests passed")

func _process(delta):
	# Auto-quit after 5 seconds
	if Time.get_ticks_msec() > 5000:
		get_tree().quit()
