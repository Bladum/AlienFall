---CraftSelectionUI - Mission Craft Selection Screen
---
---Choose which craft to use for mission deployment. Displays available crafts with stats,
---crew capacity, equipment, fuel, and readiness. Part of mission setup and deployment
---systems (Batch 8).
---
---Features:
---  - List of available crafts
---  - Craft stats display (speed, capacity, fuel, weapons)
---  - Crew assignment status
---  - Equipment loadout summary
---  - Fuel and readiness indicators
---  - Selection confirmation
---
---Craft Information Displayed:
---  - Name and type (interceptor, transport)
---  - Speed and range
---  - Soldier capacity
---  - Current crew count
---  - Fuel status
---  - Weapons and equipment
---  - Readiness state (ready, refueling, damaged)
---
---Configuration:
---  - Panel size: 480×400 pixels (centered)
---  - Craft row height: 60 pixels
---  - Padding: 12 pixels
---  - Line height: 18 pixels
---
---Key Exports:
---  - CraftSelectionUI.init(): Initializes UI
---  - CraftSelectionUI.setCrafts(crafts): Sets available craft list
---  - CraftSelectionUI.draw(): Renders selection screen
---  - CraftSelectionUI.update(dt): Updates animations
---  - CraftSelectionUI.mousepressed(x, y, button): Click handling
---  - CraftSelectionUI.getSelectedCraft(): Returns chosen craft
---
---Dependencies:
---  - None (standalone UI system)
---
---@module battlescape.ui.craft_selection_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CraftSelectionUI = require("battlescape.ui.craft_selection_ui")
---  CraftSelectionUI.setCrafts(availableCrafts)
---  CraftSelectionUI.draw()
---  local chosen = CraftSelectionUI.getSelectedCraft()
---
---@see scenes.deployment_screen For deployment flow

-- Craft Selection UI System
-- Choose which craft to use for mission deployment
-- Part of Batch 8: Mission Setup & Deployment Systems

local CraftSelectionUI = {}

-- Configuration
local PANEL_WIDTH = 480
local PANEL_HEIGHT = 400
local PANEL_X = (960 - PANEL_WIDTH) / 2
local PANEL_Y = (720 - PANEL_HEIGHT) / 2
local PADDING = 12
local LINE_HEIGHT = 18
local CRAFT_ROW_HEIGHT = 60

-- Colors
local COLORS = {
    BACKGROUND = {r=30, g=30, b=40, a=240},
    BORDER = {r=80, g=100, b=120},
    HEADER = {r=220, g=220, b=240},
    TEXT = {r=200, g=200, b=200},
    CRAFT_AVAILABLE = {r=60, g=100, b=60},
    CRAFT_UNAVAILABLE = {r=100, g=60, b=60},
    CRAFT_SELECTED = {r=100, g=140, b=180},
    CRAFT_HOVER = {r=100, g=120, b=140},
    STAT_GOOD = {r=100, g=220, b=100},
    STAT_WARNING = {r=255, g=200, b=60},
    STAT_BAD = {r=255, g=80, b=60}
}

-- Craft types with specifications
local CRAFT_SPECS = {
    SKYRANGER = {capacity = 14, speed = 760, range = 2000, weapons = 0, armor = 50},
    LIGHTNING = {capacity = 8, speed = 3100, range = 4500, weapons = 2, armor = 150},
    AVENGER = {capacity = 26, speed = 5400, range = 6800, weapons = 3, armor = 1200},
    FIRESTORM = {capacity = 2, speed = 4200, range = 5100, weapons = 4, armor = 500}
}

-- State
local visible = false
local availableCrafts = {}  -- {id, name, type, fuel, status, base, damage}
local selectedCraft = nil
local hoveredCraft = nil
local missionRange = 0  -- Distance to mission site
local confirmCallback = nil
local cancelCallback = nil
local scrollOffset = 0

--- Initialize craft selection UI
function CraftSelectionUI.init()
    visible = false
    availableCrafts = {}
    selectedCraft = nil
    hoveredCraft = nil
    missionRange = 0
    confirmCallback = nil
    cancelCallback = nil
    scrollOffset = 0
end

--- Show craft selection UI
-- @param crafts Array of craft tables {id, name, type, fuel, status, base, damage}
-- @param range Distance to mission site (km)
-- @param onConfirm Callback function: onConfirm(craft)
-- @param onCancel Callback function
function CraftSelectionUI.show(crafts, range, onConfirm, onCancel)
    availableCrafts = crafts or {}
    missionRange = range or 0
    confirmCallback = onConfirm
    cancelCallback = onCancel
    visible = true
    
    -- Auto-select first available craft
    for _, craft in ipairs(availableCrafts) do
        if isCraftAvailable(craft) then
            selectedCraft = craft
            break
        end
    end
end

--- Hide craft selection UI
function CraftSelectionUI.hide()
    visible = false
end

--- Check if visible
function CraftSelectionUI.isVisible()
    return visible
end

