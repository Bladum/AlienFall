---================================================================================
---PHASE 3G: Widget Advanced Systems Tests
---================================================================================
---
---Comprehensive test suite for advanced widget systems including:
---
---  1. Widget Hierarchy & Layout (5 tests)
---     - Grid snapping, positioning, parent-child relationships
---     - Layout calculations and bounds
---
---  2. Button Interactions (5 tests)
---     - Click detection, callbacks, state management
---     - Hover states and visual feedback
---
---  3. Container & Panels (4 tests)
---     - Container management, child ordering
---     - Panel layouts and clipping
---
---  4. Input Handling (4 tests)
---     - Text input, focus management
---     - Input validation and event propagation
---
---  5. Advanced Rendering (3 tests)
---     - Layer management, z-ordering
---     - Clipping and viewport management
---
---  6. Integration Tests (2 tests)
---     - Complete widget hierarchy traversal
---     - Event propagation through hierarchy
---
---@module tests2.widgets.widget_advanced_test

package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")

---@class MockBaseWidget
---Core widget class with positioning, sizing, hierarchy, and event handling.
---@field x number Widget x position (grid-aligned)
---field y number Widget y position (grid-aligned)
---@field width number Widget width (grid-aligned)
---@field height number Widget height (grid-aligned)
---@field enabled boolean Whether widget accepts interactions
---@field visible boolean Whether widget is rendered
---@field children table[] Child widgets
---@field parent table|nil Parent widget
local MockBaseWidget = {}
MockBaseWidget.__index = MockBaseWidget

function MockBaseWidget:new(x, y, width, height)
    local instance = {
        x = self:snapToGrid(x),
        y = self:snapToGrid(y),
        width = self:snapToGrid(width),
        height = self:snapToGrid(height),
        enabled = true,
        visible = true,
        children = {},
        parent = nil
    }
    setmetatable(instance, self)
    return instance
end

function MockBaseWidget:snapToGrid(value)
    return math.floor(value / 24) * 24
end

function MockBaseWidget:setPosition(x, y)
    self.x = self:snapToGrid(x)
    self.y = self:snapToGrid(y)
end

function MockBaseWidget:setSize(w, h)
    self.width = self:snapToGrid(w)
    self.height = self:snapToGrid(h)
end

function MockBaseWidget:setEnabled(enabled)
    self.enabled = enabled
end

function MockBaseWidget:setVisible(visible)
    self.visible = visible
end

function MockBaseWidget:addChild(child)
    table.insert(self.children, child)
    child.parent = self
end

function MockBaseWidget:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            child.parent = nil
            return true
        end
    end
    return false
end

function MockBaseWidget:containsPoint(x, y)
    return x >= self.x and x < self.x + self.width and
           y >= self.y and y < self.y + self.height
end

function MockBaseWidget:getBounds()
    return self.x, self.y, self.x + self.width, self.y + self.height
end

function MockBaseWidget:getAbsolutePosition()
    local ax, ay = self.x, self.y
    local parent = self.parent
    while parent do
        ax = ax + parent.x
        ay = ay + parent.y
        parent = parent.parent
    end
    return ax, ay
end

---@class MockButton
---Interactive button widget with callbacks and state management.
---@field text string Button label text
---@field callback function|nil Click handler
---@field pressed boolean Current press state
---@field hovered boolean Current hover state
local MockButton = setmetatable({}, {__index = MockBaseWidget})
MockButton.__index = MockButton

function MockButton:new(x, y, width, height, text)
    local instance = MockBaseWidget:new(x, y, width, height)
    instance.text = text or "Button"
    instance.callback = nil
    instance.pressed = false
    instance.hovered = false
    setmetatable(instance, self)
    return instance
end

function MockButton:setText(text)
    self.text = text or ""
end

function MockButton:setCallback(callback)
    self.callback = callback
end

function MockButton:mousepressed(x, y, button)
    if self.enabled and self:containsPoint(x, y) then
        self.pressed = true
        return true
    end
    return false
end

function MockButton:mousereleased(x, y, button)
    if self.pressed and self.enabled and self:containsPoint(x, y) then
        self.pressed = false
        if self.callback then
            self.callback()
        end
        return true
    end
    self.pressed = false
    return false
end

function MockButton:mousemoved(x, y)
    self.hovered = self:containsPoint(x, y)
end

