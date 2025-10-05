# Save System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Save System specification defines save/load functionality for Alien Fall including serialization format, save slot management, complete game state preservation (including RNG seeds), and data integrity validation to support campaign continuity, backward compatibility, and save corruption prevention across version updates while maintaining deterministic replay capability.

## Mechanics

### Save File Structure

**Save Directory:**
```
saves/
├── campaign_001/
│   ├── metadata.toml
│   ├── geoscape.toml
│   ├── bases.toml
│   ├── units.toml
│   ├── research.toml
│   ├── manufacturing.toml
│   ├── economy.toml
│   ├── missions.toml
│   └── rng_state.toml
├── campaign_002/
│   └── ...
└── autosave/
    └── ...
```

### Metadata File

**metadata.toml:**
```toml
[campaign]
name = "Earth Defense Initiative"
difficulty = "veteran"
ironman = false
version = "0.1.0"
created_date = "2025-09-30T14:30:00Z"
last_saved = "2025-09-30T16:45:23Z"
playtime_seconds = 7523

[game_state]
current_date = "1999-03-15T08:30:00Z"
campaign_month = 3
turn_number = 1085
active_mission_id = "mission_042"

[statistics]
missions_completed = 12
missions_failed = 2
aliens_killed = 87
soldiers_lost = 5
ufos_shot_down = 8
bases_built = 2

[checksum]
data_hash = "a3f5c89d2e1b..."
version_hash = "1.0.3"
```

### Geoscape State

**geoscape.toml:**
```toml
[world]
seed = "12345:world"
current_time_tick = 1085  # 5-minute ticks
time_speed = 5  # Current time multiplier

[[provinces]]
id = "province_001"
name = "North America East"
control_level = 65  # Player control %
infiltration_level = 20  # Alien infiltration %
panic_level = 35
last_mission_date = "1999-03-10T12:00:00Z"

[[ufos]]
id = "ufo_017"
type = "scout"
province_id = "province_003"
position = [145.5, 78.3]
altitude = 5000
speed = 50
mission = "abduction"
detected = true
tracked_by = ["radar_001", "radar_005"]

[[alien_bases]]
id = "alien_base_001"
type = "supply_base"
province_id = "province_007"
position = [220.1, 134.8]
discovered = false
force_size = 25
```

### Base State

**bases.toml:**
```toml
[[bases]]
id = "base_001"
name = "X-COM HQ"
province_id = "province_001"
position = [100.0, 50.0]
construction_date = "1999-01-01T00:00:00Z"

[bases.resources]
money = 500000
elerium = 25
alloys = 150
personnel = 45

[[bases.facilities]]
type = "hangar"
position = [2, 3]  # Grid position
construction_complete = true
powered = true
status = "operational"

[[bases.crafts]]
id = "craft_001"
name = "Skyranger-1"
type = "skyranger"
status = "ready"  # ready, deployed, maintenance, repair
hangar_id = "facility_hangar_001"
fuel = 100
damage = 0

[bases.crafts.loadout]
weapon_1 = "stingray"
weapon_1_ammo = 6
squad_assigned = ["soldier_001", "soldier_002", "soldier_003", ...]

[[bases.soldiers]]
id = "soldier_001"
name = "John Smith"
rank = "sergeant"
missions_completed = 8
kills = 15
assigned_craft = "craft_001"

[bases.soldiers.stats]
health = 45
energy = 65
accuracy = 72
reactions = 68
```

### Research State

**research.toml:**
```toml
[research]
current_project = "laser_weapons"
progress_hours = 350
total_required_hours = 500
scientists_assigned = 10

[[completed_projects]]
id = "alien_alloys"
completion_date = "1999-02-15T10:00:00Z"
unlocked_items = ["alloy_vest", "alloy_cannon"]

[[available_projects]]
id = "plasma_rifle"
required_items = ["plasma_clip"]
estimated_hours = 800
prerequisites_met = false
```

### Manufacturing State

