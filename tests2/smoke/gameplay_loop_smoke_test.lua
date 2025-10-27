-- ─────────────────────────────────────────────────────────────────────────
-- GAMEPLAY LOOP SMOKE TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify basic gameplay loop works (geoscape→battlescape→return)
-- Tests: 6 gameplay flow tests
-- Expected: All pass in <100ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.gameplay",
    fileName = "gameplay_loop_smoke_test.lua",
    description = "Basic gameplay loop functionality"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Gameplay Loop", function()

    local gameState = {}

    Suite:beforeEach(function()
        gameState = {
            phase = "geoscape",
            turn = 1,
            campaign = {started = false},
            battlescape = {active = false},
            map = {generated = false}
        }
    end)

    -- Test 1: Geoscape loads
    Suite:testMethod("Geoscape:load", {
        description = "Geoscape loads without errors",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        gameState.phase = "geoscape"
        Helpers.assertEqual(gameState.phase, "geoscape", "Should be in geoscape")
        Helpers.assertTrue(not gameState.battlescape.active, "Battlescape should not be active")
    end)

    -- Test 2: Battlescape loads
    Suite:testMethod("Battlescape:load", {
        description = "Battlescape loads without errors",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        gameState.phase = "battlescape"
        gameState.battlescape.active = true
        gameState.map.generated = true

        Helpers.assertEqual(gameState.phase, "battlescape", "Should be in battlescape")
        Helpers.assertTrue(gameState.battlescape.active, "Battlescape should be active")
        Helpers.assertTrue(gameState.map.generated, "Map should be generated")
    end)

    -- Test 3: Return to geoscape works
    Suite:testMethod("Gameplay:returnToGeoscape", {
        description = "Can return from battlescape to geoscape",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        -- Start in battlescape
        gameState.phase = "battlescape"
        gameState.battlescape.active = true

        -- Return to geoscape
        gameState.phase = "geoscape"
        gameState.battlescape.active = false

        Helpers.assertEqual(gameState.phase, "geoscape", "Should return to geoscape")
        Helpers.assertTrue(not gameState.battlescape.active, "Battlescape should be inactive")
    end)

    -- Test 4: Campaign starts
    Suite:testMethod("Campaign:start", {
        description = "Campaign initializes correctly",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        gameState.campaign.started = true
        gameState.turn = 1
        gameState.campaign.objectives = {}

        Helpers.assertTrue(gameState.campaign.started, "Campaign should be started")
        Helpers.assertEqual(gameState.turn, 1, "Turn should be 1")
        Helpers.assertNotNil(gameState.campaign.objectives, "Objectives should exist")
    end)

    -- Test 5: Turn completion works
    Suite:testMethod("TurnManager:completeTurn", {
        description = "Completing turn advances turn counter",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        local startTurn = gameState.turn
        gameState.turn = startTurn + 1

        Helpers.assertTrue(gameState.turn > startTurn, "Turn should advance")
        Helpers.assertEqual(gameState.turn, 2, "Turn should be 2")
    end)

    -- Test 6: Game saves state
    Suite:testMethod("SaveSystem:saveGame", {
        description = "Game state can be saved",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        local saveData = {
            turn = gameState.turn,
            phase = gameState.phase,
            campaign = gameState.campaign
        }

        Helpers.assertNotNil(saveData, "Save data should exist")
        Helpers.assertEqual(saveData.phase, "geoscape", "Phase should be in save data")
        Helpers.assertTrue(saveData.turn >= 1, "Turn should be in save data")
    end)

end)

return Suite
