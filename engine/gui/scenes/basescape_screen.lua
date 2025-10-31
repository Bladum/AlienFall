---Basescape Screen - Base Management
---
---Base management interface for XCOM operations. Provides facilities management,
---personnel assignment, research tracking, manufacturing controls, and resource
---management. Features a grid-based facility layout with interactive elements.
---
---Key Features:
---  - Facility construction and management
---  - Personnel assignment (soldiers, scientists, engineers)
---  - Research project tracking and queue
---  - Manufacturing queue and production
---  - Resource management (supplies, credits)
---  - Base defense preparation
---
---View Modes:
---  - facilities: Build and manage base facilities
---  - soldiers: Assign and manage soldier roster
---  - research: Select and track research projects
---  - manufacturing: Queue production items
---  - market: Buy and sell equipment
---
---Key Exports:
---  - Basescape:enter(): Initializes base interface
---  - Basescape:update(dt): Updates timers and production
---  - Basescape:draw(): Renders base layout and UI
---  - Basescape:mousepressed(x, y, button): Handles facility selection
---  - Basescape:keypressed(key): Switches view modes
---
---Dependencies:
---  - basescape.facilities.*: Facility system and types
---  - economy.research.research_system: Research management
---  - economy.production.manufacturing_system: Manufacturing
---  - shared.units.units: Unit roster management
---  - widgets.init: Base management UI widgets
---
---@module scenes.basescape_screen
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- Registered automatically in main.lua
---  StateManager.register("basescape", Basescape)
---  StateManager.switch("basescape")
---
---@see basescape.facilities For facility system
---@see economy.research For research management
---@see scenes.geoscape_screen For returning to world map

-- Basescape State
-- Base management with facilities, personnel, research, and manufacturing

local StateManager = require("core.state.state_manager")
local Widgets = require("gui.widgets.init")
local FacilityGridUI = require("basescape.ui.facility_grid_ui")
local ConstructionInterfaceUI = require("basescape.ui.construction_interface_ui")
local PowerManagementUI = require("basescape.ui.power_management_ui")
local ResearchQueueUI = require("basescape.ui.research_queue_ui")
local TechnologyTreeUI = require("basescape.ui.technology_tree_ui")

local Basescape = {}

-- Constants
local GRID_SIZE = 6
local CELL_SIZE = 80

function Basescape:enter()
    print("[Basescape] Entering basescape state")

    -- Initialize base data
    self:initBase()

    -- Current view mode
    self.viewMode = "facilities" -- facilities, soldiers, research, manufacturing
    self.researchSubMode = "queue" -- queue, tree (for research view)

    -- Selected facility/item
    self.selectedCell = nil
    self.hoveredCell = nil

    -- UI elements (grid-aligned: positions should be multiples of 24)
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    self.backButton = Widgets.Button.new(24, 24, 120, 48, "BACK")
    self.backButton.onClick = function()
        StateManager.switch("menu")
    end

    -- View mode buttons
    local btnY = 72
    local btnSpacing = 60

    self.facilitiesButton = Widgets.Button.new(24, btnY, 150, 48, "FACILITIES")
    self.facilitiesButton.onClick = function()
        self.viewMode = "facilities"
    end

    self.soldiersButton = Widgets.Button.new(24, btnY + btnSpacing, 150, 48, "SOLDIERS")
    self.soldiersButton.onClick = function()
        self.viewMode = "soldiers"
    end

    self.researchButton = Widgets.Button.new(24, btnY + btnSpacing * 2, 150, 48, "RESEARCH")
    self.researchButton.onClick = function()
        self.viewMode = "research"
    end

    self.manufacturingButton = Widgets.Button.new(24, btnY + btnSpacing * 3, 150, 48, "MANUFACTURING")
    self.manufacturingButton.onClick = function()
        self.viewMode = "manufacturing"
    end

    -- Info panel (grid-aligned position)
    self.infoPanel = Widgets.FrameBox.new(
        math.floor((windowWidth - 360) / 24) * 24,  -- Snap to grid
        72,  -- Already grid-aligned
        360,  -- 15 grid cells
        504,  -- 21 grid cells
        "Details"
    )

    -- Initialize facility grid UI
    self.facilityGridUI = FacilityGridUI:new(self.base, GRID_SIZE)
    self.facilityGridUI.onFacilitySelected = function(facility, x, y)
        self:onFacilitySelected(facility, x, y)
    end
    self.facilityGridUI.onCellClicked = function(x, y)
        self:onCellClicked(x, y)
    end

    -- Initialize construction interface UI
    self.constructionUI = ConstructionInterfaceUI:new(self.base)
    self.constructionUI.onFacilitySelected = function(facilityType)
        self:onConstructionFacilitySelected(facilityType)
    end
    self.constructionUI.onConstructionComplete = function(facilityType)
        self:onConstructionComplete(facilityType)
    end

    -- Initialize power management UI
    self.powerUI = PowerManagementUI:new(self.base, self.facilityGridUI)

    -- Initialize research queue UI
    self.researchQueueUI = ResearchQueueUI:new(self.base)
    self.researchQueueUI.onProjectQueued = function(projectId)
        self:onResearchProjectQueued(projectId)
    end
    self.researchQueueUI.onProjectDequeued = function(projectId)
        self:onResearchProjectDequeued(projectId)
    end
    self.researchQueueUI.onAllocationChanged = function(allocation)
        self:onScientistAllocationChanged(allocation)
    end

    -- Initialize technology tree UI
    self.technologyTreeUI = TechnologyTreeUI:new(self.base)
    self.technologyTreeUI.onTechSelected = function(techId)
        self:onTechnologySelected(techId)
    end
