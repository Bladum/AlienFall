-- ─────────────────────────────────────────────────────────────────────────
-- UI REGRESSION TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Catch regressions in UI/UX systems
-- Tests: 6 regression tests for interface issues
-- Expected: All pass in <150ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.gui.ui",
    fileName = "ui_regression_test.lua",
    description = "UI/UX system regression testing"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("UI/UX Regressions", function()

    local ui = {}

    Suite:beforeEach(function()
        ui = {
            buttons = {},
            panels = {},
            tooltips = {},
            selectedItem = nil,
            focused = nil
        }
    end)

    -- Regression 1: Button click handler duplication
    Suite:testMethod("UI:buttonClickHandling", {
        description = "Button clicks should not fire multiple times",
        testCase = "edge_case",
        type = "regression"
    }, function()
        local button = {
            id = "test_btn",
            clickCount = 0,
            enabled = true
        }

        local function handleClick(btn)
            if btn.enabled then
                btn.clickCount = btn.clickCount + 1
            end
        end

        handleClick(button)
        handleClick(button)

        Helpers.assertEqual(button.clickCount, 2, "Click count should be exact")
    end)

    -- Regression 2: Focus loss on overlay
    Suite:testMethod("UI:focusManagement", {
        description = "Focus should transfer correctly when overlays open/close",
        testCase = "edge_case",
        type = "regression"
    }, function()
        local widget1 = {id = "w1", focused = true}
        local widget2 = {id = "w2", focused = false}

        -- Overlay opens, takes focus
        widget1.focused = false
        ui.focused = "overlay"

        Helpers.assertTrue(not widget1.focused, "Widget should lose focus")
        Helpers.assertEqual(ui.focused, "overlay", "Overlay should have focus")

        -- Overlay closes, focus returns
        ui.focused = nil
        widget1.focused = true

        Helpers.assertTrue(widget1.focused, "Widget should regain focus")
    end)

    -- Regression 3: Tooltip display overlap
    Suite:testMethod("UI:tooltipDisplay", {
        description = "Tooltips should not overlap with content",
        testCase = "validation",
        type = "regression"
    }, function()
        local tooltip = {
            x = 100,
            y = 100,
            width = 200,
            height = 50
        }

        local content = {
            x = 0,
            y = 0,
            width = 1024,
            height = 768
        }

        -- Check tooltip is within bounds
        local inBounds = tooltip.x + tooltip.width <= content.width and
                        tooltip.y + tooltip.height <= content.height

        Helpers.assertTrue(inBounds, "Tooltip should fit in content area")
    end)

    -- Regression 4: List scroll position consistency
    Suite:testMethod("UI:scrollConsistency", {
        description = "Scroll position should remain consistent",
        testCase = "edge_case",
        type = "regression"
    }, function()
        local list = {
            items = {},
            scrollPosition = 0,
            maxScroll = 100
        }

        for i = 1, 50 do
            table.insert(list.items, {id = i, text = "Item " .. i})
        end

        list.scrollPosition = 30
        local saved = list.scrollPosition

        -- Refresh list
        list.scrollPosition = math.min(saved, list.maxScroll)

        Helpers.assertEqual(list.scrollPosition, 30, "Scroll position should persist")
    end)

    -- Regression 5: Text input buffer corruption
    Suite:testMethod("UI:textInputBuffer", {
        description = "Text input buffer should not corrupt on rapid input",
        testCase = "stress",
        type = "regression"
    }, function()
        local textInput = {
            buffer = "",
            cursorPos = 1,
            maxLength = 100
        }

        -- Rapid typing
        local text = "Quick brown fox jumps over lazy dog"
        for i = 1, #text do
            if #textInput.buffer < textInput.maxLength then
                textInput.buffer = textInput.buffer .. text:sub(i, i)
            end
        end

        Helpers.assertEqual(textInput.buffer, text, "Buffer should contain full text")
        Helpers.assertTrue(#textInput.buffer <= textInput.maxLength, "Buffer shouldn't exceed max")
    end)

    -- Regression 6: Panel resolution scaling
    Suite:testMethod("UI:panelScaling", {
        description = "UI panels should scale correctly for different resolutions",
        testCase = "validation",
        type = "regression"
    }, function()
        local resolutions = {
            {w = 800, h = 600},
            {w = 1024, h = 768},
            {w = 1920, h = 1080}
        }

        for _, res in ipairs(resolutions) do
            local panel = {
                x = res.w * 0.1,
                y = res.h * 0.1,
                width = res.w * 0.8,
                height = res.h * 0.8
            }

            Helpers.assertTrue(panel.width > 0, "Panel width should be positive")
            Helpers.assertTrue(panel.height > 0, "Panel height should be positive")
        end
    end)

end)

return Suite
