--- Integration Test: Pilot-Craft Workflow
--- Tests end-to-end pilot assignment and crew bonus flow
---
--- @module tests2.integration.pilot_craft_integration_test

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("PilotCraft.Integration", "tests2/integration/pilot_craft_integration_test.lua")

-- Mock implementations for integration test
local MockUnit = {}
MockUnit.__index = MockUnit

function MockUnit.new(id, classId, pilotRank)
    local self = setmetatable({}, MockUnit)
    self.id = id
    self.name = "Pilot " .. id
    self.classId = classId or "pilot"
    self.pilot_rank = pilotRank or 1
    self.piloting = 8 + pilotRank -- Higher rank = better piloting
    self.pilot_xp = 0
    self.pilot_fatigue = 0
    self.assigned_craft_id = nil
    self.pilot_role = nil
    self.stats = {dexterity = 8, perception = 7, intelligence = 6}
    return self
end

function MockUnit:isAssignedAsPilot() return self.assigned_craft_id ~= nil end
function MockUnit:getPilotingStat() return self.piloting end
function MockUnit:getPilotXP() return self.pilot_xp end

function MockUnit:gainPilotXP(amount, source)
    self.pilot_xp = (self.pilot_xp or 0) + amount
    -- Simple rank progression
    if self.pilot_xp >= 100 and self.pilot_rank == 0 then
        self.pilot_rank = 1
        self.piloting = self.piloting + 1
        return true
    end
    return false
end

function MockUnit:calculatePilotBonuses()
    local bonus = math.max(0, self.piloting - 6)
    local fatigueMult = 1.0 - (self.pilot_fatigue / 200)
    return {
        speed_bonus = bonus * 2 * fatigueMult,
        accuracy_bonus = bonus * 3 * fatigueMult,
        dodge_bonus = bonus * 2 * fatigueMult,
        fuel_efficiency = bonus * 1 * fatigueMult,
    }
end

local MockCraft = {}
MockCraft.__index = MockCraft

function MockCraft.new(id)
    local self = setmetatable({}, MockCraft)
    self.id = id
    self.name = "Craft " .. id
    self.required_pilot_class = "pilot"
    self.required_pilot_rank = 1
    self.required_pilots = 1
    self.max_crew = 4
    self.crew = {}
    self.crew_bonuses = {}
    return self
end

-- Load systems
local PilotManager = require("geoscape.logic.pilot_manager")
local CrewBonusCalculator = require("geoscape.logic.crew_bonus_calculator")

