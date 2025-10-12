--- Mod Manager System
--- Handles loading, managing, and providing access to mods.
--- All game content is loaded through the mod system.
---
--- This module scans the mods/ directory for mod.toml files, loads mods
--- in priority order, and provides access to mod content (rules, maps, assets).
--- All game data (terrain, units, weapons) must be loaded from mods.
---
--- Example usage:
---   local ModManager = require("systems.mod_manager")
---   ModManager.init()
---   local path = ModManager.getContentPath("rules", "battle/terrain.toml")
---
--- Mod Structure:
---   mods/modname/mod.toml          -- Mod metadata
---   mods/modname/content/rules/    -- Game rules (TOML)
---   mods/modname/content/maps/     -- Map data
---   mods/modname/content/assets/   -- Images, sounds

local TOML = require("libs.toml")

--- @class ModManager
--- @field mods table All loaded mods (modId -> mod)
--- @field activeMod table|nil Currently active mod
--- @field modOrder table Load order of mods (array)
--- @field contentCache table Cached content from mods
local ModManager = {
    mods = {},              -- All loaded mods
    activeMod = nil,        -- Currently active mod
    modOrder = {},          -- Load order of mods
    contentCache = {}       -- Cached content from mods
}

--- Scan mods directory and discover all available mods.
---
--- Searches mods/ folder for directories containing mod.toml files.
--- Parses TOML to extract mod metadata (name, version, etc.).
--- Returns array sorted by load_order setting (lower values first).
--- Prints detailed debug messages during scanning.
---
--- @return table Array of mod config tables
function ModManager.scanMods()
    local modsPath = "mods"
    local modList = {}
    
    -- Get all folders in mods directory
    local items = love.filesystem.getDirectoryItems(modsPath)
    print(string.format("[ModManager] Scanning %d items in mods directory", #items))
    
    for _, folder in ipairs(items) do
        local modPath = modsPath .. "/" .. folder
        local info = love.filesystem.getInfo(modPath)
        
        if info and info.type == "directory" then
            print(string.format("[ModManager] Checking directory: %s", folder))
            -- Check for mod.toml
            local configPath = modPath .. "/mod.toml"
            print(string.format("[ModManager] Looking for: %s", configPath))
            local configInfo = love.filesystem.getInfo(configPath)
            if configInfo then
                print(string.format("[ModManager] Found mod.toml in %s", folder))
                local success, modConfig = pcall(TOML.load, configPath)
                print(string.format("[ModManager] TOML load result: success=%s", tostring(success)))
                if success and modConfig then
                    print(string.format("[ModManager] TOML loaded successfully"))
                    if modConfig.mod then
                        print(string.format("[ModManager] mod section found"))
                        modConfig.mod.path = modPath
                        modConfig.mod.folder = folder
                        table.insert(modList, modConfig)
                        print(string.format("[ModManager] Found mod: %s (v%s)", 
                            modConfig.mod.name, modConfig.mod.version))
                    else
                        print(string.format("[ModManager] WARNING: No [mod] section in mod.toml"))
                    end
                else
                    print(string.format("[ModManager] ERROR: Failed to parse TOML in %s: %s", folder, tostring(modConfig)))
                end
            else
                print(string.format("[ModManager] No mod.toml in %s (configInfo=%s)", folder, tostring(configInfo)))
            end
        else
            print(string.format("[ModManager] %s is not a directory (info=%s)", folder, tostring(info)))
        end
    end
    
    -- Sort by load_order
    table.sort(modList, function(a, b)
        local orderA = (a.settings and a.settings.load_order) or 100
        local orderB = (b.settings and b.settings.load_order) or 100
        return orderA < orderB
    end)
    
    print(string.format("[ModManager] Discovered %d mods", #modList))
    return modList
end

--- Load all discovered mods.
---
--- Calls scanMods() then registers each mod.
--- Should be called during game initialization.
---
--- @return nil
function ModManager.loadMods()
    local modList = ModManager.scanMods()
    
    for _, modConfig in ipairs(modList) do
        local enabled = modConfig.settings and modConfig.settings.enabled
        if enabled == nil or enabled == true then
            ModManager.registerMod(modConfig)
        end
    end
    
    print(string.format("[ModManager] Loaded %d mods", #ModManager.modOrder))
end

--[[
    Register a mod in the system
]]
function ModManager.registerMod(modConfig)
    local modId = modConfig.mod.id
    ModManager.mods[modId] = modConfig
    table.insert(ModManager.modOrder, modId)
    
    print(string.format("[ModManager] Registered mod: %s (%s)", 
        modConfig.mod.name, modId))
end

--[[
    Set the active mod (primary content source)
]]
function ModManager.setActiveMod(modId)
    if not ModManager.mods[modId] then
        print(string.format("[ModManager] ERROR: Mod '%s' not found", modId))
        return false
    end
    
    ModManager.activeMod = modId
    print(string.format("[ModManager] Active mod set to: %s", 
        ModManager.mods[modId].mod.name))
    return true
end

--[[
    Get the active mod configuration
]]
function ModManager.getActiveMod()
    if not ModManager.activeMod then
        return nil
    end
    return ModManager.mods[ModManager.activeMod]
end

--[[
    Get path to content in active mod
    type: "assets", "rules", "mapblocks", etc.
    subpath: optional subdirectory/file within that content type
]]
function ModManager.getContentPath(contentType, subpath)
    local mod = ModManager.getActiveMod()
    if not mod then
        print("[ModManager] ERROR: No active mod set")
        return nil
    end
    
    local basePath = mod.mod.path
    local contentPath = mod.paths[contentType]
    
    if not contentPath then
        print(string.format("[ModManager] ERROR: Content type '%s' not found in mod", contentType))
        return nil
    end
    
    local fullPath = basePath .. "/" .. contentPath
    if subpath then
        fullPath = fullPath .. "/" .. subpath
    end
    
    return fullPath
end

--[[
    Get all content of a specific type from active mod
    contentType: "terrain_types", "weapons", "armours", etc.
]]
function ModManager.getContent(contentType)
    local mod = ModManager.getActiveMod()
    if not mod then
        print("[ModManager] ERROR: No active mod set")
        return nil
    end
    
    -- Check if mod provides this content
    if not mod.content[contentType] then
        print(string.format("[ModManager] Mod does not provide '%s' content", contentType))
        return nil
    end
    
    return mod
end

--[[
    Initialize mod system and load all mods
]]
function ModManager.init()
    print("[ModManager] Initializing mod system...")
    ModManager.loadMods()
    
    -- Try to load 'new' (xcom_simple) mod as default
    local defaultModLoaded = false
    if ModManager.isModLoaded("xcom_simple") then
        ModManager.setActiveMod("xcom_simple")
        defaultModLoaded = true
        print("[ModManager] Default mod 'xcom_simple' loaded successfully")
    elseif ModManager.isModLoaded("new") then
        ModManager.setActiveMod("new")
        defaultModLoaded = true
        print("[ModManager] Default mod 'new' loaded successfully")
    end
    
    -- Fallback to first available mod if default not found
    if not defaultModLoaded and #ModManager.modOrder > 0 then
        ModManager.setActiveMod(ModManager.modOrder[1])
        print(string.format("[ModManager] WARNING: Default mod not found, using '%s'", ModManager.modOrder[1]))
    elseif not defaultModLoaded then
        print("[ModManager] ERROR: No mods found!")
        error("[ModManager] Cannot start game without a mod. Please ensure mods/new/ exists with mod.toml")
    end
    
    print("[ModManager] Mod system initialized")
end

--[[
    Get list of all loaded mods
]]
function ModManager.getLoadedMods()
    local modList = {}
    for _, modId in ipairs(ModManager.modOrder) do
        table.insert(modList, ModManager.mods[modId])
    end
    return modList
end

--[[
    Check if a specific mod is loaded
]]
function ModManager.isModLoaded(modId)
    return ModManager.mods[modId] ~= nil
end

--[[
    Get terrain types from active mod
    Returns: table of terrain type definitions
]]
function ModManager.getTerrainTypes()
    local mod = ModManager.getActiveMod()
    if not mod then
        print("[ModManager] ERROR: No active mod set")
        return {}
    end
    
    -- Try to load from DataLoader first (TOML-based)
    local DataLoader = require("systems.data_loader")
    if DataLoader and DataLoader.terrainTypes then
        return DataLoader.terrainTypes
    end
    
    return {}
end

--[[
    Get mapblocks from active mod
    Returns: table of mapblock definitions
]]
function ModManager.getMapblocks()
    local mod = ModManager.getActiveMod()
    if not mod then
        print("[ModManager] ERROR: No active mod set")
        return {}
    end
    
    local mapblocksPath = ModManager.getContentPath("mapblocks")
    if not mapblocksPath then
        return {}
    end
    
    -- Load all mapblock files from directory
    local mapblocks = {}
    local items = love.filesystem.getDirectoryItems(mapblocksPath)
    for _, filename in ipairs(items) do
        if filename:match("%.toml$") then
            local filepath = mapblocksPath .. "/" .. filename
            local TOML = require("libs.toml")
            local success, mapblock = pcall(TOML.load, filepath)
            if success and mapblock then
                mapblock.filename = filename
                table.insert(mapblocks, mapblock)
            end
        end
    end
    
    return mapblocks
end

--[[
    Get current active mod data
    Returns: mod configuration table
]]
function ModManager.getCurrentMod()
    return ModManager.getActiveMod()
end

--[[
    Get mod info summary for display
    Returns: string with mod info
]]
function ModManager.getModInfo()
    local mod = ModManager.getActiveMod()
    if not mod then
        return "No active mod"
    end
    
    return string.format("%s v%s by %s", 
        mod.mod.name, 
        mod.mod.version, 
        mod.mod.author or "Unknown")
end

return ModManager
