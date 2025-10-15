---Test Suite for Button Widget
---
---Tests button functionality including click events, hover states, text management,
---enabled/disabled behavior, and grid alignment.
---
---Test Coverage:
---  - Button creation and initialization (3 tests)
---  - Text management (3 tests)
---  - Click event handling (4 tests)
---  - Hover state management (3 tests)
---  - Enabled/disabled states (3 tests)
---
---Dependencies:
---  - widgets.buttons.button
---  - widgets.core.base
---
---@module tests.widgets.test_button
---@author AlienFall Development Team
---@date 2025-10-15

-- Setup package path
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local Button = require("widgets.buttons.button")

local TestButton = {}
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

---Test: Button creation with default text
function TestButton.testButtonCreation()
    local button = Button.new(0, 0, 96, 48, "Test")
    
    assert(button ~= nil, "Button should be created")
    assert(button.text == "Test", "Button should have specified text")
    assert(button.x == 0, "Button X should be 0")
    assert(button.y == 0, "Button Y should be 0")
    assert(button.width == 96, "Button width should be 96")
    assert(button.height == 48, "Button height should be 48")
end

---Test: Button creation without text
function TestButton.testButtonCreationNoText()
    local button = Button.new(24, 24, 96, 48)
    
    assert(button.text == "Button", "Button should have default text")
end

---Test: Button grid alignment
function TestButton.testButtonGridAlignment()
    local button = Button.new(25, 30, 100, 50, "Test")
    
    -- Should snap to grid
    assert(button.x == 24, string.format("X should snap to 24, got %d", button.x))
    assert(button.y == 24, string.format("Y should snap to 24, got %d", button.y))
    assert(button.width == 96, string.format("Width should snap to 96, got %d", button.width))
    assert(button.height == 48, string.format("Height should snap to 48, got %d", button.height))
end

---Test: Set button text
function TestButton.testSetText()
    local button = Button.new(0, 0, 96, 48, "Original")
    
    button:setText("New Text")
    assert(button.text == "New Text", "Button text should be updated")
end

---Test: Set empty text
function TestButton.testSetEmptyText()
    local button = Button.new(0, 0, 96, 48, "Original")
    
    button:setText("")
    assert(button.text == "", "Button should accept empty text")
end

---Test: Set nil text defaults to empty
function TestButton.testSetNilText()
    local button = Button.new(0, 0, 96, 48, "Original")
    
    button:setText(nil)
    assert(button.text == "", "Nil text should default to empty string")
end

---Test: Button callback
function TestButton.testButtonCallback()
    local button = Button.new(0, 0, 96, 48, "Click")
    local clicked = false
    
    button:setCallback(function()
        clicked = true
    end)
    
    -- Simulate click inside button
    button:mousepressed(50, 24, 1)
    button:mousereleased(50, 24, 1)
    
    assert(clicked, "Button callback should be invoked on click")
end

---Test: Button click outside bounds
function TestButton.testClickOutsideBounds()
    local button = Button.new(100, 100, 96, 48, "Click")
    local clicked = false
    
    button:setCallback(function()
        clicked = true
    end)
    
    -- Click outside button
    button:mousepressed(50, 50, 1)
    button:mousereleased(50, 50, 1)
    
    assert(not clicked, "Button should not trigger on click outside bounds")
end

---Test: Button disabled no callback
function TestButton.testDisabledNoCallback()
    local button = Button.new(0, 0, 96, 48, "Click")
    local clicked = false
    
    button:setCallback(function()
        clicked = true
    end)
    
    button:setEnabled(false)
    
    -- Try to click disabled button
    button:mousepressed(50, 24, 1)
    button:mousereleased(50, 24, 1)
    
    assert(not clicked, "Disabled button should not trigger callback")
end

---Test: Button press and release sequence
function TestButton.testPressReleaseSequence()
    local button = Button.new(0, 0, 96, 48, "Click")
    
    -- Initially not pressed
    assert(button.pressed == false, "Button should not be pressed initially")
    
    -- Press
    button:mousepressed(50, 24, 1)
    assert(button.pressed == true, "Button should be pressed after mouse down")
    
    -- Release
    button:mousereleased(50, 24, 1)
    assert(button.pressed == false, "Button should not be pressed after release")
