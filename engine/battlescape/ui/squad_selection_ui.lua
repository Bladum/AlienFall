---SquadSelectionUI - Mission Squad Assignment Interface
---
---Interactive UI for assigning soldiers to missions with drag-and-drop functionality.
---Displays available units on the left and assigned squad on the right. Supports filtering
---by soldier class and health status. Part of mission setup and deployment systems (Batch 8).
---
---Features:
---  - Dual-pane interface (available units left, assigned squad right)
---  - Drag-and-drop unit assignment
---  - Class-based filtering (Assault, Sniper, Heavy, Support, etc.)
---  - Health status filtering (exclude wounded/tired soldiers)
---  - Squad capacity limits
---  - Visual feedback (hover effects, color coding)
---  - Scrollable unit lists
---
---Key Exports:
---  - init(): Initialize/reset the UI state
---  - show(units, capacity, onConfirm, onCancel): Display UI with unit list
---  - hide(): Hide the UI
---  - isVisible(): Check if UI is currently visible
---  - update(dt): Update animations and hover states
---  - draw(): Render the UI
---  - mousepressed(x, y, button): Handle mouse input
---  - mousereleased(x, y, button): Handle mouse release
---  - keypressed(key): Handle keyboard input
---
---Dependencies:
---  - require("widgets"): UI widget library for buttons and panels
---
---@module battlescape.ui.squad_selection_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local SquadSelectionUI = require("battlescape.ui.squad_selection_ui")
---  SquadSelectionUI.init()
---  SquadSelectionUI.show(units, 8, onConfirm, onCancel)
---
---@see battlescape.ui.mission_brief_ui For mission briefing before squad selection
---@see battlescape.ui.loadout_management_ui For equipment assignment after squad selection

-- Squad Selection UI System
-- Interface for assigning soldiers to missions
-- Part of Batch 8: Mission Setup & Deployment Systems

local SquadSelectionUI = {}

-- Configuration
local PANEL_WIDTH = 720
local PANEL_HEIGHT = 600
local PANEL_X = (960 - PANEL_WIDTH) / 2
local PANEL_Y = (720 - PANEL_HEIGHT) / 2
local PADDING = 12
local LINE_HEIGHT = 18
local UNIT_ROW_HEIGHT = 36
local SCROLL_SPEED = 3

-- Colors
local COLORS = {
    BACKGROUND = {r=30, g=30, b=40, a=240},
    BORDER = {r=80, g=100, b=120},
    HEADER = {r=220, g=220, b=240},
    TEXT = {r=200, g=200, b=200},
    UNIT_AVAILABLE = {r=60, g=80, b=100},
    UNIT_ASSIGNED = {r=60, g=100, b=60},
    UNIT_UNAVAILABLE = {r=100, g=60, b=60},
    UNIT_HOVER = {r=100, g=120, b=140},
    FILTER_ACTIVE = {r=100, g=160, b=100},
    FILTER_INACTIVE = {r=60, g=60, b=80},
    HP_HIGH = {r=100, g=220, b=100},
    HP_MEDIUM = {r=255, g=200, b=60},
    HP_LOW = {r=255, g=80, b=60}
}

-- UI layout sections
local AVAILABLE_LIST = {
    x = PANEL_X + PADDING,
    y = PANEL_Y + 120,
    width = (PANEL_WIDTH - PADDING * 3) / 2,
    height = PANEL_HEIGHT - 180
}

local ASSIGNED_LIST = {
    x = PANEL_X + PADDING * 2 + (PANEL_WIDTH - PADDING * 3) / 2,
    y = PANEL_Y + 120,
    width = (PANEL_WIDTH - PADDING * 3) / 2,
    height = PANEL_HEIGHT - 180
}

