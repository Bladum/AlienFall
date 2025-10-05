--[[
widgets/minimap.lua
MiniMap widget for tactical battlefield overview


Compact tactical overview widget with fog of war, unit markers, and interactive navigation.
Essential for turn-based strategy games requiring situational awareness and tactical planning.

PURPOSE:
- Provide a compact tactical overview of the battlefield
- Enable fog of war and exploration tracking
- Support unit visualization and faction identification
- Facilitate interactive navigation and waypoint management

KEY FEATURES:
- Terrain and object visualization with customizable color schemes
- Unit markers with different colors for each faction and unit type
- Fog of war system with exploration tracking and visibility updates
- Viewport indicator showing current camera position and zoom level
- Interactive waypoints and tactical markers
- Zoom and pan functionality with smooth animations
- Click-to-navigate support for quick camera movement
- Canvas-based rendering for optimal performance
- Real-time updates with animation support
- Integration with tactical game systems
- Customizable marker styles and sizes

@see GridMap
@see core.Base
-- Complete tactical interface setup
function createTacticalInterface()
    local interface = {}

    -- Main tactical minimap
    interface.minimap = MiniMap:new(10, 10, 220, 220, {
        gridMap = tacticalMap,
        showFogOfWar = true,
        showWaypoints = true,
        showViewport = true,
        clickable = true,
        zoomable = true,
        onMapClick = function(x, y)
            handleTacticalClick(x, y)
        end
    })

    -- Unit status overlay
    interface.unitOverlay = MiniMap:new(240, 10, 120, 120, {
        gridMap = unitView,
        showFogOfWar = false,
        backgroundColor = {0.1, 0.1, 0.15},
        unitColors = {[1] = {0, 1, 0}}, -- Only show friendly units
        tileColors = {floor = {0.2, 0.2, 0.25}, wall = {0.15, 0.15, 0.2}}
    })

    -- Mission objective markers
    for _, objective in ipairs(missionObjectives) do
        interface.minimap:addMarker(objective.x, objective.y,
            "objective", objective.name, {0, 1, 0})
    end

    return interface
end

-- Save/load minimap state
function saveMinimapState(minimap)
    local state = {
        zoom = minimap.zoom,
        panX = minimap.panX,
        panY = minimap.panY,
        waypoints = minimap.waypoints,
        markers = minimap.markers
    }
    return state
end

function loadMinimapState(minimap, state)
    minimap.zoom = state.zoom or 1.0
    minimap.panX = state.panX or 0
    minimap.panY = state.panY or 0
    minimap.waypoints = state.waypoints or {}
    minimap.markers = state.markers or {}
    minimap:refresh()
end
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")

local MiniMap = {}
MiniMap.__index = MiniMap
setmetatable(MiniMap, { __index = core.Base })

function MiniMap:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Map reference
    obj.gridMap = options and options.gridMap
    obj.viewport = options and options.viewport or { x = 0, y = 0, w = 800, h = 600 }

    -- Visual properties
    obj.backgroundColor = (options and options.backgroundColor) or { 0.1, 0.1, 0.2 }
    obj.borderColor = (options and options.borderColor) or core.theme.border
    obj.borderWidth = (options and options.borderWidth) or 2
    obj.showBorder = (options and options.showBorder) ~= false

    -- Tile rendering
    obj.tileColors = (options and options.tileColors) or {
        floor = { 0.6, 0.6, 0.5 },
        wall = { 0.3, 0.3, 0.3 },
        door = { 0.4, 0.3, 0.2 },
        coverLow = { 0.2, 0.6, 0.2 },
        coverHigh = { 0.1, 0.4, 0.1 },
        fire = { 1, 0.3, 0 },
        smoke = { 0.4, 0.4, 0.4 }
    }

    -- Unit rendering
    obj.unitColors = (options and options.unitColors) or {
        [1] = { 0.2, 0.4, 1 }, -- Player
        [2] = { 1, 0.2, 0.2 }, -- Enemy 1
        [3] = { 1, 0.6, 0 },   -- Enemy 2
        [4] = { 0.8, 0, 0.8 }  -- Enemy 3
    }

    -- Fog of war
    obj.showFogOfWar = (options and options.showFogOfWar) ~= false
    obj.currentSide = (options and options.currentSide) or 1
    obj.fogColor = (options and options.fogColor) or { 0, 0, 0, 0.7 }
    obj.unexploredColor = (options and options.unexploredColor) or { 0.05, 0.05, 0.1 }

    -- Viewport indicator
    obj.showViewport = (options and options.showViewport) ~= false
    obj.viewportColor = (options and options.viewportColor) or { 1, 1, 0, 0.8 }
    obj.viewportLineWidth = (options and options.viewportLineWidth) or 2

    -- Interaction
    obj.clickable = (options and options.clickable) ~= false
    obj.zoomable = (options and options.zoomable) or false
    obj.draggable = (options and options.draggable) or false
    obj.zoom = 1.0
    obj.minZoom = 0.5
    obj.maxZoom = 3.0
    obj.panX = 0
    obj.panY = 0

    -- Annotations
    obj.waypoints = {}
    obj.markers = {}
    obj.showWaypoints = (options and options.showWaypoints) ~= false
    obj.showMarkers = (options and options.showMarkers) ~= false

    -- Animation
    obj.animateUpdates = (options and options.animateUpdates) or false
    obj.blinkWaypoints = (options and options.blinkWaypoints) ~= false
    obj.blinkTimer = 0

    -- State
    obj.isDragging = false
    obj.lastMouseX = 0
    obj.lastMouseY = 0
    obj.needsRedraw = true
    obj.canvas = nil

    -- Callbacks
    obj.onMapClick = options and options.onMapClick
    obj.onViewportChange = options and options.onViewportChange
    obj.onWaypointClick = options and options.onWaypointClick

    setmetatable(obj, self)
    obj:_createCanvas()
    return obj
end

function MiniMap:_createCanvas()
    if love.graphics.isSupported("canvas") then
        self.canvas = love.graphics.newCanvas(self.w - self.borderWidth * 2, self.h - self.borderWidth * 2)
    end
end

function MiniMap:setGridMap(gridMap)
    self.gridMap = gridMap
    self.needsRedraw = true
end

function MiniMap:setViewport(x, y, w, h)
    self.viewport.x = x
    self.viewport.y = y
    self.viewport.w = w
    self.viewport.h = h

    if self.onViewportChange then
        self.onViewportChange(x, y, w, h, self)
    end
end

function MiniMap:setCurrentSide(side)
    self.currentSide = side
    self.needsRedraw = true
end

function MiniMap:addWaypoint(x, y, waypointType, data)
    table.insert(self.waypoints, {
        x = x,
        y = y,
        type = waypointType or "move", -- move, attack, defend, objective
        data = data or {},
        timestamp = love.timer.getTime()
    })
end

function MiniMap:removeWaypoint(index)
    if self.waypoints[index] then
        table.remove(self.waypoints, index)
    end
end

function MiniMap:clearWaypoints()
    self.waypoints = {}
end

function MiniMap:addMarker(x, y, markerType, text, color)
    table.insert(self.markers, {
        x = x,
        y = y,
        type = markerType or "info", -- info, warning, danger, objective
        text = text or "",
        color = color or core.theme.primary,
        timestamp = love.timer.getTime()
    })
end

function MiniMap:update(dt)
    core.Base.update(self, dt)

    -- Update blink timer
    self.blinkTimer = self.blinkTimer + dt

    -- Check if redraw is needed
    if self.gridMap and self.needsRedraw then
        self:_redrawMap()
        self.needsRedraw = false
    end
end

function MiniMap:_redrawMap()
    if not self.canvas or not self.gridMap then return end

    local oldCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    local scaleX = (self.w - self.borderWidth * 2) / (self.gridMap.width * self.gridMap.tileSize) * self.zoom
    local scaleY = (self.h - self.borderWidth * 2) / (self.gridMap.height * self.gridMap.tileSize) * self.zoom

    love.graphics.push()
    love.graphics.translate(self.panX, self.panY)
    love.graphics.scale(scaleX, scaleY)

    -- Draw terrain and objects
    for y = 1, self.gridMap.height do
        for x = 1, self.gridMap.width do
            local worldX = (x - 1) * self.gridMap.tileSize
            local worldY = (y - 1) * self.gridMap.tileSize

            -- Check visibility
            local isVisible = not self.showFogOfWar or
                self.gridMap:isVisible(self.currentSide, x, y)
            local isExplored = not self.showFogOfWar or
                self.gridMap:isExplored(self.currentSide, x, y)

            if isExplored then
                -- Draw terrain
                self:_drawMinimapTile(worldX, worldY, x, y)

                -- Apply fog overlay if not currently visible
                if self.showFogOfWar and not isVisible then
                    love.graphics.setColor(unpack(self.fogColor))
                    love.graphics.rectangle("fill", worldX, worldY, self.gridMap.tileSize, self.gridMap.tileSize)
                end
            else
                -- Unexplored area
                love.graphics.setColor(unpack(self.unexploredColor))
                love.graphics.rectangle("fill", worldX, worldY, self.gridMap.tileSize, self.gridMap.tileSize)
            end
        end
    end

    -- Draw units
    self:_drawMinimapUnits(scaleX, scaleY)

    love.graphics.pop()
    love.graphics.setCanvas(oldCanvas)
end

function MiniMap:_drawMinimapTile(worldX, worldY, x, y)
    local terrain = self.gridMap.terrain[y][x]
    local object = self.gridMap.objects[y][x]
    local effect = self.gridMap.effects[y][x]

    -- Draw terrain
    if terrain == self.gridMap.TILE_TYPES.FLOOR then
        love.graphics.setColor(unpack(self.tileColors.floor))
    elseif terrain == self.gridMap.TILE_TYPES.WALL then
        love.graphics.setColor(unpack(self.tileColors.wall))
    elseif terrain == self.gridMap.TILE_TYPES.DOOR then
        love.graphics.setColor(unpack(self.tileColors.door))
    else
        love.graphics.setColor(unpack(self.tileColors.floor))
    end

    love.graphics.rectangle("fill", worldX, worldY, self.gridMap.tileSize, self.gridMap.tileSize)

    -- Draw objects
    if object == self.gridMap.TILE_TYPES.COVER_LOW then
        love.graphics.setColor(unpack(self.tileColors.coverLow))
        love.graphics.rectangle("fill", worldX + 2, worldY + 2,
            self.gridMap.tileSize - 4, self.gridMap.tileSize - 4)
    elseif object == self.gridMap.TILE_TYPES.COVER_HIGH then
        love.graphics.setColor(unpack(self.tileColors.coverHigh))
        love.graphics.rectangle("fill", worldX + 1, worldY + 1,
            self.gridMap.tileSize - 2, self.gridMap.tileSize - 2)
    end

    -- Draw effects
    if effect.type == self.gridMap.EFFECT_TYPES.FIRE then
        love.graphics.setColor(unpack(self.tileColors.fire))
        love.graphics.rectangle("fill", worldX, worldY, self.gridMap.tileSize, self.gridMap.tileSize)
    elseif effect.type == self.gridMap.EFFECT_TYPES.SMOKE then
        love.graphics.setColor(unpack(self.tileColors.smoke))
        love.graphics.rectangle("fill", worldX, worldY, self.gridMap.tileSize, self.gridMap.tileSize)
    end
end

function MiniMap:_drawMinimapUnits(scaleX, scaleY)
    for unitId, unit in pairs(self.gridMap.units) do
        local worldX = (unit.mapX - 1) * self.gridMap.tileSize
        local worldY = (unit.mapY - 1) * self.gridMap.tileSize

        -- Only draw visible units
        local isVisible = not self.showFogOfWar or
            self.gridMap:isVisible(self.currentSide, unit.mapX, unit.mapY) or
            unit.side == self.currentSide

        if isVisible then
            local unitColor = self.unitColors[unit.side] or { 0.5, 0.5, 0.5 }
            love.graphics.setColor(unpack(unitColor))

            local centerX = worldX + self.gridMap.tileSize / 2
            local centerY = worldY + self.gridMap.tileSize / 2
            local radius = math.min(self.gridMap.tileSize / 3, 6 / math.min(scaleX, scaleY))

            love.graphics.circle("fill", centerX, centerY, radius)
        end
    end
end

function MiniMap:draw()
    -- Draw border
    if self.showBorder then
        love.graphics.setColor(unpack(self.borderColor))
        love.graphics.setLineWidth(self.borderWidth)
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
        love.graphics.setLineWidth(1)
    end

    -- Draw background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill",
        self.x + self.borderWidth,
        self.y + self.borderWidth,
        self.w - self.borderWidth * 2,
        self.h - self.borderWidth * 2)

    -- Draw map canvas
    if self.canvas then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.canvas, self.x + self.borderWidth, self.y + self.borderWidth)
    end

    -- Draw viewport indicator
    if self.showViewport and self.gridMap then
        self:_drawViewportIndicator()
    end

    -- Draw waypoints
    if self.showWaypoints then
        self:_drawWaypoints()
    end

    -- Draw markers
    if self.showMarkers then
        self:_drawMarkers()
    end
