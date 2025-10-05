--- Test suite for Turn Manager
--
-- Tests the TurnManager functionality for turn progression and state management.
--
-- @module test.engine.test_turn_manager

local test_framework = require "test.framework.test_framework"
local TurnManager = require "engine.turn_manager"

local test_turn_manager = {}

--- Run all Turn Manager tests
function test_turn_manager.run()
    test_framework.run_suite("Turn Manager", {
        test_initialization = test_turn_manager.test_initialization,
        test_date_management = test_turn_manager.test_date_management,
        test_calendar_advancement = test_turn_manager.test_calendar_advancement,
        test_absolute_day_calculation = test_turn_manager.test_absolute_day_calculation,
        test_event_scheduling = test_turn_manager.test_event_scheduling,
        test_turn_advancement = test_turn_manager.test_turn_advancement,
        test_queue_processing = test_turn_manager.test_queue_processing,
        test_event_bus_integration = test_turn_manager.test_event_bus_integration,
        test_telemetry_integration = test_turn_manager.test_telemetry_integration
    })
end

--- Test TurnManager initialization
function test_turn_manager.test_initialization()
    local tm = TurnManager.new()

    test_framework.assert_not_nil(tm)
    test_framework.assert_not_nil(tm.current)
    test_framework.assert_equal(tm.current.year, 2047)
    test_framework.assert_equal(tm.current.quarter, 1)
    test_framework.assert_equal(tm.current.month, 1)
    test_framework.assert_equal(tm.current.week, 1)
    test_framework.assert_equal(tm.current.day, 1)
    test_framework.assert_equal(tm.absolute, 737281) -- Calculated absolute day for new calendar
    test_framework.assert_not_nil(tm.queue)
    test_framework.assert_equal(#tm.queue, 0)
    test_framework.assert_equal(tm.turnCount, 0)
    test_framework.assert_nil(tm.eventBus)
    test_framework.assert_nil(tm.telemetry)

    -- Test with options
    local mockBus = {}
    local mockTelemetry = {}
    local tmWithOpts = TurnManager.new({
        eventBus = mockBus,
        telemetry = mockTelemetry
    })
    test_framework.assert_equal(tmWithOpts.eventBus, mockBus)
    test_framework.assert_equal(tmWithOpts.telemetry, mockTelemetry)
end

--- Test date management
function test_turn_manager.test_date_management()
    local tm = TurnManager.new()

    -- Test getDate returns a copy
    local date1 = tm:getDate()
    local date2 = tm:getDate()
    test_framework.assert_not_equal(date1, date2) -- Different table instances
    test_framework.assert_equal(date1.year, date2.year)

    -- Test setDate
    tm:setDate(2024, 2, 3, 4, 5)
    local newDate = tm:getDate()
    test_framework.assert_equal(newDate.year, 2024)
    test_framework.assert_equal(newDate.quarter, 2)
    test_framework.assert_equal(newDate.month, 3)
    test_framework.assert_equal(newDate.week, 4)
    test_framework.assert_equal(newDate.day, 5)
    test_framework.assert_equal(tm.turnCount, 0) -- Should reset turn count
end

--- Test calendar advancement logic
function test_turn_manager.test_calendar_advancement()
    local tm = TurnManager.new()
    tm:setDate(2024, 1, 1, 1, 6) -- End of first week

    -- Advance one day - should go to week 2, day 1
    tm:advance(1)
    local date = tm:getDate()
    test_framework.assert_equal(date.year, 2024)
    test_framework.assert_equal(date.quarter, 1)
    test_framework.assert_equal(date.month, 1)
    test_framework.assert_equal(date.week, 2)
    test_framework.assert_equal(date.day, 1)

    -- Advance to end of month (5 weeks = 30 days)
    tm:advance(29) -- 30 days total from start
    date = tm:getDate()
    test_framework.assert_equal(date.month, 1)
    test_framework.assert_equal(date.week, 5)
    test_framework.assert_equal(date.day, 6)

    -- Advance one more day - should go to month 2
    tm:advance(1)
    date = tm:getDate()
    test_framework.assert_equal(date.month, 2)
    test_framework.assert_equal(date.week, 1)
    test_framework.assert_equal(date.day, 1)
end

--- Test absolute day calculation
function test_turn_manager.test_absolute_day_calculation()
    local tm = TurnManager.new()

    -- Test initial absolute day
    test_framework.assert_equal(tm:getAbsoluteDay(), 737281)

    -- Test after setting date
    tm:setDate(2024, 1, 1, 1, 1)
    local expected = (2024 * 360) + ((1 - 1) * 90) + ((1 - 1) * 30) + ((1 - 1) * 6) + 1
    test_framework.assert_equal(tm:getAbsoluteDay(), expected)

    -- Test after advancement
    tm:advance(1)
    test_framework.assert_equal(tm:getAbsoluteDay(), expected + 1)
end

--- Test event scheduling
function test_turn_manager.test_event_scheduling()
    local tm = TurnManager.new()
    tm:setDate(2024, 1, 1)

    -- Test scheduling an event
    local entry = tm:schedule(5, "test_event", {data = "test"})
    test_framework.assert_not_nil(entry)
    test_framework.assert_equal(entry.trigger, tm:getAbsoluteDay() + 5)
    test_framework.assert_equal(entry.topic, "test_event")
    test_framework.assert_equal(entry.payload.data, "test")
    test_framework.assert_equal(#tm.queue, 1)

    -- Test scheduling another event
    tm:schedule(3, "another_event", {value = 42})
    test_framework.assert_equal(#tm.queue, 2)

    -- Queue should be sorted by trigger time
    test_framework.assert_equal(tm.queue[1].topic, "another_event") -- Earlier trigger
    test_framework.assert_equal(tm.queue[2].topic, "test_event") -- Later trigger
end

--- Test turn advancement
function test_turn_manager.test_turn_advancement()
    local tm = TurnManager.new()
    tm:setDate(2024, 1, 1)

    -- Test single day advancement
    tm:advance(1)
    test_framework.assert_equal(tm.turnCount, 1)
    local date = tm:getDate()
    test_framework.assert_equal(date.year, 2024)
    test_framework.assert_equal(date.month, 1)
    test_framework.assert_equal(date.day, 2)

    -- Test multiple day advancement
    tm:advance(5)
    test_framework.assert_equal(tm.turnCount, 6)
    date = tm:getDate()
    test_framework.assert_equal(date.day, 7)
end

--- Test queue processing
function test_turn_manager.test_queue_processing()
    local tm = TurnManager.new()
    tm:setDate(2024, 1, 1)

    -- Schedule events at different times
    tm:schedule(1, "event1", {id = 1}) -- Tomorrow
    tm:schedule(3, "event2", {id = 2}) -- 3 days from now
    tm:schedule(2, "event3", {id = 3}) -- 2 days from now

    -- Advance 1 day - should trigger event1
    tm:advance(1)
    test_framework.assert_equal(#tm.queue, 2) -- event1 should be processed and removed

    -- Advance another day - should trigger event3
    tm:advance(1)
    test_framework.assert_equal(#tm.queue, 1) -- event3 should be processed

    -- Advance another day - should trigger event2
    tm:advance(1)
    test_framework.assert_equal(#tm.queue, 0) -- event2 should be processed
end

--- Test EventBus integration
function test_turn_manager.test_event_bus_integration()
    local events = {}
    local mockBus = {
        publish = function(self, topic, payload)
            table.insert(events, {topic = topic, payload = payload})
        end
    }

    local tm = TurnManager.new({eventBus = mockBus})
    tm:setDate(2024, 1, 1)

    -- Advance a day - should publish day_advanced event
    tm:advance(1)
    test_framework.assert_true(#events >= 1)
    test_framework.assert_equal(events[1].topic, "time:day_advanced")
    test_framework.assert_not_nil(events[1].payload.date)
    test_framework.assert_equal(events[1].payload.turn, 1)

    -- Clear events and schedule an event
    events = {}
    tm:schedule(1, "scheduled_event", {test = true})
    tm:advance(1)

    -- Should have both day_advanced and scheduled events
    test_framework.assert_true(#events >= 2)
    local scheduledEvent = nil
    for _, event in ipairs(events) do
        if event.topic == "scheduled_event" then
            scheduledEvent = event
            break
        end
    end
    test_framework.assert_not_nil(scheduledEvent)
    test_framework.assert_equal(scheduledEvent.payload.payload.test, true)
end

--- Test telemetry integration
function test_turn_manager.test_telemetry_integration()
    local events = {}
    local mockTelemetry = {
        recordEvent = function(self, event)
            table.insert(events, event)
        end
    }

    local tm = TurnManager.new({telemetry = mockTelemetry})
    tm:setDate(2024, 1, 1)

    -- Advance a day - should record telemetry
    events = {}
    tm:advance(1)
    test_framework.assert_true(#events >= 1)
    test_framework.assert_equal(events[1].type, "turn-advanced")

    -- Schedule an event - should record telemetry
    events = {}
    tm:schedule(1, "test_event", {data = "test"})
    test_framework.assert_equal(#events, 1)
    test_framework.assert_equal(events[1].type, "turn-scheduled")
    test_framework.assert_equal(events[1].topic, "test_event")

    -- Advance to trigger event - should record telemetry
    events = {}
    tm:advance(1)
    local firedEvent = nil
    for _, event in ipairs(events) do
        if event.type == "turn-fired" then
            firedEvent = event
            break
        end
    end
    test_framework.assert_not_nil(firedEvent)
    test_framework.assert_equal(firedEvent.topic, "test_event")
end

return test_turn_manager