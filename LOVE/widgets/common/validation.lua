--[[
widgets/validation.lua
Validation utilities for form widgets and input validation


Comprehensive validation system providing reusable input validation utilities for form widgets
and user input validation in tactical strategy game interfaces. Essential for ensuring data
integrity and providing user feedback in OpenXCOM-style game forms and data entry screens.

PURPOSE:
- Provide consistent validation API for all form-like widgets
- Support common validation patterns (email, phone, numbers, etc.)
- Enable custom validation rules for domain-specific requirements
- Collect and report validation errors with user-friendly messages
- Support form-level validation with multiple field validation

KEY FEATURES:
- Built-in validation rules: required, length, email, number, phone, URL, pattern, range
- Validator objects that collect multiple validation errors
- Extensible custom validation rule support
- Pattern-based validation with regex support
- Comprehensive error message system
- Convenience functions for common validations
- Form validation helpers for multi-field validation
- Validation rule combination and chaining

@see widgets.common.textinput
@see widgets.complex.autocomplete
@see widgets.common.form
@see widgets.common.core.Base
]]

local Validation = {}

-- Validation rules
Validation.rules = {
    REQUIRED = "required",
    MIN_LENGTH = "minLength",
    MAX_LENGTH = "maxLength",
    EMAIL = "email",
    NUMBER = "number",
    INTEGER = "integer",
    PHONE = "phone",
    URL = "url",
    PATTERN = "pattern",
    RANGE = "range",
    CUSTOM = "custom"
}

-- Validation patterns
local patterns = {
    email = "^[%w%._%+%-]+@[%w%._%+%-]+%.[%a][%a]+$",
    phone = "^[%+]?[%d%s%-%(%)%.]+$",
    url = "^https?://[%w%.%-_]+%.[%a][%a]+[%w%.%-_]*/?.*$",
    number = "^%-?%d*%.?%d+$",
    integer = "^%-?%d+$"
}

-- Error messages
local errorMessages = {
    required = "This field is required",
    minLength = "Must be at least %d characters",
    maxLength = "Must be no more than %d characters",
    email = "Please enter a valid email address",
    number = "Please enter a valid number",
    integer = "Please enter a valid integer",
    phone = "Please enter a valid phone number",
    url = "Please enter a valid URL",
    pattern = "Invalid format",
    range = "Value must be between %s and %s",
    custom = "Validation failed"
}

-- Validator class
---@class Validator
---@field rules table[] List of validation rules
---@field errors table List of validation errors
---@field isValid boolean Whether the last validation passed
local Validator = {}
Validator.__index = Validator

function Validator:new(rules)
    local obj = {
        rules = rules or {},
        errors = {},
        isValid = true
    }
    setmetatable(obj, self)
    return obj
end

function Validator:addRule(rule, params)
    table.insert(self.rules, { type = rule, params = params })
    return self
end

function Validator:validate(value, fieldName)
    self.errors = {}
    self.isValid = true
    fieldName = fieldName or "Field"

    for _, rule in ipairs(self.rules) do
        local isValid, error = self:_validateRule(value, rule)
        if not isValid then
            table.insert(self.errors, error)
            self.isValid = false
        end
    end

    return self.isValid, self.errors
end

function Validator:_validateRule(value, rule)
    local ruleType = rule.type
    local params = rule.params or {}

    -- Required validation
    if ruleType == Validation.rules.REQUIRED then
        if not value or value == "" then
            return false, errorMessages.required
        end
    end

    -- Skip other validations if value is empty (unless required)
    if not value or value == "" then
        return true, nil
    end

    -- Length validations
    if ruleType == Validation.rules.MIN_LENGTH then
        if #value < params.length then
            return false, string.format(errorMessages.minLength, params.length)
        end
    elseif ruleType == Validation.rules.MAX_LENGTH then
        if #value > params.length then
            return false, string.format(errorMessages.maxLength, params.length)
        end
    end

    -- Pattern validations
    if ruleType == Validation.rules.EMAIL then
        if not string.match(value, patterns.email) then
            return false, errorMessages.email
        end
    elseif ruleType == Validation.rules.PHONE then
        if not string.match(value, patterns.phone) then
            return false, errorMessages.phone
        end
    elseif ruleType == Validation.rules.URL then
        if not string.match(value, patterns.url) then
            return false, errorMessages.url
        end
    elseif ruleType == Validation.rules.NUMBER then
        if not string.match(value, patterns.number) then
            return false, errorMessages.number
        end
    elseif ruleType == Validation.rules.INTEGER then
        if not string.match(value, patterns.integer) then
            return false, errorMessages.integer
        end
    elseif ruleType == Validation.rules.PATTERN then
        if not string.match(value, params.pattern) then
            return false, params.message or errorMessages.pattern
        end
    end

    -- Range validation (for numbers)
    if ruleType == Validation.rules.RANGE then
        local num = tonumber(value)
        if num and (num < params.min or num > params.max) then
            return false, string.format(errorMessages.range, params.min, params.max)
        end
    end

    -- Custom validation
    if ruleType == Validation.rules.CUSTOM then
        local isValid, message = params.validator(value)
        if not isValid then
            return false, message or errorMessages.custom
        end
    end

    return true, nil
