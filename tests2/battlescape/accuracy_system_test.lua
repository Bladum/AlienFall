-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Accuracy System
-- FILE: tests2/battlescape/accuracy_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for weapon accuracy calculations including range-based modifiers,
-- cover effects, weapon type variations, and edge case handling.
--
-- Coverage:
--   - Range-based accuracy (point-blank, optimal, long-range, out-of-range)
--   - Accuracy multipliers and modifier stacking
--   - Cover system integration
--   - Weapon type variations
--   - Edge cases and boundary conditions
--   - Performance benchmarks
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK ACCURACY SYSTEM
-- ─────────────────────────────────────────────────────────────────────────
-- Provides accuracy calculation functions without requiring full engine
-- ─────────────────────────────────────────────────────────────────────────

local MockAccuracySystem = {}
MockAccuracySystem.__index = MockAccuracySystem

---Create new accuracy system instance
function MockAccuracySystem:new()
    local self = setmetatable({}, MockAccuracySystem)

    -- Default accuracy profiles for weapons
    self.weaponProfiles = {
        pistol = {
            baseAccuracy = 80,
            maxRange = 15,
            optimalRange = 8,
            pointBlankBonus = 1.2,  -- 20% bonus at point-blank
            longRangePenalty = 0.7  -- 30% penalty at max range
        },
        rifle = {
            baseAccuracy = 75,
            maxRange = 25,
            optimalRange = 12,
            pointBlankBonus = 1.1,  -- 10% bonus at point-blank
            longRangePenalty = 0.8  -- 20% penalty at max range
        },
        smg = {
            baseAccuracy = 70,
            maxRange = 12,
            optimalRange = 6,
            pointBlankBonus = 1.25,  -- 25% bonus at point-blank
            longRangePenalty = 0.6   -- 40% penalty at max range
        },
        shotgun = {
            baseAccuracy = 85,
            maxRange = 8,
            optimalRange = 3,
            pointBlankBonus = 1.3,   -- 30% bonus at point-blank
            longRangePenalty = 0.4   -- 60% penalty at max range
        }
    }

    -- Cover modifier profiles
    self.coverTypes = {
        none = 1.0,
        light = 0.85,      -- 15% reduction
        heavy = 0.65,      -- 35% reduction
        full = 0.4         -- 60% reduction
    }

    return self
end

---Register custom weapon profile
function MockAccuracySystem:registerWeapon(weaponName, profile)
    self.weaponProfiles[weaponName] = profile
end

---Calculate accuracy based on range and weapon type
---@param weaponType string - Type of weapon (pistol, rifle, smg, shotgun)
---@param distance number - Distance in tiles from target
---@return number|nil - Accuracy percentage (0-100), or nil if out of range
function MockAccuracySystem:calculateAccuracy(weaponType, distance)
    local profile = self.weaponProfiles[weaponType]
    if not profile then
        error("Unknown weapon type: " .. weaponType)
    end

    -- Validate distance
    if distance < 0 then
        error("Distance cannot be negative: " .. distance)
    end

    -- Out of range check
    if distance > profile.maxRange then
        return nil
    end

    -- Point-blank range (distance 0)
    if distance == 0 then
        return math.min(profile.baseAccuracy * profile.pointBlankBonus, 100)
    end

    -- Optimal range (100% of base accuracy)
    if distance <= profile.optimalRange then
        return profile.baseAccuracy
    end

    -- Long range (linear interpolation between optimal and max)
    local rangeFromOptimal = distance - profile.optimalRange
    local rangeRemaining = profile.maxRange - profile.optimalRange
    local rangeRatio = rangeFromOptimal / rangeRemaining

    -- Interpolate from base accuracy to long-range penalty
    local multiplier = 1.0 - (rangeRatio * (1.0 - profile.longRangePenalty))
    return math.floor(profile.baseAccuracy * multiplier)
end

---Apply cover modifier to accuracy
---@param accuracy number - Base accuracy percentage
---@param coverType string - Type of cover (none, light, heavy, full)
---@return number|nil - Modified accuracy
function MockAccuracySystem:applyCoverModifier(accuracy, coverType)
    if not accuracy then return nil end

    local modifier = self.coverTypes[coverType]
    if not modifier then
        error("Unknown cover type: " .. coverType)
    end

    return math.floor(accuracy * modifier)
