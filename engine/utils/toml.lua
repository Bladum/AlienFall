---TOML Parser
---
---Simple TOML parser for game configuration files. Parses mapblock definitions,
---terrain data, weapon stats, and other game content stored in TOML format.
---Supports basic TOML features: strings, numbers, booleans, tables, arrays,
---and nested sections.
---
---Supported TOML Features:
---  - Key-value pairs: key = "value"
---  - Numbers: integer = 42, float = 3.14
---  - Booleans: flag = true
---  - Strings: name = "text"
---  - Tables: [section]
---  - Nested sections: [parent.child]
---  - Arrays: items = [1, 2, 3]
---  - Comments: # This is a comment
---
---Key Exports:
---  - TOML.parse(content): Parses TOML string into Lua table
---  - TOML.parseFile(filepath): Loads and parses TOML file
---
---Dependencies:
---  - None (pure Lua implementation)
---
---@module utils.toml
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TOML = require("utils.toml")
---  local data = TOML.parseFile("config.toml")
---  print(data.section.key)
---
---@see core.data_loader For loading game data
---@see mods.mod_manager For mod metadata parsing

local TOML = {}

-- Parse TOML string
function TOML.parse(content)
    local data = {}
    local currentSection = data
    local sectionStack = {data}
    local currentSectionName = nil
    
    for line in content:gmatch("[^\r\n]+") do
        -- Trim whitespace
        line = line:match("^%s*(.-)%s*$")
        
        -- Skip empty lines and comments
        if line == "" or line:match("^#") then
            goto continue
        end
        
        -- Array-of-tables header: [[array]] or [[parent.array]]
        local arraySection = line:match("^%[%[(.+)%]%]$")
        if arraySection then
            -- Create array structure if it doesn't exist
            if not data[arraySection] then
                data[arraySection] = {}
            end
            -- Add new table to array
            local newTable = {}
            table.insert(data[arraySection], newTable)
            currentSection = newTable
            goto continue
        end
        
        -- Section header: [section] or [section.subsection]
        local section = line:match("^%[(.+)%]$")
        if section then
            currentSectionName = section
            
            -- Handle dotted sections like [terrain.road]
            if section:match("%.") then
                local parts = {}
                for part in section:gmatch("[^%.]+") do
                    table.insert(parts, part)
                end
                
                -- Navigate/create nested structure
                currentSection = data
                for i, part in ipairs(parts) do
                    if not currentSection[part] then
                        currentSection[part] = {}
                    end
                    currentSection = currentSection[part]
                end
            else
                -- Simple section
                if not data[section] then
                    data[section] = {}
                end
                currentSection = data[section]
            end
            goto continue
        end
        
        -- Key-value pair: key = value
        local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
        if key and value then
            -- Parse value type
            value = value:match("^%s*(.-)%s*$")  -- Trim
            
            -- String: "value"
            if value:match('^".-"$') then
                currentSection[key] = value:sub(2, -2)  -- Remove quotes
            -- Number
            elseif tonumber(value) then
                currentSection[key] = tonumber(value)
            -- Boolean
            elseif value == "true" then
                currentSection[key] = true
            elseif value == "false" then
                currentSection[key] = false
            -- Default: string
            else
                currentSection[key] = value
            end
            goto continue
        end
        
        ::continue::
    end
    
    return data
end

-- Load TOML file
function TOML.load(filepath)
    -- Try love.filesystem first (for files in the game directory)
    if love and love.filesystem then
        local content, err = love.filesystem.read(filepath)
        if content then
            print(string.format("[TOML] Successfully loaded: %s (%d bytes)", filepath, #content))
            return TOML.parse(content)
        else
            print(string.format("[TOML] love.filesystem.read failed for: %s - %s", filepath, tostring(err)))
        end
    end
    
    -- Fall back to io.open (for absolute paths)
    -- Normalize path separators - try both backslash and forward slash versions
    local file = io.open(filepath, "r")
    if not file then
        -- Try converting backslashes to forward slashes
        local altpath = filepath:gsub("\\", "/")
        file = io.open(altpath, "r")
    end
    
    if not file then
        print(string.format("[TOML] ERROR: Cannot open file: %s", filepath))
        return nil
    end
    
    local content = file:read("*all")
    file:close()
    
    print(string.format("[TOML] Loaded via io.open: %s (%d bytes)", filepath, #content))
    return TOML.parse(content)
end

-- Save data to TOML file
function TOML.save(filepath, data)
    local lines = {}
    
    -- Write sections
    for section, values in pairs(data) do
        if type(values) == "table" then
            table.insert(lines, string.format("[%s]", section))
            
            for key, value in pairs(values) do
                local valueStr
                if type(value) == "string" then
                    valueStr = string.format('"%s"', value)
                elseif type(value) == "boolean" then
                    valueStr = value and "true" or "false"
                else
                    valueStr = tostring(value)
                end
                
                table.insert(lines, string.format("%s = %s", key, valueStr))
            end
            
            table.insert(lines, "")  -- Empty line between sections
        end
    end
    
    local content = table.concat(lines, "\n")
    
    local file = io.open(filepath, "w")
    if not file then
        print(string.format("[TOML] ERROR: Cannot write file: %s", filepath))
        return false
    end
    
    file:write(content)
    file:close()
    
    print(string.format("[TOML] Saved to: %s", filepath))
    return true
end

return TOML


























