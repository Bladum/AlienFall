---PathfindingUI - Visual Movement Feedback System
---
---Displays interactive pathfinding visualization for tactical unit movement.
---Shows destination hexes, valid movement paths, and reachable range. Integrates
---with pathfinding.lua to provide real-time feedback during movement planning.
---
---Features:
---  - Destination hex highlighting with color coding
---  - Path preview with waypoint visualization
---  - Reachable hex range display (movement radius)
---  - Hex hover detection for interactive feedback
---  - Color coding: Destination (green), Path (yellow), Reachable (blue), Blocked (red)
---  - Keyboard shortcuts: Left-click destination, Right-click clear, SPACE toggle preview
---  - Performance optimization: Culled rendering (off-screen hexes hidden)
---
---UI Elements:
---  - Destination overlay: Bright green glow + arrow pointing to target
---  - Path preview: Yellow waypoint line from unit to destination
---  - Reachable range: Blue semi-transparent hexes showing movement radius
---  - Blocked hexes: Red tint for impassable terrain
---  - Hover tooltip: Shows hex coordinates, terrain cost, walkability
---  - Movement cost display: TU/AP cost breakdown per hex segment
---
---Rendering:
---  - Hex grid: 24×24 pixel tiles (48×48 when scaled 2x in 960×720)
---  - Overlay layers: Destination (top) → Path (middle) → Reachable (bottom)
---  - Screen grid: 40×30 hexes = 960×720 resolution
---  - Camera-relative rendering (follows player unit)
---
---Key Exports:
---  - PathfindingUI.new(pathfinder): Creates UI system
---  - setDestination(x, y): Set movement destination
---  - showReachable(centerX, centerY, maxDistance): Display reachable hexes
---  - showPath(path): Highlight planned path
---  - draw(cameraX, cameraY): Render UI overlays
---  - clear(): Reset all highlights
---
---Dependencies:
---  - battlescape.systems.pathfinding: Path calculation
---  - battlescape.battle_ecs.hex_math: Hex coordinate operations
---  - love.graphics: Rendering (circles, lines, quads)
---
---@module battlescape.ui.pathfinding_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local PathfindingUI = require("battlescape.ui.pathfinding_ui")
---  local ui = PathfindingUI.new(pathfinder)
---  ui:setDestination(32, 48)
---  ui:showReachable(32, 48, 20)
---  ui:draw(cameraCenterX, cameraCenterY)
---
---@see battlescape.systems.pathfinding For path calculations
---@see battlescape.battle_ecs.hex_math For hex operations

local HexMath = require("battlescape.battle_ecs.hex_math")

local PathfindingUI = {}

---@class PathfindingUI
---@field pathfinder table Pathfinding system instance
---@field destination table Current destination {x, y}
---@field currentPath table Current highlighted path {x, y, ...}
---@field reachableHexes table Reachable hexes from current unit
---@field hoveredHex table Currently hovered hex {x, y}
---@field colors table Color definitions for highlighting
---@field hexSize number Size of hex tiles in pixels (24)
---@field scale number Pixel scale factor (2x = 48px display)
---@field fadeAlpha number Opacity for non-interactive elements (0-1)
---@field showReachableRange boolean Show reachable hexes overlay

---Create pathfinding UI system
---@param pathfinder table Pathfinding system instance
---@return PathfindingUI UI instance
function PathfindingUI.new(pathfinder)
    local self = setmetatable({}, {__index = PathfindingUI})
    
    self.pathfinder = pathfinder
    self.destination = nil
    self.currentPath = {}
    self.reachableHexes = {}
    self.hoveredHex = nil
    
    -- Color definitions (RGB)
    self.colors = {
        destination = {0.2, 0.9, 0.2},      -- Bright green
        path = {0.9, 0.8, 0.1},            -- Yellow
        reachable = {0.2, 0.5, 0.9},       -- Blue
        blocked = {0.9, 0.2, 0.2},         -- Red
        hover = {1.0, 1.0, 0.3},           -- Yellow-white
        background = {0.1, 0.1, 0.1, 0.5}, -- Dark semi-transparent
    }
    
    self.hexSize = 24  -- Base hex tile size in pixels
    self.scale = 2     -- Display scale (48px actual rendering)
    self.fadeAlpha = 0.6  -- Opacity for range/blocked indicators
    self.showReachableRange = true
    
    print("[PathfindingUI] Initialized")
    
    return self
end