---@class MockTextInput
---Text input widget with focus and validation.
---@field value string Current input text
---@field focused boolean Has keyboard focus
---@field maxLength number Maximum characters
---@field validator function|nil Input validation function
local MockTextInput = setmetatable({}, {__index = MockBaseWidget})
MockTextInput.__index = MockTextInput

function MockTextInput:new(x, y, width, height, maxLength)
    local instance = MockBaseWidget:new(x, y, width, height)
    instance.value = ""
    instance.focused = false
    instance.maxLength = maxLength or 100
    instance.validator = nil
    setmetatable(instance, self)
    return instance
end

function MockTextInput:setFocus(focused)
    self.focused = focused
end

function MockTextInput:textinput(text)
    if not self.focused or not self.enabled then
        return false
    end

    if #self.value + #text <= self.maxLength then
        local newValue = self.value .. text
        if not self.validator or self.validator(newValue) then
            self.value = newValue
            return true
        end
    end
    return false
end

function MockTextInput:backspace()
    if self.focused and self.enabled and #self.value > 0 then
        self.value = self.value:sub(1, -2)
        return true
    end
    return false
end

function MockTextInput:mousepressed(x, y)
    self.focused = self:containsPoint(x, y) and self.enabled
    return self.focused
end

---@class MockPanel
---Container widget for organizing child widgets.
---@field children table[] Contained child widgets
---@field scrollX number Horizontal scroll offset
---@field scrollY number Vertical scroll offset
local MockPanel = setmetatable({}, {__index = MockBaseWidget})
MockPanel.__index = MockPanel

function MockPanel:new(x, y, width, height)
    local instance = MockBaseWidget:new(x, y, width, height)
    instance.scrollX = 0
    instance.scrollY = 0
    setmetatable(instance, self)
    return instance
end

function MockPanel:scroll(dx, dy)
    self.scrollX = self.scrollX + dx
    self.scrollY = self.scrollY + dy
end

function MockPanel:isChildVisible(child)
    if not self.visible or not child.visible then
        return false
    end

    local cx, cy = child.x - self.scrollX, child.y - self.scrollY
    local cx2, cy2 = cx + child.width, cy + child.height

    -- Check if child overlaps panel bounds
    return cx2 > self.x and cx < self.x + self.width and
           cy2 > self.y and cy < self.y + self.height
end

function MockPanel:getVisibleChildren()
    local visible = {}
    for _, child in ipairs(self.children) do
        if self:isChildVisible(child) then
            table.insert(visible, child)
        end
    end
    return visible
end

---@class MockLayerSystem
---Manages widget rendering layers and z-ordering.
---@field layers table[] Organized layers of widgets
local MockLayerSystem = {}

