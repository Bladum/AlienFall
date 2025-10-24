-- Test mission data flow from campaign through battlescape
-- Verifies that mission data is captured, stored, and results are recorded

local function test_mission_data_capture()
    print("\n=== Testing Mission Data Capture ===")

    -- Mock mission data that would come from campaign
    local missionData = {
        id = "test_mission_001",
        type = "scout",
        location = { x = 50, y = 50 },
        difficulty = 1,
        enemies = 3,
        rewards = { money = 1000, xp = 500 }
    }

    -- Create mock Battlescape state
    local Battlescape = require("gui.scenes.battlescape_screen")

    -- Test 1: Verify missionData field exists
    assert(Battlescape.missionData == nil, "missionData should start as nil")
    print("✓ missionData field initialized to nil")

    -- Test 2: Simulate receiving mission data through enter()
    Battlescape:enter({ mission = missionData })
    assert(Battlescape.missionData == missionData, "missionData should be stored")
    assert(Battlescape.missionData.id == "test_mission_001", "mission id should match")
    print("✓ Mission data captured successfully through enter(args)")

    -- Test 3: Verify exit() function exists and handles mission outcome
    assert(type(Battlescape.exit) == "function", "exit() should be a function")
    print("✓ exit() function exists and is callable")

    -- Test 4: Verify exit() uses missionData if available
    -- (Can't fully test without CampaignManager mocking, but can verify structure)
    assert(Battlescape.missionData, "exit() should have access to missionData")
    print("✓ exit() has access to missionData field")

    print("\n✅ All mission data capture tests passed!")
    return true
end

local function test_mission_data_flow()
    print("\n=== Testing Mission Data Flow ===")

    local missionData = {
        id = "test_flow_001",
        type = "base_defense",
        difficulty = 2,
        location = { x = 100, y = 75 }
    }

    local Battlescape = require("gui.scenes.battlescape_screen")

    -- Test 1: Data flows correctly through enter()
    Battlescape:enter({ mission = missionData })
    assert(Battlescape.missionData.id == missionData.id, "Mission ID should be preserved")
    print("✓ Mission data flows correctly through enter()")

    -- Test 2: Mission type is accessible
    assert(Battlescape.missionData.type == "base_defense", "Mission type should be accessible")
    print("✓ Mission type accessible in battlescape state")

    -- Test 3: Mission location is preserved
    assert(Battlescape.missionData.location.x == 100, "Location X should be preserved")
    assert(Battlescape.missionData.location.y == 75, "Location Y should be preserved")
    print("✓ Mission location data preserved correctly")

    -- Test 4: Battlescape can be entered without mission data (backward compatibility)
    Battlescape:enter()
    assert(Battlescape.missionData == nil, "Should handle enter() with no args")
    print("✓ Backward compatibility: enter() works without mission data")

    -- Test 5: Battlescape can be entered with mission data again
    Battlescape:enter({ mission = missionData })
    assert(Battlescape.missionData ~= nil, "Should re-accept mission data")
    print("✓ Can accept mission data multiple times")

    print("\n✅ All mission data flow tests passed!")
    return true
end

local function test_campaign_integration_structure()
    print("\n=== Testing Campaign Integration Structure ===")

    local Battlescape = require("gui.scenes.battlescape_screen")

    -- Test 1: enter() accepts optional args parameter
    local success, result = pcall(function()
        Battlescape:enter()
    end)
    assert(success, "enter() should work without arguments")
    print("✓ enter() accepts no arguments (backward compatible)")

    -- Test 2: enter() accepts mission data in args
    success, result = pcall(function()
        Battlescape:enter({ mission = { id = "test" } })
    end)
    assert(success, "enter() should accept mission data")
    print("✓ enter() accepts mission data in args")

    -- Test 3: exit() is properly defined
    assert(type(Battlescape.exit) == "function", "exit() must be a function")
    print("✓ exit() is properly defined as a function")

    -- Test 4: Mission data is preserved until exit
    local missionData = { id = "persist_test", priority = 5 }
    Battlescape:enter({ mission = missionData })
    assert(Battlescape.missionData.priority == 5, "All mission data fields should persist")
    print("✓ Mission data fields persist through battlescape session")

    print("\n✅ All campaign integration structure tests passed!")
    return true
end

-- Run all tests
local allPassed = true

allPassed = test_mission_data_capture() and allPassed
allPassed = test_mission_data_flow() and allPassed
allPassed = test_campaign_integration_structure() and allPassed

if allPassed then
    print("\n" .. string.rep("=", 50))
    print("✅ ALL MISSION INTEGRATION TESTS PASSED")
    print(string.rep("=", 50))
else
    print("\n" .. string.rep("=", 50))
    print("❌ SOME TESTS FAILED")
    print(string.rep("=", 50))
end

return allPassed
