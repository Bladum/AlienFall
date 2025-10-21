---Cover System - Directional Protection Mechanics
---
---Provides sophisticated directional cover mechanics where terrain and objects provide
---protection from specific hex face directions. Units behind walls, rocks, or obstacles
---receive defensive bonuses that penalize incoming attacks from covered directions.
---
---Cover Properties:
---  - 6-Directional: One cover value per hex face (N, NE, SE, S, SW, NW)
---  - Cover Values: 0-100 scale (0 = no cover, 50 = half cover, 100 = total cover)
---  - Directional: Cover only applies to attacks from specific directions
---  - Height-Based: Elevation differences affect cover effectiveness
---
---Cover Types:
---  - Low Cover (25-50): Small obstacles, debris, low walls
---  - Half Cover (50-75): Standard walls, large rocks, vehicles
---  - Full Cover (75-100): Thick walls, bunkers, fortifications
---  - Dynamic Cover: Destructible terrain can lose cover value when damaged
---
---Defensive Bonuses:
---  - Accuracy Penalty: Attackers suffer -10% to -50% hit chance
---  - Grazing Hits: Cover may convert hits to grazing damage (reduced)
---  - Critical Protection: High cover reduces critical hit chance
---  - Flanking Interaction: Flanking attacks ignore cover bonuses
---
---Terrain Cover Sources:
---  - Walls: Directional cover based on wall orientation
---  - Rocks/Boulders: Radial cover in all directions
---  - Trees/Vegetation: Light cover with concealment bonus
---  - Vehicles: Heavy cover but may explode if damaged
---  - Furniture: Light cover, easily destroyed
---
---Key Exports:
---  - getCoverValue(tile, direction): Returns cover value 0-100 for direction
---  - calculateCoverPenalty(coverValue): Converts cover to accuracy penalty
---  - applyCoverToAttack(attacker, target): Applies cover modifiers to attack
---  - updateCoverVisualization(tile): Updates UI cover indicators
---  - isCoverDestroyed(tile, direction): Checks if cover still exists
---
---Integration:
---  - Works with accuracy_system.lua for hit chance penalties
---  - Uses destructible_terrain_system.lua for dynamic cover
---  - Integrates with flanking_system.lua for cover bypass
---  - Connects to los_system.lua for line-of-sight cover
---
---@module battlescape.systems.cover_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CoverSystem = require("battlescape.systems.cover_system")
---  local coverValue = CoverSystem.getCoverValue(tile, attackDirection)
---  local penalty = CoverSystem.calculateCoverPenalty(coverValue)
---
---@see battlescape.battle_ecs.accuracy For hit chance integration
---@see battlescape.systems.flanking_system For cover bypass mechanics
---@see battlescape.systems.destructible_terrain_system For dynamic cover

local CoverSystem = {}

