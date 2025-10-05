extends Node

# GeoscapeManager - Coordinates all geoscape subsystems
# Manages missions, detection, time, and other geoscape mechanics

class_name GeoscapeManager

@onready var mission_factory: MissionFactory
@onready var detection_system: DetectionSystem
@onready var time_service: TimeService

var current_day: int = 1
var radar_coverage: float = 30.0  # Starting radar coverage

func _ready():
    print("GeoscapeManager: Initializing...")
    
    # Initialize subsystems
    mission_factory = MissionFactory.new()
    add_child(mission_factory)
    
    detection_system = DetectionSystem.new()
    add_child(detection_system)
    
    # Initialize detection system with default stations
    detection_system.initialize_default_stations()
    
    # Set up time service events
    TimeService.schedule_daily_event(Callable(self, "_on_daily_tick"))
    TimeService.schedule_weekly_event(Callable(self, "_on_weekly_tick"))
    TimeService.schedule_monthly_event(Callable(self, "_on_monthly_tick"))
    
    # Subscribe to events
    EventBus.subscribe("game_mode_changed", Callable(self, "_on_game_mode_changed"))
    
    print("GeoscapeManager: Initialization complete")

func _on_game_mode_changed(data: Dictionary):
    if data.new_mode == GameState.GameMode.GEOSCAPE:
        print("GeoscapeManager: Entering geoscape mode")
        # Start time if it was paused
        if TimeService.time_paused:
            TimeService.set_paused(false)
    elif data.old_mode == GameState.GameMode.GEOSCAPE:
        print("GeoscapeManager: Leaving geoscape mode")
        # Pause time
        TimeService.set_paused(true)

# Daily tick - main geoscape update
func _on_daily_tick():
    current_day = TimeService.current_day
    print("GeoscapeManager: Daily tick - Day ", current_day)
    
    # Spawn new missions
    mission_factory.spawn_missions(current_day)
    
    # Update detection
    detection_system.perform_daily_scan(mission_factory.get_active_missions(), current_day)
    
    # Clean up old missions
    mission_factory.cleanup_missions(current_day)
    
    # Update radar coverage
    radar_coverage = detection_system.get_current_coverage()
    
    # Emit geoscape update event
    EventBus.publish("geoscape_updated", {
        "current_day": current_day,
        "active_missions": mission_factory.get_active_missions().size(),
        "detected_missions": mission_factory.get_detected_missions().size(),
        "radar_coverage": radar_coverage
    })

# Weekly tick
func _on_weekly_tick():
    print("GeoscapeManager: Weekly tick - Week ", TimeService.current_week)
    
    # Weekly events like alien activity increases, funding updates, etc.
    EventBus.publish("weekly_geoscape_update", {
        "week": TimeService.current_week
    })

# Monthly tick
func _on_monthly_tick():
    print("GeoscapeManager: Monthly tick - Month ", TimeService.current_month)
    
    # Monthly events like funding from countries, research progress, etc.
    EventBus.publish("monthly_geoscape_update", {
        "month": TimeService.current_month
    })

# Get current geoscape state
func get_geoscape_state() -> Dictionary:
    return {
        "current_day": current_day,
        "radar_coverage": radar_coverage,
        "active_missions": mission_factory.get_active_missions(),
        "detected_missions": mission_factory.get_detected_missions(),
        "mission_stats": mission_factory.get_mission_stats(),
        "detection_stats": detection_system.get_detection_stats(),
        "time_stats": TimeService.get_time_stats()
    }

# Advance time manually (for testing)
func advance_time(days: int = 1):
    for i in range(days):
        TimeService.advance_day()

# Spawn a test mission (for testing)
func spawn_test_mission():
    var mission = mission_factory.spawn_test_mission(current_day)
    return mission

# Get mission by ID
func get_mission_by_id(mission_id: String):
    return mission_factory.get_mission_by_id(mission_id)

# Get all active missions
func get_active_missions() -> Array:
    return mission_factory.get_active_missions()

# Get detected missions
func get_detected_missions() -> Array:
    return mission_factory.get_detected_missions()

# Get radar coverage at location
func get_coverage_at_location(longitude: float, latitude: float) -> float:
    return detection_system.get_coverage_at_location(longitude, latitude)

# Add radar station
func add_radar_station(longitude: float, latitude: float):
    detection_system.add_radar_station(longitude, latitude)

# Get time control state
func get_time_control_state() -> Dictionary:
    return {
        "paused": TimeService.time_paused,
        "speed": TimeService.time_speed,
        "current_day": TimeService.current_day,
        "date_string": TimeService.get_date_string()
    }

# Set time paused
func set_time_paused(paused: bool):
    TimeService.set_paused(paused)

# Set time speed
func set_time_speed(speed: int):
    TimeService.set_speed(speed)
