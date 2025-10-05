--[[
widgets/inventorygrid.lua
InventoryGrid widget for advanced inventory management


Advanced grid-based inventory system with drag-and-drop functionality for equipment and resource management.
Supports stacking, visual feedback, and complex item interactions.

PURPOSE:
- Provide advanced grid-based item storage and management
- Enable drag-and-drop functionality for item movement and organization
- Support item stacking and complex inventory interactions
- Facilitate equipment management and resource allocation

KEY FEATURES:
- Grid-based layout with configurable dimensions and cell sizes
- Drag-and-drop functionality for intuitive item movement
- Item stacking support with quantity management
- Visual feedback for drag operations and placement validation
- Equipment slot integration with validation rules
- Resource management with capacity limits and overflow handling
- Item categorization and filtering capabilities
- Save/load functionality for inventory persistence
- Integration with item database and properties
- Customizable visual themes and styling

@see widgets.common.core.Base
@see widgets.complex.dragdrop
@see widgets.complex.inventory
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local DragDrop = require("widgets.complex.dragdrop")

local InventoryGrid = {}
InventoryGrid.__index = InventoryGrid
setmetatable(InventoryGrid, { __index = core.Base })

function InventoryGrid:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Grid configuration
    obj.gridWidth = (options and options.gridWidth) or 8
    obj.gridHeight = (options and options.gridHeight) or 6
    obj.cellSize = (options and options.cellSize) or 48
    obj.cellSpacing = (options and options.cellSpacing) or 2

    -- Calculate actual dimensions based on grid
    local actualWidth = obj.gridWidth * obj.cellSize + (obj.gridWidth - 1) * obj.cellSpacing
    local actualHeight = obj.gridHeight * obj.cellSize + (obj.gridHeight - 1) * obj.cellSpacing
    obj.w = math.max(w, actualWidth)
    obj.h = math.max(h, actualHeight)

    -- Visual properties
    obj.backgroundColor = (options and options.backgroundColor) or core.theme.backgroundLight
    obj.borderColor = (options and options.borderColor) or core.theme.border
    obj.cellColor = (options and options.cellColor) or core.theme.backgroundDark
    obj.cellBorderColor = (options and options.cellBorderColor) or core.theme.border
    obj.highlightColor = (options and options.highlightColor) or core.theme.accent
    obj.validDropColor = (options and options.validDropColor) or { 0.2, 0.8, 0.2, 0.3 }
    obj.invalidDropColor = (options and options.invalidDropColor) or { 0.8, 0.2, 0.2, 0.3 }

    -- Grid state
    obj.items = {} -- [x][y] = item
    obj.hoveredSlot = nil
    obj.selectedSlot = nil
    obj.dragPreview = nil

    -- Item restrictions
    obj.allowStacking = (options and options.allowStacking) ~= false
    obj.maxStackSize = (options and options.maxStackSize) or 99
    obj.itemFilter = options and options.itemFilter -- function(item) -> boolean
    obj.slotTypes = options and options.slotTypes   -- [x][y] = type (nil = any)

    -- Multi-slot items support
    obj.allowMultiSlot = (options and options.allowMultiSlot) ~= false

    -- Visual effects
    obj.showGridLines = (options and options.showGridLines) ~= false
    obj.showTooltips = (options and options.showTooltips) ~= false
    obj.animateItems = (options and options.animateItems) ~= false
    obj.glowEffect = (options and options.glowEffect) ~= false

    -- Quality colors for item backgrounds
    obj.qualityColors = {
        common = { 0.8, 0.8, 0.8 },
        uncommon = { 0.2, 0.8, 0.2 },
        rare = { 0.2, 0.4, 1 },
        epic = { 0.8, 0.2, 1 },
        legendary = { 1, 0.5, 0 }
    }

    -- Callbacks
    obj.onItemClick = options and options.onItemClick
    obj.onItemDoubleClick = options and options.onItemDoubleClick
    obj.onItemRightClick = options and options.onItemRightClick
    obj.onItemDrop = options and options.onItemDrop
    obj.onItemHover = options and options.onItemHover
    obj.onSlotClick = options and options.onSlotClick

    -- Initialize grid
    for x = 1, obj.gridWidth do
        obj.items[x] = {}
        for y = 1, obj.gridHeight do
            obj.items[x][y] = nil
        end
    end

    -- Tooltip
    obj.tooltipText = ""
    obj.tooltipX = 0
    obj.tooltipY = 0
    obj.showTooltip = false

    -- Animation timers
    obj.animationTime = 0

    setmetatable(obj, self)
    return obj
end

function InventoryGrid:addItem(item, x, y)
    if not self:isValidPosition(x, y) then return false end

    -- Check if item fits
    if not self:canPlaceItem(item, x, y) then return false end

    -- Handle stacking
    if self.allowStacking then
        local existingItem = self.items[x][y]
        if existingItem and existingItem.id == item.id and
            (existingItem.quantity or 1) + (item.quantity or 1) <= self.maxStackSize then
            existingItem.quantity = (existingItem.quantity or 1) + (item.quantity or 1)
            return true
        end
    end

    -- Place item
    self:_placeItem(item, x, y)

    -- Trigger callback
    if self.onItemDrop then
        self.onItemDrop(item, x, y, self)
    end

    return true
end

function InventoryGrid:removeItem(x, y, quantity)
    if not self:isValidPosition(x, y) then return nil end

    local item = self.items[x][y]
    if not item then return nil end

    if quantity and quantity > 0 and item.quantity and item.quantity > quantity then
        -- Partial removal
        item.quantity = item.quantity - quantity
        local removedItem = core.deepCopy(item)
        removedItem.quantity = quantity
        return removedItem
    else
        -- Full removal
        self:_removeItem(x, y)
        return item
    end
end

function InventoryGrid:moveItem(fromX, fromY, toX, toY)
    if not self:isValidPosition(fromX, fromY) or not self:isValidPosition(toX, toY) then
        return false
    end

    local item = self.items[fromX][fromY]
    if not item then return false end

    if not self:canPlaceItem(item, toX, toY, fromX, fromY) then return false end

    -- Remove from old position
    self:_removeItem(fromX, fromY)

    -- Place at new position
    self:_placeItem(item, toX, toY)

    return true
end

function InventoryGrid:canPlaceItem(item, x, y, ignoreX, ignoreY)
    if not self:isValidPosition(x, y) then return false end

    -- Check item filter
    if self.itemFilter and not self.itemFilter(item) then return false end

    -- Check slot type
    if self.slotTypes and self.slotTypes[x] and self.slotTypes[x][y] then
        if item.type ~= self.slotTypes[x][y] then return false end
    end

    -- Get item dimensions
    local itemWidth = item.width or 1
    local itemHeight = item.height or 1

    -- Check if item fits in grid
    if x + itemWidth - 1 > self.gridWidth or y + itemHeight - 1 > self.gridHeight then
        return false
    end

    -- Check all slots the item would occupy
    for ox = 0, itemWidth - 1 do
        for oy = 0, itemHeight - 1 do
            local checkX, checkY = x + ox, y + oy

            -- Skip if this is the position we're moving from
            if not (ignoreX and ignoreY and checkX == ignoreX and checkY == ignoreY) then
                local occupant = self.items[checkX][checkY]
                if occupant then
                    -- Check for stacking
                    if self.allowStacking and occupant.id == item.id and
                        (occupant.quantity or 1) + (item.quantity or 1) <= self.maxStackSize then
                        -- Stacking is allowed, but only for 1x1 items
                        if itemWidth == 1 and itemHeight == 1 then
                            return true
                        end
                    end
                    return false
                end
            end
        end
    end

    return true
end

function InventoryGrid:_placeItem(item, x, y)
    local itemWidth = item.width or 1
    local itemHeight = item.height or 1

    -- Mark all occupied slots
    for ox = 0, itemWidth - 1 do
        for oy = 0, itemHeight - 1 do
            local slotX, slotY = x + ox, y + oy
            self.items[slotX][slotY] = (ox == 0 and oy == 0) and item or { reference = item, refX = x, refY = y }
        end
    end

    -- Set position for rendering
    item.gridX = x
    item.gridY = y

    -- Animation
    if self.animateItems then
        item.animScale = 0.5
        Animation:animate(item, 0.2, { animScale = 1 }, "outBack")
    end
end

function InventoryGrid:_removeItem(x, y)
    local item = self.items[x][y]
    if not item then return end

    -- If it's a reference, get the actual item
    if item.reference then
        item = item.reference
        x, y = item.refX, item.refY
    end

    local itemWidth = item.width or 1
    local itemHeight = item.height or 1

    -- Clear all occupied slots
    for ox = 0, itemWidth - 1 do
        for oy = 0, itemHeight - 1 do
            local slotX, slotY = x + ox, y + oy
            if self:isValidPosition(slotX, slotY) then
                self.items[slotX][slotY] = nil
            end
        end
    end
end

function InventoryGrid:isValidPosition(x, y)
    return x >= 1 and x <= self.gridWidth and y >= 1 and y <= self.gridHeight
end

function InventoryGrid:getSlotPosition(x, y)
    local slotX = self.x + (x - 1) * (self.cellSize + self.cellSpacing)
    local slotY = self.y + (y - 1) * (self.cellSize + self.cellSpacing)
    return slotX, slotY
end

function InventoryGrid:getSlotFromPosition(screenX, screenY)
    if screenX < self.x or screenY < self.y then return nil, nil end

    local relativeX = screenX - self.x
    local relativeY = screenY - self.y

    local gridX = math.floor(relativeX / (self.cellSize + self.cellSpacing)) + 1
    local gridY = math.floor(relativeY / (self.cellSize + self.cellSpacing)) + 1

    if self:isValidPosition(gridX, gridY) then
        return gridX, gridY
    end

    return nil, nil
end

function InventoryGrid:update(dt)
    core.Base.update(self, dt)

    self.animationTime = self.animationTime + dt

    -- Update item animations
    if self.animateItems then
        for x = 1, self.gridWidth do
            for y = 1, self.gridHeight do
                local item = self.items[x][y]
                if item and item.animScale then
                    -- Animation is handled by Animation system
                end
            end
        end
    end
end

function InventoryGrid:draw()
    -- Draw background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Draw border
    love.graphics.setColor(unpack(self.borderColor))
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Draw grid slots
    for x = 1, self.gridWidth do
        for y = 1, self.gridHeight do
            self:_drawSlot(x, y)
        end
    end

    -- Draw items
    for x = 1, self.gridWidth do
        for y = 1, self.gridHeight do
            local item = self.items[x][y]
            if item and not item.reference then -- Only draw the main item, not references
                self:_drawItem(item, x, y)
            end
        end
    end

    -- Draw drop preview
    if self.dragPreview then
        self:_drawDropPreview()
    end

    -- Draw tooltip
    if self.showTooltip and self.showTooltips then
        self:_drawTooltip()
    end
end

function InventoryGrid:_drawSlot(x, y)
    local slotX, slotY = self:getSlotPosition(x, y)

    -- Determine slot color
    local slotColor = self.cellColor

    -- Highlight hovered slot
    if self.hoveredSlot and self.hoveredSlot.x == x and self.hoveredSlot.y == y then
        slotColor = self.highlightColor
    end

    -- Highlight selected slot
    if self.selectedSlot and self.selectedSlot.x == x and self.selectedSlot.y == y then
        slotColor = self.highlightColor
    end

    -- Draw slot background
    love.graphics.setColor(unpack(slotColor))
    love.graphics.rectangle("fill", slotX, slotY, self.cellSize, self.cellSize)

    -- Draw slot border
    if self.showGridLines then
        love.graphics.setColor(unpack(self.cellBorderColor))
        love.graphics.rectangle("line", slotX, slotY, self.cellSize, self.cellSize)
    end

    -- Draw slot type indicator
    if self.slotTypes and self.slotTypes[x] and self.slotTypes[x][y] then
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.setFont(core.theme.font)
        local typeText = string.sub(self.slotTypes[x][y], 1, 1):upper()
        local textWidth = core.theme.font:getWidth(typeText)
        love.graphics.print(typeText, slotX + (self.cellSize - textWidth) / 2, slotY + 2)
    end
end

function InventoryGrid:_drawItem(item, x, y)
    local slotX, slotY = self:getSlotPosition(x, y)

    local itemWidth = (item.width or 1) * self.cellSize + ((item.width or 1) - 1) * self.cellSpacing
    local itemHeight = (item.height or 1) * self.cellSize + ((item.height or 1) - 1) * self.cellSpacing

    -- Apply animation scale
    local scale = 1
    if self.animateItems and item.animScale then
        scale = item.animScale
        local scaleOffset = (1 - scale) / 2
        slotX = slotX + itemWidth * scaleOffset
        slotY = slotY + itemHeight * scaleOffset
        itemWidth = itemWidth * scale
        itemHeight = itemHeight * scale
    end

    -- Draw quality background
    if item.quality and self.qualityColors[item.quality] then
        love.graphics.setColor(unpack(self.qualityColors[item.quality]))
        love.graphics.rectangle("fill", slotX + 1, slotY + 1, itemWidth - 2, itemHeight - 2)
    end

    -- Draw item background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", slotX + 2, slotY + 2, itemWidth - 4, itemHeight - 4)

    -- Draw item icon or image
    if item.image then
        love.graphics.setColor(1, 1, 1)
        local imageScale = math.min((itemWidth - 4) / item.image:getWidth(),
            (itemHeight - 4) / item.image:getHeight())
        local imageX = slotX + (itemWidth - item.image:getWidth() * imageScale) / 2
        local imageY = slotY + (itemHeight - item.image:getHeight() * imageScale) / 2
        love.graphics.draw(item.image, imageX, imageY, 0, imageScale, imageScale)
    else
        -- Draw text representation
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(core.theme.font)
        local displayText = item.icon or (item.name and string.sub(item.name, 1, 2):upper()) or "?"
        local textWidth = core.theme.font:getWidth(displayText)
        local textHeight = core.theme.font:getHeight()
        love.graphics.print(displayText,
            slotX + (itemWidth - textWidth) / 2,
            slotY + (itemHeight - textHeight) / 2)
    end

    -- Draw quantity
    if item.quantity and item.quantity > 1 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(core.theme.font)
        local quantityText = tostring(item.quantity)
        local textWidth = core.theme.font:getWidth(quantityText)
        love.graphics.print(quantityText, slotX + itemWidth - textWidth - 2, slotY + itemHeight - 12)
    end

    -- Draw item border
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", slotX, slotY, itemWidth, itemHeight)

    -- Glow effect for selected/special items
    if self.glowEffect and (item.selected or item.special) then
        local glow = 0.5 + 0.5 * math.sin(self.animationTime * 4)
        love.graphics.setColor(1, 1, 0, glow * 0.5)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", slotX - 1, slotY - 1, itemWidth + 2, itemHeight + 2)
    end
end

function InventoryGrid:_drawDropPreview()
    local x, y = love.mouse.getPosition()
    local gridX, gridY = self:getSlotFromPosition(x, y)

    if not gridX or not gridY then return end

    local item = self.dragPreview
    local canDrop = self:canPlaceItem(item, gridX, gridY)

    local slotX, slotY = self:getSlotPosition(gridX, gridY)
    local itemWidth = (item.width or 1) * self.cellSize + ((item.width or 1) - 1) * self.cellSpacing
    local itemHeight = (item.height or 1) * self.cellSize + ((item.height or 1) - 1) * self.cellSpacing

    -- Draw preview overlay
    local previewColor = canDrop and self.validDropColor or self.invalidDropColor
    love.graphics.setColor(unpack(previewColor))
    love.graphics.rectangle("fill", slotX, slotY, itemWidth, itemHeight)

    -- Draw preview border
    love.graphics.setColor(canDrop and { 0.2, 0.8, 0.2 } or { 0.8, 0.2, 0.2 })
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", slotX, slotY, itemWidth, itemHeight)
end

function InventoryGrid:_drawTooltip()
    if not self.tooltipText or self.tooltipText == "" then return end

    love.graphics.setFont(core.theme.font)
    local textWidth = core.theme.font:getWidth(self.tooltipText)
    local textHeight = core.theme.font:getHeight()

    local tooltipWidth = textWidth + 16
    local tooltipHeight = textHeight + 12

    local tooltipX = self.tooltipX
    local tooltipY = self.tooltipY - tooltipHeight - 10

    -- Adjust position if tooltip would go off screen
    if tooltipX + tooltipWidth > love.graphics.getWidth() then
        tooltipX = love.graphics.getWidth() - tooltipWidth
    end
    if tooltipY < 0 then
        tooltipY = self.tooltipY + 20
    end

    -- Draw tooltip background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 4)

    -- Draw tooltip border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 4)

    -- Draw tooltip text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.tooltipText, tooltipX + 8, tooltipY + 6)
