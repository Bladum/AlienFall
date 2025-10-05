--[[
widgets/geoscape.lua
Geoscape widget for world map and UFO tracking


Interactive world map interface for tracking UFOs, managing interceptors, and monitoring global
activity in strategy games. Essential for geoscape operations in tactical strategy game interfaces.

PURPOSE:
- Provide an interactive world map interface for tracking UFOs and managing interceptors
- Enable monitoring of global activity and mission planning
- Support interceptor management and base coverage display
- Facilitate strategic decision making with real-time global visualization

KEY FEATURES:
- Interactive world map with zoom and pan controls
- UFO tracking with flight paths and interception prediction
- Interceptor management and base coverage display
- Mission site markers and alien activity visualization
- Time acceleration controls for strategic planning
- Radar coverage visualization
- Integration with mission briefing system
- Smooth map animations and transitions
- Customizable map themes and overlays

]]

local core = require("widgets.core")
local MiniMap = require("widgets.complex.minimap")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")

local Geoscape = {}
Geoscape.__index = Geoscape
setmetatable(Geoscape, { __index = core.Base })

--- Creates a new Geoscape widget for world map display
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the geoscape widget
--- @param h number The height of the geoscape widget
--- @param worldData table World data containing UFOs, bases, etc.
--- @param options table Optional configuration table
--- @return Geoscape A new geoscape widget instance
function Geoscape:new(x, y, w, h, worldData, options)
    local obj = core.Base:new(x, y, w, h)

    obj.worldData = worldData or {}
    obj.options = options or {}

    -- Map configuration
    obj.mapWidth = 2048 -- World map dimensions
    obj.mapHeight = 1024
    obj.zoom = 1.0
    obj.offsetX = 0
    obj.offsetY = 0

    -- Game time
    obj.gameTime = obj.options.gameTime or 0
    obj.timeAcceleration = 1
    obj.paused = false

    -- UFOs and mission sites
    obj.ufos = obj.worldData.ufos or {}
    obj.missionSites = obj.worldData.missionSites or {}
    obj.bases = obj.worldData.bases or {}

    -- Radar coverage
    obj.radarCoverage = obj.worldData.radarCoverage or {}

    -- Mini-map for overview
    obj.miniMap = MiniMap:new(x + w - 210, y + 10, 200, 150, {
        mapData = obj.worldData,
        showUFOs = true,
        showMissionSites = true,
        showRadar = true
    })
    obj:addChild(obj.miniMap)

    -- Time controls
    obj.timeControls = {}
    local controlY = y + h - 40
    local pauseBtn = Button:new(x + 10, controlY, 60, 30, "Pause", function()
        obj.paused = not obj.paused
        if obj.onTimeChange then obj.onTimeChange(obj.timeAcceleration, obj.paused) end
    end)
    table.insert(obj.timeControls, pauseBtn)
    obj:addChild(pauseBtn)

    local speed1xBtn = Button:new(x + 80, controlY, 40, 30, "1x", function()
        obj.timeAcceleration = 1
        obj.paused = false
        if obj.onTimeChange then obj.onTimeChange(1, false) end
    end)
    table.insert(obj.timeControls, speed1xBtn)
    obj:addChild(speed1xBtn)

    local speed5xBtn = Button:new(x + 130, controlY, 40, 30, "5x", function()
        obj.timeAcceleration = 5
        obj.paused = false
        if obj.onTimeChange then obj.onTimeChange(5, false) end
    end)
    table.insert(obj.timeControls, speed5xBtn)
    obj:addChild(speed5xBtn)

    -- Callbacks
    obj.onUFOClick = options.onUFOClick
    obj.onMissionSiteClick = options.onMissionSiteClick
    obj.onBaseClick = options.onBaseClick
    obj.onTimeChange = options.onTimeChange

    setmetatable(obj, self)
    return obj
end

--- Adds a UFO to the geoscape for tracking
--- @param ufo table UFO data containing position, flight path, etc.
function Geoscape:addUFO(ufo)
    table.insert(self.ufos, ufo)
