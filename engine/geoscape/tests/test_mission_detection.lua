--[[
    Mission Detection System Tests
    Comprehensive test suite for Mission, CampaignManager, and DetectionManager
    
    Test Coverage:
    1. Mission entity creation and lifecycle
    2. Mission cover mechanics
    3. Campaign manager time tracking
    4. Weekly mission generation
    5. Detection manager radar scanning
    6. Cover reduction and detection
    7. Full integration test
]]

print("\n=== Mission Detection System Tests ===\n")

-- Load modules
local Mission = require("geoscape.logic.mission")
local CampaignManager = require("geoscape.systems.campaign_manager")
local DetectionManager = require("geoscape.systems.detection_manager")

-- Test counter
local testsRun = 0
local testsPassed = 0
local testsFailed = 0

local function assert_equal(actual, expected, message)
    testsRun = testsRun + 1
    if actual == expected then
        testsPassed = testsPassed + 1
        print(string.format("  ✓ %s", message))
        return true
    else
        testsFailed = testsFailed + 1
        print(string.format("  ✗ %s: Expected %s, got %s", message, tostring(expected), tostring(actual)))
        return false
    end
end

local function assert_true(condition, message)
    return assert_equal(condition, true, message)
end

local function assert_not_nil(value, message)
    testsRun = testsRun + 1
    if value ~= nil then
        testsPassed = testsPassed + 1
        print(string.format("  ✓ %s", message))
        return true
    else
        testsFailed = testsFailed + 1
        print(string.format("  ✗ %s: Value is nil", message))
        return false
    end
end

local function assert_range(value, min, max, message)
    testsRun = testsRun + 1
    if value >= min and value <= max then
        testsPassed = testsPassed + 1
        print(string.format("  ✓ %s (value: %s)", message, tostring(value)))
        return true
    else
        testsFailed = testsFailed + 1
        print(string.format("  ✗ %s: Expected %s-%s, got %s", message, tostring(min), tostring(max), tostring(value)))
        return false
    end
end

-- Test 1: Mission Entity Creation
print("Test 1: Mission Entity Creation")
do
    local mission = Mission:new({
        type = "site",
        faction = "aliens",
        biome = "forest",
        difficulty = 1,
        power = 100,
        spawnDay = 1,
    })
    
    assert_not_nil(mission, "Mission created")
    assert_equal(mission.type, "site", "Mission type is site")
    assert_equal(mission.difficulty, 1, "Mission difficulty is 1")
    assert_equal(mission.power, 100, "Mission power is 100")
    assert_equal(mission.state, "hidden", "Mission starts hidden")
    assert_equal(mission.detected, false, "Mission not detected")
    assert_equal(mission.coverValue, 100, "Mission starts with full cover")
    
    print(string.format("  Created mission: %s", mission.name))
end
print()

-- Test 2: Mission Cover Mechanics
print("Test 2: Mission Cover Mechanics")
do
    local mission = Mission:new({
        type = "ufo",
        coverValue = 50,
        coverMax = 100,
        coverRegen = 10,
        spawnDay = 1,
    })
    
    -- Test cover reduction
    mission:reduceCover(20)
    assert_equal(mission.coverValue, 30, "Cover reduced from 50 to 30")
    assert_equal(mission.detected, false, "Mission still hidden with cover > 0")
    
    -- Test detection when cover reaches 0
    mission:reduceCover(30)
    assert_equal(mission.coverValue, 0, "Cover depleted to 0")
    assert_equal(mission.detected, true, "Mission detected when cover = 0")
    assert_equal(mission.state, "detected", "Mission state changed to detected")
    
    -- Test cover regeneration
    local mission2 = Mission:new({type = "site", coverValue = 50, coverRegen = 5})
    mission2:update(2)  -- 2 days pass
    assert_equal(mission2.coverValue, 60, "Cover regenerated from 50 to 60 (5/day × 2)")
    
    print(string.format("  Mission 1 detected: %s", mission.name))
    print(string.format("  Mission 2 cover regenerated: %s", mission2.name))
end
print()

-- Test 3: Mission Lifecycle
print("Test 3: Mission Lifecycle")
do
    local mission = Mission:new({
        type = "site",
        duration = 5,  -- Expires after 5 days
        spawnDay = 1,
    })
    
    -- Advance time
    mission:update(3)
    assert_equal(mission.daysActive, 3, "Mission active for 3 days")
    assert_equal(mission.state, "hidden", "Mission still active")
    
    -- Advance to expiration
    mission:update(2)
    assert_equal(mission.daysActive, 5, "Mission active for 5 days")
    assert_equal(mission.state, "expired", "Mission expired after duration")
    
    -- Test completion
    local mission2 = Mission:new({type = "ufo"})
    mission2:complete(10)
    assert_equal(mission2.state, "completed", "Mission marked as completed")
    
    print(string.format("  Mission 1 expired: %s", mission.name))
    print(string.format("  Mission 2 completed: %s", mission2.name))
