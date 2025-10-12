-- Mod Manager System
-- Handles loading, managing, and providing access to mods
-- All game content is loaded through the mod system

local TOML = require("libs.toml")

local ModManager = {
    mods = {},              -- All loaded mods
    activeMod = nil,        -- Currently active mod
    modOrder = {},          -- Load order of mods
    contentCache = {}       -- Cached content from mods
}

--[[
    Scan mods directory and discover all available mods
    Returns: table of mod metadata
]]
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

--[[
    Load all discovered mods
]]
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
    
    -- Auto-select first mod as active if available
    if #ModManager.modOrder > 0 then
        ModManager.setActiveMod(ModManager.modOrder[1])
    else
        print("[ModManager] WARNING: No mods found!")
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

return ModManager
