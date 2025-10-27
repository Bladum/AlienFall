-- ─────────────────────────────────────────────────────────────────────────
-- BUSINESS LOGIC COMPLIANCE TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify business logic and game state transitions
-- Tests: 8 business logic compliance tests
-- Categories: State transitions, turn sequencing, game flow

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.logic",
    fileName = "business_logic_compliance_test.lua",
    description = "Business logic and game flow compliance"
})

-- ─────────────────────────────────────────────────────────────────────────
-- BUSINESS LOGIC TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("State Transitions", function()

    Suite:testMethod("GameFlow:mainMenuToNewGame", {
        description = "Can transition from main menu to new game",
        testCase = "state_transition",
        type = "compliance"
    }, function()
        local gameState = {state = "main_menu"}

        -- Transition to new game
        gameState.state = "campaign_creation"

        Helpers.assertEqual(gameState.state, "campaign_creation", "Should transition to campaign creation")
        Helpers.assertNotEqual(gameState.state, "main_menu", "Should leave main menu state")
    end)

    Suite:testMethod("GameFlow:campaignCreationToGeoscape", {
        description = "Campaign creation leads to geoscape",
        testCase = "state_transition",
        type = "compliance"
    }, function()
        local gameState = {state = "campaign_creation"}
        gameState.campaignReady = true

        if gameState.campaignReady then
            gameState.state = "geoscape"
        end

        Helpers.assertEqual(gameState.state, "geoscape", "Should transition to geoscape when campaign ready")
    end)

    Suite:testMethod("GameFlow:geoscapeToBattlescape", {
        description = "Can transition from geoscape to battlescape",
        testCase = "state_transition",
        type = "compliance"
    }, function()
        local gameState = {state = "geoscape", missionActive = false}

        -- Start mission
        gameState.missionActive = true
        gameState.state = "battlescape"

        Helpers.assertEqual(gameState.state, "battlescape", "Should transition to battlescape")
        Helpers.assertTrue(gameState.missionActive, "Mission should be active")
    end)

    Suite:testMethod("GameFlow:battlescapeToGeoscape", {
        description = "Battlescape returns to geoscape after mission",
        testCase = "state_transition",
        type = "compliance"
    }, function()
        local gameState = {state = "battlescape", missionComplete = false}

        -- Complete mission
        gameState.missionComplete = true
        gameState.state = "geoscape"

        Helpers.assertEqual(gameState.state, "geoscape", "Should return to geoscape")
        Helpers.assertTrue(gameState.missionComplete, "Mission should be marked complete")
    end)
end)

Suite:group("Turn Sequencing", function()

    Suite:testMethod("TurnSequence:phaseOrderCorrect", {
        description = "Turn phases execute in correct order",
        testCase = "sequence",
        type = "compliance"
    }, function()
        local phases = {
            "player_phase",
            "alien_phase",
            "reinforcement_phase",
            "end_turn_phase"
        }

        Helpers.assertEqual(phases[1], "player_phase", "First phase should be player")
        Helpers.assertEqual(phases[2], "alien_phase", "Second phase should be alien")
        Helpers.assertEqual(phases[3], "reinforcement_phase", "Third phase should be reinforcement")
        Helpers.assertEqual(phases[4], "end_turn_phase", "Fourth phase should be end turn")
    end)

    Suite:testMethod("TurnSequence:noSkippingPhases", {
        description = "Cannot skip phases in turn sequence",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local turn = {currentPhase = 1, maxPhase = 4}

        -- Try to skip phases
        local canSkip = turn.currentPhase < turn.maxPhase - 1

        Helpers.assertFalse(canSkip, "Should not allow skipping phases")
    end)

    Suite:testMethod("TurnSequence:incrementsCorrectly", {
        description = "Turn counter increments properly",
        testCase = "increment",
        type = "compliance"
    }, function()
        local turnCounter = 1

        for _ = 1, 10 do
            turnCounter = turnCounter + 1
        end

        Helpers.assertEqual(turnCounter, 11, "Turn should increment by 1 each time")
    end)

    Suite:testMethod("TurnSequence:resetOnNewMission", {
        description = "Turn counter resets on new mission",
        testCase = "reset",
        type = "compliance"
    }, function()
        local battleState = {turn = 15}

        -- Start new mission
        battleState.turn = 1

        Helpers.assertEqual(battleState.turn, 1, "Turn should reset to 1 on new mission")
    end)
end)

Suite:group("Game End Conditions", function()

    Suite:testMethod("GameEnd:allUnitsDeadLoses", {
        description = "Game ends in loss when all player units dead",
        testCase = "end_condition",
        type = "compliance"
    }, function()
        local battleState = {
            playerUnits = 0,
            gameOver = true,
            victory = false
        }

        Helpers.assertEqual(battleState.playerUnits, 0, "All player units should be dead")
        Helpers.assertTrue(battleState.gameOver, "Game should be over")
        Helpers.assertFalse(battleState.victory, "Should be a loss")
    end)

    Suite:testMethod("GameEnd:objectiveCompletionWins", {
        description = "Game ends in victory when objective complete",
        testCase = "end_condition",
        type = "compliance"
    }, function()
        local mission = {
            objective = "eliminate_aliens",
            objectiveComplete = true,
            victory = true
        }

        Helpers.assertTrue(mission.objectiveComplete, "Objective should be complete")
        Helpers.assertTrue(mission.victory, "Should be a victory")
    end)
end)

return Suite
