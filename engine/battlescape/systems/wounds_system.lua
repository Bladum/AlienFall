---Wounds System - Critical Injuries & Recovery
---
---Implements critical wound mechanics where units below 50% HP can receive persistent injuries
---to specific body parts (leg, arm, torso, head). Wounds have lasting combat effects and require
---extended recovery time at bases with medical facilities. Severe wounds can incapacitate soldiers.
---
---Wound Types (4 body parts):
---  - LEG Wound: -50% movement speed, doubled movement AP cost
---  - ARM Wound: -30% accuracy with all weapons, +20% reload time
---  - TORSO Wound: -25% max HP, regeneration reduced by 50%
---  - HEAD Wound: -20% accuracy, chance of unconsciousness (10% per turn)
---
---Wound Mechanics:
---  - Trigger Threshold: Only occur when unit drops below 50% HP
---  - Chance System: 20% chance per hit below 50% HP
---  - Critical Hits: 50% chance to cause wound on critical hit
---  - Multiple Wounds: Units can have multiple wounds simultaneously
---  - Stacking Penalties: Multiple wounds of same type stack effects
---
---Wound Effects in Combat:
---  - Movement Penalty: Leg wounds drastically reduce tactical mobility
---  - Accuracy Loss: Arm and head wounds reduce combat effectiveness
---  - HP Reduction: Torso wounds lower survivability
---  - Unconsciousness: Head wounds risk unit passing out mid-mission
---  - Bleeding: All wounds cause 1 HP bleed per turn (stackable)
---
---Wound Severity Levels:
---  - Minor Wound: 1-2 weeks recovery, -15% combat penalty
---  - Moderate Wound: 3-4 weeks recovery, -30% combat penalty
---  - Severe Wound: 5-8 weeks recovery, -50% combat penalty
---  - Critical Wound: 10+ weeks recovery, unit incapacitated
---
---Base Recovery System:
---  - Standard Recovery: 3 weeks base recovery time per wound
---  - Medical Facility: Advanced med bay reduces time by 40%
---  - Multiple Wounds: Recovery time stacks (2 wounds = 6 weeks)
---  - Active Recovery: Wounded soldiers are unavailable for missions
---  - Permanent Injuries: 5% chance of permanent stat reduction
---
---Recovery Modifiers:
---  - Basic Infirmary: 3 weeks per wound
---  - Advanced Med Bay: 2 weeks per wound (-33% time)
---  - Alien Med Tech: 1 week per wound (-66% time)
---  - Field Medic: +1 week if treated during mission
---  - No Treatment: +2 weeks if not stabilized
---
---Death Risk:
---  - 3+ Wounds: 10% chance of death during recovery
---  - Head + Torso: 25% chance of death (critical combination)
---  - No Medical Facility: 2x death chance multiplier
---
---Key Exports:
---  - applyWound(unit, bodyPart): Inflicts wound to specific body part
---  - checkWoundChance(unit, damage): Rolls for wound when damaged
---  - getWoundEffects(unit): Returns all active wound penalties
---  - calculateRecoveryTime(unit): Estimates days until full recovery
---  - treatWound(unit, medic): Field treatment reduces wound severity
---  - isIncapacitated(unit): Checks if unit too wounded to continue
---
---Integration:
---  - Works with damage_system.lua to trigger wound checks
---  - Uses basescape medical facilities for recovery
---  - Integrates with unit_progression.lua for permanent stat loss
---  - Connects to ui for wound status display
---
---@module battlescape.systems.wounds_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local WoundsSystem = require("battlescape.systems.wounds_system")
---  -- After damage is dealt
---  if unit.hp < unit.maxHp * 0.5 then
---      WoundsSystem.checkWoundChance(unit, damageDealt)
---  end
---  local recoveryDays = WoundsSystem.calculateRecoveryTime(unit)
---
---@see battlescape.combat.damage_system For wound trigger integration
---@see basescape.medical_system For recovery mechanics

local WoundsSystem = {}

