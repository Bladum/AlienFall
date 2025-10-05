extends Node

# BattleService - Service façade for battlescape generation and management
# Provides deterministic battle creation from mission seeds and terrain data

signal battle_created(battle_data: Dictionary)
signal battle_generation_failed(reason: String)

var active_battles: Dictionary = {}  # battle_id -> BattlescapeManager
var battle_templates: Dictionary = {}  # terrain_id -> template data

func _ready():
    print("BattleService: Initializing battle service")
    _load_battle_templates()

func _load_battle_templates():
    """Load battle templates from data registry"""
    print("BattleService: Loading battle templates...")

    # Load terrain templates
    var terrain_data = DataRegistry.get_all_data("terrain")
    if terrain_data:
        for terrain_id in terrain_data:
            var terrain = terrain_data[terrain_id]
            battle_templates[terrain_id] = terrain
            print("BattleService: Loaded terrain template: ", terrain.get("name", terrain_id))

    print("BattleService: Loaded ", battle_templates.size(), " terrain templates")

func create_battle(mission_seed: int, terrain_id: String, deployment: Dictionary) -> String:
    """
    Create a new battle deterministically from mission parameters

    Args:
        mission_seed: RNG seed for deterministic generation
        terrain_id: ID of terrain template to use
        deployment: Dictionary with player_units, enemy_units, objectives

    Returns:
        battle_id: Unique identifier for the created battle
    """
    print("BattleService: Creating battle with seed ", mission_seed, " terrain ", terrain_id)

    # Validate inputs
    if not battle_templates.has(terrain_id):
        emit_signal("battle_generation_failed", "Unknown terrain: " + terrain_id)
        return ""

    # Create deterministic RNG handle for this battle
    var rng_handle = RNGService.create_handle("battle_" + str(mission_seed))
    rng_handle.seed = mission_seed

    # Generate battle data
    var battle_data = _generate_battle_data(rng_handle, terrain_id, deployment)

    if not battle_data:
        emit_signal("battle_generation_failed", "Failed to generate battle data")
        return ""

    # Create battle ID
    var battle_id = "battle_" + str(mission_seed) + "_" + str(Time.get_ticks_msec())

    # Store battle data
    active_battles[battle_id] = battle_data

    # Emit success signal
    emit_signal("battle_created", battle_data)

    print("BattleService: Created battle ", battle_id)
    return battle_id

func _generate_battle_data(rng_handle, terrain_id: String, deployment: Dictionary) -> Dictionary:
    """Generate deterministic battle data"""
    var terrain_template = battle_templates[terrain_id]

    # Generate map dimensions
    var width = terrain_template.get("width", 20)
    var height = terrain_template.get("height", 20)
    var levels = terrain_template.get("levels", 1)

    # Create battle data structure
    var battle_data = {
        "battle_id": "",
        "terrain_id": terrain_id,
        "map_width": width,
        "map_height": height,
        "map_levels": levels,
        "player_units": deployment.get("player_units", []),
        "enemy_units": deployment.get("enemy_units", []),
        "objectives": deployment.get("objectives", []),
        "seed": rng_handle.seed,
        "topology_hash": "",  # Will be set after map generation
        "created_at": Time.get_datetime_string_from_system()
    }

    # Generate map topology deterministically
    var topology = _generate_topology(rng_handle, width, height, levels, terrain_template)
    battle_data["topology"] = topology

    # Calculate topology hash for verification
    battle_data["topology_hash"] = _calculate_topology_hash(topology)

    return battle_data

func _generate_topology(rng_handle, width: int, height: int, levels: int, terrain_template: Dictionary) -> Array:
    """Generate deterministic map topology"""
    var topology = []

    # Get terrain parameters
    var floor_chance = terrain_template.get("floor_chance", 0.7)
    var wall_chance = terrain_template.get("wall_chance", 0.2)
    var feature_chance = terrain_template.get("feature_chance", 0.1)

    for level in range(levels):
        var level_topology = []
        for y in range(height):
            var row = []
            for x in range(width):
                var tile_type = "floor"  # Default

                var rand_val = rng_handle.random_float()
                if rand_val < wall_chance:
                    tile_type = "wall"
                elif rand_val < wall_chance + feature_chance:
                    tile_type = "feature"

                row.append({
                    "type": tile_type,
                    "x": x,
                    "y": y,
                    "level": level,
                    "walkable": tile_type != "wall"
                })
            level_topology.append(row)
        topology.append(level_topology)

    return topology

func _calculate_topology_hash(topology: Array) -> String:
    """Calculate a hash of the topology for verification"""
    var hash_string = ""
    for level in topology:
        for row in level:
            for tile in row:
                hash_string += tile.type + str(tile.x) + str(tile.y) + str(tile.level)

    return hash_string.md5_text()

func get_battle_data(battle_id: String) -> Dictionary:
    """Get battle data by ID"""
    return active_battles.get(battle_id, {})

func get_active_battles() -> Array:
    """Get list of active battle IDs"""
    return active_battles.keys()

func destroy_battle(battle_id: String) -> bool:
    """Clean up a battle"""
    if active_battles.has(battle_id):
        active_battles.erase(battle_id)
        print("BattleService: Destroyed battle ", battle_id)
        return true
    return false

# Smoke test function for deterministic generation
func smoke_test_deterministic_generation(seed: int, terrain_id: String) -> bool:
    """Test that same inputs produce same outputs"""
    print("BattleService: Running deterministic generation smoke test")

    # Create deployment data
    var deployment = {
        "player_units": [{"id": "test_unit_1", "type": "soldier"}],
        "enemy_units": [{"id": "test_enemy_1", "type": "sectoid"}],
        "objectives": ["eliminate_all_enemies"]
    }

    # Generate battle twice with same inputs
    var battle1_id = create_battle(seed, terrain_id, deployment)
    var battle1_data = get_battle_data(battle1_id)

    var battle2_id = create_battle(seed, terrain_id, deployment)
    var battle2_data = get_battle_data(battle2_id)

    # Compare topology hashes
    var hash1 = battle1_data.get("topology_hash", "")
    var hash2 = battle2_data.get("topology_hash", "")

    var is_deterministic = (hash1 == hash2 and hash1 != "")

    print("BattleService: Deterministic test result: ", is_deterministic)
    print("  Hash 1: ", hash1)
    print("  Hash 2: ", hash2)

    # Clean up
    destroy_battle(battle1_id)
    destroy_battle(battle2_id)

    return is_deterministic
