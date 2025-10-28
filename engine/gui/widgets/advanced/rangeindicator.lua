---RangeIndicator Widget - Visual Range Display
---
---A visual indicator that displays range zones around a unit or point. Shows movement
---range, weapon range, or effect radius with color-coded zones. Used in tactical combat.
---Grid-aligned for consistent positioning.
---
---Features:
---  - Multiple range types (movement, weapon, sight)
---  - Color-coded by type
---  - Circular or grid-based display
---  - Grid-aligned positioning (24×24 pixels)
---  - Transparency for overlapping zones
---  - Tile-based range calculation
---
---Range Types:
---  - Movement: Where unit can move (blue)
---  - Weapon: Attack range from position (red)
---  - Sight: Vision range (green)
---
---Display Modes:
---  - Circle: Simple radius display
---  - Grid: Hex-grid or square-grid pathfinding range
---  - Line: Direct line of sight
---
---Key Exports:
---  - RangeIndicator.new(x, y, width, height): Creates indicator
---  - setRange(type, range): Sets range for type
---  - setOrigin(x, y): Sets center point
---  - setMode(mode): Sets display mode
---  - update(map): Recalculates valid tiles
---  - draw(): Renders range zones
---  - isInRange(x, y, type): Checks if position in range
---  - clear(): Clears all ranges
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---  - shared.pathfinding: Range calculation
---
---@module widgets.advanced.rangeindicator
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local RangeIndicator = require("gui.widgets.advanced.rangeindicator")
---  local indicator = RangeIndicator.new(0, 0, 800, 600)
---  indicator:setOrigin(unitX, unitY)
---  indicator:setRange("movement", 5)
---  indicator:setRange("weapon", 8)
---  indicator:draw()
---
---@see widgets.advanced.minimap For map overview

--[[
    RangeIndicator Widget
    
    Displays range/distance indicators for tactical games.
    Features:
    - Circular or grid-based range display
    - Multiple range types (movement, weapon, sight)
    - Color-coded ranges
    - Transparency/overlay rendering
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local RangeIndicator = setmetatable({}, {__index = BaseWidget})
RangeIndicator.__index = RangeIndicator

function RangeIndicator.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, RangeIndicator)
    
    self.centerX = 0  -- World coordinates
    self.centerY = 0
    self.ranges = {}  -- {type, distance, color}
    self.rangeType = "circular"  -- circular or grid
    self.tileSize = 32
    self.showGrid = false
    self.alpha = 0.3
    
    return self
end

function RangeIndicator:draw()
    if not self.visible then
        return
    end
    
    -- Draw range overlays
    for _, range in ipairs(self.ranges) do
        if self.rangeType == "circular" then
            self:drawCircularRange(range)
        else
            self:drawGridRange(range)
        end
    end
end

function RangeIndicator:drawCircularRange(range)
    local screenX = self.x + self.centerX
    local screenY = self.y + self.centerY
    local radius = range.distance * self.tileSize
    
    -- Draw filled circle with transparency
    love.graphics.setColor(range.color.r / 255, range.color.g / 255, range.color.b / 255, self.alpha)
    love.graphics.circle("fill", screenX, screenY, radius)
    
    -- Draw circle outline
    love.graphics.setColor(range.color.r / 255, range.color.g / 255, range.color.b / 255, self.alpha * 2)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", screenX, screenY, radius)
end

function RangeIndicator:drawGridRange(range)
    local screenX = self.x + self.centerX
    local screenY = self.y + self.centerY
    local distance = range.distance
    
    -- Draw grid cells within range (Manhattan distance)
    for dy = -distance, distance do
        for dx = -distance, distance do
            local dist = math.abs(dx) + math.abs(dy)
            
            if dist <= distance then
                local tileX = screenX + dx * self.tileSize
                local tileY = screenY + dy * self.tileSize
                
                -- Check if tile is within widget bounds
                if tileX >= self.x and tileX < self.x + self.width and
                   tileY >= self.y and tileY < self.y + self.height then
                    -- Draw tile highlight
                    love.graphics.setColor(range.color.r / 255, range.color.g / 255, 
                                          range.color.b / 255, self.alpha)
                    love.graphics.rectangle("fill", tileX, tileY, self.tileSize, self.tileSize)
                    
                    -- Draw tile border
                    if self.showGrid then
                        love.graphics.setColor(range.color.r / 255, range.color.g / 255, 
                                              range.color.b / 255, self.alpha * 2)
                        love.graphics.setLineWidth(1)
                        love.graphics.rectangle("line", tileX, tileY, self.tileSize, self.tileSize)
                    end
                end
            end
        end
    end
end

function RangeIndicator:addRange(rangeType, distance, color)
    table.insert(self.ranges, {
        type = rangeType,
        distance = distance,
        color = color or {r = 100, g = 200, b = 255}
    })
end

function RangeIndicator:clearRanges()
    self.ranges = {}
end

function RangeIndicator:setCenter(x, y)
    self.centerX = x
    self.centerY = y
end

function RangeIndicator:setRangeType(rangeType)
    self.rangeType = rangeType
end

function RangeIndicator:setTileSize(size)
    self.tileSize = size
end

function RangeIndicator:setAlpha(alpha)
    self.alpha = alpha
end

function RangeIndicator:setShowGrid(show)
    self.showGrid = show
end

return RangeIndicator



























