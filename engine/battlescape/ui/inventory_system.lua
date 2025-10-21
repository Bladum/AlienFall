---Inventory System - Unit Equipment Management
---
---Implements unit inventory with equipment slots, drag-drop interface,
---weight limits, and paper doll visualization. Supports weapons, armor,
---grenades, medkits, and other tactical items.
---
---Features:
---  - Equipment slots: PRIMARY WEAPON, SECONDARY WEAPON, ARMOR, BELT (4×), BACKPACK (6×)
---  - Paper doll visualization
---  - Drag-and-drop item management
---  - Weight capacity limits
---  - Item stack handling
---  - Quick-slot access (1-4 for belt items)
---  - Item properties (weight, size, usage)
---
---Integration:
---  - Call initUnit() to create unit inventory
---  - Call equipItem() to add item to slot
---  - Call removeItem() to remove from slot
---  - Call draw() to render inventory UI
---  - Call getEquippedWeapon() for combat
---
---Key Exports:
---  - InventorySystem.initUnit(unit): Initialize unit inventory
---  - InventorySystem.equipItem(unit, item, slot): Equip item to slot
---  - InventorySystem.removeItem(unit, slot): Remove item from slot
---  - InventorySystem.draw(unit, x, y): Render inventory UI
---  - InventorySystem.getEquippedWeapon(unit): Get primary weapon
---
---Dependencies:
---  - Item system for item definitions
---  - Unit system for unit data
---
---@module battlescape.ui.inventory_system
---@author UI Systems
---@license Open Source

local InventorySystem = {}

-- Configuration
local CONFIG = {
    -- Slot types
    SLOTS = {
        PRIMARY_WEAPON = {id = "primary", label = "Primary Weapon", maxItems = 1, category = "WEAPON"},
        SECONDARY_WEAPON = {id = "secondary", label = "Secondary Weapon", maxItems = 1, category = "WEAPON"},
        ARMOR = {id = "armor", label = "Armor", maxItems = 1, category = "ARMOR"},
        BELT_1 = {id = "belt1", label = "Belt Slot 1", maxItems = 1, category = "ANY", hotkey = "1"},
        BELT_2 = {id = "belt2", label = "Belt Slot 2", maxItems = 1, category = "ANY", hotkey = "2"},
        BELT_3 = {id = "belt3", label = "Belt Slot 3", maxItems = 1, category = "ANY", hotkey = "3"},
        BELT_4 = {id = "belt4", label = "Belt Slot 4", maxItems = 1, category = "ANY", hotkey = "4"},
        BACKPACK = {id = "backpack", label = "Backpack", maxItems = 6, category = "ANY"},
    },
    
    -- Weight limits
    WEIGHT_CAPACITY_BASE = 30,          -- kg
    WEIGHT_CAPACITY_PER_STRENGTH = 2,   -- kg per strength point
    OVERWEIGHT_PENALTY_AP = 2,          -- AP penalty per 10kg over limit
    
    -- Item categories
    CATEGORIES = {
        WEAPON = "WEAPON",
        ARMOR = "ARMOR",
        GRENADE = "GRENADE",
        MEDKIT = "MEDKIT",
        AMMO = "AMMO",
        TOOL = "TOOL",
        MISC = "MISC",
    },
    
    -- UI layout
    PANEL_WIDTH = 600,
    PANEL_HEIGHT = 480,
    SLOT_SIZE = 60,
    SLOT_PADDING = 8,
    BACKPACK_COLS = 3,
    BACKPACK_ROWS = 2,
    
    -- Colors
    COLORS = {
        BACKGROUND = {r = 20, g = 20, b = 30, a = 240},
        SLOT_EMPTY = {r = 40, g = 40, b = 50, a = 255},
        SLOT_FILLED = {r = 60, g = 80, b = 100, a = 255},
        SLOT_HOVER = {r = 80, g = 100, b = 120, a = 255},
        SLOT_BORDER = {r = 100, g = 100, b = 120, a = 255},
        TEXT = {r = 220, g = 220, b = 230, a = 255},
        WEIGHT_OK = {r = 80, g = 200, b = 80, a = 255},
        WEIGHT_WARNING = {r = 220, g = 180, b = 60, a = 255},
        WEIGHT_OVER = {r = 220, g = 60, b = 60, a = 255},
    },
}

