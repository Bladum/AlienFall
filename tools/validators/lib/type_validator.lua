-- TypeValidator: Core validation logic for types and values
-- Validates TOML data against schema definitions

local TypeValidator = {}

---Check if a value is of the expected type
---@param value any The value to check
---@param expectedType string The expected type
---@return boolean isValid
local function isValidType(value, expectedType)
  if expectedType == "string" then
    return type(value) == "string"
  elseif expectedType == "integer" then
    return type(value) == "number" and math.floor(value) == value
  elseif expectedType == "float" then
    return type(value) == "number"
  elseif expectedType == "boolean" then
    return type(value) == "boolean"
  elseif expectedType == "array" or expectedType:match("^array%[") then
    return type(value) == "table" and #value > 0
  elseif expectedType == "table" then
    return type(value) == "table"
  elseif expectedType == "enum" then
    return type(value) == "string"
  elseif expectedType == "reference" then
    return type(value) == "string"
  end

  return false
end

---Validate an enum value against allowed values
---@param value any The value to validate
---@param validValues table Array of valid enum values
---@return boolean isValid
---@return string|nil errorMessage
local function validateEnum(value, validValues)
  if type(value) ~= "string" then
    return false, "Expected string, got " .. type(value)
  end

  for _, validValue in ipairs(validValues) do
    if value == validValue then
      return true
    end
  end

  return false, "Invalid enum value '" .. value .. "', valid values: " .. table.concat(validValues, ", ")
end

---Validate a numeric value against constraints
---@param value number The numeric value
---@param min number|nil Minimum value
---@param max number|nil Maximum value
---@return boolean isValid
---@return string|nil errorMessage
local function validateNumeric(value, min, max)
  if type(value) ~= "number" then
    return false, "Expected number, got " .. type(value)
  end

  if min ~= nil and value < min then
    return false, "Value " .. value .. " is below minimum " .. min
  end

  if max ~= nil and value > max then
    return false, "Value " .. value .. " exceeds maximum " .. max
  end

  return true
end

---Validate a string against pattern
---@param value string The string value
---@param pattern string Regex pattern
---@return boolean isValid
---@return string|nil errorMessage
local function validatePattern(value, pattern)
  if type(value) ~= "string" then
    return false, "Expected string, got " .. type(value)
  end

  -- Simple pattern matching (not full regex)
  if value:match(pattern) then
    return true
  end

  return false, "String '" .. value .. "' does not match pattern " .. pattern
end

---Validate entire TOML file against schema definition
---@param tomlData table The parsed TOML data
---@param definition table The entity schema definition
---@param filePath string Path to the file (for error reporting)
---@return table errors Array of error objects
---@return table warnings Array of warning objects
function TypeValidator.validate(tomlData, definition, filePath)
  local errors = {}
  local warnings = {}

  if not definition or not definition.fields then
    return errors, warnings
  end

  -- Check required fields
  if definition.required_fields then
    for _, requiredField in ipairs(definition.required_fields) do
      if tomlData[requiredField] == nil then
        table.insert(errors, {
          path = filePath,
          field = requiredField,
          line = 0,  -- Would need TOML parser with line tracking for this
          message = "Required field missing: " .. requiredField
        })
      end
    end
  end

  -- Validate each field in the data
  for fieldName, value in pairs(tomlData) do
    local fieldDef = definition.fields[fieldName]

    if fieldDef then
      -- Check field type
      local expectedType = fieldDef.type
      local isValid, typeErr = isValidType(value, expectedType), nil

      if not isValid and expectedType then
        table.insert(errors, {
          path = filePath,
          field = fieldName,
          message = "Type mismatch: expected " .. expectedType .. ", got " .. type(value)
        })
      else
        -- Validate specific constraints based on type
        if expectedType == "enum" and fieldDef.values then
          local enumValid, enumErr = validateEnum(value, fieldDef.values)
          if not enumValid then
            table.insert(errors, {
              path = filePath,
              field = fieldName,
              message = enumErr or "Invalid enum value"
            })
          end
        elseif expectedType == "integer" or expectedType == "float" then
          if type(value) == "number" then
            local numValid, numErr = validateNumeric(value, fieldDef.min, fieldDef.max)
            if not numValid then
              table.insert(errors, {
                path = filePath,
                field = fieldName,
                message = numErr or "Numeric constraint violation"
              })
            end
          end
        elseif expectedType == "string" and fieldDef.pattern then
          if type(value) == "string" then
            local patternValid, patternErr = validatePattern(value, fieldDef.pattern)
            if not patternValid then
              table.insert(errors, {
                path = filePath,
                field = fieldName,
                message = patternErr or "Pattern validation failed"
              })
            end
          end
        end
      end
    else
      -- Unknown field
      if fieldName:match("^_") then
        -- Allow private fields starting with _
      else
        table.insert(warnings, {
          path = filePath,
          field = fieldName,
          message = "Unknown field (not in schema)"
        })
      end
    end
  end

  return errors, warnings
end

---Simple validation without full schema (for testing)
---@param tomlData table The parsed TOML data
---@return table errors Array of validation errors
function TypeValidator.quickValidate(tomlData)
  local errors = {}

  -- Check for required id and name fields
  if not tomlData.id or tomlData.id == "" then
    table.insert(errors, "Missing required 'id' field")
  end

  if tomlData.id and not tomlData.id:match("^[a-z0-9_]+$") then
    table.insert(errors, "Field 'id' must match pattern ^[a-z0-9_]+$ (got: " .. tomlData.id .. ")")
  end

  if not tomlData.name or tomlData.name == "" then
    table.insert(errors, "Missing required 'name' field")
  end

  return errors
end

return TypeValidator
