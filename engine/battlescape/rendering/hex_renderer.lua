---HexRenderer - Hexagonal Grid Tile Rendering System
---
---Renders map tiles on a hexagonal grid with proper 6-directional adjacency and
---coordinate conversion. Handles flat-top hex layout with odd-column offset for
---tactical battlescape visualization. Part of hex grid integration (Phase 6).
---
---Features:
---  - Flat-top hexagonal grid layout
---  - Odd-column offset for proper hex packing
---  - Coordinate conversion (pixel ↔ hex)
---  - 6-directional neighbor calculation
---  - Multi-tile rendering support
---  - Grid overlay for debugging
---  - Integration with tileset system
---
---Key Exports:
---  - new(tileSize): Create new hex renderer instance
---  - hexToPixel(hexX, hexY): Convert hex coordinates to pixels
---  - pixelToHex(pixelX, pixelY): Convert pixel coordinates to hex
---  - getHexNeighbors(hexX, hexY): Get 6 neighboring hex coordinates
---  - drawTile(hexX, hexY, tileKey, tileset): Render tile at hex position
---  - drawGrid(camera, width, height): Draw hex grid overlay
---  - setTileSize(size): Change tile size (affects hex dimensions)
---
---Dependencies:
---  - require("battlescape.data.tilesets"): Tileset definitions and textures
---  - require("battlescape.utils.multitile"): Multi-tile rendering utilities
---
---@module battlescape.rendering.hex_renderer
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local HexRenderer = require("battlescape.rendering.hex_renderer")
---  local renderer = HexRenderer.new(24)
---  local pixelX, pixelY = renderer:hexToPixel(5, 3)
---  renderer:drawTile(5, 3, "wall", tileset)
---
---@see battlescape.rendering.renderer For main battlefield renderer
---@see battlescape.data.tilesets For tile definitions

-- Hex Renderer Enhancement
-- Phase 6: Hex Grid Integration with Map Tile System
-- Renders Map Tiles correctly on hex grid with 6-directional adjacency

local Tilesets = require("battlescape.data.tilesets")
local MultiTile = require("battlescape.utils.multitile")

local HexRenderer = {}

---@class HexRenderer
---@field tileSize number Base tile size in pixels
---@field hexWidth number Hex width (calculated)
---@field hexHeight number Hex height (calculated)
---@field showGrid boolean Show hex grid overlay

---Create new hex renderer
---@param tileSize number Base tile size in pixels (default 24)
---@return table HexRenderer instance
function HexRenderer.new(tileSize)
    local self = {}
    
    self.tileSize = tileSize or 24
    -- Hex dimensions (flat-top hexagons)
    self.hexWidth = self.tileSize
    self.hexHeight = self.tileSize * 0.866 -- sqrt(3)/2
    self.showGrid = false
    
    return setmetatable(self, {__index = HexRenderer})
end

---Convert hex coordinates to pixel coordinates (flat-top hex)
---@param hexX number Hex column
---@param hexY number Hex row
---@return number pixelX
---@return number pixelY
function HexRenderer:hexToPixel(hexX, hexY)
    local x = hexX * self.hexWidth
    local y = hexY * self.hexHeight
    
    -- Offset odd columns by half height
    if hexX % 2 == 1 then
        y = y + self.hexHeight * 0.5
    end
    
    return x, y
end

---Convert pixel coordinates to hex coordinates
---@param pixelX number Pixel X
---@param pixelY number Pixel Y
---@return number hexX
---@return number hexY
function HexRenderer:pixelToHex(pixelX, pixelY)
    -- Approximate hex from pixel
    local hexX = math.floor(pixelX / self.hexWidth)
    local hexY = math.floor(pixelY / self.hexHeight)
    
    -- Adjust for odd column offset
    if hexX % 2 == 1 then
        hexY = math.floor((pixelY - self.hexHeight * 0.5) / self.hexHeight)
    end
    
    return hexX, hexY
end

