---Geoscape World Renderer - Visual Hex World Map
---
---Renders hex-based world map with provinces, borders, day/night overlay, and UI elements.
---Provides camera controls (pan, zoom) and visual feedback for province selection,
---mission markers, and base locations. Integrates with widget system for UI rendering.
---
---Rendering Layers:
---  1. Background (cleared to dark blue)
---  2. Province borders and connections
---  3. Province fills (colored by biome/faction)
---  4. Province labels (name, population)
---  5. Day/night overlay (visual-only)
---  6. Mission markers (UFOs, sites, bases)
---  7. Base markers (player facilities)
---  8. UI widgets (panels, buttons, tooltips)
---
---Camera System:
---  - Pan: Drag with mouse or arrow keys
---  - Zoom: Mouse wheel or +/- keys
---  - Bounds: Constrained to world limits
---  - Transform: Applied via love.graphics.push/pop
---
---Visual Features:
---  - Hex grid outline (optional debug mode)
---  - Province highlighting on hover
---  - Mission detection state (hidden/detected)
---  - Base defense status indicators
---  - Animated day/night cycle movement
---
---Key Exports:
---  - GeoscapeRenderer.new(world): Creates renderer instance
---  - draw(): Renders entire world map
---  - updateCamera(dt): Updates camera position
---  - screenToWorld(x, y): Converts screen to world coordinates
---  - worldToScreen(x, y): Converts world to screen coordinates
---
---Dependencies:
---  - widgets.init: UI widget system
---  - geoscape.world.world: World entity with hex grid
---  - geoscape.geography.province: Province entities
---  - geoscape.systems.daynight_cycle: Day/night overlay
---
---@module geoscape.world.world_renderer
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local GeoscapeRenderer = require("geoscape.world.world_renderer")
---  local renderer = GeoscapeRenderer.new(worldEntity)
---  function love.draw()
---    renderer:draw()
---  end
---
---@see geoscape.world.world For world entity
---@see geoscape.systems.hex_grid For coordinate system

local Widgets = require("gui.widgets.init")

local GeoscapeRenderer = {}

---Initialize renderer with world instance
---@param world table World instance
---@return table Renderer instance
function GeoscapeRenderer.new(world)
    local self = {
        world = world,
        camera = {
            x = 0,
            y = 0,
            zoom = 1.0,
            minZoom = 0.3,
            maxZoom = 3.0
        },
        showGrid = true,
        showProvinces = true,
        showDayNight = true,
        showLabels = false,
        hoveredProvince = nil,
        selectedProvince = nil
    }
    
    print("[GeoscapeRenderer] Initialized renderer")
    
    return setmetatable(self, {__index = GeoscapeRenderer})
end

---Set camera position
---@param x number X position
---@param y number Y position
function GeoscapeRenderer:setCameraPosition(x, y)
    self.camera.x = x
    self.camera.y = y
end

---Set camera zoom
---@param zoom number Zoom level
function GeoscapeRenderer:setCameraZoom(zoom)
    self.camera.zoom = math.max(self.camera.minZoom, math.min(self.camera.maxZoom, zoom))
end

---Pan camera by delta
---@param dx number Delta X
---@param dy number Delta Y
function GeoscapeRenderer:panCamera(dx, dy)
    self.camera.x = self.camera.x + dx / self.camera.zoom
    self.camera.y = self.camera.y + dy / self.camera.zoom
end

---Zoom camera by delta
---@param delta number Zoom delta
---@param focusX number? Focus X (screen space)
---@param focusY number? Focus Y (screen space)
function GeoscapeRenderer:zoomCamera(delta, focusX, focusY)
    local oldZoom = self.camera.zoom
    local newZoom = math.max(self.camera.minZoom, math.min(self.camera.maxZoom, oldZoom + delta))
    
    if focusX and focusY then
        -- Zoom towards focus point
        local worldX, worldY = self:screenToWorld(focusX, focusY)
        self.camera.zoom = newZoom
        local newWorldX, newWorldY = self:screenToWorld(focusX, focusY)
        self.camera.x = self.camera.x + (worldX - newWorldX)
        self.camera.y = self.camera.y + (worldY - newWorldY)
    else
        self.camera.zoom = newZoom
    end
end

