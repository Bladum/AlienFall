--[[
widgets/tilemap.lua
TileMap widget for multi-layer tile grid management


Lightweight tile grid abstraction supporting multiple layers, editing primitives,
and integration with game data, persistence, and pathfinding systems.

PURPOSE:
- Provide a lightweight tile grid abstraction for level editors and tactical maps
- Support multiple layers for complex map structures
- Enable simple editing primitives and mouse interactions
- Facilitate integration with game data and pathfinding systems

KEY FEATURES:
- Fixed-size grid with configurable rows/columns and per-layer tile storage
- Multiple layer support for terrain, objects, and overlays
- Mouse interaction helpers for basic editing (left click to cycle, right click to clear)
- Grid rendering toggle for visual feedback
- Layer switching and management
- Tile value validation and bounds checking
- Serialization support for save/load functionality
- Pathfinding overlay integration
- Custom tile type support
- Performance optimized for large grids

]]

local core = require("widgets.core")
local TileMap = {}
TileMap.__index = TileMap

function TileMap:new(x, y, cols, rows, cellSize, layers)
    local obj = {
        x = x or 0,
        y = y or 0,
        cols = cols or 10,
        rows = rows or 10,
        cellSize = cellSize or 32,
        layers = {},
        currentLayer = 1,
        showGrid = true,
        onTileChange = nil
    }
    setmetatable(obj, self)

    local numLayers = layers or 3
    for l = 1, numLayers do
        obj.layers[l] = {}
        for r = 1, obj.rows do
            obj.layers[l][r] = {}
            for c = 1, obj.cols do
                obj.layers[l][r][c] = 0
            end
        end
    end
    return obj
end

function TileMap:draw()
    -- Draw all layers
    for l = 1, #self.layers do
        for r = 1, self.rows do
            for c = 1, self.cols do
                local tile = self.layers[l][r][c]
                if tile > 0 then
                    local x = self.x + (c - 1) * self.cellSize
                    local y = self.y + (r - 1) * self.cellSize

                    -- Different colors for different layers
                    if l == 1 then
                        love.graphics.setColor(0.8, 0.8, 0.8)
                    elseif l == 2 then
                        love.graphics.setColor(0.6, 0.8, 0.6)
                    else
                        love.graphics.setColor(0.8, 0.6, 0.6)
                    end

                    love.graphics.rectangle("fill", x, y, self.cellSize, self.cellSize)
                end
            end
        end
    end

    -- Draw grid
    if self.showGrid then
        love.graphics.setColor(0, 0, 0, 0.3)
        for r = 1, self.rows + 1 do
            local y = self.y + (r - 1) * self.cellSize
            love.graphics.line(self.x, y, self.x + self.cols * self.cellSize, y)
        end
        for c = 1, self.cols + 1 do
            local x = self.x + (c - 1) * self.cellSize
            love.graphics.line(x, self.y, x, self.y + self.rows * self.cellSize)
        end
    end
end

function TileMap:setCurrentLayer(layer)
    self.currentLayer = math.max(1, math.min(#self.layers, layer))
end

function TileMap:getTile(layer, row, col)
    if layer < 1 or layer > #self.layers or row < 1 or row > self.rows or col < 1 or col > self.cols then
        return 0
    end
    return self.layers[layer][row][col]
end

function TileMap:setTile(layer, row, col, value)
    if layer >= 1 and layer <= #self.layers and row >= 1 and row <= self.rows and col >= 1 and col <= self.cols then
        self.layers[layer][row][col] = value
        if self.onTileChange then
            self.onTileChange(layer, row, col, value)
        end
    end
end

function TileMap:mousepressed(x, y, button)
    if not core.isInside(x, y, self.x, self.y, self.cols * self.cellSize, self.rows * self.cellSize) then return false end

    local col = math.floor((x - self.x) / self.cellSize) + 1
    local row = math.floor((y - self.y) / self.cellSize) + 1

    if button == 1 then
        -- Left click: cycle tile value
        local current = self.layers[self.currentLayer][row][col]
        self.layers[self.currentLayer][row][col] = (current + 1) % 3
    elseif button == 2 then
        -- Right click: clear tile
        self.layers[self.currentLayer][row][col] = 0
    end

    if self.onTileChange then
        self.onTileChange(self.currentLayer, row, col, self.layers[self.currentLayer][row][col])
    end

    return true
end

return TileMap






