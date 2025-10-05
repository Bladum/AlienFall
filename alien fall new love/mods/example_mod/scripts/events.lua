-- Example Mod Event Handlers
-- This script contains event handling functions for the example mod

local example_mod_events = {}

-- Handle mod initialization event
function example_mod_events.on_mod_initialized(event_data)
    print("Example Mod: Mod initialized event received")
    -- Handle mod initialization
end

-- Handle content loading event
function example_mod_events.on_mod_content_loaded(event_data)
    print("Example Mod: Content loaded event received")
    -- Handle content loading completion
end

-- Handle custom weapon unlocked event
function example_mod_events.on_custom_weapon_unlocked(event_data)
    print("Example Mod: Custom weapon unlocked: " .. tostring(event_data.weapon_id))
    -- Handle weapon unlock logic
end

-- Handle mod feature activation
function example_mod_events.on_mod_feature_activated(event_data)
    print("Example Mod: Mod feature activated: " .. tostring(event_data.feature_id))
    -- Handle feature activation
end

-- Handle new campaign start
function example_mod_events.on_new_campaign_started(event_data)
    print("Example Mod: New campaign started")
    -- Reset mod-specific campaign data
end

-- Handle difficulty changes
function example_mod_events.on_difficulty_changed(event_data)
    print("Example Mod: Difficulty changed to: " .. tostring(event_data.new_difficulty))
    -- Adjust mod balance based on difficulty
end

-- Handle mod unit spawning
function example_mod_events.on_mod_unit_spawned(event_data)
    print("Example Mod: Mod unit spawned: " .. tostring(event_data.unit_id))
    -- Handle custom unit spawning logic
end

-- Handle custom ability usage
function example_mod_events.on_custom_ability_used(event_data)
    print("Example Mod: Custom ability used: " .. tostring(event_data.ability_id))
    -- Handle custom ability effects
end

-- Handle mod mission spawning
function example_mod_events.on_mod_mission_spawned(event_data)
    print("Example Mod: Mod mission spawned: " .. tostring(event_data.mission_id))
    -- Handle custom mission logic
end

-- Handle province control changes
function example_mod_events.on_province_control_changed(event_data)
    print("Example Mod: Province control changed: " .. tostring(event_data.province_id))
    -- Handle province control changes
end

return example_mod_events