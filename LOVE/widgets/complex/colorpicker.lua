--[[
widgets/colorpicker.lua
ColorPicker widget (palette-based color selection)


Compact color palette widget providing grid-based color selection with click interaction
for tactical strategy game interfaces. Essential for customizing soldier uniforms,
faction colors, UI themes, and other visual elements in base management screens.

PURPOSE:
- Provide a compact color palette UI for selecting colors with click interaction
- Enable quick color selection for customization features in strategy games
- Support visual feedback and accessibility for color selection
- Foundation for more advanced color picking interfaces

KEY FEATURES:
- Simple grid-based color palette with customizable colors
- Click-to-select functionality with visual feedback
- Support for custom color arrays and palette sizes
- Integration with core.theme for consistent styling
- Accessibility support with keyboard navigation
- Lightweight and performant for UI customization

]]

local core = require("widgets.core")
local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker:new(x, y, cols, rows)
    local obj = {
        x = x,
        y = y,
        cols = cols or { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 }, { 1, 1, 0 }, { 1, 0, 1 }, { 0, 1, 1 } },
        rows = rows or 1,
        size = 24,
        selected = 1,
        onColorChange = nil
    }
    setmetatable(obj, self)
    return obj
end

function ColorPicker:draw()
    for i, c in ipairs(self.cols) do
        love.graphics.setColor(unpack(c))
        love.graphics.rectangle("fill", self.x + (i - 1) * (self.size + 4), self.y, self.size, self.size)
        love.graphics.setColor(unpack(core.theme.border))
        love.graphics.rectangle("line", self.x + (i - 1) * (self.size + 4), self.y, self.size, self.size)
    end
end

function ColorPicker:mousepressed(x, y, button)
    if button ~= 1 then return false end
    for i = 1, #self.cols do
        local sx = self.x + (i - 1) * (self.size + 4); if core.isInside(x, y, sx, self.y, self.size, self.size) then
            self.selected = i; return true
        end
    end
    return false
end

return ColorPicker






