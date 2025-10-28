---TilePalette - Individual Tile Selection Widget for Map Editor
---
---Grid-based widget displaying all tiles from a selected tileset, allowing individual
---tile selection for painting operations in the map editor. Shows tile previews with
---scrolling and selection feedback. Part of map editor enhancement (Phase 5).
---
---Features:
---  - Grid layout of tiles from selected tileset
---  - Visual tile selection with highlighting
---  - Scrollable interface for large tilesets
---  - Tile preview images and tooltips
---  - Integration with tileset data system
---  - Callback system for tile selection events
---
---Key Exports:
---  - new(x, y, width, height): Create new tile palette widget
---  - setTileset(tilesetId): Set tileset to display tiles from
---  - handleClick(mouseX, mouseY, button): Handle tile selection
---  - handleScroll(dy): Handle mouse wheel scrolling
---  - draw(): Render the tile palette grid
---  - getSelectedTile(): Get currently selected tile data
---
---Dependencies:
---  - require("gui.widgets.core.base"): Base widget class
---  - require("gui.widgets.core.theme"): UI theming system
---  - require("battlescape.data.tilesets"): Tileset definitions and textures
---
---@module battlescape.ui.tile_palette
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TilePalette = require("battlescape.ui.tile_palette")
---  local palette = TilePalette.new(220, 10, 200, 300)
---  palette:setTileset("forest_tileset")
---  palette.onSelect = function(tileKey) print("Selected tile:", tileKey) end
---
---@see battlescape.ui.map_editor For main map editor interface
---@see battlescape.ui.tileset_browser For tileset selection

-- Tile Palette Widget
-- Phase 5: Map Editor Enhancement
-- Display and select individual Map Tiles from a tileset

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")
local Widgets = require("gui.widgets.init")
local Tilesets = require("battlescape.data.tilesets")

---@class TilePalette
---@field tilesetId string? Current tileset ID
---@field tiles table Array of tile data {id, key, texture}
---@field selectedTile table? Currently selected tile
---@field scrollOffset number Vertical scroll position
---@field tileSize number Size of each tile in pixels
---@field tilesPerRow number Number of tiles per row
---@field onTileSelected function? Callback when tile is selected
---@field isPointInside fun(self, x: number, y: number): boolean Check if point is inside widget
---@field handleScroll fun(self, delta: number) Handle scroll wheel input

local TilePalette = setmetatable({}, {__index = BaseWidget})
TilePalette.__index = TilePalette

---Create new Tile Palette
---@param x number X position (will snap to grid)
---@param y number Y position (will snap to grid)
---@param width number Width (will snap to grid)
---@param height number Height (will snap to grid)
---@return TilePalette
function TilePalette.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height)
    setmetatable(self, TilePalette)
    
    self.tilesetId = nil
    self.tiles = {} -- Array of {id, key, texture}
    self.selectedTile = nil
    self.scrollOffset = 0
    self.tileSize = 48 -- Display size for tiles (2 grid cells)
    self.tilesPerRow = math.floor((width - 16) / (self.tileSize + 8))
    self.onSelect = nil -- Callback function(tileKey)
    
    return self
end

