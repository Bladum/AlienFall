--- ItemService.lua
-- Comprehensive item management service for Alien Fall
-- Manages all item types, damage models, manufacturing recipes, and equipment systems

local class = require 'lib.Middleclass'
local Item = require 'items.Item'
local ItemUnit = require 'items.ItemUnit'
local ItemCraft = require 'items.ItemCraft'
local ItemResource = require 'items.ItemResource'
local ItemLore = require 'items.ItemLore'
local ItemPrisoner = require 'items.ItemPrisoner'

--- ItemService class
-- @type ItemService
ItemService = class('ItemService')

--- Damage types enumeration
ItemService.DAMAGE_TYPES = {
    KINETIC = "kinetic",
    ENERGY = "energy",
    PLASMA = "plasma",
    CHEMICAL = "chemical",
    PSIONIC = "psionic"
}

--- Item families enumeration
ItemService.FAMILIES = {
    WEAPON = "weapon",
    ARMOR = "armor",
    UTILITY = "utility",
    CONSUMABLE = "consumable",
    RESOURCE = "resource",
    CRAFT_WEAPON = "craft_weapon",
    FACILITY_MODULE = "facility_module",
    LORE = "lore"
}

--- Create a new ItemService instance
-- @param registry Service registry for accessing other systems
-- @return ItemService instance
function ItemService:initialize(registry)
    self.registry = registry

    -- Item collections
    self.items = {} -- item_id -> Item instance
    self.itemTemplates = {} -- item_id -> template data
    self.damageTypes = {} -- damage_type -> damage data
    self.recipes = {} -- recipe_id -> recipe data
    self.statusEffects = {} -- effect_id -> effect data

    -- Inventory management
    self.inventories = {} -- owner_id -> {item_id -> quantity}

    -- Manufacturing queues
    self.manufacturingQueues = {} -- base_id -> {queue of manufacturing jobs}

    -- Load item data
    self:_loadItemData()

    -- Note: Service registration is handled by ServiceRegistry
end

--- Load item-related data from data files
function ItemService:_loadItemData()
    if not self.registry then return end

    local dataRegistry = self.registry:resolve('data_registry')
    if not dataRegistry then return end

    -- Load damage types
    self:_loadDamageTypes(dataRegistry)

    -- Load status effects
    self:_loadStatusEffects(dataRegistry)

    -- Load recipes
    self:_loadRecipes(dataRegistry)

    -- Load item templates
    self:_loadItemTemplates(dataRegistry)
end

--- Load damage type definitions
function ItemService:_loadDamageTypes(dataRegistry)
    local damageTypes = dataRegistry:get('items', 'damage_types') or {}

    for _, damageData in ipairs(damageTypes) do
        self.damageTypes[damageData.id] = damageData
    end

    -- Set defaults if not loaded
    if not self.damageTypes[ItemService.DAMAGE_TYPES.KINETIC] then
        self.damageTypes[ItemService.DAMAGE_TYPES.KINETIC] = {
            id = ItemService.DAMAGE_TYPES.KINETIC,
            name = "Kinetic",
            armor_multiplier = 1.0,
            default_resistance = 0
        }
    end
end

--- Load status effect definitions
function ItemService:_loadStatusEffects(dataRegistry)
    local statusEffects = dataRegistry:get('items', 'status_effects') or {}

    for _, effectData in ipairs(statusEffects) do
        self.statusEffects[effectData.id] = effectData
    end
end

--- Load manufacturing recipes
function ItemService:_loadRecipes(dataRegistry)
    local recipes = dataRegistry:get('items', 'recipes') or {}

    for _, recipeData in ipairs(recipes) do
        self.recipes[recipeData.id] = recipeData
    end
end

--- Load item templates
function ItemService:_loadItemTemplates(dataRegistry)
    -- Load different item types
    local itemTypes = {
        'items', 'item_unit', 'item_craft', 'item_resource', 'item_lore', 'item_prisoner'
    }

    for _, itemType in ipairs(itemTypes) do
        local items = dataRegistry:get('items', itemType) or {}
        for _, itemData in ipairs(items) do
            self.itemTemplates[itemData.id] = itemData
        end
    end
