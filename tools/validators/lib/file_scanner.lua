-- FileScanner: Scan mod folder and categorize TOML files
-- Determines which API section each file should validate against
-- Validates file locations and naming conventions

local FileScanner = {}

---Recursively scan directory for .toml files
---@param dirPath string Path to scan
---@return table files Array of file paths
local function scanDirectory(dirPath)
  local files = {}

  -- Handle Love2D filesystem or standard I/O
  local function readDir(path)
    local items = {}

    -- Try Love2D filesystem first
    if love and love.filesystem then
      local success, result = pcall(function()
        return love.filesystem.getDirectoryItems(path)
      end)
      if success then
        return result
      end
    end

    -- Fall back to standard I/O
    local handle = io.popen('dir /s /b "' .. path .. '"')
    if handle then
      for line in handle:lines() do
        if line:match("%.toml$") then
          table.insert(items, line)
        end
      end
      handle:close()
    end

    return items
  end

  local function recurse(path)
    local items = readDir(path)

    for _, item in ipairs(items) do
      if item:match("%.toml$") then
        table.insert(files, item)
      end
    end
  end

  recurse(dirPath)
  return files
end

---Scan entire mod folder for all TOML files
---@param modPath string Path to mod folder
---@return table files Array of relative file paths
function FileScanner.scanMod(modPath)
  print("[FileScanner] Scanning mod: " .. modPath)

  local rulesPath = modPath .. "/rules"

  -- Simple approach: use os.execute to find files
  local files = {}

  local command
  if jit and jit.os == "Windows" or love then
    -- Windows with PowerShell
    command = 'powershell -NoProfile -Command "Get-ChildItem -Path \'' .. rulesPath .. '\' -Filter \'*.toml\' -Recurse | Select-Object -ExpandProperty FullName"'
  else
    -- Unix
    command = "find '" .. rulesPath .. "' -name '*.toml'"
  end

  local handle = io.popen(command)
  if handle then
    for line in handle:lines() do
      line = line:gsub("\r", "")  -- Remove carriage returns
      if line:match("%.toml$") then
        table.insert(files, line)
      end
    end
    handle:close()
  end

  print("[FileScanner] Found " .. #files .. " TOML files")
  return files
end

---Determine which API section a file belongs to based on its path
---@param filePath string Full path to file
---@param modPath string Root mod path
---@return string|nil category Entity category or nil if unknown
function FileScanner.categorizeFile(filePath, modPath)
  -- Normalize path separators
  filePath = filePath:gsub("\\", "/")
  modPath = modPath:gsub("\\", "/")

  -- Extract relative path
  local relativePath = filePath:sub(#modPath + 2)  -- +2 to skip the separator

  -- Map path patterns to categories
  local pathMappings = {
    ["rules/units/"] = "units",
    ["rules/items/"] = "items",
    ["rules/weapons/"] = "weapons",
    ["rules/armor/"] = "armor",
    ["rules/crafts/"] = "crafts",
    ["rules/facilities/"] = "facilities",
    ["rules/research/"] = "research",
    ["rules/manufacturing/"] = "manufacturing",
    ["rules/missions/"] = "missions",
    ["rules/ufos/"] = "ufos",
    ["rules/aliens/"] = "aliens",
    ["rules/regions/"] = "regions",
    ["rules/countries/"] = "countries",
    ["rules/events/"] = "events",
    ["rules/pilots/"] = "pilots",
    ["rules/perks/"] = "perks",
    ["rules/tilesets/"] = "tilesets",
    ["rules/mapblocks/"] = "mapblocks",
    ["rules/geoscape/"] = "geoscape",
    ["rules/economy/"] = "economy",
    ["rules/lore/"] = "lore",
  }

  -- Check which category this file belongs to
  for pattern, category in pairs(pathMappings) do
    if relativePath:match(pattern) then
      return category
    end
  end

  return nil  -- Unknown category
end

---Validate that file location matches API expectations
---@param filePath string Path to file
---@param modPath string Root mod path
---@param category string Entity category
---@param schema table The schema
---@return table errors Array of error messages
function FileScanner.validateLocation(filePath, modPath, category, schema)
  local errors = {}

  -- Get expected location from schema
  local definition = schema.api and schema.api[category]
  if not definition then
    table.insert(errors, "Unknown category: " .. category)
    return errors
  end

  local expectedLocation = definition.file_location
  if not expectedLocation then
    -- No location requirement
    return errors
  end

  -- Convert pattern to regex (simple version)
  -- e.g., "mods/*/rules/units/*.toml" -> pattern for validation
  local expectedPattern = expectedLocation:gsub("%*", "[^/]+")
  expectedPattern = expectedPattern:gsub("/", "\\/")

  filePath = filePath:gsub("\\", "/")

  if not filePath:match(expectedPattern) then
    table.insert(errors, "File location does not match expected pattern: " .. expectedLocation)
  end

  return errors
end

---Validate file naming convention
---@param filePath string Path to file
---@param category string Entity category
---@param schema table The schema
---@return table errors Array of error messages
function FileScanner.validateNaming(filePath, category, schema)
  local errors = {}

  -- Extract filename
  local filename = filePath:match("([^/\\]+)%.toml$")
  if not filename then
    table.insert(errors, "Invalid filename format")
    return errors
  end

  -- Get global validation rules
  local rules = schema._validation or {}

  -- Check ID pattern (filename should be valid ID format)
  local idPattern = rules.id_pattern or "^[a-z0-9_]+$"

  -- Adjust pattern for filename (allows underscores)
  if not filename:match(idPattern) then
    table.insert(errors, "Filename does not match required pattern: " .. idPattern .. " (got: " .. filename .. ")")
  end

  -- Check length
  local minLen = rules.id_min_length or 1
  local maxLen = rules.id_max_length or 50

  if #filename < minLen then
    table.insert(errors, "Filename too short (min: " .. minLen .. ", got: " .. #filename .. ")")
  end

  if #filename > maxLen then
    table.insert(errors, "Filename too long (max: " .. maxLen .. ", got: " .. #filename .. ")")
  end

  return errors
end

return FileScanner