end

--- Clean up the basescape state.
--- Removes all widgets and frees resources when leaving base management.
---
--- @return nil
function Basescape:exit()
    print("[Basescape] Exiting basescape state")
end

--- Initialize base data and configuration.
--- Sets up the XCOM base with default facilities, resources, and personnel.
---
--- @return nil
function Basescape:initBase()
    -- Base resources
    self.base = {
        name = "Alien Fall Base Alpha",
        funds = 1000000,
        monthlyIncome = 500000,
        monthlyExpenses = 150000
    }

    -- Facility grid (6x6) - initialize as part of base
    self.base.facilities = {}
    for y = 1, GRID_SIZE do
        self.base.facilities[y] = {}
        for x = 1, GRID_SIZE do
            self.base.facilities[y][x] = {
                type = "empty",
                built = true,
                level = 0,
                condition = 100
            }
        end
    end

    -- Add starting facilities
    self.base.facilities[1][1] = {
        type = "command",
        name = "Command Center",
        built = true,
        level = 1,
        condition = 100,
        upkeep = 50000
    }

    self.base.facilities[2][1] = {
        type = "quarters",
        name = "Living Quarters",
        built = true,
        level = 1,
        condition = 100,
        upkeep = 10000,
        capacity = 10
    }

    self.base.facilities[3][1] = {
        type = "hangar",
        name = "Hangar",
        built = true,
        level = 1,
        condition = 100,
        upkeep = 25000,
        capacity = 1
    }

    -- Keep old facilities array for backward compatibility
    self.facilities = self.base.facilities

    -- Personnel
    self.soldiers = {
        {name = "John Smith", health = 50, accuracy = 70, rank = "Rookie", salary = 20000},
        {name = "Jane Doe", health = 55, accuracy = 75, rank = "Rookie", salary = 20000},
        {name = "Bob Johnson", health = 48, accuracy = 68, rank = "Rookie", salary = 20000},
        {name = "Alice Williams", health = 52, accuracy = 72, rank = "Rookie", salary = 20000}
    }

    self.scientists = 2
    self.engineers = 2

    -- Research projects
    self.researchProjects = {
        {name = "Laser Weapons", daysRequired = 20, daysCompleted = 0, active = false},
        {name = "Personal Armor", daysRequired = 15, daysCompleted = 0, active = false},
        {name = "Advanced Radar", daysRequired = 10, daysCompleted = 0, active = false}
    }

    -- Manufacturing queue
    self.manufacturingQueue = {}
