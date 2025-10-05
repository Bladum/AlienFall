--- UnitManager.lua
-- Unit collection and base management system for Alien Fall
-- Manages unit assignments, transfers, and fleet operations

-- GROK: UnitManager handles unit collections, base assignments, and transfers
-- GROK: Used by unit_system for base operations and strategic unit management
-- GROK: Key methods: assignToBase(), transferUnit(), getUnitsAtBase()
-- GROK: Handles base capacity, transfer logistics, and unit availability

local class = require 'lib.Middleclass'

UnitManager = class('UnitManager')

--- Initialize a new unit manager
function UnitManager:initialize()
    self.units = {} -- Unit ID -> Unit object
    self.base_assignments = {} -- Base ID -> {unit_id -> unit}
    self.transferring_units = {} -- Unit ID -> transfer info

    -- Configuration
    self.max_units_per_base = 50
    self.transfer_time_per_distance = 2 -- hours per distance unit
    self.transfer_cost_per_unit = 100 -- credits per unit transferred

    -- Statistics
    self.stats = {
        total_units = 0,
        operational_units = 0,
        wounded_units = 0,
        transferring_units = 0,
        units_by_base = {},
        units_by_class = {}
    }
end

--- Add a unit to the manager
-- @param unit The Unit object to add
function UnitManager:addUnit(unit)
    self.units[unit.id] = unit
    self:_updateStats()
end

--- Remove a unit from the manager
-- @param unit_id The unit ID to remove
-- @return true if removed successfully
function UnitManager:removeUnit(unit_id)
    if self.units[unit_id] then
        -- Remove from base assignment
        for base_id, base_units in pairs(self.base_assignments) do
            if base_units[unit_id] then
                base_units[unit_id] = nil
                break
            end
        end

        -- Remove from transferring units
        self.transferring_units[unit_id] = nil

        -- Remove unit
        self.units[unit_id] = nil
        self:_updateStats()
        return true
    end
    return false
end

--- Assign a unit to a base
-- @param unit_id The unit ID
-- @param base_id The base ID
-- @return true if assigned successfully
function UnitManager:assignToBase(unit_id, base_id)
    local unit = self.units[unit_id]
    if not unit then
        return false, "Unit not found"
    end

    -- Check base capacity
    local base_units = self:getUnitsAtBase(base_id)
    if #base_units >= self.max_units_per_base then
        return false, "Base at capacity"
    end

    -- Remove from current base
    self:_removeFromCurrentBase(unit_id)

    -- Assign to new base
    self.base_assignments[base_id] = self.base_assignments[base_id] or {}
    self.base_assignments[base_id][unit_id] = unit

    self:_updateStats()
    return true
end

--- Get units assigned to a base
-- @param base_id The base ID
-- @return Array of units at the base
function UnitManager:getUnitsAtBase(base_id)
    local units = {}
    local base_units = self.base_assignments[base_id] or {}

    for _, unit in pairs(base_units) do
        table.insert(units, unit)
    end

    return units
end

--- Get operational units at a base
-- @param base_id The base ID
-- @return Array of operational units at the base
function UnitManager:getOperationalUnitsAtBase(base_id)
    local units = {}
    local base_units = self:getUnitsAtBase(base_id)

    for _, unit in ipairs(base_units) do
        if unit:isOperational() then
            table.insert(units, unit)
        end
    end

    return units
end

--- Get available units for mission at a base
-- @param base_id The base ID
-- @param mission_requirements Table with mission requirements
-- @return Array of available units
function UnitManager:getAvailableUnitsForMission(base_id, mission_requirements)
    local available = {}
    local base_units = self:getUnitsAtBase(base_id)

    for _, unit in ipairs(base_units) do
        if self:_unitMeetsMissionRequirements(unit, mission_requirements) then
            table.insert(available, unit)
        end
    end

    return available
end

--- Check if a unit meets mission requirements
-- @param unit The unit to check
-- @param requirements Mission requirements
-- @return true if unit meets requirements
function UnitManager:_unitMeetsMissionRequirements(unit, requirements)
    -- Must be operational
    if not unit:isOperational() then
        return false
    end

    -- Check class requirements
    if requirements.required_classes then
        local has_required_class = false
        for _, required_class in ipairs(requirements.required_classes) do
            if unit.class_id == required_class then
                has_required_class = true
                break
            end
        end
        if not has_required_class then
            return false
        end
    end

    -- Check ability requirements
    if requirements.required_abilities then
        for _, required_ability in ipairs(requirements.required_abilities) do
            if not unit:hasAbility(required_ability) then
                return false
            end
        end
    end

    -- Check trait requirements
    if requirements.required_traits then
        for _, required_trait in ipairs(requirements.required_traits) do
            if not unit:hasTrait(required_trait) then
                return false
            end
        end
    end

    -- Check health requirements
    if requirements.min_health_percentage then
        if unit:getHealthPercentage() < requirements.min_health_percentage then
            return false
        end
    end

    -- Check rank requirements
    if requirements.min_rank then
        if unit.rank < requirements.min_rank then
            return false
        end
    end

    return true
