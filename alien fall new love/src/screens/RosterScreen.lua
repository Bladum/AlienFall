--- Roster Screen
-- Displays all available soldiers/units with equipment and stats
--
-- @classmod screens.RosterScreen

-- GROK: RosterScreen shows player's soldier roster with filtering and sorting
-- GROK: Grid-aligned UI at 800x600 resolution using 20px grid system
-- GROK: Key methods: draw(), update(), mousepressed(), keypressed()
-- GROK: Integrates with unit system, equipment calculator, and save/load

local class = require 'lib.Middleclass'
local Button = require 'widgets.Button'
local Panel = require 'widgets.Panel'

--- RosterScreen class
-- @type RosterScreen
local RosterScreen = class('RosterScreen')

-- Constants (20px grid system, 800x600 resolution)
local GRID_SIZE = 20
local SCREEN_WIDTH = 800
local SCREEN_HEIGHT = 600
local GRID_WIDTH = SCREEN_WIDTH / GRID_SIZE  -- 40 units
local GRID_HEIGHT = SCREEN_HEIGHT / GRID_SIZE -- 30 units

--- Create a new RosterScreen
-- @param registry Service registry
-- @return RosterScreen instance
function RosterScreen:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    
    -- UI state
    self.selectedUnitIndex = nil
    self.sortBy = 'name' -- name, rank, wounds, missions
    self.filterStatus = 'all' -- all, available, wounded, training
    self.scrollOffset = 0
    
    -- Create UI widgets
    self:_createWidgets()
end

--- Create UI widgets
function RosterScreen:_createWidgets()
    self.widgets = {}
    
    -- Title panel (2 grid units tall)
    self.widgets.titlePanel = Panel:new(
        0, 0, 
        GRID_WIDTH * GRID_SIZE, 
        2 * GRID_SIZE,
        {title = "SOLDIER ROSTER", bordered = true}
    )
    
    -- Filter buttons (1 row, 4 buttons)
    local filterY = 2 * GRID_SIZE
    local filterWidth = 8 * GRID_SIZE
    local filterSpacing = 1 * GRID_SIZE
    
    self.widgets.filterAll = Button:new(
        1 * GRID_SIZE, filterY,
        filterWidth, 2 * GRID_SIZE,
        "ALL",
        function() self:setFilter('all') end
    )
    
    self.widgets.filterAvailable = Button:new(
        10 * GRID_SIZE, filterY,
        filterWidth, 2 * GRID_SIZE,
        "AVAILABLE",
        function() self:setFilter('available') end
    )
    
    self.widgets.filterWounded = Button:new(
        19 * GRID_SIZE, filterY,
        filterWidth, 2 * GRID_SIZE,
        "WOUNDED",
        function() self:setFilter('wounded') end
    )
    
    self.widgets.filterTraining = Button:new(
        28 * GRID_SIZE, filterY,
        filterWidth, 2 * GRID_SIZE,
        "TRAINING",
        function() self:setFilter('training') end
    )
    
    -- Sort buttons
    local sortY = 5 * GRID_SIZE
    self.widgets.sortName = Button:new(
        1 * GRID_SIZE, sortY,
        6 * GRID_SIZE, 2 * GRID_SIZE,
        "NAME",
        function() self:setSortBy('name') end
    )
    
    self.widgets.sortRank = Button:new(
        8 * GRID_SIZE, sortY,
        6 * GRID_SIZE, 2 * GRID_SIZE,
        "RANK",
        function() self:setSortBy('rank') end
    )
    
    self.widgets.sortMissions = Button:new(
        15 * GRID_SIZE, sortY,
        7 * GRID_SIZE, 2 * GRID_SIZE,
        "MISSIONS",
        function() self:setSortBy('missions') end
    )
    
    -- Unit list area (from grid row 8 to 27 = 20 rows)
    self.listStartY = 8 * GRID_SIZE
    self.listHeight = 19 * GRID_SIZE
    self.rowHeight = 3 * GRID_SIZE
    
    -- Bottom buttons
    local bottomY = 27 * GRID_SIZE
    self.widgets.btnBack = Button:new(
        1 * GRID_SIZE, bottomY,
        8 * GRID_SIZE, 2 * GRID_SIZE,
        "BACK",
        function() self:goBack() end
    )
    
    self.widgets.btnEquip = Button:new(
        16 * GRID_SIZE, bottomY,
        8 * GRID_SIZE, 2 * GRID_SIZE,
        "EQUIP UNIT",
        function() self:equipSelected() end
    )
    
    self.widgets.btnDismiss = Button:new(
        25 * GRID_SIZE, bottomY,
        8 * GRID_SIZE, 2 * GRID_SIZE,
        "DISMISS",
        function() self:dismissSelected() end
    )
