---Flanking System - Tactical Positioning Bonuses
---
---Implements flanking mechanics where attacking from sides or rear provides significant
---accuracy and damage bonuses. Uses 6-directional hex facing system. Flanking attacks
---bypass target's cover bonuses, rewarding tactical positioning and maneuver warfare.
---
---Facing Directions (6 Hex Directions):
---  - Direction 0: Front (North)
---  - Direction 1: Front-Right (NE)
---  - Direction 2: Rear-Right (SE)
---  - Direction 3: Rear (South)
---  - Direction 4: Rear-Left (SW)
---  - Direction 5: Front-Left (NW)
---
---Flank Types:
---  - Front Attack: No bonus (directions 0, 1, 5)
---  - Side Flank: +10% accuracy, partial cover bypass (directions 1, 5)
---  - Rear Flank: +25% accuracy, +25% damage, full cover negation (directions 2, 3, 4)
---
---Tactical Benefits:
---  - Cover Negation: Flanking attacks ignore target's cover bonuses
---  - Damage Amplification: Rear attacks deal significantly more damage
---  - Accuracy Enhancement: Side and rear attacks have higher hit chance
---  - Panic Induction: Flanked units more susceptible to morale loss
---
---Facing Mechanics:
---  - Units rotate to face last attacker or direction moved
---  - Facing persists between turns until unit takes action
---  - Rotation affects both offensive and defensive positioning
---  - Overwatch units automatically face detected threats
---
---Key Exports:
---  - calculateFlankType(attacker, target): Returns flank type (front/side/rear)
---  - getFlankBonus(flankType): Returns accuracy and damage bonuses
---  - updateFacing(unit, newDirection): Rotates unit facing
---  - shouldIgnoreCover(flankType): Checks if flanking negates cover
---
---Integration:
---  - Works with accuracy_system.lua for hit chance calculations
---  - Uses cover_system.lua to negate cover bonuses
---  - Integrates with morale_system.lua for panic mechanics
---  - Connects to ai_system.lua for positioning decisions
---
---@module battlescape.systems.flanking_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FlankingSystem = require("battlescape.systems.flanking_system")
---  local flankType = FlankingSystem.calculateFlankType(attacker, target)
---  local bonus = FlankingSystem.getFlankBonus(flankType)
---  FlankingSystem.updateFacing(unit, 3) -- Face south
---
---@see battlescape.battle_ecs.accuracy For hit chance integration
---@see battlescape.systems.cover_system For cover negation mechanics
---@see battlescape.battle_ecs.hex_math For direction calculations

local FlankingSystem = {}

