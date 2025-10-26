--- Morale system for battlescape combat
--- Handles unit morale, panic, and psychological effects

local MoraleSystem = {}
MoraleSystem.__index = MoraleSystem

-- Morale constants
MoraleSystem.MAX_MORALE = 100
MoraleSystem.MIN_MORALE = 0
MoraleSystem.BASE_MORALE = 75

-- Morale loss multipliers
MoraleSystem.DAMAGE_MORALE_LOSS_MULTIPLIER = 0.5  -- 0.5 morale loss per HP damage
MoraleSystem.DEATH_WITNESS_MORALE_LOSS = 20  -- Base morale loss from seeing ally die
MoraleSystem.DEATH_DISTANCE_MULTIPLIER = 0.1  -- Additional loss per tile distance

-- Panic thresholds
MoraleSystem.PANIC_THRESHOLD = 25  -- Morale below this = panic
MoraleSystem.UNCONSCIOUS_THRESHOLD = 10  -- Morale below this = unconscious

--- Create a new morale system instance
---@return table New MoraleSystem instance
function MoraleSystem.new()
    local self = setmetatable({}, MoraleSystem)

    print("[MoraleSystem] Morale system initialized")

    return self
end

--- Initialize morale for a unit
---@param unit table Unit to initialize
function MoraleSystem:initializeUnitMorale(unit)
    if not unit.morale then
        unit.morale = MoraleSystem.BASE_MORALE
        unit.maxMorale = MoraleSystem.MAX_MORALE
        unit.isPanicked = false
        unit.isUnconscious = false
    end
end

--- Calculate morale loss from taking damage
---@param unit table Unit that took damage
---@param healthDamage number Amount of health damage taken
---@return number Morale loss amount
function MoraleSystem:calculateDamageMoraleLoss(unit, healthDamage)
    self:initializeUnitMorale(unit)

    -- Base morale loss proportional to damage taken
    local baseLoss = healthDamage * MoraleSystem.DAMAGE_MORALE_LOSS_MULTIPLIER

    -- Additional loss if unit is already wounded
    local woundMultiplier = 1.0
    if unit.wounds and unit.wounds > 0 then
        woundMultiplier = 1.0 + (unit.wounds * 0.25)  -- 25% extra per wound
    end

    local totalLoss = math.floor(baseLoss * woundMultiplier)

    print(string.format("[MoraleSystem] Damage morale loss: %d (damage: %d, wounds: %d)",
          totalLoss, healthDamage, unit.wounds or 0))

    return totalLoss
end

--- Apply morale loss to a unit
---@param unit table Unit to affect
---@param amount number Morale loss amount
function MoraleSystem:applyMoraleLoss(unit, amount)
    self:initializeUnitMorale(unit)

    unit.morale = unit.morale - amount

    if unit.morale < MoraleSystem.MIN_MORALE then
        unit.morale = MoraleSystem.MIN_MORALE
    end

    -- Check for panic
    if unit.morale <= MoraleSystem.PANIC_THRESHOLD and not unit.isPanicked then
        unit.isPanicked = true
        print(string.format("[MoraleSystem] Unit %s is now PANICKED (morale: %d)",
              unit.name or "Unknown", unit.morale))
    end

    -- Check for unconsciousness from low morale
    if unit.morale <= MoraleSystem.UNCONSCIOUS_THRESHOLD and not unit.isUnconscious then
        unit.isUnconscious = true
        print(string.format("[MoraleSystem] Unit %s is now UNCONSCIOUS from low morale (morale: %d)",
              unit.name or "Unknown", unit.morale))
    end

    print(string.format("[MoraleSystem] Unit %s morale: %d/%d",
          unit.name or "Unknown", unit.morale, unit.maxMorale))
end

--- Calculate morale loss from witnessing an ally's death
---@param witness table Witnessing unit
---@param deceased table Unit that died
---@param distance number Distance to death in tiles
---@return number Morale loss amount
function MoraleSystem:calculateDeathWitnessMoraleLoss(witness, deceased, distance)
    self:initializeUnitMorale(witness)

    -- Base loss from seeing death
    local baseLoss = MoraleSystem.DEATH_WITNESS_MORALE_LOSS

    -- Distance modifier (closer = more impact)
    local distanceModifier = math.max(0.1, 1.0 - (distance * MoraleSystem.DEATH_DISTANCE_MULTIPLIER))

    -- Relationship modifier (same team = more impact)
    local relationshipModifier = 1.0
    if witness.team == deceased.team then
        relationshipModifier = 2.0  -- Double impact for same team
    end

    local totalLoss = math.floor(baseLoss * distanceModifier * relationshipModifier)

    print(string.format("[MoraleSystem] Death witness morale loss: %d (distance: %.1f, same team: %s)",
          totalLoss, distance, tostring(witness.team == deceased.team)))

    return totalLoss
end

--- Check if unit is unconscious from morale
---@param unit table Unit to check
---@return boolean True if unconscious from morale
function MoraleSystem:isUnconscious(unit)
    self:initializeUnitMorale(unit)
    return unit.morale <= MoraleSystem.UNCONSCIOUS_THRESHOLD
end

--- Check if unit is panicked
---@param unit table Unit to check
---@return boolean True if panicked
function MoraleSystem:isPanicked(unit)
    self:initializeUnitMorale(unit)
    return unit.morale <= MoraleSystem.PANIC_THRESHOLD
end

--- Restore morale (from medical treatment, rest, etc.)
---@param unit table Unit to heal
---@param amount number Morale to restore
function MoraleSystem:restoreMorale(unit, amount)
    self:initializeUnitMorale(unit)

    unit.morale = unit.morale + amount

    if unit.morale > unit.maxMorale then
        unit.morale = unit.maxMorale
    end

    -- Clear panic if morale recovered
    if unit.isPanicked and unit.morale > MoraleSystem.PANIC_THRESHOLD then
        unit.isPanicked = false
        print(string.format("[MoraleSystem] Unit %s recovered from panic",
              unit.name or "Unknown"))
    end

    -- Clear unconsciousness if morale recovered
    if unit.isUnconscious and unit.morale > MoraleSystem.UNCONSCIOUS_THRESHOLD then
        unit.isUnconscious = false
        print(string.format("[MoraleSystem] Unit %s recovered from unconsciousness",
              unit.name or "Unknown"))
    end

    print(string.format("[MoraleSystem] Unit %s morale restored to: %d/%d",
          unit.name or "Unknown", unit.morale, unit.maxMorale))
end

--- Process end-of-turn morale recovery
---@param unit table Unit to process
function MoraleSystem:processTurnRecovery(unit)
    self:initializeUnitMorale(unit)

    -- Small recovery if not panicked
    if not unit.isPanicked and unit.morale < unit.maxMorale then
        local recovery = 5  -- 5 morale per turn
        self:restoreMorale(unit, recovery)
    end
end

--- Get morale status description
---@param unit table Unit to check
---@return string Status description
function MoraleSystem:getMoraleStatus(unit)
    self:initializeUnitMorale(unit)

    if unit.morale <= MoraleSystem.UNCONSCIOUS_THRESHOLD then
        return "Unconscious"
    elseif unit.morale <= MoraleSystem.PANIC_THRESHOLD then
        return "Panicked"
    elseif unit.morale <= 50 then
        return "Shaken"
    elseif unit.morale <= 75 then
        return "Steady"
    else
        return "High"
    end
end

return MoraleSystem