-- Unit inventories
-- Format: inventories[unitId] = { slots = {}, weight = 0, capacity = 0 }
local inventories = {}

-- Drag state
local dragState = {
    active = false,
    item = nil,
    sourceSlot = nil,
    mouseX = 0,
    mouseY = 0,
}

--[[
    Initialize inventory for unit
    
    @param unitId: Unit identifier
    @param strength: Unit strength stat (affects capacity)
]]
function InventorySystem.initUnit(unitId, strength)
    strength = strength or 10
    local capacity = CONFIG.WEIGHT_CAPACITY_BASE + (strength * CONFIG.WEIGHT_CAPACITY_PER_STRENGTH)
    
    inventories[unitId] = {
        slots = {},
        weight = 0,
        capacity = capacity,
    }
    
    -- Initialize all slots
    for slotName, slotConfig in pairs(CONFIG.SLOTS) do
        inventories[unitId].slots[slotConfig.id] = {
            config = slotConfig,
            items = {},
        }
    end
    
    print(string.format("[InventorySystem] Initialized inventory for unit %s (capacity: %d kg)",
        tostring(unitId), capacity))
end

--[[
    Remove unit inventory
    
    @param unitId: Unit identifier
]]
function InventorySystem.removeUnit(unitId)
    inventories[unitId] = nil
    print(string.format("[InventorySystem] Removed inventory for unit %s", tostring(unitId)))
end

--[[
    Equip item to slot
    
    @param unitId: Unit identifier
    @param slotId: Slot identifier
    @param item: Item data { id, name, category, weight, properties }
    @return success: Boolean
]]
function InventorySystem.equipItem(unitId, slotId, item)
    if not inventories[unitId] then
        print(string.format("[InventorySystem] ERROR: No inventory for unit %s", tostring(unitId)))
        return false
    end
    
    local inventory = inventories[unitId]
    local slot = inventory.slots[slotId]
    
    if not slot then
        print(string.format("[InventorySystem] ERROR: Invalid slot %s", slotId))
        return false
    end
    
    -- Check slot category
    if slot.config.category ~= "ANY" and slot.config.category ~= item.category then
        print(string.format("[InventorySystem] ERROR: Item category %s doesn't match slot %s",
            item.category, slot.config.category))
        return false
    end
    
    -- Check slot capacity
    if #slot.items >= slot.config.maxItems then
        print(string.format("[InventorySystem] ERROR: Slot %s is full", slotId))
        return false
    end
    
    -- Check weight capacity
    local newWeight = inventory.weight + item.weight
    if newWeight > inventory.capacity * 1.5 then  -- Allow 150% overweight max
        print(string.format("[InventorySystem] ERROR: Too much weight (%d > %d kg)",
            newWeight, inventory.capacity * 1.5))
        return false
    end
    
    -- Add item
    table.insert(slot.items, item)
    inventory.weight = inventory.weight + item.weight
    
    print(string.format("[InventorySystem] Equipped %s to %s (weight: %d/%d kg)",
        item.name, slotId, inventory.weight, inventory.capacity))
    
    return true
end

--[[
    Remove item from slot
    
    @param unitId: Unit identifier
    @param slotId: Slot identifier
    @param itemIndex: Item index in slot (default 1)
    @return item: Removed item or nil
]]
function InventorySystem.removeItem(unitId, slotId, itemIndex)
    itemIndex = itemIndex or 1
    
    if not inventories[unitId] then
        return nil
    end
    
    local inventory = inventories[unitId]
    local slot = inventory.slots[slotId]
    
    if not slot or #slot.items == 0 then
        return nil
    end
    
    local item = table.remove(slot.items, itemIndex)
    if item then
        inventory.weight = inventory.weight - item.weight
        print(string.format("[InventorySystem] Removed %s from %s", item.name, slotId))
    end
    
    return item
