---Test Suite for BaseWidget
---
---Tests the core BaseWidget class functionality including grid snapping,
---position/size management, enabled/disabled states, visibility, and
---parent-child relationships.
---
---Test Coverage:
---  - Grid snapping (8 tests)
---  - Position and size management (6 tests)
---  - State management (4 tests)
---  - Parent-child relationships (3 tests)
---  - Event handling (3 tests)
---
---Dependencies:
---  - widgets.core.base
---  - widgets.core.grid
---
---@module tests.widgets.test_base_widget
---@author AlienFall Development Team
---@date 2025-10-15

-- Setup package path
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local BaseWidget = require("gui.widgets.core.base")
local Grid = require("gui.widgets.core.grid")

local TestBaseWidget = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper: Run a test
local function runTest(name, testFunc)
    local success, err = pcall(testFunc)
    if success then
        print("✓ " .. name .. " passed")
        testsPassed = testsPassed + 1
    else
        print("✗ " .. name .. " failed: " .. tostring(err))
        testsFailed = testsFailed + 1
        table.insert(failureDetails, {name = name, error = tostring(err)})
    end
end

-- Helper: Assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

---Test: Grid snapping on creation
function TestBaseWidget.testGridSnappingOnCreation()
    local widget = BaseWidget.new(25, 30, 50, 50)
    
    -- Positions should snap to nearest 24-pixel boundary
    assert(widget.x == 24, string.format("X should snap to 24, got %d", widget.x))
    assert(widget.y == 24, string.format("Y should snap to 24, got %d", widget.y))
    
    -- Sizes should snap to multiples of 24
    assert(widget.width == 48, string.format("Width should snap to 48, got %d", widget.width))
    assert(widget.height == 48, string.format("Height should snap to 48, got %d", widget.height))
end

---Test: Exact grid alignment
function TestBaseWidget.testExactGridAlignment()
    local widget = BaseWidget.new(48, 72, 96, 120)
    
    assert(widget.x == 48, "Exact grid X should not change")
    assert(widget.y == 72, "Exact grid Y should not change")
    assert(widget.width == 96, "Exact grid width should not change")
    assert(widget.height == 120, "Exact grid height should not change")
end

---Test: Zero position snapping
function TestBaseWidget.testZeroPositionSnapping()
    local widget = BaseWidget.new(0, 0, 24, 24)
    
    assert(widget.x == 0, "Zero X should remain 0")
    assert(widget.y == 0, "Zero Y should remain 0")
end

---Test: Large position snapping
function TestBaseWidget.testLargePositionSnapping()
    local widget = BaseWidget.new(937, 697, 24, 24)
    
    -- Should snap to 936, 696 (last valid grid position in 960×720)
    assert(widget.x == 936, string.format("X should snap to 936, got %d", widget.x))
    assert(widget.y == 696, string.format("Y should snap to 696, got %d", widget.y))
end

---Test: Set position with snapping
function TestBaseWidget.testSetPositionSnapping()
    local widget = BaseWidget.new(0, 0, 24, 24)
    
    widget:setPosition(50, 75)
    
    assert(widget.x == 48, string.format("X should snap to 48, got %d", widget.x))
    assert(widget.y == 72, string.format("Y should snap to 72, got %d", widget.y))
end

---Test: Set size with snapping
function TestBaseWidget.testSetSizeSnapping()
    local widget = BaseWidget.new(0, 0, 24, 24)
    
    widget:setSize(100, 130)
    
    assert(widget.width == 96, string.format("Width should snap to 96, got %d", widget.width))
    assert(widget.height == 120, string.format("Height should snap to 120, got %d", widget.height))
end

---Test: Grid coordinate conversion
function TestBaseWidget.testGridCoordinates()
    local widget = BaseWidget.new(120, 144, 72, 96)
    
    -- Grid coordinates should be pixel coords / 24
    local gridX, gridY = widget:getGridPosition()
    assert(gridX == 5, string.format("Grid X should be 5, got %d", gridX))
    assert(gridY == 6, string.format("Grid Y should be 6, got %d", gridY))