end

--- Enter the screen
function RosterScreen:enter()
    self.selectedUnitIndex = nil
    self.scrollOffset = 0
    self:_loadUnits()
end

--- Load units from unit system
function RosterScreen:_loadUnits()
    local unitSystem = self.registry and self.registry:resolve('unit_system')
    if unitSystem then
        self.allUnits = unitSystem:getAllUnits() or {}
    else
        self.allUnits = {}
    end
    
    self:_applyFiltersAndSort()
end

--- Apply current filters and sorting
function RosterScreen:_applyFiltersAndSort()
    -- Filter units
    self.filteredUnits = {}
    for _, unit in ipairs(self.allUnits) do
        if self:_matchesFilter(unit) then
            table.insert(self.filteredUnits, unit)
        end
    end
    
    -- Sort units
    table.sort(self.filteredUnits, function(a, b)
        return self:_compareUnits(a, b)
    end)
end

--- Check if unit matches current filter
-- @param unit Unit to check
-- @return boolean Matches filter
function RosterScreen:_matchesFilter(unit)
    if self.filterStatus == 'all' then
        return true
    elseif self.filterStatus == 'available' then
        return unit.status == 'available' or not unit.status
    elseif self.filterStatus == 'wounded' then
        return unit.status == 'wounded' or (unit.wounds and unit.wounds > 0)
    elseif self.filterStatus == 'training' then
        return unit.status == 'training'
    end
    return false
end

--- Compare units for sorting
-- @param a First unit
-- @param b Second unit
-- @return boolean a < b
function RosterScreen:_compareUnits(a, b)
    if self.sortBy == 'name' then
        return (a.name or "") < (b.name or "")
    elseif self.sortBy == 'rank' then
        local rankOrder = {recruit = 1, squaddie = 2, sergeant = 3, lieutenant = 4, captain = 5, colonel = 6}
        local rankA = rankOrder[a.rank or 'recruit'] or 0
        local rankB = rankOrder[b.rank or 'recruit'] or 0
        return rankA > rankB -- Higher rank first
    elseif self.sortBy == 'missions' then
        return (a.missions or 0) > (b.missions or 0) -- More missions first
    end
    return false
end

--- Set filter
-- @param filter Filter name
function RosterScreen:setFilter(filter)
    self.filterStatus = filter
    self.scrollOffset = 0
    self.selectedUnitIndex = nil
    self:_applyFiltersAndSort()
end

--- Set sort order
-- @param sortBy Sort field name
function RosterScreen:setSortBy(sortBy)
    self.sortBy = sortBy
    self:_applyFiltersAndSort()
end

--- Go back to previous screen
function RosterScreen:goBack()
    local screenManager = self.registry and self.registry:resolve('screen_manager')
    if screenManager then
        screenManager:popScreen()
    end
end

--- Equip selected unit
function RosterScreen:equipSelected()
    if not self.selectedUnitIndex then return end
    
    local unit = self.filteredUnits[self.selectedUnitIndex]
    if not unit then return end
    
    -- Navigate to equipment screen for this unit
    local screenManager = self.registry and self.registry:resolve('screen_manager')
    if screenManager then
        screenManager:pushScreen('equipment', {unitId = unit.id})
    end
end

--- Dismiss selected unit
function RosterScreen:dismissSelected()
    if not self.selectedUnitIndex then return end
    
    local unit = self.filteredUnits[self.selectedUnitIndex]
    if not unit then return end
    
    -- Show confirmation dialog
    -- TODO: Implement dialog widget
    local unitSystem = self.registry and self.registry:resolve('unit_system')
    if unitSystem and unitSystem.removeUnit then
        unitSystem:removeUnit(unit.id)
        self:_loadUnits()
        self.selectedUnitIndex = nil
    end
end

--- Update screen
-- @param dt Delta time
function RosterScreen:update(dt)
    -- Update widgets
    for _, widget in pairs(self.widgets) do
        if widget.update then
            widget:update(dt)
        end
    end
end

