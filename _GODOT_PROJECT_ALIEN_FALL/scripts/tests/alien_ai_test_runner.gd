extends Node
class_name AlienAITestRunner

# Alien AI Test Runner - Comprehensive testing for the Alien AI system
# Tests AI behaviors, decision making, state transitions, and integration

@onready var test_output = $"../TestOutput"
@onready var status_label = $"../StatusLabel"

var test_results = []
var ai_manager = null
var test_units = []

func _ready():
	print("Alien AI Test Runner initialized")
	# Don't auto-run tests, wait for button press

func _on_run_tests_pressed():
	test_output.text = ""
	status_label.text = "Running tests..."
	run_all_tests()

func run_all_tests():
	print("\n=== Running Alien AI Tests ===\n")
	log_to_ui("\n=== Running Alien AI Tests ===\n")

	test_ai_initialization()
	test_ai_behaviors()
	test_ai_state_transitions()
	test_ai_decision_making()
	test_ai_group_coordination()
	test_ai_damage_response()
	test_ai_integration()

	print("\n=== Test Results ===")
	log_to_ui("\n=== Test Results ===")

	for result in test_results:
		print(result)
		log_to_ui(result)

	var passed = test_results.filter(func(r): return r.begins_with("PASS")).size()
	var total = test_results.size()
	var result_text = "\nPassed: " + str(passed) + "/" + str(total)

	print(result_text)
	log_to_ui(result_text)

	if passed == total:
		print("All tests PASSED!")
		log_to_ui("All tests PASSED!")
		status_label.text = "All tests PASSED! (" + str(passed) + "/" + str(total) + ")"
	else:
		print("Some tests FAILED!")
		log_to_ui("Some tests FAILED!")
		status_label.text = "Some tests FAILED! (" + str(passed) + "/" + str(total) + ")"

func log_to_ui(message: String):
	if test_output:
		test_output.text += message + "\n"
		# Auto scroll to bottom
		test_output.scroll_vertical = test_output.get_line_count()

func test_ai_initialization():
	print("Testing AI initialization...")
	log_to_ui("Testing AI initialization...")

	# Create AI manager
	ai_manager = AIManager.new()
	add_child(ai_manager)

	# Create test unit
	var unit = create_test_unit()
	test_units.append(unit)

	# Add AI to unit
	ai_manager.add_ai_unit(unit, AlienAI.AIBehavior.AGGRESSIVE)

	# Verify AI was added
	var has_ai = unit.has_node("AlienAI")
	assert(has_ai, "Unit should have AlienAI node")

	if has_ai:
		var ai_controller = unit.get_node("AlienAI")
		assert(ai_controller.ai_behavior == AlienAI.AIBehavior.AGGRESSIVE, "AI behavior should be AGGRESSIVE")

	test_results.append("PASS: AI initialization" if has_ai else "FAIL: AI initialization")
	log_to_ui("PASS: AI initialization" if has_ai else "FAIL: AI initialization")

func test_ai_behaviors():
	print("Testing AI behaviors...")
	log_to_ui("Testing AI behaviors...")

	var behaviors_tested = 0
	var behaviors_working = 0

	for behavior in AlienAI.AIBehavior.values():
		var unit = create_test_unit()
		test_units.append(unit)

		ai_manager.add_ai_unit(unit, behavior)
		behaviors_tested += 1

		if unit.has_node("AlienAI"):
			var ai = unit.get_node("AlienAI")
			if ai.ai_behavior == behavior:
				behaviors_working += 1

	test_results.append("PASS: AI behaviors (" + str(behaviors_working) + "/" + str(behaviors_tested) + ")" if behaviors_working == behaviors_tested else "FAIL: AI behaviors")
	log_to_ui("PASS: AI behaviors (" + str(behaviors_working) + "/" + str(behaviors_tested) + ")" if behaviors_working == behaviors_tested else "FAIL: AI behaviors")

func test_ai_state_transitions():
	print("Testing AI state transitions...")
	log_to_ui("Testing AI state transitions...")

	var unit = create_test_unit()
	test_units.append(unit)
	ai_manager.add_ai_unit(unit, AlienAI.AIBehavior.AGGRESSIVE)

	if unit.has_node("AlienAI"):
		var ai = unit.get_node("AlienAI")

		# Test state changes
		var initial_state = ai.current_state
		ai.force_state_change(AlienAI.AIState.PATROL)
		var patrol_state = ai.current_state

		ai.force_state_change(AlienAI.AIState.ATTACKING)
		var attack_state = ai.current_state

		var transitions_work = (initial_state != patrol_state and patrol_state != attack_state)
		test_results.append("PASS: AI state transitions" if transitions_work else "FAIL: AI state transitions")
		log_to_ui("PASS: AI state transitions" if transitions_work else "FAIL: AI state transitions")

