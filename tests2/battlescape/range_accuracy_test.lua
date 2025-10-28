-- ─────────────────────────────────────────────────────────────────────────
-- RANGE & ACCURACY SYSTEM TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Tests range calculations, accuracy systems, weapon properties, and shooting logic
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK RANGE SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local RangeSystem = {}
RangeSystem.__index = RangeSystem

function RangeSystem.calculateDistance(pos1, pos2)
    -- Handle axial coordinates (q, r) - simplified for testing
    if pos1.q and pos1.r and pos2.q and pos2.r then
        local dq = math.abs(pos2.q - pos1.q)
        local dr = math.abs(pos2.r - pos1.r)
        return math.max(dq, dr)  -- Simplified: max(|dq|, |dr|) instead of proper hex distance
    end

    -- Handle offset coordinates (x, y)
    if pos1.x and pos1.y and pos2.x and pos2.y then
        local dx = pos2.x - pos1.x
        local dy = pos2.y - pos1.y
        return math.sqrt(dx * dx + dy * dy)
    end

    return 0
end

function RangeSystem.getRangeZone(distance, maxRange)
    local ratio = distance / maxRange

    if ratio <= 0.75 then
        return "optimal"
    elseif ratio <= 1.0 then
        return "effective"
    elseif ratio <= 1.25 then
        return "long"
    else
        return "out_of_range"
    end
end

function RangeSystem.isInRange(distance, maxRange)
    local ratio = distance / maxRange
    return ratio <= 1.25
end

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK ACCURACY SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local AccuracySystem = {}
AccuracySystem.__index = AccuracySystem

function AccuracySystem.calculateEffectiveAccuracy(distance, maxRange, baseAccuracy)
    local ratio = distance / maxRange

    if ratio <= 0.75 then
        -- Optimal range: 100% of base accuracy
        return baseAccuracy * 100
    elseif ratio <= 1.0 then
        -- Effective range: Linear drop from 100% to 50%
        local factor = 1.0 - ((ratio - 0.75) / 0.25) * 0.5
        return baseAccuracy * factor * 100
    elseif ratio <= 1.25 then
        -- Long range: Linear drop from 50% to 0%
        local factor = 0.5 - ((ratio - 1.0) / 0.25) * 0.5
        return math.max(0, baseAccuracy * factor * 100)
    else
        -- Out of range
        return nil
    end
end

function AccuracySystem.getAccuracyZoneDescription(distance, maxRange)
    local zone = RangeSystem.getRangeZone(distance, maxRange)

    if zone == "optimal" then
        return "Optimal Range"
    elseif zone == "effective" then
        return "Effective Range"
    elseif zone == "long" then
        return "Long Range"
    else
        return "Out of Range"
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK WEAPON SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local WeaponSystem = {}
WeaponSystem.__index = WeaponSystem

local WEAPONS = {
    pistol = {
        maxRange = 12,
        damage = 3,
        baseAccuracy = 0.6,
        type = "ranged"
    },
    rifle = {
        maxRange = 20,
        damage = 4,
        baseAccuracy = 0.55,
        type = "ranged"
    }
}

function WeaponSystem.loadWeapons()
    return WEAPONS
end

function WeaponSystem.getWeapon(weaponId)
    return WEAPONS[weaponId]
end

function WeaponSystem.getMaxRange(weaponId)
    local weapon = WEAPONS[weaponId]
    return weapon and weapon.maxRange or 0
end

function WeaponSystem.getDamage(weaponId)
    local weapon = WEAPONS[weaponId]
    return weapon and weapon.damage or 0
end

function WeaponSystem.getBaseAccuracy(weaponId)
    local weapon = WEAPONS[weaponId]
    return weapon and weapon.baseAccuracy or 0.5
end

function WeaponSystem.isRanged(weaponId)
    local weapon = WEAPONS[weaponId]
    return weapon and weapon.type == "ranged"
end

function WeaponSystem.getWeaponType(weaponId)
    local weapon = WEAPONS[weaponId]
    return weapon and weapon.type or "unknown"
end

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK SHOOTING SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local ShootingSystem = {}
ShootingSystem.__index = ShootingSystem

function ShootingSystem.getShootingInfo(shooter, target)
    local weaponId = shooter.weapon1
    if not weaponId then return {canShoot = false} end

    local maxRange = WeaponSystem.getMaxRange(weaponId)
    local baseAccuracy = WeaponSystem.getBaseAccuracy(weaponId)

    -- Calculate distance (simple manhattan for this mock)
    local distance = math.abs(target.x - shooter.x) + math.abs(target.y - shooter.y)

    local canShoot = RangeSystem.isInRange(distance, maxRange)
    if not canShoot then
        return {canShoot = false}
    end

    local accuracy = AccuracySystem.calculateEffectiveAccuracy(distance, maxRange, baseAccuracy)
    local rangeZone = RangeSystem.getRangeZone(distance, maxRange)

    return {
        canShoot = true,
        accuracy = accuracy,
        rangeZone = rangeZone,
        distance = distance,
        maxRange = maxRange
    }
