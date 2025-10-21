---FlankingSystem - Tactical Flanking Position Detection & Bonuses
---
---Calculates flanking positions relative to unit facing and applies tactical bonuses
---for accuracy, damage, and cover reduction. Integrates with hex-based combat system.
---
---Flanking Mechanics:
---  - FRONT: Attack from directly in front (no bonus)
---  - SIDE: Attack from side hexes (±10% accuracy, ×1.25 damage, ÷2 cover)
---  - REAR: Attack from directly behind (±25% accuracy, ×1.5 damage, no cover)
---
---Hex Direction System (0-5):
---         0
---       5   1
---     4       2
---       3
---
---Facing Conversion:
---  - 8-directional facing (0-7) converted to 6-directional hex (0-5)
---  - Facing 0 = hex direction 0 (front)
---  - Facing 2 = hex direction 1 (front-right)
---  - Facing 4 = hex direction 3 (rear)
---
---Features:
---  - Direction-based flanking detection using hex geometry
---  - Accuracy and damage multipliers
---  - Cover reduction based on flanking status
---  - Morale impacts
---  - Visual indicator flags
---
---Key Exports:
---  - FlankingSystem.new(hexMath): Creates flanking system
---  - getFlankingStatus(attacker, defender): Determines front/side/rear
---  - getDamageMultiplier(status): Returns damage multiplier
---  - getAccuracyBonus(status): Returns accuracy bonus
---  - getCoverMultiplier(status): Returns cover effectiveness
---  - getMoraleModifier(status): Returns morale impact
---  - canIgnoreCover(status): Returns if cover is negated
---
---Dependencies:
---  - battlescape.battle_ecs.hex_math: Hex coordinate calculations
---
---@module battlescape.combat.flanking_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FlankingSystem = require("battlescape.combat.flanking_system")
---  local HexMath = require("battlescape.battle_ecs.hex_math")
---  local flanking = FlankingSystem.new(HexMath)
---  
---  local status = flanking:getFlankingStatus(attacker, defender)
---  -- Returns: "front" | "side" | "rear"
---  
---  local damageMultiplier = flanking:getDamageMultiplier(status)
---  -- Returns: 1.0 | 1.25 | 1.5

-- Flanking Detection & Position Calculation System
-- Determines if attacker is flanking defender and applies tactical bonuses

local FlankingSystem = {}
FlankingSystem.__index = FlankingSystem

--- Flanking status enumeration
FlankingSystem.STATUS = {
    FRONT = "front",
    SIDE = "side",
    REAR = "rear",
    UNKNOWN = "unknown"
}

--- Flanking bonus definitions
--- Each status defines accuracy, damage, and cover modifiers
FlankingSystem.BONUSES = {
    front = {
        name = "Front",
        description = "Direct front attack - no bonuses",
        accuracyBonus = 0.0,           -- No accuracy bonus
        accuracyValue = 50,            -- Starting accuracy 50%
        damageMultiplier = 1.0,        -- ×1.0 (no change)
        coverMultiplier = 1.0,         -- Full cover effectiveness
        moraleImpact = 0.0,            -- No morale impact
        iconType = "attack_front",
        actionCost = 20                -- TU cost
    },
    
    side = {
        name = "Flanking",
        description = "Side attack - +10% accuracy, +25% damage, half cover",
        accuracyBonus = 0.1,           -- +10% accuracy
        accuracyValue = 60,            -- Starting accuracy 60%
        damageMultiplier = 1.25,       -- ×1.25 (+25% damage)
        coverMultiplier = 0.5,         -- Half cover effectiveness
        moraleImpact = 0.15,           -- 15% morale damage
        iconType = "attack_side",
        actionCost = 20                -- TU cost (same)
    },
    
    rear = {
        name = "Rear Attack",
        description = "Rear attack - +25% accuracy, +50% damage, no cover",
        accuracyBonus = 0.25,          -- +25% accuracy
        accuracyValue = 75,            -- Starting accuracy 75%
        damageMultiplier = 1.5,        -- ×1.5 (+50% damage)
        coverMultiplier = 0.0,         -- No cover effectiveness
        moraleImpact = 0.30,           -- 30% morale damage (psychological)
        iconType = "attack_rear",
        actionCost = 20                -- TU cost (same)
    }
}

--- Create flanking system
-- @param hexMath table HexMath module for coordinate calculations
-- @return table New FlankingSystem instance
function FlankingSystem.new(hexMath)
    print("[FlankingSystem] Initializing flanking system")
    
    local self = setmetatable({}, FlankingSystem)
    self.hexMath = hexMath or error("FlankingSystem requires HexMath module")
    
    return self
