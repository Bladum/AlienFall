---HexMath - Hexagonal Grid Mathematics (ECS)
---
---Pure functional hexagonal grid mathematics using cube/axial coordinates. Part
---of the ECS (Entity-Component-System) battle architecture. Provides all hex
---calculations: distance, neighbors, directions, coordinate conversions.
---
---Features:
---  - Cube coordinate system (q, r, s where q+r+s=0)
---  - Axial coordinate system (q, r stored form)
---  - Offset coordinate system (col, row display)
---  - Distance calculations
---  - Neighbor queries (6 adjacent hexes)
---  - Direction vectors
---  - Coordinate conversions
---  - Line interpolation
---
---Coordinate Systems:
---  - Cube: (q, r, s) with q+r+s=0 constraint
---  - Axial: (q, r) - two coordinates (s implicit)
---  - Offset: (col, row) - even-q vertical offset
---
---Hex Directions (6 neighbors):
---  - 0: E (East, right)
---  - 1: NE (North-East, up-right)
---  - 2: NW (North-West, up-left)
---  - 3: W (West, left)
---  - 4: SW (South-West, down-left)
---  - 5: SE (South-East, down-right)
---
---Key Exports:
---  - HexMath.DIRECTIONS: Table of 6 direction vectors
---  - distance(q1, r1, q2, r2): Returns hex distance
---  - neighbor(q, r, direction): Returns adjacent hex
---  - neighbors(q, r): Returns all 6 neighbors
---  - axialToOffset(q, r): Converts axial to offset
---  - offsetToAxial(col, row): Converts offset to axial
---  - lerp(q1, r1, q2, r2, t): Interpolates between hexes
---
---Dependencies:
---  - None (pure math library)
---
---@module battlescape.battle_ecs.hex_math
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local HexMath = require("battlescape.battle_ecs.hex_math")
---  local dist = HexMath.distance(0, 0, 3, 2)  -- Returns 5
---  local neighbors = HexMath.neighbors(10, 15)
---
---@see battlescape.battle_ecs.hex_system For hex grid
---@see battlescape.battle_ecs.movement_system For movement

-- hex_math.lua
-- Pure functional hexagonal grid mathematics using cube coordinates
-- Part of ECS architecture for battle system
--
-- Coordinate System: Even-Q vertical offset (even columns shifted down)
-- Cube coordinates: (q, r, s) where q + r + s = 0
-- Axial coordinates: (q, r) - stored form
-- Offset coordinates: (col, row) - display form

local HexMath = {}

-- Constants
HexMath.DIRECTIONS = {
    {q = 1, r = 0},   -- E
    {q = 1, r = -1},  -- NE
    {q = 0, r = -1},  -- NW
    {q = -1, r = 0},  -- W
    {q = -1, r = 1},  -- SW
    {q = 0, r = 1}    -- SE
}

-- Convert offset coordinates (col, row) to axial (q, r)
-- Even-Q layout: even columns are shifted down by 0.5
function HexMath.offsetToAxial(col, row)
    local q = col
    local r = row - math.floor((col + (col % 2)) / 2)
    return q, r
end

-- Convert axial coordinates (q, r) to offset (col, row)
function HexMath.axialToOffset(q, r)
    local col = q
    local row = r + math.floor((q + (q % 2)) / 2)
    return col, row
end

-- Convert axial (q, r) to cube (q, r, s)
function HexMath.axialToCube(q, r)
    return q, r, -q - r
end

-- Convert cube (q, r, s) to axial (q, r)
function HexMath.cubeToAxial(q, r, s)
    return q, r
end

-- Get neighbor in direction (0-5)
function HexMath.neighbor(q, r, direction)
    local dir = HexMath.DIRECTIONS[direction + 1]
    if not dir then
        return q, r  -- Invalid direction, return same position
    end
    return q + dir.q, r + dir.r
end

-- Get all 6 neighbors of a hex
function HexMath.getNeighbors(q, r)
    local neighbors = {}
    for i = 0, 5 do
        local nq, nr = HexMath.neighbor(q, r, i)
        table.insert(neighbors, {q = nq, r = nr})
    end
    return neighbors
end

-- Calculate distance between two hexes (in hexes)
function HexMath.distance(q1, r1, q2, r2)
    local q1c, r1c, s1c = HexMath.axialToCube(q1, r1)
    local q2c, r2c, s2c = HexMath.axialToCube(q2, r2)
    return math.floor((math.abs(q1c - q2c) + math.abs(r1c - r2c) + math.abs(s1c - s2c)) / 2)
