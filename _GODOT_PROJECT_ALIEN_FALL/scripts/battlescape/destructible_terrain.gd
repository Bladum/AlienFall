extends Node
class_name DestructibleTerrain

# DestructibleTerrain - Manages terrain that can be damaged and destroyed
# Handles environmental damage, dynamic cover, and terrain modifications

enum TerrainType {
	SOFT_COVER,      # Low walls, crates, light cover
	HARD_COVER,      # Concrete walls, heavy barriers
	DESTRUCTIBLE,    # Objects that can be destroyed
	INDestructible   # Terrain that cannot be damaged
}

var terrain_grid = {}  # position -> terrain data
var damage_zones = []  # Areas affected by explosions

signal terrain_destroyed(position: Vector2i, terrain_type: TerrainType)
signal cover_modified(position: Vector2i, new_cover_value: int)

func _ready():
	print("DestructibleTerrain system initialized")

func add_terrain_at(position: Vector2i, terrain_type: TerrainType, health: int = 100):
	var terrain_data = {
		"type": terrain_type,
		"health": health,
		"max_health": health,
		"position": position,
		"cover_value": get_cover_value_for_type(terrain_type),
		"blocks_movement": terrain_type != TerrainType.DESTRUCTIBLE,
		"blocks_los": terrain_type in [TerrainType.SOFT_COVER, TerrainType.HARD_COVER]
	}
	
	terrain_grid[position] = terrain_data
	print("Added terrain at ", position, " of type ", TerrainType.keys()[terrain_type])

func remove_terrain_at(position: Vector2i):
	if terrain_grid.has(position):
		var terrain_data = terrain_grid[position]
		terrain_grid.erase(position)
		print("Removed terrain at ", position)

func get_terrain_at(position: Vector2i) -> Dictionary:
	return terrain_grid.get(position, {})

func is_position_blocked(position: Vector2i) -> bool:
	var terrain = get_terrain_at(position)
	return terrain.get("blocks_movement", false)

func get_cover_value_at(position: Vector2i) -> int:
	var terrain = get_terrain_at(position)
	return terrain.get("cover_value", 0)

func apply_damage_at(position: Vector2i, damage: int, damage_type: String = "explosive"):
	if not terrain_grid.has(position):
		return
	
	var terrain = terrain_grid[position]
	
	# Apply damage modifiers based on terrain type and damage type
	var actual_damage = calculate_damage(terrain, damage, damage_type)
	terrain.health -= actual_damage
	
	print("Applied ", actual_damage, " damage to terrain at ", position, " (remaining: ", terrain.health, ")")
	
	# Check if terrain is destroyed
	if terrain.health <= 0:
		destroy_terrain_at(position)
	else:
		# Terrain is damaged but not destroyed - reduce effectiveness
		update_terrain_effectiveness(terrain, position)

func calculate_damage(terrain: Dictionary, base_damage: int, damage_type: String) -> int:
	var damage = base_damage
	
	# Terrain type modifiers
	match terrain.type:
		TerrainType.SOFT_COVER:
			damage *= 1.5  # Soft cover takes more damage
		TerrainType.HARD_COVER:
			damage *= 0.7  # Hard cover resists damage
		TerrainType.DESTRUCTIBLE:
			damage *= 2.0  # Destructible objects are very vulnerable
		TerrainType.INDestructible:
			return 0  # Cannot be damaged
	
	# Damage type modifiers
	match damage_type:
		"explosive":
			damage *= 1.3  # Explosives are good at destroying terrain
		"plasma":
			damage *= 1.1  # Plasma has moderate terrain damage
		"kinetic":
			damage *= 0.8  # Kinetic weapons are less effective
	
	return int(damage)

func destroy_terrain_at(position: Vector2i):
	if not terrain_grid.has(position):
		return
	
	var terrain = terrain_grid[position]
	var terrain_type = terrain.type
	
	# Remove the terrain
	terrain_grid.erase(position)
	
	# Create debris or effects
	create_destruction_effects(position, terrain_type)
	
	# Notify listeners
	terrain_destroyed.emit(position, terrain_type)
	
	print("Terrain destroyed at ", position, " (type: ", TerrainType.keys()[terrain_type], ")")

func update_terrain_effectiveness(terrain: Dictionary, position: Vector2i):
	# Reduce cover value based on damage
	var health_percentage = float(terrain.health) / terrain.max_health
	var new_cover_value = int(terrain.cover_value * health_percentage)
	
	terrain.cover_value = new_cover_value
	terrain.blocks_los = health_percentage > 0.3  # Los blocked until heavily damaged
	
	cover_modified.emit(position, new_cover_value)
	
	print("Terrain at ", position, " effectiveness reduced to ", health_percentage * 100, "%")

func create_explosion_damage_zone(center: Vector2i, radius: int, damage: int):
	var affected_positions = []
	
	# Calculate all positions within the blast radius
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var pos = Vector2i(x, y)
			var distance = center.distance_to(pos)
			
			if distance <= radius:
				affected_positions.append({
					"position": pos,
					"distance": distance,
					"damage": calculate_falloff_damage(damage, distance, radius)
				})
	
	# Apply damage to all affected positions
	for zone in affected_positions:
		apply_damage_at(zone.position, zone.damage, "explosive")
	
	print("Explosion at ", center, " affected ", affected_positions.size(), " terrain positions")

func calculate_falloff_damage(base_damage: int, distance: float, max_radius: int) -> int:
	# Damage falls off with distance
	var falloff_factor = 1.0 - (distance / max_radius)
	falloff_factor = clamp(falloff_factor, 0.1, 1.0)
	
	return int(base_damage * falloff_factor)

func get_cover_value_for_type(terrain_type: TerrainType) -> int:
	match terrain_type:
		TerrainType.SOFT_COVER:
			return 20  # 20% damage reduction
		TerrainType.HARD_COVER:
			return 40  # 40% damage reduction
		TerrainType.DESTRUCTIBLE:
			return 10  # 10% damage reduction
		TerrainType.INDestructible:
			return 50  # 50% damage reduction
		_:
			return 0

func create_destruction_effects(position: Vector2i, terrain_type: TerrainType):
	# This would trigger particle effects, sound effects, etc.
	# For now, just log the effect
	match terrain_type:
		TerrainType.SOFT_COVER:
			print("Soft cover destruction effect at ", position)
		TerrainType.HARD_COVER:
			print("Hard cover destruction effect at ", position)
		TerrainType.DESTRUCTIBLE:
			print("Destructible object destruction effect at ", position)

func get_all_terrain_positions() -> Array:
	return terrain_grid.keys()

func clear_all_terrain():
	terrain_grid.clear()
	print("All terrain cleared")

func save_terrain_state() -> Dictionary:
	return {
		"terrain_grid": terrain_grid.duplicate(),
		"damage_zones": damage_zones.duplicate()
	}

func load_terrain_state(state: Dictionary):
	terrain_grid = state.get("terrain_grid", {}).duplicate()
	damage_zones = state.get("damage_zones", []).duplicate()
	print("Terrain state loaded with ", terrain_grid.size(), " terrain pieces")

func to_dict() -> Dictionary:
	return {
		"terrain_grid": terrain_grid.duplicate(),
		"damage_zones": damage_zones.duplicate()
	}

func from_dict(state: Dictionary):
	terrain_grid = state.get("terrain_grid", {}).duplicate()
	damage_zones = state.get("damage_zones", []).duplicate()
	print("Terrain state loaded with ", terrain_grid.size(), " terrain pieces")
