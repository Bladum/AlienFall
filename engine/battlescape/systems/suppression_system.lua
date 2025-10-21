---Suppression System - Pin Down Enemies with Heavy Fire
---
---Implements suppression mechanics where sustained heavy fire near a unit applies suppression
---status. Suppressed units suffer reduced combat effectiveness, movement restrictions, and morale
---penalties. Tactical use of suppressive fire can control enemy positioning and deny areas.
---
---Suppression Accumulation:
---  - Nearby Hits: +1 suppression per shot within 2 hexes
---  - Near Misses: +0.5 suppression per shot within 1 hex
---  - Explosions: +2 suppression per explosion within 3 hexes
---  - Burst Fire: +3 suppression per full-auto burst nearby
---  - Heavy Weapons: +1.5x suppression multiplier for HMGs/LMGs
---
---Suppression Threshold:
---  - Activation: 3+ suppression points triggers suppressed status
---  - Duration: Lasts 2 turns by default
---  - Decay: -1 suppression per turn if no new fire
---  - Stacking: Can accumulate up to 10 suppression points
---  - Immunity: Cannot suppress units with >80 morale
---
---Suppressed Status Effects:
---  - Accuracy Penalty: -30% hit chance with all weapons
---  - Movement Restrictions: Cannot move more than 3 hexes per turn
---  - Panic Check: Must pass morale check to move (50% chance)
---  - Cover Bonus: Suppressed units cannot leave cover voluntarily
---  - Reaction Fire: Cannot use overwatch while suppressed
---
---Morale Impact:
---  - Morale Drain: -5 morale per turn while suppressed
---  - Panic Risk: 20% chance to panic if morale below 40
---  - Rally Penalty: -50% effectiveness of rally actions
---  - Berserk: Low morale + suppression can trigger berserk state
---
---Tactical Suppression Uses:
---  - Area Denial: Suppress enemies to control movement
---  - Flanking Setup: Pin down target while teammates flank
---  - Extraction Cover: Suppress enemies during evacuation
---  - Defensive Position: Suppress attackers to buy time
---  - HMG Dominance: Heavy weapons excel at suppression
---
---Heavy Weapons Suppression:
---  - Light Machine Gun: 2x suppression radius (4 hexes)
---  - Heavy Machine Gun: 3x suppression, ignores partial cover
---  - Autocannon: Explosive rounds add +2 suppression
---  - Grenade Launcher: Area suppression on explosion
---
---Visual Indicators:
---  - Suppression Bar: Shows current suppression level (0-10)
---  - Status Icon: Skull icon above suppressed units
---  - Animation: Units duck/flinch when suppressed
---  - Hex Overlay: Red gradient on suppressed unit tiles
---
---Key Exports:
---  - addSuppression(unit, amount): Increases suppression points
---  - updateSuppression(unit): Processes suppression decay and effects
---  - isSuppressed(unit): Checks if unit has suppressed status
---  - getSuppression Level(unit): Returns current suppression (0-10)
---  - canMove(unit): Checks if unit can move despite suppression
---  - calculateSuppressionPenalty(unit): Returns accuracy/morale penalties
---
---Integration:
---  - Works with shooting_system.lua to trigger suppression
---  - Uses morale_system.lua for panic and morale drain
---  - Integrates with movement_system.lua for movement restrictions
---  - Connects to ui for suppression status display
---
---@module battlescape.systems.suppression_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local SuppressionSystem = require("battlescape.systems.suppression_system")
---  -- When shot lands near unit
---  SuppressionSystem.addSuppression(nearbyUnit, 1)
---  -- Check suppression before movement
---  if SuppressionSystem.isSuppressed(unit) then
---      local canMove = SuppressionSystem.canMove(unit) -- Morale check
---  end
---
---@see battlescape.battle_ecs.shooting For suppression triggers
---@see battlescape.systems.morale_system For morale integration

local SuppressionSystem = {}

-- Configuration
local CONFIG = {
    -- Suppression Thresholds
    SUPPRESSION_THRESHOLD = 3,   -- Need 3+ suppression points to be suppressed
    MAX_SUPPRESSION = 10,         -- Maximum suppression points
    
    -- Suppression Duration
    SUPPRESSION_DURATION = 2,     -- Lasts 2 turns once triggered
    
    -- Suppression Sources & Points
    SUPPRESSION_POINTS = {
        NEAR_HIT = 1,            -- Shot lands within 2 hexes
        DIRECT_HIT = 2,          -- Shot hits the unit directly
        EXPLOSION_NEAR = 2,      -- Explosion within 3 hexes
        EXPLOSION_DIRECT = 3,    -- Explosion hits the unit
        HEAVY_WEAPON = 1,        -- Bonus point for machine guns, etc.
    },
    
    -- Suppression Effects
    ACCURACY_PENALTY = 30,        -- -30% accuracy when suppressed
    MORALE_DRAIN_PER_TURN = 5,   -- -5 morale per turn while suppressed
    MOVEMENT_PANIC_CHANCE = 60,  -- 60% chance to panic when trying to move
    
    -- Suppression Radius
    NEAR_HIT_RADIUS = 2,          -- Hexes within this radius count as "near"
    EXPLOSION_RADIUS = 3,         -- Explosion suppression radius
    
    -- Decay
    DECAY_PER_TURN = 2,           -- Suppression points decay by 2 per turn
}