-- Filter buttons
local FILTERS = {
    {id = "ALL", label = "All", x = PANEL_X + PADDING, active = true},
    {id = "ASSAULT", label = "Assault", x = PANEL_X + PADDING + 60, active = false},
    {id = "SNIPER", label = "Sniper", x = PANEL_X + PADDING + 144, active = false},
    {id = "MEDIC", label = "Medic", x = PANEL_X + PADDING + 228, active = false},
    {id = "HEAVY", label = "Heavy", x = PANEL_X + PADDING + 312, active = false},
    {id = "HEALTHY", label = "Healthy", x = PANEL_X + PADDING + 396, active = false}
}

-- Action buttons
local BUTTONS = {
    AUTOFILL = {x = PANEL_X + PADDING, y = PANEL_Y + PANEL_HEIGHT - 48 - PADDING, width = 144, height = 48, label = "AUTO-FILL"},
    CLEAR = {x = PANEL_X + PADDING + 156, y = PANEL_Y + PANEL_HEIGHT - 48 - PADDING, width = 96, height = 48, label = "CLEAR"},
    CONFIRM = {x = PANEL_X + PANEL_WIDTH - 144 - PADDING, y = PANEL_Y + PANEL_HEIGHT - 48 - PADDING, width = 144, height = 48, label = "CONFIRM"}
}

-- State
local visible = false
local availableUnits = {}  -- All soldiers available for selection
local assignedUnits = {}   -- Currently assigned soldiers
local maxCapacity = 8      -- Mission capacity (craft-dependent)
local scrollOffsetAvailable = 0
local scrollOffsetAssigned = 0
local hoveredUnit = nil
local hoveredButton = nil
local draggedUnit = nil
local confirmCallback = nil
local cancelCallback = nil

--- Initialize squad selection UI
function SquadSelectionUI.init()
    visible = false
    availableUnits = {}
    assignedUnits = {}
    maxCapacity = 8
    scrollOffsetAvailable = 0
    scrollOffsetAssigned = 0
    hoveredUnit = nil
    hoveredButton = nil
    draggedUnit = nil
    confirmCallback = nil
    cancelCallback = nil
    
    -- Reset filters
    for _, filter in ipairs(FILTERS) do
        filter.active = (filter.id == "ALL")
    end
end

--- Show squad selection UI
-- @param units Array of unit tables {id, name, rank, class, hp, maxHp, status}
-- @param capacity Maximum squad size for this mission
-- @param onConfirm Callback function when confirmed: onConfirm(assignedUnits)
-- @param onCancel Callback function when cancelled
function SquadSelectionUI.show(units, capacity, onConfirm, onCancel)
    availableUnits = {}
    assignedUnits = {}
    maxCapacity = capacity or 8
    confirmCallback = onConfirm
    cancelCallback = onCancel
    
    -- Filter available units (not wounded/tired)
    for _, unit in ipairs(units) do
        if not unit.status or unit.status == "READY" then
            table.insert(availableUnits, unit)
        end
    end
    
    visible = true
end

--- Hide squad selection UI
function SquadSelectionUI.hide()
    visible = false
end

--- Check if visible
function SquadSelectionUI.isVisible()
    return visible
end

--- Apply active filters to unit list
local function getFilteredUnits()
    local filtered = {}
    
    for _, unit in ipairs(availableUnits) do
        local include = true
        
        -- Check class filters
        local classFilterActive = false
        local classMatches = false
        for _, filter in ipairs(FILTERS) do
            if filter.active and filter.id ~= "ALL" and filter.id ~= "HEALTHY" then
                classFilterActive = true
                if unit.class == filter.id then
                    classMatches = true
                end
            end
        end
        if classFilterActive and not classMatches then
            include = false
        end
        
        -- Check healthy filter
        for _, filter in ipairs(FILTERS) do
            if filter.active and filter.id == "HEALTHY" then
                if unit.hp < unit.maxHp * 0.8 then
                    include = false
                end
            end
        end
        
        if include then
            table.insert(filtered, unit)
        end
    end
    
    return filtered
end