---Convert screen coordinates to world coordinates
---@param screenX number Screen X
---@param screenY number Screen Y
---@return number, number World X, Y
function GeoscapeRenderer:screenToWorld(screenX, screenY)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    local worldX = (screenX - screenWidth / 2) / self.camera.zoom + self.camera.x
    local worldY = (screenY - screenHeight / 2) / self.camera.zoom + self.camera.y
    
    return worldX, worldY
end

---Convert world coordinates to screen coordinates
---@param worldX number World X
---@param worldY number World Y
---@return number, number Screen X, Y
function GeoscapeRenderer:worldToScreen(worldX, worldY)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    local screenX = (worldX - self.camera.x) * self.camera.zoom + screenWidth / 2
    local screenY = (worldY - self.camera.y) * self.camera.zoom + screenHeight / 2
    
    return screenX, screenY
end

---Update renderer (hover detection, etc.)
---@param dt number Delta time
function GeoscapeRenderer:update(dt)
    -- Update hovered province
    local mouseX, mouseY = love.mouse.getPosition()
    local worldX, worldY = self:screenToWorld(mouseX, mouseY)
    local q, r = self.world:pixelToHex(worldX, worldY)
    
    self.hoveredProvince = self.world:getProvinceAtHex(q, r)
end

---Draw the world
function GeoscapeRenderer:draw()
    love.graphics.push()
    
    -- Apply camera transform
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    love.graphics.translate(screenWidth / 2, screenHeight / 2)
    love.graphics.scale(self.camera.zoom, self.camera.zoom)
    love.graphics.translate(-self.camera.x, -self.camera.y)
    
    -- Draw background
    self:drawBackground()
    
    -- Draw hex grid
    if self.showGrid then
        self:drawHexGrid()
    end
    
    -- Draw provinces
    if self.showProvinces then
        self:drawProvinces()
    end
    
    -- Draw day/night overlay
    if self.showDayNight then
        self:drawDayNightOverlay()
    end
    
    -- Draw labels
    if self.showLabels then
        self:drawLabels()
    end
    
    -- Draw missions
    if self.campaignManager then
        self:drawMissions()
    end
    
    love.graphics.pop()
    
    -- Draw UI (screen space)
    self:drawUI()
end

---Draw background
function GeoscapeRenderer:drawBackground()
    local bg = self.world.backgroundColor
    love.graphics.setColor(bg.r, bg.g, bg.b)
    
    local worldWidth = self.world.width * self.world.hexGrid.hexWidth
    local worldHeight = self.world.height * self.world.hexGrid.hexHeight
    love.graphics.rectangle("fill", 0, 0, worldWidth, worldHeight)
end

---Draw hex grid
function GeoscapeRenderer:drawHexGrid()
    love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
    love.graphics.setLineWidth(1 / self.camera.zoom)
    
    for q = 0, self.world.width - 1 do
        for r = 0, self.world.height - 1 do
            if self.world.hexGrid:inBounds(q, r) then
                local corners = self.world.hexGrid:getCorners(q, r)
                local vertices = {}
                for _, corner in ipairs(corners) do
                    table.insert(vertices, corner.x)
                    table.insert(vertices, corner.y)
                end
                love.graphics.polygon("line", vertices)
            end
        end
    end
end

---Draw provinces
function GeoscapeRenderer:drawProvinces()
    for _, province in pairs(self.world:getAllProvinces()) do
        local corners = self.world.hexGrid:getCorners(province.q, province.r)
        local vertices = {}
        for _, corner in ipairs(corners) do
            table.insert(vertices, corner.x)
            table.insert(vertices, corner.y)
        end
        
        -- Determine color
        local color = province.color
        local isHovered = self.hoveredProvince == province
        local isSelected = self.selectedProvince == province
        
        if isSelected then
            love.graphics.setColor(1, 1, 0, 0.8)  -- Yellow for selected
        elseif isHovered then
            love.graphics.setColor(color.r * 1.5, color.g * 1.5, color.b * 1.5, 0.8)
        else
            love.graphics.setColor(color.r, color.g, color.b, 0.6)
        end
        
        love.graphics.polygon("fill", vertices)
        
        -- Draw outline
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.setLineWidth(2 / self.camera.zoom)
        love.graphics.polygon("line", vertices)
        
        -- Draw base indicator
        if province:hasBase() then
            local cx, cy = self.world:hexToPixel(province.q, province.r)
            love.graphics.setColor(0, 1, 0)
            love.graphics.circle("fill", cx, cy, 5 / self.camera.zoom)
        end
        
        -- Draw mission indicator
        if province:hasMissions() then
            local cx, cy = self.world:hexToPixel(province.q, province.r)
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle("fill", cx, cy, 3 / self.camera.zoom)
        end
    end
