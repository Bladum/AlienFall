--- Capacity Manager Class
-- Manages base resource constraints and limitations for storage, throughput, and service capabilities
--
-- @classmod basescape.CapacityManager

local class = require 'lib.Middleclass'

CapacityManager = class('CapacityManager')

--- Capacity types
CapacityManager.TYPE_STORAGE = "storage"       -- Volume-based storage (items, resources)
CapacityManager.TYPE_SLOTS = "slots"           -- Integer slots (personnel, craft berths)
CapacityManager.TYPE_THROUGHPUT = "throughput" -- Rate-based (research points/day, man-hours)
CapacityManager.TYPE_SERVICE = "service"       -- Boolean capabilities (power, comms)

--- Overflow policies
CapacityManager.OVERFLOW_BLOCK = "block"           -- Prevent operations exceeding capacity
CapacityManager.OVERFLOW_QUEUE = "queue"           -- Queue excess requests
CapacityManager.OVERFLOW_AUTO_SELL = "auto_sell"   -- Auto-sell excess at market rate
CapacityManager.OVERFLOW_AUTO_TRANSFER = "auto_transfer" -- Transfer to other bases
CapacityManager.OVERFLOW_DISCARD = "discard"       -- Remove excess with penalties

--- Create a new capacity manager instance
-- @param registry Service registry for accessing other systems
-- @param base_id ID of the base this manager serves
-- @return CapacityManager New capacity manager instance
function CapacityManager:initialize(registry, base_id)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.event_bus = registry and registry:eventBus() or nil

    self.base_id = base_id

    -- Capacity definitions: name -> capacity_info
    self.capacities = {}

    -- Current usage: name -> current_amount
    self.usage = {}

    -- Reservations: name -> {reservation_id -> amount}
    self.reservations = {}

    -- Overflow policies: name -> policy
    self.overflow_policies = {}

    -- Facility contributions: facility_id -> {capacity_name -> amount}
    self.facility_contributions = {}

    -- Initialize default capacities
    self:_initializeDefaultCapacities()

    if self.logger then
        self.logger:info("CapacityManager", string.format("Created capacity manager for base %s", base_id))
    end
end

--- Initialize default base capacities
function CapacityManager:_initializeDefaultCapacities()
    -- Storage capacities
    self:addCapacity("item_storage", CapacityManager.TYPE_STORAGE, 0, CapacityManager.OVERFLOW_AUTO_SELL)
    self:addCapacity("resource_storage", CapacityManager.TYPE_STORAGE, 0, CapacityManager.OVERFLOW_BLOCK)
    self:addCapacity("fuel_storage", CapacityManager.TYPE_STORAGE, 0, CapacityManager.OVERFLOW_BLOCK)

    -- Personnel capacities
    self:addCapacity("personnel_quarters", CapacityManager.TYPE_SLOTS, 0, CapacityManager.OVERFLOW_BLOCK)
    self:addCapacity("officer_quarters", CapacityManager.TYPE_SLOTS, 0, CapacityManager.OVERFLOW_BLOCK)

    -- Craft capacities
    self:addCapacity("craft_berths", CapacityManager.TYPE_SLOTS, 0, CapacityManager.OVERFLOW_BLOCK)
    self:addCapacity("transport_slots", CapacityManager.TYPE_SLOTS, 0, CapacityManager.OVERFLOW_BLOCK)

    -- Prisoner capacities
    self:addCapacity("prisoner_cells", CapacityManager.TYPE_SLOTS, 0, CapacityManager.OVERFLOW_AUTO_TRANSFER)

    -- Throughput capacities
    self:addCapacity("manufacturing_hours", CapacityManager.TYPE_THROUGHPUT, 0, CapacityManager.OVERFLOW_QUEUE)
    self:addCapacity("research_points", CapacityManager.TYPE_THROUGHPUT, 0, CapacityManager.OVERFLOW_QUEUE)
    self:addCapacity("training_xp", CapacityManager.TYPE_THROUGHPUT, 0, CapacityManager.OVERFLOW_BLOCK)

    -- Service capacities (boolean)
    self:addCapacity("power_generation", CapacityManager.TYPE_SERVICE, false, CapacityManager.OVERFLOW_BLOCK)
    self:addCapacity("communications", CapacityManager.TYPE_SERVICE, false, CapacityManager.OVERFLOW_BLOCK)
    self:addCapacity("medical_facility", CapacityManager.TYPE_SERVICE, false, CapacityManager.OVERFLOW_BLOCK)
    self:addCapacity("radar_coverage", CapacityManager.TYPE_SERVICE, false, CapacityManager.OVERFLOW_BLOCK)
end

