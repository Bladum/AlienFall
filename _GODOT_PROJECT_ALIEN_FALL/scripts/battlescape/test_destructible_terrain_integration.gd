extends Node

# Test script for Destructible Terrain integration with Combat System
# Demonstrates terrain damage during attacks

func _ready():
	print("=== Destructible Terrain Integration Test ===")

	# Create test systems
	var test_map = BattlescapeMap.new(10, 10)
	test_map.generate_random_map()

	var los_system = LineOfSightSystem.new(test_map)
	var terrain_system = DestructibleTerrain.new(test_map)
	var combat_system = CombatSystem.new(los_system, terrain_system)

	# Create test units
	var attacker = Unit.new()
	attacker.name = "Soldier"
	attacker.position = Vector2(2, 2)
	attacker.stats = {"health": 100, "tu": 50}

	var target = Unit.new()
	target.name = "Alien"
	target.position = Vector2(5, 5)
	target.stats = {"health": 100, "tu": 50}

	# Add units to map
	test_map.add_unit(attacker, attacker.position)
	test_map.add_unit(target, target.position)

	# Add some destructible terrain
	terrain_system.add_terrain_at(Vector2i(5, 5), DestructibleTerrain.TerrainType.SOFT_COVER, 50)
	terrain_system.add_terrain_at(Vector2i(6, 6), DestructibleTerrain.TerrainType.HARD_COVER, 100)

	print("Initial terrain at target position:", terrain_system.get_terrain_at(Vector2i(5, 5)))

	# Create test weapon
	var weapon = {
		"name": "Assault Rifle",
		"damage": 25,
		"accuracy": 70,
		"current_ammo": 30,
		"weapon_type": "bullet"
	}

	# Perform attack
	print("\n--- Performing Attack ---")
	var result = combat_system.perform_attack_enhanced(attacker, target, weapon, "single")

	print("Attack result:", result)

	# Check terrain damage
	print("\nTerrain after attack:")
	print("Target position terrain:", terrain_system.get_terrain_at(Vector2i(5, 5)))
	print("Adjacent terrain:", terrain_system.get_terrain_at(Vector2i(6, 6)))

	# Test explosion damage
	print("\n--- Testing Explosion Damage ---")
	var explosive_weapon = {
		"name": "Rocket Launcher",
		"damage": 40,
		"accuracy": 60,
		"current_ammo": 5,
		"weapon_type": "explosive",
		"explosion_radius": 2
	}

	# Reset target health
	target.stats.health = 100

	# Add more terrain for explosion test
	terrain_system.add_terrain_at(Vector2i(4, 4), DestructibleTerrain.TerrainType.DESTRUCTIBLE, 30)
	terrain_system.add_terrain_at(Vector2i(5, 4), DestructibleTerrain.TerrainType.SOFT_COVER, 40)
	terrain_system.add_terrain_at(Vector2i(6, 4), DestructibleTerrain.TerrainType.HARD_COVER, 80)

	print("Terrain before explosion:")
	print("4,4:", terrain_system.get_terrain_at(Vector2i(4, 4)))
	print("5,4:", terrain_system.get_terrain_at(Vector2i(5, 4)))
	print("6,4:", terrain_system.get_terrain_at(Vector2i(6, 4)))

	# Perform explosive attack
	var explosion_result = combat_system.perform_attack_enhanced(attacker, target, explosive_weapon, "single")
	print("Explosion attack result:", explosion_result)

	print("\nTerrain after explosion:")
	print("4,4:", terrain_system.get_terrain_at(Vector2i(4, 4)))
	print("5,4:", terrain_system.get_terrain_at(Vector2i(5, 4)))
	print("6,4:", terrain_system.get_terrain_at(Vector2i(6, 4)))
	print("5,5:", terrain_system.get_terrain_at(Vector2i(5, 5)))

	print("\n=== Test Complete ===")
