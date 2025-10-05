extends Node

# DetectionSystem - Handles radar coverage and mission detection
# Manages how missions become visible to the player

class_name DetectionSystem

var radar_stations: Array = []
var current_coverage: float = 0.0
var detection_range: float = 50.0  # degrees of longitude/latitude

func _ready():
    print("DetectionSystem: Initializing...")
    
    # Subscribe to relevant events
    EventBus.subscribe("game_mode_changed", Callable(self, "_on_game_mode_changed"))
    EventBus.subscribe("base_built", Callable(self, "_on_base_built"))
    EventBus.subscribe("radar_upgraded", Callable(self, "_on_radar_upgraded"))

func _on_game_mode_changed(data: Dictionary):
    if data.new_mode == GameState.GameMode.GEOSCAPE:
        print("DetectionSystem: Entering geoscape mode")
        update_coverage()
    elif data.old_mode == GameState.GameMode.GEOSCAPE:
        print("DetectionSystem: Leaving geoscape mode")

# Add a radar station at specific location
func add_radar_station(longitude: float, latitude: float, range_km: float = 1000.0):
    var station = {
        "longitude": longitude,
        "latitude": latitude,
        "range": range_km,
        "active": true
    }
    radar_stations.append(station)
    update_coverage()
    
    print("DetectionSystem: Added radar station at (", longitude, ", ", latitude, ") with range ", range_km, "km")

# Remove a radar station
func remove_radar_station(index: int):
    if index >= 0 and index < radar_stations.size():
        radar_stations.remove_at(index)
        update_coverage()
        print("DetectionSystem: Removed radar station at index ", index)

# Update overall radar coverage percentage
func update_coverage():
    # Simplified coverage calculation
    # In a real game, this would consider overlapping coverage areas
    var base_coverage = radar_stations.size() * 10.0  # 10% per station
    current_coverage = min(100.0, base_coverage)
    
    print("DetectionSystem: Updated coverage to ", current_coverage, "%")

# Check if a location is within radar coverage
func is_location_covered(longitude: float, latitude: float) -> bool:
    for station in radar_stations:
        if not station.active:
            continue
            
        var distance = calculate_distance(station.longitude, station.latitude, longitude, latitude)
        if distance <= detection_range:
            return true
    return false

# Calculate distance between two points (simplified)
func calculate_distance(lon1: float, lat1: float, lon2: float, lat2: float) -> float:
    # Simplified distance calculation using Euclidean distance
    # In a real game, you'd use proper geographic distance
    var delta_lon = lon2 - lon1
    var delta_lat = lat2 - lat1
    return sqrt(delta_lon * delta_lon + delta_lat * delta_lat)

# Get coverage at specific location (0.0 to 1.0)
func get_coverage_at_location(longitude: float, latitude: float) -> float:
    if radar_stations.is_empty():
        return 0.0
    
    var max_coverage = 0.0
    for station in radar_stations:
        if not station.active:
            continue
            
        var distance = calculate_distance(station.longitude, station.latitude, longitude, latitude)
        var coverage = 1.0 - (distance / detection_range)
        coverage = max(0.0, min(1.0, coverage))
        max_coverage = max(max_coverage, coverage)
    
    return max_coverage

# Perform daily detection scan
func perform_daily_scan(missions: Array, current_day: int):
    print("DetectionSystem: Performing daily detection scan...")
    
    for mission in missions:
        if not mission.detected and mission.is_active:
            var coverage = get_coverage_at_location(mission.longitude, mission.latitude)
            var detection_chance = mission.get_detection_chance(coverage * 100.0)
            
            var rng = RNGService.get_rng_handle("detection_" + mission.id + "_" + str(current_day))
            if rng.randf() < detection_chance:
                mission.mark_detected(current_day)
                print("DetectionSystem: Mission detected: ", mission.name)

# Get all radar stations
func get_radar_stations() -> Array:
    return radar_stations.duplicate()

# Get current overall coverage
func get_current_coverage() -> float:
    return current_coverage

# Set detection range (for testing or upgrades)
func set_detection_range(range_degrees: float):
    detection_range = range_degrees
    print("DetectionSystem: Detection range set to ", range_degrees, " degrees")

# Event handlers
func _on_base_built(data: Dictionary):
    # When a base is built, add a radar station there
    if data.has("longitude") and data.has("latitude"):
        add_radar_station(data.longitude, data.latitude)

func _on_radar_upgraded(data: Dictionary):
    # Handle radar upgrades
    if data.has("station_index") and data.has("new_range"):
        if data.station_index >= 0 and data.station_index < radar_stations.size():
            radar_stations[data.station_index].range = data.new_range
            update_coverage()
            print("DetectionSystem: Upgraded radar station ", data.station_index, " to range ", data.new_range)

# Initialize with default radar stations (for testing)
func initialize_default_stations():
    # Add some default radar stations
    add_radar_station(-74.0, 40.7)  # New York area
    add_radar_station(-118.2, 34.0)  # Los Angeles area
    add_radar_station(-87.6, 41.9)  # Chicago area
    
    print("DetectionSystem: Initialized with default radar stations")

# Get detection statistics
func get_detection_stats() -> Dictionary:
    return {
        "radar_stations": radar_stations.size(),
        "active_stations": radar_stations.filter(func(s): return s.active).size(),
        "current_coverage": current_coverage,
        "detection_range": detection_range
    }
