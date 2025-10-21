---@meta

---Unit Inventory System
---Manages unit equipment, weight/bulk limits, quick slots, backpack
---@module inventory_system

local InventorySystem = {}

---@class InventorySlot
---@field slotId string Slot identifier (weapon, armor, belt1-4, quick1-2, backpack1-20)
---@field itemId string|nil Item ID in this slot
---@field quantity number Stack quantity (for stackable items)

---@class UnitInventory
---@field unitId string
---@field slots table<string, InventorySlot> All inventory slots
---@field totalWeight number Current total weight
---@field totalBulk number Current total bulk
---@field maxWeight number Maximum weight capacity
---@field maxBulk number Maximum bulk capacity

-- Configuration
InventorySystem.CONFIG = {
    -- Slot configuration
    WEAPON_SLOTS = {"weapon_primary", "weapon_secondary"},
    ARMOR_SLOT = "armor",
    BELT_SLOTS = {"belt1", "belt2", "belt3", "belt4"},
    QUICK_SLOTS = {"quick1", "quick2"},
    BACKPACK_SIZE = 20, -- 20 backpack slots
    
    -- Weight/bulk limits (base values)
    BASE_MAX_WEIGHT = 50, -- kg
    BASE_MAX_BULK = 30, -- units
    
    -- Penalties for over-encumbrance
    OVERWEIGHT_AP_PENALTY = 2, -- -2 AP per 10kg over
    OVERWEIGHT_ACCURACY_PENALTY = 5, -- -5% accuracy per 10kg over
}

-- Private state: unitId -> UnitInventory
local inventories = {}

---Initialize inventory for a unit
---@param unitId string Unit identifier
---@param maxWeight number|nil Custom max weight
---@param maxBulk number|nil Custom max bulk
function InventorySystem.initUnit(unitId, maxWeight, maxBulk)
    local cfg = InventorySystem.CONFIG
    
    local inv = {
        unitId = unitId,
        slots = {},
        totalWeight = 0,
        totalBulk = 0,
        maxWeight = maxWeight or cfg.BASE_MAX_WEIGHT,
        maxBulk = maxBulk or cfg.BASE_MAX_BULK,
    }
    
    -- Initialize all slots
    for _, slotId in ipairs(cfg.WEAPON_SLOTS) do
        inv.slots[slotId] = {slotId = slotId, itemId = nil, quantity = 0}
    end
    inv.slots[cfg.ARMOR_SLOT] = {slotId = cfg.ARMOR_SLOT, itemId = nil, quantity = 0}
    for _, slotId in ipairs(cfg.BELT_SLOTS) do
        inv.slots[slotId] = {slotId = slotId, itemId = nil, quantity = 0}
    end
    for _, slotId in ipairs(cfg.QUICK_SLOTS) do
        inv.slots[slotId] = {slotId = slotId, itemId = nil, quantity = 0}
    end
    for i = 1, cfg.BACKPACK_SIZE do
        local slotId = "backpack" .. i
        inv.slots[slotId] = {slotId = slotId, itemId = nil, quantity = 0}
    end
    
    inventories[unitId] = inv
    print(string.format("[Inventory] Initialized for %s (weight: %d/%d, bulk: %d/%d)", 
        unitId, inv.totalWeight, inv.maxWeight, inv.totalBulk, inv.maxBulk))
end

---Remove unit from inventory tracking
---@param unitId string Unit identifier
function InventorySystem.removeUnit(unitId)
    inventories[unitId] = nil
end

---Get unit inventory
---@param unitId string Unit identifier
---@return UnitInventory|nil inventory
function InventorySystem.getInventory(unitId)
    return inventories[unitId]
end

