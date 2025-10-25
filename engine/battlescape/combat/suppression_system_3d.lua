-- Phase 4.2: Advanced Suppression & Morale System for 3D Combat
-- Suppression tracking, morale effects, AI behavior changes, panic mechanics

local SuppressionSystem = {}

-- Suppression levels
local SUPPRESSION_LEVEL_NONE = 0
local SUPPRESSION_LEVEL_LOW = 30
local SUPPRESSION_LEVEL_MEDIUM = 60
local SUPPRESSION_LEVEL_HIGH = 90

-- Morale states
local MORALE_STATE_CONFIDENT = "confident"
local MORALE_STATE_NORMAL = "normal"
local MORALE_STATE_SHAKEN = "shaken"
local MORALE_STATE_PANICKED = "panicked"
local MORALE_STATE_BROKEN = "broken"

function SuppressionSystem.new()
    local self = {}
    self.suppressionLog = {}  -- Track suppression events
    self.moraleLog = {}       -- Track morale changes

    return setmetatable(self, { __index = SuppressionSystem })
end

-- Apply suppression to unit
-- Args:
--   unit: unit to suppress
--   suppressionAmount: amount to add (0-100)
-- Returns:
--   new suppression level
function SuppressionSystem:applySuppression(unit, suppressionAmount)
    if not unit then return 0 end

    if not unit.suppressionLevel then
        unit.suppressionLevel = 0
    end

    unit.suppressionLevel = math.min(100, unit.suppressionLevel + suppressionAmount)

    -- Log suppression
    table.insert(self.suppressionLog, {
        unit = unit.id or "Unit",
        amount = suppressionAmount,
        newLevel = unit.suppressionLevel,
        timestamp = love.timer.getTime()
    })

    -- Update unit behavior
    self:updateSuppressionBehavior(unit)

    return unit.suppressionLevel
end

-- Reduce suppression each turn
-- Args:
--   unit: unit
--   reduction: amount to reduce (default 15)
function SuppressionSystem:reduceSuppression(unit, reduction)
    if not unit then return end

    reduction = reduction or 15

    if not unit.suppressionLevel then
        unit.suppressionLevel = 0
    end

    unit.suppressionLevel = math.max(0, unit.suppressionLevel - reduction)

    -- Update behavior
    self:updateSuppressionBehavior(unit)
end

-- Update unit behavior based on suppression
-- Args:
--   unit: unit
function SuppressionSystem:updateSuppressionBehavior(unit)
    if not unit then return end

    local supp = unit.suppressionLevel or 0

    if supp < SUPPRESSION_LEVEL_LOW then
        unit.isSuppressed = false
        unit.suppressionBehavior = "normal"
        unit.weaponPenalty = (unit.weaponPenalty or 0) - 5
    elseif supp < SUPPRESSION_LEVEL_MEDIUM then
        unit.isSuppressed = true
        unit.suppressionBehavior = "cautious"
        unit.weaponPenalty = (unit.weaponPenalty or 0) + 10
        unit.movementPenalty = (unit.movementPenalty or 0) + 0.2
    elseif supp < SUPPRESSION_LEVEL_HIGH then
        unit.isSuppressed = true
        unit.suppressionBehavior = "pinned"
        unit.weaponPenalty = (unit.weaponPenalty or 0) + 25
        unit.movementPenalty = (unit.movementPenalty or 0) + 0.5
        unit.canMove = false  -- Cannot move
    else
        unit.isSuppressed = true
        unit.suppressionBehavior = "suppressed"
        unit.weaponPenalty = (unit.weaponPenalty or 0) + 50
        unit.movementPenalty = 1.0
        unit.canMove = false
        unit.canAct = false  -- Cannot act
    end
end

