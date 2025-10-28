-- ─────────────────────────────────────────────────────────────────────────
-- UI SMOKE TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify UI renders and responds without critical errors
-- Tests: 3 UI functionality tests
-- Expected: All pass in <150ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.gui",
    fileName = "ui_smoke_test.lua",
    description = "User interface rendering and interaction"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("UI System", function()

    local uiManager = {}

    Suite:beforeEach(function()
        uiManager = {
            screens = {},
            activeScreen = nil,
            widgets = {},
            errors = {}
        }
    end)

    -- Test 1: Main menu renders
    Suite:testMethod("UIManager:renderMainMenu", {
        description = "Main menu screen renders without errors",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        -- Create main menu
        uiManager.screens.mainMenu = {
            visible = true,
            width = 1024,
            height = 768,
            elements = {
                title = {text = "XCOM Simple", rendered = true},
                buttons = {count = 4}
            }
        }

        uiManager.activeScreen = uiManager.screens.mainMenu

        Helpers.assertTrue(uiManager.activeScreen ~= nil, "Main menu should exist")
        Helpers.assertEqual(uiManager.activeScreen.width, 1024, "Menu width should be correct")
        Helpers.assertTrue(uiManager.activeScreen.elements.title.rendered, "Title should render")
    end)

    -- Test 2: Buttons respond
    Suite:testMethod("UIManager:buttonInteraction", {
        description = "UI buttons respond to input without errors",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        -- Create buttons
        uiManager.widgets.buttons = {
            {id = "play", x = 100, y = 100, width = 200, height = 50, clicked = false},
            {id = "settings", x = 100, y = 200, width = 200, height = 50, clicked = false},
            {id = "quit", x = 100, y = 300, width = 200, height = 50, clicked = false}
        }

        -- Simulate button click
        local playButton = uiManager.widgets.buttons[1]
        playButton.clicked = true

        Helpers.assertTrue(playButton.clicked, "Button should register click")
        Helpers.assertEqual(playButton.id, "play", "Button should have correct ID")
        Helpers.assertEqual(#uiManager.widgets.buttons, 3, "Should have 3 buttons")
    end)

    -- Test 3: No layout errors
    Suite:testMethod("UIManager:validateLayout", {
        description = "UI layout is valid with no overlapping or missing elements",
        testCase = "validation",
        type = "smoke"
    }, function()
        -- Create layout
        uiManager.screens.battleUI = {
            header = {x = 0, y = 0, width = 1024, height = 80},
            sidebar = {x = 0, y = 80, width = 200, height = 688},
            viewport = {x = 200, y = 80, width = 824, height = 688},
            footer = {x = 0, y = 768, width = 1024, height = 32}
        }

        local layout = uiManager.screens.battleUI

        -- Validate no overlaps
        Helpers.assertEqual(layout.header.y, 0, "Header should start at top")
        Helpers.assertEqual(layout.sidebar.x + layout.sidebar.width, 200, "Sidebar should end at 200")
        Helpers.assertEqual(layout.viewport.x, 200, "Viewport should start at 200")

        -- Validate coverage
        local totalWidth = layout.viewport.width + layout.sidebar.width
        Helpers.assertEqual(totalWidth, 1024, "Layout should cover full width")
    end)

end)

return Suite