--- Add a new capacity definition
-- @param name Capacity name/key
-- @param type Capacity type (storage/slots/throughput/service)
-- @param initial_amount Initial capacity amount
-- @param overflow_policy Policy for handling overflow
function CapacityManager:addCapacity(name, type, initial_amount, overflow_policy)
    self.capacities[name] = {
        type = type,
        amount = initial_amount or 0,
        overflow_policy = overflow_policy or CapacityManager.OVERFLOW_BLOCK
    }

    self.usage[name] = 0
    self.reservations[name] = {}
    self.overflow_policies[name] = overflow_policy or CapacityManager.OVERFLOW_BLOCK

    if self.logger then
        self.logger:debug("CapacityManager", string.format("Added capacity %s (%s) with %s overflow policy",
            name, type, overflow_policy))
    end
end

--- Update facility capacity contributions
-- @param facility Facility instance
-- @param operation "add" or "remove"
function CapacityManager:updateFacilityCapacities(facility, operation)
    local multiplier = (operation == "add") and 1 or -1

    -- Remove old contributions if updating
    if self.facility_contributions[facility.id] then
        for capacity_name, amount in pairs(self.facility_contributions[facility.id]) do
            if self.capacities[capacity_name] then
                self.capacities[capacity_name].amount = self.capacities[capacity_name].amount - amount
            end
        end
    end

    -- Add new contributions
    self.facility_contributions[facility.id] = {}

    if facility.capacities then
        for capacity_name, amount in pairs(facility.capacities) do
            local effective_amount = amount * multiplier * (facility.health / 100) -- Health affects capacity

            if self.capacities[capacity_name] then
                self.capacities[capacity_name].amount = self.capacities[capacity_name].amount + effective_amount
                self.facility_contributions[facility.id][capacity_name] = effective_amount

                if self.logger then
                    self.logger:debug("CapacityManager", string.format("Facility %s %s %s %s capacity (%s -> %s)",
                        facility.id, operation, effective_amount, capacity_name,
                        self.capacities[capacity_name].amount - effective_amount,
                        self.capacities[capacity_name].amount))
                end
            end
        end
    end

    -- Publish capacity change event
    if self.event_bus then
        self.event_bus:publish("capacity:updated", {
            base_id = self.base_id,
            operation = operation,
            facility_id = facility.id
        })
    end
end

--- Check if capacity is available for allocation
-- @param capacity_name Name of capacity to check
-- @param amount Amount needed
-- @return boolean Available
-- @return number Available amount
-- @return string Overflow policy if exceeded
function CapacityManager:checkCapacity(capacity_name, amount)
    if not self.capacities[capacity_name] then
        return false, 0, "capacity_not_found"
    end

    local capacity = self.capacities[capacity_name]
    local total_reserved = 0

    -- Sum reservations
    for _, reserved_amount in pairs(self.reservations[capacity_name]) do
        total_reserved = total_reserved + reserved_amount
    end

    local available = capacity.amount - self.usage[capacity_name] - total_reserved

    if capacity.type == CapacityManager.TYPE_SERVICE then
        -- Service capacities are boolean
        return capacity.amount > 0, capacity.amount, nil
    else
        -- Numeric capacities
        if available >= amount then
            return true, available, nil
        else
            return false, available, capacity.overflow_policy
        end
    end
end

--- Allocate capacity for use
-- @param capacity_name Name of capacity
-- @param amount Amount to allocate
-- @param consumer_id ID of consumer (for tracking)
-- @return boolean Success
-- @return string Error message
-- @return table Reservation info if successful
function CapacityManager:allocateCapacity(capacity_name, amount, consumer_id)
    local available, available_amount, overflow_policy = self:checkCapacity(capacity_name, amount)

    if not available then
        -- Handle overflow based on policy
        if overflow_policy == CapacityManager.OVERFLOW_BLOCK then
            return false, string.format("Insufficient %s capacity (%d/%d available)",
                capacity_name, available_amount, self.capacities[capacity_name].amount)
        elseif overflow_policy == CapacityManager.OVERFLOW_QUEUE then
            -- Queue would be implemented here
            return false, string.format("%s capacity exceeded, queued", capacity_name)
        elseif overflow_policy == CapacityManager.OVERFLOW_AUTO_SELL then
            -- Auto-sell would be implemented here
            return false, string.format("%s capacity exceeded, auto-selling excess", capacity_name)
        elseif overflow_policy == CapacityManager.OVERFLOW_AUTO_TRANSFER then
            -- Auto-transfer would be implemented here
            return false, string.format("%s capacity exceeded, transferring to other bases", capacity_name)
        elseif overflow_policy == CapacityManager.OVERFLOW_DISCARD then
            -- Discard would be implemented here
            return false, string.format("%s capacity exceeded, discarding excess", capacity_name)
        end
    end

    -- Allocate capacity
    self.usage[capacity_name] = self.usage[capacity_name] + amount

    local reservation = {
        consumer_id = consumer_id,
        amount = amount,
        timestamp = os.time()
    }

    if self.logger then
        self.logger:debug("CapacityManager", string.format("Allocated %d %s capacity to %s (usage: %d/%d)",
            amount, capacity_name, consumer_id, self.usage[capacity_name], self.capacities[capacity_name].amount))
    end

    return true, nil, reservation
