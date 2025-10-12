--[[
    Widget Test Framework
    
    Provides testing utilities for widget development and validation.
    Features:
    - Grid alignment validation
    - Theme integration checks
    - Event handling verification
    - Mock event generation
    - Test result reporting
]]

local WidgetTestFramework = {}

-- Test results storage
WidgetTestFramework.results = {
    passed = 0,
    failed = 0,
    tests = {}
}

--[[
    Assert a condition is true
]]
function WidgetTestFramework.assert(condition, message)
    if not condition then
        error(message or "Assertion failed", 2)
    end
end

--[[
    Assert two values are equal
]]
function WidgetTestFramework.assertEqual(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\nExpected: %s\nActual: %s", 
            message or "Values not equal", 
            tostring(expected), 
            tostring(actual)), 2)
    end
end

--[[
    Assert a value is not nil
]]
function WidgetTestFramework.assertNotNil(value, message)
    if value == nil then
        error(message or "Value is nil", 2)
    end
end

--[[
    Assert a value is nil
]]
function WidgetTestFramework.assertNil(value, message)
    if value ~= nil then
        error(message or "Value is not nil", 2)
    end
end

--[[
    Run a test with error handling
]]
function WidgetTestFramework.runTest(name, testFunc)
    local success, err = pcall(testFunc)
    
    local result = {
        name = name,
        passed = success,
        error = err
    }
    
    table.insert(WidgetTestFramework.results.tests, result)
    
    if success then
        WidgetTestFramework.results.passed = WidgetTestFramework.results.passed + 1
        print(string.format("  ✓ %s", name))
    else
        WidgetTestFramework.results.failed = WidgetTestFramework.results.failed + 1
        print(string.format("  ✗ %s", name))
        print(string.format("    Error: %s", err))
    end
    
    return success
end

--[[
    Validate grid alignment for a widget
]]
function WidgetTestFramework.validateGridAlignment(widget, widgetName)
    local Grid = require("widgets.grid")
    
    WidgetTestFramework.runTest(widgetName .. " - Grid X alignment", function()
        WidgetTestFramework.assert(widget.x % Grid.CELL_SIZE == 0, 
            "X position not aligned to grid: " .. widget.x)
    end)
    
    WidgetTestFramework.runTest(widgetName .. " - Grid Y alignment", function()
        WidgetTestFramework.assert(widget.y % Grid.CELL_SIZE == 0, 
            "Y position not aligned to grid: " .. widget.y)
    end)
    
    WidgetTestFramework.runTest(widgetName .. " - Grid Width alignment", function()
        WidgetTestFramework.assert(widget.width % Grid.CELL_SIZE == 0, 
            "Width not aligned to grid: " .. widget.width)
    end)
    
    WidgetTestFramework.runTest(widgetName .. " - Grid Height alignment", function()
        WidgetTestFramework.assert(widget.height % Grid.CELL_SIZE == 0, 
            "Height not aligned to grid: " .. widget.height)
    end)
end

--[[
    Validate theme integration
]]
function WidgetTestFramework.validateTheme(widget, widgetName)
    WidgetTestFramework.runTest(widgetName .. " - Has background color", function()
        WidgetTestFramework.assertNotNil(widget.backgroundColor, 
            "Widget missing backgroundColor")
    end)
    
    WidgetTestFramework.runTest(widgetName .. " - Has border color", function()
        WidgetTestFramework.assertNotNil(widget.borderColor, 
            "Widget missing borderColor")
    end)
    
    WidgetTestFramework.runTest(widgetName .. " - Has text color", function()
        WidgetTestFramework.assertNotNil(widget.textColor, 
            "Widget missing textColor")
    end)
end

