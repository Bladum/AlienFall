--- Widget Showcase Module
--- Demonstrates all available widgets in the system.
---
--- Provides an interactive gallery of UI components with examples
--- of their usage, properties, and visual appearance.
---
--- @class WidgetShowcase
--- @field widgets table Array of demo widgets
--- @field title string Showcase title
--- @field currentDemo string Currently selected demo
---
--- @usage
---   local WidgetShowcase = require("modules.widget_showcase")
---   WidgetShowcase:enter()  -- Initialize showcase
---   WidgetShowcase:draw()   -- Render widget gallery

-- Widget Showcase State
-- Demonstrates all available widgets in the system

local StateManager = require("systems.state_manager")
local Widgets = require("widgets.init")

local WidgetShowcase = {}

function WidgetShowcase:enter()
    print("[WidgetShowcase] Entering widget showcase state")
    
    -- Window dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    self.title = "WIDGET SHOWCASE"
    self.widgets = {}
    
    -- Layout parameters (grid-aligned)
    local col1X = 48    -- 2 grid cells from left
    local col2X = 504   -- 21 grid cells from left
    local startY = 120  -- 5 grid cells from top
    local rowSpacing = 72
    local currentRow = 0
    
    -- Column 1: Basic Widgets
    
    -- Button
    table.insert(self.widgets, {
        name = "Button",
        widget = Widgets.Button.new(col1X, startY + rowSpacing * currentRow, 192, 48, "Click Me", function()
            print("[Showcase] Button clicked!")
        end)
    })
    
    -- Label
    currentRow = currentRow + 1
    table.insert(self.widgets, {
        name = "Label",
        widget = Widgets.Label.new(col1X, startY + rowSpacing * currentRow, "This is a label")
    })
    
    -- TextInput
    currentRow = currentRow + 1
    table.insert(self.widgets, {
        name = "TextInput",
        widget = Widgets.TextInput.new(col1X, startY + rowSpacing * currentRow, 288, 48, "Enter text here")
    })
    
    -- Checkbox
    currentRow = currentRow + 1
    local checkbox = Widgets.Checkbox.new(col1X, startY + rowSpacing * currentRow, "Enable Option")
    table.insert(self.widgets, {
        name = "Checkbox",
        widget = checkbox
    })
    
    -- ProgressBar
    currentRow = currentRow + 1
    local progressBar = Widgets.ProgressBar.new(col1X, startY + rowSpacing * currentRow, 288, 24)
    progressBar:setValue(0.65)
    table.insert(self.widgets, {
        name = "ProgressBar",
        widget = progressBar
    })
    
    -- HealthBar
    currentRow = currentRow + 1
    local healthBar = Widgets.HealthBar.new(col1X, startY + rowSpacing * currentRow, 288, 24)
    healthBar:setValue(75, 100)
    table.insert(self.widgets, {
        name = "HealthBar",
        widget = healthBar
    })
    
    -- Column 2: Advanced Widgets
    currentRow = 0
    
    -- Dropdown
    local dropdown = Widgets.Dropdown.new(col2X, startY + rowSpacing * currentRow, 240, 48)
    dropdown:setItems({"Option 1", "Option 2", "Option 3", "Option 4"})
    dropdown:setSelected(1)
    table.insert(self.widgets, {
        name = "Dropdown",
        widget = dropdown
    })
    
    -- ListBox
    currentRow = currentRow + 1
    local listbox = Widgets.ListBox.new(col2X, startY + rowSpacing * currentRow, 240, 192)
    listbox:setItems({"Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"})
    table.insert(self.widgets, {
        name = "ListBox",
        widget = listbox
    })
    
    -- RadioButton Group
    currentRow = currentRow + 4
    local radioGroup = "showcase_group"
    local radio1 = Widgets.RadioButton.new(col2X, startY + rowSpacing * currentRow, "Option A", radioGroup)
    radio1:setChecked(true)
    table.insert(self.widgets, {
        name = "RadioButton 1",
        widget = radio1
    })
    
    currentRow = currentRow + 0.5
    local radio2 = Widgets.RadioButton.new(col2X, startY + rowSpacing * currentRow, "Option B", radioGroup)
    table.insert(self.widgets, {
        name = "RadioButton 2",
        widget = radio2
    })
    
    currentRow = currentRow + 0.5
    local radio3 = Widgets.RadioButton.new(col2X, startY + rowSpacing * currentRow, "Option C", radioGroup)
    table.insert(self.widgets, {
        name = "RadioButton 3",
        widget = radio3
    })
    
    -- Back button
    self.backButton = Widgets.Button.new(
        windowWidth - 240,
        windowHeight - 72,
        192,
        48,
        "BACK"
    )
    self.backButton.onClick = function()
        StateManager.switch("tests_menu")
    end
    
    -- Animation for progress bar
    self.progressAnimation = 0
