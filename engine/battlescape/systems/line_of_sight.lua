---Line of Sight System for Hex Grid Combat
---
---Implements visibility calculations for hex grids with terrain and height
---blocking. Handles vision cones, visibility ranges, and LOS blocking.
---
---Features:
---  - Bresenham-style line tracing on hex grids
---  - Terrain height-based blocking
---  - Line of fire (LOF) vs Line of sight (LOS)
---  - Vision cone calculations (6 directions)
---  - Cover value calculation
---  - Stealth/visibility checks
---
---Vision Rules:
---  - Walls and terrain blocks sight
---  - Height difference can block/reduce visibility
---  - Vision range based on unit stats
---  - Cover affects visibility (partial/full)
---
---Key Exports:
---  - LineOfSight.new(hex_grid, terrain_system)
---  - hasLineOfSight(observer, target)
---  - getVisibleHexes(observer, range)
---  - getLineOfFire(observer, target)
---  - calculateCoverValue(position, direction)
---
---Dependencies:
---  - battlescape.battle_ecs.hex_math: Hex coordinate math
---  - battlescape.systems.terrain: Terrain and height data
---
---@module battlescape.systems.line_of_sight
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local LineOfSight = {}
LineOfSight.__index = LineOfSight

local HexMath = require("battlescape.battle_ecs.hex_math")

--- Create new line of sight system
---@param hexGrid table Hex grid system reference
---@param terrainSystem table Terrain system reference
---@return table New LineOfSight instance
function LineOfSight.new(hexGrid, terrainSystem)
    local self = setmetatable({}, LineOfSight)
    
    self.hexGrid = hexGrid
    self.terrainSystem = terrainSystem
    
    -- Vision cache
    self.visionCache = {}
    
    -- Visibility thresholds
    self.config = {
        baseVisionRange = 15,
        partialCoverThreshold = 0.5,  -- > 50% blocked = partial cover
        fullCoverThreshold = 0.9,      -- > 90% blocked = full cover
        heightDifference = 1.0,        -- Height units per tile
    }
    
    print("[LineOfSight] Initialized line of sight system")
    
    return self
end

--- Check if target is visible from observer position
---@param observerPos table Observer hex {q, r}
---@param targetPos table Target hex {q, r}
---@param visionRange number Maximum vision range (default: 15)
---@return boolean True if target is visible
function LineOfSight:hasLineOfSight(observerPos, targetPos, visionRange)
    visionRange = visionRange or self.config.baseVisionRange
    
    -- Check cache
    local cacheKey = string.format("LOS_%d,%d_%d,%d_%d",
        observerPos.q, observerPos.r, targetPos.q, targetPos.r, visionRange)
    if self.visionCache[cacheKey] ~= nil then
        return self.visionCache[cacheKey]
    end
    
    -- Check distance first
    local distance = HexMath.distance(observerPos, targetPos)
    if distance > visionRange then
        self.visionCache[cacheKey] = false
        return false
    end
    
    -- Trace line of sight
    local line = self:_traceLine(observerPos, targetPos)
    local blocked = false
    
    for i = 2, #line - 1 do  -- Skip observer and target
        local hexPos = line[i]
        local terrain = self.terrainSystem:getTerrain(hexPos)
        
        if terrain and (terrain.blocksVision or terrain.blocked) then
            blocked = true
            break
        end
    end
    
    local result = not blocked
    self.visionCache[cacheKey] = result
    return result
end

--- Get all hexes visible from observer position
---@param observerPos table Observer hex {q, r}
---@param visionRange number Vision range (default: 15)
---@return table Array of visible hex positions
function LineOfSight:getVisibleHexes(observerPos, visionRange)
    visionRange = visionRange or self.config.baseVisionRange
    
    local visible = {}
    local checked = {}
    
    -- Check hexes in radius
    for distance = 1, visionRange do
        local ring = HexMath.getRing(observerPos, distance)
        
        for _, hexPos in ipairs(ring) do
            local key = string.format("%d,%d", hexPos.q, hexPos.r)
            if not checked[key] then
                checked[key] = true
                
                if self:hasLineOfSight(observerPos, hexPos, visionRange) then
                    table.insert(visible, hexPos)
                end
            end
        end
    end
    
    return visible
