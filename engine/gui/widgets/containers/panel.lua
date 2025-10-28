---Panel Widget - Simple Background Container
---
---A simple rectangular background panel for grouping widgets. Provides colored background
---and optional border. Can contain child widgets. Grid-aligned for consistent positioning.
---
---Features:
---  - Colored background
---  - Optional border
---  - Can contain child widgets
---  - Grid-aligned positioning (24×24 pixels)
---  - Theme-based styling
---  - Z-order layering
---
---Use Cases:
---  - Background for widget groups
---  - Visual separation of UI sections
---  - Sidebar containers
---  - Info panels
---  - Dialog backgrounds
---
---Key Exports:
---  - Panel.new(x, y, width, height): Creates panel
---  - setBackgroundColor(r, g, b, a): Sets fill color
---  - setBorderColor(r, g, b, a): Sets border color
---  - addChild(widget): Adds child widget
---  - draw(): Renders panel and children
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color theme
---
---@module widgets.containers.panel
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Panel = require("gui.widgets.containers.panel")
---  local panel = Panel.new(0, 0, 240, 240)
---  panel:setBackgroundColor(0.1, 0.1, 0.1, 0.9)
---  panel:draw()
---
---@see widgets.containers.window For draggable windows

--[[
    Panel Widget
    
    A simple rectangular background panel.
    Features:
    - Colored background
    - Optional border
    - Can contain child widgets
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

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



























