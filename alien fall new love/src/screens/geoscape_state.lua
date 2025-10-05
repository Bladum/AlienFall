local BaseState = require "screens.base_state"
local Button = require "widgets.Button"
local Combobox = require "widgets.ComboBox"
local MapRenderer = require "src.geoscape.map_renderer"

--- Geoscape game state for strategic gameplay, managing bases, world map, and global operations.
-- @class GeoscapeState
-- @field turnManager TurnManager Game turn management system
-- @field rng RNG Random number generator
-- @field world table World state data (day, month, year)
-- @field dateFont love.Font Font for date display
-- @field buttonFont love.Font Font for button text
-- @field funding number Current game funding/currency
-- @field panicLevel number Global panic level
-- @field upperPanelButtons table Array of command buttons (Base, Research, etc.)
-- @field worldCombobox Combobox World selection dropdown
-- @field dateWidget table Date display widget
-- @field moneyWidget table Money/funding display widget
-- @field menuButton Button Main menu button
-- @field turnButton Button End turn button
-- @field mapView table World map view settings
-- @field selectedWorld string Currently selected world
local GeoscapeState = {}
GeoscapeState.__index = GeoscapeState
setmetatable(GeoscapeState, { __index = BaseState })

--- Grid size constant for UI layout (20 pixels per grid unit).
local GRID_SIZE = 20

--- Number of grid columns in the game window.
local GRID_COLS = 40

--- Number of grid rows in the game window.
local GRID_ROWS = 30

