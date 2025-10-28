---Line of Sight (LOS) System - Vision & Fog of War (Vertical Axial Hex)
---
---Implements hex-based line of sight using shadowcasting algorithm for tactical combat.
---Uses UNIVERSAL VERTICAL AXIAL coordinate system for all visibility calculations.
---
---COORDINATE SYSTEM: Vertical Axial (Flat-Top Hexagons)
---  - All positions use axial coordinates {q, r}
---  - LOS calculation: HexMath.hexLine(q1, r1, q2, r2)
---  - Vision range: HexMath.hexesInRange(q, r, radius)
---  - Distance: HexMath.distance(q1, r1, q2, r2)
---
---DESIGN REFERENCE: design/mechanics/hex_vertical_axial_system.md
---
---@module battlescape.systems.los_system
---@see engine.battlescape.battle_ecs.hex_math For hex mathematics

local HexMath = require("engine.battlescape.battle_ecs.hex_math")
local LOSSystem = {}

-- Configuration
local CONFIG = {
    -- Vision Range by Time of Day
    VISION_RANGE = {
        DAY = 20,          -- 20 hexes during day
        DUSK = 15,         -- 15 hexes at dusk/dawn
        NIGHT = 10,        -- 10 hexes at night
    },
    
    -- Obstacle Types
    OBSTACLE_BLOCK = {
        NONE = 0,           -- Transparent (no blocking)
        PARTIAL = 1,        -- Partially blocks (reduces vision)
        FULL = 2,           -- Fully blocks (stops vision)
    },
    
    -- Terrain Obstacle Values
    TERRAIN_OBSTACLES = {
        WALL = 2,           -- Full block
        TREE = 1,           -- Partial block
        FENCE = 1,          -- Partial block
        SMOKE = 1,          -- Partial block (density-based)
        ROCK = 2,           -- Full block
        VEHICLE = 2,        -- Full block
        DEBRIS = 1,         -- Partial block
        CRATE = 1,          -- Partial block
        BUSH = 0,           -- Transparent
    },
    
    -- Height-Based Vision
    HEIGHT_VISION_BONUS = 5,    -- +5 hex range per level higher
    HEIGHT_SEE_OVER = 1,        -- Can see over obstacles 1 level lower
    
    -- Smoke Density Threshold
    SMOKE_BLOCK_DENSITY = 5,    -- Smoke density ≥5 blocks vision
}

-- Per-unit visible tiles
-- Format: visibility[unitId] = { [hexKey] = true }
local visibility = {}

-- Per-team fog of war (discovered tiles)
-- Format: fogOfWar[teamId] = { [hexKey] = true }
local fogOfWar = {}

-- Current time of day (for vision range calculation)
local timeOfDay = "DAY"  -- DAY, DUSK, or NIGHT

--[[
    Generate hex key for lookup
    
    @param q, r: Hex coordinates
    @return string key
]]
local function hexKey(q, r)
    return string.format("%d,%d", q, r)
end

--[[
    Initialize LOS for a unit
    
    @param unitId: Unit identifier
]]
function LOSSystem.initializeUnit(unitId)
    if not visibility[unitId] then
        visibility[unitId] = {}
        print(string.format("[LOSSystem] Initialized LOS for unit %s", tostring(unitId)))
    end
end

--[[
    Remove unit from LOS system
    
    @param unitId: Unit identifier
]]
function LOSSystem.removeUnit(unitId)
    visibility[unitId] = nil
    print(string.format("[LOSSystem] Removed unit %s from LOS system", tostring(unitId)))
end

--[[
    Initialize fog of war for a team
    
    @param teamId: Team identifier
]]
function LOSSystem.initializeTeam(teamId)
    if not fogOfWar[teamId] then
        fogOfWar[teamId] = {}
        print(string.format("[LOSSystem] Initialized fog of war for team %s", tostring(teamId)))
    end
end

--[[
    Set time of day (affects vision range)
    
    @param tod: String - "DAY", "DUSK", or "NIGHT"
]]
function LOSSystem.setTimeOfDay(tod)
    timeOfDay = tod
    print(string.format("[LOSSystem] Time of day set to %s", tod))
end

