--[[
    Panel Widget
    
    A simple rectangular background panel.
    Features:
    - Colored background
    - Optional border
    - Can contain child widgets
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

local Panel = setmetatable({}, {__index = BaseWidget})
Panel.__index = Panel

--[[
    Create a new panel
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New panel instance
]]
function Panel.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height)
    setmetatable(self, Panel)
    
    self.backgroundColor = "backgroundLight"
    self.borderColor = "border"
    self.showBorder = true
    
    return self
end

--[[
    Draw the panel
]]
function Panel:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    if self.showBorder then
        Theme.setColor(self.borderColor)
        love.graphics.setLineWidth(Theme.borderWidth)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end
    
    -- Draw children
    for _, child in ipairs(self.children) do
        child:draw()
    end
end

--[[
    Set background color
    @param colorName string - Color name from theme
]]
function Panel:setBackgroundColor(colorName)
    self.backgroundColor = colorName
end

--[[
    Set border color
    @param colorName string - Color name from theme
]]
function Panel:setBorderColor(colorName)
    self.borderColor = colorName
end

--[[
    Show or hide border
    @param show boolean - True to show border
]]
function Panel:setBorder(show)
    self.showBorder = show
end

print("[Panel] Panel widget loaded")

return Panel
