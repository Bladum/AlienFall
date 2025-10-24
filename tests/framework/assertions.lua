-- Test Framework: Assertion Library
-- Provides comprehensive assertions with descriptive error messages

local Assertions = {}

-- Global assertion counter
_G._assertion_count = 0
_G._assertion_failures = 0

---Helper function to get stack trace
local function getStackTrace(depth)
    depth = depth or 3
    local trace = debug.traceback("", depth)
    return trace
end

---Format a value for display
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

---Generic assertion handler
local function assert_impl(condition, message, level)
    level = level or 2
    _G._assertion_count = (_G._assertion_count or 0) + 1

    if not condition then
        _G._assertion_failures = (_G._assertion_failures or 0) + 1
        local stack = getStackTrace(level + 1)
        local err = message .. "\n" .. stack
        error(err, level + 1)
    end
end

---Assert values are equal
function Assertions.assertEqual(actual, expected, message)
    message = message or string.format("Expected %s, got %s", formatValue(expected), formatValue(actual))
    assert_impl(actual == expected, message, 2)
end

---Assert values are not equal
function Assertions.assertNotEqual(actual, expected, message)
    message = message or string.format("Expected not %s, got %s", formatValue(expected), formatValue(actual))
    assert_impl(actual ~= expected, message, 2)
end

---Assert condition is true
function Assertions.assertTrue(condition, message)
    message = message or "Expected condition to be true"
    assert_impl(condition == true, message, 2)
end

---Assert condition is false
function Assertions.assertFalse(condition, message)
    message = message or "Expected condition to be false"
    assert_impl(condition == false, message, 2)
end

---Assert value is nil
function Assertions.assertIsNil(value, message)
    message = message or string.format("Expected nil, got %s", formatValue(value))
    assert_impl(value == nil, message, 2)
end

---Assert value is not nil
function Assertions.assertIsNotNil(value, message)
    message = message or "Expected non-nil value"
    assert_impl(value ~= nil, message, 2)
end

---Assert value is a table
function Assertions.assertIsTable(value, message)
    message = message or string.format("Expected table, got %s", type(value))
    assert_impl(type(value) == "table", message, 2)
end

---Assert value is a function
function Assertions.assertIsFunction(value, message)
    message = message or string.format("Expected function, got %s", type(value))
    assert_impl(type(value) == "function", message, 2)
end

---Assert value is a string
function Assertions.assertIsString(value, message)
    message = message or string.format("Expected string, got %s", type(value))
    assert_impl(type(value) == "string", message, 2)
end

---Assert value is a number
function Assertions.assertIsNumber(value, message)
    message = message or string.format("Expected number, got %s", type(value))
    assert_impl(type(value) == "number", message, 2)
end

---Assert table contains value
function Assertions.assertContains(tbl, value, message)
    Assertions.assertIsTable(tbl, "First argument must be a table")
    local found = false
    for _, v in ipairs(tbl) do
        if v == value then
            found = true
            break
        end
    end
    message = message or string.format("Expected table to contain %s", formatValue(value))
    assert_impl(found, message, 2)
end

---Assert table does not contain value
function Assertions.assertNotContains(tbl, value, message)
    Assertions.assertIsTable(tbl, "First argument must be a table")
    local found = false
    for _, v in ipairs(tbl) do
        if v == value then
            found = true
            break
        end
    end
    message = message or string.format("Expected table to not contain %s", formatValue(value))
    assert_impl(not found, message, 2)
end

---Assert two tables are equal
function Assertions.assertTableEquals(tbl1, tbl2, message)
    Assertions.assertIsTable(tbl1, "First argument must be a table")
    Assertions.assertIsTable(tbl2, "Second argument must be a table")

    local function compare(t1, t2, visited)
        visited = visited or {}

        -- Avoid infinite recursion
        if visited[t1] then return true end
        visited[t1] = true

        -- Check keys match
        for k in pairs(t1) do
            if t2[k] == nil then return false end
        end
        for k in pairs(t2) do
            if t1[k] == nil then return false end
        end

        -- Check values match
        for k, v in pairs(t1) do
            if type(v) == "table" and type(t2[k]) == "table" then
                if not compare(v, t2[k], visited) then return false end
            elseif v ~= t2[k] then
                return false
            end
        end

        return true
    end

    local equal = compare(tbl1, tbl2)
    message = message or "Expected tables to be equal"
    assert_impl(equal, message, 2)
end

---Assert a > b
function Assertions.assertGreater(a, b, message)
    message = message or string.format("Expected %s > %s", formatValue(a), formatValue(b))
    assert_impl(a > b, message, 2)
end

---Assert a < b
function Assertions.assertLess(a, b, message)
    message = message or string.format("Expected %s < %s", formatValue(a), formatValue(b))
    assert_impl(a < b, message, 2)
end

---Assert a >= b
function Assertions.assertGreaterOrEqual(a, b, message)
    message = message or string.format("Expected %s >= %s", formatValue(a), formatValue(b))
    assert_impl(a >= b, message, 2)
end

---Assert a <= b
function Assertions.assertLessOrEqual(a, b, message)
    message = message or string.format("Expected %s <= %s", formatValue(a), formatValue(b))
    assert_impl(a <= b, message, 2)
end

---Assert string matches pattern
function Assertions.assertMatches(str, pattern, message)
    Assertions.assertIsString(str, "First argument must be a string")
    local match = string.match(str, pattern)
    message = message or string.format("Expected %s to match %s", formatValue(str), formatValue(pattern))
    assert_impl(match ~= nil, message, 2)
end

---Assert function throws error
function Assertions.assertThrows(fn, expectedError, message)
    Assertions.assertIsFunction(fn, "First argument must be a function")
    local success, err = pcall(fn)

    if success then
        message = message or string.format("Expected function to throw error")
        assert_impl(false, message, 2)
    end

    if expectedError then
        local match = tostring(err):find(tostring(expectedError), 1, true)
        message = message or string.format("Expected error to contain %s, got %s",
                                          formatValue(expectedError), formatValue(err))
        assert_impl(match ~= nil, message, 2)
    end
end

---Assert function does not throw error
function Assertions.assertDoesNotThrow(fn, message)
    Assertions.assertIsFunction(fn, "First argument must be a function")
    local success, err = pcall(fn)
    message = message or string.format("Expected function not to throw, but got: %s", tostring(err))
    assert_impl(success, message, 2)
end

---Assert value within range
function Assertions.assertInRange(value, minVal, maxVal, message)
    message = message or string.format("Expected %s to be between %s and %s",
                                      formatValue(value), formatValue(minVal), formatValue(maxVal))
    assert_impl(value >= minVal and value <= maxVal, message, 2)
end

---Assert table has key
function Assertions.assertHasKey(tbl, key, message)
    Assertions.assertIsTable(tbl, "First argument must be a table")
    message = message or string.format("Expected table to have key %s", formatValue(key))
    assert_impl(tbl[key] ~= nil, message, 2)
end

---Assert table does not have key
function Assertions.assertNotHasKey(tbl, key, message)
    Assertions.assertIsTable(tbl, "First argument must be a table")
    message = message or string.format("Expected table to not have key %s", formatValue(key))
    assert_impl(tbl[key] == nil, message, 2)
end

---Get assertion statistics
function Assertions.getStats()
    return {
        total = _G._assertion_count or 0,
        failures = _G._assertion_failures or 0,
        passed = (_G._assertion_count or 0) - (_G._assertion_failures or 0)
    }
end

---Reset assertion counters
function Assertions.resetStats()
    _G._assertion_count = 0
    _G._assertion_failures = 0
end

return Assertions
