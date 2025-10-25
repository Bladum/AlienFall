--[[
  Simple YAML Parser for Lua
  Handles basic YAML structure used in army configs
]]--

local YAMLParser = {}

-- Convert YAML to table - parse list items properly with all nested properties
function YAMLParser.parseSimple(content)
    local result = {}
    local lines = content:split("\n")

    local function get_indent(line)
        return #line - #line:lstrip()
    end

    local function get_trimmed(line)
        return line:match("^%s*(.*)$")
    end

    -- Main parsing
    local i = 1
    local function parse_value_recursive(start_indent, parent)
        while i <= #lines do
            local line = lines[i]
            i = i + 1

            -- Skip empty and comments
            if line:match("^%s*$") or line:match("^%s*#") then
                goto continue_parse_value
            end

            local indent = get_indent(line)
            local trimmed = get_trimmed(line)

            -- If we've dedented, return
            if indent < start_indent then
                i = i - 1  -- Back up so parent can process this line
                return
            end

            -- Skip if indentation doesn't match exactly (for keys at this level)
            -- Only skip if it's strictly greater (for nested content)
            if start_indent >= 0 and indent > start_indent then
                i = i - 1
                return
            end

            -- Parse key: value at this level
            if trimmed:match("^[%w_%-]+:") then
                local key, val = trimmed:match("^([%w_%-]+):%s*(.*)$")
                if val == "" then
                    -- Nested object - recursively parse it
                    local nested = {}
                    parent[key] = nested
                    parse_value_recursive(indent + 2, nested)
                else
                    -- Direct value
                    parent[key] = YAMLParser.parseValue(val)
                end

            -- Handle list items
            elseif trimmed:match("^%-") then
                -- Create list if it doesn't exist
                if not parent._items then
                    parent._items = {}
                end

                local item_str = trimmed:match("^%-%s*(.*)$")

                -- Check if list item has inline key:value
                if item_str:match("^[%w_%-]+:") then
                    local k, v = item_str:match("^([%w_%-]+):%s*(.*)$")
                    local item = { [k] = YAMLParser.parseValue(v) }
                    table.insert(parent._items, item)

                    -- Parse properties for this item
                    parse_value_recursive(indent + 2, item)
                else
                    -- Simple list item
                    table.insert(parent._items, item_str)
                end
            end

            ::continue_parse_value::
        end
    end

    parse_value_recursive(-1, result)
    return result
end

-- Alias for compatibility
function YAMLParser.parse(content)
    return YAMLParser.parseSimple(content)
end

-- Parse a value and convert to appropriate type
function YAMLParser.parseValue(value)
    if not value or value == "" then
        return nil
    end

    value = value:trim()

    -- Booleans
    if value:lower() == "true" then
        return true
    elseif value:lower() == "false" then
        return false
    end

    -- Numbers
    local num = tonumber(value)
    if num then
        return num
    end

    -- Strings with quotes
    if (value:match('^"') and value:match('"$')) or (value:match("^'") and value:match("'$")) then
        return value:sub(2, -2)
    end

    -- Unquoted string
    return value
end

-- String utility functions
function string:split(sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep:gsub("[%^%$%(%)%%%.%*%+%-%?%[%]%|]", "%%%1"))
    for each in self:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

function string:lstrip()
    return self:match("^%s*(.*)")
end

function string:rstrip()
    return self:match("(.-)%s*$")
end

function string:trim()
    return self:lstrip():rstrip()
end

return YAMLParser
