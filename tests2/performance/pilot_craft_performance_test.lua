--- Performance Tests for Pilot-Craft System
--- Tests system performance with large numbers of pilots and crafts
---
--- @module tests2.performance.pilot_craft_performance_test

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("PilotCraft.Performance", "tests2/performance/pilot_craft_performance_test.lua")

-- Mock implementations for performance testing
local MockUnit = {}
MockUnit.__index = MockUnit

function MockUnit.new(id, piloting)
    return setmetatable({
        id = id,
        name = "Pilot " .. id,
        classId = "pilot",
        piloting = piloting or 8,
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
    }, MockUnit)
end

local MockCraft = {}
MockCraft.__index = MockCraft

function MockCraft.new(id)
    return setmetatable({
        id = id,
        name = "Craft " .. id,
        required_pilots = 1,
        max_crew = 8,
        crew = {},
        crew_bonuses = {},
    }, MockCraft)
end

local PilotManager = require("geoscape.logic.pilot_manager")
local CrewBonusCalculator = require("geoscape.logic.crew_bonus_calculator")

-- Performance Test 1: Assign 1000 pilots to crafts
suite:testMethod("performance", "Assign 1000 pilots in under 1 second", function()
    local startTime = os.clock()
    local pilots = {}
    local crafts = {}

    -- Create 1000 pilots
    for i = 1, 1000 do
        pilots[i] = MockUnit.new(i, 8 + (i % 5))
    end

    -- Create 200 crafts (5 pilots per craft)
    for i = 1, 200 do
        crafts[i] = MockCraft.new("craft" .. i)
    end

    -- Assign pilots to crafts
    for i = 1, 1000 do
        local craftIdx = math.floor((i - 1) / 5) + 1
        local role = (i % 5 == 1) and "pilot" or "crew"
        PilotManager.assignToCraft(pilots[i], crafts[craftIdx], role)
    end

    local endTime = os.clock()
    local elapsed = endTime - startTime

    suite:assert(elapsed < 1.0, string.format("Should complete in under 1s (took %.3fs)", elapsed))
    print(string.format("[Performance] Assigned 1000 pilots in %.3fs", elapsed))
end)

-- Performance Test 2: Calculate bonuses for 200 crafts
suite:testMethod("performance", "Calculate bonuses for 200 crafts in under 0.5s", function()
    local crafts = {}

    -- Create 200 crafts with crews
    for i = 1, 200 do
        local craft = MockCraft.new("craft" .. i)
        craft.crew = {}
        for j = 1, 5 do
            local unit = MockUnit.new((i-1)*5 + j, 8 + (j % 3))
            table.insert(craft.crew, unit.id)
        end
        crafts[i] = craft
    end

    local startTime = os.clock()

    -- Calculate bonuses for all crafts
    for i = 1, 200 do
        local bonuses = CrewBonusCalculator.calculateForCraft(crafts[i])
    end

    local endTime = os.clock()
    local elapsed = endTime - startTime

    suite:assert(elapsed < 0.5, string.format("Should complete in under 0.5s (took %.3fs)", elapsed))
    print(string.format("[Performance] Calculated bonuses for 200 crafts in %.3fs", elapsed))
end)

-- Performance Test 3: Mass pilot XP gain
suite:testMethod("performance", "Award XP to 1000 pilots in under 0.2s", function()
    local pilots = {}

    -- Create 1000 pilots
    for i = 1, 1000 do
        pilots[i] = MockUnit.new(i, 8)
    end

    local startTime = os.clock()

    -- Award XP to all pilots (simulate interception)
    for i = 1, 1000 do
        local pilot = pilots[i]
        pilot.pilot_xp = pilot.pilot_xp + 50

        -- Simple rank check
        if pilot.pilot_xp >= 100 and pilot.pilot_rank == 0 then
            pilot.pilot_rank = 1
            pilot.piloting = pilot.piloting + 1
        end
    end

    local endTime = os.clock()
    local elapsed = endTime - startTime

    suite:assert(elapsed < 0.2, string.format("Should complete in under 0.2s (took %.3fs)", elapsed))
    print(string.format("[Performance] Processed 1000 pilot XP updates in %.3fs", elapsed))
end)

-- Performance Test 4: Recalculate 500 craft bonuses after crew changes
suite:testMethod("performance", "Recalculate 500 crafts after crew changes in under 1s", function()
    local crafts = {}
    local pilots = {}

    -- Setup
    for i = 1, 500 do
        crafts[i] = MockCraft.new("craft" .. i)
        pilots[i] = MockUnit.new(i, 9)
    end

    local startTime = os.clock()

    -- Assign pilots and recalculate
    for i = 1, 500 do
        PilotManager.assignToCraft(pilots[i], crafts[i], "pilot")
        -- Recalculation happens in assignToCraft
    end

    local endTime = os.clock()
    local elapsed = endTime - startTime

    suite:assert(elapsed < 1.0, string.format("Should complete in under 1s (took %.3fs)", elapsed))
    print(string.format("[Performance] Assigned and recalculated 500 crafts in %.3fs", elapsed))
end)

-- Performance Test 5: Memory usage with large crew arrays
suite:testMethod("performance", "Handle 100 crafts with max crew (800 total units)", function()
    local crafts = {}
    local pilots = {}

    -- Create pilots
    for i = 1, 800 do
        pilots[i] = MockUnit.new(i, 7 + (i % 6))
    end

    -- Create crafts and assign crews
    local startTime = os.clock()

    for c = 1, 100 do
        local craft = MockCraft.new("craft" .. c)

        -- Assign 8 crew members per craft
        for i = 1, 8 do
            local pilotIdx = (c - 1) * 8 + i
            local role = (i == 1) and "pilot" or (i == 2) and "co-pilot" or "crew"
            PilotManager.assignToCraft(pilots[pilotIdx], craft, role)
        end

        crafts[c] = craft
    end

    local endTime = os.clock()
    local elapsed = endTime - startTime

    suite:assert(#crafts == 100, "Should have 100 crafts")
    suite:assert(elapsed < 2.0, string.format("Should complete in under 2s (took %.3fs)", elapsed))
    print(string.format("[Performance] Created 100 crafts with 800 crew members in %.3fs", elapsed))
end)

-- Performance Test 6: Rapid crew reassignment
suite:testMethod("performance", "Reassign 200 pilots between crafts in under 0.5s", function()
    local pilots = {}
    local craft1 = MockCraft.new("craft1")
    local craft2 = MockCraft.new("craft2")

    craft1.max_crew = 200
    craft2.max_crew = 200

    -- Create pilots
    for i = 1, 200 do
        pilots[i] = MockUnit.new(i, 8)
    end

    local startTime = os.clock()

    -- Assign all to craft1
    for i = 1, 200 do
        PilotManager.assignToCraft(pilots[i], craft1, "crew")
    end

    -- Unassign all
    for i = 1, 200 do
        PilotManager.unassignFromCraft(pilots[i], craft1)
    end

    -- Assign all to craft2
    for i = 1, 200 do
        PilotManager.assignToCraft(pilots[i], craft2, "crew")
    end

    local endTime = os.clock()
    local elapsed = endTime - startTime

    suite:assert(#craft2.crew == 200, "Craft2 should have 200 crew")
    suite:assert(#craft1.crew == 0, "Craft1 should have 0 crew")
    suite:assert(elapsed < 0.5, string.format("Should complete in under 0.5s (took %.3fs)", elapsed))
    print(string.format("[Performance] Reassigned 200 pilots in %.3fs", elapsed))
end)

return suite

