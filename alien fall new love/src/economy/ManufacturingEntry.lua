--- ManufacturingEntry.lua
-- Manufacturing entry system for Alien Fall
-- Defines buildable items with requirements and production recipes

-- GROK: ManufacturingEntry defines production recipes with inputs, outputs, and requirements
-- GROK: Manages resource consumption, facility needs, and production prerequisites
-- GROK: Key methods: meetsRequirements(), calculateCost(), getInputs(), getOutputs()
-- GROK: Integrates with ManufacturingProject for actual production execution

local class = require 'lib.Middleclass'

ManufacturingEntry = class('ManufacturingEntry')

--- Initialize a new manufacturing entry
-- @param data The manufacturing entry data
function ManufacturingEntry:initialize(data)
    -- Basic entry information
    self.id = data.id
    self.name = data.name or self.id
    self.description = data.description or ""

    -- Production requirements
    self.category = data.category or "general"
    self.manHours = data.manHours or 100  -- Engineering hours required
    self.productionTime = data.productionTime or 5  -- Days to complete (estimate)

    -- Inputs and outputs
    self.inputs = data.inputs or {}  -- Array of {id, quantity, type} entries
    self.outputs = data.outputs or {}  -- Array of {id, quantity, type} entries

    -- Milestone outputs (produced at percentage completion points)
    self.milestones = data.milestones or {}  -- Array of {percentage, outputs} entries

    -- Requirements
    self.requirements = data.requirements or {}

    -- Facility requirements
    self.facilityRequirements = data.facilityRequirements or {}

    -- Cost information
    self.baseCost = data.baseCost or 0  -- Fixed cost in credits
    self.engineerCostPerDay = data.engineerCostPerDay or 500  -- Cost per engineer per day

    -- Metadata
    self.isUnlocked = data.isUnlocked or false

    -- Event integration
    self.eventBus = self:_getEventBus()

    -- Validate data
    self:_validate()
end

--- Get the event bus for integration
function ManufacturingEntry:_getEventBus()
    local registry = require 'services.registry'
    return registry:getService('eventBus')
end

--- Validate the manufacturing entry data
function ManufacturingEntry:_validate()
    assert(self.id, "Manufacturing entry must have an id")
    assert(self.name, "Manufacturing entry must have a name")
    assert(type(self.manHours) == "number" and self.manHours > 0, "Man hours must be a positive number")
    assert(type(self.productionTime) == "number" and self.productionTime > 0, "Production time must be a positive number")

    -- Validate inputs
    assert(type(self.inputs) == "table", "Inputs must be a table")
    for i, input in ipairs(self.inputs) do
        assert(input.id, "Input " .. i .. " must have an id")
        assert(type(input.quantity) == "number" and input.quantity > 0, "Input " .. i .. " quantity must be positive")
        assert(input.type, "Input " .. i .. " must have a type")
    end

    -- Validate outputs
    assert(type(self.outputs) == "table", "Outputs must be a table")
    for i, output in ipairs(self.outputs) do
        assert(output.id, "Output " .. i .. " must have an id")
        assert(type(output.quantity) == "number" and output.quantity > 0, "Output " .. i .. " quantity must be positive")
        assert(output.type, "Output " .. i .. " must have a type")
    end

    -- Validate milestones
    assert(type(self.milestones) == "table", "Milestones must be a table")
    for i, milestone in ipairs(self.milestones) do
        assert(type(milestone.percentage) == "number" and milestone.percentage > 0 and milestone.percentage <= 100,
               "Milestone " .. i .. " percentage must be between 1-100")
        assert(type(milestone.outputs) == "table", "Milestone " .. i .. " must have outputs table")
        for j, output in ipairs(milestone.outputs) do
            assert(output.id, "Milestone " .. i .. " output " .. j .. " must have an id")
            assert(type(output.quantity) == "number" and output.quantity > 0,
                   "Milestone " .. i .. " output " .. j .. " quantity must be positive")
            assert(output.type, "Milestone " .. i .. " output " .. j .. " must have a type")
        end
    end
