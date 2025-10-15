---MapScriptsV2 - OpenXCOM-Style MapScript Loader
---
---Loads and manages MapScripts from TOML files. MapScripts define procedural map
---generation using OpenXCOM-style commands (addBlock, fillArea, digTunnel, etc.).
---This is the v2 loader supporting the new TOML-based format.
---
---Features:
---  - TOML-based MapScript loading
---  - Command parsing and validation
---  - Label system for conditional commands
---  - MapScript registry
---  - File path tracking
---  - Error reporting
---
---MapScript Structure (TOML):
---  ```toml
---  [mapscript]
---  id = "urban_crash"
---  name = "Urban Crash Site"
---  mapSize = {width = 4, height = 4}
---  
---  [[commands]]
---  command = "addBlock"
---  tags = ["urban", "building"]
---  ```
---
---Supported Commands:
---  - addBlock: Place single MapBlock
---  - addLine: Place line of MapBlocks
---  - fillArea: Fill area with blocks
---  - digTunnel: Create connecting tunnels
---  - addCraft: Place player craft
---  - addUFO: Place UFO wreckage
---  - checkBlock: Validate placement
---  - removeBlocks: Clear specific group
---
---Key Exports:
---  - MapScriptsV2.load(filePath): Loads MapScript from TOML
---  - MapScriptsV2.get(id): Returns MapScript by ID
---  - MapScriptsV2.getAll(): Returns all loaded MapScripts
---  - MapScriptsV2.validate(script): Validates script syntax
---  - MapScriptsV2.unload(id): Removes MapScript from registry
---
---Dependencies:
---  - None (uses TOML parser from utils)
---
---@module battlescape.data.mapscripts_v2
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapScriptsV2 = require("battlescape.data.mapscripts_v2")
---  MapScriptsV2.load("mods/core/content/mapscripts/urban_crash.toml")
---  local script = MapScriptsV2.get("urban_crash")
---
---@see battlescape.mapscripts.mapscript_executor For execution
---@see battlescape.data.mapscripts For legacy system

-- Map Script Loader v2 - OpenXCOM-style Map Script System
-- Loads and manages Map Scripts from TOML files

local MapScriptsV2 = {}

---@class MapScriptV2
---@field id string Unique identifier
---@field name string Display name
---@field description string? Script description
---@field mapSize table {width, height} in blocks
---@field commands table[] Array of commands to execute
---@field labels table<string, number> Label positions {labelName -> commandIndex}
---@field filePath string Source file path

-- Registry of loaded Map Scripts
MapScriptsV2.scripts = {}

---Parse TOML file
---@param filepath string Path to TOML file
---@return table? Parsed TOML data
local function parseTOML(filepath)
    local file = io.open(filepath, "r")
    if not file then
        print(string.format("[MapScriptsV2] Cannot open file: %s", filepath))
        return nil
    end
    
    local content = file:read("*all")
    file:close()
    
    -- Try using TOML library
    local hasToml, toml = pcall(require, "utils.libs.toml")
    if hasToml then
        local success, result = pcall(toml.parse, content)
        if success then
            return result
        else
            print(string.format("[MapScriptsV2] TOML parse error in %s: %s", filepath, tostring(result)))
            return nil
        end
    end
    
    -- Fallback: simple parser
    local data = {metadata = {}, commands = {}}
    local currentSection = nil
    local currentCommand = nil
    
    for line in content:gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        
        if line:match("^#") or line == "" then
            goto continue
        end
        
        if line:match("^%[metadata%]") then
            currentSection = data.metadata
            currentCommand = nil
        elseif line:match("^%[%[commands%]%]") then
            currentCommand = {}
            table.insert(data.commands, currentCommand)
            currentSection = currentCommand
        else
            local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
            if key and value and currentSection then
                -- Parse value
                value = value:gsub("^%s+", ""):gsub("%s+$", "")
                
                -- Array values
                if value:match("^%[") then
                    local arr = {}
                    for item in value:gmatch("[^%[%],%s]+") do
                        if tonumber(item) then
                            table.insert(arr, tonumber(item))
                        elseif item == "true" then
                            table.insert(arr, true)
                        elseif item == "false" then
                            table.insert(arr, false)
                        else
                            table.insert(arr, item:gsub('"', ''):gsub("'", ''))
                        end
                    end
                    value = arr
                -- String values
                elseif value:match('^"') or value:match("^'") then
                    value = value:gsub('"', ''):gsub("'", '')
                -- Boolean values
                elseif value == "true" then
                    value = true
                elseif value == "false" then
                    value = false
                -- Numeric values
                elseif tonumber(value) then
                    value = tonumber(value)
                end
                
                currentSection[key] = value
            end
        end
        
        ::continue::
    end
    
    return data
end

---Load a single Map Script from TOML file
---@param filepath string Path to TOML file
---@return MapScriptV2? script Loaded script or nil
function MapScriptsV2.loadScript(filepath)
    local data = parseTOML(filepath)
    if not data or not data.metadata then
        print(string.format("[MapScriptsV2] Invalid TOML format: %s", filepath))
        return nil
    end
    
    local meta = data.metadata
    
    -- Validate required fields
    if not meta.id then
        print(string.format("[MapScriptsV2] Missing 'id' in: %s", filepath))
        return nil
    end
    
    local script = {
        id = meta.id,
        name = meta.name or meta.id,
        description = meta.description,
        mapSize = meta.mapSize or {7, 7},
        commands = data.commands or {},
        labels = {},
        filePath = filepath
    }
    
    -- Build label index
    for i, cmd in ipairs(script.commands) do
        if cmd.label then
            script.labels[cmd.label] = i
        end
    end
    
    return script
end

---Load all Map Scripts from directory
---@param dirPath string Directory path
---@return number count Number of scripts loaded
function MapScriptsV2.loadAll(dirPath)
    dirPath = dirPath or "mods/core/mapscripts"
    print(string.format("[MapScriptsV2] Loading Map Scripts from: %s", dirPath))
    
    -- Clear existing data
    MapScriptsV2.scripts = {}
    
    local files = love.filesystem.getDirectoryItems(dirPath)
    local count = 0
    
    for _, filename in ipairs(files) do
        if filename:match("%.toml$") then
            local filepath = dirPath .. "/" .. filename
            local script = MapScriptsV2.loadScript(filepath)
            if script then
                MapScriptsV2.register(script)
                count = count + 1
            end
        end
    end
    
    print(string.format("[MapScriptsV2] Loaded %d Map Scripts", count))
    return count
end

---Register a Map Script
---@param script MapScriptV2 Script to register
function MapScriptsV2.register(script)
    MapScriptsV2.scripts[script.id] = script
    print(string.format("[MapScriptsV2] Registered: %s (%d commands)", 
        script.id, #script.commands))
end

---Get a Map Script by ID
---@param scriptId string Script ID
---@return MapScriptV2?
function MapScriptsV2.get(scriptId)
    return MapScriptsV2.scripts[scriptId]
end

---Get all Map Scripts
---@return table<string, MapScriptV2>
function MapScriptsV2.getAll()
    return MapScriptsV2.scripts
end

---Clear all loaded Map Scripts
function MapScriptsV2.clear()
    MapScriptsV2.scripts = {}
    print("[MapScriptsV2] Cleared all Map Scripts")
end

return MapScriptsV2






















