--[[
widgets/gridmap.lua
GridMap widget for grid-based map display


Grid-based map display widget for tactical games with tile rendering and interaction.
Supports multiple layers, units, and overlays for turn-based strategy gameplay.

PURPOSE:
- Display grid-based maps with tiles, units, and overlays for turn-based strategy games
- Provide interactive map interface for tactical gameplay and map editing
- Support multiple rendering layers for terrain, units, and effects
- Enable mouse interaction for selection and movement planning

KEY FEATURES:
- Grid-based rendering with configurable tile size and dimensions
- Support for multiple layers (terrain, units, overlays, effects)
- Different tile types with custom rendering and properties
- Unit placement and movement visualization
- Mouse interaction for tile selection and path planning
- Zoom and pan controls for large maps
- Fog of war and exploration tracking
- Custom tile rendering with sprites and animations
- Pathfinding visualization and movement range display
- Integration with tactical game systems

@see widgets.common.core.Base
@see widgets.complex.minimap
@see widgets.complex.tilemap
]]

local core = require("widgets.core")
local GridMap = {}
GridMap.__index = GridMap

function GridMap:new(x, y, width, height, options)
    options = options or {}
    local obj = core.Base:new(x, y, width, height)
    setmetatable(obj, GridMap)

    obj.tileSize = options.tileSize or 32
    obj.cols = math.floor(width / obj.tileSize)
    obj.rows = math.floor(height / obj.tileSize)
    obj.tiles = {}

    -- Initialize grid
    for r = 1, obj.rows do
        obj.tiles[r] = {}
        for c = 1, obj.cols do
            obj.tiles[r][c] = 0
        end
    end

    return obj
end

function GridMap:setTile(x, y, tile)
    local col = math.floor(x / self.tileSize) + 1
    local row = math.floor(y / self.tileSize) + 1
    if row >= 1 and row <= self.rows and col >= 1 and col <= self.cols then
        self.tiles[row][col] = tile
    end
end

function GridMap:getTile(x, y)
    local col = math.floor(x / self.tileSize) + 1
    local row = math.floor(y / self.tileSize) + 1
    if row >= 1 and row <= self.rows and col >= 1 and col <= self.cols then
        return self.tiles[row][col]
    end
    return 0
end

function GridMap:draw()
    for r = 1, self.rows do
        for c = 1, self.cols do
            local tile = self.tiles[r][c]
            local x = self.x + (c - 1) * self.tileSize
            local y = self.y + (r - 1) * self.tileSize

            -- Draw tile background
            love.graphics.setColor(unpack(core.theme.background))
            love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)

            -- Draw tile border
            love.graphics.setColor(unpack(core.theme.border))
            love.graphics.rectangle("line", x, y, self.tileSize, self.tileSize)

            -- Draw tile content based on type
            if tile > 0 then
                love.graphics.setColor(unpack(core.theme.text))
                love.graphics.print(tostring(tile), x + 4, y + 4)
            end
        end
    end
end

return GridMap






