--[[
    Comprehensive Widget Test Suite
    
    Tests all 33 widgets (23 base + 10 strategy)
    Run from: engine/widgets/tests/
    
    Usage: require("widgets.tests.test_all_widgets").runAll()
]]

local TestFramework = require("widgets.tests.widget_test_framework")
local Widgets = require("widgets")

local AllWidgetTests = {}

--[[
    Test all base widgets (23 total)
]]
function AllWidgetTests.testBaseWidgets()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING BASE WIDGETS (23)                        ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    -- Test Button
    local button = Widgets.Button.new(24, 24, 96, 48, "Test Button")
    TestFramework.testWidget(button, "Button")
    
    -- Test Label
    local label = Widgets.Label.new(24, 24, 96, 24, "Test Label")
    TestFramework.testWidget(label, "Label")
    
    -- Test Panel
    local panel = Widgets.Panel.new(24, 24, 240, 240)
    TestFramework.testWidget(panel, "Panel")
    
    -- Test Container
    local container = Widgets.Container.new(24, 24, 240, 240)
    TestFramework.testWidget(container, "Container")
    
    -- Test TextInput
    local textInput = Widgets.TextInput.new(24, 24, 144, 24)
    TestFramework.testWidget(textInput, "TextInput")
    
    -- Test Checkbox
    local checkbox = Widgets.Checkbox.new(24, 24, 120, 24, "Test Checkbox")
    TestFramework.testWidget(checkbox, "Checkbox")
    
    -- Test Dropdown
    local dropdown = Widgets.Dropdown.new(24, 24, 144, 24)
    TestFramework.testWidget(dropdown, "Dropdown")
    
    -- Test ListBox
    local listbox = Widgets.ListBox.new(24, 24, 192, 240)
    TestFramework.testWidget(listbox, "ListBox")
    
    -- Test ProgressBar
    local progressBar = Widgets.ProgressBar.new(24, 24, 192, 24)
    TestFramework.testWidget(progressBar, "ProgressBar")
    
    -- Test HealthBar
    local healthBar = Widgets.HealthBar.new(24, 24, 192, 24)
    TestFramework.testWidget(healthBar, "HealthBar")
    
    -- Test ScrollBox
    local scrollbox = Widgets.ScrollBox.new(24, 24, 240, 240)
    TestFramework.testWidget(scrollbox, "ScrollBox")
    
    -- Test Tooltip
    local tooltip = Widgets.Tooltip.new(24, 24, 144, 48, "Test Tooltip")
    TestFramework.testWidget(tooltip, "Tooltip")
    
    -- Test FrameBox
    local framebox = Widgets.FrameBox.new(24, 24, 240, 240, "Test Frame")
    TestFramework.testWidget(framebox, "FrameBox")
    
    -- Test TabWidget
    local tabwidget = Widgets.TabWidget.new(24, 24, 288, 240)
    TestFramework.testWidget(tabwidget, "TabWidget")
    
    -- Test Dialog
    local dialog = Widgets.Dialog.new(240, 168, 288, 192, "Test Dialog")
    TestFramework.testWidget(dialog, "Dialog")
    
    -- Test Window
    local window = Widgets.Window.new(240, 168, 288, 192, "Test Window")
    TestFramework.testWidget(window, "Window")
    
    -- Test ImageButton
    local imageButton = Widgets.ImageButton.new(24, 24, 48, 48)
    TestFramework.testWidget(imageButton, "ImageButton")
    
    -- Test ComboBox
    local combobox = Widgets.ComboBox.new(24, 24, 144, 24)
    TestFramework.testWidget(combobox, "ComboBox")
    
    -- Test RadioButton
    local radioButton = Widgets.RadioButton.new(24, 24, 120, 24, "Test Radio", "group1")
    TestFramework.testWidget(radioButton, "RadioButton")
    
    -- Test Spinner
    local spinner = Widgets.Spinner.new(24, 24, 96, 24)
    TestFramework.testWidget(spinner, "Spinner")
    
    -- Test Autocomplete
    local autocomplete = Widgets.Autocomplete.new(24, 24, 144, 24)
    TestFramework.testWidget(autocomplete, "Autocomplete")
    
    -- Test Table
    local table = Widgets.Table.new(24, 24, 288, 240)
    TestFramework.testWidget(table, "Table")
    
    -- Test TextArea
    local textarea = Widgets.TextArea.new(24, 24, 288, 192)
    TestFramework.testWidget(textarea, "TextArea")
end

