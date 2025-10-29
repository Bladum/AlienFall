---Morale System Tests
---Tests for morale, bravery, and in-battle psychological mechanics
---Reference: design/mechanics/MoraleBraverySanity.md

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("MoraleSystem", "tests2/battlescape/morale_system_test.lua")

-- Test setup
local MoraleSystem

suite:beforeAll(function()
    MoraleSystem = require("engine.battlescape.systems.morale_system")
end)

suite:afterEach(function()
    -- Clean up test units
    if MoraleSystem and MoraleSystem._testCleanup then
        MoraleSystem._testCleanup()
    end
end)

-- Initialization Tests
suite:testMethod("MoraleSystem.initUnit", {
    description = "Initializes unit with bravery and sanity values",
    testCase = "init_unit_valid",
    type = "functional"
}, function()
    local unitId = "test_unit_1"
    local bravery = 10
    local sanity = 8

    MoraleSystem.initUnit(unitId, bravery, sanity)

    local state = MoraleSystem.getState(unitId)
    suite:assert(state ~= nil, "State should be created")
    suite:assert(state.morale == bravery, "Morale should equal bravery at start")
    suite:assert(state.maxMorale == bravery, "Max morale should equal bravery")
    suite:assert(state.sanity == sanity, "Sanity should be initialized")
    suite:assert(state.maxSanity == sanity, "Max sanity should be set")
end)

suite:testMethod("MoraleSystem.initUnit", {
    description = "Clamps bravery values to 1-12 range",
    testCase = "init_unit_clamp",
    type = "edge_case"
}, function()
    MoraleSystem.initUnit("test_high", 20, 10)
    local stateHigh = MoraleSystem.getState("test_high")
    suite:assert(stateHigh.maxMorale <= 12, "Bravery should be clamped to max 12")

    MoraleSystem.initUnit("test_low", 0, 10)
    local stateLow = MoraleSystem.getState("test_low")
    suite:assert(stateLow.maxMorale >= 1, "Bravery should be clamped to min 1")
end)

-- Morale Event Tests
suite:testMethod("MoraleSystem.onAllyKilled", {
    description = "Reduces morale when ally killed nearby",
    testCase = "ally_death_nearby",
    type = "functional"
}, function()
    local unitId = "test_unit_ally"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialMorale = MoraleSystem.getState(unitId).morale
    MoraleSystem.onAllyKilled(unitId, 3)  -- Within 5 hexes

    local newMorale = MoraleSystem.getState(unitId).morale
    suite:assert(newMorale == initialMorale - 1, "Morale should decrease by 1")
end)

suite:testMethod("MoraleSystem.onAllyKilled", {
    description = "No morale loss if ally killed far away",
    testCase = "ally_death_far",
    type = "edge_case"
}, function()
    local unitId = "test_unit_far"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialMorale = MoraleSystem.getState(unitId).morale
    MoraleSystem.onAllyKilled(unitId, 10)  -- Beyond 5 hexes

    local newMorale = MoraleSystem.getState(unitId).morale
    suite:assert(newMorale == initialMorale, "Morale should not change")
end)

suite:testMethod("MoraleSystem.onTakeDamage", {
    description = "Reduces morale when unit takes damage",
    testCase = "take_damage",
    type = "functional"
}, function()
    local unitId = "test_unit_damage"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialMorale = MoraleSystem.getState(unitId).morale
    MoraleSystem.onTakeDamage(unitId)

    local newMorale = MoraleSystem.getState(unitId).morale
    suite:assert(newMorale == initialMorale - 1, "Morale should decrease by 1 from damage")
end)

suite:testMethod("MoraleSystem.onCriticalHit", {
    description = "Reduces morale significantly on critical hit",
    testCase = "critical_hit",
    type = "functional"
}, function()
    local unitId = "test_unit_crit"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialMorale = MoraleSystem.getState(unitId).morale
    MoraleSystem.onCriticalHit(unitId)

    local newMorale = MoraleSystem.getState(unitId).morale
    suite:assert(newMorale <= initialMorale - 1, "Morale should decrease on critical")
end)