end

--- Determine flanking status between attacker and defender
-- Calculates if attacker is in front, side, or rear position relative to defender's facing
--
-- @param attacker table Attacker unit with x, y position
-- @param defender table Defender unit with x, y, facing properties
-- @return string Flanking status: "front" | "side" | "rear" | "unknown"
function FlankingSystem:getFlankingStatus(attacker, defender)
    -- Validate inputs
    if not attacker or not attacker.x or not attacker.y then
        print("[FlankingSystem] ERROR: Invalid attacker position")
        return FlankingSystem.STATUS.UNKNOWN
    end
    
    if not defender or not defender.x or not defender.y then
        print("[FlankingSystem] ERROR: Invalid defender position")
        return FlankingSystem.STATUS.UNKNOWN
    end
    
    -- Convert positions to axial hex coordinates
    local aq, ar = self.hexMath.offsetToAxial(attacker.x, attacker.y)
    local dq, dr = self.hexMath.offsetToAxial(defender.x, defender.y)
    
    -- Get direction from defender TO attacker (where attack is coming from)
    local direction = self.hexMath.getDirection(dq, dr, aq, ar)
    
    if direction == -1 then
        print("[FlankingSystem] ERROR: Could not calculate direction")
        return FlankingSystem.STATUS.UNKNOWN
    end
    
    -- Get defender's facing direction (0-5 hex directions)
    -- Facing ranges from 0-7 (8 directions) in some systems, convert to 0-5 (6 hex)
    local defenderFacing = 0
    
    if defender.facing then
        -- If facing is 0-7 (8-directional), convert to 0-5 (6-directional hex)
        if defender.facing > 5 then
            -- 8-directional system: convert 0-7 to 0-5
            -- Formula: round(facing * 6 / 8) mod 6
            defenderFacing = math.floor((defender.facing * 6 / 8) + 0.5) % 6
        else
            -- Already 6-directional
            defenderFacing = defender.facing % 6
        end
    end
    
    -- Calculate angular difference between direction and facing
    -- Difference of 0 = front, 1-2 = side, 3 = rear
    local diff = math.abs(direction - defenderFacing)
    
    -- Handle wrap-around (e.g., facing 0 and direction 5 should be 1 apart, not 5)
    if diff > 3 then
        diff = 6 - diff
    end
    
    -- Classify position based on angular difference
    local status
    if diff == 0 then
        -- Directly in front (0° difference)
        status = FlankingSystem.STATUS.FRONT
    elseif diff == 1 or diff == 5 then
        -- 60° or 300° difference (side hexes)
        status = FlankingSystem.STATUS.SIDE
    elseif diff >= 2 then
        -- 120°+ difference (rear hexes, including directly behind at 180°)
        status = FlankingSystem.STATUS.REAR
    else
        status = FlankingSystem.STATUS.UNKNOWN
    end
    
    print(string.format("[FlankingSystem] Flanking check: attacker(%d,%d) vs defender(%d,%d) facing=%d, direction=%d, diff=%d -> %s",
          attacker.x, attacker.y, defender.x, defender.y, defenderFacing, direction, diff, status))
    
    return status
end

--- Get damage multiplier for flanking status
-- @param status string Flanking status ("front" | "side" | "rear")
-- @return number Damage multiplier (1.0 | 1.25 | 1.5)
function FlankingSystem:getDamageMultiplier(status)
    local bonus = FlankingSystem.BONUSES[status]
    if not bonus then
        print("[FlankingSystem] WARNING: Unknown flanking status '" .. tostring(status) .. "'")
        return 1.0
    end
    
    return bonus.damageMultiplier
end

--- Get accuracy bonus percentage for flanking status
-- @param status string Flanking status ("front" | "side" | "rear")
-- @return number Accuracy bonus (0.0 | 0.1 | 0.25)
function FlankingSystem:getAccuracyBonus(status)
    local bonus = FlankingSystem.BONUSES[status]
    if not bonus then
        print("[FlankingSystem] WARNING: Unknown flanking status '" .. tostring(status) .. "'")
        return 0.0
    end
    
    return bonus.accuracyBonus
end

