-- Scaling utilities for responsive UI
-- Handles scaling between base resolution (960x720) and current window size

local Scaling = {}

-- Base resolution constants
Scaling.BASE_WIDTH = 960
Scaling.BASE_HEIGHT = 720
Scaling.BASE_GUI_WIDTH = 240  -- 10 columns
Scaling.BASE_GUI_HEIGHT = 720 -- 30 rows
Scaling.BASE_FRAME_HEIGHT = 240 -- 10 rows
Scaling.BASE_TILE_SIZE = 24

-- Current scale factors
Scaling.scaleX = 1.0
Scaling.scaleY = 1.0
Scaling.scaleMin = 1.0 -- Use minimum scale to maintain aspect ratio

-- Update scale factors based on current window size
function Scaling.update()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    Scaling.scaleX = windowWidth / Scaling.BASE_WIDTH
    Scaling.scaleY = windowHeight / Scaling.BASE_HEIGHT
    Scaling.scaleMin = math.min(Scaling.scaleX, Scaling.scaleY)

    print(string.format("[Scaling] Window: %dx%d, Scale: %.2fx%.2f (min: %.2f)",
        windowWidth, windowHeight, Scaling.scaleX, Scaling.scaleY, Scaling.scaleMin))
end

-- Scale a value by the minimum scale factor (maintains aspect ratio)
function Scaling.scale(value)
    return value * Scaling.scaleMin
end

-- Scale X coordinate
function Scaling.scaleCoordX(value)
    return value * Scaling.scaleX
end

-- Scale Y coordinate
function Scaling.scaleCoordY(value)
    return value * Scaling.scaleY
end

-- Get scaled GUI dimensions
function Scaling.getGUIDimensions()
    return {
        width = Scaling.scale(Scaling.BASE_GUI_WIDTH),
        height = Scaling.scale(Scaling.BASE_GUI_HEIGHT),
        frameHeight = Scaling.scale(Scaling.BASE_FRAME_HEIGHT)
    }
end

-- Get scaled tile size
function Scaling.getTileSize()
    return Scaling.scale(Scaling.BASE_TILE_SIZE)
end

return Scaling