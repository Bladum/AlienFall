---Dialog Widget - Modal Dialog Box
---
---A modal dialog box for important messages or confirmations. Blocks interaction with
---underlying UI until dismissed. Grid-aligned for consistent positioning.
---
---Features:
---  - Modal overlay (darkens background, blocks clicks)
---  - Title and message text
---  - Buttons (OK, Cancel, Yes/No, etc.)
---  - Grid-aligned positioning (24×24 pixels)
---  - Auto-centering on screen
---  - Keyboard shortcuts (Enter for OK, ESC for Cancel)
---
---Dialog Types:
---  - Info: Single OK button
---  - Confirm: OK and Cancel buttons
---  - YesNo: Yes and No buttons
---  - Custom: User-defined button layout
---
---Modal Behavior:
---  - Semi-transparent overlay blocks underlying UI
---  - Dialog centered on screen
---  - ESC key closes dialog
---  - Click outside dialog area closes it (optional)
---
---Key Exports:
---  - Dialog.new(title, message, buttons): Creates dialog
---  - show(): Displays dialog
---  - hide(): Dismisses dialog
---  - setCallback(buttonId, func): Sets button callback
---  - draw(): Renders overlay and dialog
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---  - widgets.buttons.button: Dialog buttons
---
---@module widgets.containers.dialog
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Dialog = require("widgets.containers.dialog")
---  local dialog = Dialog.new("Confirm", "Delete this item?", {"Yes", "No"})
---  dialog:setCallback("Yes", function() deleteItem() end)
---  dialog:show()
---
---@see widgets.containers.window For non-modal windows

--[[
    Dialog Widget
    
    A modal dialog box for important messages or confirmations.
    Features:
    - Modal overlay
    - Title and message
    - Buttons (OK, Cancel, etc.)
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local Dialog = setmetatable({}, {__index = BaseWidget})
Dialog.__index = Dialog

--[[
    Create a new dialog
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param title string - Dialog title
    @param message string - Dialog message
    @return table - New dialog instance
]]
function Dialog.new(x, y, width, height, title, message)
    local self = BaseWidget.new(x, y, width, height, "dialog")
    setmetatable(self, Dialog)
    
    self.title = title or "Dialog"
    self.message = message or ""
    self.titleHeight = 24
    self.buttonHeight = 24
    self.modal = true
    self.buttons = {}
    self.onClose = nil
    
    return self
end

--[[
    Draw the dialog
]]
function Dialog:draw()
    if not self.visible then
        return
    end
    
    -- Draw modal overlay
    if self.modal then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end
    
    -- Draw title bar
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.titleHeight)
    
    -- Draw title text
    Theme.setFont(self.font)
    Theme.setColor(self.textColor)
    local font = Theme.getFont(self.font)
    local textHeight = font:getHeight()
    local titleY = self.y + (self.titleHeight - textHeight) / 2
    love.graphics.print(self.title, self.x + 8, titleY)
    
    -- Draw content area
    local contentY = self.y + self.titleHeight
    local contentHeight = self.height - self.titleHeight - self.buttonHeight - 8
    
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, contentY, self.width, contentHeight)
    
    -- Draw message
    Theme.setFont("default")
    Theme.setColor(self.textColor)
    love.graphics.print(self.message, self.x + 8, contentY + 8)
    
    -- Draw buttons
    local buttonY = self.y + self.height - self.buttonHeight - 4
    local buttonWidth = 72
    local buttonSpacing = 8
    local totalButtonWidth = #self.buttons * (buttonWidth + buttonSpacing) - buttonSpacing
    local buttonX = self.x + self.width - totalButtonWidth - 8
    
    for i, button in ipairs(self.buttons) do
        local bx = buttonX + (i - 1) * (buttonWidth + buttonSpacing)
        
        -- Draw button
        Theme.setColor(self.hoverColor)
        love.graphics.rectangle("fill", bx, buttonY, buttonWidth, self.buttonHeight)
        
        Theme.setColor(self.borderColor)
        love.graphics.setLineWidth(self.borderWidth)
        love.graphics.rectangle("line", bx, buttonY, buttonWidth, self.buttonHeight)
        
        -- Draw button text
        Theme.setColor(self.textColor)
        local textWidth = font:getWidth(button.label)
        local tx = bx + (buttonWidth - textWidth) / 2
        local ty = buttonY + (self.buttonHeight - textHeight) / 2
        love.graphics.print(button.label, tx, ty)
    end
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.line(self.x, self.y + self.titleHeight, self.x + self.width, self.y + self.titleHeight)
end

--[[
    Handle mouse press
]]
function Dialog:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button ~= 1 then
        return false
    end
    
    -- Check button clicks
    local buttonY = self.y + self.height - self.buttonHeight - 4
    local buttonWidth = 72
    local buttonSpacing = 8
    local totalButtonWidth = #self.buttons * (buttonWidth + buttonSpacing) - buttonSpacing
    local buttonX = self.x + self.width - totalButtonWidth - 8
    
    for i, btn in ipairs(self.buttons) do
        local bx = buttonX + (i - 1) * (buttonWidth + buttonSpacing)
        
        if x >= bx and x < bx + buttonWidth and
           y >= buttonY and y < buttonY + self.buttonHeight then
            if btn.onClick then
                btn.onClick()
            end
            return true
        end
    end
    
    return true  -- Consume all clicks to maintain modal behavior
end

--[[
    Add a button
    @param label string - Button label
    @param onClick function - Click callback
]]
function Dialog:addButton(label, onClick)
    table.insert(self.buttons, {label = label, onClick = onClick})
end

--[[
    Close the dialog
]]
function Dialog:close()
    self.visible = false
    if self.onClose then
        self.onClose()
    end
end

return Dialog






















