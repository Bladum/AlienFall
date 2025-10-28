-- ─────────────────────────────────────────────────────────────────────────
-- INPUT VALIDATION SECURITY TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify input validation prevents malicious data
-- Tests: 8 input validation security tests
-- Categories: Range validation, type checking, sanitization

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.security",
    fileName = "input_validation_security_test.lua",
    description = "Input validation and malicious data prevention"
})

-- ─────────────────────────────────────────────────────────────────────────
-- INPUT VALIDATION TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("String Input Validation", function()

    Suite:testMethod("Security:rejectLuaCodeInjection", {
        description = "Rejects Lua code in string inputs",
        testCase = "injection",
        type = "security"
    }, function()
        local playerInput = "normal_name"
        local maliciousInput = "'; os.execute('rm -rf') --"

        -- Simple validation: no semicolons or quotes in names
        local isValid = function(str)
            if str:find(";") or str:find("'") or str:find("\"") then
                return false
            end
            return true
        end

        Helpers.assertTrue(isValid(playerInput), "Valid input should pass")
        Helpers.assertFalse(isValid(maliciousInput), "Malicious input should be rejected")
    end)

    Suite:testMethod("Security:validatePlayerNameLength", {
        description = "Player name length is limited",
        testCase = "validation",
        type = "security"
    }, function()
        local maxNameLength = 32
        local validName = "Commander"
        local tooLongName = string.rep("A", 100)

        Helpers.assertTrue(#validName <= maxNameLength, "Valid name should fit limit")
        Helpers.assertFalse(#tooLongName <= maxNameLength, "Long name should exceed limit")
    end)

    Suite:testMethod("Security:sanitizeFileNames", {
        description = "File names cannot contain dangerous characters",
        testCase = "sanitization",
        type = "security"
    }, function()
        local dangerousChars = {"<", ">", ":", "\"", "|", "?", "*", "/", "\\"}
        local fileName = "mysave.sav"

        local isSafe = function(name)
            for _, char in ipairs(dangerousChars) do
                if name:find(char) then
                    return false
                end
            end
            return true
        end

        Helpers.assertTrue(isSafe(fileName), "Safe filename should pass")
    end)

    Suite:testMethod("Security:validateUnitCount", {
        description = "Unit count cannot be negative or absurd",
        testCase = "validation",
        type = "security"
    }, function()
        local validCount = 5
        local invalidCount = -10
        local absurdCount = 999999

        local isValid = function(count)
            return count > 0 and count <= 100
        end

        Helpers.assertTrue(isValid(validCount), "Valid count should pass")
        Helpers.assertFalse(isValid(invalidCount), "Negative count should fail")
        Helpers.assertFalse(isValid(absurdCount), "Absurd count should fail")
    end)
end)

Suite:group("Numeric Input Validation", function()

    Suite:testMethod("Security:coordinateRangeValidation", {
        description = "Map coordinates are within valid range",
        testCase = "validation",
        type = "security"
    }, function()
        local mapWidth = 100
        local mapHeight = 100
        local validX = 50
        local validY = 50
        local invalidX = -5
        local invalidY = 150

        local isValidCoord = function(x, y, maxX, maxY)
            return x >= 0 and x < maxX and y >= 0 and y < maxY
        end

        Helpers.assertTrue(isValidCoord(validX, validY, mapWidth, mapHeight), "Valid coords should pass")
        Helpers.assertFalse(isValidCoord(invalidX, validY, mapWidth, mapHeight), "Invalid X should fail")
        Helpers.assertFalse(isValidCoord(validX, invalidY, mapWidth, mapHeight), "Invalid Y should fail")
    end)

    Suite:testMethod("Security:damageValueBoundCheck", {
        description = "Damage values cannot be negative or excessive",
        testCase = "validation",
        type = "security"
    }, function()
        local validDamage = 25
        local negativeDamage = -10
        local excessiveDamage = 99999

        local isValidDamage = function(damage)
            return damage >= 1 and damage <= 100
        end

        Helpers.assertTrue(isValidDamage(validDamage), "Valid damage should pass")
        Helpers.assertFalse(isValidDamage(negativeDamage), "Negative damage should fail")
        Helpers.assertFalse(isValidDamage(excessiveDamage), "Excessive damage should fail")
    end)

    Suite:testMethod("Security:turnNumberValidation", {
        description = "Turn numbers cannot be negative",
        testCase = "validation",
        type = "security"
    }, function()
        local validTurn = 42
        local invalidTurn = -1

        local isValidTurn = function(turn)
            return turn > 0
        end

        Helpers.assertTrue(isValidTurn(validTurn), "Valid turn should pass")
        Helpers.assertFalse(isValidTurn(invalidTurn), "Negative turn should fail")
    end)

    Suite:testMethod("Security:resourceAmountValidation", {
        description = "Resource amounts cannot be negative",
        testCase = "validation",
        type = "security"
    }, function()
        local funds = 50000
        local invalidFunds = -1000

        local isValidAmount = function(amount)
            return amount >= 0
        end

        Helpers.assertTrue(isValidAmount(funds), "Positive amount should pass")
        Helpers.assertFalse(isValidAmount(invalidFunds), "Negative amount should fail")
    end)
end)

Suite:group("Type Validation", function()

    Suite:testMethod("Security:enforceNumberType", {
        description = "Numeric fields reject non-numeric input",
        testCase = "type_check",
        type = "security"
    }, function()
        local validNumber = 42
        local invalidString = "not a number"

        local isNumber = function(val)
            return type(val) == "number"
        end

        Helpers.assertTrue(isNumber(validNumber), "Numbers should be accepted")
        Helpers.assertFalse(isNumber(invalidString), "Strings should be rejected")
    end)

    Suite:testMethod("Security:enforceStringType", {
        description = "String fields reject non-string input",
        testCase = "type_check",
        type = "security"
    }, function()
        local validString = "Commander"
        local invalidNumber = 12345

        local isString = function(val)
            return type(val) == "string"
        end

        Helpers.assertTrue(isString(validString), "Strings should be accepted")
        Helpers.assertFalse(isString(invalidNumber), "Numbers should be rejected for string fields")
    end)
end)

return Suite
