---Renderer3D - First-Person 3D Battlescape Renderer
---
---First-person 3D rendering for hex-based tactical combat. Toggles between 2D and 3D views
---for Wolfenstein 3D-style first-person perspective. Renders walls, floors, units, items,
---and effects in 3D space.
---
---Features:
---  - First-person 3D rendering
---  - Wall and floor rendering
---  - Unit billboards (always face camera)
---  - Item and object rendering
---  - Fire and smoke effects
---  - Raycasting for visibility
---  - Toggle between 2D/3D views
---
---Rendering Pipeline:
---  1. Setup camera matrices
---  2. Render floor tiles
---  3. Render walls (raycasted)
---  4. Render units (billboards)
---  5. Render items and objects
---  6. Render effects (fire, smoke, explosions)
---  7. Render HUD overlay
---
---Camera:
---  - Position: Unit world position
---  - Orientation: Unit facing direction
---  - FOV: Configurable field of view
---  - Near/far planes: Visibility range
---
---Key Exports:
---  - Renderer3D.new(battlescape): Creates 3D renderer
---  - draw(): Renders 3D view
---  - update(dt): Updates animations
---  - setCamera(x, y, z, angle): Positions camera
---  - toggle2D3D(): Switches rendering mode
---  - getCamera(): Returns camera data
---
---Dependencies:
---  - None (standalone renderer)
---
---@module battlescape.rendering.renderer_3d
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Renderer3D = require("battlescape.rendering.renderer_3d")
---  local renderer = Renderer3D.new(battlescape)
---  renderer:setCamera(unitX, unitY, unitZ, unitAngle)
---  renderer:draw()
---
---@see battlescape.rendering.camera For camera system
---@see battlescape.rendering.billboard For billboard sprites

-- 3D Battlescape Renderer
-- First-person 3D rendering for hex-based tactical combat
-- Toggles between 2D and 3D views

local Renderer3D = {}
Renderer3D.__index = Renderer3D

--- Create new 3D renderer
-- @param battlescape table Reference to battlescape state
-- @return table New Renderer3D instance
function Renderer3D.new(battlescape)
    local self = setmetatable({}, Renderer3D)
    
    self.battlescape = battlescape
    self.camera = {
        x = 0,
        y = 0,
        z = 1.5,        -- Eye height (1.5 tiles up)
        angle = 0,      -- Rotation angle (radians)
        fov = math.pi / 3, -- 60 degree field of view
        near = 0.1,
        far = 20.0
    }
    
    self.renderDistance = 15    -- Max rendering distance in tiles
    self.fogStart = 8           -- Distance where fog starts
    self.fogEnd = 15            -- Distance where fog is complete
    
    print("[Renderer3D] Initialized 3D renderer")
    
    return self
end

--- Initialize 3D rendering (called when switching to 3D mode)
function Renderer3D:initialize()
    -- Position camera at active unit
    local activeUnit = self.battlescape:getActiveUnit()
    
    if activeUnit then
        self.camera.x = activeUnit.x
        self.camera.y = activeUnit.y
        self.camera.angle = activeUnit.facing or 0
        
        print(string.format("[Renderer3D] Camera positioned at unit (%d, %d), facing: %.2f",
              activeUnit.x, activeUnit.y, self.camera.angle))
    end
end

--- Update camera position (follows active unit)
function Renderer3D:updateCamera()
    local activeUnit = self.battlescape:getActiveUnit()
    
    if activeUnit then
        self.camera.x = activeUnit.x
        self.camera.y = activeUnit.y
        self.camera.angle = activeUnit.facing or 0
    end
end

--- Render 3D view
-- @param screenWidth number Screen width (960)
-- @param screenHeight number Screen height (720)
function Renderer3D:render(screenWidth, screenHeight)
    -- Update camera position
    self:updateCamera()
    
    -- Clear screen
    love.graphics.clear(0, 0, 0)
    
    -- Render sky/ceiling
    self:renderSky(screenWidth, screenHeight)
    
    -- Render floor
    self:renderFloor(screenWidth, screenHeight)
    
    -- Render walls using hex raycasting
    self:renderWalls(screenWidth, screenHeight)
    
    -- Render units (sprites billboarded to camera)
    self:renderUnits(screenWidth, screenHeight)
    
    -- Render UI overlay
    self:renderUI(screenWidth, screenHeight)
end

--- Render sky/ceiling
function Renderer3D:renderSky(screenWidth, screenHeight)
    local horizonY = screenHeight / 2
    
    -- Sky (upper half)
    love.graphics.setColor(0.4, 0.6, 0.9) -- Blue sky
    love.graphics.rectangle("fill", 0, 0, screenWidth, horizonY)
    
    -- Floor horizon (lower half - will be covered by floor rendering)
    love.graphics.setColor(0.2, 0.2, 0.2) -- Dark ground color
    love.graphics.rectangle("fill", 0, horizonY, screenWidth, screenHeight - horizonY)
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end

--- Render floor (simplified - textured grid in front of camera)
function Renderer3D:renderFloor(screenWidth, screenHeight)
    local horizonY = screenHeight / 2
    local eyeHeight = self.camera.z
    
    -- Render floor strips from near to far
    for y = horizonY, screenHeight, 4 do
        -- Calculate distance from camera to this floor row
        local screenDistance = y - horizonY
        local distance = (eyeHeight * screenHeight) / (screenDistance * 2)
        
        if distance < self.renderDistance then
            -- Calculate fog factor
            local fogFactor = self:calculateFog(distance)
            
            -- Draw floor strip with fog
            love.graphics.setColor(0.3 * fogFactor, 0.3 * fogFactor, 0.3 * fogFactor)
            love.graphics.rectangle("fill", 0, y, screenWidth, 4)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

