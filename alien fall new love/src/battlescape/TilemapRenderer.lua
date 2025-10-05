--- TilemapRenderer - Optimized tilemap rendering using SpriteBatch
--
-- Uses Love2D's SpriteBatch for efficient rendering of large tilemaps.
-- Supports dynamic tile updates, layers, and culling.
--
-- @module battlescape.TilemapRenderer

local class = require("lib.middleclass")

local TilemapRenderer = class('TilemapRenderer')

-- Constants
local TILE_SIZE = 32  -- Default tile size in pixels

--- Initialize the tilemap renderer
--- @param opts table Configuration options
--- @param opts.tileset love.Image The tileset image
--- @param opts.tileWidth number Width of each tile (default: 32)
--- @param opts.tileHeight number Height of each tile (default: 32)
--- @param opts.mapWidth number Width of the map in tiles
--- @param opts.mapHeight number Height of the map in tiles
--- @param opts.layers number Number of rendering layers (default: 3)
function TilemapRenderer:initialize(opts)
    opts = opts or {}
    
    self.tileset = opts.tileset
    self.tileWidth = opts.tileWidth or TILE_SIZE
    self.tileHeight = opts.tileHeight or TILE_SIZE
    self.mapWidth = opts.mapWidth or 50
    self.mapHeight = opts.mapHeight or 50
    self.layerCount = opts.layers or 3
    
    -- Calculate tileset dimensions
    if self.tileset then
        self.tilesetWidth = self.tileset:getWidth()
        self.tilesetHeight = self.tileset:getHeight()
        self.tilesPerRow = math.floor(self.tilesetWidth / self.tileWidth)
        self.tilesPerColumn = math.floor(self.tilesetHeight / self.tileHeight)
    end
    
    -- Create sprite batches for each layer
    self.spriteBatches = {}
    self.dirty = {}  -- Track which layers need rebuild
    
    for layer = 1, self.layerCount do
        if self.tileset then
            -- Create sprite batch with capacity for all tiles
            local capacity = self.mapWidth * self.mapHeight
            self.spriteBatches[layer] = love.graphics.newSpriteBatch(
                self.tileset,
                capacity,
                "static"  -- Static batches are faster for non-changing tiles
            )
        end
        self.dirty[layer] = true
    end
    
    -- Tile data storage [layer][y][x] = tileId
    self.tiles = {}
    for layer = 1, self.layerCount do
        self.tiles[layer] = {}
        for y = 1, self.mapHeight do
            self.tiles[layer][y] = {}
            for x = 1, self.mapWidth do
                self.tiles[layer][y][x] = 0  -- 0 = empty tile
            end
        end
    end
    
    -- Create quads for each tile in tileset
    self.quads = {}
    if self.tileset then
        local quadIndex = 0
        for ty = 0, self.tilesPerColumn - 1 do
            for tx = 0, self.tilesPerRow - 1 do
                local quad = love.graphics.newQuad(
                    tx * self.tileWidth,
                    ty * self.tileHeight,
                    self.tileWidth,
                    self.tileHeight,
                    self.tilesetWidth,
                    self.tilesetHeight
                )
                self.quads[quadIndex] = quad
                quadIndex = quadIndex + 1
            end
        end
    end
    
    -- Viewport culling
    self.viewportX = 0
    self.viewportY = 0
    self.viewportWidth = love.graphics.getWidth()
    self.viewportHeight = love.graphics.getHeight()
    
    -- Performance tracking
    self.stats = {
        tilesDrawn = 0,
        tilesCulled = 0,
        lastRebuildTime = 0
    }
end

--- Set a tile at specific coordinates
--- @param layer number Layer index (1-based)
--- @param x number Tile X coordinate
--- @param y number Tile Y coordinate
--- @param tileId number Tile ID from tileset
function TilemapRenderer:setTile(layer, x, y, tileId)
    if layer < 1 or layer > self.layerCount then
        return
    end
    
    if x < 1 or x > self.mapWidth or y < 1 or y > self.mapHeight then
        return
    end
    
    self.tiles[layer][y][x] = tileId
    self.dirty[layer] = true  -- Mark layer as needing rebuild
end

--- Get tile at specific coordinates
--- @param layer number Layer index
--- @param x number Tile X coordinate
--- @param y number Tile Y coordinate
--- @return number tileId The tile ID at this location
function TilemapRenderer:getTile(layer, x, y)
    if layer < 1 or layer > self.layerCount then
        return 0
    end
    
    if x < 1 or x > self.mapWidth or y < 1 or y > self.mapHeight then
        return 0
    end
    
    return self.tiles[layer][y][x]
end

--- Rebuild sprite batch for a specific layer
--- @param layer number Layer index to rebuild
function TilemapRenderer:rebuildLayer(layer)
    if not self.spriteBatches[layer] then
        return
    end
    
    local startTime = love.timer.getTime()
    
    local batch = self.spriteBatches[layer]
    batch:clear()
    
    local tilesAdded = 0
    
    -- Calculate visible tile range for culling
    local minTileX = math.max(1, math.floor(self.viewportX / self.tileWidth))
    local maxTileX = math.min(self.mapWidth, math.ceil((self.viewportX + self.viewportWidth) / self.tileWidth))
    local minTileY = math.max(1, math.floor(self.viewportY / self.tileHeight))
    local maxTileY = math.min(self.mapHeight, math.ceil((self.viewportY + self.viewportHeight) / self.tileHeight))
    
    -- Add tiles to batch (only visible tiles)
    for y = minTileY, maxTileY do
        for x = minTileX, maxTileX do
            local tileId = self.tiles[layer][y][x]
            
            if tileId > 0 and self.quads[tileId] then
                local screenX = (x - 1) * self.tileWidth
                local screenY = (y - 1) * self.tileHeight
                
                batch:add(self.quads[tileId], screenX, screenY)
                tilesAdded = tilesAdded + 1
            end
        end
    end
    
    self.dirty[layer] = false
    
    local endTime = love.timer.getTime()
    self.stats.lastRebuildTime = endTime - startTime
    self.stats.tilesDrawn = tilesAdded
    self.stats.tilesCulled = (self.mapWidth * self.mapHeight) - tilesAdded
