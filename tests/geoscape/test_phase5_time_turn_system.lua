--- Test suite for Phase 5 Time and Turn Management systems
-- Tests: Calendar, SeasonSystem, EventScheduler, TurnAdvancer
--
-- @module test_phase5_time_turn_system
-- @author AI Agent
-- @license MIT

local Calendar = require("engine.geoscape.systems.calendar")
local SeasonSystem = require("engine.geoscape.systems.season_system")
local EventScheduler = require("engine.geoscape.systems.event_scheduler")
local TurnAdvancer = require("engine.geoscape.systems.turn_advancer")

-- Test utilities
local Test = {}
Test.results = {passed = 0, failed = 0, errors = {}}

function Test.assert(condition, message)
  if not condition then
    Test.results.failed = Test.results.failed + 1
    table.insert(Test.results.errors, message)
    print("  ❌ FAIL: " .. message)
    return false
  else
    Test.results.passed = Test.results.passed + 1
    return true
  end
end

function Test.suite(name)
  print("\n📋 Test Suite: " .. name)
  return {
    name = name,
    tests_passed = 0,
    tests_failed = 0,
  }
end

function Test.test(suite, name)
  print("  🧪 " .. name)
  return {suite = suite, name = name}
end

-- ============================================================================
-- CALENDAR TESTS (5 tests)
-- ============================================================================

local CalendarSuite = Test.suite("Calendar")

-- Test 1: Calendar initialization
do
  local test = Test.test(CalendarSuite, "Initialization with default year")
  local cal = Calendar.new(1996)
  Test.assert(cal.year == 1996, "Year should be 1996")
  Test.assert(cal.month == 1, "Month should default to 1")
  Test.assert(cal.day == 1, "Day should default to 1")
  Test.assert(cal.turn == 1, "Turn should default to 1")
end

-- Test 2: Leap year calculation
do
  local test = Test.test(CalendarSuite, "Leap year detection")
  Test.assert(Calendar.isLeapYear(1996), "1996 should be leap year")
  Test.assert(Calendar.isLeapYear(2000), "2000 should be leap year")
  Test.assert(not Calendar.isLeapYear(1900), "1900 should not be leap year")
  Test.assert(not Calendar.isLeapYear(2001), "2001 should not be leap year")
end

-- Test 3: Days in month
do
  local test = Test.test(CalendarSuite, "Days in month calculation")
  local cal = Calendar.new(1996)

  cal.month = 1  -- January (31 days)
  Test.assert(cal:getDaysInMonth() == 31, "January should have 31 days")

  cal.month = 2  -- February (29 days in leap year)
  Test.assert(cal:getDaysInMonth() == 29, "February 1996 should have 29 days")

  cal.year = 2001
  Test.assert(cal:getDaysInMonth() == 28, "February 2001 should have 28 days")
end

-- Test 4: Date advancement
do
  local test = Test.test(CalendarSuite, "Calendar advancement")
  local cal = Calendar.new(1996)

  cal:advance(30)  -- Advance 30 days
  Test.assert(cal.day == 31, "After 30 days, should be Jan 31")
  Test.assert(cal.turn == 31, "Turn should be 31")

  cal:advance(1)   -- Advance to February
  Test.assert(cal.month == 2, "Should advance to February")
  Test.assert(cal.day == 1, "Should reset to day 1")
end

-- Test 5: Season detection
do
  local test = Test.test(CalendarSuite, "Season detection")
  local cal = Calendar.new(1996)

  cal.month = 12
  cal.day = 21
  Test.assert(cal:getSeasonName() == "Winter", "Dec 21 should be Winter")

  cal.month = 3
  cal.day = 21
  Test.assert(cal:getSeasonName() == "Spring", "Mar 21 should be Spring")

  cal.month = 6
  cal.day = 21
  Test.assert(cal:getSeasonName() == "Summer", "Jun 21 should be Summer")

  cal.month = 9
  cal.day = 21
  Test.assert(cal:getSeasonName() == "Autumn", "Sep 21 should be Autumn")
end

-- ============================================================================
-- SEASON SYSTEM TESTS (4 tests)
-- ============================================================================

local SeasonSuite = Test.suite("SeasonSystem")

-- Test 6: Seasonal modifiers
do
  local test = Test.test(SeasonSuite, "Seasonal modifier values")
  local season_sys = SeasonSystem.new()

  local winter_resource = season_sys:getSeasonalModifier("Winter", "resources")
  Test.assert(winter_resource == 0.70, "Winter resources should be 0.70 (-30%)")

  local summer_missions = season_sys:getSeasonalModifier("Summer", "missions")
  Test.assert(summer_missions == 1.30, "Summer missions should be 1.30 (+30%)")
end