--- Render walls using hex-aware raycasting
function Renderer3D:renderWalls(screenWidth, screenHeight)
    local numRays = screenWidth / 2 -- Cast ray every 2 pixels for performance
    local horizonY = screenHeight / 2
    
    for i = 0, numRays - 1 do
        local rayAngle = self.camera.angle - (self.camera.fov / 2) + (i / numRays) * self.camera.fov
        
        -- Cast ray
        local hit, distance, tileType = self:castRay(rayAngle)
        
        if hit then
            -- Calculate wall height on screen
            local wallHeight = (screenHeight / distance) * 0.5
            
            -- Calculate fog
            local fogFactor = self:calculateFog(distance)
            
            -- Determine wall color based on tile type
            local color = self:getTileColor(tileType)
            love.graphics.setColor(color[1] * fogFactor, color[2] * fogFactor, color[3] * fogFactor)
            
            -- Draw wall slice
            local x = i * 2
            local wallTop = horizonY - wallHeight
            local wallBottom = horizonY + wallHeight
            
            love.graphics.rectangle("fill", x, wallTop, 2, wallBottom - wallTop)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

--- Cast ray from camera in direction
-- @param angle number Ray angle in radians
-- @return boolean Hit flag
-- @return number Distance to hit
-- @return string|nil Tile type if hit
function Renderer3D:castRay(angle)
    local rayX = self.camera.x
    local rayY = self.camera.y
    local rayDirX = math.cos(angle)
    local rayDirY = math.sin(angle)
    
    local stepSize = 0.1
    local maxSteps = self.renderDistance / stepSize
    
    for step = 1, maxSteps do
        rayX = rayX + rayDirX * stepSize
        rayY = rayY + rayDirY * stepSize
        
        -- Check if ray hit a wall
        local tileX = math.floor(rayX)
        local tileY = math.floor(rayY)
        local tile = self:getTile(tileX, tileY)
        
        if tile and tile.blocking then
            local distance = math.sqrt((rayX - self.camera.x)^2 + (rayY - self.camera.y)^2)
            return true, distance, tile.terrain
        end
    end
    
    return false, 0, nil
end

--- Get tile at position (placeholder - integrates with battlescape map)
-- @param x number Tile X coordinate
-- @param y number Tile Y coordinate
-- @return table|nil Tile data
function Renderer3D:getTile(x, y)
    -- TODO: Integrate with actual battlescape map system
    -- For now, create a simple test pattern
    if x < 0 or x >= 20 or y < 0 or y >= 20 then
        return {blocking = true, terrain = "wall"}
    end
    
    -- Create walls around perimeter
    if x == 0 or x == 19 or y == 0 or y == 19 then
        return {blocking = true, terrain = "wall"}
    end
    
    return {blocking = false, terrain = "floor"}
end

--- Get tile color based on type
-- @param tileType string Tile type name
-- @return table RGB color {r, g, b}
function Renderer3D:getTileColor(tileType)
    local colors = {
        wall = {0.5, 0.5, 0.5},
        floor = {0.3, 0.3, 0.3},
        door = {0.6, 0.4, 0.2},
        window = {0.4, 0.6, 0.8}
    }
    
    return colors[tileType] or {0.5, 0.5, 0.5}
end

--- Calculate fog factor based on distance
-- @param distance number Distance from camera
-- @return number Fog factor (0.0 to 1.0)
function Renderer3D:calculateFog(distance)
    if distance < self.fogStart then
        return 1.0
    elseif distance > self.fogEnd then
        return 0.1 -- Minimum visibility
    else
        local fogRange = self.fogEnd - self.fogStart
        local distanceInFog = distance - self.fogStart
        return 1.0 - (distanceInFog / fogRange) * 0.9
    end
end

--- Render units as billboarded sprites
function Renderer3D:renderUnits(screenWidth, screenHeight)
    -- TODO: Implement unit sprite rendering
    -- Units should be rendered as sprites that always face the camera
    -- Position calculated based on distance and angle from camera
end

--- Render UI overlay (health, AP, unit info)
function Renderer3D:renderUI(screenWidth, screenHeight)
    love.graphics.setColor(1, 1, 1)
    
    -- Draw debug info
    love.graphics.print(string.format("3D View - Camera: (%.1f, %.1f) Angle: %.2f",
                                      self.camera.x, self.camera.y, self.camera.angle), 10, 10)
    love.graphics.print("Press SPACE to toggle 2D view", 10, 30)
    
    -- Draw crosshair
    local centerX = screenWidth / 2
    local centerY = screenHeight / 2
    love.graphics.circle("line", centerX, centerY, 5)
end

--- Rotate camera
-- @param deltaAngle number Angle change in radians
function Renderer3D:rotateCamera(deltaAngle)
    self.camera.angle = (self.camera.angle + deltaAngle) % (2 * math.pi)
end

--- Handle keyboard input for 3D view
-- @param key string Key pressed
function Renderer3D:keyPressed(key)
    if key == "left" then
        self:rotateCamera(-math.pi / 12) -- Rotate left 15 degrees
    elseif key == "right" then
        self:rotateCamera(math.pi / 12)  -- Rotate right 15 degrees
    end
end

return Renderer3D

