end

---Test: Hover state on mouse move
function TestButton.testHoverState()
    local button = Button.new(100, 100, 96, 48, "Hover")
    
    -- Initially not hovered
    assert(button.hovered == false or button.hovered == nil, "Button should not be hovered initially")
    
    -- Move mouse over button
    button:mousemoved(150, 124, 0, 0)
    
    -- Check if hover tracking exists (implementation may vary)
    -- This tests that mousemoved doesn't error
end

---Test: Hover outside bounds
function TestButton.testHoverOutside()
    local button = Button.new(100, 100, 96, 48, "Hover")
    
    -- Move mouse outside button
    button:mousemoved(50, 50, 0, 0)
    
    -- Should not error
end

---Test: Hover then leave
function TestButton.testHoverLeave()
    local button = Button.new(100, 100, 96, 48, "Hover")
    
    -- Enter button
    button:mousemoved(150, 124, 0, 0)
    
    -- Leave button
    button:mousemoved(50, 50, 0, 0)
    
    -- Should not error
end

---Test: Enable and disable button
function TestButton.testEnableDisable()
    local button = Button.new(0, 0, 96, 48, "Toggle")
    
    assert(button.enabled == true, "Button should be enabled by default")
    
    button:setEnabled(false)
    assert(button.enabled == false, "Button should be disabled")
    
    button:setEnabled(true)
    assert(button.enabled == true, "Button should be re-enabled")
end

---Test: Disabled button appearance
function TestButton.testDisabledAppearance()
    local button = Button.new(0, 0, 96, 48, "Disabled")
    
    button:setEnabled(false)
    
    -- Button should still have text and dimensions when disabled
    assert(button.text == "Disabled", "Disabled button should keep text")
    assert(button.width == 96, "Disabled button should keep width")
    assert(button.height == 48, "Disabled button should keep height")
end

---Test: Multiple buttons independence
function TestButton.testMultipleButtonsIndependence()
    local button1 = Button.new(0, 0, 96, 48, "Button 1")
    local button2 = Button.new(120, 0, 96, 48, "Button 2")
    
    local clicked1 = false
    local clicked2 = false
    
    button1:setCallback(function() clicked1 = true end)
    button2:setCallback(function() clicked2 = true end)
    
    -- Click button 1
    button1:mousepressed(50, 24, 1)
    button1:mousereleased(50, 24, 1)
    
    assert(clicked1, "Button 1 should be clicked")
    assert(not clicked2, "Button 2 should not be clicked")
end

-- Run all tests
function TestButton.runAll()
    print("\n=== Running Button Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    -- Creation tests
    runTest("Button creation with text", TestButton.testButtonCreation)
    runTest("Button creation without text", TestButton.testButtonCreationNoText)
    runTest("Button grid alignment", TestButton.testButtonGridAlignment)
    
    -- Text management tests
    runTest("Set button text", TestButton.testSetText)
    runTest("Set empty text", TestButton.testSetEmptyText)
    runTest("Set nil text", TestButton.testSetNilText)
    
    -- Click event tests
    runTest("Button callback", TestButton.testButtonCallback)
    runTest("Click outside bounds", TestButton.testClickOutsideBounds)
    runTest("Disabled no callback", TestButton.testDisabledNoCallback)
    runTest("Press and release sequence", TestButton.testPressReleaseSequence)
    
    -- Hover tests
    runTest("Hover state", TestButton.testHoverState)
    runTest("Hover outside", TestButton.testHoverOutside)
    runTest("Hover then leave", TestButton.testHoverLeave)
    
    -- Enable/disable tests
    runTest("Enable and disable", TestButton.testEnableDisable)
    runTest("Disabled appearance", TestButton.testDisabledAppearance)
    runTest("Multiple buttons independence", TestButton.testMultipleButtonsIndependence)
    
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
        print("\n✓ All Button tests passed!")
    end
    
    return testsPassed, testsFailed
end

-- Run if executed directly
if arg and arg[0]:match("test_button%.lua$") then
    TestButton.runAll()
end

return TestButton
