---Unit Recovery & Healing System
---
---Processes weekly unit recovery at bases: HP restoration, sanity recovery,
---wound healing with time tracking. Facilities provide recovery bonuses.
---
---Recovery rates:
---  - Health: 1 + (facility_level × 0.5) HP per week
---  - Sanity: 5 + (facility_level × 1) points per week (if not wounded)
---  - Wounds: 3 weeks per wound minus facility bonuses
---
---@module basescape.logic.unit_recovery
---@author AlienFall Development Team

local UnitRecovery = {}
UnitRecovery.__index = UnitRecovery

---Create new recovery manager
---@param baseId string Base identifier
---@return table recovery Recovery manager instance
function UnitRecovery.new(baseId)
    local self = setmetatable({}, UnitRecovery)
    self.baseId = baseId
    self.unit_recovery_data = {}  -- unitId -> {hp_current, sanity_current, wounds[]}
    return self
end

---Initialize unit recovery tracking
---@param unitId string Unit identifier
---@param hp number Current HP
---@param max_hp number Max HP
---@param sanity number Current sanity (0-100)
---@param wounds table Array of wound data
function UnitRecovery:initUnit(unitId, hp, max_hp, sanity, wounds)
    self.unit_recovery_data[unitId] = {
        hp = hp,
        max_hp = max_hp,
        sanity = sanity or 100,
        wounds = wounds or {},
        recovery_weeks = 0  -- Weeks in recovery
    }

    print(string.format("[UnitRecovery] Initialized unit %s: %d/%d HP, %d sanity, %d wounds",
          unitId, hp, max_hp, sanity or 100, #(wounds or {})))
end

---Process weekly recovery for all units
---@param base table Base object
---@return table results {recovered_units, healed_wounds}
function UnitRecovery:processWeeklyRecovery(base)
    local results = {
        recovered_units = {},
        healed_wounds = {},
        recovered_sanity = {}
    }

    -- Get base facility level for healing bonuses
    local medical_facility_level = self:getMedicalFacilityLevel(base)

    for unitId, unit_data in pairs(self.unit_recovery_data) do
        -- HP recovery (1 per week + facility bonus)
        local hp_recovery = 1 + (medical_facility_level * 0.5)
        local old_hp = unit_data.hp
        unit_data.hp = math.min(unit_data.max_hp, unit_data.hp + hp_recovery)

        if unit_data.hp > old_hp then
            table.insert(results.recovered_units, {
                unit = unitId,
                hp_recovered = unit_data.hp - old_hp,
                new_hp = unit_data.hp
            })
        end

        -- Sanity recovery (5 per week + facility bonus, if not wounded)
        local sanity_recovery = 5 + (medical_facility_level * 1)
        if #unit_data.wounds == 0 then  -- Only recover if not wounded
            local old_sanity = unit_data.sanity
            unit_data.sanity = math.min(100, unit_data.sanity + sanity_recovery)

            if unit_data.sanity > old_sanity then
                table.insert(results.recovered_sanity, {
                    unit = unitId,
                    sanity_recovered = unit_data.sanity - old_sanity,
                    new_sanity = unit_data.sanity
                })
            end
        end

        -- Wound healing (3 weeks per wound, -1 week with medical facility)
        local wound_recovery_time = 3 - medical_facility_level
        self:processWoundHealing(unitId, unit_data, wound_recovery_time, results.healed_wounds)

        unit_data.recovery_weeks = unit_data.recovery_weeks + 1
    end

    print(string.format("[UnitRecovery] Weekly recovery processed: %d units recovered HP, %d wounds healed",
          #results.recovered_units, #results.healed_wounds))

    return results
end

---Process wound healing for a unit
---@param unitId string Unit identifier
---@param unit_data table Unit recovery data
---@param heal_weeks number Weeks to reduce from each wound
---@param results table Results array to append to
function UnitRecovery:processWoundHealing(unitId, unit_data, heal_weeks, results)
    local healed = {}

    for i = #unit_data.wounds, 1, -1 do
        local wound = unit_data.wounds[i]

        -- Reduce weeks remaining
        wound.weeks_remaining = (wound.weeks_remaining or 3) - heal_weeks

        if wound.weeks_remaining <= 0 then
            -- Wound healed completely
            table.insert(healed, {
                unit = unitId,
                location = wound.location,
                status = "healed"
            })
            table.remove(unit_data.wounds, i)
        else
            -- Wound partially healed
            table.insert(healed, {
                unit = unitId,
                location = wound.location,
                status = "healing",
                weeks_remaining = wound.weeks_remaining
            })
        end
    end

    -- Add to results
    for _, heal_record in ipairs(healed) do
        table.insert(results, heal_record)
    end
end

---Get medical facility level (0-5)
---@param base table Base object
---@return number level Medical facility upgrade level
function UnitRecovery:getMedicalFacilityLevel(base)
    if not base or not base.grid then
        return 0
    end

    local medical_level = 0

    -- Check for medical facilities
    for _, facility in ipairs(base.grid:getAllFacilities()) do
        if facility.typeId == "medical" or facility.typeId == "psi_lab" then
            if facility.upgrades then
                medical_level = math.max(medical_level, #facility.upgrades)
            end
        end
    end

    return math.min(medical_level, 5)
end

---Add wound to unit
---@param unitId string Unit identifier
---@param location string Wound location (LEG, ARM, TORSO, HEAD)
---@param severity number Severity 1-5 (affects healing time)
function UnitRecovery:addWound(unitId, location, severity)
    if not self.unit_recovery_data[unitId] then
        return false
    end

    local unit_data = self.unit_recovery_data[unitId]

    table.insert(unit_data.wounds, {
        location = location,
        severity = severity or 1,
        weeks_remaining = 3 + (severity - 1),  -- Extra week per severity point
        created_week = unit_data.recovery_weeks
    })

    print(string.format("[UnitRecovery] Added %s wound (severity %d) to unit %s",
          location, severity or 1, unitId))

    return true
end

---Get unit recovery status
---@param unitId string Unit identifier
---@return table|nil status {hp, sanity, wounds, recovery_weeks}
function UnitRecovery:getUnitStatus(unitId)
    if not self.unit_recovery_data[unitId] then
        return nil
    end

    local unit_data = self.unit_recovery_data[unitId]

    return {
        hp = unit_data.hp,
        max_hp = unit_data.max_hp,
        sanity = unit_data.sanity,
        wounds = unit_data.wounds,
        recovery_weeks = unit_data.recovery_weeks,
        is_injured = unit_data.hp < unit_data.max_hp or #unit_data.wounds > 0
    }
end

---Check if unit is deployable
---Deployable if: HP > 0, sanity > 30, not critically wounded
---@param unitId string Unit identifier
---@return boolean deployable Can unit be deployed
---@return string|nil reason Reason if not deployable
function UnitRecovery:isDeployable(unitId)
    if not self.unit_recovery_data[unitId] then
        return false, "Unit not tracked"
    end

    local unit_data = self.unit_recovery_data[unitId]

    -- Must have HP
    if unit_data.hp <= 0 then
        return false, "Unit deceased"
    end

    -- Must have sanity
    if unit_data.sanity < 30 then
        return false, "Sanity too low"
    end

    -- Cannot deploy if critical wounds (severity 5)
    for _, wound in ipairs(unit_data.wounds) do
        if wound.severity >= 5 then
            return false, "Critical wound prevents deployment"
        end
    end

    return true, nil
end

---Get recovery cost (credits for medical supplies)
---@param unitId string Unit identifier
---@param weeks number Number of weeks
---@return number cost Recovery cost in credits
function UnitRecovery:getRecoveryCost(unitId, weeks)
    local status = self:getUnitStatus(unitId)
    if not status then
        return 0
    end

    weeks = weeks or 1

    -- Base cost: $100 per week
    local cost = 100 * weeks

    -- Wound cost: $500 per wound per week
    cost = cost + (#status.wounds * 500 * weeks)

    -- Sanity cost: $50 per 10 sanity below 100
    if status.sanity < 100 then
        local sanity_deficit = (100 - status.sanity) / 10
        cost = cost + (sanity_deficit * 50 * weeks)
    end

    return math.floor(cost)
end

---Accelerate recovery with medical supplies
---Spending credits can reduce recovery time
---@param unitId string Unit identifier
---@param credits number Credits to spend (max 2000)
---@return number weeks_reduced Weeks of healing accelerated
function UnitRecovery:accelerateRecovery(unitId, credits)
    credits = math.min(credits, 2000)

    if not self.unit_recovery_data[unitId] then
        return 0
    end

    -- $200 per week accelerated
    local weeks_reduced = math.floor(credits / 200)

    local unit_data = self.unit_recovery_data[unitId]

    -- Reduce wound healing time
    for _, wound in ipairs(unit_data.wounds) do
        wound.weeks_remaining = math.max(1, wound.weeks_remaining - weeks_reduced)
    end

    print(string.format("[UnitRecovery] Accelerated recovery for unit %s by %d weeks ($%d spent)",
          unitId, weeks_reduced, credits))

    return weeks_reduced
end

---Get recovery summary for base
---@return table summary {total_units, injured_units, critical_units, wounded_units}
function UnitRecovery:getBaseSummary()
    local summary = {
        total_units = 0,
        injured_units = 0,
        critical_units = 0,
        wounded_units = 0,
        avg_sanity = 0,
        total_sanity = 0
    }

    for _, unit_data in pairs(self.unit_recovery_data) do
        summary.total_units = summary.total_units + 1

        if unit_data.hp < unit_data.max_hp or #unit_data.wounds > 0 then
            summary.injured_units = summary.injured_units + 1
        end

        if #unit_data.wounds > 0 then
            summary.wounded_units = summary.wounded_units + 1

            for _, wound in ipairs(unit_data.wounds) do
                if wound.severity >= 4 then
                    summary.critical_units = summary.critical_units + 1
                    break
                end
            end
        end

        summary.total_sanity = summary.total_sanity + unit_data.sanity
    end

    if summary.total_units > 0 then
        summary.avg_sanity = math.floor(summary.total_sanity / summary.total_units)
    end

    return summary
end

return UnitRecovery
