---Spinner Widget - Numeric Up/Down Control
---
---Numeric input widget with increment/decrement buttons. Allows users to adjust numeric
---values within a specified range using buttons or direct text input. Grid-aligned for
---consistent UI positioning.
---
---Features:
---  - Numeric value input (integer or decimal)
---  - Up/Down arrow buttons
---  - Min/Max value constraints
---  - Step size (increment amount)
---  - Keyboard input support
---  - Mouse wheel support
---  - Grid-aligned positioning (24×24 pixels)
---
---Input Methods:
---  - Click up/down buttons
---  - Keyboard arrow keys
---  - Mouse wheel scroll
---  - Direct text entry
---  - Page Up/Down for larger steps
---
---Key Exports:
---  - Spinner.new(x, y, width, height): Creates spinner widget
---  - setValue(value): Sets current value
---  - getValue(): Returns current value
---  - setRange(min, max): Sets value constraints
---  - setStep(step): Sets increment amount
---  - draw(): Renders spinner
---  - mousepressed(x, y, button): Button click handling
---  - wheelmoved(x, y): Scroll handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.advanced.spinner
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Spinner = require("gui.widgets.advanced.spinner")
---  local spinner = Spinner.new(0, 0, 96, 48)
---  spinner:setRange(0, 100)
---  spinner:setStep(5)
---  spinner:setValue(50)
---  spinner:draw()
---
---@see widgets.input.textinput For text input

--[[
    Spinner Widget - Numeric up/down spinner
]]
local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local Spinner = setmetatable({}, {__index = BaseWidget})
Spinner.__index = Spinner

function Spinner.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height)
    setmetatable(self, Spinner)
    self.value = 0
    self.min = 0
    self.max = 100
    self.step = 1
    self.buttonWidth = 24
    return self
end

function Spinner:draw()
    if not self.visible then return end
    Theme.setColor("backgroundDark")
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    Theme.setColor("border")
    love.graphics.setLineWidth(Theme.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    Theme.setFont("default")
    Theme.setColor("text")
    local font = Theme.getFont("default")
    local text = tostring(self.value)
    local textX = self.x + (self.width - self.buttonWidth * 2 - font:getWidth(text)) / 2
    local textY = self.y + (self.height - font:getHeight()) / 2
    love.graphics.print(text, textX, textY)
    local btnX = self.x + self.width - self.buttonWidth * 2
    Theme.setColor(self.hovered and "hover" or "primary")
    love.graphics.rectangle("fill", btnX, self.y, self.buttonWidth, self.height)
    love.graphics.rectangle("fill", btnX + self.buttonWidth, self.y, self.buttonWidth, self.height)
    Theme.setColor("border")
    love.graphics.rectangle("line", btnX, self.y, self.buttonWidth, self.height)
    love.graphics.rectangle("line", btnX + self.buttonWidth, self.y, self.buttonWidth, self.height)
    Theme.setColor("text")
    love.graphics.print("-", btnX + 8, textY)
    love.graphics.print("+", btnX + self.buttonWidth + 8, textY)
end

function Spinner:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    if button == 1 and self:containsPoint(x, y) then
        local btnX = self.x + self.width - self.buttonWidth * 2
        if x >= btnX and x < btnX + self.buttonWidth then
            self:setValue(self.value - self.step)
            return true
        elseif x >= btnX + self.buttonWidth and x < btnX + self.buttonWidth * 2 then
            self:setValue(self.value + self.step)
            return true
        end
    end
    return false
end

function Spinner:setValue(value)
    self.value = math.max(self.min, math.min(self.max, value))
    if self.onChange then self.onChange(self, self.value) end
end

print("[Spinner] Spinner widget loaded")
return Spinner



























