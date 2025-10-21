---Geoscape Screen - Strategic World Map
---
---Strategic layer game state showing the world map with hex grid, provinces,
---countries, UFO tracking, mission deployment, and day/night cycle. Players manage
---global operations, deploy craft, track UFOs, and respond to missions.
---
---Key Features:
---  - Hex-based world map with provinces and countries
---  - Real-time day/night cycle with lighting
---  - UFO detection and tracking system
---  - Mission generation and deployment
---  - Craft management and interception
---  - Campaign progression and events
---
---Key Exports:
---  - Geoscape:enter(): Initializes world map and systems
---  - Geoscape:update(dt): Updates world state, time, and events
---  - Geoscape:draw(): Renders world map, UI, and overlays
---  - Geoscape:mousepressed(x, y, button): Handles province selection
---  - Geoscape:keypressed(key): Handles time controls and shortcuts
---
---Dependencies:
---  - geoscape.world.world: World map representation
---  - geoscape.world.world_renderer: World rendering system
---  - geoscape.geography.province: Province definitions
---  - geoscape.systems.detection_manager: UFO detection
---  - lore.campaign.campaign_manager: Campaign progression
---  - shared.crafts.craft: Craft definitions
---  - widgets.init: UI widgets for geoscape interface
---
---@module scenes.geoscape_screen
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- Registered automatically in main.lua
---  StateManager.register("geoscape", Geoscape)
---  StateManager.switch("geoscape")
---
---@see geoscape.world.world For world map system
---@see lore.campaign.campaign_manager For campaign management
---@see scenes.battlescape_screen For tactical missions

local StateManager = require("core.state_manager")
local Widgets = require("gui.widgets.init")

-- New hex-based systems
local World = require("geoscape.world.world")
local Province = require("geoscape.geography.province")
local Craft = require("content.crafts.craft")
local GeoscapeRenderer = require("geoscape.world.world_renderer")

-- Mission detection systems
local CampaignManager = require("lore.campaign.campaign_manager")
local DetectionManager = require("geoscape.systems.detection_manager")

local Geoscape = {}

function Geoscape:enter()
    print("[Geoscape] Entering new hex-based geoscape state")
    
    -- Initialize campaign and detection managers
    CampaignManager:init()
    DetectionManager:init()
    
    -- Create world
    self.world = World.new({
        id = "earth",
        name = "Earth",
        width = 80,
        height = 40,
        hexSize = 12,
        scale = 500,
        dayNightSpeed = 4,
        dayNightCoverage = 0.5
    })
    
    -- Create some test provinces
    self:initTestProvinces()
    
    -- Create renderer
    self.renderer = GeoscapeRenderer.new(self.world)
    
    -- Pass campaign manager to renderer for mission drawing
    self.renderer.campaignManager = CampaignManager
    
    -- Camera/input state
    self.isDragging = false
    self.dragStartX = 0
    self.dragStartY = 0
    
    -- Time progression state
    self.paused = false
    self.autoAdvanceTimer = 0
    self.autoAdvanceInterval = 10.0  -- Advance every 10 seconds
    
    -- Time control
    self.paused = false
    self.timeScale = 1
    
    -- UI elements (grid-aligned)
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    self.backButton = Widgets.Button.new(24, 24, 120, 48, "BACK")
    self.backButton.onClick = function()
        StateManager.switch("menu")
    end
    
    self.pauseButton = Widgets.Button.new(
        windowWidth - 144,
        24,
        120,
        48,
        "PAUSE"
    )
    self.pauseButton.onClick = function()
        self.paused = not self.paused
        self.pauseButton:setText(self.paused and "RESUME" or "PAUSE")
    end
    
    self.advanceButton = Widgets.Button.new(
        windowWidth - 144,
        96,
        120,
        48,
        "NEXT DAY"
    )
    self.advanceButton.onClick = function()
        self.world:advanceDay()
        
        -- Advance campaign and perform detections
        CampaignManager:advanceDay()
        DetectionManager:performDailyScans(CampaignManager)
        
        print(string.format("[Geoscape] Advanced to %s", self.world:getDate()))
        CampaignManager:printStatus()
    end
end

function Geoscape:exit()
    print("[Geoscape] Exiting geoscape state")
end