--- Auto-fill squad with best available units
local function autoFillSquad()
    assignedUnits = {}
    local filtered = getFilteredUnits()
    
    -- Sort by HP descending (prioritize healthy units)
    table.sort(filtered, function(a, b)
        return a.hp > b.hp
    end)
    
    -- Take up to capacity
    for i = 1, math.min(maxCapacity, #filtered) do
        table.insert(assignedUnits, filtered[i])
    end
    
    -- Remove assigned units from available list
    for _, assigned in ipairs(assignedUnits) do
        for i, available in ipairs(availableUnits) do
            if available.id == assigned.id then
                table.remove(availableUnits, i)
                break
            end
        end
    end
end

--- Clear assigned squad
local function clearSquad()
    -- Move all assigned back to available
    for _, unit in ipairs(assignedUnits) do
        table.insert(availableUnits, unit)
    end
    assignedUnits = {}
end

--- Draw the squad selection UI
function SquadSelectionUI.draw()
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
    love.graphics.print("SQUAD SELECTION", PANEL_X + PADDING, PANEL_Y + PADDING)
    
    -- Capacity display
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    local capacityText = "Assigned: " .. #assignedUnits .. " / " .. maxCapacity
    love.graphics.print(capacityText, PANEL_X + PANEL_WIDTH - PADDING - love.graphics.getFont():getWidth(capacityText), PANEL_Y + PADDING)
    
    -- Draw filters
    local filterY = PANEL_Y + PADDING + 30
    for _, filter in ipairs(FILTERS) do
        local color = filter.active and COLORS.FILTER_ACTIVE or COLORS.FILTER_INACTIVE
        love.graphics.setColor(color.r/255, color.g/255, color.b/255, 0.8)
        love.graphics.rectangle("fill", filter.x, filterY, 48, 24)
        
        love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", filter.x, filterY, 48, 24)
        
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print(filter.label, filter.x + 4, filterY + 4)
    end
    
    -- Column headers
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("AVAILABLE (" .. #getFilteredUnits() .. ")", AVAILABLE_LIST.x, AVAILABLE_LIST.y - 24)
    love.graphics.print("ASSIGNED (" .. #assignedUnits .. ")", ASSIGNED_LIST.x, ASSIGNED_LIST.y - 24)
    
    -- Draw available units list
    drawUnitList(getFilteredUnits(), AVAILABLE_LIST, scrollOffsetAvailable, false)
    
    -- Draw assigned units list
    drawUnitList(assignedUnits, ASSIGNED_LIST, scrollOffsetAssigned, true)
    
    -- Draw buttons
    drawButton(BUTTONS.AUTOFILL, hoveredButton == "AUTOFILL")
    drawButton(BUTTONS.CLEAR, hoveredButton == "CLEAR")
    drawButton(BUTTONS.CONFIRM, hoveredButton == "CONFIRM")
end

--- Draw a list of units
local function drawUnitList(units, listArea, scrollOffset, isAssigned)
    -- Clip to list area
    love.graphics.setScissor(listArea.x, listArea.y, listArea.width, listArea.height)
    
    local yPos = listArea.y - scrollOffset * UNIT_ROW_HEIGHT
    
    for i, unit in ipairs(units) do
        if yPos >= listArea.y - UNIT_ROW_HEIGHT and yPos < listArea.y + listArea.height then
            local isHovered = (hoveredUnit and hoveredUnit.id == unit.id)
            local color = isAssigned and COLORS.UNIT_ASSIGNED or COLORS.UNIT_AVAILABLE
            if isHovered then
                color = COLORS.UNIT_HOVER
            end
            
            -- Unit background
            love.graphics.setColor(color.r/255, color.g/255, color.b/255, 0.8)
            love.graphics.rectangle("fill", listArea.x, yPos, listArea.width, UNIT_ROW_HEIGHT - 2)
            
            -- Unit border
            love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", listArea.x, yPos, listArea.width, UNIT_ROW_HEIGHT - 2)
            
            -- Unit info
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print(unit.name, listArea.x + 4, yPos + 2)
            love.graphics.print(unit.rank .. " - " .. unit.class, listArea.x + 4, yPos + 18)
            
            -- HP bar
            local hpPercent = unit.hp / unit.maxHp
            local hpColor = COLORS.HP_HIGH
            if hpPercent < 0.3 then
                hpColor = COLORS.HP_LOW
            elseif hpPercent < 0.6 then
                hpColor = COLORS.HP_MEDIUM
            end
            
            local hpBarWidth = 60
            local hpBarX = listArea.x + listArea.width - hpBarWidth - 4
            
            love.graphics.setColor(40/255, 40/255, 40/255, 0.8)
            love.graphics.rectangle("fill", hpBarX, yPos + 10, hpBarWidth, 16)
            
            love.graphics.setColor(hpColor.r/255, hpColor.g/255, hpColor.b/255)
            love.graphics.rectangle("fill", hpBarX, yPos + 10, hpBarWidth * hpPercent, 16)
            
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print(unit.hp .. "/" .. unit.maxHp, hpBarX + 4, yPos + 12)
        end
        
        yPos = yPos + UNIT_ROW_HEIGHT
    end
    
    -- Reset scissor
    love.graphics.setScissor()
end

--- Draw a button
local function drawButton(button, isHovered)
    local color = COLORS.FILTER_INACTIVE
    if isHovered then
        color = COLORS.UNIT_HOVER
    end
    
    love.graphics.setColor(color.r/255, color.g/255, color.b/255, 0.8)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
    
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    local textWidth = love.graphics.getFont():getWidth(button.label)
    love.graphics.print(button.label, button.x + (button.width - textWidth) / 2, button.y + (button.height - LINE_HEIGHT) / 2)
end

--- Handle mouse click
function SquadSelectionUI.handleClick(mouseX, mouseY)
    if not visible then return false end
    
    -- Check filter buttons
    local filterY = PANEL_Y + PADDING + 30
    for _, filter in ipairs(FILTERS) do
        if mouseX >= filter.x and mouseX <= filter.x + 48 and
           mouseY >= filterY and mouseY <= filterY + 24 then
            if filter.id == "ALL" then
                -- Deactivate all other filters
                for _, f in ipairs(FILTERS) do
                    f.active = (f.id == "ALL")
                end
            else
                filter.active = not filter.active
                FILTERS[1].active = false  -- Deactivate "ALL"
            end
            return true
        end
    end
    
    -- Check action buttons
    if mouseX >= BUTTONS.AUTOFILL.x and mouseX <= BUTTONS.AUTOFILL.x + BUTTONS.AUTOFILL.width and
       mouseY >= BUTTONS.AUTOFILL.y and mouseY <= BUTTONS.AUTOFILL.y + BUTTONS.AUTOFILL.height then
        autoFillSquad()
        return true
    end
    
    if mouseX >= BUTTONS.CLEAR.x and mouseX <= BUTTONS.CLEAR.x + BUTTONS.CLEAR.width and
       mouseY >= BUTTONS.CLEAR.y and mouseY <= BUTTONS.CLEAR.y + BUTTONS.CLEAR.height then
        clearSquad()
        return true
    end
    
    if mouseX >= BUTTONS.CONFIRM.x and mouseX <= BUTTONS.CONFIRM.x + BUTTONS.CONFIRM.width and
       mouseY >= BUTTONS.CONFIRM.y and mouseY <= BUTTONS.CONFIRM.y + BUTTONS.CONFIRM.height then
        if #assignedUnits > 0 and confirmCallback then
            confirmCallback(assignedUnits)
            SquadSelectionUI.hide()
        end
        return true
    end
    
    -- Check unit clicks (assign/unassign)
    local clickedUnit = getUnitAtPosition(mouseX, mouseY)
    if clickedUnit then
        toggleUnitAssignment(clickedUnit)
        return true
    end
    
    return false
end

--- Get unit at mouse position
function getUnitAtPosition(mouseX, mouseY)
    -- Check available list
    if mouseX >= AVAILABLE_LIST.x and mouseX <= AVAILABLE_LIST.x + AVAILABLE_LIST.width and
       mouseY >= AVAILABLE_LIST.y and mouseY <= AVAILABLE_LIST.y + AVAILABLE_LIST.height then
        local relativeY = mouseY - AVAILABLE_LIST.y + scrollOffsetAvailable * UNIT_ROW_HEIGHT
        local index = math.floor(relativeY / UNIT_ROW_HEIGHT) + 1
        local filtered = getFilteredUnits()
        if index >= 1 and index <= #filtered then
            return filtered[index]
        end
    end
    
    -- Check assigned list
    if mouseX >= ASSIGNED_LIST.x and mouseX <= ASSIGNED_LIST.x + ASSIGNED_LIST.width and
       mouseY >= ASSIGNED_LIST.y and mouseY <= ASSIGNED_LIST.y + ASSIGNED_LIST.height then
        local relativeY = mouseY - ASSIGNED_LIST.y + scrollOffsetAssigned * UNIT_ROW_HEIGHT
        local index = math.floor(relativeY / UNIT_ROW_HEIGHT) + 1
        if index >= 1 and index <= #assignedUnits then
            return assignedUnits[index]
        end
    end
    
    return nil
end

--- Toggle unit assignment
function toggleUnitAssignment(unit)
    -- Check if already assigned
    for i, assigned in ipairs(assignedUnits) do
        if assigned.id == unit.id then
            -- Unassign
            table.remove(assignedUnits, i)
            table.insert(availableUnits, unit)
            return
        end
    end
    
    -- Check if can assign (capacity check)
    if #assignedUnits >= maxCapacity then
        return  -- At capacity
    end
    
    -- Assign
    for i, available in ipairs(availableUnits) do
        if available.id == unit.id then
            table.remove(availableUnits, i)
            table.insert(assignedUnits, unit)
            return
        end
    end
end

--- Handle mouse movement
function SquadSelectionUI.handleMouseMove(mouseX, mouseY)
    if not visible then return end
    
    hoveredUnit = getUnitAtPosition(mouseX, mouseY)
    
    hoveredButton = nil
    for name, button in pairs(BUTTONS) do
        if mouseX >= button.x and mouseX <= button.x + button.width and
           mouseY >= button.y and mouseY <= button.y + button.height then
            hoveredButton = name
        end
    end
end

--- Handle scroll
function SquadSelectionUI.handleScroll(mouseX, mouseY, scrollY)
    if not visible then return false end
    
    -- Scroll available list
    if mouseX >= AVAILABLE_LIST.x and mouseX <= AVAILABLE_LIST.x + AVAILABLE_LIST.width and
       mouseY >= AVAILABLE_LIST.y and mouseY <= AVAILABLE_LIST.y + AVAILABLE_LIST.height then
        scrollOffsetAvailable = math.max(0, math.min(scrollOffsetAvailable - scrollY * SCROLL_SPEED, #getFilteredUnits() - 10))
        return true
    end
    
    -- Scroll assigned list
    if mouseX >= ASSIGNED_LIST.x and mouseX <= ASSIGNED_LIST.x + ASSIGNED_LIST.width and
       mouseY >= ASSIGNED_LIST.y and mouseY <= ASSIGNED_LIST.y + ASSIGNED_LIST.height then
        scrollOffsetAssigned = math.max(0, math.min(scrollOffsetAssigned - scrollY * SCROLL_SPEED, #assignedUnits - 10))
        return true
    end
    
    return false
end

--- Get assigned units
function SquadSelectionUI.getAssignedUnits()
    return assignedUnits
end

return SquadSelectionUI






