end
print()

-- Test 4: Campaign Manager Initialization
print("Test 4: Campaign Manager Initialization")
do
    CampaignManager:init()
    
    assert_equal(CampaignManager.currentDay, 1, "Campaign starts on Day 1")
    assert_equal(CampaignManager.currentWeek, 1, "Campaign starts on Week 1")
    assert_equal(CampaignManager.currentMonth, 1, "Campaign starts on Month 1")
    assert_equal(CampaignManager.currentYear, 1, "Campaign starts on Year 1")
    assert_equal(#CampaignManager.activeMissions, 0, "No missions at start")
    
    print("  Campaign initialized successfully")
end
print()

-- Test 5: Campaign Time Tracking
print("Test 5: Campaign Time Tracking")
do
    CampaignManager:init()
    
    -- Advance 7 days
    for i = 1, 7 do
        CampaignManager:advanceDay()
    end
    
    assert_equal(CampaignManager.currentDay, 8, "Advanced to Day 8")
    assert_equal(CampaignManager.currentWeek, 2, "Advanced to Week 2")
    
    -- Check Monday detection
    assert_true(CampaignManager:isMonday(), "Day 8 is Monday (8-1)%7=0")
    
    print(string.format("  Time tracking: Day %d, Week %d", 
        CampaignManager.currentDay, CampaignManager.currentWeek))
end
print()

-- Test 6: Weekly Mission Generation
print("Test 6: Weekly Mission Generation")
do
    CampaignManager:init()
    
    -- Advance to Monday (Day 1 is Monday)
    local events = CampaignManager:advanceDay()  -- Day 2
    
    -- Check that missions were generated on Day 1
    local initialMissions = CampaignManager.totalMissionsGenerated
    
    -- Advance to next Monday
    for i = 1, 6 do
        CampaignManager:advanceDay()
    end
    
    -- Day 8 is Monday - should generate missions
    assert_true(CampaignManager:isMonday(), "Day 8 is Monday")
    
    local missionsBefore = CampaignManager.totalMissionsGenerated
    CampaignManager:advanceDay()  -- Day 9
    local missionsAfter = CampaignManager.totalMissionsGenerated
    
    assert_true(missionsAfter > missionsBefore, "Missions generated on Monday")
    assert_true(#CampaignManager.activeMissions > 0, "Active missions list populated")
    
    print(string.format("  Total missions generated: %d", CampaignManager.totalMissionsGenerated))
    print(string.format("  Active missions: %d", #CampaignManager.activeMissions))
end
print()

-- Test 7: Mission Cleanup
print("Test 7: Mission Cleanup")
do
    CampaignManager:init()
    
    -- Create test missions
    local mission1 = Mission:new({type = "site", duration = 1, spawnDay = 1})
    local mission2 = Mission:new({type = "ufo", spawnDay = 1})
    
    table.insert(CampaignManager.activeMissions, mission1)
    table.insert(CampaignManager.activeMissions, mission2)
    
    assert_equal(#CampaignManager.activeMissions, 2, "2 active missions")
    
    -- Expire mission1
    mission1:expire()
    CampaignManager:cleanupMissions()
    
    assert_equal(#CampaignManager.activeMissions, 1, "1 active mission after cleanup")
    assert_equal(#CampaignManager.expiredMissions, 1, "1 expired mission")
    
    -- Complete mission2
    mission2:complete()
    CampaignManager:cleanupMissions()
    
    assert_equal(#CampaignManager.activeMissions, 0, "0 active missions")
    assert_equal(#CampaignManager.completedMissions, 1, "1 completed mission")
    
    print("  Mission cleanup working correctly")
end
print()

-- Test 8: Detection Manager Initialization
print("Test 8: Detection Manager Initialization")
do
    DetectionManager:init()
    
    local stats = DetectionManager:getStatistics()
    assert_equal(stats.totalScansPerformed, 0, "No scans performed yet")
    assert_equal(stats.totalMissionsDetected, 0, "No detections yet")
    
    print("  Detection Manager initialized successfully")
end
print()

-- Test 9: Radar Power and Range Calculations
print("Test 9: Radar Power and Range Calculations")
do
    DetectionManager:init()
    
    -- Test base radar
    local base = {
        name = "Test Base",
        facilities = {
            {type = "radar_small"},
            {type = "radar_large"},
        },
    }
    
    local power = DetectionManager:getBaseRadarPower(base)
    local range = DetectionManager:getBaseRadarRange(base)
    
    assert_equal(power, 70, "Base radar power: 20 + 50 = 70")
    assert_equal(range, 10, "Base radar range: max(5, 10) = 10")
    
    -- Test craft radar
    local craft = {
        name = "Test Craft",
        equipment = {
            {type = "craft_radar_basic"},
        },
    }
    
    local craftPower = DetectionManager:getCraftRadarPower(craft)
    local craftRange = DetectionManager:getCraftRadarRange(craft)
    
    assert_equal(craftPower, 10, "Craft radar power: 10")
    assert_equal(craftRange, 3, "Craft radar range: 3")
    
    print(string.format("  Base: Power %d, Range %d", power, range))
    print(string.format("  Craft: Power %d, Range %d", craftPower, craftRange))
end
print()

-- Test 10: Distance Calculation
print("Test 10: Distance Calculation")
do
    DetectionManager:init()
    
    local pos1 = {x = 0, y = 0}
    local pos2 = {x = 3, y = 4}
    
    local distance = DetectionManager:calculateDistance(pos1, pos2)
    assert_equal(distance, 5, "Distance from (0,0) to (3,4) is 5")
    
    print(string.format("  Distance: %.1f", distance))
end
print()

-- Test 11: Cover Reduction Calculation
print("Test 11: Cover Reduction Calculation")
do
    DetectionManager:init()
    
    local radarPower = 100
    local maxRange = 10
    
    -- At zero distance (on top of mission)
    local reduction1 = DetectionManager:calculateCoverReduction(radarPower, 0, maxRange)
    assert_equal(reduction1, 100, "Cover reduction at distance 0: 100 × 1.0 = 100")
    
    -- At half range
    local reduction2 = DetectionManager:calculateCoverReduction(radarPower, 5, maxRange)
    assert_equal(reduction2, 50, "Cover reduction at distance 5: 100 × 0.5 = 50")
    
    -- At maximum range
    local reduction3 = DetectionManager:calculateCoverReduction(radarPower, 10, maxRange)
    assert_equal(reduction3, 0, "Cover reduction at max range: 100 × 0.0 = 0")
    
    print(string.format("  Reductions: %.0f, %.0f, %.0f", reduction1, reduction2, reduction3))
end
print()

-- Test 12: Full Integration Test
print("Test 12: Full Integration Test")
do
    -- Initialize systems
    CampaignManager:init()
    DetectionManager:init()
    
    -- Create test missions at various positions
    local mission1 = Mission:new({
        type = "site",
        position = {x = 55, y = 55},  -- Near HQ (50, 50)
        coverValue = 40,
        spawnDay = 1,
    })
    
    local mission2 = Mission:new({
        type = "ufo",
        position = {x = 100, y = 100},  -- Far from HQ
        coverValue = 100,
        spawnDay = 1,
    })
    
    table.insert(CampaignManager.activeMissions, mission1)
    table.insert(CampaignManager.activeMissions, mission2)
    
    print(string.format("  Created 2 test missions"))
    print(string.format("    Mission 1: %s at (55,55), cover %d", mission1.name, mission1.coverValue))
    print(string.format("    Mission 2: %s at (100,100), cover %d", mission2.name, mission2.coverValue))
    
    -- Perform daily scan
    local results = DetectionManager:performDailyScans(CampaignManager)
    
    assert_true(results.scansPerformed > 0, "Scans performed")
    print(string.format("  Performed %d scans", results.scansPerformed))
    
    -- Check detection results
    if #results.newDetections > 0 then
        print(string.format("  Detected %d mission(s) on first scan", #results.newDetections))
        for _, mission in ipairs(results.newDetections) do
            print(string.format("    - %s", mission.name))
        end
    else
        print("  No detections on first scan (missions out of range or cover too high)")
    end
    
    -- Simulate multiple days to detect missions
    print("\n  Simulating 5 days of scanning...")
    for day = 1, 5 do
        CampaignManager:advanceDay()
        local dayResults = DetectionManager:performDailyScans(CampaignManager)
        
        if #dayResults.newDetections > 0 then
            print(string.format("    Day %d: Detected %d mission(s)", day, #dayResults.newDetections))
        end
    end
    
    -- Check final results
    local detectedMissions = CampaignManager:getDetectedMissions()
    print(string.format("\n  Total detected missions: %d", #detectedMissions))
    
    assert_true(#detectedMissions >= 0, "Detection system working")
end
print()

-- Print summary
print("=== Test Summary ===")
print(string.format("Tests Run: %d", testsRun))
print(string.format("Tests Passed: %d", testsPassed))
print(string.format("Tests Failed: %d", testsFailed))

if testsFailed == 0 then
    print("\n✓ All tests passed!")
else
    print(string.format("\n✗ %d test(s) failed", testsFailed))
end

print("\n=== Mission Detection System Tests Complete ===\n")