--- Creates a new GeoscapeState instance.
-- @param registry table Service registry for dependency injection
-- @return GeoscapeState A new geoscape state instance
-- @usage local geoscape = GeoscapeState.new(registry)
function GeoscapeState.new(registry)
    local self = BaseState.new({
        name = "geoscape",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, GeoscapeState)

    self.turnManager = registry and registry:resolve("turn_manager") or nil
    self.rng = registry and registry:resolve("rng") or nil
    self.world = {
        day = 1,
        month = 1,
        year = 2047
    }
    self.dateFont = love.graphics.newFont(14)   -- Smaller
    self.buttonFont = love.graphics.newFont(12) -- For buttons, 2 points smaller

    -- Status displays
    self.funding = 50000  -- Starting funding
    self.panicLevel = 0   -- Global panic

    -- World map and selection system
    self.currentWorld = nil  -- Current world instance
    self.selectedBase = nil  -- Currently selected base province
    self.selectedCraft = nil -- Currently selected craft
    self.radarRangeDisplay = nil  -- Provinces in radar range
    self.craftRangeDisplay = nil  -- Provinces in craft range
    self.showRadarRanges = false  -- Whether to show radar range circles
    self.showCraftRanges = false  -- Whether to show craft range highlights
    
    -- Craft management
    self.baseCrafts = {}  -- base_id -> {craft_id -> craft_instance}
    self.craftSpeedPoints = {}  -- craft_id -> remaining speed points this turn
    
    -- Craft info display
    self.craftInfoPanel = nil  -- Panel showing selected craft details

    -- World map display area (below upper panel)
    self.mapArea = {
        x = 0,
        y = 2 * GRID_SIZE,  -- Below upper panel (2 tiles)
        width = GRID_COLS * GRID_SIZE,
        height = (GRID_ROWS - 2) * GRID_SIZE
    }

    -- Upper panel layout (exactly on screen edge)
    self.upperPanelButtons = {}
    
    -- 8 buttons, each 2x2 tiles (40x40 pixels), positioned on screen edge
    local buttonLabels = {"Base", "Research", "Manufacture", "Intercept", "Diplomacy", "Reports", "Options", "Save"}
    local buttonActions = {
        function() self.stack:push("basescape", {}) end,  -- Base
        function() print("Research clicked") end,       -- Research
        function() print("Manufacture clicked") end,    -- Manufacture  
        function() self.stack:push("interception", {}) end, -- Intercept
        function() print("Diplomacy clicked") end,      -- Diplomacy
        function() print("Reports clicked") end,        -- Reports
        function() self.stack:push("options", {}) end,  -- Options
        function() print("Save clicked") end            -- Save
    }
    
    for i = 1, 8 do
        local button = Button:new({
            id = "upper_" .. i,
            label = buttonLabels[i],
            onClick = buttonActions[i],
            width = 3 * GRID_SIZE,  -- 3x2 tiles = 60x40 pixels
            height = 2 * GRID_SIZE,
            font = self.buttonFont
        })
        -- Position exactly on screen edge, buttons flow from left to right
        button:setPosition((i-1) * 3 * GRID_SIZE, 0)
        self.upperPanelButtons[i] = button
    end
    
    -- 6x2 combo box for world selection (after the 8 buttons)
    self.worldCombobox = Combobox:new({
        id = "world_select",
        label = "World",
        options = {"Earth", "Mars", "Venus"},  -- Placeholder worlds
        selectedIndex = 1,
        font = self.dateFont,
        onChange = function(index, value)
            print("World selected: " .. value)
        end,
        width = 6 * GRID_SIZE,  -- 6 tiles wide
        height = 2 * GRID_SIZE   -- 2 tiles tall
    })
    self.worldCombobox:setPosition(24 * GRID_SIZE, 0)  -- After 8 buttons (8*3=24 tiles)
    
    -- 6x1 date widget (positioned after world combo)
    self.dateWidget = {
        x = 30 * GRID_SIZE,
        y = 0,
        width = 6 * GRID_SIZE,
        height = 1 * GRID_SIZE,
        getText = function()
            return string.format("%04d-%02d-%02d", self.world.year, self.world.month, self.world.day)
        end
    }
    
    -- 6x1 money widget (positioned below date)
    self.moneyWidget = {
        x = 30 * GRID_SIZE,
        y = 1 * GRID_SIZE,
        width = 6 * GRID_SIZE,
        height = 1 * GRID_SIZE,
        getText = function()
            return string.format("$%d", self.funding)
        end
    }
    -- Budget label (6x1) - positioned after world combo
    
    -- 2x2 MENU button
    self.menuButton = Button:new({
        id = "menu",
        label = "MENU",
        onClick = function()
            self.stack:replace("main_menu", {})
        end,
        width = 2 * GRID_SIZE,
        height = 2 * GRID_SIZE,
        font = self.buttonFont
    })
    self.menuButton:setPosition(38 * GRID_SIZE, 0)  -- Near right edge
    
    -- 2x2 TURN button
    self.turnButton = Button:new({
        id = "turn",
        label = "TURN",
        onClick = function()
            self:advance(1)  -- Advance one day
        end,
        width = 2 * GRID_SIZE,
        height = 2 * GRID_SIZE,
        font = self.buttonFont
    })
    self.turnButton:setPosition(36 * GRID_SIZE, 0)  -- Rightmost position

    -- Initialize world map view settings
    self.mapView = {
        scale = 1.0,
        offsetX = 0,
        offsetY = 0
    }
    self.selectedWorld = "Earth"  -- Default selected world
    
    -- Initialize map renderer
    self.mapRenderer = MapRenderer.new({
        x = 0,
        y = 2 * GRID_SIZE,
        width = GRID_COLS * GRID_SIZE,
        height = (GRID_ROWS - 2) * GRID_SIZE
    })

    return self
end

function GeoscapeState:enter(payload)
    BaseState.enter(self, payload)
    if payload and payload.seed and self.rng then
        self.rng:seed(payload.seed)
    end
    
    -- Load selected mods
    if payload and payload.mods and self.registry then
        self.registry:loadMods(payload.mods)
    elseif payload and payload.mod and self.registry then
        -- Fallback for single mod (backward compatibility)
        self.registry:loadMods({payload.mod})
    end
    
    if self.eventBus then
        self.eventBus:publish("geoscape:entered", { date = self.turnManager and self.turnManager:getDate() })
    end
end

function GeoscapeState:exit(reason)
    BaseState.exit(self, reason)
end

function GeoscapeState:advance(days)
    if self.turnManager then
        self.turnManager:advance(days or 1)
    end
    
    -- Reset craft speed points at end of turn
    -- if days and days >= 1 then
    --     self:resetCraftSpeedPoints()
    -- end
end

--- Set the current world
-- @param world World instance
function GeoscapeState:setWorld(world)
    self.currentWorld = world
    self.selectedBase = nil
    self.selectedCraft = nil
    self.radarRangeDisplay = nil
    self.craftRangeDisplay = nil
    self.showRadarRanges = false
    self.showCraftRanges = false
end

--- Select a base and show radar ranges
-- @param base_province Province containing the base
function GeoscapeState:selectBase(base_province)
    self.selectedBase = base_province
    self.selectedCraft = nil
    self.craftRangeDisplay = nil
    self.showCraftRanges = false

    -- Calculate radar ranges from base facilities
    if self.currentWorld and base_province then
        self.radarRangeDisplay = self:calculateRadarRanges(base_province)
        self.showRadarRanges = true
    end
end

--- Select a craft and show operational ranges
-- @param craft Craft instance
-- @param base_province Base province
function GeoscapeState:selectCraft(craft, base_province)
    -- Check if craft can be selected
    local can_select, reason = self:canSelectCraft(craft, base_province)
    if not can_select then
        if self.logger then
            self.logger:warn("GeoscapeState", "Cannot select craft: " .. reason)
        end
        return false
    end

    self.selectedCraft = craft
    self.selectedBase = base_province

    -- Calculate craft operational ranges
    if self.currentWorld and craft and base_province then
        local fuel_available = self:getBaseFuel(base_province.id)
        local speed_points_remaining = self:getCraftSpeedPoints(craft.id)
        self.craftRangeDisplay, self.craftRangeLimit = self.currentWorld:getProvincesInCraftRange(
            craft, base_province, fuel_available, speed_points_remaining)
        self.showCraftRanges = true
        self.showRadarRanges = false
    end

    return true
end

--- Calculate radar ranges for a base
-- @param base_province Province containing the base
-- @return Table of radar ranges by facility type
function GeoscapeState:calculateRadarRanges(base_province)
    local ranges = {
        small_radar = {range = 15, provinces = {}},
        radar = {range = 25, provinces = {}},
        satellite_uplink = {range = 30, provinces = {}},
        satellite_nexus = {range = 50, provinces = {}}
    }

    if not self.currentWorld then return ranges end

    -- Get radar ranges for each facility type
    for facility_type, range_data in pairs(ranges) do
        range_data.provinces = self.currentWorld:getProvincesInRadarRange(base_province, range_data.range)
    end

    return ranges
end

--- Clear all selections and range displays
function GeoscapeState:clearSelection()
    self.selectedBase = nil
    self.selectedCraft = nil
    self.radarRangeDisplay = nil
    self.craftRangeDisplay = nil
    self.showRadarRanges = false
    self.showCraftRanges = false
    self.craftInfoPanel = nil
end

--- Reset craft speed points at the end of each turn
function GeoscapeState:resetCraftSpeedPoints()
    -- Reset speed points for all crafts
    for craft_id, _ in pairs(self.craftSpeedPoints) do
        -- Reset to maximum speed points (this is a placeholder - should get from craft data)
        self.craftSpeedPoints[craft_id] = 100  -- TODO: Get actual max speed from craft
    end
end

--- Update craft info panel with current selection
function GeoscapeState:updateCraftInfoPanel()
    if not self.selectedCraft or not self.selectedBase then
        self.craftInfoPanel = nil
        return
    end

    local craft = self.selectedCraft
    local base = self.selectedBase
    local speed_points = self:getCraftSpeedPoints(craft.id)
    local fuel_available = self:getBaseFuel(base.id)
    local max_range, limit = self.currentWorld:getCraftOperationalRange(craft, base, fuel_available, speed_points)

    self.craftInfoPanel = {
        x = 2 * GRID_SIZE,
        y = self.mapArea.y + self.mapArea.height - 6 * GRID_SIZE,
        width = 12 * GRID_SIZE,
        height = 6 * GRID_SIZE,
        craft_name = craft:getName() or "Unknown Craft",
        speed_points = speed_points,
        max_speed = craft:getSpeedRating(),
        fuel_available = fuel_available,
        max_range = string.format("%.0f km", max_range),
        range_limit = limit,
        province_count = #self.craftRangeDisplay
    }
end

--- Draw craft info panel
function GeoscapeState:drawCraftInfoPanel()
    if not self.craftInfoPanel then return end

    local panel = self.craftInfoPanel

    -- Draw panel background
    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)

    -- Draw panel border
    love.graphics.setColor(0.5, 0.5, 0.8, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)

    -- Draw craft information
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.buttonFont)

    local text_y = panel.y + 5
    local line_height = 15

    love.graphics.printf("Craft: " .. panel.craft_name, panel.x + 5, text_y, panel.width - 10, "left")
    text_y = text_y + line_height

    love.graphics.printf(string.format("Speed: %d/%d", panel.speed_points, panel.max_speed),
                        panel.x + 5, text_y, panel.width - 10, "left")
    text_y = text_y + line_height

    love.graphics.printf("Fuel: " .. panel.fuel_available .. " units",
                        panel.x + 5, text_y, panel.width - 10, "left")
    text_y = text_y + line_height

    love.graphics.printf("Range: " .. panel.max_range .. " (" .. panel.range_limit .. " limited)",
                        panel.x + 5, text_y, panel.width - 10, "left")
    text_y = text_y + line_height

    love.graphics.printf("Provinces in range: " .. panel.province_count,
                        panel.x + 5, text_y, panel.width - 10, "left")
