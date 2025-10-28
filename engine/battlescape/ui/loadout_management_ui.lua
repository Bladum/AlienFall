---LoadoutManagementUI - Soldier Equipment Assignment Interface
---
---Interactive equipment management system for assigning weapons, armor, and items to
---individual soldiers before mission deployment. Features drag-and-drop interface,
---equipment templates, and base storage integration. Part of mission setup and
---deployment systems (Batch 8).
---
---Features:
---  - Paper doll equipment slots (primary, secondary, armor, belt, backpack)
---  - Drag-and-drop equipment assignment
---  - Base storage integration with item filtering
---  - Equipment templates by soldier class (Assault, Sniper, Medic, Heavy)
---  - Weight and capacity management
---  - Visual equipment preview
---  - Item tooltips and statistics
---
---Key Exports:
---  - init(): Initialize/reset the UI state
---  - show(unit, baseStorage, onConfirm, onCancel): Display loadout for specific soldier
---  - hide(): Hide the loadout management screen
---  - isVisible(): Check if UI is currently visible
---  - update(dt): Update animations and hover states
---  - draw(): Render the equipment interface
---  - mousepressed(x, y, button): Handle mouse input for drag operations
---  - mousereleased(x, y, button): Handle mouse release for drop operations
---  - keypressed(key): Handle keyboard input
---
---Dependencies:
---  - require("widgets"): UI widget library for panels and buttons
---  - require("shared.items"): Item definitions and statistics
---
---@module battlescape.ui.loadout_management_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local LoadoutManagementUI = require("battlescape.ui.loadout_management_ui")
---  LoadoutManagementUI.init()
---  LoadoutManagementUI.show(unitData, baseStorage, onConfirm, onCancel)
---
---@see battlescape.ui.squad_selection_ui For soldier selection before loadout
---@see shared.items For item definitions and equipment data

-- Loadout Management UI System
-- Per-unit equipment selection before mission
-- Part of Batch 8: Mission Setup & Deployment Systems

local LoadoutManagementUI = {}

-- Configuration
local PANEL_WIDTH = 800
local PANEL_HEIGHT = 600
local PANEL_X = (960 - PANEL_WIDTH) / 2
local PANEL_Y = (720 - PANEL_HEIGHT) / 2
local PADDING = 12
local LINE_HEIGHT = 18
local SLOT_SIZE = 60
local ITEM_LIST_ROW_HEIGHT = 30

-- Colors
local COLORS = {
    BACKGROUND = {r=30, g=30, b=40, a=240},
    BORDER = {r=80, g=100, b=120},
    HEADER = {r=220, g=220, b=240},
    TEXT = {r=200, g=200, b=200},
    SLOT_EMPTY = {r=40, g=40, b=50},
    SLOT_FILLED = {r=60, g=80, b=100},
    SLOT_HOVER = {r=100, g=120, b=140},
    WEIGHT_OK = {r=100, g=220, b=100},
    WEIGHT_WARNING = {r=255, g=200, b=60},
    WEIGHT_OVER = {r=255, g=80, b=60},
    TEMPLATE_BUTTON = {r=60, g=100, b=140}
}

-- Equipment slot layout
local SLOTS = {
    PRIMARY_WEAPON = {x = 0, y = 0, width = 60, height = 60, label = "PRIMARY"},
    SECONDARY_WEAPON = {x = 72, y = 0, width = 60, height = 60, label = "SECONDARY"},
    ARMOR = {x = 144, y = 0, width = 60, height = 60, label = "ARMOR"},
    BELT_1 = {x = 0, y = 72, width = 60, height = 60, label = "BELT 1 [1]"},
    BELT_2 = {x = 72, y = 72, width = 60, height = 60, label = "BELT 2 [2]"},
    BELT_3 = {x = 144, y = 72, width = 60, height = 60, label = "BELT 3 [3]"},
    BELT_4 = {x = 216, y = 72, width = 60, height = 60, label = "BELT 4 [4]"},
    BACKPACK_1 = {x = 0, y = 144, width = 60, height = 60, label = "PACK 1"},
    BACKPACK_2 = {x = 72, y = 144, width = 60, height = 60, label = "PACK 2"},
    BACKPACK_3 = {x = 144, y = 144, width = 60, height = 60, label = "PACK 3"},
    BACKPACK_4 = {x = 0, y = 216, width = 60, height = 60, label = "PACK 4"},
    BACKPACK_5 = {x = 72, y = 216, width = 60, height = 60, label = "PACK 5"},
    BACKPACK_6 = {x = 144, y = 216, width = 60, height = 60, label = "PACK 6"}
}

