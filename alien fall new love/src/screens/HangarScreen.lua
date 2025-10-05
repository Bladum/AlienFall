--- Hangar Screen
-- Displays available craft with equipment, armament, and soldier assignment
--
-- @classmod screens.HangarScreen

-- GROK: HangarScreen shows craft management and loadout configuration
-- GROK: Grid-aligned UI at 800x600 resolution using 20px grid system
-- GROK: Key methods: draw(), update(), mousepressed(), assignSoldiers()
-- GROK: Integrates with craft system, unit roster, and equipment

local class = require 'lib.Middleclass'
local Button = require 'widgets.Button'
local Panel = require 'widgets.Panel'

--- HangarScreen class
-- @type HangarScreen
local HangarScreen = class('HangarScreen')

-- Constants (20px grid system, 800x600 resolution)
local GRID_SIZE = 20
local SCREEN_WIDTH = 800
local SCREEN_HEIGHT = 600

--- Create a new HangarScreen
-- @param registry Service registry
-- @return HangarScreen instance
function HangarScreen:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    
    -- UI state
    self.selectedCraftIndex = 1
    self.crafts = {}
    
    -- Create UI widgets
    self:_createWidgets()
end

--- Create UI widgets
function HangarScreen:_createWidgets()
    self.widgets = {}
    
    -- Title
    self.widgets.titlePanel = Panel:new(
        0, 0,
        SCREEN_WIDTH,
        2 * GRID_SIZE,
        {title = "HANGAR", bordered = true}
    )
    
    -- Craft list panel (left side, 15 units wide)
    self.widgets.craftListPanel = Panel:new(
        1 * GRID_SIZE, 3 * GRID_SIZE,
        15 * GRID_SIZE, 23 * GRID_SIZE,
        {title = "CRAFT", bordered = true}
    )
    
    -- Craft details panel (right side)
    self.widgets.detailsPanel = Panel:new(
        17 * GRID_SIZE, 3 * GRID_SIZE,
        22 * GRID_SIZE, 23 * GRID_SIZE,
        {title = "CRAFT DETAILS", bordered = true}
    )
    
    -- Action buttons
    local btnY = 27 * GRID_SIZE
    self.widgets.btnBack = Button:new(
        1 * GRID_SIZE, btnY,
        8 * GRID_SIZE, 2 * GRID_SIZE,
        "BACK",
        function() self:goBack() end
    )
    
    self.widgets.btnAssignSoldiers = Button:new(
        10 * GRID_SIZE, btnY,
        12 * GRID_SIZE, 2 * GRID_SIZE,
        "ASSIGN SOLDIERS",
        function() self:assignSoldiers() end
    )
    
    self.widgets.btnEquipCraft = Button:new(
        23 * GRID_SIZE, btnY,
        10 * GRID_SIZE, 2 * GRID_SIZE,
        "EQUIP CRAFT",
        function() self:equipCraft() end
    )
end

--- Enter the screen
function HangarScreen:enter()
    self:_loadCrafts()
    self.selectedCraftIndex = 1
end

--- Load crafts from craft system
function HangarScreen:_loadCrafts()
    local geoscapeService = self.registry and self.registry:getService('geoscapeService')
    if geoscapeService and geoscapeService.getAllCrafts then
        self.crafts = geoscapeService:getAllCrafts() or {}
    else
        -- Fallback mock data
        self.crafts = {
            {id = "craft_1", name = "Skyranger-1", type = "skyranger", status = "ready", soldiers = {}, weapons = {}},
            {id = "craft_2", name = "Interceptor-1", type = "interceptor", status = "maintenance", soldiers = {}, weapons = {}}
        }
    end
end

--- Go back to previous screen
function HangarScreen:goBack()
    local screenManager = self.registry and self.registry:resolve('screen_manager')
    if screenManager then
        screenManager:popScreen()
    end
end

--- Assign soldiers to selected craft
function HangarScreen:assignSoldiers()
    if not self.crafts[self.selectedCraftIndex] then return end
    
    local craft = self.crafts[self.selectedCraftIndex]
    local screenManager = self.registry and self.registry:resolve('screen_manager')
    if screenManager then
        screenManager:pushScreen('soldier_assignment', {craftId = craft.id})
    end
end

--- Equip selected craft
function HangarScreen:equipCraft()
    if not self.crafts[self.selectedCraftIndex] then return end
    
    local craft = self.crafts[self.selectedCraftIndex]
    local screenManager = self.registry and self.registry:resolve('screen_manager')
    if screenManager then
        screenManager:pushScreen('craft_equipment', {craftId = craft.id})
    end
end

--- Update screen
-- @param dt Delta time
function HangarScreen:update(dt)
    for _, widget in pairs(self.widgets) do
        if widget.update then
            widget:update(dt)
        end
    end
end

