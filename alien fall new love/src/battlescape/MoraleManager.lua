--- MoraleManager.lua
-- Implements unit morale system for tactical missions
-- Handles Will tests, AP modifiers, panic states, and recovery mechanisms
-- Deterministic with seeded RNG for reproducible outcomes

local Class = require("util.Class")
local RNG = require("services.rng")

---@class MoraleManager
---@field private _missionSeed number Mission seed for deterministic RNG
---@field private _unitMorale table Unit morale tracking {unitId -> morale}
---@field private _panicStates table Unit panic tracking {unitId -> panicData}
local MoraleManager = Class()

---Initialize MoraleManager
---@param missionSeed number Mission seed for deterministic calculations
function MoraleManager:init(missionSeed)
    self._missionSeed = missionSeed
    self._unitMorale = {}
    self._panicStates = {}
end

---Initialize unit morale at mission start
---@param unit table Unit entity
---@param isAmbush boolean Whether this is an ambush mission
function MoraleManager:initializeUnitMorale(unit, isAmbush)
    local startingMorale = isAmbush and 7 or 10 -- Lower for ambush scenarios
    self._unitMorale[unit.id] = startingMorale
end

---Perform Will test for stressful event
---@param unit table Unit entity
---@param testModifier number Situation modifier (-30 for reaction fire, etc.)
---@param eventId number Unique event identifier for seeding
---@return boolean success Whether the test succeeded
function MoraleManager:performWillTest(unit, testModifier, eventId)
    local will = unit.will or 40 -- Default Will stat
    local successChance = math.max(0.1, math.min(0.9, (will + testModifier) / 100))

    local rng = RNG:createSeededRNG(self._missionSeed + unit.id + eventId)
    local roll = rng:random()

    local success = roll <= successChance

    if not success then
        self:reduceMorale(unit, 1)
    end

    return success
end

---Reduce unit morale
---@param unit table Unit entity
---@param amount number Amount to reduce
function MoraleManager:reduceMorale(unit, amount)
    self._unitMorale[unit.id] = math.max(0, (self._unitMorale[unit.id] or 10) - amount)

    -- Check for panic
    if self._unitMorale[unit.id] <= 0 then
        self:triggerPanic(unit)
    end
end

---Trigger panic state for unit
---@param unit table Unit entity
function MoraleManager:triggerPanic(unit)
    self._panicStates[unit.id] = {
        active = true,
        triggeredAt = os.time(),
        recoveryActions = 0
    }

    -- Apply panic effects
    unit.panic = true
    unit.apModifier = -4 -- Severe AP penalty
end

---Attempt panic recovery
---@param unit table Unit entity
---@return boolean recovered
function MoraleManager:attemptPanicRecovery(unit)
    if not self._panicStates[unit.id] or not self._panicStates[unit.id].active then
        return false
    end

    local recoveryActions = self._panicStates[unit.id].recoveryActions + 1
    self._panicStates[unit.id].recoveryActions = recoveryActions

    -- Recovery chance increases with attempts
    local recoveryChance = math.min(0.3 + (recoveryActions - 1) * 0.2, 0.8)

    local rng = RNG:createSeededRNG(self._missionSeed + unit.id + recoveryActions)
    local success = rng:random() <= recoveryChance

    if success then
        self._panicStates[unit.id].active = false
        unit.panic = false
        unit.apModifier = 0
        self._unitMorale[unit.id] = 1 -- Minimum morale after recovery
        return true
    end

    return false
end

---Get AP modifier for unit based on morale
---@param unit table Unit entity
---@return number apModifier AP modifier (-4 to +1)
function MoraleManager:getAPModifier(unit)
    if unit.panic then
        return -4
    end

    local morale = self._unitMorale[unit.id] or 10

    if morale >= 10 then
        return 1 -- High morale bonus
    elseif morale >= 4 then
        return 0 -- Normal
    elseif morale == 3 then
        return -1
    elseif morale == 2 then
        return -2
    elseif morale == 1 then
        return -3
    else
        return -4 -- Shouldn't reach here normally
    end
end

---Apply REST action for morale recovery
---@param unit table Unit entity
---@return boolean success
function MoraleManager:applyRestAction(unit)
    if unit.panic then
        return self:attemptPanicRecovery(unit)
    else
        -- Normal morale recovery
        local currentMorale = self._unitMorale[unit.id] or 10
        if currentMorale < 10 then
            self._unitMorale[unit.id] = math.min(10, currentMorale + 1)
            return true
        end
    end
    return false
end

---Apply leader aura morale boost
---@param leader table Leader unit
---@param affectedUnits table Units in aura range
---@param boostAmount number Morale boost amount
function MoraleManager:applyLeaderAura(leader, affectedUnits, boostAmount)
    for _, unit in ipairs(affectedUnits) do
        if unit.id ~= leader.id then
            local currentMorale = self._unitMorale[unit.id] or 10
            self._unitMorale[unit.id] = math.min(10, currentMorale + boostAmount)
        end
    end
end

---Process casualty event (friendly unit death)
---@param deadUnit table Dead unit
---@param witnesses table Units that witnessed the death
function MoraleManager:processCasualty(deadUnit, witnesses)
    for _, unit in ipairs(witnesses) do
        if unit.id ~= deadUnit.id then
            self:performWillTest(unit, -20, deadUnit.id * 1000 + 1)
        end
    end
end

---Process damage event
---@param damagedUnit table Damaged unit
---@param damageAmount number Amount of damage taken
---@param isReactionFire boolean Whether damage came from reaction fire
function MoraleManager:processDamage(damagedUnit, damageAmount, isReactionFire)
    local modifier = isReactionFire and -30 or -10

    -- Extra tests for large damage hits
    local extraTests = math.floor(damageAmount / 3)
    for i = 1, extraTests + 1 do
        self:performWillTest(damagedUnit, modifier, damagedUnit.id * 1000 + i)
    end
end

---Process suppression event
---@param suppressedUnit table Suppressed unit
function MoraleManager:processSuppression(suppressedUnit)
    self:performWillTest(suppressedUnit, -25, suppressedUnit.id * 1000 + 2)
end

---Process environmental stress (explosion nearby, etc.)
---@param affectedUnits table Units affected by environmental event
---@param severity number Event severity (1-3)
function MoraleManager:processEnvironmentalStress(affectedUnits, severity)
    local modifier = -10 * severity
    for _, unit in ipairs(affectedUnits) do
        self:performWillTest(unit, modifier, unit.id * 1000 + 3)
    end
end

---Get morale status for unit
---@param unitId number Unit ID
---@return table status {morale, panic, apModifier}
function MoraleManager:getMoraleStatus(unitId)
    return {
        morale = self._unitMorale[unitId] or 10,
        panic = self._panicStates[unitId] and self._panicStates[unitId].active or false,
        apModifier = self:getAPModifier({id = unitId, panic = self._panicStates[unitId] and self._panicStates[unitId].active})
    }
end

---Get all morale data for serialization
---@return table moraleData
function MoraleManager:getMoraleData()
    return {
        unitMorale = self._unitMorale,
        panicStates = self._panicStates
    }
end

---Load morale data from save
---@param moraleData table Saved morale data
function MoraleManager:loadMoraleData(moraleData)
    self._unitMorale = moraleData.unitMorale or {}
    self._panicStates = moraleData.panicStates or {}
end

return MoraleManager