end

--- Initiate unit transfer between bases
-- @param unit_id The unit ID
-- @param target_base_id The destination base ID
-- @param distance The distance between bases
-- @return true if transfer initiated
function UnitManager:transferUnit(unit_id, target_base_id, distance)
    local unit = self.units[unit_id]
    if not unit then
        return false, "Unit not found"
    end

    -- Check if unit is already transferring
    if self.transferring_units[unit_id] then
        return false, "Unit already transferring"
    end

    -- Check if target base has capacity
    local target_base_units = self:getUnitsAtBase(target_base_id)
    if #target_base_units >= self.max_units_per_base then
        return false, "Target base at capacity"
    end

    -- Calculate transfer time
    local transfer_time = math.floor(distance * self.transfer_time_per_distance)

    -- Initiate transfer
    self.transferring_units[unit_id] = {
        from_base = self:_getUnitBase(unit_id),
        to_base = target_base_id,
        distance = distance,
        eta = transfer_time,
        start_time = os.time()
    }

    unit.status = "transferring"
    unit.transfer_destination = target_base_id
    unit.transfer_eta = transfer_time

    self:_updateStats()
    return true
end

--- Complete a unit transfer
-- @param unit_id The unit ID
-- @return true if transfer completed
function UnitManager:completeTransfer(unit_id)
    local transfer_info = self.transferring_units[unit_id]
    if not transfer_info then
        return false, "No transfer in progress"
    end

    local unit = self.units[unit_id]
    if not unit then
        return false, "Unit not found"
    end

    -- Remove from current base
    self:_removeFromCurrentBase(unit_id)

    -- Assign to new base
    self.base_assignments[transfer_info.to_base] = self.base_assignments[transfer_info.to_base] or {}
    self.base_assignments[transfer_info.to_base][unit_id] = unit

    -- Clear transfer status
    self.transferring_units[unit_id] = nil
    unit.status = "barracks"
    unit.transfer_destination = nil
    unit.transfer_eta = 0

    self:_updateStats()
    return true
end

--- Update transferring units (called hourly)
function UnitManager:updateTransfers()
    local completed_transfers = {}

    for unit_id, transfer_info in pairs(self.transferring_units) do
        transfer_info.eta = transfer_info.eta - 1

        local unit = self.units[unit_id]
        if unit then
            unit.transfer_eta = transfer_info.eta
        end

        if transfer_info.eta <= 0 then
            table.insert(completed_transfers, unit_id)
        end
    end

    -- Complete transfers
    for _, unit_id in ipairs(completed_transfers) do
        self:completeTransfer(unit_id)
    end

    self:_updateStats()
end

--- Get the base a unit is assigned to
-- @param unit_id The unit ID
-- @return Base ID or nil
function UnitManager:_getUnitBase(unit_id)
    for base_id, base_units in pairs(self.base_assignments) do
        if base_units[unit_id] then
            return base_id
        end
    end
    return nil
end

--- Remove a unit from its current base assignment
-- @param unit_id The unit ID
function UnitManager:_removeFromCurrentBase(unit_id)
    for base_id, base_units in pairs(self.base_assignments) do
        if base_units[unit_id] then
            base_units[unit_id] = nil
            break
        end
    end
end

--- Get transfer cost for a unit
-- @param unit_id The unit ID
-- @param distance The transfer distance
-- @return Transfer cost
function UnitManager:getTransferCost(unit_id, distance)
    return self.transfer_cost_per_unit * distance
end

--- Get units currently transferring
-- @return Array of transferring units
function UnitManager:getTransferringUnits()
    local transferring = {}
    for unit_id, _ in pairs(self.transferring_units) do
        local unit = self.units[unit_id]
        if unit then
            table.insert(transferring, unit)
        end
    end
    return transferring
end

--- Update statistics
function UnitManager:_updateStats()
    self.stats.total_units = 0
    self.stats.operational_units = 0
    self.stats.wounded_units = 0
    self.stats.transferring_units = 0
    self.stats.units_by_base = {}
    self.stats.units_by_class = {}

    for _, unit in pairs(self.units) do
        self.stats.total_units = self.stats.total_units + 1

        -- Status counts
        if unit.status == "transferring" then
            self.stats.transferring_units = self.stats.transferring_units + 1
        elseif unit:isWounded() then
            self.stats.wounded_units = self.stats.wounded_units + 1
        elseif unit:isOperational() then
            self.stats.operational_units = self.stats.operational_units + 1
        end

        -- Class counts
        self.stats.units_by_class[unit.class_id] = (self.stats.units_by_class[unit.class_id] or 0) + 1
    end

    -- Base counts
    for base_id, base_units in pairs(self.base_assignments) do
        local count = 0
        for _ in pairs(base_units) do
            count = count + 1
        end
        self.stats.units_by_base[base_id] = count
    end
