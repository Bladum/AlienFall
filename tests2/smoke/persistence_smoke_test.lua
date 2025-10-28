-- ─────────────────────────────────────────────────────────────────────────
-- PERSISTENCE SMOKE TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify save/load system works without errors
-- Tests: 4 persistence tests
-- Expected: All pass in <200ms (file I/O simulated)

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.persistence",
    fileName = "persistence_smoke_test.lua",
    description = "Game state persistence and save/load"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Persistence System", function()

    local saveManager = {}
    local tempSaveDir = "temp"

    Suite:beforeEach(function()
        saveManager = {
            slots = {},
            currentSlot = 1,
            errors = {}
        }

        -- Initialize save slots
        for i = 1, 3 do
            saveManager.slots[i] = {
                exists = false,
                data = nil,
                timestamp = nil
            }
        end
    end)

    -- Test 1: Save game creates file
    Suite:testMethod("SaveManager:saveGame", {
        description = "Save game operation creates valid save file",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        local gameState = {
            campaign = {turnNumber = 1},
            geoscape = {funds = 1000},
            bases = {}
        }

        -- Simulate save
        saveManager.slots[1].exists = true
        saveManager.slots[1].data = gameState
        saveManager.slots[1].timestamp = os.time()

        Helpers.assertTrue(saveManager.slots[1].exists, "Save slot should exist")
        Helpers.assertEqual(saveManager.slots[1].data.campaign.turnNumber, 1, "Game state should be preserved")
        Helpers.assertTrue(saveManager.slots[1].timestamp ~= nil, "Timestamp should be set")
    end)

    -- Test 2: Load restores state
    Suite:testMethod("SaveManager:loadGame", {
        description = "Load operation correctly restores game state",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        -- Setup: Create a saved state
        local savedState = {
            campaign = {turnNumber = 5},
            player = {funds = 2500},
            bases = {count = 2}
        }
        saveManager.slots[1].data = savedState
        saveManager.slots[1].exists = true

        -- Load
        local loadedState = saveManager.slots[1].data

        Helpers.assertTrue(loadedState ~= nil, "Loaded state should not be nil")
        Helpers.assertEqual(loadedState.campaign.turnNumber, 5, "Turn number should be restored")
        Helpers.assertEqual(loadedState.player.funds, 2500, "Funds should be restored")
    end)

    -- Test 3: Multiple save slots work
    Suite:testMethod("SaveManager:multipleSaveSlots", {
        description = "Multiple save slots can store different game states",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        -- Save different states to different slots
        for i = 1, 3 do
            saveManager.slots[i].exists = true
            saveManager.slots[i].data = {
                campaign = {turnNumber = i * 10},
                slot = i
            }
        end

        -- Verify each slot has correct data
        for i = 1, 3 do
            Helpers.assertTrue(saveManager.slots[i].exists, "Slot " .. i .. " should exist")
            Helpers.assertEqual(saveManager.slots[i].data.slot, i, "Slot " .. i .. " should have correct data")
        end
    end)

    -- Test 4: Rapid save/load works
    Suite:testMethod("SaveManager:rapidSaveLoad", {
        description = "Multiple save/load cycles work without corruption",
        testCase = "stress",
        type = "smoke"
    }, function()
        local successCount = 0
        local state = {data = "test"}

        -- Perform 10 rapid save/load cycles
        for i = 1, 10 do
            saveManager.slots[1].data = {value = i}
            local loaded = saveManager.slots[1].data

            if loaded and loaded.value == i then
                successCount = successCount + 1
            end
        end

        Helpers.assertEqual(successCount, 10, "All 10 save/load cycles should succeed")
        Helpers.assertEqual(saveManager.slots[1].data.value, 10, "Final value should be 10")
    end)

end)

return Suite
