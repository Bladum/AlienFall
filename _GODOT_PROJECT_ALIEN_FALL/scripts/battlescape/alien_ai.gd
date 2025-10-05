extends Node
class_name AlienAI

# Alien AI System - Controls alien unit behavior in battlescape
# Provides intelligent decision-making for enemy units

enum AIState { IDLE, PATROL, HUNTING, ATTACKING, RETREATING, OVERWATCH }
enum AIBehavior { AGGRESSIVE, DEFENSIVE, STEALTHY, BERSERK }

@export var ai_state: AIState = AIState.IDLE
@export var ai_behavior: AIBehavior = AIBehavior.AGGRESSIVE
@export var detection_range: int = 12
@export var aggression_level: float = 0.7  # 0.0 = passive, 1.0 = aggressive
@export var reaction_time: float = 1.0  # seconds to react

var controlled_unit = null
var last_known_enemy_positions = []
var patrol_points = []
var current_patrol_index = 0
var reaction_timer = 0.0
var last_action_time = 0.0

signal ai_decision_made(decision_type: String, target_position: Vector2i)

func _ready():
	# Initialize AI
	randomize_patrol_points()
	last_action_time = Time.get_time()

func _process(delta):
	if not controlled_unit or not controlled_unit.is_alive:
		return

	reaction_timer += delta

	# Update AI state based on situation
	update_ai_state()

	# Make decisions based on current state
	make_decision()

func set_controlled_unit(unit):
	controlled_unit = unit
	if controlled_unit:
		controlled_unit.ai_controller = self

func update_ai_state():
	if not controlled_unit:
		return

	# Check for visible enemies
	var visible_enemies = get_visible_enemies()

	if visible_enemies.size() > 0:
		# Enemies detected
		last_known_enemy_positions = visible_enemies

		if ai_behavior == AIBehavior.AGGRESSIVE:
			ai_state = AIState.ATTACKING
		elif ai_behavior == AIBehavior.DEFENSIVE:
			ai_state = AIState.ATTACKING if randf() < aggression_level else AIState.RETREATING
		else:  # STEALTHY
			ai_state = AIState.HUNTING if randf() < 0.3 else AIState.IDLE

	elif last_known_enemy_positions.size() > 0:
		# No visible enemies but we know where they were
		if ai_behavior == AIBehavior.AGGRESSIVE:
			ai_state = AIState.HUNTING
		else:
			ai_state = AIState.PATROL

	else:
		# No enemies detected
		if ai_state == AIState.IDLE:
			ai_state = AIState.PATROL if randf() < 0.4 else AIState.IDLE

func make_decision():
	if reaction_timer < reaction_time:
		return  # Not ready to act yet

	var current_time = Time.get_time()
	if current_time - last_action_time < 1.0:  # Minimum 1 second between actions
		return

	match ai_state:
		AIState.IDLE:
			make_idle_decision()
		AIState.PATROL:
			make_patrol_decision()
		AIState.HUNTING:
			make_hunting_decision()
		AIState.ATTACKING:
			make_attack_decision()
		AIState.RETREATING:
			make_retreat_decision()
		AIState.OVERWATCH:
			make_overwatch_decision()

	last_action_time = current_time
	reaction_timer = 0.0

func make_idle_decision():
	# Occasionally look around or move slightly
	if randf() < 0.2:  # 20% chance
		var random_offset = Vector2i(randi_range(-2, 2), randi_range(-2, 2))
		var new_position = controlled_unit.position + random_offset
		emit_signal("ai_decision_made", "move", new_position)

func make_patrol_decision():
	if patrol_points.size() == 0:
		randomize_patrol_points()

	if current_patrol_index < patrol_points.size():
		var target_point = patrol_points[current_patrol_index]
		emit_signal("ai_decision_made", "move", target_point)
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func make_hunting_decision():
	if last_known_enemy_positions.size() > 0:
		# Move toward last known enemy position
		var target_pos = last_known_enemy_positions[0]
		var direction = target_pos - controlled_unit.position
		var distance = direction.length()

		if distance > 1:
			# Move closer
			var move_direction = direction.normalized()
			var new_position = controlled_unit.position + Vector2i(move_direction.x, move_direction.y)
			emit_signal("ai_decision_made", "move", new_position)
		else:
			# Close enough, switch to attack mode
			ai_state = AIState.ATTACKING

