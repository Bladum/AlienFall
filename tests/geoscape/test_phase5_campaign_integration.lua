--- Phase 5 Campaign Integration Test
-- Tests integration of Phase 5 systems with campaign_manager.lua
-- Verifies: calendar, season, events, turn advancement in campaign context
--
-- @module test_phase5_campaign_integration
-- @author AI Agent
-- @license MIT

local CampaignManager = require("engine.geoscape.campaign_manager")

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

-- ============================================================================
-- CAMPAIGN INITIALIZATION TESTS (3 tests)
-- ============================================================================

local InitSuite = "Campaign Initialization"

print("\n📋 Test Suite: " .. InitSuite)

-- Test 1: Campaign initialization
print("  🧪 Campaign initialization")
CampaignManager.init()
Test.assert(CampaignManager.calendar ~= nil, "Calendar should be initialized")
Test.assert(CampaignManager.season_system ~= nil, "SeasonSystem should be initialized")
Test.assert(CampaignManager.event_scheduler ~= nil, "EventScheduler should be initialized")
Test.assert(CampaignManager.turn_advancer ~= nil, "TurnAdvancer should be initialized")

-- Test 2: Initial calendar state
print("  🧪 Initial calendar state")
Test.assert(CampaignManager.calendar.year == 1996, "Year should be 1996")
Test.assert(CampaignManager.calendar.month == 1, "Month should be 1")
Test.assert(CampaignManager.calendar.day == 1, "Day should be 1")
Test.assert(CampaignManager.calendar.turn == 0, "Turn should be 0")

-- Test 3: Campaign phase properties
print("  🧪 Campaign phase properties")
Test.assert(CampaignManager.currentPhase == 0, "Should start in Shadow War (phase 0)")
Test.assert(CampaignManager.threatLevel == 0.1, "Initial threat should be 0.1")
Test.assert(CampaignManager.winRate == 0.5, "Initial win rate should be 0.5")

-- ============================================================================
-- TURN ADVANCEMENT TESTS (4 tests)
-- ============================================================================

local TurnSuite = "Turn Advancement"

print("\n📋 Test Suite: " .. TurnSuite)

-- Test 4: Single turn advancement
print("  🧪 Single turn advancement")
local metrics = CampaignManager.advanceTurn()
Test.assert(metrics ~= nil, "Metrics should be returned")
Test.assert(CampaignManager.calendar.turn == 1, "Turn counter should increment to 1")
Test.assert(CampaignManager.calendar.day == 2, "Day should advance to 2")

-- Test 5: Multiple turns
print("  🧪 Multiple turn advancement")
for i = 1, 29 do
  CampaignManager.advanceTurn()
end
Test.assert(CampaignManager.calendar.turn == 30, "After 30 turns, turn counter should be 30")
Test.assert(CampaignManager.calendar.day == 1, "After 30 days (1 month), day should wrap to 1")
Test.assert(CampaignManager.calendar.month == 2, "After 31 days, month should advance to 2")

-- Test 6: Season advancement
print("  🧪 Season advancement over months")
-- Advance to middle of March
for i = 1, 70 do
  CampaignManager.advanceTurn()
end
Test.assert(CampaignManager.calendar.month == 3, "Should be in March after 100 days")
Test.assert(CampaignManager.calendar:getSeasonName() == "Spring", "Mid-March should be Spring")

-- Test 7: Turn metrics
print("  🧪 Turn advancement metrics")
local metrics_final = CampaignManager.advanceTurn()
Test.assert(metrics_final.total_time ~= nil, "Metrics should include total_time")
Test.assert(metrics_final.phase_times ~= nil, "Metrics should include phase_times")
Test.assert(type(metrics_final.total_time) == "number", "Total time should be a number")

-- ============================================================================
-- SEASONAL EFFECTS TESTS (3 tests)
-- ============================================================================

local SeasonSuite = "Seasonal Effects"

print("\n📋 Test Suite: " .. SeasonSuite)

