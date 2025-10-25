---InventorySlot Widget - Drag-and-Drop Item Slot
---
---A single inventory slot that displays an item with icon, quantity, and drag-drop
---support. Used in inventory grids, equipment screens, and storage interfaces.
---Grid-aligned for consistent positioning.
---
---Features:
---  - Item icon display
---  - Stack count label (for stackable items)
---  - Drag-and-drop support
---  - Rarity/quality coloring
---  - Hover tooltip (item details)
---  - Grid-aligned positioning (24×24 pixels)
---  - Empty slot placeholder
---
---Slot States:
---  - Empty: No item, shows placeholder
---  - Filled: Contains item, shows icon
---  - Dragging: Source slot highlights
---  - Drop target: Destination slot highlights
---  - Hover: Tooltip appears
---
---Item Structure:
---  - Icon: Image asset
---  - Name: Item name
---  - Quantity: Stack size
---  - Category: Item type
---  - Rarity: Quality level (affects border color)
---
---Key Exports:
---  - InventorySlot.new(x, y, width, height): Creates inventory slot
---  - setItem(item): Assigns item to slot
---  - getItem(): Returns current item
---  - clearItem(): Removes item
---  - draw(): Renders slot and item
---  - mousepressed(x, y, button): Start drag
---  - mousereleased(x, y, button): Complete drag/drop
---  - mousemoved(x, y): Drag update
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---  - widgets.display.tooltip: Hover tooltip
---
---@module widgets.advanced.inventoryslot
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local InventorySlot = require("gui.widgets.advanced.inventoryslot")
---  local slot = InventorySlot.new(0, 0, 48, 48)
---  slot:setItem({
---    icon = rifleIcon,
---    name = "Assault Rifle",
---    quantity = 1,
---    category = "weapon",
---    rarity = "rare"
---  })
---  slot:draw()
---
---@see widgets.advanced.minimap For minimap widget

--[[
    InventorySlot Widget
    
    Displays an item slot in an inventory grid.
    Features:
    - Item icon
    - Stack count
    - Drag and drop support
    - Rarity/quality coloring
    - Tooltip on hover
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local InventorySlot = setmetatable({}, {__index = BaseWidget})
InventorySlot.__index = InventorySlot

function InventorySlot.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, InventorySlot)
    
    self.item = nil  -- {name, icon, count, rarity}
    self.slotIndex = 0
    self.dragging = false
    self.empty = true
    self.locked = false
    
    return self
end

function InventorySlot:draw()
    if not self.visible then
        return
    end
    
    -- Draw slot background
    if self.locked then
        Theme.setColor(self.disabledColor)
    elseif self.empty then
        love.graphics.setColor(0.2, 0.2, 0.2)
    else
        -- Color by rarity
        if self.item and self.item.rarity then
            local rarityColors = {
                common = {0.7, 0.7, 0.7},
                uncommon = {0.3, 1, 0.3},
                rare = {0.3, 0.5, 1},
                epic = {0.8, 0.3, 1},
                legendary = {1, 0.7, 0.2}
            }
            local color = rarityColors[self.item.rarity] or rarityColors.common
            love.graphics.setColor(color[1] * 0.3, color[2] * 0.3, color[3] * 0.3)
        else
            Theme.setColor(self.backgroundColor)
        end
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw item if present
    if not self.empty and self.item then
        -- Draw icon
        if self.item.icon then
            love.graphics.setColor(1, 1, 1, 1)
            local iconScale = math.min(
                (self.width - 8) / self.item.icon:getWidth(),
                (self.height - 8) / self.item.icon:getHeight()
            )
            local iconX = self.x + (self.width - self.item.icon:getWidth() * iconScale) / 2
            local iconY = self.y + (self.height - self.item.icon:getHeight() * iconScale) / 2
            love.graphics.draw(self.item.icon, iconX, iconY, 0, iconScale, iconScale)
        end
        
        -- Draw stack count
        if self.item.count and self.item.count > 1 then
            Theme.setFont("small")
            Theme.setColor(self.textColor)
            local countText = tostring(self.item.count)
            local font = Theme.getFont("small")
            local textX = self.x + self.width - font:getWidth(countText) - 4
            local textY = self.y + self.height - font:getHeight() - 4
            love.graphics.print(countText, textX, textY)
        end
    end
    
    -- Draw border (highlight on hover)
    if self.hovered then
        Theme.setColor(self.hoverColor)
        love.graphics.setLineWidth(2)
    else
        Theme.setColor(self.borderColor)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function InventorySlot:mousepressed(x, y, button)
    if not self.visible or not self.enabled or self.locked then
        return false
    end
    
    if self:containsPoint(x, y) and button == 1 then
        if not self.empty then
            self.dragging = true
        end
        
        if self.onClick then
            self.onClick(self)
        end
        
        return true
    end
    
    return false
end

function InventorySlot:mousereleased(x, y, button)
    if button == 1 then
        self.dragging = false
    end
end

function InventorySlot:setItem(item)
    self.item = item
    self.empty = (item == nil)
end

function InventorySlot:getItem()
    return self.item
end

function InventorySlot:isEmpty()
    return self.empty
end

function InventorySlot:setLocked(locked)
    self.locked = locked
end

return InventorySlot



























