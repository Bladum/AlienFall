--[[
    Spinner Widget - Numeric up/down spinner
]]
local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

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