end

---Draw day/night overlay
function GeoscapeRenderer:drawDayNightOverlay()
    for q = 0, self.world.width - 1 do
        for r = 0, self.world.height - 1 do
            if self.world.hexGrid:inBounds(q, r) then
                local lightLevel = self.world:getLightLevel(q, r)
                
                if lightLevel < 0.9 then  -- Only draw if not full day
                    local corners = self.world.hexGrid:getCorners(q, r)
                    local vertices = {}
                    for _, corner in ipairs(corners) do
                        table.insert(vertices, corner.x)
                        table.insert(vertices, corner.y)
                    end
                    
                    local r, g, b, a = self.world.dayNightCycle.getDarknessColor(lightLevel)
                    love.graphics.setColor(r, g, b, a)
                    love.graphics.polygon("fill", vertices)
                end
            end
        end
    end
end

---Draw province labels
function GeoscapeRenderer:drawLabels()
    love.graphics.setColor(1, 1, 1)
    
    for _, province in pairs(self.world:getAllProvinces()) do
        local cx, cy = self.world:hexToPixel(province.q, province.r)
        local sx, sy = self:worldToScreen(cx, cy)
        
        -- Only draw if visible on screen
        if sx >= 0 and sx <= love.graphics.getWidth() and sy >= 0 and sy <= love.graphics.getHeight() then
            love.graphics.push()
            love.graphics.origin()
            love.graphics.print(province.name, sx, sy)
            love.graphics.pop()
        end
    end
end

