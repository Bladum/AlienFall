--- Input Sanitization Utility
-- Provides comprehensive input sanitization for user-provided data
-- @module sanitize

local Sanitize = {}

--- Sanitize text input by removing dangerous characters
-- @param text Input text
-- @param max_length Maximum allowed length (default: 1000)
-- @return Sanitized text
function Sanitize.text(text, max_length)
    if not text or type(text) ~= 'string' then
        return ""
    end
    
    max_length = max_length or 1000
    
    -- Trim to max length
    if #text > max_length then
        text = text:sub(1, max_length)
    end
    
    -- Remove control characters except newline and tab
    text = text:gsub('[%c]', function(c)
        if c == '\n' or c == '\t' then
            return c
        end
        return ''
    end)
    
    -- Remove potential script injection attempts
    text = text:gsub('<%s*script', '')
    text = text:gsub('%[%s*%[', '')  -- Lua long strings
    
    return text
end

--- Sanitize filename by removing path traversal and dangerous characters
-- @param filename Input filename
-- @return Sanitized filename
function Sanitize.filename(filename)
    if not filename or type(filename) ~= 'string' then
        return "unnamed"
    end
    
    -- Remove path traversal
    filename = filename:gsub('%.%.', '')
    filename = filename:gsub('[/\\]', '')
    
    -- Remove dangerous characters
    filename = filename:gsub('[<>:"|?*%c]', '')
    
    -- Limit length
    if #filename > 255 then
        filename = filename:sub(1, 255)
    end
    
    -- Ensure not empty
    if #filename == 0 then
        return "unnamed"
    end
    
    return filename
end

--- Sanitize number input
-- @param value Input value
-- @param min Minimum allowed value
-- @param max Maximum allowed value
-- @param default Default value if invalid
-- @return Sanitized number
function Sanitize.number(value, min, max, default)
    local num = tonumber(value)
    
    if not num then
        return default or 0
    end
    
    if min and num < min then
        num = min
    end
    
    if max and num > max then
        num = max
    end
    
    return num
end

--- Sanitize integer input
-- @param value Input value
-- @param min Minimum allowed value
-- @param max Maximum allowed value
-- @param default Default value if invalid
-- @return Sanitized integer
function Sanitize.integer(value, min, max, default)
    local num = Sanitize.number(value, min, max, default)
    return math.floor(num)
end

--- Sanitize boolean input
-- @param value Input value
-- @param default Default value if invalid
-- @return Boolean
function Sanitize.boolean(value, default)
    if type(value) == 'boolean' then
        return value
    end
    
    if type(value) == 'string' then
        local lower = value:lower()
        if lower == 'true' or lower == 'yes' or lower == '1' then
            return true
        end
        if lower == 'false' or lower == 'no' or lower == '0' then
            return false
        end
    end
    
    if type(value) == 'number' then
        return value ~= 0
    end
    
    return default or false
end

--- Sanitize array input
-- @param value Input value
-- @param sanitize_element Function to sanitize each element
-- @param max_length Maximum array length
-- @return Sanitized array
function Sanitize.array(value, sanitize_element, max_length)
    if type(value) ~= 'table' then
        return {}
    end
    
    max_length = max_length or 1000
    local result = {}
    
    for i, v in ipairs(value) do
        if i > max_length then
            break
        end
        
        if sanitize_element then
            table.insert(result, sanitize_element(v))
        else
            table.insert(result, v)
        end
    end
    
    return result
end

--- Escape special characters for pattern matching
-- @param text Input text
-- @return Escaped text
function Sanitize.escapePattern(text)
    if not text then return "" end
    
    -- Escape Lua pattern special characters
    return text:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%1')
end

--- Sanitize HTML-like input (basic escape)
-- @param text Input text
-- @return Escaped text
function Sanitize.escapeHTML(text)
    if not text then return "" end
    
    text = text:gsub('&', '&amp;')
    text = text:gsub('<', '&lt;')
    text = text:gsub('>', '&gt;')
    text = text:gsub('"', '&quot;')
    text = text:gsub("'", '&#39;')
    
    return text
end

--- Sanitize SQL-like input (basic escape)
-- @param text Input text
-- @return Escaped text
function Sanitize.escapeSQL(text)
    if not text then return "" end
    
    -- Escape single quotes
    text = text:gsub("'", "''")
    
    -- Remove null bytes
    text = text:gsub('%z', '')
    
    return text
end

--- Validate and sanitize email format
-- @param email Input email
-- @return Sanitized email or nil if invalid
function Sanitize.email(email)
    if not email or type(email) ~= 'string' then
        return nil
    end
    
    -- Basic email pattern
    local pattern = '^[%w%.%%%+%-]+@[%w%.%-]+%.%w+$'
    
    if email:match(pattern) then
        return email:lower()
    end
    
    return nil
end

--- Sanitize URL
-- @param url Input URL
-- @return Sanitized URL or nil if invalid
function Sanitize.url(url)
    if not url or type(url) ~= 'string' then
        return nil
    end
    
    -- Basic URL validation (http/https only)
    if url:match('^https?://[%w%.%-]+') then
        return url
    end
    
    return nil
end

--- Whitelist validation
-- @param value Input value
-- @param whitelist Table of allowed values
-- @param default Default value if not in whitelist
-- @return Whitelisted value
function Sanitize.whitelist(value, whitelist, default)
    for _, allowed in ipairs(whitelist) do
        if value == allowed then
            return value
        end
    end
    
    return default
end

--- Sanitize table keys (prevent code injection via table keys)
-- @param tbl Input table
-- @param sanitize_value Function to sanitize values (optional)
-- @return Sanitized table
function Sanitize.table_safe(tbl, sanitize_value)
    if type(tbl) ~= 'table' then
        return {}
    end
    
    local result = {}
    
    for k, v in pairs(tbl) do
        -- Only allow string and number keys
        if type(k) == 'string' or type(k) == 'number' then
            local safe_key = k
            
            -- Sanitize string keys
            if type(k) == 'string' then
                safe_key = Sanitize.text(k, 100)
            end
            
            -- Sanitize value if function provided
            if sanitize_value then
                result[safe_key] = sanitize_value(v)
            else
                result[safe_key] = v
            end
        end
    end
    
    return result
end

return Sanitize