end

function InventoryGrid:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    local gridX, gridY = self:getSlotFromPosition(x, y)
    if not gridX or not gridY then return true end

    local item = self.items[gridX][gridY]

    if button == 1 then -- Left click
        if item then
            -- Handle item reference
            if item.reference then
                item = item.reference
                gridX, gridY = item.refX, item.refY
            end

            self.selectedSlot = { x = gridX, y = gridY, item = item }

            if self.onItemClick then
                self.onItemClick(item, gridX, gridY, self)
            end

            -- Start drag
            DragDrop:startDrag(item, x, y, function(dragItem, dropX, dropY)
                local dropGridX, dropGridY = self:getSlotFromPosition(dropX, dropY)
                if dropGridX and dropGridY then
                    return self:moveItem(gridX, gridY, dropGridX, dropGridY)
                end
                return false
            end)
        else
            self.selectedSlot = { x = gridX, y = gridY, item = nil }

            if self.onSlotClick then
                self.onSlotClick(gridX, gridY, self)
            end
        end
    elseif button == 2 then -- Right click
        if item and self.onItemRightClick then
            if item.reference then
                item = item.reference
                gridX, gridY = item.refX, item.refY
            end
            self.onItemRightClick(item, gridX, gridY, self)
        end
    end

    return true
end

