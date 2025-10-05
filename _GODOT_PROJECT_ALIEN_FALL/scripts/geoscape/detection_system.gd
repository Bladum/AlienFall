extends Node

# DetectionSystem - Handles detection mechanics for missions and UFOs
# Calculates detection chances, handles interception, and manages detection events

var base_detection_chance: float = 0.1  # 10% base chance
var interception_bonus: float = 0.3     # 30% bonus for interception
var radar_range: float = 500.0          # Radar detection range in world units

# Detection modifiers
var detection_modifiers = {
	"weather_clear": 1.0,
	"weather_cloudy": 0.8,
	"weather_storm": 0.6,
	"time_day": 1.0,
	"time_night": 0.7,
	"terrain_open": 1.0,
	"terrain_urban": 0.9,
	"terrain_mountain": 0.5
}

func _ready():
	print("DetectionSystem initialized")

func calculate_detection_chance(mission) -> float:
	if not mission:
		return 0.0
	
	var chance = base_detection_chance
	
	# Mission type modifiers
	match mission.type:
		"UFO_Scout":
			chance *= 0.8  # Scouts are stealthier
		"UFO_Fighter":
			chance *= 1.0  # Standard detection
		"UFO_Destroyer":
			chance *= 1.2  # Destroyers are more detectable
		"Terror_Site":
			chance *= 1.5  # Terror sites have higher activity
		"Alien_Base":
			chance *= 0.5  # Bases are well hidden
	
	# Difficulty modifier
	chance *= (1.0 + mission.difficulty * 0.1)
	
	# Time remaining modifier (easier to detect as time runs out)
	var time_factor = 1.0 - (mission.time_remaining / (mission.duration_hours * 3600.0))
	chance *= (1.0 + time_factor * 0.5)
	
	# Random variation (±20%)
	var random_factor = 0.8 + (randf() * 0.4)
	chance *= random_factor
	
	# Clamp to reasonable range
	chance = clamp(chance, 0.01, 0.95)
	
	print("Detection chance for " + mission.name + ": " + str(chance * 100) + "%")
	return chance

func calculate_interception_chance(mission, interceptor_count: int = 1) -> float:
	var base_chance = calculate_detection_chance(mission)
	var interception_chance = base_chance + (interception_bonus * interceptor_count)
	
	# Interception is more effective at higher difficulties
	interception_chance *= (1.0 + mission.difficulty * 0.2)
	
	interception_chance = clamp(interception_chance, 0.05, 0.99)
	
	print("Interception chance for " + mission.name + ": " + str(interception_chance * 100) + "%")
	return interception_chance

func is_within_radar_range(mission_position: Vector2, radar_position: Vector2) -> bool:
	var distance = mission_position.distance_to(radar_position)
	return distance <= radar_range

func calculate_radar_detection_time(mission) -> float:
	# Time in hours to detect mission with radar
	var detection_chance = calculate_detection_chance(mission)
	
	# Inverse relationship - higher chance = faster detection
	var detection_time = 24.0 / detection_chance  # Base 24 hours
	
	# Random variation
	detection_time *= (0.5 + randf())
	
	return detection_time

func apply_environmental_modifier(chance: float, weather: String, time_of_day: String, terrain: String) -> float:
	var modifier = 1.0
	
	if detection_modifiers.has(weather):
		modifier *= detection_modifiers[weather]
	
	if detection_modifiers.has("time_" + time_of_day):
		modifier *= detection_modifiers["time_" + time_of_day]
	
	if detection_modifiers.has("terrain_" + terrain):
		modifier *= detection_modifiers["terrain_" + terrain]
	
	return chance * modifier

func simulate_detection_roll(mission) -> bool:
	var chance = calculate_detection_chance(mission)
	var roll = randf()
	var detected = roll < chance
	
	print("Detection roll for " + mission.name + ": " + str(roll) + " < " + str(chance) + " = " + str(detected))
	return detected

func get_detection_status(mission) -> Dictionary:
	return {
		"detected": simulate_detection_roll(mission),
		"chance": calculate_detection_chance(mission),
		"interception_chance": calculate_interception_chance(mission),
		"radar_time": calculate_radar_detection_time(mission)
	}

func update_radar_range(new_range: float):
	radar_range = new_range
	print("Radar range updated to: " + str(radar_range))

func get_radar_coverage_area() -> float:
	# Calculate area covered by radar (approximate circle area)
	return PI * radar_range * radar_range

func can_intercept_mission(mission, available_interceptors: int) -> bool:
	if available_interceptors <= 0:
		return false
	
	var interception_chance = calculate_interception_chance(mission, available_interceptors)
	return randf() < interception_chance

func get_optimal_interceptor_count(mission) -> int:
	# Calculate how many interceptors needed for 80% success chance
	var base_chance = calculate_detection_chance(mission)
	var target_chance = 0.8
	
	if base_chance >= target_chance:
		return 1
	
	var needed_bonus = target_chance - base_chance
	var interceptors_needed = ceil(needed_bonus / interception_bonus)
	
	return max(1, interceptors_needed)