-- Configuration
local CONFIG = {
    -- Cover Value Thresholds
    NO_COVER = 0,
    LIGHT_COVER = 25,
    MEDIUM_COVER = 50,
    HEAVY_COVER = 75,
    FULL_COVER = 100,
    
    -- Accuracy Penalties (applied to attacker's accuracy)
    LIGHT_COVER_PENALTY = 10,   -- -10% accuracy
    MEDIUM_COVER_PENALTY = 25,  -- -25% accuracy
    HEAVY_COVER_PENALTY = 40,   -- -40% accuracy
    FULL_COVER_PENALTY = 60,    -- -60% accuracy (nearly impossible to hit)
    
    -- Terrain Cover Values
    TERRAIN_COVER = {
        WALL = 80,           -- Walls provide heavy cover
        ROCK = 70,           -- Rocks provide heavy cover
        TREE = 50,           -- Trees provide medium cover
        FENCE = 40,          -- Fences provide light-medium cover
        CRATE = 60,          -- Crates provide medium-heavy cover
        VEHICLE = 75,        -- Vehicles provide heavy cover
        DEBRIS = 35,         -- Debris provides light-medium cover
        BUSH = 20,           -- Bushes provide light cover
    },
    
    -- Height-Based Cover Bonuses
    HEIGHT_BONUS = 15,       -- +15 cover per level of height advantage
    MAX_HEIGHT_BONUS = 45,   -- Maximum +45 cover from height
    
    -- Crouching Bonus
    CROUCH_COVER_BONUS = 20, -- +20% cover when crouching
}

-- Hex direction vectors (for 6 hex faces)
-- Directions: 0=E, 1=NE, 2=NW, 3=W, 4=SW, 5=SE
local HEX_DIRECTIONS = {
    [0] = { q = 1, r = 0 },   -- East
    [1] = { q = 1, r = -1 },  -- Northeast
    [2] = { q = 0, r = -1 },  -- Northwest
    [3] = { q = -1, r = 0 },  -- West
    [4] = { q = -1, r = 1 },  -- Southwest
    [5] = { q = 0, r = 1 },   -- Southeast
}

-- Unit cover state (per unit)
-- Format: unitCover[unitId] = { [direction] = coverValue, isCrouching = bool }
local unitCover = {}

--[[
    Initialize cover for a unit
    
    @param unitId: Unit identifier
]]
function CoverSystem.initializeUnit(unitId)
    if not unitCover[unitId] then
        unitCover[unitId] = {
            [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0,
            isCrouching = false,
        }
        print(string.format("[CoverSystem] Initialized cover for unit %s", tostring(unitId)))
    end
end

--[[
    Remove unit from cover system
    
    @param unitId: Unit identifier
]]
function CoverSystem.removeUnit(unitId)
    unitCover[unitId] = nil
    print(string.format("[CoverSystem] Removed unit %s from cover system", tostring(unitId)))
end

--[[
    Calculate direction index from attacker to target (0-5)
    
    @param fromQ, fromR: Attacker hex coordinates
    @param toQ, toR: Target hex coordinates
    @return direction index (0-5), or nil if same hex
]]
function CoverSystem.calculateDirection(fromQ, fromR, toQ, toR)
    local dq = toQ - fromQ
    local dr = toR - fromR
    
    -- Same hex, no direction
    if dq == 0 and dr == 0 then
        return nil
    end
    
    -- Normalize to unit vector (approximate)
    local angle = math.atan2(dr, dq)
    
    -- Convert to hex direction (0-5)
    -- 0 degrees = East (direction 0)
    -- 60 degrees = Northeast (direction 1)
    -- etc.
    local directionIndex = math.floor((angle + math.pi) / (math.pi / 3) + 0.5) % 6
    
    return directionIndex
end

--[[
    Get opposite direction (for checking cover from attack direction)
    
    @param direction: Direction index (0-5)
    @return opposite direction index (0-5)
]]
function CoverSystem.getOppositeDirection(direction)
    return (direction + 3) % 6
end

--[[
    Update cover for a unit based on terrain at their position
    
    @param unitId: Unit identifier
    @param q, r: Unit hex position
    @param terrain: Terrain data for adjacent hexes (table of 6 terrains)
    @param height: Unit's height level (default 0)
]]
function CoverSystem.updateCoverFromTerrain(unitId, q, r, terrain, height)
    CoverSystem.initializeUnit(unitId)
    
    height = height or 0
    
    -- Check each of the 6 adjacent hexes for cover-providing terrain
    for direction = 0, 5 do
        local adjQ = q + HEX_DIRECTIONS[direction].q
        local adjR = r + HEX_DIRECTIONS[direction].r
        
        local coverValue = 0
        
        -- Get terrain type from adjacent hex
        if terrain and terrain[direction] then
            local terrainType = terrain[direction]
            coverValue = CONFIG.TERRAIN_COVER[terrainType] or 0
        end
        
        -- Store cover value for this direction
        unitCover[unitId][direction] = coverValue
    end
    
    print(string.format("[CoverSystem] Updated cover for unit %s at (%d,%d)", tostring(unitId), q, r))
end

--[[
    Get cover value from a specific direction
    
    @param unitId: Unit identifier
    @param direction: Direction index (0-5)
    @return cover value (0-100)
]]
function CoverSystem.getCoverFromDirection(unitId, direction)
    CoverSystem.initializeUnit(unitId)
    
    local baseCover = unitCover[unitId][direction] or 0
    local bonus = 0
    
    -- Add crouching bonus
    if unitCover[unitId].isCrouching then
        bonus = bonus + CONFIG.CROUCH_COVER_BONUS
    end
    
    local totalCover = math.min(100, baseCover + bonus)
    return totalCover
end

--[[
    Set unit crouching state (affects cover)
    
    @param unitId: Unit identifier
    @param isCrouching: Boolean
]]
function CoverSystem.setCrouching(unitId, isCrouching)
    CoverSystem.initializeUnit(unitId)
    unitCover[unitId].isCrouching = isCrouching
    print(string.format("[CoverSystem] Unit %s crouching: %s", tostring(unitId), tostring(isCrouching)))
end

--[[
    Calculate accuracy penalty from cover
    
    Called when an attack is made to reduce attacker's accuracy based on
    target's cover from the attack direction.
    
    @param attackerQ, attackerR: Attacker hex position
    @param targetId: Target unit identifier
    @param targetQ, targetR: Target hex position
    @param targetHeight: Target's height level (default 0)
    @param attackerHeight: Attacker's height level (default 0)
    @return accuracyPenalty: Percentage penalty to apply (0-60)
]]
function CoverSystem.calculateCoverValue(attackerQ, attackerR, targetId, targetQ, targetR, targetHeight, attackerHeight)
    CoverSystem.initializeUnit(targetId)
    
    targetHeight = targetHeight or 0
    attackerHeight = attackerHeight or 0
    
    -- Calculate attack direction (from attacker to target)
    local attackDirection = CoverSystem.calculateDirection(attackerQ, attackerR, targetQ, targetR)
    
    if not attackDirection then
        -- Same hex, no cover
        return 0
    end
    
    -- Get cover from the opposite direction (target's cover facing the attacker)
    local coverDirection = CoverSystem.getOppositeDirection(attackDirection)
    local coverValue = CoverSystem.getCoverFromDirection(targetId, coverDirection)
    
    -- Apply height-based modifications
    local heightDiff = targetHeight - attackerHeight
    if heightDiff > 0 then
        -- Target is higher, gets bonus cover
        local heightBonus = math.min(heightDiff * CONFIG.HEIGHT_BONUS, CONFIG.MAX_HEIGHT_BONUS)
        coverValue = math.min(100, coverValue + heightBonus)
    elseif heightDiff < 0 then
        -- Attacker is higher, target gets less cover
        local heightPenalty = math.min(math.abs(heightDiff) * CONFIG.HEIGHT_BONUS, CONFIG.MAX_HEIGHT_BONUS)
        coverValue = math.max(0, coverValue - heightPenalty)
    end
    
    -- Convert cover value to accuracy penalty
    local accuracyPenalty = 0
    if coverValue >= CONFIG.FULL_COVER then
        accuracyPenalty = CONFIG.FULL_COVER_PENALTY
    elseif coverValue >= CONFIG.HEAVY_COVER then
        accuracyPenalty = CONFIG.HEAVY_COVER_PENALTY
    elseif coverValue >= CONFIG.MEDIUM_COVER then
        accuracyPenalty = CONFIG.MEDIUM_COVER_PENALTY
    elseif coverValue >= CONFIG.LIGHT_COVER then
        accuracyPenalty = CONFIG.LIGHT_COVER_PENALTY
    end
    
    print(string.format("[CoverSystem] Attack from (%d,%d) to unit %s at (%d,%d): Cover=%d%%, Penalty=%d%%",
        attackerQ, attackerR, tostring(targetId), targetQ, targetR, coverValue, accuracyPenalty))
    
    return accuracyPenalty
end

--[[
    Get cover description for UI display
    
    @param coverValue: Cover value (0-100)
    @return description string, color
]]
function CoverSystem.getCoverDescription(coverValue)
    if coverValue >= CONFIG.FULL_COVER then
        return "Full Cover", { r = 0, g = 255, b = 0 }      -- Green
    elseif coverValue >= CONFIG.HEAVY_COVER then
        return "Heavy Cover", { r = 100, g = 200, b = 100 } -- Light green
    elseif coverValue >= CONFIG.MEDIUM_COVER then
        return "Medium Cover", { r = 255, g = 255, b = 0 }  -- Yellow
    elseif coverValue >= CONFIG.LIGHT_COVER then
        return "Light Cover", { r = 255, g = 200, b = 100 } -- Orange
    else
        return "No Cover", { r = 255, g = 100, b = 100 }    -- Red
    end
end

--[[
    Get visual cover data for UI display
    
    Returns cover values for all 6 directions for visualization
    
    @param unitId: Unit identifier
    @return table of cover values and descriptions for each direction
]]
function CoverSystem.visualizeCover(unitId)
    CoverSystem.initializeUnit(unitId)
    
    local visualization = {}
    for direction = 0, 5 do
        local coverValue = CoverSystem.getCoverFromDirection(unitId, direction)
        local desc, color = CoverSystem.getCoverDescription(coverValue)
        
        visualization[direction] = {
            value = coverValue,
            description = desc,
            color = color,
        }
    end
    
    return visualization
end

--[[
    Get all units' cover state (for debugging)
    
    @return table of all unit cover data
]]
function CoverSystem.getAllCover()
    return unitCover
end

return CoverSystem

























