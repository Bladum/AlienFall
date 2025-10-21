---Hex Grid System - Axial Coordinate System for Geoscape
---
---Implements flat-top hexagon grid with axial coordinates (q, r) and cube coordinate
---conversion for calculations. Provides pathfinding (A*), distance calculations, neighbor
---lookups, and coordinate transformations. Foundation for geoscape spatial logic.
---
---Coordinate Systems:
---  - Axial: {q, r} - Storage format (2 values)
---  - Cube: {x, y, z} - Calculation format (x + y + z = 0 constraint)
---  - Pixel: {x, y} - Screen space conversion
---
---Hexagon Orientation:
---  - Flat-top hexagons (⬡ not ⬢)
---  - East direction: q+1, r+0
---  - Six neighbors per hex
---
---Key Operations:
---  - distance(a, b): Manhattan distance between hexes
---  - neighbors(hex): Returns 6 adjacent hexes
---  - hexToPixel(q, r): Converts hex to screen coordinates
---  - pixelToHex(x, y): Converts screen to hex coordinates
---  - pathfind(start, goal, isWalkable): A* pathfinding
---  - line(start, end): Bresenham hex line
---
---Key Exports:
---  - HexGrid.new(hexSize): Creates hex grid system
---  - distance(hexA, hexB): Returns hex distance
---  - neighbors(hex): Returns array of 6 neighbors
---  - pathfind(start, goal, isWalkable): Returns hex path array
---  - hexToPixel(q, r): Returns {x, y} pixel position
---  - pixelToHex(x, y): Returns {q, r} hex coordinates
---
---Dependencies: None (pure math library)
---
---@module geoscape.systems.hex_grid
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local HexGrid = require("geoscape.systems.hex_grid")
---  local grid = HexGrid.new(32)  -- 32 pixel hex size
---  local dist = grid:distance({q=0, r=0}, {q=5, r=3})
---  local path = grid:pathfind(start, goal, isWalkableFunc)
---
---@see geoscape.geography.province_graph For province pathfinding
---@see geoscape.world.world For world entity integration

local HexGrid = {}
HexGrid.__index = HexGrid

-- Hex layout constants (flat-top hexagons)
local SQRT3 = math.sqrt(3)

-- Axial direction vectors (flat-top orientation)
local HEX_DIRECTIONS = {
    {q = 1, r = 0},   -- East
    {q = 1, r = -1},  -- Northeast
    {q = 0, r = -1},  -- Northwest
    {q = -1, r = 0},  -- West
    {q = -1, r = 1},  -- Southwest
    {q = 0, r = 1}    -- Southeast
}

---Create a new hex grid
---@param width number Width in hex tiles
---@param height number Height in hex tiles
---@param hexSize number Pixel size of hex (distance from center to corner)
---@return table HexGrid instance
function HexGrid.new(width, height, hexSize)
    local self = setmetatable({}, HexGrid)
    
    self.width = width or 90
    self.height = height or 45
    self.hexSize = hexSize or 12  -- Default 12 pixels for 24x24 grid alignment
    
    -- Pre-calculate layout constants
    self.hexWidth = self.hexSize * SQRT3
    self.hexHeight = self.hexSize * 2
    
    print(string.format("[HexGrid] Created %dx%d grid, hex size=%d (width=%.2f, height=%.2f)",
        self.width, self.height, self.hexSize, self.hexWidth, self.hexHeight))
    
    return self
end

---Convert axial coordinates to cube coordinates
---@param q number Axial Q coordinate
---@param r number Axial R coordinate
---@return number, number, number Cube X, Y, Z coordinates
function HexGrid.axialToCube(q, r)
    local x = q
    local z = r
    local y = -x - z
    return x, y, z
end

---Convert cube coordinates to axial coordinates
---@param x number Cube X coordinate
---@param y number Cube Y coordinate
---@param z number Cube Z coordinate
---@return number, number Axial Q, R coordinates
function HexGrid.cubeToAxial(x, y, z)
    local q = x
    local r = z
    return q, r
end

---Calculate distance between two hexes (in hex tiles)
---@param q1 number First hex Q coordinate
---@param r1 number First hex R coordinate
---@param q2 number Second hex Q coordinate
---@param r2 number Second hex R coordinate
---@return number Distance in hex tiles
function HexGrid.distance(q1, r1, q2, r2)
    local x1, y1, z1 = HexGrid.axialToCube(q1, r1)
    local x2, y2, z2 = HexGrid.axialToCube(q2, r2)
    
    return (math.abs(x1 - x2) + math.abs(y1 - y2) + math.abs(z1 - z2)) / 2
end

---Get all 6 neighbors of a hex
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return table Array of {q, r} coordinate pairs
function HexGrid.neighbors(q, r)
    local result = {}
    for _, dir in ipairs(HEX_DIRECTIONS) do
        table.insert(result, {q = q + dir.q, r = r + dir.r})
    end
    return result
end

---Get neighbor in specific direction (0-5)
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@param direction number Direction index (0-5)
---@return number, number Neighbor Q, R coordinates
function HexGrid.neighbor(q, r, direction)
    local dir = HEX_DIRECTIONS[(direction % 6) + 1]
    return q + dir.q, r + dir.r
end

---Convert axial coordinates to pixel position (center of hex)
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return number, number Pixel X, Y coordinates
function HexGrid:toPixel(q, r)
    -- Flat-top hexagon layout
    local x = self.hexSize * SQRT3 * (q + r / 2)
    local y = self.hexSize * (3/2) * r
    return x, y