end

---Test: Grid size calculation
function TestBaseWidget.testGridSize()
    local widget = BaseWidget.new(0, 0, 96, 144)
    
    local gridW, gridH = widget:getGridSize()
    assert(gridW == 4, string.format("Grid width should be 4, got %d", gridW))
    assert(gridH == 6, string.format("Grid height should be 6, got %d", gridH))
end

---Test: Initial enabled state
function TestBaseWidget.testInitialEnabledState()
    local widget = BaseWidget.new(0, 0, 24, 24)
    
    assert(widget.enabled == true, "Widget should be enabled by default")
end

---Test: Set enabled state
function TestBaseWidget.testSetEnabled()
    local widget = BaseWidget.new(0, 0, 24, 24)
    
    widget:setEnabled(false)
    assert(widget.enabled == false, "Widget should be disabled")
    
    widget:setEnabled(true)
    assert(widget.enabled == true, "Widget should be re-enabled")
end

---Test: Initial visible state
function TestBaseWidget.testInitialVisibleState()
    local widget = BaseWidget.new(0, 0, 24, 24)
    
    assert(widget.visible == true, "Widget should be visible by default")
end

---Test: Set visible state
function TestBaseWidget.testSetVisible()
    local widget = BaseWidget.new(0, 0, 24, 24)
    
    widget:setVisible(false)
    assert(widget.visible == false, "Widget should be hidden")
    
    widget:setVisible(true)
    assert(widget.visible == true, "Widget should be visible again")
end

---Test: Contains point detection
function TestBaseWidget.testContainsPoint()
    local widget = BaseWidget.new(100, 100, 100, 100)
    
    -- Inside widget
    assert(widget:containsPoint(150, 150), "Point (150,150) should be inside")
    assert(widget:containsPoint(100, 100), "Top-left corner should be inside")
    assert(widget:containsPoint(199, 199), "Bottom-right edge should be inside")
    
    -- Outside widget
    assert(not widget:containsPoint(50, 50), "Point (50,50) should be outside")
    assert(not widget:containsPoint(200, 200), "Point (200,200) should be outside")
end

---Test: Bounds calculation
function TestBaseWidget.testGetBounds()
    local widget = BaseWidget.new(120, 144, 96, 72)
    
    local x1, y1, x2, y2 = widget:getBounds()
    
    assert(x1 == 120, string.format("Left bound should be 120, got %d", x1))
    assert(y1 == 144, string.format("Top bound should be 144, got %d", y1))
    assert(x2 == 216, string.format("Right bound should be 216, got %d", x2))
    assert(y2 == 216, string.format("Bottom bound should be 216, got %d", y2))
end