end

--- Creates a validator that requires a non-empty value
--- @return Validator A validator instance for required fields
function Validation.required()
    return Validator:new():addRule(Validation.rules.REQUIRED)
end

--- Creates a validator for email addresses
--- @return Validator A validator instance for email validation
function Validation.email()
    return Validator:new():addRule(Validation.rules.EMAIL)
end

--- Creates a validator for minimum length
--- @param length number The minimum required length
--- @return Validator A validator instance for minimum length validation
function Validation.minLength(length)
    return Validator:new():addRule(Validation.rules.MIN_LENGTH, { length = length })
end

--- Creates a validator for maximum length
--- @param length number The maximum allowed length
--- @return Validator A validator instance for maximum length validation
function Validation.maxLength(length)
    return Validator:new():addRule(Validation.rules.MAX_LENGTH, { length = length })
end

--- Creates a validator for numeric range
--- @param min number The minimum allowed value
--- @param max number The maximum allowed value
--- @return Validator A validator instance for range validation
function Validation.range(min, max)
    return Validator:new():addRule(Validation.rules.RANGE, { min = min, max = max })
end

--- Creates a custom validator
--- @param validator function The custom validation function
--- @param message string Optional custom error message
--- @return Validator A validator instance for custom validation
function Validation.custom(validator, message)
    return Validator:new():addRule(Validation.rules.CUSTOM, { validator = validator, message = message })
end

--- Combines multiple validators
--- @param ... Validator Multiple validator instances to combine
--- @return Validator A combined validator instance
function Validation.combine(...)
    local validators = { ... }
    local combined = Validator:new()

    for _, validator in ipairs(validators) do
        for _, rule in ipairs(validator.rules) do
            table.insert(combined.rules, rule)
        end
    end

    return combined
end

--- Validates an entire form with multiple fields
--- @param formData table Table containing field names as keys and field values as values
--- @param validationRules table Table containing field names as keys and validator instances as values
--- @return boolean, table Returns true if form is valid, false otherwise, and a table of field errors
function Validation.validateForm(formData, validationRules)
    local formErrors = {}
    local isFormValid = true

    for fieldName, validator in pairs(validationRules) do
        local value = formData[fieldName]
        local isValid, errors = validator:validate(value, fieldName)

        if not isValid then
            formErrors[fieldName] = errors
            isFormValid = false
        end
    end

    return isFormValid, formErrors
end

--- Validates a widget using the provided validator
--- @param widget table The widget instance to validate
--- @param validator Validator|function The validator instance or validation function to use
--- @return table A result table with state and message fields
function Validation.validateWidget(widget, validator)
    if not validator then
        return { state = "none", message = "" }
    end

    local value = widget.getText and widget:getText() or widget.text or ""

    -- Handle function validators
    if type(validator) == "function" then
        local success, result = pcall(validator, value)
        if success then
            if result == true then
                return { state = "valid", message = "" }
            elseif type(result) == "string" then
                return { state = "invalid", message = result }
            else
                return { state = "invalid", message = "Validation failed" }
            end
        else
            return { state = "invalid", message = "Validation error: " .. tostring(result) }
        end
    end

    -- Handle Validator objects
    if type(validator) == "table" then
        --- @type Validator
        local validatorObj = validator
        local success, isValid, errors = pcall(function() return validatorObj:validate(value, widget.placeholder or "Field") end)
        if success then
            return {
                state = isValid and "valid" or "invalid",
                message = type(errors) == "table" and table.concat(errors, "; ") or tostring(errors or "")
            }
        end
    end

    -- Fallback for unknown validator types
    return { state = "invalid", message = "Invalid validator type" }
end

Validation.Validator = Validator
return Validation