func test_ai_decision_making():
	print("Testing AI decision making...")
	log_to_ui("Testing AI decision making...")

	var unit = create_test_unit()
	test_units.append(unit)
	ai_manager.add_ai_unit(unit, AlienAI.AIBehavior.AGGRESSIVE)

	var decisions_made = 0

	if unit.has_node("AlienAI"):
		var ai = unit.get_node("AlienAI")

		# Simulate some updates to trigger decisions
		for i in range(10):
			ai._process(0.5)
			if ai.last_decision_time > 0:
				decisions_made += 1

	test_results.append("PASS: AI decision making" if decisions_made > 0 else "FAIL: AI decision making")
	log_to_ui("PASS: AI decision making" if decisions_made > 0 else "FAIL: AI decision making")

func test_ai_group_coordination():
	print("Testing AI group coordination...")
	log_to_ui("Testing AI group coordination...")

	# Create squad
	var squad = ai_manager.create_ai_squad(Vector2i(5, 5), 3, AlienAI.AIBehavior.DEFENSIVE)

	# Change group behavior
	ai_manager.set_group_behavior(AlienAI.AIBehavior.AGGRESSIVE)

	# Verify all units have new behavior
	var all_changed = true
	for unit in squad:
		if unit.has_node("AlienAI"):
			var ai = unit.get_node("AlienAI")
			if ai.ai_behavior != AlienAI.AIBehavior.AGGRESSIVE:
				all_changed = false
				break

	test_results.append("PASS: AI group coordination" if all_changed else "FAIL: AI group coordination")
	log_to_ui("PASS: AI group coordination" if all_changed else "FAIL: AI group coordination")

func test_ai_damage_response():
	print("Testing AI damage response...")
	log_to_ui("Testing AI damage response...")

	var unit = create_test_unit()
	test_units.append(unit)
	ai_manager.add_ai_unit(unit, AlienAI.AIBehavior.DEFENSIVE)

	if unit.has_node("AlienAI"):
		var ai = unit.get_node("AlienAI")
		var initial_state = ai.current_state

		# Simulate damage
		ai_manager.notify_damage_taken(unit, 30, Vector2i(1, 1))

		# AI should react to damage
		var reacted = (ai.current_state != initial_state or ai.has_enemy_memory())

		test_results.append("PASS: AI damage response" if reacted else "FAIL: AI damage response")
		log_to_ui("PASS: AI damage response" if reacted else "FAIL: AI damage response")

func test_ai_integration():
	print("Testing AI integration with battlescape...")
	log_to_ui("Testing AI integration with battlescape...")

	# This would test integration with actual battlescape manager
	# For now, just verify AI manager exists and functions
	var manager_exists = ai_manager != null
	var has_units = ai_manager.active_ai_units.size() > 0

	test_results.append("PASS: AI integration" if manager_exists and has_units else "FAIL: AI integration")
	log_to_ui("PASS: AI integration" if manager_exists and has_units else "FAIL: AI integration")

func create_test_unit():
	var unit = Node.new()
	unit.name = "TestUnit_" + str(randi())
	unit.position = Vector2i(randi() % 10, randi() % 10)
	unit.faction = "alien"
	unit.unit_class = "sectoid"
	unit.is_alive = true

	# Add basic stats
	unit.stats = {
		"health": 100,
		"tu": 60,
		"accuracy": 65
	}

	# Add inventory
	var inventory = InventoryManager.new()
	unit.add_child(inventory)

	var sample_data = SampleWeaponData.new()
	var weapon = sample_data.create_plasma_rifle()
	inventory.add_item(weapon)
	inventory.equip_item(weapon, InventoryManager.SlotType.PRIMARY_WEAPON)

	return unit

func cleanup():
	if ai_manager:
		ai_manager.cleanup()
		ai_manager.queue_free()

	for unit in test_units:
		if unit:
			unit.queue_free()

	test_units.clear()
	print("Alien AI Test Runner cleaned up")

func _exit_tree():
	cleanup()
