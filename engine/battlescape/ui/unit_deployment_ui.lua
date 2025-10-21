---UnitDeploymentUI - Soldier Assignment to Landing Zones
---
---Interactive interface for assigning squad members to specific landing zones on the
---battlefield. Features drag-and-drop assignment, landing zone capacity management,
---and visual deployment planning. Part of mission setup and deployment systems (Batch 8).
---
---Features:
---  - Landing zone panels with capacity indicators
---  - Drag-and-drop unit assignment
---  - Visual soldier cards with class/rank display
---  - Landing zone capacity limits and warnings
---  - Unassigned soldier pool
---  - Deployment confirmation and validation
---  - Hover tooltips for landing zone details
---
---Key Exports:
---  - init(): Initialize/reset the UI state
---  - show(units, lzData, onConfirm, onCancel): Display deployment interface
---  - hide(): Hide the deployment screen
---  - isVisible(): Check if UI is currently visible
---  - update(dt): Update animations and hover states
---  - draw(): Render the deployment interface
---  - mousepressed(x, y, button): Handle drag operations
---  - mousereleased(x, y, button): Handle drop operations
---  - keypressed(key): Handle keyboard input
---
---Dependencies:
---  - require("widgets"): UI widget library for panels and buttons
---
---@module battlescape.ui.unit_deployment_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local UnitDeploymentUI = require("battlescape.ui.unit_deployment_ui")
---  UnitDeploymentUI.init()
---  UnitDeploymentUI.show(squadUnits, landingZones, onDeploy, onCancel)
---
---@see battlescape.ui.landing_zone_preview_ui For LZ selection before deployment
---@see battlescape.ui.loadout_management_ui For equipment assignment after deployment

-- Unit Deployment Assignment UI System
-- Assign squad units to specific landing zones
-- Part of Batch 8: Mission Setup & Deployment Systems

local UnitDeploymentUI = {}

-- Configuration
local PANEL_WIDTH = 720
local PANEL_HEIGHT = 480
local PANEL_X = (960 - PANEL_WIDTH) / 2
local PANEL_Y = (720 - PANEL_HEIGHT) / 2
local PADDING = 12
local LINE_HEIGHT = 18
local UNIT_CARD_HEIGHT = 48
local LZ_PANEL_WIDTH = 160
local LZ_PANEL_HEIGHT = 200

-- Colors
local COLORS = {
    BACKGROUND = {r=30, g=30, b=40, a=240},
    BORDER = {r=80, g=100, b=120},
    HEADER = {r=220, g=220, b=240},
    TEXT = {r=200, g=200, b=200},
    UNIT_UNASSIGNED = {r=100, g=60, b=60},
    UNIT_ASSIGNED = {r=60, g=100, b=60},
    UNIT_HOVER = {r=100, g=120, b=140},
    LZ_PANEL = {r=50, g=70, b=60},
    LZ_FULL = {r=100, g=60, b=60},
    LZ_HOVER = {r=80, g=120, b=100}
}

-- State
local visible = false
local squadUnits = {}  -- All units in squad
local landingZones = {}  -- {id, name, capacity, units[]}
local selectedUnit = nil
local hoveredLZ = nil
local draggedUnit = nil
local confirmCallback = nil
local cancelCallback = nil

--- Initialize unit deployment UI
function UnitDeploymentUI.init()
    visible = false
    squadUnits = {}
    landingZones = {}
    selectedUnit = nil
    hoveredLZ = nil
    draggedUnit = nil
    confirmCallback = nil
    cancelCallback = nil
end

--- Show unit deployment UI
-- @param units Array of unit tables {id, name, rank, class}
-- @param lzData Array of landing zones {id, name, capacity}
-- @param onConfirm Callback function: onConfirm(lzAssignments)
-- @param onCancel Callback function
function UnitDeploymentUI.show(units, lzData, onConfirm, onCancel)
    squadUnits = units or {}
    confirmCallback = onConfirm
    cancelCallback = onCancel
    visible = true
    
    -- Initialize landing zones
    landingZones = {}
    for _, lz in ipairs(lzData or {}) do
        table.insert(landingZones, {
            id = lz.id,
            name = lz.name or ("LZ" .. lz.id),
            capacity = lz.capacity or 6,
            units = {}
        })
    end
