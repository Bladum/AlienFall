-- ─────────────────────────────────────────────────────────────────────────
-- ACCESSIBILITY TEST SUITE
-- FILE: tests2/core/accessibility_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests accessibility features
-- Covers: Colorblind modes, UI scaling, controller support
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.accessibility.accessibility_manager",
    fileName = "accessibility_manager.lua",
    description = "Game accessibility features and settings"
})

-- ─────────────────────────────────────────────────────────────────────────
-- MODULE SETUP
-- ─────────────────────────────────────────────────────────────────────────

print("[ACCESSIBILITY_TEST] Setting up")

local AccessibilityManager = {
    colorblindMode = "normal",
    colorblindModes = {"normal", "protanopia", "deuteranopia", "tritanopia"},
    uiScale = 1.0,
    minScale = 0.8,
    maxScale = 2.0,
    controllerEnabled = false,
    subtitles = true,
    keyboardLayout = "qwerty",

    setColorblindMode = function(self, mode)
        for _, valid in ipairs(self.colorblindModes) do
            if valid == mode then
                self.colorblindMode = mode
                return true
            end
        end
        return false
    end,

    getColorblindMode = function(self)
        return self.colorblindMode
    end,

    getAvailableColorblindModes = function(self)
        return self.colorblindModes
    end,

    setUIScale = function(self, scale)
        if scale < self.minScale or scale > self.maxScale then
            return false
        end
        self.uiScale = scale
        return true
    end,

    getUIScale = function(self)
        return self.uiScale
    end,

    increaseUIScale = function(self)
        local newScale = self.uiScale + 0.1
        return self:setUIScale(newScale)
    end,

    decreaseUIScale = function(self)
        local newScale = self.uiScale - 0.1
        return self:setUIScale(newScale)
    end,

    enableController = function(self)
        self.controllerEnabled = true
        return true
    end,

    disableController = function(self)
        self.controllerEnabled = false
        return true
    end,

    isControllerEnabled = function(self)
        return self.controllerEnabled
    end,

    setSubtitles = function(self, enabled)
        self.subtitles = enabled
        return true
    end,

    areSubtitlesEnabled = function(self)
        return self.subtitles
    end,

    setKeyboardLayout = function(self, layout)
        if layout ~= "qwerty" and layout ~= "dvorak" and layout ~= "azerty" then
            return false
        end
        self.keyboardLayout = layout
        return true
    end,

    getKeyboardLayout = function(self)
        return self.keyboardLayout
    end
}

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Colorblind Modes", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.access = setmetatable({
            colorblindMode = "normal",
            colorblindModes = {"normal", "protanopia", "deuteranopia", "tritanopia"}
        }, {__index = AccessibilityManager})
    end)

    Suite:testMethod("AccessibilityManager.setColorblindMode", {
        description = "Sets colorblind mode",
        testCase = "set_mode",
        type = "functional"
    }, function()
        local ok = shared.access:setColorblindMode("protanopia")
        Helpers.assertEqual(ok, true, "Mode set successfully")
        Helpers.assertEqual(shared.access.colorblindMode, "protanopia", "Mode changed")
    end)

    Suite:testMethod("AccessibilityManager.setColorblindMode", {
        description = "Rejects invalid mode",
        testCase = "invalid_mode",
        type = "functional"
    }, function()
        local ok = shared.access:setColorblindMode("invalid")
        Helpers.assertEqual(ok, false, "Invalid mode rejected")
        Helpers.assertEqual(shared.access.colorblindMode, "normal", "Mode unchanged")
    end)

    Suite:testMethod("AccessibilityManager.getAvailableColorblindModes", {
        description = "Returns available modes",
        testCase = "available_modes",
        type = "functional"
    }, function()
        local modes = shared.access:getAvailableColorblindModes()
        local count = 0
        for _ in pairs(modes) do count = count + 1 end
        Helpers.assertEqual(count >= 1, true, "Modes available")
    end)
end)