end

--- Draw the world map with provinces, missions, and crafts
function GeoscapeState:drawWorldMap()
    if not self.mapRenderer then return end
    
    -- Get geoscape service
    local geoscapeService = self.registry and self.registry:getService('geoscapeService')
    
    -- Draw background
    self.mapRenderer:drawBackground(self.currentWorld)
    
    -- Draw provinces if world loaded
    if self.currentWorld then
        self.mapRenderer:drawProvinces(self.currentWorld, self.selectedBase)
    end
    
    -- Draw radar coverage if enabled
    if self.showRadarRanges and self.baseCrafts then
        -- TODO: Get bases from base service
        -- self.mapRenderer:drawRadarCoverage(bases)
    end
    
    -- Draw missions
    if geoscapeService then
        local missions = geoscapeService:getActiveMissions()
        self.mapRenderer:drawMissions(missions)
    end
    
    -- Draw crafts
    if geoscapeService then
        local crafts = geoscapeService:getActiveCrafts()
        self.mapRenderer:drawCrafts(crafts, self.selectedCraft)
    end
    
    -- Draw craft path if craft selected
    if self.selectedCraft and self.selectedCraft.destination then
        self.mapRenderer:drawCraftPath(self.selectedCraft)
    end
    
    -- Draw legend
    self.mapRenderer:drawLegend(10, 100)
