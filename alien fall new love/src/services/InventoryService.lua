--- Inventory Service
-- Centralized inventory management for items, equipment, and resources
--
-- @classmod services.InventoryService

-- GROK: InventoryService manages global inventory across bases and missions
-- GROK: Handles item stacking, transfers, loot processing, and manufacturing integration
-- GROK: Key methods: addItem(), removeItem(), transferItem(), processLoot()
-- GROK: Integrates with manufacturing, missions, and base management

local class = require 'lib.Middleclass'

--- InventoryService class
-- @type InventoryService
local InventoryService = class('InventoryService')

--- Create a new InventoryService
-- @param registry Service registry
-- @return InventoryService instance
function InventoryService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:getService('eventBus') or nil
    
    -- Inventory state per base
    self.baseInventories = {} -- baseId -> {itemId -> quantity}
    
    -- Craft inventories (for missions)
    self.craftInventories = {} -- craftId -> {itemId -> quantity}
    
    -- Global inventory (shared resources)
    self.globalInventory = {} -- itemId -> quantity
    
    -- Register with service registry
    if registry then
        registry:registerService('inventoryService', self)
    end
end

--- Add item to inventory
-- @param location Location identifier (baseId, craftId, or "global")
-- @param itemId Item type ID
-- @param quantity Quantity to add
-- @return boolean Success
function InventoryService:addItem(location, itemId, quantity)
    quantity = quantity or 1
    
    local inventory = self:_getInventory(location)
    if not inventory then return false end
    
    -- Get current quantity
    local currentQty = inventory[itemId] or 0
    inventory[itemId] = currentQty + quantity
    
    -- Emit event
    if self.eventBus then
        self.eventBus:emit('inventory:item_added', {
            location = location,
            itemId = itemId,
            quantity = quantity,
            totalQuantity = inventory[itemId]
        })
    end
    
    return true
end

--- Remove item from inventory
-- @param location Location identifier
-- @param itemId Item type ID
-- @param quantity Quantity to remove
-- @return boolean Success (false if insufficient quantity)
function InventoryService:removeItem(location, itemId, quantity)
    quantity = quantity or 1
    
    local inventory = self:_getInventory(location)
    if not inventory then return false end
    
    local currentQty = inventory[itemId] or 0
    if currentQty < quantity then
        return false -- Insufficient quantity
    end
    
    inventory[itemId] = currentQty - quantity
    
    -- Remove entry if quantity is zero
    if inventory[itemId] <= 0 then
        inventory[itemId] = nil
    end
    
    -- Emit event
    if self.eventBus then
        self.eventBus:emit('inventory:item_removed', {
            location = location,
            itemId = itemId,
            quantity = quantity,
            remainingQuantity = inventory[itemId] or 0
        })
    end
    
    return true
end

--- Transfer item between locations
-- @param fromLocation Source location
-- @param toLocation Destination location
-- @param itemId Item type ID
-- @param quantity Quantity to transfer
-- @return boolean Success
function InventoryService:transferItem(fromLocation, toLocation, itemId, quantity)
    quantity = quantity or 1
    
    -- Check if source has enough
    if not self:hasItem(fromLocation, itemId, quantity) then
        return false
    end
    
    -- Remove from source
    if not self:removeItem(fromLocation, itemId, quantity) then
        return false
    end
    
    -- Add to destination
    if not self:addItem(toLocation, itemId, quantity) then
        -- Rollback removal
        self:addItem(fromLocation, itemId, quantity)
        return false
    end
    
    -- Emit event
    if self.eventBus then
        self.eventBus:emit('inventory:item_transferred', {
            fromLocation = fromLocation,
            toLocation = toLocation,
            itemId = itemId,
            quantity = quantity
        })
    end
    
    return true
end

--- Check if location has item in sufficient quantity
-- @param location Location identifier
-- @param itemId Item type ID
-- @param quantity Required quantity (default 1)
-- @return boolean Has sufficient quantity
function InventoryService:hasItem(location, itemId, quantity)
    quantity = quantity or 1
    
    local inventory = self:_getInventory(location)
    if not inventory then return false end
    
    local currentQty = inventory[itemId] or 0
    return currentQty >= quantity
end

--- Get item quantity at location
-- @param location Location identifier
-- @param itemId Item type ID
-- @return number Quantity (0 if not found)
function InventoryService:getItemQuantity(location, itemId)
    local inventory = self:_getInventory(location)
    if not inventory then return 0 end
    
    return inventory[itemId] or 0
end

--- Get all items at location
-- @param location Location identifier
-- @return table Item ID -> quantity map
function InventoryService:getInventory(location)
    local inventory = self:_getInventory(location)
    if not inventory then return {} end
    
    -- Return copy to prevent external modification
    local copy = {}
    for itemId, quantity in pairs(inventory) do
        copy[itemId] = quantity
    end
    
    return copy
end

--- Get inventory reference (internal)
-- @param location Location identifier
-- @return table|nil Inventory reference or nil
function InventoryService:_getInventory(location)
    if location == "global" then
        return self.globalInventory
    elseif location:match("^base_") then
        if not self.baseInventories[location] then
            self.baseInventories[location] = {}
        end
        return self.baseInventories[location]
    elseif location:match("^craft_") then
        if not self.craftInventories[location] then
            self.craftInventories[location] = {}
        end
        return self.craftInventories[location]
    end
    
    return nil
end

