extends Node

# GameState - Global game state management
# Manages current game session, player progress, and game settings

enum GameMode {
    NONE,
    MAIN_MENU,
    GEOSCAPE,
    BASESCAPE,
    BATTLESCAPE,
    INTERCEPTION,
    DEBRIEFING
}

var current_mode: GameMode = GameMode.NONE
var campaign_data: Dictionary = {}
var player_data: Dictionary = {}
var game_settings: Dictionary = {}

# Game session data
var is_game_active: bool = false
var campaign_name: String = ""
var save_slot: int = -1

func _ready():
    print("GameState: Initializing...")
    load_default_settings()

# Initialize a new campaign
func new_campaign(campaign_name: String, settings: Dictionary = {}) -> void:
    self.campaign_name = campaign_name
    campaign_data = {
        "name": campaign_name,
        "start_date": Time.get_datetime_dict_from_system(),
        "difficulty": settings.get("difficulty", "normal"),
        "mods": settings.get("mods", []),
        "stats": {
            "missions_completed": 0,
            "aliens_killed": 0,
            "bases_destroyed": 0,
            "funding": 1000000,
            "score": 0
        }
    }
    
    player_data = {
        "bases": [],
        "craft": [],
        "research": {},
        "inventory": {}
    }
    
    is_game_active = true
    current_mode = GameMode.GEOSCAPE
    
    print("GameState: New campaign started: ", campaign_name)

# Load an existing campaign
func load_campaign(save_data: Dictionary) -> bool:
    if not save_data.has("campaign_data") or not save_data.has("player_data"):
        print("GameState: Invalid save data")
        return false
    
    campaign_data = save_data.campaign_data
    player_data = save_data.player_data
    campaign_name = campaign_data.get("name", "Loaded Campaign")
    
    is_game_active = true
    current_mode = GameMode.GEOSCAPE
    
    print("GameState: Campaign loaded: ", campaign_name)
    return true

# End the current campaign
func end_campaign() -> void:
    campaign_data.clear()
    player_data.clear()
    is_game_active = false
    current_mode = GameMode.NONE
    campaign_name = ""
    
    print("GameState: Campaign ended")

# Change game mode
func set_game_mode(mode: GameMode) -> void:
    var old_mode = current_mode
    current_mode = mode
    
    print("GameState: Mode changed from ", GameMode.keys()[old_mode], " to ", GameMode.keys()[mode])
    
    # Emit signal for mode change
    EventBus.publish("game_mode_changed", {
        "old_mode": old_mode,
        "new_mode": mode
    })

# Get current game mode as string
func get_current_mode_string() -> String:
    return GameMode.keys()[current_mode]

# Check if game is in a specific mode
func is_in_mode(mode: GameMode) -> bool:
    return current_mode == mode

# Update campaign statistics
func update_stat(stat_name: String, value: int, additive: bool = true) -> void:
    if not campaign_data.has("stats"):
        campaign_data.stats = {}
    
    if additive:
        campaign_data.stats[stat_name] = campaign_data.stats.get(stat_name, 0) + value
    else:
        campaign_data.stats[stat_name] = value
    
    print("GameState: Updated stat ", stat_name, " to ", campaign_data.stats[stat_name])

# Get campaign statistic
func get_stat(stat_name: String) -> int:
    if campaign_data.has("stats"):
        return campaign_data.stats.get(stat_name, 0)
    return 0

# Add funding
func add_funding(amount: int) -> void:
    update_stat("funding", amount)

# Get current funding
func get_funding() -> int:
    return get_stat("funding")

# Modify funding (can be negative to subtract)
func modify_funding(amount: int) -> void:
    update_stat("funding", amount)

# Get completed research (delegate to ResearchManager)
func get_completed_research() -> Array:
    return ResearchManager.get_completed_research()

# Check if research is completed
func is_research_completed(research_id: String) -> bool:
    return ResearchManager.is_research_completed(research_id)

# Load default game settings
func load_default_settings() -> void:
    game_settings = {
        "audio": {
            "master_volume": 1.0,
            "music_volume": 0.7,
            "sfx_volume": 0.8
        },
        "video": {
            "resolution": "1280x720",
            "fullscreen": false,
            "vsync": true
        },
        "gameplay": {
            "autosave": true,
            "tooltips": true,
            "confirm_actions": true
        },
        "controls": {
            "mouse_sensitivity": 1.0
        }
    }
    
    print("GameState: Default settings loaded")

# Save current settings
func save_settings() -> void:
    # In a real implementation, this would save to a config file
    print("GameState: Settings saved")

# Get full game state for saving
func get_save_data() -> Dictionary:
    return {
        "campaign_data": campaign_data,
        "player_data": player_data,
        "game_settings": game_settings,
        "current_mode": current_mode,
        "is_game_active": is_game_active,
        "save_version": "1.0",
        "timestamp": Time.get_datetime_dict_from_system()
    }

# Validate save data compatibility
func validate_save_data(save_data: Dictionary) -> bool:
    if not save_data.has("save_version"):
        return false
    
    # Add version compatibility checks here
    return true