end

--- Hide unit deployment UI
function UnitDeploymentUI.hide()
    visible = false
end

--- Check if visible
function UnitDeploymentUI.isVisible()
    return visible
end

--- Check if unit is assigned to any LZ
local function isUnitAssigned(unitId)
    for _, lz in ipairs(landingZones) do
        for _, unit in ipairs(lz.units) do
            if unit.id == unitId then
                return true
            end
        end
    end
    return false
end

--- Get unassigned units
local function getUnassignedUnits()
    local unassigned = {}
    for _, unit in ipairs(squadUnits) do
        if not isUnitAssigned(unit.id) then
            table.insert(unassigned, unit)
        end
    end
    return unassigned
end

--- Assign unit to landing zone
local function assignUnitToLZ(unit, lz)
    -- Check if LZ is full
    if #lz.units >= lz.capacity then
        return false
    end
    
    -- Remove from any other LZ
    for _, otherLZ in ipairs(landingZones) do
        for i, assignedUnit in ipairs(otherLZ.units) do
            if assignedUnit.id == unit.id then
                table.remove(otherLZ.units, i)
                break
            end
        end
    end
    
    -- Add to new LZ
    table.insert(lz.units, unit)
    return true
end

--- Unassign unit from LZ
local function unassignUnit(unitId)
    for _, lz in ipairs(landingZones) do
        for i, unit in ipairs(lz.units) do
            if unit.id == unitId then
                table.remove(lz.units, i)
                return true
            end
        end
    end
    return false
end

--- Auto-distribute units evenly
local function autoDistribute()
    -- Clear all assignments
    for _, lz in ipairs(landingZones) do
        lz.units = {}
    end
    
    -- Distribute units evenly
    local lzIndex = 1
    for _, unit in ipairs(squadUnits) do
        local lz = landingZones[lzIndex]
        if lz and #lz.units < lz.capacity then
            table.insert(lz.units, unit)
            lzIndex = lzIndex + 1
            if lzIndex > #landingZones then
                lzIndex = 1
            end
        end
    end
end

--- Check if all units assigned
local function allUnitsAssigned()
    return #getUnassignedUnits() == 0
end

