--- EnergyPool.lua
-- Implements energy resource system for units
-- Manages MaxEnergy, CurrentEnergy, regeneration, and consumption
-- Data-driven with deterministic arithmetic and seeded randomness

local Class = require("util.Class")

---@class EnergyPool
---@field private _maxEnergy number Maximum energy capacity
---@field private _currentEnergy number Current energy level
---@field private _regenerationRate number Energy restored per turn
---@field private _bufferEnergy number Temporary energy buffer
---@field private _turnCounter number Turn counter for regeneration timing
local EnergyPool = Class()

---Initialize EnergyPool
---@param maxEnergy number Maximum energy capacity
---@param regenerationRate number Energy per turn regeneration (default 25% of max)
function EnergyPool:init(maxEnergy, regenerationRate)
    self._maxEnergy = maxEnergy
    self._currentEnergy = maxEnergy -- Start full
    self._regenerationRate = regenerationRate or math.floor(maxEnergy * 0.25)
    self._bufferEnergy = 0 -- Temporary buffer from items
    self._turnCounter = 0
end

---Try to consume energy for an action
---@param amount number Energy required
---@param reason string Consumption reason for logging
---@return boolean success Whether energy was available and consumed
function EnergyPool:tryConsumeEnergy(amount, reason)
    local totalAvailable = self._currentEnergy + self._bufferEnergy

    if totalAvailable >= amount then
        -- Consume from buffer first
        local bufferConsumed = math.min(amount, self._bufferEnergy)
        self._bufferEnergy = self._bufferEnergy - bufferConsumed

        local mainConsumed = amount - bufferConsumed
        self._currentEnergy = self._currentEnergy - mainConsumed

        -- Log consumption
        self:_logEnergyChange(-amount, reason)
        return true
    end

    return false
end

---Apply energy delta (positive or negative)
---@param delta number Energy change amount
---@param reason string Reason for change
function EnergyPool:applyEnergyDelta(delta, reason)
    local oldEnergy = self._currentEnergy

    -- Apply to main pool first
    self._currentEnergy = math.max(0, math.min(self._maxEnergy, self._currentEnergy + delta))

    -- If we still have delta and buffer exists, apply to buffer
    if delta > 0 and self._bufferEnergy < self._maxEnergy then
        local bufferSpace = self._maxEnergy - self._bufferEnergy
        local bufferDelta = math.min(delta - (self._currentEnergy - oldEnergy), bufferSpace)
        self._bufferEnergy = self._bufferEnergy + bufferDelta
    end

    self:_logEnergyChange(delta, reason)
end

---Add energy buffer (temporary energy from items)
---@param amount number Buffer amount to add
---@param reason string Reason for buffer addition
function EnergyPool:addEnergyBuffer(amount, reason)
    self._bufferEnergy = math.min(self._maxEnergy, self._bufferEnergy + amount)
    self:_logEnergyChange(amount, reason .. " (buffer)")
end

---Process end-of-turn regeneration
function EnergyPool:processTurnRegeneration()
    self._turnCounter = self._turnCounter + 1

    local regeneration = self._regenerationRate
    self:applyEnergyDelta(regeneration, "turn regeneration")
end

---Get current energy status
---@return table status {current, max, buffer, percentage}
function EnergyPool:getEnergyStatus()
    local totalCurrent = self._currentEnergy + self._bufferEnergy
    local percentage = (totalCurrent / self._maxEnergy) * 100

    return {
        current = self._currentEnergy,
        max = self._maxEnergy,
        buffer = self._bufferEnergy,
        total = totalCurrent,
        percentage = percentage
    }
end

---Check if unit has enough energy for action
---@param amount number Required energy
---@return boolean hasEnough
function EnergyPool:hasEnoughEnergy(amount)
    return (self._currentEnergy + self._bufferEnergy) >= amount
end

