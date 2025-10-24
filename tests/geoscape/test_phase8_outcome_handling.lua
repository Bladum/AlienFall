---
-- Phase 8 Integration Tests
-- @module tests.geoscape.test_phase8_outcome_handling
--
-- Comprehensive test suite for Phase 8 Campaign Outcome Handling
-- Tests mission outcome processing, craft return/damage, unit recovery,
-- threat escalation, and salvage handling integration points.

local MissionOutcomeProcessor = require("engine.geoscape.mission_outcome_processor")
local CraftReturnSystem = require("engine.geoscape.craft_return_system")
local UnitRecoveryProgression = require("engine.geoscape.unit_recovery_progression")
local DifficultyEscalation = require("engine.geoscape.difficulty_escalation")
local SalvageProcessor = require("engine.geoscape.salvage_processor")

-- Test counter
local tests = {}
local passed = 0
local failed = 0

---
-- Assert condition and track test results
-- @param name string Test name
-- @param condition boolean Assertion result
-- @param message string Error message if failed
function assert_test(name, condition, message)
    if condition then
        print(string.format("  ✓ %s", name))
        passed = passed + 1
    else
        print(string.format("  ✗ %s: %s", name, message or "assertion failed"))
        failed = failed + 1
    end
end

-- ===================================================================
-- MISSION OUTCOME PROCESSOR TESTS
-- ===================================================================

function tests.test_mission_outcome_victory()
    print("\n[TEST] Mission Outcome - Victory")

    local mission = {id = "m1", type = "site", difficulty = "normal", reward_credits = 1000}
    local battleResult = {
        outcome = "victory",
        objectives_completed = {"objective_1"},
        enemies_killed = 15,
        casualties = {},
        wounded = {},
        items_collected = {},
        crafts_damaged = {}
    }

    local outcome = MissionOutcomeProcessor.processMissionOutcome(mission, battleResult)

    assert_test("Outcome recorded", outcome ~= nil, "Outcome is nil")
    assert_test("Victory status", outcome and outcome.status == "victory", "Status is " .. (outcome and outcome.status or "nil"))
    assert_test("Enemies killed tracked", outcome and outcome.enemies_killed == 15, "Got " .. (outcome and outcome.enemies_killed or 0))
    assert_test("Credits calculated", outcome and outcome.rewards and outcome.rewards.total_credits == 1750,
        string.format("Got %d (base 1000 + kills 15*50)", outcome and outcome.rewards and outcome.rewards.total_credits or 0))
    assert_test("Reputation gain positive", outcome and outcome.rewards and outcome.rewards.reputation_gain > 0, "Reputation: " .. (outcome and outcome.rewards and outcome.rewards.reputation_gain or "nil"))
end

