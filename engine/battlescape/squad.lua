---@class SquadSystem
---@field squads table
---@field availableUnits table
---@field availablePilots table
---@field availableCrafts table
local SquadSystem = {}
SquadSystem.__index = SquadSystem

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local SQUAD_SIZE_LIMITS = {
    MIN = 3,
    MAX = 8
}

local CRAFT_CAPACITIES = {
    interceptor = {soldiers = 0, pilots = {primary = 1, copilot = 1}},
    transport = {soldiers = 8, pilots = {primary = 1, copilot = 1}}
}

local PILOT_REQUIREMENTS = {
    interceptor = 1,  -- 1 primary
    transport = 2     -- 1 primary + 1 copilot
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function SquadSystem:new()
    local self = setmetatable({}, SquadSystem)
    self.squads = {}
    self.availableUnits = {}
    self.availablePilots = {}
    self.availableCrafts = {}
    return self
end

-- ============================================================================
-- SQUAD COMPOSITION VALIDATION
-- ============================================================================

---@param squad table List of unit IDs
---@return boolean isValid
---@return string errorMessage
function SquadSystem:validateSquadComposition(squad)
    if not squad or #squad < SQUAD_SIZE_LIMITS.MIN then
        return false, string.format("Squad too small (minimum %d units)", SQUAD_SIZE_LIMITS.MIN)
    end

    if #squad > SQUAD_SIZE_LIMITS.MAX then
        return false, string.format("Squad too large (maximum %d units)", SQUAD_SIZE_LIMITS.MAX)
    end

    -- Check for leader
    local hasLeader = false
    local combatCount = 0
    local supportCount = 0
    local specialistCount = 0

    for _, unitId in ipairs(squad) do
        local unit = self:getUnitById(unitId)
        if not unit then
            return false, string.format("Unit %s not found", unitId)
        end

        if unit.role == "leader" or unit.class == "commander" then
            if hasLeader then
                return false, "Multiple leaders in squad"
            end
            hasLeader = true
        elseif unit.role == "combat" then
            combatCount = combatCount + 1
        elseif unit.role == "support" then
            supportCount = supportCount + 1
        elseif unit.role == "specialist" then
            specialistCount = specialistCount + 1
        end
    end

    if not hasLeader then
        return false, "Squad must have exactly one leader"
    end

    if combatCount < 2 then
        return false, "Squad must have at least 2 combat units"
    end

    if combatCount > 5 then
        return false, "Squad cannot have more than 5 combat units"
    end

    if supportCount > 2 then
        return false, "Squad cannot have more than 2 support units"
    end

    if specialistCount > 2 then
        return false, "Squad cannot have more than 2 specialist units"
    end

    return true, "Squad composition valid"
end

-- ============================================================================
-- PILOT ASSIGNMENT VALIDATION
-- ============================================================================

---@param craftType string Type of craft ("interceptor" or "transport")
---@param pilots table List of pilot IDs assigned to craft
---@return boolean isValid
---@return string errorMessage
function SquadSystem:validatePilotAssignment(craftType, pilots)
    local required = PILOT_REQUIREMENTS[craftType]
    if not required then
        return false, string.format("Unknown craft type: %s", craftType)
    end

    if not pilots or #pilots ~= required then
        return false, string.format("Craft type %s requires exactly %d pilots", craftType, required)
    end

    -- Check pilot availability and status
    for _, pilotId in ipairs(pilots) do
        local pilot = self:getPilotById(pilotId)
        if not pilot then
            return false, string.format("Pilot %s not found", pilotId)
        end

        if pilot.status == "injured" or pilot.status == "incapacitated" then
            return false, string.format("Pilot %s is %s and cannot fly", pilot.name, pilot.status)
        end

        if pilot.fatigue >= 100 then
            return false, string.format("Pilot %s has maximum fatigue and cannot fly", pilot.name)
        end
    end

    return true, "Pilot assignment valid"
end

-- ============================================================================
-- CAPACITY VALIDATION
-- ============================================================================

---@param squad table List of unit IDs
---@param craftAssignments table Map of craft IDs to their assigned pilots
---@return boolean isValid
---@return string errorMessage
function SquadSystem:validateCapacity(squad, craftAssignments)
    local totalSoldiers = #squad
    local totalCapacity = 0
    local totalPilotsRequired = 0

    -- Calculate total capacity and pilot requirements
    for craftId, pilots in pairs(craftAssignments) do
        local craft = self:getCraftById(craftId)
        if not craft then
            return false, string.format("Craft %s not found", craftId)
        end

        local capacity = CRAFT_CAPACITIES[craft.type]
        if not capacity then
            return false, string.format("Unknown craft type: %s", craft.type)
        end

        totalCapacity = totalCapacity + capacity.soldiers
        totalPilotsRequired = totalPilotsRequired + PILOT_REQUIREMENTS[craft.type]
    end

    if totalSoldiers > totalCapacity then
        return false, string.format("Squad size (%d) exceeds craft capacity (%d)", totalSoldiers, totalCapacity)
    end

    -- Count assigned pilots
    local assignedPilots = 0
    for _, pilots in pairs(craftAssignments) do
        assignedPilots = assignedPilots + #pilots
    end

    if assignedPilots < totalPilotsRequired then
        return false, string.format("Insufficient pilots assigned (%d required, %d assigned)", totalPilotsRequired, assignedPilots)
    end

    return true, "Capacity requirements met"
end

-- ============================================================================
-- EQUIPMENT WEIGHT VALIDATION
-- ============================================================================

---@param squad table List of unit IDs
---@return boolean isValid
---@return table overweightUnits List of units exceeding capacity
function SquadSystem:validateEquipmentWeight(squad)
    local overweightUnits = {}

    for _, unitId in ipairs(squad) do
        local unit = self:getUnitById(unitId)
        if unit then
            local capacity = self:calculateStrengthCapacity(unit.strength)
            local totalWeight = self:calculateUnitWeight(unit)

            if totalWeight > capacity then
                table.insert(overweightUnits, {
                    unitId = unitId,
                    name = unit.name,
                    capacity = capacity,
                    weight = totalWeight,
                    overload = totalWeight - capacity
                })
            end
        end
    end

    if #overweightUnits > 0 then
        return false, overweightUnits
    end

    return true, {}
end

---@param strength number Unit's strength stat
---@return number capacity Weight capacity in kg
function SquadSystem:calculateStrengthCapacity(strength)
    -- Formula: STR × 10kg, with minimum of 30kg
    return math.max(strength * 10, 30)
end

---@param unit table Unit data with equipment
---@return number totalWeight Total equipment weight
function SquadSystem:calculateUnitWeight(unit)
    local totalWeight = 0

    -- Add weapon weights
    if unit.primaryWeapon then
        totalWeight = totalWeight + (unit.primaryWeapon.weight or 0)
    end
    if unit.secondaryWeapon then
        totalWeight = totalWeight + (unit.secondaryWeapon.weight or 0)
    end

    -- Add armor weight
    if unit.armor then
        totalWeight = totalWeight + (unit.armor.weight or 0)
    end

    -- Add equipment weight
    if unit.equipment then
        for _, item in ipairs(unit.equipment) do
            totalWeight = totalWeight + (item.weight or 0)
        end
    end

    return totalWeight
end

-- ============================================================================
-- MISSION LAUNCH VALIDATION
-- ============================================================================

---@param squad table List of unit IDs
---@param craftAssignments table Map of craft IDs to pilot assignments
---@return boolean canLaunch
---@return table errors List of validation errors
function SquadSystem:validateMissionLaunch(squad, craftAssignments)
    local errors = {}

    -- Validate squad composition
    local squadValid, squadError = self:validateSquadComposition(squad)
    if not squadValid then
        table.insert(errors, {type = "squad", message = squadError})
    end

    -- Validate pilot assignments
    for craftId, pilots in pairs(craftAssignments) do
        local craft = self:getCraftById(craftId)
        if craft then
            local pilotValid, pilotError = self:validatePilotAssignment(craft.type, pilots)
            if not pilotValid then
                table.insert(errors, {type = "pilot", craft = craftId, message = pilotError})
            end
        end
    end

    -- Validate capacity
    local capacityValid, capacityError = self:validateCapacity(squad, craftAssignments)
    if not capacityValid then
        table.insert(errors, {type = "capacity", message = capacityError})
    end

    -- Validate equipment weight
    local weightValid, overweightUnits = self:validateEquipmentWeight(squad)
    if not weightValid then
        for _, unit in ipairs(overweightUnits) do
            table.insert(errors, {
                type = "weight",
                unit = unit.unitId,
                message = string.format("%s overloaded by %.1fkg", unit.name, unit.overload)
            })
        end
    end

    return #errors == 0, errors
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

---@param unitId string
---@return table|nil unit Unit data or nil if not found
function SquadSystem:getUnitById(unitId)
    return self.availableUnits[unitId]
end

---@param pilotId string
---@return table|nil pilot Pilot data or nil if not found
function SquadSystem:getPilotById(pilotId)
    return self.availablePilots[pilotId]
end

---@param craftId string
---@return table|nil craft Craft data or nil if not found
function SquadSystem:getCraftById(craftId)
    return self.availableCrafts[craftId]
end

---@param units table
---@param pilots table
---@param crafts table
function SquadSystem:updateAvailableResources(units, pilots, crafts)
    self.availableUnits = units or {}
    self.availablePilots = pilots or {}
    self.availableCrafts = crafts or {}
end

return SquadSystem
