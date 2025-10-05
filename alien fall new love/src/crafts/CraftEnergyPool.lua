--- CraftEnergyPool.lua
-- Implements energy resource system for crafts (vehicles/aircraft)
-- Separate from unit energy with shared weapon consumption and craft-specific mechanics
-- Supports multiple weapon systems drawing from shared energy reserves

local Class = require("util.Class")

---@class CraftEnergyPool
---@field private _maxEnergy number Maximum energy capacity
---@field private _currentEnergy number Current energy level
---@field private _regenerationRate number Energy restored per turn
---@field private _weaponEnergy number Dedicated weapon energy pool
---@field private _systemEnergy number Energy for craft systems (shields, engines)
---@field private _turnCounter number Turn counter for regeneration timing
local CraftEnergyPool = Class()

---Initialize CraftEnergyPool
---@param maxEnergy number Total maximum energy capacity
---@param weaponRatio number Ratio of energy allocated to weapons (0-1)
---@param regenerationRate number Energy per turn regeneration
function CraftEnergyPool:init(maxEnergy, weaponRatio, regenerationRate)
    self._maxEnergy = maxEnergy
    self._currentEnergy = maxEnergy -- Start full

    -- Split energy between weapon and system pools
    self._weaponEnergy = math.floor(maxEnergy * weaponRatio)
    self._systemEnergy = maxEnergy - self._weaponEnergy

    self._regenerationRate = regenerationRate or math.floor(maxEnergy * 0.3)
    self._turnCounter = 0
end

---Try to consume weapon energy
---@param amount number Energy required for weapon
---@param weaponId string Weapon identifier
---@return boolean success Whether energy was available
function CraftEnergyPool:tryConsumeWeaponEnergy(amount, weaponId)
    if self._weaponEnergy >= amount then
        self._weaponEnergy = self._weaponEnergy - amount
        self:_logEnergyChange(-amount, "weapon: " .. weaponId)
        return true
    end
    return false
end

---Try to consume system energy
---@param amount number Energy required for system
---@param systemType string System type ("engine", "shield", "sensor")
---@return boolean success Whether energy was available
function CraftEnergyPool:tryConsumeSystemEnergy(amount, systemType)
    if self._systemEnergy >= amount then
        self._systemEnergy = self._systemEnergy - amount
        self:_logEnergyChange(-amount, "system: " .. systemType)
        return true
    end
    return false
end

---Get energy cost for craft weapon
---@param weapon table Weapon data
---@param fireMode string "single", "burst", "sustained"
---@return number energyCost
function CraftEnergyPool:getWeaponEnergyCost(weapon, fireMode)
    local baseCost = weapon.energyCost or 2

    local modeMultipliers = {
        single = 1.0,
        burst = 2.5,
        sustained = 4.0
    }

    local multiplier = modeMultipliers[fireMode] or 1.0
    return baseCost * multiplier
end

---Get energy cost for craft system
---@param systemType string System type
---@param action string Specific action
---@return number energyCost
function CraftEnergyPool:getSystemEnergyCost(systemType, action)
    local systemCosts = {
        engine = {
            boost = 5,
            evade = 3,
            afterburner = 8
        },
        shield = {
            raise = 4,
            maintain = 2,
            overload = 10
        },
        sensor = {
            active_scan = 3,
            target_lock = 2,
            jam = 6
        }
    }

    return systemCosts[systemType] and systemCosts[systemType][action] or 1
end

---Process end-of-turn regeneration
---@param inCombat boolean Whether craft is in combat (affects regeneration)
function CraftEnergyPool:processTurnRegeneration(inCombat)
    self._turnCounter = self._turnCounter + 1

    local regeneration = self._regenerationRate

    -- Reduced regeneration in combat
    if inCombat then
        regeneration = math.floor(regeneration * 0.5)
    end

    -- Distribute regeneration (prioritize systems, then weapons)
    local systemDeficit = (self._maxEnergy - self._weaponEnergy) - self._systemEnergy
    local weaponDeficit = self._weaponEnergy - (self._maxEnergy - (self._maxEnergy - self._weaponEnergy) - self._systemEnergy)

    -- Restore systems first
    local systemRestore = math.min(regeneration, systemDeficit)
    self._systemEnergy = self._systemEnergy + systemRestore

    -- Then weapons
    local weaponRestore = math.min(regeneration - systemRestore, weaponDeficit)
    local weaponPoolSize = self._maxEnergy - (self._maxEnergy - self._weaponEnergy)
    self._weaponEnergy = math.min(weaponPoolSize, self._weaponEnergy + weaponRestore)

    self:_logEnergyChange(systemRestore + weaponRestore, "turn regeneration")
