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
    local hasToml, toml = pcall(require, "libs.toml")
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
