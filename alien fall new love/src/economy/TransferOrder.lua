--- TransferOrder.lua
-- Transfer order system for Alien Fall logistics
-- Handles individual transfer operations between bases

-- GROK: TransferOrder represents a single logistics transfer between bases
-- GROK: Manages payload, costs, transit time, and capacity validation
-- GROK: Key methods: calculateCost(), validateCapacity(), reserveResources(), executeTransfer()
-- GROK: Integrates with TransferManager for scheduling and lifecycle management

local class = require 'lib.Middleclass'

TransferOrder = class('TransferOrder')

-- Transfer status constants
TransferOrder.STATUS_PENDING = "pending"
TransferOrder.STATUS_ACTIVE = "active"
TransferOrder.STATUS_COMPLETED = "completed"
TransferOrder.STATUS_CANCELLED = "cancelled"
TransferOrder.STATUS_FAILED = "failed"

-- Transfer priority constants
TransferOrder.PRIORITY_LOW = "low"
TransferOrder.PRIORITY_NORMAL = "normal"
TransferOrder.PRIORITY_HIGH = "high"
TransferOrder.PRIORITY_EMERGENCY = "emergency"

--- Initialize a new transfer order
-- @param data The transfer order data
function TransferOrder:initialize(data)
    -- Basic transfer information
    self.id = data.id or self:_generateId()
    self.originBaseId = data.originBaseId  -- Can be "void" for market deliveries
    self.destinationBaseId = data.destinationBaseId
    self.priority = data.priority or TransferOrder.PRIORITY_NORMAL

    -- Payload information
    self.payload = data.payload or {}  -- Array of payload entries

    -- Transport information
    self.transportId = data.transportId  -- Optional assigned transport

    -- Timing information
    self.creationTime = data.creationTime or 0
    self.departureTime = data.departureTime
    self.arrivalTime = data.arrivalTime
    self.transitDays = data.transitDays or 0
    self.remainingDays = data.remainingDays or self.transitDays

    -- Cost information
    self.cost = data.cost or 0
    self.refundAmount = data.refundAmount or 0

    -- Status and progress
    self.status = data.status or TransferOrder.STATUS_PENDING
    self.progress = data.progress or 0  -- 0-100 percentage

    -- Validation and requirements
    self.capacityRequired = data.capacityRequired or self:_calculateCapacityRequired()
    self.isValidated = data.isValidated or false

    -- Event integration
    self.eventBus = self:_getEventBus()

    -- Validate data
    self:_validate()
end

--- Generate a unique transfer ID
function TransferOrder:_generateId()
    return "transfer_" .. tostring(os.time()) .. "_" .. tostring(math.random(10000, 99999))
end

--- Get the event bus for integration
function TransferOrder:_getEventBus()
    local registry = require 'core.services.registry'
    return registry:getService('eventBus')
end

--- Validate the transfer order data
function TransferOrder:_validate()
    assert(self.originBaseId, "Transfer order must have an origin base ID")
    assert(self.destinationBaseId, "Transfer order must have a destination base ID")
    assert(self.originBaseId ~= self.destinationBaseId, "Origin and destination bases must be different")

    -- Validate priority
    local validPriorities = {
        [TransferOrder.PRIORITY_LOW] = true,
        [TransferOrder.PRIORITY_NORMAL] = true,
        [TransferOrder.PRIORITY_HIGH] = true,
        [TransferOrder.PRIORITY_EMERGENCY] = true
    }
    assert(validPriorities[self.priority], "Invalid transfer priority: " .. tostring(self.priority))

    -- Validate payload
    assert(type(self.payload) == "table", "Payload must be a table")
    for i, entry in ipairs(self.payload) do
        assert(entry.type, "Payload entry " .. i .. " must have a type")
        assert(entry.id, "Payload entry " .. i .. " must have an id")
        assert(entry.quantity and entry.quantity > 0, "Payload entry " .. i .. " must have a positive quantity")
    end
end

--- Calculate the capacity required for this transfer
function TransferOrder:_calculateCapacityRequired()
    local capacity = { units = 0, volume = 0 }

    for _, entry in ipairs(self.payload) do
        if entry.type == "unit" or entry.type == "craft" then
            capacity.units = capacity.units + (entry.size or 1) * entry.quantity
        elseif entry.type == "item" or entry.type == "resource" then
            capacity.volume = capacity.volume + (entry.volume or 1) * entry.quantity
        end
    end

    return capacity
