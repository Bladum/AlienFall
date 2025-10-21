-- test_range_accuracy.lua
-- Unit tests for range and accuracy calculation systems

local RangeSystem = require("battlescape.battle.systems.range_system")
local AccuracySystem = require("battlescape.battle.systems.accuracy_system")
local WeaponSystem = require("battlescape.combat.weapon_system")
local ShootingSystem = require("battlescape.battle.systems.shooting_system")

local TestSuite = {}

-- Helper function for assertions
local function assertEquals(expected, actual, message)
    if expected ~= actual then
        error(string.format("ASSERT FAILED: %s\nExpected: %s\nActual: %s", message, tostring(expected), tostring(actual)))
    end
end

local function assertTrue(condition, message)
    if not condition then
        error(string.format("ASSERT FAILED: %s", message))
    end
end

local function assertFalse(condition, message)
    if condition then
        error(string.format("ASSERT FAILED: %s", message))
    end
end

local function assertNotNil(value, message)
    if value == nil then
        error(string.format("ASSERT FAILED: %s", message))
    end
end

-- Test Range System
function TestSuite.testRangeSystem()
    print("\n--- Testing Range System ---")

    -- Test distance calculation with axial coordinates
    local dist1 = RangeSystem.calculateDistance({q = 0, r = 0}, {q = 3, r = 0})
    assertEquals(3, dist1, "Distance from (0,0) to (3,0) should be 3")

    local dist2 = RangeSystem.calculateDistance({q = 0, r = 0}, {q = 1, r = 1})
    assertEquals(1, dist2, "Distance from (0,0) to (1,1) should be 1")

    -- Test distance calculation with offset coordinates
    local dist3 = RangeSystem.calculateDistance({x = 0, y = 0}, {x = 5, y = 5})
    assertTrue(dist3 > 0, "Distance calculation with offset coords should work")

    -- Test range zones
    assertEquals("optimal", RangeSystem.getRangeZone(5, 10), "5/10 should be optimal range")
    assertEquals("effective", RangeSystem.getRangeZone(8, 10), "8/10 should be effective range")
    assertEquals("long", RangeSystem.getRangeZone(12, 10), "12/10 should be long range")
    assertEquals("out_of_range", RangeSystem.getRangeZone(15, 10), "15/10 should be out of range")

    -- Test in range checks
    assertTrue(RangeSystem.isInRange(10, 10), "Exactly max range should be in range")
    assertTrue(RangeSystem.isInRange(12.5, 10), "125% of max range should be in range")
    assertFalse(RangeSystem.isInRange(12.6, 10), "More than 125% should be out of range")

    print("Range System: ALL TESTS PASSED")
end

-- Test Accuracy System
function TestSuite.testAccuracySystem()
    print("\n--- Testing Accuracy System ---")

    -- Test accuracy zones
    -- Pistol: 60% base accuracy, 12 tile range
    local baseAccuracy = 0.6
    local maxRange = 12

    -- Optimal range (0-75% = 9 tiles): 100% of base accuracy
    local acc1 = AccuracySystem.calculateEffectiveAccuracy(5, maxRange, baseAccuracy)
    assertEquals(60, acc1, "5 tiles should give 60% accuracy (optimal range)")

    -- Effective range (75-100% = 9-12 tiles): Linear drop from 100% to 50%
    local acc2 = AccuracySystem.calculateEffectiveAccuracy(10, maxRange, baseAccuracy)
    assertTrue(acc2 < 60 and acc2 > 30, "10 tiles should give accuracy between 30-60%")

    -- Long range (100-125% = 12-15 tiles): Linear drop from 50% to 0%
    local acc3 = AccuracySystem.calculateEffectiveAccuracy(14, maxRange, baseAccuracy)
    assertTrue(acc3 < 30 and acc3 >= 0, "14 tiles should give accuracy between 0-30%")

    -- Out of range
    local acc4 = AccuracySystem.calculateEffectiveAccuracy(16, maxRange, baseAccuracy)
    assertEquals(nil, acc4, "16 tiles should be out of range")

    -- Test zone descriptions
    assertEquals("Optimal Range", AccuracySystem.getAccuracyZoneDescription(5, maxRange), "5 tiles should be optimal")
    assertEquals("Effective Range", AccuracySystem.getAccuracyZoneDescription(10, maxRange), "10 tiles should be effective")
    assertEquals("Long Range", AccuracySystem.getAccuracyZoneDescription(14, maxRange), "14 tiles should be long")
    assertEquals("Out of Range", AccuracySystem.getAccuracyZoneDescription(16, maxRange), "16 tiles should be out of range")

    print("Accuracy System: ALL TESTS PASSED")