-- Test 7: Mission frequency modifier by season
do
  local test = Test.test(SeasonSuite, "Mission frequency modifiers")
  local season_sys = SeasonSystem.new()

  -- Mock calendar
  local mock_cal = {
    turn = 100,
    month = 1,  -- Winter
    getSeasonName = function(self) return "Winter" end,
  }

  season_sys.calendar = mock_cal
  local winter_freq = season_sys:getMissionFrequencyModifier()
  Test.assert(winter_freq == 0.80, "Winter mission frequency should be 0.80 (-20%)")
end

-- Test 8: Alien activity modifier
do
  local test = Test.test(SeasonSuite, "Alien activity modifiers")
  local season_sys = SeasonSystem.new()

  -- Mock calendar for Spring (high alien activity)
  local mock_cal = {
    turn = 100,
    month = 4,
    getSeasonName = function(self) return "Spring" end,
  }

  season_sys.calendar = mock_cal
  local spring_activity = season_sys:getAlienActivityModifier()
  Test.assert(spring_activity == 1.20, "Spring alien activity should be 1.20 (+20%)")
end

-- Test 9: Quarter escalation
do
  local test = Test.test(SeasonSuite, "Quarter-based escalation")
  local season_sys = SeasonSystem.new()

  -- Mock calendar
  local mock_cal = {
    turn = 90,  -- Q1
    getQuarter = function(self)
      if self.turn <= 91 then return 1 end
      if self.turn <= 182 then return 2 end
      if self.turn <= 273 then return 3 end
      return 4
    end,
  }

  season_sys.calendar = mock_cal
  local q1_escalation = season_sys:getQuarterEscalation()
  Test.assert(q1_escalation >= 1.0 and q1_escalation <= 1.2, "Q1 escalation should be in range 1.0-1.2")
end

-- ============================================================================
-- EVENT SCHEDULER TESTS (6 tests)
-- ============================================================================

local EventSuite = Test.suite("EventScheduler")

