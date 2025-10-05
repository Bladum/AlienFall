extends Resource
class_name Mission

# Mission - Represents objectives and encounters in the game
# Core domain class for missions, quests, and encounters

@export var id: String = ""
@export var name: String = ""
@export var type: String = ""  # terror, research, abduction, etc.
@export var province_id: String = ""
@export var difficulty: int = 1

# Location and timing
@export var longitude: float = 0.0
@export var latitude: float = 0.0
@export var altitude: int = 0  # 0 = ground, 1 = low, 2 = high
@export var spawn_day: int = 1
@export var duration_days: int = 7

# Detection and visibility
@export var cover: int = 50  # 0-100, lower = easier to detect
@export var detected: bool = false
@export var detection_day: int = -1

# Combat parameters
@export var deployment_budget: int = 100
@export var alien_race: String = "sectoid"
@export var alien_count: int = 4
@export var alien_rank: String = "rookie"

# Rewards and consequences
@export var funding_reward: int = 0
@export var experience_reward: int = 0
@export var research_chance: float = 0.0  # chance to get research data

# Status
@export var is_active: bool = true
@export var is_completed: bool = false
@export var is_failed: bool = false
@export var completion_day: int = -1

# Map generation seed
@export var map_seed: int = 0

func _init(mission_id: String = "", mission_name: String = ""):
    id = mission_id
    name = mission_name
    map_seed = randi()

# Create mission from data dictionary
static func from_data(data: Dictionary) -> Mission:
    var mission = Mission.new(data.get("id", ""), data.get("name", ""))
    
    mission.type = data.get("type", "")
    mission.province_id = data.get("province_id", "")
    mission.difficulty = data.get("difficulty", 1)
    
    mission.longitude = data.get("longitude", 0.0)
    mission.latitude = data.get("latitude", 0.0)
    mission.altitude = data.get("altitude", 0)
    mission.spawn_day = data.get("spawn_day", 1)
    mission.duration_days = data.get("duration_days", 7)
    
    mission.cover = data.get("cover", 50)
    mission.detected = data.get("detected", false)
    mission.detection_day = data.get("detection_day", -1)
    
    mission.deployment_budget = data.get("deployment_budget", 100)
    mission.alien_race = data.get("alien_race", "sectoid")
    mission.alien_count = data.get("alien_count", 4)
    mission.alien_rank = data.get("alien_rank", "rookie")
    
    mission.funding_reward = data.get("funding_reward", 0)
    mission.experience_reward = data.get("experience_reward", 0)
    mission.research_chance = data.get("research_chance", 0.0)
    
    return mission

# Convert mission to dictionary
func to_dict() -> Dictionary:
    return {
        "id": id,
        "name": name,
        "type": type,
        "province_id": province_id,
        "difficulty": difficulty,
        "longitude": longitude,
        "latitude": latitude,
        "altitude": altitude,
        "spawn_day": spawn_day,
        "duration_days": duration_days,
        "cover": cover,
        "detected": detected,
        "detection_day": detection_day,
        "deployment_budget": deployment_budget,
        "alien_race": alien_race,
        "alien_count": alien_count,
        "alien_rank": alien_rank,
        "funding_reward": funding_reward,
        "experience_reward": experience_reward,
        "research_chance": research_chance,
        "is_active": is_active,
        "is_completed": is_completed,
        "is_failed": is_failed,
        "completion_day": completion_day,
        "map_seed": map_seed
    }

# Check if mission is expired
func is_expired(current_day: int) -> bool:
    return current_day > (spawn_day + duration_days)

# Get days remaining
func get_days_remaining(current_day: int) -> int:
    var end_day = spawn_day + duration_days
    return max(0, end_day - current_day)

# Mark as detected
func mark_detected(current_day: int) -> void:
    detected = true
    detection_day = current_day
    
    EventBus.publish("mission_detected", {
        "mission_id": id,
        "detection_day": detection_day
    })

# Complete mission successfully
func complete(current_day: int) -> void:
    is_completed = true
    is_active = false
    completion_day = current_day
    
    EventBus.publish("mission_completed", {
        "mission_id": id,
        "completion_day": completion_day,
        "funding_reward": funding_reward,
        "experience_reward": experience_reward
    })

# Fail mission
func fail(current_day: int) -> void:
    is_failed = true
    is_active = false
    completion_day = current_day
    
    EventBus.publish("mission_failed", {
        "mission_id": id,
        "failure_day": completion_day
    })

# Get mission type display name
func get_type_display_name() -> String:
    match type:
        "terror":
            return "Terror Mission"
        "research":
            return "Research Mission"
        "abduction":
            return "Abduction Mission"
        "infiltration":
            return "Infiltration Mission"
        "base_attack":
            return "Base Attack"
        "ufo_crash":
            return "UFO Crash Site"
        _:
            return "Unknown Mission"

# Get difficulty display name
func get_difficulty_display_name() -> String:
    match difficulty:
        1:
            return "Easy"
        2:
            return "Normal"
        3:
            return "Hard"
        4:
            return "Very Hard"
        5:
            return "Extreme"
        _:
            return "Unknown"

# Calculate detection chance based on current radar coverage
func get_detection_chance(radar_coverage: float) -> float:
    # Base detection chance modified by radar coverage and mission cover
    var base_chance = 0.1  # 10% base chance
    var coverage_modifier = radar_coverage / 100.0  # Convert to 0-1
    var cover_modifier = (100.0 - cover) / 100.0  # Lower cover = higher chance
    
    return base_chance * coverage_modifier * cover_modifier

# Get position as Vector2 (for UI display)
func get_position() -> Vector2:
    return Vector2(longitude, latitude)

# Check if mission is at specific location (with tolerance)
func is_at_location(check_longitude: float, check_latitude: float, tolerance: float = 1.0) -> bool:
    var distance = sqrt(pow(longitude - check_longitude, 2) + pow(latitude - check_latitude, 2))
    return distance <= tolerance
