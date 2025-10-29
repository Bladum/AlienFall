---Sanity System Tests
---Tests for long-term sanity management between missions

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("SanitySystem", "tests2/battlescape/sanity_system_test.lua")

local MoraleSystem

suite:beforeAll(function()
    MoraleSystem = require("engine.battlescape.systems.morale_system")
end)

-- Sanity Accuracy Penalty Tests
suite:testMethod("MoraleSystem.getSanityAccuracyPenalty", {
    description = "Returns correct accuracy penalties based on sanity",
    testCase = "sanity_accuracy_penalties",
    type = "functional"
}, function()
    local unitId = "test_sanity_acc"
    MoraleSystem.initUnit(unitId, 10, 10)
    local state = MoraleSystem.getState(unitId)

    state.sanity = 10
    suite:assert(MoraleSystem.getSanityAccuracyPenalty(unitId) == 0, "No penalty at high sanity")

    state.sanity = 7
    suite:assert(MoraleSystem.getSanityAccuracyPenalty(unitId) == -5, "-5% at sanity 7-9")

    state.sanity = 5
    suite:assert(MoraleSystem.getSanityAccuracyPenalty(unitId) == -10, "-10% at sanity 5-6")

    state.sanity = 3
    suite:assert(MoraleSystem.getSanityAccuracyPenalty(unitId) == -15, "-15% at sanity 3-4")

    state.sanity = 1
    suite:assert(MoraleSystem.getSanityAccuracyPenalty(unitId) == -25, "-25% at sanity 1-2")
end)

-- Sanity Morale Modifier Tests
suite:testMethod("MoraleSystem.getSanityMoraleModifier", {
    description = "Low sanity reduces starting morale",
    testCase = "sanity_morale_modifier",
    type = "functional"
}, function()
    local unitId = "test_sanity_morale"
    MoraleSystem.initUnit(unitId, 10, 10)
    local state = MoraleSystem.getState(unitId)

    state.sanity = 10
    suite:assert(MoraleSystem.getSanityMoraleModifier(unitId) == 0, "No modifier at high sanity")

    state.sanity = 5
    suite:assert(MoraleSystem.getSanityMoraleModifier(unitId) == -1, "-1 morale at sanity 5-6")

    state.sanity = 3
    suite:assert(MoraleSystem.getSanityMoraleModifier(unitId) == -2, "-2 morale at sanity 3-4")

    state.sanity = 1
    suite:assert(MoraleSystem.getSanityMoraleModifier(unitId) == -3, "-3 morale at sanity 1-2")
end)

-- Sanity Status Tests
suite:testMethod("MoraleSystem.getSanityStatus", {
    description = "Returns correct status string for sanity level",
    testCase = "sanity_status",
    type = "functional"
}, function()
    local unitId = "test_sanity_status"
    MoraleSystem.initUnit(unitId, 10, 10)
    local state = MoraleSystem.getState(unitId)

    state.sanity = 10
    suite:assert(MoraleSystem.getSanityStatus(unitId) == "stable", "Should be stable")

    state.sanity = 7
    suite:assert(MoraleSystem.getSanityStatus(unitId) == "strained", "Should be strained")

    state.sanity = 5
    suite:assert(MoraleSystem.getSanityStatus(unitId) == "fragile", "Should be fragile")

    state.sanity = 3
    suite:assert(MoraleSystem.getSanityStatus(unitId) == "breaking", "Should be breaking")

    state.sanity = 1
    suite:assert(MoraleSystem.getSanityStatus(unitId) == "unstable", "Should be unstable")

    state.sanity = 0
    suite:assert(MoraleSystem.getSanityStatus(unitId) == "broken", "Should be broken")
end)

-- Broken State Tests
suite:testMethod("MoraleSystem.canDeploy", {
    description = "Broken units (sanity 0) cannot deploy",
    testCase = "broken_state",
    type = "functional"
}, function()
    local unitId = "test_broken"
    MoraleSystem.initUnit(unitId, 10, 0)

    local canDeploy, reason = MoraleSystem.canDeploy(unitId)
    suite:assert(canDeploy == false, "Cannot deploy when broken")
    suite:assert(reason:match("broken") ~= nil, "Reason should mention broken state")
end)

-- Combined Recovery Test
suite:testMethod("MoraleSystem.weeklyRecovery", {
    description = "Combined base + Temple recovery",
    testCase = "combined_recovery",
    type = "integration"
}, function()
    local unitId = "test_combined"
    MoraleSystem.initUnit(unitId, 10, 4)

    local initialSanity = MoraleSystem.getState(unitId).sanity

    -- Base recovery: +1
    MoraleSystem.weeklyBaseRecovery(unitId)
    local afterBase = MoraleSystem.getState(unitId).sanity
    suite:assert(afterBase == initialSanity + 1, "Base recovery should add 1")

    -- Temple recovery: +1 additional
    MoraleSystem.weeklyTempleRecovery(unitId)
    local afterTemple = MoraleSystem.getState(unitId).sanity
    suite:assert(afterTemple == afterBase + 1, "Temple should add 1 more")
    suite:assert(afterTemple == initialSanity + 2, "Total should be +2 with Temple")
end)

-- Recovery from Broken State
suite:testMethod("MoraleSystem.recoveryFromBroken", {
    description = "Unit can recover from broken state over time",
    testCase = "recovery_from_broken",
    type = "integration"
}, function()
    local unitId = "test_recover_broken"
    MoraleSystem.initUnit(unitId, 10, 0)

    -- Cannot deploy when broken
    suite:assert(MoraleSystem.canDeploy(unitId) == false, "Should be broken")

    -- Apply medical treatment
    MoraleSystem.medicalTreatment(unitId)
    local afterTreatment = MoraleSystem.getState(unitId).sanity
    suite:assert(afterTreatment == 3, "Should have 3 sanity after treatment")

    -- Can deploy again
    suite:assert(MoraleSystem.canDeploy(unitId) == true, "Should be able to deploy")
end)

return suite