end

function MiniMap:_drawViewportIndicator()
    local contentW = self.w - self.borderWidth * 2
    local contentH = self.h - self.borderWidth * 2

    local mapWorldW = self.gridMap.width * self.gridMap.tileSize
    local mapWorldH = self.gridMap.height * self.gridMap.tileSize

    local scaleX = contentW / mapWorldW * self.zoom
    local scaleY = contentH / mapWorldH * self.zoom

    local viewportX = self.x + self.borderWidth + (self.viewport.x * scaleX) + self.panX
    local viewportY = self.y + self.borderWidth + (self.viewport.y * scaleY) + self.panY
    local viewportW = self.viewport.w * scaleX
    local viewportH = self.viewport.h * scaleY

    love.graphics.setColor(unpack(self.viewportColor))
    love.graphics.setLineWidth(self.viewportLineWidth)
    love.graphics.rectangle("line", viewportX, viewportY, viewportW, viewportH)
    love.graphics.setLineWidth(1)
end

function MiniMap:_drawWaypoints()
    if not self.gridMap then return end

    local contentW = self.w - self.borderWidth * 2
    local contentH = self.h - self.borderWidth * 2
    local mapWorldW = self.gridMap.width * self.gridMap.tileSize
    local mapWorldH = self.gridMap.height * self.gridMap.tileSize
    local scaleX = contentW / mapWorldW * self.zoom
    local scaleY = contentH / mapWorldH * self.zoom

    for i, waypoint in ipairs(self.waypoints) do
        local worldX = (waypoint.x - 1) * self.gridMap.tileSize
        local worldY = (waypoint.y - 1) * self.gridMap.tileSize

        local screenX = self.x + self.borderWidth + (worldX * scaleX) + self.panX
        local screenY = self.y + self.borderWidth + (worldY * scaleY) + self.panY

        -- Blink effect
        local alpha = 1
        if self.blinkWaypoints then
            alpha = 0.5 + 0.5 * math.sin(self.blinkTimer * 4 + i * 0.5)
        end

        -- Waypoint color based on type
        local color = { 1, 1, 1, alpha }
        if waypoint.type == "attack" then
            color = { 1, 0.2, 0.2, alpha }
        elseif waypoint.type == "defend" then
            color = { 0.2, 0.2, 1, alpha }
        elseif waypoint.type == "objective" then
            color = { 0, 1, 0, alpha }
        end

        love.graphics.setColor(unpack(color))
        love.graphics.circle("fill", screenX + self.gridMap.tileSize * scaleX / 2,
            screenY + self.gridMap.tileSize * scaleY / 2, 4)
    end