end

--- Callback when a facility is selected in the grid
---@param facility table Facility data
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
function Basescape:onFacilitySelected(facility, x, y)
    self.selectedCell = {x = x, y = y}
    print(string.format("[Basescape] Selected facility at %d,%d: %s", x, y, facility.type))
end

--- Callback when a cell is clicked in the grid
---@param x number Grid X coordinate
---@param y number Grid Y coordinate
function Basescape:onCellClicked(x, y)
    self.selectedCell = {x = x, y = y}
    print(string.format("[Basescape] Clicked cell at %d,%d", x, y))
end

--- Callback when a facility is selected in the construction interface
---@param facilityType string Type of facility selected
function Basescape:onConstructionFacilitySelected(facilityType)
    print(string.format("[Basescape] Construction facility selected: %s", facilityType))
    -- Enable construction mode in facility grid
    if self.facilityGridUI then
        self.facilityGridUI:setConstructionMode(true)
        self.facilityGridUI.selectedFacilityType = facilityType
    end
end

--- Callback when construction is completed
---@param facilityType string Type of facility completed
function Basescape:onConstructionComplete(facilityType)
    print(string.format("[Basescape] Construction completed: %s", facilityType))
    -- Update base facilities and refresh UI
    if self.facilityGridUI then
        self.facilityGridUI:setBase(self.base)
    end
    if self.constructionUI then
        self.constructionUI:setBase(self.base)
    end
end

--- Callback when a research project is queued
---@param projectId string Project identifier
function Basescape:onResearchProjectQueued(projectId)
    print(string.format("[Basescape] Research project queued: %s", projectId))
    -- Update research projects and refresh UI
    if self.researchQueueUI then
        self.researchQueueUI:updateAvailableProjects()
    end
end

--- Callback when a research project is dequeued
---@param projectId string Project identifier
function Basescape:onResearchProjectDequeued(projectId)
    print(string.format("[Basescape] Research project dequeued: %s", projectId))
    -- Update research projects and refresh UI
    if self.researchQueueUI then
        self.researchQueueUI:updateAvailableProjects()
    end
end

--- Callback when scientist allocation changes
---@param allocation number Number of scientists allocated
function Basescape:onScientistAllocationChanged(allocation)
    print(string.format("[Basescape] Scientist allocation changed to: %d", allocation))
    -- Update scientist count
    self.scientists = allocation
end

--- Callback when a technology is selected in the tree
---@param techId string Technology identifier
function Basescape:onTechnologySelected(techId)
    print(string.format("[Basescape] Technology selected: %s", techId))
    -- Could trigger research project creation or show details
end

--- Update the basescape state.
--- Handles button animations and UI updates each frame.
---
--- @param dt number Delta time since last update in seconds
--- @return nil
function Basescape:update(dt)
    -- Update UI buttons
    self.backButton:update(dt)
    self.facilitiesButton:update(dt)
    self.soldiersButton:update(dt)
    self.researchButton:update(dt)
    self.manufacturingButton:update(dt)

    -- Update facility grid UI
    if self.facilityGridUI then
        self.facilityGridUI:update(dt)
    end

    -- Update construction UI
    if self.constructionUI then
        self.constructionUI:update(dt)
    end

    -- Update power UI
    if self.powerUI then
        self.powerUI:setBase(self.base, self.facilityGridUI)
    end

    -- Update research queue UI
    if self.researchQueueUI then
        self.researchQueueUI:update(dt)
    end

    -- Update technology tree UI
    if self.technologyTreeUI then
        self.technologyTreeUI:update(dt)
    end

    -- Calculate hovered cell for facilities view
    if self.viewMode == "facilities" then
        local mx, my = love.mouse.getPosition()
        local gridStartX = 200
        local gridStartY = 100

        local cellX = math.floor((mx - gridStartX) / CELL_SIZE) + 1
        local cellY = math.floor((my - gridStartY) / CELL_SIZE) + 1

        if cellX >= 1 and cellX <= GRID_SIZE and cellY >= 1 and cellY <= GRID_SIZE then
            self.hoveredCell = {x = cellX, y = cellY}
        else
            self.hoveredCell = nil
        end
    end