function InventoryGrid:mousemoved(x, y, dx, dy)
    local gridX, gridY = self:getSlotFromPosition(x, y)

    if gridX and gridY then
        self.hoveredSlot = { x = gridX, y = gridY }

        local item = self.items[gridX][gridY]
        if item then
            if item.reference then
                item = item.reference
            end

            -- Show tooltip
            self.tooltipText = self:_getItemTooltip(item)
            self.tooltipX = x
            self.tooltipY = y
            self.showTooltip = true

            if self.onItemHover then
                self.onItemHover(item, gridX, gridY, self)
            end
        else
            self.showTooltip = false
        end
    else
        self.hoveredSlot = nil
        self.showTooltip = false
    end
end

function InventoryGrid:_getItemTooltip(item)
    if not item then return "" end

    local tooltip = item.name or "Item"

    if item.description then
        tooltip = tooltip .. "\n" .. item.description
    end

    if item.quantity and item.quantity > 1 then
        tooltip = tooltip .. "\nQuantity: " .. item.quantity
    end

    if item.weight then
        tooltip = tooltip .. "\nWeight: " .. item.weight
    end

    if item.value then
        tooltip = tooltip .. "\nValue: " .. item.value
    end

    return tooltip
end

-- Public API
function InventoryGrid:clear()
    for x = 1, self.gridWidth do
        for y = 1, self.gridHeight do
            self.items[x][y] = nil
        end
    end
end

function InventoryGrid:findEmptySlot(item)
    local itemWidth = item.width or 1
    local itemHeight = item.height or 1

    for y = 1, self.gridHeight - itemHeight + 1 do
        for x = 1, self.gridWidth - itemWidth + 1 do
            if self:canPlaceItem(item, x, y) then
                return x, y
            end
        end
    end

    return nil, nil
end

function InventoryGrid:autoAddItem(item)
    local x, y = self:findEmptySlot(item)
    if x and y then
        return self:addItem(item, x, y)
    end
    return false
end

function InventoryGrid:getItemCount(itemId)
    local count = 0
    for x = 1, self.gridWidth do
        for y = 1, self.gridHeight do
            local item = self.items[x][y]
            if item and not item.reference and item.id == itemId then
                count = count + (item.quantity or 1)
            end
        end
    end
    return count
end

function InventoryGrid:getAllItems()
    local items = {}
    for x = 1, self.gridWidth do
        for y = 1, self.gridHeight do
            local item = self.items[x][y]
            if item and not item.reference then
                table.insert(items, { item = item, x = x, y = y })
            end
        end
    end
    return items
end

return InventoryGrid
