--- Crew Bonus Calculator
--- Calculates craft performance bonuses from assigned crew.
---
--- This module implements the crew bonus formula:
--- - Pilot (position 1): 100% stat contribution
--- - Co-Pilot (position 2): 50% stat contribution
--- - Crew (position 3): 25% stat contribution
--- - Extra Crew (4+): 10% stat contribution (diminishing returns)
---
--- @module CrewBonusCalculator

local CrewBonusCalculator = {}

--- Calculate crew bonuses for craft.
---
--- @param craft table Craft object with crew array
--- @return table Bonus table
function CrewBonusCalculator.calculateForCraft(craft)
    if not craft or not craft.crew then
        return {
            speed_bonus = 0,
            accuracy_bonus = 0,
            dodge_bonus = 0,
            fuel_efficiency = 0,
            initiative_bonus = 0,
            sensor_bonus = 0,
        }
    end

    local bonuses = {
        speed_bonus = 0,
        accuracy_bonus = 0,
        dodge_bonus = 0,
        fuel_efficiency = 0,
        initiative_bonus = 0,
        sensor_bonus = 0,
        power_management = 0,
    }

    local totalFatigue = 0
    local crewCount = 0

    -- Sum bonuses from each crew member
    for position, crewId in ipairs(craft.crew) do
        -- Get unit (this would need actual unit lookup in real implementation)
        -- For now, use mock data or skip
        local unit = CrewBonusCalculator.getUnit(crewId)

        if unit then
            -- Get position multiplier
            local multiplier = CrewBonusCalculator.getRoleMultiplier(position)

            -- Calculate unit's pilot bonuses
            local unitBonuses = unit:calculatePilotBonuses()

            -- Apply position multiplier and add to total
            bonuses.speed_bonus = bonuses.speed_bonus + (unitBonuses.speed_bonus * multiplier)
            bonuses.accuracy_bonus = bonuses.accuracy_bonus + (unitBonuses.accuracy_bonus * multiplier)
            bonuses.dodge_bonus = bonuses.dodge_bonus + (unitBonuses.dodge_bonus * multiplier)
            bonuses.fuel_efficiency = bonuses.fuel_efficiency + (unitBonuses.fuel_efficiency * multiplier)

            -- Initiative and sensor don't scale with multiplier (absolute values)
            if position == 1 then
                bonuses.initiative_bonus = unitBonuses.initiative_bonus or 0
                bonuses.sensor_bonus = unitBonuses.sensor_bonus or 0
                bonuses.power_management = unitBonuses.power_management or 0
            end

            -- Track fatigue for averaging
            totalFatigue = totalFatigue + (unit.pilot_fatigue or 0)
            crewCount = crewCount + 1

            print(string.format("[CrewBonus] Position %d (%.0f%%): speed +%.1f%%, accuracy +%.1f%%, dodge +%.1f%%",
                position, multiplier * 100,
                unitBonuses.speed_bonus * multiplier,
                unitBonuses.accuracy_bonus * multiplier,
                unitBonuses.dodge_bonus * multiplier))
        end
    end

    -- Apply average fatigue modifier
    if crewCount > 0 then
        local avgFatigue = totalFatigue / crewCount
        bonuses = CrewBonusCalculator.applyFatigueModifier(bonuses, avgFatigue)

        print(string.format("[CrewBonus] Final bonuses (avg fatigue %.1f): speed +%.1f%%, accuracy +%.1f%%, dodge +%.1f%%, fuel +%.1f%%",
            avgFatigue, bonuses.speed_bonus, bonuses.accuracy_bonus, bonuses.dodge_bonus, bonuses.fuel_efficiency))
    end

    return bonuses
end

--- Get unit by ID (helper function - would need actual implementation)
---
--- @param unitId number Unit ID
--- @return table|nil Unit object or nil
function CrewBonusCalculator.getUnit(unitId)
    -- This is a placeholder that would need actual unit lookup
    -- For now, return nil to avoid errors
    -- In real implementation, would do:
    -- return UnitManager.getUnit(unitId) or similar
    return nil
end

--- Get role multiplier for crew position.
---
--- @param position number Position in crew (1-8)
--- @return number Multiplier (1.0, 0.5, 0.25, 0.1)
function CrewBonusCalculator.getRoleMultiplier(position)
    if position == 1 then
        return 1.0  -- Pilot
    elseif position == 2 then
        return 0.5  -- Co-Pilot
    elseif position == 3 then
        return 0.25  -- Crew
    else
        return 0.1  -- Additional crew (diminishing)
    end
end

--- Apply fatigue modifier to bonuses.
---
--- @param bonuses table Bonus table
--- @param averageFatigue number Average crew fatigue (0-100)
--- @return table Modified bonuses
function CrewBonusCalculator.applyFatigueModifier(bonuses, averageFatigue)
    local multiplier = 1.0 - (averageFatigue / 200)  -- Max -50% at 100 fatigue

    -- Apply to performance bonuses (not to initiative/sensor which are absolute)
    bonuses.speed_bonus = bonuses.speed_bonus * multiplier
    bonuses.accuracy_bonus = bonuses.accuracy_bonus * multiplier
    bonuses.dodge_bonus = bonuses.dodge_bonus * multiplier
    bonuses.fuel_efficiency = bonuses.fuel_efficiency * multiplier

    return bonuses
end

--- Calculate bonuses for craft (legacy alias)
---
--- @param craftId string Craft ID
--- @return table Bonus table
function CrewBonusCalculator.calculate(craftId)
    -- This is a legacy function signature
    -- Would need craft lookup to work properly
    print("[CrewBonus] WARNING: calculate(craftId) called - use calculateForCraft(craft) instead")

    return {
        speed_bonus = 0,
        accuracy_bonus = 0,
        dodge_bonus = 0,
        fuel_efficiency = 0,
        initiative_bonus = 0,
        sensor_bonus = 0,
    }
end

return CrewBonusCalculator


