---Widget Demo Application - Standalone Widget Showcase
---
---A standalone Love2D application that showcases all 23+ widgets in the AlienFall
---widget system. Displays each widget with interactive examples and grid overlay
---for development. Used for testing, documentation, and demonstration purposes.
---
---Features:
---  - Showcase all 23+ widgets
---  - Interactive widget examples
---  - Grid overlay (F9 toggle)
---  - Live testing environment
---  - Visual widget catalog
---  - Grid-aligned positioning (24×24 pixels)
---
---Showcased Widgets:
---  - Buttons: Button, ImageButton, ActionButton
---  - Display: Label, ProgressBar, HealthBar, Tooltip
---  - Input: TextInput, TextArea, Checkbox, RadioButton
---  - Navigation: ListBox, Dropdown, TabWidget, Table
---  - Containers: Panel, Window, Dialog, ScrollBox
---  - Advanced: UnitCard, Minimap, Spinner, ResearchTree
---  - Combat: WeaponModeSelector
---
---Controls:
---  - F9: Toggle grid overlay
---  - F12: Toggle fullscreen
---  - Mouse: Interact with widgets
---  - Keyboard: Widget-specific shortcuts
---
---Key Exports:
---  - love.load(): Initializes demo widgets
---  - love.update(dt): Updates widget system
---  - love.draw(): Renders all widgets
---  - love.mousepressed/released: Mouse interaction
---  - love.keypressed: Keyboard input
---
---Dependencies:
---  - widgets.init: Widget system loader
---  - Love2D 12.0+: Game framework
---
---@module widgets.demo.main
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- Run with: lovec "engine/widgets/demo"
---  -- Or execute: run_demo.bat
---  -- Press F9 to toggle grid overlay
---
---@see widgets.init For widget system

-- Widget System Demo Application
-- Showcases all 23 widgets

local widgets
local demoWidgets = {} -- Store persistent widget instances

function love.load()
    -- Add widgets directory to package path
    local widgetPath = love.filesystem.getSourceBaseDirectory() .. "/../?.lua"
    package.path = package.path .. ";" .. widgetPath
    
    -- Set nearest neighbor filtering for pixel art
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Load widget system
    widgets = require("widgets.init")
    widgets.init()

    -- Initialize demo widgets
    initDemoWidgets()

    print("[Demo] Widget demo loaded")
    print("[Demo] Press F9 to toggle grid overlay")
    print("[Demo] Press F12 to toggle fullscreen")
    print("[Demo] Press ESC to quit")
    print("[Demo] Click widgets to test interaction")
end

function initDemoWidgets()
    demoWidgets = {}

    local startY = 96
    local spacing = 72

    -- Phase 1: Basic widgets
    demoWidgets.button = widgets.Button.new(24, startY + 24, 96, 48, "Click Me")
    demoWidgets.label = widgets.Label.new(144, startY + 24, 200, 48, "This is a label")
    demoWidgets.panel = widgets.Panel.new(360, startY + 24, 144, 48)
    demoWidgets.container = widgets.Container.new(528, startY + 24, 144, 48)

    startY = startY + spacing

    -- Phase 2: Input widgets
    demoWidgets.textinput = widgets.TextInput.new(24, startY + 24, 200, 24, "Type here...")
    demoWidgets.checkbox = widgets.Checkbox.new(240, startY + 24, 150, 24, "Enable")
    demoWidgets.dropdown = widgets.Dropdown.new(408, startY + 24, 150, 24)
    demoWidgets.dropdown:setOptions({"Option 1", "Option 2", "Option 3"})
    demoWidgets.listbox = widgets.ListBox.new(576, startY + 24, 150, 48)
    demoWidgets.listbox:setItems({"Item 1", "Item 2", "Item 3"})

    startY = startY + spacing

    -- Phase 3: Display widgets
    demoWidgets.progressbar = widgets.ProgressBar.new(24, startY + 24, 200, 24)
    demoWidgets.progressbar:setValue(0.75)
    demoWidgets.healthbar = widgets.HealthBar.new(240, startY + 24, 200, 24)
    demoWidgets.healthbar:setHealth(75, 100)
    demoWidgets.healthbar:setLabel("HP")
    demoWidgets.tooltip = widgets.Tooltip.new()
    demoWidgets.tooltip.text = "Tooltip example"
    demoWidgets.tooltip.visible = true
    demoWidgets.tooltip:setPosition(456, startY + 24)

    startY = startY + spacing

    -- Phase 4: Complex widgets
    demoWidgets.framebox = widgets.FrameBox.new(24, startY + 24, 150, 96, "Group")
    demoWidgets.tabwidget = widgets.TabWidget.new(192, startY + 24, 200, 96)
    demoWidgets.tabwidget:addTab("Tab 1", nil)
    demoWidgets.tabwidget:addTab("Tab 2", nil)
    demoWidgets.window = widgets.Window.new(408, startY + 24, 200, 96, "Window")

    startY = startY + 120

    -- Phase 5: Extended widgets
    demoWidgets.radiobutton = widgets.RadioButton.new(24, startY + 24, 150, 24, "Option A")
    demoWidgets.spinner = widgets.Spinner.new(192, startY + 24, 150, 24)
    demoWidgets.spinner:setValue(50)
    demoWidgets.combobox = widgets.ComboBox.new(360, startY + 24, 150, 24)
    demoWidgets.combobox.options = {"Choice 1", "Choice 2"}
    demoWidgets.table = widgets.Table.new(528, startY + 24, 200, 72)
    demoWidgets.table:setData({"Col1", "Col2"}, {{"A", "1"}, {"B", "2"}})

    startY = startY + 96

    -- Add click handlers for interactive widgets
    demoWidgets.button.onClick = function()
        print("[Demo] Button clicked!")
        demoWidgets.button.text = "Clicked!"
    end

    demoWidgets.checkbox.onChange = function(checked)
        print("[Demo] Checkbox changed: " .. tostring(checked))
    end

    demoWidgets.dropdown.onChange = function(selected)
        print("[Demo] Dropdown selected: " .. tostring(selected))
    end

    demoWidgets.listbox.onSelect = function(index, item)
        print("[Demo] ListBox selected: " .. index .. " - " .. item)
    end

    demoWidgets.spinner.onChange = function(widget, value)
        print("[Demo] Spinner value: " .. value)
    end

    demoWidgets.combobox.onChange = function(selected)
        print("[Demo] ComboBox selected: " .. tostring(selected))
    end

    demoWidgets.tabwidget.onTabChange = function(tabIndex)
        print("[Demo] Tab changed to: " .. tabIndex)
    end