---Get energy cost for movement
---@param baseCost number Base AP cost
---@param movementType string "standard", "sprint", "crouch", etc.
---@return number energyCost
function EnergyPool:getMovementEnergyCost(baseCost, movementType)
    local multipliers = {
        standard = 1.0,
        sprint = 3.0, -- High energy cost for sprinting
        crouch = 1.5,
        crawl = 2.0
    }

    local multiplier = multipliers[movementType] or 1.0
    return baseCost * multiplier
end

---Get energy cost for weapon firing
---@param weapon table Weapon data
---@param fireMode string "single", "burst", "auto"
---@return number energyCost
function EnergyPool:getWeaponEnergyCost(weapon, fireMode)
    local baseCost = weapon.energyCost or 1

    local modeMultipliers = {
        single = 1.0,
        burst = 3.0,
        auto = 5.0
    }

    local multiplier = modeMultipliers[fireMode] or 1.0
    return baseCost * multiplier
end

---Get energy cost for special ability
---@param ability table Ability data
---@return number energyCost
function EnergyPool:getAbilityEnergyCost(ability)
    return ability.energyCost or 10
end

---Apply damage effects to energy
---@param damageType string Damage type ("emp", "energy", "radiation")
---@param amount number Damage amount
function EnergyPool:applyDamage(damageType, amount)
    if damageType == "emp" then
        -- EMP drains energy
        self:applyEnergyDelta(-amount, "EMP damage")
    elseif damageType == "energy" then
        -- Energy weapons drain energy
        self:applyEnergyDelta(-math.floor(amount * 0.5), "energy weapon damage")
    elseif damageType == "radiation" then
        -- Radiation reduces regeneration temporarily
        self._regenerationRate = math.max(0, self._regenerationRate - 1)
    end
end

---Apply status effects to energy
---@param statusType string Status type ("stun", "wound", "exhaustion")
---@param severity number Effect severity (1-3)
function EnergyPool:applyStatusEffect(statusType, severity)
    if statusType == "stun" then
        -- Stun prevents regeneration
        self._regenerationRate = 0
    elseif statusType == "wound" then
        -- Wounds reduce max energy temporarily
        local reduction = severity * 2
        self._maxEnergy = math.max(1, self._maxEnergy - reduction)
        self._currentEnergy = math.min(self._currentEnergy, self._maxEnergy)
    elseif statusType == "exhaustion" then
        -- Exhaustion reduces regeneration
        self._regenerationRate = math.max(0, self._regenerationRate - severity)
    end
end

---Remove status effects
---@param statusType string Status type to remove
function EnergyPool:removeStatusEffect(statusType)
    if statusType == "stun" then
        -- Restore normal regeneration
        self._regenerationRate = math.floor(self._maxEnergy * 0.25)
    elseif statusType == "wound" then
        -- Restore max energy (would need original value)
        -- Simplified - assume full restoration
        self._maxEnergy = self._maxEnergy + 2 -- Restore some
    elseif statusType == "exhaustion" then
        self._regenerationRate = math.floor(self._maxEnergy * 0.25)
    end
end

---Get energy data for serialization
---@return table energyData
function EnergyPool:getEnergyData()
    return {
        maxEnergy = self._maxEnergy,
        currentEnergy = self._currentEnergy,
        regenerationRate = self._regenerationRate,
        bufferEnergy = self._bufferEnergy,
        turnCounter = self._turnCounter
    }
end

---Load energy data from save
---@param energyData table Saved energy data
function EnergyPool:loadEnergyData(energyData)
    self._maxEnergy = energyData.maxEnergy
    self._currentEnergy = energyData.currentEnergy
    self._regenerationRate = energyData.regenerationRate
    self._bufferEnergy = energyData.bufferEnergy or 0
    self._turnCounter = energyData.turnCounter or 0
end

---Internal logging function
---@param delta number Energy change
---@param reason string Reason for change
function EnergyPool:_logEnergyChange(delta, reason)
    -- In a real implementation, this would log to provenance system
    -- For now, just store in a simple log
    if not self._energyLog then self._energyLog = {} end
    table.insert(self._energyLog, {
        turn = self._turnCounter,
        delta = delta,
        reason = reason,
        timestamp = os.time()
    })
end

return EnergyPool
