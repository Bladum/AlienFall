---Grid System - 24×24 Pixel Grid Alignment
---
---Provides grid-based positioning and snapping for widgets. ALL widgets MUST align
---to the 24×24 pixel grid for consistent UI layout.
---
---Grid Specification:
---  - Resolution: 960×720 pixels
---  - Grid Size: 24×24 pixels per cell
---  - Columns: 40 (960 / 24)
---  - Rows: 30 (720 / 24)
---  - Total Cells: 1200 (40 × 30)
---
---Grid Coordinates:
---  - (0, 0): Top-left corner (pixel 0, 0)
---  - (39, 29): Bottom-right corner (pixel 936, 696)
---  - Column 5, Row 3: Pixel position (120, 72)
---
---Snapping Functions:
---  - snapToGrid(x, y): Snaps pixel position to nearest grid cell
---  - snapSize(width, height): Rounds size to multiple of 24
---  - gridToPixels(col, row): Converts grid coordinates to pixels
---  - pixelsToGrid(x, y): Converts pixels to grid coordinates
---
---Debug Features:
---  - F9: Toggle grid overlay (shows all grid lines)
---  - Grid overlay: Green lines, red crosshairs at mouse
---  - Grid coordinates displayed in corner
---
---Key Exports:
---  - Grid.CELL_SIZE: 24 (grid cell size in pixels)
---  - Grid.COLS: 40 (number of columns)
---  - Grid.ROWS: 30 (number of rows)
---  - Grid.snapToGrid(x, y): Returns grid-aligned x, y
---  - Grid.snapSize(width, height): Returns grid-aligned dimensions
---  - Grid.gridToPixels(col, row): Returns pixel position
---  - Grid.pixelsToGrid(x, y): Returns grid coordinates
---  - Grid.drawGrid(): Renders debug grid overlay
---
---Dependencies: None (pure math library)
---
---@module widgets.core.grid
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Grid = require("widgets.core.grid")
---  local x, y = Grid.snapToGrid(123, 456)  -- Returns (120, 456)
---  local w, h = Grid.snapSize(97, 50)  -- Returns (96, 48)
---  Grid.drawGrid()  -- Draw debug overlay (F9 to toggle)
---
---@see widgets.core.base For widget implementation

--[[
    Grid System
    
    Provides grid-based positioning and snapping for widgets.
    All widgets MUST align to a 24×24 pixel grid.
    
    Resolution: 960×720 pixels (40 columns × 30 rows)
    Grid Cell Size: 24×24 pixels
]]

local Grid = {}

-- Grid constants
Grid.CELL_SIZE = 24
Grid.COLS = 40  -- 960 / 24
Grid.ROWS = 30  -- 720 / 24
Grid.WIDTH = Grid.COLS * Grid.CELL_SIZE   -- 960
Grid.HEIGHT = Grid.ROWS * Grid.CELL_SIZE  -- 720

-- Debug overlay state
Grid.debugEnabled = false
Grid.scaleX = 1
Grid.scaleY = 1

--[[
    Snap a position to the nearest grid point
    @param x number - X coordinate in pixels
    @param y number - Y coordinate in pixels
    @return number, number - Grid-aligned X and Y coordinates
]]
function Grid.snapToGrid(x, y)
    local gridX = math.floor((x + Grid.CELL_SIZE / 2) / Grid.CELL_SIZE) * Grid.CELL_SIZE
    local gridY = math.floor((y + Grid.CELL_SIZE / 2) / Grid.CELL_SIZE) * Grid.CELL_SIZE
    return gridX, gridY
end

--[[
    Snap a size to grid-aligned dimensions
    @param width number - Width in pixels
    @param height number - Height in pixels
    @return number, number - Grid-aligned width and height
]]
function Grid.snapSize(width, height)
    local gridWidth = math.max(Grid.CELL_SIZE, math.floor((width + Grid.CELL_SIZE / 2) / Grid.CELL_SIZE) * Grid.CELL_SIZE)
    local gridHeight = math.max(Grid.CELL_SIZE, math.floor((height + Grid.CELL_SIZE / 2) / Grid.CELL_SIZE) * Grid.CELL_SIZE)
    return gridWidth, gridHeight
end

