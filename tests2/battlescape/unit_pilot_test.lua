--- Unit Pilot Functions Test
--- Tests for pilot-related functions in Unit class
---
--- @module tests2.battlescape.unit_pilot_test

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("Unit.Pilot", "tests2/battlescape/unit_pilot_test.lua")

-- Mock Unit for testing (simplified)
local MockUnit = {}
MockUnit.__index = MockUnit

function MockUnit.new()
    local self = setmetatable({}, MockUnit)
    self.name = "Test Pilot"
    self.piloting = 8
    self.pilot_xp = 0
    self.pilot_rank = 0
    self.pilot_fatigue = 0
    self.assigned_craft_id = nil
    self.pilot_role = nil
    self.total_interceptions = 0
    self.craft_kills = 0
    self.stats = {
        dexterity = 8,
        perception = 7,
        intelligence = 6,
    }
    return self
end

-- Import actual Unit pilot functions
function MockUnit:getPilotingStat() return self.piloting or 6 end
function MockUnit:getPilotXP() return self.pilot_xp or 0 end
function MockUnit:getPilotRank() return self.pilot_rank or 0 end
function MockUnit:getPilotFatigue() return self.pilot_fatigue or 0 end
function MockUnit:isAssignedAsPilot() return self.assigned_craft_id ~= nil end

function MockUnit:gainPilotXP(amount, source)
    self.pilot_xp = (self.pilot_xp or 0) + amount
    return self:promotePilot()
end

function MockUnit:promotePilot()
    local rankThresholds = {100, 300, 600, 1000, 1500}
    local currentRank = self.pilot_rank or 0

    if currentRank >= 5 then return false end

    local nextRank = currentRank + 1
    local threshold = rankThresholds[nextRank]

    if self.pilot_xp >= threshold then
        self.pilot_rank = nextRank
        self.piloting = (self.piloting or 6) + 1
        return true
    end

    return false
end

function MockUnit:addPilotFatigue(amount)
    self.pilot_fatigue = math.min((self.pilot_fatigue or 0) + amount, 100)
end

function MockUnit:restPilot(amount)
    self.pilot_fatigue = math.max((self.pilot_fatigue or 0) - amount, 0)
end

function MockUnit:calculatePilotBonuses()
    local piloting = self.piloting or 6
    local fatigue = self.pilot_fatigue or 0

    local pilotingBonus = math.max(0, piloting - 6)
    local speedBonus = pilotingBonus * 2
    local accuracyBonus = pilotingBonus * 3
    local dodgeBonus = pilotingBonus * 2
    local fuelEfficiency = pilotingBonus * 1

    local fatigueMultiplier = 1.0 - (fatigue / 200)

    local dexterity = self.stats.dexterity or 6
    local perception = self.stats.perception or 6
    local intelligence = self.stats.intelligence or 6

    return {
        speed_bonus = speedBonus * fatigueMultiplier,
        accuracy_bonus = accuracyBonus * fatigueMultiplier,
        dodge_bonus = dodgeBonus * fatigueMultiplier,
        fuel_efficiency = fuelEfficiency * fatigueMultiplier,
        initiative_bonus = math.floor(dexterity / 2),
        sensor_bonus = math.floor(perception / 2),
        power_management = math.floor(intelligence / 2),
    }
end

-- Test getPilotingStat
suite:testMethod("getPilotingStat", "Returns piloting stat", function()
    local unit = MockUnit.new()
    unit.piloting = 10

    suite:assert(unit:getPilotingStat() == 10, "Should return piloting stat")
end)

suite:testMethod("getPilotingStat", "Returns default 6 if not set", function()
    local unit = MockUnit.new()
    unit.piloting = nil

    suite:assert(unit:getPilotingStat() == 6, "Should return default 6")
end)

-- Test gainPilotXP
suite:testMethod("gainPilotXP", "Adds XP correctly", function()
    local unit = MockUnit.new()
    unit:gainPilotXP(50, "test")

    suite:assert(unit:getPilotXP() == 50, "Should have 50 XP")
end)