--[[
    Validate basic widget properties
]]
function WidgetTestFramework.validateBasicProperties(widget, widgetName)
    WidgetTestFramework.runTest(widgetName .. " - Has visible property", function()
        WidgetTestFramework.assertNotNil(widget.visible, "Widget missing visible property")
    end)
    
    WidgetTestFramework.runTest(widgetName .. " - Has enabled property", function()
        WidgetTestFramework.assertNotNil(widget.enabled, "Widget missing enabled property")
    end)
    
    WidgetTestFramework.runTest(widgetName .. " - Has containsPoint method", function()
        WidgetTestFramework.assertNotNil(widget.containsPoint, "Widget missing containsPoint method")
        WidgetTestFramework.assertEqual(type(widget.containsPoint), "function", 
            "containsPoint is not a function")
    end)
    
    WidgetTestFramework.runTest(widgetName .. " - Has draw method", function()
        WidgetTestFramework.assertNotNil(widget.draw, "Widget missing draw method")
        WidgetTestFramework.assertEqual(type(widget.draw), "function", 
            "draw is not a function")
    end)
end

--[[
    Test containsPoint functionality
]]
function WidgetTestFramework.testContainsPoint(widget, widgetName)
    WidgetTestFramework.runTest(widgetName .. " - containsPoint (inside)", function()
        local centerX = widget.x + widget.width / 2
        local centerY = widget.y + widget.height / 2
        WidgetTestFramework.assert(widget:containsPoint(centerX, centerY), 
            "containsPoint failed for center point")
    end)
    
    WidgetTestFramework.runTest(widgetName .. " - containsPoint (outside)", function()
        local outsideX = widget.x - 10
        local outsideY = widget.y - 10
        WidgetTestFramework.assert(not widget:containsPoint(outsideX, outsideY), 
            "containsPoint incorrectly returned true for outside point")
    end)
end

--[[
    Test enabled/disabled state
]]
function WidgetTestFramework.testEnabledState(widget, widgetName)
    WidgetTestFramework.runTest(widgetName .. " - Enable/Disable", function()
        widget.enabled = true
        WidgetTestFramework.assert(widget.enabled, "Widget not enabled")
        
        widget.enabled = false
        WidgetTestFramework.assert(not widget.enabled, "Widget not disabled")
        
        widget.enabled = true
    end)
end

--[[
    Test visible/hidden state
]]
function WidgetTestFramework.testVisibleState(widget, widgetName)
    WidgetTestFramework.runTest(widgetName .. " - Show/Hide", function()
        widget.visible = true
        WidgetTestFramework.assert(widget.visible, "Widget not visible")
        
        widget.visible = false
        WidgetTestFramework.assert(not widget.visible, "Widget not hidden")
        
        widget.visible = true
    end)
end

--[[
    Run comprehensive widget tests
]]
function WidgetTestFramework.testWidget(widget, widgetName)
    print("\n" .. widgetName .. ":")
    
    WidgetTestFramework.validateGridAlignment(widget, widgetName)
    WidgetTestFramework.validateTheme(widget, widgetName)
    WidgetTestFramework.validateBasicProperties(widget, widgetName)
    WidgetTestFramework.testContainsPoint(widget, widgetName)
    WidgetTestFramework.testEnabledState(widget, widgetName)
    WidgetTestFramework.testVisibleState(widget, widgetName)
end

--[[
    Reset test results
]]
function WidgetTestFramework.reset()
    WidgetTestFramework.results = {
        passed = 0,
        failed = 0,
        tests = {}
    }
end

--[[
    Print test summary
]]
function WidgetTestFramework.printSummary()
    print("\n" .. string.rep("=", 60))
    print("TEST SUMMARY")
    print(string.rep("=", 60))
    print(string.format("Total Tests: %d", WidgetTestFramework.results.passed + WidgetTestFramework.results.failed))
    print(string.format("Passed: %d", WidgetTestFramework.results.passed))
    print(string.format("Failed: %d", WidgetTestFramework.results.failed))
    
    local coverage = 0
    if WidgetTestFramework.results.passed + WidgetTestFramework.results.failed > 0 then
        coverage = (WidgetTestFramework.results.passed / 
                   (WidgetTestFramework.results.passed + WidgetTestFramework.results.failed)) * 100
    end
    print(string.format("Pass Rate: %.1f%%", coverage))
    print(string.rep("=", 60))
end

return WidgetTestFramework
