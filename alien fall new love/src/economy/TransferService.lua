--- Transfer Service
-- Manages logistics, capacity validation, and inter-base transfers
--
-- @classmod economy.TransferService

-- GROK: TransferService handles all transfer operations with capacity and cost management
-- GROK: Manages transfer lifecycle, scheduling, and delivery tracking
-- GROK: Key methods: createTransfer(), getTransferStatus(), updateTransfers(), validateCapacity()
-- GROK: Integrates with bases, items, units, and crafts for comprehensive logistics

local class = require 'lib.Middleclass'
local TransferManager = require 'economy.TransferManager'

--- TransferService class
-- @type TransferService
TransferService = class('TransferService')

--- Create a new TransferService instance
-- @param registry Service registry for accessing other systems
-- @return TransferService instance
function TransferService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:getService('eventBus') or nil

    -- Initialize transfer manager
    self.manager = TransferManager:new(registry)

    -- Register with service registry
    if registry then
        registry:registerService('transferService', self)
    end
end

--- Create a new transfer
-- @param transferData Transfer configuration {originBase, destBase, items, priority}
-- @return boolean Success status
-- @return string|number Error message or transfer ID
function TransferService:createTransfer(transferData)
    local success, result = self.manager:create_transfer(transferData)

    if success and self.eventBus then
        self.eventBus:emit('transfer:created', {
            transferId = result,
            originBase = transferData.originBase,
            destBase = transferData.destBase,
            priority = transferData.priority
        })
    end

    return success, result
end

--- Create a purchase delivery transfer (void origin)
-- @param supplierId The supplier ID
-- @param itemId The item ID
-- @param quantity The quantity
-- @param baseId The destination base ID
-- @param cost The transfer cost (0 for marketplace)
-- @return boolean Success status
-- @return string|number Error message or transfer ID
function TransferService:createPurchaseTransfer(supplierId, itemId, quantity, baseId, cost)
    local transferData = {
        originBase = "void",
        destBase = baseId,
        items = {{id = itemId, quantity = quantity}},
        priority = "normal",
        cost = cost or 0,
        supplierId = supplierId
    }

    return self:createTransfer(transferData)
end

--- Get transfer status
-- @param transferId The transfer ID
-- @return table|nil Transfer status data or nil if not found
function TransferService:getTransferStatus(transferId)
    return self.manager:get_transfer_status(transferId)
end

--- Get all active transfers
-- @return table Array of active transfer data
function TransferService:getActiveTransfers()
    return self.manager:get_active_transfers()
end

--- Get transfers for a specific base
-- @param baseId The base ID
-- @param includeCompleted Whether to include completed transfers
-- @return table Array of transfer data
function TransferService:getTransfersForBase(baseId, includeCompleted)
    return self.manager:get_transfers_for_base(baseId, includeCompleted)
end

--- Cancel a transfer
-- @param transferId The transfer ID
-- @return boolean Success status
-- @return string Error message if failed
function TransferService:cancelTransfer(transferId)
    local success, message = self.manager:cancel_transfer(transferId)

    if success and self.eventBus then
        self.eventBus:emit('transfer:cancelled', {
            transferId = transferId
        })
    end

    return success, message
end

--- Update transfer progress (called each game hour)
-- @param deltaTime Time elapsed in game hours (default 1)
-- @return number: Number of transfers that arrived
function TransferService:updateTransfers(deltaTime)
    deltaTime = deltaTime or 1
    local arrivedCount = 0
    
    -- Update all active transfers
    local transfers = self:getActiveTransfers()
    for _, transfer in ipairs(transfers) do
        if transfer.eta then
            transfer.eta = transfer.eta - deltaTime
            
            -- Check if arrived
            if transfer.eta <= 0 then
                self:processArrival(transfer.id)
                arrivedCount = arrivedCount + 1
            end
        end
    end
    
    return arrivedCount
end

--- Validate transfer capacity requirements
-- @param transferData The transfer data to validate
-- @return boolean Whether capacity requirements are met
-- @return string Error message if invalid
function TransferService:validateCapacity(transferData)
    return self.manager:validate_capacity(transferData)
end

--- Calculate transfer cost
-- @param transferData The transfer data
-- @return number Transfer cost
function TransferService:calculateCost(transferData)
    return self.manager:calculate_cost(transferData)
end

--- Get transfer capacity information
-- @param transferData The transfer data
-- @return table Capacity information {required, available}
function TransferService:getCapacityInfo(transferData)
    return self.manager:get_capacity_info(transferData)
end

--- Check if transfer can be created
-- @param transferData The transfer data
-- @return boolean Whether transfer can be created
-- @return string Error message if cannot
function TransferService:canCreateTransfer(transferData)
    -- Validate capacity
    local capacityValid, capacityMessage = self:validateCapacity(transferData)
    if not capacityValid then
        return false, capacityMessage
    end

    -- Check funds for non-marketplace transfers
    if transferData.cost and transferData.cost > 0 then
        if not self:_hasSufficientFunds(transferData.cost) then
            return false, "Insufficient funds"
        end
    end

    -- Check origin has required items/units
    if not self:_hasRequiredItems(transferData) then
        return false, "Insufficient items at origin"
    end

    return true, "Transfer can be created"
end

--- Get transfer statistics
-- @return table Transfer statistics
function TransferService:getTransferStats()
    local active = self:getActiveTransfers()

    local stats = {
        active = #active,
        pending = 0,
        inTransit = 0,
        completed = 0,
        cancelled = 0,
        failed = 0
    }

    for _, transfer in ipairs(active) do
        stats[transfer.status] = (stats[transfer.status] or 0) + 1
    end

    return stats
end

--- Process transfer arrival
-- @param transferId The transfer ID that arrived
function TransferService:processArrival(transferId)
    local success = self.manager:process_arrival(transferId)

    if success and self.eventBus then
        local transfer = self:getTransferStatus(transferId)
        if transfer then
            self.eventBus:emit('transfer:arrived', {
                transferId = transferId,
                destBase = transfer.destBase,
                items = transfer.items
            })
        end
    end

    return success
end

--- Check if origin base has required items/units
-- @param transferData The transfer data
-- @return boolean Whether required items exist
function TransferService:_hasRequiredItems(transferData)
    -- TODO: Integrate with base inventory system
    return true -- Placeholder
end

--- Check if player has sufficient funds
-- @param amount The required amount
-- @return boolean Whether sufficient funds exist
function TransferService:_hasSufficientFunds(amount)
    -- TODO: Integrate with finance system
    return true -- Placeholder
end

--- Get transfer state summary
-- @return table: Transfer state
function TransferService:getState()
    local transfers = self:getActiveTransfers()
    
    local pendingCount = 0
    local enRouteCount = 0
    
    for _, transfer in ipairs(transfers) do
        if transfer.status == "pending" then
            pendingCount = pendingCount + 1
        elseif transfer.status == "in_transit" or transfer.status == "inTransit" then
            enRouteCount = enRouteCount + 1
        end
    end
    
    return {
        pending = pendingCount,
        enRoute = enRouteCount,
        total = #transfers
    }
end

return TransferService
