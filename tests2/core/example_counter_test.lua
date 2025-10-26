-- ─────────────────────────────────────────────────────────────────────────
-- EXAMPLE TEST: Simple Counter Module
-- FILE: tests2/core/example_counter_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- This is a complete working example of hierarchical test structure
-- Can be used as template for other test files
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- Mock simple counter module for demonstration
local Counter = {
    value = 0
}

Counter.__index = Counter  -- Enable method lookups

function Counter:new()
    local self = setmetatable({}, Counter)
    self.value = 0
    return self
end

function Counter:increment()
    self.value = self.value + 1
    return self.value
end

function Counter:decrement()
    self.value = self.value - 1
    return self.value
end

function Counter:reset()
    self.value = 0
end

function Counter:getValue()
    return self.value
end

function Counter:addValue(amount)
    if type(amount) ~= "number" then
        error("Amount must be number")
    end
    self.value = self.value + amount
    return self.value
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "example.counter",
    fileName = "counter.lua",
    description = "Test suite for simple counter module"
})

-- Module-level setup (runs once before all tests)
Suite:before(function()
    print("[Counter] Setting up module-level fixtures")
end)

-- Module-level teardown (runs once after all tests)
Suite:after(function()
    print("[Counter] Cleaning up module-level fixtures")
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: INITIALIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Initialization", function()

    -- Per-test setup
    Suite:beforeEach(function()
        -- Reset any state before each test
    end)

    -- LEVEL 3: Test methods in "Initialization" group

    Suite:testMethod("Counter:new", {
        description = "Creates new counter instance",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local counter = Counter:new()

        -- Assertions
        assert(counter ~= nil, "Counter should be created")
        assert(type(counter) == "table", "Counter should be table")
        assert(counter.value == 0, "Initial value should be 0")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Counter:new", {
        description = "Initializes with zero value",
        testCase = "default_state",
        type = "functional"
    }, function()
        local counter = Counter:new()
        Helpers.assertEqual(counter:getValue(), 0, "Initial value should be 0")

        -- Removed manual print - framework handles this
    end)

end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: BASIC OPERATIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Basic Operations", function()

    -- Need to capture counter in closure for beforeEach
    local shared = {}

    Suite:beforeEach(function()
        shared.counter = Counter:new()
    end)

    -- LEVEL 3: Increment method tests

    Suite:testMethod("Counter:increment", {
        description = "Increments value by 1",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local counter = shared.counter
        local result = counter:increment()

        Helpers.assertEqual(result, 1, "Should return 1")
        Helpers.assertEqual(counter:getValue(), 1, "Value should be 1")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Counter:increment", {
        description = "Multiple increments stack",
        testCase = "multiple_calls",
        type = "functional"
    }, function()
        local counter = shared.counter
        counter:increment()
        counter:increment()
        counter:increment()

        Helpers.assertEqual(counter:getValue(), 3, "Value should be 3 after 3 increments")

        -- Removed manual print - framework handles this
    end)

    -- LEVEL 3: Decrement method tests

    Suite:testMethod("Counter:decrement", {
        description = "Decrements value by 1",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local counter = shared.counter
        counter:increment()
        counter:increment()

        local result = counter:decrement()

        Helpers.assertEqual(result, 1, "Should return 1")
        Helpers.assertEqual(counter:getValue(), 1, "Value should be 1")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Counter:decrement", {
        description = "Can decrement below zero",
        testCase = "edge_case",
        type = "functional"
    }, function()
        local counter = shared.counter
        counter:decrement()
        counter:decrement()

        Helpers.assertEqual(counter:getValue(), -2, "Value can go negative")

        -- Removed manual print - framework handles this
    end)

end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: ADVANCED OPERATIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Advanced Operations", function()

    -- Need to capture counter in closure for beforeEach
    local shared = {}

    Suite:beforeEach(function()
        shared.counter = Counter:new()
    end)

    -- LEVEL 3: Reset method tests

    Suite:testMethod("Counter:reset", {
        description = "Resets value to zero",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local counter = shared.counter
        counter:increment()
        counter:increment()
        counter:increment()

        counter:reset()

        Helpers.assertEqual(counter:getValue(), 0, "Value should be 0 after reset")

        -- Removed manual print - framework handles this
    end)

    -- LEVEL 3: AddValue method tests

    Suite:testMethod("Counter:addValue", {
        description = "Adds positive value",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local counter = shared.counter
        local result = counter:addValue(5)

        Helpers.assertEqual(result, 5, "Should return 5")
        Helpers.assertEqual(counter:getValue(), 5, "Value should be 5")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Counter:addValue", {
        description = "Adds negative value",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local counter = shared.counter
        counter:addValue(10)
        counter:addValue(-3)

        Helpers.assertEqual(counter:getValue(), 7, "Should be 10 - 3 = 7")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Counter:addValue", {
        description = "Throws on non-number input",
        testCase = "error_handling",
        type = "error_handling"
    }, function()
        local counter = shared.counter
        Helpers.assertThrows(function()
            counter:addValue("not a number")
        end, "must be number", "Should throw on string input")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Counter:addValue", {
        description = "Throws on nil input",
        testCase = "error_handling",
        type = "error_handling"
    }, function()
        local counter = shared.counter
        Helpers.assertThrows(function()
            counter:addValue(nil)
        end, "must be number", "Should throw on nil input")

        -- Removed manual print - framework handles this
    end)

end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

-- Return suite for execution
return Suite