**manufacturing.toml:**
```toml
[[production_queue]]
id = "production_001"
item_type = "laser_rifle"
quantity_ordered = 5
quantity_completed = 2
progress_hours = 120
total_hours_per_unit = 100
engineers_assigned = 8
materials_consumed = true

[production_queue.materials]
alloys = 10
elerium = 2
```

### Mission State

**missions.toml:**
```toml
[[active_missions]]
id = "mission_042"
type = "ufo_crash"
province_id = "province_003"
location = [155.2, 82.1]
expires_at = "1999-03-15T18:00:00Z"
ufo_type = "scout"
alien_force = 8
mission_seed = "12345:world:mission:mission_042"

[[craft_in_transit]]
craft_id = "craft_001"
destination = [155.2, 82.1]
eta_minutes = 45
fuel_consumed = 15

[[battlescape_state]]
mission_id = "mission_042"
turn_number = 3
current_phase = "player_turn"
map_seed = "12345:world:mission:mission_042:map"

[[battlescape_state.units]]
id = "soldier_001"
position = [12, 8, 0]  # x, y, z
facing = 90  # degrees
ap_remaining = 2
energy = 48

[battlescape_state.units.status_effects]
overwatch = {active = true, ap_reserved = 2}

[[battlescape_state.items]]
id = "item_rifle_001"
type = "laser_rifle"
position = [15, 10, 0]
ammo_remaining = 24
```

### RNG State

**rng_state.toml:**
```toml
[campaign_rng]
seed = "12345"
state = "a3f5c89d2e1b4f6a..."  # Serialized RNG state

[world_rng]
seed = "12345:world"
state = "f2d8b1a5c3e7d9f1..."

[mission_rng]
seed = "12345:world:mission:mission_042"
state = "9c4e2f1d8b7a6e5d..."

[combat_rng]
seed = "12345:world:mission:mission_042:combat"
state = "7e6d5c4b3a2f1e9d..."
```

---

## Serialization System

### Lua to TOML Conversion

**Serialization:**
```lua
local toml = require("lib.toml")

function serialize_game_state(game_state, save_path)
    -- Create save directory
    love.filesystem.createDirectory(save_path)
    
    -- Serialize each subsystem
    local serializers = {
        metadata = serialize_metadata,
        geoscape = serialize_geoscape,
        bases = serialize_bases,
        units = serialize_units,
        research = serialize_research,
        manufacturing = serialize_manufacturing,
        economy = serialize_economy,
        missions = serialize_missions,
        rng_state = serialize_rng_state
    }
    
    for name, serializer in pairs(serializers) do
        local data = serializer(game_state)
        local toml_string = toml.encode(data)
        local file_path = save_path .. "/" .. name .. ".toml"
        
        local success, error_msg = love.filesystem.write(file_path, toml_string)
        if not success then
            log_error("Failed to save " .. name .. ": " .. error_msg)
            return false
        end
    end
    
    -- Calculate checksum
    local checksum = calculate_save_checksum(save_path)
    save_checksum(save_path, checksum)
    
    return true
end
```

**Deserialization:**
```lua
function deserialize_game_state(save_path)
    -- Verify checksum first
    if not verify_save_checksum(save_path) then
        log_error("Save file corrupted: checksum mismatch")
        return nil
    end
    
    local game_state = {}
    
    -- Deserialize each subsystem
    local deserializers = {
        metadata = deserialize_metadata,
        geoscape = deserialize_geoscape,
        bases = deserialize_bases,
        units = deserialize_units,
        research = deserialize_research,
        manufacturing = deserialize_manufacturing,
        economy = deserialize_economy,
        missions = deserialize_missions,
        rng_state = deserialize_rng_state
    }
    
    for name, deserializer in pairs(deserializers) do
        local file_path = save_path .. "/" .. name .. ".toml"
        local toml_string = love.filesystem.read(file_path)
        
        if not toml_string then
            log_error("Failed to read " .. name .. ".toml")
            return nil
        end
        
        local data = toml.decode(toml_string)
        deserializer(game_state, data)
    end
    
    return game_state
end
```