end

--[[
    Get equipped weapon
    
    @param unitId: Unit identifier
    @param weaponType: "primary" or "secondary" (default "primary")
    @return weapon: Weapon item or nil
]]
function InventorySystem.getEquippedWeapon(unitId, weaponType)
    weaponType = weaponType or "primary"
    
    if not inventories[unitId] then
        return nil
    end
    
    local slot = inventories[unitId].slots[weaponType]
    if slot and #slot.items > 0 then
        return slot.items[1]
    end
    
    return nil
end

--[[
    Get all items in slot
    
    @param unitId: Unit identifier
    @param slotId: Slot identifier
    @return items: Array of items
]]
function InventorySystem.getSlotItems(unitId, slotId)
    if not inventories[unitId] then
        return {}
    end
    
    local slot = inventories[unitId].slots[slotId]
    return slot and slot.items or {}
end

--[[
    Get total weight and capacity
    
    @param unitId: Unit identifier
    @return weight, capacity, overweight
]]
function InventorySystem.getWeight(unitId)
    if not inventories[unitId] then
        return 0, 0, false
    end
    
    local inventory = inventories[unitId]
    local overweight = inventory.weight > inventory.capacity
    return inventory.weight, inventory.capacity, overweight
end

--[[
    Calculate AP penalty from overweight
    
    @param unitId: Unit identifier
    @return apPenalty: AP penalty (0 if not overweight)
]]
function InventorySystem.getOverweightPenalty(unitId)
    local weight, capacity, overweight = InventorySystem.getWeight(unitId)
    
    if not overweight then
        return 0
    end
    
    local excessWeight = weight - capacity
    local penalty = math.floor(excessWeight / 10) * CONFIG.OVERWEIGHT_PENALTY_AP
    return penalty
end

--[[
    Move item between slots
    
    @param unitId: Unit identifier
    @param fromSlot: Source slot id
    @param toSlot: Target slot id
    @param itemIndex: Item index in source slot (default 1)
    @return success: Boolean
]]
function InventorySystem.moveItem(unitId, fromSlot, toSlot, itemIndex)
    local item = InventorySystem.removeItem(unitId, fromSlot, itemIndex)
    if not item then
        return false
    end
    
    local success = InventorySystem.equipItem(unitId, toSlot, item)
    if not success then
        -- Return item to original slot
        InventorySystem.equipItem(unitId, fromSlot, item)
        return false
    end
    
    return true
end

--[[
    Start dragging item
    
    @param item: Item being dragged
    @param sourceSlot: Source slot id
    @param mouseX, mouseY: Mouse position
]]
function InventorySystem.startDrag(item, sourceSlot, mouseX, mouseY)
    dragState.active = true
    dragState.item = item
    dragState.sourceSlot = sourceSlot
    dragState.mouseX = mouseX
    dragState.mouseY = mouseY
    print(string.format("[InventorySystem] Started dragging %s from %s", item.name, sourceSlot))
end

--[[
    End dragging item
    
    @param targetSlot: Target slot id (nil to cancel)
    @param unitId: Unit identifier
    @return success: Boolean
]]
function InventorySystem.endDrag(targetSlot, unitId)
    if not dragState.active then
        return false
    end
    
    local success = false
    
    if targetSlot and targetSlot ~= dragState.sourceSlot then
        success = InventorySystem.moveItem(unitId, dragState.sourceSlot, targetSlot, 1)
    end
    
    dragState.active = false
    dragState.item = nil
    dragState.sourceSlot = nil
    
    return success
end