suite:testMethod("MoraleSystem.onFlanked", {
    description = "Reduces morale when flanked by enemies",
    testCase = "flanked",
    type = "functional"
}, function()
    local unitId = "test_unit_flanked"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialMorale = MoraleSystem.getState(unitId).morale
    MoraleSystem.onFlanked(unitId)

    local newMorale = MoraleSystem.getState(unitId).morale
    suite:assert(newMorale == initialMorale - 1, "Morale should decrease when flanked")
end)

suite:testMethod("MoraleSystem.onOutnumbered", {
    description = "Reduces morale when outnumbered",
    testCase = "outnumbered",
    type = "functional"
}, function()
    local unitId = "test_unit_outnumbered"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialMorale = MoraleSystem.getState(unitId).morale
    MoraleSystem.onOutnumbered(unitId)

    local newMorale = MoraleSystem.getState(unitId).morale
    suite:assert(newMorale == initialMorale - 1, "Morale should decrease when outnumbered")
end)

suite:testMethod("MoraleSystem.onCommanderKilled", {
    description = "Severely reduces morale when commander dies",
    testCase = "commander_killed",
    type = "functional"
}, function()
    local unitId = "test_unit_commander"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialMorale = MoraleSystem.getState(unitId).morale
    MoraleSystem.onCommanderKilled(unitId)

    local newMorale = MoraleSystem.getState(unitId).morale
    suite:assert(newMorale == initialMorale - 2, "Morale should decrease by 2")
end)

suite:testMethod("MoraleSystem.onNewAlienEncounter", {
    description = "Reduces morale on first alien encounter",
    testCase = "new_alien",
    type = "functional"
}, function()
    local unitId = "test_unit_alien"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialMorale = MoraleSystem.getState(unitId).morale
    MoraleSystem.onNewAlienEncounter(unitId, "sectoid")

    local newMorale = MoraleSystem.getState(unitId).morale
    suite:assert(newMorale == initialMorale - 1, "Morale should decrease on new alien")
end)

suite:testMethod("MoraleSystem.onNightMission", {
    description = "Reduces morale at night mission start",
    testCase = "night_mission",
    type = "functional"
}, function()
    local unitId = "test_unit_night"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialMorale = MoraleSystem.getState(unitId).morale
    MoraleSystem.onNightMission(unitId)

    local newMorale = MoraleSystem.getState(unitId).morale
    suite:assert(newMorale == initialMorale - 1, "Morale should decrease on night mission")
end)

-- Morale Threshold Tests
suite:testMethod("MoraleSystem.getAPModifier", {
    description = "Returns correct AP penalties at different morale levels",
    testCase = "ap_modifier_thresholds",
    type = "functional"
}, function()
    local unitId = "test_unit_ap"
    MoraleSystem.initUnit(unitId, 10, 10)

    -- High morale: no penalty
    local state = MoraleSystem.getState(unitId)
    state.morale = 8
    suite:assert(MoraleSystem.getAPModifier(unitId) == 0, "No AP penalty at high morale")

    -- Morale 2: -1 AP
    state.morale = 2
    suite:assert(MoraleSystem.getAPModifier(unitId) == -1, "Should have -1 AP at morale 2")

    -- Morale 1: -2 AP
    state.morale = 1
    suite:assert(MoraleSystem.getAPModifier(unitId) == -2, "Should have -2 AP at morale 1")

    -- Morale 0: -4 AP (panic)
    state.morale = 0
    suite:assert(MoraleSystem.getAPModifier(unitId) == -4, "Should have -4 AP at panic")
end)

suite:testMethod("MoraleSystem.getMoraleAccuracyPenalty", {
    description = "Returns correct accuracy penalties at different morale",
    testCase = "accuracy_penalty_thresholds",
    type = "functional"
}, function()
    local unitId = "test_unit_acc"
    MoraleSystem.initUnit(unitId, 10, 10)
    local state = MoraleSystem.getState(unitId)

    state.morale = 10
    suite:assert(MoraleSystem.getMoraleAccuracyPenalty(unitId) == 0, "No penalty at high morale")

    state.morale = 5
    suite:assert(MoraleSystem.getMoraleAccuracyPenalty(unitId) == -5, "-5% at morale 4-5")

    state.morale = 3
    suite:assert(MoraleSystem.getMoraleAccuracyPenalty(unitId) == -10, "-10% at morale 3")

    state.morale = 2
    suite:assert(MoraleSystem.getMoraleAccuracyPenalty(unitId) == -15, "-15% at morale 2")

    state.morale = 1
    suite:assert(MoraleSystem.getMoraleAccuracyPenalty(unitId) == -25, "-25% at morale 1")

    state.morale = 0
    suite:assert(MoraleSystem.getMoraleAccuracyPenalty(unitId) == -50, "-50% at panic")
end)

