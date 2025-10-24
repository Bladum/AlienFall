-- DataGenerator: Generate synthetic data for each field type
-- Creates realistic mock values based on schema definitions

local DataGenerator = {}

local NameGenerator = require("name_generator")
local IDGenerator = require("id_generator")

---Generate value for a field based on its schema definition
---@param fieldDef table The field schema definition
---@param context table Context information (entityType, entityId, fieldName)
---@param strategy string Generation strategy (minimal, coverage, stress, realistic)
---@return any value The generated value
function DataGenerator.generate(fieldDef, context, strategy)
  local fieldType = fieldDef.type or "string"
  strategy = strategy or "realistic"

  if fieldType == "string" then
    return DataGenerator.generateString(fieldDef, context, strategy)
  elseif fieldType == "integer" then
    return DataGenerator.generateInteger(fieldDef, context, strategy)
  elseif fieldType == "float" then
    return DataGenerator.generateFloat(fieldDef, context, strategy)
  elseif fieldType == "boolean" then
    return DataGenerator.generateBoolean(fieldDef, context, strategy)
  elseif fieldType == "enum" then
    return DataGenerator.generateEnum(fieldDef, context, strategy)
  elseif fieldType:match("^array") then
    return DataGenerator.generateArray(fieldDef, context, strategy)
  elseif fieldType == "table" then
    return DataGenerator.generateTable(fieldDef, context, strategy)
  elseif fieldType == "reference" then
    return DataGenerator.generateReference(fieldDef, context, strategy)
  end

  return nil
end

---Generate string value
---@param fieldDef table Field definition
---@param context table Context information
---@param strategy string Generation strategy
---@return string value
function DataGenerator.generateString(fieldDef, context, strategy)
  local fieldName = context.fieldName or ""

  -- Handle special naming fields
  if fieldName == "name" or fieldName == "display_name" then
    return NameGenerator.generate(context.entityType or "item")
  end

  if fieldName == "description" then
    return "Generated description for " .. (context.entityId or context.entityType or "entity")
  end

  if fieldName:match("_file") or fieldName:match("_path") then
    return "assets/" .. (context.entityType or "items") .. "/" .. (context.entityId or "entity") .. ".png"
  end

  if fieldName == "id" then
    return IDGenerator.generate(context.entityId or fieldName, context.entityType)
  end

  -- Default: generic string
  return "generated_" .. fieldName
end

---Generate integer value
---@param fieldDef table Field definition
---@param context table Context information
---@param strategy string Generation strategy
---@return integer value
function DataGenerator.generateInteger(fieldDef, context, strategy)
  local min = fieldDef.min or 0
  local max = fieldDef.max or 100

  if strategy == "minimal" then
    return min
  elseif strategy == "coverage" then
    -- Use both extremes and middle
    if math.random() < 0.33 then
      return min
    elseif math.random() < 0.67 then
      return max
    else
      return math.floor((min + max) / 2)
    end
  elseif strategy == "realistic" or strategy == "stress" then
    -- Random value in range
    return math.random(min, max)
  end

  return math.floor((min + max) / 2)
end

---Generate float value
---@param fieldDef table Field definition
---@param context table Context information
---@param strategy string Generation strategy
---@return number value
function DataGenerator.generateFloat(fieldDef, context, strategy)
  local min = fieldDef.min or 0.0
  local max = fieldDef.max or 100.0

  if strategy == "minimal" then
    return min
  elseif strategy == "coverage" then
    if math.random() < 0.33 then
      return min
    elseif math.random() < 0.67 then
      return max
    else
      return (min + max) / 2
    end
  else
    -- Random float in range
    return min + math.random() * (max - min)
  end
end

---Generate boolean value
---@param fieldDef table Field definition
---@param context table Context information
---@param strategy string Generation strategy
---@return boolean value
function DataGenerator.generateBoolean(fieldDef, context, strategy)
  if strategy == "coverage" then
    return math.random() < 0.5
  end

  return fieldDef.default or false
end

---Generate enum value
---@param fieldDef table Field definition
---@param context table Context information
---@param strategy string Generation strategy
---@return string value
function DataGenerator.generateEnum(fieldDef, context, strategy)
  local values = fieldDef.values

  if not values or #values == 0 then
    return "default"
  end

  if strategy == "minimal" then
    return values[1]  -- First value
  elseif strategy == "coverage" then
    -- Return different value each time for coverage
    return values[math.random(1, #values)]
  else
    return values[math.random(1, #values)]
  end
end

---Generate array value
---@param fieldDef table Field definition
---@param context table Context information
---@param strategy string Generation strategy
---@return table value Array
function DataGenerator.generateArray(fieldDef, context, strategy)
  local array = {}

  local elementCount = 1
  if strategy == "coverage" then
    elementCount = math.random(1, 3)
  elseif strategy == "stress" then
    elementCount = math.random(3, 10)
  end

  for i = 1, elementCount do
    local elementType = fieldDef.element_type or "string"

    if elementType == "string" then
      table.insert(array, "element_" .. i)
    elseif elementType == "integer" then
      table.insert(array, i)
    elseif elementType == "reference" then
      table.insert(array, "ref_" .. i)
    else
      table.insert(array, "item_" .. i)
    end
  end

  return array
end

---Generate table value
---@param fieldDef table Field definition
---@param context table Context information
---@param strategy string Generation strategy
---@return table value Table/object
function DataGenerator.generateTable(fieldDef, context, strategy)
  local table_result = {}

  -- Generic table with a few key-value pairs
  if strategy == "minimal" then
    table_result["default"] = 1
  else
    table_result["stat_1"] = math.random(1, 100)
    table_result["stat_2"] = math.random(1, 100)

    if strategy == "coverage" or strategy == "stress" then
      table_result["stat_3"] = math.random(1, 100)
    end
  end

  return table_result
end

---Generate reference value (foreign key)
---@param fieldDef table Field definition
---@param context table Context information
---@param strategy string Generation strategy
---@return string value Referenced entity ID
function DataGenerator.generateReference(fieldDef, context, strategy)
  local referencedType = fieldDef.references

  if referencedType then
    local refId = IDGenerator.getReferenceId(referencedType, context)
    if refId then
      return refId
    end
  end

  -- Fallback: generate a placeholder
  return "ref_" .. (referencedType or "unknown") .. "_" .. math.random(1, 1000)
end

return DataGenerator
