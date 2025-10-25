---Mod Manager System
---
---Manages mod loading, content resolution, and mod priority. All game content
---(terrain, units, weapons, maps, assets) is loaded through the mod system.
---Scans mods/ directory, parses mod.toml metadata, and provides path resolution
---for mod content. The active mod determines which content is used.
---
---Mod Structure:
---  mods/modname/
---  ├── mod.toml                 -- Mod metadata (name, version, dependencies)
---  ├── content/
---  │   ├── rules/               -- Game rules (terrain.toml, weapons.toml, etc.)
---  │   ├── maps/                -- Map data (mapblocks, mapscripts)
---  │   ├── mapblocks/           -- MapBlock TOML files
---  │   ├── mapscripts/          -- MapScript TOML files
---  │   ├── assets/              -- Images, sounds, fonts
---  │   ├── missions/            -- Mission definitions
---  │   └── data/                -- Additional game data
---
---Key Exports:
---  - ModManager.init(): Scans and loads all mods
---  - ModManager.setActiveMod(modId): Sets which mod to use
---  - ModManager.getContentPath(contentType, ...): Resolves content path
---  - ModManager.getMods(): Returns all loaded mods
---  - ModManager.getActiveMod(): Returns active mod metadata
---
---Content Types:
---  - "rules": Game rules (terrain, weapons, units)
---  - "maps": Map data
---  - "mapblocks": MapBlock definitions
---  - "mapscripts": MapScript definitions
---  - "assets": Images, sounds, fonts
---  - "missions": Mission definitions
---  - "data": Additional game data
---
---Dependencies:
---  - utils.toml: TOML file parsing for mod.toml
---  - love.filesystem: File system access for mod scanning
---
---@module mods.mod_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ModManager = require("mods.mod_manager")
---  ModManager.init()  -- Scan and load all mods
---  ModManager.setActiveMod("core")  -- Use core mod
---  local terrainPath = ModManager.getContentPath("rules", "battle/terrain.toml")
---
---@see core.data_loader For loading mod content
---@see core.assets For loading mod assets
---@see battlescape.maps.mapblock_system For loading mapblocks

local TOML = require("utils.toml")

--- @class ModManager
--- @field mods table All loaded mods (modId -> mod)
--- @field activeMod table|nil Currently active mod
--- @field modOrder table Load order of mods (array)
local ModManager = {}
ModManager.mods = {}
ModManager.activeMod = nil
ModManager.modOrder = {}

