-- content_loader.lua
-- Loads all TOML files from a mod and builds entity registry
-- Purpose: Load mod content into memory for validation

local ContentLoader = {}

-- Utility: List files in directory (Love2D compatible)
local function listFiles(directory, pattern)
  local files = {}
  
  if love then
    -- Love2D filesystem API
    local items = love.filesystem.getDirectoryItems(directory)
    for _, item in ipairs(items) do
      local fullPath = directory .. "/" .. item
      local info = love.filesystem.getInfo(fullPath)
      
      if info and info.type == "file" then
        if not pattern or item:match(pattern) then
          table.insert(files, fullPath)
        end
      end
    end
  else
    -- Standard Lua - use io library
    local function scanDir(dir)
      local cmd
      if package.config:sub(1,1) == '\\' then
        -- Windows
        cmd = 'dir /b "' .. dir .. '"'
      else
        -- Unix
        cmd = 'find "' .. dir .. '" -maxdepth 1 -type f'
      end
      
      local handle = io.popen(cmd)
      if handle then
        for file in handle:lines() do
          if not pattern or file:match(pattern) then
            table.insert(files, dir .. "/" .. file)
          end
        end
        handle:close()
      end
    end
    scanDir(directory)
  end
  
  return files
end

-- Parse TOML file with error handling
local function loadTOML(filePath)
  local ok, toml
  
  if love then
    -- Love2D: Try using built-in TOML support
    ok, toml = pcall(require, "toml")
    if ok and toml then
      local content = love.filesystem.read(filePath)
      if content then
        local ok2, data = pcall(toml.parse, content)
        if ok2 then
          return data
        else
          return nil, tostring(data)
        end
      end
    end
  end
  
  -- Fallback: Try to parse with basic Lua TOML
  local file = io.open(filePath, "r")
  if not file then
    return nil, "File not found"
  end
  
  local content = file:read("*a")
  file:close()
  
  -- Simple TOML parser (basic support)
  local data = {}
  local currentSection = data
  local sectionStack = {}
  
  for line in content:gmatch("[^\n]+") do
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    
    if line ~= "" and not line:match("^#") then
      -- Section header
      if line:match("^%[%[") then
        local sectionName = line:match("^%[%[(.+)%]%]")
        if sectionName then
          if not data[sectionName] then
            data[sectionName] = {}
          end
          currentSection = data[sectionName]
          sectionStack = {sectionName}
        end
      elseif line:match("^%[") then
        local sectionName = line:match("^%[(.+)%]")
        if sectionName then
          local parts = {}
          for part in sectionName:gmatch("[^.]+") do
            table.insert(parts, part)
          end
          
          currentSection = data
          for _, part in ipairs(parts) do
            if not currentSection[part] then
              currentSection[part] = {}
            end
            currentSection = currentSection[part]
          end
          sectionStack = parts
        end
      else
        -- Key-value pair
        local key, value = line:match("^(.-)%s*=%s*(.+)")
        if key and value then
          key = key:gsub("^%s+", ""):gsub("%s+$", "")
          
          -- Parse value
          if value:match("^%d+%.%d+$") then
            currentSection[key] = tonumber(value)
          elseif value:match("^%d+$") then
            currentSection[key] = tonumber(value)
          elseif value == "true" or value == "false" then
            currentSection[key] = value == "true"
          elseif value:match("^['\"]") then
            currentSection[key] = value:gsub("^['\"]", ""):gsub("['\"]$", "")
          elseif value:match("^%[") then
            -- Array
            local array = {}
            for item in value:gmatch("%\"([^\"]+)\"") do
              table.insert(array, item)
            end
            currentSection[key] = array
          else
            currentSection[key] = value
          end
        end
      end
    end
  end
  
  return data
end

-- Load entire mod into memory
function ContentLoader.loadMod(modPath)
  local mod = {
    units = {},
    items = {},
    weapons = {},
    armor = {},
    crafts = {},
    facilities = {},
    research = {},
    manufacturing = {},
    missions = {},
    ufos = {},
    aliens = {},
    regions = {},
    countries = {},
    events = {},
    pilots = {},
    perks = {},
    tilesets = {},
    mapblocks = {},
    races = {},
    enemies = {},
  }
  
  -- Scan and load each category
  for category in pairs(mod) do
    mod[category] = ContentLoader.loadCategory(modPath, category)
  end
  
  return mod
end

-- Load all files from specific category
function ContentLoader.loadCategory(modPath, category)
  local entities = {}
  local categoryPath = modPath .. "/rules/" .. category
  
  -- Find all TOML files
  local files = listFiles(categoryPath, "%.toml$")
  
  for _, filePath in ipairs(files) do
    local data, err = loadTOML(filePath)
    
    if data then
      -- Use id field or filename as key
      local entityId = data.id or filePath:match("([^/]+)%.toml$"):gsub("%.toml$", "")
      
      entities[entityId] = {
        id = entityId,
        data = data,
        file = filePath,
        category = category,
      }
    else
      -- Log error but continue
      io.stderr:write("[ERROR] Failed to load " .. filePath .. ": " .. (err or "unknown") .. "\n")
    end
  end
  
  return entities
end

-- Build entity ID index for fast lookups
function ContentLoader.buildIndex(mod)
  local index = {
    byId = {},
    byCategory = mod,
  }
  
  for category, entities in pairs(mod) do
    for entityId, entity in pairs(entities) do
      index.byId[entityId] = {
        entity = entity,
        category = category,
      }
    end
  end
  
  return index
end

-- Get entity by ID (searches all categories)
function ContentLoader.getEntityById(index, entityId)
  return index.byId[entityId]
end

-- Get entity in specific category
function ContentLoader.getEntity(mod, category, entityId)
  if mod[category] then
    return mod[category][entityId]
  end
  return nil
end

-- Count total entities in mod
function ContentLoader.countEntities(mod)
  local count = 0
  for _, entities in pairs(mod) do
    for _ in pairs(entities) do
      count = count + 1
    end
  end
  return count
end

return ContentLoader
