---HexMath - Hexagonal Grid Mathematics (Vertical Axial)
---
---Pure functional hexagonal grid mathematics using VERTICAL AXIAL coordinates.
---This is the UNIVERSAL coordinate system for ALL AlienFall maps (Geoscape,
---Battlescape, Basescape). All calculations use axial (q, r) coordinates.
---
---COORDINATE SYSTEM: Vertical Axial (Flat-Top Hexagons)
---  - Primary: Axial coordinates (q, r) - ALWAYS USE THIS
---  - Internal: Cube coordinates (x, y, z) where x+y+z=0 - for calculations only
---  - Rendering: Pixel coordinates (x, y) - for display only
---
---IMPORTANT: This module defines the SINGLE SOURCE OF TRUTH for hex math.
---All other modules must use this API. Never implement custom hex math.
---
---DIRECTION SYSTEM (Vertical Axial - Flat Top):
---  - 0: E  (East)      → q+1, r+0  (right)
---  - 1: SE (Southeast) → q+0, r+1  (down-right)
---  - 2: SW (Southwest) → q-1, r+1  (down-left)
---  - 3: W  (West)      → q-1, r+0  (left)
---  - 4: NW (Northwest) → q+0, r-1  (up-left)
---  - 5: NE (Northeast) → q+1, r-1  (up-right)
---
---DESIGN REFERENCE: design/mechanics/hex_vertical_axial_system.md
---
---@module battlescape.battle_ecs.hex_math
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local HexMath = {}

---Direction vectors for vertical axial hex grid (flat-top orientation)
HexMath.DIRECTIONS = {
    {q = 1, r = 0},   -- 0: E  (East)
    {q = 0, r = 1},   -- 1: SE (Southeast)
    {q = -1, r = 1},  -- 2: SW (Southwest)
    {q = -1, r = 0},  -- 3: W  (West)
    {q = 0, r = -1},  -- 4: NW (Northwest)
    {q = 1, r = -1}   -- 5: NE (Northeast)
}

---Direction names for debugging
HexMath.DIRECTION_NAMES = {"E", "SE", "SW", "W", "NW", "NE"}

---Math constant
HexMath.SQRT3 = math.sqrt(3)

---
--- COORDINATE CONVERSIONS
---

---Convert axial (q, r) to cube (x, y, z)
function HexMath.axialToCube(q, r)
    local x = q
    local z = r
    local y = -x - z
    return x, y, z
end

---Convert cube (x, y, z) to axial (q, r)
function HexMath.cubeToAxial(x, y, z)
    return x, z
end

---
--- DISTANCE AND NEIGHBORS
---

---Calculate distance between two hexes
function HexMath.distance(q1, r1, q2, r2)
    local x1, y1, z1 = HexMath.axialToCube(q1, r1)
    local x2, y2, z2 = HexMath.axialToCube(q2, r2)
    return (math.abs(x1 - x2) + math.abs(y1 - y2) + math.abs(z1 - z2)) / 2
end

---Get neighbor in direction (0-5)
function HexMath.neighbor(q, r, direction)
    local dir = HexMath.DIRECTIONS[(direction % 6) + 1]
    if not dir then
        return q, r
    end
    return q + dir.q, r + dir.r
end

---Get all 6 neighbors
function HexMath.getNeighbors(q, r)
    local neighbors = {}
    for i = 0, 5 do
        local nq, nr = HexMath.neighbor(q, r, i)
        table.insert(neighbors, {q = nq, r = nr})
    end
    return neighbors
end

---Get direction from hex1 to hex2 (-1 if not adjacent)
function HexMath.getDirection(q1, r1, q2, r2)
    local dq = q2 - q1
    local dr = r2 - r1

    for i = 0, 5 do
        local dir = HexMath.DIRECTIONS[i + 1]
        if dir.q == dq and dir.r == dr then
            return i
        end
    end
    return -1
end

---
--- LINE OF SIGHT
---

---Check if target is in front arc (120°)
function HexMath.isInFrontArc(sourceQ, sourceR, sourceFacing, targetQ, targetR)
    local direction = HexMath.getDirection(sourceQ, sourceR, targetQ, targetR)
    if direction == -1 then
        return false
    end

    local leftDir = (sourceFacing - 1 + 6) % 6
    local rightDir = (sourceFacing + 1) % 6
    return direction == sourceFacing or direction == leftDir or direction == rightDir
end

