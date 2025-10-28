-- SchemaLoader: Load and manage GAME_API.toml schema
-- Provides interface to query schema definitions, validate types, and check constraints

local SchemaLoader = {}

-- Load TOML parser
-- Try multiple methods to require TOML library
local function loadTomlParser()
  -- Try Love2D bundled parser first
  if love and love.filesystem then
    -- Love2D environment
    local status, toml = pcall(require, "Toml")
    if status then return toml end
  end

  -- Try system Lua require
  local status, toml = pcall(require, "toml")
  if status then return toml end

  -- Fallback: use a simple Lua-based parser if available
  local status, toml = pcall(require, "lib.toml")
  if status then return toml end

  error("[SchemaLoader] TOML parser not found. Install 'toml' package or use Love2D with Toml library.")
end

local toml = loadTomlParser()

-- Cache for loaded schemas
local schemaCache = {}

---Load GAME_API.toml from the specified path
---@param schemaPath string Path to GAME_API.toml file
---@return table schema The parsed schema
function SchemaLoader.load(schemaPath)
  schemaPath = schemaPath or "api/GAME_API.toml"

  -- Check cache first
  if schemaCache[schemaPath] then
    return schemaCache[schemaPath]
  end

  print("[SchemaLoader] Loading schema from: " .. schemaPath)

  -- Load file
  local file, err = io.open(schemaPath, "r")
  if not file then
    error("[SchemaLoader] Failed to load schema: " .. (err or "unknown error"))
  end

  local content = file:read("*a")
  file:close()

  -- Parse TOML
  local schema, parseErr = toml.parse(content)
  if not schema then
    error("[SchemaLoader] Failed to parse schema TOML: " .. (parseErr or "unknown error"))
  end

  -- Cache the schema
  schemaCache[schemaPath] = schema

  print("[SchemaLoader] Schema loaded successfully")
  return schema
end

---Get API definition for a specific entity type
---@param schema table The schema object
---@param entityType string The entity type (e.g., "units", "items", "crafts")
---@return table definition The entity definition
function SchemaLoader.getDefinition(schema, entityType)
  if not schema.api then
    error("[SchemaLoader] Schema has no 'api' section")
  end

  if not schema.api[entityType] then
    return nil  -- Unknown entity type
  end

  return schema.api[entityType]
end

---Check if a field is required
---@param definition table Entity definition
---@param fieldName string Name of the field
---@return boolean required True if field is required
function SchemaLoader.isRequired(definition, fieldName)
  if not definition.fields or not definition.fields[fieldName] then
    return false
  end

  local fieldDef = definition.fields[fieldName]
  return fieldDef.required == true
end

---Get field type
---@param definition table Entity definition
---@param fieldName string Name of the field
---@return string|nil type The field type (string, integer, float, boolean, enum, array, table, reference)
function SchemaLoader.getFieldType(definition, fieldName)
  if not definition.fields or not definition.fields[fieldName] then
    return nil
  end

  return definition.fields[fieldName].type
end

---Get valid enum values for an enum field
---@param definition table Entity definition
---@param fieldName string Name of the field
---@return table|nil values Array of valid values
function SchemaLoader.getEnumValues(definition, fieldName)
  if not definition.fields or not definition.fields[fieldName] then
    return nil
  end

  local fieldDef = definition.fields[fieldName]
  if fieldDef.type == "enum" then
    return fieldDef.values
  end

  return nil
end

---Get numeric constraints (min, max, default)
---@param definition table Entity definition
---@param fieldName string Name of the field
---@return table constraints Table with min, max, default values
function SchemaLoader.getConstraints(definition, fieldName)
  if not definition.fields or not definition.fields[fieldName] then
    return {}
  end

  local fieldDef = definition.fields[fieldName]
  local constraints = {}

  if fieldDef.min ~= nil then
    constraints.min = fieldDef.min
  end

  if fieldDef.max ~= nil then
    constraints.max = fieldDef.max
  end

  if fieldDef.default ~= nil then
    constraints.default = fieldDef.default
  end

  return constraints
end

---Get field default value
---@param definition table Entity definition
---@param fieldName string Name of the field
---@return any|nil default The default value
function SchemaLoader.getDefault(definition, fieldName)
  if not definition.fields or not definition.fields[fieldName] then
    return nil
  end

  return definition.fields[fieldName].default
end

---Get field description
---@param definition table Entity definition
---@param fieldName string Name of the field
---@return string|nil description The field description
function SchemaLoader.getDescription(definition, fieldName)
  if not definition.fields or not definition.fields[fieldName] then
    return nil
  end

  return definition.fields[fieldName].description
end

---Get pattern for string validation
---@param definition table Entity definition
---@param fieldName string Name of the field
---@return string|nil pattern Regex pattern
function SchemaLoader.getPattern(definition, fieldName)
  if not definition.fields or not definition.fields[fieldName] then
    return nil
  end

  return definition.fields[fieldName].pattern
end

---Get what entity type a reference field refers to
---@param definition table Entity definition
---@param fieldName string Name of the field
---@return string|nil references The referenced entity type
function SchemaLoader.getReferences(definition, fieldName)
  if not definition.fields or not definition.fields[fieldName] then
    return nil
  end

  return definition.fields[fieldName].references
end

---Get required fields for this entity type
---@param definition table Entity definition
---@return table requiredFields Array of field names that are required
function SchemaLoader.getRequiredFields(definition)
  if not definition.required_fields then
    return {}
  end

  return definition.required_fields
end

---Get all field names in definition
---@param definition table Entity definition
---@return table fieldNames Array of all field names
function SchemaLoader.getAllFieldNames(definition)
  if not definition.fields then
    return {}
  end

  local names = {}
  for fieldName, _ in pairs(definition.fields) do
    table.insert(names, fieldName)
  end

  return names
end

---Get enums dictionary from schema
---@param schema table The schema object
---@return table enums The enums dictionary
function SchemaLoader.getEnums(schema)
  return schema._enums or {}
end

---Get validation rules from schema
---@param schema table The schema object
---@return table rules The validation rules
function SchemaLoader.getValidationRules(schema)
  return schema._validation or {}
end

---Clear schema cache
function SchemaLoader.clearCache()
  schemaCache = {}
end

return SchemaLoader
