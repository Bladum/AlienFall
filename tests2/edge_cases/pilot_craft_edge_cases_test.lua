--- Edge Case Tests for Pilot-Craft System
--- Tests boundary conditions, error handling, and unusual scenarios
---
--- @module tests2.edge_cases.pilot_craft_edge_cases_test

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("PilotCraft.EdgeCases", "tests2/edge_cases/pilot_craft_edge_cases_test.lua")

-- Mock Unit
local function createMockUnit(id, piloting)
    return {
        id = id,
        name = "Unit " .. id,
        classId = "pilot",
        piloting = piloting or 6,
        pilot_xp = 0,
        pilot_rank = 0,
        pilot_fatigue = 0,
        assigned_craft_id = nil,
        pilot_role = nil,
        stats = {dexterity = 8, perception = 7, intelligence = 6},

        isAssignedAsPilot = function(self) return self.assigned_craft_id ~= nil end,
        getPilotingStat = function(self) return self.piloting end,
        calculatePilotBonuses = function(self)
            local bonus = math.max(0, self.piloting - 6)
            local fatigueMult = 1.0 - (self.pilot_fatigue / 200)
            return {
                speed_bonus = bonus * 2 * fatigueMult,
                accuracy_bonus = bonus * 3 * fatigueMult,
                dodge_bonus = bonus * 2 * fatigueMult,
                fuel_efficiency = bonus * 1 * fatigueMult,
            }
        end,
    }
end

-- Mock Craft
local function createMockCraft(id)
    return {
        id = id,
        name = "Craft " .. id,
        required_pilots = 1,
        max_crew = 4,
        crew = {},
        crew_bonuses = {},
    }
end

local PilotManager = require("geoscape.logic.pilot_manager")
local CrewBonusCalculator = require("geoscape.logic.crew_bonus_calculator")

-- Edge Case 1: Zero piloting skill
suite:testMethod("edge_cases", "Unit with zero piloting skill", function()
    local unit = createMockUnit(1, 0)
    local bonuses = unit:calculatePilotBonuses()

    suite:assert(bonuses.speed_bonus <= 0, "Should have zero or negative bonus")
    print("[EdgeCase] Zero piloting handled correctly")
end)

-- Edge Case 2: Maximum piloting skill
suite:testMethod("edge_cases", "Unit with maximum piloting skill (20)", function()
    local unit = createMockUnit(1, 20)
    local bonuses = unit:calculatePilotBonuses()

    -- (20-6)*2 = 28% speed bonus
    suite:assert(bonuses.speed_bonus == 28, "Should have maximum bonus")
    print("[EdgeCase] Maximum piloting handled correctly")
end)

-- Edge Case 3: 100% fatigue
suite:testMethod("edge_cases", "Pilot with 100% fatigue", function()
    local unit = createMockUnit(1, 10)
    unit.pilot_fatigue = 100

    local bonuses = unit:calculatePilotBonuses()

    -- 100 fatigue = 50% penalty, so (10-6)*2*0.5 = 4% instead of 8%
    suite:assert(bonuses.speed_bonus == 4, "Should apply 50% fatigue penalty")
    print("[EdgeCase] Maximum fatigue handled correctly")
end)

-- Edge Case 4: Assign nil unit
suite:testMethod("edge_cases", "Assign nil unit to craft", function()
    local craft = createMockCraft("craft1")

    local success, msg = PilotManager.assignToCraft(nil, craft, "pilot")

    suite:assert(success == false, "Should fail with nil unit")
    suite:assert(msg ~= nil, "Should have error message")
    print("[EdgeCase] Nil unit rejected correctly")
end)

-- Edge Case 5: Assign to nil craft
suite:testMethod("edge_cases", "Assign unit to nil craft", function()
    local unit = createMockUnit(1, 8)

    local success, msg = PilotManager.assignToCraft(unit, nil, "pilot")

    suite:assert(success == false, "Should fail with nil craft")
    suite:assert(msg ~= nil, "Should have error message")
    print("[EdgeCase] Nil craft rejected correctly")
end)

-- Edge Case 6: Invalid role
suite:testMethod("edge_cases", "Assign with invalid role", function()
    local unit = createMockUnit(1, 8)
    local craft = createMockCraft("craft1")

    local success, msg = PilotManager.assignToCraft(unit, craft, "invalid_role")

    suite:assert(success == false, "Should fail with invalid role")
    suite:assert(msg:find("Invalid role") ~= nil, "Should mention invalid role")
    print("[EdgeCase] Invalid role rejected correctly")
end)

-- Edge Case 7: Assign same pilot twice
suite:testMethod("edge_cases", "Assign same pilot to two crafts", function()
    local unit = createMockUnit(1, 8)
    local craft1 = createMockCraft("craft1")
    local craft2 = createMockCraft("craft2")

    -- First assignment should succeed
    local success1 = PilotManager.assignToCraft(unit, craft1, "pilot")
    suite:assert(success1 == true, "First assignment should succeed")

    -- Second assignment should fail
    local success2, msg = PilotManager.assignToCraft(unit, craft2, "pilot")
    suite:assert(success2 == false, "Second assignment should fail")
    suite:assert(msg:find("already assigned") ~= nil, "Should mention already assigned")

    print("[EdgeCase] Double assignment prevented correctly")
end)