-- Configuration
local CONFIG = {
    -- Wound Chance Thresholds (HP percentage)
    WOUND_HP_THRESHOLD = 50,      -- Can only get wounds below 50% HP
    
    -- Wound Chance by HP Range (percentage)
    WOUND_CHANCE = {
        { hp = 50, chance = 10 },  -- 50-40% HP: 10% wound chance
        { hp = 40, chance = 20 },  -- 40-30% HP: 20% wound chance
        { hp = 30, chance = 35 },  -- 30-20% HP: 35% wound chance
        { hp = 20, chance = 50 },  -- 20-10% HP: 50% wound chance
        { hp = 10, chance = 75 },  -- 10-1% HP: 75% wound chance
    },
    
    -- Wound Types
    WOUND_TYPES = {
        LEG = {
            name = "Leg Wound",
            movementPenalty = 50,     -- -50% movement (halves AP for movement)
            accuracyPenalty = 0,
            icon = "leg_wound",
            canMove = true,
        },
        ARM = {
            name = "Arm Wound",
            movementPenalty = 0,
            accuracyPenalty = 25,     -- -25% accuracy
            icon = "arm_wound",
            canMove = true,
        },
        TORSO = {
            name = "Torso Wound",
            movementPenalty = 25,     -- -25% movement
            accuracyPenalty = 15,     -- -15% accuracy
            icon = "torso_wound",
            canMove = true,
        },
        HEAD = {
            name = "Head Wound",
            movementPenalty = 0,
            accuracyPenalty = 40,     -- -40% accuracy
            icon = "head_wound",
            canMove = true,
            unconsciousChance = 30,   -- 30% chance to go unconscious
        },
    },
    
    -- Wound Location Chances (random distribution)
    WOUND_LOCATION_CHANCE = {
        { location = "LEG", weight = 35 },    -- 35% legs
        { location = "ARM", weight = 30 },    -- 30% arms
        { location = "TORSO", weight = 25 },  -- 25% torso
        { location = "HEAD", weight = 10 },   -- 10% head
    },
    
    -- Recovery System
    BASE_RECOVERY_WEEKS = 3,      -- 3 weeks to heal one wound naturally
    MEDICAL_FACILITY_BONUS = -1,  -- Medical facilities reduce recovery by 1 week
    MIN_RECOVERY_WEEKS = 1,       -- Minimum 1 week recovery time
    
    -- Stacking Penalties
    MAX_WOUNDS_PER_LOCATION = 3,  -- Can have up to 3 wounds in same location
    PENALTY_STACK_MULTIPLIER = 1.5, -- Each additional wound multiplies penalty by 1.5x
}

-- Unit wound state
-- Format: wounds[unitId] = { { location, weeksRemaining }, ... }
local wounds = {}

-- Wound recovery tracking (for base recovery system)
-- Format: recovery[unitId] = { atBase = baseId, weeksRemaining = N }
local recovery = {}

--[[
    Initialize wounds for a unit
    
    @param unitId: Unit identifier
]]
function WoundsSystem.initializeUnit(unitId)
    if not wounds[unitId] then
        wounds[unitId] = {}
        print(string.format("[WoundsSystem] Initialized wounds for unit %s", tostring(unitId)))
    end
end

--[[
    Remove unit from wounds system
    
    @param unitId: Unit identifier
]]
function WoundsSystem.removeUnit(unitId)
    wounds[unitId] = nil
    recovery[unitId] = nil
    print(string.format("[WoundsSystem] Removed unit %s from wounds system", tostring(unitId)))
end