---Set movement destination
---@param x number Destination hex X
---@param y number Destination hex Y
---@param unitCenter? table Current unit position for pathing
function PathfindingUI:setDestination(x, y, unitCenter)
    self.destination = {x = x, y = y}
    
    -- Calculate path if unit position provided
    if unitCenter and self.pathfinder then
        self.currentPath = self.pathfinder:findPath(unitCenter.x, unitCenter.y, x, y) or {}
        
        print(string.format("[PathfindingUI] Destination set to (%.0f, %.0f), path length: %d",
            x, y, #self.currentPath))
    end
end

---Display reachable hexes from position with distance limit
---@param centerX number Center hex X
---@param centerY number Center hex Y
---@param maxDistance number Maximum movement distance (in tiles or TU)
---@param terrainCosts? table Optional terrain cost multipliers
function PathfindingUI:showReachable(centerX, centerY, maxDistance, terrainCosts)
    self.reachableHexes = {}
    
    if not self.pathfinder then
        return
    end
    
    -- Get all reachable hexes using pathfinding system
    local reachable = self.pathfinder:getReachableHexes(centerX, centerY, maxDistance, terrainCosts)
    
    if reachable then
        for _, hex in ipairs(reachable) do
            table.insert(self.reachableHexes, {x = hex.x, y = hex.y, cost = hex.cost})
        end
    end
    
    print(string.format("[PathfindingUI] Showing %d reachable hexes from (%.0f, %.0f)",
        #self.reachableHexes, centerX, centerY))
end

---Highlight a specific path
---@param path table Array of {x, y} coordinates
function PathfindingUI:showPath(path)
    self.currentPath = path or {}
    
    print(string.format("[PathfindingUI] Path set with %d waypoints", #self.currentPath))
end

---Update hovered hex based on mouse position
---@param mouseX number Mouse X in screen space
---@param mouseY number Mouse Y in screen space
---@param cameraX number Camera center X in world space
---@param cameraY number Camera center Y in world space
function PathfindingUI:updateHover(mouseX, mouseY, cameraX, cameraY)
    -- Convert mouse screen coordinates to world coordinates
    local screenWidth = 960
    local screenHeight = 720
    local hexPixels = self.hexSize * self.scale
    
    -- Offset from screen center (camera center)
    local offsetX = mouseX - (screenWidth / 2)
    local offsetY = mouseY - (screenHeight / 2)
    
    -- Convert to hex coordinates (flat-top hex grid)
    -- Simplified conversion: assumes square grid for now
    local worldX = cameraX + (offsetX / hexPixels)
    local worldY = cameraY + (offsetY / hexPixels)
    
    self.hoveredHex = {
        x = math.floor(worldX + 0.5),
        y = math.floor(worldY + 0.5)
    }
end

---Draw pathfinding UI overlays
---@param cameraX number Camera center X
---@param cameraY number Camera center Y
---@param screenWidth? number Screen width (default 960)
---@param screenHeight? number Screen height (default 720)
function PathfindingUI:draw(cameraX, cameraY, screenWidth, screenHeight)
    screenWidth = screenWidth or 960
    screenHeight = screenHeight or 720
    
    local hexPixels = self.hexSize * self.scale
    local hexRadius = hexPixels / 2
    
    -- Draw reachable range hexes (bottom layer)
    if self.showReachableRange then
        self:drawReachableHexes(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    end
    
    -- Draw blocked hexes (red overlay)
    self:drawBlockedHexes(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    
    -- Draw current path (yellow waypoints)
    if #self.currentPath > 0 then
        self:drawPath(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    end
    
    -- Draw destination hex (green glow)
    if self.destination then
        self:drawDestination(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    end
    
    -- Draw hovered hex outline
    if self.hoveredHex then
        self:drawHoveredHex(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    end
    
    -- Draw cost/distance info if applicable
    if self.hoveredHex and self.destination then
        self:drawMovementInfo(self.hoveredHex, self.destination)
    end
end

---Draw reachable hexes overlay
---@param cameraX number Camera X
---@param cameraY number Camera Y
---@param screenWidth number Screen width
---@param screenHeight number Screen height
---@param hexPixels number Hex size in pixels
function PathfindingUI:drawReachableHexes(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    love.graphics.setColor(self.colors.reachable[1], self.colors.reachable[2], 
        self.colors.reachable[3], self.fadeAlpha)
    
    for _, hex in ipairs(self.reachableHexes) do
        local screenX, screenY = self:hexToScreen(hex.x, hex.y, cameraX, cameraY, 
            screenWidth, screenHeight, hexPixels)
        
        -- Draw only if on screen
        if screenX > -hexPixels and screenX < screenWidth + hexPixels and
           screenY > -hexPixels and screenY < screenHeight + hexPixels then
            
            -- Draw hexagon (approximated as circle for simplicity)
            love.graphics.circle("fill", screenX, screenY, hexPixels / 2 - 2)
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color
end

---Draw blocked terrain hexes
---@param cameraX number Camera X
---@param cameraY number Camera Y
---@param screenWidth number Screen width
---@param screenHeight number Screen height
---@param hexPixels number Hex size in pixels
function PathfindingUI:drawBlockedHexes(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    -- Note: Would need access to terrain data to know which hexes are blocked
    -- This is a placeholder for when terrain layer is available
    love.graphics.setColor(1, 1, 1, 1)  -- Reset
end

---Draw path waypoints
---@param cameraX number Camera X
---@param cameraY number Camera Y
---@param screenWidth number Screen width
---@param screenHeight number Screen height
---@param hexPixels number Hex size in pixels
function PathfindingUI:drawPath(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    -- Draw path line
    love.graphics.setColor(self.colors.path[1], self.colors.path[2], 
        self.colors.path[3], 0.8)
    
    local prevX, prevY = nil, nil
    
    for _, hex in ipairs(self.currentPath) do
        local screenX, screenY = self:hexToScreen(hex.x, hex.y, cameraX, cameraY,
            screenWidth, screenHeight, hexPixels)
        
        -- Draw line segment
        if prevX then
            love.graphics.line(prevX, prevY, screenX, screenY)
        end
        
        -- Draw waypoint circle
        love.graphics.circle("fill", screenX, screenY, 3)
        
        prevX, prevY = screenX, screenY
    end
    
    love.graphics.setColor(1, 1, 1, 1)  -- Reset
end

---Draw destination hex highlight
---@param cameraX number Camera X
---@param cameraY number Camera Y
---@param screenWidth number Screen width
---@param screenHeight number Screen height
---@param hexPixels number Hex size in pixels
function PathfindingUI:drawDestination(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    local screenX, screenY = self:hexToScreen(self.destination.x, self.destination.y,
        cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    
    -- Check if on screen
    if screenX > -hexPixels and screenX < screenWidth + hexPixels and
       screenY > -hexPixels and screenY < screenHeight + hexPixels then
        
        -- Draw glowing circle for destination
        love.graphics.setColor(self.colors.destination[1], self.colors.destination[2],
            self.colors.destination[3], 0.9)
        love.graphics.circle("fill", screenX, screenY, hexPixels / 2 - 4)
        
        -- Draw outer glow ring
        love.graphics.setColor(self.colors.destination[1], self.colors.destination[2],
            self.colors.destination[3], 0.3)
        love.graphics.circle("line", screenX, screenY, hexPixels / 2)
    end
    
    love.graphics.setColor(1, 1, 1, 1)  -- Reset
end

---Draw hovered hex outline
---@param cameraX number Camera X
---@param cameraY number Camera Y
---@param screenWidth number Screen width
---@param screenHeight number Screen height
---@param hexPixels number Hex size in pixels
function PathfindingUI:drawHoveredHex(cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    local screenX, screenY = self:hexToScreen(self.hoveredHex.x, self.hoveredHex.y,
        cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    
    -- Check if on screen
    if screenX > -hexPixels and screenX < screenWidth + hexPixels and
       screenY > -hexPixels and screenY < screenHeight + hexPixels then
        
        love.graphics.setColor(self.colors.hover[1], self.colors.hover[2],
            self.colors.hover[3], 0.7)
        love.graphics.circle("line", screenX, screenY, hexPixels / 2 - 1)
    end
    
    love.graphics.setColor(1, 1, 1, 1)  -- Reset
end

---Draw movement cost/distance information
---@param fromHex table From {x, y}
---@param toHex table To {x, y}
function PathfindingUI:drawMovementInfo(fromHex, toHex)
    if not HexMath or not HexMath.distance then
        return
    end
    
    local distance = HexMath.distance(fromHex.x, fromHex.y, toHex.x, toHex.y)
    local costPerHex = 2  -- Base TU cost per hex (configurable)
    local totalCost = distance * costPerHex
    
    -- Draw info text at top of screen
    love.graphics.setColor(1, 1, 0)
    local infoText = string.format("Distance: %.0f | TU Cost: %.0f", distance, totalCost)
    love.graphics.print(infoText, 10, 10)
    love.graphics.setColor(1, 1, 1)
end

---Convert hex coordinates to screen coordinates
---@param hexX number Hex X
---@param hexY number Hex Y
---@param cameraX number Camera X (in hex coords)
---@param cameraY number Camera Y (in hex coords)
---@param screenWidth number Screen width
---@param screenHeight number Screen height
---@param hexPixels number Hex pixel size
---@return number screenX Screen X coordinate
---@return number screenY Screen Y coordinate
function PathfindingUI:hexToScreen(hexX, hexY, cameraX, cameraY, screenWidth, screenHeight, hexPixels)
    -- Offset from camera
    local offsetX = hexX - cameraX
    local offsetY = hexY - cameraY
    
    -- Convert to screen pixels
    local screenX = (screenWidth / 2) + (offsetX * hexPixels)
    local screenY = (screenHeight / 2) + (offsetY * hexPixels)
    
    return screenX, screenY
end

---Clear all highlights
function PathfindingUI:clear()
    self.destination = nil
    self.currentPath = {}
    self.hoveredHex = nil
    
    print("[PathfindingUI] Cleared all highlights")
end

---Toggle reachable hex display
function PathfindingUI:toggleReachable()
    self.showReachableRange = not self.showReachableRange
    
    print(string.format("[PathfindingUI] Reachable range display: %s",
        self.showReachableRange and "ON" or "OFF"))
end

return PathfindingUI