-- Status Query Tests
suite:testMethod("MoraleSystem.getMoraleStatus", {
    description = "Returns correct status string for morale level",
    testCase = "morale_status",
    type = "functional"
}, function()
    local unitId = "test_unit_status"
    MoraleSystem.initUnit(unitId, 10, 10)
    local state = MoraleSystem.getState(unitId)

    state.morale = 10
    suite:assert(MoraleSystem.getMoraleStatus(unitId) == "confident", "Should be confident")

    state.morale = 3
    suite:assert(MoraleSystem.getMoraleStatus(unitId) == "stressed", "Should be stressed")

    state.morale = 2
    suite:assert(MoraleSystem.getMoraleStatus(unitId) == "shaken", "Should be shaken")

    state.morale = 0
    suite:assert(MoraleSystem.getMoraleStatus(unitId) == "panic", "Should be panic")
end)

suite:testMethod("MoraleSystem.canAct", {
    description = "Prevents action when panicked (morale 0)",
    testCase = "panic_state",
    type = "functional"
}, function()
    local unitId = "test_unit_panic"
    MoraleSystem.initUnit(unitId, 10, 10)
    local state = MoraleSystem.getState(unitId)

    -- Normal state
    state.morale = 5
    state.state = "normal"
    local canAct, reason = MoraleSystem.canAct(unitId)
    suite:assert(canAct == true, "Should be able to act normally")

    -- Panicked state
    state.morale = 0
    state.state = "panicked"
    canAct, reason = MoraleSystem.canAct(unitId)
    suite:assert(canAct == false, "Should not be able to act when panicked")
    suite:assert(reason ~= nil, "Should provide reason")
end)

-- Morale Reset Tests
suite:testMethod("MoraleSystem.resetMorale", {
    description = "Resets morale to bravery at mission end",
    testCase = "morale_reset",
    type = "functional"
}, function()
    local unitId = "test_unit_reset"
    local bravery = 10
    MoraleSystem.initUnit(unitId, bravery, 10)

    -- Reduce morale during battle
    MoraleSystem.modifyMorale(unitId, -5, "test reduction")
    local reducedMorale = MoraleSystem.getState(unitId).morale
    suite:assert(reducedMorale < bravery, "Morale should be reduced")

    -- Reset at mission end
    MoraleSystem.resetMorale(unitId)
    local resetMorale = MoraleSystem.getState(unitId).morale
    suite:assert(resetMorale == bravery, "Morale should reset to bravery")
end)

-- Sanity Tests
suite:testMethod("MoraleSystem.applyMissionTrauma", {
    description = "Applies correct sanity loss based on mission difficulty",
    testCase = "mission_trauma",
    type = "functional"
}, function()
    local unitId = "test_unit_trauma"
    MoraleSystem.initUnit(unitId, 10, 10)

    local initialSanity = MoraleSystem.getState(unitId).sanity

    -- Standard mission: 0 loss
    MoraleSystem.applyMissionTrauma(unitId, "standard", false, 0, false)
    suite:assert(MoraleSystem.getState(unitId).sanity == initialSanity, "No loss on standard")

    -- Moderate mission: -1
    MoraleSystem.initUnit(unitId, 10, 10)
    MoraleSystem.applyMissionTrauma(unitId, "moderate", false, 0, false)
    suite:assert(MoraleSystem.getState(unitId).sanity == 9, "Should lose 1 sanity")

    -- Hard mission: -2
    MoraleSystem.initUnit(unitId, 10, 10)
    MoraleSystem.applyMissionTrauma(unitId, "hard", false, 0, false)
    suite:assert(MoraleSystem.getState(unitId).sanity == 8, "Should lose 2 sanity")

    -- Horror mission: -3
    MoraleSystem.initUnit(unitId, 10, 10)
    MoraleSystem.applyMissionTrauma(unitId, "horror", false, 0, false)
    suite:assert(MoraleSystem.getState(unitId).sanity == 7, "Should lose 3 sanity")
end)

