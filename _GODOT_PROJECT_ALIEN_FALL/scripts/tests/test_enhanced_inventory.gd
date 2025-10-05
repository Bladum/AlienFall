extends Node

# Test script for enhanced inventory and combat system
# Demonstrates weapons, armor, equipment, and combat with new systems

@onready var sample_data = $SampleWeaponData

func _ready():
	print("=== Enhanced Inventory & Combat Test ===")

	# Test 1: Create sample weapons
	test_weapon_creation()

	# Test 2: Test inventory management
	test_inventory_management()

	# Test 3: Test weapon modes and damage
	test_weapon_modes()

	# Test 4: Test armor and damage reduction
	test_armor_system()

	# Test 5: Test enhanced combat
	test_enhanced_combat()

	print("=== Enhanced Inventory & Combat Test Complete ===")

func test_weapon_creation():
	print("\n--- Test 1: Weapon Creation ---")

	var pistol = sample_data.create_pistol()
	var rifle = sample_data.create_assault_rifle()
	var plasma = sample_data.create_plasma_rifle()

	print("Created weapons:")
	print("  Pistol: ", pistol.name, " - Damage: ", pistol.base_damage, " - Modes: ", pistol.get_weapon_mode_names())
	print("  Rifle: ", rifle.name, " - Damage: ", rifle.base_damage, " - Modes: ", rifle.get_weapon_mode_names())
	print("  Plasma: ", plasma.name, " - Damage: ", plasma.base_damage, " - Type: ", pistol.DamageType.keys()[plasma.damage_type])

	assert(pistol.weapon_modes.size() > 0)
	assert(rifle.weapon_modes.size() > 0)
	assert(plasma.damage_type == plasma.DamageType.PLASMA)

	print("✓ Weapon creation successful")

func test_inventory_management():
	print("\n--- Test 2: Inventory Management ---")

	# Create a mock unit with inventory
	var mock_unit = Node.new()
	mock_unit.name = "TestUnit"
	var inventory_manager = preload("res://scripts/battlescape/inventory_manager.gd").new()
	mock_unit.add_child(inventory_manager)

	# Add weapons to inventory
	var pistol = sample_data.create_pistol()
	var rifle = sample_data.create_assault_rifle()
	var armor = sample_data.create_combat_armor()

	assert(inventory_manager.add_item(pistol))
	assert(inventory_manager.add_item(rifle))
	assert(inventory_manager.add_item(armor))

	print("Added items to inventory:")
	print("  Inventory size: ", inventory_manager.get_inventory_items().size())

	# Test equipping
	assert(inventory_manager.equip_item(pistol, inventory_manager.SlotType.PRIMARY_WEAPON))
	assert(inventory_manager.equip_item(armor, inventory_manager.SlotType.ARMOR))

	print("Equipped items:")
	print("  Primary weapon: ", inventory_manager.get_equipped_weapon(inventory_manager.SlotType.PRIMARY_WEAPON).name)
	print("  Armor: ", inventory_manager.get_equipped_armor().name)

	# Test inventory summary
	var summary = inventory_manager.get_inventory_summary()
	print("Inventory summary: ", summary)

	assert(inventory_manager.get_equipped_weapons().size() == 1)
	assert(inventory_manager.get_equipped_armor() != null)

	print("✓ Inventory management successful")

	# Clean up
	mock_unit.queue_free()

func test_weapon_modes():
	print("\n--- Test 3: Weapon Modes ---")

	var rifle = sample_data.create_assault_rifle()

	print("Testing weapon modes for: ", rifle.name)

	# Test each mode
	for mode in rifle.weapon_modes:
		var mode_name = rifle.get_weapon_mode_names()[rifle.weapon_modes.find(mode)]
		var damage = rifle.get_damage_for_mode(mode)
		var accuracy = rifle.get_accuracy_for_mode(mode)
		var tu_cost = rifle.get_tu_cost_for_mode(mode)

		print("  ", mode_name, ": Damage=", damage, ", Accuracy=", accuracy, ", TU=", tu_cost)

		assert(damage > 0)
		assert(accuracy > 0)
		assert(tu_cost > 0)

	# Test mode validation
	assert(rifle.can_use_mode(rifle.WeaponMode.AIMED))
	assert(rifle.can_use_mode(rifle.WeaponMode.BURST))
	assert(rifle.can_use_mode(rifle.WeaponMode.AUTO))

	print("✓ Weapon modes test successful")

func test_armor_system():
	print("\n--- Test 4: Armor System ---")

	var armor = sample_data.create_combat_armor()

	print("Testing armor: ", armor.name)
	print("  Armor rating: ", armor.armor_rating)

	# Test damage reduction for each type
	for damage_type in armor.DamageType.values():
		var reduction = armor.get_damage_reduction(damage_type)
		var type_name = armor.DamageType.keys()[damage_type]
		print("  ", type_name, " reduction: ", reduction, "%")

		assert(reduction >= 0)

	print("✓ Armor system test successful")

func test_enhanced_combat():
	print("\n--- Test 5: Enhanced Combat ---")

	# Create mock units
	var attacker = create_mock_unit("Soldier")
	var target = create_mock_unit("Alien")

	# Add inventory to units
	var attacker_inventory = preload("res://scripts/battlescape/inventory_manager.gd").new()
	var target_inventory = preload("res://scripts/battlescape/inventory_manager.gd").new()

	attacker.add_child(attacker_inventory)
	target.add_child(target_inventory)

	# Equip weapons and armor
	var rifle = sample_data.create_assault_rifle()
	var armor = sample_data.create_combat_armor()

	attacker_inventory.add_item(rifle)
	attacker_inventory.equip_item(rifle, attacker_inventory.SlotType.PRIMARY_WEAPON)

	target_inventory.add_item(armor)
	target_inventory.equip_item(armor, target_inventory.SlotType.ARMOR)

	# Create combat system
	var los_system = preload("res://scripts/battlescape/line_of_sight_system.gd").new(null)
	var combat_system = preload("res://scripts/battlescape/combat_system.gd").new(los_system)

	# Test enhanced hit chance
	var hit_chance = combat_system.calculate_hit_chance_enhanced(
		attacker, target, rifle, rifle.WeaponMode.AIMED
	)
	print("Enhanced hit chance (Aimed): ", hit_chance * 100, "%")

	# Test enhanced damage
	var damage = combat_system.calculate_damage_enhanced(
		attacker, target, rifle, rifle.WeaponMode.AIMED
	)
	print("Enhanced damage calculation: ", damage)

	# Test enhanced attack
	var attack_result = combat_system.perform_attack_enhanced(
		attacker, target, rifle, rifle.WeaponMode.AIMED
	)
	print("Enhanced attack result: ", attack_result)

	assert(hit_chance > 0.0 and hit_chance <= 1.0)
	assert(damage > 0)

	print("✓ Enhanced combat test successful")

	# Clean up
	attacker.queue_free()
	target.queue_free()

func create_mock_unit(unit_name: String) -> Node:
	var unit = Node.new()
	unit.name = unit_name

	# Add basic unit properties
	unit.stats = {
		"tu": 60,
		"health": 100,
		"accuracy": 60
	}
	unit.unit_class = "soldier"
	unit.position = Vector2(0, 0)
	unit.is_alive = true

	return unit

func _process(delta):
	# Exit after test completion
	if Time.get_ticks_msec() > 3000:  # 3 seconds
		get_tree().quit()
