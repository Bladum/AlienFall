extends Node
class_name MultiUnitActionSystem

# MultiUnitActionSystem - Manages squad commands and formation movement
# Enables coordinated unit actions and tactical formations

enum FormationType {
	LINE,        # Units in a straight line
	COLUMN,      # Units in a column
	WEDGE,       # V-shaped formation
	CIRCLE,      # Circular formation
	SCATTER,     # Spread out formation
}

enum SquadCommand {
	MOVE_TO_POSITION,    # Move squad to target position
	ATTACK_TARGET,       # All units attack designated target
	DEFEND_POSITION,     # Hold position and defend
	FOLLOW_LEADER,       # Follow squad leader
	SPREAD_OUT,          # Disperse for better cover
	GROUP_UP,            # Form tight formation
	RETREAT,             # Withdraw from combat
}

var squad_units: Array[Unit] = []
var squad_leader: Unit = null
var current_formation: FormationType = FormationType.LINE
var command_queue: Array = []

signal squad_command_executed(command: SquadCommand, success: bool)
signal formation_changed(new_formation: FormationType)
signal squad_leader_changed(new_leader: Unit)

func _ready():
	print("MultiUnitActionSystem initialized")

func add_unit_to_squad(unit: Unit) -> bool:
	if unit in squad_units:
		return false
	
	squad_units.append(unit)
	
	# Set as leader if first unit
	if squad_leader == null:
		set_squad_leader(unit)
	
	print("Added unit ", unit.name, " to squad. Squad size: ", squad_units.size())
	return true

func remove_unit_from_squad(unit: Unit) -> bool:
	if not unit in squad_units:
		return false
	
	squad_units.erase(unit)
	
	# Choose new leader if leader was removed
	if unit == squad_leader and squad_units.size() > 0:
		set_squad_leader(squad_units[0])
	
	print("Removed unit ", unit.name, " from squad. Squad size: ", squad_units.size())
	return true

func set_squad_leader(unit: Unit) -> bool:
	if not unit in squad_units:
		return false
	
	squad_leader = unit
	emit_signal("squad_leader_changed", squad_leader)
	print("New squad leader: ", unit.name)
	return true

func set_formation(formation: FormationType) -> bool:
	if formation == current_formation:
		return true
	
	current_formation = formation
	emit_signal("formation_changed", current_formation)
	
	# Rearrange units into new formation
	rearrange_into_formation()
	
	print("Formation changed to: ", FormationType.keys()[formation])
	return true

func rearrange_into_formation():
	if squad_units.size() == 0 or squad_leader == null:
		return
	
	var leader_pos = squad_leader.position
	var positions = calculate_formation_positions(leader_pos, squad_units.size())
	
	# Assign positions to units (skip leader at index 0)
	for i in range(1, squad_units.size()):
		if i < positions.size():
			var unit = squad_units[i]
			var target_pos = positions[i]
			# In a real implementation, this would use pathfinding
			unit.position = target_pos
			print("Unit ", unit.name, " moved to formation position: ", target_pos)

func calculate_formation_positions(center_pos: Vector2, unit_count: int) -> Array[Vector2]:
	var positions = []
	
	match current_formation:
		FormationType.LINE:
			# Horizontal line formation
			for i in range(unit_count):
				var offset = Vector2(i * 2 - (unit_count - 1), 0)
				positions.append(center_pos + offset)
		
		FormationType.COLUMN:
			# Vertical column formation
			for i in range(unit_count):
				var offset = Vector2(0, i * 2 - (unit_count - 1))
				positions.append(center_pos + offset)
		
		FormationType.WEDGE:
			# V-shaped wedge formation
			for i in range(unit_count):
				var row = i / 3
				var col = i % 3 - 1
				var offset = Vector2(col * 2, row * 2)
				positions.append(center_pos + offset)
		
		FormationType.CIRCLE:
			# Circular formation
			var radius = 2.0
			for i in range(unit_count):
				var angle = (2 * PI * i) / unit_count
				var offset = Vector2(cos(angle) * radius, sin(angle) * radius)
				positions.append(center_pos + offset)
		
		FormationType.SCATTER:
			# Spread out randomly
			var rng = RandomNumberGenerator.new()
			rng.seed = Time.get_ticks_msec()
			for i in range(unit_count):
				var offset = Vector2(
					rng.randf_range(-3, 3),
					rng.randf_range(-3, 3)
				)
				positions.append(center_pos + offset)
	
	return positions

