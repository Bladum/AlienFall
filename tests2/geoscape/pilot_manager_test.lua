--- PilotManager Test
--- Tests for pilot assignment and crew management
---
--- @module tests2.geoscape.pilot_manager_test

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("PilotManager", "tests2/geoscape/pilot_manager_test.lua")

local PilotManager = require("geoscape.logic.pilot_manager")

-- Mock Unit
local function createMockUnit(id, classId, pilotRank)
    return {
        id = id,
        name = "Test Unit " .. id,
        classId = classId or "pilot",
        pilot_rank = pilotRank or 1,
        piloting = 8,
        pilot_fatigue = 0,
        assigned_craft_id = nil,
        pilot_role = nil,
        stats = {dexterity = 8, perception = 7, intelligence = 6},

        isAssignedAsPilot = function(self)
            return self.assigned_craft_id ~= nil
        end,

        getPilotingStat = function(self)
            return self.piloting
        end,

        calculatePilotBonuses = function(self)
            local piloting = self.piloting or 6
            local bonus = math.max(0, piloting - 6)
            return {
                speed_bonus = bonus * 2,
                accuracy_bonus = bonus * 3,
                dodge_bonus = bonus * 2,
                fuel_efficiency = bonus * 1,
                initiative_bonus = 4,
                sensor_bonus = 3,
            }
        end,
    }
end

-- Mock Craft
local function createMockCraft(id, requiredClass, requiredRank)
    return {
        id = id,
        name = "Test Craft " .. id,
        required_pilot_class = requiredClass,
        required_pilot_rank = requiredRank or 1,
        required_pilots = 1,
        max_crew = 4,
        crew = {},
        crew_bonuses = {},
    }
end

-- Test assignToCraft - success
suite:testMethod("assignToCraft", "Assigns unit successfully", function()
    local unit = createMockUnit(1, "pilot", 1)
    local craft = createMockCraft("craft1", "pilot", 1)

    local success, msg = PilotManager.assignToCraft(unit, craft, "pilot")

    suite:assert(success == true, "Should assign successfully")
    suite:assert(unit.assigned_craft_id == "craft1", "Unit should have craft ID")
    suite:assert(unit.pilot_role == "pilot", "Unit should have pilot role")
    suite:assert(#craft.crew == 1, "Craft should have 1 crew member")
end)

-- Test assignToCraft - already assigned
suite:testMethod("assignToCraft", "Fails if unit already assigned", function()
    local unit = createMockUnit(1, "pilot", 1)
    unit.assigned_craft_id = "other_craft"
    local craft = createMockCraft("craft1", "pilot", 1)

    local success, msg = PilotManager.assignToCraft(unit, craft, "pilot")

    suite:assert(success == false, "Should fail when already assigned")
    suite:assert(msg:find("already assigned") ~= nil, "Error message should mention already assigned")
end)

-- Test assignToCraft - invalid role
suite:testMethod("assignToCraft", "Fails with invalid role", function()
    local unit = createMockUnit(1, "pilot", 1)
    local craft = createMockCraft("craft1", "pilot", 1)

    local success, msg = PilotManager.assignToCraft(unit, craft, "invalid")

    suite:assert(success == false, "Should fail with invalid role")
    suite:assert(msg:find("Invalid role") ~= nil, "Should have invalid role error")
end)

-- Test assignToCraft - wrong class
suite:testMethod("assignToCraft", "Fails if unit class doesn't match", function()
    local unit = createMockUnit(1, "soldier", 1)
    local craft = createMockCraft("craft1", "fighter_pilot", 2)

    local success, msg = PilotManager.assignToCraft(unit, craft, "pilot")

    suite:assert(success == false, "Should fail with wrong class")
    suite:assert(msg:find("does not match") ~= nil, "Should have class mismatch error")
end)

-- Test assignToCraft - insufficient rank
suite:testMethod("assignToCraft", "Fails if unit rank too low", function()
    local unit = createMockUnit(1, "fighter_pilot", 1)
    local craft = createMockCraft("craft1", "fighter_pilot", 3)

    local success, msg = PilotManager.assignToCraft(unit, craft, "pilot")

    suite:assert(success == false, "Should fail with low rank")
    suite:assert(msg:find("below required") ~= nil, "Should have rank error")
end)

-- Test assignToCraft - crew capacity
suite:testMethod("assignToCraft", "Fails if crew at capacity", function()
    local unit = createMockUnit(1, "pilot", 1)
    local craft = createMockCraft("craft1", "pilot", 1)
    craft.max_crew = 2
    craft.crew = {101, 102} -- Already full

    local success, msg = PilotManager.assignToCraft(unit, craft, "pilot")

    suite:assert(success == false, "Should fail at capacity")
    suite:assert(msg:find("capacity") ~= nil, "Should have capacity error")
end)

-- Test unassignFromCraft
suite:testMethod("unassignFromCraft", "Unassigns unit successfully", function()
    local unit = createMockUnit(1, "pilot", 1)
    local craft = createMockCraft("craft1", "pilot", 1)

    -- First assign
    PilotManager.assignToCraft(unit, craft, "pilot")

    -- Then unassign
    local success = PilotManager.unassignFromCraft(unit, craft)

    suite:assert(success == true, "Should unassign successfully")
    suite:assert(unit.assigned_craft_id == nil, "Unit should have no craft ID")
    suite:assert(unit.pilot_role == nil, "Unit should have no role")
    suite:assert(#craft.crew == 0, "Craft should have 0 crew")
end)

-- Test canOperateCraft - success
suite:testMethod("canOperateCraft", "Returns true for valid pilot", function()
    local unit = createMockUnit(1, "fighter_pilot", 2)
    local craft = createMockCraft("craft1", "fighter_pilot", 2)

    local canOperate, msg = PilotManager.canOperateCraft(unit, craft)

    suite:assert(canOperate == true, "Should be able to operate")
end)

-- Test canOperateCraft - wrong class
suite:testMethod("canOperateCraft", "Returns false for wrong class", function()
    local unit = createMockUnit(1, "pilot", 1)
    local craft = createMockCraft("craft1", "fighter_pilot", 2)

    local canOperate, msg = PilotManager.canOperateCraft(unit, craft)

    suite:assert(canOperate == false, "Should not be able to operate")
    suite:assert(msg:find("pilot class") ~= nil, "Should mention class requirement")
end)

-- Test validateCrew - valid
suite:testMethod("validateCrew", "Returns true for sufficient crew", function()
    local craft = createMockCraft("craft1", "pilot", 1)
    craft.crew = {1, 2}
    craft.required_pilots = 1

    local valid, msg = PilotManager.validateCrew(craft)

    suite:assert(valid == true, "Crew should be valid")
end)

-- Test validateCrew - insufficient
suite:testMethod("validateCrew", "Returns false for insufficient crew", function()
    local craft = createMockCraft("craft1", "pilot", 1)
    craft.crew = {}
    craft.required_pilots = 1

    local valid, msg = PilotManager.validateCrew(craft)

    suite:assert(valid == false, "Crew should be invalid")
    suite:assert(msg:find("Insufficient") ~= nil, "Should mention insufficient crew")
end)

-- Test awardCrewXP
suite:testMethod("awardCrewXP", "Awards XP to crew members", function()
    local craft = createMockCraft("craft1", "pilot", 1)
    craft.crew = {1, 2, 3}

    -- Should not error (actual XP awarding would need unit lookup)
    PilotManager.awardCrewXP(craft, 100, "test")

    suite:assert(true, "Should complete without error")
end)

return suite