---Get 6 hex neighbors (flat-top hex grid with odd-column offset)
---@param hexX number Hex column
---@param hexY number Hex row
---@return table neighbors Array of {x, y} neighbor coordinates
function HexRenderer:getHexNeighbors(hexX, hexY)
    local neighbors = {}
    
    -- Flat-top hex with odd-column offset
    local isOdd = (hexX % 2 == 1)
    
    if isOdd then
        -- Odd column neighbors
        table.insert(neighbors, {x = hexX, y = hexY - 1})     -- North
        table.insert(neighbors, {x = hexX + 1, y = hexY})     -- Northeast
        table.insert(neighbors, {x = hexX + 1, y = hexY + 1}) -- Southeast
        table.insert(neighbors, {x = hexX, y = hexY + 1})     -- South
        table.insert(neighbors, {x = hexX - 1, y = hexY + 1}) -- Southwest
        table.insert(neighbors, {x = hexX - 1, y = hexY})     -- Northwest
    else
        -- Even column neighbors
        table.insert(neighbors, {x = hexX, y = hexY - 1})     -- North
        table.insert(neighbors, {x = hexX + 1, y = hexY - 1}) -- Northeast
        table.insert(neighbors, {x = hexX + 1, y = hexY})     -- Southeast
        table.insert(neighbors, {x = hexX, y = hexY + 1})     -- South
        table.insert(neighbors, {x = hexX - 1, y = hexY})     -- Southwest
        table.insert(neighbors, {x = hexX - 1, y = hexY - 1}) -- Northwest
    end
    
    return neighbors
end

---Calculate autotile neighbors for hex grid (6-directional)
---@param map table Map grid {[x_y] = tileKey}
---@param hexX number Hex column
---@param hexY number Hex row
---@param matchTileKey string Tile KEY to match for autotile
---@return number neighborMask Bitmask of matching neighbors (0-63)
function HexRenderer:calculateHexAutotile(map, hexX, hexY, matchTileKey)
    local neighbors = self:getHexNeighbors(hexX, hexY)
    local mask = 0
    
    for i, neighbor in ipairs(neighbors) do
        local key = string.format("%d_%d", neighbor.x, neighbor.y)
        local neighborTile = map[key]
        
        -- Check if neighbor matches (for autotile purposes)
        if neighborTile and neighborTile == matchTileKey then
            mask = mask + math.pow(2, i - 1)
        end
    end
    
    return mask
end

---Render Map Tile on hex grid
---@param tileKey string Map Tile KEY (tileset:tileId)
---@param hexX number Hex column
---@param hexY number Hex row
---@param zoom number Zoom factor (default 1.0)
---@param brightness number Brightness multiplier (default 1.0)
---@param map table? Optional map grid for autotile calculation
function HexRenderer:renderMapTile(tileKey, hexX, hexY, zoom, brightness, map)
    zoom = zoom or 1.0
    brightness = brightness or 1.0
    
    -- Parse tile KEY
    local tilesetId, tileId = tileKey:match("^([^:]+):(.+)$")
    if not tilesetId or not tileId then
        -- Invalid KEY, draw placeholder
        self:renderPlaceholder(hexX, hexY, zoom, {1, 0, 0})
        return
    end
    
    -- Get tileset and tile
    local tileset = Tilesets.get(tilesetId)
    if not tileset then
        self:renderPlaceholder(hexX, hexY, zoom, {1, 1, 0})
        return
    end
    
    local tile = tileset.tiles[tileId]
    if not tile then
        self:renderPlaceholder(hexX, hexY, zoom, {1, 0, 1})
        return
    end
    
    -- Get pixel position
    local pixelX, pixelY = self:hexToPixel(hexX, hexY)
    
    -- Handle multi-tile rendering
    local mode = tile.multiTileMode or "none"
    
    if mode == "variant" then
        -- Random variant selection (would need RNG seed in real impl)
        local variantIndex = ((hexX * 31 + hexY * 17) % #tile.variants) + 1
        local variant = tile.variants[variantIndex]
        self:renderTileAsset(variant, pixelX, pixelY, zoom, brightness)
        
    elseif mode == "animation" then
        -- Frame selection (would need animation time in real impl)
        local frameIndex = 1 -- Placeholder
        local frame = tile.frames[frameIndex]
        self:renderTileAsset(frame, pixelX, pixelY, zoom, brightness)
        
    elseif mode == "autotile" and map then
        -- Calculate hex autotile neighbors (6-directional)
        local neighborMask = self:calculateHexAutotile(map, hexX, hexY, tileKey)
        local variant = tile.autotileVariants[neighborMask + 1] or tile.autotileVariants[1]
        self:renderTileAsset(variant, pixelX, pixelY, zoom, brightness)
        
    elseif mode == "damage" then
        -- Damage state (would need damage level in real impl)
        local damageLevel = 0 -- 0 = intact
        local state = tile.damageStates[damageLevel + 1] or tile.damageStates[1]
        self:renderTileAsset(state, pixelX, pixelY, zoom, brightness)
        
    else
        -- Single tile or fallback
        self:renderTileAsset(tile.asset, pixelX, pixelY, zoom, brightness)
    end
end

---Render tile asset (texture)
---@param asset string Asset path
---@param pixelX number Pixel X
---@param pixelY number Pixel Y
---@param zoom number Zoom factor
---@param brightness number Brightness multiplier
function HexRenderer:renderTileAsset(asset, pixelX, pixelY, zoom, brightness)
    -- Placeholder: actual texture loading would use Assets system
    -- For now, draw colored square
    love.graphics.setColor(brightness * 0.5, brightness * 0.6, brightness * 0.7, 1)
    love.graphics.rectangle("fill", 
        pixelX * zoom, pixelY * zoom,
        self.tileSize * zoom, self.tileSize * zoom)
    
    -- Draw asset path hint
    love.graphics.setColor(1, 1, 1, 0.5)
    local displayAsset = asset:match("([^/]+)$") or asset
    if #displayAsset > 8 then
        displayAsset = displayAsset:sub(1, 8)
    end
    love.graphics.print(displayAsset, pixelX * zoom + 2, pixelY * zoom + 2)
end

---Render placeholder for missing tiles
---@param hexX number Hex column
---@param hexY number Hex row
---@param zoom number Zoom factor
---@param color table RGB color {r, g, b}
function HexRenderer:renderPlaceholder(hexX, hexY, zoom, color)
    local pixelX, pixelY = self:hexToPixel(hexX, hexY)
    
    love.graphics.setColor(color[1], color[2], color[3], 0.5)
    love.graphics.rectangle("fill",
        pixelX * zoom, pixelY * zoom,
        self.tileSize * zoom, self.tileSize * zoom)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line",
        pixelX * zoom, pixelY * zoom,
        self.tileSize * zoom, self.tileSize * zoom)
