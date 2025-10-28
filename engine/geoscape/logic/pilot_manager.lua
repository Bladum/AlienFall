--- Pilot Manager
--- Manages pilot assignment to crafts and crew bonus calculation.
---
--- This module handles:
--- - Assigning units to crafts as pilots/crew
--- - Validating pilot class requirements
--- - Calculating crew stat bonuses
--- - Managing pilot fatigue
---
--- @module PilotManager

local PilotManager = {}

-- Cache for loaded systems (lazy loading)
local Units = nil
local Crafts = nil

--- Get Units system (lazy load)
local function getUnits()
    if not Units then
        -- Try multiple possible locations
        local success, result = pcall(require, "battlescape.combat.unit")
        if success then
            Units = result
        else
            success, result = pcall(require, "engine.battlescape.combat.unit")
            if success then
                Units = result
            end
        end
    end
    return Units
end

--- Get Crafts system (lazy load)
local function getCrafts()
    if not Crafts then
        -- Try multiple possible locations
        local success, result = pcall(require, "geoscape.craft_system")
        if success then
            Crafts = result
        else
            success, result = pcall(require, "engine.geoscape.craft_system")
            if success then
                Crafts = result
            end
        end
    end
    return Crafts
end

--- Assign unit to craft as crew member.
---
--- @param unit table Unit object to assign
--- @param craft table Craft object
--- @param role string Role: "pilot", "co-pilot", "crew"
--- @return boolean, string Success status and error message
function PilotManager.assignToCraft(unit, craft, role)
    if not unit or not craft or not role then
        return false, "Invalid parameters: unit, craft, and role required"
    end

    -- Validate role
    local validRoles = {pilot = true, ["co-pilot"] = true, crew = true}
    if not validRoles[role] then
        return false, "Invalid role: must be 'pilot', 'co-pilot', or 'crew'"
    end

    -- Check if unit is already assigned
    if unit:isAssignedAsPilot() then
        return false, string.format("Unit %s already assigned to craft %s",
            unit.name, unit.assigned_craft_id)
    end

    -- Check craft crew capacity
    craft.crew = craft.crew or {}
    local maxCrew = craft.max_crew or craft.crew_capacity or 8
    if #craft.crew >= maxCrew then
        return false, string.format("Craft %s crew at capacity (%d/%d)",
            craft.name or craft.id, #craft.crew, maxCrew)
    end

    -- Validate pilot class requirements (for pilot role)
    if role == "pilot" and craft.required_pilot_class then
        if unit.classId ~= craft.required_pilot_class then
            return false, string.format("Unit class %s does not match required %s",
                unit.classId, craft.required_pilot_class)
        end
    end

    -- Validate pilot rank requirements
    if role == "pilot" and craft.required_pilot_rank then
        local unitRank = unit.pilot_rank or 0
        if unitRank < craft.required_pilot_rank then
            return false, string.format("Unit rank %d below required %d",
                unitRank, craft.required_pilot_rank)
        end
    end

    print(string.format("[PilotManager] Assigning unit %s to craft %s as %s",
        unit.name, craft.name or craft.id, role))

    -- Update unit properties
    unit.assigned_craft_id = craft.id
    unit.pilot_role = role

    -- Update craft crew list
    table.insert(craft.crew, unit.id)

    -- Recalculate craft bonuses
    PilotManager.recalculateCraftBonuses(craft)

    return true, "Assigned successfully"
end

--- Unassign unit from craft.
---
--- @param unit table Unit object to unassign
--- @param craft table Craft object (optional, will lookup if not provided)
--- @return boolean Success status
function PilotManager.unassignFromCraft(unit, craft)
    if not unit then
        return false
    end

    if not unit:isAssignedAsPilot() then
        return false -- Not assigned, nothing to do
    end

    local craftId = unit.assigned_craft_id

    print(string.format("[PilotManager] Unassigning unit %s from craft %s",
        unit.name, craftId))

    -- If craft not provided, try to find it
    if not craft then
        -- This would need actual craft lookup implementation
        print("[PilotManager] WARNING: Craft lookup not implemented, assuming direct access")
    end

    -- Clear unit properties
    unit.assigned_craft_id = nil
    unit.pilot_role = nil

    -- Remove from craft crew list if we have craft reference
    if craft and craft.crew then
        for i, crewId in ipairs(craft.crew) do
            if crewId == unit.id then
                table.remove(craft.crew, i)
                break
            end
        end

        -- Recalculate craft bonuses
        PilotManager.recalculateCraftBonuses(craft)
    end

    return true
end

--- Check if unit can operate craft type.
---
--- @param unit table Unit object
--- @param craft table Craft object
--- @return boolean, string Can operate and reason
function PilotManager.canOperateCraft(unit, craft)
    if not unit or not craft then
        return false, "Invalid parameters"
    end

    -- Check pilot class requirement
    if craft.required_pilot_class then
        if unit.classId ~= craft.required_pilot_class then
            return false, string.format("Requires pilot class: %s (unit is %s)",
                craft.required_pilot_class, unit.classId)
        end
    end

    -- Check pilot rank requirement
    if craft.required_pilot_rank then
        local unitRank = unit.pilot_rank or 0
        if unitRank < craft.required_pilot_rank then
            return false, string.format("Requires pilot rank %d (unit is rank %d)",
                craft.required_pilot_rank, unitRank)
        end
    end

    -- Check if unit has minimum piloting skill
    local piloting = unit:getPilotingStat()
    if piloting < 6 then
        return false, "Insufficient piloting skill"
    end

    return true, "Unit can operate this craft"
end

--- Validate craft crew meets requirements.
---
--- @param craft table Craft object
--- @return boolean, string Valid and reason
function PilotManager.validateCrew(craft)
    if not craft then
        return false, "Invalid craft"
    end

    craft.crew = craft.crew or {}
    local crewCount = #craft.crew
    local requiredPilots = craft.required_pilots or 1

    if crewCount < requiredPilots then
        return false, string.format("Insufficient crew: %d/%d pilots",
            crewCount, requiredPilots)
    end

    -- Check if at least one primary pilot exists
    local hasPilot = false
    -- This would need actual unit lookup to verify roles
    if crewCount > 0 then
        hasPilot = true -- Simplified for now
    end

    if not hasPilot then
        return false, "No primary pilot assigned"
    end

    return true, "Crew valid"
end

--- Recalculate craft bonuses from crew.
---
--- @param craft table Craft object
function PilotManager.recalculateCraftBonuses(craft)
    if not craft then return end

    -- Use Craft's built-in recalculation method if available
    if craft.recalculateCrewBonuses then
        craft:recalculateCrewBonuses()
        return
    end

    -- Fallback: Use CrewBonusCalculator directly
    local success, calculator = pcall(require, "geoscape.logic.crew_bonus_calculator")
    if not success then
        success, calculator = pcall(require, "engine.geoscape.logic.crew_bonus_calculator")
    end

    if success and calculator then
        craft.crew_bonuses = calculator.calculateForCraft(craft)
    else
        -- Ultimate fallback: zero bonuses
        craft.crew_bonuses = {
            speed_bonus = 0,
            accuracy_bonus = 0,
            dodge_bonus = 0,
            fuel_efficiency = 0,
        }
    end
end

--- Award pilot XP to all crew members after interception.
---
--- @param craft table Craft object
--- @param baseXP number Base XP amount
--- @param source string XP source (e.g., "interception_kill")
function PilotManager.awardCrewXP(craft, baseXP, source)
    if not craft or not craft.crew then
        return
    end

    print(string.format("[PilotManager] Awarding %d XP to %d crew members (%s)",
        baseXP, #craft.crew, source))

    -- XP multipliers by position
    local multipliers = {1.0, 0.5, 0.25, 0.1, 0.1, 0.1, 0.1, 0.1}

    for i, crewId in ipairs(craft.crew) do
        local multiplier = multipliers[i] or 0.1
        local xp = math.floor(baseXP * multiplier)

        -- This would need actual unit lookup
        print(string.format("[PilotManager]   Crew position %d: %d XP (%.0f%%)",
            i, xp, multiplier * 100))

        -- TODO: Get unit and call unit:gainPilotXP(xp, source)
    end
end

return PilotManager