--- Check if craft is available for mission
function isCraftAvailable(craft)
    if not craft then return false end
    
    -- Check operational status
    if craft.status ~= "READY" then
        return false
    end
    
    -- Check fuel
    local specs = CRAFT_SPECS[craft.type]
    if not specs then return false end
    
    local fuelNeeded = (missionRange / specs.range) * 100
    if craft.fuel < fuelNeeded then
        return false
    end
    
    return true
end

--- Get craft unavailability reason
local function getUnavailableReason(craft)
    if not craft then return "Unknown" end
    
    if craft.status == "REPAIRING" then
        return "Under Repair"
    elseif craft.status == "REFUELING" then
        return "Refueling"
    elseif craft.status == "DEPLOYED" then
        return "Already Deployed"
    end
    
    local specs = CRAFT_SPECS[craft.type]
    if specs then
        local fuelNeeded = (missionRange / specs.range) * 100
        if craft.fuel < fuelNeeded then
            return "Insufficient Fuel"
        end
    end
    
    return "Unavailable"
end

--- Draw the craft selection UI
function CraftSelectionUI.draw()
    if not visible then return end
    
    -- Panel background
    love.graphics.setColor(COLORS.BACKGROUND.r/255, COLORS.BACKGROUND.g/255, COLORS.BACKGROUND.b/255, COLORS.BACKGROUND.a/255)
    love.graphics.rectangle("fill", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Panel border
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Header
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("SELECT CRAFT", PANEL_X + PADDING, PANEL_Y + PADDING)
    
    -- Mission range
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("Mission Range: " .. missionRange .. " km", PANEL_X + PANEL_WIDTH - 200, PANEL_Y + PADDING)
    
    -- Craft list
    local listY = PANEL_Y + 60
    local listHeight = PANEL_HEIGHT - 140
    
    love.graphics.setScissor(PANEL_X + PADDING, listY, PANEL_WIDTH - PADDING * 2, listHeight)
    
    local yPos = listY - scrollOffset * CRAFT_ROW_HEIGHT
    
    for _, craft in ipairs(availableCrafts) do
        if yPos >= listY - CRAFT_ROW_HEIGHT and yPos < listY + listHeight then
            local isAvailable = isCraftAvailable(craft)
            local isSelected = (selectedCraft and selectedCraft.id == craft.id)
            local isHovered = (hoveredCraft and hoveredCraft.id == craft.id)
            
            local bgColor = COLORS.CRAFT_UNAVAILABLE
            if isAvailable then
                bgColor = COLORS.CRAFT_AVAILABLE
            end
            if isSelected then
                bgColor = COLORS.CRAFT_SELECTED
            end
            if isHovered then
                bgColor = COLORS.CRAFT_HOVER
            end
            
            -- Craft background
            love.graphics.setColor(bgColor.r/255, bgColor.g/255, bgColor.b/255, 0.8)
            love.graphics.rectangle("fill", PANEL_X + PADDING, yPos, PANEL_WIDTH - PADDING * 2, CRAFT_ROW_HEIGHT - 2)
            
            -- Craft border
            love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", PANEL_X + PADDING, yPos, PANEL_WIDTH - PADDING * 2, CRAFT_ROW_HEIGHT - 2)
            
            -- Craft info
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print(craft.name, PANEL_X + PADDING + 4, yPos + 4)
            love.graphics.print("Type: " .. craft.type, PANEL_X + PADDING + 4, yPos + 20)
            love.graphics.print("Base: " .. (craft.base or "Unknown"), PANEL_X + PADDING + 4, yPos + 36)
            
            -- Status
            if isAvailable then
                love.graphics.setColor(COLORS.STAT_GOOD.r/255, COLORS.STAT_GOOD.g/255, COLORS.STAT_GOOD.b/255)
                love.graphics.print("READY", PANEL_X + PANEL_WIDTH - 96, yPos + 4)
            else
                love.graphics.setColor(COLORS.STAT_BAD.r/255, COLORS.STAT_BAD.g/255, COLORS.STAT_BAD.b/255)
                love.graphics.print(getUnavailableReason(craft), PANEL_X + PANEL_WIDTH - 180, yPos + 4)
            end
            
            -- Fuel bar
            local fuelPercent = craft.fuel / 100
            local fuelBarWidth = 80
            local fuelBarX = PANEL_X + PANEL_WIDTH - 96
            
            love.graphics.setColor(40/255, 40/255, 40/255)
            love.graphics.rectangle("fill", fuelBarX, yPos + 24, fuelBarWidth, 12)
            
            local fuelColor = COLORS.STAT_GOOD
            if fuelPercent < 0.3 then
                fuelColor = COLORS.STAT_BAD
            elseif fuelPercent < 0.6 then
                fuelColor = COLORS.STAT_WARNING
            end
            
            love.graphics.setColor(fuelColor.r/255, fuelColor.g/255, fuelColor.b/255)
            love.graphics.rectangle("fill", fuelBarX, yPos + 24, fuelBarWidth * fuelPercent, 12)
            
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print("Fuel: " .. craft.fuel .. "%", fuelBarX, yPos + 40, 0, 0.7, 0.7)
        end
        
        yPos = yPos + CRAFT_ROW_HEIGHT
    end
    
    love.graphics.setScissor()
    
    -- Selected craft details
    if selectedCraft then
        local detailsY = PANEL_Y + PANEL_HEIGHT - 120
        love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
        love.graphics.print("CRAFT SPECIFICATIONS", PANEL_X + PADDING, detailsY - 20)
        
        local specs = CRAFT_SPECS[selectedCraft.type]
        if specs then
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print("Capacity: " .. specs.capacity .. " soldiers", PANEL_X + PADDING, detailsY)
            love.graphics.print("Speed: " .. specs.speed .. " km/h", PANEL_X + PADDING, detailsY + 18)
            love.graphics.print("Range: " .. specs.range .. " km", PANEL_X + PADDING, detailsY + 36)
            love.graphics.print("Weapons: " .. specs.weapons, PANEL_X + PADDING + 240, detailsY)
            love.graphics.print("Armor: " .. specs.armor, PANEL_X + PADDING + 240, detailsY + 18)
        end
    end
    
    -- Confirm/Cancel buttons
    local confirmX = PANEL_X + PANEL_WIDTH - 120 - PADDING
    local confirmY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    local confirmEnabled = (selectedCraft and isCraftAvailable(selectedCraft))
    local confirmColor = confirmEnabled and COLORS.CRAFT_AVAILABLE or COLORS.CRAFT_UNAVAILABLE
    
    love.graphics.setColor(confirmColor.r/255, confirmColor.g/255, confirmColor.b/255)
    love.graphics.rectangle("fill", confirmX, confirmY, 108, 36)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", confirmX, confirmY, 108, 36)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("CONFIRM", confirmX + 24, confirmY + 12)
    
    local cancelX = PANEL_X + PADDING
    love.graphics.setColor(COLORS.CRAFT_UNAVAILABLE.r/255, COLORS.CRAFT_UNAVAILABLE.g/255, COLORS.CRAFT_UNAVAILABLE.b/255)
    love.graphics.rectangle("fill", cancelX, confirmY, 84, 36)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", cancelX, confirmY, 84, 36)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("CANCEL", cancelX + 18, confirmY + 12)
end

--- Handle mouse click
function CraftSelectionUI.handleClick(mouseX, mouseY)
    if not visible then return false end
    
    -- Check craft list clicks
    local listY = PANEL_Y + 60
    local listHeight = PANEL_HEIGHT - 140
    
    if mouseX >= PANEL_X + PADDING and mouseX <= PANEL_X + PANEL_WIDTH - PADDING and
       mouseY >= listY and mouseY <= listY + listHeight then
        local relativeY = mouseY - listY + scrollOffset * CRAFT_ROW_HEIGHT
        local index = math.floor(relativeY / CRAFT_ROW_HEIGHT) + 1
        if index >= 1 and index <= #availableCrafts then
            local craft = availableCrafts[index]
            if isCraftAvailable(craft) then
                selectedCraft = craft
            end
            return true
        end
    end
    
    -- Check confirm button
    local confirmX = PANEL_X + PANEL_WIDTH - 120 - PADDING
    local confirmY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    if mouseX >= confirmX and mouseX <= confirmX + 108 and
       mouseY >= confirmY and mouseY <= confirmY + 36 then
        if selectedCraft and isCraftAvailable(selectedCraft) and confirmCallback then
            confirmCallback(selectedCraft)
            CraftSelectionUI.hide()
        end
        return true
    end
    
    -- Check cancel button
    local cancelX = PANEL_X + PADDING
    if mouseX >= cancelX and mouseX <= cancelX + 84 and
       mouseY >= confirmY and mouseY <= confirmY + 36 then
        if cancelCallback then
            cancelCallback()
        end
        CraftSelectionUI.hide()
        return true
    end
    
    return false
end

--- Handle mouse movement
function CraftSelectionUI.handleMouseMove(mouseX, mouseY)
    if not visible then return end
    
    hoveredCraft = nil
    
    local listY = PANEL_Y + 60
    local listHeight = PANEL_HEIGHT - 140
    
    if mouseX >= PANEL_X + PADDING and mouseX <= PANEL_X + PANEL_WIDTH - PADDING and
       mouseY >= listY and mouseY <= listY + listHeight then
        local relativeY = mouseY - listY + scrollOffset * CRAFT_ROW_HEIGHT
        local index = math.floor(relativeY / CRAFT_ROW_HEIGHT) + 1
        if index >= 1 and index <= #availableCrafts then
            hoveredCraft = availableCrafts[index]
        end
    end
end

--- Handle scroll
function CraftSelectionUI.handleScroll(mouseX, mouseY, scrollY)
    if not visible then return false end
    
    local listY = PANEL_Y + 60
    local listHeight = PANEL_HEIGHT - 140
    
    if mouseX >= PANEL_X + PADDING and mouseX <= PANEL_X + PANEL_WIDTH - PADDING and
       mouseY >= listY and mouseY <= listY + listHeight then
        scrollOffset = math.max(0, math.min(scrollOffset - scrollY, #availableCrafts - 4))
        return true
    end
    
    return false
end

--- Get selected craft
function CraftSelectionUI.getSelectedCraft()
    return selectedCraft
end

return CraftSelectionUI

