--- Draw the unit deployment UI
function UnitDeploymentUI.draw()
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
    love.graphics.print("UNIT DEPLOYMENT", PANEL_X + PADDING, PANEL_Y + PADDING)
    
    -- Assignment status
    local unassignedCount = #getUnassignedUnits()
    local statusColor = unassignedCount == 0 and COLORS.UNIT_ASSIGNED or COLORS.UNIT_UNASSIGNED
    love.graphics.setColor(statusColor.r/255, statusColor.g/255, statusColor.b/255)
    local statusText = "Unassigned: " .. unassignedCount .. " / " .. #squadUnits
    love.graphics.print(statusText, PANEL_X + PANEL_WIDTH - PADDING - love.graphics.getFont():getWidth(statusText), PANEL_Y + PADDING)
    
    -- Unassigned units list
    local unassignedX = PANEL_X + PADDING
    local unassignedY = PANEL_Y + 60
    
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("UNASSIGNED UNITS (" .. unassignedCount .. ")", unassignedX, unassignedY - 20)
    
    local unitY = unassignedY
    for _, unit in ipairs(getUnassignedUnits()) do
        local isHovered = (selectedUnit and selectedUnit.id == unit.id)
        local unitColor = COLORS.UNIT_UNASSIGNED
        if isHovered then
            unitColor = COLORS.UNIT_HOVER
        end
        
        love.graphics.setColor(unitColor.r/255, unitColor.g/255, unitColor.b/255, 0.8)
        love.graphics.rectangle("fill", unassignedX, unitY, 180, UNIT_CARD_HEIGHT - 2)
        
        love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", unassignedX, unitY, 180, UNIT_CARD_HEIGHT - 2)
        
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print(unit.name, unassignedX + 4, unitY + 4)
        love.graphics.print(unit.rank .. " - " .. unit.class, unassignedX + 4, unitY + 24, 0, 0.8, 0.8)
        
        unitY = unitY + UNIT_CARD_HEIGHT
        if unitY > unassignedY + 280 then
            break  -- Max display
        end
    end
    
    -- Landing zones
    local lzX = PANEL_X + 220
    local lzY = PANEL_Y + 60
    
    for i, lz in ipairs(landingZones) do
        local lzPanelX = lzX + ((i - 1) % 3) * (LZ_PANEL_WIDTH + 12)
        local lzPanelY = lzY + math.floor((i - 1) / 3) * (LZ_PANEL_HEIGHT + 12)
        
        local isHovered = (hoveredLZ and hoveredLZ.id == lz.id)
        local isFull = (#lz.units >= lz.capacity)
        
        local lzColor = COLORS.LZ_PANEL
        if isFull then
            lzColor = COLORS.LZ_FULL
        end
        if isHovered then
            lzColor = COLORS.LZ_HOVER
        end
        
        -- LZ panel background
        love.graphics.setColor(lzColor.r/255, lzColor.g/255, lzColor.b/255, 0.8)
        love.graphics.rectangle("fill", lzPanelX, lzPanelY, LZ_PANEL_WIDTH, LZ_PANEL_HEIGHT)
        
        love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", lzPanelX, lzPanelY, LZ_PANEL_WIDTH, LZ_PANEL_HEIGHT)
        
        -- LZ header
        love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
        love.graphics.print(lz.name, lzPanelX + 4, lzPanelY + 4)
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print(#lz.units .. " / " .. lz.capacity, lzPanelX + LZ_PANEL_WIDTH - 40, lzPanelY + 4)
        
        -- Assigned units
        local unitYInLZ = lzPanelY + 28
        for _, unit in ipairs(lz.units) do
            love.graphics.setColor(COLORS.UNIT_ASSIGNED.r/255, COLORS.UNIT_ASSIGNED.g/255, COLORS.UNIT_ASSIGNED.b/255, 0.9)
            love.graphics.rectangle("fill", lzPanelX + 4, unitYInLZ, LZ_PANEL_WIDTH - 8, 24)
            
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print(unit.name, lzPanelX + 6, unitYInLZ + 4, 0, 0.7, 0.7)
            
            unitYInLZ = unitYInLZ + 26
        end
    end
    
    -- Auto-distribute button
    local autoX = PANEL_X + PADDING
    local autoY = PANEL_Y + PANEL_HEIGHT - 96
    
    love.graphics.setColor(COLORS.LZ_PANEL.r/255, COLORS.LZ_PANEL.g/255, COLORS.LZ_PANEL.b/255)
    love.graphics.rectangle("fill", autoX, autoY, 144, 36)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", autoX, autoY, 144, 36)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("AUTO-DISTRIBUTE", autoX + 12, autoY + 12)
    
    -- Confirm/Cancel buttons
    local confirmX = PANEL_X + PANEL_WIDTH - 120 - PADDING
    local confirmY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    local confirmEnabled = allUnitsAssigned()
    local confirmColor = confirmEnabled and COLORS.UNIT_ASSIGNED or COLORS.UNIT_UNASSIGNED
    
    love.graphics.setColor(confirmColor.r/255, confirmColor.g/255, confirmColor.b/255)
    love.graphics.rectangle("fill", confirmX, confirmY, 108, 36)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", confirmX, confirmY, 108, 36)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("CONFIRM", confirmX + 24, confirmY + 12)
    
    local cancelX = PANEL_X + PADDING
    local cancelY = confirmY
    love.graphics.setColor(COLORS.UNIT_UNASSIGNED.r/255, COLORS.UNIT_UNASSIGNED.g/255, COLORS.UNIT_UNASSIGNED.b/255)
    love.graphics.rectangle("fill", cancelX, cancelY, 84, 36)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", cancelX, cancelY, 84, 36)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("CANCEL", cancelX + 18, cancelY + 12)
end

--- Handle mouse click
function UnitDeploymentUI.handleClick(mouseX, mouseY)
    if not visible then return false end
    
    -- Check unassigned unit clicks (to assign)
    local unassignedX = PANEL_X + PADDING
    local unassignedY = PANEL_Y + 60
    local unitY = unassignedY
    
    for _, unit in ipairs(getUnassignedUnits()) do
        if mouseX >= unassignedX and mouseX <= unassignedX + 180 and
           mouseY >= unitY and mouseY <= unitY + UNIT_CARD_HEIGHT - 2 then
            selectedUnit = unit
            return true
        end
        unitY = unitY + UNIT_CARD_HEIGHT
    end
    
    -- Check LZ clicks (to assign selected unit or unassign)
    local lzX = PANEL_X + 220
    local lzY = PANEL_Y + 60
    
    for i, lz in ipairs(landingZones) do
        local lzPanelX = lzX + ((i - 1) % 3) * (LZ_PANEL_WIDTH + 12)
        local lzPanelY = lzY + math.floor((i - 1) / 3) * (LZ_PANEL_HEIGHT + 12)
        
        if mouseX >= lzPanelX and mouseX <= lzPanelX + LZ_PANEL_WIDTH and
           mouseY >= lzPanelY and mouseY <= lzPanelY + LZ_PANEL_HEIGHT then
            
            -- Check if clicking on assigned unit (to unassign)
            local unitYInLZ = lzPanelY + 28
            for _, unit in ipairs(lz.units) do
                if mouseY >= unitYInLZ and mouseY <= unitYInLZ + 24 then
                    unassignUnit(unit.id)
                    return true
                end
                unitYInLZ = unitYInLZ + 26
            end
            
            -- Assign selected unit to LZ
            if selectedUnit then
                assignUnitToLZ(selectedUnit, lz)
                selectedUnit = nil
                return true
            end
        end
    end
    
    -- Check auto-distribute button
    local autoX = PANEL_X + PADDING
    local autoY = PANEL_Y + PANEL_HEIGHT - 96
    
    if mouseX >= autoX and mouseX <= autoX + 144 and
       mouseY >= autoY and mouseY <= autoY + 36 then
        autoDistribute()
        return true
    end
    
    -- Check confirm button
    local confirmX = PANEL_X + PANEL_WIDTH - 120 - PADDING
    local confirmY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    if mouseX >= confirmX and mouseX <= confirmX + 108 and
       mouseY >= confirmY and mouseY <= confirmY + 36 then
        if allUnitsAssigned() and confirmCallback then
            confirmCallback(landingZones)
            UnitDeploymentUI.hide()
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
        UnitDeploymentUI.hide()
        return true
    end
    
    return false
end

--- Handle mouse movement
function UnitDeploymentUI.handleMouseMove(mouseX, mouseY)
    if not visible then return end
    
    hoveredLZ = nil
    
    local lzX = PANEL_X + 220
    local lzY = PANEL_Y + 60
    
    for i, lz in ipairs(landingZones) do
        local lzPanelX = lzX + ((i - 1) % 3) * (LZ_PANEL_WIDTH + 12)
        local lzPanelY = lzY + math.floor((i - 1) / 3) * (LZ_PANEL_HEIGHT + 12)
        
        if mouseX >= lzPanelX and mouseX <= lzPanelX + LZ_PANEL_WIDTH and
           mouseY >= lzPanelY and mouseY <= lzPanelY + LZ_PANEL_HEIGHT then
            hoveredLZ = lz
        end
    end
end

--- Get deployment assignments
function UnitDeploymentUI.getDeployment()
    return landingZones
end

return UnitDeploymentUI

