end

-- Test Weapon System
function TestSuite.testWeaponSystem()
    print("\n--- Testing Weapon System ---")

    -- Test loading weapons
    local weapons = WeaponSystem.loadWeapons()
    assertNotNil(weapons, "Weapons should load successfully")
    assertNotNil(weapons.pistol, "Pistol weapon should exist")

    -- Test pistol properties
    assertEquals(12, WeaponSystem.getMaxRange("pistol"), "Pistol range should be 12")
    assertEquals(3, WeaponSystem.getDamage("pistol"), "Pistol damage should be 3")
    assertEquals(0.6, WeaponSystem.getBaseAccuracy("pistol"), "Pistol accuracy should be 60%")
    assertTrue(WeaponSystem.isRanged("pistol"), "Pistol should be ranged")
    assertEquals("ranged", WeaponSystem.getWeaponType("pistol"), "Pistol type should be ranged")

    -- Test rifle properties
    assertEquals(20, WeaponSystem.getMaxRange("rifle"), "Rifle range should be 20")
    assertEquals(4, WeaponSystem.getDamage("rifle"), "Rifle damage should be 4")
    assertEquals(0.55, WeaponSystem.getBaseAccuracy("rifle"), "Rifle accuracy should be 55%")

    -- Test invalid weapon
    assertEquals(nil, WeaponSystem.getWeapon("nonexistent"), "Invalid weapon should return nil")
    assertEquals(0.5, WeaponSystem.getBaseAccuracy("nonexistent"), "Invalid weapon should return default accuracy")

    print("Weapon System: ALL TESTS PASSED")
end

-- Test Shooting System
function TestSuite.testShootingSystem()
    print("\n--- Testing Shooting System ---")

    -- Create mock units
    local shooter = {
        x = 5, y = 5,
        weapon1 = "pistol"
    }

    local target = {
        x = 10, y = 5  -- 5 tiles away
    }

    -- Test shooting info
    local info = ShootingSystem.getShootingInfo(shooter, target)
    assertTrue(info.canShoot, "Should be able to shoot at 5 tiles with pistol")
    assertEquals(60, info.accuracy, "Should have 60% accuracy at optimal range")
    assertEquals("optimal", info.rangeZone, "Should be optimal range zone")

    -- Test shooting at longer range
    target.x = 15  -- 10 tiles away
    info = ShootingSystem.getShootingInfo(shooter, target)
    assertTrue(info.canShoot, "Should be able to shoot at 10 tiles with pistol")
    assertTrue(info.accuracy < 60, "Accuracy should be reduced at longer range")

    -- Test shooting out of range
    target.x = 25  -- 20 tiles away
    info = ShootingSystem.getShootingInfo(shooter, target)
    assertFalse(info.canShoot, "Should not be able to shoot at 20 tiles with pistol")

    -- Test actual shooting (with mocked random)
    math.randomseed(12345)  -- For consistent testing
    target.x = 10  -- Back to 5 tiles
    local result = ShootingSystem.shoot(shooter, target)
    assertTrue(result.success, "Shooting should succeed")
    assertNotNil(result.hit, "Should have hit result")
    assertNotNil(result.accuracy, "Should have accuracy info")

    print("Shooting System: ALL TESTS PASSED")
end

-- Run all tests
function TestSuite.runAll()
    print("Running Range and Accuracy System Tests...")

    local success, error = pcall(function()
        TestSuite.testRangeSystem()
        TestSuite.testAccuracySystem()
        TestSuite.testWeaponSystem()
        TestSuite.testShootingSystem()
    end)

    if success then
        print("\n? ALL RANGE AND ACCURACY TESTS PASSED")
        return true
    else
        print("\n? TESTS FAILED: " .. error)
        return false
    end
end

return TestSuite
