end

function MiniMap:_drawMarkers()
    if not self.gridMap then return end

    local contentW = self.w - self.borderWidth * 2
    local contentH = self.h - self.borderWidth * 2
    local mapWorldW = self.gridMap.width * self.gridMap.tileSize
    local mapWorldH = self.gridMap.height * self.gridMap.tileSize
    local scaleX = contentW / mapWorldW * self.zoom
    local scaleY = contentH / mapWorldH * self.zoom

    for _, marker in ipairs(self.markers) do
        local worldX = (marker.x - 1) * self.gridMap.tileSize
        local worldY = (marker.y - 1) * self.gridMap.tileSize

        local screenX = self.x + self.borderWidth + (worldX * scaleX) + self.panX
        local screenY = self.y + self.borderWidth + (worldY * scaleY) + self.panY

        -- Marker shape based on type
        love.graphics.setColor(unpack(marker.color))

        if marker.type == "info" then
            love.graphics.circle("fill", screenX, screenY, 3)
        elseif marker.type == "warning" then
            love.graphics.polygon("fill", screenX, screenY - 4, screenX - 3, screenY + 2, screenX + 3, screenY + 2)
        elseif marker.type == "danger" then
            love.graphics.rectangle("fill", screenX - 2, screenY - 2, 4, 4)
        elseif marker.type == "objective" then
            love.graphics.circle("line", screenX, screenY, 5)
            love.graphics.circle("fill", screenX, screenY, 2)
        end
    end
