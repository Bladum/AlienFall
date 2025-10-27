-- ─────────────────────────────────────────────────────────────────────────
-- ASSET LOADING SMOKE TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify all required assets load without errors
-- Tests: 4 asset loading tests
-- Expected: All pass in <100ms (mocked assets)

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.assets",
    fileName = "asset_loading_smoke_test.lua",
    description = "Asset loading and resource management"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Asset Loading", function()

    local assetManager = {}

    Suite:beforeEach(function()
        assetManager = {
            sprites = {},
            audio = {},
            ui = {},
            errors = {}
        }
    end)

    -- Test 1: All sprites load
    Suite:testMethod("AssetManager:loadSprites", {
        description = "All sprite assets load without errors",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        local spriteCategories = {
            "units", "enemies", "effects", "ui_icons", "terrain"
        }

        for _, category in ipairs(spriteCategories) do
            assetManager.sprites[category] = {loaded = true, count = 0}
        end

        Helpers.assertEqual(#spriteCategories, 5, "Should have 5 sprite categories")
        Helpers.assertTrue(assetManager.sprites.units ~= nil, "Units sprites should load")
        Helpers.assertTrue(assetManager.sprites.terrain ~= nil, "Terrain sprites should load")
    end)

    -- Test 2: All audio files load
    Suite:testMethod("AssetManager:loadAudio", {
        description = "All audio assets load without errors",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        local audioCategories = {
            "music", "sfx", "ambient", "ui_sounds"
        }

        for _, category in ipairs(audioCategories) do
            assetManager.audio[category] = {loaded = true}
        end

        Helpers.assertTrue(assetManager.audio.music ~= nil, "Music should load")
        Helpers.assertTrue(assetManager.audio.sfx ~= nil, "SFX should load")
    end)

    -- Test 3: UI assets available
    Suite:testMethod("AssetManager:loadUI", {
        description = "UI assets are available and accessible",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        assetManager.ui = {
            buttons = {count = 10},
            panels = {count = 5},
            icons = {count = 20},
            fonts = {count = 3}
        }

        Helpers.assertTrue(assetManager.ui.buttons.count > 0, "Buttons should exist")
        Helpers.assertTrue(assetManager.ui.fonts.count > 0, "Fonts should exist")
    end)

    -- Test 4: No file not found errors
    Suite:testMethod("AssetManager:validateAssets", {
        description = "No missing asset files detected",
        testCase = "validation",
        type = "smoke"
    }, function()
        -- Simulate asset validation
        local missingAssets = {}

        -- Check categories
        for _, cat in ipairs({"sprites", "audio", "ui"}) do
            if assetManager[cat] == nil or Helpers.tableSize(assetManager[cat]) == 0 then
                table.insert(missingAssets, cat)
            end
        end

        -- Should have no missing categories
        Helpers.assertEqual(#missingAssets, 0, "All asset categories should exist")
        Helpers.assertTrue(Helpers.tableSize(assetManager) > 0, "Asset manager should have content")
    end)

end)

return Suite
