--- CrewBonusCalculator Test
--- Tests for crew bonus calculation
---
--- @module tests2.geoscape.crew_bonus_calculator_test

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("CrewBonusCalculator", "tests2/geoscape/crew_bonus_calculator_test.lua")

local CrewBonusCalculator = require("geoscape.logic.crew_bonus_calculator")

-- Test getRoleMultiplier
suite:testMethod("getRoleMultiplier", "Returns 1.0 for position 1 (pilot)", function()
    local mult = CrewBonusCalculator.getRoleMultiplier(1)
    suite:assert(mult == 1.0, "Pilot should have 100% multiplier")
end)

suite:testMethod("getRoleMultiplier", "Returns 0.5 for position 2 (co-pilot)", function()
    local mult = CrewBonusCalculator.getRoleMultiplier(2)
    suite:assert(mult == 0.5, "Co-pilot should have 50% multiplier")
end)

suite:testMethod("getRoleMultiplier", "Returns 0.25 for position 3 (crew)", function()
    local mult = CrewBonusCalculator.getRoleMultiplier(3)
    suite:assert(mult == 0.25, "Crew should have 25% multiplier")
end)

suite:testMethod("getRoleMultiplier", "Returns 0.1 for position 4+ (extra crew)", function()
    local mult4 = CrewBonusCalculator.getRoleMultiplier(4)
    local mult5 = CrewBonusCalculator.getRoleMultiplier(5)

    suite:assert(mult4 == 0.1, "Position 4 should have 10% multiplier")
    suite:assert(mult5 == 0.1, "Position 5 should have 10% multiplier")
end)

-- Test applyFatigueModifier
suite:testMethod("applyFatigueModifier", "Applies no penalty at 0 fatigue", function()
    local bonuses = {
        speed_bonus = 10,
        accuracy_bonus = 15,
        dodge_bonus = 10,
        fuel_efficiency = 5,
    }

    local result = CrewBonusCalculator.applyFatigueModifier(bonuses, 0)

    suite:assert(result.speed_bonus == 10, "Should have no reduction")
    suite:assert(result.accuracy_bonus == 15, "Should have no reduction")
end)

suite:testMethod("applyFatigueModifier", "Applies 25% penalty at 50 fatigue", function()
    local bonuses = {
        speed_bonus = 10,
        accuracy_bonus = 15,
        dodge_bonus = 10,
        fuel_efficiency = 5,
    }

    local result = CrewBonusCalculator.applyFatigueModifier(bonuses, 50)

    -- 50 fatigue = 50/200 = 0.25 penalty = 0.75 multiplier
    suite:assert(result.speed_bonus == 7.5, "Should reduce by 25%")
    suite:assert(result.accuracy_bonus == 11.25, "Should reduce by 25%")
end)

suite:testMethod("applyFatigueModifier", "Applies 50% penalty at 100 fatigue", function()
    local bonuses = {
        speed_bonus = 10,
        accuracy_bonus = 15,
        dodge_bonus = 10,
        fuel_efficiency = 5,
    }

    local result = CrewBonusCalculator.applyFatigueModifier(bonuses, 100)

    -- 100 fatigue = 100/200 = 0.5 penalty = 0.5 multiplier
    suite:assert(result.speed_bonus == 5, "Should reduce by 50%")
    suite:assert(result.accuracy_bonus == 7.5, "Should reduce by 50%")
end)

-- Test calculateForCraft - empty crew
suite:testMethod("calculateForCraft", "Returns zero bonuses for empty crew", function()
    local craft = {
        id = "craft1",
        crew = {},
    }

    local bonuses = CrewBonusCalculator.calculateForCraft(craft)

    suite:assert(bonuses.speed_bonus == 0, "Should have 0 speed bonus")
    suite:assert(bonuses.accuracy_bonus == 0, "Should have 0 accuracy bonus")
    suite:assert(bonuses.dodge_bonus == 0, "Should have 0 dodge bonus")
end)

-- Test calculateForCraft - nil craft
suite:testMethod("calculateForCraft", "Handles nil craft gracefully", function()
    local bonuses = CrewBonusCalculator.calculateForCraft(nil)

    suite:assert(bonuses ~= nil, "Should return bonuses table")
    suite:assert(bonuses.speed_bonus == 0, "Should have 0 bonuses")
end)

-- Test calculate (legacy function)
suite:testMethod("calculate", "Legacy function returns zero bonuses", function()
    local bonuses = CrewBonusCalculator.calculate("craft1")

    suite:assert(bonuses ~= nil, "Should return bonuses table")
    suite:assert(bonuses.speed_bonus == 0, "Should have 0 bonuses")
end)

-- Test bonus calculation logic (integration-style)
suite:testMethod("calculateForCraft", "Calculates correct bonus structure", function()
    local craft = {
        id = "craft1",
        crew = {}, -- Empty for now since we can't easily mock units
    }

    local bonuses = CrewBonusCalculator.calculateForCraft(craft)

    -- Check structure
    suite:assert(bonuses.speed_bonus ~= nil, "Should have speed_bonus")
    suite:assert(bonuses.accuracy_bonus ~= nil, "Should have accuracy_bonus")
    suite:assert(bonuses.dodge_bonus ~= nil, "Should have dodge_bonus")
    suite:assert(bonuses.fuel_efficiency ~= nil, "Should have fuel_efficiency")
    suite:assert(bonuses.initiative_bonus ~= nil, "Should have initiative_bonus")
    suite:assert(bonuses.sensor_bonus ~= nil, "Should have sensor_bonus")
end)

return suite