-- Configuration
local CONFIG = {
    -- Flanking Zones (relative to facing direction)
    FLANK_ZONES = {
        FRONT = { directions = { 0 }, accuracyBonus = 0, damageBonus = 0 },
        FRONT_SIDE = { directions = { 1, 5 }, accuracyBonus = 5, damageBonus = 0 },
        SIDE = { directions = { 2, 4 }, accuracyBonus = 10, damageBonus = 0 },
        REAR = { directions = { 3 }, accuracyBonus = 25, damageBonus = 25 },
    },
    
    -- Default Facing Direction
    DEFAULT_FACING = 0,  -- East
    
    -- AP Cost for Rotation
    ROTATION_AP_COST = 0,  -- Free rotation (0 AP), or set to 1 for tactical rotation
    
    -- Cover Negation
    FLANKING_NEGATES_COVER = true,  -- Flanking attacks ignore target's cover
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

-- Unit facing state
-- Format: unitFacing[unitId] = directionIndex (0-5)
local unitFacing = {}

--[[
    Initialize unit facing
    
    @param unitId: Unit identifier
    @param initialFacing: Initial facing direction (0-5), default 0
]]
function FlankingSystem.initializeUnit(unitId, initialFacing)
    unitFacing[unitId] = initialFacing or CONFIG.DEFAULT_FACING
    print(string.format("[FlankingSystem] Initialized unit %s facing direction %d", 
        tostring(unitId), unitFacing[unitId]))
end

--[[
    Remove unit from flanking system
    
    @param unitId: Unit identifier
]]
function FlankingSystem.removeUnit(unitId)
    unitFacing[unitId] = nil
    print(string.format("[FlankingSystem] Removed unit %s from flanking system", tostring(unitId)))
end

--[[
    Set unit facing direction
    
    @param unitId: Unit identifier
    @param direction: Direction index (0-5)
]]
function FlankingSystem.setUnitFacing(unitId, direction)
    if not unitFacing[unitId] then
        FlankingSystem.initializeUnit(unitId)
    end
    
    unitFacing[unitId] = direction % 6
    print(string.format("[FlankingSystem] Unit %s now facing direction %d", 
        tostring(unitId), unitFacing[unitId]))
end

--[[
    Get unit facing direction
    
    @param unitId: Unit identifier
    @return direction: Direction index (0-5)
]]
function FlankingSystem.getUnitFacing(unitId)
    if not unitFacing[unitId] then
        FlankingSystem.initializeUnit(unitId)
    end
    return unitFacing[unitId]
end

--[[
    Rotate unit facing
    
    @param unitId: Unit identifier
    @param clockwise: Boolean, true for clockwise, false for counter-clockwise
    @return newFacing: New facing direction
    @return apCost: AP cost for rotation
]]
function FlankingSystem.rotateUnit(unitId, clockwise)
    local currentFacing = FlankingSystem.getUnitFacing(unitId)
    local newFacing
    
    if clockwise then
        newFacing = (currentFacing + 1) % 6
    else
        newFacing = (currentFacing - 1 + 6) % 6
    end
    
    FlankingSystem.setUnitFacing(unitId, newFacing)
    
    return newFacing, CONFIG.ROTATION_AP_COST
end

--[[
    Calculate attack direction from attacker to target
    
    @param attackerQ, attackerR: Attacker position
    @param targetQ, targetR: Target position
    @return direction: Direction index (0-5)
]]
function FlankingSystem.calculateAttackDirection(attackerQ, attackerR, targetQ, targetR)
    local dq = targetQ - attackerQ
    local dr = targetR - targetR
    
    -- Calculate angle
    local angle = math.atan2(dr, dq)
    
    -- Convert to hex direction (0-5)
    local directionIndex = math.floor((angle + math.pi) / (math.pi / 3) + 0.5) % 6
    
    return directionIndex
end

--[[
    Get relative direction from target's facing to attack direction
    
    @param targetFacing: Target's facing direction (0-5)
    @param attackDirection: Direction attack is coming from (0-5)
    @return relativeDirection: Relative direction (0-5)
]]
function FlankingSystem.getRelativeDirection(targetFacing, attackDirection)
    -- Calculate difference (how many 60° steps from facing to attack)
    local diff = (attackDirection - targetFacing + 6) % 6
    return diff
end

--[[
    Determine flank zone based on relative direction
    
    @param relativeDirection: Relative direction (0-5)
    @return flankZone: String (FRONT, FRONT_SIDE, SIDE, REAR)
]]
function FlankingSystem.getFlankZone(relativeDirection)
    -- Map relative directions to flank zones
    -- 0 = front, 1/5 = front-side, 2/4 = side, 3 = rear
    if relativeDirection == 0 then
        return "FRONT"
    elseif relativeDirection == 1 or relativeDirection == 5 then
        return "FRONT_SIDE"
    elseif relativeDirection == 2 or relativeDirection == 4 then
        return "SIDE"
    elseif relativeDirection == 3 then
        return "REAR"
    end
    
    return "FRONT"
end

--[[
    Check if attack is flanking
    
    @param attackerQ, attackerR: Attacker position
    @param targetId: Target unit identifier
    @param targetQ, targetR: Target position
    @return isFlanking: Boolean
    @return flankZone: String (FRONT, SIDE, REAR, etc.)
]]
function FlankingSystem.isFlankingAttack(attackerQ, attackerR, targetId, targetQ, targetR)
    local targetFacing = FlankingSystem.getUnitFacing(targetId)
    local attackDirection = FlankingSystem.calculateAttackDirection(attackerQ, attackerR, targetQ, targetR)
    local relativeDirection = FlankingSystem.getRelativeDirection(targetFacing, attackDirection)
    local flankZone = FlankingSystem.getFlankZone(relativeDirection)
    
    local isFlanking = (flankZone == "SIDE" or flankZone == "REAR" or flankZone == "FRONT_SIDE")
    
    return isFlanking, flankZone
end

--[[
    Get flanking bonuses for an attack
    
    @param attackerQ, attackerR: Attacker position
    @param targetId: Target unit identifier
    @param targetQ, targetR: Target position
    @return accuracyBonus: Percentage bonus (0-25)
    @return damageBonus: Percentage bonus (0-25)
    @return flankZone: String
    @return negatesCover: Boolean
]]
function FlankingSystem.getFlankBonus(attackerQ, attackerR, targetId, targetQ, targetR)
    local isFlanking, flankZone = FlankingSystem.isFlankingAttack(attackerQ, attackerR, targetId, targetQ, targetR)
    
    local zoneData = CONFIG.FLANK_ZONES[flankZone]
    local accuracyBonus = zoneData and zoneData.accuracyBonus or 0
    local damageBonus = zoneData and zoneData.damageBonus or 0
    local negatesCover = isFlanking and CONFIG.FLANKING_NEGATES_COVER or false
    
    if isFlanking then
        print(string.format("[FlankingSystem] Flanking attack! Zone=%s, Accuracy=+%d%%, Damage=+%d%%, NegatesCover=%s",
            flankZone, accuracyBonus, damageBonus, tostring(negatesCover)))
    end
    
    return accuracyBonus, damageBonus, flankZone, negatesCover
end

--[[
    Auto-face unit toward target (convenience function)
    
    @param unitId: Unit identifier
    @param unitQ, unitR: Unit position
    @param targetQ, targetR: Target position
]]
function FlankingSystem.faceToward(unitId, unitQ, unitR, targetQ, targetR)
    local direction = FlankingSystem.calculateAttackDirection(unitQ, unitR, targetQ, targetR)
    FlankingSystem.setUnitFacing(unitId, direction)
end

--[[
    Get facing direction name for UI
    
    @param direction: Direction index (0-5)
    @return name: String
]]
function FlankingSystem.getFacingName(direction)
    local names = {
        [0] = "East",
        [1] = "Northeast",
        [2] = "Northwest",
        [3] = "West",
        [4] = "Southwest",
        [5] = "Southeast",
    }
    return names[direction] or "Unknown"
end

--[[
    Visualize flanking data for UI
    
    @param attackerQ, attackerR: Attacker position
    @param targetId: Target unit identifier
    @param targetQ, targetR: Target position
    @return visualization data
]]
function FlankingSystem.visualizeFlanking(attackerQ, attackerR, targetId, targetQ, targetR)
    local isFlanking, flankZone = FlankingSystem.isFlankingAttack(attackerQ, attackerR, targetId, targetQ, targetR)
    local accuracyBonus, damageBonus, _, negatesCover = FlankingSystem.getFlankBonus(attackerQ, attackerR, targetId, targetQ, targetR)
    local targetFacing = FlankingSystem.getUnitFacing(targetId)
    
    local color
    if flankZone == "REAR" then
        color = { r = 255, g = 50, b = 50 }      -- Red (best)
    elseif flankZone == "SIDE" then
        color = { r = 255, g = 150, b = 50 }     -- Orange (good)
    elseif flankZone == "FRONT_SIDE" then
        color = { r = 255, g = 255, b = 100 }    -- Yellow (minor)
    else
        color = { r = 150, g = 150, b = 150 }    -- Gray (none)
    end
    
    return {
        isFlanking = isFlanking,
        flankZone = flankZone,
        accuracyBonus = accuracyBonus,
        damageBonus = damageBonus,
        negatesCover = negatesCover,
        targetFacing = targetFacing,
        targetFacingName = FlankingSystem.getFacingName(targetFacing),
        color = color,
    }
end

--[[
    Get all unit facing data (for debugging)
    
    @return table of all unit facing
]]
function FlankingSystem.getAllFacing()
    return unitFacing
end

return FlankingSystem






