---Draw UI overlay
function GeoscapeRenderer:drawUI()
    love.graphics.setColor(1, 1, 1)
    
    -- Draw calendar
    love.graphics.print(self.world:getDate(), 10, 10)
    
    -- Draw camera info
    love.graphics.print(string.format("Zoom: %.2f", self.camera.zoom), 10, 30)
    
    -- Draw hovered province info
    if self.hoveredProvince then
        local info = self.hoveredProvince:getInfo()
        local text = string.format("%s (%s)\nPopulation: %s\nCrafts: %d | Missions: %d",
            info.name, info.country, 
            tostring(info.population),
            info.crafts, info.missions)
        love.graphics.print(text, 10, 60)
    end
    
    -- Draw mission stats if available
    if self.campaignManager then
        local stats = self.campaignManager:getStatistics()
        local detected = self.campaignManager:getDetectedMissions()
        local text = string.format("Day %d | Active: %d | Detected: %d | Completed: %d",
            stats.currentDay, stats.activeMissions, #detected, stats.completedMissions)
        love.graphics.print(text, 10, 150)
    end
    
    -- Draw instructions
    love.graphics.print("Mouse: Pan | Wheel: Zoom | Click: Select Province", 10, love.graphics.getHeight() - 30)
end

---Draw detected missions on map
function GeoscapeRenderer:drawMissions()
    if not self.campaignManager then return end
    
    local detectedMissions = self.campaignManager:getDetectedMissions()
    
    for _, mission in ipairs(detectedMissions) do
        self:drawMissionIcon(mission)
    end
end

---Draw a single mission icon
---@param mission table Mission instance
function GeoscapeRenderer:drawMissionIcon(mission)
    -- Use mission position
    local x, y = mission.position.x, mission.position.y
    
    -- Get mission icon type
    local iconType = mission:getIcon()
    
    -- Draw mission icon programmatically
    self:drawMissionIconGraphic(iconType, x, y, mission)
    
    -- Add blinking effect for newly detected missions
    if mission.detectedDay and self.campaignManager then
        local daysSinceDetection = self.campaignManager.currentDay - mission.detectedDay
        if daysSinceDetection <= 2 then  -- Blink for 2 days
            local alpha = (math.sin(love.timer.getTime() * 5) + 1) / 2
            love.graphics.setColor(1, 1, 0, alpha)
            love.graphics.circle("line", x, y, 20 / self.camera.zoom)
        end
    end
    
    -- Draw tooltip on hover
    local mouseX, mouseY = love.mouse.getPosition()
    local worldX, worldY = self:screenToWorld(mouseX, mouseY)
    local distance = math.sqrt((worldX - x)^2 + (worldY - y)^2)
    
    if distance < 16 / self.camera.zoom then
        self:drawMissionTooltip(mission)
    end
end

---Draw mission icon graphics programmatically
---@param iconType string Icon type name
---@param x number World X position
---@param y number World Y position
---@param mission table Mission instance
function GeoscapeRenderer:drawMissionIconGraphic(iconType, x, y, mission)
    local size = 12 / self.camera.zoom
    local halfSize = size / 2
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(1 / self.camera.zoom)
    
    if iconType == "ufo_air" then
        -- Flying UFO: Red triangle with wings
        love.graphics.setColor(1, 0, 0)  -- Red
        -- Triangle body
        love.graphics.polygon("fill", 0, -halfSize, -halfSize, halfSize, halfSize, halfSize)
        -- Wings
        love.graphics.setColor(0.8, 0, 0)  -- Dark red
        love.graphics.rectangle("fill", -halfSize*1.5, -halfSize*0.3, halfSize, halfSize*0.6)
        love.graphics.rectangle("fill", halfSize*0.5, -halfSize*0.3, halfSize, halfSize*0.6)
        
    elseif iconType == "ufo_landed" then
        -- Landed UFO: Red dome on ground
        love.graphics.setColor(1, 0, 0)  -- Red
        -- Dome
        love.graphics.arc("fill", 0, -halfSize*0.5, halfSize, math.pi, 0)
        -- Base
        love.graphics.rectangle("fill", -halfSize, -halfSize*0.5, size, halfSize*0.3)
        
    elseif iconType == "alien_site" then
        -- Alien Site: Orange building
        love.graphics.setColor(1, 0.5, 0)  -- Orange
        -- Main building
        love.graphics.rectangle("fill", -halfSize, -halfSize, size, size)
        -- Roof
        love.graphics.setColor(0.8, 0.3, 0)  -- Dark orange
        love.graphics.polygon("fill", -halfSize*1.2, -halfSize, 0, -halfSize*1.5, halfSize*1.2, -halfSize)
        
    elseif iconType == "alien_base_underground" then
        -- Underground Base: Purple bunker
        love.graphics.setColor(0.8, 0, 0.8)  -- Purple
        -- Bunker entrance
        love.graphics.rectangle("fill", -halfSize, -halfSize*0.5, size, halfSize)
        -- Underground indicator (lines)
        love.graphics.setColor(0.6, 0, 0.6)  -- Dark purple
        for i = 1, 3 do
            local yOffset = halfSize * 0.2 * i
            love.graphics.line(-halfSize, yOffset, halfSize, yOffset)
        end
        
    elseif iconType == "alien_base_underwater" then
        -- Underwater Base: Purple dome with bubbles
        love.graphics.setColor(0.8, 0, 0.8)  -- Purple
        -- Dome
        love.graphics.arc("fill", 0, 0, halfSize, 0, math.pi)
        -- Bubbles
        love.graphics.setColor(0.9, 0.9, 1, 0.7)  -- Light blue bubbles
        love.graphics.circle("fill", -halfSize*0.3, -halfSize*0.3, halfSize*0.2)
        love.graphics.circle("fill", halfSize*0.4, -halfSize*0.5, halfSize*0.15)
        
    else
        -- Unknown mission: White question mark
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", 0, 0, halfSize)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("?", -3, -6)
    end
    
    -- Draw outline for all icons
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", 0, 0, halfSize + 2)
    
    love.graphics.pop()
end

---Draw mission tooltip
---@param mission table Mission instance
function GeoscapeRenderer:drawMissionTooltip(mission)
    local mouseX, mouseY = love.mouse.getPosition()
    
    -- Build tooltip text
    local info = mission:getInfo()
    local text = string.format("%s\nType: %s | Difficulty: %d\nPower: %d | State: %s\nDays Active: %d | Biome: %s",
        info.name,
        info.type,
        info.difficulty,
        info.power,
        info.state,
        info.daysActive,
        info.biome
    )
    
    -- Draw tooltip background
    love.graphics.push()
    love.graphics.origin()
    
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight() * 7  -- 7 lines
    
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", mouseX + 10, mouseY + 10, textWidth + 10, textHeight + 10)
    
    -- Draw tooltip text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, mouseX + 15, mouseY + 15)
    
    love.graphics.pop()
end

return GeoscapeRenderer

























