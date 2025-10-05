extends Node
class_name AIManager

# AI Manager - Coordinates alien AI units and manages group behaviors
# Handles squad tactics, reinforcements, and coordinated actions

var active_ai_units = []
var ai_update_timer = 0.0
var ai_update_interval = 0.5  # Update AI every 0.5 seconds

signal ai_action_taken(unit: Node, action_type: String, target: Vector2i)

func _ready():
	print("AI Manager initialized")

func _process(delta):
	ai_update_timer += delta

	if ai_update_timer >= ai_update_interval:
		update_all_ai()
		ai_update_timer = 0.0

func add_ai_unit(unit, ai_behavior = AlienAI.AIBehavior.AGGRESSIVE):
	if not unit:
		return

	# Create AI controller for the unit
	var ai_controller = AlienAI.new()
	ai_controller.ai_behavior = ai_behavior
	ai_controller.set_controlled_unit(unit)

	# Connect AI signals
	ai_controller.ai_decision_made.connect(_on_ai_decision_made)

	# Add to unit
	unit.add_child(ai_controller)
	active_ai_units.append(unit)

	print("Added AI unit: ", unit.name, " with behavior: ", AlienAI.AIBehavior.keys()[ai_behavior])

func remove_ai_unit(unit):
	if unit in active_ai_units:
		active_ai_units.erase(unit)

		# Remove AI controller
		if unit.has_node("AlienAI"):
			var ai_controller = unit.get_node("AlienAI")
			ai_controller.queue_free()

func update_all_ai():
	for unit in active_ai_units:
		if unit and unit.is_alive and unit.has_node("AlienAI"):
			var ai_controller = unit.get_node("AlienAI")
			ai_controller._process(ai_update_interval)

func _on_ai_decision_made(action_type: String, target_position: Vector2i):
	# Find which unit made this decision
	for unit in active_ai_units:
		if unit.has_node("AlienAI"):
			var ai_controller = unit.get_node("AlienAI")
			if ai_controller == get_viewport().get_camera_3d():  # This is a hack, need better way
				emit_signal("ai_action_taken", unit, action_type, target_position)
				execute_ai_action(unit, action_type, target_position)
				break

func execute_ai_action(unit, action_type: String, target_position: Vector2i):
	match action_type:
		"move":
			execute_move_action(unit, target_position)
		"attack":
			execute_attack_action(unit, target_position)
		"overwatch":
			execute_overwatch_action(unit)

func execute_move_action(unit, target_position: Vector2i):
	# Get battlescape manager
	var battlescape_manager = get_node("/root/BattlescapeManager")
	if not battlescape_manager:
		return

	# Calculate path to target
	var path = battlescape_manager.battlescape_map.get_path(unit.position, target_position)
	if path.size() > 1:
		# Move to next position in path
		var next_pos = path[1]
		var success = battlescape_manager.battlescape_map.move_unit(unit.position, next_pos)

		if success:
			unit.position = next_pos
			print("AI Unit ", unit.name, " moved to ", next_pos)

func execute_attack_action(unit, target_position: Vector2i):
	# Get battlescape manager
	var battlescape_manager = get_node("/root/BattlescapeManager")
	if not battlescape_manager:
		return

	# Get target unit at position
	var target_unit = battlescape_manager.battlescape_map.get_unit_at(target_position)
	if not target_unit:
		return

	# Perform attack
	var weapon = get_unit_weapon(unit)
	if weapon:
		var attack_result = battlescape_manager.combat_system.perform_attack_enhanced(
			unit, target_unit, weapon, weapon.WeaponMode.SNAPSHOT
		)

		print("AI Unit ", unit.name, " attacked: ", attack_result.message)

func execute_overwatch_action(unit):
	# Set unit to overwatch mode
	unit.is_overwatching = true
	print("AI Unit ", unit.name, " entered overwatch mode")

func get_unit_weapon(unit):
	if unit.has_node("InventoryManager"):
		var inventory = unit.get_node("InventoryManager")
		return inventory.get_equipped_weapon(inventory.SlotType.PRIMARY_WEAPON)
	return null

func notify_damage_taken(unit, damage: int, attacker_pos: Vector2i):
	if unit.has_node("AlienAI"):
		var ai_controller = unit.get_node("AlienAI")
		ai_controller.on_damage_taken(damage, attacker_pos)

func notify_enemy_detected(unit, enemy_pos: Vector2i):
	if unit.has_node("AlienAI"):
		var ai_controller = unit.get_node("AlienAI")
		ai_controller.on_enemy_detected(enemy_pos)

func get_ai_status_report() -> Dictionary:
	var report = {
		"total_ai_units": active_ai_units.size(),
		"active_units": 0,
		"behaviors": {}
	}

	for unit in active_ai_units:
		if unit and unit.is_alive:
			report.active_units += 1

			if unit.has_node("AlienAI"):
				var ai_controller = unit.get_node("AlienAI")
				var behavior = AlienAI.AIBehavior.keys()[ai_controller.ai_behavior]

				if not report.behaviors.has(behavior):
					report.behaviors[behavior] = 0
				report.behaviors[behavior] += 1

	return report

func set_group_behavior(behavior: AlienAI.AIBehavior):
	for unit in active_ai_units:
		if unit.has_node("AlienAI"):
			var ai_controller = unit.get_node("AlienAI")
			ai_controller.ai_behavior = behavior

	print("Set group behavior to: ", AlienAI.AIBehavior.keys()[behavior])

func create_ai_squad(center_pos: Vector2i, num_units: int, behavior = AlienAI.AIBehavior.AGGRESSIVE):
	var squad_units = []

	for i in range(num_units):
		var unit = create_alien_unit(center_pos + Vector2i(i * 2, 0))
		add_ai_unit(unit, behavior)
		squad_units.append(unit)

	print("Created AI squad with ", num_units, " units")
	return squad_units

func create_alien_unit(position: Vector2i):
	# Create a basic alien unit for testing
	var unit = Node.new()
	unit.name = "AlienUnit_" + str(randi())
	unit.position = position
	unit.faction = "alien"
	unit.unit_class = "sectoid"
	unit.is_alive = true

	# Add basic stats
	unit.stats = {
		"health": 80,
		"tu": 50,
		"accuracy": 60
	}

	# Add inventory with basic weapon
	var inventory = preload("res://scripts/battlescape/inventory_manager.gd").new()
	unit.add_child(inventory)

	var sample_data = preload("res://scripts/battlescape/sample_weapon_data.gd").new()
	var plasma_weapon = sample_data.create_plasma_rifle()
	inventory.add_item(plasma_weapon)
	inventory.equip_item(plasma_weapon, inventory.SlotType.PRIMARY_WEAPON)

	return unit

func cleanup():
	for unit in active_ai_units:
		if unit:
			unit.queue_free()
	active_ai_units.clear()
	print("AI Manager cleaned up")
