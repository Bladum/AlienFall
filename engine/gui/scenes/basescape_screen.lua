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

local StateManager = require("core.state_manager")
local Widgets = require("gui.widgets.init")

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
    
    -- Facility grid (6x6)
    self.facilities = {}
    for y = 1, GRID_SIZE do
        self.facilities[y] = {}
        for x = 1, GRID_SIZE do
            self.facilities[y][x] = {type = "empty", built = true}
        end
    end
    
    -- Add starting facilities
    self.facilities[1][1] = {
        type = "command",
        name = "Command Center",
        built = true,
        upkeep = 50000
    }
    
    self.facilities[2][1] = {
        type = "quarters",
        name = "Living Quarters",
        built = true,
        upkeep = 10000,
        capacity = 10
    }
    
    self.facilities[3][1] = {
        type = "hangar",
        name = "Hangar",
        built = true,
        upkeep = 25000,
        capacity = 1
    }
    
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
    local startX = 200
    local startY = 100
    local rowHeight = 50
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    
    love.graphics.print("Available Research Projects:", startX, startY)
    
    -- Research list
    for i, project in ipairs(self.researchProjects) do
        local y = startY + 40 + (i - 1) * rowHeight
        
        love.graphics.print(project.name, startX, y)
        love.graphics.print("Days: " .. project.daysRequired, startX + 250, y)
        
        if project.active then
            love.graphics.setColor(0.2, 0.8, 0.2)
            love.graphics.print("IN PROGRESS", startX + 350, y)
            
            -- Progress bar
            love.graphics.setColor(0.3, 0.3, 0.4)
            love.graphics.rectangle("fill", startX, y + 20, 200, 10)
            love.graphics.setColor(0.2, 0.8, 0.2)
            local progress = (project.daysCompleted / project.daysRequired) * 200
            love.graphics.rectangle("fill", startX, y + 20, progress, 10)
        else
            love.graphics.setColor(0.6, 0.6, 0.6)
            love.graphics.print("Not Started", startX + 350, y)
        end
        
        love.graphics.setColor(1, 1, 1)
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
    
    if self.viewMode == "facilities" and self.hoveredCell then
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
    
    -- Base finances
    love.graphics.print("--- Monthly Budget ---", panelX, panelY + 100)
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.print("Income: $" .. self:formatNumber(self.base.monthlyIncome), panelX, panelY + 130)
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.print("Expenses: $" .. self:formatNumber(self.base.monthlyExpenses), panelX, panelY + 160)
    
    local balance = self.base.monthlyIncome - self.base.monthlyExpenses
    if balance >= 0 then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.print("Balance: +$" .. self:formatNumber(balance), panelX, panelY + 190)
    else
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.print("Balance: -$" .. self:formatNumber(math.abs(balance)), panelX, panelY + 190)
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
    
    if button == 1 and self.hoveredCell and self.viewMode == "facilities" then
        self.selectedCell = self.hoveredCell
        print("[Basescape] Selected cell: " .. self.hoveredCell.x .. ", " .. self.hoveredCell.y)
    end
end

function Basescape:mousereleased(x, y, button, istouch, presses)
    self.backButton:mousereleased(x, y, button)
    self.facilitiesButton:mousereleased(x, y, button)
    self.soldiersButton:mousereleased(x, y, button)
    self.researchButton:mousereleased(x, y, button)
    self.manufacturingButton:mousereleased(x, y, button)
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


