func execute_squad_command(command: SquadCommand, target = null) -> bool:
	if squad_units.size() == 0:
		return false
	
	var success = false
	
	match command:
		SquadCommand.MOVE_TO_POSITION:
			success = execute_move_command(target)
		SquadCommand.ATTACK_TARGET:
			success = execute_attack_command(target)
		SquadCommand.DEFEND_POSITION:
			success = execute_defend_command(target)
		SquadCommand.FOLLOW_LEADER:
			success = execute_follow_command()
		SquadCommand.SPREAD_OUT:
			success = execute_spread_command()
		SquadCommand.GROUP_UP:
			success = execute_group_command()
		SquadCommand.RETREAT:
			success = execute_retreat_command()
	
	emit_signal("squad_command_executed", command, success)
	return success

func execute_move_command(target_position: Vector2) -> bool:
	if squad_units.size() == 0:
		return false
	
	print("Executing squad move command to: ", target_position)
	
	# Calculate formation positions around target
	var positions = calculate_formation_positions(target_position, squad_units.size())
	
	# Move each unit to their assigned position
	for i in range(squad_units.size()):
		if i < positions.size():
			var unit = squad_units[i]
			var target_pos = positions[i]
			# In a real implementation, this would use the movement system
			unit.position = target_pos
			print("Unit ", unit.name, " moving to: ", target_pos)
	
	return true

func execute_attack_command(target: Unit) -> bool:
	if squad_units.size() == 0 or target == null:
		return false
	
	print("Executing squad attack command on: ", target.name)
	
	# Each unit attacks the target if they can
	for unit in squad_units:
		if unit != target and unit.is_alive:
			# In a real implementation, this would use the combat system
			print("Unit ", unit.name, " attacking ", target.name)
	
	return true

func execute_defend_command(position: Vector2) -> bool:
	if squad_units.size() == 0:
		return false
	
	print("Executing squad defend command at: ", position)
	
	# Move to defensive positions
	set_formation(FormationType.CIRCLE)
	execute_move_command(position)
	
	return true

func execute_follow_command() -> bool:
	if squad_units.size() == 0 or squad_leader == null:
		return false
	
	print("Executing squad follow command")
	
	# Rearrange into formation around leader
	rearrange_into_formation()
	
	return true

func execute_spread_command() -> bool:
	if squad_units.size() == 0:
		return false
	
	print("Executing squad spread command")
	
	set_formation(FormationType.SCATTER)
	
	return true

func execute_group_command() -> bool:
	if squad_units.size() == 0:
		return false
	
	print("Executing squad group command")
	
	set_formation(FormationType.CIRCLE)
	
	return true

func execute_retreat_command() -> bool:
	if squad_units.size() == 0:
		return false
	
	print("Executing squad retreat command")
	
	# Move away from current position
	var retreat_pos = Vector2(-10, -10)  # Simplified retreat direction
	execute_move_command(retreat_pos)
	
	return true

func get_squad_center() -> Vector2:
	if squad_units.size() == 0:
		return Vector2.ZERO
	
	var total_pos = Vector2.ZERO
	for unit in squad_units:
		total_pos += unit.position
	
	return total_pos / squad_units.size()

func get_squad_bounds() -> Rect2:
	if squad_units.size() == 0:
		return Rect2()
	
	var min_pos = squad_units[0].position
	var max_pos = squad_units[0].position
	
	for unit in squad_units:
		min_pos = min_pos.min(unit.position)
		max_pos = max_pos.max(unit.position)
	
	return Rect2(min_pos, max_pos - min_pos)

func clear_squad():
	squad_units.clear()
	squad_leader = null
	command_queue.clear()
	print("Squad cleared")

func to_dict() -> Dictionary:
	var unit_ids = []
	for unit in squad_units:
		unit_ids.append(unit.unit_id)
	
	return {
		"squad_units": unit_ids,
		"squad_leader_id": squad_leader.unit_id if squad_leader else "",
		"current_formation": current_formation,
		"command_queue": command_queue.duplicate()
	}

func from_dict(data: Dictionary):
	squad_units.clear()
	command_queue = data.get("command_queue", []).duplicate()
	current_formation = data.get("current_formation", FormationType.LINE)
	
	# Note: Unit references would need to be resolved from the main unit list
	print("Squad state loaded")
