--- Transfer Manager Class
-- Manages transfer of items, units, and crafts between bases with capacity, cost, and scheduling
--
-- @classmod economy.TransferManager

local class = require 'lib.Middleclass'

TransferManager = class('TransferManager')

-- Transfer status constants
TransferManager.STATUS_PENDING = "pending"
TransferManager.STATUS_ACTIVE = "active"
TransferManager.STATUS_COMPLETED = "completed"
TransferManager.STATUS_CANCELLED = "cancelled"
TransferManager.STATUS_FAILED = "failed"

-- Transfer priority constants
TransferManager.PRIORITY_LOW = "low"
TransferManager.PRIORITY_NORMAL = "normal"
TransferManager.PRIORITY_HIGH = "high"
TransferManager.PRIORITY_EMERGENCY = "emergency"

--- Create a new transfer manager instance
-- @param registry Service registry for accessing other systems
-- @return TransferManager instance
function TransferManager:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.event_bus = registry and registry:eventBus() or nil
    self.turn_manager = registry and registry:resolve("turn_manager") or nil

    -- Transfer state
    self.transfers = {}      -- All transfers by ID
    self.active_transfers = {}  -- Currently active transfers
    self.next_id = 1         -- Next transfer ID

    -- Configuration
    self.cost_factors = {
        unit_cost_factor = 10,      -- Cost per unit size per tile
        item_cost_factor = 2,       -- Cost per item volume per tile
        base_fixed_cost = 50,       -- Base cost per transfer
        days_per_tile = 1,          -- Days per tile distance
        fixed_overhead_days = 1     -- Fixed overhead days
    }

    self.priority_multipliers = {
        low = 0.8,
        normal = 1.0,
        high = 1.5,
        emergency = 2.0
    }

    self.refund_percentages = {
        pre_departure = 0.8,  -- 80% refund before departure
        in_transit_min = 0.2, -- Minimum 20% refund during transit
        in_transit_max = 0.8  -- Maximum 80% refund during transit
    }

    -- Load configuration
    self:load_transfer_config()

    return self
end

--- Load transfer configuration from data registry
function TransferManager:load_transfer_config()
    local data_registry = self.registry and self.registry:resolve("data_registry")
    if not data_registry then return end

    local config = data_registry:get("transfers") or {}
    self.cost_factors = config.cost_factors or self.cost_factors
    self.priority_multipliers = config.priority_multipliers or self.priority_multipliers
    self.refund_percentages = config.refund_percentages or self.refund_percentages
end