### Custom Serializers

**Example: Unit Serialization:**
```lua
function serialize_unit(unit)
    return {
        id = unit.id,
        name = unit.name,
        type = unit.type,
        rank = unit.rank,
        
        -- Stats
        stats = {
            health = unit.stats.health,
            energy = unit.stats.energy,
            accuracy = unit.stats.accuracy,
            -- ... all stats
        },
        
        -- Status effects
        status_effects = serialize_status_effects(unit.status_effects),
        
        -- Inventory
        inventory = serialize_inventory(unit.inventory),
        
        -- Position (if in battlescape)
        position = unit.position and {
            x = unit.position.x,
            y = unit.position.y,
            z = unit.position.z
        } or nil,
        
        -- Mission history
        missions_completed = unit.missions_completed,
        kills = unit.kills,
        experience = unit.experience
    }
end

function deserialize_unit(unit_data)
    local unit = Unit:new(unit_data.type)
    
    unit.id = unit_data.id
    unit.name = unit_data.name
    unit.rank = unit_data.rank
    
    -- Restore stats
    for stat_name, stat_value in pairs(unit_data.stats) do
        unit.stats[stat_name] = stat_value
    end
    
    -- Restore status effects
    unit.status_effects = deserialize_status_effects(unit_data.status_effects)
    
    -- Restore inventory
    unit.inventory = deserialize_inventory(unit_data.inventory)
    
    -- Restore position
    if unit_data.position then
        unit.position = Vector3:new(
            unit_data.position.x,
            unit_data.position.y,
            unit_data.position.z
        )
    end
    
    -- Restore history
    unit.missions_completed = unit_data.missions_completed
    unit.kills = unit_data.kills
    unit.experience = unit_data.experience
    
    return unit
end
```

---

## Save Slot Management

### Save Slot System

**Slot Management:**
```lua
save_system = {
    max_manual_saves = 10,
    max_autosaves = 3,
    max_quicksaves = 1
}

function get_save_slots()
    local saves_dir = "saves/"
    local items = love.filesystem.getDirectoryItems(saves_dir)
    local slots = {}
    
    for _, item in ipairs(items) do
        if love.filesystem.getInfo(saves_dir .. item, "directory") then
            local metadata = load_save_metadata(saves_dir .. item)
            if metadata then
                table.insert(slots, {
                    path = saves_dir .. item,
                    name = metadata.campaign.name,
                    date = metadata.campaign.last_saved,
                    playtime = metadata.campaign.playtime_seconds,
                    difficulty = metadata.campaign.difficulty,
                    is_ironman = metadata.campaign.ironman
                })
            end
        end
    end
    
    -- Sort by date (newest first)
    table.sort(slots, function(a, b)
        return a.date > b.date
    end)
    
    return slots
end
```

### Autosave System

**Autosave Triggers:**
```lua
autosave_config = {
    enabled = true,
    frequency_minutes = 10,  -- Every 10 real-time minutes
    max_autosaves = 3,       -- Keep last 3 autosaves
    
    triggers = {
        mission_start = true,
        mission_end = true,
        month_transition = true,
        research_complete = true,
        base_built = true
    }
}

function check_autosave_trigger(event_type)
    if not autosave_config.enabled then
        return false
    end
    
    if autosave_config.triggers[event_type] then
        perform_autosave(event_type)
        return true
    end
    
    return false
end

function perform_autosave(trigger_reason)
    local autosave_dir = "saves/autosave/"
    
    -- Rotate autosaves
    rotate_autosaves(autosave_dir, autosave_config.max_autosaves)
    
    -- Create new autosave
    local save_path = autosave_dir .. "autosave_" .. os.time()
    local success = serialize_game_state(game_state, save_path)
    
    if success then
        log_info("Autosave created: " .. trigger_reason)
    else
        log_error("Autosave failed: " .. trigger_reason)
    end
end
```