end

--- Render the basescape interface.
--- Draws the base management screen with current view mode and UI elements.
---
--- @return nil
function Basescape:draw()
    -- Clear background
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Draw UI buttons
    self.backButton:draw()

    -- Draw view mode buttons (widgets handle their own styling)
    self.facilitiesButton:draw()
    self.soldiersButton:draw()
    self.researchButton:draw()
    self.manufacturingButton:draw()

    -- Draw view-specific content
    if self.viewMode == "facilities" then
        self:drawFacilitiesView()
    elseif self.viewMode == "soldiers" then
        self:drawSoldiersView()
    elseif self.viewMode == "research" then
        self:drawResearchView()
    elseif self.viewMode == "manufacturing" then
        self:drawManufacturingView()
    end

    -- Draw info panel
    self.infoPanel:draw()
    self:drawInfoPanel()

    -- Draw base status at top
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print(self.base.name, 200, 20)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Funds: $" .. self:formatNumber(self.base.funds), 200, 45)
    love.graphics.print("Scientists: " .. self.scientists .. " | Engineers: " .. self.engineers, 450, 45)
end

function Basescape:drawFacilitiesView()
    -- Draw facility grid using the new UI component
    if self.facilityGridUI then
        self.facilityGridUI:draw()
    else
        -- Fallback to old implementation if UI component fails to load
        self:drawFacilitiesViewFallback()
    end

    -- Draw construction interface
    if self.constructionUI then
        self.constructionUI:draw()
    end

    -- Draw power management interface
    if self.powerUI then
        self.powerUI:draw()
    end
end

function Basescape:drawFacilitiesViewFallback()
    local gridStartX = 200
    local gridStartY = 100

    -- Draw facility grid
    for y = 1, GRID_SIZE do
        for x = 1, GRID_SIZE do
            local facility = self.facilities[y][x]
            local screenX = gridStartX + (x - 1) * CELL_SIZE
            local screenY = gridStartY + (y - 1) * CELL_SIZE

            -- Determine color based on facility type
            local color
            if facility.type == "empty" then
                color = {0.15, 0.15, 0.2}
            elseif facility.type == "command" then
                color = {0.3, 0.5, 0.7}
            elseif facility.type == "quarters" then
                color = {0.4, 0.6, 0.3}
            elseif facility.type == "hangar" then
                color = {0.6, 0.5, 0.3}
            elseif facility.type == "laboratory" then
                color = {0.5, 0.3, 0.7}
            elseif facility.type == "workshop" then
                color = {0.7, 0.4, 0.3}
            else
                color = {0.3, 0.3, 0.4}
            end

            love.graphics.setColor(color)
            love.graphics.rectangle("fill", screenX, screenY, CELL_SIZE - 2, CELL_SIZE - 2)

            -- Highlight hovered cell
            if self.hoveredCell and self.hoveredCell.x == x and self.hoveredCell.y == y then
                love.graphics.setColor(1, 1, 0, 0.3)
                love.graphics.rectangle("fill", screenX, screenY, CELL_SIZE - 2, CELL_SIZE - 2)
            end

            -- Draw border
            love.graphics.setColor(0.5, 0.5, 0.6)
            love.graphics.rectangle("line", screenX, screenY, CELL_SIZE - 2, CELL_SIZE - 2)

            -- Draw facility name (abbreviated)
            if facility.type ~= "empty" then
                love.graphics.setColor(1, 1, 1)
                love.graphics.setFont(love.graphics.newFont(10))
                local abbrev = self:abbreviateFacility(facility.type)
                love.graphics.print(abbrev, screenX + 5, screenY + CELL_SIZE / 2 - 5)
            end
        end
    end
end

