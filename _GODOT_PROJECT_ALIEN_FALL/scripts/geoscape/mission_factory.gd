extends Node

# MissionFactory - Creates and configures missions for the geoscape
# Handles mission generation, difficulty scaling, and mission properties

const MISSION_TYPES = {
	"UFO_Scout": {
		"name": "UFO Scout",
		"description": "A small scout UFO has been detected",
		"difficulty": 1,
		"duration_hours": 48,
		"reward_xp": 50,
		"reward_credits": 1000
	},
	"UFO_Fighter": {
		"name": "UFO Fighter",
		"description": "A combat-capable UFO fighter is active",
		"difficulty": 2,
		"duration_hours": 36,
		"reward_xp": 100,
		"reward_credits": 2000
	},
	"UFO_Destroyer": {
		"name": "UFO Destroyer",
		"description": "A powerful destroyer-class UFO threatens the region",
		"difficulty": 3,
		"duration_hours": 24,
		"reward_xp": 200,
		"reward_credits": 5000
	},
	"Terror_Site": {
		"name": "Terror Site",
		"description": "Aliens are attacking a civilian location",
		"difficulty": 3,
		"duration_hours": 12,
		"reward_xp": 150,
		"reward_credits": 3000
	},
	"Alien_Base": {
		"name": "Alien Base",
		"description": "An alien base has been located",
		"difficulty": 4,
		"duration_hours": 72,
		"reward_xp": 500,
		"reward_credits": 10000
	}
}

func create_mission(mission_type: String, day_number: int) -> Mission:
	if not MISSION_TYPES.has(mission_type):
		print("ERROR: Unknown mission type: " + mission_type)
		return null
	
	var template = MISSION_TYPES[mission_type]
	var mission = Mission.new()
	
	# Basic properties
	mission.name = template.name
	mission.type = mission_type
	mission.description = template.description
	mission.difficulty = template.difficulty
	
	# Scale difficulty based on day
	var difficulty_multiplier = 1.0 + (day_number - 1) * 0.1
	mission.difficulty = int(mission.difficulty * difficulty_multiplier)
	
	# Time properties
	mission.duration_hours = template.duration_hours
	mission.time_remaining = mission.duration_hours * 3600  # Convert to seconds
	mission.day_created = day_number
	
	# Rewards
	mission.reward_xp = template.reward_xp
	mission.reward_credits = template.reward_credits
	
	# Random position on world map
	mission.position = Vector2(
		randi() % 1000,  # World coordinates
		randi() % 1000
	)
	
	# Generate unique ID
	mission.id = "mission_" + mission_type + "_" + str(day_number) + "_" + str(randi())
	
	print("Created mission: " + mission.name + " (ID: " + mission.id + ")")
	return mission

func create_random_mission(day_number: int) -> Mission:
	var mission_types = MISSION_TYPES.keys()
	var random_type = mission_types[randi() % mission_types.size()]
	return create_mission(random_type, day_number)

func get_available_mission_types() -> Array:
	return MISSION_TYPES.keys()

func get_mission_template(mission_type: String) -> Dictionary:
	if MISSION_TYPES.has(mission_type):
		return MISSION_TYPES[mission_type].duplicate()
	return {}

# Mission class definition
class Mission:
	var id: String
	var name: String
	var type: String
	var description: String
	var difficulty: int
	var duration_hours: int
	var time_remaining: int
	var day_created: int
	var position: Vector2
	var reward_xp: int
	var reward_credits: int
	var is_completed: bool = false
	var is_failed: bool = false
	
	func update_timer(seconds_passed: int):
		time_remaining -= seconds_passed
		if time_remaining <= 0:
			time_remaining = 0
			is_failed = true
	
	func is_expired() -> bool:
		return time_remaining <= 0 and not is_completed
	
	func complete():
		is_completed = true
	
	func get_time_remaining_string() -> String:
		var hours = time_remaining / 3600
		var minutes = (time_remaining % 3600) / 60
		return str(hours) + "h " + str(minutes) + "m"
	
	func get_difficulty_string() -> String:
		match difficulty:
			1: return "Easy"
			2: return "Medium"
			3: return "Hard"
			4: return "Very Hard"
			5: return "Extreme"
			_: return "Unknown"