---Add item to inventory
---@param unitId string Unit ID
---@param itemId string Item ID
---@param slotId string|nil Specific slot (nil for auto-assign)
---@param quantity number|nil Stack quantity (default 1)
---@return boolean success, string|nil reason
function InventorySystem.addItem(unitId, itemId, slotId, quantity)
    local inv = inventories[unitId]
    if not inv then
        return false, "No inventory for unit"
    end
    
    quantity = quantity or 1
    
    -- Get item data (mock for now)
    local itemData = InventorySystem.getItemData(itemId)
    if not itemData then
        return false, "Unknown item"
    end
    
    -- Check weight/bulk limits
    local newWeight = inv.totalWeight + (itemData.weight * quantity)
    local newBulk = inv.totalBulk + (itemData.bulk * quantity)
    
    if newWeight > inv.maxWeight then
        return false, "Exceeds weight limit"
    end
    if newBulk > inv.maxBulk then
        return false, "Exceeds bulk limit"
    end
    
    -- Find slot
    local targetSlot
    if slotId then
        targetSlot = inv.slots[slotId]
        if not targetSlot then
            return false, "Invalid slot"
        end
        if targetSlot.itemId ~= nil then
            return false, "Slot occupied"
        end
    else
        -- Auto-assign to appropriate slot type
        targetSlot = InventorySystem.findEmptySlot(inv, itemData.slotType)
        if not targetSlot then
            return false, "No empty slots"
        end
    end
    
    -- Add to slot
    targetSlot.itemId = itemId
    targetSlot.quantity = quantity
    inv.totalWeight = newWeight
    inv.totalBulk = newBulk
    
    print(string.format("[Inventory] Added %s x%d to %s slot %s (weight: %d/%d)", 
        itemId, quantity, unitId, targetSlot.slotId, inv.totalWeight, inv.maxWeight))
    
    return true
end

---Remove item from inventory
---@param unitId string Unit ID
---@param slotId string Slot to remove from
---@param quantity number|nil Amount to remove (default all)
---@return boolean success, string|nil itemId
function InventorySystem.removeItem(unitId, slotId, quantity)
    local inv = inventories[unitId]
    if not inv then
        return false, nil
    end
    
    local slot = inv.slots[slotId]
    if not slot or not slot.itemId then
        return false, nil
    end
    
    local itemId = slot.itemId
    local itemData = InventorySystem.getItemData(itemId)
    if not itemData then
        return false, nil
    end
    
    quantity = quantity or slot.quantity
    
    if quantity >= slot.quantity then
        -- Remove entirely
        inv.totalWeight = inv.totalWeight - (itemData.weight * slot.quantity)
        inv.totalBulk = inv.totalBulk - (itemData.bulk * slot.quantity)
        slot.itemId = nil
        slot.quantity = 0
    else
        -- Partial removal
        inv.totalWeight = inv.totalWeight - (itemData.weight * quantity)
        inv.totalBulk = inv.totalBulk - (itemData.bulk * quantity)
        slot.quantity = slot.quantity - quantity
    end
    
    print(string.format("[Inventory] Removed %s x%d from %s slot %s", 
        itemId, quantity, unitId, slotId))
    
    return true, itemId
end

---Move item between slots
---@param unitId string Unit ID
---@param fromSlot string Source slot
---@param toSlot string Destination slot
---@return boolean success
function InventorySystem.moveItem(unitId, fromSlot, toSlot)
    local inv = inventories[unitId]
    if not inv then return false end
    
    local from = inv.slots[fromSlot]
    local to = inv.slots[toSlot]
    
    if not from or not from.itemId then return false end
    if not to or to.itemId then return false end -- Destination must be empty
    
    -- Swap
    to.itemId = from.itemId
    to.quantity = from.quantity
    from.itemId = nil
    from.quantity = 0
    
    print(string.format("[Inventory] Moved item from %s to %s for %s", 
        fromSlot, toSlot, unitId))
    
    return true
end

---Drop item on ground
---@param unitId string Unit ID
---@param slotId string Slot to drop from
---@param groundItems table Ground items list
---@param unitPos table {q, r} Unit position
---@return boolean success
function InventorySystem.dropItem(unitId, slotId, groundItems, unitPos)
    local success, itemId = InventorySystem.removeItem(unitId, slotId)
    if not success then return false end
    
    -- Add to ground items
    table.insert(groundItems, {
        itemId = itemId,
        q = unitPos.q,
        r = unitPos.r,
    })
    
    print(string.format("[Inventory] %s dropped %s at (%d,%d)", 
        unitId, itemId, unitPos.q, unitPos.r))
    
    return true
end

---Pickup item from ground
---@param unitId string Unit ID
---@param itemId string Item to pickup
---@param groundItems table Ground items list
---@param unitPos table {q, r} Unit position
---@return boolean success
function InventorySystem.pickupItem(unitId, itemId, groundItems, unitPos)
    -- Find item on ground
    local itemIndex = nil
    for i, groundItem in ipairs(groundItems) do
        if groundItem.itemId == itemId and groundItem.q == unitPos.q and groundItem.r == unitPos.r then
            itemIndex = i
            break
        end
    end
    
    if not itemIndex then
        return false
    end
    
    -- Try to add to inventory
    local success, reason = InventorySystem.addItem(unitId, itemId)
    if not success then
        print(string.format("[Inventory] Failed to pickup %s: %s", itemId, reason or "unknown"))
        return false
    end
    
    -- Remove from ground
    table.remove(groundItems, itemIndex)
    
    print(string.format("[Inventory] %s picked up %s at (%d,%d)", 
        unitId, itemId, unitPos.q, unitPos.r))
    
    return true
