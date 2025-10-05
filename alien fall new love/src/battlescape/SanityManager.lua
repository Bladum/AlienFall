--- SanityManager.lua
-- Implements campaign-scoped sanity system
-- Handles mission resolution changes, weekly recovery, and tactical effects
-- Immutable during missions, changes applied at mission end or weekly ticks

local Class = require("util.Class")

---@class SanityManager
---@field private _unitSanity table Unit sanity tracking {unitId -> sanity}
---@field private _facilityBonuses table Active facility bonuses
local SanityManager = Class()

---Initialize SanityManager
function SanityManager:init()
    self._unitSanity = {}
    self._facilityBonuses = {}
end

---Initialize unit sanity (typically at campaign start)
---@param unit table Unit entity
---@param startingSanity number Starting sanity value (default 10)
function SanityManager:initializeUnitSanity(unit, startingSanity)
    self._unitSanity[unit.id] = startingSanity or 10
end

---Apply mission resolution sanity changes
---@param unit table Unit entity
---@param missionIntensity string "low", "medium", "high"
---@param performanceData table Mission performance metrics
function SanityManager:applyMissionResolution(unit, missionIntensity, performanceData)
    local baseLoss = self:getBaseLossForIntensity(missionIntensity)
    local penalties = self:calculatePenalties(performanceData)

    local totalDelta = -(baseLoss + penalties)
    self:modifySanity(unit, totalDelta)
end

---Get base sanity loss for mission intensity
---@param intensity string Mission intensity
---@return number baseLoss
function SanityManager:getBaseLossForIntensity(intensity)
    local losses = {
        low = 1,
        medium = 2,
        high = 3
    }
    return losses[intensity] or 1
end

---Calculate penalties from mission performance
---@param performanceData table Performance metrics
---@return number penalties Total penalty amount
function SanityManager:calculatePenalties(performanceData)
    local penalties = 0

    -- Heavy wounds penalty
    if performanceData.heavyWounds then
        penalties = penalties + 1
    end

    -- Witnessed ally deaths
    penalties = penalties + (performanceData.witnessedDeaths or 0)

    -- Scripted horror events
    penalties = penalties + (performanceData.horrorEvents or 0)

    -- Psionic exposure
    if performanceData.psionicExposure then
        penalties = penalties + (performanceData.psionicExposure * 2)
    end

    return penalties
end

---Apply weekly recovery
---@param unit table Unit entity
function SanityManager:applyWeeklyRecovery(unit)
    local baseRecovery = 1
    local facilityBonus = self:getFacilityBonus(unit)
    local traitBonus = self:getTraitBonus(unit)

    local totalRecovery = baseRecovery + facilityBonus + traitBonus
    self:modifySanity(unit, totalRecovery)
end

---Get facility bonus for unit
---@param unit table Unit entity
---@return number bonus Facility bonus amount
function SanityManager:getFacilityBonus(unit)
    -- This would check active facilities in the base
    -- Simplified implementation
    local bonus = 0

    if self._facilityBonuses.psiClinic then
        bonus = bonus + 1
    end
    if self._facilityBonuses.hospital then
        bonus = bonus + 2
    end
    if self._facilityBonuses.recreation then
        bonus = bonus + math.floor(bonus * 0.5) -- 50% multiplier
    end

    return bonus
end

---Get trait bonus for unit
---@param unit table Unit entity
---@return number bonus Trait bonus amount
function SanityManager:getTraitBonus(unit)
    -- Racial and individual trait modifiers
    local bonus = 0

    if unit.traits then
        for _, trait in ipairs(unit.traits) do
            if trait.sanityModifier then
                bonus = bonus + trait.sanityModifier
            end
        end
    end

    return bonus
end

---Modify unit sanity with bounds checking
---@param unit table Unit entity
---@param delta number Sanity change (positive or negative)
function SanityManager:modifySanity(unit, delta)
    local currentSanity = self._unitSanity[unit.id] or 10
    self._unitSanity[unit.id] = math.max(0, math.min(10, currentSanity + delta))
end

---Get tactical AP modifier from sanity
---@param unit table Unit entity
---@return number apModifier AP modifier based on sanity
function SanityManager:getTacticalAPModifier(unit)
    local sanity = self._unitSanity[unit.id] or 10

    if sanity >= 10 then
        return 1 -- Bonus for perfect sanity
    elseif sanity <= 3 then
        return -1 -- Penalty for low sanity
    else
        return 0 -- Normal
    end
end

---Get sanity status for unit
---@param unitId number Unit ID
---@return table status {sanity, apModifier, status}
function SanityManager:getSanityStatus(unitId)
    local sanity = self._unitSanity[unitId] or 10
    local apModifier = self:getTacticalAPModifier({id = unitId})

    local status
    if sanity >= 8 then
        status = "excellent"
    elseif sanity >= 6 then
        status = "good"
    elseif sanity >= 4 then
        status = "fair"
    elseif sanity >= 2 then
        status = "poor"
    else
        status = "critical"
    end

    return {
        sanity = sanity,
        apModifier = apModifier,
        status = status
    }
end

---Update facility bonuses
---@param facilities table Active facilities in base
function SanityManager:updateFacilityBonuses(facilities)
    self._facilityBonuses = {
        psiClinic = facilities.psiClinic and facilities.psiClinic.active,
        hospital = facilities.hospital and facilities.hospital.active,
        recreation = facilities.recreation and facilities.recreation.active
    }
end

---Get all sanity data for serialization
---@return table sanityData
function SanityManager:getSanityData()
    return {
        unitSanity = self._unitSanity,
        facilityBonuses = self._facilityBonuses
    }
end

---Load sanity data from save
---@param sanityData table Saved sanity data
function SanityManager:loadSanityData(sanityData)
    self._unitSanity = sanityData.unitSanity or {}
    self._facilityBonuses = sanityData.facilityBonuses or {}
end

---Get units requiring rest (sanity <= 3)
---@return table criticalUnits List of unit IDs with critical sanity
function SanityManager:getCriticalSanityUnits()
    local criticalUnits = {}

    for unitId, sanity in pairs(self._unitSanity) do
        if sanity <= 3 then
            table.insert(criticalUnits, unitId)
        end
    end

    return criticalUnits
end

return SanityManager
