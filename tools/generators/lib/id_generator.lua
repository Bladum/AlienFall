-- IDGenerator: Generate consistent, readable IDs for entities
-- Creates IDs that are both human-readable and follow validation rules

local IDGenerator = {}

-- Track generated IDs to avoid duplicates
local generatedIds = {}
local entityRegistry = {}

---Initialize ID tracker
function IDGenerator.init()
  generatedIds = {}
  entityRegistry = {}
end

---Convert name to snake_case ID
---@param name string The display name
---@param entityType string Type of entity (for context)
---@param index number|nil Optional index for disambiguation
---@return string id The generated ID
function IDGenerator.generate(name, entityType, index)
  -- Convert to snake_case
  local id = name
    :lower()                               -- lowercase
    :gsub("[^a-z0-9]+", "_")              -- replace non-alphanumeric with underscore
    :gsub("^_+", "")                      -- remove leading underscores
    :gsub("_+$", "")                      -- remove trailing underscores
    :gsub("_+", "_")                      -- collapse multiple underscores

  -- Add index if provided
  if index then
    id = id .. "_" .. index
  end

  -- Ensure uniqueness
  local baseId = id
  local counter = 1
  while generatedIds[id] do
    id = baseId .. "_" .. counter
    counter = counter + 1
  end

  generatedIds[id] = true

  return id
end

---Register an entity for reference resolution
---@param entityType string Type of entity (units, items, etc)
---@param entityId string The entity's ID
---@param data table The entity data
function IDGenerator.registerEntity(entityType, entityId, data)
  if not entityRegistry[entityType] then
    entityRegistry[entityType] = {}
  end

  entityRegistry[entityType][entityId] = data
end

---Get a reference ID for a specific entity type
---@param entityType string The entity type to reference
---@param context table|nil Context information
---@return string|nil entityId A valid entity ID or nil if none available
function IDGenerator.getReferenceId(entityType, context)
  if not entityRegistry[entityType] or #entityRegistry[entityType] == 0 then
    return nil
  end

  -- Return a random existing entity of this type
  local entities = entityRegistry[entityType]
  local keys = {}
  for k, _ in pairs(entities) do
    table.insert(keys, k)
  end

  if #keys > 0 then
    return keys[math.random(1, #keys)]
  end

  return nil
end

---Get count of registered entities by type
---@param entityType string The entity type
---@return integer count Number of entities registered
function IDGenerator.getCount(entityType)
  if not entityRegistry[entityType] then
    return 0
  end

  local count = 0
  for _ in pairs(entityRegistry[entityType]) do
    count = count + 1
  end

  return count
end

---Clear all registries
function IDGenerator.clear()
  generatedIds = {}
  entityRegistry = {}
end

---Check if ID already exists
---@param id string The ID to check
---@return boolean exists
function IDGenerator.exists(id)
  return generatedIds[id] == true
end

return IDGenerator