--[[
    Convert grid coordinates to pixel coordinates
    @param col number - Column index (0-based)
    @param row number - Row index (0-based)
    @return number, number - Pixel X and Y coordinates
]]
function Grid.gridToPixels(col, row)
    return col * Grid.CELL_SIZE, row * Grid.CELL_SIZE
end

--[[
    Convert pixel coordinates to grid coordinates
    @param x number - X coordinate in pixels
    @param y number - Y coordinate in pixels
    @return number, number - Column and row indices
]]
function Grid.pixelsToGrid(x, y)
    return math.floor(x / Grid.CELL_SIZE), math.floor(y / Grid.CELL_SIZE)
end

--[[
    Check if a position is exactly on the grid
    @param x number - X coordinate in pixels
    @param y number - Y coordinate in pixels
    @return boolean - True if position is grid-aligned
]]
function Grid.isOnGrid(x, y)
    return (x % Grid.CELL_SIZE == 0) and (y % Grid.CELL_SIZE == 0)
end

--[[
    Check if a size is grid-aligned
    @param width number - Width in pixels
    @param height number - Height in pixels
    @return boolean - True if size is grid-aligned
]]
function Grid.isValidSize(width, height)
    return (width % Grid.CELL_SIZE == 0) and (height % Grid.CELL_SIZE == 0)
end

--[[
    Toggle debug grid overlay (F9 key)
]]
function Grid.toggleDebug()
    Grid.debugEnabled = not Grid.debugEnabled
    if Grid.debugEnabled then
        print("[Grid] Debug overlay enabled (F9 to toggle)")
    else
        print("[Grid] Debug overlay disabled")
    end
end

--[[
    Set grid scale for fullscreen mode
    @param scaleX number - X scale factor
    @param scaleY number - Y scale factor
]]
function Grid.setScale(scaleX, scaleY)
    Grid.scaleX = scaleX or 1
    Grid.scaleY = scaleY or 1
end

--[[
    Reset grid scale to default
]]
function Grid.resetScale()
    Grid.scaleX = 1
    Grid.scaleY = 1
end

--[[
    Draw debug grid overlay
    Call this at the end of love.draw() to show the grid
]]
function Grid.drawDebug()
    if not Grid.debugEnabled then
        return
    end
    
    -- Save current color
    local r, g, b, a = love.graphics.getColor()
    
    -- Draw grid lines
    love.graphics.setColor(0, 1, 0, 0.3)  -- Green with transparency
    love.graphics.setLineWidth(1)
    
    -- Vertical lines
    for col = 0, Grid.COLS do
        local x = col * Grid.CELL_SIZE
        love.graphics.line(x, 0, x, Grid.HEIGHT)
    end
    
    -- Horizontal lines
    for row = 0, Grid.ROWS do
        local y = row * Grid.CELL_SIZE
        love.graphics.line(0, y, Grid.WIDTH, y)
    end
    
    -- Draw mouse position and grid coordinates
    local mx, my = love.mouse.getPosition()
    
    -- Account for scaling in fullscreen mode
    mx = mx / Grid.scaleX
    my = my / Grid.scaleY
    
    local gridCol, gridRow = Grid.pixelsToGrid(mx, my)
    local snapX, snapY = Grid.snapToGrid(mx, my)
    
    -- Draw crosshair at mouse position
    love.graphics.setColor(1, 0, 0, 0.8)  -- Red
    love.graphics.setLineWidth(2)
    love.graphics.line(mx - 10, my, mx + 10, my)
    love.graphics.line(mx, my - 10, mx, my + 10)
    
    -- Draw grid info in corner
    love.graphics.setColor(1, 1, 1, 1)  -- White
    love.graphics.print(string.format(
        "Grid: %d×%d (%d×%d px)\nMouse: (%.0f, %.0f)\nGrid: (%d, %d)\nSnap: (%.0f, %.0f)",
        Grid.COLS, Grid.ROWS, Grid.WIDTH, Grid.HEIGHT,
        mx, my,
        gridCol, gridRow,
        snapX, snapY
    ), 10, 10)
    
    -- Restore original color
    love.graphics.setColor(r, g, b, a)
end

print("[Grid] Grid system loaded - " .. Grid.COLS .. "×" .. Grid.ROWS .. " cells (" .. Grid.WIDTH .. "×" .. Grid.HEIGHT .. " pixels)")

return Grid






















