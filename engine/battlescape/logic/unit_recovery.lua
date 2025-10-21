---UnitRecovery - Health and Sanity Restoration System
---
---Handles unit health recovery, wound healing, and sanity restoration between missions.
---Integrates with base medical facilities for accelerated recovery. Weekly recovery
---process for injured and traumatized units.
---
---Features:
---  - HP recovery (1 HP/week base)
---  - Sanity recovery (1 sanity/week base)
---  - Wound healing (3 weeks per wound)
---  - Medical facility bonuses
---  - Recovery time tracking
---  - Full recovery detection
---
---Recovery Rates (Base):
---  - HP: +1 per week
---  - Sanity: +1 per week
---  - Wounds: 3 weeks per wound to heal
---
---Medical Facility Bonuses:
---  - Medical Bay: +50% HP recovery
---  - Infirmary: +100% HP recovery
---  - Psi Lab: +50% sanity recovery
---  - Multiple facilities stack
---
---Recovery Process:
---  1. Check unit recovery status (wounded, low sanity)
---  2. Apply base recovery rates
---  3. Apply facility bonuses
---  4. Update unit health/sanity values
---  5. Heal wounds if recovery time met
---  6. Mark recovered units as mission-ready
---
---Key Exports:
---  - UnitRecovery.processWeekly(units, facilityBonuses): Processes weekly recovery
---  - UnitRecovery.calculateRecovery(unit, bonuses): Returns recovery amounts
---  - UnitRecovery.healWound(unit, woundId): Heals specific wound
---  - UnitRecovery.isFullyRecovered(unit): Returns true if mission-ready
---  - UnitRecovery.getRecoveryTime(unit): Returns weeks until recovered
---
---Dependencies:
---  - None (standalone system)
---
---@module battlescape.logic.unit_recovery
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local UnitRecovery = require("battlescape.logic.unit_recovery")
---  local bonuses = {medical_bay = 1.5}
---  UnitRecovery.processWeekly(baseUnits, bonuses)
---
---@see basescape.facilities.facility_system For facility bonuses

-- Unit Recovery System
-- Handles unit health recovery, wound healing, and sanity restoration
-- Integrates with base medical facilities

local UnitRecovery = {}
UnitRecovery.__index = UnitRecovery

--- Recovery rates (per week)
UnitRecovery.BASE_HP_RECOVERY = 1       -- 1 HP per week
UnitRecovery.BASE_SANITY_RECOVERY = 1   -- 1 sanity per week
UnitRecovery.WOUND_RECOVERY_WEEKS = 3   -- 3 weeks per wound

--- Process weekly recovery for all units in base
-- @param units table Array of units
-- @param facilityBonuses table|nil Optional facility bonuses
function UnitRecovery.processWeeklyRecovery(units, facilityBonuses)
    facilityBonuses = facilityBonuses or {}
    
    local medicalBonus = facilityBonuses.medical or 0
    local sanityBonus = facilityBonuses.support or 0
    
    print(string.format("[UnitRecovery] Processing weekly recovery (medical: +%d, support: +%d)",
          medicalBonus, sanityBonus))
    
    for _, unit in ipairs(units) do
        if unit.alive then
            UnitRecovery.recoverUnit(unit, medicalBonus, sanityBonus)
        end
    end
end

--- Recover a single unit's health and sanity
-- @param unit table Unit entity
-- @param medicalBonus number Medical facility bonus
-- @param sanityBonus number Support facility bonus
function UnitRecovery.recoverUnit(unit, medicalBonus, sanityBonus)
    local recovered = false
    
    -- Health recovery
    if unit.health and unit.maxHealth and unit.health < unit.maxHealth then
        local hpRecovery = UnitRecovery.BASE_HP_RECOVERY + medicalBonus
        unit.health = math.min(unit.maxHealth, unit.health + hpRecovery)
        recovered = true
        print(string.format("[UnitRecovery] %s recovered %d HP (now %d/%d)",
              unit.name or "Unknown", hpRecovery, unit.health, unit.maxHealth))
    end
    
    -- Sanity recovery
    if unit.sanity and unit.maxSanity and unit.sanity < unit.maxSanity then
        local sanityRecovery = UnitRecovery.BASE_SANITY_RECOVERY + sanityBonus
        unit.sanity = math.min(unit.maxSanity, unit.sanity + sanityRecovery)
        recovered = true
        print(string.format("[UnitRecovery] %s recovered %d sanity (now %d/%d)",
              unit.name or "Unknown", sanityRecovery, unit.sanity, unit.maxSanity))
    end
    
    -- Wound recovery (decrement recovery time)
    if unit.woundRecoveryWeeks and unit.woundRecoveryWeeks > 0 then
        unit.woundRecoveryWeeks = unit.woundRecoveryWeeks - 1
        recovered = true
        
        if unit.woundRecoveryWeeks <= 0 then
            unit.woundRecoveryWeeks = 0
            unit.wounds = 0
            print(string.format("[UnitRecovery] %s fully recovered from wounds!", unit.name or "Unknown"))
        else
            print(string.format("[UnitRecovery] %s wound recovery: %d weeks remaining",
                  unit.name or "Unknown", unit.woundRecoveryWeeks))
        end
    end
    
    if not recovered then
        print(string.format("[UnitRecovery] %s at full health", unit.name or "Unknown"))
    end