---Test: Add child widget
function TestBaseWidget.testAddChild()
    local parent = BaseWidget.new(0, 0, 200, 200)
    local child = BaseWidget.new(24, 24, 48, 48)
    
    parent:addChild(child)
    
    assert(#parent.children == 1, "Parent should have 1 child")
    assert(child.parent == parent, "Child should reference parent")
end

---Test: Remove child widget
function TestBaseWidget.testRemoveChild()
    local parent = BaseWidget.new(0, 0, 200, 200)
    local child = BaseWidget.new(24, 24, 48, 48)
    
    parent:addChild(child)
    parent:removeChild(child)
    
    assert(#parent.children == 0, "Parent should have 0 children")
    assert(child.parent == nil, "Child should not reference parent")
end

---Test: Multiple children
function TestBaseWidget.testMultipleChildren()
    local parent = BaseWidget.new(0, 0, 200, 200)
    local child1 = BaseWidget.new(24, 24, 48, 48)
    local child2 = BaseWidget.new(96, 24, 48, 48)
    local child3 = BaseWidget.new(24, 96, 48, 48)
    
    parent:addChild(child1)
    parent:addChild(child2)
    parent:addChild(child3)
    
    assert(#parent.children == 3, string.format("Parent should have 3 children, got %d", #parent.children))
end

---Test: Mouse press event
function TestBaseWidget.testMousePress()
    local widget = BaseWidget.new(100, 100, 100, 100)
    local clickedInside = false
    local clickedOutside = false
    
    widget.mousepressed = function(self, x, y, button)
        if self:containsPoint(x, y) then
            clickedInside = true
        else
            clickedOutside = true
        end
    end
    
    widget:mousepressed(150, 150, 1)  -- Inside
    assert(clickedInside, "Should detect click inside widget")
    
    clickedInside = false
    widget:mousepressed(50, 50, 1)  -- Outside
    -- Outside clicks shouldn't be handled by containsPoint check
end

---Test: Update function exists
function TestBaseWidget.testUpdateFunction()
    local widget = BaseWidget.new(0, 0, 24, 24)
    
    assert(type(widget.update) == "function", "Widget should have update function")
    
    -- Should not error when called
    local success = pcall(function() widget:update(0.016) end)
    assert(success, "Update should not error")
end

---Test: Draw function exists
function TestBaseWidget.testDrawFunction()
    local widget = BaseWidget.new(0, 0, 24, 24)
    
    assert(type(widget.draw) == "function", "Widget should have draw function")
end

-- Run all tests
function TestBaseWidget.runAll()
    print("\n=== Running BaseWidget Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    -- Grid snapping tests
    runTest("Grid snapping on creation", TestBaseWidget.testGridSnappingOnCreation)
    runTest("Exact grid alignment", TestBaseWidget.testExactGridAlignment)
    runTest("Zero position snapping", TestBaseWidget.testZeroPositionSnapping)
    runTest("Large position snapping", TestBaseWidget.testLargePositionSnapping)
    runTest("Set position with snapping", TestBaseWidget.testSetPositionSnapping)
    runTest("Set size with snapping", TestBaseWidget.testSetSizeSnapping)
    runTest("Grid coordinate conversion", TestBaseWidget.testGridCoordinates)
    runTest("Grid size calculation", TestBaseWidget.testGridSize)
    
    -- State management tests
    runTest("Initial enabled state", TestBaseWidget.testInitialEnabledState)
    runTest("Set enabled state", TestBaseWidget.testSetEnabled)
    runTest("Initial visible state", TestBaseWidget.testInitialVisibleState)
    runTest("Set visible state", TestBaseWidget.testSetVisible)
    
    -- Position/size tests
    runTest("Contains point detection", TestBaseWidget.testContainsPoint)
    runTest("Bounds calculation", TestBaseWidget.testGetBounds)
    
    -- Parent-child tests
    runTest("Add child widget", TestBaseWidget.testAddChild)
    runTest("Remove child widget", TestBaseWidget.testRemoveChild)
    runTest("Multiple children", TestBaseWidget.testMultipleChildren)
    
    -- Event tests
    runTest("Mouse press event", TestBaseWidget.testMousePress)
    runTest("Update function exists", TestBaseWidget.testUpdateFunction)
    runTest("Draw function exists", TestBaseWidget.testDrawFunction)
    
    -- Print results
    print("\n=== Test Results ===")
    print(string.format("Total: %d, Passed: %d (%.1f%%), Failed: %d",
        testsPassed + testsFailed,
        testsPassed,
        (testsPassed / (testsPassed + testsFailed)) * 100,
        testsFailed
    ))
    
    if testsFailed > 0 then
        print("\nFailed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  ✗ %s: %s", failure.name, failure.error))
        end
    else
        print("\n✓ All BaseWidget tests passed!")
    end
    
    return testsPassed, testsFailed
end

-- Run if executed directly
if arg and arg[0]:match("test_base_widget%.lua$") then
    TestBaseWidget.runAll()
end

return TestBaseWidget