function Geoscape:update(dt)
    -- Update renderer
    self.renderer:update(dt)
    
    -- Auto-advance time if not paused
    if not self.paused then
        self.autoAdvanceTimer = self.autoAdvanceTimer + dt
        if self.autoAdvanceTimer >= self.autoAdvanceInterval then
            self.autoAdvanceTimer = 0
            
            -- Advance to next day
            self.world:advanceDay()
            CampaignManager:advanceDay()
            DetectionManager:performDailyScans(CampaignManager)
            
            print(string.format("[Geoscape] Auto-advanced to %s", self.world:getDate()))
        end
    end
end

function Geoscape:draw()
    -- Draw world
    self.renderer:draw()
    
    -- Draw UI buttons
    self.backButton:draw()
    self.pauseButton:draw()
    self.advanceButton:draw()
end

function Geoscape:mousepressed(x, y, button)
    -- Check UI buttons
    if self.backButton:mousepressed(x, y, button) then return end
    if self.pauseButton:mousepressed(x, y, button) then return end
    if self.advanceButton:mousepressed(x, y, button) then return end
    
    if button == 1 then
        -- Left click - select province or start drag
        local worldX, worldY = self.renderer:screenToWorld(x, y)
        local q, r = self.world:pixelToHex(worldX, worldY)
        local province = self.world:getProvinceAtHex(q, r)
        
        if province then
            self.renderer.selectedProvince = province
            print(string.format("[Geoscape] Selected province: %s", province.name))
        else
            -- Start drag
            self.isDragging = true
            self.dragStartX = x
            self.dragStartY = y
        end
    end
end

function Geoscape:mousereleased(x, y, button)
    if button == 1 then
        self.isDragging = false
    end
end

function Geoscape:mousemoved(x, y, dx, dy)
    -- Update UI hover states
    self.backButton:mousemoved(x, y)
    self.pauseButton:mousemoved(x, y)
    self.advanceButton:mousemoved(x, y)
    
    -- Handle camera drag
    if self.isDragging then
        self.renderer:panCamera(-dx, -dy)
    end
end

function Geoscape:wheelmoved(x, y)
    -- Zoom camera
    local mouseX, mouseY = love.mouse.getPosition()
    self.renderer:zoomCamera(y * 0.1, mouseX, mouseY)
end

function Geoscape:keypressed(key)
    if key == "escape" then
        StateManager.switch("menu")
    elseif key == "space" then
        self.world:advanceDay()
        print(string.format("[Geoscape] Advanced to %s", self.world:getDate()))
    elseif key == "g" then
        self.renderer.showGrid = not self.renderer.showGrid
    elseif key == "n" then
        self.renderer.showDayNight = not self.renderer.showDayNight
    elseif key == "l" then
        self.renderer.showLabels = not self.renderer.showLabels
    end
end

-- Initialize test provinces
function Geoscape:initTestProvinces()
    -- Create a simple test map with a few provinces
    local provinceData = {
        {id = "p1", name = "Central Plains", q = 40, r = 20, biomeId = "plains", countryId = "nation1", 
         color = {r = 0.4, g = 0.7, b = 0.4}, population = 1000000},
        {id = "p2", name = "Northern Forest", q = 35, r = 15, biomeId = "forest", countryId = "nation1",
         color = {r = 0.2, g = 0.6, b = 0.2}, population = 500000},
        {id = "p3", name = "Eastern Mountains", q = 45, r = 20, biomeId = "mountains", countryId = "nation2",
         color = {r = 0.6, g = 0.5, b = 0.4}, population = 300000},
        {id = "p4", name = "Southern Desert", q = 40, r = 25, biomeId = "desert", countryId = "nation2",
         color = {r = 0.8, g = 0.7, b = 0.4}, population = 100000},
        {id = "p5", name = "Western Coast", q = 35, r = 20, biomeId = "coastal", countryId = "nation3",
         color = {r = 0.4, g = 0.6, b = 0.8}, population = 800000},
    }
    
    -- Create provinces
    for _, data in ipairs(provinceData) do
        local province = Province.new(data)
        self.world:addProvince(province)
    end
    
    -- Connect provinces
    self.world.provinceGraph:addConnection("p1", "p2", 1)
    self.world.provinceGraph:addConnection("p1", "p3", 1)
    self.world.provinceGraph:addConnection("p1", "p4", 1)
    self.world.provinceGraph:addConnection("p1", "p5", 1)
    self.world.provinceGraph:addConnection("p2", "p5", 1)
    self.world.provinceGraph:addConnection("p3", "p4", 1)
    
    print(string.format("[Geoscape] Created %d test provinces", #provinceData))
end

return Geoscape
