end

--- Create an item instance from template
-- @param itemId The item template ID
-- @param quantity The quantity to create (optional, defaults to 1)
-- @return Item instance or nil on failure
function ItemService:createItem(itemId, quantity)
    local template = self.itemTemplates[itemId]
    if not template then
        return nil, "Item template not found: " .. itemId
    end

    -- Create appropriate item class based on type
    local itemClass = self:_getItemClassForType(template.type or template.category)
    if not itemClass then
        return nil, "Unknown item type: " .. (template.type or template.category)
    end

    -- Create item instance
    local itemData = {}
    for k, v in pairs(template) do
        itemData[k] = v
    end
    itemData.quantity = quantity or 1

    local item = itemClass:new(itemData)
    self.items[item.id] = item

    -- Fire creation event
    self:_fireEvent('item:created', {item = item, template = template})

    return item
end

--- Get the appropriate item class for a given type
function ItemService:_getItemClassForType(itemType)
    local typeMap = {
        weapon = ItemUnit,
        armor = ItemUnit,
        utility = ItemUnit,
        unit = ItemUnit,
        craft = ItemCraft,
        craft_weapon = ItemCraft,
        resource = ItemResource,
        lore = ItemLore,
        prisoner = ItemPrisoner
    }

    return typeMap[itemType] or Item
end

--- Get item by ID
-- @param itemId The item ID
-- @return Item instance or nil
function ItemService:getItem(itemId)
    return self.items[itemId]
end

--- Get item template by ID
-- @param itemId The item template ID
-- @return Template data or nil
function ItemService:getItemTemplate(itemId)
    return self.itemTemplates[itemId]
end

--- Get all items
-- @return Table of all items (id -> item)
function ItemService:getAllItems()
    return self.items
end

--- Get items by category
-- @param category The item category
-- @return Array of items in the category
function ItemService:getItemsByCategory(category)
    local items = {}
    for _, item in pairs(self.items) do
        if item.category == category then
            table.insert(items, item)
        end
    end
    return items
end

--- Get items by type
-- @param itemType The item type
-- @return Array of items of the type
function ItemService:getItemsByType(itemType)
    local items = {}
    for _, item in pairs(self.items) do
        if item.type == itemType then
            table.insert(items, item)
        end
    end
    return items
end

--- Add item to inventory
-- @param ownerId The owner ID (base, unit, craft, etc.)
-- @param itemId The item ID
-- @param quantity The quantity to add
-- @return success, actual quantity added
function ItemService:addToInventory(ownerId, itemId, quantity)
    if not self.inventories[ownerId] then
        self.inventories[ownerId] = {}
    end

    local currentQty = self.inventories[ownerId][itemId] or 0
    self.inventories[ownerId][itemId] = currentQty + quantity

    -- Fire inventory event
    self:_fireEvent('item:inventory_changed', {
        owner = ownerId,
        item = itemId,
        quantity = quantity,
        action = 'add'
    })

    return true, quantity
end

--- Remove item from inventory
-- @param ownerId The owner ID
-- @param itemId The item ID
-- @param quantity The quantity to remove
-- @return success, actual quantity removed
function ItemService:removeFromInventory(ownerId, itemId, quantity)
    if not self.inventories[ownerId] then
        return false, 0
    end

    local currentQty = self.inventories[ownerId][itemId] or 0
    local removeQty = math.min(quantity, currentQty)

    if removeQty > 0 then
        self.inventories[ownerId][itemId] = currentQty - removeQty

        -- Clean up empty entries
        if self.inventories[ownerId][itemId] <= 0 then
            self.inventories[ownerId][itemId] = nil
        end

        -- Fire inventory event
        self:_fireEvent('item:inventory_changed', {
            owner = ownerId,
            item = itemId,
            quantity = removeQty,
            action = 'remove'
        })
    end

    return true, removeQty