-- Loadout templates
local TEMPLATES = {
    {id = "ASSAULT", label = "Assault", items = {"RIFLE", "PISTOL", "ARMOR_LIGHT", "GRENADE_FRAG", "GRENADE_FRAG", "MEDKIT", "AMMO_RIFLE"}},
    {id = "SNIPER", label = "Sniper", items = {"SNIPER_RIFLE", "PISTOL", "ARMOR_LIGHT", "GRENADE_SMOKE", "MEDKIT", "AMMO_SNIPER", "AMMO_SNIPER"}},
    {id = "MEDIC", label = "Medic", items = {"SMG", "PISTOL", "ARMOR_LIGHT", "MEDKIT", "MEDKIT", "MEDKIT", "GRENADE_SMOKE"}},
    {id = "HEAVY", label = "Heavy", items = {"LMG", "PISTOL", "ARMOR_HEAVY", "GRENADE_FRAG", "GRENADE_FRAG", "AMMO_LMG", "AMMO_LMG"}}
}

-- State
local visible = false
local currentUnit = nil  -- {id, name, strength}
local unitLoadout = {}   -- {slotName: item}
local baseStorage = {}   -- {category: {item1, item2, ...}}
local selectedSlot = nil
local hoveredSlot = nil
local hoveredItem = nil
local storageScrollOffset = 0
local storageFilter = "ALL"  -- ALL, WEAPON, ARMOR, GRENADE, MEDKIT, AMMO
local confirmCallback = nil
local cancelCallback = nil

-- Item categories for filtering
local ITEM_CATEGORIES = {"ALL", "WEAPON", "ARMOR", "GRENADE", "MEDKIT", "AMMO", "TOOL"}

--- Initialize loadout management UI
function LoadoutManagementUI.init()
    visible = false
    currentUnit = nil
    unitLoadout = {}
    baseStorage = {}
    selectedSlot = nil
    hoveredSlot = nil
    hoveredItem = nil
    storageScrollOffset = 0
    storageFilter = "ALL"
    confirmCallback = nil
    cancelCallback = nil
end

--- Show loadout management UI
-- @param unit Table {id, name, strength}
-- @param currentEquipment Table {slotName: item}
-- @param storage Table {category: {item1, item2, ...}}
-- @param onConfirm Callback function: onConfirm(loadout)
-- @param onCancel Callback function
function LoadoutManagementUI.show(unit, currentEquipment, storage, onConfirm, onCancel)
    currentUnit = unit
    unitLoadout = currentEquipment or {}
    baseStorage = storage or {}
    confirmCallback = onConfirm
    cancelCallback = onCancel
    visible = true
end

--- Hide loadout management UI
function LoadoutManagementUI.hide()
    visible = false
end

--- Check if visible
function LoadoutManagementUI.isVisible()
    return visible
end

--- Calculate total weight
local function calculateWeight()
    local totalWeight = 0
    for _, item in pairs(unitLoadout) do
        if item and item.weight then
            totalWeight = totalWeight + item.weight
        end
    end
    return totalWeight
end

--- Calculate weight capacity
local function getWeightCapacity()
    local baseCapacity = 30
    local strengthBonus = (currentUnit and currentUnit.strength or 10) * 2
    return baseCapacity + strengthBonus
end

--- Check if over weight
local function isOverweight()
    return calculateWeight() > getWeightCapacity()
end

--- Get weight penalty
local function getWeightPenalty()
    local weight = calculateWeight()
    local capacity = getWeightCapacity()
    if weight <= capacity then
        return 0
    end
    local excessWeight = weight - capacity
    return math.floor(excessWeight / 10) * 2
end

--- Apply loadout template
local function applyTemplate(template)
    -- Clear current loadout
    unitLoadout = {}
    
    -- Try to equip items from storage
    local slotIndex = 1
    for _, itemType in ipairs(template.items) do
        -- Find item in storage
        for category, items in pairs(baseStorage) do
            for i, item in ipairs(items) do
                if item.type == itemType then
                    -- Assign to next available slot
                    local slotName = getNextAvailableSlot(item)
                    if slotName then
                        unitLoadout[slotName] = item
                        table.remove(items, i)
                        break
                    end
                end
            end
        end
    end
end

--- Get next available slot for item
function getNextAvailableSlot(item)
    -- Primary/secondary weapons
    if item.category == "WEAPON" then
        if not unitLoadout.PRIMARY_WEAPON then
            return "PRIMARY_WEAPON"
        elseif not unitLoadout.SECONDARY_WEAPON then
            return "SECONDARY_WEAPON"
        end
    end
    
    -- Armor
    if item.category == "ARMOR" then
        if not unitLoadout.ARMOR then
            return "ARMOR"
        end
    end
    
    -- Belt slots
    for i = 1, 4 do
        local slotName = "BELT_" .. i
        if not unitLoadout[slotName] then
            return slotName
        end
    end
    
    -- Backpack slots
    for i = 1, 6 do
        local slotName = "BACKPACK_" .. i
        if not unitLoadout[slotName] then
            return slotName
        end
    end
    
    return nil  -- No available slots
