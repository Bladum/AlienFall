--- StatBar Widget
--- Displays a labeled stat bar with current/max values and colored fill.
---
--- Used for displaying unit stats like HP, EP, MP, AP, and Morale in the unit info panel.
--- Features a label, colored progress bar, and numeric values.
---
--- @class StatBar
--- @field label string The stat name (e.g., "HP", "EP")
--- @field current number Current stat value
--- @field max number Maximum stat value
--- @field color table RGB color table for the bar fill
--- @field x number X position in pixels
--- @field y number Y position in pixels
--- @field width number Width in pixels
--- @field height number Height in pixels
---
--- @usage
---   local hpBar = StatBar:new({
---     label = "HP",
---     current = 75,
---     max = 100,
---     color = {1, 0, 0},  -- Red for health
---     x = 24, y = 72,
---     width = 192, height = 24
---   })
---   hpBar:draw()

local BaseWidget = require("gui.widgets.core.base")

local StatBar = setmetatable({}, {__index = BaseWidget})
StatBar.__index = StatBar

--- Create a new StatBar widget.
---
--- @param options table Configuration options with fields: label, current, max, color, x, y, width, height
--- @return StatBar New StatBar instance
function StatBar:new(options)
    local self = BaseWidget.new(self, options)
    self.label = options.label or ""
    self.current = options.current or 0
    self.max = options.max or 100
    self.color = options.color or {0.5, 0.5, 0.5}
    return self
end

--- Update the stat bar values.
---
--- @param current number New current value
--- @param max number New maximum value (optional)
function StatBar:setValues(current, max)
    self.current = current
    if max then
        self.max = max
    end
end

--- Render the stat bar.
--- Draws the label, background bar, filled portion, and numeric values.
function StatBar:draw()
    if not self.visible then return end

    local theme = require("gui.widgets.theme")

    -- Background bar
    love.graphics.setColor(theme.colors.background)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Border
    love.graphics.setColor(theme.colors.border)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Filled portion
    local fillWidth = 0
    if self.max > 0 then
        fillWidth = (self.current / self.max) * (self.width - 4)
    end
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x + 2, self.y + 2, fillWidth, self.height - 4)

    -- Label
    love.graphics.setColor(theme.colors.text)
    love.graphics.setFont(theme.fonts.small)
    love.graphics.print(self.label, self.x + 4, self.y + 2)

    -- Values (right-aligned)
    local valueText = string.format("%d/%d", self.current, self.max)
    local textWidth = theme.fonts.small:getWidth(valueText)
    love.graphics.print(valueText, self.x + self.width - textWidth - 4, self.y + 2)
end

return StatBar

