end

--- Get inventory for owner
-- @param ownerId The owner ID
-- @return Inventory table (item_id -> quantity)
function ItemService:getInventory(ownerId)
    return self.inventories[ownerId] or {}
end

--- Check if owner has item
-- @param ownerId The owner ID
-- @param itemId The item ID
-- @param quantity The required quantity (optional, defaults to 1)
-- @return has_item, available_quantity
function ItemService:hasItem(ownerId, itemId, quantity)
    quantity = quantity or 1
    local inventory = self:getInventory(ownerId)
    local available = inventory[itemId] or 0
    return available >= quantity, available
end

--- Transfer item between inventories
-- @param fromOwner The source owner ID
-- @param toOwner The destination owner ID
-- @param itemId The item ID
-- @param quantity The quantity to transfer
-- @return success, actual quantity transferred
function ItemService:transferItem(fromOwner, toOwner, itemId, quantity)
    if not self:hasItem(fromOwner, itemId, quantity) then
        return false, 0
    end

    local success1, removed = self:removeFromInventory(fromOwner, itemId, quantity)
    if not success1 then return false, 0 end

    local success2, added = self:addToInventory(toOwner, itemId, removed)
    if not success2 then
        -- Rollback
        self:addToInventory(fromOwner, itemId, removed)
        return false, 0
    end

    -- Fire transfer event
    self:_fireEvent('item:transferred', {
        from = fromOwner,
        to = toOwner,
        item = itemId,
        quantity = removed
    })

    return true, removed
end

--- Calculate damage with armor mitigation
-- @param damageAmount The base damage amount
-- @param damageType The damage type
-- @param armorValue The armor value
-- @param armorType The armor type (optional)
-- @return final_damage, damage_reduction
function ItemService:calculateDamage(damageAmount, damageType, armorValue, armorType)
    local damageTypeData = self.damageTypes[damageType] or self.damageTypes[ItemService.DAMAGE_TYPES.KINETIC]

    -- Base armor reduction
    local armorMultiplier = damageTypeData.armor_multiplier or 1.0
    local effectiveArmor = armorValue * armorMultiplier

    -- Calculate damage reduction
    local damageReduction = math.min(effectiveArmor, damageAmount * 0.9) -- Max 90% reduction
    local finalDamage = math.max(0, damageAmount - damageReduction)

    return finalDamage, damageReduction
end

--- Get damage type data
-- @param damageType The damage type
-- @return Damage type data or nil
function ItemService:getDamageType(damageType)
    return self.damageTypes[damageType]
end

--- Get status effect data
-- @param effectId The effect ID
-- @return Status effect data or nil
function ItemService:getStatusEffect(effectId)
    return self.statusEffects[effectId]
end

--- Get manufacturing recipe
-- @param recipeId The recipe ID
-- @return Recipe data or nil
function ItemService:getRecipe(recipeId)
    return self.recipes[recipeId]
end

--- Check if recipe can be manufactured
-- @param recipeId The recipe ID
-- @param baseId The base ID for resource checking
-- @return can_manufacture, missing_requirements
function ItemService:canManufacture(recipeId, baseId)
    local recipe = self:getRecipe(recipeId)
    if not recipe then
        return false, {"Recipe not found"}
    end

    local missing = {}

    -- Check inputs
    if recipe.inputs then
        for _, input in ipairs(recipe.inputs) do
            if not self:hasItem(baseId, input.item, input.quantity) then
                table.insert(missing, string.format("%s x%d", input.item, input.quantity))
            end
        end
    end

    -- Check research requirements
    if recipe.research_required then
        -- Would need to check with research service
        -- For now, assume available
    end

    return #missing == 0, missing
end

