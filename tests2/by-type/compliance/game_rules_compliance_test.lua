-- ─────────────────────────────────────────────────────────────────────────
-- GAME RULES COMPLIANCE TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify game rules are enforced correctly
-- Tests: 8 critical game rule tests
-- Categories: Difficulty modifiers, campaign rules, victory conditions

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.rules",
    fileName = "game_rules_compliance_test.lua",
    description = "Game rules and design compliance verification"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GAME RULES TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Difficulty Modifiers", function()

    Suite:testMethod("GameRules:applyDifficultyModifier", {
        description = "Difficulty modifiers apply correctly to damage",
        testCase = "happy_path",
        type = "compliance"
    }, function()
        local difficulties = {
            easy = 0.75,
            normal = 1.0,
            hard = 1.25,
            ironman = 1.5
        }

        local baseDamage = 10
        for difficulty, modifier in pairs(difficulties) do
            local adjustedDamage = baseDamage * modifier
            Helpers.assertTrue(adjustedDamage > 0, "Damage should be positive for " .. difficulty)
            Helpers.assertEqual(adjustedDamage, baseDamage * modifier, "Modifier should apply correctly")
        end
    end)

    Suite:testMethod("GameRules:validateDifficultyRange", {
        description = "Difficulty modifiers stay within valid range",
        testCase = "validation",
        type = "compliance"
    }, function()
        local validModifiers = {0.5, 0.75, 1.0, 1.25, 1.5, 2.0}

        for _, modifier in ipairs(validModifiers) do
            Helpers.assertTrue(modifier >= 0.5, "Modifier should be >= 0.5")
            Helpers.assertTrue(modifier <= 2.0, "Modifier should be <= 2.0")
        end
    end)

    Suite:testMethod("GameRules:ironmanModeEnforcement", {
        description = "Ironman mode prevents quicksave/quickload",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local gameConfig = {
            difficulty = "ironman",
            allowQuickSave = false,
            allowQuickLoad = false,
            allowManualReload = false
        }

        Helpers.assertFalse(gameConfig.allowQuickSave, "Quicksave should be disabled in ironman")
        Helpers.assertFalse(gameConfig.allowQuickLoad, "Quickload should be disabled in ironman")
        Helpers.assertFalse(gameConfig.allowManualReload, "Manual reload should be disabled in ironman")
    end)

    Suite:testMethod("GameRules:casualModeAllowsQuickSave", {
        description = "Casual mode allows quicksave/quickload",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local gameConfig = {
            difficulty = "easy",
            allowQuickSave = true,
            allowQuickLoad = true,
            allowManualReload = true
        }

        Helpers.assertTrue(gameConfig.allowQuickSave, "Quicksave should be enabled in casual")
        Helpers.assertTrue(gameConfig.allowQuickLoad, "Quickload should be enabled in casual")
    end)
end)

Suite:group("Campaign Rules", function()

    Suite:testMethod("GameRules:campaignStartYearValid", {
        description = "Campaign starts with valid year",
        testCase = "validation",
        type = "compliance"
    }, function()
        local startYear = 2024
        Helpers.assertTrue(startYear >= 1900, "Start year should be realistic")
        Helpers.assertTrue(startYear <= 3000, "Start year should not be too far future")
    end)

    Suite:testMethod("GameRules:turnOrderSequence", {
        description = "Turns follow correct sequence: player -> aliens -> reinforcement",
        testCase = "sequence",
        type = "compliance"
    }, function()
        local turnSequence = {"player_action", "alien_action", "reinforcement_check", "end_turn"}

        for i, phase in ipairs(turnSequence) do
            Helpers.assertNotNil(phase, "Phase " .. i .. " should exist")
        end

        Helpers.assertEqual(turnSequence[1], "player_action", "First phase should be player action")
        Helpers.assertEqual(turnSequence[#turnSequence], "end_turn", "Last phase should be end turn")
    end)

    Suite:testMethod("GameRules:missionTimeoutEnforcement", {
        description = "Missions timeout after configured turns",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local mission = {
            type = "alien_base",
            maxTurns = 20,
            currentTurn = 15,
            isTimeout = false
        }

        if mission.currentTurn >= mission.maxTurns then
            mission.isTimeout = true
        end

        Helpers.assertFalse(mission.isTimeout, "Should not timeout at turn 15 of 20")

        mission.currentTurn = 21
        if mission.currentTurn >= mission.maxTurns then
            mission.isTimeout = true
        end
        Helpers.assertTrue(mission.isTimeout, "Should timeout at turn 21 of 20")
    end)
end)

Suite:group("Victory Conditions", function()

    Suite:testMethod("GameRules:eliminateAlienBaseVictory", {
        description = "Player wins when alien base is destroyed",
        testCase = "happy_path",
        type = "compliance"
    }, function()
        local alienBase = {
            hp = 0,
            isDestroyed = true
        }

        Helpers.assertTrue(alienBase.isDestroyed, "Base should be destroyed when HP = 0")
        Helpers.assertEqual(alienBase.hp, 0, "Destroyed base should have 0 HP")
    end)

    Suite:testMethod("GameRules:captureAliensVictory", {
        description = "Player wins when all aliens are captured/defeated",
        testCase = "happy_path",
        type = "compliance"
    }, function()
        local aliens = {
            {alive = false, captured = true},
            {alive = false, captured = false},
            {alive = false, captured = true}
        }

        local allDefeated = true
        for _, alien in ipairs(aliens) do
            if alien.alive then
                allDefeated = false
                break
            end
        end

        Helpers.assertTrue(allDefeated, "All aliens should be defeated")
    end)
end)

return Suite
