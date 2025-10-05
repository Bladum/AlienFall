--- Test suite for EventBus
--
-- Tests the EventBus functionality for event subscription, publishing, and management.
--
-- @module test.engine.test_event_bus

local test_framework = require "test.framework.test_framework"
local EventBus = require "engine.event_bus"

local test_event_bus = {}

--- Run all EventBus tests
function test_event_bus.run()
    test_framework.run_suite("EventBus", {
        test_initialization = test_event_bus.test_initialization,
        test_subscribe_unsubscribe = test_event_bus.test_subscribe_unsubscribe,
        test_publish_events = test_event_bus.test_publish_events,
        test_once_handlers = test_event_bus.test_once_handlers,
        test_priority_ordering = test_event_bus.test_priority_ordering,
        test_error_handling = test_event_bus.test_error_handling
    })
end

--- Test EventBus initialization
function test_event_bus.test_initialization()
    local bus = EventBus.new()

    test_framework.assert_not_nil(bus)
    test_framework.assert_equal(type(bus.listeners), "table")
    test_framework.assert_equal(bus.nextId, 1)
end

--- Test subscribe and unsubscribe functionality
function test_event_bus.test_subscribe_unsubscribe()
    local bus = EventBus.new()
    local callCount = 0

    local function handler() callCount = callCount + 1 end

    -- Test subscribe
    local token = bus:subscribe("test_topic", handler)
    test_framework.assert_not_nil(token)
    test_framework.assert_equal(type(token), "number")

    -- Test that listener is registered
    test_framework.assert_not_nil(bus.listeners["test_topic"])
    test_framework.assert_equal(#bus.listeners["test_topic"], 1)

    -- Test unsubscribe
    local unsubscribed = bus:unsubscribe("test_topic", token)
    test_framework.assert_equal(unsubscribed, true)

    -- Test that listener is removed
    test_framework.assert_equal(#bus.listeners["test_topic"], 0)
end

--- Test event publishing
function test_event_bus.test_publish_events()
    local bus = EventBus.new()
    local callCount = 0
    local receivedData = nil

    local function handler(data)
        callCount = callCount + 1
        receivedData = data
    end

    bus:subscribe("test_event", handler)

    -- Test publish without data
    bus:publish("test_event")
    test_framework.assert_equal(callCount, 1)
    test_framework.assert_nil(receivedData)

    -- Test publish with data
    bus:publish("test_event", {message = "hello"})
    test_framework.assert_equal(callCount, 2)
    test_framework.assert_not_nil(receivedData)
    if receivedData then
        test_framework.assert_equal(receivedData.message, "hello")
    end
end

--- Test once handlers
function test_event_bus.test_once_handlers()
    local bus = EventBus.new()
    local callCount = 0

    local function handler() callCount = callCount + 1 end

    bus:subscribe("once_event", handler, {once = true})

    -- First publish should trigger handler
    bus:publish("once_event")
    test_framework.assert_equal(callCount, 1)

    -- Second publish should not trigger handler (already unsubscribed)
    bus:publish("once_event")
    test_framework.assert_equal(callCount, 1)
end

--- Test priority ordering
function test_event_bus.test_priority_ordering()
    local bus = EventBus.new()
    local callOrder = {}

    local function handler1() table.insert(callOrder, 1) end
    local function handler2() table.insert(callOrder, 2) end
    local function handler3() table.insert(callOrder, 3) end

    -- Subscribe with different priorities (higher priority = called first)
    bus:subscribe("priority_event", handler1, {priority = 1})
    bus:subscribe("priority_event", handler2, {priority = 5}) -- Higher priority
    bus:subscribe("priority_event", handler3, {priority = 1})

    bus:publish("priority_event")

    -- Handler2 should be called first (highest priority), then handlers 1 and 3
    test_framework.assert_equal(#callOrder, 3)
    test_framework.assert_equal(callOrder[1], 2)
    test_framework.assert_equal(callOrder[2], 1)
    test_framework.assert_equal(callOrder[3], 3)
end

--- Test error handling
function test_event_bus.test_error_handling()
    local bus = EventBus.new()

    -- Test valid subscription works
    local token = bus:subscribe("valid_topic", function() end)
    test_framework.assert_not_nil(token)
    test_framework.assert_equal(type(token), "number")

    -- Test unsubscribe with valid parameters works
    local success = bus:unsubscribe("valid_topic", token)
    test_framework.assert_true(success)

    -- Test unsubscribe with non-existent topic/token (should return false, not crash)
    local result1 = bus:unsubscribe("nonexistent_topic", 999)
    test_framework.assert_false(result1)

    -- Test that the system remains functional after operations
    local token2 = bus:subscribe("another_topic", function() end)
    test_framework.assert_not_nil(token2)
end

return test_event_bus