function Basescape:drawSoldiersView()
    local startX = 200
    local startY = 100
    local rowHeight = 40

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))

    -- Header
    love.graphics.print("Name", startX, startY)
    love.graphics.print("Health", startX + 150, startY)
    love.graphics.print("Accuracy", startX + 250, startY)
    love.graphics.print("Rank", startX + 350, startY)

    -- Soldier list
    for i, soldier in ipairs(self.soldiers) do
        local y = startY + 30 + (i - 1) * rowHeight
        love.graphics.print(soldier.name, startX, y)
        love.graphics.print(soldier.health, startX + 150, y)
        love.graphics.print(soldier.accuracy .. "%", startX + 250, y)
        love.graphics.print(soldier.rank, startX + 350, y)
    end
end

function Basescape:drawResearchView()
    -- Draw research sub-mode toggle buttons
    self:drawResearchSubModeButtons()

    -- Draw the selected research sub-view
    if self.researchSubMode == "queue" then
        self:drawResearchQueueView()
    elseif self.researchSubMode == "tree" then
        self:drawResearchTreeView()
    end
end

function Basescape:drawResearchSubModeButtons()
    local buttonY = 100
    local buttonWidth = 120
    local buttonHeight = 40
    local buttonSpacing = 10

    -- Queue View Button
    local queueX = 200
    self:drawSubModeButton("QUEUE", queueX, buttonY, buttonWidth, buttonHeight, self.researchSubMode == "queue")

    -- Tree View Button
    local treeX = queueX + buttonWidth + buttonSpacing
    self:drawSubModeButton("TREE", treeX, buttonY, buttonWidth, buttonHeight, self.researchSubMode == "tree")
end

function Basescape:drawSubModeButton(label, x, y, width, height, isSelected)
    local isHovered = self:isButtonHovered(x, y, width, height)

    -- Button background
    if isSelected then
        love.graphics.setColor(0.3, 0.5, 0.7, 0.9)
    elseif isHovered then
        love.graphics.setColor(0.2, 0.3, 0.4, 0.8)
    else
        love.graphics.setColor(0.15, 0.2, 0.3, 0.7)
    end

    love.graphics.rectangle("fill", x, y, width, height)

    -- Button border
    love.graphics.setColor(0.4, 0.5, 0.6, 0.9)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)

    -- Button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    local textWidth = love.graphics.getFont():getWidth(label)
    love.graphics.print(label, x + (width - textWidth) / 2, y + 12)
end

function Basescape:drawResearchQueueView()
    -- Draw research queue using the new UI component
    if self.researchQueueUI then
        self.researchQueueUI:draw()
    else
        -- Fallback to old implementation if UI component fails to load
        self:drawResearchViewFallback()
    end
end

function Basescape:drawResearchTreeView()
    -- Draw technology tree using the new UI component
    if self.technologyTreeUI then
        self.technologyTreeUI:draw()
    else
        -- Fallback message
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.print("Technology Tree UI not available", 300, 200)
    end
end

function Basescape:drawManufacturingView()
    local startX = 200
    local startY = 100

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))

    love.graphics.print("Manufacturing Queue:", startX, startY)

    if #self.manufacturingQueue == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.print("No items in queue", startX, startY + 40)
    else
        -- Draw manufacturing items
        for i, item in ipairs(self.manufacturingQueue) do
            local y = startY + 40 + (i - 1) * 40
            love.graphics.print(item.name .. " x" .. item.quantity, startX, y)
        end
    end
end