### Ironman Mode

**Ironman Save Restrictions:**
```lua
function save_game_ironman(game_state, save_path)
    -- In ironman mode, only one save slot
    local ironman_path = "saves/ironman_current"
    
    -- Delete existing ironman save
    if love.filesystem.getInfo(ironman_path, "directory") then
        delete_directory_recursive(ironman_path)
    end
    
    -- Save new state
    local success = serialize_game_state(game_state, ironman_path)
    
    if success then
        -- Mark as ironman
        local metadata_path = ironman_path .. "/metadata.toml"
        local metadata = toml.decode(love.filesystem.read(metadata_path))
        metadata.campaign.ironman = true
        love.filesystem.write(metadata_path, toml.encode(metadata))
    end
    
    return success
end

function load_game_ironman()
    local ironman_path = "saves/ironman_current"
    
    if not love.filesystem.getInfo(ironman_path, "directory") then
        return nil, "No ironman save found"
    end
    
    local game_state = deserialize_game_state(ironman_path)
    
    if game_state then
        -- Immediately save to prevent save scumming
        serialize_game_state(game_state, ironman_path)
    end
    
    return game_state
end
```

---

## Data Integrity

### Checksum Validation

**Checksum Calculation:**
```lua
function calculate_save_checksum(save_path)
    local files = {
        "metadata.toml",
        "geoscape.toml",
        "bases.toml",
        "units.toml",
        "research.toml",
        "manufacturing.toml",
        "economy.toml",
        "missions.toml",
        "rng_state.toml"
    }
    
    local combined_hash = ""
    
    for _, filename in ipairs(files) do
        local file_path = save_path .. "/" .. filename
        local content = love.filesystem.read(file_path)
        
        if content then
            local file_hash = calculate_sha256(content)
            combined_hash = combined_hash .. file_hash
        end
    end
    
    return calculate_sha256(combined_hash)
end

function verify_save_checksum(save_path)
    local checksum_file = save_path .. "/checksum.txt"
    local stored_checksum = love.filesystem.read(checksum_file)
    
    if not stored_checksum then
        log_warning("No checksum found for save: " .. save_path)
        return false
    end
    
    local calculated_checksum = calculate_save_checksum(save_path)
    
    if stored_checksum ~= calculated_checksum then
        log_error("Save file corrupted: checksum mismatch")
        log_error("Expected: " .. stored_checksum)
        log_error("Got: " .. calculated_checksum)
        return false
    end
    
    return true
end
```

### Version Compatibility

**Version Check:**
```lua
function check_save_compatibility(metadata)
    local save_version = parse_version(metadata.campaign.version)
    local current_version = parse_version(GAME_VERSION)
    
    -- Major version must match
    if save_version.major ~= current_version.major then
        return false, "Incompatible major version"
    end
    
    -- Minor version can differ (backward compatible)
    if save_version.minor > current_version.minor then
        return false, "Save from newer version"
    end
    
    -- Patch version doesn't matter
    return true
end

function parse_version(version_string)
    local major, minor, patch = version_string:match("(%d+)%.(%d+)%.(%d+)")
    return {
        major = tonumber(major),
        minor = tonumber(minor),
        patch = tonumber(patch)
    }
end
```

### Migration System

**Save Migration:**
```lua
migrations = {}

migrations["0.1.0_to_0.2.0"] = function(game_state)
    -- Example migration: Add new soldier stat
    for _, base in ipairs(game_state.bases) do
        for _, soldier in ipairs(base.soldiers) do
            if not soldier.stats.willpower then
                soldier.stats.willpower = 50  -- Default value
            end
        end
    end
    
    return game_state
end

function migrate_save(game_state, from_version, to_version)
    local migration_key = from_version .. "_to_" .. to_version
    local migration_func = migrations[migration_key]
    
    if migration_func then
        log_info("Migrating save from " .. from_version .. " to " .. to_version)
        game_state = migration_func(game_state)
    end
    
    return game_state
end
```