end

function MiniMap:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    if button == 1 and self.clickable and self.gridMap then
        -- Convert screen coordinates to map coordinates
        local mapCoords = self:screenToMap(x, y)

        if mapCoords then
            if self.onMapClick then
                self.onMapClick(mapCoords.x, mapCoords.y, self)
            end
        end
        return true
    end

    return false
end

-- Utility methods
function MiniMap:screenToMap(screenX, screenY)
    if not self.gridMap then return nil end

    local contentW = self.w - self.borderWidth * 2
    local contentH = self.h - self.borderWidth * 2
    local mapWorldW = self.gridMap.width * self.gridMap.tileSize
    local mapWorldH = self.gridMap.height * self.gridMap.tileSize

    local relX = (screenX - self.x - self.borderWidth - self.panX) / (contentW * self.zoom)
    local relY = (screenY - self.y - self.borderWidth - self.panY) / (contentH * self.zoom)

    local worldX = relX * mapWorldW
    local worldY = relY * mapWorldH

    local mapX = math.floor(worldX / self.gridMap.tileSize) + 1
    local mapY = math.floor(worldY / self.gridMap.tileSize) + 1

    if mapX >= 1 and mapX <= self.gridMap.width and
        mapY >= 1 and mapY <= self.gridMap.height then
        return { x = mapX, y = mapY }
    end

    return nil
end

function MiniMap:refresh()
    self.needsRedraw = true
end

return MiniMap