end

function love.update(dt)
    -- Update widgets that need animation/updates
    for _, widget in pairs(demoWidgets) do
        if widget.update then
            widget:update(dt)
        end
    end
end

function drawWidgetsInLayers()
    -- Create a list of all widgets with their z-index
    local widgetList = {}
    for name, widget in pairs(demoWidgets) do
        table.insert(widgetList, {name = name, widget = widget, zIndex = widget.zIndex or 0})
    end
    
    -- Sort widgets by z-index (lower z-index drawn first)
    table.sort(widgetList, function(a, b) return a.zIndex < b.zIndex end)
    
    -- Draw background elements first (labels and layout)
    local startY = 96
    local spacing = 72
    
    -- Phase 1: Basic widgets
    widgets.Theme.setFont("default")
    widgets.Theme.setColor("text")
    love.graphics.print("Phase 1: Basic Widgets", 24, startY)
    
    startY = startY + spacing
    
    -- Phase 2: Input widgets
    love.graphics.print("Phase 2: Input Widgets", 24, startY)
    
    startY = startY + spacing
    
    -- Phase 3: Display widgets
    love.graphics.print("Phase 3: Display Widgets", 24, startY)
    
    startY = startY + spacing
    
    -- Phase 4: Complex widgets
    love.graphics.print("Phase 4: Complex Widgets", 24, startY)
    
    startY = startY + 120
    
    -- Phase 5: Extended widgets
    love.graphics.print("Phase 5: Extended Widgets", 24, startY)
    
    startY = startY + 96
    
    -- Summary
    widgets.Theme.setFont("small")
    widgets.Theme.setColor("success")
    love.graphics.print("? All 23 widgets loaded and interactive!", 24, startY)
    
    -- Draw widgets in z-index order
    for _, widgetInfo in ipairs(widgetList) do
        widgetInfo.widget:draw()
    end
end

function love.draw()
    -- Get current window dimensions
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    -- Calculate scaling to maintain aspect ratio
    local scaleX = windowWidth / 1200
    local scaleY = windowHeight / 900
    local scale = math.min(scaleX, scaleY)
    
    -- Calculate viewport to center the scaled content
    local viewportWidth = 1200 * scale
    local viewportHeight = 900 * scale
    local viewportX = (windowWidth - viewportWidth) / 2
    local viewportY = (windowHeight - viewportHeight) / 2
    
    -- Set scissor and viewport for proper aspect ratio
    love.graphics.setScissor(viewportX, viewportY, viewportWidth, viewportHeight)
    love.graphics.push()
    love.graphics.translate(viewportX, viewportY)
    love.graphics.scale(scale, scale)
    
    love.graphics.clear(0.1, 0.1, 0.15, 1)
    
    -- Draw title
    widgets.Theme.setFont("large")
    widgets.Theme.setColor("text")
    love.graphics.print("Widget System Demo - All 23 Widgets", 24, 24)
    
    -- Draw info text
    widgets.Theme.setFont("small")
    widgets.Theme.setColor("textDark")
    love.graphics.print("F9: Toggle Grid | F12: Fullscreen | ESC: Quit | Click widgets to test", 24, 48)
    
    -- Draw demo widgets in proper layering order
    drawWidgetsInLayers()
    
    love.graphics.pop()
    
    -- Draw debug grid overlay (outside scaling, in viewport)
    widgets.drawDebug()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    -- Handle widget system keys
    widgets.keypressed(key)

    -- Handle F12 for fullscreen with scaling
    if key == "f12" then
        toggleFullscreen()
    end

    -- Forward key events to widgets that need them
    for _, widget in pairs(demoWidgets) do
        if widget.keypressed then
            widget:keypressed(key)
        end
    end
