---Geoscape World State - Strategic Layer Logic
---
---Manages game state, province data, and updates for the geoscape (strategic layer).
---Coordinates world map initialization, province management, camera controls, and UI state.
---Entry point for geoscape gameplay logic.
---
---Core Responsibilities:
---  - Initialize province network and connections
---  - Track camera position and zoom level
---  - Manage UI state (selected province, paused status)
---  - Handle time progression and turn advancement
---  - Coordinate with campaign and mission systems
---
---State Properties:
---  - provinces: Array of province entities
---  - selectedProvince: Currently selected province (nullable)
---  - camera: {x, y, zoom} for viewport control
---  - paused: Time progression paused flag
---  - currentDay: Game time tracking
---
---Key Exports:
---  - GeoscapeLogic:enter(): Initializes geoscape state
---  - GeoscapeLogic:initProvinces(): Sets up province data
---  - GeoscapeLogic:update(dt): Updates game logic
---  - GeoscapeLogic:selectProvince(province): Sets selected province
---
---Dependencies:
---  - core.state_manager: State transitions
---  - widgets.init: UI widgets
---  - geoscape.geography: Province system
---  - geoscape.world: World entity
---
---@module geoscape.world.world_state
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local GeoscapeLogic = require("geoscape.world.world_state")
---  GeoscapeLogic:enter()
---  GeoscapeLogic:update(deltaTime)
---
---@see geoscape.world.world For world entity
---@see geoscape.geography.province For province system

local StateManager = require("core.state_manager")
local Widgets = require("gui.widgets.init")

local GeoscapeLogic = {}

function GeoscapeLogic:enter()
    print("[Geoscape] Entering geoscape state")
    
    -- Initialize province data
    self:initProvinces()
    
    -- Camera/view settings
    self.camera = {
        x = 0,
        y = 0,
        zoom = 0.5, -- Start zoomed out to see the whole world
        minZoom = 0.3,
        maxZoom = 2.0
    }
    
    -- Mouse drag settings
    self.isDragging = false
    self.dragStartX = 0
    self.dragStartY = 0
    self.dragStartCamX = 0
    self.dragStartCamY = 0
    
    -- Selected province
    self.selectedProvince = nil
    self.hoveredProvince = nil
    
    -- Time settings
    self.paused = false
    self.gameTime = 0
    self.timeScale = 1 -- 1 = normal, 2 = fast, 5 = very fast
    
    -- UI elements (grid-aligned)
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    self.backButton = Widgets.Button.new(24, 24, 120, 48, "BACK")
    self.backButton.onClick = function()
        StateManager.switch("menu")
    end
    
    self.pauseButton = Widgets.Button.new(
        math.floor((windowWidth - 144) / 24) * 24,  -- Snap to grid
        24,  -- Already grid-aligned
        120,  -- 5 grid cells
        48,   -- 2 grid cells
        "PAUSE"
    )
    self.pauseButton.onClick = function()
        self.paused = not self.paused
        self.pauseButton:setText(self.paused and "RESUME" or "PAUSE")
    end
    
    -- Info panel (grid-aligned)
    self.infoPanel = Widgets.FrameBox.new(
        24,  -- 1 grid cell margin
        math.floor((windowHeight - 168) / 24) * 24,  -- Snap to grid (150 + 18 for title)
        312,  -- 13 grid cells
        168,  -- 7 grid cells
        "Province Info"
    )
end

function GeoscapeLogic:exit()
    print("[Geoscape] Exiting geoscape state")
end

function GeoscapeLogic:update(dt)
    if not self.paused then
        self.gameTime = self.gameTime + dt * self.timeScale
        
        -- Update province satisfaction and funding (simplified simulation)
        for _, province in ipairs(self.provinces) do
            -- Random fluctuations
            province.satisfaction = math.max(0, math.min(100, province.satisfaction + (math.random() - 0.5) * 2))
            -- Funding based on population and satisfaction
            province.funding = math.floor(province.population * province.satisfaction / 100000)
        end
    end
    
    -- Update hovered province
    local mouseX, mouseY = love.mouse.getPosition()
    local worldX = (mouseX - love.graphics.getWidth() / 2) / self.camera.zoom + self.camera.x
    local worldY = (mouseY - love.graphics.getHeight() / 2) / self.camera.zoom + self.camera.y
    self.hoveredProvince = self:getProvinceAtWorldPosition(worldX, worldY)
end

return GeoscapeLogic

























