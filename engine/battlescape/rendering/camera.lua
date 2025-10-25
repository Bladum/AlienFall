--- Camera Controller
--- Manages camera position, zoom, and viewport for battlefield navigation.
---
--- This module handles camera movement, zooming, and coordinate transformations
--- between screen and world space. Supports mouse dragging, keyboard movement,
--- and centering on units or positions.
---
--- Example usage:
---   local camera = Camera.new(0, 0)
---   camera:centerOn(unit.x, unit.y, 24, screenWidth/2, screenHeight/2)
---   camera:zoomBy(1.2)
---   local worldX, worldY = camera:screenToWorld(mouseX, mouseY)

--- @class Camera
--- @field x number Camera X position in screen space
--- @field y number Camera Y position in screen space
--- @field speed number Movement speed in pixels per key press
--- @field zoom number Current zoom level (1.0 = normal)
--- @field minZoom number Minimum allowed zoom level
--- @field maxZoom number Maximum allowed zoom level
--- @field isDragging boolean Whether mouse drag is active
--- @field lastMouseX number Last mouse X position during drag
--- @field lastMouseY number Last mouse Y position during drag
local Camera = {}
Camera.__index = Camera

--- Create a new camera instance.
---
--- @param x number Initial X position (default: 0)
--- @param y number Initial Y position (default: 0)
--- @return table New Camera instance
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

--- Start mouse drag operation.
---
--- Records starting mouse position for drag calculations.
---
--- @param mouseX number Current mouse X position
--- @param mouseY number Current mouse Y position
--- @return nil
function Camera:startDrag(mouseX, mouseY)
    self.isDragging = true
    self.lastMouseX = mouseX
    self.lastMouseY = mouseY
end

--- Update camera position during mouse drag.
---
--- Moves camera by difference between current and last mouse positions.
---
--- @param mouseX number Current mouse X position
--- @param mouseY number Current mouse Y position
--- @return nil
function Camera:updateDrag(mouseX, mouseY)
    if self.isDragging then
        local dx = mouseX - self.lastMouseX
        local dy = mouseY - self.lastMouseY
        self:move(dx, dy)
        self.lastMouseX = mouseX
        self.lastMouseY = mouseY
    end
end

--- Stop mouse drag operation.
---
--- @return nil
function Camera:stopDrag()
    self.isDragging = false
end

--- Set zoom level with bounds checking.
---
--- Clamps zoom between minZoom and maxZoom.
---
--- @param zoom number Desired zoom level
--- @return nil
function Camera:setZoom(zoom)
    self.zoom = math.max(self.minZoom, math.min(self.maxZoom, zoom))
end

--- Zoom in or out by a multiplicative factor.
---
--- @param factor number Zoom multiplier (e.g., 1.2 for 20% zoom in)
--- @return nil
function Camera:zoomBy(factor)
    self:setZoom(self.zoom * factor)
end

--- Zoom in/out centered on a specific point.
---
--- Adjusts camera position to keep the center point fixed during zoom.
---
--- @param factor number Zoom multiplier
--- @param centerX number X coordinate to keep centered
--- @param centerY number Y coordinate to keep centered
--- @return nil
function Camera:zoomAt(factor, centerX, centerY)
    local oldZoom = self.zoom
    self:zoomBy(factor)

    -- Adjust position to keep the center point fixed
    local zoomRatio = self.zoom / oldZoom
    self.x = centerX - (centerX - self.x) * zoomRatio
    self.y = centerY - (centerY - self.y) * zoomRatio
end

--- Move camera by delta amounts.
---
--- @param dx number Change in X position
--- @param dy number Change in Y position
--- @return nil
function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

--- Set camera position directly.
---
--- @param x number New X position
--- @param y number New Y position
--- @return nil
function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

--- Center camera on a tile position.
---
--- Positions camera so the specified tile is at the center of the screen.
--- Accounts for hex grid offset on even/odd columns.
---
--- @param tileX number Tile X coordinate
--- @param tileY number Tile Y coordinate
--- @param tileSize number Size of each tile in pixels
--- @param centerX number Screen X coordinate to center on
--- @param centerY number Screen Y coordinate to center on
--- @return nil
function Camera:centerOn(tileX, tileY, tileSize, centerX, centerY)
    local worldX = tileX * tileSize
    local worldY = tileY * tileSize
    -- Account for hex grid offset
    local offsetY = (tileX % 2 == 0) and (tileSize * self.zoom * 0.5) or 0
    self.x = centerX - worldX * self.zoom
    self.y = centerY - (worldY + offsetY) * self.zoom
end

--- Convert screen coordinates to world coordinates.
---
--- @param screenX number Screen X coordinate
--- @param screenY number Screen Y coordinate
--- @return number, number World X, Y coordinates
function Camera:screenToWorld(screenX, screenY)
    return (screenX - self.x) / self.zoom, (screenY - self.y) / self.zoom
end

--- Convert world coordinates to screen coordinates.
---
--- @param worldX number World X coordinate
--- @param worldY number World Y coordinate
--- @return number, number Screen X, Y coordinates
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


























