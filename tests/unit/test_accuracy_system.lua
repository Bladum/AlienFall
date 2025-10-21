---Test Suite for Accuracy System
---Tests range-based accuracy calculations for weapon combat

local AccuracySystem = require("engine.battlescape.battle_ecs.accuracy_system")

local TestAccuracySystem = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper function to run a test
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

-- Helper function to assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

---Test: Point blank range (100% accuracy)
function TestAccuracySystem.testPointBlankRange()
    local baseAccuracy = 0.75  -- 75% base
    local maxRange = 30
    local distance = 5  -- Very close
    
    local accuracy = AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, baseAccuracy)
    assert(accuracy ~= nil, "Should return accuracy value")
    assert(accuracy >= baseAccuracy * 0.9, "Point blank should have high accuracy")
end

---Test: Optimal range accuracy
function TestAccuracySystem.testOptimalRange()
    local baseAccuracy = 0.75
    local maxRange = 30
    local distance = 15  -- 50% of max range
    
    local accuracy = AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, baseAccuracy)
    assert(accuracy ~= nil, "Should return accuracy value")
    assert(accuracy >= baseAccuracy * 0.75, "Optimal range should have good accuracy")
end

---Test: Long range accuracy penalty
function TestAccuracySystem.testLongRange()
    local baseAccuracy = 0.75
    local maxRange = 30
    local distance = 28  -- Near max range
    
    local accuracy = AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, baseAccuracy)
    assert(accuracy ~= nil, "Should return accuracy value")
    assert(accuracy < baseAccuracy, "Long range should have reduced accuracy")
end

---Test: Out of range returns nil
function TestAccuracySystem.testOutOfRange()
    local baseAccuracy = 0.75
    local maxRange = 30
    local distance = 40  -- Beyond max range
    
    local accuracy = AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, baseAccuracy)
    assert(accuracy == nil, "Out of range should return nil")
end

---Test: Zero distance
function TestAccuracySystem.testZeroDistance()
    local baseAccuracy = 0.75
    local maxRange = 30
    local distance = 0
    
    local accuracy = AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, baseAccuracy)
    assert(accuracy ~= nil, "Zero distance should be valid")
    assert(accuracy >= baseAccuracy * 0.9, "Zero distance should have maximum accuracy")
end

---Test: Calculate effective accuracy
function TestAccuracySystem.testEffectiveAccuracy()
    local baseAccuracy = 0.75
    local maxRange = 30
    local distance = 15
    
    local effective = AccuracySystem.calculateEffectiveAccuracy(distance, maxRange, baseAccuracy)
    assert(effective ~= nil, "Should return effective accuracy")
    assert(effective >= 0.0 and effective <= 1.0, "Effective accuracy should be 0.0-1.0")
end

---Test: Accuracy zone description
function TestAccuracySystem.testAccuracyZoneDescription()
    local maxRange = 30
    
    local desc = AccuracySystem.getAccuracyZoneDescription(5, maxRange)
    assert(desc ~= nil, "Should return zone description")
    assert(type(desc) == "string", "Description should be string")
    
    desc = AccuracySystem.getAccuracyZoneDescription(15, maxRange)
    assert(desc ~= nil, "Should return zone description for medium range")
    
    desc = AccuracySystem.getAccuracyZoneDescription(28, maxRange)
    assert(desc ~= nil, "Should return zone description for long range")
end