end

--- Get statistics
-- @return Table with unit statistics
function UnitManager:getStatistics()
    return self.stats
end

--- Get base capacity information
-- @param base_id The base ID
-- @return Table with capacity info {current, max, available}
function UnitManager:getBaseCapacity(base_id)
    local current = #(self:getUnitsAtBase(base_id))
    return {
        current = current,
        max = self.max_units_per_base,
        available = self.max_units_per_base - current
    }
end

--- Find suitable base for unit assignment
-- @param unit_id The unit ID
-- @param preferred_bases Array of preferred base IDs
-- @return Suitable base ID or nil
function UnitManager:findSuitableBase(unit_id, preferred_bases)
    local unit = self.units[unit_id]
    if not unit then return nil end

    -- Try preferred bases first
    if preferred_bases then
        for _, base_id in ipairs(preferred_bases) do
            local capacity = self:getBaseCapacity(base_id)
            if capacity.available > 0 then
                return base_id
            end
        end
    end

    -- Find any base with capacity
    for base_id, _ in pairs(self.base_assignments) do
        local capacity = self:getBaseCapacity(base_id)
        if capacity.available > 0 then
            return base_id
        end
    end

    return nil -- No suitable base found
end

--- Rebalance units across bases
-- @param base_ids Array of base IDs to rebalance
function UnitManager:rebalanceUnits(base_ids)
    -- Simple rebalancing: move excess units to bases with capacity
    for _, base_id in ipairs(base_ids) do
        local capacity = self:getBaseCapacity(base_id)
        if capacity.current > capacity.max then
            local excess = capacity.current - capacity.max
            local base_units = self:getUnitsAtBase(base_id)

            -- Move excess units to other bases
            for i = 1, excess do
                local unit = base_units[i]
                local target_base = self:findSuitableBase(unit.id, base_ids)
                if target_base then
                    self:assignToBase(unit.id, target_base)
                end
            end
        end
    end
end

--- Serialize manager data for saving
-- @return Table with serializable data
function UnitManager:serialize()
    local data = {
        units = {},
        base_assignments = {},
        transferring_units = self.transferring_units,
        max_units_per_base = self.max_units_per_base,
        transfer_time_per_distance = self.transfer_time_per_distance,
        transfer_cost_per_unit = self.transfer_cost_per_unit
    }

    -- Serialize units (basic info only, detailed serialization handled by UnitSystem)
    for id, unit in pairs(self.units) do
        data.units[id] = {
            id = unit.id,
            base_id = self:_getUnitBase(id)
        }
    end

    -- Serialize base assignments
    for base_id, base_units in pairs(self.base_assignments) do
        data.base_assignments[base_id] = {}
        for unit_id, _ in pairs(base_units) do
            data.base_assignments[base_id][unit_id] = true
        end
    end

    return data
end

--- Deserialize manager data from save
-- @param data The serialized data
-- @param unit_system The UnitSystem to get unit objects from
function UnitManager:deserialize(data, unit_system)
    if not data then return end

    self.max_units_per_base = data.max_units_per_base or 50
    self.transfer_time_per_distance = data.transfer_time_per_distance or 2
    self.transfer_cost_per_unit = data.transfer_cost_per_unit or 100
    self.transferring_units = data.transferring_units or {}

    -- Rebuild units and assignments
    self.units = {}
    self.base_assignments = {}

    if data.units then
        for unit_id, unit_info in pairs(data.units) do
            local unit = unit_system:getUnitById(unit_id)
            if unit then
                self.units[unit_id] = unit

                -- Restore base assignment
                if unit_info.base_id then
                    self.base_assignments[unit_info.base_id] = self.base_assignments[unit_info.base_id] or {}
                    self.base_assignments[unit_info.base_id][unit_id] = unit
                end
            end
        end
    end

    -- Restore base assignments from data
    if data.base_assignments then
        for base_id, base_units in pairs(data.base_assignments) do
            self.base_assignments[base_id] = self.base_assignments[base_id] or {}
            for unit_id, _ in pairs(base_units) do
                local unit = unit_system:getUnitById(unit_id)
                if unit then
                    self.base_assignments[base_id][unit_id] = unit
                end
            end
        end
    end

    self:_updateStats()
end

return UnitManager