end

--- Calculate recovery time after mission
-- @param unit table Unit entity
-- @param damageT aken number HP lost in mission
-- @param woundsTaken number Wounds received in mission
-- @return number Total recovery weeks needed
function UnitRecovery.calculateRecoveryTime(unit, damageTaken, woundsTaken)
    -- HP recovery: 1 week per HP lost
    local hpWeeks = math.ceil(damageTaken / UnitRecovery.BASE_HP_RECOVERY)
    
    -- Wound recovery: 3 weeks per wound
    local woundWeeks = woundsTaken * UnitRecovery.WOUND_RECOVERY_WEEKS
    
    -- Total is sum (not max)
    local totalWeeks = hpWeeks + woundWeeks
    
    -- Store on unit
    unit.woundRecoveryWeeks = (unit.woundRecoveryWeeks or 0) + woundWeeks
    
    print(string.format("[UnitRecovery] %s recovery time: %d weeks (%d HP + %d wounds)",
          unit.name or "Unknown", totalWeeks, hpWeeks, woundWeeks))
    
    return totalWeeks
end

--- Check if unit is available for deployment
-- @param unit table Unit entity
-- @return boolean True if available, false if recovering
function UnitRecovery.isAvailableForDeployment(unit)
    if not unit.alive then
        return false
    end
    
    -- Check health
    if unit.health and unit.maxHealth and unit.health < unit.maxHealth then
        return false
    end
    
    -- Check wound recovery
    if unit.woundRecoveryWeeks and unit.woundRecoveryWeeks > 0 then
        return false
    end
    
    return true
end

--- Get recovery status for UI display
-- @param unit table Unit entity
-- @return table Recovery status
function UnitRecovery.getRecoveryStatus(unit)
    local status = {
        isRecovering = false,
        healthPercent = 100,
        sanityPercent = 100,
        weeksRemaining = 0,
        statusText = "Ready"
    }
    
    -- Health percentage
    if unit.health and unit.maxHealth then
        status.healthPercent = math.floor((unit.health / unit.maxHealth) * 100)
        if status.healthPercent < 100 then
            status.isRecovering = true
            status.statusText = "Wounded"
        end
    end
    
    -- Sanity percentage
    if unit.sanity and unit.maxSanity then
        status.sanityPercent = math.floor((unit.sanity / unit.maxSanity) * 100)
        if status.sanityPercent < 100 then
            status.isRecovering = true
            if status.statusText == "Ready" then
                status.statusText = "Recovering"
            end
        end
    end
    
    -- Wound recovery time
    if unit.woundRecoveryWeeks and unit.woundRecoveryWeeks > 0 then
        status.isRecovering = true
        status.weeksRemaining = unit.woundRecoveryWeeks
        status.statusText = string.format("Wounded (%d weeks)", status.weeksRemaining)
    end
    
    return status
end

--- Process post-mission damage and wounds
-- @param unit table Unit entity
-- @param missionData table Mission results
function UnitRecovery.processMissionDamage(unit, missionData)
    -- Calculate damage taken
    local maxHP = unit.maxHealth or 10
    local currentHP = unit.health or maxHP
    local damageTaken = maxHP - currentHP
    
    -- Get wounds from mission
    local woundsTaken = unit.wounds or 0
    
    if damageTaken > 0 or woundsTaken > 0 then
        local recoveryTime = UnitRecovery.calculateRecoveryTime(unit, damageTaken, woundsTaken)
        print(string.format("[UnitRecovery] Post-mission: %s needs %d weeks recovery",
              unit.name or "Unknown", recoveryTime))
    end
    
    -- Process sanity loss from mission
    if missionData.sanityLoss and missionData.sanityLoss > 0 then
        unit.sanity = math.max(4, (unit.sanity or 10) - missionData.sanityLoss)
        print(string.format("[UnitRecovery] %s lost %d sanity (now %d)",
              unit.name or "Unknown", missionData.sanityLoss, unit.sanity))
    end
end

return UnitRecovery

