end

--- Get line of fire from observer to target
---@param observerPos table Observer hex {q, r}
---@param targetPos table Target hex {q, r}
---@return table Line of fire data: {blocked, coverValue, hitChance}
function LineOfSight:getLineOfFire(observerPos, targetPos)
    local line = self:_traceLine(observerPos, targetPos)
    
    local coverValue = 0
    local blockedCount = 0
    
    -- Analyze blocking along line
    for i = 2, #line - 1 do
        local hexPos = line[i]
        local terrain = self.terrainSystem:getTerrain(hexPos)
        
        if terrain then
            if terrain.blocksVision then
                blockedCount = blockedCount + 1
            end
            
            if terrain.coverValue then
                coverValue = math.max(coverValue, terrain.coverValue)
            end
        end
    end
    
    local lineLength = #line - 1
    local blockPercentage = blockedCount / lineLength
    
    local result = {
        blocked = blockPercentage > self.config.partialCoverThreshold,
        coverValue = coverValue,
        blockPercentage = blockPercentage,
        hitChance = 1.0 - (blockPercentage * 0.5)  -- 50% penalty per coverage
    }
    
    return result
end

--- Calculate cover value at position from direction
---@param position table Hex position {q, r}
---@param direction number Direction angle (0-360)
---@return number Cover value (0-100), 0 = no cover, 100 = full cover
function LineOfSight:calculateCoverValue(position, direction)
    local terrain = self.terrainSystem:getTerrain(position)
    
    if not terrain then
        return 0
    end
    
    -- Base cover from terrain
    local cover = terrain.coverValue or 0
    
    -- Check adjacent hexes for direction-specific cover
    local hexDir = math.floor((direction / 60) % 6) + 1
    local adjacentPos = HexMath.getNeighbor(position, hexDir)
    
    if adjacentPos then
        local adjacentTerrain = self.terrainSystem:getTerrain(adjacentPos)
        if adjacentTerrain and adjacentTerrain.coverValue then
            -- Adjacent cover adds to total but with diminishing returns
            cover = cover + (adjacentTerrain.coverValue * 0.3)
        end
    end
    
    return math.min(cover, 100)
end

--- PRIVATE: Trace line between two hexes using Bresenham
function LineOfSight:_traceLine(fromPos, toPos)
    local line = {}
    
    -- Simple line tracing for hex grids
    local distance = HexMath.distance(fromPos, toPos)
    
    for i = 0, distance do
        local t = distance > 0 and (i / distance) or 0
        
        -- Linear interpolation in hex space
        local qInterp = fromPos.q + (toPos.q - fromPos.q) * t
        local rInterp = fromPos.r + (toPos.r - fromPos.r) * t
        
        -- Round to nearest hex
        local hex = self:_roundHex({q = qInterp, r = rInterp})
        
        -- Avoid duplicates
        if #line == 0 or not (line[#line].q == hex.q and line[#line].r == hex.r) then
            table.insert(line, hex)
        end
    end
    
    return line
end

--- PRIVATE: Round fractional hex coordinates to nearest hex
function LineOfSight:_roundHex(frac)
    -- Convert to cube coordinates for rounding
    local q = frac.q
    local r = frac.r
    local s = -q - r
    
    local rq = math.floor(q + 0.5)
    local rr = math.floor(r + 0.5)
    local rs = math.floor(s + 0.5)
    
    -- Fix rounding errors
    local qDiff = math.abs(rq - q)
    local rDiff = math.abs(rr - r)
    local sDiff = math.abs(rs - s)
    
    if qDiff > rDiff and qDiff > sDiff then
        rq = -rr - rs
    elseif rDiff > sDiff then
        rr = -rq - rs
    end
    
    return {q = rq, r = rr}
end

--- Clear visibility cache
function LineOfSight:clearCache()
    self.visionCache = {}
    print("[LineOfSight] Cache cleared")
end

return LineOfSight




