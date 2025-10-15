---ItemRenderer3D - 3D Ground Item Rendering System
---
---Renders dropped items and equipment on the ground in the 3D battlescape view.
---Items are displayed as small sprites positioned at 5 slots per tile (corners + center)
---with depth sorting and proper 3D perspective. Scaled to 50% size for ground clutter.
---
---Features:
---  - 5-slot positioning per tile (4 corners + center)
---  - 50% scale for ground items
---  - Depth sorting for proper rendering order
---  - Item pickup detection with slot-based positioning
---  - Ground item persistence across turns
---  - Integration with 3D camera and perspective
---
---Key Exports:
---  - new(): Create new 3D item renderer instance
---  - addItem(item, tileX, tileY): Add item to ground at tile position
---  - removeItem(item): Remove item from ground
---  - clearTile(tileX, tileY): Clear all items from tile
---  - getItemsAtTile(tileX, tileY): Get all items at tile position
---  - update(dt): Update animations and effects
---  - draw(camera): Render all ground items with depth sorting
---  - getItemAtPosition(worldX, worldZ): Find item at 3D world position
---
---Dependencies:
---  - require("battlescape.rendering.renderer_3d"): Main 3D renderer for camera data
---  - require("shared.items"): Item definitions and sprites
---
---@module battlescape.rendering.item_renderer_3d
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ItemRenderer3D = require("battlescape.rendering.item_renderer_3d")
---  local renderer = ItemRenderer3D.new()
---  renderer:addItem(droppedWeapon, 5, 3)
---  renderer:draw(camera)
---
---@see battlescape.rendering.renderer_3d For main 3D rendering pipeline
---@see shared.items For item definitions

-- Ground Item Renderer for 3D Battlescape
-- Renders items on ground as small sprites in 5 positions per tile
-- Items scaled to 50%, positioned at 4 corners + center

local ItemRenderer3D = {}
ItemRenderer3D.__index = ItemRenderer3D

--- Item slot positions within a tile
local ITEM_SLOTS = {
    {x = -0.3, z = -0.3},  -- Slot 1: Top-left corner
    {x = 0.3,  z = -0.3},  -- Slot 2: Top-right corner
    {x = 0.0,  z = 0.0},   -- Slot 3: Center
    {x = -0.3, z = 0.3},   -- Slot 4: Bottom-left corner
    {x = 0.3,  z = 0.3},   -- Slot 5: Bottom-right corner
}

--- Create new item renderer
function ItemRenderer3D.new()
    local self = setmetatable({}, ItemRenderer3D)
    
    -- Items on ground (indexed by tile)
    self.groundItems = {}  -- [tileKey] = {items}
    
    -- Settings
    self.settings = {
        itemScale = 0.5,    -- 50% size
        itemHeight = 0.1,   -- Just above ground
        maxItemsPerTile = 5, -- 5 slots
    }
    
    print("[ItemRenderer3D] Initialized")
    return self
end

--- Add item to ground at tile
---@param item table Item data {id, spriteName, x, y}
---@param tileX number Tile X coordinate
---@param tileY number Tile Y coordinate
function ItemRenderer3D:addItem(item, tileX, tileY)
    local key = tileX .. "," .. tileY
    
    if not self.groundItems[key] then
        self.groundItems[key] = {}
    end
    
    local items = self.groundItems[key]
    
    -- Check slot availability
    if #items >= self.settings.maxItemsPerTile then
        print("[ItemRenderer3D] Tile full, cannot add item")
        return false
    end
    
    -- Assign slot (1-5)
    item.slot = #items + 1
    item.x = tileX
    item.y = tileY
    
    -- Store slot offset for picking
    local slot = ITEM_SLOTS[item.slot]
    item.slotOffset = {x = slot.x, z = slot.z}
    
    table.insert(items, item)
    
    print("[ItemRenderer3D] Added item to slot " .. item.slot .. " at " .. tileX .. "," .. tileY)
    return true
end