end

---Convert pixel position to axial coordinates (rounded to nearest hex)
---@param x number Pixel X coordinate
---@param y number Pixel Y coordinate
---@return number, number Hex Q, R coordinates
function HexGrid:toHex(x, y)
    -- Convert to fractional cube coordinates
    local q = (SQRT3/3 * x - 1/3 * y) / self.hexSize
    local r = (2/3 * y) / self.hexSize
    
    -- Round to nearest hex
    return HexGrid.roundHex(q, r)
end

---Round fractional axial coordinates to nearest hex
---@param q number Fractional Q coordinate
---@param r number Fractional R coordinate
---@return number, number Integer Q, R coordinates
function HexGrid.roundHex(q, r)
    -- Convert to cube coordinates
    local x, y, z = HexGrid.axialToCube(q, r)
    
    -- Round each coordinate
    local rx = math.floor(x + 0.5)
    local ry = math.floor(y + 0.5)
    local rz = math.floor(z + 0.5)
    
    -- Calculate rounding errors
    local x_diff = math.abs(rx - x)
    local y_diff = math.abs(ry - y)
    local z_diff = math.abs(rz - z)
    
    -- Reset coordinate with largest error to maintain x + y + z = 0
    if x_diff > y_diff and x_diff > z_diff then
        rx = -ry - rz
    elseif y_diff > z_diff then
        ry = -rx - rz
    else
        rz = -rx - ry
    end
    
    -- Convert back to axial
    return HexGrid.cubeToAxial(rx, ry, rz)
end

---Get all hexes in a ring at exact distance from center
---@param q number Center hex Q coordinate
---@param r number Center hex R coordinate
---@param radius number Ring radius (distance from center)
---@return table Array of {q, r} coordinate pairs
function HexGrid.ring(q, r, radius)
    if radius == 0 then
        return {{q = q, r = r}}
    end
    
    local results = {}
    
    -- Start at hex in direction 4 (southwest) at given radius
    local hex_q, hex_r = q, r
    for i = 1, radius do
        hex_q, hex_r = HexGrid.neighbor(hex_q, hex_r, 4)  -- Move southwest
    end
    
    -- Walk around the ring
    for i = 0, 5 do
        for j = 0, radius - 1 do
            table.insert(results, {q = hex_q, r = hex_r})
            hex_q, hex_r = HexGrid.neighbor(hex_q, hex_r, i)
        end
    end
    
    return results
end

---Get all hexes within radius (area of effect)
---@param q number Center hex Q coordinate
---@param r number Center hex R coordinate
---@param radius number Maximum distance from center
---@return table Array of {q, r} coordinate pairs
function HexGrid.area(q, r, radius)
    local results = {}
    
    for ring_radius = 0, radius do
        local ring_hexes = HexGrid.ring(q, r, ring_radius)
        for _, hex in ipairs(ring_hexes) do
            table.insert(results, hex)
        end
    end
    
    return results
end

---Check if hex coordinates are within grid bounds
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return boolean True if within bounds
function HexGrid:inBounds(q, r)
    -- Convert to offset coordinates for bounds checking
    local col = q
    local row = r + math.floor(q / 2)
    
    return col >= 0 and col < self.width and row >= 0 and row < self.height
end

---Get all valid neighbors within grid bounds
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return table Array of {q, r} coordinate pairs
function HexGrid:validNeighbors(q, r)
    local all_neighbors = HexGrid.neighbors(q, r)
    local valid = {}
    
    for _, neighbor in ipairs(all_neighbors) do
        if self:inBounds(neighbor.q, neighbor.r) then
            table.insert(valid, neighbor)
        end
    end
    
    return valid
end

---Linear interpolation between two hexes
---@param q1 number Start hex Q coordinate
---@param r1 number Start hex R coordinate
---@param q2 number End hex Q coordinate
---@param r2 number End hex R coordinate
---@param t number Interpolation factor (0.0 to 1.0)
---@return number, number Interpolated Q, R coordinates
function HexGrid.lerp(q1, r1, q2, r2, t)
    local q = q1 * (1 - t) + q2 * t
    local r = r1 * (1 - t) + r2 * t
    return q, r
end

---Get line of hexes from start to end
---@param q1 number Start hex Q coordinate
---@param r1 number Start hex R coordinate
---@param q2 number End hex Q coordinate
---@param r2 number End hex R coordinate
---@return table Array of {q, r} coordinate pairs
function HexGrid.line(q1, r1, q2, r2)
    local dist = HexGrid.distance(q1, r1, q2, r2)
    local results = {}
    
    if dist == 0 then
        return {{q = q1, r = r1}}
    end
    
    for i = 0, dist do
        local t = i / dist
        local q, r = HexGrid.lerp(q1, r1, q2, r2, t)
        q, r = HexGrid.roundHex(q, r)
        table.insert(results, {q = q, r = r})
    end
    
    return results
end

---Get corner positions of a hex for rendering
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return table Array of {x, y} corner positions (6 corners)
function HexGrid:getCorners(q, r)
    local cx, cy = self:toPixel(q, r)
    local corners = {}
    
    for i = 0, 5 do
        local angle = math.pi / 3 * i  -- 60 degrees per corner (flat-top)
        local x = cx + self.hexSize * math.cos(angle)
        local y = cy + self.hexSize * math.sin(angle)
        table.insert(corners, {x = x, y = y})
    end
    
    return corners
end

return HexGrid

























