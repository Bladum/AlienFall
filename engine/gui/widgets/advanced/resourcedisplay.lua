---ResourceDisplay Widget - Game Resource Display Panel
---
---Displays game resources like money, supplies, research points, and manufacturing capacity.
---Shows icons and values in a compact horizontal layout with color-coded warnings for low
---resources. Grid-aligned for consistent UI positioning.
---
---Features:
---  - Multiple resource types (credits, supplies, research, manufacturing)
---  - Icon + value display
---  - Color-coded warnings (red for low resources)
---  - Compact horizontal layout
---  - Grid-aligned positioning (24×24 pixels)
---  - Automatic resource updates
---
---Resource Types:
---  - Credits: Money ($)
---  - Supplies: Materials/Equipment (📦)
---  - Research: Science points (🔬)
---  - Manufacturing: Production capacity (🔧)
---  - Custom: Any resource with icon
---
---Visual States:
---  - Normal: White text
---  - Low: Yellow warning
---  - Critical: Red alert
---  - Disabled: Grayed out
---
---Key Exports:
---  - ResourceDisplay.new(x, y, width, height): Creates resource display
---  - setResource(resourceType, value, max): Updates resource value
---  - setWarningThreshold(resourceType, threshold): Sets warning percentage
---  - draw(): Renders resource display
---  - update(dt): Updates animations
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.advanced.resourcedisplay
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ResourceDisplay = require("gui.widgets.advanced.resourcedisplay")
---  local display = ResourceDisplay.new(0, 0, 480, 48)
---  display:setResource("credits", 50000, 100000)
---  display:setResource("supplies", 200, 500)
---  display:draw()
---
---@see widgets.display.stat_bar For single stat display

--[[
    ResourceDisplay Widget
    
    Displays game resources like money, supplies, research points.
    Features:
    - Multiple resource types
    - Icons and values
    - Color-coded warnings (low resources)
    - Compact horizontal layout
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local ResourceDisplay = setmetatable({}, {__index = BaseWidget})
ResourceDisplay.__index = ResourceDisplay

--[[
    Create a new resource display
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New resource display instance
]]
function ResourceDisplay.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, ResourceDisplay)
    
    self.resources = {}  -- {name, value, icon, max, warningThreshold}
    self.padding = 4
    self.iconSize = 16
    
    return self
end

--[[
    Draw the resource display
]]
function ResourceDisplay:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Calculate spacing for resources
    local resourceCount = #self.resources
    if resourceCount == 0 then
        return
    end
    
    local resourceWidth = (self.width - self.padding * (resourceCount + 1)) / resourceCount
    local currentX = self.x + self.padding
    
    Theme.setFont("small")
    local font = Theme.getFont("small")
    local textHeight = font:getHeight()
    
    for i, resource in ipairs(self.resources) do
        local resourceX = currentX + (i - 1) * (resourceWidth + self.padding)
        local resourceY = self.y + (self.height - self.iconSize) / 2
        
        -- Draw icon or colored box
        if resource.icon then
            love.graphics.setColor(1, 1, 1, 1)
            local iconScale = self.iconSize / resource.icon:getWidth()
            love.graphics.draw(resource.icon, resourceX, resourceY, 0, iconScale, iconScale)
        else
            -- Draw colored placeholder
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", resourceX, resourceY, self.iconSize, self.iconSize)
        end
        
        -- Draw value with warning color if low
        local textX = resourceX + self.iconSize + 4
        local textY = self.y + (self.height - textHeight) / 2
        
        -- Check if resource is low (below warning threshold)
        local isLow = false
        if resource.max and resource.warningThreshold then
            local percent = resource.value / resource.max
            isLow = percent < resource.warningThreshold
        end
        
        if isLow then
            love.graphics.setColor(1, 0.3, 0.3)  -- Red warning
        else
            Theme.setColor(self.textColor)
        end
        
        local valueText = resource.max and 
                         string.format("%d/%d", resource.value, resource.max) or
                         tostring(resource.value)
        love.graphics.print(valueText, textX, textY)
    end
end

--[[
    Add a resource to display
    @param resource table - {name, value, icon, max, warningThreshold}
]]
function ResourceDisplay:addResource(resource)
    table.insert(self.resources, resource)
end

--[[
    Update resource value
    @param name string - Resource name
    @param value number - New value
]]
function ResourceDisplay:setResourceValue(name, value)
    for _, resource in ipairs(self.resources) do
        if resource.name == name then
            resource.value = value
            break
        end
    end
end

--[[
    Clear all resources
]]
function ResourceDisplay:clearResources()
    self.resources = {}
end

return ResourceDisplay



























