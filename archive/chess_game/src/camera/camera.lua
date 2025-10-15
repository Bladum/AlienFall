-- Camera system for panning and zooming
local Constants = require("src.core.constants")

local Camera = {}
Camera.__index = Camera

function Camera.new(x, y, zoom)
    local self = setmetatable({}, Camera)
    
    self.x = x or 0
    self.y = y or 0
    self.zoom = zoom or 1.0
    self.targetZoom = self.zoom
    
    -- Camera bounds (set by board size)
    self.minX = 0
    self.minY = 0
    self.maxX = 1000
    self.maxY = 1000
    
    -- Pan state
    self.isPanning = false
    self.panStartX = 0
    self.panStartY = 0
    self.panStartCamX = 0
    self.panStartCamY = 0
    
    return self
end

function Camera:setBounds(boardWidth, boardHeight, tileSize)
    self.maxX = boardWidth * tileSize
    self.maxY = boardHeight * tileSize
end

function Camera:update(dt)
    -- Smooth zoom
    if math.abs(self.zoom - self.targetZoom) > 0.01 then
        self.zoom = self.zoom + (self.targetZoom - self.zoom) * 10 * dt
    else
        self.zoom = self.targetZoom
    end
    
    -- Clamp zoom
    self.zoom = math.max(Constants.CAMERA_MIN_ZOOM, math.min(Constants.CAMERA_MAX_ZOOM, self.zoom))
    self.targetZoom = math.max(Constants.CAMERA_MIN_ZOOM, math.min(Constants.CAMERA_MAX_ZOOM, self.targetZoom))
    
    -- Clamp camera position
    self.x = math.max(self.minX, math.min(self.maxX - Constants.WINDOW_WIDTH / self.zoom, self.x))
    self.y = math.max(self.minY, math.min(self.maxY - Constants.WINDOW_HEIGHT / self.zoom, self.y))
end

function Camera:worldToScreen(worldX, worldY)
    return (worldX - self.x) * self.zoom, (worldY - self.y) * self.zoom
end

function Camera:screenToWorld(screenX, screenY)
    return screenX / self.zoom + self.x, screenY / self.zoom + self.y
end

function Camera:startPan(mouseX, mouseY)
    self.isPanning = true
    self.panStartX = mouseX
    self.panStartY = mouseY
    self.panStartCamX = self.x
    self.panStartCamY = self.y
end

function Camera:updatePan(mouseX, mouseY)
    if self.isPanning then
        local dx = (mouseX - self.panStartX) / self.zoom
        local dy = (mouseY - self.panStartY) / self.zoom
        self.x = self.panStartCamX - dx
        self.y = self.panStartCamY - dy
    end
end

-- Pan by a delta in screen coordinates (useful for mousemove dx/dy)
function Camera:panBy(screenDx, screenDy)
    self.x = self.x - (screenDx / self.zoom)
    self.y = self.y - (screenDy / self.zoom)
    -- clamp
    self.x = math.max(self.minX, math.min(self.maxX - Constants.WINDOW_WIDTH / self.zoom, self.x))
    self.y = math.max(self.minY, math.min(self.maxY - Constants.WINDOW_HEIGHT / self.zoom, self.y))
end

function Camera:endPan()
    self.isPanning = false
end

function Camera:zoom_in()
    self.targetZoom = self.targetZoom + Constants.CAMERA_ZOOM_SPEED
end

function Camera:zoom_out()
    self.targetZoom = self.targetZoom - Constants.CAMERA_ZOOM_SPEED
end

function Camera:wheelMoved(dy)
    if dy > 0 then
        self:zoom_in()
    else
        self:zoom_out()
    end
end

return Camera






