end

---Find empty slot of specified type
---@param inv UnitInventory
---@param slotType string Slot type (weapon, belt, quick, backpack)
---@return InventorySlot|nil slot
function InventorySystem.findEmptySlot(inv, slotType)
    local searchSlots = {}
    
    if slotType == "weapon" then
        searchSlots = InventorySystem.CONFIG.WEAPON_SLOTS
    elseif slotType == "belt" then
        searchSlots = InventorySystem.CONFIG.BELT_SLOTS
    elseif slotType == "quick" then
        searchSlots = InventorySystem.CONFIG.QUICK_SLOTS
    elseif slotType == "backpack" then
        for i = 1, InventorySystem.CONFIG.BACKPACK_SIZE do
            table.insert(searchSlots, "backpack" .. i)
        end
    else
        -- Default to backpack
        for i = 1, InventorySystem.CONFIG.BACKPACK_SIZE do
            table.insert(searchSlots, "backpack" .. i)
        end
    end
    
    for _, slotId in ipairs(searchSlots) do
        local slot = inv.slots[slotId]
        if slot and not slot.itemId then
            return slot
        end
    end
    
    return nil
end

---Check if unit is over-encumbered
---@param unitId string Unit ID
---@return boolean overWeight, boolean overBulk, number weightPenalty, number bulkPenalty
function InventorySystem.checkEncumbrance(unitId)
    local inv = inventories[unitId]
    if not inv then return false, false, 0, 0 end
    
    local cfg = InventorySystem.CONFIG
    
    local overWeight = inv.totalWeight > inv.maxWeight
    local overBulk = inv.totalBulk > inv.maxBulk
    
    local weightExcess = math.max(0, inv.totalWeight - inv.maxWeight)
    local bulkExcess = math.max(0, inv.totalBulk - inv.maxBulk)
    
    local weightPenalty = math.floor(weightExcess / 10) * cfg.OVERWEIGHT_AP_PENALTY
    local bulkPenalty = 0 -- Bulk doesn't penalize, just prevents adding more
    
    return overWeight, overBulk, weightPenalty, bulkPenalty
end

---Get encumbrance penalties
---@param unitId string Unit ID
---@return table penalties {apPenalty, accuracyPenalty}
function InventorySystem.getEncumbrancePenalties(unitId)
    local overWeight, _, weightPenalty, _ = InventorySystem.checkEncumbrance(unitId)
    
    if not overWeight then
        return {apPenalty = 0, accuracyPenalty = 0}
    end
    
    local cfg = InventorySystem.CONFIG
    local inv = inventories[unitId]
    local weightExcess = inv.totalWeight - inv.maxWeight
    
    return {
        apPenalty = weightPenalty,
        accuracyPenalty = math.floor(weightExcess / 10) * cfg.OVERWEIGHT_ACCURACY_PENALTY,
    }
end

---Mock item database (replace with real item system)
---@param itemId string Item ID
---@return table|nil itemData {weight, bulk, slotType}
function InventorySystem.getItemData(itemId)
    local mockItems = {
        rifle = {weight = 5, bulk = 8, slotType = "weapon"},
        pistol = {weight = 2, bulk = 3, slotType = "weapon"},
        grenade = {weight = 0.5, bulk = 1, slotType = "belt"},
        medkit = {weight = 1, bulk = 2, slotType = "belt"},
        armor = {weight = 10, bulk = 12, slotType = "armor"},
        ammo = {weight = 0.5, bulk = 1, slotType = "backpack"},
    }
    
    return mockItems[itemId]
end

---Configure inventory system
---@param config table Configuration overrides
function InventorySystem.configure(config)
    for k, v in pairs(config) do
        if InventorySystem.CONFIG[k] ~= nil then
            InventorySystem.CONFIG[k] = v
            print(string.format("[Inventory] Config: %s = %s", k, tostring(v)))
        end
    end
end

---Reset entire system
function InventorySystem.reset()
    inventories = {}
    print("[Inventory] System reset")
end

return InventorySystem

























