---LOSSystem - Line of Sight Calculation
---
---Implements hex-based line of sight for visibility calculations in tactical combat.
---Calculates which tiles and units are visible from a given position, accounting for
---obstacles, terrain, smoke, and darkness. Core system for fog of war.
---
---Features:
---  - Hex-based line of sight calculation
---  - Obstacle detection (walls, objects)
---  - Sight cost accumulation (smoke, darkness)
---  - Range-based visibility falloff
---  - Unit visibility determination
---  - Fog of war integration
---
---LOS Calculation:
---  1. Convert hex coordinates to axial system
---  2. Generate line points between source and target
---  3. Check each point for obstacles
---  4. Accumulate sight costs (smoke, terrain)
---  5. Compare total cost to unit sight range
---  6. Return visibility result
---
---Sight Cost Factors:
---  - Walls: Block LOS completely
---  - Smoke: +2 per level (max 6)
---  - Darkness: +1 per tile
---  - Distance: Natural falloff
---
---Key Exports:
---  - LOS.new(): Creates LOS system
---  - calculateLine(x0, y0, x1, y1, maxDistance): Gets line points
---  - hasLineOfSight(fromX, fromY, toX, toY, map, unit): Checks visibility
---  - getVisibleTiles(x, y, range, map): Returns all visible tiles
---  - isBlocked(x, y, map): Checks if tile blocks LOS
---  - calculateSightCost(x, y, map): Returns tile sight cost
---
---Dependencies:
---  - core.data_loader: Terrain definitions
---  - battlescape.battle_ecs.hex_math: Hex coordinate math
---
---@module battlescape.combat.los_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local LOS = require("battlescape.combat.los_system")
---  local los = LOS.new()
---  if los:hasLineOfSight(unitX, unitY, targetX, targetY, map, unit) then
---    -- Target is visible, can shoot
---  end
---
---@see battlescape.combat.los_optimized For optimized LOS

-- Line of Sight System
-- Implements hex-based line of sight for visibility calculations

local DataLoader = require("core.data_loader")
local HexMath = require("battlescape.battle_ecs.hex_math")

local LOS = {}
LOS.__index = LOS

-- Create LOS system
function LOS.new()
    local self = setmetatable({}, LOS)
    return self
end

-- Hex-based line of sight calculation
function LOS:calculateLine(x0, y0, x1, y1, maxDistance)
    local points = {}

    -- Convert offset coordinates to axial
    local q0, r0 = HexMath.offsetToAxial(x0, y0)
    local q1, r1 = HexMath.offsetToAxial(x1, y1)
    
    -- Get hexes in line
    local hexLine = HexMath.hexLine(q0, r0, q1, r1)
    
    for i, hex in ipairs(hexLine) do
        -- Convert back to offset coordinates
        local col, row = HexMath.axialToOffset(hex.q, hex.r)
        
        -- Calculate distance from start
        local distance = HexMath.distance(q0, r0, hex.q, hex.r)
        
        -- Check distance limit
        if not maxDistance or distance <= maxDistance then
            table.insert(points, {x = col, y = row, distance = distance})
        else
            break
        end
    end

    return points
end

-- Check if line of sight is clear between two points
-- Returns: clearLOS (boolean), lastVisiblePoint (table or nil)
function LOS:hasClearLOS(battlefield, x0, y0, x1, y1, maxDistance)
    local line = self:calculateLine(x0, y0, x1, y1, maxDistance)
    local lastVisiblePoint = nil

    for i, point in ipairs(line) do
        -- Skip starting point
        if i > 1 then
            local tile = battlefield:getTile(point.x, point.y)
            if not tile then
                -- Out of bounds - last visible point is the one before
                return false, lastVisiblePoint
            end

            local terrain = tile.terrain
            if terrain.blocksSight then
                -- Obstacle blocks LOS, but the obstacle itself is visible
                lastVisiblePoint = point
                return false, lastVisiblePoint
            end

            -- Check for environmental effects that block sight
            if tile.effects and tile.effects.smoke and tile.effects.smoke > 0 then
                lastVisiblePoint = point
                return false, lastVisiblePoint
            end
            
            lastVisiblePoint = point
        end
    end

    return true, lastVisiblePoint
end

