-- ConsoleCommands - Game-specific console commands for debugging and development

local ConsoleCommands = {}

function ConsoleCommands.register(console, registry)
    -- Spawn unit command
    console:registerCommand("spawn_unit", "Spawn a unit at coordinates (spawn_unit <unit_id> <x> <y>)", function(args)
        if #args < 3 then
            console:print("Usage: spawn_unit <unit_id> <x> <y>")
            return
        end
        
        local unit_id = args[1]
        local x = tonumber(args[2])
        local y = tonumber(args[3])
        
        if not x or not y then
            console:print("Error: Invalid coordinates")
            return
        end
        
        console:print(string.format("Spawning unit '%s' at (%d, %d)", unit_id, x, y))
        -- TODO: Implement actual unit spawning through registry
        console:print("Note: Unit spawning not yet implemented")
    end)
    
    -- Give item command
    console:registerCommand("give_item", "Give an item to a unit (give_item <unit_id> <item_id>)", function(args)
        if #args < 2 then
            console:print("Usage: give_item <unit_id> <item_id>")
            return
        end
        
        local unit_id = args[1]
        local item_id = args[2]
        
        console:print(string.format("Giving item '%s' to unit '%s'", item_id, unit_id))
        -- TODO: Implement actual item giving through registry
        console:print("Note: Item giving not yet implemented")
    end)
    
    -- Set stat command
    console:registerCommand("set_stat", "Set a unit stat (set_stat <unit_id> <stat_name> <value>)", function(args)
        if #args < 3 then
            console:print("Usage: set_stat <unit_id> <stat_name> <value>")
            return
        end
        
        local unit_id = args[1]
        local stat_name = args[2]
        local value = tonumber(args[3])
        
        if not value then
            console:print("Error: Invalid value")
            return
        end
        
        console:print(string.format("Setting %s.%s = %d", unit_id, stat_name, value))
        -- TODO: Implement actual stat setting through registry
        console:print("Note: Stat setting not yet implemented")
    end)
    
    -- Teleport command
    console:registerCommand("teleport", "Teleport a unit (teleport <unit_id> <x> <y>)", function(args)
        if #args < 3 then
            console:print("Usage: teleport <unit_id> <x> <y>")
            return
        end
        
        local unit_id = args[1]
        local x = tonumber(args[2])
        local y = tonumber(args[3])
        
        if not x or not y then
            console:print("Error: Invalid coordinates")
            return
        end
        
        console:print(string.format("Teleporting unit '%s' to (%d, %d)", unit_id, x, y))
        -- TODO: Implement actual teleporting through registry
        console:print("Note: Teleport not yet implemented")
    end)
    
    -- List units command
    console:registerCommand("list_units", "List all units in the current scene", function(args)
        console:print("Listing units...")
        -- TODO: Get units from battlescape or other systems
        console:print("Note: Unit listing not yet implemented")
    end)
    
    -- List items command
    console:registerCommand("list_items", "List all available items", function(args)
        console:print("Listing items...")
        -- TODO: Get items from catalog
        console:print("Note: Item listing not yet implemented")
    end)
    
    -- Save game command
    console:registerCommand("save_game", "Save the game (save_game <slot_name>)", function(args)
        if #args < 1 then
            console:print("Usage: save_game <slot_name>")
            return
        end
        
        local slot_name = args[1]
        console:print("Saving game to slot: " .. slot_name)
        
        -- TODO: Trigger save through registry
        if registry then
            local save_service = registry:get("save")
            if save_service then
                console:print("Save service found - attempting save...")
                -- save_service:save(slot_name)
                console:print("Note: Save not yet implemented")
            else
                console:print("Error: Save service not found")
            end
        end
    end)
    
    -- Load game command
    console:registerCommand("load_game", "Load a saved game (load_game <slot_name>)", function(args)
        if #args < 1 then
            console:print("Usage: load_game <slot_name>")
            return
        end
        
        local slot_name = args[1]
        console:print("Loading game from slot: " .. slot_name)
        
        -- TODO: Trigger load through registry
        console:print("Note: Load not yet implemented")
    end)
    
    -- Time scale command
    console:registerCommand("timescale", "Set game time scale (timescale <multiplier>)", function(args)
        if #args < 1 then
            console:print("Usage: timescale <multiplier>")
            console:print("Current timescale: 1.0")
            return
        end
        
        local scale = tonumber(args[1])
        if not scale then
            console:print("Error: Invalid timescale value")
            return
        end
        
        console:print(string.format("Setting timescale to %.2fx", scale))
        -- TODO: Implement timescale through registry
        console:print("Note: Timescale not yet implemented")
    end)
    
    -- God mode command
    console:registerCommand("god", "Toggle god mode (invincibility)", function(args)
        console:print("Toggling god mode...")
        -- TODO: Implement god mode
        console:print("Note: God mode not yet implemented")
    end)
    
    -- Fog of war command
    console:registerCommand("fog", "Toggle fog of war", function(args)
        console:print("Toggling fog of war...")
        -- TODO: Implement fog of war toggle
        console:print("Note: Fog of war toggle not yet implemented")
    end)
    
    -- Complete mission command
    console:registerCommand("win", "Instantly win current mission", function(args)
        console:print("Completing mission...")
        -- TODO: Trigger mission completion
        console:print("Note: Mission completion not yet implemented")
    end)
    
    -- Add resources command
    console:registerCommand("add_resources", "Add resources (add_resources <resource_type> <amount>)", function(args)
        if #args < 2 then
            console:print("Usage: add_resources <resource_type> <amount>")
            console:print("Resource types: money, supplies, intel, elerium")
            return
        end
        
        local resource_type = args[1]
        local amount = tonumber(args[2])
        
        if not amount then
            console:print("Error: Invalid amount")
            return
        end
        
        console:print(string.format("Adding %d %s", amount, resource_type))
        -- TODO: Implement resource addition
        console:print("Note: Resource addition not yet implemented")
    end)
    
    -- Debug visualization commands
    console:registerCommand("debug_path", "Toggle pathfinding visualization", function(args)
        if _G.App and _G.App.debugDraw then
            local state = _G.App.debugDraw:togglePathfinding()
            console:print("Pathfinding visualization: " .. (state and "ON" or "OFF"))
        else
            console:print("Debug draw not available")
        end
    end)
    
    console:registerCommand("debug_los", "Toggle line of sight visualization", function(args)
        if _G.App and _G.App.debugDraw then
            local state = _G.App.debugDraw:toggleLOS()
            console:print("LOS visualization: " .. (state and "ON" or "OFF"))
        else
            console:print("Debug draw not available")
        end
    end)
    
    console:registerCommand("debug_detection", "Toggle detection range visualization", function(args)
        if _G.App and _G.App.debugDraw then
            local state = _G.App.debugDraw:toggleDetection()
            console:print("Detection visualization: " .. (state and "ON" or "OFF"))
        else
            console:print("Debug draw not available")
        end
    end)
    
    console:registerCommand("debug_collision", "Toggle collision box visualization", function(args)
        if _G.App and _G.App.debugDraw then
            local state = _G.App.debugDraw:toggleCollision()
            console:print("Collision visualization: " .. (state and "ON" or "OFF"))
        else
            console:print("Debug draw not available")
        end
    end)
    
    console:registerCommand("debug_ai", "Toggle AI state visualization", function(args)
        if _G.App and _G.App.debugDraw then
            local state = _G.App.debugDraw:toggleAI()
            console:print("AI state visualization: " .. (state and "ON" or "OFF"))
        else
            console:print("Debug draw not available")
        end
    end)
    
    -- Mod management commands
    console:registerCommand("list_mods", "List all active mods", function(args)
        if registry then
            local mod_loader = registry.modLoader
            if mod_loader then
                local mods = mod_loader:getActiveMods()
                console:print(string.format("Active Mods (%d):", #mods))
                for i, mod in ipairs(mods) do
                    local priority = mod.priority or 100
                    console:print(string.format("%d. [%d] %s (%s) v%s", 
                        i, priority, mod.name, mod.id, mod.version))
                end
            else
                console:print("Mod loader not available")
            end
        else
            console:print("Registry not available")
        end
    end)
    
    console:registerCommand("mod_info", "Show detailed info for a mod (mod_info <mod_id>)", function(args)
        if #args < 1 then
            console:print("Usage: mod_info <mod_id>")
            return
        end
        
        local mod_id = args[1]
        if registry then
            local mod_loader = registry.modLoader
            if mod_loader then
                local mods = mod_loader:getActiveMods()
                for _, mod in ipairs(mods) do
                    if mod.id == mod_id then
                        console:print("=== Mod Information ===")
                        console:print("ID: " .. mod.id)
                        console:print("Name: " .. mod.name)
                        console:print("Version: " .. mod.version)
                        console:print("Author: " .. (mod.author or "Unknown"))
                        console:print("Priority: " .. (mod.priority or 100))
                        console:print("Description: " .. (mod.description or ""))
                        
                        if mod.dependencies and #mod.dependencies > 0 then
                            console:print("Dependencies: " .. table.concat(mod.dependencies, ", "))
                        end
                        
                        return
                    end
                end
                console:print("Mod not found: " .. mod_id)
            else
                console:print("Mod loader not available")
            end
        else
            console:print("Registry not available")
        end
    end)
    
    console:registerCommand("validate_mod", "Validate a mod (validate_mod <mod_id>)", function(args)
        if #args < 1 then
            console:print("Usage: validate_mod <mod_id>")
            return
        end
        
        local DebugTools = require('mods.DebugTools')
        local tools = DebugTools:new()
        
        local mod_id = args[1]
        if registry and registry.modLoader then
            local mods = registry.modLoader:getActiveMods()
            for _, mod in ipairs(mods) do
                if mod.id == mod_id then
                    local report = tools:generateReport(mod)
                    for line in report:gmatch("[^\r\n]+") do
                        console:print(line)
                    end
                    return
                end
            end
            console:print("Mod not found: " .. mod_id)
        else
            console:print("Registry not available")
        end
    end)
    
    console:registerCommand("browse_mod", "Browse mod content (browse_mod <mod_id>)", function(args)
        if #args < 1 then
            console:print("Usage: browse_mod <mod_id>")
            return
        end
        
        local DebugTools = require('mods.DebugTools')
        local tools = DebugTools:new()
        
        local mod_id = args[1]
        if registry and registry.modLoader then
            local mods = registry.modLoader:getActiveMods()
            for _, mod in ipairs(mods) do
                if mod.id == mod_id then
                    local content = tools:browseContent(mod)
                    for line in content:gmatch("[^\r\n]+") do
                        console:print(line)
                    end
                    return
                end
            end
            console:print("Mod not found: " .. mod_id)
        else
            console:print("Registry not available")
        end
    end)
end

return ConsoleCommands