end

--- Get province at screen coordinates
-- @param x number Screen X coordinate
-- @param y number Screen Y coordinate
-- @return Province instance or nil
function GeoscapeState:getProvinceAt(x, y)
    if not self.currentWorld then return nil end

    -- Convert screen coordinates to world coordinates
    local worldX = x - self.mapArea.x
    local worldY = y - self.mapArea.y

    -- Clamp to valid ranges (assuming 800x600 world for now)
    worldX = math.max(0, math.min(worldX, 800))
    worldY = math.max(0, math.min(worldY, 600))

    -- Find closest province (simple distance check)
    local closest_province = nil
    local min_distance = 20  -- 20 pixel tolerance

    for _, province in pairs(self.currentWorld:getProvinces()) do
        local px, py = province:getCoordinates()
        local distance = math.sqrt((worldX - px)^2 + (worldY - py)^2)
        if distance < min_distance then
            closest_province = province
            min_distance = distance
        end
    end

    return closest_province
end

function GeoscapeState:update(dt)
    for _, button in ipairs(self.upperPanelButtons) do
        button:update(dt)
    end
    self.worldCombobox:update(dt)
    self.menuButton:update(dt)
    self.turnButton:update(dt)
end

--- Renders the geoscape UI including background, buttons, and status displays.
function GeoscapeState:draw()
    love.graphics.clear(0.02, 0.05, 0.09, 1)
    
    -- Draw subtle grid background
    love.graphics.setColor(0.05, 0.08, 0.12, 0.2)
    for x = 0, GRID_COLS - 1 do
        for y = 0, GRID_ROWS - 1 do
            if (x + y) % 2 == 0 then
                love.graphics.rectangle("fill", x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
            end
        end
    end
    
    -- Draw world map
    -- self:drawWorldMap()  -- TODO: Implement world map rendering
    
    -- Draw radar ranges if enabled
    if self.showRadarRanges and self.radarRangeDisplay then
        self:drawRadarRanges()
    end
    
    -- Draw craft ranges if enabled
    if self.showCraftRanges and self.craftRangeDisplay then
        self:drawCraftRanges()
    end
    
    -- Draw upper panel buttons
    for _, button in ipairs(self.upperPanelButtons) do
        button:draw(button.hovered)
    end
    
    -- Draw world combo box
    self.worldCombobox:draw(false)
    
    -- Draw date and money widgets
    love.graphics.setFont(self.dateFont)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.printf(self.dateWidget:getText(), self.dateWidget.x, self.dateWidget.y + 2, self.dateWidget.width, "center")
    
    love.graphics.setColor(0, 0.8, 0.4, 1)
    love.graphics.printf(self.moneyWidget:getText(), self.moneyWidget.x, self.moneyWidget.y + 2, self.moneyWidget.width, "center")
    
    -- Draw MENU and TURN buttons
    self.menuButton:draw(self.menuButton.hovered)
    self.turnButton:draw(self.turnButton.hovered)

    -- Draw craft info panel if available
    self:drawCraftInfoPanel()
end

function GeoscapeState:mousepressed(x, y, button)
    -- Check upper panel buttons first
    for _, btn in ipairs(self.upperPanelButtons) do
        if btn:mousepressed(x, y, button) then
            return true
        end
    end
    
    -- Check world combo box
    if self.worldCombobox:mousepressed(x, y, button) then
        return true
    end
    
    -- Check MENU and TURN buttons
    if self.menuButton:mousepressed(x, y, button) then
        return true
    end
    if self.turnButton:mousepressed(x, y, button) then
        return true
    end
    
    -- Check world map clicks (for province selection)
    if y >= self.mapArea.y then
        local province = self:getProvinceAt(x - self.mapArea.x, y - self.mapArea.y)
        if province then
            if button == 1 then  -- Left click - select base
                if province.base_present then
                    self:selectBase(province)
                    if self.logger then
                        self.logger:info("GeoscapeState", "Selected base in province: " .. province.name)
                    end
                end
            elseif button == 2 then  -- Right click - clear selection
                self:clearSelection()
            end
            return true
        end
    end
    
    return false
end

function GeoscapeState:mousereleased(x, y, button)
    self.worldCombobox:mousereleased(x, y, button)
end

--- Handles mouse movement events for UI hover effects.
-- @param x number Mouse X position
-- @param y number Mouse Y position
-- @param dx number Mouse X movement delta
-- @param dy number Mouse Y movement delta
-- @param istouch boolean Whether this is a touch event
function GeoscapeState:mousemoved(x, y, dx, dy, istouch)
    self.worldCombobox:mousemoved(x, y)
    
    -- Check button hover states
    for _, button in ipairs(self.upperPanelButtons) do
        button:mousemoved(x, y)
    end
    self.menuButton:mousemoved(x, y)
    self.turnButton:mousemoved(x, y)
    
    return false
end

return GeoscapeState
