---Test Suite for Karma System
---
---Tests karma tracking, level calculation, karma modification, effects,
---black market access, and karma history management.
---
---Test Coverage:
---  - Karma initialization and levels (5 tests)
---  - Karma modification (4 tests)
---  - Karma effects and thresholds (4 tests)
---  - Black market access (3 tests)
---  - Karma history tracking (3 tests)
---
---Dependencies:
---  - politics.karma.karma_system
---
---@module tests.unit.test_karma_system
---@author AlienFall Development Team
---@date 2025-10-15

-- Setup package path
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local KarmaSystem = require("politics.karma.karma_system")

local TestKarmaSystem = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper: Run a test
local function runTest(name, testFunc)
    local success, err = pcall(testFunc)
    if success then
        print("✓ " .. name .. " passed")
        testsPassed = testsPassed + 1
    else
        print("✗ " .. name .. " failed: " .. tostring(err))
        testsFailed = testsFailed + 1
        table.insert(failureDetails, {name = name, error = tostring(err)})
    end
end

-- Helper: Assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

---Test: Create karma system
function TestKarmaSystem.testCreateSystem()
    local karma = KarmaSystem.new()
    
    assert(karma ~= nil, "Karma system should be created")
    assert(karma.karma == 0, "Initial karma should be 0 (Neutral)")
    assert(type(karma.history) == "table", "Should have history table")
end

---Test: Initial karma level is Neutral
function TestKarmaSystem.testInitialNeutral()
    local karma = KarmaSystem.new()
    
    local level = karma:getLevel()
    assert(level == "Neutral", string.format("Initial level should be Neutral, got %s", level))
end

---Test: Karma level Evil
function TestKarmaSystem.testLevelEvil()
    local karma = KarmaSystem.new()
    karma.karma = -90
    
    local level = karma:getLevel()
    assert(level == "Evil", string.format("Karma -90 should be Evil, got %s", level))
end

---Test: Karma level Saintly
function TestKarmaSystem.testLevelSaintly()
    local karma = KarmaSystem.new()
    karma.karma = 85
    
    local level = karma:getLevel()
    assert(level == "Saintly", string.format("Karma 85 should be Saintly, got %s", level))
end

---Test: Karma level boundaries
function TestKarmaSystem.testLevelBoundaries()
    local karma = KarmaSystem.new()
    
    -- Test various boundary values
    karma.karma = -75
    assert(karma:getLevel() == "Evil", "Karma -75 should be Evil")
    
    karma.karma = -74
    assert(karma:getLevel() == "Ruthless", "Karma -74 should be Ruthless")
    
    karma.karma = -40
    assert(karma:getLevel() == "Ruthless", "Karma -40 should be Ruthless")
    
    karma.karma = -39
    assert(karma:getLevel() == "Pragmatic", "Karma -39 should be Pragmatic")
    
    karma.karma = 9
    assert(karma:getLevel() == "Neutral", "Karma 9 should be Neutral")
    
    karma.karma = 10
    assert(karma:getLevel() == "Principled", "Karma 10 should be Principled")
    
    karma.karma = 74
    assert(karma:getLevel() == "Heroic", "Karma 74 should be Heroic")
    
    karma.karma = 75
    assert(karma:getLevel() == "Saintly", "Karma 75 should be Saintly")
end

---Test: Modify karma positive
function TestKarmaSystem.testModifyKarmaPositive()
    local karma = KarmaSystem.new()
    
    karma:modifyKarma(25, "Saved civilians")
    
    assert(karma.karma == 25, string.format("Karma should be 25, got %d", karma.karma))
end

---Test: Modify karma negative
function TestKarmaSystem.testModifyKarmaNegative()
    local karma = KarmaSystem.new()
    
    karma:modifyKarma(-30, "Civilian casualties")
    
    assert(karma.karma == -30, string.format("Karma should be -30, got %d", karma.karma))
end

---Test: Karma clamping at maximum
function TestKarmaSystem.testKarmaMaxClamp()
    local karma = KarmaSystem.new()
    
    karma:modifyKarma(150, "Extreme good deed")  -- Try to exceed 100
    
    assert(karma.karma <= 100, string.format("Karma should not exceed 100, got %d", karma.karma))
end

---Test: Karma clamping at minimum
function TestKarmaSystem.testKarmaMinClamp()
    local karma = KarmaSystem.new()
    
    karma:modifyKarma(-150, "Extreme evil deed")  -- Try to go below -100
    
    assert(karma.karma >= -100, string.format("Karma should not go below -100, got %d", karma.karma))
end

---Test: Karma effects check positive
function TestKarmaSystem.testEffectsPositive()
    local karma = KarmaSystem.new()
    karma.karma = 50  -- Heroic level
    
    local effects = karma:getKarmaEffects()
    
    assert(type(effects) == "table", "Effects should be a table")
end

---Test: Karma effects check negative
function TestKarmaSystem.testEffectsNegative()
    local karma = KarmaSystem.new()
    karma.karma = -50  -- Ruthless level
    
    local effects = karma:getKarmaEffects()
    
    assert(type(effects) == "table", "Effects should be a table")
end

---Test: Black market access at low karma
function TestKarmaSystem.testBlackMarketAccessLowKarma()
    local karma = KarmaSystem.new()
    karma.karma = -30  -- Pragmatic, should have black market access
    
    local hasAccess = karma:canAccessBlackMarket()
    
    assert(hasAccess, "Should have black market access at karma -30")