--- Process loot from mission completion
-- @param lootTable Array of {itemId, quantity} entries
-- @param baseId Base to receive loot
-- @return table Summary of processed loot
function InventoryService:processLoot(lootTable, baseId)
    local summary = {
        itemsAdded = 0,
        totalValue = 0,
        items = {}
    }
    
    for _, lootEntry in ipairs(lootTable) do
        local itemId = lootEntry.itemId or lootEntry.id
        local quantity = lootEntry.quantity or 1
        
        if self:addItem(baseId, itemId, quantity) then
            summary.itemsAdded = summary.itemsAdded + 1
            
            -- Track individual items
            table.insert(summary.items, {
                itemId = itemId,
                quantity = quantity
            })
            
            -- Calculate value (TODO: get from item data)
            local itemValue = self:_getItemValue(itemId)
            summary.totalValue = summary.totalValue + (itemValue * quantity)
        end
    end
    
    -- Emit loot processed event
    if self.eventBus then
        self.eventBus:emit('inventory:loot_processed', {
            baseId = baseId,
            summary = summary
        })
    end
    
    return summary
end

--- Get item value from data registry
-- @param itemId Item type ID
-- @return number Item value
function InventoryService:_getItemValue(itemId)
    local dataRegistry = self.registry and self.registry:resolve("data_registry")
    if not dataRegistry then return 0 end
    
    local itemData = dataRegistry:get("item", itemId)
    return itemData and itemData.value or 0
end

--- Process manufacturing completion
-- @param recipe Manufacturing recipe
-- @param baseId Base where manufacturing occurred
function InventoryService:processManufacturing(recipe, baseId)
    -- Consume input materials
    if recipe.materials then
        for materialId, quantity in pairs(recipe.materials) do
            self:removeItem(baseId, materialId, quantity)
        end
    end
    
    -- Add output items
    if recipe.output then
        local outputId = recipe.output.itemId or recipe.output.id
        local outputQty = recipe.output.quantity or 1
        
        self:addItem(baseId, outputId, outputQty)
    end
    
    -- Emit manufacturing event
    if self.eventBus then
        self.eventBus:emit('inventory:manufacturing_completed', {
            baseId = baseId,
            recipeId = recipe.id,
            output = recipe.output
        })
    end
end

--- Load equipment onto craft for mission
-- @param craftId Craft ID
-- @param equipment Equipment list {itemId, quantity}
-- @param sourceBase Base to load from
-- @return boolean Success
function InventoryService:loadEquipment(craftId, equipment, sourceBase)
    -- Validate all items available
    for _, item in ipairs(equipment) do
        if not self:hasItem(sourceBase, item.itemId, item.quantity) then
            return false
        end
    end
    
    -- Transfer all items
    for _, item in ipairs(equipment) do
        if not self:transferItem(sourceBase, craftId, item.itemId, item.quantity) then
            return false
        end
    end
    
    return true
end

--- Unload equipment from craft back to base
-- @param craftId Craft ID
-- @param targetBase Base to unload to
-- @return boolean Success
function InventoryService:unloadEquipment(craftId, targetBase)
    local craftInventory = self:getInventory(craftId)
    
    -- Transfer all items back
    for itemId, quantity in pairs(craftInventory) do
        if not self:transferItem(craftId, targetBase, itemId, quantity) then
            return false
        end
    end
    
    return true
end

--- Get inventory summary across all locations
-- @return table Summary data
function InventoryService:getGlobalSummary()
    local summary = {
        totalItems = 0,
        totalValue = 0,
        byLocation = {}
    }
    
    -- Count global inventory
    local globalCount = 0
    local globalValue = 0
    for itemId, quantity in pairs(self.globalInventory) do
        globalCount = globalCount + quantity
        globalValue = globalValue + (self:_getItemValue(itemId) * quantity)
    end
    summary.byLocation["global"] = {count = globalCount, value = globalValue}
    summary.totalItems = summary.totalItems + globalCount
    summary.totalValue = summary.totalValue + globalValue
    
    -- Count base inventories
    for baseId, inventory in pairs(self.baseInventories) do
        local baseCount = 0
        local baseValue = 0
        for itemId, quantity in pairs(inventory) do
            baseCount = baseCount + quantity
            baseValue = baseValue + (self:_getItemValue(itemId) * quantity)
        end
        summary.byLocation[baseId] = {count = baseCount, value = baseValue}
        summary.totalItems = summary.totalItems + baseCount
        summary.totalValue = summary.totalValue + baseValue
    end
    
    -- Count craft inventories
    for craftId, inventory in pairs(self.craftInventories) do
        local craftCount = 0
        local craftValue = 0
        for itemId, quantity in pairs(inventory) do
            craftCount = craftCount + quantity
            craftValue = craftValue + (self:_getItemValue(itemId) * quantity)
        end
        summary.byLocation[craftId] = {count = craftCount, value = craftValue}
        summary.totalItems = summary.totalItems + craftCount
        summary.totalValue = summary.totalValue + craftValue
    end
    
    return summary
end

--- Clear craft inventory (e.g., after mission)
-- @param craftId Craft ID
function InventoryService:clearCraftInventory(craftId)
    self.craftInventories[craftId] = {}
end

--- Serialize inventory state for saving
-- @return table Serialized state
function InventoryService:serialize()
    return {
        baseInventories = self.baseInventories,
        craftInventories = self.craftInventories,
        globalInventory = self.globalInventory
    }
end

--- Deserialize inventory state from save
-- @param data Saved state
function InventoryService:deserialize(data)
    if not data then return end
    
    self.baseInventories = data.baseInventories or {}
    self.craftInventories = data.craftInventories or {}
    self.globalInventory = data.globalInventory or {}
end

return InventoryService