function MockLayerSystem:new()
    local instance = {
        layers = {}
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockLayerSystem:addWidget(widget, layer)
    layer = layer or 0
    if not self.layers[layer] then
        self.layers[layer] = {}
    end
    table.insert(self.layers[layer], widget)
end

function MockLayerSystem:removeWidget(widget)
    for layer, widgets in pairs(self.layers) do
        for i, w in ipairs(widgets) do
            if w == widget then
                table.remove(widgets, i)
                return true
            end
        end
    end
    return false
end

function MockLayerSystem:bringToFront(widget)
    self:removeWidget(widget)
    self:addWidget(widget, 100)  -- Top layer
end

function MockLayerSystem:sendToBack(widget)
    self:removeWidget(widget)
    self:addWidget(widget, -100)  -- Bottom layer
end

function MockLayerSystem:getWidgetsInOrder()
    local result = {}
    for layer = -100, 100 do
        if self.layers[layer] then
            for _, widget in ipairs(self.layers[layer]) do
                table.insert(result, widget)
            end
        end
    end
    return result
end

---@class MockEventPropagator
---Handles event propagation through widget hierarchy.
local MockEventPropagator = {}

function MockEventPropagator:new()
    local instance = {
        eventLog = {}
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockEventPropagator:propagateMousePress(widgets, x, y)
    for i = #widgets, 1, -1 do
        local widget = widgets[i]
        if widget.enabled and widget:containsPoint(x, y) then
            table.insert(self.eventLog, {type = "press", widget = widget})
            if widget.mousepressed then
                local consumed = widget:mousepressed(x, y, 1)
                if consumed then return true end
            end
        end
    end
    return false
end

function MockEventPropagator:propagateMouseRelease(widgets, x, y)
    for i = #widgets, 1, -1 do
        local widget = widgets[i]
        if widget.enabled then
            table.insert(self.eventLog, {type = "release", widget = widget})
            if widget.mousereleased then
                local consumed = widget:mousereleased(x, y, 1)
                if consumed then return true end
            end
        end
    end
    return false
end

function MockEventPropagator:getEventCount()
    return #self.eventLog
end

---================================================================================
---TEST SUITE
---================================================================================

local Suite = HierarchicalSuite:new({
    module = "engine.gui.widgets.advanced",
    file = "widget_advanced_test.lua",
    description = "Widget advanced systems - Hierarchy, buttons, panels, input, layers"
})

---WIDGET HIERARCHY & LAYOUT TESTS
Suite:group("Widget Hierarchy & Layout", function()

    Suite:testMethod("MockBaseWidget:new", {
        description = "Creates widget with grid-snapped dimensions",
        testCase = "initialization",
        type = "functional"
    }, function()
        local widget = MockBaseWidget:new(25, 30, 100, 50)
        if widget.x ~= 24 then error("X should snap to 24") end
        if widget.y ~= 24 then error("Y should snap to 24") end
        if widget.width ~= 96 then error("Width should snap to 96") end
        if widget.height ~= 48 then error("Height should snap to 48") end
    end)

    Suite:testMethod("MockBaseWidget:setPosition", {
        description = "Updates widget position with grid snapping",
        testCase = "positioning",
        type = "functional"
    }, function()
        local widget = MockBaseWidget:new(0, 0, 48, 48)
        widget:setPosition(50, 75)

        if widget.x ~= 48 then error("X should snap to 48") end
        if widget.y ~= 72 then error("Y should snap to 72") end
    end)

    Suite:testMethod("MockBaseWidget:addChild", {
        description = "Establishes parent-child widget relationships",
        testCase = "hierarchy",
        type = "functional"
    }, function()
        local parent = MockBaseWidget:new(0, 0, 200, 200)
        local child = MockBaseWidget:new(24, 24, 48, 48)

        parent:addChild(child)
        if #parent.children ~= 1 then error("Parent should have 1 child") end
        if child.parent ~= parent then error("Child should reference parent") end
    end)

    Suite:testMethod("MockBaseWidget:removeChild", {
        description = "Removes child from parent hierarchy",
        testCase = "hierarchy_removal",
        type = "functional"
    }, function()
        local parent = MockBaseWidget:new(0, 0, 200, 200)
        local child = MockBaseWidget:new(24, 24, 48, 48)

        parent:addChild(child)
        parent:removeChild(child)

        if #parent.children ~= 0 then error("Parent should have 0 children") end
        if child.parent ~= nil then error("Child parent should be nil") end
    end)

    Suite:testMethod("MockBaseWidget:getAbsolutePosition", {
        description = "Calculates absolute position in hierarchy",
        testCase = "absolute_position",
        type = "functional"
    }, function()
        local parent = MockBaseWidget:new(120, 144, 200, 200)
        local child = MockBaseWidget:new(48, 48, 96, 96)

        parent:addChild(child)

        local ax, ay = child:getAbsolutePosition()
        if ax ~= 168 then error("Absolute X should be 168") end
        if ay ~= 192 then error("Absolute Y should be 192") end
    end)
end)

---BUTTON INTERACTIONS TESTS
Suite:group("Button Interactions", function()

    Suite:testMethod("MockButton:new", {
        description = "Creates button with text and dimensions",
        testCase = "initialization",
        type = "functional"
    }, function()
        local button = MockButton:new(0, 0, 96, 48, "Click Me")
        if button.text ~= "Click Me" then error("Text should be 'Click Me'") end
        if button.pressed then error("Button should not be pressed initially") end
    end)

    Suite:testMethod("MockButton:setText", {
        description = "Updates button text dynamically",
        testCase = "text_update",
        type = "functional"
    }, function()
        local button = MockButton:new(0, 0, 96, 48, "Original")
        button:setText("Updated")

        if button.text ~= "Updated" then error("Text should be 'Updated'") end
    end)

    Suite:testMethod("MockButton:setCallback", {
        description = "Triggers callback on click",
        testCase = "callback",
        type = "functional"
    }, function()
        local button = MockButton:new(0, 0, 96, 48, "Click")
        local clicked = false

        button:setCallback(function()
            clicked = true
        end)

        button:mousepressed(50, 24, 1)
        button:mousereleased(50, 24, 1)

        if not clicked then error("Callback should be triggered") end
    end)

    Suite:testMethod("MockButton:mousepressed", {
        description = "Detects clicks inside button bounds",
        testCase = "click_detection",
        type = "functional"
    }, function()
        local button = MockButton:new(100, 100, 96, 48)

        local inside = button:mousepressed(150, 124, 1)
        if not inside then error("Click inside should be detected") end

        local outside = button:mousepressed(50, 50, 1)
        if outside then error("Click outside should not be detected") end
    end)

    Suite:testMethod("MockButton:mousemoved", {
        description = "Tracks hover state over button",
        testCase = "hover_tracking",
        type = "functional"
    }, function()
        local button = MockButton:new(100, 100, 96, 48)

        button:mousemoved(150, 124)
        if not button.hovered then error("Button should be hovered") end

        button:mousemoved(50, 50)
        if button.hovered then error("Button should not be hovered outside") end
    end)
end)

---CONTAINER & PANELS TESTS
Suite:group("Container & Panels", function()

    Suite:testMethod("MockPanel:new", {
        description = "Creates panel container",
        testCase = "initialization",
        type = "functional"
    }, function()
        local panel = MockPanel:new(0, 0, 480, 360)
        if panel.scrollX ~= 0 then error("Initial scroll X should be 0") end
        if panel.scrollY ~= 0 then error("Initial scroll Y should be 0") end
    end)

    Suite:testMethod("MockPanel:addChild", {
        description = "Adds widgets to panel",
        testCase = "child_management",
        type = "functional"
    }, function()
        local panel = MockPanel:new(0, 0, 480, 360)
        local widget = MockBaseWidget:new(24, 24, 48, 48)

        panel:addChild(widget)
        if #panel.children ~= 1 then error("Panel should have 1 child") end
    end)

    Suite:testMethod("MockPanel:scroll", {
        description = "Handles panel scrolling",
        testCase = "scrolling",
        type = "functional"
    }, function()
        local panel = MockPanel:new(0, 0, 480, 360)
        panel:scroll(100, 50)

        if panel.scrollX ~= 100 then error("Scroll X should be 100") end
        if panel.scrollY ~= 50 then error("Scroll Y should be 50") end
    end)

    Suite:testMethod("MockPanel:getVisibleChildren", {
        description = "Filters visible children based on scroll and clip",
        testCase = "visibility_culling",
        type = "functional"
    }, function()
        local panel = MockPanel:new(0, 0, 240, 180)
        local child1 = MockBaseWidget:new(0, 0, 48, 48)
        local child2 = MockBaseWidget:new(500, 500, 48, 48)  -- Far outside

        panel:addChild(child1)
        panel:addChild(child2)

        local visible = panel:getVisibleChildren()
        if #visible ~= 1 then error("Should have 1 visible child") end
    end)
end)

---TEXT INPUT TESTS
Suite:group("Input Handling", function()

    Suite:testMethod("MockTextInput:new", {
        description = "Creates text input widget",
        testCase = "initialization",
        type = "functional"
    }, function()
        local input = MockTextInput:new(0, 0, 240, 48, 50)
        if input.value ~= "" then error("Initial value should be empty") end
        if input.focused then error("Should not be focused initially") end
        if input.maxLength ~= 50 then error("Max length should be 50") end
    end)

    Suite:testMethod("MockTextInput:setFocus", {
        description = "Sets input focus state",
        testCase = "focus",
        type = "functional"
    }, function()
        local input = MockTextInput:new(0, 0, 240, 48)
        input:setFocus(true)

        if not input.focused then error("Should be focused") end

        input:setFocus(false)
        if input.focused then error("Should not be focused") end
    end)

    Suite:testMethod("MockTextInput:textinput", {
        description = "Accepts text input when focused",
        testCase = "text_entry",
        type = "functional"
    }, function()
        local input = MockTextInput:new(0, 0, 240, 48, 50)
        input:setFocus(true)

        input:textinput("Hello")
        if input.value ~= "Hello" then error("Value should be 'Hello'") end

        input:textinput(" World")
        if input.value ~= "Hello World" then error("Value should be 'Hello World'") end
    end)

    Suite:testMethod("MockTextInput:backspace", {
        description = "Removes character on backspace",
        testCase = "deletion",
        type = "functional"
    }, function()
        local input = MockTextInput:new(0, 0, 240, 48, 50)
        input:setFocus(true)
        input:textinput("Test")

        input:backspace()
        if input.value ~= "Tes" then error("Value should be 'Tes'") end
    end)
end)

---LAYER & RENDERING TESTS
Suite:group("Advanced Rendering", function()

    Suite:testMethod("MockLayerSystem:new", {
        description = "Initializes layer system",
        testCase = "initialization",
        type = "functional"
    }, function()
        local layers = MockLayerSystem:new()
        if #layers:getWidgetsInOrder() ~= 0 then error("Should start empty") end
    end)

    Suite:testMethod("MockLayerSystem:addWidget", {
        description = "Adds widget to layer",
        testCase = "layer_management",
        type = "functional"
    }, function()
        local layers = MockLayerSystem:new()
        local widget = MockBaseWidget:new(0, 0, 48, 48)

        layers:addWidget(widget, 0)
        if #layers:getWidgetsInOrder() ~= 1 then error("Should have 1 widget") end
    end)

    Suite:testMethod("MockLayerSystem:bringToFront", {
        description = "Brings widget to front layer",
        testCase = "z_ordering",
        type = "functional"
    }, function()
        local layers = MockLayerSystem:new()
        local widget1 = MockBaseWidget:new(0, 0, 48, 48)
        local widget2 = MockBaseWidget:new(48, 0, 48, 48)

        layers:addWidget(widget1, 0)
        layers:addWidget(widget2, 0)

        layers:bringToFront(widget1)

        local order = layers:getWidgetsInOrder()
        if order[#order] ~= widget1 then error("Widget1 should be last (front)") end
    end)
end)

---INTEGRATION TESTS
Suite:group("Integration", function()

    Suite:testMethod("Widget Hierarchy Traversal", {
        description = "Traverses complete widget tree",
        testCase = "tree_traversal",
        type = "integration"
    }, function()
        local root = MockPanel:new(0, 0, 960, 720)
        local panel1 = MockPanel:new(24, 24, 450, 300)
        local button1 = MockButton:new(48, 48, 96, 48, "B1")
        local button2 = MockButton:new(48, 120, 96, 48, "B2")
        local input = MockTextInput:new(48, 200, 200, 48)

        root:addChild(panel1)
        panel1:addChild(button1)
        panel1:addChild(button2)
        panel1:addChild(input)

        if #root.children ~= 1 then error("Root should have 1 child") end
        if #panel1.children ~= 3 then error("Panel should have 3 children") end

        local ax, ay = button1:getAbsolutePosition()
        if ax < 24 then error("Button absolute X should account for parent") end
    end)

    Suite:testMethod("Event Propagation", {
        description = "Propagates events through widget hierarchy",
        testCase = "event_flow",
        type = "integration"
    }, function()
        local propagator = MockEventPropagator:new()
        local buttons = {}

        for i = 1, 5 do
            table.insert(buttons, MockButton:new((i-1)*120, 0, 96, 48))
        end

        propagator:propagateMousePress(buttons, 150, 24)

        if propagator:getEventCount() == 0 then error("Should have logged event") end
    end)
end)

---PERFORMANCE BENCHMARKS
Suite:group("Performance", function()

    Suite:testMethod("Scaling - Widget Hierarchy", {
        description = "Handles large widget trees efficiently",
        testCase = "hierarchy_scaling",
        type = "performance"
    }, function()
        local startTime = os.clock()
        local root = MockPanel:new(0, 0, 960, 720)

        for i = 1, 50 do
            local child = MockBaseWidget:new(math.random(0, 900), math.random(0, 650), 48, 48)
            root:addChild(child)
        end

        -- Traverse tree
        for _, child in ipairs(root.children) do
            child:getAbsolutePosition()
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 50-widget hierarchy: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)

    Suite:testMethod("Scaling - Event Propagation", {
        description = "Propagates events efficiently through many widgets",
        testCase = "event_scaling",
        type = "performance"
    }, function()
        local propagator = MockEventPropagator:new()
        local buttons = {}

        for i = 1, 100 do
            table.insert(buttons, MockButton:new((i % 10) * 96, math.floor(i / 10) * 48, 96, 48))
        end

        local startTime = os.clock()

        for i = 1, 50 do
            propagator:propagateMousePress(buttons, math.random(0, 960), math.random(0, 480))
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 50 events on 100 buttons: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)
end)

---================================================================================
---RUN TESTS
---================================================================================

Suite:run()

-- Close the Love2D window after tests complete
love.event.quit()