end

---Calculate hit probability with all modifiers
---@param weaponType string - Weapon type
---@param distance number - Distance to target
---@param coverType string - Target's cover type
---@return number|nil - Final accuracy percentage (0-100)
function MockAccuracySystem:calculateFinalAccuracy(weaponType, distance, coverType)
    local baseAccuracy = self:calculateAccuracy(weaponType, distance)
    if not baseAccuracy then return nil end

    return self:applyCoverModifier(baseAccuracy, coverType or "none")
end

---Get weapon profile (for verification)
---@param weaponType string - Weapon type
---@return table - Weapon profile configuration
function MockAccuracySystem:getProfile(weaponType)
    return Helpers.deepCopy(self.weaponProfiles[weaponType])
end

---Calculate accuracy penalty for specific distance
---@param weaponType string - Weapon type
---@param distance number - Distance in tiles
---@return number - Penalty multiplier (0.0-1.0)
function MockAccuracySystem:getPenaltyMultiplier(weaponType, distance)
    local profile = self.weaponProfiles[weaponType]
    if not profile then
        error("Unknown weapon type: " .. weaponType)
    end

    if distance <= profile.optimalRange then
        return 1.0
    end

    if distance > profile.maxRange then
        return 0.0
    end

    local rangeFromOptimal = distance - profile.optimalRange
    local rangeRemaining = profile.maxRange - profile.optimalRange
    local rangeRatio = rangeFromOptimal / rangeRemaining

    return 1.0 - (rangeRatio * (1.0 - profile.longRangePenalty))
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE SETUP
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.systems.accuracy_system",
    fileName = "accuracy_system.lua",
    description = "Weapon accuracy system - range modifiers, cover effects, calculations"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: RANGE-BASED ACCURACY CALCULATIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Range-Based Accuracy", function()

    Suite:testMethod("AccuracySystem:calculateAccuracy", {
        description = "Point-blank range (distance 0) receives accuracy bonus",
        testCase = "point_blank_bonus",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- Pistol: base 80 * 1.2 bonus = 96
        local result = accuracy:calculateAccuracy("pistol", 0)
        Helpers.assertEqual(result, 96, "Point-blank pistol should get 20% bonus")

        -- Shotgun: base 85 * 1.3 bonus = 110.5, capped at 100
        result = accuracy:calculateAccuracy("shotgun", 0)
        Helpers.assertEqual(result, 100, "Point-blank shotgun should be capped at 100%")
    end)

    Suite:testMethod("AccuracySystem:calculateAccuracy", {
        description = "Optimal range (within weapon's sweet spot) maintains base accuracy",
        testCase = "optimal_range_maintenance",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- Pistol: optimal range is 8, base accuracy is 80
        local result = accuracy:calculateAccuracy("pistol", 4)
        Helpers.assertEqual(result, 80, "Within optimal range should maintain base accuracy")

        result = accuracy:calculateAccuracy("pistol", 8)
        Helpers.assertEqual(result, 80, "At optimal range limit should maintain base accuracy")

        -- Rifle: optimal range is 12
        result = accuracy:calculateAccuracy("rifle", 10)
        Helpers.assertEqual(result, 75, "Rifle within optimal range maintains 75% base")
    end)

    Suite:testMethod("AccuracySystem:calculateAccuracy", {
        description = "Long-range distances receive accuracy penalties with linear interpolation",
        testCase = "long_range_penalty",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- Pistol: optimal 8, max 15, base 80, penalty 0.7
        -- At distance 12: ratio=(12-8)/(15-8)=4/7≈0.57, mult=1-0.57*(1-0.7)≈0.83, acc≈66
        local result = accuracy:calculateAccuracy("pistol", 12)
        Helpers.assertGreater(result, 60, "Long-range should be reduced but still viable")
        Helpers.assertLess(result, 75, "Long-range should be less than optimal")
    end)

    Suite:testMethod("AccuracySystem:calculateAccuracy", {
        description = "Out-of-range distances return nil (impossible shot)",
        testCase = "out_of_range",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        local result = accuracy:calculateAccuracy("pistol", 16)
        Helpers.assertNil(result, "Distance beyond max range should return nil")

        result = accuracy:calculateAccuracy("rifle", 26)
        Helpers.assertNil(result, "Rifle beyond 25 tiles should be impossible")
    end)

    Suite:testMethod("AccuracySystem:calculateAccuracy", {
        description = "Weapon profiles vary appropriately (SMG vs Rifle)",
        testCase = "weapon_variation",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- SMG (70 base, optimal 6) vs Rifle (75 base, optimal 12) at mid-range
        -- Both within optimal, so SMG (70) < Rifle (75) at distance 3
        local smgMid = accuracy:calculateAccuracy("smg", 3)
        local rifleMid = accuracy:calculateAccuracy("rifle", 3)
        Helpers.assertLess(smgMid, rifleMid, "Rifle should be more accurate than SMG at mid distance")

        -- Shotgun better at point-blank
        local shotgunClose = accuracy:calculateAccuracy("shotgun", 0)
        local rifleClose = accuracy:calculateAccuracy("rifle", 0)
        Helpers.assertGreater(shotgunClose, rifleClose, "Shotgun should be better at point-blank")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: ACCURACY MODIFIERS AND STACKING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Accuracy Modifiers", function()

    Suite:testMethod("AccuracySystem:applyCoverModifier", {
        description = "No cover applies 1.0x multiplier (no effect)",
        testCase = "no_cover",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        local result = accuracy:applyCoverModifier(80, "none")
        Helpers.assertEqual(result, 80, "No cover should not modify accuracy")
    end)

    Suite:testMethod("AccuracySystem:applyCoverModifier", {
        description = "Light cover reduces accuracy by 15%",
        testCase = "light_cover",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- 80 * 0.85 = 68
        local result = accuracy:applyCoverModifier(80, "light")
        Helpers.assertEqual(result, 68, "Light cover should reduce accuracy by 15%")
    end)

    Suite:testMethod("AccuracySystem:applyCoverModifier", {
        description = "Heavy cover reduces accuracy by 35%",
        testCase = "heavy_cover",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- 80 * 0.65 = 52
        local result = accuracy:applyCoverModifier(80, "heavy")
        Helpers.assertEqual(result, 52, "Heavy cover should reduce accuracy by 35%")
    end)

    Suite:testMethod("AccuracySystem:applyCoverModifier", {
        description = "Full cover significantly reduces accuracy by 60%",
        testCase = "full_cover",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- 80 * 0.4 = 32
        local result = accuracy:applyCoverModifier(80, "full")
        Helpers.assertEqual(result, 32, "Full cover should reduce accuracy by 60%")
    end)

    Suite:testMethod("AccuracySystem:applyCoverModifier", {
        description = "Nil accuracy input returns nil (out of range)",
        testCase = "nil_input",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        local result = accuracy:applyCoverModifier(nil, "none")
        Helpers.assertNil(result, "Nil accuracy should return nil")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: COMBINED CALCULATIONS (Range + Cover)
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Combined Range & Cover Effects", function()

    Suite:testMethod("AccuracySystem:calculateFinalAccuracy", {
        description = "Close range with no cover maintains high accuracy",
        testCase = "close_no_cover",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        local result = accuracy:calculateFinalAccuracy("pistol", 0, "none")
        Helpers.assertEqual(result, 96, "Point-blank pistol with no cover = 96%")
    end)

    Suite:testMethod("AccuracySystem:calculateFinalAccuracy", {
        description = "Close range with cover reduces accuracy appropriately",
        testCase = "close_with_cover",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- Point-blank pistol (96%) with light cover (×0.85) = 81.6 → 81
        local result = accuracy:calculateFinalAccuracy("pistol", 0, "light")
        Helpers.assertEqual(result, 81, "Point-blank with light cover should be ~81%")
    end)

    Suite:testMethod("AccuracySystem:calculateFinalAccuracy", {
        description = "Long range with heavy cover creates difficult shot",
        testCase = "long_range_heavy_cover",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- Long range reduces accuracy, then heavy cover applies
        local result = accuracy:calculateFinalAccuracy("pistol", 14, "heavy")
        Helpers.assertGreater(result, 0, "Should still be possible")
        Helpers.assertLess(result, 50, "Should be difficult shot")
    end)

    Suite:testMethod("AccuracySystem:calculateFinalAccuracy", {
        description = "Out-of-range returns nil regardless of cover",
        testCase = "out_of_range_cover",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        local result = accuracy:calculateFinalAccuracy("pistol", 20, "none")
        Helpers.assertNil(result, "Out of range should return nil")

        result = accuracy:calculateFinalAccuracy("pistol", 20, "light")
        Helpers.assertNil(result, "Out of range should return nil even with cover modifier")
    end)

    Suite:testMethod("AccuracySystem:calculateFinalAccuracy", {
        description = "Accuracy never exceeds 100% after modifiers",
        testCase = "accuracy_cap",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        -- Try point-blank shotgun (would be 110.5, capped at 100)
        local result = accuracy:calculateFinalAccuracy("shotgun", 0, "none")
        Helpers.assertLessOrEqual(result, 100, "Accuracy should never exceed 100%")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: EDGE CASES AND ERROR HANDLING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Edge Cases & Validation", function()

    Suite:testMethod("AccuracySystem:calculateAccuracy", {
        description = "Zero distance is treated as point-blank, not error",
        testCase = "zero_distance",
        type = "edge_case"
    }, function()
        local accuracy = MockAccuracySystem:new()

        local result = accuracy:calculateAccuracy("pistol", 0)
        Helpers.assertNotNil(result, "Zero distance should be valid")
        Helpers.assertGreater(result, 0, "Point-blank should have positive accuracy")
    end)

    Suite:testMethod("AccuracySystem:calculateAccuracy", {
        description = "Negative distance throws error",
        testCase = "negative_distance",
        type = "error_handling"
    }, function()
        local accuracy = MockAccuracySystem:new()

        Helpers.assertThrows(
            function() accuracy:calculateAccuracy("pistol", -5) end,
            "Distance cannot be negative",
            "Negative distance should throw error"
        )
    end)

    Suite:testMethod("AccuracySystem:calculateAccuracy", {
        description = "Unknown weapon type throws error",
        testCase = "unknown_weapon",
        type = "error_handling"
    }, function()
        local accuracy = MockAccuracySystem:new()

        Helpers.assertThrows(
            function() accuracy:calculateAccuracy("raygun", 5) end,
            "Unknown weapon type",
            "Unknown weapon should throw error"
        )
    end)

    Suite:testMethod("AccuracySystem:applyCoverModifier", {
        description = "Unknown cover type throws error",
        testCase = "unknown_cover",
        type = "error_handling"
    }, function()
        local accuracy = MockAccuracySystem:new()

        Helpers.assertThrows(
            function() accuracy:applyCoverModifier(80, "invisible") end,
            "Unknown cover type",
            "Unknown cover should throw error"
        )
    end)

    Suite:testMethod("AccuracySystem:registerWeapon", {
        description = "Custom weapon profiles can be registered",
        testCase = "custom_weapon",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        accuracy:registerWeapon("plasma_rifle", {
            baseAccuracy = 85,
            maxRange = 30,
            optimalRange = 15,
            pointBlankBonus = 1.15,
            longRangePenalty = 0.75
        })

        local result = accuracy:calculateAccuracy("plasma_rifle", 15)
        Helpers.assertEqual(result, 85, "Custom weapon should work at optimal range")

        -- Out of default range
        local profile = accuracy:getProfile("plasma_rifle")
        Helpers.assertEqual(profile.baseAccuracy, 85, "Custom profile should persist")
    end)

    Suite:testMethod("AccuracySystem:getPenaltyMultiplier", {
        description = "Penalty multiplier is 1.0 within optimal range",
        testCase = "multiplier_optimal",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        local mult = accuracy:getPenaltyMultiplier("pistol", 5)
        Helpers.assertEqual(mult, 1.0, "Within optimal range = 1.0 multiplier")
    end)

    Suite:testMethod("AccuracySystem:getPenaltyMultiplier", {
        description = "Penalty multiplier is 0.0 beyond max range",
        testCase = "multiplier_max_range",
        type = "functional"
    }, function()
        local accuracy = MockAccuracySystem:new()

        local mult = accuracy:getPenaltyMultiplier("pistol", 20)
        Helpers.assertEqual(mult, 0.0, "Beyond max range = 0.0 multiplier")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: PERFORMANCE BENCHMARKS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Performance", function()

    Suite:testMethod("AccuracySystem:calculateAccuracy", {
        description = "1000 accuracy calculations complete within reasonable time",
        testCase = "calculation_throughput",
        type = "performance"
    }, function()
        local accuracy = MockAccuracySystem:new()
        local startTime = os.clock()
        local iterations = 1000

        local weapons = {"pistol", "rifle", "smg", "shotgun"}

        for i = 1, iterations do
            local weapon = weapons[((i - 1) % 4) + 1]
            local distance = math.random(0, 25)
            accuracy:calculateAccuracy(weapon, distance)
        end

        local elapsed = os.clock() - startTime
        local avgTime = (elapsed / iterations) * 1000000  -- microseconds

        print("[Accuracy Performance] 1000 calculations: " ..
              string.format("%.2f ms", elapsed * 1000) ..
              " (avg: " .. string.format("%.2f µs", avgTime) .. " per call)")

        Helpers.assertLess(elapsed, 0.05, "1000 calculations should complete in <50ms")
    end)

    Suite:testMethod("AccuracySystem:calculateFinalAccuracy", {
        description = "Combined calculations (range + cover) maintain performance",
        testCase = "final_accuracy_throughput",
        type = "performance"
    }, function()
        local accuracy = MockAccuracySystem:new()
        local startTime = os.clock()
        local iterations = 1000

        local weapons = {"pistol", "rifle", "smg", "shotgun"}
        local covers = {"none", "light", "heavy", "full"}

        for i = 1, iterations do
            local weapon = weapons[((i - 1) % 4) + 1]
            local cover = covers[((i - 1) % 4) + 1]
            local distance = math.random(0, 20)
            accuracy:calculateFinalAccuracy(weapon, distance, cover)
        end

        local elapsed = os.clock() - startTime

        print("[Accuracy Performance] 1000 final calculations: " ..
              string.format("%.2f ms", elapsed * 1000))

        Helpers.assertLess(elapsed, 0.05, "1000 final calculations should complete in <50ms")
    end)

    Suite:testMethod("AccuracySystem:applyCoverModifier", {
        description = "Cover modifier calculations are fast",
        testCase = "cover_modifier_speed",
        type = "performance"
    }, function()
        local accuracy = MockAccuracySystem:new()
        local startTime = os.clock()
        local iterations = 10000

        local covers = {"none", "light", "heavy", "full"}

        for i = 1, iterations do
            local cover = covers[((i - 1) % 4) + 1]
            accuracy:applyCoverModifier(75, cover)
        end

        local elapsed = os.clock() - startTime

        print("[Accuracy Performance] 10000 cover modifiers: " ..
              string.format("%.3f ms", elapsed * 1000))

        Helpers.assertLess(elapsed, 0.02, "10000 modifiers should complete in <20ms")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- HELPER FUNCTIONS FOR TESTING
-- ─────────────────────────────────────────────────────────────────────────

---Assert value is greater than expected
function Helpers.assertGreater(actual, expected, message)
    if not (actual > expected) then
        error(message or string.format("Expected %s > %s", tostring(actual), tostring(expected)))
    end
end

---Assert value is less than expected
function Helpers.assertLess(actual, expected, message)
    if not (actual < expected) then
        error(message or string.format("Expected %s < %s", tostring(actual), tostring(expected)))
    end
end

---Assert value is less than or equal to expected
function Helpers.assertLessOrEqual(actual, expected, message)
    if not (actual <= expected) then
        error(message or string.format("Expected %s <= %s", tostring(actual), tostring(expected)))
    end
end

---Assert value is nil
function Helpers.assertNil(actual, message)
    if actual ~= nil then
        error(message or string.format("Expected nil, got %s", tostring(actual)))
    end
end

---Assert value is not nil
function Helpers.assertNotNil(actual, message)
    if actual == nil then
        error(message or "Expected non-nil value")
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- RUN SUITE
-- ─────────────────────────────────────────────────────────────────────────

Suite:run()
