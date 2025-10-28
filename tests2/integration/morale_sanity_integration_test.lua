---Morale/Sanity Integration Tests
---Tests for complete mission flow and penalty stacking

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("MoraleSanityIntegration", "tests2/integration/morale_sanity_integration_test.lua")

local MoraleSystem

suite:beforeAll(function()
    MoraleSystem = require("engine.battlescape.systems.morale_system")
end)

-- Complete Mission Flow Test
suite:testMethod("completeMissionFlow", {
    description = "Complete mission: morale during, sanity after, reset",
    testCase = "complete_mission_flow",
    type = "integration"
}, function()
    local unitId = "test_mission_flow"
    local bravery = 10
    local sanity = 10

    -- Mission start
    MoraleSystem.initUnit(unitId, bravery, sanity)
    suite:assert(MoraleSystem.getState(unitId).morale == bravery, "Morale starts at bravery")

    -- During mission: morale events
    MoraleSystem.onTakeDamage(unitId)
    MoraleSystem.onAllyKilled(unitId, 3)
    local duringMorale = MoraleSystem.getState(unitId).morale
    suite:assert(duringMorale < bravery, "Morale should decrease during combat")

    -- Mission end: reset morale
    MoraleSystem.resetMorale(unitId)
    suite:assert(MoraleSystem.getState(unitId).morale == bravery, "Morale resets to bravery")

    -- Post-mission: sanity loss
    MoraleSystem.applyMissionTrauma(unitId, "moderate", false, 1, false)
    local postSanity = MoraleSystem.getState(unitId).sanity
    suite:assert(postSanity == 8, "Sanity should be 10 - 1 (mission) - 1 (death) = 8")

    -- Between missions: recovery
    MoraleSystem.weeklyBaseRecovery(unitId)
    suite:assert(MoraleSystem.getState(unitId).sanity == 9, "Sanity should recover")
end)

-- Penalty Stacking Test
suite:testMethod("penaltyStacking", {
    description = "Morale + Sanity penalties stack correctly",
    testCase = "penalty_stacking",
    type = "integration"
}, function()
    local unitId = "test_stacking"
    MoraleSystem.initUnit(unitId, 10, 10)
    local state = MoraleSystem.getState(unitId)

    -- Low morale: -10% accuracy
    state.morale = 3
    local moralePenalty = MoraleSystem.getMoraleAccuracyPenalty(unitId)

    -- Low sanity: -10% accuracy
    state.sanity = 5
    local sanityPenalty = MoraleSystem.getSanityAccuracyPenalty(unitId)

    -- Total penalty should be -20%
    local totalPenalty = moralePenalty + sanityPenalty
    suite:assert(totalPenalty == -20, "Penalties should stack: -10 + -10 = -20")
end)

-- Roster Rotation Test
suite:testMethod("rosterRotation", {
    description = "Simulates roster rotation for sanity recovery",
    testCase = "roster_rotation",
    type = "integration"
}, function()
    -- Squad A: Deploy and trauma
    local squadA = {"soldier_a1", "soldier_a2"}
    for _, unitId in ipairs(squadA) do
        MoraleSystem.initUnit(unitId, 10, 10)
        MoraleSystem.applyMissionTrauma(unitId, "hard", false, 0, false)
    end

    -- Squad A sanity should be 8
    for _, unitId in ipairs(squadA) do
        suite:assert(MoraleSystem.getState(unitId).sanity == 8, "Squad A should have 8 sanity")
    end

    -- Squad B: Fresh reserves
    local squadB = {"soldier_b1", "soldier_b2"}
    for _, unitId in ipairs(squadB) do
        MoraleSystem.initUnit(unitId, 10, 10)
    end

    -- Deploy Squad B while Squad A recovers
    -- Simulate 1 week recovery for Squad A
    for _, unitId in ipairs(squadA) do
        MoraleSystem.weeklyBaseRecovery(unitId)
        MoraleSystem.weeklyTempleRecovery(unitId)
    end

    -- Squad A should have recovered to 10
    for _, unitId in ipairs(squadA) do
        suite:assert(MoraleSystem.getState(unitId).sanity == 10, "Squad A should recover to 10")
    end
end)

-- Psychological Breakdown Test
suite:testMethod("psychologicalBreakdown", {
    description = "Unit breaks down after sustained trauma",
    testCase = "breakdown_scenario",
    type = "integration"
}, function()
    local unitId = "test_breakdown"
    MoraleSystem.initUnit(unitId, 6, 6)  -- Low base stats

    -- Mission 1: Horror mission
    MoraleSystem.applyMissionTrauma(unitId, "horror", true, 2, false)
    -- -3 (horror) -1 (night) -2 (deaths) = -6 total
    suite:assert(MoraleSystem.getState(unitId).sanity == 0, "Should be broken")
    suite:assert(MoraleSystem.canDeploy(unitId) == false, "Cannot deploy when broken")

    -- Recovery: Medical treatment + weekly recovery
    MoraleSystem.medicalTreatment(unitId)
    suite:assert(MoraleSystem.getState(unitId).sanity == 3, "Should have 3 after treatment")

    MoraleSystem.weeklyBaseRecovery(unitId)
    MoraleSystem.weeklyTempleRecovery(unitId)
    suite:assert(MoraleSystem.getState(unitId).sanity == 5, "Should recover to 5")
    suite:assert(MoraleSystem.canDeploy(unitId) == true, "Can deploy again")
end)

-- AP Loss from Combined Psychological State
suite:testMethod("combinedAPLoss", {
    description = "AP penalties from morale OR sanity",
    testCase = "combined_ap_loss",
    type = "integration"
}, function()
    local unitId = "test_ap_combined"
    MoraleSystem.initUnit(unitId, 10, 10)
    local state = MoraleSystem.getState(unitId)

    -- High morale, low sanity
    state.morale = 8
    state.sanity = 2
    suite:assert(MoraleSystem.getAPModifier(unitId) == -1, "Sanity 2 should give -1 AP")

    -- Low morale, high sanity
    state.morale = 2
    state.sanity = 8
    suite:assert(MoraleSystem.getAPModifier(unitId) == -1, "Morale 2 should give -1 AP")

    -- Both low (uses minimum)
    state.morale = 1
    state.sanity = 2
    suite:assert(MoraleSystem.getAPModifier(unitId) == -2, "Morale 1 should give -2 AP")
end)

return suite