-- Get suppression level name
function SuppressionSystem:getSuppressionLevelName(level)
    if level < SUPPRESSION_LEVEL_LOW then
        return "Normal"
    elseif level < SUPPRESSION_LEVEL_MEDIUM then
        return "Suppressed"
    elseif level < SUPPRESSION_LEVEL_HIGH then
        return "Pinned Down"
    else
        return "Heavily Suppressed"
    end
end

-- Apply morale change to unit
-- Args:
--   unit: unit
--   moraleChange: amount to change (-30 to +30)
--   reason: string description
-- Returns:
--   new morale state
function SuppressionSystem:applyMoraleChange(unit, moraleChange, reason)
    if not unit then return nil end

    if not unit.morale then
        unit.morale = 100
    end

    unit.morale = math.max(0, math.min(100, unit.morale + moraleChange))

    -- Log morale change
    table.insert(self.moraleLog, {
        unit = unit.id or "Unit",
        change = moraleChange,
        newMorale = unit.morale,
        reason = reason or "Unknown",
        timestamp = love.timer.getTime()
    })

    -- Update morale state
    self:updateMoraleState(unit)

    return unit.moraleState
end

-- Update unit morale state
-- Args:
--   unit: unit
function SuppressionSystem:updateMoraleState(unit)
    if not unit then return end

    local morale = unit.morale or 100

    if morale >= 80 then
        unit.moraleState = MORALE_STATE_CONFIDENT
        unit.moraleBonus = 1.2  -- +20% bonus
    elseif morale >= 60 then
        unit.moraleState = MORALE_STATE_NORMAL
        unit.moraleBonus = 1.0
    elseif morale >= 40 then
        unit.moraleState = MORALE_STATE_SHAKEN
        unit.moraleBonus = 0.9  -- -10% penalty
    elseif morale >= 20 then
        unit.moraleState = MORALE_STATE_PANICKED
        unit.moraleBonus = 0.7  -- -30% penalty
    else
        unit.moraleState = MORALE_STATE_BROKEN
        unit.moraleBonus = 0.5  -- -50% penalty
        unit.isMoraleBroken = true
    end
end

-- Check if unit will flee (panic mechanic)
-- Args:
--   unit: unit to check
-- Returns:
--   true if unit should flee
function SuppressionSystem:shouldFlee(unit)
    if not unit then return false end

    -- Dead units don't flee
    if not unit.alive then return false end

    -- Broken morale + heavy suppression = flee
    if unit.moraleState == MORALE_STATE_BROKEN and
       unit.suppressionLevel and unit.suppressionLevel > 70 then
        return true
    end

    -- Critical health + panicked morale = flee
    if unit.health and unit.maxHealth then
        local healthPercent = (unit.health / unit.maxHealth) * 100
        if healthPercent < 20 and unit.moraleState == MORALE_STATE_PANICKED then
            return true
        end
    end

    return false
end

-- Get morale effect on accuracy
-- Args:
--   unit: unit
-- Returns:
--   accuracy multiplier (0.5 - 1.2)
function SuppressionSystem:getMoraleAccuracyModifier(unit)
    if not unit then return 1.0 end

    return unit.moraleBonus or 1.0
end

-- Get morale effect on defense
-- Args:
--   unit: unit
-- Returns:
--   defense multiplier (0.7 - 1.2)
function SuppressionSystem:getMoraleDefenseModifier(unit)
    if not unit then return 1.0 end

    -- Good morale = better defense (dodging, reactions)
    -- Bad morale = worse defense (frozen in fear)
    if unit.moraleState == MORALE_STATE_CONFIDENT then
        return 1.2
    elseif unit.moraleState == MORALE_STATE_NORMAL then
        return 1.0
    elseif unit.moraleState == MORALE_STATE_SHAKEN then
        return 0.9
    elseif unit.moraleState == MORALE_STATE_PANICKED then
        return 0.7
    else  -- BROKEN
        return 0.5
    end
end

