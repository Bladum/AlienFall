-- Camera Controller
-- Manages camera position and viewport for battlefield

local Camera = {}
Camera.__index = Camera

-- Create a new camera
function Camera.new(x, y)
    local self = setmetatable({}, Camera)
    
    self.x = x or 0
    self.y = y or 0
    self.speed = 50  -- Pixels per key press
    self.zoom = 1.0
    self.minZoom = 0.25
    self.maxZoom = 2.0
    
    -- Mouse drag state
    self.isDragging = false
    self.lastMouseX = 0
    self.lastMouseY = 0
    
    return self
end

-- Start mouse drag
function Camera:startDrag(mouseX, mouseY)
    self.isDragging = true
    self.lastMouseX = mouseX
    self.lastMouseY = mouseY
end

-- Update mouse drag
function Camera:updateDrag(mouseX, mouseY)
    if self.isDragging then
        local dx = mouseX - self.lastMouseX
        local dy = mouseY - self.lastMouseY
        self:move(dx, dy)
        self.lastMouseX = mouseX
        self.lastMouseY = mouseY
    end
end

-- Stop mouse drag
function Camera:stopDrag()
    self.isDragging = false
end

-- Set zoom level
function Camera:setZoom(zoom)
    self.zoom = math.max(self.minZoom, math.min(self.maxZoom, zoom))
end

-- Zoom in/out by factor
function Camera:zoomBy(factor)
    self:setZoom(self.zoom * factor)
end

-- Zoom in/out centered on a point
function Camera:zoomAt(factor, centerX, centerY)
    local oldZoom = self.zoom
    self:zoomBy(factor)
    
    -- Adjust position to keep the center point fixed
    local zoomRatio = self.zoom / oldZoom
    self.x = centerX - (centerX - self.x) * zoomRatio
    self.y = centerY - (centerY - self.y) * zoomRatio
end

-- Move camera by delta
function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

-- Set camera position
function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Center camera on position (in tile coordinates)
function Camera:centerOn(tileX, tileY, tileSize, centerX, centerY)
    local worldX = tileX * tileSize
    local worldY = tileY * tileSize
    -- Account for hex grid offset
    local offsetY = (tileX % 2 == 0) and (tileSize * self.zoom * 0.5) or 0
    self.x = centerX - worldX * self.zoom
    self.y = centerY - (worldY + offsetY) * self.zoom
end

-- Convert screen coordinates to world coordinates
function Camera:screenToWorld(screenX, screenY)
    return (screenX - self.x) / self.zoom, (screenY - self.y) / self.zoom
end

-- Convert world coordinates to screen coordinates
function Camera:worldToScreen(worldX, worldY)
    return worldX * self.zoom + self.x, worldY * self.zoom + self.y
end

-- Get visible tile bounds
function Camera:getVisibleBounds(screenWidth, screenHeight, tileSize, mapWidth, mapHeight)
    local worldLeft, worldTop = self:screenToWorld(0, 0)
    local worldRight, worldBottom = self:screenToWorld(screenWidth, screenHeight)
    
    return {
        minX = math.max(1, math.floor(worldLeft / tileSize) + 1),
        minY = math.max(1, math.floor(worldTop / tileSize) + 1),
        maxX = math.min(mapWidth or 60, math.ceil(worldRight / tileSize)),
        maxY = math.min(mapHeight or 60, math.ceil(worldBottom / tileSize))
    }
end

-- Handle keyboard movement
function Camera:handleKeyboard(dt)
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        self:move(0, self.speed)
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        self:move(0, -self.speed)
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self:move(self.speed, 0)
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self:move(-self.speed, 0)
    end
end

return Camera
