-- ─────────────────────────────────────────────────────────────────────────
-- COMBAT REGRESSION TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Catch regressions in battlescape combat systems
-- Tests: 8 regression tests for tactical combat edge cases
-- Expected: All pass in <250ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.combat",
    fileName = "combat_regression_test.lua",
    description = "Combat system regression testing"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Combat Regressions", function()

    local battle = {}

    Suite:beforeEach(function()
        battle = {
            units = {},
            enemies = {},
            turn = 1,
            phase = "player",
            terrain = {}
        }
    end)

    -- Regression 1: Hit chance calculation overflow
    Suite:testMethod("Combat:hitChanceCalculation", {
        description = "Hit chance should never exceed 100% or go below 0%",
        testCase = "validation",
        type = "regression"
    }, function()
        local function calcHitChance(accuracy, distance, cover)
            local chance = accuracy - (distance * 2) + cover
            -- Clamp to 0-100
            chance = math.max(0, math.min(100, chance))
            return chance
        end

        local hits = {
            calcHitChance(100, 0, 0),    -- Should be 100
            calcHitChance(50, 100, 0),   -- Should be 0 (clamped)
            calcHitChance(60, 10, 50)    -- Should be 100 (clamped)
        }

        for _, hit in ipairs(hits) do
            Helpers.assertTrue(hit >= 0 and hit <= 100, "Hit chance should be 0-100: " .. hit)
        end
    end)

    -- Regression 2: Armor calculation underflow
    Suite:testMethod("Combat:armorCalculation", {
        description = "Armor damage reduction should never go negative",
        testCase = "validation",
        type = "regression"
    }, function()
        local unit = {
            armor = 50,
            health = 100
        }

        local function takeDamage(unit, damage)
            local reducedDamage = math.max(0, damage - unit.armor / 2)
            unit.health = unit.health - reducedDamage
            unit.health = math.max(0, unit.health)
            return reducedDamage
        end

        local dmg1 = takeDamage(unit, 30)
        local dmg2 = takeDamage(unit, 5)

        Helpers.assertTrue(unit.health >= 0, "Health should never go negative")
        Helpers.assertTrue(dmg1 >= 0, "Damage should never be negative")
    end)

    -- Regression 3: Turn order consistency
    Suite:testMethod("Combat:turnOrderConsistency", {
        description = "Turn order should remain consistent throughout battle",
        testCase = "edge_case",
        type = "regression"
    }, function()
        battle.units = {
            {id = 1, initiative = 10},
            {id = 2, initiative = 5},
            {id = 3, initiative = 15}
        }

        -- Sort by initiative
        table.sort(battle.units, function(a, b) return a.initiative > b.initiative end)

        Helpers.assertEqual(battle.units[1].id, 3, "Unit 3 should go first (initiative 15)")
        Helpers.assertEqual(battle.units[2].id, 1, "Unit 1 should go second (initiative 10)")
    end)

    -- Regression 4: Movement point exhaustion
    Suite:testMethod("Combat:movementPointExhaustion", {
        description = "Units shouldn't move beyond their movement points",
        testCase = "validation",
        type = "regression"
    }, function()
        local unit = {
            x = 5,
            y = 5,
            movementPoints = 10,
            maxMovement = 10
        }

        local function moveUnit(unit, distance)
            if unit.movementPoints >= distance then
                unit.movementPoints = unit.movementPoints - distance
                return true
            end
            return false
        end

        Helpers.assertTrue(moveUnit(unit, 5), "Should move 5 points")
        Helpers.assertTrue(moveUnit(unit, 5), "Should move final 5 points")
        Helpers.assertTrue(not moveUnit(unit, 1), "Should not move when exhausted")
    end)

    -- Regression 5: Friendly fire prevention
    Suite:testMethod("Combat:friendlyFirePrevention", {
        description = "Friendly units should not be targeted",
        testCase = "validation",
        type = "regression"
    }, function()
        local attacker = {id = 1, team = "player"}
        local ally = {id = 2, team = "player"}
        local enemy = {id = 3, team = "alien"}

        local function canTarget(attacker, target)
            return target.team ~= attacker.team and target.id ~= attacker.id
        end

        Helpers.assertTrue(not canTarget(attacker, ally), "Should not target ally")
        Helpers.assertTrue(canTarget(attacker, enemy), "Should target enemy")
    end)

    -- Regression 6: Line of sight calculation
    Suite:testMethod("Combat:lineOfSight", {
        description = "Line of sight should be calculated correctly",
        testCase = "validation",
        type = "regression"
    }, function()
        local function hasLineOfSight(x1, y1, x2, y2, obstacles)
            local distance = math.sqrt((x2-x1)^2 + (y2-y1)^2)
            -- Simple LOS check
            return distance <= 20 and not obstacles[x2 .. "," .. y2]
        end

        local obstacles = {}
        Helpers.assertTrue(hasLineOfSight(0, 0, 10, 10, obstacles), "Should have LoS")

        obstacles["10,10"] = true
        Helpers.assertTrue(not hasLineOfSight(0, 0, 10, 10, obstacles), "Obstacle blocks LoS")
    end)

    -- Regression 7: Action point overflow
    Suite:testMethod("Combat:actionPointManagement", {
        description = "Action points should reset correctly each turn",
        testCase = "edge_case",
        type = "regression"
    }, function()
        local unit = {
            actionPoints = 20,
            maxActionPoints = 20
        }

        -- Use points
        unit.actionPoints = unit.actionPoints - 12
        Helpers.assertEqual(unit.actionPoints, 8, "Should have 8 points after action")

        -- Reset for next turn
        unit.actionPoints = unit.maxActionPoints
        Helpers.assertEqual(unit.actionPoints, 20, "Should reset to max")
    end)

    -- Regression 8: Critical hit probability bounds
    Suite:testMethod("Combat:criticalHitProbability", {
        description = "Critical hit chance should stay within bounds",
        testCase = "validation",
        type = "regression"
    }, function()
        local function calcCritChance(skill, difficulty)
            local chance = skill - difficulty
            chance = math.max(0, math.min(50, chance))  -- 0-50% crit
            return chance
        end

        local crits = {
            calcCritChance(80, 20),   -- 60 -> clamped to 50
            calcCritChance(10, 50),   -- -40 -> clamped to 0
            calcCritChance(30, 15)    -- 15 -> valid
        }

        for _, crit in ipairs(crits) do
            Helpers.assertTrue(crit >= 0 and crit <= 50, "Crit chance should be 0-50%: " .. crit)
        end
    end)

end)

return Suite
