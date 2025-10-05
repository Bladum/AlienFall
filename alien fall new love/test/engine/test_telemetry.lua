--- Test suite for Telemetry
--
-- Tests the Telemetry functionality for event tracking and performance monitoring.
--
-- @module test.engine.test_telemetry

local test_framework = require "test.framework.test_framework"
local Telemetry = require "engine.telemetry"

local test_telemetry = {}

--- Run all Telemetry tests
function test_telemetry.run()
    test_framework.run_suite("Telemetry", {
        test_initialization = test_telemetry.test_initialization,
        test_enable_disable = test_telemetry.test_enable_disable,
        test_event_recording = test_telemetry.test_event_recording,
        test_history_limit = test_telemetry.test_history_limit,
        test_drain_functionality = test_telemetry.test_drain_functionality,
        test_timestamp_assignment = test_telemetry.test_timestamp_assignment
    })
end

--- Test Telemetry initialization
function test_telemetry.test_initialization()
    -- Test default initialization
    local telemetry = Telemetry.new()
    test_framework.assert_not_nil(telemetry)
    test_framework.assert_true(telemetry.enabled)
    test_framework.assert_equal(telemetry.historyLimit, 512)
    test_framework.assert_not_nil(telemetry.records)
    test_framework.assert_equal(#telemetry.records, 0)

    -- Test with custom options
    local telemetryWithOpts = Telemetry.new({
        enabled = false,
        historyLimit = 100
    })
    test_framework.assert_false(telemetryWithOpts.enabled)
    test_framework.assert_equal(telemetryWithOpts.historyLimit, 100)

    -- Test with enabled=true explicitly
    local telemetryEnabled = Telemetry.new({enabled = true})
    test_framework.assert_true(telemetryEnabled.enabled)
end

--- Test enable/disable functionality
function test_telemetry.test_enable_disable()
    local telemetry = Telemetry.new()

    -- Test initial state
    test_framework.assert_true(telemetry:isEnabled())

    -- Test disabling
    telemetry:setEnabled(false)
    test_framework.assert_false(telemetry:isEnabled())

    -- Test enabling
    telemetry:setEnabled(true)
    test_framework.assert_true(telemetry:isEnabled())

    -- Test setEnabled with falsy values
    telemetry:setEnabled(nil)
    test_framework.assert_false(telemetry:isEnabled())

    telemetry:setEnabled(0)
    test_framework.assert_false(telemetry:isEnabled())

    telemetry:setEnabled("")
    test_framework.assert_false(telemetry:isEnabled())
end

--- Test event recording
function test_telemetry.test_event_recording()
    local telemetry = Telemetry.new()

    -- Test recording when enabled
    local event1 = {type = "test", value = 42}
    telemetry:recordEvent(event1)
    test_framework.assert_equal(#telemetry.records, 1)
    test_framework.assert_equal(telemetry.records[1].type, "test")
    test_framework.assert_equal(telemetry.records[1].value, 42)
    test_framework.assert_not_nil(telemetry.records[1].timestamp)

    -- Test recording another event
    local event2 = {type = "another", data = "test"}
    telemetry:recordEvent(event2)
    test_framework.assert_equal(#telemetry.records, 2)
    test_framework.assert_equal(telemetry.records[2].type, "another")

    -- Test recording when disabled
    telemetry:setEnabled(false)
    local event3 = {type = "disabled", ignored = true}
    telemetry:recordEvent(event3)
    test_framework.assert_equal(#telemetry.records, 2) -- Should not have increased
end

--- Test history limit functionality
function test_telemetry.test_history_limit()
    local telemetry = Telemetry.new({historyLimit = 3})

    -- Add events up to the limit
    for i = 1, 3 do
        telemetry:recordEvent({type = "event", id = i})
    end
    test_framework.assert_equal(#telemetry.records, 3)

    -- Add one more - should trigger pruning
    telemetry:recordEvent({type = "event", id = 4})
    test_framework.assert_equal(#telemetry.records, 3)
    test_framework.assert_equal(telemetry.records[1].id, 2) -- First event should be removed
    test_framework.assert_equal(telemetry.records[2].id, 3)
    test_framework.assert_equal(telemetry.records[3].id, 4)

    -- Test with default limit
    local defaultTelemetry = Telemetry.new()
    for i = 1, 513 do
        defaultTelemetry:recordEvent({type = "event", id = i})
    end
    test_framework.assert_equal(#defaultTelemetry.records, 512) -- Should be limited to 512
    test_framework.assert_equal(defaultTelemetry.records[1].id, 2) -- First should be pruned
end

--- Test drain functionality
function test_telemetry.test_drain_functionality()
    local telemetry = Telemetry.new()

    -- Add some events
    telemetry:recordEvent({type = "event1"})
    telemetry:recordEvent({type = "event2"})
    telemetry:recordEvent({type = "event3"})
    test_framework.assert_equal(#telemetry.records, 3)

    -- Drain the events
    local snapshot = telemetry:drain()
    test_framework.assert_equal(#snapshot, 3)
    test_framework.assert_equal(snapshot[1].type, "event1")
    test_framework.assert_equal(snapshot[2].type, "event2")
    test_framework.assert_equal(snapshot[3].type, "event3")

    -- Records should be cleared
    test_framework.assert_equal(#telemetry.records, 0)

    -- Draining again should return empty array
    local emptySnapshot = telemetry:drain()
    test_framework.assert_equal(#emptySnapshot, 0)
end

--- Test timestamp assignment
function test_telemetry.test_timestamp_assignment()
    local telemetry = Telemetry.new()

    -- Mock love.timer.getTime
    local mockTime = 123.456
    local originalLove = love
    love = {
        timer = {
            getTime = function() return mockTime end
        }
    }

    -- Record event with mocked timer
    telemetry:recordEvent({type = "timed_event"})
    test_framework.assert_equal(telemetry.records[1].timestamp, mockTime)

    -- Test fallback to os.clock when love.timer not available
    love = nil
    telemetry:drain() -- Clear previous records
    telemetry:recordEvent({type = "fallback_event"})
    test_framework.assert_not_nil(telemetry.records[1].timestamp)
    test_framework.assert_equal(type(telemetry.records[1].timestamp), "number")

    -- Restore original love
    love = originalLove
end

return test_telemetry