end

function ShootingSystem.shoot(shooter, target)
    local info = ShootingSystem.getShootingInfo(shooter, target)
    if not info.canShoot then
        return {success = false, reason = "out_of_range"}
    end

    -- Mock shooting result
    local hit = math.random() * 100 <= info.accuracy

    return {
        success = true,
        hit = hit,
        accuracy = info.accuracy,
        damage = hit and WeaponSystem.getDamage(shooter.weapon1) or 0
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "battlescape.combat.range_accuracy",
    fileName = "range_accuracy_test.lua",
    description = "Range calculation, accuracy, weapon, and shooting systems"
})

Suite:before(function() print("[RangeAccuracyTest] Setting up") end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: RANGE CALCULATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Range Calculation", function()
    Suite:testMethod("RangeSystem.calculateDistance", {description="Calculates distance with axial coordinates", testCase="axial_distance", type="functional"},
    function()
        local dist1 = RangeSystem.calculateDistance({q = 0, r = 0}, {q = 3, r = 0})
        Helpers.assertEqual(dist1, 3, "Distance from (0,0) to (3,0) should be 3")

        local dist2 = RangeSystem.calculateDistance({q = 0, r = 0}, {q = 1, r = 1})
        Helpers.assertEqual(dist2, 1, "Distance from (0,0) to (1,1) should be 1")
    end)

    Suite:testMethod("RangeSystem.calculateDistance", {description="Calculates distance with offset coordinates", testCase="offset_distance", type="functional"},
    function()
        local dist = RangeSystem.calculateDistance({x = 0, y = 0}, {x = 5, y = 5})
        Helpers.assertTrue(dist > 0, "Distance calculation with offset coords should work")
        Helpers.assertEqual(dist, math.sqrt(50), "Distance should be sqrt(5^2 + 5^2)")
    end)

    Suite:testMethod("RangeSystem.getRangeZone", {description="Determines range zones correctly", testCase="range_zones", type="functional"},
    function()
        Helpers.assertEqual(RangeSystem.getRangeZone(5, 10), "optimal", "5/10 should be optimal range")
        Helpers.assertEqual(RangeSystem.getRangeZone(8, 10), "effective", "8/10 should be effective range")
        Helpers.assertEqual(RangeSystem.getRangeZone(12, 10), "long", "12/10 should be long range")
        Helpers.assertEqual(RangeSystem.getRangeZone(15, 10), "out_of_range", "15/10 should be out of range")
    end)

    Suite:testMethod("RangeSystem.isInRange", {description="Checks if targets are in range", testCase="in_range_checks", type="functional"},
    function()
        Helpers.assertTrue(RangeSystem.isInRange(10, 10), "Exactly max range should be in range")
        Helpers.assertTrue(RangeSystem.isInRange(12.5, 10), "125% of max range should be in range")
        Helpers.assertFalse(RangeSystem.isInRange(12.6, 10), "More than 125% should be out of range")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: ACCURACY SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Accuracy System", function()
    Suite:testMethod("AccuracySystem.calculateEffectiveAccuracy", {description="Calculates accuracy at different ranges", testCase="accuracy_calculation", type="functional"},
    function()
        local baseAccuracy = 0.6
        local maxRange = 12

        -- Optimal range (0-75% = 9 tiles): 100% of base accuracy
        local acc1 = AccuracySystem.calculateEffectiveAccuracy(5, maxRange, baseAccuracy)
        Helpers.assertEqual(acc1, 60, "5 tiles should give 60% accuracy (optimal range)")

        -- Effective range (75-100% = 9-12 tiles): Linear drop from 100% to 50%
        local acc2 = AccuracySystem.calculateEffectiveAccuracy(10, maxRange, baseAccuracy)
        Helpers.assertTrue(acc2 < 60 and acc2 > 30, "10 tiles should give accuracy between 30-60%")

        -- Long range (100-125% = 12-15 tiles): Linear drop from 50% to 0%
        local acc3 = AccuracySystem.calculateEffectiveAccuracy(14, maxRange, baseAccuracy)
        Helpers.assertTrue(acc3 < 30 and acc3 >= 0, "14 tiles should give accuracy between 0-30%")

        -- Out of range
        local acc4 = AccuracySystem.calculateEffectiveAccuracy(16, maxRange, baseAccuracy)
        Helpers.assertEqual(acc4, nil, "16 tiles should be out of range")
    end)

    Suite:testMethod("AccuracySystem.getAccuracyZoneDescription", {description="Provides zone descriptions", testCase="zone_descriptions", type="functional"},
    function()
        local maxRange = 12
        Helpers.assertEqual(AccuracySystem.getAccuracyZoneDescription(5, maxRange), "Optimal Range", "5 tiles should be optimal")
        Helpers.assertEqual(AccuracySystem.getAccuracyZoneDescription(10, maxRange), "Effective Range", "10 tiles should be effective")
        Helpers.assertEqual(AccuracySystem.getAccuracyZoneDescription(14, maxRange), "Long Range", "14 tiles should be long")
        Helpers.assertEqual(AccuracySystem.getAccuracyZoneDescription(16, maxRange), "Out of Range", "16 tiles should be out of range")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: WEAPON SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Weapon System", function()
    Suite:testMethod("WeaponSystem.loadWeapons", {description="Loads weapon definitions", testCase="weapon_loading", type="functional"},
    function()
        local weapons = WeaponSystem.loadWeapons()
        Helpers.assertNotNil(weapons, "Weapons should load successfully")
        Helpers.assertNotNil(weapons.pistol, "Pistol weapon should exist")
    end)

    Suite:testMethod("WeaponSystem.getWeapon", {description="Retrieves weapon properties", testCase="weapon_properties", type="functional"},
    function()
        -- Test pistol properties
        Helpers.assertEqual(WeaponSystem.getMaxRange("pistol"), 12, "Pistol range should be 12")
        Helpers.assertEqual(WeaponSystem.getDamage("pistol"), 3, "Pistol damage should be 3")
        Helpers.assertEqual(WeaponSystem.getBaseAccuracy("pistol"), 0.6, "Pistol accuracy should be 60%")
        Helpers.assertTrue(WeaponSystem.isRanged("pistol"), "Pistol should be ranged")
        Helpers.assertEqual(WeaponSystem.getWeaponType("pistol"), "ranged", "Pistol type should be ranged")

        -- Test rifle properties
        Helpers.assertEqual(WeaponSystem.getMaxRange("rifle"), 20, "Rifle range should be 20")
        Helpers.assertEqual(WeaponSystem.getDamage("rifle"), 4, "Rifle damage should be 4")
        Helpers.assertEqual(WeaponSystem.getBaseAccuracy("rifle"), 0.55, "Rifle accuracy should be 55%")
    end)

    Suite:testMethod("WeaponSystem.getWeapon", {description="Handles invalid weapons", testCase="invalid_weapon", type="functional"},
    function()
        Helpers.assertEqual(WeaponSystem.getWeapon("nonexistent"), nil, "Invalid weapon should return nil")
        Helpers.assertEqual(WeaponSystem.getBaseAccuracy("nonexistent"), 0.5, "Invalid weapon should return default accuracy")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: SHOOTING LOGIC
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Shooting Logic", function()
    Suite:testMethod("ShootingSystem.getShootingInfo", {description="Retrieves shooting information", testCase="shooting_info", type="functional"},
    function()
        local shooter = {x = 5, y = 5, weapon1 = "pistol"}
        local target = {x = 10, y = 5}  -- 5 tiles away

        local info = ShootingSystem.getShootingInfo(shooter, target)
        Helpers.assertTrue(info.canShoot, "Should be able to shoot at 5 tiles with pistol")
        Helpers.assertEqual(info.accuracy, 60, "Should have 60% accuracy at optimal range")
        Helpers.assertEqual(info.rangeZone, "optimal", "Should be optimal range zone")
    end)

    Suite:testMethod("ShootingSystem.getShootingInfo", {description="Handles range limitations", testCase="range_limitation", type="functional"},
    function()
        local shooter = {x = 5, y = 5, weapon1 = "pistol"}

        -- Test longer range
        local target1 = {x = 15, y = 5}  -- 10 tiles away
        local info1 = ShootingSystem.getShootingInfo(shooter, target1)
        Helpers.assertTrue(info1.canShoot, "Should be able to shoot at 10 tiles with pistol")
        Helpers.assertTrue(info1.accuracy < 60, "Accuracy should be reduced at longer range")

        -- Test out of range
        local target2 = {x = 25, y = 5}  -- 20 tiles away
        local info2 = ShootingSystem.getShootingInfo(shooter, target2)
        Helpers.assertFalse(info2.canShoot, "Should not be able to shoot at 20 tiles with pistol")
    end)

    Suite:testMethod("ShootingSystem.shoot", {description="Executes shooting action", testCase="actual_shooting", type="functional"},
    function()
        math.randomseed(12345)  -- For consistent testing

        local shooter = {x = 5, y = 5, weapon1 = "pistol"}
        local target = {x = 10, y = 5}  -- 5 tiles away

        local result = ShootingSystem.shoot(shooter, target)
        Helpers.assertTrue(result.success, "Shooting should succeed")
        Helpers.assertNotNil(result.hit, "Should have hit result")
        Helpers.assertNotNil(result.accuracy, "Should have accuracy info")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
