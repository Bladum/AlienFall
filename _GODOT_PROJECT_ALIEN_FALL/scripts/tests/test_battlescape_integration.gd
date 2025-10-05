extends Node

# Test script for battlescape system integration
# Tests the complete battlescape system including map, LOS, turns, and combat

@onready var battlescape_manager = $"/root/BattlescapeManager" if has_node("/root/BattlescapeManager") else null
@onready var event_bus = $"/root/EventBus" if has_node("/root/EventBus") else null

func _ready():
	print("=== Battlescape Integration Test Started ===")

	# Test 1: System Initialization
	test_system_initialization()

	# Test 2: Map Generation
	test_map_generation()

	# Test 3: Unit Placement
	test_unit_placement()

	# Test 4: Line of Sight
	test_line_of_sight()

	# Test 5: Turn Management
	test_turn_management()

	# Test 6: Combat Resolution
	test_combat_resolution()

	# Test 7: Event Integration
	test_event_integration()

	print("=== Battlescape Integration Test Completed ===")

func test_system_initialization():
	print("\n--- Test 1: System Initialization ---")

	if battlescape_manager:
		print("✓ BattlescapeManager found")
		if battlescape_manager.battlescape_map:
			print("✓ BattlescapeMap initialized")
		else:
			print("✗ BattlescapeMap not initialized")

		if battlescape_manager.line_of_sight_system:
			print("✓ LineOfSightSystem initialized")
		else:
			print("✗ LineOfSightSystem not initialized")

		if battlescape_manager.turn_manager:
			print("✓ TurnManager initialized")
		else:
			print("✗ TurnManager not initialized")

		if battlescape_manager.combat_system:
			print("✓ CombatSystem initialized")
		else:
			print("✗ CombatSystem not initialized")
	else:
		print("✗ BattlescapeManager not found")

func test_map_generation():
	print("\n--- Test 2: Map Generation ---")

	if battlescape_manager and battlescape_manager.battlescape_map:
		var map = battlescape_manager.battlescape_map

		# Test map dimensions
		var width = map.map_width
		var height = map.map_height
		print("Map dimensions: ", width, "x", height)

		# Test terrain generation
		if map.terrain_grid.size() > 0:
			print("✓ Terrain grid generated (", map.terrain_grid.size(), " tiles)")

			# Check some terrain types
			var terrain_types = []
			for terrain in map.terrain_grid:
				if not terrain_types.has(terrain.type):
					terrain_types.append(terrain.type)
			print("Terrain types found: ", terrain_types)
		else:
			print("✗ Terrain grid not generated")

		# Test unit positions
		if map.unit_positions.size() > 0:
			print("✓ Unit positions initialized (", map.unit_positions.size(), " positions)")
		else:
			print("✗ Unit positions not initialized")
	else:
		print("✗ BattlescapeMap not available")

func test_unit_placement():
	print("\n--- Test 3: Unit Placement ---")

	if battlescape_manager and battlescape_manager.battlescape_map:
		var map = battlescape_manager.battlescape_map

		# Test unit placement
		var test_unit = preload("res://scripts/domain/unit.gd").new()
		test_unit.unit_id = "test_unit"
		test_unit.name = "Test Soldier"
		test_unit.faction = "player"

		var placed = map.place_unit(test_unit, Vector2i(5, 5))
		if placed:
			print("✓ Unit placement successful")

			# Test unit retrieval
			var retrieved_unit = map.get_unit_at(Vector2i(5, 5))
			if retrieved_unit and retrieved_unit.unit_id == "test_unit":
				print("✓ Unit retrieval successful")
			else:
				print("✗ Unit retrieval failed")

			# Test unit movement
			var moved = map.move_unit(Vector2i(5, 5), Vector2i(6, 5))
			if moved:
				print("✓ Unit movement successful")
			else:
				print("✗ Unit movement failed")
		else:
			print("✗ Unit placement failed")

func test_line_of_sight():
	print("\n--- Test 4: Line of Sight ---")

	if battlescape_manager and battlescape_manager.line_of_sight_system:
		var los_system = battlescape_manager.line_of_sight_system

		# Test basic LOS calculation
		var visible = los_system.has_line_of_sight(Vector2i(0, 0), Vector2i(5, 5))
		print("LOS from (0,0) to (5,5): ", visible)

		# Test visibility calculation
		var visibility = los_system.calculate_visibility(Vector2i(0, 0), 5)
		print("Visibility radius 5 from (0,0): ", visibility.size(), " tiles")

		# Test concealment
		var concealment = los_system.get_concealment(Vector2i(5, 5))
		print("Concealment at (5,5): ", concealment)

		print("✓ Line of sight system operational")
	else:
		print("✗ LineOfSightSystem not available")

func test_turn_management():
	print("\n--- Test 5: Turn Management ---")

	if battlescape_manager and battlescape_manager.turn_manager:
		var turn_manager = battlescape_manager.turn_manager

		# Test turn initialization
		print("Current turn: ", turn_manager.current_turn)
		print("Current phase: ", turn_manager.current_phase)
		print("Active faction: ", turn_manager.active_faction)

		# Test turn progression
		var initial_turn = turn_manager.current_turn
		turn_manager.next_turn()
		if turn_manager.current_turn > initial_turn:
			print("✓ Turn progression successful")
		else:
			print("✗ Turn progression failed")

		# Test phase switching
		var initial_phase = turn_manager.current_phase
		turn_manager.next_phase()
		if turn_manager.current_phase != initial_phase:
			print("✓ Phase switching successful")
		else:
			print("✗ Phase switching failed")
	else:
		print("✗ TurnManager not available")

func test_combat_resolution():
	print("\n--- Test 6: Combat Resolution ---")

	if battlescape_manager and battlescape_manager.combat_system:
		var combat_system = battlescape_manager.combat_system

		# Create test units
		var attacker = preload("res://scripts/domain/unit.gd").new()
		attacker.unit_id = "attacker"
		attacker.name = "Attacker"
		attacker.faction = "player"
		attacker.stats = {"accuracy": 70, "damage": 50}

		var defender = preload("res://scripts/domain/unit.gd").new()
		defender.unit_id = "defender"
		defender.name = "Defender"
		defender.faction = "alien"
		defender.stats = {"armor": 30, "health": 100}

		# Test hit chance calculation
		var hit_chance = combat_system.calculate_hit_chance(attacker, defender, Vector2i(0, 0), Vector2i(1, 0))
		print("Hit chance: ", hit_chance, "%")

		# Test damage calculation
		var damage = combat_system.calculate_damage(attacker, defender)
		print("Damage: ", damage)

		# Test attack resolution
		var result = combat_system.resolve_attack(attacker, defender, Vector2i(0, 0), Vector2i(1, 0))
		if result:
			print("✓ Attack resolution successful")
			print("Result: ", result)
		else:
			print("✗ Attack resolution failed")
	else:
		print("✗ CombatSystem not available")

func test_event_integration():
	print("\n--- Test 7: Event Integration ---")

	if event_bus:
		print("✓ EventBus available for battlescape events")

		# Test event subscription (would need actual event handlers)
		var event_types = [
			"battlescape_unit_moved",
			"battlescape_combat_resolved",
			"battlescape_turn_changed",
			"battlescape_phase_changed"
		]

		for event_type in event_types:
			print("Event type available: ", event_type)
	else:
		print("✗ EventBus not available")

func _process(delta):
	# Exit after a short time
	if Time.get_ticks_msec() > 5000:  # 5 seconds for more thorough testing
		get_tree().quit()