end

--- Release allocated capacity
-- @param capacity_name Name of capacity
-- @param amount Amount to release
-- @param consumer_id ID of consumer
-- @return boolean Success
function CapacityManager:releaseCapacity(capacity_name, amount, consumer_id)
    if not self.capacities[capacity_name] then
        return false
    end

    if self.usage[capacity_name] >= amount then
        self.usage[capacity_name] = self.usage[capacity_name] - amount

        if self.logger then
            self.logger:debug("CapacityManager", string.format("Released %d %s capacity from %s (usage: %d/%d)",
                amount, capacity_name, consumer_id, self.usage[capacity_name], self.capacities[capacity_name].amount))
        end

        return true
    end

    return false
end

--- Reserve capacity temporarily (for planning)
-- @param capacity_name Name of capacity
-- @param amount Amount to reserve
-- @param reservation_id Unique reservation ID
-- @return boolean Success
function CapacityManager:reserveCapacity(capacity_name, amount, reservation_id)
    if not self.capacities[capacity_name] then
        return false
    end

    local available, _, overflow_policy = self:checkCapacity(capacity_name, amount)
    if not available and overflow_policy == CapacityManager.OVERFLOW_BLOCK then
        return false
    end

    self.reservations[capacity_name][reservation_id] = amount

    if self.logger then
        self.logger:debug("CapacityManager", string.format("Reserved %d %s capacity (reservation: %s)",
            amount, capacity_name, reservation_id))
    end

    return true
end

--- Release capacity reservation
-- @param capacity_name Name of capacity
-- @param reservation_id Reservation ID to release
-- @return boolean Success
function CapacityManager:releaseReservation(capacity_name, reservation_id)
    if not self.capacities[capacity_name] or not self.reservations[capacity_name][reservation_id] then
        return false
    end

    self.reservations[capacity_name][reservation_id] = nil

    if self.logger then
        self.logger:debug("CapacityManager", string.format("Released %s reservation for %s capacity",
            reservation_id, capacity_name))
    end

    return true
end

--- Get capacity utilization information
-- @param capacity_name Name of capacity (optional, returns all if nil)
-- @return table Capacity information
function CapacityManager:getCapacityInfo(capacity_name)
    if capacity_name then
        if not self.capacities[capacity_name] then
            return nil
        end

        local total_reserved = 0
        for _, amount in pairs(self.reservations[capacity_name]) do
            total_reserved = total_reserved + amount
        end

        local utilization_percent = 0
        if self.capacities[capacity_name].amount > 0 then
            utilization_percent = (self.usage[capacity_name] / self.capacities[capacity_name].amount) * 100
        end

        return {
            name = capacity_name,
            type = self.capacities[capacity_name].type,
            total = self.capacities[capacity_name].amount,
            used = self.usage[capacity_name],
            reserved = total_reserved,
            available = self.capacities[capacity_name].amount - self.usage[capacity_name] - total_reserved,
            utilization_percent = utilization_percent,
            overflow_policy = self.overflow_policies[capacity_name]
        }
    else
        -- Return all capacities
        local all_info = {}
        for name, _ in pairs(self.capacities) do
            all_info[name] = self:getCapacityInfo(name)
        end
        return all_info
    end
end

--- Get capacity utilization summary
-- @return table Summary statistics
function CapacityManager:getCapacitySummary()
    local summary = {
        total_capacities = 0,
        overutilized = 0,
        underutilized = 0,
        fully_utilized = 0,
        average_utilization = 0
    }

    local total_utilization = 0

    for name, capacity in pairs(self.capacities) do
        if capacity.type ~= CapacityManager.TYPE_SERVICE then
            summary.total_capacities = summary.total_capacities + 1

            local info = self:getCapacityInfo(name)
            total_utilization = total_utilization + info.utilization_percent

            if info.utilization_percent > 95 then
                summary.fully_utilized = summary.fully_utilized + 1
            elseif info.utilization_percent > 80 then
                summary.overutilized = summary.overutilized + 1
            else
                summary.underutilized = summary.underutilized + 1
            end
        end
    end

    if summary.total_capacities > 0 then
        summary.average_utilization = total_utilization / summary.total_capacities
    end

    return summary
end

--- Update capacity manager (called each frame)
-- @param dt Time delta
function CapacityManager:update(dt)
    -- Capacity updates would go here (regeneration, decay, etc.)
    -- For now, this is a placeholder
end

return CapacityManager