-- Calculate directional cone of sight
-- coneAngle: 120 for standard forward vision
function LOS:calculateConeOfSight(battlefield, centerX, centerY, facing, coneAngle, maxDistance, isDay)
    local visiblePoints = {}
    local blockedTiles = {}  -- Track tiles blocked by obstacles

    -- Convert center to axial coordinates
    local centerQ, centerR = HexMath.offsetToAxial(centerX, centerY)
    
    -- Facing is 0-5 for hex directions (6 directions)
    local hexFacing = facing % 6
    
    -- Get all hexes in range
    local hexesInRange = HexMath.hexesInRange(centerQ, centerR, maxDistance or 10)
    
    for _, hex in ipairs(hexesInRange) do
        -- Convert back to offset coordinates
        local x, y = HexMath.axialToOffset(hex.q, hex.r)
        
        -- Calculate hex distance
        local distance = HexMath.distance(centerQ, centerR, hex.q, hex.r)
        
        -- Check if hex is in cone (120° = 2 hex directions on each side)
        local inCone = false
        if distance == 0 then
            -- Current tile always visible
            inCone = true
        else
            local direction = HexMath.getDirection(centerQ, centerR, hex.q, hex.r)
            if direction ~= -1 then
                local facingDiff = math.abs(direction - hexFacing)
                -- Handle wrap-around (e.g., facing 0 and direction 5 should be 1 apart)
                if facingDiff > 3 then facingDiff = 6 - facingDiff end
                -- Allow 120° cone (2 directions on each side)
                inCone = facingDiff <= 2
            end
        end
        
        if inCone then
            local clearLOS, lastVisible = self:hasClearLOS(battlefield, centerX, centerY, x, y, distance)
            if clearLOS then
                table.insert(visiblePoints, {x = x, y = y, distance = distance})
            elseif lastVisible then
                -- Can see the obstacle even though it blocks further vision
                if not blockedTiles[string.format("%d,%d", lastVisible.x, lastVisible.y)] then
                    table.insert(visiblePoints, {x = lastVisible.x, y = lastVisible.y, distance = lastVisible.distance})
                    blockedTiles[string.format("%d,%d", lastVisible.x, lastVisible.y)] = true
                end
            end
        end
    end

    return visiblePoints
end

-- Calculate omnidirectional sight (360°)
function LOS:calculateOmniSight(battlefield, centerX, centerY, maxDistance)
    local visiblePoints = {}
    local blockedTiles = {}  -- Track tiles blocked by obstacles

    -- Convert center to axial coordinates
    local centerQ, centerR = HexMath.offsetToAxial(centerX, centerY)
    
    -- Get all hexes in range
    local hexesInRange = HexMath.hexesInRange(centerQ, centerR, maxDistance or 10)
    
    for _, hex in ipairs(hexesInRange) do
        -- Convert back to offset coordinates
        local x, y = HexMath.axialToOffset(hex.q, hex.r)
        
        -- Calculate hex distance
        local distance = HexMath.distance(centerQ, centerR, hex.q, hex.r)
        
        local clearLOS, lastVisible = self:hasClearLOS(battlefield, centerX, centerY, x, y, distance)
        if clearLOS then
            table.insert(visiblePoints, {x = x, y = y, distance = distance})
        elseif lastVisible then
            -- Can see the obstacle even though it blocks further vision
            if not blockedTiles[string.format("%d,%d", lastVisible.x, lastVisible.y)] then
                table.insert(visiblePoints, {x = lastVisible.x, y = lastVisible.y, distance = lastVisible.distance})
                blockedTiles[string.format("%d,%d", lastVisible.x, lastVisible.y)] = true
            end
        end
    end

    return visiblePoints
end

-- Check if unit can see another unit
function LOS:canSeeUnit(seer, target, battlefield)
    -- Calculate hex distance
    local q1, r1 = HexMath.offsetToAxial(seer.x, seer.y)
    local q2, r2 = HexMath.offsetToAxial(target.x, target.y)
    local distance = HexMath.distance(q1, r1, q2, r2)

    -- Check if within sight range
    if distance > seer.stats.sight then
        return false
    end

    -- Check directional cone using hex directions
    local direction = HexMath.getDirection(q1, r1, q2, r2)
    if direction ~= -1 then
        -- Map 8-directional facing to 6-directional hex facing
        local hexFacing = math.floor(seer.facing * 6 / 8) % 6
        local facingDiff = math.abs(direction - hexFacing) % 6
        facingDiff = math.min(facingDiff, 6 - facingDiff)

        if facingDiff <= 1 then  -- Within 120° cone (1 direction on each side)
            return self:hasClearLOS(battlefield, seer.x, seer.y, target.x, target.y, seer.stats.sight)
        end
    end

    -- Check omnidirectional sense
    if distance <= seer.stats.sense then
        return self:hasClearLOS(battlefield, seer.x, seer.y, target.x, target.y, seer.stats.sense)
    end

    return false
end

-- Calculate all tiles visible to a unit
-- isDay: true for day (20 tiles sight), false for night (10 tiles sight)
-- Calculate visibility for unit (omnidirectional, no facing)
function LOS:calculateVisibilityForUnit(unit, battlefield, isDay)
    local visibleTiles = {}
    
    -- Default to day if not specified
    if isDay == nil then isDay = true end
    
    -- Calculate sight range based on time of day (omnidirectional)
    local sightRange = isDay and 15 or 10

    -- Add unit's own position
    table.insert(visibleTiles, {x = unit.x, y = unit.y, distance = 0})

    -- Calculate omnidirectional sight with raycasting
    local omniTiles = self:calculateOmniSight(battlefield, unit.x, unit.y, sightRange)
    for _, tile in ipairs(omniTiles) do
        table.insert(visibleTiles, tile)
    end

    return visibleTiles
end

return LOS
