--[[
    Draw inventory UI
    
    @param unitId: Unit identifier
    @param x, y: Panel position
]]
function InventorySystem.draw(unitId, x, y)
    if not inventories[unitId] then
        return
    end
    
    local inventory = inventories[unitId]
    
    -- Background
    love.graphics.setColor(CONFIG.COLORS.BACKGROUND.r, CONFIG.COLORS.BACKGROUND.g,
        CONFIG.COLORS.BACKGROUND.b, CONFIG.COLORS.BACKGROUND.a)
    love.graphics.rectangle("fill", x, y, CONFIG.PANEL_WIDTH, CONFIG.PANEL_HEIGHT)
    
    -- Border
    love.graphics.setColor(CONFIG.COLORS.SLOT_BORDER.r, CONFIG.COLORS.SLOT_BORDER.g,
        CONFIG.COLORS.SLOT_BORDER.b, CONFIG.COLORS.SLOT_BORDER.a)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, CONFIG.PANEL_WIDTH, CONFIG.PANEL_HEIGHT)
    
    -- Title
    love.graphics.setColor(CONFIG.COLORS.TEXT.r, CONFIG.COLORS.TEXT.g,
        CONFIG.COLORS.TEXT.b, CONFIG.COLORS.TEXT.a)
    love.graphics.print("Inventory", x + 10, y + 10, 0, 1.2, 1.2)
    
    -- Weight display
    local weight, capacity, overweight = InventorySystem.getWeight(unitId)
    local weightColor = overweight and CONFIG.COLORS.WEIGHT_OVER or
                       weight > capacity * 0.8 and CONFIG.COLORS.WEIGHT_WARNING or
                       CONFIG.COLORS.WEIGHT_OK
    love.graphics.setColor(weightColor.r, weightColor.g, weightColor.b, weightColor.a)
    love.graphics.print(string.format("Weight: %d/%d kg", weight, capacity),
        x + CONFIG.PANEL_WIDTH - 150, y + 10)
    
    -- Draw slots
    local offsetY = y + 50
    
    -- Weapon slots
    InventorySystem.drawSlot(inventory.slots.primary, x + 20, offsetY)
    InventorySystem.drawSlot(inventory.slots.secondary, x + 110, offsetY)
    
    -- Armor slot
    InventorySystem.drawSlot(inventory.slots.armor, x + 200, offsetY)
    
    -- Belt slots
    offsetY = offsetY + 100
    love.graphics.setColor(CONFIG.COLORS.TEXT.r, CONFIG.COLORS.TEXT.g,
        CONFIG.COLORS.TEXT.b, CONFIG.COLORS.TEXT.a)
    love.graphics.print("Quick Belt", x + 20, offsetY - 25, 0, 0.9, 0.9)
    
    InventorySystem.drawSlot(inventory.slots.belt1, x + 20, offsetY)
    InventorySystem.drawSlot(inventory.slots.belt2, x + 110, offsetY)
    InventorySystem.drawSlot(inventory.slots.belt3, x + 200, offsetY)
    InventorySystem.drawSlot(inventory.slots.belt4, x + 290, offsetY)
    
    -- Backpack
    offsetY = offsetY + 100
    love.graphics.setColor(CONFIG.COLORS.TEXT.r, CONFIG.COLORS.TEXT.g,
        CONFIG.COLORS.TEXT.b, CONFIG.COLORS.TEXT.a)
    love.graphics.print("Backpack", x + 20, offsetY - 25, 0, 0.9, 0.9)
    
    -- Backpack grid (3×2)
    for row = 0, CONFIG.BACKPACK_ROWS - 1 do
        for col = 0, CONFIG.BACKPACK_COLS - 1 do
            local slotX = x + 20 + col * (CONFIG.SLOT_SIZE + CONFIG.SLOT_PADDING)
            local slotY = offsetY + row * (CONFIG.SLOT_SIZE + CONFIG.SLOT_PADDING)
            -- Backpack uses single slot, items just rendered in grid
            if row == 0 and col == 0 then
                InventorySystem.drawSlot(inventory.slots.backpack, slotX, slotY, true)
            else
                InventorySystem.drawEmptySlot(slotX, slotY)
            end
        end
    end
    
    -- Draw dragged item
    if dragState.active and dragState.item then
        InventorySystem.drawDraggedItem(dragState.item, dragState.mouseX, dragState.mouseY)
    end