--- Draw screen
function RosterScreen:draw()
    -- Clear background
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle('fill', 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- Draw title panel
    self.widgets.titlePanel:draw()
    
    -- Draw filter buttons
    self.widgets.filterAll:draw()
    self.widgets.filterAvailable:draw()
    self.widgets.filterWounded:draw()
    self.widgets.filterTraining:draw()
    
    -- Draw sort buttons
    self.widgets.sortName:draw()
    self.widgets.sortRank:draw()
    self.widgets.sortMissions:draw()
    
    -- Draw unit list
    self:_drawUnitList()
    
    -- Draw bottom buttons
    self.widgets.btnBack:draw()
    self.widgets.btnEquip:draw()
    self.widgets.btnDismiss:draw()
    
    -- Draw unit count
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        string.format("Units: %d / %d", #self.filteredUnits, #self.allUnits),
        36 * GRID_SIZE, 27 * GRID_SIZE + 8
    )
end

--- Draw unit list
function RosterScreen:_drawUnitList()
    love.graphics.setScissor(0, self.listStartY, SCREEN_WIDTH, self.listHeight)
    
    local maxVisible = math.floor(self.listHeight / self.rowHeight)
    local startIndex = self.scrollOffset + 1
    local endIndex = math.min(startIndex + maxVisible - 1, #self.filteredUnits)
    
    for i = startIndex, endIndex do
        local unit = self.filteredUnits[i]
        local yPos = self.listStartY + (i - startIndex) * self.rowHeight
        
        -- Highlight selected
        if i == self.selectedUnitIndex then
            love.graphics.setColor(0.2, 0.3, 0.5)
            love.graphics.rectangle('fill', 0, yPos, SCREEN_WIDTH, self.rowHeight)
        end
        
        -- Draw unit info
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(unit.name or "Unknown", 2 * GRID_SIZE, yPos + 8)
        love.graphics.print(unit.rank or "Recruit", 12 * GRID_SIZE, yPos + 8)
        love.graphics.print(string.format("HP: %d/%d", unit.currentHealth or 0, unit.maxHealth or 100), 20 * GRID_SIZE, yPos + 8)
        love.graphics.print(string.format("Missions: %d", unit.missions or 0), 28 * GRID_SIZE, yPos + 8)
        
        -- Status indicator
        local status = unit.status or 'available'
        local statusColor = {available = {0, 1, 0}, wounded = {1, 0, 0}, training = {1, 1, 0}}
        love.graphics.setColor(statusColor[status] or {1, 1, 1})
        love.graphics.circle('fill', 1.5 * GRID_SIZE, yPos + GRID_SIZE, 6)
        
        -- Separator line
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.line(0, yPos + self.rowHeight, SCREEN_WIDTH, yPos + self.rowHeight)
    end
    
    love.graphics.setScissor()
end

--- Handle mouse press
-- @param x Mouse X
-- @param y Mouse Y
-- @param button Mouse button
function RosterScreen:mousepressed(x, y, button)
    if button ~= 1 then return end
    
    -- Check widgets
    for _, widget in pairs(self.widgets) do
        if widget.mousepressed and widget:mousepressed(x, y, button) then
            return
        end
    end
    
    -- Check unit list clicks
    if y >= self.listStartY and y < self.listStartY + self.listHeight then
        local clickedRow = math.floor((y - self.listStartY) / self.rowHeight)
        local unitIndex = self.scrollOffset + clickedRow + 1
        
        if unitIndex <= #self.filteredUnits then
            self.selectedUnitIndex = unitIndex
        end
    end
end

--- Handle key press
-- @param key Key name
function RosterScreen:keypressed(key)
    if key == 'escape' then
        self:goBack()
    elseif key == 'up' then
        if self.selectedUnitIndex and self.selectedUnitIndex > 1 then
            self.selectedUnitIndex = self.selectedUnitIndex - 1
            self:_ensureVisible(self.selectedUnitIndex)
        end
    elseif key == 'down' then
        if self.selectedUnitIndex and self.selectedUnitIndex < #self.filteredUnits then
            self.selectedUnitIndex = self.selectedUnitIndex + 1
            self:_ensureVisible(self.selectedUnitIndex)
        end
    elseif key == 'return' or key == 'space' then
        self:equipSelected()
    end
end

--- Ensure selected unit is visible
-- @param index Unit index
function RosterScreen:_ensureVisible(index)
    local maxVisible = math.floor(self.listHeight / self.rowHeight)
    
    if index < self.scrollOffset + 1 then
        self.scrollOffset = index - 1
    elseif index > self.scrollOffset + maxVisible then
        self.scrollOffset = index - maxVisible
    end
    
    self.scrollOffset = math.max(0, math.min(self.scrollOffset, #self.filteredUnits - maxVisible))
end

--- Handle mouse wheel
-- @param x Wheel X
-- @param y Wheel Y
function RosterScreen:wheelmoved(x, y)
    local maxVisible = math.floor(self.listHeight / self.rowHeight)
    local maxScroll = math.max(0, #self.filteredUnits - maxVisible)
    
    self.scrollOffset = self.scrollOffset - y
    self.scrollOffset = math.max(0, math.min(self.scrollOffset, maxScroll))
end

return RosterScreen