-- Test 10: Event scheduling and retrieval
do
  local test = Test.test(EventSuite, "Schedule and retrieve events")
  local scheduler = EventScheduler.new()

  local event_id = scheduler:scheduleEvent(100, "research_milestone", {tech = "laser"})
  Test.assert(event_id > 0, "Event ID should be positive")

  local scheduled = scheduler:getScheduledEvents()
  Test.assert(#scheduled == 1, "Should have 1 scheduled event")
  Test.assert(scheduled[1].type == "research_milestone", "Event type should match")
end

-- Test 11: Event firing
do
  local test = Test.test(EventSuite, "Event firing on target turn")
  local scheduler = EventScheduler.new()

  scheduler:scheduleEvent(50, "alien_invasion", {})

  local fired = scheduler:updateAndFire(49)  -- Before turn
  Test.assert(#fired == 0, "Should not fire before target turn")

  fired = scheduler:updateAndFire(50)  -- On target turn
  Test.assert(#fired == 1, "Should fire on target turn")
end

-- Test 12: Event cancellation
do
  local test = Test.test(EventSuite, "Cancel scheduled event")
  local scheduler = EventScheduler.new()

  local event_id = scheduler:scheduleEvent(75, "world_event", {})
  local cancelled = scheduler:cancelEvent(event_id)
  Test.assert(cancelled, "Event should be cancelled")

  local scheduled = scheduler:getScheduledEvents()
  Test.assert(#scheduled == 0, "No events should be scheduled")
end

-- Test 13: Repeating events
do
  local test = Test.test(EventSuite, "Repeating annual events")
  local scheduler = EventScheduler.new()

  scheduler:scheduleEvent(100, "season_change", {}, 3, true)  -- Repeating annual

  scheduler:updateAndFire(100)  -- Fire first occurrence

  local scheduled = scheduler:getScheduledEvents()
  Test.assert(#scheduled == 1, "Should have 1 rescheduled event (annual repeat)")
  Test.assert(scheduled[1].turn_scheduled == 465, "Repeat should be ~365 days later")
end

-- Test 14: Event history
do
  local test = Test.test(EventSuite, "Event history tracking")
  local scheduler = EventScheduler.new()

  scheduler:scheduleEvent(10, "ufo_sighting", {})
  scheduler:scheduleEvent(20, "diplomatic_incident", {})

  scheduler:updateAndFire(10)
  scheduler:updateAndFire(20)

  local history = scheduler:getTriggeredEvents()
  Test.assert(#history == 2, "Should have 2 events in history")
  Test.assert(history[1].type == "ufo_sighting", "First event should match")
  Test.assert(history[2].type == "diplomatic_incident", "Second event should match")
end

-- Test 15: Get next event
do
  local test = Test.test(EventSuite, "Get next scheduled event")
  local scheduler = EventScheduler.new()

  scheduler:scheduleEvent(200, "event1", {})
  scheduler:scheduleEvent(50, "event2", {})
  scheduler:scheduleEvent(100, "event3", {})

  local next = scheduler:getNextEvent()
  Test.assert(next ~= nil, "Should have a next event")
  if next then
    Test.assert(next.turn_scheduled == 50, "Next event should be earliest (turn 50)")
  end
end

-- ============================================================================
-- TURN ADVANCER TESTS (4 tests)
-- ============================================================================

local TurnSuite = Test.suite("TurnAdvancer")

-- Test 16: Phase callback registration
do
  local test = Test.test(TurnSuite, "Register phase callbacks")
  local advancer = TurnAdvancer.new()

  local callback_called = false
  local phase_called = nil

  local function test_callback(turn, advancer)
    callback_called = true
    phase_called = turn
  end

  local cb_id = advancer:registerPhaseCallback(TurnAdvancer.PHASES.CALENDAR_ADVANCE, test_callback, "test")
  Test.assert(cb_id > 0, "Callback ID should be positive")

  advancer:advanceTurn()
  Test.assert(callback_called, "Callback should have been called")
  Test.assert(phase_called == 1, "Turn should be 1")
end

-- Test 17: Global callback registration
do
  local test = Test.test(TurnSuite, "Register global callbacks")
  local advancer = TurnAdvancer.new()

  local global_called = false

  advancer:registerGlobalCallback(function(turn, advancer)
    global_called = true
  end, "test_global")

  advancer:advanceTurn()
  Test.assert(global_called, "Global callback should be called")
end

-- Test 18: Turn advancement
do
  local test = Test.test(TurnSuite, "Turn counter advancement")
  local advancer = TurnAdvancer.new()

  Test.assert(advancer:getCurrentTurn() == 0, "Initial turn should be 0")

  advancer:advanceTurn()
  Test.assert(advancer:getCurrentTurn() == 1, "After advance, turn should be 1")

  advancer:advanceTurn()
  Test.assert(advancer:getCurrentTurn() == 2, "After second advance, turn should be 2")
end

-- Test 19: Performance metrics
do
  local test = Test.test(TurnSuite, "Performance tracking")
  local advancer = TurnAdvancer.new()

  advancer:advanceTurn()
  advancer:advanceTurn()

  local summary = advancer:getPerformanceSummary()
  Test.assert(summary.turns_advanced == 2, "Should have advanced 2 turns")
  Test.assert(summary.average_time_ms >= 0, "Average time should be non-negative")
end

-- ============================================================================
-- INTEGRATION TESTS (3 tests)
-- ============================================================================

local IntegrationSuite = Test.suite("Integration Tests")

-- Test 20: Calendar and Season System integration
do
  local test = Test.test(IntegrationSuite, "Calendar-SeasonSystem integration")
  local cal = Calendar.new(1996)
  local season_sys = SeasonSystem.new()

  season_sys.calendar = cal

  -- Advance to different seasons and verify modifiers
  cal.month = 6  -- June (Summer)
  local summer_mod = season_sys:getSeasonalModifier("Summer", "missions")
  Test.assert(summer_mod == 1.30, "Should get correct seasonal modifier")
end

-- Test 21: Event Scheduler with Calendar dates
do
  local test = Test.test(IntegrationSuite, "EventScheduler date-based scheduling")
  local cal = Calendar.new(1996)
  local scheduler = EventScheduler.new()

  -- Schedule event for specific date (March 15)
  local event_id = scheduler:scheduleDateEvent(3, 15, "milestone", {}, cal)
  Test.assert(event_id > 0, "Should create dated event")

  local scheduled = scheduler:getScheduledEvents()
  Test.assert(#scheduled == 1, "Should have scheduled event")
end

-- Test 22: Full turn orchestration
do
  local test = Test.test(IntegrationSuite, "Complete turn advancement flow")
  local cal = Calendar.new(1996)
  local advancer = TurnAdvancer.new()
  local scheduler = EventScheduler.new()

  local calendar_updated = false
  local event_processed = false

  -- Register calendar update callback
  advancer:registerPhaseCallback(TurnAdvancer.PHASES.CALENDAR_ADVANCE, function(turn, adv)
    calendar_updated = true
  end)

  -- Register event processing callback
  advancer:registerPhaseCallback(TurnAdvancer.PHASES.EVENT_FIRE, function(turn, adv)
    event_processed = true
  end)

  advancer:advanceTurn()

  Test.assert(calendar_updated, "Calendar should be updated in phase")
  Test.assert(event_processed, "Events should be processed in phase")
end

-- ============================================================================
-- TEST SUMMARY
-- ============================================================================

print("\n" .. string.rep("=", 80))
print("📊 TEST SUMMARY")
print(string.rep("=", 80))
print("✅ Passed: " .. Test.results.passed)
print("❌ Failed: " .. Test.results.failed)
print("Total:  " .. (Test.results.passed + Test.results.failed))

if Test.results.failed > 0 then
  print("\n❌ FAILED TESTS:")
  for _, error in ipairs(Test.results.errors) do
    print("  • " .. error)
  end
else
  print("\n🎉 ALL TESTS PASSED!")
end

print(string.rep("=", 80))

return {
  passed = Test.results.passed,
  failed = Test.results.failed,
  errors = Test.results.errors,
}