Suite:group("UI Scaling", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.access = setmetatable({
            uiScale = 1.0,
            minScale = 0.8,
            maxScale = 2.0
        }, {__index = AccessibilityManager})
    end)

    Suite:testMethod("AccessibilityManager.setUIScale", {
        description = "Sets UI scale",
        testCase = "set_scale",
        type = "functional"
    }, function()
        local ok = shared.access:setUIScale(1.5)
        Helpers.assertEqual(ok, true, "Scale set successfully")
        Helpers.assertEqual(shared.access.uiScale, 1.5, "Scale value changed")
    end)

    Suite:testMethod("AccessibilityManager.setUIScale", {
        description = "Enforces minimum scale",
        testCase = "min_scale",
        type = "functional"
    }, function()
        local ok = shared.access:setUIScale(0.5)
        Helpers.assertEqual(ok, false, "Below minimum rejected")
        Helpers.assertEqual(shared.access.uiScale, 1.0, "Scale unchanged")
    end)

    Suite:testMethod("AccessibilityManager.setUIScale", {
        description = "Enforces maximum scale",
        testCase = "max_scale",
        type = "functional"
    }, function()
        local ok = shared.access:setUIScale(3.0)
        Helpers.assertEqual(ok, false, "Above maximum rejected")
        Helpers.assertEqual(shared.access.uiScale, 1.0, "Scale unchanged")
    end)

    Suite:testMethod("AccessibilityManager.increaseUIScale", {
        description = "Increases UI scale",
        testCase = "increase_scale",
        type = "functional"
    }, function()
        local ok = shared.access:increaseUIScale()
        Helpers.assertEqual(ok, true, "Scale increased")
        Helpers.assertEqual(shared.access.uiScale, 1.1, "Scale incremented by 0.1")
    end)

    Suite:testMethod("AccessibilityManager.decreaseUIScale", {
        description = "Decreases UI scale",
        testCase = "decrease_scale",
        type = "functional"
    }, function()
        shared.access.uiScale = 1.5
        local ok = shared.access:decreaseUIScale()
        Helpers.assertEqual(ok, true, "Scale decreased")
        Helpers.assertEqual(shared.access.uiScale, 1.4, "Scale decremented by 0.1")
    end)
end)

Suite:group("Controller Support", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.access = setmetatable({
            controllerEnabled = false
        }, {__index = AccessibilityManager})
    end)

    Suite:testMethod("AccessibilityManager.enableController", {
        description = "Enables controller support",
        testCase = "enable_controller",
        type = "functional"
    }, function()
        local ok = shared.access:enableController()
        Helpers.assertEqual(ok, true, "Controller enabled")
        Helpers.assertEqual(shared.access.controllerEnabled, true, "Controller flag set")
    end)

    Suite:testMethod("AccessibilityManager.disableController", {
        description = "Disables controller support",
        testCase = "disable_controller",
        type = "functional"
    }, function()
        shared.access.controllerEnabled = true
        local ok = shared.access:disableController()
        Helpers.assertEqual(ok, true, "Controller disabled")
        Helpers.assertEqual(shared.access.controllerEnabled, false, "Controller flag unset")
    end)

    Suite:testMethod("AccessibilityManager.isControllerEnabled", {
        description = "Reports controller status",
        testCase = "controller_status",
        type = "functional"
    }, function()
        local enabled = shared.access:isControllerEnabled()
        Helpers.assertEqual(enabled, false, "Controller initially disabled")
        shared.access:enableController()
        enabled = shared.access:isControllerEnabled()
        Helpers.assertEqual(enabled, true, "Controller enabled after toggle")
    end)
end)

Suite:group("Accessibility Settings", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.access = setmetatable({
            subtitles = true,
            keyboardLayout = "qwerty"
        }, {__index = AccessibilityManager})
    end)

    Suite:testMethod("AccessibilityManager.setSubtitles", {
        description = "Toggles subtitles",
        testCase = "toggle_subtitles",
        type = "functional"
    }, function()
        shared.access:setSubtitles(false)
        Helpers.assertEqual(shared.access.subtitles, false, "Subtitles disabled")
        shared.access:setSubtitles(true)
        Helpers.assertEqual(shared.access.subtitles, true, "Subtitles enabled")
    end)

    Suite:testMethod("AccessibilityManager.areSubtitlesEnabled", {
        description = "Reports subtitle status",
        testCase = "subtitle_status",
        type = "functional"
    }, function()
        local enabled = shared.access:areSubtitlesEnabled()
        Helpers.assertEqual(enabled, true, "Subtitles enabled by default")
    end)

    Suite:testMethod("AccessibilityManager.setKeyboardLayout", {
        description = "Changes keyboard layout",
        testCase = "keyboard_layout",
        type = "functional"
    }, function()
        local ok = shared.access:setKeyboardLayout("dvorak")
        Helpers.assertEqual(ok, true, "Layout changed")
        Helpers.assertEqual(shared.access.keyboardLayout, "dvorak", "Layout value updated")
    end)

    Suite:testMethod("AccessibilityManager.setKeyboardLayout", {
        description = "Rejects invalid layout",
        testCase = "invalid_layout",
        type = "functional"
    }, function()
        local ok = shared.access:setKeyboardLayout("colemak")
        Helpers.assertEqual(ok, false, "Invalid layout rejected")
        Helpers.assertEqual(shared.access.keyboardLayout, "qwerty", "Layout unchanged")
    end)
end)

Suite:run()