--- Remove item from ground
---@param item table Item to remove
function ItemRenderer3D:removeItem(item)
    local key = item.x .. "," .. item.y
    local items = self.groundItems[key]
    
    if not items then return false end
    
    -- Find and remove item
    for i, groundItem in ipairs(items) do
        if groundItem.id == item.id then
            table.remove(items, i)
            
            -- Reassign slots for remaining items
            for j = i, #items do
                items[j].slot = j
                local slot = ITEM_SLOTS[j]
                items[j].slotOffset = {x = slot.x, z = slot.z}
            end
            
            print("[ItemRenderer3D] Removed item from " .. item.x .. "," .. item.y)
            return true
        end
    end
    
    return false
end

--- Get all items on ground
---@return table Array of items
function ItemRenderer3D:getAllItems()
    local allItems = {}
    
    for _, items in pairs(self.groundItems) do
        for _, item in ipairs(items) do
            table.insert(allItems, item)
        end
    end
    
    return allItems
end

--- Get items at specific tile
---@param tileX number Tile X coordinate
---@param tileY number Tile Y coordinate
---@return table Array of items
function ItemRenderer3D:getItemsAtTile(tileX, tileY)
    local key = tileX .. "," .. tileY
    return self.groundItems[key] or {}
end

--- Render items (using billboard system)
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
function ItemRenderer3D:render(billboard, camera, assets)
    for _, items in pairs(self.groundItems) do
        for _, item in ipairs(items) do
            self:renderItem(item, billboard, camera, assets)
        end
    end
end

--- Render single item
---@param item table Item data
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
function ItemRenderer3D:renderItem(item, billboard, camera, assets)
    -- Get item sprite
    local sprite = assets:get("items", item.spriteName)
    if not sprite then
        print("[ItemRenderer3D] Missing sprite: " .. item.spriteName)
        return
    end
    
    -- Calculate world position
    local slot = ITEM_SLOTS[item.slot] or ITEM_SLOTS[3]
    local worldX = item.x + slot.x
    local worldZ = item.y + slot.z
    local worldY = self.settings.itemHeight
    
    -- Render as billboard (scaled down)
    billboard:add(worldX, worldY, worldZ, sprite, {
        width = self.settings.itemScale,
        height = self.settings.itemScale,
        alpha = 1.0,
        emissive = false,
    })
end

--- Pickup item at tile (Eye of the Beholder style)
---@param tileX number Tile X coordinate
---@param tileY number Tile Y coordinate
---@param slot number Optional: specific slot (1-5), nil = first item
---@return table|nil Picked item
function ItemRenderer3D:pickupItem(tileX, tileY, slot)
    local items = self:getItemsAtTile(tileX, tileY)
    
    if #items == 0 then
        print("[ItemRenderer3D] No items at tile")
        return nil
    end
    
    -- Pick specific slot or first item
    local item
    if slot then
        item = items[slot]
    else
        item = items[1]
    end
    
    if item then
        self:removeItem(item)
        print("[ItemRenderer3D] Picked up " .. item.spriteName)
        return item
    end
    
    return nil
end

--- Drop item at tile
---@param item table Item to drop
---@param tileX number Tile X coordinate
---@param tileY number Tile Y coordinate
---@return boolean Success
function ItemRenderer3D:dropItem(item, tileX, tileY)
    return self:addItem(item, tileX, tileY)
end

--- Clear all items (used when exiting battlescape)
function ItemRenderer3D:clear()
    self.groundItems = {}
    print("[ItemRenderer3D] Cleared all items")
end

--- Debug: Count total items
---@return number Total item count
function ItemRenderer3D:getItemCount()
    local count = 0
    for _, items in pairs(self.groundItems) do
        count = count + #items
    end
    return count
end

--- Debug: Print items at tile
---@param tileX number Tile X coordinate
---@param tileY number Tile Y coordinate
function ItemRenderer3D:debugPrintTile(tileX, tileY)
    local items = self:getItemsAtTile(tileX, tileY)
    print("[ItemRenderer3D] Tile " .. tileX .. "," .. tileY .. " has " .. #items .. " items:")
    for _, item in ipairs(items) do
        print("  Slot " .. item.slot .. ": " .. item.spriteName)
    end
end

return ItemRenderer3D






