-- Unit suppression state
-- Format: suppression[unitId] = { points, duration, isSuppressed }
local suppression = {}

--[[
    Initialize suppression for a unit
    
    @param unitId: Unit identifier
]]
function SuppressionSystem.initializeUnit(unitId)
    if not suppression[unitId] then
        suppression[unitId] = {
            points = 0,
            duration = 0,
            isSuppressed = false,
        }
        print(string.format("[SuppressionSystem] Initialized suppression for unit %s", tostring(unitId)))
    end
end

--[[
    Remove unit from suppression system
    
    @param unitId: Unit identifier
]]
function SuppressionSystem.removeUnit(unitId)
    suppression[unitId] = nil
    print(string.format("[SuppressionSystem] Removed unit %s from suppression system", tostring(unitId)))
end

--[[
    Add suppression event (shot/explosion near/at unit)
    
    @param unitId: Unit identifier
    @param eventType: Type of suppression event (NEAR_HIT, DIRECT_HIT, etc.)
    @param isHeavyWeapon: Boolean, if source is heavy weapon (adds bonus)
]]
function SuppressionSystem.addSuppressionEvent(unitId, eventType, isHeavyWeapon)
    SuppressionSystem.initializeUnit(unitId)
    
    local points = CONFIG.SUPPRESSION_POINTS[eventType] or 0
    
    -- Add heavy weapon bonus
    if isHeavyWeapon then
        points = points + CONFIG.SUPPRESSION_POINTS.HEAVY_WEAPON
    end
    
    -- Add suppression points
    local state = suppression[unitId]
    state.points = math.min(CONFIG.MAX_SUPPRESSION, state.points + points)
    
    -- Check if unit becomes suppressed
    if not state.isSuppressed and state.points >= CONFIG.SUPPRESSION_THRESHOLD then
        state.isSuppressed = true
        state.duration = CONFIG.SUPPRESSION_DURATION
        print(string.format("[SuppressionSystem] Unit %s is now SUPPRESSED (points=%d)", 
            tostring(unitId), state.points))
    else
        print(string.format("[SuppressionSystem] Unit %s suppression points: %d", 
            tostring(unitId), state.points))
    end
end

--[[
    Add suppression from a shot event
    
    Convenience function for common shot scenarios
    
    @param unitId: Unit identifier
    @param isDirectHit: Boolean, did shot hit the unit?
    @param distance: Distance from shot to unit (if not direct hit)
    @param isHeavyWeapon: Boolean, is source a heavy weapon?
]]
function SuppressionSystem.addSuppressionFromShot(unitId, isDirectHit, distance, isHeavyWeapon)
    if isDirectHit then
        SuppressionSystem.addSuppressionEvent(unitId, "DIRECT_HIT", isHeavyWeapon)
    elseif distance and distance <= CONFIG.NEAR_HIT_RADIUS then
        SuppressionSystem.addSuppressionEvent(unitId, "NEAR_HIT", isHeavyWeapon)
    end
end

--[[
    Add suppression from an explosion event
    
    @param unitId: Unit identifier
    @param isDirectHit: Boolean, was unit at explosion center?
    @param distance: Distance from explosion to unit
]]
function SuppressionSystem.addSuppressionFromExplosion(unitId, isDirectHit, distance)
    if isDirectHit then
        SuppressionSystem.addSuppressionEvent(unitId, "EXPLOSION_DIRECT", false)
    elseif distance and distance <= CONFIG.EXPLOSION_RADIUS then
        SuppressionSystem.addSuppressionEvent(unitId, "EXPLOSION_NEAR", false)
    end
end

--[[
    Check if unit is suppressed
    
    @param unitId: Unit identifier
    @return isSuppressed: Boolean
]]
function SuppressionSystem.isUnitSuppressed(unitId)
    SuppressionSystem.initializeUnit(unitId)
    return suppression[unitId].isSuppressed
end

--[[
    Get suppression state for a unit
    
    @param unitId: Unit identifier
    @return state table with points, duration, isSuppressed
]]
function SuppressionSystem.getSuppressionState(unitId)
    SuppressionSystem.initializeUnit(unitId)
    return {
        points = suppression[unitId].points,
        duration = suppression[unitId].duration,
        isSuppressed = suppression[unitId].isSuppressed,
    }
end