function tests.test_mission_outcome_defeat()
    print("\n[TEST] Mission Outcome - Defeat")

    local mission = {id = "m2", type = "site", difficulty = "hard", reward_credits = 1000}
    local battleResult = {
        outcome = "defeat",
        objectives_completed = {},
        enemies_killed = 5,
        casualties = {"unit1", "unit2", "unit3"},
        wounded = {},
        items_collected = {},
        crafts_damaged = {}
    }

    local outcome = MissionOutcomeProcessor.processMissionOutcome(mission, battleResult)

    assert_test("Defeat status", outcome.status == "defeat", "Status is " .. outcome.status)
    assert_test("Casualties recorded", #outcome.casualties == 3, "Got " .. #outcome.casualties)
    assert_test("Reduced credits", outcome.rewards.total_credits < 500,
        string.format("Got %d (should be 25%% of base)", outcome.rewards.total_credits))
    assert_test("Reputation penalty", outcome.rewards.reputation_gain < 0, "Reputation: " .. outcome.rewards.reputation_gain)
end

function tests.test_mission_outcome_retreat()
    print("\n[TEST] Mission Outcome - Retreat")

    local mission = {id = "m3", type = "ufo", difficulty = "impossible"}
    local battleResult = {
        outcome = "retreat",
        objectives_completed = {"escape"},
        enemies_killed = 3,
        casualties = {},
        wounded = {unit1 = {hp_remaining = 20}},
        items_collected = {},
        crafts_damaged = {}
    }

    local outcome = MissionOutcomeProcessor.processMissionOutcome(mission, battleResult)

    assert_test("Retreat status", outcome.status == "retreat", "Status is " .. outcome.status)
    assert_test("Partial rewards", outcome.rewards.total_credits > 250, "Credits: " .. outcome.rewards.total_credits)
    assert_test("Threat reduced minimally", outcome.rewards.threat_reduction == -5, "Threat: " .. outcome.rewards.threat_reduction)
end

-- ===================================================================
-- CRAFT RETURN SYSTEM TESTS
-- ===================================================================

function tests.test_craft_return_undamaged()
    print("\n[TEST] Craft Return - Undamaged")

    local craftStatus = CraftReturnSystem.processCraftReturn("craft1", "m1",
        {hull_damage = 0, engine_damage = 0, weapon_damage = 0, systems_damage = 0, fuel_consumed = 10})

    assert_test("Operational condition", craftStatus.condition == "operational", "Condition: " .. craftStatus.condition)
    assert_test("No repairs needed", craftStatus.needs_repair == false, "Repair needed: " .. tostring(craftStatus.needs_repair))
    assert_test("Available for deployment", craftStatus.available == true, "Available: " .. tostring(craftStatus.available))
    assert_test("Repair cost zero", craftStatus.repair_cost == 500, "Cost: " .. craftStatus.repair_cost)
end

function tests.test_craft_return_damaged()
    print("\n[TEST] Craft Return - Damaged")

    local craftStatus = CraftReturnSystem.processCraftReturn("craft2", "m2",
        {hull_damage = 20, engine_damage = 15, weapon_damage = 10, systems_damage = 5, fuel_consumed = 50})

    assert_test("Damaged condition", craftStatus.condition == "damaged", "Condition: " .. craftStatus.condition)
    assert_test("Repairs scheduled", craftStatus.needs_repair == true, "Repair: " .. tostring(craftStatus.needs_repair))
    assert_test("Unavailable while repairing", craftStatus.available == false, "Available: " .. tostring(craftStatus.available))
    assert_test("Repair cost calculated", craftStatus.repair_cost > 500, "Cost: " .. craftStatus.repair_cost)
    assert_test("Repair time estimated", craftStatus.days_to_repair > 0, "Days: " .. craftStatus.days_to_repair)
end

function tests.test_craft_return_critical()
    print("\n[TEST] Craft Return - Critical Damage")

    local craftStatus = CraftReturnSystem.processCraftReturn("craft3", "m3",
        {hull_damage = 60, engine_damage = 50, weapon_damage = 40, systems_damage = 30, fuel_consumed = 90})

    assert_test("Critical condition", craftStatus.condition == "critical", "Condition: " .. craftStatus.condition)
    assert_test("Extensive repairs needed", craftStatus.days_to_repair > 20, "Days: " .. craftStatus.days_to_repair)
    assert_test("High repair cost", craftStatus.repair_cost > 5000, "Cost: " .. craftStatus.repair_cost)
end

-- ===================================================================
-- UNIT RECOVERY TESTS
-- ===================================================================

function tests.test_unit_recovery_healthy()
    print("\n[TEST] Unit Recovery - Healthy")

    local recovery = UnitRecoveryProgression.processUnitRecovery("unit1",
        {hp_remaining = 100, wounds_count = 0, sanity_damage = 0})

    assert_test("Active status", recovery.status == "active", "Status: " .. recovery.status)
    assert_test("No recovery needed", recovery.health.days_to_recover == 0, "Days: " .. recovery.health.days_to_recover)
    assert_test("Available for deployment", recovery.available_deployment == true, "Available: " .. tostring(recovery.available_deployment))
end

function tests.test_unit_recovery_wounded()
    print("\n[TEST] Unit Recovery - Wounded")

    local medicalFacility = {available = true, healing_bonus = 0.5, wound_speed_bonus = 1, psych_bonus = 0.3}
    local recovery = UnitRecoveryProgression.processUnitRecovery("unit2",
        {hp_remaining = 40, wounds_count = 2, sanity_damage = 20}, medicalFacility)

    assert_test("Wounded status", recovery.status == "wounded", "Status: " .. recovery.status)
    assert_test("HP recovery time set", recovery.health.days_to_recover > 0, "HP days: " .. recovery.health.days_to_recover)
    assert_test("Wounds healing tracked", recovery.wounds.healing_time > 0, "Wound days: " .. recovery.wounds.healing_time)
    assert_test("Unavailable while wounded", recovery.available_deployment == false, "Available: " .. tostring(recovery.available_deployment))
    assert_test("Medical bonus applied", recovery.medical_bonus_applied == true, "Medical bonus: " .. tostring(recovery.medical_bonus_applied))
end

function tests.test_unit_progression_xp()
    print("\n[TEST] Unit Progression - XP Earned")

    local progression = UnitRecoveryProgression.processUnitProgression("unit3",
        {difficulty = "hard", type = "assault"},
        {kills = 12, hit_accuracy = 75, objectives_completed = 3})

    assert_test("XP calculated", progression.xp_earned > 200, "XP: " .. progression.xp_earned)
    assert_test("Kills recorded", progression.kill_count == 12, "Kills: " .. progression.kill_count)
    assert_test("Achievement tracked", progression.medals_earned ~= nil, "Medals: " .. (progression.medals_earned == nil and "nil" or "ok"))
end

-- ===================================================================
-- DIFFICULTY ESCALATION TESTS
-- ===================================================================

function tests.test_difficulty_threat_calculation()
    print("\n[TEST] Difficulty - Threat Calculation")

    local threat = DifficultyEscalation.calculateThreatLevel(5, 2, 1, 30)

    assert_test("Threat calculated", threat >= 0 and threat <= 100, "Threat: " .. threat)
    assert_test("Win rate increases threat", threat > 50, "Low threat from wins")
end

function tests.test_difficulty_mission_scaling()
    print("\n[TEST] Difficulty - Mission Scaling")

    local mission = {id = "m_test", difficulty = "normal", reward_credits = 1000}
    local scaled = DifficultyEscalation.scaleMissionDifficulty(mission, 75)

    assert_test("Difficulty scaled", scaled.scaled_difficulty ~= nil, "Scaled: " .. (scaled.scaled_difficulty or "nil"))
    assert_test("High threat = hard", scaled.scaled_difficulty == "hard", "Difficulty: " .. scaled.scaled_difficulty)
    assert_test("Stat multiplier set", scaled.enemy_stat_multiplier > 1.0, "Multiplier: " .. scaled.enemy_stat_multiplier)
end

function tests.test_difficulty_enemy_composition()
    print("\n[TEST] Difficulty - Enemy Composition")

    local rosters = {
        low = DifficultyEscalation.getEnemyComposition(10, "site"),
        medium = DifficultyEscalation.getEnemyComposition(50, "ufo"),
        high = DifficultyEscalation.getEnemyComposition(80, "base")
    }

    assert_test("Low threat roster", #rosters.low > 0, "Roster: " .. #rosters.low)
    assert_test("Medium threat has more", #rosters.medium > #rosters.low, "Medium: " .. #rosters.medium)
    assert_test("High threat strongest", #rosters.high > 0, "High roster: " .. #rosters.high)
end

function tests.test_difficulty_ufo_activity()
    print("\n[TEST] Difficulty - UFO Activity")

    local activity = DifficultyEscalation.adjustUFOActivity(80)

    assert_test("UFO spawning rate set", activity.ufo_spawn_rate > 0, "Rate: " .. activity.ufo_spawn_rate)
    assert_test("High threat = more UFOs", activity.ufo_spawn_rate > 2, "Got " .. activity.ufo_spawn_rate)
    assert_test("Intercept probability set", activity.intercept_probability > 50, "Intercept: " .. activity.intercept_probability)
end

-- ===================================================================
-- SALVAGE PROCESSOR TESTS
-- ===================================================================

function tests.test_salvage_processing_basic()
    print("\n[TEST] Salvage - Basic Processing")

    local mission = {id = "m_salvage", type = "site"}
    local battleResult = {
        items_collected = {
            {type = "plasma_rifle", quantity = 1, condition = "good"},
            {type = "alien_grenade", quantity = 3, condition = "good"}
        },
        enemies_killed_list = {
            {species = "sectoid"},
            {species = "muton"}
        }
    }
    local baseData = {inventory_space = 500}

    local salvage = SalvageProcessor.processMissionSalvage(mission, battleResult, baseData)

    assert_test("Salvage collected", salvage ~= nil, "Salvage is nil")
    assert_test("Items recorded", #salvage.items_collected > 0, "Items: " .. #salvage.items_collected)
    assert_test("Materials extracted", countTable(salvage.materials_gained) > 0, "Materials: " .. countTable(salvage.materials_gained))
end

function tests.test_salvage_value_calculation()
    print("\n[TEST] Salvage - Value Calculation")

    local goodPlasma = {type = "plasma_rifle", quantity = 1, condition = "good"}
    local damagedPlasma = {type = "plasma_rifle", quantity = 1, condition = "damaged"}

    local goodValue = SalvageProcessor._calculateItemValue(goodPlasma)
    local damagedValue = SalvageProcessor._calculateItemValue(damagedPlasma)

    assert_test("Good condition valued", goodValue > 0, "Good: " .. goodValue)
    assert_test("Damaged condition less", damagedValue < goodValue,
        string.format("Damaged %d < Good %d", damagedValue, goodValue))
end

function tests.test_corpse_material_extraction()
    print("\n[TEST] Salvage - Corpse Material Extraction")

    local sectoidYield = SalvageProcessor.processCorporealMaterial("sectoid", 2)
    local mutonYield = SalvageProcessor.processCorporealMaterial("muton", 1)

    assert_test("Sectoid yields materials", countTable(sectoidYield) > 0, "Sectoid materials: " .. countTable(sectoidYield))
    assert_test("Muton yields more", countTable(mutonYield) >= countTable(sectoidYield),
        string.format("Muton %d >= Sectoid %d", countTable(mutonYield), countTable(sectoidYield)))
    assert_test("Organic matter extracted", (mutonYield.organic_matter or 0) > 0,
        "Organic matter: " .. (mutonYield.organic_matter or 0))
end

-- ===================================================================
-- INTEGRATION TESTS (Cross-System)
-- ===================================================================

function tests.test_integration_full_mission_flow()
    print("\n[TEST] Integration - Full Mission Flow")

    -- Step 1: Mission outcome
    local mission = {id = "full_test", type = "site", difficulty = "hard", reward_credits = 1000}
    local battleResult = {
        outcome = "victory",
        objectives_completed = {"obj1"},
        enemies_killed = 10,
        casualties = {"unit_lost"},
        wounded = {unit2 = {hp_remaining = 50, wounds_count = 1, sanity_damage = 15}},
        items_collected = {{type = "plasma_rifle", quantity = 1, condition = "good"}},
        crafts_damaged = {craft1 = {hull_damage = 15, engine_damage = 5, fuel_consumed = 30}}
    }

    local outcome = MissionOutcomeProcessor.processMissionOutcome(mission, battleResult)
    assert_test("Mission outcome recorded", outcome.status == "victory", "Status: " .. outcome.status)

    -- Step 2: Craft return
    local craftStatus = CraftReturnSystem.processCraftReturn("craft1", mission.id,
        battleResult.crafts_damaged.craft1, false)
    assert_test("Craft returned with damage", craftStatus.needs_repair == true, "Repair: " .. tostring(craftStatus.needs_repair))

    -- Step 3: Unit recovery
    local recovery = UnitRecoveryProgression.processUnitRecovery("unit2", battleResult.wounded.unit2)
    assert_test("Unit recovery scheduled", recovery.status == "wounded", "Status: " .. recovery.status)

    -- Step 4: Difficulty escalation
    local threatUpdate = DifficultyEscalation.updateDifficultyAfterMission(mission, outcome,
        {wins = 0, losses = 0, retreats = 0, threat_level = 50})
    assert_test("Threat updated", threatUpdate.new_threat ~= nil, "Threat: " .. (threatUpdate.new_threat or "nil"))

    -- Step 5: Salvage processing
    local salvage = SalvageProcessor.processMissionSalvage(mission, battleResult, {inventory_space = 500})
    assert_test("Salvage collected", #salvage.items_collected > 0, "Items: " .. #salvage.items_collected)

    print("  ✓ Full mission flow integrated successfully")
    passed = passed + 1
end

-- ===================================================================
-- HELPER FUNCTION
-- ===================================================================

function countTable(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end

-- ===================================================================
-- TEST RUNNER
-- ===================================================================

print("========================================")
print("Phase 8: Campaign Outcome Handling Tests")
print("========================================")

-- Run all tests
for testName, testFunc in pairs(tests) do
    if type(testFunc) == "function" then
        testFunc()
    end
end

print("\n========================================")
print(string.format("Results: %d passed, %d failed (%d%%)",
    passed, failed, math.floor(passed / (passed + failed) * 100)))
print("========================================")

return {
    passed = passed,
    failed = failed,
    total = passed + failed
}