--- Start manufacturing job
-- @param recipeId The recipe ID
-- @param baseId The base ID
-- @param quantity The quantity to manufacture
-- @return success, job_id, estimated_time
function ItemService:startManufacturing(recipeId, baseId, quantity)
    local canManufacture, missing = self:canManufacture(recipeId, baseId)
    if not canManufacture then
        return false, nil, 0, "Missing requirements: " .. table.concat(missing, ", ")
    end

    local recipe = self:getRecipe(recipeId)
    local jobId = string.format("manufacture_%s_%s_%d", recipeId, baseId, os.time())

    -- Calculate time (simplified)
    local timePerUnit = recipe.manufacture_time or 60 -- minutes
    local totalTime = timePerUnit * quantity

    -- Consume inputs
    if recipe.inputs then
        for _, input in ipairs(recipe.inputs) do
            self:removeFromInventory(baseId, input.item, input.quantity * quantity)
        end
    end

    -- Add to manufacturing queue
    if not self.manufacturingQueues[baseId] then
        self.manufacturingQueues[baseId] = {}
    end

    local job = {
        id = jobId,
        recipe_id = recipeId,
        base_id = baseId,
        quantity = quantity,
        remaining_time = totalTime,
        start_time = os.time(),
        status = "in_progress"
    }

    table.insert(self.manufacturingQueues[baseId], job)

    -- Fire manufacturing event
    self:_fireEvent('item:manufacturing_started', job)

    return true, jobId, totalTime
end

--- Update manufacturing queues
-- @param deltaTime Time elapsed in minutes
function ItemService:updateManufacturing(deltaTime)
    for baseId, queue in pairs(self.manufacturingQueues) do
        local i = 1
        while i <= #queue do
            local job = queue[i]
            if job.status == "in_progress" then
                job.remaining_time = job.remaining_time - deltaTime

                if job.remaining_time <= 0 then
                    -- Job complete
                    self:_completeManufacturingJob(job)
                    table.remove(queue, i)
                else
                    i = i + 1
                end
            else
                i = i + 1
            end
        end
    end
end

--- Complete a manufacturing job
function ItemService:_completeManufacturingJob(job)
    local recipe = self:getRecipe(job.recipe_id)
    if not recipe then return end

    -- Create output items
    if recipe.outputs then
        for _, output in ipairs(recipe.outputs) do
            local itemId = output.item
            local quantity = output.quantity * job.quantity

            -- Add to base inventory
            self:addToInventory(job.base_id, itemId, quantity)
        end
    end

    -- Update job status
    job.status = "completed"
    job.completion_time = os.time()

    -- Fire completion event
    self:_fireEvent('item:manufacturing_completed', job)
end

--- Get manufacturing queue for base
-- @param baseId The base ID
-- @return Array of manufacturing jobs
function ItemService:getManufacturingQueue(baseId)
    return self.manufacturingQueues[baseId] or {}
end

--- Fire an event through the event bus
function ItemService:_fireEvent(eventType, data)
    if self.registry then
        local eventBus = self.registry:getService('eventBus')
        if eventBus then
            eventBus:fire(eventType, data)
        end
    end
end

--- Save item service state
-- @return Serializable state data
function ItemService:saveState()
    return {
        items = self.items,
        inventories = self.inventories,
        manufacturingQueues = self.manufacturingQueues,
        itemTemplates = self.itemTemplates,
        damageTypes = self.damageTypes,
        recipes = self.recipes,
        statusEffects = self.statusEffects
    }
end

--- Load item service state
-- @param state Saved state data
function ItemService:loadState(state)
    self.items = state.items or {}
    self.inventories = state.inventories or {}
    self.manufacturingQueues = state.manufacturingQueues or {}
    self.itemTemplates = state.itemTemplates or {}
    self.damageTypes = state.damageTypes or {}
    self.recipes = state.recipes or {}
    self.statusEffects = state.statusEffects or {}
end

--- Convert to string representation
-- @return String representation
function ItemService:__tostring()
    local itemCount = 0
    for _ in pairs(self.items) do itemCount = itemCount + 1 end

    return string.format("ItemService{items=%d, templates=%d, recipes=%d}",
                        itemCount, #self.itemTemplates, #self.recipes)
end

return ItemService