-- Test 8: Winter modifiers
print("  🧪 Winter seasonal modifiers")
local winter_cal = require("engine.geoscape.systems.calendar").new(1996)
winter_cal.month = 1  -- January = Winter
winter_cal.day = 21
local winter_season = CampaignManager.season_system:getSeasonalModifier("Winter", "resources")
Test.assert(winter_season == 0.70, "Winter resources should be 0.70 (-30%)")

-- Test 9: Summer modifiers
print("  🧪 Summer seasonal modifiers")
local summer_season = CampaignManager.season_system:getSeasonalModifier("Summer", "missions")
Test.assert(summer_season == 1.30, "Summer missions should be 1.30 (+30%)")

-- Test 10: Season transitions
print("  🧪 Season transitions over year")
-- Verify all 4 seasons
local seasons = {}
for month = 1, 12 do
  CampaignManager.calendar.month = month
  CampaignManager.calendar.day = 21
  local season = CampaignManager.calendar:getSeasonName()
  if not seasons[season] then
    seasons[season] = true
  end
end
Test.assert(seasons["Winter"] == true, "Year should include Winter")
Test.assert(seasons["Spring"] == true, "Year should include Spring")
Test.assert(seasons["Summer"] == true, "Year should include Summer")
Test.assert(seasons["Autumn"] == true, "Year should include Autumn")

-- ============================================================================
-- EVENT SCHEDULING TESTS (2 tests)
-- ============================================================================

local EventSuite = "Event Scheduling Integration"

print("\n📋 Test Suite: " .. EventSuite)

-- Test 11: Event scheduling
print("  🧪 Event scheduling through campaign")
local event_id = CampaignManager.event_scheduler:scheduleEvent(150, "research_milestone", {tech = "laser"}, 3)
Test.assert(event_id > 0, "Event should be scheduled with positive ID")

local scheduled = CampaignManager.event_scheduler:getScheduledEvents()
Test.assert(#scheduled == 1, "Event scheduler should have 1 scheduled event")

-- Test 12: Event firing during turns
print("  🧪 Event firing during campaign turns")
-- Reset calendar to known state
CampaignManager.calendar = require("engine.geoscape.systems.calendar").new(1996)
CampaignManager.event_scheduler = require("engine.geoscape.systems.event_scheduler").new()
CampaignManager.turn_advancer = require("engine.geoscape.systems.turn_advancer").new()

-- Register calendar callback
CampaignManager.turn_advancer:registerPhaseCallback(
  CampaignManager.turn_advancer.PHASES.CALENDAR_ADVANCE,
  function(turn, adv) CampaignManager.calendar:advance(1) end
)

-- Schedule event for turn 50
CampaignManager.event_scheduler:scheduleEvent(50, "alien_invasion", {})

-- Advance to turn 50
for i = 1, 49 do
  CampaignManager.turn_advancer:advanceTurn()
end

-- Fire events at turn 50
local fired = CampaignManager.event_scheduler:updateAndFire(50, CampaignManager.calendar)
Test.assert(#fired == 1, "Event should fire at scheduled turn (50)")

-- ============================================================================
-- SERIALIZATION TESTS (2 tests)
-- ============================================================================

local SerializeSuite = "Save/Load Serialization"

print("\n📋 Test Suite: " .. SerializeSuite)

-- Test 13: Campaign save
print("  🧪 Campaign save serialization")
local save_data = CampaignManager.save()
Test.assert(save_data ~= nil, "Save should return data")
Test.assert(save_data.currentPhase ~= nil, "Save should include currentPhase")
Test.assert(save_data.phase5_systems ~= nil, "Save should include phase5_systems")
Test.assert(save_data.phase5_systems.calendar ~= nil, "Save should include calendar data")

-- Test 14: Campaign load
print("  🧪 Campaign load deserialization")
CampaignManager.load(save_data)
Test.assert(CampaignManager.calendar ~= nil, "Calendar should be restored from save")
Test.assert(CampaignManager.season_system ~= nil, "SeasonSystem should be restored from save")
Test.assert(CampaignManager.event_scheduler ~= nil, "EventScheduler should be restored from save")
Test.assert(CampaignManager.turn_advancer ~= nil, "TurnAdvancer should be restored from save")

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