end

--- Draw the loadout management UI
function LoadoutManagementUI.draw()
    if not visible or not currentUnit then return end
    
    -- Panel background
    love.graphics.setColor(COLORS.BACKGROUND.r/255, COLORS.BACKGROUND.g/255, COLORS.BACKGROUND.b/255, COLORS.BACKGROUND.a/255)
    love.graphics.rectangle("fill", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Panel border
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Header
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("LOADOUT MANAGEMENT", PANEL_X + PADDING, PANEL_Y + PADDING)
    
    -- Unit name
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("Unit: " .. currentUnit.name, PANEL_X + PADDING, PANEL_Y + PADDING + 24)
    
    -- Weight display
    local weight = calculateWeight()
    local capacity = getWeightCapacity()
    local weightPercent = weight / capacity
    local weightColor = COLORS.WEIGHT_OK
    if weightPercent > 1.0 then
        weightColor = COLORS.WEIGHT_OVER
    elseif weightPercent > 0.8 then
        weightColor = COLORS.WEIGHT_WARNING
    end
    
    love.graphics.setColor(weightColor.r/255, weightColor.g/255, weightColor.b/255)
    local weightText = "Weight: " .. weight .. " / " .. capacity .. " kg"
    if isOverweight() then
        weightText = weightText .. " (AP penalty: -" .. getWeightPenalty() .. ")"
    end
    love.graphics.print(weightText, PANEL_X + PANEL_WIDTH - PADDING - love.graphics.getFont():getWidth(weightText), PANEL_Y + PADDING)
    
    -- Draw equipment slots
    local slotsX = PANEL_X + PADDING
    local slotsY = PANEL_Y + 80
    
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("EQUIPMENT", slotsX, slotsY - 20)
    
    for slotName, slot in pairs(SLOTS) do
        local slotX = slotsX + slot.x
        local slotY = slotsY + slot.y
        local item = unitLoadout[slotName]
        
        local slotColor = item and COLORS.SLOT_FILLED or COLORS.SLOT_EMPTY
        if hoveredSlot == slotName then
            slotColor = COLORS.SLOT_HOVER
        end
        
        -- Slot background
        love.graphics.setColor(slotColor.r/255, slotColor.g/255, slotColor.b/255)
        love.graphics.rectangle("fill", slotX, slotY, slot.width, slot.height)
        
        -- Slot border
        love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", slotX, slotY, slot.width, slot.height)
        
        -- Item name if equipped
        if item then
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print(item.name or item.type, slotX + 2, slotY + 2, 0, 0.6, 0.6)
        end
    end
    
    -- Draw base storage
    local storageX = PANEL_X + 320
    local storageY = PANEL_Y + 80
    
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("BASE STORAGE", storageX, storageY - 20)
    
    -- Storage filters
    local filterY = storageY + 10
    for i, category in ipairs(ITEM_CATEGORIES) do
        local filterX = storageX + (i - 1) * 72
        local isActive = (storageFilter == category)
        
        local filterColor = isActive and COLORS.TEMPLATE_BUTTON or COLORS.SLOT_EMPTY
        love.graphics.setColor(filterColor.r/255, filterColor.g/255, filterColor.b/255)
        love.graphics.rectangle("fill", filterX, filterY, 60, 24)
        
        love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", filterX, filterY, 60, 24)
        
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print(category, filterX + 4, filterY + 4, 0, 0.7, 0.7)
    end
    
    -- Storage items list (scrollable)
    local itemListY = storageY + 50
    drawStorageItems(storageX, itemListY, 450, 300)
    
    -- Draw template buttons
    local templateY = PANEL_Y + PANEL_HEIGHT - 100
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("QUICK TEMPLATES:", PANEL_X + PADDING, templateY - 24)
    
    for i, template in ipairs(TEMPLATES) do
        local btnX = PANEL_X + PADDING + (i - 1) * 100
        love.graphics.setColor(COLORS.TEMPLATE_BUTTON.r/255, COLORS.TEMPLATE_BUTTON.g/255, COLORS.TEMPLATE_BUTTON.b/255)
        love.graphics.rectangle("fill", btnX, templateY, 90, 30)
        
        love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", btnX, templateY, 90, 30)
        
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print(template.label, btnX + 4, templateY + 8)
    end
    
    -- Confirm/Cancel buttons
    local confirmX = PANEL_X + PANEL_WIDTH - 156 - PADDING
    local confirmY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    love.graphics.setColor(COLORS.TEMPLATE_BUTTON.r/255, COLORS.TEMPLATE_BUTTON.g/255, COLORS.TEMPLATE_BUTTON.b/255)
    love.graphics.rectangle("fill", confirmX, confirmY, 144, 48)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", confirmX, confirmY, 144, 48)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("CONFIRM", confirmX + 36, confirmY + 18)
    
    local cancelX = PANEL_X + PADDING
    love.graphics.setColor(COLORS.SLOT_EMPTY.r/255, COLORS.SLOT_EMPTY.g/255, COLORS.SLOT_EMPTY.b/255)
    love.graphics.rectangle("fill", cancelX, confirmY, 96, 48)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", cancelX, confirmY, 96, 48)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("CANCEL", cancelX + 24, confirmY + 18)
end

--- Draw storage items
local function drawStorageItems(x, y, width, height)
    love.graphics.setScissor(x, y, width, height)
    
    local itemY = y - storageScrollOffset * ITEM_LIST_ROW_HEIGHT
    
    for category, items in pairs(baseStorage) do
        if storageFilter == "ALL" or category == storageFilter then
            for i, item in ipairs(items) do
                if itemY >= y - ITEM_LIST_ROW_HEIGHT and itemY < y + height then
                    local isHovered = (hoveredItem and hoveredItem.id == item.id)
                    local itemColor = isHovered and COLORS.SLOT_HOVER or COLORS.SLOT_EMPTY
                    
                    love.graphics.setColor(itemColor.r/255, itemColor.g/255, itemColor.b/255)
                    love.graphics.rectangle("fill", x, itemY, width, ITEM_LIST_ROW_HEIGHT - 2)
                    
                    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
                    love.graphics.setLineWidth(1)
                    love.graphics.rectangle("line", x, itemY, width, ITEM_LIST_ROW_HEIGHT - 2)
                    
                    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
                    love.graphics.print(item.name or item.type, x + 4, itemY + 6)
                    love.graphics.print(item.weight .. " kg", x + width - 60, itemY + 6)
                end
                
                itemY = itemY + ITEM_LIST_ROW_HEIGHT
            end
        end
    end
    
    love.graphics.setScissor()
end

--- Handle mouse click
function LoadoutManagementUI.handleClick(mouseX, mouseY)
    if not visible then return false end
    
    -- Check slot clicks
    local slotsX = PANEL_X + PADDING
    local slotsY = PANEL_Y + 80
    
    for slotName, slot in pairs(SLOTS) do
        local slotX = slotsX + slot.x
        local slotY = slotsY + slot.y
        
        if mouseX >= slotX and mouseX <= slotX + slot.width and
           mouseY >= slotY and mouseY <= slotY + slot.height then
            -- Unequip item
            if unitLoadout[slotName] then
                local item = unitLoadout[slotName]
                unitLoadout[slotName] = nil
                -- Return to storage
                if not baseStorage[item.category] then
                    baseStorage[item.category] = {}
                end
                table.insert(baseStorage[item.category], item)
            end
            return true
        end
    end
    
    -- Check template clicks
    local templateY = PANEL_Y + PANEL_HEIGHT - 100
    for i, template in ipairs(TEMPLATES) do
        local btnX = PANEL_X + PADDING + (i - 1) * 100
        if mouseX >= btnX and mouseX <= btnX + 90 and
           mouseY >= templateY and mouseY <= templateY + 30 then
            applyTemplate(template)
            return true
        end
    end
    
    -- Check confirm/cancel
    local confirmX = PANEL_X + PANEL_WIDTH - 156 - PADDING
    local confirmY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    if mouseX >= confirmX and mouseX <= confirmX + 144 and
       mouseY >= confirmY and mouseY <= confirmY + 48 then
        if confirmCallback then
            confirmCallback(unitLoadout)
        end
        LoadoutManagementUI.hide()
        return true
    end
    
    local cancelX = PANEL_X + PADDING
    if mouseX >= cancelX and mouseX <= cancelX + 96 and
       mouseY >= confirmY and mouseY <= confirmY + 48 then
        if cancelCallback then
            cancelCallback()
        end
        LoadoutManagementUI.hide()
        return true
    end
    
    return false
end

--- Handle mouse movement
function LoadoutManagementUI.handleMouseMove(mouseX, mouseY)
    if not visible then return end
    
    hoveredSlot = nil
    local slotsX = PANEL_X + PADDING
    local slotsY = PANEL_Y + 80
    
    for slotName, slot in pairs(SLOTS) do
        local slotX = slotsX + slot.x
        local slotY = slotsY + slot.y
        if mouseX >= slotX and mouseX <= slotX + slot.width and
           mouseY >= slotY and mouseY <= slotY + slot.height then
            hoveredSlot = slotName
        end
    end
end

--- Get loadout
function LoadoutManagementUI.getLoadout()
    return unitLoadout
end

return LoadoutManagementUI


























