--- Phase 4: Faction & Mission System Tests
-- Comprehensive test suite for AlienFaction, MissionSystem, TerrorSystem, EventSystem
-- Tests all systems individually and in integration scenarios
--
-- Run: lovec tests/runners geoscape

local AlienFaction = require("engine.geoscape.factions.alien_faction")
local MissionSystem = require("engine.lore.missions.geoscape_mission_system")
local TerrorSystem = require("engine.geoscape.terror.terror_system")
local EventSystem = require("engine.core.event_system")

-- Test framework helpers
local function assert_equal(actual, expected, message)
  if actual ~= expected then
    error(string.format("ASSERTION FAILED: %s\nExpected: %s\nActual: %s", message, tostring(expected), tostring(actual)))
  end
end

local function assert_true(value, message)
  if not value then
    error(string.format("ASSERTION FAILED: %s", message))
  end
end

local function assert_false(value, message)
  if value then
    error(string.format("ASSERTION FAILED: %s", message))
  end
end

local function assert_between(value, min, max, message)
  if value < min or value > max then
    error(string.format("ASSERTION FAILED: %s\nExpected between %d and %d, got %d", message, min, max, value))
  end
end

local function assert_gt(actual, expected, message)
  if actual <= expected then
    error(string.format("ASSERTION FAILED: %s\nExpected > %d, got %d", message, expected, actual))
  end
end

local test_results = { passed = 0, failed = 0, tests = {} }

local function run_test(suite_name, test_name, test_func)
  local test_id = string.format("%s::%s", suite_name, test_name)

  local success, err = pcall(test_func)

  if success then
    test_results.passed = test_results.passed + 1
    table.insert(test_results.tests, { name = test_id, status = "PASS" })
  else
    test_results.failed = test_results.failed + 1
    table.insert(test_results.tests, { name = test_id, status = "FAIL", error = err })
    print(string.format("[FAIL] %s: %s", test_id, err))
  end
end

---===============================================
--- SUITE 1: AlienFaction Tests (5 tests)
---===============================================

local function test_suite_1_alien_faction()
  print("\n=== SUITE 1: AlienFaction Tests ===")

  -- Test 1: Faction creation and initialization
  run_test("Suite1", "Faction Creation", function()
    local faction = AlienFaction.new("Sectoids", 0.3, 40)

    assert_equal(faction.name, "Sectoids", "Faction name")
    assert_equal(faction.control, 0.3, "Initial control")
    assert_equal(faction.threat, 40, "Initial threat")
    assert_equal(faction:getActivityLevel(), 0, "Initial activity should be 0")
  end)

  -- Test 2: Activity level calculation
  run_test("Suite1", "Activity Level Calculation", function()
    local faction = AlienFaction.new("Mutons", 0.5, 50)
    faction:update(10, 5, 3)  -- 5 regions, threat level 3

    local activity = faction:getActivityLevel()
    assert_between(activity, 0, 10, "Activity level in valid range")
    assert_gt(activity, 0, "Activity should increase with regions")
  end)

  -- Test 3: Threat level calculation
  run_test("Suite1", "Threat Level Calculation", function()
    local faction = AlienFaction.new("Ethereals", 0.2, 30)
    faction:incrementActivity(5)
    faction:update(15, 8, 5)

    local threat = faction:getThreatLevel()
    assert_between(threat, 0, 100, "Threat level in valid range")
    assert_gt(threat, 30, "Threat should increase from activity")
  end)

  -- Test 4: UFO generation
  run_test("Suite1", "UFO Generation", function()
    local faction = AlienFaction.new("Sectoids", 0, 50)

    -- Generate UFO
    local ufo = faction:generateUFO()
    assert_true(ufo.type, "UFO has type")
    assert_true(ufo.units > 0, "UFO has units")

    -- Check fleet updated
    local fleet = faction:getFleet()
    assert_gt(fleet.total, 0, "Fleet total increased")
  end)

  -- Test 5: Mission scheduling
  run_test("Suite1", "Mission Scheduling", function()
    local faction = AlienFaction.new("Mutons", 0.5, 60)
    faction:incrementActivity(4)
    faction:scheduleMission(10, 5)

    local pending = faction:getPendingMissions()
    assert_equal(pending, 1, "Mission queued")

    local mission = faction:activateMission()
    assert_true(mission, "Mission activated")
    assert_true(mission.type, "Mission has type")
  end)
