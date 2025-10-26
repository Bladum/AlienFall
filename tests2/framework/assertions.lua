-- ─────────────────────────────────────────────────────────────────────────
-- HIERARCHICAL TEST ASSERTIONS
-- Assertion library for tests2 framework with HierarchicalSuite integration
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Provide comprehensive assertions with clear error messages
-- Usage:
--   local assert = require("tests2.framework.assertions")
--   assert.assertEqual(actual, expected, "Error message")
--   assert.assertThrows(function() ... end, "Expected error pattern", "msg")
-- ─────────────────────────────────────────────────────────────────────────

local Assertions = {}

-- ─────────────────────────────────────────────────────────────────────────
-- UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Format a value for display in error messages
---@param v any - value to format
---@return string - formatted representation
local function formatValue(v)
    if v == nil then
        return "nil"
    elseif type(v) == "boolean" then
        return tostring(v)
    elseif type(v) == "number" then
        return tostring(v)
    elseif type(v) == "string" then
        return '"' .. v .. '"'
    elseif type(v) == "table" then
        local count = 0
        for _ in pairs(v) do count = count + 1 end
        return "{table: " .. count .. " items}"
    elseif type(v) == "function" then
        return "[function]"
    else
        return "[" .. type(v) .. "]"
    end
end

---Format a table for detailed display
---@param t table - table to format
---@param depth number - current recursion depth
---@return string - formatted representation
local function formatTable(t, depth)
    depth = depth or 0
    if depth > 3 then return "{...}" end

    local indent = string.rep("  ", depth)
    local result = "{\n"

    for k, v in pairs(t) do
        result = result .. indent .. "  " .. tostring(k) .. " = "
        if type(v) == "table" then
            result = result .. formatTable(v, depth + 1)
        else
            result = result .. formatValue(v)
        end
        result = result .. "\n"
    end

    result = result .. indent .. "}"
    return result
end

---Get concise stack trace for error reporting
---@param depth number - stack depth to start from
---@return string - stack trace
local function getStackTrace(depth)
    depth = depth or 3
    local info = debug.getinfo(depth, "Sl")
    if info then
        return string.format("at %s:%d", info.source, info.currentline)
    end
    return "unknown location"
end

-- ─────────────────────────────────────────────────────────────────────────
-- CORE ASSERTION FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Core assertion implementation
---@param condition boolean - condition to test
---@param message string - error message if condition fails
local function assert_impl(condition, message)
    if not condition then
        error(message, 3)
    end
end

