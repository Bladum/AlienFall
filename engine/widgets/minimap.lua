--[[
    MiniMap Widget
    
    Displays a miniature overview of the tactical map.
    Features:
    - Scaled-down map view
    - Unit markers
    - Fog of war
    - Click to center view
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

local MiniMap = setmetatable({}, {__index = BaseWidget})
MiniMap.__index = MiniMap

function MiniMap.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, MiniMap)
    
    self.mapWidth = 50
    self.mapHeight = 50
    self.tiles = {}  -- 2D array of tile data
    self.units = {}  -- {x, y, team} for each unit
    self.viewportX = 0
    self.viewportY = 0
    self.viewportWidth = 10
    self.viewportHeight = 10
    
    return self
end

function MiniMap:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Calculate scale
    local scaleX = (self.width - 4) / self.mapWidth
    local scaleY = (self.height - 4) / self.mapHeight
    local scale = math.min(scaleX, scaleY)
    
    -- Draw tiles (simplified)
    for ty = 0, self.mapHeight - 1 do
        for tx = 0, self.mapWidth - 1 do
            local px = self.x + 2 + tx * scale
            local py = self.y + 2 + ty * scale
            
            -- Simplified terrain coloring
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", px, py, scale, scale)
        end
    end
    
    -- Draw viewport indicator
    local vpX = self.x + 2 + self.viewportX * scale
    local vpY = self.y + 2 + self.viewportY * scale
    local vpW = self.viewportWidth * scale
    local vpH = self.viewportHeight * scale
    
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", vpX, vpY, vpW, vpH)
    
    -- Draw units
    for _, unit in ipairs(self.units) do
        local ux = self.x + 2 + unit.x * scale
        local uy = self.y + 2 + unit.y * scale
        
        if unit.team == "player" then
            love.graphics.setColor(0, 0.8, 1)
        else
            love.graphics.setColor(1, 0.3, 0.3)
        end
        
        love.graphics.circle("fill", ux + scale / 2, uy + scale / 2, scale / 2)
    end
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function MiniMap:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:containsPoint(x, y) and button == 1 then
        local scaleX = (self.width - 4) / self.mapWidth
        local scaleY = (self.height - 4) / self.mapHeight
        local scale = math.min(scaleX, scaleY)
        
        local mapX = math.floor((x - self.x - 2) / scale)
        local mapY = math.floor((y - self.y - 2) / scale)
        
        if self.onClick then
            self.onClick(mapX, mapY)
        end
        
        return true
    end
    
    return false
end

function MiniMap:setViewport(x, y, width, height)
    self.viewportX = x
    self.viewportY = y
    self.viewportWidth = width
    self.viewportHeight = height
end

function MiniMap:setUnits(units)
    self.units = units or {}
end

function MiniMap:setMapSize(width, height)
    self.mapWidth = width
    self.mapHeight = height
end

return MiniMap