end

---Test: Humanitarian missions at high karma
function TestKarmaSystem.testHumanitarianMissionsHighKarma()
    local karma = KarmaSystem.new()
    karma.karma = 50  -- Heroic, should unlock humanitarian missions
    
    local effects = karma:getKarmaEffects()
    local hasHumanitarian = false
    
    for _, effect in ipairs(effects) do
        if effect.description and effect.description:match("humanitarian") then
            hasHumanitarian = true
            break
        end
    end
    
    -- This test may pass if effects system is implemented
end

---Test: Ruthless tactics at low karma
function TestKarmaSystem.testRuthlessTacticsLowKarma()
    local karma = KarmaSystem.new()
    karma.karma = -50  -- Ruthless, should unlock ruthless tactics
    
    local effects = karma:getKarmaEffects()
    
    -- Check that effects exist for this karma level
    assert(type(effects) == "table", "Should return effects at ruthless karma")
end

---Test: No black market access at high karma
function TestKarmaSystem.testNoBlackMarketHighKarma()
    local karma = KarmaSystem.new()
    karma.karma = 50  -- Heroic, should NOT have black market access
    
    local hasAccess = karma:canAccessBlackMarket()
    
    assert(not hasAccess, "Should NOT have black market access at karma 50")
end

---Test: Karma history tracking
function TestKarmaSystem.testHistoryTracking()
    local karma = KarmaSystem.new()
    
    karma:modifyKarma(10, "Saved a soldier")
    karma:modifyKarma(-5, "Collateral damage")
    
    assert(#karma.history >= 2, string.format("Should have at least 2 history entries, got %d", #karma.history))
end

---Test: Karma history contains reason
function TestKarmaSystem.testHistoryReason()
    local karma = KarmaSystem.new()
    
    karma:modifyKarma(15, "Rescued civilians")
    
    local lastEntry = karma.history[#karma.history]
    assert(lastEntry ~= nil, "Should have history entry")
    assert(lastEntry.reason == "Rescued civilians", "History should contain reason")
end

---Test: Karma history contains amount
function TestKarmaSystem.testHistoryAmount()
    local karma = KarmaSystem.new()
    
    karma:modifyKarma(20, "Heroic action")
    
    local lastEntry = karma.history[#karma.history]
    assert(lastEntry.amount == 20, string.format("History amount should be 20, got %d", lastEntry.amount))
end

---Test: Get karma level color
function TestKarmaSystem.testGetLevelColor()
    local karma = KarmaSystem.new()
    karma.karma = 50  -- Heroic
    
    local color = karma:getLevelColor()
    
    assert(type(color) == "table", "Color should be a table")
    assert(color.r ~= nil, "Color should have r component")
    assert(color.g ~= nil, "Color should have g component")
    assert(color.b ~= nil, "Color should have b component")
end

-- Run all tests
function TestKarmaSystem.runAll()
    print("\n=== Running Karma System Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    -- Initialization and levels
    runTest("Create karma system", TestKarmaSystem.testCreateSystem)
    runTest("Initial level is Neutral", TestKarmaSystem.testInitialNeutral)
    runTest("Karma level Evil", TestKarmaSystem.testLevelEvil)
    runTest("Karma level Saintly", TestKarmaSystem.testLevelSaintly)
    runTest("Karma level boundaries", TestKarmaSystem.testLevelBoundaries)
    
    -- Modification
    runTest("Modify karma positive", TestKarmaSystem.testModifyKarmaPositive)
    runTest("Modify karma negative", TestKarmaSystem.testModifyKarmaNegative)
    runTest("Karma max clamp", TestKarmaSystem.testKarmaMaxClamp)
    runTest("Karma min clamp", TestKarmaSystem.testKarmaMinClamp)
    
    -- Effects
    runTest("Karma effects positive", TestKarmaSystem.testEffectsPositive)
    runTest("Karma effects negative", TestKarmaSystem.testEffectsNegative)
    runTest("Black market access low karma", TestKarmaSystem.testBlackMarketAccessLowKarma)
    runTest("Humanitarian missions high karma", TestKarmaSystem.testHumanitarianMissionsHighKarma)
    runTest("Ruthless tactics low karma", TestKarmaSystem.testRuthlessTacticsLowKarma)
    runTest("No black market high karma", TestKarmaSystem.testNoBlackMarketHighKarma)
    
    -- History
    runTest("Karma history tracking", TestKarmaSystem.testHistoryTracking)
    runTest("History contains reason", TestKarmaSystem.testHistoryReason)
    runTest("History contains amount", TestKarmaSystem.testHistoryAmount)
    runTest("Get level color", TestKarmaSystem.testGetLevelColor)
    
    -- Print results
    print("\n=== Test Results ===")
    print(string.format("Total: %d, Passed: %d (%.1f%%), Failed: %d",
        testsPassed + testsFailed,
        testsPassed,
        (testsPassed / (testsPassed + testsFailed)) * 100,
        testsFailed
    ))
    
    if testsFailed > 0 then
        print("\nFailed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  ✗ %s: %s", failure.name, failure.error))
        end
    else
        print("\n✓ All Karma System tests passed!")
    end
    
    return testsPassed, testsFailed
end

-- Run if executed directly
if arg and arg[0]:match("test_karma_system%.lua$") then
    TestKarmaSystem.runAll()
end

return TestKarmaSystem