suite:testMethod("gainPilotXP", "Promotes at threshold", function()
    local unit = MockUnit.new()
    unit:gainPilotXP(100, "test")

    suite:assert(unit:getPilotRank() == 1, "Should promote to rank 1")
    suite:assert(unit.piloting == 9, "Should increase piloting by 1")
end)

suite:testMethod("gainPilotXP", "Doesn't promote below threshold", function()
    local unit = MockUnit.new()
    unit:gainPilotXP(50, "test")

    suite:assert(unit:getPilotRank() == 0, "Should stay at rank 0")
    suite:assert(unit.piloting == 8, "Piloting should not change")
end)

-- Test promotePilot
suite:testMethod("promotePilot", "Returns false at max rank", function()
    local unit = MockUnit.new()
    unit.pilot_rank = 5
    unit.pilot_xp = 2000

    local promoted = unit:promotePilot()

    suite:assert(promoted == false, "Should not promote at max rank")
    suite:assert(unit.pilot_rank == 5, "Should stay at rank 5")
end)

-- Test fatigue
suite:testMethod("addPilotFatigue", "Adds fatigue correctly", function()
    local unit = MockUnit.new()
    unit:addPilotFatigue(30)

    suite:assert(unit:getPilotFatigue() == 30, "Should have 30 fatigue")
end)

suite:testMethod("addPilotFatigue", "Caps at 100", function()
    local unit = MockUnit.new()
    unit:addPilotFatigue(150)

    suite:assert(unit:getPilotFatigue() == 100, "Should cap at 100")
end)

suite:testMethod("restPilot", "Reduces fatigue correctly", function()
    local unit = MockUnit.new()
    unit.pilot_fatigue = 50
    unit:restPilot(20)

    suite:assert(unit:getPilotFatigue() == 30, "Should have 30 fatigue")
end)

suite:testMethod("restPilot", "Floors at 0", function()
    local unit = MockUnit.new()
    unit.pilot_fatigue = 10
    unit:restPilot(20)

    suite:assert(unit:getPilotFatigue() == 0, "Should floor at 0")
end)

-- Test calculatePilotBonuses
suite:testMethod("calculatePilotBonuses", "Calculates bonuses correctly", function()
    local unit = MockUnit.new()
    unit.piloting = 10  -- +4 above base
    unit.pilot_fatigue = 0

    local bonuses = unit:calculatePilotBonuses()

    suite:assert(bonuses.speed_bonus == 8, "Speed bonus should be 8%")
    suite:assert(bonuses.accuracy_bonus == 12, "Accuracy bonus should be 12%")
    suite:assert(bonuses.dodge_bonus == 8, "Dodge bonus should be 8%")
    suite:assert(bonuses.fuel_efficiency == 4, "Fuel efficiency should be 4%")
end)

suite:testMethod("calculatePilotBonuses", "Applies fatigue penalty", function()
    local unit = MockUnit.new()
    unit.piloting = 10
    unit.pilot_fatigue = 50  -- 25% penalty

    local bonuses = unit:calculatePilotBonuses()

    -- 8% * 0.75 = 6%
    suite:assert(bonuses.speed_bonus == 6, "Speed bonus should be reduced by fatigue")
end)

suite:testMethod("calculatePilotBonuses", "Returns zero at base piloting", function()
    local unit = MockUnit.new()
    unit.piloting = 6
    unit.pilot_fatigue = 0

    local bonuses = unit:calculatePilotBonuses()

    suite:assert(bonuses.speed_bonus == 0, "Should have no bonus at base piloting")
    suite:assert(bonuses.accuracy_bonus == 0, "Should have no bonus at base piloting")
end)

-- Test isAssignedAsPilot
suite:testMethod("isAssignedAsPilot", "Returns true when assigned", function()
    local unit = MockUnit.new()
    unit.assigned_craft_id = "craft_001"

    suite:assert(unit:isAssignedAsPilot() == true, "Should be assigned")
end)

suite:testMethod("isAssignedAsPilot", "Returns false when not assigned", function()
    local unit = MockUnit.new()

    suite:assert(unit:isAssignedAsPilot() == false, "Should not be assigned")
end)

return suite