--- Scan mods directory and discover all available mods.
---
--- Searches mods/ folder for directories containing mod.toml files.
--- Parses TOML to extract mod metadata (name, version, etc.).
--- Returns array sorted by load_order setting (lower values first).
--- Prints detailed debug messages during scanning.
---
--- @return table Array of mod config tables
function ModManager.scanMods()
    local modsPath = "mods"  -- Mods directory relative to game root
    local modList = {}
    
    -- Use io to list directories (since love.filesystem can't access outside game tree)
    local items = {}
    local sourceDir = love.filesystem.getSourceBaseDirectory()
    print("[ModManager] Source directory: " .. sourceDir)
    
    -- Try both possible locations for mods
    local modsFullPath1 = sourceDir .. "\\mods"  -- If running from Projects or engine
    local modsFullPath2 = sourceDir .. "\\..\\mods"  -- If running from somewhere else
    
    -- Try mods directory first
    local pfile = io.popen('dir "' .. modsFullPath1 .. '" /b /ad 2>nul')
    local modsFullPath = modsFullPath1
    if pfile then
        for dirname in pfile:lines() do
            table.insert(items, dirname)
        end
        pfile:close()
    end
    
    -- If that didn't work, try parent directory
    if #items == 0 then
        print("[ModManager] Mods not found in sourceDir, trying parent...")
        pfile = io.popen('dir "' .. modsFullPath2 .. '" /b /ad 2>nul')
        modsFullPath = modsFullPath2
        if pfile then
            for dirname in pfile:lines() do
                table.insert(items, dirname)
            end
            pfile:close()
        end
    end
    
    -- Fallback: manually check for known mod directories if dir didn't work
    if #items == 0 then
        print("[ModManager] WARNING: Dir command returned 0 items, trying fallback...")
        local knownMods = {"core", "xcom_simple", "new"}
        for _, modName in ipairs(knownMods) do
            local testPath = modsFullPath .. "\\" .. modName .. "\\mod.toml"
            print("[ModManager] Checking fallback path: " .. testPath)
            local testFile = io.open(testPath, "r")
            if testFile then
                table.insert(items, modName)
                testFile:close()
                print("[ModManager] Fallback found mod directory: " .. modName)
            end
        end
    end
    
    print("[ModManager] Full mods path: " .. modsFullPath)
    print(string.format("[ModManager] Scanning %d items in directory", #items))
    for i, item in ipairs(items) do
        print(string.format("[ModManager] Item %d: %s", i, item))
        
        -- Check if directory contains mod.toml (use same modsFullPath for consistency)
        local modDir = modsFullPath .. "\\" .. item
        local tomlPath = modDir .. "\\mod.toml"
        local file = io.open(tomlPath, "r")
        if file then
            print(string.format("[ModManager] Found mod.toml in %s", item))
            file:close()
            
            -- DON'T mount to love.filesystem - just store the physical path
            -- This works better on Windows where mounting can have issues
            local physicalPath = modDir
            
            -- Load TOML using io
            local tomlContent = ""
            file = io.open(tomlPath, "r")
            if file then
                tomlContent = file:read("*all")
                file:close()
            end
            
            local success, modConfig = pcall(TOML.parse, tomlContent)
            if success and modConfig and modConfig.mod then
                modConfig.mod.path = physicalPath  -- Store physical path instead of mounted path
                modConfig.mod.folder = item
                table.insert(modList, modConfig)
                print(string.format("[ModManager] Loaded mod config: %s", tostring(modConfig.mod.name)))
            else
                print(string.format("[ModManager] ERROR: Failed to parse TOML for %s", item))
            end
        end
    end
    
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

--- Set the active mod for content resolution.
---
--- Makes the specified mod the primary content source. All subsequent
--- calls to getContentPath() will use this mod.
---
--- @param modId string Mod identifier to activate
--- @return boolean True if successful, false if mod not found
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

--- Get the active mod configuration.
---
--- Returns the full mod metadata table for the active mod.
---
--- @return table|nil Mod configuration or nil if none active
function ModManager.getActiveMod()
    if not ModManager.activeMod then
        return nil
    end
    return ModManager.mods[ModManager.activeMod]
end

--- Get path to content in active mod.
---
--- Resolves content path using mod's paths configuration.
--- Returns full path ready for love.filesystem or io operations.
---
--- @param contentType string Content type ("assets", "rules", "mapblocks", "mapscripts")
--- @param subpath string|nil Optional subdirectory/filename within content type
--- @return string|nil Full path to content or nil if not found
--- @usage
---   local terrainPath = ModManager.getContentPath("rules", "battle/terrain.toml")
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
    
    -- Build full path with consistent separators
    -- Detect if we're on Windows (basePath contains backslashes)
    local isWindows = basePath:find("\\") ~= nil
    local separator = isWindows and "\\" or "/"
    
    -- Start with base path + content type
    local fullPath = basePath .. separator .. contentPath
    
    if subpath then
        -- Normalize subpath separators to match the platform
        subpath = subpath:gsub("/", separator):gsub("\\", separator)
        fullPath = fullPath .. separator .. subpath
    end
    
    return fullPath
end

--- Get content reference from active mod.
---
--- Checks if mod provides specific content type.
--- Deprecated - prefer using getContentPath() instead.
---
--- @param contentType string Content type identifier
--- @return table|nil Mod table if content exists
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

--- Initialize mod system and load all mods.
---
--- Scans mods/ directory, loads mod.toml files, and sets default active mod.
--- Tries 'core' first for complete test data. Falls back to xcom_simple or new if core unavailable.
--- Should be called once during game startup.
---
--- @error If no mods found in mods/ directory
--- @return nil
function ModManager.init()
    print("[ModManager] Initializing mod system...")
    ModManager.loadMods()
    
    -- Try to load 'core' mod as default (has complete game data structure)
    local defaultModLoaded = false
    if ModManager.isModLoaded("core") then
        ModManager.setActiveMod("core")
        defaultModLoaded = true
        print("[ModManager] Default mod 'core' loaded successfully (complete test data)")
    elseif ModManager.isModLoaded("xcom_simple") then
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

--- Get list of all loaded mods.
---
--- Returns array of mod configurations in load order.
---
--- @return table Array of mod config tables
function ModManager.getLoadedMods()
    local modList = {}
    for _, modId in ipairs(ModManager.modOrder) do
        table.insert(modList, ModManager.mods[modId])
    end
    return modList
end

--- Check if a specific mod is loaded.
---
--- @param modId string Mod identifier to check
--- @return boolean True if mod is loaded
function ModManager.isModLoaded(modId)
    return ModManager.mods[modId] ~= nil
end

--- Get terrain types from active mod.
---
--- Loads terrain definitions through DataLoader.
--- Returns empty table if mod not set or terrain data not found.
---
--- @return table Terrain types table with utility functions
function ModManager.getTerrainTypes()
    local mod = ModManager.getActiveMod()
    if not mod then
        print("[ModManager] ERROR: No active mod set")
        return {}
    end
    
    -- Try to load from DataLoader first (TOML-based)
    local DataLoader = require("core.data_loader")
    if DataLoader and DataLoader.terrainTypes then
        return DataLoader.terrainTypes
    end
    
    return {}
end

--- Get mapblocks from active mod.
---
--- Scans mapblocks directory and loads all .toml files.
--- Returns array of mapblock definitions with filename property.
---
--- @return table Array of mapblock config tables
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
            local TOML = require("utils.toml")
            local success, mapblock = pcall(TOML.load, filepath)
            if success and mapblock then
                mapblock.filename = filename
                table.insert(mapblocks, mapblock)
            end
        end
    end
    
    return mapblocks
end

--- Load a specific mod by ID.
---
--- Compatibility alias for loadMods(). Currently loads all mods
--- then attempts to set requested mod as active.
---
--- @param modId string Mod identifier to load
--- @return boolean True if mod loaded and activated
function ModManager.loadMod(modId)
    -- For now, just call loadMods which loads all mods
    -- In the future, this could be enhanced to load specific mods
    ModManager.loadMods()
    
    -- Try to set the requested mod as active if it was loaded
    if ModManager.isModLoaded(modId) then
        return ModManager.setActiveMod(modId)
    end
    
    return false
end

--- Get current active mod data.
---
--- Alias for getActiveMod(). Returns active mod configuration.
---
--- @return table|nil Active mod config or nil
function ModManager.getCurrentMod()
    return ModManager.getActiveMod()
end

--- Get mod info summary for display.
---
--- Returns formatted string with mod name, version, and author.
---
--- @return string Formatted mod info string
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


























