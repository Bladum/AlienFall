--- Test Framework for Alien Fall
--
-- Wrapper around lust.lua testing framework with compatibility layer.
-- Provides both lust API and legacy compatibility functions.
--
-- @module test_framework

local lust = require "lust"

-- Create compatibility layer
local test_framework = {}

-- Expose lust API directly
test_framework.describe = lust.describe
test_framework.it = lust.it
test_framework.expect = lust.expect
test_framework.before = lust.before
test_framework.after = lust.after
test_framework.spy = lust.spy

-- Legacy compatibility functions
test_framework.results = {
    passed = 0,
    failed = 0,
    total = 0,
    failures = {},
    tests = {} -- Buffer for TAP output
}

--- Assert that two values are equal (legacy compatibility)
-- @param actual any: The actual value
-- @param expected any: The expected value
-- @param message string: Optional custom message
function test_framework.assert_equal(actual, expected, message)
    if actual ~= expected then
        local msg = message or string.format("Expected %s, got %s", tostring(expected), tostring(actual))
        error(msg, 2)
    end
end

--- Assert that a value is true (legacy compatibility)
-- @param value any: The value to check
-- @param message string: Optional custom message
function test_framework.assert_true(value, message)
    if not value then
        local msg = message or "Expected true, got false"
        error(msg, 2)
    end
end

--- Assert that a value is false (legacy compatibility)
-- @param value any: The value to check
-- @param message string: Optional custom message
function test_framework.assert_false(value, message)
    if value then
        local msg = message or "Expected false, got true"
        error(msg, 2)
    end
end

--- Assert that a value is not nil (legacy compatibility)
-- @param value any: The value to check
-- @param message string: Optional custom message
function test_framework.assert_not_nil(value, message)
    if value == nil then
        local msg = message or "Expected non-nil value, got nil"
        error(msg, 2)
    end
end

--- Assert that a value is nil (legacy compatibility)
-- @param value any: The value to check
-- @param message string: Optional custom message
function test_framework.assert_nil(value, message)
    if value ~= nil then
        local msg = message or string.format("Expected nil, got %s", tostring(value))
        error(msg, 2)
    end
end

--- Assert that two tables are equal (legacy compatibility)
-- @param actual table: The actual table
-- @param expected table: The expected table
-- @param message string: Optional custom message
function test_framework.assert_table_equal(actual, expected, message)
    if type(actual) ~= "table" or type(expected) ~= "table" then
        local msg = message or "Both arguments must be tables"
        error(msg, 2)
    end

    -- Check lengths
    if #actual ~= #expected then
        local msg = message or string.format("Table lengths differ: expected %d, got %d", #expected, #actual)
        error(msg, 2)
    end

    -- Check array part
    for i = 1, #actual do
        if actual[i] ~= expected[i] then
            local msg = message or string.format("Tables differ at index %d: expected %s, got %s", i, tostring(expected[i]), tostring(actual[i]))
            error(msg, 2)
        end
    end

    -- Check hash part
    for k, v in pairs(actual) do
        if type(k) ~= "number" or k > #actual or k < 1 then
            if expected[k] ~= v then
                local msg = message or string.format("Tables differ at key %s: expected %s, got %s", tostring(k), tostring(expected[k]), tostring(v))
                error(msg, 2)
            end
        end
    end

    for k, v in pairs(expected) do
        if type(k) ~= "number" or k > #expected or k < 1 then
            if actual[k] ~= v then
                local msg = message or string.format("Tables differ at key %s: expected %s, got %s", tostring(k), tostring(expected[k]), tostring(v))
                error(msg, 2)
            end
        end
    end
end

--- Run a single test (legacy compatibility)
-- @param name string: Test name
-- @param test_func function: Test function
function test_framework.run_test(name, test_func)
    test_framework.results.total = test_framework.results.total + 1

    local success, err = pcall(test_func)
    if success then
        test_framework.results.passed = test_framework.results.passed + 1
        table.insert(test_framework.results.tests, {name = name, success = true})
    else
        test_framework.results.failed = test_framework.results.failed + 1
        test_framework.results.failures[#test_framework.results.failures + 1] = {
            name = name,
            error = err
        }
        table.insert(test_framework.results.tests, {name = name, success = false, error = err})
    end
end

--- Run a test suite (legacy compatibility)
-- @param suite_name string: Suite name
-- @param tests table: Table of test functions keyed by name
function test_framework.run_suite(suite_name, tests)
    print(string.format("# %s", suite_name))

    for test_name, test_func in pairs(tests) do
        test_framework.run_test(string.format("%s.%s", suite_name, test_name), test_func)
    end
end

--- Print test results summary (legacy compatibility)
function test_framework.print_summary()
    -- Custom test reporting with clear, readable output
    print("\n" .. string.rep("=", 60))
    print("ALIEN FALL TEST RESULTS")
    print(string.rep("=", 60))

    print(string.format("Total Tests: %d", test_framework.results.total))
    print(string.format("Passed: %d", test_framework.results.passed))
    print(string.format("Failed: %d", test_framework.results.failed))
    print(string.format("Success Rate: %.1f%%", (test_framework.results.passed / test_framework.results.total) * 100))

    if #test_framework.results.failures > 0 then
        print("\n" .. string.rep("-", 60))
        print("FAILURE DETAILS")
        print(string.rep("-", 60))

        for i, failure in ipairs(test_framework.results.failures) do
            print(string.format("\n%d. %s", i, failure.name))
            print(string.format("   %s", failure.error))

            -- Try to extract file and line info from error
            local file, line = failure.error:match("([^:]+):(%d+)")
            if file and line then
                print(string.format("   File: %s, Line: %s", file, line))
            end
        end
    end

    print("\n" .. string.rep("=", 60))

    if test_framework.results.failed == 0 then
        print("ALL TESTS PASSED!")
    else
        print("SOME TESTS FAILED - Check details above")
    end

    print(string.rep("=", 60))

    -- Print lust summary too
    if lust.passes > 0 or lust.errors > 0 then
        print(string.format("\n📋 Lust Framework: %d passes, %d errors", lust.passes, lust.errors))
    end
end

--- Reset test results (legacy compatibility)
function test_framework.reset()
    test_framework.results = {
        passed = 0,
        failed = 0,
        total = 0,
        failures = {},
        tests = {}
    }
    -- Reset lust counters too
    lust.passes = 0
    lust.errors = 0
end

--- Dump function for debugging (legacy compatibility)
function test_framework.dump(value)
    if type(value) == "table" then
        local parts = {}
        for k, v in pairs(value) do
            table.insert(parts, string.format("%s=%s", tostring(k), tostring(v)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    else
        return tostring(value)
    end
end

return test_framework