--- Create a new transfer
-- @param origin_id Origin base ID or "void" for purchases
-- @param destination_id Destination base ID
-- @param payload Array of payload items {type, id, quantity}
-- @param options Transfer options (priority, transport_id, etc.)
-- @return boolean Success status
-- @return string Error message if failed
function TransferManager:create_transfer(origin_id, destination_id, payload, options)
    options = options or {}

    -- Validate payload
    if not payload or #payload == 0 then
        return false, "Empty payload"
    end

    -- Calculate transfer requirements
    local requirements = self:calculate_requirements(payload)
    if not requirements then
        return false, "Invalid payload"
    end

    -- Calculate distance and costs
    local distance = self:calculate_distance(origin_id, destination_id)
    local cost = self:calculate_cost(distance, requirements, options.priority or "normal")

    -- Check if origin has the items (unless it's a void origin)
    if origin_id ~= "void" then
        if not self:validate_origin_inventory(origin_id, payload) then
            return false, "Insufficient items in origin base"
        end
    end

    -- Check destination capacity
    if not self:validate_destination_capacity(destination_id, payload) then
        return false, "Insufficient capacity in destination base"
    end

    -- Create transfer object
    local transfer = {
        id = self.next_id,
        origin_id = origin_id,
        destination_id = destination_id,
        payload = payload,
        requirements = requirements,
        distance = distance,
        cost = cost,
        priority = options.priority or "normal",
        status = TransferManager.STATUS_PENDING,
        progress_days = 0,
        total_days = self:calculate_transit_days(distance, options.delivery_time),
        transport_id = options.transport_id,
        created_turn = self.turn_manager and self.turn_manager:getTurnCount() or 0,
        source = options.source or "manual",
        supplier_id = options.supplier_id,
        listing_id = options.listing_id
    }

    self.next_id = self.next_id + 1
    self.transfers[transfer.id] = transfer

    -- Reserve resources
    if origin_id ~= "void" then
        self:reserve_origin_resources(origin_id, payload)
    end
    self:reserve_destination_capacity(destination_id, payload)

    -- Publish creation event
    if self.event_bus then
        self.event_bus:publish("transfer:created", {
            transfer_id = transfer.id,
            origin_id = origin_id,
            destination_id = destination_id,
            cost = cost
        })
    end

    if self.logger then
        self.logger:info("TransferManager", string.format("Created transfer %d from %s to %s (cost: %d)",
            transfer.id, origin_id, destination_id, cost))
    end

    return true, transfer.id
end

--- Calculate resource requirements for a payload
-- @param payload Array of payload items
-- @return table Requirements {unit_capacity, volume_capacity}
function TransferManager:calculate_requirements(payload)
    local requirements = {
        unit_capacity = 0,
        volume_capacity = 0
    }

    for _, item in ipairs(payload) do
        if item.type == "unit" then
            -- Units consume capacity based on their size
            local unit_size = self:get_unit_size(item.id)
            requirements.unit_capacity = requirements.unit_capacity + (unit_size * (item.quantity or 1))
        elseif item.type == "craft" then
            -- Crafts consume capacity based on their size
            local craft_size = self:get_craft_size(item.id)
            requirements.unit_capacity = requirements.unit_capacity + craft_size
        elseif item.type == "item" or item.type == "resource" then
            -- Items consume volume based on their volume
            local item_volume = self:get_item_volume(item.id)
            requirements.volume_capacity = requirements.volume_capacity + (item_volume * (item.quantity or 1))
        else
            if self.logger then
                self.logger:warn("TransferManager", string.format("Unknown payload type: %s", item.type))
            end
            return nil
        end
    end

    return requirements
end

--- Get size of a unit
-- @param unit_id Unit ID
-- @return number Unit size
function TransferManager:get_unit_size(unit_id)
    -- Placeholder - would look up unit size from data
    return 1  -- Default size
end

--- Get size of a craft
-- @param craft_id Craft ID
-- @return number Craft size
function TransferManager:get_craft_size(craft_id)
    -- Placeholder - would look up craft size from data
    return 5  -- Default size for crafts
end

--- Get volume of an item
-- @param item_id Item ID
-- @return number Item volume
function TransferManager:get_item_volume(item_id)
    -- Placeholder - would look up item volume from data
    return 1  -- Default volume
end

--- Calculate distance between two bases
-- @param origin_id Origin base ID or "void"
-- @param destination_id Destination base ID
-- @return number Distance in tiles
function TransferManager:calculate_distance(origin_id, destination_id)
    if origin_id == "void" then
        return 0  -- Void transfers have no distance cost
    end

    -- Placeholder - would calculate actual tile distance between bases
    return 10  -- Default distance
end

--- Calculate transfer cost
-- @param distance Distance in tiles
-- @param requirements Resource requirements
-- @param priority Transfer priority
-- @return number Total cost in credits
function TransferManager:calculate_cost(distance, requirements, priority)
    local base_cost = distance * (
        (requirements.unit_capacity * self.cost_factors.unit_cost_factor) +
        (requirements.volume_capacity * self.cost_factors.item_cost_factor)
    ) + self.cost_factors.base_fixed_cost

    local priority_multiplier = self.priority_multipliers[priority] or 1.0

    return math.floor(base_cost * priority_multiplier)
end

--- Calculate transit time in days
-- @param distance Distance in tiles
-- @param delivery_time Override delivery time (for purchases)
-- @return number Transit time in days
function TransferManager:calculate_transit_days(distance, delivery_time)
    if delivery_time then
        return delivery_time  -- Override for purchases
    end

    return distance * self.cost_factors.days_per_tile + self.cost_factors.fixed_overhead_days
end

--- Validate that origin base has the required items
-- @param origin_id Origin base ID
-- @param payload Required payload
-- @return boolean True if valid
function TransferManager:validate_origin_inventory(origin_id, payload)
    local base_manager = self.registry and self.registry:resolve("base_manager")
    if not base_manager then return true end  -- Assume valid if no base manager

    for _, item in ipairs(payload) do
        if not base_manager:has_item(origin_id, item.id, item.quantity or 1) then
            return false
        end
    end

    return true
end

--- Validate that destination base has capacity for the payload
-- @param destination_id Destination base ID
-- @param payload Incoming payload
-- @return boolean True if valid
function TransferManager:validate_destination_capacity(destination_id, payload)
    local base_manager = self.registry and self.registry:resolve("base_manager")
    if not base_manager or not base_manager.has_capacity then return true end  -- Assume valid if no base manager

    local requirements = self:calculate_requirements(payload)
    return base_manager:has_capacity(destination_id, requirements.unit_capacity, requirements.volume_capacity)
end

--- Reserve resources in origin base
-- @param origin_id Origin base ID
-- @param payload Payload to reserve
function TransferManager:reserve_origin_resources(origin_id, payload)
    local base_manager = self.registry and self.registry:resolve("base_manager")
    if not base_manager then return end

    for _, item in ipairs(payload) do
        base_manager:reserve_item(origin_id, item.id, item.quantity or 1)
    end
end

--- Reserve capacity in destination base
-- @param destination_id Destination base ID
-- @param payload Payload requiring capacity
function TransferManager:reserve_destination_capacity(destination_id, payload)
    local base_manager = self.registry and self.registry:resolve("base_manager")
    if not base_manager or not base_manager.reserve_capacity then return end

    local requirements = self:calculate_requirements(payload)
    base_manager:reserve_capacity(destination_id, requirements.unit_capacity, requirements.volume_capacity)
end

--- Start a pending transfer
-- @param transfer_id Transfer ID to start
-- @return boolean Success status
function TransferManager:start_transfer(transfer_id)
    local transfer = self.transfers[transfer_id]
    if not transfer then
        return false, "Transfer not found"
    end

    if transfer.status ~= TransferManager.STATUS_PENDING then
        return false, "Transfer not pending"
    end

    -- Assign transport if needed
    if not transfer.transport_id and transfer.origin_id ~= "void" then
        transfer.transport_id = self:assign_transport(transfer)
        if not transfer.transport_id then
            return false, "No available transport"
        end
    end

    transfer.status = TransferManager.STATUS_ACTIVE
    self.active_transfers[transfer_id] = transfer

    -- Publish start event
    if self.event_bus then
        self.event_bus:publish("transfer:started", {
            transfer_id = transfer_id,
            transport_id = transfer.transport_id
        })
    end

    if self.logger then
        self.logger:info("TransferManager", string.format("Started transfer %d", transfer_id))
    end

    return true
end

--- Assign a transport to a transfer
-- @param transfer Transfer object
-- @return string Transport ID or nil if none available
function TransferManager:assign_transport(transfer)
    -- Placeholder - would find available transport with sufficient capacity
    return "transport_1"  -- Default transport
end

--- Update transfers (called daily)
function TransferManager:update()
    for transfer_id, transfer in pairs(self.active_transfers) do
        self:update_transfer(transfer_id)
    end
end

--- Update a specific transfer
-- @param transfer_id Transfer ID to update
function TransferManager:update_transfer(transfer_id)
    local transfer = self.transfers[transfer_id]
    if not transfer or transfer.status ~= TransferManager.STATUS_ACTIVE then
        return
    end

    transfer.progress_days = transfer.progress_days + 1

    -- Check if transfer is complete
    if transfer.progress_days >= transfer.total_days then
        self:complete_transfer(transfer_id)
    end
end

--- Complete a transfer
-- @param transfer_id Transfer ID to complete
function TransferManager:complete_transfer(transfer_id)
    local transfer = self.transfers[transfer_id]
    if not transfer then return end

    transfer.status = TransferManager.STATUS_COMPLETED
    self.active_transfers[transfer_id] = nil

    -- Deliver payload to destination
    self:deliver_payload(transfer)

    -- Release reservations
    self:release_reservations(transfer)

    -- Publish completion event
    if self.event_bus then
        self.event_bus:publish("transfer:completed", {
            transfer_id = transfer_id,
            destination_id = transfer.destination_id
        })
    end

    if self.logger then
        self.logger:info("TransferManager", string.format("Completed transfer %d", transfer_id))
    end
end

--- Deliver payload to destination base
-- @param transfer Transfer object
function TransferManager:deliver_payload(transfer)
    local base_manager = self.registry and self.registry:resolve("base_manager")
    if not base_manager then return end

    for _, item in ipairs(transfer.payload) do
        if transfer.origin_id == "void" then
            -- Void origin - create items directly
            base_manager:add_item(transfer.destination_id, item.id, item.quantity or 1)
        else
            -- Move items from origin to destination
            base_manager:move_item(transfer.origin_id, transfer.destination_id, item.id, item.quantity or 1)
        end
    end
end

--- Release resource reservations
-- @param transfer Transfer object
function TransferManager:release_reservations(transfer)
    -- Reservations are automatically released when items are moved/delivered
    -- Additional cleanup if needed
end

--- Cancel a transfer
-- @param transfer_id Transfer ID to cancel
-- @return boolean Success status
-- @return number Refund amount
function TransferManager:cancel_transfer(transfer_id)
    local transfer = self.transfers[transfer_id]
    if not transfer then
        return false, 0
    end

    if transfer.status == TransferManager.STATUS_COMPLETED or
       transfer.status == TransferManager.STATUS_CANCELLED then
        return false, 0
    end

    local refund_amount = self:calculate_refund(transfer)

    -- Refund funds
    if refund_amount > 0 then
        local finance_system = self.registry and self.registry:resolve("finance")
        if finance_system then
            finance_system:add_funds(refund_amount)
        end
    end

    -- Release reservations
    self:release_reservations(transfer)

    -- Update status
    transfer.status = TransferManager.STATUS_CANCELLED
    if self.active_transfers[transfer_id] then
        self.active_transfers[transfer_id] = nil
    end

    -- Publish cancellation event
    if self.event_bus then
        self.event_bus:publish("transfer:cancelled", {
            transfer_id = transfer_id,
            refund_amount = refund_amount
        })
    end

    if self.logger then
        self.logger:info("TransferManager", string.format("Cancelled transfer %d, refunded %d credits",
            transfer_id, refund_amount))
    end

    return true, refund_amount
end

--- Calculate refund amount for a cancelled transfer
-- @param transfer Transfer object
-- @return number Refund amount
function TransferManager:calculate_refund(transfer)
    if transfer.status == TransferManager.STATUS_PENDING then
        return math.floor(transfer.cost * self.refund_percentages.pre_departure)
    elseif transfer.status == TransferManager.STATUS_ACTIVE then
        local progress_ratio = transfer.progress_days / transfer.total_days
        local refund_ratio = self.refund_percentages.in_transit_min +
            (self.refund_percentages.in_transit_max - self.refund_percentages.in_transit_min) * (1 - progress_ratio)
        return math.floor(transfer.cost * refund_ratio)
    end

    return 0
end

--- Get transfer by ID
-- @param transfer_id Transfer ID
-- @return table Transfer object or nil
function TransferManager:get_transfer(transfer_id)
    return self.transfers[transfer_id]
end

--- Get all transfers
-- @return table Array of all transfers
function TransferManager:get_all_transfers()
    local transfers = {}
    for _, transfer in pairs(self.transfers) do
        table.insert(transfers, transfer)
    end
    return transfers
end

--- Get active transfers
-- @return table Array of active transfers
function TransferManager:get_active_transfers()
    local active = {}
    for _, transfer in pairs(self.active_transfers) do
        table.insert(active, transfer)
    end
    return active
end

--- Get pending transfers
-- @return table Array of pending transfers
function TransferManager:get_pending_transfers()
    local pending = {}
    for _, transfer in pairs(self.transfers) do
        if transfer.status == TransferManager.STATUS_PENDING then
            table.insert(pending, transfer)
        end
    end
    return pending
end

return TransferManager