end

function WidgetShowcase:exit()
    print("[WidgetShowcase] Exiting widget showcase state")
end

function WidgetShowcase:update(dt)
    -- Animate progress bar
    self.progressAnimation = self.progressAnimation + dt * 0.3
    if self.progressAnimation > 1 then
        self.progressAnimation = 0
    end
    
    -- Update progress bar widget
    for _, item in ipairs(self.widgets) do
        if item.name == "ProgressBar" then
            item.widget:setValue(self.progressAnimation)
        end
    end
    
    -- Update all widgets
    for _, item in ipairs(self.widgets) do
        if item.widget.update then
            item.widget:update(dt)
        end
    end
    
    self.backButton:update(dt)
end

function WidgetShowcase:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Clear background
    love.graphics.clear(0.1, 0.1, 0.15)
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf(self.title, 0, 40, windowWidth, "center")
    
    -- Draw column headers
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Basic Widgets", 48, 90)
    love.graphics.print("Advanced Widgets", 504, 90)
    
    -- Draw all widgets with labels
    love.graphics.setFont(love.graphics.newFont(12))
    for _, item in ipairs(self.widgets) do
        -- Draw widget name above widget
        love.graphics.setColor(0.6, 0.6, 0.6)
        local nameY = item.widget.y - 18
        love.graphics.print(item.name, item.widget.x, nameY)
        
        -- Draw widget
        love.graphics.setColor(1, 1, 1)
        item.widget:draw()
    end
    
    -- Draw back button
    self.backButton:draw()
    
    -- Draw instructions
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Press ESC to return to Tests Menu", 0, windowHeight - 30, windowWidth, "center")
end

function WidgetShowcase:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        StateManager.switch("tests_menu")
    end
    
    -- Pass to widgets
    for _, item in ipairs(self.widgets) do
        if item.widget.keypressed then
            item.widget:keypressed(key, scancode, isrepeat)
        end
    end
end

function WidgetShowcase:textinput(text)
    -- Pass to widgets
    for _, item in ipairs(self.widgets) do
        if item.widget.textinput then
            item.widget:textinput(text)
        end
    end
end

function WidgetShowcase:mousepressed(x, y, button, istouch, presses)
    -- Pass to back button
    self.backButton:mousepressed(x, y, button)
    
    -- Pass to widgets
    for _, item in ipairs(self.widgets) do
        if item.widget.mousepressed then
            item.widget:mousepressed(x, y, button)
        end
    end
end

function WidgetShowcase:mousereleased(x, y, button, istouch, presses)
    -- Pass to back button
    self.backButton:mousereleased(x, y, button)
    
    -- Pass to widgets
    for _, item in ipairs(self.widgets) do
        if item.widget.mousereleased then
            item.widget:mousereleased(x, y, button, istouch, presses)
        end
    end
end

function WidgetShowcase:mousemoved(x, y, dx, dy, istouch)
    -- Pass to widgets
    for _, item in ipairs(self.widgets) do
        if item.widget.mousemoved then
            item.widget:mousemoved(x, y, dx, dy, istouch)
        end
    end
end

return WidgetShowcase