--[[
    Get current vision range based on time of day
    
    @param unitHeight: Unit's height level (optional bonus)
    @return visionRange: Number of hexes
]]
function LOSSystem.getVisionRange(unitHeight)
    unitHeight = unitHeight or 0
    
    local baseRange = CONFIG.VISION_RANGE[timeOfDay] or CONFIG.VISION_RANGE.DAY
    local heightBonus = unitHeight * CONFIG.HEIGHT_VISION_BONUS
    
    return baseRange + heightBonus
end

--[[
    Check if terrain blocks LOS
    
    @param terrainType: Terrain type string
    @param smokeDensity: Smoke density (0-10, optional)
    @return blockLevel: 0=none, 1=partial, 2=full
]]
function LOSSystem.getTerrainBlockLevel(terrainType, smokeDensity)
    smokeDensity = smokeDensity or 0
    
    -- Check smoke blocking
    if smokeDensity >= CONFIG.SMOKE_BLOCK_DENSITY then
        return CONFIG.OBSTACLE_BLOCK.PARTIAL
    end
    
    -- Check terrain blocking
    local blockLevel = CONFIG.TERRAIN_OBSTACLES[terrainType]
    if blockLevel then
        return blockLevel
    end
    
    return CONFIG.OBSTACLE_BLOCK.NONE
end

--[[
    Hex distance calculation
    
    @param q1, r1: First hex coordinates
    @param q2, r2: Second hex coordinates
    @return distance: Integer distance in hexes
]]
function LOSSystem.hexDistance(q1, r1, q2, r2)
    local dq = q2 - q1
    local dr = r2 - r1
    return math.max(math.abs(dq), math.abs(dr), math.abs(dq + dr))
end

--[[
    Trace LOS from origin to target
    
    Uses line interpolation to check each hex along the path
    
    @param originQ, originR: Origin hex
    @param targetQ, targetR: Target hex
    @param getTerrainFunc: Function(q, r) returning {terrainType, smokeDensity, height}
    @param originHeight: Origin height level
    @param targetHeight: Target height level
    @return canSee: Boolean
    @return blockedAt: Hex coordinates where blocked (if canSee=false)
]]
function LOSSystem.traceLOS(originQ, originR, targetQ, targetR, getTerrainFunc, originHeight, targetHeight)
    originHeight = originHeight or 0
    targetHeight = targetHeight or 0
    
    -- Same hex, can always see
    if originQ == targetQ and originR == targetR then
        return true, nil
    end
    
    local distance = LOSSystem.hexDistance(originQ, originR, targetQ, targetR)
    
    -- Check each hex along the line
    for i = 1, distance - 1 do  -- Don't check origin or target
        local t = i / distance
        local q = math.floor(originQ + t * (targetQ - originQ) + 0.5)
        local r = math.floor(originR + t * (targetR - originR) + 0.5)
        
        -- Get terrain data for this hex
        local terrainData = getTerrainFunc(q, r)
        local terrainType = terrainData.terrainType or "FLOOR"
        local smokeDensity = terrainData.smokeDensity or 0
        local hexHeight = terrainData.height or 0
        
        -- Check if observer can see over this obstacle
        local heightDiff = originHeight - hexHeight
        if heightDiff >= CONFIG.HEIGHT_SEE_OVER then
            -- Can see over this obstacle
            -- print(string.format("[LOSSystem] Can see over obstacle at (%d,%d), height diff=%d", q, r, heightDiff))
        else
            -- Check blocking
            local blockLevel = LOSSystem.getTerrainBlockLevel(terrainType, smokeDensity)
            
            if blockLevel == CONFIG.OBSTACLE_BLOCK.FULL then
                -- Fully blocked
                return false, { q = q, r = r }
            elseif blockLevel == CONFIG.OBSTACLE_BLOCK.PARTIAL then
                -- Partial block - could implement chance here, but for now treat as blocked
                return false, { q = q, r = r }
            end
        end
    end
    
    return true, nil
end

