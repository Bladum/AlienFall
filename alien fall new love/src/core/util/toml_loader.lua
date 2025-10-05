--- TOML Loader utility for parsing TOML configuration files.
--
-- This module provides TOML 1.0 compliant parsing functionality,
-- specifically designed for mod configuration files (main.toml).
--
-- @module util.toml_loader
-- @usage local toml = require "util.toml_loader"
--        local data = toml.load("mods/my_mod/main.toml")

local toml_loader = {}

--- Load and parse a TOML file.
-- @param filePath string: Path to the TOML file
-- @return table: Parsed TOML data as a Lua table, or nil if loading fails
-- @return string: Error message if loading fails
function toml_loader.load(filePath)
    local content, err = love.filesystem.read(filePath)
    if not content then
        return nil, "Failed to open file: " .. err
    end

    return toml_loader.parse(content)
end

--- Parse TOML content string into a Lua table.
-- @param content string: TOML content as string
-- @return table: Parsed TOML data as a Lua table
-- @return string: Error message if parsing fails
function toml_loader.parse(content)
    local result = {}
    local currentTable = result
    local tableStack = {result}
    local arrayOfTables = {} -- Track array of tables

    -- Split content into lines and process
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local i = 1
    while i <= #lines do
        local line = lines[i]
        line = line:match("^%s*(.-)%s*$") -- trim whitespace

        if line == "" or line:sub(1, 1) == "#" then
            -- skip empty lines and comments
        elseif line:match("^%[%[.*%]%]$") then
            -- Array of tables header [[table]]
            local tableName = line:match("^%[%[(.-)%]%]$")
            
            -- Initialize array if not exists
            if not arrayOfTables[tableName] then
                arrayOfTables[tableName] = {}
                toml_loader.setNestedValue(result, tableName, arrayOfTables[tableName])
            end

            -- Create new table for this array element
            local newTable = {}
            table.insert(arrayOfTables[tableName], newTable)
            currentTable = newTable
            tableStack = {result}
            for part in tableName:gmatch("[^%.]+") do
                table.insert(tableStack, currentTable)
            end
        elseif line:match("^%[.*%]$") then
            -- Regular table header [table]
            local tableName = line:match("^%[(.-)%]$")
            
            -- Check if this is a subtable of an array element
            local arrayBase, subPath = tableName:match("^([^%.]+)%.(.+)$")
            if arrayBase and arrayOfTables[arrayBase] then
                -- This is a subtable of an array element
                local arrayTable = arrayOfTables[arrayBase]
                local lastElement = arrayTable[#arrayTable]
                if lastElement then
                    currentTable, tableStack = toml_loader.navigateToTable(lastElement, subPath)
                else
                    -- Fallback to regular navigation
                    currentTable, tableStack = toml_loader.navigateToTable(result, tableName)
                end
            else
                currentTable, tableStack = toml_loader.navigateToTable(result, tableName)
            end
            
            arrayOfTables[tableName] = nil -- Reset array of tables for this path
        else
            -- Key-value pair or inline table
            local key, value = toml_loader.parseKeyValue(line, lines, i)
            if key and value then
                currentTable[key] = value
            end
        end
        i = i + 1
    end

    return result
end

--- Navigate to a nested table, creating intermediate tables as needed
-- @param root table: Root table
-- @param path string: Dotted path like "a.b.c"
-- @return table: The target table
-- @return table: Stack of tables
function toml_loader.navigateToTable(root, path)
    local current = root
    local stack = {root}
    local parts = {}

    for part in path:gmatch("[^%.]+") do
        table.insert(parts, part)
    end

    for _, part in ipairs(parts) do
        current[part] = current[part] or {}
        current = current[part]
        table.insert(stack, current)
    end

    return current, stack
end

--- Set a nested value in a table
-- @param root table: Root table
-- @param path string: Dotted path
-- @param value any: Value to set
function toml_loader.setNestedValue(root, path, value)
    local current = root
    local parts = {}

    for part in path:gmatch("[^%.]+") do
        table.insert(parts, part)
    end

    for i = 1, #parts - 1 do
        current[parts[i]] = current[parts[i]] or {}
        current = current[parts[i]]
    end

    current[parts[#parts]] = value
end

--- Parse a key-value pair, handling inline tables
-- @param line string: Current line
-- @param lines table: All lines
-- @param index number: Current line index
-- @return string: Key
-- @return any: Value
function toml_loader.parseKeyValue(line, lines, index)
    local key, value = line:match("^([^=]+)=(.*)$")
    if not key or not value then return nil, nil end

    key = key:match("^%s*(.-)%s*$")
    value = value:match("^%s*(.-)%s*$")

    -- Parse key (handle quoted keys)
    key = toml_loader.parseKey(key)

    -- Check for inline table
    if value:match("^{.*}$") then
        return key, toml_loader.parseInlineTable(value:sub(2, -2))
    end

    -- Parse value
    local parsedValue, consumedLines = toml_loader.parseValue(value, lines, index)
    return key, parsedValue, consumedLines
end

--- Parse a TOML key (bare or quoted)
-- @param key string: Key string
-- @return string: Parsed key
function toml_loader.parseKey(key)
    -- Trim whitespace
    key = key:match("^%s*(.-)%s*$")

    if key:sub(1, 1) == '"' and key:sub(-1) == '"' then
        return key:sub(2, -2)
    elseif key:sub(1, 1) == "'" and key:sub(-1) == "'" then
        return key:sub(2, -2)
    end
    return key
end

--- Parse a TOML value
-- @param value string: Value string
-- @param lines table: All lines (for multi-line strings)
-- @param index number: Current line index
-- @return any: Parsed value
-- @return number: Lines consumed (for multi-line values)
function toml_loader.parseValue(value, lines, index)
    -- Multi-line basic string
    if value:match('^"""') then
        return toml_loader.parseMultiLineString(value, lines, index, '"""')
    -- Multi-line literal string
    elseif value:match("^'''") then
        return toml_loader.parseMultiLineString(value, lines, index, "'''")
    -- Basic string
    elseif value:sub(1, 1) == '"' then
        return toml_loader.parseString(value)
    -- Literal string
    elseif value:sub(1, 1) == "'" then
        return toml_loader.parseLiteralString(value)
    -- Boolean
    elseif value == "true" then
        return true
    elseif value == "false" then
        return false
    -- Array
    elseif value:sub(1, 1) == "[" then
        return toml_loader.parseArray(value)
    -- Inline table
    elseif value:sub(1, 1) == "{" then
        return toml_loader.parseInlineTable(value:sub(2, -2))
    -- Date/Time (basic support)
    elseif value:match("^%d%d%d%d%-%d%d%-%d%d") then
        return value -- Keep as string for now
    -- Number
    else
        local num = toml_loader.parseNumber(value)
        if num then return num end
    end

    -- Fallback to string
    return value
end

--- Parse a string value (basic or literal)
-- @param str string: String to parse
-- @return string: Parsed string
function toml_loader.parseString(str)
    if str:sub(1, 1) == '"' and str:sub(-1) == '"' then
        local content = str:sub(2, -2)
        -- Basic escaping
        content = content:gsub('\\"', '"')
        content = content:gsub("\\\\", "\\")
        content = content:gsub("\\n", "\n")
        content = content:gsub("\\t", "\t")
        content = content:gsub("\\r", "\r")
        return content
    end
    return str
end

--- Parse a literal string
-- @param str string: String to parse
-- @return string: Parsed string
function toml_loader.parseLiteralString(str)
    if str:sub(1, 1) == "'" and str:sub(-1) == "'" then
        return str:sub(2, -2)
    end
    return str
end

--- Parse multi-line string
-- @param start string: Starting part of the string
-- @param lines table: All lines
-- @param index number: Current line index
-- @param delimiter string: String delimiter
-- @return string: Parsed multi-line string
-- @return number: Lines consumed
function toml_loader.parseMultiLineString(start, lines, index, delimiter)
    local content = start:gsub("^" .. delimiter:gsub("%p", "%%%1"), "")
    local consumed = 0

    for i = index + 1, #lines do
        local line = lines[i]
        consumed = consumed + 1

        if line:match(delimiter .. "%s*$") then
            content = content .. "\n" .. line:gsub(delimiter .. ".*$", "")
            break
        else
            content = content .. "\n" .. line
        end
    end

    return content, consumed
end

--- Parse a number (decimal, hex, octal, binary, float)
-- @param num string: Number string
-- @return number: Parsed number
function toml_loader.parseNumber(num)
    -- Remove underscores for readability
    num = num:gsub("_", "")

    -- Hexadecimal
    if num:match("^0x") then
        return tonumber(num:gsub("^0x", ""), 16)
    -- Octal
    elseif num:match("^0o") then
        return tonumber(num:gsub("^0o", ""), 8)
    -- Binary
    elseif num:match("^0b") then
        return tonumber(num:gsub("^0b", ""), 2)
    -- Decimal or float
    else
        return tonumber(num)
    end
end

--- Parse an array
-- @param arr string: Array string
-- @return table: Parsed array
function toml_loader.parseArray(arr)
    if arr:sub(1, 1) == "[" and arr:sub(-1) == "]" then
        local content = arr:sub(2, -2)
        local array = {}
        local current = ""
        local inString = false
        local stringChar = nil
        local braceLevel = 0
        local bracketLevel = 0

        for i = 1, #content do
            local char = content:sub(i, i)

            if not inString then
                if char == '"' or char == "'" then
                    inString = true
                    stringChar = char
                elseif char == "{" then
                    braceLevel = braceLevel + 1
                elseif char == "}" then
                    braceLevel = braceLevel - 1
                elseif char == "[" then
                    bracketLevel = bracketLevel + 1
                elseif char == "]" then
                    bracketLevel = bracketLevel - 1
                elseif char == "," and braceLevel == 0 and bracketLevel == 0 then
                    if current:match("%S") then
                        table.insert(array, toml_loader.parseValue(current:match("^%s*(.-)%s*$")))
                    end
                    current = ""
                    goto continue
                end
            elseif inString and char == stringChar and content:sub(i-1, i-1) ~= "\\" then
                inString = false
                stringChar = nil
            end

            current = current .. char
            ::continue::
        end

        if current:match("%S") then
            table.insert(array, toml_loader.parseValue(current:match("^%s*(.-)%s*$")))
        end

        return array
    end
    return {}
end

--- Parse an inline table
-- @param content string: Inline table content (without braces)
-- @return table: Parsed table
function toml_loader.parseInlineTable(content)
    local table = {}
    local current = ""
    local inString = false
    local stringChar = nil
    local braceLevel = 0
    local bracketLevel = 0

    for i = 1, #content do
        local char = content:sub(i, i)

        if not inString then
            if char == '"' or char == "'" then
                inString = true
                stringChar = char
            elseif char == "{" then
                braceLevel = braceLevel + 1
            elseif char == "}" then
                braceLevel = braceLevel - 1
            elseif char == "[" then
                bracketLevel = bracketLevel + 1
            elseif char == "]" then
                bracketLevel = bracketLevel - 1
            elseif char == "," and braceLevel == 0 and bracketLevel == 0 then
                local key, value = current:match("^%s*([^=]+)%s*=%s*(.-)%s*$")
                if key and value then
                    key = toml_loader.parseKey(key)
                    table[key] = toml_loader.parseValue(value)
                end
                current = ""
                goto continue
            end
        elseif inString and char == stringChar and content:sub(i-1, i-1) ~= "\\" then
            inString = false
            stringChar = nil
        end

        current = current .. char
        ::continue::
    end

    -- Handle last key-value pair
    local key, value = current:match("^%s*([^=]+)%s*=%s*(.-)%s*$")
    if key and value then
        key = toml_loader.parseKey(key)
        table[key] = toml_loader.parseValue(value)
    end

    return table
end

--- Validate a mod's main.toml structure.
-- @param data table: Parsed TOML data
-- @return boolean: true if valid
-- @return string: Error message if invalid
function toml_loader.validateModConfig(data)
    if not data.mod then
        return false, "Missing [mod] section"
    end

    if not data.mod.id then
        return false, "Missing mod.id"
    end

    if not data.mod.name then
        return false, "Missing mod.name"
    end

    if not data.mod.version then
        return false, "Missing mod.version"
    end

    return true
end

return toml_loader