end

--- Set viewport for culling optimization
--- @param x number Viewport X coordinate
--- @param y number Viewport Y coordinate
--- @param width number Viewport width
--- @param height number Viewport height
function TilemapRenderer:setViewport(x, y, width, height)
    local changed = (self.viewportX ~= x or 
                    self.viewportY ~= y or
                    self.viewportWidth ~= width or
                    self.viewportHeight ~= height)
    
    if changed then
        self.viewportX = x
        self.viewportY = y
        self.viewportWidth = width
        self.viewportHeight = height
        
        -- Mark all layers dirty due to viewport change
        for layer = 1, self.layerCount do
            self.dirty[layer] = true
        end
    end
end

--- Draw the tilemap
--- @param layers table Optional array of layer indices to draw (default: all)
function TilemapRenderer:draw(layers)
    layers = layers or {}
    
    -- If no specific layers requested, draw all
    if #layers == 0 then
        for i = 1, self.layerCount do
            table.insert(layers, i)
        end
    end
    
    -- Rebuild dirty layers
    for _, layer in ipairs(layers) do
        if self.dirty[layer] then
            self:rebuildLayer(layer)
        end
    end
    
    -- Draw each layer
    love.graphics.push()
    love.graphics.translate(-self.viewportX, -self.viewportY)
    
    for _, layer in ipairs(layers) do
        if self.spriteBatches[layer] then
            love.graphics.draw(self.spriteBatches[layer], 0, 0)
        end
    end
    
    love.graphics.pop()
end

--- Load tilemap from data array
--- @param layer number Layer to load into
--- @param data table 2D array of tile IDs
function TilemapRenderer:loadFromData(layer, data)
    if layer < 1 or layer > self.layerCount then
        return
    end
    
    for y = 1, math.min(#data, self.mapHeight) do
        for x = 1, math.min(#data[y], self.mapWidth) do
            self.tiles[layer][y][x] = data[y][x] or 0
        end
    end
    
    self.dirty[layer] = true
end

--- Fill a rectangular area with a tile
--- @param layer number Layer index
--- @param x number Start X coordinate
--- @param y number Start Y coordinate
--- @param width number Width in tiles
--- @param height number Height in tiles
--- @param tileId number Tile ID to fill with
function TilemapRenderer:fillRect(layer, x, y, width, height, tileId)
    if layer < 1 or layer > self.layerCount then
        return
    end
    
    for ty = y, math.min(y + height - 1, self.mapHeight) do
        for tx = x, math.min(x + width - 1, self.mapWidth) do
            self.tiles[layer][ty][tx] = tileId
        end
    end
    
    self.dirty[layer] = true
end

--- Force rebuild of all layers
function TilemapRenderer:rebuildAll()
    for layer = 1, self.layerCount do
        self.dirty[layer] = true
        self:rebuildLayer(layer)
    end
end

--- Get rendering statistics
--- @return table stats Performance statistics
function TilemapRenderer:getStats()
    return {
        tilesDrawn = self.stats.tilesDrawn,
        tilesCulled = self.stats.tilesCulled,
        lastRebuildTime = self.stats.lastRebuildTime,
        totalTiles = self.mapWidth * self.mapHeight,
        layerCount = self.layerCount
    }
end

--- Clear all tiles from a layer
--- @param layer number Layer to clear
function TilemapRenderer:clearLayer(layer)
    if layer < 1 or layer > self.layerCount then
        return
    end
    
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self.tiles[layer][y][x] = 0
        end
    end
    
    self.dirty[layer] = true
end

--- Convert screen coordinates to tile coordinates
--- @param screenX number Screen X coordinate
--- @param screenY number Screen Y coordinate
--- @return number tileX Tile X coordinate
--- @return number tileY Tile Y coordinate
function TilemapRenderer:screenToTile(screenX, screenY)
    local worldX = screenX + self.viewportX
    local worldY = screenY + self.viewportY
    
    local tileX = math.floor(worldX / self.tileWidth) + 1
    local tileY = math.floor(worldY / self.tileHeight) + 1
    
    return tileX, tileY
end

--- Convert tile coordinates to screen coordinates
--- @param tileX number Tile X coordinate
--- @param tileY number Tile Y coordinate
--- @return number screenX Screen X coordinate
--- @return number screenY Screen Y coordinate
function TilemapRenderer:tileToScreen(tileX, tileY)
    local worldX = (tileX - 1) * self.tileWidth
    local worldY = (tileY - 1) * self.tileHeight
    
    local screenX = worldX - self.viewportX
    local screenY = worldY - self.viewportY
    
    return screenX, screenY
end

return TilemapRenderer
