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

local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

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
