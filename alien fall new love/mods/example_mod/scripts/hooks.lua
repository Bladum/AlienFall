-- Example Mod Hooks Script
-- This script contains hook implementations for the example mod

local example_mod_hooks = {}

-- Initialization hook - called when mod loads
function example_mod_hooks.init()
    print("Example Mod: Initialization hook called")
    -- Initialize mod-specific data structures
    _G.example_mod_data = {
        initialized = true,
        version = "1.0.0",
        features = {}
    }
    return true
end

-- Pre-load hook - called before mod content loads
function example_mod_hooks.preload()
    print("Example Mod: Pre-load hook called")
    -- Validate dependencies, prepare for content loading
    return true
end

-- Post-load hook - called after mod content loads
function example_mod_hooks.postload()
    print("Example Mod: Post-load hook called")
    -- Register custom content, setup event handlers
    _G.example_mod_data.loaded = true
    return true
end

-- Game start hook - called when game begins
function example_mod_hooks.game_start()
    print("Example Mod: Game start hook called")
    -- Initialize game-specific mod features
    _G.example_mod_data.game_active = true
    return true
end

-- Game shutdown hook - called when game ends
function example_mod_hooks.game_shutdown()
    print("Example Mod: Game shutdown hook called")
    -- Cleanup mod resources
    _G.example_mod_data.game_active = false
    return true
end

-- Custom mod-specific hooks
function example_mod_hooks.custom_mod_setup()
    print("Example Mod: Custom setup hook called")
    -- Custom initialization logic
    return true
end

function example_mod_hooks.validate_mod_content()
    print("Example Mod: Content validation hook called")
    -- Validate that all mod content was loaded correctly
    return true
end

function example_mod_hooks.handle_mod_save_load()
    print("Example Mod: Save/load hook called")
    -- Handle custom save/load logic
    return true
end

function example_mod_hooks.setup_mod_ui()
    print("Example Mod: UI setup hook called")
    -- Setup custom UI elements
    return true
end

return example_mod_hooks