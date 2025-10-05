--- TileSet.lua
-- Implements the TileSet system for battlescape graphics
-- TileSets are collections of graphics stored in single PNG files
--
-- @classmod battlescape.TileSet

local class = require 'lib.middleclass'

--- TileSet class
-- @type TileSet
TileSet = class('TileSet')

--- Create a new TileSet instance
-- @param name string Name of the tileset
-- @param imagePath string Path to the PNG tileset image
-- @param tileWidth number Width of each tile in pixels
-- @param tileHeight number Height of each tile in pixels
-- @return TileSet instance
function TileSet:initialize(name, imagePath, tileWidth, tileHeight)
    self.name = name
    self.imagePath = imagePath
    self.tileWidth = tileWidth or 20
    self.tileHeight = tileHeight or 20
    self.image = nil -- Will be loaded when needed
    self.tiles = {} -- Dictionary of tile categories
end

--- Load the tileset image
-- @return boolean Success status
function TileSet:loadImage()
    if self.image then return true end

    -- Load the PNG image
    local success, img = pcall(love.graphics.newImage, self.imagePath)
    if success then
        self.image = img
        return true
    else
        print("Failed to load tileset image: " .. self.imagePath)
        return false
    end
end

--- Add a tile category with multiple tiles
-- @param categoryName string Name of the category (e.g., "forest", "urban")
-- @param tiles table Dictionary of position keys to tile data
function TileSet:addTileCategory(categoryName, tiles)
    self.tiles[categoryName] = tiles
end

--- Get tile data for a specific category and position
-- @param categoryName string Category name
-- @param positionKey string Position key (e.g., "34")
-- @return table|nil Tile data or nil if not found
function TileSet:getTile(categoryName, positionKey)
    local category = self.tiles[categoryName]
    if not category then return nil end

    return category[positionKey]
end

--- Get the quad (rectangle) for a tile at the given position
-- @param positionKey string Position key (e.g., "34")
-- @return table Quad data {x, y, width, height}
function TileSet:getTileQuad(positionKey)
    -- Parse position key (assuming format like "34" means row 3, column 4)
    local row = math.floor(tonumber(positionKey) / 10)
    local col = tonumber(positionKey) % 10

    return {
        x = col * self.tileWidth,
        y = row * self.tileHeight,
        width = self.tileWidth,
        height = self.tileHeight
    }
end

--- Draw a tile from this tileset
-- @param categoryName string Category name
-- @param positionKey string Position key
-- @param x number Screen X coordinate
-- @param y number Screen Y coordinate
-- @param scale number Scale factor (default 1)
function TileSet:drawTile(categoryName, positionKey, x, y, scale)
    scale = scale or 1

    if not self:loadImage() then return end

    local tileData = self:getTile(categoryName, positionKey)
    if not tileData then return end

    local quad = self:getTileQuad(positionKey)

    -- Create quad for drawing
    local quadObj = love.graphics.newQuad(
        quad.x, quad.y,
        quad.width, quad.height,
        self.image:getDimensions()
    )

    love.graphics.draw(
        self.image, quadObj,
        x, y, 0,
        scale, scale
    )
end

--- Get dimensions of the tileset image
-- @return number, number Width and height in pixels
function TileSet:getImageDimensions()
    if not self.image then return 0, 0 end
    return self.image:getDimensions()
end

--- Get number of tiles in each dimension
-- @return number, number Number of tiles wide and tall
function TileSet:getTileGridSize()
    local imgWidth, imgHeight = self:getImageDimensions()
    return math.floor(imgWidth / self.tileWidth), math.floor(imgHeight / self.tileHeight)
end

return TileSet