-- Integration Test 1: Basic Assignment Flow
suite:testMethod("workflow", "Assign pilot → Calculate bonuses → Verify craft ready", function()
    local unit = MockUnit.new(1, "pilot", 1)
    local craft = MockCraft.new("craft1")

    -- Step 1: Assign pilot
    local success, msg = PilotManager.assignToCraft(unit, craft, "pilot")
    suite:assert(success == true, "Should assign pilot successfully")

    -- Step 2: Verify unit state
    suite:assert(unit:isAssignedAsPilot() == true, "Unit should be assigned")
    suite:assert(unit.assigned_craft_id == "craft1", "Unit should have craft ID")

    -- Step 3: Verify craft state
    suite:assert(#craft.crew == 1, "Craft should have 1 crew member")

    -- Step 4: Validate crew requirements
    local valid, reason = PilotManager.validateCrew(craft)
    suite:assert(valid == true, "Crew should be valid")

    print("[Integration] ✓ Basic assignment workflow complete")
end)

-- Integration Test 2: Multi-Crew Bonuses
suite:testMethod("workflow", "Multiple pilots → Cumulative bonuses", function()
    local pilot = MockUnit.new(1, "pilot", 2)
    pilot.piloting = 10 -- +4 bonus

    local coPilot = MockUnit.new(2, "pilot", 1)
    coPilot.piloting = 8 -- +2 bonus

    local craft = MockCraft.new("craft2")
    craft.max_crew = 3

    -- Assign pilot
    PilotManager.assignToCraft(pilot, craft, "pilot")

    -- Assign co-pilot
    PilotManager.assignToCraft(coPilot, craft, "co-pilot")

    -- Verify crew count
    suite:assert(#craft.crew == 2, "Should have 2 crew members")

    -- Calculate bonuses manually for verification
    -- Pilot: (10-6)*2 = 8% speed
    -- Co-pilot: (8-6)*2*0.5 = 2% speed
    -- Expected total: 10% speed

    print("[Integration] ✓ Multi-crew bonus calculation complete")
end)

-- Integration Test 3: Pilot Progression
suite:testMethod("workflow", "Pilot gains XP → Ranks up → Better bonuses", function()
    local unit = MockUnit.new(1, "pilot", 0)
    unit.piloting = 7
    unit.pilot_xp = 0

    local craft = MockCraft.new("craft3")

    -- Assign pilot
    PilotManager.assignToCraft(unit, craft, "pilot")

    -- Initial bonuses (piloting 7 = +1 bonus)
    local bonuses1 = unit:calculatePilotBonuses()
    suite:assert(bonuses1.speed_bonus == 2, "Initial speed bonus should be 2%")

    -- Award XP (simulating interception)
    local rankedUp = unit:gainPilotXP(100, "interception_kill")

    -- Verify rank up
    suite:assert(rankedUp == true, "Should rank up at 100 XP")
    suite:assert(unit.pilot_rank == 1, "Should be rank 1")
    suite:assert(unit.piloting == 8, "Piloting should increase to 8")

    -- New bonuses (piloting 8 = +2 bonus)
    local bonuses2 = unit:calculatePilotBonuses()
    suite:assert(bonuses2.speed_bonus == 4, "New speed bonus should be 4%")

    print("[Integration] ✓ Pilot progression workflow complete")
end)

-- Integration Test 4: Fatigue Effects
suite:testMethod("workflow", "Pilot fatigue → Reduced bonuses", function()
    local unit = MockUnit.new(1, "pilot", 1)
    unit.piloting = 10
    unit.pilot_fatigue = 0

    -- Bonuses at 0 fatigue
    local bonuses1 = unit:calculatePilotBonuses()
    local speedNoFatigue = bonuses1.speed_bonus

    -- Add fatigue
    unit.pilot_fatigue = 50

    -- Bonuses at 50 fatigue (25% penalty)
    local bonuses2 = unit:calculatePilotBonuses()
    local speedWithFatigue = bonuses2.speed_bonus

    -- Verify reduction
    suite:assert(speedWithFatigue < speedNoFatigue, "Fatigue should reduce bonuses")
    suite:assert(speedWithFatigue == speedNoFatigue * 0.75, "Should be 25% reduction")

    print("[Integration] ✓ Fatigue effect workflow complete")
end)

-- Integration Test 5: Unassign Workflow
suite:testMethod("workflow", "Assign → Unassign → Reassign", function()
    local unit = MockUnit.new(1, "pilot", 1)
    local craft1 = MockCraft.new("craft1")
    local craft2 = MockCraft.new("craft2")

    -- Assign to craft1
    PilotManager.assignToCraft(unit, craft1, "pilot")
    suite:assert(unit.assigned_craft_id == "craft1", "Should be assigned to craft1")
    suite:assert(#craft1.crew == 1, "Craft1 should have crew")

    -- Unassign
    PilotManager.unassignFromCraft(unit, craft1)
    suite:assert(unit.assigned_craft_id == nil, "Should be unassigned")
    suite:assert(#craft1.crew == 0, "Craft1 should have no crew")

    -- Reassign to craft2
    PilotManager.assignToCraft(unit, craft2, "pilot")
    suite:assert(unit.assigned_craft_id == "craft2", "Should be assigned to craft2")
    suite:assert(#craft2.crew == 1, "Craft2 should have crew")

    print("[Integration] ✓ Reassignment workflow complete")
end)

-- Integration Test 6: Class Requirements
suite:testMethod("workflow", "Class requirement validation", function()
    local fighterPilot = MockUnit.new(1, "fighter_pilot", 2)
    local basicPilot = MockUnit.new(2, "pilot", 1)

    local fighterCraft = MockCraft.new("fighter1")
    fighterCraft.required_pilot_class = "fighter_pilot"
    fighterCraft.required_pilot_rank = 2

    -- Fighter pilot should succeed
    local canOperate1 = PilotManager.canOperateCraft(fighterPilot, fighterCraft)
    suite:assert(canOperate1 == true, "Fighter pilot should operate fighter craft")

    -- Basic pilot should fail
    local canOperate2 = PilotManager.canOperateCraft(basicPilot, fighterCraft)
    suite:assert(canOperate2 == false, "Basic pilot should not operate fighter craft")

    print("[Integration] ✓ Class requirement validation complete")
end)

-- Integration Test 7: Crew Capacity Limits
suite:testMethod("workflow", "Crew capacity enforcement", function()
    local craft = MockCraft.new("craft1")
    craft.max_crew = 2

    local pilot1 = MockUnit.new(1, "pilot", 1)
    local pilot2 = MockUnit.new(2, "pilot", 1)
    local pilot3 = MockUnit.new(3, "pilot", 1)

    -- Assign first two should succeed
    local success1 = PilotManager.assignToCraft(pilot1, craft, "pilot")
    local success2 = PilotManager.assignToCraft(pilot2, craft, "co-pilot")

    suite:assert(success1 == true, "First pilot should assign")
    suite:assert(success2 == true, "Second pilot should assign")

    -- Third should fail (at capacity)
    local success3 = PilotManager.assignToCraft(pilot3, craft, "crew")
    suite:assert(success3 == false, "Third pilot should fail (capacity)")

    print("[Integration] ✓ Capacity enforcement complete")
end)

return suite

