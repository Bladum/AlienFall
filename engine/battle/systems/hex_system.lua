-- hex_system.lua
-- Hex grid management system
-- Part of ECS architecture for battle system

local HexMath = require("battle.utils.hex_math")
local Debug = require("battle.utils.debug")

local HexSystem = {}

-- Initialize hex system with grid dimensions
-- @param width number: Grid width in hexes
-- @param height number: Grid height in hexes
-- @param hexSize number: Hex size in pixels (default 24)
function HexSystem.new(width, height, hexSize)
    local self = {
        width = width or 60,
        height = height or 60,
        hexSize = hexSize or 24,
        tiles = {},  -- [q_r] = {q, r, terrain, blocking, etc}
        units = {}   -- [unitId] = {transform, ...components}
    }
    
    -- Initialize tiles
    for col = 0, self.width - 1 do
        for row = 0, self.height - 1 do
            local q, r = HexMath.offsetToAxial(col, row)
            local key = q .. "_" .. r
            self.tiles[key] = {
                q = q,
                r = r,
                col = col,
                row = row,
                terrain = "floor",
                blocking = false,
                visible = false,
                explored = false
            }
        end
    end
    
    Debug.print("HexSystem", string.format("Initialized %dx%d hex grid", width, height))
    return self
end

-- Get tile at hex coordinates
function HexSystem.getTile(self, q, r)
    local key = q .. "_" .. r
    return self.tiles[key]
end

-- Get tile at offset coordinates
function HexSystem.getTileOffset(self, col, row)
    local q, r = HexMath.offsetToAxial(col, row)
    return HexSystem.getTile(self, q, r)
end

-- Check if hex is valid and within bounds
function HexSystem.isValidHex(self, q, r)
    local col, row = HexMath.axialToOffset(q, r)
    return col >= 0 and col < self.width and row >= 0 and row < self.height
end

-- Check if hex is walkable
function HexSystem.isWalkable(self, q, r)
    local tile = HexSystem.getTile(self, q, r)
    if not tile then return false end
    return not tile.blocking
end

-- Get neighbors of a hex (only valid ones)
function HexSystem.getValidNeighbors(self, q, r)
    local neighbors = HexMath.getNeighbors(q, r)
    local valid = {}
    for _, neighbor in ipairs(neighbors) do
        if HexSystem.isValidHex(self, neighbor.q, neighbor.r) then
            table.insert(valid, neighbor)
        end
    end
    return valid
end

-- Convert screen coordinates to hex
function HexSystem.screenToHex(self, screenX, screenY)
    return HexMath.pixelToHex(screenX, screenY, self.hexSize)
end

-- Convert hex coordinates to screen
function HexSystem.hexToScreen(self, q, r)
    return HexMath.hexToPixel(q, r, self.hexSize)
end

-- Add unit to system
function HexSystem.addUnit(self, unitId, unit)
    self.units[unitId] = unit
    Debug.log("HexSystem", "Added unit: " .. unitId)
end

-- Remove unit from system
function HexSystem.removeUnit(self, unitId)
    self.units[unitId] = nil
    Debug.log("HexSystem", "Removed unit: " .. unitId)
end

-- Get unit at hex position
function HexSystem.getUnitAt(self, q, r)
    for unitId, unit in pairs(self.units) do
        if unit.transform and unit.transform.q == q and unit.transform.r == r then
            return unit, unitId
        end
    end
    return nil
end

-- Draw hex grid overlay (for debug)
function HexSystem.drawHexGrid(self, camera)
    if not Debug.showHexGrid then return end
    
    Debug.print("HexSystem", "Drawing hex grid overlay")
    
    love.graphics.push()
    love.graphics.setColor(0, 1, 0, 0.8)  -- Green overlay - increased opacity
    love.graphics.setLineWidth(2)  -- Thicker lines
    
    -- Draw actual hexagons at hex positions
    for q = -15, 15 do
        for r = -15, 15 do
            -- Convert hex coordinates to pixel position
            local x, y = HexMath.hexToPixel(q, r, self.hexSize)
            
            -- Apply camera offset (same as battlefield)
            local screenX = x + camera.x
            local screenY = y + camera.y
            
            -- Only draw if on screen (with some margin)
            if screenX > -self.hexSize and screenX < 720 + self.hexSize and
               screenY > -self.hexSize and screenY < 720 + self.hexSize then
                
                -- Draw hexagon
                local points = {}
                for i = 0, 5 do
                    local angle = math.pi / 3 * i
                    local px = screenX + self.hexSize * math.cos(angle)
                    local py = screenY + self.hexSize * math.sin(angle)
                    table.insert(points, px)
                    table.insert(points, py)
                end
                
                if #points >= 6 then
                    love.graphics.polygon("line", points)
                end
            end
        end
    end
    
    love.graphics.pop()
end

return HexSystem