---

## RNG State Preservation

### RNG Serialization

**Save RNG State:**
```lua
function serialize_rng_state(game_state)
    local rng_data = {
        campaign_rng = {
            seed = game_state.rng.campaign.seed,
            state = serialize_rng_internal_state(game_state.rng.campaign)
        },
        world_rng = {
            seed = game_state.rng.world.seed,
            state = serialize_rng_internal_state(game_state.rng.world)
        },
        mission_rng = {},
        combat_rng = {}
    }
    
    -- Save mission-specific RNG states
    for mission_id, rng in pairs(game_state.rng.missions) do
        rng_data.mission_rng[mission_id] = {
            seed = rng.seed,
            state = serialize_rng_internal_state(rng)
        }
    end
    
    return rng_data
end

function serialize_rng_internal_state(rng)
    -- Love2D's RandomGenerator:getState() returns a string
    return rng:getState()
end
```

**Restore RNG State:**
```lua
function deserialize_rng_state(game_state, rng_data)
    game_state.rng = {}
    
    -- Restore campaign RNG
    game_state.rng.campaign = love.math.newRandomGenerator(rng_data.campaign_rng.seed)
    game_state.rng.campaign:setState(rng_data.campaign_rng.state)
    
    -- Restore world RNG
    game_state.rng.world = love.math.newRandomGenerator(rng_data.world_rng.seed)
    game_state.rng.world:setState(rng_data.world_rng.state)
    
    -- Restore mission RNG states
    game_state.rng.missions = {}
    for mission_id, rng_info in pairs(rng_data.mission_rng) do
        local rng = love.math.newRandomGenerator(rng_info.seed)
        rng:setState(rng_info.state)
        game_state.rng.missions[mission_id] = rng
    end
end
```

---

## Performance Optimization

### Lazy Loading

**Partial Save Loading:**
```lua
function load_save_metadata_only(save_path)
    local metadata_path = save_path .. "/metadata.toml"
    local metadata_string = love.filesystem.read(metadata_path)
    
    if not metadata_string then
        return nil
    end
    
    return toml.decode(metadata_string)
end

function load_save_progressive(save_path, callback)
    local files = {
        "metadata", "geoscape", "bases", "units",
        "research", "manufacturing", "economy", "missions", "rng_state"
    }
    
    local game_state = {}
    
    for i, name in ipairs(files) do
        local data = load_save_file(save_path, name)
        deserialize_subsystem(game_state, name, data)
        
        -- Progress callback
        if callback then
            callback(i, #files)
        end
    end
    
    return game_state
end
```

### Compression

**Save Compression:**
```lua
function compress_save(save_path)
    -- Use love.data.compress()
    local files = get_all_save_files(save_path)
    local archive_data = {}
    
    for _, filename in ipairs(files) do
        local content = love.filesystem.read(save_path .. "/" .. filename)
        if content then
            archive_data[filename] = content
        end
    end
    
    local serialized = serialize_table(archive_data)
    local compressed = love.data.compress("string", "gzip", serialized)
    
    local archive_path = save_path .. ".sav"
    love.filesystem.write(archive_path, compressed)
    
    return archive_path
end

function decompress_save(archive_path)
    local compressed = love.filesystem.read(archive_path)
    local decompressed = love.data.decompress("string", "gzip", compressed)
    local archive_data = deserialize_table(decompressed)
    
    return archive_data
end
```

---

## Cross-References

**Related Systems:**
- [Determinism](Determinism.md) - RNG seed architecture
- [Data Validation](Data_Validation.md) - TOML validation
- [File Structure](../README.md) - Project organization

**Implementation Files:**
- `src/systems/save_system.lua` - Save/load implementation
- `src/systems/serialization.lua` - Data serialization
- `lib/toml.lua` - TOML parser/encoder

---

## Version History

- **v1.0 (2025-09-30):** Initial save system specification