func make_attack_decision():
	var visible_enemies = get_visible_enemies()

	if visible_enemies.size() > 0:
		var target = select_best_target(visible_enemies)

		if target:
			# Check if we have line of sight and are in range
			if can_attack_target(target):
				emit_signal("ai_decision_made", "attack", target)
			else:
				# Move closer to target
				var direction = target - controlled_unit.position
				var move_direction = direction.normalized()
				var new_position = controlled_unit.position + Vector2i(move_direction.x, move_direction.y)
				emit_signal("ai_decision_made", "move", new_position)

func make_retreat_decision():
	# Move away from known enemy positions
	if last_known_enemy_positions.size() > 0:
		var enemy_pos = last_known_enemy_positions[0]
		var direction = controlled_unit.position - enemy_pos
		var retreat_direction = direction.normalized()
		var retreat_position = controlled_unit.position + Vector2i(retreat_direction.x * 3, retreat_direction.y * 3)
		emit_signal("ai_decision_made", "move", retreat_position)

func make_overwatch_decision():
	# Stay in position and watch for enemies
	# Could implement special overwatch mechanics here
	pass

func get_visible_enemies() -> Array:
	# This would integrate with the line of sight system
	# For now, return mock enemy positions within detection range
	var enemies = []
	var battlescape_manager = get_node("/root/BattlescapeManager")

	if battlescape_manager and battlescape_manager.battlescape_map:
		var map = battlescape_manager.battlescape_map
		var all_units = map.get_all_units()

		for unit in all_units:
			if unit.faction != controlled_unit.faction:
				var distance = controlled_unit.position.distance_to(unit.position)
				if distance <= detection_range:
					enemies.append(unit.position)

	return enemies

func select_best_target(visible_enemies: Array) -> Vector2i:
	if visible_enemies.size() == 0:
		return Vector2i.ZERO

	# Select closest enemy
	var closest_pos = visible_enemies[0]
	var closest_distance = controlled_unit.position.distance_to(closest_pos)

	for enemy_pos in visible_enemies:
		var distance = controlled_unit.position.distance_to(enemy_pos)
		if distance < closest_distance:
			closest_distance = distance
			closest_pos = enemy_pos

	return closest_pos

func can_attack_target(target_pos: Vector2i) -> bool:
	# Check line of sight and range
	var battlescape_manager = get_node("/root/BattlescapeManager")

	if battlescape_manager and battlescape_manager.line_of_sight_system:
		var los_system = battlescape_manager.line_of_sight_system
		if los_system.has_line_of_sight(controlled_unit.position, target_pos):
			var distance = controlled_unit.position.distance_to(target_pos)
			# Check if we have a weapon with sufficient range
			var weapon = get_equipped_weapon()
			if weapon and distance <= weapon.range:
				return true

	return false

func get_equipped_weapon():
	# Get the unit's equipped weapon
	if controlled_unit and controlled_unit.has_node("InventoryManager"):
		var inventory = controlled_unit.get_node("InventoryManager")
		return inventory.get_equipped_weapon(inventory.SlotType.PRIMARY_WEAPON)
	return null

func randomize_patrol_points():
	patrol_points.clear()
	var num_points = randi_range(3, 6)

	for i in range(num_points):
		var random_pos = Vector2i(
			randi_range(-10, 10),
			randi_range(-10, 10)
		)
		patrol_points.append(controlled_unit.position + random_pos)

func on_damage_taken(damage: int, attacker_pos: Vector2i):
	# React to taking damage
	last_known_enemy_positions = [attacker_pos]

	if ai_behavior == AIBehavior.AGGRESSIVE:
		ai_state = AIState.ATTACKING
		aggression_level = min(aggression_level + 0.2, 1.0)  # Become more aggressive
	elif ai_behavior == AIBehavior.DEFENSIVE:
		ai_state = AIState.RETREATING if randf() < 0.6 else AIState.ATTACKING
	else:  # STEALTHY
		ai_state = AIState.RETREATING

	reaction_timer = 0.0  # React immediately to damage

func on_enemy_detected(enemy_pos: Vector2i):
	# Called when enemy is detected
	last_known_enemy_positions = [enemy_pos]

	if ai_behavior == AIBehavior.AGGRESSIVE:
		ai_state = AIState.ATTACKING
	elif ai_behavior == AIBehavior.STEALTHY:
		ai_state = AIState.HUNTING

func get_ai_status() -> Dictionary:
	return {
		"state": AIState.keys()[ai_state],
		"behavior": AIBehavior.keys()[ai_behavior],
		"aggression": aggression_level,
		"reaction_timer": reaction_timer,
		"known_enemies": last_known_enemy_positions.size()
	}
