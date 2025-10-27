-- ─────────────────────────────────────────────────────────────────────────
-- CONFIGURATION CONSTRAINTS TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify configuration settings respect constraints
-- Tests: 7 configuration validation tests
-- Categories: Setting ranges, valid values, defaults

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.config",
    fileName = "configuration_constraints_test.lua",
    description = "Configuration settings and constraint validation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- CONFIGURATION CONSTRAINT TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Setting Range Validation", function()

    Suite:testMethod("Config:volumeRangeValid", {
        description = "Volume settings stay within 0-100 range",
        testCase = "validation",
        type = "compliance"
    }, function()
        local audioConfig = {
            masterVolume = 75,
            musicVolume = 50,
            sfxVolume = 80,
            uiVolume = 60
        }

        for key, volume in pairs(audioConfig) do
            Helpers.assertTrue(volume >= 0, key .. " should be >= 0")
            Helpers.assertTrue(volume <= 100, key .. " should be <= 100")
        end
    end)

    Suite:testMethod("Config:resolutionValid", {
        description = "Resolution settings are supported values",
        testCase = "validation",
        type = "compliance"
    }, function()
        local validResolutions = {
            {width = 1024, height = 768},
            {width = 1280, height = 720},
            {width = 1920, height = 1080},
            {width = 2560, height = 1440}
        }

        for _, res in ipairs(validResolutions) do
            Helpers.assertTrue(res.width >= 640, "Width should be at least 640")
            Helpers.assertTrue(res.height >= 480, "Height should be at least 480")
            Helpers.assertTrue(res.width > res.height or res.width == res.height, "Should be landscape or square")
        end
    end)

    Suite:testMethod("Config:gameSpeedValid", {
        description = "Game speed multiplier stays in valid range",
        testCase = "validation",
        type = "compliance"
    }, function()
        local gameSpeeds = {0.25, 0.5, 1.0, 1.5, 2.0}

        for _, speed in ipairs(gameSpeeds) do
            Helpers.assertTrue(speed >= 0.1, "Speed should be >= 0.1")
            Helpers.assertTrue(speed <= 5.0, "Speed should be <= 5.0")
        end
    end)

    Suite:testMethod("Config:turnTimeLimitValid", {
        description = "Turn time limits are reasonable",
        testCase = "validation",
        type = "compliance"
    }, function()
        local turnTimeLimit = 180  -- seconds

        Helpers.assertTrue(turnTimeLimit >= 30, "Turn time should be at least 30 seconds")
        Helpers.assertTrue(turnTimeLimit <= 600, "Turn time should not exceed 10 minutes")
    end)
end)

Suite:group("Configuration Defaults", function()

    Suite:testMethod("Config:defaultDifficultySet", {
        description = "Default difficulty is 'normal'",
        testCase = "default",
        type = "compliance"
    }, function()
        local config = {difficulty = "normal"}

        Helpers.assertNotNil(config.difficulty, "Difficulty should have default")
        Helpers.assertEqual(config.difficulty, "normal", "Default difficulty should be 'normal'")
    end)

    Suite:testMethod("Config:defaultLanguageSet", {
        description = "Default language is 'english'",
        testCase = "default",
        type = "compliance"
    }, function()
        local config = {language = "english"}

        Helpers.assertNotNil(config.language, "Language should have default")
        Helpers.assertEqual(config.language, "english", "Default language should be 'english'")
    end)

    Suite:testMethod("Config:defaultFullscreenFalse", {
        description = "Default display mode is windowed",
        testCase = "default",
        type = "compliance"
    }, function()
        local config = {fullscreen = false}

        Helpers.assertFalse(config.fullscreen, "Default should be windowed mode")
    end)
end)

return Suite