end

--- Check if this manufacturing entry meets all requirements
-- @param gameState The current game state
function ManufacturingEntry:meetsRequirements(gameState)
    -- Check research requirements
    if self.requirements.research then
        for _, researchId in ipairs(self.requirements.research) do
            if not self:_isResearchCompleted(researchId, gameState) then
                return false
            end
        end
    end

    -- Check facility requirements
    if not self:_meetsFacilityRequirements(gameState) then
        return false
    end

    -- Check other requirements (services, etc.)
    if self.requirements.services then
        for _, serviceId in ipairs(self.requirements.services) do
            if not self:_isServiceAvailable(serviceId, gameState) then
                return false
            end
        end
    end

    return true
end

--- Check if research is completed
-- @param researchId The research ID to check
-- @param gameState The current game state
function ManufacturingEntry:_isResearchCompleted(researchId, gameState)
    -- This would integrate with the research system
    if gameState.researchTree then
        return gameState.researchTree:isCompleted(researchId)
    end
    return false
end

--- Check if facility requirements are met
-- @param gameState The current game state
function ManufacturingEntry:_meetsFacilityRequirements(gameState)
    for _, facilityReq in ipairs(self.facilityRequirements) do
        local facilityId = facilityReq.id
        local requiredLevel = facilityReq.level or 1

        if not self:_hasFacility(facilityId, requiredLevel, gameState) then
            return false
        end
    end

    return true
end

--- Check if a facility is available at required level
-- @param facilityId The facility ID
-- @param requiredLevel The required level
-- @param gameState The current game state
function ManufacturingEntry:_hasFacility(facilityId, requiredLevel, gameState)
    -- This would integrate with the base/facility system
    if gameState.facilities then
        local facility = gameState.facilities[facilityId]
        return facility and facility.level >= requiredLevel
    end
    return false
end

--- Check if a service is available
-- @param serviceId The service ID
-- @param gameState The current game state
function ManufacturingEntry:_isServiceAvailable(serviceId, gameState)
    -- This would integrate with the base services system
    if gameState.services then
        return gameState.services[serviceId] == true
    end
    return false
end

--- Check if all input resources are available
-- @param baseId The base ID to check inventory
-- @param gameState The current game state
function ManufacturingEntry:hasRequiredInputs(baseId, gameState)
    for _, input in ipairs(self.inputs) do
        local available = self:_getItemQuantity(input.id, input.type, baseId, gameState)
        if available < input.quantity then
            return false
        end
    end

    return true
end

--- Get the quantity of an item in a base
-- @param itemId The item ID
-- @param itemType The item type
-- @param baseId The base ID
-- @param gameState The current game state
function ManufacturingEntry:_getItemQuantity(itemId, itemType, baseId, gameState)
    -- This would integrate with the inventory system
    if gameState.inventory and gameState.inventory[baseId] then
        local baseInventory = gameState.inventory[baseId]
        if baseInventory[itemType] and baseInventory[itemType][itemId] then
            return baseInventory[itemType][itemId]
        end
    end
    return 0
end

--- Calculate the total cost of manufacturing this entry
-- @param engineerCount Number of engineers assigned
-- @param modifiers Cost modifiers
function ManufacturingEntry:calculateCost(engineerCount, modifiers)
    modifiers = modifiers or {}

    -- Base cost
    local cost = self.baseCost

    -- Engineer costs: cost per engineer per day * estimated days
    local estimatedDays = self:calculateProductionTime(engineerCount, modifiers)
    cost = cost + (self.engineerCostPerDay * engineerCount * estimatedDays)

    -- Apply modifiers
    if modifiers.costMultiplier then
        cost = cost * modifiers.costMultiplier
    end

    return math.floor(cost)
end