--- Draw screen
function HangarScreen:draw()
    -- Clear background
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle('fill', 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- Draw panels
    self.widgets.titlePanel:draw()
    self.widgets.craftListPanel:draw()
    self.widgets.detailsPanel:draw()
    
    -- Draw craft list
    self:_drawCraftList()
    
    -- Draw craft details
    self:_drawCraftDetails()
    
    -- Draw buttons
    self.widgets.btnBack:draw()
    self.widgets.btnAssignSoldiers:draw()
    self.widgets.btnEquipCraft:draw()
end

--- Draw craft list
function HangarScreen:_drawCraftList()
    local listX = 2 * GRID_SIZE
    local listY = 5 * GRID_SIZE
    local rowHeight = 3 * GRID_SIZE
    
    for i, craft in ipairs(self.crafts) do
        local yPos = listY + (i - 1) * rowHeight
        
        -- Highlight selected
        if i == self.selectedCraftIndex then
            love.graphics.setColor(0.2, 0.3, 0.5)
            love.graphics.rectangle('fill', listX, yPos, 13 * GRID_SIZE, rowHeight)
        end
        
        -- Status indicator
        local statusColors = {
            ready = {0, 1, 0},
            out = {1, 1, 0},
            maintenance = {1, 0.5, 0},
            damaged = {1, 0, 0}
        }
        love.graphics.setColor(statusColors[craft.status] or {0.5, 0.5, 0.5})
        love.graphics.circle('fill', listX + 8, yPos + GRID_SIZE, 6)
        
        -- Craft name
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(craft.name, listX + 20, yPos + 8)
        love.graphics.print(craft.type or "Unknown", listX + 20, yPos + 28)
        
        -- Soldier count
        local soldierCount = craft.soldiers and #craft.soldiers or 0
        love.graphics.print(string.format("%d soldiers", soldierCount), listX + 20, yPos + 48)
    end
end

--- Draw craft details
function HangarScreen:_drawCraftDetails()
    if not self.crafts[self.selectedCraftIndex] then return end
    
    local craft = self.crafts[self.selectedCraftIndex]
    local detailX = 18 * GRID_SIZE
    local detailY = 5 * GRID_SIZE
    local lineHeight = GRID_SIZE
    
    love.graphics.setColor(1, 1, 1)
    
    -- Craft name
    love.graphics.print("Name: " .. craft.name, detailX, detailY)
    detailY = detailY + lineHeight * 2
    
    -- Craft type
    love.graphics.print("Type: " .. (craft.type or "Unknown"), detailX, detailY)
    detailY = detailY + lineHeight * 1.5
    
    -- Status
    love.graphics.print("Status: " .. (craft.status or "Unknown"), detailX, detailY)
    detailY = detailY + lineHeight * 2
    
    -- Stats
    love.graphics.print("--- STATISTICS ---", detailX, detailY)
    detailY = detailY + lineHeight * 1.5
    
    love.graphics.print(string.format("Speed: %d", craft.speed or 0), detailX, detailY)
    detailY = detailY + lineHeight
    
    love.graphics.print(string.format("Range: %d km", craft.range or 0), detailX, detailY)
    detailY = detailY + lineHeight
    
    love.graphics.print(string.format("Fuel: %.0f%%", (craft.fuel or 100)), detailX, detailY)
    detailY = detailY + lineHeight
    
    love.graphics.print(string.format("Capacity: %d", craft.capacity or 0), detailX, detailY)
    detailY = detailY + lineHeight * 2
    
    -- Soldiers
    love.graphics.print("--- SOLDIERS ---", detailX, detailY)
    detailY = detailY + lineHeight * 1.5
    
    if craft.soldiers and #craft.soldiers > 0 then
        for _, soldier in ipairs(craft.soldiers) do
            love.graphics.print("• " .. (soldier.name or "Unknown"), detailX, detailY)
            detailY = detailY + lineHeight
        end
    else
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.print("No soldiers assigned", detailX, detailY)
        detailY = detailY + lineHeight
    end
    
    detailY = detailY + lineHeight
    
    -- Weapons
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("--- WEAPONS ---", detailX, detailY)
    detailY = detailY + lineHeight * 1.5
    
    if craft.weapons and #craft.weapons > 0 then
        for _, weapon in ipairs(craft.weapons) do
            love.graphics.print("• " .. (weapon.name or weapon.id or "Unknown"), detailX, detailY)
            detailY = detailY + lineHeight
        end
    else
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.print("No weapons equipped", detailX, detailY)
    end
end

--- Handle mouse press
-- @param x Mouse X
-- @param y Mouse Y
-- @param button Mouse button
function HangarScreen:mousepressed(x, y, button)
    if button ~= 1 then return end
    
    -- Check widgets
    for _, widget in pairs(self.widgets) do
        if widget.mousepressed and widget:mousepressed(x, y, button) then
            return
        end
    end
    
    -- Check craft list clicks
    local listX = 2 * GRID_SIZE
    local listY = 5 * GRID_SIZE
    local listWidth = 13 * GRID_SIZE
    local rowHeight = 3 * GRID_SIZE
    
    if x >= listX and x < listX + listWidth then
        for i, _ in ipairs(self.crafts) do
            local yPos = listY + (i - 1) * rowHeight
            if y >= yPos and y < yPos + rowHeight then
                self.selectedCraftIndex = i
                break
            end
        end
    end
end

--- Handle key press
-- @param key Key name
function HangarScreen:keypressed(key)
    if key == 'escape' then
        self:goBack()
    elseif key == 'up' then
        if self.selectedCraftIndex > 1 then
            self.selectedCraftIndex = self.selectedCraftIndex - 1
        end
    elseif key == 'down' then
        if self.selectedCraftIndex < #self.crafts then
            self.selectedCraftIndex = self.selectedCraftIndex + 1
        end
    elseif key == 'return' then
        self:assignSoldiers()
    elseif key == 'e' then
        self:equipCraft()
    end
end

return HangarScreen
