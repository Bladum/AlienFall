-- Simple YAML Parser for UI Tests
-- Parses declarative UI test scripts in YAML format

local YAMLParser = {}

-- Parse simple YAML format
-- Handles: key: value, lists with -, and indentation
function YAMLParser.parse(content)
  local result = {}
  local stack = {result}
  local current_key = nil
  local line_num = 0
  
  for line in content:gmatch("[^\n]+") do
    line_num = line_num + 1
    
    -- Skip empty lines and comments
    if line:match("^%s*$") or line:match("^%s*#") then
      goto continue
    end
    
    -- Get indentation level
    local indent = 0
    for i = 1, #line do
      if line:sub(i, i) == " " then
        indent = indent + 1
      elseif line:sub(i, i) == "\t" then
        indent = indent + 4  -- Treat tab as 4 spaces
      else
        break
      end
    end
    
    -- Trim the line
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    
    if not line:match("^%s*$") then
      -- Handle list items (starts with -)
      if line:match("^%-") then
        local item = line:gsub("^%-?%s*", "")
        
        if not stack[#stack]._list then
          stack[#stack]._list = {}
        end
        
        -- Check if item has a colon (key: value)
        if item:match(":") then
          local k, v = item:match("^([^:]+):%s*(.*)$")
          if k and v then
            local item_table = {}
            item_table[k] = v
            table.insert(stack[#stack]._list, item_table)
          end
        else
          table.insert(stack[#stack]._list, item)
        end
      
      -- Handle key: value pairs
      elseif line:match(":") then
        local key, value = line:match("^([^:]+):%s*(.*)$")
        
        if key and value then
          -- Remove quotes if present
          value = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
          
          -- Store the value
          current_key = key
          stack[#stack][key] = value
        end
      end
    end
    
    ::continue::
  end
  
  return result
end

-- Parse test script into structured format
function YAMLParser.parseTestScript(content)
  local raw = YAMLParser.parse(content)
  
  local script = {
    name = raw.name or "Unnamed Test",
    version = raw.version or "1.0",
    description = raw.description,
    setup = raw.setup or {},
    teardown = raw.teardown or {},
    tests = {},
  }
  
  -- Convert raw list format to structured tests
  if raw._list then
    for _, item in ipairs(raw._list) do
      if type(item) == "table" and item.name then
        script.tests[item.name] = {
          name = item.name,
          description = item.description,
          steps = item._list or {},
        }
      end
    end
  end
  
  return script
end

-- Test action structure
function YAMLParser.createAction(action_type, args)
  return {
    action = action_type,
    args = args or {},
  }
end

-- Parse an individual action line
function YAMLParser.parseAction(line)
  -- Format: action_type: arg1=value1, arg2=value2
  local action, args_str = line:match("^([%w_]+):%s*(.*)$")
  
  if not action then
    return nil
  end
  
  local args = {}
  if args_str and args_str ~= "" then
    for arg_pair in args_str:gmatch("[^,]+") do
      local key, value = arg_pair:match("^%s*([%w_]+)%s*=%s*(.*)%s*$")
      if key and value then
        -- Remove quotes
        value = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
        args[key] = value
      end
    end
  end
  
  return YAMLParser.createAction(action, args)
end

return YAMLParser
