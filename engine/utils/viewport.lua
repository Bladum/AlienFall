---Viewport System for Dynamic Resolution
---
---Manages viewport calculations for dynamic window resolution while maintaining
---fixed GUI sizing. Separates coordinate systems for GUI (always 240×720) and
---battlefield (scales with window). Handles fullscreen, window resizing, and
---proper coordinate translation between screen and game space.
---
---Resolution System:
---  - GUI: Fixed 240×720 pixels (10×30 grid cells at 24px)
---  - Battlefield: Dynamic, fills remaining window space
---  - Base Resolution: 960×720 (40×30 grid)
---  - Grid System: 24×24 pixels per cell
---  - Minimum: 960×720 (ensures GUI fits)
---
---Key Exports:
---  - Viewport.getBattlefieldViewport(): Returns battlefield dimensions
---  - Viewport.getGUIViewport(): Returns GUI panel dimensions
---  - Viewport.screenToWorld(x, y): Converts screen to world coords
---  - Viewport.worldToScreen(x, y): Converts world to screen coords
---  - Viewport.getScale(): Returns current scale factor
---  - Viewport.printInfo(): Displays viewport information
---
---Dependencies:
---  - love.window: Window dimensions and properties
---  - love.graphics: Rendering transformations
---
---@module utils.viewport
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Viewport = require("utils.viewport")
---  local bfX, bfY, bfW, bfH = Viewport.getBattlefieldViewport()
---  local worldX, worldY = Viewport.screenToWorld(mouseX, mouseY)
---  Viewport.printInfo()  -- Debug viewport state
---
---@see main For window resize handling
---@see battlescape.rendering.camera For battlefield camera

local Viewport = {}

-- GUI Constants (Always Fixed Size)
Viewport.GUI_WIDTH = 240   -- 10 tiles × 24px
Viewport.GUI_HEIGHT = 720  -- 30 tiles × 24px
Viewport.TILE_SIZE = 24

-- Section heights for GUI panels
Viewport.SECTION_HEIGHT = 240  -- Each GUI section is 10 tiles tall

--[[
    Get the battlefield viewport dimensions
    Returns the area available for battlefield rendering after GUI space
    @return number x - Starting X position (always GUI_WIDTH)
    @return number y - Starting Y position (always 0)
    @return number width - Available width for battlefield
    @return number height - Available height for battlefield
]]
function Viewport.getBattlefieldViewport()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    local x = Viewport.GUI_WIDTH
    local y = 0
    local width = windowWidth - Viewport.GUI_WIDTH
    local height = windowHeight
    
    return x, y, width, height
end

--[[
    Check if screen coordinates are within GUI area
    @param x number - Screen X coordinate (physical pixels)
    @param y number - Screen Y coordinate (physical pixels)
    @return boolean - True if coordinates are in GUI area
]]
function Viewport.isInGUI(x, y)
    return x < Viewport.GUI_WIDTH
end

--[[
    Check if screen coordinates are within battlefield area
    @param x number - Screen X coordinate (physical pixels)
    @param y number - Screen Y coordinate (physical pixels)
    @return boolean - True if coordinates are in battlefield area
]]
function Viewport.isInBattlefield(x, y)
    return x >= Viewport.GUI_WIDTH
end

--[[
    Convert screen coordinates to battlefield-relative coordinates
    Removes the GUI offset from screen X coordinate
    @param screenX number - Screen X coordinate (physical pixels)
    @param screenY number - Screen Y coordinate (physical pixels)
    @return number - Battlefield-relative X coordinate
    @return number - Battlefield-relative Y coordinate (unchanged)
]]
function Viewport.screenToBattlefield(screenX, screenY)
    return screenX - Viewport.GUI_WIDTH, screenY
end

--[[
    Convert battlefield-relative coordinates to screen coordinates
    Adds the GUI offset to battlefield X coordinate
    @param bfX number - Battlefield-relative X coordinate
    @param bfY number - Battlefield-relative Y coordinate
    @return number - Screen X coordinate
    @return number - Screen Y coordinate (unchanged)
]]
function Viewport.battlefieldToScreen(bfX, bfY)
    return bfX + Viewport.GUI_WIDTH, bfY
end