---Test: Accuracy zone color
function TestAccuracySystem.testAccuracyZoneColor()
    local maxRange = 30
    
    local color = AccuracySystem.getAccuracyZoneColor(5, maxRange)
    assert(color ~= nil, "Should return zone color")
    assert(type(color) == "table", "Color should be table")
    assert(#color >= 3, "Color should have RGB components")
end

---Test: Invalid parameters
function TestAccuracySystem.testInvalidParameters()
    -- Nil parameters
    local accuracy = AccuracySystem.calculateAccuracyMultiplier(nil, 30, 0.75)
    assert(accuracy == nil, "Nil distance should return nil")
    
    accuracy = AccuracySystem.calculateAccuracyMultiplier(10, nil, 0.75)
    assert(accuracy == nil, "Nil maxRange should return nil")
    
    accuracy = AccuracySystem.calculateAccuracyMultiplier(10, 30, nil)
    assert(accuracy == nil, "Nil baseAccuracy should return nil")
end

---Test: Accuracy progression across range
function TestAccuracySystem.testAccuracyProgression()
    local baseAccuracy = 1.0  -- Perfect base accuracy
    local maxRange = 30
    
    local accuracies = {}
    for dist = 0, 35, 5 do
        local acc = AccuracySystem.calculateAccuracyMultiplier(dist, maxRange, baseAccuracy)
        table.insert(accuracies, {distance = dist, accuracy = acc})
    end
    
    -- Verify accuracy decreases with distance (until out of range)
    for i = 1, #accuracies - 1 do
        if accuracies[i].accuracy and accuracies[i+1].accuracy then
            assert(accuracies[i].accuracy >= accuracies[i+1].accuracy,
                string.format("Accuracy should decrease with distance (%.2f >= %.2f at distances %d and %d)",
                    accuracies[i].accuracy, accuracies[i+1].accuracy,
                    accuracies[i].distance, accuracies[i+1].distance))
        end
    end
    
    print("[Accuracy Progression]")
    for _, data in ipairs(accuracies) do
        if data.accuracy then
            print(string.format("  Distance %d: %.1f%%", data.distance, data.accuracy * 100))
        else
            print(string.format("  Distance %d: OUT OF RANGE", data.distance))
        end
    end
end

---Test: Different weapon base accuracies
function TestAccuracySystem.testDifferentWeapons()
    local maxRange = 30
    local distance = 15
    
    -- Accurate weapon
    local accurateWeapon = AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, 0.95)
    
    -- Average weapon
    local averageWeapon = AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, 0.75)
    
    -- Inaccurate weapon
    local inaccurateWeapon = AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, 0.50)
    
    assert(accurateWeapon > averageWeapon, "Accurate weapon should have higher accuracy")
    assert(averageWeapon > inaccurateWeapon, "Average weapon should beat inaccurate weapon")
    
    print(string.format("[Weapon Comparison at %d tiles]", distance))
    print(string.format("  Accurate (95%%): %.1f%%", accurateWeapon * 100))
    print(string.format("  Average (75%%): %.1f%%", averageWeapon * 100))
    print(string.format("  Inaccurate (50%%): %.1f%%", inaccurateWeapon * 100))
end

-- Run all tests
function TestAccuracySystem.runAll()
    print("\n=== Running Accuracy System Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    runTest("Point Blank Range", TestAccuracySystem.testPointBlankRange)
    runTest("Optimal Range", TestAccuracySystem.testOptimalRange)
    runTest("Long Range Penalty", TestAccuracySystem.testLongRange)
    runTest("Out of Range", TestAccuracySystem.testOutOfRange)
    runTest("Zero Distance", TestAccuracySystem.testZeroDistance)
    runTest("Effective Accuracy", TestAccuracySystem.testEffectiveAccuracy)
    runTest("Accuracy Zone Description", TestAccuracySystem.testAccuracyZoneDescription)
    runTest("Accuracy Zone Color", TestAccuracySystem.testAccuracyZoneColor)
    runTest("Invalid Parameters", TestAccuracySystem.testInvalidParameters)
    runTest("Accuracy Progression", TestAccuracySystem.testAccuracyProgression)
    runTest("Different Weapons", TestAccuracySystem.testDifferentWeapons)
    
    print("\n=== Accuracy System Test Results ===")
    print(string.format("Total: %d, Passed: %d (%.1f%%), Failed: %d (%.1f%%)",
        testsPassed + testsFailed,
        testsPassed,
        (testsPassed / (testsPassed + testsFailed)) * 100,
        testsFailed,
        (testsFailed / (testsPassed + testsFailed)) * 100
    ))
    
    if testsFailed > 0 then
        print("\nFailed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  ✗ %s: %s", failure.name, failure.error))
        end
    else
        print("\n✓ All tests passed!")
    end
    
    return testsPassed, testsFailed
end

return TestAccuracySystem



