extends Node

# MissionFactory - Generates and manages missions on the geoscape
# Handles mission spawning, detection, and lifecycle

class_name MissionFactory

var active_missions: Array = []
var mission_templates: Dictionary = {}
var next_mission_id: int = 1

func _ready():
    print("MissionFactory: Initializing...")
    load_mission_templates()
    
    # Subscribe to relevant events
    EventBus.subscribe("game_mode_changed", Callable(self, "_on_game_mode_changed"))
    EventBus.subscribe("mission_completed", Callable(self, "_on_mission_completed"))
    EventBus.subscribe("mission_failed", Callable(self, "_on_mission_failed"))

func load_mission_templates():
    # Load mission templates from data
    mission_templates = {
        "terror_city": {
            "name": "Terror in {city}",
            "type": "terror",
            "difficulty": 2,
            "duration_days": 7,
            "cover": 40,
            "deployment_budget": 120,
            "alien_race": "sectoid",
            "alien_count": 8,
            "alien_rank": "squaddie",
            "funding_reward": 50000,
            "experience_reward": 50,
            "research_chance": 0.3
        },
        "ufo_crash": {
            "name": "UFO Crash Site",
            "type": "ufo_crash",
            "difficulty": 1,
            "duration_days": 14,
            "cover": 20,
            "deployment_budget": 80,
            "alien_race": "sectoid",
            "alien_count": 4,
            "alien_rank": "rookie",
            "funding_reward": 30000,
            "experience_reward": 30,
            "research_chance": 0.8
        },
        "abduction": {
            "name": "Abduction",
            "type": "abduction",
            "difficulty": 1,
            "duration_days": 5,
            "cover": 60,
            "deployment_budget": 60,
            "alien_race": "sectoid",
            "alien_count": 3,
            "alien_rank": "rookie",
            "funding_reward": 20000,
            "experience_reward": 20,
            "research_chance": 0.1
        },
        "research_outpost": {
            "name": "Research Outpost",
            "type": "research",
            "difficulty": 3,
            "duration_days": 10,
            "cover": 30,
            "deployment_budget": 150,
            "alien_race": "sectoid",
            "alien_count": 6,
            "alien_rank": "corporal",
            "funding_reward": 75000,
            "experience_reward": 75,
            "research_chance": 0.6
        }
    }
    
    print("MissionFactory: Loaded ", mission_templates.size(), " mission templates")

# Generate a new mission
func generate_mission(template_id: String, province_id: String, current_day: int) -> Mission:
    if not mission_templates.has(template_id):
        print("MissionFactory: Unknown mission template: ", template_id)
        return null
    
    var template = mission_templates[template_id]
    var mission_id = "mission_" + str(next_mission_id)
    next_mission_id += 1
    
    var mission = Mission.new(mission_id, template.name)
    mission.type = template.type
    mission.province_id = province_id
    mission.difficulty = template.difficulty
    mission.spawn_day = current_day
    mission.duration_days = template.duration_days
    mission.cover = template.cover
    mission.deployment_budget = template.deployment_budget
    mission.alien_race = template.alien_race
    mission.alien_count = template.alien_count
    mission.alien_rank = template.alien_rank
    mission.funding_reward = template.funding_reward
    mission.experience_reward = template.experience_reward
    mission.research_chance = template.research_chance
    
    # Generate random position within province
    var rng = RNGService.get_rng_handle("mission_position_" + mission_id)
    mission.longitude = rng.randf_range(-180.0, 180.0)
    mission.latitude = rng.randf_range(-90.0, 90.0)
    mission.altitude = rng.randi_range(0, 2)  # 0=ground, 1=low, 2=high
    
    print("MissionFactory: Generated mission ", mission_id, " of type ", template.type)
    return mission

# Spawn missions based on game state and random chance
func spawn_missions(current_day: int, difficulty_modifier: float = 1.0):
    var rng = RNGService.get_rng_handle("mission_spawn_" + str(current_day))
    
    # Base spawn chance per day
    var base_spawn_chance = 0.3 * difficulty_modifier
    
    # Spawn 0-2 missions per day
    var spawn_count = rng.rand_weighted([0.5, 0.3, 0.2])  # 50% none, 30% one, 20% two
    
    for i in range(spawn_count):
        var template_keys = mission_templates.keys()
        var template_id = template_keys[rng.randi() % template_keys.size()]
        
        # Generate random province (simplified)
        var province_id = "province_" + str(rng.randi_range(1, 10))
        
        var mission = generate_mission(template_id, province_id, current_day)
        if mission:
            active_missions.append(mission)
            
            EventBus.publish("mission_spawned", {
                "mission_id": mission.id,
                "mission_type": mission.type,
                "spawn_day": current_day
            })

# Update mission detection status
func update_detection(current_day: int, radar_coverage: float):
    for mission in active_missions:
        if not mission.detected and mission.is_active:
            var detection_chance = mission.get_detection_chance(radar_coverage)
            var rng = RNGService.get_rng_handle("mission_detection_" + mission.id + "_" + str(current_day))
            
            if rng.randf() < detection_chance:
                mission.mark_detected(current_day)

# Get all active missions
func get_active_missions() -> Array:
    return active_missions

# Get detected missions
func get_detected_missions() -> Array:
    var detected = []
    for mission in active_missions:
        if mission.detected and mission.is_active:
            detected.append(mission)
    return detected

# Get mission by ID
func get_mission_by_id(mission_id: String) -> Mission:
    for mission in active_missions:
        if mission.id == mission_id:
            return mission
    return null

# Remove completed/failed/expired missions
func cleanup_missions(current_day: int):
    var to_remove = []
    
    for mission in active_missions:
        if mission.is_expired(current_day) and mission.is_active:
            mission.fail(current_day)
            to_remove.append(mission)
        elif not mission.is_active:
            to_remove.append(mission)
    
    for mission in to_remove:
        active_missions.erase(mission)
        print("MissionFactory: Cleaned up mission ", mission.id)

# Get mission statistics
func get_mission_stats() -> Dictionary:
    var stats = {
        "total_active": active_missions.size(),
        "detected": 0,
        "by_type": {}
    }
    
    for mission in active_missions:
        if mission.detected:
            stats.detected += 1
        
        if not stats.by_type.has(mission.type):
            stats.by_type[mission.type] = 0
        stats.by_type[mission.type] += 1
    
    return stats

# Event handlers
func _on_game_mode_changed(data: Dictionary):
    if data.new_mode == GameState.GameMode.GEOSCAPE:
        print("MissionFactory: Entering geoscape mode")
    elif data.old_mode == GameState.GameMode.GEOSCAPE:
        print("MissionFactory: Leaving geoscape mode")

func _on_mission_completed(data: Dictionary):
    var mission = get_mission_by_id(data.mission_id)
    if mission:
        print("MissionFactory: Mission completed: ", mission.name)
        # Award rewards
        GameState.add_funding(mission.funding_reward)
        # TODO: Award experience to units

func _on_mission_failed(data: Dictionary):
    var mission = get_mission_by_id(data.mission_id)
    if mission:
        print("MissionFactory: Mission failed: ", mission.name)

# Debug function to spawn a test mission
func spawn_test_mission(current_day: int) -> Mission:
    var mission = generate_mission("terror_city", "test_province", current_day)
    if mission:
        active_missions.append(mission)
        mission.mark_detected(current_day)  # Make it immediately visible for testing
    return mission