--[[
    Update visible tiles for a unit using shadowcasting
    
    Simplified implementation - uses radial check with LOS tracing
    
    @param unitId: Unit identifier
    @param unitQ, unitR: Unit hex position
    @param unitTeam: Team identifier
    @param getTerrainFunc: Function(q, r) returning terrain data
    @param unitHeight: Unit's height level (optional)
]]
function LOSSystem.updateUnitVision(unitId, unitQ, unitR, unitTeam, getTerrainFunc, unitHeight)
    LOSSystem.initializeUnit(unitId)
    LOSSystem.initializeTeam(unitTeam)
    
    unitHeight = unitHeight or 0
    
    -- Clear current visibility
    visibility[unitId] = {}
    
    -- Get vision range
    local visionRange = LOSSystem.getVisionRange(unitHeight)
    
    -- Check all hexes within range
    for q = unitQ - visionRange, unitQ + visionRange do
        for r = unitR - visionRange, unitR + visionRange do
            local distance = LOSSystem.hexDistance(unitQ, unitR, q, r)
            
            if distance <= visionRange then
                -- Check LOS
                local canSee, blockedAt = LOSSystem.traceLOS(unitQ, unitR, q, r, getTerrainFunc, unitHeight, 0)
                
                if canSee then
                    local key = hexKey(q, r)
                    visibility[unitId][key] = true
                    
                    -- Add to team fog of war (discovered tiles)
                    fogOfWar[unitTeam][key] = true
                end
            end
        end
    end
    
    print(string.format("[LOSSystem] Updated vision for unit %s at (%d,%d): %d tiles visible", 
        tostring(unitId), unitQ, unitR, LOSSystem.countVisibleTiles(unitId)))
end

--[[
    Check if unit can see a specific hex
    
    @param unitId: Unit identifier
    @param q, r: Hex coordinates
    @return isVisible: Boolean
]]
function LOSSystem.isHexVisibleToUnit(unitId, q, r)
    LOSSystem.initializeUnit(unitId)
    local key = hexKey(q, r)
    return visibility[unitId][key] == true
end

--[[
    Check if hex is discovered by team (in fog of war)
    
    @param teamId: Team identifier
    @param q, r: Hex coordinates
    @return isDiscovered: Boolean
]]
function LOSSystem.isHexDiscoveredByTeam(teamId, q, r)
    LOSSystem.initializeTeam(teamId)
    local key = hexKey(q, r)
    return fogOfWar[teamId][key] == true
end

--[[
    Check if unit can see another unit
    
    @param observerUnitId: Observer unit identifier
    @param targetQ, targetR: Target hex coordinates
    @return canSee: Boolean
]]
function LOSSystem.canUnitSee(observerUnitId, targetQ, targetR)
    return LOSSystem.isHexVisibleToUnit(observerUnitId, targetQ, targetR)
end

--[[
    Count visible tiles for a unit
    
    @param unitId: Unit identifier
    @return count: Number of visible tiles
]]
function LOSSystem.countVisibleTiles(unitId)
    LOSSystem.initializeUnit(unitId)
    
    local count = 0
    for _ in pairs(visibility[unitId]) do
        count = count + 1
    end
    
    return count
end

--[[
    Get all visible hexes for a unit
    
    @param unitId: Unit identifier
    @return table of visible hex coordinates { {q, r}, ... }
]]
function LOSSystem.getVisibleHexes(unitId)
    LOSSystem.initializeUnit(unitId)
    
    local hexes = {}
    for key, _ in pairs(visibility[unitId]) do
        local q, r = key:match("([^,]+),([^,]+)")
        table.insert(hexes, { q = tonumber(q), r = tonumber(r) })
    end
    
    return hexes
end

--[[
    Clear all visibility and fog of war (for new mission)
]]
function LOSSystem.clearAll()
    visibility = {}
    fogOfWar = {}
    print("[LOSSystem] Cleared all visibility and fog of war")
end

--[[
    Get debug visualization data
    
    @param unitId: Unit identifier
    @return visualization data
]]
function LOSSystem.visualizeVision(unitId)
    local visibleHexes = LOSSystem.getVisibleHexes(unitId)
    
    return {
        unitId = unitId,
        visibleTileCount = #visibleHexes,
        visionRange = LOSSystem.getVisionRange(0),
        timeOfDay = timeOfDay,
        visibleHexes = visibleHexes,
    }
end

return LOSSystem


























