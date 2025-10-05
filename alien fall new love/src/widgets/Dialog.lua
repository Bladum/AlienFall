--- Dialog Widget
-- Modal dialog box for confirmations, messages, and simple input
--
-- @classmod widgets.Dialog

-- GROK: Dialog provides modal popup dialogs with buttons
-- GROK: Grid-aligned widget using 20px grid system centered on screen
-- GROK: Key methods: show(), hide(), draw(), addButton()
-- GROK: Used for confirmations, alerts, and simple user interactions

local class = require 'lib.Middleclass'
local Button = require 'widgets.Button'

--- Dialog class
-- @type Dialog
local Dialog = class('Dialog')

-- Constants
local GRID_SIZE = 20
local SCREEN_WIDTH = 800
local SCREEN_HEIGHT = 600

--- Create a new Dialog
-- @param title Dialog title
-- @param message Dialog message
-- @param options Optional configuration {width, height, buttons}
-- @return Dialog instance
function Dialog:initialize(title, message, options)
    self.title = title or "Dialog"
    self.message = message or ""
    
    options = options or {}
    self.width = options.width or (20 * GRID_SIZE) -- 400px
    self.height = options.height or (10 * GRID_SIZE) -- 200px
    
    -- Center on screen
    self.x = (SCREEN_WIDTH - self.width) / 2
    self.y = (SCREEN_HEIGHT - self.height) / 2
    
    self.visible = false
    self.buttons = {}
    self.callback = nil
    
    -- Colors
    self.bgColor = {0.1, 0.1, 0.15}
    self.overlayColor = {0, 0, 0, 0.7}
    self.borderColor = {0.5, 0.7, 1.0}
    self.titleColor = {1, 1, 1}
    self.messageColor = {0.9, 0.9, 0.9}
    
    -- Create default buttons if not provided
    if options.buttons then
        for _, btnDef in ipairs(options.buttons) do
            self:addButton(btnDef.text, btnDef.callback, btnDef.result)
        end
    else
        -- Default OK button
        self:addButton("OK", function() self:hide() end, true)
    end
end

--- Add a button to the dialog
-- @param text Button text
-- @param callback Button callback function
-- @param result Result value to pass to dialog callback
function Dialog:addButton(text, callback, result)
    local button = {
        text = text,
        callback = callback,
        result = result
    }
    table.insert(self.buttons, button)
    
    -- Recalculate button positions
    self:_layoutButtons()
end

--- Layout buttons at bottom of dialog
function Dialog:_layoutButtons()
    local buttonHeight = 2 * GRID_SIZE
    local buttonSpacing = GRID_SIZE
    local totalButtonWidth = 0
    
    -- Calculate total width needed
    for _, btn in ipairs(self.buttons) do
        local btnWidth = 6 * GRID_SIZE -- Default button width
        totalButtonWidth = totalButtonWidth + btnWidth + buttonSpacing
    end
    totalButtonWidth = totalButtonWidth - buttonSpacing -- Remove last spacing
    
    -- Position buttons centered at bottom
    local startX = self.x + (self.width - totalButtonWidth) / 2
    local btnY = self.y + self.height - buttonHeight - GRID_SIZE
    
    for i, btn in ipairs(self.buttons) do
        local btnWidth = 6 * GRID_SIZE
        local btnX = startX + (i - 1) * (btnWidth + buttonSpacing)
        
        btn.widget = Button:new(
            btnX, btnY,
            btnWidth, buttonHeight,
            btn.text,
            function()
                if btn.callback then
                    btn.callback()
                end
                if self.callback then
                    self.callback(btn.result)
                end
            end
        )
    end
end

--- Show the dialog
-- @param callback Optional callback when dialog closes with result
function Dialog:show(callback)
    self.visible = true
    self.callback = callback
end

--- Hide the dialog
function Dialog:hide()
    self.visible = false
end

--- Check if dialog is visible
-- @return boolean Visible state
function Dialog:isVisible()
    return self.visible
end

--- Update dialog
-- @param dt Delta time
function Dialog:update(dt)
    if not self.visible then return end
    
    for _, btn in ipairs(self.buttons) do
        if btn.widget and btn.widget.update then
            btn.widget:update(dt)
        end
    end
end

--- Draw dialog
function Dialog:draw()
    if not self.visible then return end
    
    -- Draw overlay
    love.graphics.setColor(self.overlayColor)
    love.graphics.rectangle('fill', 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- Draw dialog background
    love.graphics.setColor(self.bgColor)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    
    -- Draw title bar
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle('fill', self.x, self.y, self.width, 2 * GRID_SIZE)
    love.graphics.setColor(self.borderColor)
    love.graphics.line(self.x, self.y + 2 * GRID_SIZE, self.x + self.width, self.y + 2 * GRID_SIZE)
    
    -- Draw title text
    love.graphics.setColor(self.titleColor)
    love.graphics.print(self.title, self.x + GRID_SIZE, self.y + 8)
    
    -- Draw message
    love.graphics.setColor(self.messageColor)
    local messageY = self.y + 3 * GRID_SIZE
    local messageX = self.x + GRID_SIZE
    local messageWidth = self.width - 2 * GRID_SIZE
    
    -- Word wrap message
    local font = love.graphics.getFont()
    local _, wrappedText = font:getWrap(self.message, messageWidth)
    
    for _, line in ipairs(wrappedText) do
        love.graphics.print(line, messageX, messageY)
        messageY = messageY + font:getHeight() + 4
    end
    
    -- Draw buttons
    for _, btn in ipairs(self.buttons) do
        if btn.widget then
            btn.widget:draw()
        end
    end
end

--- Handle mouse press
-- @param mx Mouse X
-- @param my Mouse Y
-- @param button Mouse button
-- @return boolean Handled
function Dialog:mousepressed(mx, my, button)
    if not self.visible then return false end
    
    -- Check buttons
    for _, btn in ipairs(self.buttons) do
        if btn.widget and btn.widget:mousepressed(mx, my, button) then
            return true
        end
    end
    
    -- Block clicks outside dialog
    return true
end

--- Handle key press
-- @param key Key name
-- @return boolean Handled
function Dialog:keypressed(key)
    if not self.visible then return false end
    
    if key == 'return' or key == 'space' then
        -- Trigger first button (typically OK/Yes)
        if self.buttons[1] and self.buttons[1].widget then
            self.buttons[1].widget.onClick()
            return true
        end
    elseif key == 'escape' then
        -- Trigger last button (typically Cancel/No)
        local lastBtn = self.buttons[#self.buttons]
        if lastBtn and lastBtn.widget then
            lastBtn.widget.onClick()
            return true
        end
    end
    
    return true -- Block all keys when dialog is visible
end

--- Create a confirmation dialog
-- @param title Title text
-- @param message Message text
-- @param callback Callback with true/false result
-- @return Dialog instance
function Dialog.confirm(title, message, callback)
    return Dialog:new(title, message, {
        buttons = {
            {text = "Yes", callback = function() end, result = true},
            {text = "No", callback = function() end, result = false}
        }
    }):show(callback)
end

--- Create an alert dialog
-- @param title Title text
-- @param message Message text
-- @param callback Optional callback when closed
-- @return Dialog instance
function Dialog.alert(title, message, callback)
    return Dialog:new(title, message, {
        buttons = {
            {text = "OK", callback = function() end, result = true}
        }
    }):show(callback)
end

return Dialog