end

--- Calculate the total cost of this transfer
-- @param distance The tile path distance between bases
-- @param config The transfer configuration parameters
function TransferOrder:calculateCost(distance, config)
    config = config or self:_getDefaultConfig()

    -- Market deliveries are free
    if self.originBaseId == "void" then
        self.cost = 0
        return 0
    end

    -- Base cost calculation: distance * (unit factor * unit size + item factor * item volume) + base cost
    local unitCost = 0
    local itemCost = 0

    for _, entry in ipairs(self.payload) do
        if entry.type == "unit" or entry.type == "craft" then
            unitCost = unitCost + (entry.size or 1) * entry.quantity
        elseif entry.type == "item" or entry.type == "resource" then
            itemCost = itemCost + (entry.volume or 1) * entry.quantity
        end
    end

    local baseCost = distance * (
        config.unitCostFactor * unitCost +
        config.itemCostFactor * itemCost
    ) + config.baseFixedCost

    -- Apply priority multiplier
    local priorityMultipliers = {
        [TransferOrder.PRIORITY_LOW] = config.lowPriorityMultiplier,
        [TransferOrder.PRIORITY_NORMAL] = 1.0,
        [TransferOrder.PRIORITY_HIGH] = config.highPriorityMultiplier,
        [TransferOrder.PRIORITY_EMERGENCY] = config.emergencyPriorityMultiplier
    }

    self.cost = math.floor(baseCost * priorityMultipliers[self.priority])
    return self.cost
end

--- Calculate transit time in days
-- @param distance The tile path distance between bases
-- @param config The transfer configuration parameters
function TransferOrder:calculateTransitTime(distance, config)
    config = config or self:_getDefaultConfig()

    -- Market deliveries have fixed delivery time
    if self.originBaseId == "void" then
        self.transitDays = config.marketDeliveryTime or 1
        self.remainingDays = self.transitDays
        return self.transitDays
    end

    -- Standard calculation: distance * days per tile + fixed overhead
    self.transitDays = distance * config.daysPerTile + config.fixedOverheadDays
    self.remainingDays = self.transitDays
    return self.transitDays
end

--- Validate that the assigned transport has sufficient capacity
-- @param transportCapacity The transport's capacity {units, volume}
function TransferOrder:validateCapacity(transportCapacity)
    if not transportCapacity then return false end

    local required = self.capacityRequired
    return transportCapacity.units >= required.units and transportCapacity.volume >= required.volume
end

--- Reserve resources for this transfer
-- @param originBase The origin base object
-- @param transport The assigned transport (optional)
function TransferOrder:reserveResources(originBase, transport)
    if self.originBaseId == "void" then return true end  -- Market deliveries don't reserve

    -- Reserve payload items/units from origin base
    for _, entry in ipairs(self.payload) do
        if not originBase:reserveItem(entry.id, entry.quantity) then
            return false
        end
    end

    -- Reserve transport if assigned
    if transport then
        transport.reserved = true
        transport.reservedUntil = self.arrivalTime
    end

    return true
end

--- Release reserved resources
-- @param originBase The origin base object
-- @param transport The assigned transport (optional)
function TransferOrder:releaseResources(originBase, transport)
    if self.originBaseId == "void" then return end  -- Market deliveries don't reserve

    -- Release payload items/units back to origin base
    for _, entry in ipairs(self.payload) do
        originBase:releaseReservedItem(entry.id, entry.quantity)
    end

    -- Release transport if assigned
    if transport and transport.reserved then
        transport.reserved = false
        transport.reservedUntil = nil
    end
end

--- Execute the transfer (move to active status)
function TransferOrder:executeTransfer()
    if self.status ~= TransferOrder.STATUS_PENDING then return false end

    self.status = TransferOrder.STATUS_ACTIVE
    self.departureTime = self:_getCurrentTime()

    -- Emit transfer started event
    if self.eventBus then
        self.eventBus:emit("transfer:started", {
            transferId = self.id,
            originBaseId = self.originBaseId,
            destinationBaseId = self.destinationBaseId,
            payload = self.payload,
            cost = self.cost
        })
    end

    return true