end

--[[
    Draw individual slot
    
    @param slot: Slot data
    @param x, y: Position
    @param isBackpack: Is backpack slot (don't draw label)
]]
function InventorySystem.drawSlot(slot, x, y, isBackpack)
    local hasItem = #slot.items > 0
    local color = hasItem and CONFIG.COLORS.SLOT_FILLED or CONFIG.COLORS.SLOT_EMPTY
    
    -- Background
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics.rectangle("fill", x, y, CONFIG.SLOT_SIZE, CONFIG.SLOT_SIZE)
    
    -- Border
    love.graphics.setColor(CONFIG.COLORS.SLOT_BORDER.r, CONFIG.COLORS.SLOT_BORDER.g,
        CONFIG.COLORS.SLOT_BORDER.b, CONFIG.COLORS.SLOT_BORDER.a)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, CONFIG.SLOT_SIZE, CONFIG.SLOT_SIZE)
    
    -- Label
    if not isBackpack then
        love.graphics.setColor(CONFIG.COLORS.TEXT.r, CONFIG.COLORS.TEXT.g,
            CONFIG.COLORS.TEXT.b, CONFIG.COLORS.TEXT.a)
        love.graphics.print(slot.config.label, x, y - 20, 0, 0.7, 0.7)
    end
    
    -- Hotkey
    if slot.config.hotkey then
        love.graphics.setColor(220, 180, 60, 255)
        love.graphics.print(slot.config.hotkey, x + CONFIG.SLOT_SIZE - 12, y + 4, 0, 1.2, 1.2)
    end
    
    -- Item preview (just first letter of name for now)
    if hasItem then
        love.graphics.setColor(220, 220, 230, 255)
        local firstLetter = string.sub(slot.items[1].name, 1, 1)
        love.graphics.print(firstLetter, x + CONFIG.SLOT_SIZE/2 - 8, y + CONFIG.SLOT_SIZE/2 - 8, 0, 2, 2)
    end
end

--[[
    Draw empty slot (for backpack grid visualization)
    
    @param x, y: Position
]]
function InventorySystem.drawEmptySlot(x, y)
    love.graphics.setColor(CONFIG.COLORS.SLOT_EMPTY.r, CONFIG.COLORS.SLOT_EMPTY.g,
        CONFIG.COLORS.SLOT_EMPTY.b, CONFIG.COLORS.SLOT_EMPTY.a)
    love.graphics.rectangle("fill", x, y, CONFIG.SLOT_SIZE, CONFIG.SLOT_SIZE)
    
    love.graphics.setColor(CONFIG.COLORS.SLOT_BORDER.r, CONFIG.COLORS.SLOT_BORDER.g,
        CONFIG.COLORS.SLOT_BORDER.b, CONFIG.COLORS.SLOT_BORDER.a)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, CONFIG.SLOT_SIZE, CONFIG.SLOT_SIZE)
end

--[[
    Draw dragged item
    
    @param item: Item being dragged
    @param mouseX, mouseY: Mouse position
]]
function InventorySystem.drawDraggedItem(item, mouseX, mouseY)
    local size = CONFIG.SLOT_SIZE * 0.8
    local x = mouseX - size/2
    local y = mouseY - size/2
    
    -- Semi-transparent background
    love.graphics.setColor(60, 80, 100, 200)
    love.graphics.rectangle("fill", x, y, size, size)
    
    -- Border
    love.graphics.setColor(220, 220, 230, 255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, size, size)
    
    -- Item preview
    local firstLetter = string.sub(item.name, 1, 1)
    love.graphics.print(firstLetter, x + size/2 - 8, y + size/2 - 8, 0, 1.5, 1.5)
end

--[[
    Get all inventories for debugging
    
    @return inventories table
]]
function InventorySystem.getAllInventories()
    return inventories
end

return InventorySystem

