--- Get accuracy value (base percentage) for flanking status
-- Starting accuracy percentage for attacks from this position
-- @param status string Flanking status ("front" | "side" | "rear")
-- @return number Base accuracy percentage (50 | 60 | 75)
function FlankingSystem:getAccuracyValue(status)
    local bonus = FlankingSystem.BONUSES[status]
    if not bonus then
        print("[FlankingSystem] WARNING: Unknown flanking status '" .. tostring(status) .. "'")
        return 50
    end
    
    return bonus.accuracyValue
end

--- Get cover multiplier for flanking status
-- Determines how effective cover is against attack from this position
-- 1.0 = full cover, 0.5 = half cover, 0.0 = no cover
--
-- @param status string Flanking status ("front" | "side" | "rear")
-- @return number Cover multiplier (1.0 | 0.5 | 0.0)
function FlankingSystem:getCoverMultiplier(status)
    local bonus = FlankingSystem.BONUSES[status]
    if not bonus then
        print("[FlankingSystem] WARNING: Unknown flanking status '" .. tostring(status) .. "'")
        return 1.0
    end
    
    return bonus.coverMultiplier
end

--- Check if cover is completely ignored for this flanking status
-- @param status string Flanking status
-- @return boolean True if cover provides no protection
function FlankingSystem:canIgnoreCover(status)
    return self:getCoverMultiplier(status) == 0.0
end

--- Get morale impact modifier for flanking status
-- Additional morale damage beyond normal damage morale effects
-- @param status string Flanking status
-- @return number Morale impact (0.0 | 0.15 | 0.30)
function FlankingSystem:getMoraleModifier(status)
    local bonus = FlankingSystem.BONUSES[status]
    if not bonus then
        print("[FlankingSystem] WARNING: Unknown flanking status '" .. tostring(status) .. "'")
        return 0.0
    end
    
    return bonus.moraleImpact
end

--- Get human-readable description of flanking status
-- @param status string Flanking status
-- @return string Description text
function FlankingSystem:getDescription(status)
    local bonus = FlankingSystem.BONUSES[status]
    if not bonus then
        return "Unknown position"
    end
    
    return bonus.description
end

--- Get icon type for UI display
-- @param status string Flanking status
-- @return string Icon identifier for UI rendering
function FlankingSystem:getIconType(status)
    local bonus = FlankingSystem.BONUSES[status]
    if not bonus then
        return "unknown"
    end
    
    return bonus.iconType
end

--- Calculate combined tactical bonus info
-- Returns all bonuses in one structure for attack preview
-- @param attacker table Attacker unit
-- @param defender table Defender unit
-- @return table Tactical info with all bonuses
function FlankingSystem:getTacticalInfo(attacker, defender)
    local status = self:getFlankingStatus(attacker, defender)
    
    return {
        status = status,
        description = self:getDescription(status),
        damageMultiplier = self:getDamageMultiplier(status),
        accuracyBonus = self:getAccuracyBonus(status),
        accuracyValue = self:getAccuracyValue(status),
        coverMultiplier = self:getCoverMultiplier(status),
        moraleModifier = self:getMoraleModifier(status),
        canIgnoreCover = self:canIgnoreCover(status),
        iconType = self:getIconType(status)
    }
end

--- Get all flanking status names
-- @return table Array of status names
function FlankingSystem:getAllStatuses()
    return {
        FlankingSystem.STATUS.FRONT,
        FlankingSystem.STATUS.SIDE,
        FlankingSystem.STATUS.REAR
    }
end

--- Get all bonus definitions
-- @return table Bonuses table
function FlankingSystem:getAllBonuses()
    return FlankingSystem.BONUSES
end

--- Create debug info string for position analysis
-- @param attacker table Attacker unit
-- @param defender table Defender unit
-- @return string Debug information
function FlankingSystem:getDebugInfo(attacker, defender)
    local status = self:getFlankingStatus(attacker, defender)
    local info = ""
    
    info = info .. string.format("Attacker: (%d, %d)\n", attacker.x, attacker.y)
    info = info .. string.format("Defender: (%d, %d) facing=%d\n", defender.x, defender.y, defender.facing or 0)
    info = info .. string.format("Flanking Status: %s\n", status)
    info = info .. string.format("Damage: ×%.2f\n", self:getDamageMultiplier(status))
    info = info .. string.format("Accuracy: +%.0f%%\n", self:getAccuracyBonus(status) * 100)
    info = info .. string.format("Cover: ×%.2f\n", self:getCoverMultiplier(status))
    info = info .. string.format("Morale: +%.0f%%\n", self:getMoraleModifier(status) * 100)
    
    return info
end

return FlankingSystem



