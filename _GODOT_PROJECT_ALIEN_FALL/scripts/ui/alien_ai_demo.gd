extends Control
class_name AlienAIDemo

# Alien AI Demo - Interactive demonstration of the Alien AI system
# Shows AI behaviors, decision making, and group coordination

@onready var ai_manager = $AIManager
@onready var status_label = $DemoControls/StatusLabel
@onready var behavior_option = $DemoControls/BehaviorOption
@onready var log_vbox = $LogContainer/LogVBox

var demo_units = []
var log_entries = []

func _ready():
	print("Alien AI Demo initialized")

	# Connect AI manager signals
	ai_manager.ai_action_taken.connect(_on_ai_action_taken)

	# Update status
	update_status_display()

func _on_create_squad_pressed():
	var center_pos = Vector2i(5, 5)  # Center of demo area
	var squad = ai_manager.create_ai_squad(center_pos, 3)
	demo_units.append_array(squad)

	add_log_entry("Created AI squad with 3 units")
	update_status_display()

func _on_create_single_pressed():
	var position = Vector2i(3, 3)
	var unit = ai_manager.create_alien_unit(position)
	var behavior = get_selected_behavior()
	ai_manager.add_ai_unit(unit, behavior)
	demo_units.append(unit)

	add_log_entry("Created single AI unit")
	update_status_display()

func _on_set_behavior_pressed():
	var behavior = get_selected_behavior()
	ai_manager.set_group_behavior(behavior)

	var behavior_name = AlienAI.AIBehavior.keys()[behavior]
	add_log_entry("Set group behavior to: " + behavior_name)
	update_status_display()

func _on_clear_log_pressed():
	for child in log_vbox.get_children():
		child.queue_free()
	log_entries.clear()

func _on_ai_action_taken(unit: Node, action_type: String, target: Vector2i):
	var unit_name = unit.name if unit else "Unknown"
	var action_desc = "Unit " + unit_name + " performed " + action_type

	if action_type == "move":
		action_desc += " to position " + str(target)
	elif action_type == "attack":
		action_desc += " at position " + str(target)

	add_log_entry(action_desc)

func get_selected_behavior() -> AlienAI.AIBehavior:
	match behavior_option.selected:
		0: return AlienAI.AIBehavior.AGGRESSIVE
		1: return AlienAI.AIBehavior.DEFENSIVE
		2: return AlienAI.AIBehavior.STEALTHY
		3: return AlienAI.AIBehavior.BERSERK
		_: return AlienAI.AIBehavior.AGGRESSIVE

func update_status_display():
	var status_report = ai_manager.get_ai_status_report()

	var status_text = "AI Status:\n"
	status_text += "Total Units: " + str(status_report.total_ai_units) + "\n"
	status_text += "Active Units: " + str(status_report.active_units) + "\n"

	if status_report.behaviors.size() > 0:
		status_text += "Behaviors:\n"
		for behavior in status_report.behaviors:
			status_text += "  " + behavior + ": " + str(status_report.behaviors[behavior]) + "\n"

	status_label.text = status_text

func add_log_entry(message: String):
	var timestamp = Time.get_time_string_from_system()
	var log_entry = "[" + timestamp + "] " + message

	log_entries.append(log_entry)

	# Keep only last 50 entries
	if log_entries.size() > 50:
		log_entries.remove_at(0)

	# Update UI
	update_log_display()

	print("AI Demo Log: ", message)

func update_log_display():
	# Clear existing log entries
	for child in log_vbox.get_children():
		child.queue_free()

	# Add current log entries
	for entry in log_entries:
		var label = Label.new()
		label.text = entry
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		log_vbox.add_child(label)

	# Auto scroll to bottom
	await get_tree().process_frame
	$LogContainer.scroll_vertical = $LogContainer.get_v_scroll_bar().max_value

func simulate_damage(unit_index: int, damage: int):
	if unit_index < demo_units.size():
		var unit = demo_units[unit_index]
		var attacker_pos = Vector2i(0, 0)  # Simulate attacker position
		ai_manager.notify_damage_taken(unit, damage, attacker_pos)
		add_log_entry("Simulated " + str(damage) + " damage to unit " + unit.name)

func simulate_enemy_detection(unit_index: int, enemy_pos: Vector2i):
	if unit_index < demo_units.size():
		var unit = demo_units[unit_index]
		ai_manager.notify_enemy_detected(unit, enemy_pos)
		add_log_entry("Simulated enemy detection at " + str(enemy_pos) + " for unit " + unit.name)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				simulate_damage(0, 20)
			KEY_2:
				simulate_enemy_detection(0, Vector2i(2, 2))
			KEY_3:
				if demo_units.size() > 0:
					var unit = demo_units[0]
					if unit.has_node("AlienAI"):
						var ai = unit.get_node("AlienAI")
						ai.force_state_change(AlienAI.AIState.ATTACKING)
						add_log_entry("Forced unit into ATTACKING state")

func cleanup_demo():
	ai_manager.cleanup()
	demo_units.clear()
	add_log_entry("Demo cleaned up")

func _exit_tree():
	cleanup_demo()