--- Calculate the production time in days
-- @param engineerCount Number of engineers assigned
-- @param modifiers Time modifiers
function ManufacturingEntry:calculateProductionTime(engineerCount, modifiers)
    modifiers = modifiers or {}
    engineerCount = engineerCount or 1

    -- Base calculation: man-hours / (engineers * hours per day)
    local hoursPerDay = 8  -- Standard work day
    local dailyCapacity = engineerCount * hoursPerDay

    local days = self.manHours / dailyCapacity

    -- Apply modifiers
    if modifiers.timeMultiplier then
        days = days * modifiers.timeMultiplier
    end

    return math.max(1, math.ceil(days))
end

--- Get the inputs required for this manufacturing entry
function ManufacturingEntry:getInputs()
    return self.inputs
end

--- Get the outputs produced by this manufacturing entry
function ManufacturingEntry:getOutputs()
    return self.outputs
end

--- Get milestone outputs for this manufacturing entry
function ManufacturingEntry:getMilestones()
    return self.milestones
end

--- Get facility requirements
function ManufacturingEntry:getFacilityRequirements()
    return self.facilityRequirements
end

--- Get research requirements
function ManufacturingEntry:getResearchRequirements()
    return self.requirements.research or {}
end

--- Reserve inputs for manufacturing
-- @param baseId The base ID
-- @param gameState The current game state
function ManufacturingEntry:reserveInputs(baseId, gameState)
    for _, input in ipairs(self.inputs) do
        self:_reserveItem(input.id, input.type, input.quantity, baseId, gameState)
    end
end

--- Release reserved inputs
-- @param baseId The base ID
-- @param gameState The current game state
function ManufacturingEntry:releaseInputs(baseId, gameState)
    for _, input in ipairs(self.inputs) do
        self:_releaseReservedItem(input.id, input.type, input.quantity, baseId, gameState)
    end
end

--- Add outputs to inventory
-- @param baseId The base ID
-- @param gameState The current game state
-- @param overflowPolicy Policy for handling storage overflow ("fail", "queue", "auto_sell", "auto_transfer")
function ManufacturingEntry:addOutputs(baseId, gameState, overflowPolicy)
    overflowPolicy = overflowPolicy or "fail"

    for _, output in ipairs(self.outputs) do
        local success = self:_addItemWithOverflowCheck(output.id, output.type, output.quantity, baseId, gameState, overflowPolicy)
        if not success and overflowPolicy == "fail" then
            -- For fail policy, stop processing if any item fails
            return false
        end
    end

    return true
end

--- Reserve an item in inventory
function ManufacturingEntry:_reserveItem(itemId, itemType, quantity, baseId, gameState)
    -- This would integrate with the inventory system
    if gameState.inventory and gameState.inventory[baseId] then
        local baseInventory = gameState.inventory[baseId]
        if baseInventory[itemType] and baseInventory[itemType][itemId] then
            baseInventory[itemType][itemId] = baseInventory[itemType][itemId] - quantity
            -- Track reserved items separately
            if not baseInventory.reserved then baseInventory.reserved = {} end
            if not baseInventory.reserved[itemType] then baseInventory.reserved[itemType] = {} end
            baseInventory.reserved[itemType][itemId] = (baseInventory.reserved[itemType][itemId] or 0) + quantity
        end
    end
end

--- Release a reserved item
function ManufacturingEntry:_releaseReservedItem(itemId, itemType, quantity, baseId, gameState)
    -- This would integrate with the inventory system
    if gameState.inventory and gameState.inventory[baseId] then
        local baseInventory = gameState.inventory[baseId]
        if baseInventory.reserved and baseInventory.reserved[itemType] and baseInventory.reserved[itemType][itemId] then
            baseInventory.reserved[itemType][itemId] = baseInventory.reserved[itemType][itemId] - quantity
            -- Return to available inventory
            if baseInventory[itemType] then
                baseInventory[itemType][itemId] = (baseInventory[itemType][itemId] or 0) + quantity
            end
        end
    end
end

--- Add an item to inventory
function ManufacturingEntry:_addItem(itemId, itemType, quantity, baseId, gameState)
    -- This would integrate with the inventory system
    if gameState.inventory and gameState.inventory[baseId] then
        local baseInventory = gameState.inventory[baseId]
        if not baseInventory[itemType] then baseInventory[itemType] = {} end
        baseInventory[itemType][itemId] = (baseInventory[itemType][itemId] or 0) + quantity
    end