--[[
    Get accuracy penalty for suppressed unit
    
    @param unitId: Unit identifier
    @return accuracyPenalty: Percentage penalty (0 or 30)
]]
function SuppressionSystem.getAccuracyPenalty(unitId)
    if SuppressionSystem.isUnitSuppressed(unitId) then
        return CONFIG.ACCURACY_PENALTY
    end
    return 0
end

--[[
    Check if unit can move without panic check
    
    Suppressed units must pass a panic check to move
    
    @param unitId: Unit identifier
    @return canMove: Boolean (true if not suppressed)
    @return panicChance: Panic chance percentage if suppressed
]]
function SuppressionSystem.checkMovementAllowed(unitId)
    if SuppressionSystem.isUnitSuppressed(unitId) then
        return false, CONFIG.MOVEMENT_PANIC_CHANCE
    end
    return true, 0
end

--[[
    Attempt to move while suppressed (requires panic check)
    
    @param unitId: Unit identifier
    @return success: Boolean, true if panic check passed
]]
function SuppressionSystem.attemptSuppressedMovement(unitId)
    if not SuppressionSystem.isUnitSuppressed(unitId) then
        return true  -- Not suppressed, can move freely
    end
    
    -- Roll panic check
    local roll = math.random(1, 100)
    local success = roll > CONFIG.MOVEMENT_PANIC_CHANCE
    
    if success then
        print(string.format("[SuppressionSystem] Unit %s overcame suppression to move (roll=%d)", 
            tostring(unitId), roll))
    else
        print(string.format("[SuppressionSystem] Unit %s failed to move due to suppression (roll=%d)", 
            tostring(unitId), roll))
    end
    
    return success
end

--[[
    Clear suppression from a unit
    
    @param unitId: Unit identifier
]]
function SuppressionSystem.clearSuppression(unitId)
    SuppressionSystem.initializeUnit(unitId)
    suppression[unitId].points = 0
    suppression[unitId].duration = 0
    suppression[unitId].isSuppressed = false
    print(string.format("[SuppressionSystem] Cleared suppression for unit %s", tostring(unitId)))
end

--[[
    Process turn-end for suppression system
    
    Handles:
    - Duration countdown for suppressed units
    - Suppression point decay
    - Morale drain integration point
    
    @param unitId: Unit identifier
    @return moraleDrain: Amount of morale to drain (for morale system integration)
]]
function SuppressionSystem.processTurn(unitId)
    SuppressionSystem.initializeUnit(unitId)
    
    local state = suppression[unitId]
    local moraleDrain = 0
    
    if state.isSuppressed then
        -- Apply morale drain
        moraleDrain = CONFIG.MORALE_DRAIN_PER_TURN
        
        -- Countdown duration
        state.duration = state.duration - 1
        
        if state.duration <= 0 then
            -- Suppression expires
            state.isSuppressed = false
            state.duration = 0
            print(string.format("[SuppressionSystem] Unit %s suppression expired", tostring(unitId)))
        else
            print(string.format("[SuppressionSystem] Unit %s suppressed for %d more turns", 
                tostring(unitId), state.duration))
        end
    end
    
    -- Decay suppression points
    if state.points > 0 then
        state.points = math.max(0, state.points - CONFIG.DECAY_PER_TURN)
        print(string.format("[SuppressionSystem] Unit %s suppression decayed to %d points", 
            tostring(unitId), state.points))
    end
    
    return moraleDrain
end

--[[
    Get suppression level description for UI
    
    @param points: Suppression points (0-10)
    @return description, color
]]
function SuppressionSystem.getSuppressionDescription(points)
    if points >= CONFIG.SUPPRESSION_THRESHOLD then
        return "SUPPRESSED", { r = 255, g = 50, b = 50 }    -- Red
    elseif points >= 2 then
        return "Under Fire", { r = 255, g = 150, b = 50 }   -- Orange
    elseif points >= 1 then
        return "Taking Fire", { r = 255, g = 255, b = 100 } -- Yellow
    else
        return "No Suppression", { r = 150, g = 150, b = 150 } -- Gray
    end
end

--[[
    Get visual suppression data for UI
    
    @param unitId: Unit identifier
    @return visualization data
]]
function SuppressionSystem.visualizeSuppression(unitId)
    local state = SuppressionSystem.getSuppressionState(unitId)
    local desc, color = SuppressionSystem.getSuppressionDescription(state.points)
    
    return {
        points = state.points,
        maxPoints = CONFIG.MAX_SUPPRESSION,
        isSuppressed = state.isSuppressed,
        duration = state.duration,
        description = desc,
        color = color,
        accuracyPenalty = state.isSuppressed and CONFIG.ACCURACY_PENALTY or 0,
        moraleDrain = state.isSuppressed and CONFIG.MORALE_DRAIN_PER_TURN or 0,
    }
end

--[[
    Get all suppression state (for debugging)
    
    @return table of all unit suppression data
]]
function SuppressionSystem.getAllSuppression()
    return suppression
end

return SuppressionSystem

