---Assert values are equal
---@param actual any - actual value
---@param expected any - expected value
---@param message string - optional error message
function Assertions.assertEqual(actual, expected, message)
    if actual ~= expected then
        message = message or ""
        local errorMsg = string.format(
            "Assertion Failed: assertEqual\n" ..
            "  Expected: %s\n" ..
            "  Actual:   %s\n" ..
            "%s",
            formatValue(expected),
            formatValue(actual),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert values are not equal
---@param actual any - actual value
---@param notExpected any - value that should not equal
---@param message string - optional error message
function Assertions.assertNotEqual(actual, notExpected, message)
    if actual == notExpected then
        message = message or ""
        local errorMsg = string.format(
            "Assertion Failed: assertNotEqual\n" ..
            "  Should not be: %s\n" ..
            "  But was:       %s\n" ..
            "%s",
            formatValue(notExpected),
            formatValue(actual),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert condition is true
---@param condition boolean - condition to test
---@param message string - optional error message
function Assertions.assertTrue(condition, message)
    message = message or "Expected condition to be true"
    if condition ~= true then
        error("Assertion Failed: assertTrue\n  " .. message, 2)
    end
end

---Assert condition is false
---@param condition boolean - condition to test
---@param message string - optional error message
function Assertions.assertFalse(condition, message)
    message = message or "Expected condition to be false"
    if condition ~= false then
        error("Assertion Failed: assertFalse\n  " .. message, 2)
    end
end

---Assert value is nil
---@param value any - value to test
---@param message string - optional error message
function Assertions.assertNil(value, message)
    message = message or ""
    if value ~= nil then
        local errorMsg = string.format(
            "Assertion Failed: assertNil\n" ..
            "  Expected: nil\n" ..
            "  Got:      %s\n" ..
            "%s",
            formatValue(value),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert value is not nil
---@param value any - value to test
---@param message string - optional error message
function Assertions.assertNotNil(value, message)
    message = message or "Expected non-nil value"
    if value == nil then
        error("Assertion Failed: assertNotNil\n  " .. message, 2)
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- TYPE ASSERTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Assert value is a table
---@param value any - value to test
---@param message string - optional error message
function Assertions.assertTable(value, message)
    message = message or ""
    if type(value) ~= "table" then
        local errorMsg = string.format(
            "Assertion Failed: assertTable\n" ..
            "  Expected: table\n" ..
            "  Got:      %s\n" ..
            "%s",
            type(value),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert value is a function
---@param value any - value to test
---@param message string - optional error message
function Assertions.assertFunction(value, message)
    message = message or ""
    if type(value) ~= "function" then
        local errorMsg = string.format(
            "Assertion Failed: assertFunction\n" ..
            "  Expected: function\n" ..
            "  Got:      %s\n" ..
            "%s",
            type(value),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert value is a string
---@param value any - value to test
---@param message string - optional error message
function Assertions.assertString(value, message)
    message = message or ""
    if type(value) ~= "string" then
        local errorMsg = string.format(
            "Assertion Failed: assertString\n" ..
            "  Expected: string\n" ..
            "  Got:      %s\n" ..
            "%s",
            type(value),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert value is a number
---@param value any - value to test
---@param message string - optional error message
function Assertions.assertNumber(value, message)
    message = message or ""
    if type(value) ~= "number" then
        local errorMsg = string.format(
            "Assertion Failed: assertNumber\n" ..
            "  Expected: number\n" ..
            "  Got:      %s\n" ..
            "%s",
            type(value),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert value is a boolean
---@param value any - value to test
---@param message string - optional error message
function Assertions.assertBoolean(value, message)
    message = message or ""
    if type(value) ~= "boolean" then
        local errorMsg = string.format(
            "Assertion Failed: assertBoolean\n" ..
            "  Expected: boolean\n" ..
            "  Got:      %s\n" ..
            "%s",
            type(value),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- EXCEPTION ASSERTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Assert that function throws an error matching pattern
---@param fn function - function to test
---@param pattern string - error message pattern to match (optional)
---@param message string - optional error message
function Assertions.assertThrows(fn, pattern, message)
    pattern = pattern or ".*"  -- Match any error if no pattern
    message = message or ""

    local ok, result = pcall(fn)

    if ok then
        local errorMsg = string.format(
            "Assertion Failed: assertThrows\n" ..
            "  Expected: function to throw error\n" ..
            "  But:      function returned normally\n" ..
            "%s",
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end

    -- Check if error matches pattern
    if pattern ~= ".*" and not string.find(tostring(result), pattern) then
        local errorMsg = string.format(
            "Assertion Failed: assertThrows (pattern mismatch)\n" ..
            "  Expected pattern: %s\n" ..
            "  Actual error:     %s\n" ..
            "%s",
            pattern,
            tostring(result),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert that function does not throw an error
---@param fn function - function to test
---@param message string - optional error message
function Assertions.assertNoThrow(fn, message)
    message = message or ""

    local ok, result = pcall(fn)

    if not ok then
        local errorMsg = string.format(
            "Assertion Failed: assertNoThrow\n" ..
            "  Expected: function to not throw error\n" ..
            "  But error was:    %s\n" ..
            "%s",
            tostring(result),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- TABLE ASSERTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Assert table contains a value
---@param tbl table - table to search
---@param value any - value to find
---@param message string - optional error message
function Assertions.assertContains(tbl, value, message)
    message = message or ""
    Assertions.assertTable(tbl, "First argument must be a table")

    for _, v in ipairs(tbl) do
        if v == value then
            return  -- Found
        end
    end

    local errorMsg = string.format(
        "Assertion Failed: assertContains\n" ..
        "  Table does not contain: %s\n" ..
        "  Table contains %d items\n" ..
        "%s",
        formatValue(value),
        #tbl,
        message ~= "" and "  Message: " .. message or ""
    )
    error(errorMsg, 2)
end

---Assert table does not contain a value
---@param tbl table - table to search
---@param value any - value to find
---@param message string - optional error message
function Assertions.assertNotContains(tbl, value, message)
    message = message or ""
    Assertions.assertTable(tbl, "First argument must be a table")

    for _, v in ipairs(tbl) do
        if v == value then
            local errorMsg = string.format(
                "Assertion Failed: assertNotContains\n" ..
                "  Table should not contain: %s\n" ..
                "%s",
                formatValue(value),
                message ~= "" and "  Message: " .. message or ""
            )
            error(errorMsg, 2)
        end
    end
end

---Assert table has key
---@param tbl table - table to check
---@param key string|number - key to find
---@param message string - optional error message
function Assertions.assertHasKey(tbl, key, message)
    message = message or ""
    Assertions.assertTable(tbl, "First argument must be a table")

    if tbl[key] == nil then
        local errorMsg = string.format(
            "Assertion Failed: assertHasKey\n" ..
            "  Table missing key: %s\n" ..
            "%s",
            formatValue(key),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert table has expected size
---@param tbl table - table to check
---@param expectedSize number - expected size
---@param message string - optional error message
function Assertions.assertSize(tbl, expectedSize, message)
    message = message or ""
    Assertions.assertTable(tbl, "First argument must be a table")

    local actualSize = 0
    for _ in pairs(tbl) do actualSize = actualSize + 1 end

    if actualSize ~= expectedSize then
        local errorMsg = string.format(
            "Assertion Failed: assertSize\n" ..
            "  Expected size: %d\n" ..
            "  Actual size:   %d\n" ..
            "%s",
            expectedSize,
            actualSize,
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- NUMERIC ASSERTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Assert number is greater than threshold
---@param actual number - value to test
---@param threshold number - minimum value
---@param message string - optional error message
function Assertions.assertGreater(actual, threshold, message)
    message = message or ""
    if actual <= threshold then
        local errorMsg = string.format(
            "Assertion Failed: assertGreater\n" ..
            "  Expected: > %s\n" ..
            "  Got:      %s\n" ..
            "%s",
            formatValue(threshold),
            formatValue(actual),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert number is less than threshold
---@param actual number - value to test
---@param threshold number - maximum value
---@param message string - optional error message
function Assertions.assertLess(actual, threshold, message)
    message = message or ""
    if actual >= threshold then
        local errorMsg = string.format(
            "Assertion Failed: assertLess\n" ..
            "  Expected: < %s\n" ..
            "  Got:      %s\n" ..
            "%s",
            formatValue(threshold),
            formatValue(actual),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert number is approximately equal
---@param actual number - actual value
---@param expected number - expected value
---@param tolerance number - acceptable difference
---@param message string - optional error message
function Assertions.assertApprox(actual, expected, tolerance, message)
    message = message or ""
    tolerance = tolerance or 0.001

    if math.abs(actual - expected) > tolerance then
        local errorMsg = string.format(
            "Assertion Failed: assertApprox\n" ..
            "  Expected: %s (±%s)\n" ..
            "  Got:      %s\n" ..
            "%s",
            formatValue(expected),
            formatValue(tolerance),
            formatValue(actual),
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- STRING ASSERTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Assert string matches pattern
---@param str string - string to test
---@param pattern string - Lua pattern to match
---@param message string - optional error message
function Assertions.assertMatches(str, pattern, message)
    message = message or ""
    Assertions.assertString(str, "First argument must be a string")

    if not string.find(str, pattern) then
        local errorMsg = string.format(
            "Assertion Failed: assertMatches\n" ..
            "  Expected pattern: %s\n" ..
            "  String: %s\n" ..
            "%s",
            pattern,
            str,
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

---Assert string does not match pattern
---@param str string - string to test
---@param pattern string - Lua pattern to not match
---@param message string - optional error message
function Assertions.assertNotMatches(str, pattern, message)
    message = message or ""
    Assertions.assertString(str, "First argument must be a string")

    if string.find(str, pattern) then
        local errorMsg = string.format(
            "Assertion Failed: assertNotMatches\n" ..
            "  Should not match: %s\n" ..
            "  String: %s\n" ..
            "%s",
            pattern,
            str,
            message ~= "" and "  Message: " .. message or ""
        )
        error(errorMsg, 2)
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- FAIL ASSERTION (for manual test failures)
-- ─────────────────────────────────────────────────────────────────────────

---Unconditionally fail test with message
---@param message string - error message
function Assertions.fail(message)
    message = message or "Test failed"
    error("Assertion Failed: " .. message, 2)
end

-- ─────────────────────────────────────────────────────────────────────────
-- BATCH ASSERTIONS (for fluent API support)
-- ─────────────────────────────────────────────────────────────────────────

---Create a batch assertion context for fluent API
---@param value any - initial value to test
---@return table - context object with fluent methods
function Assertions.assert(value)
    return {
        value = value,
        eq = function(self, expected, msg)
            Assertions.assertEqual(self.value, expected, msg)
            return self
        end,
        neq = function(self, notExpected, msg)
            Assertions.assertNotEqual(self.value, notExpected, msg)
            return self
        end,
        truthy = function(self, msg)
            Assertions.assertTrue(self.value, msg)
            return self
        end,
        falsy = function(self, msg)
            Assertions.assertFalse(self.value, msg)
            return self
        end,
        nil_val = function(self, msg)
            Assertions.assertNil(self.value, msg)
            return self
        end,
        notnull = function(self, msg)
            Assertions.assertNotNil(self.value, msg)
            return self
        end
    }
end

return Assertions
