extends Node

# DataRegistry - Central repository for all game data
# Loads and caches game data from JSON/YAML files

var _data_cache: Dictionary = {}  # type -> Dictionary[id -> data]
var _loaded_files: Array = []

func _ready():
    print("DataRegistry: Initializing...")
    load_core_data()

# Load all core game data
func load_core_data() -> void:
    print("DataRegistry: Loading core data...")
    
    # Load units
    load_data_directory("units", "res://resources/data/units/")
    
    # Load items
    load_data_directory("items", "res://resources/data/items/")
    
    # Load facilities
    load_data_directory("facilities", "res://resources/data/facilities/")
    
    # Load terrains
    load_data_directory("terrains", "res://resources/data/terrains/")
    
    # Load missions
    load_data_directory("missions", "res://resources/data/missions/")
    
    # Add fallback sample data if directories don't exist
    add_sample_data()
    
    print("DataRegistry: Core data loaded. Total files: ", _loaded_files.size())

# Add sample data for testing when data files don't exist
func add_sample_data() -> void:
    print("DataRegistry: Adding sample data...")
    
    # Sample mission data
    if not _data_cache.has("missions") or _data_cache["missions"].is_empty():
        _data_cache["missions"] = {
            "ufo_scout": {
                "id": "ufo_scout",
                "name": "UFO Scout",
                "type": "reconnaissance",
                "difficulty": 1,
                "description": "Small scout UFO performing reconnaissance",
                "duration": 48,
                "reward_credits": 1000,
                "reward_xp": 50
            },
            "ufo_fighter": {
                "id": "ufo_fighter",
                "name": "UFO Fighter",
                "type": "combat",
                "difficulty": 2,
                "description": "Combat-capable fighter UFO",
                "duration": 36,
                "reward_credits": 2000,
                "reward_xp": 100
            },
            "terror_site": {
                "id": "terror_site",
                "name": "Terror Site",
                "type": "emergency",
                "difficulty": 3,
                "description": "Aliens attacking civilian location",
                "duration": 12,
                "reward_credits": 3000,
                "reward_xp": 150
            }
        }
        print("DataRegistry: Added sample mission data")
    
    # Sample unit data
    if not _data_cache.has("units") or _data_cache["units"].is_empty():
        _data_cache["units"] = {
            "sectoid": {
                "id": "sectoid",
                "name": "Sectoid",
                "type": "alien",
                "health": 80,
                "accuracy": 60,
                "description": "Basic alien soldier"
            }
        }
        print("DataRegistry: Added sample unit data")

# Load all JSON files from a directory
func load_data_directory(data_type: String, directory_path: String) -> void:
    var dir = DirAccess.open(directory_path)
    if not dir:
        print("DataRegistry: Could not open directory: ", directory_path)
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".json"):
            var file_path = directory_path + file_name
            load_data_file(data_type, file_path)
        file_name = dir.get_next()

# Load a single data file
func load_data_file(data_type: String, file_path: String) -> void:
    if not FileAccess.file_exists(file_path):
        print("DataRegistry: File not found: ", file_path)
        return
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        print("DataRegistry: Could not open file: ", file_path)
        return
    
    var json_text = file.get_as_text()
    var json = JSON.new()
    var error = json.parse(json_text)
    
    if error != OK:
        print("DataRegistry: JSON parse error in ", file_path, ": ", json.get_error_message())
        return
    
    var data = json.get_data()
    
    if not _data_cache.has(data_type):
        _data_cache[data_type] = {}
    
    # Handle both single object and array of objects
    if data is Dictionary and data.has("id"):
        # Single object
        _data_cache[data_type][data.id] = data
        print("DataRegistry: Loaded ", data_type, " '", data.id, "' from ", file_path)
    elif data is Array:
        # Array of objects
        for item in data:
            if item is Dictionary and item.has("id"):
                _data_cache[data_type][item.id] = item
                print("DataRegistry: Loaded ", data_type, " '", item.id, "' from ", file_path)
    
    _loaded_files.append(file_path)

# Get data by type and id
func get_data(data_type: String, id: String) -> Dictionary:
    if _data_cache.has(data_type) and _data_cache[data_type].has(id):
        return _data_cache[data_type][id].duplicate(true)  # Return a copy
    return {}

# Get all data of a specific type
func get_all_data(data_type: String) -> Dictionary:
    if _data_cache.has(data_type):
        return _data_cache[data_type].duplicate(true)  # Return a copy
    return {}

# Get all IDs for a data type
func get_ids(data_type: String) -> Array:
    if _data_cache.has(data_type):
        return _data_cache[data_type].keys()
    return []

# Check if data exists
func has_data(data_type: String, id: String) -> bool:
    return _data_cache.has(data_type) and _data_cache[data_type].has(id)

# Get data with filters (simple key-value matching)
func get_filtered_data(data_type: String, filters: Dictionary) -> Array:
    var results = []
    
    if not _data_cache.has(data_type):
        return results
    
    for id in _data_cache[data_type]:
        var data = _data_cache[data_type][id]
        var matches = true
        
        for filter_key in filters:
            if not data.has(filter_key) or data[filter_key] != filters[filter_key]:
                matches = false
                break
        
        if matches:
            results.append(data.duplicate(true))
    
    return results

# Get data types that are loaded
func get_data_types() -> Array:
    return _data_cache.keys()

# Get statistics about loaded data
func get_stats() -> Dictionary:
    var stats = {
        "total_files": _loaded_files.size(),
        "data_types": {}
    }
    
    for data_type in _data_cache:
        stats.data_types[data_type] = _data_cache[data_type].size()
    
    return stats

# Clear all cached data
func clear_cache() -> void:
    _data_cache.clear()
    _loaded_files.clear()
    print("DataRegistry: Cache cleared")

# Reload all data
func reload_data() -> void:
    clear_cache()
    load_core_data()