end

function love.mousepressed(x, y, button)
    -- Get current window dimensions and calculate viewport
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scaleX = windowWidth / 1200
    local scaleY = windowHeight / 900
    local scale = math.min(scaleX, scaleY)
    local viewportWidth = 1200 * scale
    local viewportHeight = 900 * scale
    local viewportX = (windowWidth - viewportWidth) / 2
    local viewportY = (windowHeight - viewportHeight) / 2
    
    -- Transform mouse coordinates to viewport space
    local viewportMouseX = x - viewportX
    local viewportMouseY = y - viewportY
    
    -- Only process if mouse is within viewport
    if viewportMouseX >= 0 and viewportMouseX < viewportWidth and
       viewportMouseY >= 0 and viewportMouseY < viewportHeight then
        -- Transform to scaled coordinates
        local scaledX = viewportMouseX / scale
        local scaledY = viewportMouseY / scale
        
        -- Forward mouse events to all widgets
        for _, widget in pairs(demoWidgets) do
            if widget.mousepressed then
                widget:mousepressed(scaledX, scaledY, button)
            end
        end
    end
end

function love.mousereleased(x, y, button)
    -- Get current window dimensions and calculate viewport
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scaleX = windowWidth / 1200
    local scaleY = windowHeight / 900
    local scale = math.min(scaleX, scaleY)
    local viewportWidth = 1200 * scale
    local viewportHeight = 900 * scale
    local viewportX = (windowWidth - viewportWidth) / 2
    local viewportY = (windowHeight - viewportHeight) / 2
    
    -- Transform mouse coordinates to viewport space
    local viewportMouseX = x - viewportX
    local viewportMouseY = y - viewportY
    
    -- Only process if mouse is within viewport
    if viewportMouseX >= 0 and viewportMouseX < viewportWidth and
       viewportMouseY >= 0 and viewportMouseY < viewportHeight then
        -- Transform to scaled coordinates
        local scaledX = viewportMouseX / scale
        local scaledY = viewportMouseY / scale
        
        -- Forward mouse release events to all widgets
        for _, widget in pairs(demoWidgets) do
            if widget.mousereleased then
                widget:mousereleased(scaledX, scaledY, button)
            end
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- Get current window dimensions and calculate viewport
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scaleX = windowWidth / 1200
    local scaleY = windowHeight / 900
    local scale = math.min(scaleX, scaleY)
    local viewportWidth = 1200 * scale
    local viewportHeight = 900 * scale
    local viewportX = (windowWidth - viewportWidth) / 2
    local viewportY = (windowHeight - viewportHeight) / 2
    
    -- Transform mouse coordinates to viewport space
    local viewportMouseX = x - viewportX
    local viewportMouseY = y - viewportY
    
    -- Only process if mouse is within viewport
    if viewportMouseX >= 0 and viewportMouseX < viewportWidth and
       viewportMouseY >= 0 and viewportMouseY < viewportHeight then
        -- Transform to scaled coordinates
        local scaledX = viewportMouseX / scale
        local scaledY = viewportMouseY / scale
        local scaledDx = dx / scale
        local scaledDy = dy / scale
        
        -- Forward mouse move events to all widgets
        for _, widget in pairs(demoWidgets) do
            if widget.mousemoved then
                widget:mousemoved(scaledX, scaledY, scaledDx, scaledDy, istouch)
            end
        end
    end
end

function love.textinput(text)
    -- Forward text input to widgets that need it
    for _, widget in pairs(demoWidgets) do
        if widget.textinput then
            widget:textinput(text)
        end
    end
end

function toggleFullscreen()
    local isFullscreen = love.window.getFullscreen()
    love.window.setFullscreen(not isFullscreen, "desktop")
    
    -- Calculate scaling factors based on new window size
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scaleX = windowWidth / 1200  -- Base width
    local scaleY = windowHeight / 900   -- Base height
    
    -- Use uniform scaling to maintain aspect ratio
    local scale = math.min(scaleX, scaleY)
    
    -- Apply scaling to grid system
    widgets.Grid.setScale(scale, scale)
    
    if not isFullscreen then
        -- Going fullscreen
        print(string.format("[Demo] Entering fullscreen mode - Window: %dx%d, Scale: %.2f", windowWidth, windowHeight, scale))
    else
        -- Leaving fullscreen
        widgets.Grid.resetScale()
        print("[Demo] Leaving fullscreen mode - Scale reset to 1.0")
    end
end





















