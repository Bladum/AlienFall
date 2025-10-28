---Hex Grid System - Vertical Axial Coordinate System for Geoscape
---
---UNIVERSAL HEX SYSTEM: Uses the same vertical axial coordinate system as all
---other AlienFall maps (Battlescape, Basescape). This ensures consistency across
---all game layers and eliminates coordinate conversion errors.
---
---COORDINATE SYSTEM: Vertical Axial (Flat-Top Hexagons)
---  - Axial: {q, r} - Primary storage format
---  - Cube: {x, y, z} where x+y+z=0 - For calculations only
---  - Pixel: {x, y} - For rendering only
---
---IMPORTANT: This module shares the SAME coordinate system as:
---  - engine/battlescape/battle_ecs/hex_math.lua
---  - All battle maps, world maps, and base layouts
---
---DIRECTION SYSTEM (Vertical Axial - Flat Top):
---  - 0: E  (East)      → q+1, r+0  (right)
---  - 1: SE (Southeast) → q+0, r+1  (down-right)
---  - 2: SW (Southwest) → q-1, r+1  (down-left)
---  - 3: W  (West)      → q-1, r+0  (left)
---  - 4: NW (Northwest) → q+0, r-1  (up-left)
---  - 5: NE (Northeast) → q+1, r-1  (up-right)
---
---Key Operations:
---  - distance(q1, r1, q2, r2): Manhattan distance between hexes
---  - neighbors(q, r): Returns 6 adjacent hexes
---  - hexToPixel(q, r): Converts hex to screen coordinates
---  - pixelToHex(x, y): Converts screen to hex coordinates
---  - pathfind(start, goal, isWalkable): A* pathfinding
---  - ring(q, r, radius): Get hexes at exact distance
---  - area(q, r, radius): Get all hexes within distance
---
---DESIGN REFERENCE: design/mechanics/hex_vertical_axial_system.md
---
---@module geoscape.systems.hex_grid
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local HexGrid = require("geoscape.systems.hex_grid")
---  local grid = HexGrid.new(90, 45, 24)  -- World map: 90×45 hexes
---  local dist = grid.distance(0, 0, 5, 3)  -- Returns 8
---
---@see design.mechanics.hex_vertical_axial_system Design documentation
---@see battlescape.battle_ecs.hex_math Shared hex math module

local HexGrid = {}
HexGrid.__index = HexGrid

-- Hex layout constants (flat-top hexagons, vertical axial)
local SQRT3 = math.sqrt(3)

-- Direction vectors for vertical axial system (MUST match battlescape/battle_ecs/hex_math.lua)
local HEX_DIRECTIONS = {
    {q = 1, r = 0},   -- 0: E  (East)
    {q = 0, r = 1},   -- 1: SE (Southeast)
    {q = -1, r = 1},  -- 2: SW (Southwest)
    {q = -1, r = 0},  -- 3: W  (West)
    {q = 0, r = -1},  -- 4: NW (Northwest)
    {q = 1, r = -1}   -- 5: NE (Northeast)
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
---Uses vertical axial formula (flat-top orientation)
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return number, number Pixel X, Y coordinates
function HexGrid:toPixel(q, r)
    -- Vertical axial formula (flat-top hexagons)
    local x = self.hexSize * SQRT3 * q
    local y = self.hexSize * 1.5 * r

    -- Odd column offset (shift odd columns down by 0.75 * hexSize)
    if q % 2 == 1 then
        y = y + self.hexSize * 0.75
    end

    return x, y
end

---Convert pixel position to axial coordinates (rounded to nearest hex)
---Uses vertical axial formula (flat-top orientation)
---@param x number Pixel X coordinate
---@param y number Pixel Y coordinate
---@return number, number Hex Q, R coordinates
function HexGrid:toHex(x, y)
    -- Reverse vertical axial formula
    local q = x / (self.hexSize * SQRT3)

    -- Adjust for odd column offset
    local qRounded = math.floor(q + 0.5)
    local yAdjusted = y
    if qRounded % 2 == 1 then
        yAdjusted = yAdjusted - self.hexSize * 0.75
    end

    local r = yAdjusted / (self.hexSize * 1.5)

    -- Round to nearest hex using cube coordinates
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


