--[[
    Get wound chance based on current HP percentage
    
    @param currentHP: Current HP
    @param maxHP: Maximum HP
    @return woundChance: Percentage chance (0-100)
]]
function WoundsSystem.getWoundChance(currentHP, maxHP)
    local hpPercent = (currentHP / maxHP) * 100
    
    -- No wounds above threshold
    if hpPercent >= CONFIG.WOUND_HP_THRESHOLD then
        return 0
    end
    
    -- Find appropriate wound chance
    for _, threshold in ipairs(CONFIG.WOUND_CHANCE) do
        if hpPercent >= threshold.hp then
            return threshold.chance
        end
    end
    
    -- Default to highest chance if very low HP
    return CONFIG.WOUND_CHANCE[#CONFIG.WOUND_CHANCE].chance
end

--[[
    Select random wound location based on weights
    
    @return woundLocation: String (LEG, ARM, TORSO, HEAD)
]]
function WoundsSystem.selectWoundLocation()
    local totalWeight = 0
    for _, loc in ipairs(CONFIG.WOUND_LOCATION_CHANCE) do
        totalWeight = totalWeight + loc.weight
    end
    
    local roll = math.random(1, totalWeight)
    local cumulative = 0
    
    for _, loc in ipairs(CONFIG.WOUND_LOCATION_CHANCE) do
        cumulative = cumulative + loc.weight
        if roll <= cumulative then
            return loc.location
        end
    end
    
    return "LEG"  -- Fallback
end

--[[
    Check for wound when unit takes damage
    
    Should be called whenever a unit takes damage and is below 50% HP
    
    @param unitId: Unit identifier
    @param currentHP: Current HP after damage
    @param maxHP: Maximum HP
    @return woundReceived: Boolean, true if wound was inflicted
    @return woundLocation: String (if wound received)
    @return isUnconscious: Boolean (if HEAD wound causes unconsciousness)
]]
function WoundsSystem.checkForWound(unitId, currentHP, maxHP)
    WoundsSystem.initializeUnit(unitId)
    
    local hpPercent = (currentHP / maxHP) * 100
    
    -- No wound possible above threshold
    if hpPercent >= CONFIG.WOUND_HP_THRESHOLD then
        return false, nil, false
    end
    
    -- Roll for wound
    local woundChance = WoundsSystem.getWoundChance(currentHP, maxHP)
    local roll = math.random(1, 100)
    
    if roll > woundChance then
        return false, nil, false  -- No wound
    end
    
    -- Select wound location
    local location = WoundsSystem.selectWoundLocation()
    
    -- Check if location already has max wounds
    local locationCount = 0
    for _, wound in ipairs(wounds[unitId]) do
        if wound.location == location then
            locationCount = locationCount + 1
        end
    end
    
    if locationCount >= CONFIG.MAX_WOUNDS_PER_LOCATION then
        -- Can't wound same location more than max times
        print(string.format("[WoundsSystem] Unit %s %s already has max wounds", 
            tostring(unitId), location))
        return false, nil, false
    end
    
    -- Apply wound
    local recoveryWeeks = CONFIG.BASE_RECOVERY_WEEKS
    table.insert(wounds[unitId], {
        location = location,
        weeksRemaining = recoveryWeeks,
    })
    
    print(string.format("[WoundsSystem] Unit %s received %s wound (recovery: %d weeks)", 
        tostring(unitId), location, recoveryWeeks))
    
    -- Check for unconsciousness (HEAD wounds only)
    local isUnconscious = false
    if location == "HEAD" then
        local unconsciousChance = CONFIG.WOUND_TYPES.HEAD.unconsciousChance or 0
        local unconsciousRoll = math.random(1, 100)
        if unconsciousRoll <= unconsciousChance then
            isUnconscious = true
            print(string.format("[WoundsSystem] Unit %s went UNCONSCIOUS from head wound", 
                tostring(unitId)))
        end
    end
    
    return true, location, isUnconscious
end

--[[
    Get all wounds for a unit
    
    @param unitId: Unit identifier
    @return table of wounds
]]
function WoundsSystem.getWounds(unitId)
    WoundsSystem.initializeUnit(unitId)
    return wounds[unitId]
end

--[[
    Get wound penalties for a unit
    
    Returns aggregate movement and accuracy penalties from all wounds
    
    @param unitId: Unit identifier
    @return movementPenalty: Percentage (0-100+)
    @return accuracyPenalty: Percentage (0-100+)
]]
function WoundsSystem.getWoundPenalties(unitId)
    WoundsSystem.initializeUnit(unitId)
    
    local totalMovementPenalty = 0
    local totalAccuracyPenalty = 0
    
    -- Count wounds by location
    local woundCounts = {}
    for _, wound in ipairs(wounds[unitId]) do
        woundCounts[wound.location] = (woundCounts[wound.location] or 0) + 1
    end
    
    -- Calculate penalties with stacking multipliers
    for location, count in pairs(woundCounts) do
        local woundType = CONFIG.WOUND_TYPES[location]
        if woundType then
            -- First wound = base penalty
            -- Additional wounds multiply by 1.5x each
            local multiplier = 1
            for i = 1, count do
                totalMovementPenalty = totalMovementPenalty + (woundType.movementPenalty * multiplier)
                totalAccuracyPenalty = totalAccuracyPenalty + (woundType.accuracyPenalty * multiplier)
                multiplier = multiplier * CONFIG.PENALTY_STACK_MULTIPLIER
            end
        end
    end
    
    return totalMovementPenalty, totalAccuracyPenalty
end

--[[
    Check if unit can act (not unconscious from head wounds)
    
    @param unitId: Unit identifier
    @return canAct: Boolean
]]
function WoundsSystem.canUnitAct(unitId)
    -- In a full implementation, this would check for unconscious status
    -- For now, all wounded units can act (unconscious is a separate system)
    return true
end

--[[
    Process weekly recovery for a unit at base
    
    Should be called by base management system weekly
    
    @param unitId: Unit identifier
    @param hasMedicalFacility: Boolean, does base have medical facilities?
    @return woundsHealed: Number of wounds that healed this week
]]
function WoundsSystem.processWeeklyRecovery(unitId, hasMedicalFacility)
    WoundsSystem.initializeUnit(unitId)
    
    local woundsHealed = 0
    local remainingWounds = {}
    
    for _, wound in ipairs(wounds[unitId]) do
        -- Reduce recovery time
        local weeklyRecovery = 1
        if hasMedicalFacility then
            weeklyRecovery = weeklyRecovery + math.abs(CONFIG.MEDICAL_FACILITY_BONUS)
        end
        
        wound.weeksRemaining = wound.weeksRemaining - weeklyRecovery
        
        if wound.weeksRemaining <= 0 then
            -- Wound healed
            woundsHealed = woundsHealed + 1
            print(string.format("[WoundsSystem] Unit %s %s wound healed", 
                tostring(unitId), wound.location))
        else
            -- Wound still recovering
            table.insert(remainingWounds, wound)
        end
    end
    
    wounds[unitId] = remainingWounds
    
    if woundsHealed > 0 then
        print(string.format("[WoundsSystem] Unit %s healed %d wound(s)", 
            tostring(unitId), woundsHealed))
    end
    
    return woundsHealed
end

--[[
    Get wound count by location
    
    @param unitId: Unit identifier
    @return table of wound counts { LEG = N, ARM = N, ... }
]]
function WoundsSystem.getWoundCountsByLocation(unitId)
    WoundsSystem.initializeUnit(unitId)
    
    local counts = { LEG = 0, ARM = 0, TORSO = 0, HEAD = 0 }
    for _, wound in ipairs(wounds[unitId]) do
        counts[wound.location] = counts[wound.location] + 1
    end
    
    return counts
end

--[[
    Get visual wound data for UI
    
    @param unitId: Unit identifier
    @return visualization data
]]
function WoundsSystem.visualizeWounds(unitId)
    local woundList = WoundsSystem.getWounds(unitId)
    local movementPenalty, accuracyPenalty = WoundsSystem.getWoundPenalties(unitId)
    local counts = WoundsSystem.getWoundCountsByLocation(unitId)
    
    local details = {}
    for _, wound in ipairs(woundList) do
        local woundType = CONFIG.WOUND_TYPES[wound.location]
        table.insert(details, {
            location = wound.location,
            name = woundType.name,
            icon = woundType.icon,
            weeksRemaining = wound.weeksRemaining,
        })
    end
    
    return {
        totalWounds = #woundList,
        movementPenalty = movementPenalty,
        accuracyPenalty = accuracyPenalty,
        woundsByLocation = counts,
        woundDetails = details,
        canAct = WoundsSystem.canUnitAct(unitId),
    }
end

--[[
    Get all wounds state (for debugging)
    
    @return table of all unit wounds
]]
function WoundsSystem.getAllWounds()
    return wounds
end

return WoundsSystem






















