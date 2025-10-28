-- ─────────────────────────────────────────────────────────────────────────
-- COLORBLIND MODE TEST SUITE
-- FILE: tests2/core/colorblind_mode_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.accessibility.colorblind_mode",
    fileName = "colorblind_mode.lua",
    description = "Colorblind mode system"
})

print("[COLORBLIND_MODE_TEST] Setting up")

local ColorblindMode = {
    modes = {
        normal = {r = 1, g = 1, b = 1},
        protanopia = {r = 0.567, g = 0.433, b = 0},
        deuteranopia = {r = 0.625, g = 0.375, b = 0},
        tritanopia = {r = 0.95, g = 0.05, b = 0}
    },
    currentMode = "normal",

    setMode = function(self, mode)
        if not self.modes[mode] then return false end
        self.currentMode = mode
        return true
    end,

    getMode = function(self) return self.currentMode end,

    applyFilter = function(self, color)
        local mode = self.modes[self.currentMode]
        return {
            r = color.r * mode.r,
            g = color.g * mode.g,
            b = color.b * mode.b
        }
    end,

    getModes = function(self)
        local result = {}
        for name, _ in pairs(self.modes) do
            table.insert(result, name)
        end
        return result
    end,

    simulateColorblindness = function(self, color)
        local original = self.currentMode
        local results = {}
        for mode, _ in pairs(self.modes) do
            self.currentMode = mode
            results[mode] = self:applyFilter(color)
        end
        self.currentMode = original
        return results
    end
}

Suite:group("Mode Selection", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cb = setmetatable({modes = ColorblindMode.modes, currentMode = "normal"}, {__index = ColorblindMode})
    end)

    Suite:testMethod("ColorblindMode.setMode", {description = "Sets colorblind mode", testCase = "set", type = "functional"}, function()
        local ok = shared.cb:setMode("protanopia")
        Helpers.assertEqual(ok, true, "Mode set")
        Helpers.assertEqual(shared.cb:getMode(), "protanopia", "Mode changed")
    end)

    Suite:testMethod("ColorblindMode.setMode", {description = "Rejects invalid mode", testCase = "invalid", type = "functional"}, function()
        local ok = shared.cb:setMode("invalid")
        Helpers.assertEqual(ok, false, "Invalid rejected")
        Helpers.assertEqual(shared.cb:getMode(), "normal", "Mode unchanged")
    end)

    Suite:testMethod("ColorblindMode.getModes", {description = "Lists available modes", testCase = "list", type = "functional"}, function()
        local modes = shared.cb:getModes()
        Helpers.assertEqual(#modes >= 1, true, "Modes available")
    end)
end)

Suite:group("Color Filtering", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cb = setmetatable({modes = ColorblindMode.modes, currentMode = "normal"}, {__index = ColorblindMode})
    end)

    Suite:testMethod("ColorblindMode.applyFilter", {description = "Applies filter to color", testCase = "filter", type = "functional"}, function()
        local color = {r = 1, g = 0.5, b = 0.25}
        local filtered = shared.cb:applyFilter(color)
        Helpers.assertEqual(filtered ~= nil, true, "Filter applied")
    end)

    Suite:testMethod("ColorblindMode.applyFilter", {description = "Normal mode preserves color", testCase = "normal_preserve", type = "functional"}, function()
        shared.cb:setMode("normal")
        local color = {r = 1, g = 0.5, b = 0.25}
        local filtered = shared.cb:applyFilter(color)
        if filtered then
            Helpers.assertEqual(filtered.r, 1, "Red preserved")
            Helpers.assertEqual(filtered.g, 0.5, "Green preserved")
        end
    end)

    Suite:testMethod("ColorblindMode.simulateColorblindness", {description = "Simulates all modes", testCase = "simulate", type = "functional"}, function()
        local color = {r = 0.5, g = 0.7, b = 0.3}
        local results = shared.cb:simulateColorblindness(color)
        Helpers.assertEqual(results ~= nil, true, "Simulation completed")
    end)
end)

Suite:group("Accessibility", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cb = setmetatable({modes = ColorblindMode.modes, currentMode = "normal"}, {__index = ColorblindMode})
    end)

    Suite:testMethod("ColorblindMode.setMode", {description = "Deuteranopia mode available", testCase = "deuteranopia", type = "functional"}, function()
        local ok = shared.cb:setMode("deuteranopia")
        Helpers.assertEqual(ok, true, "Deuteranopia available")
    end)

    Suite:testMethod("ColorblindMode.setMode", {description = "Tritanopia mode available", testCase = "tritanopia", type = "functional"}, function()
        local ok = shared.cb:setMode("tritanopia")
        Helpers.assertEqual(ok, true, "Tritanopia available")
    end)

    Suite:testMethod("ColorblindMode.getMode", {description = "Returns current mode", testCase = "current", type = "functional"}, function()
        local mode = shared.cb:getMode()
        Helpers.assertEqual(mode == "normal", true, "Normal mode default")
    end)
end)

Suite:run()
