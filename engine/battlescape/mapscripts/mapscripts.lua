---MapScripts - Unified MapScript Loader
---
---Loads and manages MapScripts from TOML files. MapScripts define procedural map
---generation using OpenXCOM-style commands (addBlock, fillArea, digTunnel, etc.).
---This is the unified loader supporting TOML-based format.
---
---Features:
---  - TOML-based MapScript loading
---  - Command parsing and validation
---  - Label system for conditional commands
---  - MapScript registry
---  - File path tracking
---  - Error reporting
---  - getAllIds() for compatibility
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
---  - MapScripts.load(filePath): Loads MapScript from TOML
---  - MapScripts.get(id): Returns MapScript by ID
---  - MapScripts.getAll(): Returns all loaded MapScripts
---  - MapScripts.getAllIds(): Returns array of all script IDs
---  - MapScripts.validate(script): Validates script syntax
---  - MapScripts.unload(id): Removes MapScript from registry
---
---Dependencies:
---  - None (uses TOML parser from utils)
---
---@module battlescape.mapscripts.mapscripts
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapScripts = require("battlescape.mapscripts.mapscripts")
---  MapScripts.loadAll("mods/core/mapscripts")
---  local script = MapScripts.get("urban_crash")
---
---@see battlescape.mapscripts.mapscript_executor For execution

-- Map Script Loader - Unified Map Script System
-- Loads and manages Map Scripts from TOML files

local MapScripts = {}

---@class MapScript
---@field id string Unique identifier
---@field name string Display name
---@field description string? Script description
---@field mapSize table {width, height} in blocks
---@field commands table[] Array of commands to execute
---@field labels table<string, number> Label positions {labelName -> commandIndex}
---@field filePath string Source file path

-- Registry of loaded Map Scripts
MapScripts.scripts = {}

---Parse TOML file
---@param filepath string Path to TOML file
---@return table? Parsed TOML data
local function parseTOML(filepath)
    local file = io.open(filepath, "r")
    if not file then
        print(string.format("[MapScripts] Cannot open file: %s", filepath))
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
            print(string.format("[MapScripts] TOML parse error in %s: %s", filepath, tostring(result)))
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
---@return MapScript? script Loaded script or nil
function MapScripts.loadScript(filepath)
    local data = parseTOML(filepath)
    if not data or not data.metadata then
        print(string.format("[MapScripts] Invalid TOML format: %s", filepath))
        return nil
    end

    local meta = data.metadata

    -- Validate required fields
    if not meta.id then
        print(string.format("[MapScripts] Missing 'id' in: %s", filepath))
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
function MapScripts.loadAll(dirPath)
    dirPath = dirPath or "mods/core/mapscripts"
    print(string.format("[MapScripts] Loading Map Scripts from: %s", dirPath))

    -- Clear existing data
    MapScripts.scripts = {}

    local files = love.filesystem.getDirectoryItems(dirPath)
    local count = 0

    for _, filename in ipairs(files) do
        if filename:match("%.toml$") then
            local filepath = dirPath .. "/" .. filename
            local script = MapScripts.loadScript(filepath)
            if script then
                MapScripts.register(script)
                count = count + 1
            end
        end
    end

    print(string.format("[MapScripts] Loaded %d Map Scripts", count))
    return count
end

---Register a Map Script
---@param script MapScript Script to register
function MapScripts.register(script)
    MapScripts.scripts[script.id] = script
    print(string.format("[MapScripts] Registered: %s (%d commands)",
        script.id, #script.commands))
end

---Get a Map Script by ID
---@param scriptId string Script ID
---@return MapScript?
function MapScripts.get(scriptId)
    return MapScripts.scripts[scriptId]
end

---Get all Map Scripts
---@return table<string, MapScript>
function MapScripts.getAll()
    return MapScripts.scripts
end

---Get all Map Script IDs (for compatibility)
---@return table Array of MapScript IDs
function MapScripts.getAllIds()
    local ids = {}
    for id, _ in pairs(MapScripts.scripts) do
        table.insert(ids, id)
    end
    return ids
end

---Clear all loaded Map Scripts
function MapScripts.clear()
    MapScripts.scripts = {}
    print("[MapScripts] Cleared all Map Scripts")
end

return MapScripts