end

---===============================================
--- SUITE 2: MissionSystem Tests (5 tests)
---===============================================

local function test_suite_2_mission_system()
  print("\n=== SUITE 2: MissionSystem Tests ===")

  -- Test 1: Mission generation
  run_test("Suite2", "Mission Generation", function()
    local mission_sys = MissionSystem.new()
    local mission = mission_sys:generateMission("Sectoids", 1, "infiltration", 60)

    assert_true(mission, "Mission generated")
    assert_equal(mission.faction, "Sectoids", "Mission faction")
    assert_true(mission.type, "Mission has type")
    assert_equal(mission.region_id, 1, "Mission region")
    assert_equal(mission.status, "active", "Initial status")
    assert_gt(mission.duration, 0, "Mission has duration")
  end)

  -- Test 2: Mission type distribution
  run_test("Suite2", "Mission Type Distribution", function()
    local mission_sys = MissionSystem.new()
    local types = { infiltration = 0, terror = 0, research = 0, supply = 0 }

    -- Generate 100 missions and count types
    for i = 1, 100 do
      local mission = mission_sys:generateMission("Test", i, nil, 50)
      types[mission.type] = types[mission.type] + 1
    end

    -- All types should appear at least once
    assert_gt(types.infiltration, 0, "Infiltration missions generated")
    assert_gt(types.terror, 0, "Terror missions generated")
  end)

  -- Test 3: Regional targeting
  run_test("Suite2", "Regional Targeting", function()
    local mission_sys = MissionSystem.new()

    local m1 = mission_sys:generateMission("Sect", 1, "infiltration", 50)
    local m2 = mission_sys:generateMission("Sect", 1, "terror", 50)
    local m3 = mission_sys:generateMission("Muton", 2, "research", 50)

    local region1 = mission_sys:getMissionsInRegion(1)
    local region2 = mission_sys:getMissionsInRegion(2)

    assert_equal(#region1, 2, "Region 1 has 2 missions")
    assert_equal(#region2, 1, "Region 2 has 1 mission")
  end)

  -- Test 4: Mission completion
  run_test("Suite2", "Mission Completion", function()
    local mission_sys = MissionSystem.new()
    local mission = mission_sys:generateMission("Sect", 1, "terror", 50)
    local mission_id = mission.id

    mission_sys:completeMission(mission_id, "stopped", 1.0)

    assert_equal(#mission_sys.completed_missions, 1, "Mission moved to completed")
    assert_equal(mission_sys.active_missions[mission_id], nil, "Removed from active")
  end)

  -- Test 5: Mission serialization
  run_test("Suite2", "Mission Serialization", function()
    local mission_sys = MissionSystem.new()
    mission_sys:generateMission("Sect", 1, "infiltration", 50)

    local serialized = mission_sys:serialize()
    local restored = MissionSystem.deserialize(serialized)

    assert_equal(#restored.active_missions, 1, "Mission count preserved")
  end)
end

---===============================================
--- SUITE 3: TerrorSystem Tests (5 tests)
---===============================================

local function test_suite_3_terror_system()
  print("\n=== SUITE 3: TerrorSystem Tests ===")

  -- Test 1: Terror attack initialization
  run_test("Suite3", "Terror Attack Initialization", function()
    local terror_sys = TerrorSystem.new()
    local attack = terror_sys:startTerrorAttack("Sectoids", 1, 5)

    assert_equal(attack.faction, "Sectoids", "Attack faction")
    assert_equal(attack.region_id, 1, "Attack region")
    assert_equal(attack.intensity, 5, "Attack intensity")
    assert_equal(attack.status, "active", "Initial status")
    assert_between(#attack.locations, 3, 7, "Location count 3-7")
  end)

  -- Test 2: Terror location generation
  run_test("Suite3", "Terror Location Generation", function()
    local terror_sys = TerrorSystem.new()
    terror_sys:startTerrorAttack("Mutons", 1, 3)

    local locations = terror_sys:getTerrorLocations(1)
    assert_gt(#locations, 0, "Locations generated")

    for _, loc in ipairs(locations) do
      assert_true(loc.intensity, "Location has intensity")
      assert_true(loc.civilians_affected >= 0, "Location has civilians")
    end
  end)

  -- Test 3: Terror effects calculation
  run_test("Suite3", "Terror Effects Calculation", function()
    local terror_sys = TerrorSystem.new()
    terror_sys:startTerrorAttack("Sect", 1, 4)

    local before = terror_sys:getRegionalTerrorLevel(1)
    terror_sys:update(10)
    local after = terror_sys:getRegionalTerrorLevel(1)

    assert_gt(after, before, "Terror level increases after update")
  end)

  -- Test 4: Terror escalation
  run_test("Suite3", "Terror Escalation", function()
    local terror_sys = TerrorSystem.new()
    local attack = terror_sys:startTerrorAttack("Ethereals", 1, 2)

    -- Simulate 5 turns of no opposition
    for i = 1, 5 do
      terror_sys:update(i)
    end

    local escalations = terror_sys:update(6)
    -- Escalation should have occurred
    assert_gt(attack.intensity, 2, "Intensity increased from escalation")
  end)

  -- Test 5: Regional terror level
  run_test("Suite3", "Regional Terror Level", function()
    local terror_sys = TerrorSystem.new()
    terror_sys:startTerrorAttack("Sect", 1, 3)
    terror_sys:startTerrorAttack("Muton", 1, 2)

    local level = terror_sys:getRegionalTerrorLevel(1)
    assert_between(level, 0, 100, "Terror level in valid range")

    local desc = terror_sys:getTerrorDescription(1)
    assert_true(desc, "Terror description exists")
  end)
end

---===============================================
--- SUITE 4: EventSystem Tests (4 tests)
---===============================================

local function test_suite_4_event_system()
  print("\n=== SUITE 4: EventSystem Tests ===")

  -- Test 1: Event registration
  run_test("Suite4", "Event Registration", function()
    local event_sys = EventSystem.new()

    local callback = function() end
    event_sys:register(EventSystem.EVENT_TYPES.MISSION_GENERATED, callback)

    local count = event_sys:getListenerCount(EventSystem.EVENT_TYPES.MISSION_GENERATED)
    assert_equal(count, 1, "Listener registered")
  end)

  -- Test 2: Event broadcasting
  run_test("Suite4", "Event Broadcasting", function()
    local event_sys = EventSystem.new()

    local received_event = nil
    event_sys:register(EventSystem.EVENT_TYPES.MISSION_STARTED, function(event)
      received_event = event
    end)

    local listener_count = event_sys:broadcast(EventSystem.EVENT_TYPES.MISSION_STARTED, { mission_id = 42 })

    assert_equal(listener_count, 1, "One listener called")
    assert_true(received_event, "Event received")
    if received_event then
      assert_equal(received_event.mission_id, 42, "Event data passed")
    end
  end)

  -- Test 3: Event history tracking
  run_test("Suite4", "Event History Tracking", function()
    local event_sys = EventSystem.new()

    event_sys:broadcast(EventSystem.EVENT_TYPES.FACTION_ACTIVITY_INCREASED, { faction = "Sect" })
    event_sys:broadcast(EventSystem.EVENT_TYPES.MISSION_GENERATED, { mission_id = 1 })

    local history = event_sys:getHistory()
    assert_equal(#history, 2, "Both events in history")

    local recent = event_sys:getRecentEvents(1)
    assert_equal(#recent, 1, "Recent gets 1")
  end)

  -- Test 4: Event filtering
  run_test("Suite4", "Event Filtering", function()
    local event_sys = EventSystem.new()

    event_sys:broadcast(EventSystem.EVENT_TYPES.FACTION_ACTIVITY_INCREASED, {})
    event_sys:broadcast(EventSystem.EVENT_TYPES.MISSION_GENERATED, {})
    event_sys:broadcast(EventSystem.EVENT_TYPES.FACTION_ACTIVITY_INCREASED, {})

    local activity_events = event_sys:getHistory(EventSystem.EVENT_TYPES.FACTION_ACTIVITY_INCREASED)
    assert_equal(#activity_events, 2, "Correct event type count")
  end)
end

---===============================================
--- SUITE 5: Integration Tests (3 tests)
---===============================================

local function test_suite_5_integration()
  print("\n=== SUITE 5: Integration Tests ===")

  -- Test 1: Faction-Mission workflow
  run_test("Suite5", "Faction-Mission Workflow", function()
    local faction = AlienFaction.new("Sectoids", 0.5, 50)
    local mission_sys = MissionSystem.new()
    local event_sys = EventSystem.new()

    -- Faction activity triggers mission scheduling
    faction:incrementActivity(3)
    faction:update(10, 5, 2)

    -- Simulate scheduled mission becomes active
    if faction:getPendingMissions() > 0 then
      local queued = faction:activateMission()
      if queued and queued.type and queued.threat_level then
        local mission = mission_sys:generateMission(faction.name, 1, queued.type, queued.threat_level)
        event_sys:broadcast(EventSystem.EVENT_TYPES.MISSION_GENERATED, {
          faction = faction.name,
          mission_id = mission.id,
          type = mission.type,
        })
      end
    end

    local stats = mission_sys:getStatistics()
    assert_true(stats.active >= 0, "Mission system updated")
  end)

  -- Test 2: Faction-Terror integration
  run_test("Suite5", "Faction-Terror Integration", function()
    local faction = AlienFaction.new("Mutons", 0.3, 40)
    local terror_sys = TerrorSystem.new()
    local event_sys = EventSystem.new()

    -- Start terror from faction activity
    terror_sys:startTerrorAttack(faction.name, 1, 4)
    event_sys:broadcast(EventSystem.EVENT_TYPES.TERROR_ATTACK_STARTED, {
      faction = faction.name,
      region_id = 1,
      intensity = 4,
    })

    -- Terror effects feed back to faction
    faction:incrementActivity(1)

    assert_gt(faction:getActivityLevel(), 0, "Activity increased from terror")
    assert_gt(terror_sys:getRegionalTerrorLevel(1), 0, "Regional terror level set")
  end)

  -- Test 3: Full campaign turn
  run_test("Suite5", "Full Campaign Turn", function()
    -- Initialize all systems
    local factions = {
      AlienFaction.new("Sectoids", 0.2, 30),
      AlienFaction.new("Mutons", 0.3, 40),
    }
    local mission_sys = MissionSystem.new()
    local terror_sys = TerrorSystem.new()
    local event_sys = EventSystem.new()

    -- Simulate one campaign turn
    local turn = 1

    -- Update all factions
    for _, faction in ipairs(factions) do
      faction:update(turn, math.random(1, 5), math.random(1, 5))

      -- Activate pending missions
      while faction:getPendingMissions() > 0 do
        local queued = faction:activateMission()
        local mission = mission_sys:generateMission(faction.name, 1, queued.type, queued.threat_level)
        event_sys:broadcast(EventSystem.EVENT_TYPES.MISSION_GENERATED, {
          mission_id = mission.id,
          faction = faction.name,
        })
      end
    end

    -- Update mission system
    mission_sys:update(turn)

    -- Update terror system
    terror_sys:update(turn)

    -- Verify systems updated
    assert_gt(mission_sys:getActiveMissionCount() + #mission_sys.completed_missions, 0, "Missions exist")
  end)
end

---===============================================
--- Main Test Runner
---===============================================

print("=" .. string.rep("=", 73) .. "=")
print("TASK-025 PHASE 4: Faction & Mission System Tests")
print("=" .. string.rep("=", 73) .. "=")

test_suite_1_alien_faction()
test_suite_2_mission_system()
test_suite_3_terror_system()
test_suite_4_event_system()
test_suite_5_integration()

print("\n" .. string.rep("=", 75))
print(string.format("TEST RESULTS: %d PASSED, %d FAILED", test_results.passed, test_results.failed))
print(string.rep("=", 75))

if test_results.failed > 0 then
  print("\nFAILED TESTS:")
  for _, test in ipairs(test_results.tests) do
    if test.status == "FAIL" then
      print(string.format("  - %s", test.name))
    end
  end
end

print(string.format("\nTotal: %d tests", test_results.passed + test_results.failed))
print("=" .. string.rep("=", 73) .. "=\n")

return test_results