end

--- Add an item to inventory with overflow handling
function ManufacturingEntry:_addItemWithOverflowCheck(itemId, itemType, quantity, baseId, gameState, overflowPolicy)
    -- Check if there's enough storage space
    local canAdd = self:_canAddItem(itemId, itemType, quantity, baseId, gameState)

    if canAdd then
        self:_addItem(itemId, itemType, quantity, baseId, gameState)
        return true
    else
        -- Apply overflow policy
        return self:_handleOverflow(itemId, itemType, quantity, baseId, gameState, overflowPolicy)
    end
end

--- Check if an item can be added to inventory (storage capacity check)
function ManufacturingEntry:_canAddItem(itemId, itemType, quantity, baseId, gameState)
    -- This would integrate with storage capacity system
    -- For now, assume unlimited storage
    return true
end

--- Handle overflow according to policy
function ManufacturingEntry:_handleOverflow(itemId, itemType, quantity, baseId, gameState, overflowPolicy)
    if overflowPolicy == "fail" then
        return false
    elseif overflowPolicy == "queue" then
        -- Queue the item for later addition when storage becomes available
        self:_queueItemForLater(itemId, itemType, quantity, baseId, gameState)
        return true
    elseif overflowPolicy == "auto_sell" then
        -- Auto-sell the item at reduced price
        self:_autoSellItem(itemId, itemType, quantity, baseId, gameState)
        return true
    elseif overflowPolicy == "auto_transfer" then
        -- Auto-transfer to another base or external storage
        self:_autoTransferItem(itemId, itemType, quantity, baseId, gameState)
        return true
    end

    return false
end

--- Queue item for later addition
function ManufacturingEntry:_queueItemForLater(itemId, itemType, quantity, baseId, gameState)
    -- This would add to a storage queue system
    if self.logger then
        self.logger:info("Queued item for later storage", {itemId = itemId, quantity = quantity, baseId = baseId})
    end
end

--- Auto-sell item at reduced price
function ManufacturingEntry:_autoSellItem(itemId, itemType, quantity, baseId, gameState)
    -- This would integrate with marketplace selling system
    if self.logger then
        self.logger:info("Auto-sold item due to storage overflow", {itemId = itemId, quantity = quantity, baseId = baseId})
    end
end

--- Auto-transfer item to another location
function ManufacturingEntry:_autoTransferItem(itemId, itemType, quantity, baseId, gameState)
    -- This would integrate with transfer system
    if self.logger then
        self.logger:info("Auto-transferred item due to storage overflow", {itemId = itemId, quantity = quantity, baseId = baseId})
    end
end

--- Get manufacturing entry summary
function ManufacturingEntry:getSummary()
    return {
        id = self.id,
        name = self.name,
        category = self.category,
        manHours = self.manHours,
        productionTime = self.productionTime,
        inputCount = #self.inputs,
        outputCount = #self.outputs,
        milestoneCount = #self.milestones,
        baseCost = self.baseCost,
        isUnlocked = self.isUnlocked
    }
end

--- Check if entry is unlocked
function ManufacturingEntry:isEntryUnlocked()
    return self.isUnlocked
end

--- Unlock this manufacturing entry
function ManufacturingEntry:unlockEntry()
    if self.isUnlocked then return end

    self.isUnlocked = true

    -- Emit unlock event
    if self.eventBus then
        self.eventBus:emit("manufacturing:entry_unlocked", {
            entryId = self.id,
            entryName = self.name,
            category = self.category
        })
    end
end

--- Get the category
function ManufacturingEntry:getCategory()
    return self.category
end

--- Get man-hours required
function ManufacturingEntry:getManHours()
    return self.manHours
end

--- Get base cost
function ManufacturingEntry:getBaseCost()
    return self.baseCost
end

return ManufacturingEntry