end

-- Get direction from hex1 to hex2 (returns 0-5 or -1 if not adjacent)
function HexMath.getDirection(q1, r1, q2, r2)
    local dq = q2 - q1
    local dr = r2 - r1

    for i = 0, 5 do
        local dir = HexMath.DIRECTIONS[i + 1]
        if dir.q == dq and dir.r == dr then
            return i
        end
    end
    return -1  -- Not adjacent
end

-- Check if a hex is in front arc (120°) from position facing direction
-- Arc covers 3 forward hexes (facing, facing-1, facing+1)
function HexMath.isInFrontArc(sourceQ, sourceR, sourceFacing, targetQ, targetR)
    -- Get direction to target
    local direction = HexMath.getDirection(sourceQ, sourceR, targetQ, targetR)
    if direction == -1 then
        -- Not adjacent, check if in front cone
        local neighbors = HexMath.getNeighbors(sourceQ, sourceR)
        for i = -1, 1 do
            local checkDir = (sourceFacing + i) % 6
            local frontHex = neighbors[checkDir + 1]
            if frontHex.q == targetQ and frontHex.r == targetR then
                return true
            end
        end
        return false
    end

    -- Check if adjacent hex is in front arc
    local leftDir = (sourceFacing - 1) % 6
    local rightDir = (sourceFacing + 1) % 6
    return direction == sourceFacing or direction == leftDir or direction == rightDir
end

-- Get hexes in a line from source to target (for LOS)
function HexMath.hexLine(q1, r1, q2, r2)
    local distance = HexMath.distance(q1, r1, q2, r2)
    if distance == 0 then
        return {{q = q1, r = r1}}
    end

    local results = {}
    for i = 0, distance do
        local t = i / distance
        local q = q1 + (q2 - q1) * t
        local r = r1 + (r2 - r1) * t
        local s = -q - r

        -- Round to nearest hex
        local rq = math.floor(q + 0.5)
        local rr = math.floor(r + 0.5)
        local rs = math.floor(s + 0.5)

        -- Correct rounding if sum != 0
        local qDiff = math.abs(rq - q)
        local rDiff = math.abs(rr - r)
        local sDiff = math.abs(rs - s)

        if qDiff > rDiff and qDiff > sDiff then
            rq = -rr - rs
        elseif rDiff > sDiff then
            rr = -rq - rs
        end

        table.insert(results, {q = rq, r = rr})
    end

    return results
end

-- Get all hexes within range (circular)
function HexMath.hexesInRange(centerQ, centerR, range)
    local results = {}
    for q = -range, range do
        local r1 = math.max(-range, -q - range)
        local r2 = math.min(range, -q + range)
        for r = r1, r2 do
            local s = -q - r
            if math.abs(q) + math.abs(r) + math.abs(s) <= range * 2 then
                table.insert(results, {q = centerQ + q, r = centerR + r})
            end
        end
    end
    return results
end

-- Convert hex coordinates to pixel position (for rendering)
-- Uses pointy-top hex orientation
function HexMath.hexToPixel(q, r, hexSize)
    local col, row = HexMath.axialToOffset(q, r)
    local x = hexSize * 3/2 * col
    local y = hexSize * math.sqrt(3) * (row + 0.5 * (col % 2))
    return x, y
end

-- Convert pixel position to hex coordinates
function HexMath.pixelToHex(x, y, hexSize)
    local q = (2/3 * x) / hexSize
    local r = (-1/3 * x + math.sqrt(3)/3 * y) / hexSize
    local s = -q - r

    -- Round to nearest hex
    local rq = math.floor(q + 0.5)
    local rr = math.floor(r + 0.5)
    local rs = math.floor(s + 0.5)

    local qDiff = math.abs(rq - q)
    local rDiff = math.abs(rr - r)
    local sDiff = math.abs(rs - s)

    if qDiff > rDiff and qDiff > sDiff then
        rq = -rr - rs
    elseif rDiff > sDiff then
        rr = -rq - rs
    end

    return rq, rr
end

-- Calculate rotation needed to face from hex1 to hex2
-- Returns number of 60° rotations needed (-3 to 3)
function HexMath.rotationToFace(currentFacing, targetFacing)
    local diff = (targetFacing - currentFacing) % 6
    if diff > 3 then
        diff = diff - 6  -- Prefer shorter rotation
    end
    return diff
end

return HexMath