-- Calculate witness damage morale penalty
-- Args:
--   unit: unit witnessing damage
--   damage: damage amount witnessed
--   isAlly: whether victim is ally (true) or enemy (false)
-- Returns:
--   morale penalty
function SuppressionSystem:calculateWitnessMoralePenalty(unit, damage, isAlly)
    if not unit then return 0 end

    local basePenalty = math.ceil(damage / 5)

    -- Witnessing ally damage is worse
    if isAlly then
        basePenalty = basePenalty * 2
    end

    return basePenalty
end

-- Apply witness damage to nearby units
-- Args:
--   damagedUnit: unit that took damage
--   damageAmount: amount of damage
--   allUnits: list of all units
--   hexDistance: function to calculate hex distance
-- Returns:
--   table of affected units
function SuppressionSystem:applyWitnessDamage(damagedUnit, damageAmount, allUnits, hexDistance)
    if not damagedUnit or not allUnits then return {} end

    local affectedUnits = {}
    local witnessRange = 8  -- Hex tiles to observe from

    for _, unit in ipairs(allUnits) do
        if unit and unit.alive and unit ~= damagedUnit then
            -- Calculate distance
            local distance = 0
            if hexDistance then
                distance = hexDistance(damagedUnit.position, unit.position)
            else
                -- Simple fallback
                distance = math.abs(damagedUnit.x - unit.x) + math.abs(damagedUnit.y - unit.y)
            end

            if distance <= witnessRange then
                -- Witnessed damage
                local isAlly = unit.team == damagedUnit.team
                local penalty = self:calculateWitnessMoralePenalty(
                    unit, damageAmount, isAlly)

                self:applyMoraleChange(unit, -penalty,
                    "Witnessed damage to " .. (isAlly and "ally" or "enemy"))

                table.insert(affectedUnits, {
                    unit = unit,
                    penalty = penalty,
                    isAlly = isAlly
                })
            end
        end
    end

    return affectedUnits
end

-- Get comprehensive unit state for AI decisions
-- Args:
--   unit: unit to check
-- Returns:
--   table with tactical state info
function SuppressionSystem:getTacticalState(unit)
    if not unit then return nil end

    return {
        unitId = unit.id or "Unit",
        alive = unit.alive or false,
        morale = unit.morale or 100,
        moraleState = unit.moraleState or MORALE_STATE_NORMAL,
        suppression = unit.suppressionLevel or 0,
        suppressionState = self:getSuppressionLevelName(unit.suppressionLevel or 0),
        health = unit.health or 0,
        maxHealth = unit.maxHealth or 100,
        healthPercent = (unit.health or 0) / (unit.maxHealth or 100) * 100,
        canMove = unit.canMove ~= false,
        canAct = unit.canAct ~= false,
        shouldFlee = self:shouldFlee(unit),
        tacticalRating = self:calculateTacticalRating(unit)
    }
end

-- Calculate overall tactical rating (0-100)
function SuppressionSystem:calculateTacticalRating(unit)
    if not unit or not unit.alive then return 0 end

    local rating = 100

    -- Health penalty
    if unit.health and unit.maxHealth then
        local healthPercent = (unit.health / unit.maxHealth) * 100
        rating = rating * (healthPercent / 100)
    end

    -- Morale penalty
    if unit.morale then
        rating = rating * ((unit.morale or 100) / 100)
    end

    -- Suppression penalty
    if unit.suppressionLevel then
        rating = rating * (1.0 - (unit.suppressionLevel or 0) / 200)
    end

    return math.max(0, math.min(100, rating))
end

-- AI decision helper: get best action for suppressed unit
function SuppressionSystem:getSuppressionAIAction(unit)
    local tactical = self:getTacticalState(unit)

    if not tactical then return "normal" end

    if tactical.shouldFlee then
        return "flee"
    elseif (tactical.suppression or 0) > 80 then
        return "take_cover"
    elseif (tactical.healthPercent or 100) < 30 then
        return "suppress_fire"
    else
        return "normal"
    end
end

return SuppressionSystem