---Set tileset to display
---@param tilesetId string Tileset ID
function TilePalette:setTileset(tilesetId)
    self.tilesetId = tilesetId
    self.tiles = {}
    self.selectedTile = nil
    self.scrollOffset = 0
    
    if not tilesetId then
        return
    end
    
    local tileset = Tilesets.get(tilesetId)
    if not tileset then
        print(string.format("[TilePalette] Tileset not found: %s", tilesetId))
        return
    end
    
    -- Build tile list
    for tileId, tile in pairs(tileset.tiles) do
        local key = string.format("%s:%s", tilesetId, tileId)
        table.insert(self.tiles, {
            id = tileId,
            key = key,
            tile = tile
        })
    end
    
    -- Sort by ID
    table.sort(self.tiles, function(a, b)
        return a.id < b.id
    end)
    
    print(string.format("[TilePalette] Loaded %d tiles from %s", #self.tiles, tilesetId))
end

---Handle mouse click
---@param mouseX number Mouse X
---@param mouseY number Mouse Y
---@param button number Mouse button
---@return boolean handled
function TilePalette:handleClick(mouseX, mouseY, button)
    if not self:isPointInside(mouseX, mouseY) then
        return false
    end
    
    if button == 1 then -- Left click
        local relativeX = mouseX - self.x - 8
        local relativeY = mouseY - self.y - 8 + self.scrollOffset
        
        local col = math.floor(relativeX / (self.tileSize + 8))
        local row = math.floor(relativeY / (self.tileSize + 8))
        
        local index = row * self.tilesPerRow + col + 1
        
        if index >= 1 and index <= #self.tiles then
            local tile = self.tiles[index]
            self.selectedTile = tile.key
            
            if self.onSelect then
                self.onSelect(tile.key)
            end
            
            print(string.format("[TilePalette] Selected: %s", tile.key))
            return true
        end
    end
    
    return false
end

---Handle mouse wheel scroll
---@param dy number Scroll delta
function TilePalette:handleScroll(dy)
    self.scrollOffset = math.max(0, self.scrollOffset - dy * 24)
    
    -- Calculate content height
    local rows = math.ceil(#self.tiles / self.tilesPerRow)
    local contentHeight = rows * (self.tileSize + 8) + 8
    local maxScroll = math.max(0, contentHeight - self.height)
    self.scrollOffset = math.min(self.scrollOffset, maxScroll)
end

---Draw the widget
function TilePalette:draw()
    if not self.visible then return end
    
    love.graphics.push()
    
    -- Draw background
    love.graphics.setColor(Theme.colors.background.r, Theme.colors.background.g,
                          Theme.colors.background.b, Theme.colors.background.a)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    love.graphics.setColor(Theme.colors.border.r, Theme.colors.border.g,
                          Theme.colors.border.b, Theme.colors.border.a)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Set scissor for scrolling
    love.graphics.setScissor(self.x, self.y, self.width, self.height)
    
    -- Draw tiles
    local startY = self.y + 8 - self.scrollOffset
    
    for i, tileData in ipairs(self.tiles) do
        local col = (i - 1) % self.tilesPerRow
        local row = math.floor((i - 1) / self.tilesPerRow)
        
        local tileX = self.x + 8 + col * (self.tileSize + 8)
        local tileY = startY + row * (self.tileSize + 8)
        
        -- Skip if not visible
        if tileY + self.tileSize < self.y or tileY > self.y + self.height then
            goto continue
        end
        
        -- Draw selection highlight
        local isSelected = (tileData.key == self.selectedTile)
        if isSelected then
            love.graphics.setColor(Theme.colors.primary.r, Theme.colors.primary.g,
                                  Theme.colors.primary.b, 0.5)
            love.graphics.rectangle("fill", tileX - 2, tileY - 2, 
                                  self.tileSize + 4, self.tileSize + 4)
        end
        
        -- Draw tile background (checkerboard for transparency)
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", tileX, tileY, self.tileSize, self.tileSize)
        
        -- Draw tile placeholder (actual texture rendering would go here)
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.rectangle("line", tileX, tileY, self.tileSize, self.tileSize)
        
        -- Draw tile ID
        love.graphics.setColor(Theme.colors.text.r, Theme.colors.text.g,
                              Theme.colors.text.b, 0.7)
        love.graphics.setFont(Theme.fonts.small)
        local displayId = tileData.id
        if #displayId > 8 then
            displayId = displayId:sub(1, 8) .. "..."
        end
        love.graphics.print(displayId, tileX + 2, tileY + 2)
        
        ::continue::
    end
    
    love.graphics.setScissor()
    
    -- Draw info text if no tileset selected
    if #self.tiles == 0 then
        love.graphics.setColor(Theme.colors.textSecondary.r, Theme.colors.textSecondary.g,
                              Theme.colors.textSecondary.b, Theme.colors.textSecondary.a)
        love.graphics.setFont(Theme.fonts.default)
        love.graphics.printf("Select a tileset", self.x, self.y + self.height / 2 - 10,
                           self.width, "center")
    end
    
    love.graphics.pop()
end

---Check if point is inside widget
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@return boolean
function TilePalette:isPointInside(x, y)
    return self:containsPoint(x, y)
end

return TilePalette


