--[[
    Test all strategy widgets (10 total)
]]
function AllWidgetTests.testStrategyWidgets()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING STRATEGY WIDGETS (10)                    ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    -- Test UnitCard
    local unitCard = Widgets.UnitCard.new(24, 24, 192, 240)
    TestFramework.testWidget(unitCard, "UnitCard")
    
    -- Test ActionBar
    local actionBar = Widgets.ActionBar.new(24, 24, 480, 72)
    TestFramework.testWidget(actionBar, "ActionBar")
    
    -- Test ResourceDisplay
    local resourceDisplay = Widgets.ResourceDisplay.new(24, 24, 288, 48)
    TestFramework.testWidget(resourceDisplay, "ResourceDisplay")
    
    -- Test MiniMap
    local miniMap = Widgets.MiniMap.new(24, 24, 192, 192)
    TestFramework.testWidget(miniMap, "MiniMap")
    
    -- Test TurnIndicator
    local turnIndicator = Widgets.TurnIndicator.new(24, 24, 192, 96)
    TestFramework.testWidget(turnIndicator, "TurnIndicator")
    
    -- Test InventorySlot
    local inventorySlot = Widgets.InventorySlot.new(24, 24, 72, 72)
    TestFramework.testWidget(inventorySlot, "InventorySlot")
    
    -- Test ResearchTree
    local researchTree = Widgets.ResearchTree.new(24, 24, 480, 360)
    TestFramework.testWidget(researchTree, "ResearchTree")
    
    -- Test NotificationBanner
    local notificationBanner = Widgets.NotificationBanner.new(240, 24, 480, 72)
    TestFramework.testWidget(notificationBanner, "NotificationBanner")
    
    -- Test ContextMenu
    local contextMenu = Widgets.ContextMenu.new(120, 120, 144, 120)
    TestFramework.testWidget(contextMenu, "ContextMenu")
    
    -- Test RangeIndicator
    local rangeIndicator = Widgets.RangeIndicator.new(24, 24, 480, 360)
    TestFramework.testWidget(rangeIndicator, "RangeIndicator")
end

--[[
    Test Grid System
]]
function AllWidgetTests.testGridSystem()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING GRID SYSTEM                              ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local Grid = Widgets.Grid
    
    TestFramework.runTest("Grid - snapToGrid", function()
        local x, y = Grid.snapToGrid(10, 15)
        TestFramework.assertEqual(x, 0, "snapToGrid X failed")
        TestFramework.assertEqual(y, 24, "snapToGrid Y failed")
    end)
    
    TestFramework.runTest("Grid - snapSize", function()
        local w, h = Grid.snapSize(50, 60)
        TestFramework.assertEqual(w, 48, "snapSize width failed")
        TestFramework.assertEqual(h, 72, "snapSize height failed")
    end)
    
    TestFramework.runTest("Grid - gridToPixels", function()
        local x, y = Grid.gridToPixels(5, 3)
        TestFramework.assertEqual(x, 120, "gridToPixels X failed")
        TestFramework.assertEqual(y, 72, "gridToPixels Y failed")
    end)
    
    TestFramework.runTest("Grid - pixelsToGrid", function()
        local col, row = Grid.pixelsToGrid(120, 72)
        TestFramework.assertEqual(col, 5, "pixelsToGrid col failed")
        TestFramework.assertEqual(row, 3, "pixelsToGrid row failed")
    end)
    
    TestFramework.runTest("Grid - isOnGrid", function()
        TestFramework.assert(Grid.isOnGrid(24, 48), "isOnGrid failed for aligned position")
        TestFramework.assert(not Grid.isOnGrid(25, 48), "isOnGrid incorrectly returned true")
    end)
    
    TestFramework.runTest("Grid - isValidSize", function()
        TestFramework.assert(Grid.isValidSize(48, 72), "isValidSize failed for valid size")
        TestFramework.assert(not Grid.isValidSize(50, 72), "isValidSize incorrectly returned true")
    end)
end

--[[
    Test Theme System
]]
function AllWidgetTests.testThemeSystem()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING THEME SYSTEM                             ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local Theme = Widgets.Theme
    
    TestFramework.runTest("Theme - Get primary color", function()
        local color = Theme.getColor("primary")
        TestFramework.assertNotNil(color, "Primary color is nil")
        TestFramework.assertNotNil(color.r, "Primary color missing r")
    end)
    
    TestFramework.runTest("Theme - Get default font", function()
        local font = Theme.getFont("default")
        TestFramework.assertNotNil(font, "Default font is nil")
    end)
    
    TestFramework.runTest("Theme - Apply widget style", function()
        local mockWidget = {
            x = 24, y = 24, width = 96, height = 48,
            backgroundColor = nil,
            borderColor = nil,
            textColor = nil
        }
        Theme.applyWidgetStyle(mockWidget, "button")
        TestFramework.assertNotNil(mockWidget.backgroundColor, "backgroundColor not applied")
        TestFramework.assertNotNil(mockWidget.borderColor, "borderColor not applied")
        TestFramework.assertNotNil(mockWidget.textColor, "textColor not applied")
    end)
end

--[[
    Run all widget tests
]]
function AllWidgetTests.runAll()
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║         WIDGET TEST SUITE - ALL 33 WIDGETS               ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    TestFramework.reset()
    
    -- Run all test suites
    local success1, err1 = pcall(AllWidgetTests.testBaseWidgets)
    if not success1 then
        print("\n[ERROR] Base widget tests failed:")
        print(err1)
    end
    
    local success2, err2 = pcall(AllWidgetTests.testStrategyWidgets)
    if not success2 then
        print("\n[ERROR] Strategy widget tests failed:")
        print(err2)
    end
    
    local success3, err3 = pcall(AllWidgetTests.testGridSystem)
    if not success3 then
        print("\n[ERROR] Grid system tests failed:")
        print(err3)
    end
    
    local success4, err4 = pcall(AllWidgetTests.testThemeSystem)
    if not success4 then
        print("\n[ERROR] Theme system tests failed:")
        print(err4)
    end
    
    -- Print summary
    TestFramework.printSummary()
    
    return TestFramework.results
end

return AllWidgetTests