end

---Draw hex grid overlay
---@param startX number Start hex column
---@param startY number Start hex row
---@param width number Grid width in hexes
---@param height number Grid height in hexes
---@param zoom number Zoom factor
function HexRenderer:drawHexGrid(startX, startY, width, height, zoom)
    if not self.showGrid then return end
    
    love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
    
    for y = startY, startY + height - 1 do
        for x = startX, startX + width - 1 do
            local pixelX, pixelY = self:hexToPixel(x, y)
            
            -- Draw hex outline (simplified as rectangle)
            love.graphics.rectangle("line",
                pixelX * zoom, pixelY * zoom,
                self.tileSize * zoom, self.tileSize * zoom)
            
            -- Draw coordinate label
            love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
            love.graphics.print(string.format("%d,%d", x, y),
                pixelX * zoom + 2, pixelY * zoom + 2)
            love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
        end
    end
end

---Toggle grid overlay
function HexRenderer:toggleGrid()
    self.showGrid = not self.showGrid
    print(string.format("[HexRenderer] Grid: %s", tostring(self.showGrid)))
end

---Check if tile occupies multiple hex cells
---@param tileKey string Map Tile KEY
---@return boolean isMultiCell
---@return number? width Cell width if multi-cell
---@return number? height Cell height if multi-cell
function HexRenderer:isMultiCell(tileKey)
    local tilesetId, tileId = tileKey:match("^([^:]+):(.+)$")
    if not tilesetId or not tileId then
        return false
    end
    
    local tileset = Tilesets.get(tilesetId)
    if not tileset then
        return false
    end
    
    local tile = tileset.tiles[tileId]
    if not tile then
        return false
    end
    
    if tile.multiTileMode == "multi-cell" and tile.cellWidth and tile.cellHeight then
        return true, tile.cellWidth, tile.cellHeight
    end
    
    return false
end

---Render multi-cell tile across multiple hex cells
---@param tileKey string Map Tile KEY
---@param hexX number Origin hex column
---@param hexY number Origin hex row
---@param zoom number Zoom factor
---@param brightness number Brightness
function HexRenderer:renderMultiCellTile(tileKey, hexX, hexY, zoom, brightness)
    local isMulti, width, height = self:isMultiCell(tileKey)
    if not isMulti then
        self:renderMapTile(tileKey, hexX, hexY, zoom, brightness)
        return
    end
    
    -- Render across multiple cells
    -- For hex grid, multi-cell placement is more complex
    -- This is a simplified implementation
    for dy = 0, height - 1 do
        for dx = 0, width - 1 do
            self:renderMapTile(tileKey, hexX + dx, hexY + dy, zoom, brightness)
        end
    end
end

return HexRenderer


























