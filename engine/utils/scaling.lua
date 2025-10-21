---Scaling Utilities for Responsive UI
---
---Handles UI scaling calculations for responsive interface design. Computes scale
---factors between base resolution (960×720) and current window size. Maintains
---aspect ratio and grid alignment while supporting dynamic window resizing.
---
---Base Resolution:
---  - Width: 960 pixels (40 columns × 24px)
---  - Height: 720 pixels (30 rows × 24px)
---  - GUI Width: 240 pixels (10 columns × 24px)
---  - Tile Size: 24 pixels per grid cell
---
---Key Exports:
---  - Scaling.update(): Recalculates scale factors for current window
---  - Scaling.scaleX: Horizontal scale factor
---  - Scaling.scaleY: Vertical scale factor
---  - Scaling.scaleMin: Minimum scale (maintains aspect ratio)
---  - Scaling.scale(value): Scales value by scaleMin
---
---Dependencies:
---  - love.window: Window dimensions
---
---@module utils.scaling
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Scaling = require("utils.scaling")
---  Scaling.update()  -- Call on window resize
---  local scaledSize = Scaling.scale(100)  -- Scale a value
---  love.graphics.scale(Scaling.scaleMin, Scaling.scaleMin)
---
---@see utils.viewport For viewport calculations
---@see main For window resize handling

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
