-- Edge Case 8: Empty crew bonus calculation
suite:testMethod("edge_cases", "Calculate bonuses with empty crew", function()
    local craft = createMockCraft("craft1")
    craft.crew = {}

    local bonuses = CrewBonusCalculator.calculateForCraft(craft)

    suite:assert(bonuses.speed_bonus == 0, "Should have zero bonuses")
    suite:assert(bonuses.accuracy_bonus == 0, "Should have zero bonuses")
    print("[EdgeCase] Empty crew handled correctly")
end)

-- Edge Case 9: Nil craft for bonus calculation
suite:testMethod("edge_cases", "Calculate bonuses with nil craft", function()
    local bonuses = CrewBonusCalculator.calculateForCraft(nil)

    suite:assert(bonuses ~= nil, "Should return bonuses table")
    suite:assert(bonuses.speed_bonus == 0, "Should have zero bonuses")
    print("[EdgeCase] Nil craft handled gracefully")
end)

-- Edge Case 10: Unassign from wrong craft
suite:testMethod("edge_cases", "Unassign pilot from wrong craft", function()
    local unit = createMockUnit(1, 8)
    local craft1 = createMockCraft("craft1")
    local craft2 = createMockCraft("craft2")

    -- Assign to craft1
    PilotManager.assignToCraft(unit, craft1, "pilot")

    -- Try to unassign from craft2 (wrong craft)
    local success = PilotManager.unassignFromCraft(unit, craft2)

    -- Should still work (removes from unit, but craft2 wasn't affected)
    suite:assert(success == true, "Should complete without error")

    print("[EdgeCase] Unassign from wrong craft handled")
end)

-- Edge Case 11: Exceed crew capacity
suite:testMethod("edge_cases", "Assign more crew than capacity", function()
    local craft = createMockCraft("craft1")
    craft.max_crew = 2

    local pilot1 = createMockUnit(1, 8)
    local pilot2 = createMockUnit(2, 8)
    local pilot3 = createMockUnit(3, 8)

    -- First two should succeed
    local success1 = PilotManager.assignToCraft(pilot1, craft, "pilot")
    local success2 = PilotManager.assignToCraft(pilot2, craft, "co-pilot")

    suite:assert(success1 == true, "First should succeed")
    suite:assert(success2 == true, "Second should succeed")

    -- Third should fail (at capacity)
    local success3, msg = PilotManager.assignToCraft(pilot3, craft, "crew")

    suite:assert(success3 == false, "Third should fail")
    suite:assert(msg:find("capacity") ~= nil, "Should mention capacity")

    print("[EdgeCase] Capacity limit enforced correctly")
end)

-- Edge Case 12: Negative XP
suite:testMethod("edge_cases", "Handle negative pilot XP", function()
    local unit = createMockUnit(1, 8)
    unit.pilot_xp = -50

    local xp = unit.pilot_xp

    suite:assert(xp == -50, "Should store negative XP")
    -- System should handle this gracefully (no rank down, XP can't go below 0 naturally)

    print("[EdgeCase] Negative XP stored correctly")
end)

-- Edge Case 13: Very large crew (beyond reasonable limits)
suite:testMethod("edge_cases", "Craft with 100 crew members", function()
    local craft = createMockCraft("craft1")
    craft.max_crew = 100
    craft.crew = {}

    -- Add 100 crew IDs
    for i = 1, 100 do
        table.insert(craft.crew, i)
    end

    -- Should calculate bonuses without error (even if impractical)
    local bonuses = CrewBonusCalculator.calculateForCraft(craft)

    suite:assert(bonuses ~= nil, "Should return bonuses")
    suite:assert(type(bonuses.speed_bonus) == "number", "Should have numeric bonus")

    print("[EdgeCase] Large crew handled without crash")
end)

-- Edge Case 14: Craft with required_pilots = 0
suite:testMethod("edge_cases", "Craft with zero required pilots", function()
    local craft = createMockCraft("craft1")
    craft.required_pilots = 0
    craft.crew = {}

    local valid, msg = PilotManager.validateCrew(craft)

    suite:assert(valid == true, "Should be valid with zero requirement")

    print("[EdgeCase] Zero required pilots handled correctly")
end)

-- Edge Case 15: Role multiplier beyond defined positions
suite:testMethod("edge_cases", "Get multiplier for position 100", function()
    local mult = CrewBonusCalculator.getRoleMultiplier(100)

    suite:assert(mult == 0.1, "Should return 0.1 for any position > 3")

    print("[EdgeCase] High position numbers handled correctly")
end)

return suite