suite:testMethod("MoraleSystem.applyMissionTrauma", {
    description = "Adds sanity loss for night missions and deaths",
    testCase = "mission_trauma_factors",
    type = "functional"
}, function()
    local unitId = "test_unit_factors"

    -- Night mission adds -1
    MoraleSystem.initUnit(unitId, 10, 10)
    MoraleSystem.applyMissionTrauma(unitId, "standard", true, 0, false)
    suite:assert(MoraleSystem.getState(unitId).sanity == 9, "Night mission should add -1")

    -- Ally deaths add -1 each
    MoraleSystem.initUnit(unitId, 10, 10)
    MoraleSystem.applyMissionTrauma(unitId, "standard", false, 2, false)
    suite:assert(MoraleSystem.getState(unitId).sanity == 8, "2 deaths should add -2")

    -- Mission failure adds -2
    MoraleSystem.initUnit(unitId, 10, 10)
    MoraleSystem.applyMissionTrauma(unitId, "standard", false, 0, true)
    suite:assert(MoraleSystem.getState(unitId).sanity == 8, "Failure should add -2")
end)

suite:testMethod("MoraleSystem.canDeploy", {
    description = "Prevents deployment when sanity is 0 (broken)",
    testCase = "deployment_check",
    type = "functional"
}, function()
    local unitId = "test_unit_deploy"
    MoraleSystem.initUnit(unitId, 10, 10)
    local state = MoraleSystem.getState(unitId)

    -- Normal sanity
    state.sanity = 5
    local canDeploy, reason = MoraleSystem.canDeploy(unitId)
    suite:assert(canDeploy == true, "Should be able to deploy with sanity > 0")

    -- Broken (sanity 0)
    state.sanity = 0
    canDeploy, reason = MoraleSystem.canDeploy(unitId)
    suite:assert(canDeploy == false, "Should not deploy when broken")
    suite:assert(reason ~= nil, "Should provide reason")
end)

-- Recovery Tests
suite:testMethod("MoraleSystem.weeklyBaseRecovery", {
    description = "Recovers 1 sanity per week at base",
    testCase = "base_recovery",
    type = "functional"
}, function()
    local unitId = "test_unit_recovery"
    MoraleSystem.initUnit(unitId, 10, 5)

    local initialSanity = MoraleSystem.getState(unitId).sanity
    MoraleSystem.weeklyBaseRecovery(unitId)

    local newSanity = MoraleSystem.getState(unitId).sanity
    suite:assert(newSanity == initialSanity + 1, "Should recover 1 sanity per week")
end)

suite:testMethod("MoraleSystem.weeklyTempleRecovery", {
    description = "Recovers additional 1 sanity with Temple",
    testCase = "temple_recovery",
    type = "functional"
}, function()
    local unitId = "test_unit_temple"
    MoraleSystem.initUnit(unitId, 10, 5)

    local initialSanity = MoraleSystem.getState(unitId).sanity
    MoraleSystem.weeklyTempleRecovery(unitId)

    local newSanity = MoraleSystem.getState(unitId).sanity
    suite:assert(newSanity == initialSanity + 1, "Temple should add 1 sanity per week")
end)

suite:testMethod("MoraleSystem.medicalTreatment", {
    description = "Immediately recovers 3 sanity with treatment",
    testCase = "medical_treatment",
    type = "functional"
}, function()
    local unitId = "test_unit_medical"
    MoraleSystem.initUnit(unitId, 10, 5)

    local initialSanity = MoraleSystem.getState(unitId).sanity
    MoraleSystem.medicalTreatment(unitId)

    local newSanity = MoraleSystem.getState(unitId).sanity
    suite:assert(newSanity == initialSanity + 3, "Should recover 3 sanity immediately")
end)

suite:testMethod("MoraleSystem.leaveVacation", {
    description = "Recovers 5 sanity with leave/vacation",
    testCase = "leave_vacation",
    type = "functional"
}, function()
    local unitId = "test_unit_leave"
    MoraleSystem.initUnit(unitId, 10, 3)

    local initialSanity = MoraleSystem.getState(unitId).sanity
    MoraleSystem.leaveVacation(unitId)

    local newSanity = MoraleSystem.getState(unitId).sanity
    suite:assert(newSanity == initialSanity + 5, "Should recover 5 sanity with leave")
end)

return suite