end

--- Update transfer progress (called daily)
function TransferOrder:updateProgress()
    if self.status ~= TransferOrder.STATUS_ACTIVE then return end

    self.remainingDays = self.remainingDays - 1
    self.progress = math.floor(((self.transitDays - self.remainingDays) / self.transitDays) * 100)

    -- Emit progress update event
    if self.eventBus then
        self.eventBus:emit("transfer:progress", {
            transferId = self.id,
            progress = self.progress,
            remainingDays = self.remainingDays
        })
    end

    -- Check if transfer is complete
    if self.remainingDays <= 0 then
        self:_completeTransfer()
    end
end

--- Complete the transfer
function TransferOrder:_completeTransfer()
    self.status = TransferOrder.STATUS_COMPLETED
    self.progress = 100
    self.arrivalTime = self:_getCurrentTime()

    -- Emit transfer completed event
    if self.eventBus then
        self.eventBus:emit("transfer:completed", {
            transferId = self.id,
            originBaseId = self.originBaseId,
            destinationBaseId = self.destinationBaseId,
            payload = self.payload
        })
    end
end

--- Cancel the transfer
-- @param reason The cancellation reason
function TransferOrder:cancelTransfer(reason)
    if self.status == TransferOrder.STATUS_COMPLETED or self.status == TransferOrder.STATUS_CANCELLED then
        return false
    end

    self.status = TransferOrder.STATUS_CANCELLED

    -- Calculate refund based on progress
    if self.status == TransferOrder.STATUS_ACTIVE then
        local progressRatio = (self.transitDays - self.remainingDays) / self.transitDays
        self.refundAmount = math.floor(self.cost * (1 - progressRatio) * 0.8)  -- 80% refund minus progress penalty
    else
        self.refundAmount = math.floor(self.cost * 0.9)  -- 90% refund for pending transfers
    end

    -- Emit transfer cancelled event
    if self.eventBus then
        self.eventBus:emit("transfer:cancelled", {
            transferId = self.id,
            reason = reason or "user_cancelled",
            refundAmount = self.refundAmount
        })
    end

    return true
end

--- Fail the transfer
-- @param reason The failure reason
function TransferOrder:failTransfer(reason)
    if self.status ~= TransferOrder.STATUS_ACTIVE then return false end

    self.status = TransferOrder.STATUS_FAILED

    -- Emit transfer failed event
    if self.eventBus then
        self.eventBus:emit("transfer:failed", {
            transferId = self.id,
            reason = reason or "unknown_failure"
        })
    end

    return true
end

--- Get default configuration parameters
function TransferOrder:_getDefaultConfig()
    return {
        unitCostFactor = 10,
        itemCostFactor = 2,
        baseFixedCost = 50,
        daysPerTile = 1,
        fixedOverheadDays = 1,
        marketDeliveryTime = 1,
        lowPriorityMultiplier = 0.8,
        highPriorityMultiplier = 1.5,
        emergencyPriorityMultiplier = 2.0
    }
end

--- Get current time (days elapsed)
function TransferOrder:_getCurrentTime()
    local timeSystem = self:_getTimeSystem()
    return timeSystem and timeSystem:getDaysElapsed() or 0
end

--- Get the time system
function TransferOrder:_getTimeSystem()
    local registry = require 'services.registry'
    return registry:getService('timeSystem')
end

--- Get transfer status as string
function TransferOrder:getStatusString()
    return self.status
end

--- Check if transfer is in progress
function TransferOrder:isInProgress()
    return self.status == TransferOrder.STATUS_ACTIVE
end

--- Check if transfer is completed
function TransferOrder:isCompleted()
    return self.status == TransferOrder.STATUS_COMPLETED
end

--- Check if transfer is pending
function TransferOrder:isPending()
    return self.status == TransferOrder.STATUS_PENDING
end

--- Get transfer summary for UI display
function TransferOrder:getSummary()
    return {
        id = self.id,
        originBaseId = self.originBaseId,
        destinationBaseId = self.destinationBaseId,
        status = self.status,
        priority = self.priority,
        progress = self.progress,
        remainingDays = self.remainingDays,
        cost = self.cost,
        payloadCount = #self.payload
    }
end

return TransferOrder