---Get hexes on line from source to target
function HexMath.hexLine(q1, r1, q2, r2)
    local dist = HexMath.distance(q1, r1, q2, r2)
    if dist == 0 then
        return {{q = q1, r = r1}}
    end

    local results = {}
    for i = 0, dist do
        local t = i / dist
        local x1, y1, z1 = HexMath.axialToCube(q1, r1)
        local x2, y2, z2 = HexMath.axialToCube(q2, r2)

        local x = x1 + (x2 - x1) * t
        local y = y1 + (y2 - y1) * t
        local z = z1 + (z2 - z1) * t

        local rx = math.floor(x + 0.5)
        local ry = math.floor(y + 0.5)
        local rz = math.floor(z + 0.5)

        local xDiff = math.abs(rx - x)
        local yDiff = math.abs(ry - y)
        local zDiff = math.abs(rz - z)

        if xDiff > yDiff and xDiff > zDiff then
            rx = -ry - rz
        elseif yDiff > zDiff then
            ry = -rx - rz
        else
            rz = -rx - ry
        end

        local q, r = HexMath.cubeToAxial(rx, ry, rz)
        table.insert(results, {q = q, r = r})
    end

    return results
end

---
--- RANGE AND AREA
---

---Get all hexes within range
function HexMath.hexesInRange(centerQ, centerR, range)
    local results = {}

    for x = -range, range do
        for y = math.max(-range, -x - range), math.min(range, -x + range) do
            local z = -x - y
            if math.abs(x) + math.abs(y) + math.abs(z) <= range * 2 then
                local q, r = HexMath.cubeToAxial(x, y, z)
                table.insert(results, {q = centerQ + q, r = centerR + r})
            end
        end
    end

    return results
end

---Get hexes at exact distance
function HexMath.hexRing(centerQ, centerR, radius)
    if radius == 0 then
        return {{q = centerQ, r = centerR}}
    end

    local results = {}
    local q, r = centerQ, centerR

    for i = 1, radius do
        q, r = HexMath.neighbor(q, r, 4)
    end

    for dir = 0, 5 do
        for step = 0, radius - 1 do
            table.insert(results, {q = q, r = r})
            q, r = HexMath.neighbor(q, r, dir)
        end
    end

    return results
end

---
--- PIXEL CONVERSION
---

---Convert hex to pixel position
function HexMath.hexToPixel(q, r, hexSize)
    hexSize = hexSize or 24

    local x = hexSize * HexMath.SQRT3 * q
    local y = hexSize * 1.5 * r

    if q % 2 == 1 then
        y = y + hexSize * 0.75
    end

    return x, y
end

---Convert pixel to hex position
function HexMath.pixelToHex(x, y, hexSize)
    hexSize = hexSize or 24

    local q = x / (hexSize * HexMath.SQRT3)
    local qRounded = math.floor(q + 0.5)
    local yAdjusted = y

    if qRounded % 2 == 1 then
        yAdjusted = yAdjusted - hexSize * 0.75
    end

    local r = yAdjusted / (hexSize * 1.5)

    local x1, y1, z1 = HexMath.axialToCube(q, r)
    local rx = math.floor(x1 + 0.5)
    local ry = math.floor(y1 + 0.5)
    local rz = math.floor(z1 + 0.5)

    local xDiff = math.abs(rx - x1)
    local yDiff = math.abs(ry - y1)
    local zDiff = math.abs(rz - z1)

    if xDiff > yDiff and xDiff > zDiff then
        rx = -ry - rz
    elseif yDiff > zDiff then
        ry = -rx - rz
    else
        rz = -rx - ry
    end

    return HexMath.cubeToAxial(rx, ry, rz)
end

---
--- ROTATION
---

---Calculate rotation to face target
function HexMath.rotationToFace(currentFacing, targetFacing)
    local diff = (targetFacing - currentFacing) % 6
    if diff > 3 then
        diff = diff - 6
    end
    return diff
end

---Rotate direction
function HexMath.rotateDirection(direction, rotation)
    return (direction + rotation) % 6
end

---Get opposite direction
function HexMath.oppositeDirection(direction)
    return (direction + 3) % 6
end

---
--- UTILITY
---

---Check if coordinates are equal
function HexMath.equals(q1, r1, q2, r2)
    return q1 == q2 and r1 == r2
end

---Validate coordinates
function HexMath.isValid(q, r)
    return type(q) == "number" and type(r) == "number" and q == q and r == r
end

---Format coordinates as string
function HexMath.toString(q, r)
    return string.format("hex(%d, %d)", q, r)
end

return HexMath