--[[
    Get the visible tile bounds for the battlefield given camera position
    This determines which tiles need to be rendered
    @param camera table - Camera object with x, y, zoom properties
    @param mapWidth number - Total map width in tiles
    @param mapHeight number - Total map height in tiles
    @return number minTileX - Minimum visible tile X (1-based)
    @return number minTileY - Minimum visible tile Y (1-based)
    @return number maxTileX - Maximum visible tile X (1-based)
    @return number maxTileY - Maximum visible tile Y (1-based)
]]
function Viewport.getVisibleTileBounds(camera, mapWidth, mapHeight)
    local _, _, viewWidth, viewHeight = Viewport.getBattlefieldViewport()
    
    -- Convert screen corners to world coordinates
    local worldLeft = (0 - camera.x) / camera.zoom
    local worldTop = (0 - camera.y) / camera.zoom
    local worldRight = (viewWidth - camera.x) / camera.zoom
    local worldBottom = (viewHeight - camera.y) / camera.zoom
    
    -- Convert world coordinates to tile coordinates (1-based)
    local minTileX = math.max(1, math.floor(worldLeft / Viewport.TILE_SIZE) + 1)
    local minTileY = math.max(1, math.floor(worldTop / Viewport.TILE_SIZE) + 1)
    local maxTileX = math.min(mapWidth, math.ceil(worldRight / Viewport.TILE_SIZE))
    local maxTileY = math.min(mapHeight, math.ceil(worldBottom / Viewport.TILE_SIZE))
    
    return minTileX, minTileY, maxTileX, maxTileY
end

--[[
    Convert battlefield screen coordinates to tile coordinates
    Takes into account camera position and zoom
    @param screenX number - Screen X coordinate (physical pixels)
    @param screenY number - Screen Y coordinate (physical pixels)
    @param camera table - Camera object with x, y, zoom properties
    @param tileSize number - Size of tiles in pixels (usually 24)
    @return number tileX - Tile X coordinate (1-based)
    @return number tileY - Tile Y coordinate (1-based)
]]
function Viewport.screenToTile(screenX, screenY, camera, tileSize)
    tileSize = tileSize or Viewport.TILE_SIZE
    
    -- First convert screen to battlefield coordinates
    local bfX, bfY = Viewport.screenToBattlefield(screenX, screenY)
    
    -- Then convert battlefield to world coordinates (camera transform)
    local worldX = (bfX - camera.x) / camera.zoom
    local worldY = (bfY - camera.y) / camera.zoom
    
    -- Convert world coordinates to tile coordinates (1-based)
    local tileX = math.floor(worldX / tileSize) + 1
    local tileY = math.floor(worldY / tileSize) + 1
    
    return tileX, tileY
end

--[[
    Convert tile coordinates to battlefield screen coordinates
    Takes into account camera position and zoom
    @param tileX number - Tile X coordinate (1-based)
    @param tileY number - Tile Y coordinate (1-based)
    @param camera table - Camera object with x, y, zoom properties
    @param tileSize number - Size of tiles in pixels (usually 24)
    @return number screenX - Screen X coordinate (physical pixels)
    @return number screenY - Screen Y coordinate (physical pixels)
]]
function Viewport.tileToScreen(tileX, tileY, camera, tileSize)
    tileSize = tileSize or Viewport.TILE_SIZE
    
    -- Convert tile coordinates to world coordinates (0-based pixel position)
    local worldX = (tileX - 1) * tileSize
    local worldY = (tileY - 1) * tileSize
    
    -- Apply camera transform (world to battlefield coordinates)
    local bfX = worldX * camera.zoom + camera.x
    local bfY = worldY * camera.zoom + camera.y
    
    -- Convert battlefield to screen coordinates
    return Viewport.battlefieldToScreen(bfX, bfY)
end

--[[
    Get GUI section position and size
    Helper for positioning GUI elements in the three sections
    @param section number - Section index (1=top/minimap, 2=middle/info, 3=bottom/actions)
    @return number x - Section X position
    @return number y - Section Y position
    @return number width - Section width
    @return number height - Section height
]]
function Viewport.getGUISection(section)
    local x = 0
    local y = (section - 1) * Viewport.SECTION_HEIGHT
    local width = Viewport.GUI_WIDTH
    local height = Viewport.SECTION_HEIGHT
    
    return x, y, width, height
end

--[[
    Print viewport information for debugging
]]
function Viewport.printInfo()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local bfX, bfY, bfWidth, bfHeight = Viewport.getBattlefieldViewport()
    
    print("[Viewport] Window: " .. windowWidth .. "×" .. windowHeight)
    print("[Viewport] GUI: " .. Viewport.GUI_WIDTH .. "×" .. Viewport.GUI_HEIGHT)
    print("[Viewport] Battlefield: " .. bfWidth .. "×" .. bfHeight .. " at (" .. bfX .. ", " .. bfY .. ")")
    
    -- Calculate visible tiles (approximate, without camera)
    local tilesWide = math.floor(bfWidth / Viewport.TILE_SIZE)
    local tilesTall = math.floor(bfHeight / Viewport.TILE_SIZE)
    print("[Viewport] Approx visible tiles: " .. tilesWide .. "×" .. tilesTall)
end

return Viewport






