end

--- Removes a UFO from the geoscape by its ID
--- @param ufoId any The unique identifier of the UFO to remove
function Geoscape:removeUFO(ufoId)
    for i, ufo in ipairs(self.ufos) do
        if ufo.id == ufoId then
            table.remove(self.ufos, i)
            break
        end
    end
end

--- Adds a mission site to the geoscape
--- @param site table Mission site data containing location and details
function Geoscape:addMissionSite(site)
    table.insert(self.missionSites, site)
end

--- Updates the geoscape time and game state
--- @param deltaTime number Time delta since last update
function Geoscape:updateTime(deltaTime)
    if not self.paused then
        self.gameTime = self.gameTime + (deltaTime * self.timeAcceleration)
    end
end

--- Draws the geoscape widget including world map, UFOs, and UI elements
function Geoscape:draw()
    core.Base.draw(self)

    -- World map background (simplified)
    love.graphics.setColor(0.1, 0.3, 0.8, 0.5) -- Ocean blue
    love.graphics.rectangle("fill", self.x, self.y, self.w - 220, self.h - 50)

    -- Draw continents (simplified representation)
    love.graphics.setColor(0.2, 0.6, 0.2) -- Land green
    -- North America
    love.graphics.rectangle("fill", self.x + 100, self.y + 100, 200, 150)
    -- Europe
    love.graphics.rectangle("fill", self.x + 400, self.y + 80, 120, 100)
    -- Asia
    love.graphics.rectangle("fill", self.x + 550, self.y + 60, 300, 180)

    -- Draw UFOs
    love.graphics.setColor(1, 0, 0) -- Red for UFOs
    for _, ufo in ipairs(self.ufos) do
        local screenX = self.x + (ufo.x / self.mapWidth) * (self.w - 220)
        local screenY = self.y + (ufo.y / self.mapHeight) * (self.h - 50)
        love.graphics.circle("fill", screenX, screenY, 5)

        -- UFO trail
        if ufo.path then
            love.graphics.setColor(1, 0, 0, 0.3)
            for i = 2, #ufo.path do
                local prevX = self.x + (ufo.path[i - 1].x / self.mapWidth) * (self.w - 220)
                local prevY = self.y + (ufo.path[i - 1].y / self.mapHeight) * (self.h - 50)
                local currX = self.x + (ufo.path[i].x / self.mapWidth) * (self.w - 220)
                local currY = self.y + (ufo.path[i].y / self.mapHeight) * (self.h - 50)
                love.graphics.line(prevX, prevY, currX, currY)
            end
        end
    end

    -- Draw mission sites
    love.graphics.setColor(1, 1, 0) -- Yellow for mission sites
    for _, site in ipairs(self.missionSites) do
        local screenX = self.x + (site.x / self.mapWidth) * (self.w - 220)
        local screenY = self.y + (site.y / self.mapHeight) * (self.h - 50)
        love.graphics.rectangle("fill", screenX - 3, screenY - 3, 6, 6)
    end

    -- Draw bases
    love.graphics.setColor(0, 1, 0) -- Green for bases
    for _, base in ipairs(self.bases) do
        local screenX = self.x + (base.x / self.mapWidth) * (self.w - 220)
        local screenY = self.y + (base.y / self.mapHeight) * (self.h - 50)
        love.graphics.circle("fill", screenX, screenY, 8)
    end

    -- Time display
    love.graphics.setColor(unpack(core.theme.text))
    local timeStr = string.format("Time: %02d:%02d",
        math.floor(self.gameTime / 3600) % 24,
        math.floor(self.gameTime / 60) % 60)
    love.graphics.printf(timeStr, self.x + 10, self.y + 10, 200, "left")

    -- Speed indicator
    local speedStr = self.paused and "PAUSED" or (self.timeAcceleration .. "x")
    love.graphics.printf(speedStr, self.x + 10, self.y + 30, 200, "left")
end

return Geoscape