end

---Apply damage effects to craft energy
---@param damageType string Damage type
---@param amount number Damage amount
---@param location string Damage location ("weapons", "systems", "general")
function CraftEnergyPool:applyDamage(damageType, amount, location)
    if damageType == "energy" then
        if location == "weapons" then
            self._weaponEnergy = math.max(0, self._weaponEnergy - amount)
        elseif location == "systems" then
            self._systemEnergy = math.max(0, self._systemEnergy - amount)
        else
            -- General damage affects both proportionally
            local weaponDamage = math.floor(amount * 0.6)
            local systemDamage = amount - weaponDamage
            self._weaponEnergy = math.max(0, self._weaponEnergy - weaponDamage)
            self._systemEnergy = math.max(0, self._systemEnergy - systemDamage)
        end
    elseif damageType == "emp" then
        -- EMP affects all systems
        self._weaponEnergy = math.floor(self._weaponEnergy * 0.5)
        self._systemEnergy = math.floor(self._systemEnergy * 0.5)
    end

    self:_logEnergyChange(-amount, "damage: " .. damageType .. " (" .. location .. ")")
end

---Get current energy status
---@return table status {weaponEnergy, systemEnergy, totalCurrent, totalMax, weaponPercent, systemPercent}
function CraftEnergyPool:getEnergyStatus()
    local totalCurrent = self._weaponEnergy + self._systemEnergy
    local weaponMax = self._maxEnergy - (self._maxEnergy - self._weaponEnergy)
    local systemMax = self._maxEnergy - self._weaponEnergy

    return {
        weaponEnergy = self._weaponEnergy,
        systemEnergy = self._systemEnergy,
        totalCurrent = totalCurrent,
        totalMax = self._maxEnergy,
        weaponPercent = (self._weaponEnergy / weaponMax) * 100,
        systemPercent = (self._systemEnergy / systemMax) * 100
    }
end

---Check if craft can perform weapon action
---@param energyCost number Required energy
---@return boolean canFire
function CraftEnergyPool:canFireWeapon(energyCost)
    return self._weaponEnergy >= energyCost
end

---Check if craft can perform system action
---@param energyCost number Required energy
---@return boolean canActivate
function CraftEnergyPool:canActivateSystem(energyCost)
    return self._systemEnergy >= energyCost
end

---Get energy efficiency rating
---@return number efficiency 0-1 rating
function CraftEnergyPool:getEfficiencyRating()
    local status = self:getEnergyStatus()
    return (status.weaponPercent + status.systemPercent) / 200 -- Average percentage as 0-1
end

---Apply emergency power redistribution
---@param fromPool string Source pool ("weapons", "systems")
---@param toPool string Target pool
---@param amount number Energy to transfer
---@return boolean success
function CraftEnergyPool:redistributePower(fromPool, toPool, amount)
    if fromPool == "weapons" and toPool == "systems" then
        if self._weaponEnergy >= amount then
            self._weaponEnergy = self._weaponEnergy - amount
            self._systemEnergy = self._systemEnergy + amount
            self:_logEnergyChange(-amount, "redistribution: weapons to systems")
            return true
        end
    elseif fromPool == "systems" and toPool == "weapons" then
        if self._systemEnergy >= amount then
            self._systemEnergy = self._systemEnergy - amount
            self._weaponEnergy = self._weaponEnergy + amount
            self:_logEnergyChange(-amount, "redistribution: systems to weapons")
            return true
        end
    end

    return false
end

---Get energy data for serialization
---@return table energyData
function CraftEnergyPool:getEnergyData()
    return {
        maxEnergy = self._maxEnergy,
        weaponEnergy = self._weaponEnergy,
        systemEnergy = self._systemEnergy,
        regenerationRate = self._regenerationRate,
        turnCounter = self._turnCounter
    }
end

---Load energy data from save
---@param energyData table Saved energy data
function CraftEnergyPool:loadEnergyData(energyData)
    self._maxEnergy = energyData.maxEnergy
    self._weaponEnergy = energyData.weaponEnergy
    self._systemEnergy = energyData.systemEnergy
    self._regenerationRate = energyData.regenerationRate
    self._turnCounter = energyData.turnCounter or 0
end

---Internal logging function
---@param delta number Energy change
---@param reason string Reason for change
function CraftEnergyPool:_logEnergyChange(delta, reason)
    -- In a real implementation, this would log to provenance system
    if not self._energyLog then self._energyLog = {} end
    table.insert(self._energyLog, {
        turn = self._turnCounter,
        delta = delta,
        reason = reason,
        timestamp = os.time()
    })
end

return CraftEnergyPool