function Basescape:drawInfoPanel()
    local panelX = self.infoPanel.x + 10
    local panelY = self.infoPanel.y + 35

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))

    if self.viewMode == "facilities" then
        if self.facilityGridUI and self.selectedCell then
            -- Use new facility grid UI for detailed information
            local facilityInfo = self.facilityGridUI:getFacilityInfo(self.selectedCell.x, self.selectedCell.y)

            love.graphics.print(facilityInfo.name, panelX, panelY)
            love.graphics.print(facilityInfo.description, panelX, panelY + 25)

            if facilityInfo.level then
                love.graphics.print("Level: " .. facilityInfo.level, panelX, panelY + 50)
            end

            if facilityInfo.condition then
                love.graphics.print("Condition: " .. facilityInfo.condition .. "%", panelX, panelY + 75)
            end

            -- Show adjacency bonuses
            if #facilityInfo.adjacencyBonuses > 0 then
                love.graphics.print("Adjacency Bonuses:", panelX, panelY + 100)
                for i, bonus in ipairs(facilityInfo.adjacencyBonuses) do
                    local bonusY = panelY + 120 + (i-1) * 20
                    love.graphics.print("• " .. bonus.description, panelX + 10, bonusY)
                end
            end

            -- Show power status
            local powerData = facilityInfo.powerData
            if powerData.status == "full_power" then
                love.graphics.setColor(0.2, 0.8, 0.2)
                love.graphics.print("Power: Full", panelX, panelY + 200)
            elseif powerData.status == "low_power" then
                love.graphics.setColor(0.8, 0.6, 0.2)
                love.graphics.print("Power: Low", panelX, panelY + 200)
            else
                love.graphics.setColor(0.8, 0.2, 0.2)
                love.graphics.print("Power: None", panelX, panelY + 200)
            end

        elseif self.hoveredCell then
            -- Fallback to old system
            local facility = self.facilities[self.hoveredCell.y][self.hoveredCell.x]

            if facility.type == "empty" then
                love.graphics.print("Empty Slot", panelX, panelY)
                love.graphics.print("Click to build a facility", panelX, panelY + 30)
            else
                love.graphics.print(facility.name or "Facility", panelX, panelY)
                love.graphics.print("Upkeep: $" .. self:formatNumber(facility.upkeep or 0), panelX, panelY + 30)
                if facility.capacity then
                    love.graphics.print("Capacity: " .. facility.capacity, panelX, panelY + 60)
                end
            end
        else
            love.graphics.print("Hover over a facility", panelX, panelY)
            love.graphics.print("to see details", panelX, panelY + 25)
        end

    elseif self.viewMode == "soldiers" then
        love.graphics.print("Total Soldiers: " .. #self.soldiers, panelX, panelY)
        love.graphics.print("Monthly Salaries: $" .. self:formatNumber(#self.soldiers * 20000), panelX, panelY + 30)
    elseif self.viewMode == "research" then
        love.graphics.print("Scientists: " .. self.scientists, panelX, panelY)
        love.graphics.print("Active Projects: " .. self:countActiveResearch(), panelX, panelY + 30)
    elseif self.viewMode == "manufacturing" then
        love.graphics.print("Engineers: " .. self.engineers, panelX, panelY)
        love.graphics.print("Queue Items: " .. #self.manufacturingQueue, panelX, panelY + 30)
    end

    -- Base finances (always shown)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("--- Monthly Budget ---", panelX, panelY + 250)
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.print("Income: $" .. self:formatNumber(self.base.monthlyIncome), panelX, panelY + 280)
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.print("Expenses: $" .. self:formatNumber(self.base.monthlyExpenses), panelX, panelY + 300)

    local balance = self.base.monthlyIncome - self.base.monthlyExpenses
    if balance >= 0 then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.print("Balance: +$" .. self:formatNumber(balance), panelX, panelY + 330)
    else
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.print("Balance: -$" .. self:formatNumber(math.abs(balance)), panelX, panelY + 330)
    end
end

function Basescape:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        StateManager.switch("menu")
    elseif key == "1" then
        self.viewMode = "facilities"
    elseif key == "2" then
        self.viewMode = "soldiers"
    elseif key == "3" then
        self.viewMode = "research"
    elseif key == "4" then
        self.viewMode = "manufacturing"
    end
end

function Basescape:mousepressed(x, y, button, istouch, presses)
    self.backButton:mousepressed(x, y, button)
    self.facilitiesButton:mousepressed(x, y, button)
    self.soldiersButton:mousepressed(x, y, button)
    self.researchButton:mousepressed(x, y, button)
    self.manufacturingButton:mousepressed(x, y, button)

    -- Handle facility grid interactions
    if self.viewMode == "facilities" and self.facilityGridUI then
        self.facilityGridUI:mousepressed(x, y, button)
    elseif button == 1 and self.hoveredCell and self.viewMode == "facilities" then
        -- Fallback for old system
        self.selectedCell = self.hoveredCell
        print("[Basescape] Selected cell: " .. self.hoveredCell.x .. ", " .. self.hoveredCell.y)
    end

    -- Handle construction interface interactions
    if self.viewMode == "facilities" and self.constructionUI then
        self.constructionUI:mousepressed(x, y, button)
    end

    -- Handle power management interactions
    if self.viewMode == "facilities" and self.powerUI then
        self.powerUI:mousepressed(x, y, button)
    end

    -- Handle research queue interactions
    if self.viewMode == "research" and self.researchQueueUI then
        self.researchQueueUI:mousepressed(x, y, button)
    end

    -- Handle research sub-mode button clicks
    if self.viewMode == "research" and button == 1 then
        local buttonY = 100
        local buttonWidth = 120
        local buttonHeight = 40
        local buttonSpacing = 10
        local queueX = 200
        local treeX = queueX + buttonWidth + buttonSpacing

        if self:isButtonHovered(queueX, buttonY, buttonWidth, buttonHeight) then
            self.researchSubMode = "queue"
            return
        elseif self:isButtonHovered(treeX, buttonY, buttonWidth, buttonHeight) then
            self.researchSubMode = "tree"
            return
        end
    end

    -- Handle technology tree interactions
    if self.viewMode == "research" and self.researchSubMode == "tree" and self.technologyTreeUI then
        self.technologyTreeUI:mousepressed(x, y, button)
    end
end

function Basescape:mousereleased(x, y, button, istouch, presses)
    self.backButton:mousereleased(x, y, button)
    self.facilitiesButton:mousereleased(x, y, button)
    self.soldiersButton:mousereleased(x, y, button)
    self.researchButton:mousereleased(x, y, button)
    self.manufacturingButton:mousereleased(x, y, button)

    -- Handle technology tree mouse release
    if self.viewMode == "research" and self.researchSubMode == "tree" and self.technologyTreeUI then
        self.technologyTreeUI:mousereleased(x, y, button)
    end
end

function Basescape:mousemoved(x, y, dx, dy, istouch)
    -- Handle mouse movement for technology tree panning
    if self.viewMode == "research" and self.researchSubMode == "tree" and self.technologyTreeUI then
        self.technologyTreeUI:mousemoved(x, y, dx, dy)
    end
end

function Basescape:wheelmoved(x, y)
    -- Handle mouse wheel for construction interface scrolling
    if self.viewMode == "facilities" and self.constructionUI then
        self.constructionUI:mousewheel(x, y)
    end

    -- Handle mouse wheel for research queue scrolling
    if self.viewMode == "research" and self.researchSubMode == "queue" and self.researchQueueUI then
        self.researchQueueUI:mousewheel(x, y)
    end

    -- Handle mouse wheel for technology tree zooming
    if self.viewMode == "research" and self.researchSubMode == "tree" and self.technologyTreeUI then
        self.technologyTreeUI:mousewheel(x, y)
    end
end

-- Helper: Check if a button is hovered
function Basescape:isButtonHovered(x, y, width, height)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x + width and my >= y and my <= y + height
end

-- Helper: Abbreviate facility type
function Basescape:abbreviateFacility(type)
    local abbrevs = {
        command = "CMD",
        quarters = "QUARTERS",
        hangar = "HANGAR",
        laboratory = "LAB",
        workshop = "SHOP",
        storage = "STORAGE"
    }
    return abbrevs[type] or type:upper()
end

-- Helper: Count active research projects
function Basescape:countActiveResearch()
    local count = 0
    for _, project in ipairs(self.researchProjects) do
        if project.active then
            count = count + 1
        end
    end
    return count
end

-- Helper: Format large numbers with commas
function Basescape:formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

return Basescape
