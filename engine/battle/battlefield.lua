-- Battlefield Module
-- Manages the tactical battle map, tiles, and spatial operations

local BattleTile = require("systems.battle_tile")
local DataLoader = require("systems.data_loader")

--- @class Battlefield
--- Manages the tactical battle map with terrain generation, tile management, and spatial operations.
--- Provides optimized map generation with pre-calculated features and efficient tile access methods.
--- Supports unit placement, movement tracking, and pathfinding operations.
---
--- @field width number Map width in tiles (default: 30)
--- @field height number Map height in tiles (default: 30)
--- @field mapWidth number Alias for width for compatibility
--- @field mapHeight number Alias for height for compatibility
--- @field tileSize number Size of each tile in pixels (default: 24)
--- @field map table[][] 2D array of BattleTile objects [y][x]
local Battlefield = {}
Battlefield.__index = Battlefield

--- Creates a new battlefield with the specified dimensions.
--- Automatically generates a map with terrain features, rooms, and paths.
---
--- @param width number|nil Map width in tiles (default: 30)
--- @param height number|nil Map height in tiles (default: 30)
--- @return Battlefield A new Battlefield instance with generated map
function Battlefield.new(width, height)
    local self = setmetatable({}, Battlefield)

    self.width = width or 30
    self.height = height or 30
    self.mapWidth = self.width  -- Alias for compatibility
    self.mapHeight = self.height  -- Alias for compatibility
    self.tileSize = 24
    self.map = {}

    self:generate()

    return self
end

--- Generates the battlefield map with optimized terrain features.
--- Creates base tiles, adds wooden rooms, stone wall clusters, tree groves, and paths.
--- Uses batch processing and pre-calculated features for performance.
function Battlefield:generate()
    local genStartTime = love and love.timer and love.timer.getTime() or os.clock()

    -- OPTIMIZATION: Pre-allocate all tiles in one pass
    local passStartTime = love and love.timer and love.timer.getTime() or os.clock()
    for y = 1, self.height do
        self.map[y] = {}
        for x = 1, self.width do
            local terrainId = "floor"

            -- Create borders as walls
            if x == 1 or x == self.width or y == 1 or y == self.height then
                terrainId = "wall"
            end

            self.map[y][x] = BattleTile.new(terrainId, x, y)
        end
    end

    if love and love.timer then
        local passTime = (love.timer.getTime() - passStartTime) * 1000
        print(string.format("[Battlefield] Base tiles created: %.3f ms", passTime))
    end

    -- OPTIMIZATION: Batch terrain features (fewer random checks)
    local featureStartTime = love and love.timer and love.timer.getTime() or os.clock()

    -- Pre-calculate feature zones to avoid overlapping checks
    local features = {
        -- Wooden rooms (3 total)
        {type = "room", x = 15, y = 15, w = 8, h = 6},
        {type = "room", x = 45, y = 45, w = 8, h = 6},
        {type = "room", x = 70, y = 20, w = 8, h = 6},

        -- Stone wall clusters (4 total)
        {type = "stone", x = 25, y = 25, w = 6, h = 4},
        {type = "stone", x = 60, y = 10, w = 5, h = 5},
        {type = "stone", x = 10, y = 70, w = 7, h = 3},
        {type = "stone", x = 75, y = 65, w = 4, h = 6},

        -- Tree groves (4 total)
        {type = "trees", x = 25, y = 60, w = 12, h = 12},
        {type = "trees", x = 60, y = 75, w = 15, h = 15},
        {type = "trees", x = 10, y = 35, w = 10, h = 10},
        {type = "trees", x = 40, y = 10, w = 8, h = 8},
    }

    -- Apply all features in batch
    for _, feature in ipairs(features) do
        if feature.type == "room" then
            self:addWoodenRoomFast(feature.x, feature.y, feature.w, feature.h)
        elseif feature.type == "stone" then
            self:addStoneWallClusterFast(feature.x, feature.y, feature.w, feature.h)
        elseif feature.type == "trees" then
            self:addTreeGroveFast(feature.x, feature.y, feature.w, feature.h)
        end
    end

    if love and love.timer then
        local featureTime = (love.timer.getTime() - featureStartTime) * 1000
        print(string.format("[Battlefield] Features added: %.3f ms", featureTime))
    end

    -- OPTIMIZATION: Paths last (fewer tile overwrites)
    local pathStartTime = love and love.timer and love.timer.getTime() or os.clock()
    self:addPathFast(10, 10, 80, 80)
    self:addPathFast(20, 80, 80, 20)
    self:addPathFast(45, 10, 45, 80)

    if love and love.timer then
        local pathTime = (love.timer.getTime() - pathStartTime) * 1000
        print(string.format("[Battlefield] Paths added: %.3f ms", pathTime))
        local totalTime = (love.timer.getTime() - genStartTime) * 1000
        print(string.format("[Battlefield] Generated %dx%d map with features in %.3f ms", self.width, self.height, totalTime))
    else
        print(string.format("[Battlefield] Generated %dx%d map with features", self.width, self.height))
    end
end

--- Adds a wooden room with walls around the perimeter and floor inside.
--- Optimized version with pre-calculated bounds and no internal bounds checking.
---
--- @param startX number Starting X coordinate (1-based)
--- @param startY number Starting Y coordinate (1-based)
--- @param width number Room width in tiles
--- @param height number Room height in tiles
function Battlefield:addWoodenRoomFast(startX, startY, width, height)
    local endX = math.min(startX + width - 1, self.height - 1)
    local endY = math.min(startY + height - 1, self.height - 1)
    local rightX = startX + width - 1
    local bottomY = startY + height - 1

    for y = startY, endY do
        for x = startX, endX do
            -- Create walls on perimeter
            if x == startX or x == rightX or y == startY or y == bottomY then
                self.map[y][x].terrain = DataLoader.terrainTypes.get("wood_wall")
                self.map[y][x].terrainId = "wood_wall"
            else
                -- Floor inside
                self.map[y][x].terrain = DataLoader.terrainTypes.get("floor")
                self.map[y][x].terrainId = "floor"
            end
        end
    end
end

--- Adds a cluster of stone walls with random placement probability.
--- Optimized version with pre-calculated bounds and batched terrain updates.
---
--- @param startX number Starting X coordinate (1-based)
--- @param startY number Starting Y coordinate (1-based)
--- @param width number Cluster width in tiles
--- @param height number Cluster height in tiles
function Battlefield:addStoneWallClusterFast(startX, startY, width, height)
    local endX = math.min(startX + width - 1, self.height - 1)
    local endY = math.min(startY + height - 1, self.height - 1)
    local wallTerrain = DataLoader.terrainTypes.get("wall")

    for y = startY, endY do
        for x = startX, endX do
            -- Random chance to place stone wall (60%)
            if math.random() < 0.6 then
                self.map[y][x].terrain = wallTerrain
                self.map[y][x].terrainId = "wall"
            end
        end
    end
end

--- Adds a grove of trees with random placement probability.
--- Optimized version with pre-calculated bounds and batched terrain updates.
---
--- @param startX number Starting X coordinate (1-based)
--- @param startY number Starting Y coordinate (1-based)
--- @param width number Grove width in tiles
--- @param height number Grove height in tiles
function Battlefield:addTreeGroveFast(startX, startY, width, height)
    local endX = math.min(startX + width - 1, self.height - 1)
    local endY = math.min(startY + height - 1, self.height - 1)
    local treeTerrain = DataLoader.terrainTypes.get("tree")

    for y = startY, endY do
        if y >= 1 then
            for x = startX, endX do
                if x >= 1 and math.random() < 0.85 then
                    self.map[y][x].terrain = treeTerrain
                    self.map[y][x].terrainId = "tree"
                end
            end
        end
    end
end

--- Adds a wide path between two points using Bresenham's line algorithm.
--- Optimized version with pre-calculated positions and batched terrain updates.
---
--- @param x1 number Starting X coordinate (1-based)
--- @param y1 number Starting Y coordinate (1-based)
--- @param x2 number Ending X coordinate (1-based)
--- @param y2 number Ending Y coordinate (1-based)
function Battlefield:addPathFast(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    local steps = math.max(math.abs(dx), math.abs(dy))

    if steps == 0 then return end

    local stepX = dx / steps
    local stepY = dy / steps
    local roadTerrain = DataLoader.terrainTypes.get("road")

    -- Pre-calculate all path positions
    for i = 0, steps do
        local px = math.floor(x1 + stepX * i)
        local py = math.floor(y1 + stepY * i)

        if px >= 2 and px < self.width and py >= 2 and py < self.height then
            self.map[py][px].terrain = roadTerrain
            self.map[py][px].terrainId = "road"

            -- Make path wider (3 tiles) - batch update
            if px + 1 < self.width then
                self.map[py][px + 1].terrain = roadTerrain
                self.map[py][px + 1].terrainId = "road"
            end
            if py + 1 < self.height then
                self.map[py + 1][px].terrain = roadTerrain
                self.map[py + 1][px].terrainId = "road"
            end
        end
    end
end

--- Compatibility method for adding wooden rooms (calls optimized version).
---
--- @param startX number Starting X coordinate (1-based)
--- @param startY number Starting Y coordinate (1-based)
--- @param width number Room width in tiles
--- @param height number Room height in tiles
function Battlefield:addWoodenRoom(startX, startY, width, height)
    return self:addWoodenRoomFast(startX, startY, width, height)
end

--- Compatibility method for adding stone wall clusters (calls optimized version).
---
--- @param startX number Starting X coordinate (1-based)
--- @param startY number Starting Y coordinate (1-based)
--- @param width number Cluster width in tiles
--- @param height number Cluster height in tiles
function Battlefield:addStoneWallCluster(startX, startY, width, height)
    return self:addStoneWallClusterFast(startX, startY, width, height)
end

--- Compatibility method for adding tree groves (calls optimized version).
---
--- @param startX number Starting X coordinate (1-based)
--- @param startY number Starting Y coordinate (1-based)
--- @param width number Grove width in tiles
--- @param height number Grove height in tiles
function Battlefield:addTreeGrove(startX, startY, width, height)
    return self:addTreeGroveFast(startX, startY, width, height)
end

--- Compatibility method for adding paths (calls optimized version).
---
--- @param x1 number Starting X coordinate (1-based)
--- @param y1 number Starting Y coordinate (1-based)
--- @param x2 number Ending X coordinate (1-based)
--- @param y2 number Ending Y coordinate (1-based)
function Battlefield:addPath(x1, y1, x2, y2)
    return self:addPathFast(x1, y1, x2, y2)
end

--- Gets the tile at the specified coordinates.
---
--- @param x number X coordinate (1-based)
--- @param y number Y coordinate (1-based)
--- @return table|nil The BattleTile at the position, or nil if out of bounds
function Battlefield:getTile(x, y)
    if x >= 1 and x <= self.width and y >= 1 and y <= self.height then
        return self.map[y][x]
    end
    return nil
end

--- Checks if the given coordinates are within the map bounds.
---
--- @param x number X coordinate (1-based)
--- @param y number Y coordinate (1-based)
--- @return boolean True if position is valid, false otherwise
function Battlefield:isValidPosition(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

--- Checks if the tile at the given coordinates is walkable.
---
--- @param x number X coordinate (1-based)
--- @param y number Y coordinate (1-based)
--- @return boolean True if tile exists and doesn't block movement, false otherwise
function Battlefield:isWalkable(x, y)
    local tile = self:getTile(x, y)
    if not tile then return false end

    -- tile.terrain is already the terrain object from TerrainTypes
    return tile.terrain and not tile.terrain.blocksMovement
end

--- Checks if the given position is occupied by any unit from the provided units table.
---
--- @param x number X coordinate (1-based)
--- @param y number Y coordinate (1-based)
--- @param units table Table of units to check against
--- @return boolean True if position is occupied by a living unit, false otherwise
function Battlefield:isOccupied(x, y, units)
    for _, unit in pairs(units) do
        if unit.alive and unit:occupiesTile(x, y) then
            return true
        end
    end
    return false
end

--- Gets the unit occupying the specified tile position.
---
--- @param x number X coordinate (1-based)
--- @param y number Y coordinate (1-based)
--- @param units table Table of units to search
--- @return table|nil The unit at the position, or nil if no unit found
function Battlefield:getUnitAt(x, y, units)
    for _, unit in pairs(units) do
        if unit.alive and unit:occupiesTile(x, y) then
            return unit
        end
    end
    return nil
end

--- Places a unit on the map by marking all tiles it occupies.
---
--- @param unit table The unit to place (must have getOccupiedTiles() method)
function Battlefield:placeUnit(unit)
    for _, tile in ipairs(unit:getOccupiedTiles()) do
        local mapTile = self:getTile(tile.x, tile.y)
        if mapTile then
            mapTile.unit = unit
        end
    end
end

--- Moves a unit from its current position to a new position on the map.
---
--- @param unit table The unit to move (must have x, y fields and getOccupiedTiles() method)
--- @param newX number New X coordinate (1-based)
--- @param newY number New Y coordinate (1-based)
function Battlefield:moveUnit(unit, newX, newY)
    -- Remove from old position
    self:removeUnit(unit)

    -- Update unit position
    unit.x = newX
    unit.y = newY

    -- Place at new position
    self:placeUnit(unit)
end

--- Removes a unit from the map by clearing all tiles it occupies.
---
--- @param unit table The unit to remove (must have getOccupiedTiles() method)
function Battlefield:removeUnit(unit)
    for _, tile in ipairs(unit:getOccupiedTiles()) do
        local mapTile = self:getTile(tile.x, tile.y)
        if mapTile and mapTile.unit == unit then
            mapTile.unit = nil
        end
    end
end

--- Gets all tiles in the map as a flat array.
---
--- @return table[] Array of all BattleTile objects in the map
function Battlefield:getAllTiles()
    local tiles = {}
    for y = 1, self.height do
        for x = 1, self.width do
            table.insert(tiles, self.map[y][x])
        end
    end
    return tiles
end

--- Gets all neighboring tiles in 8 directions (including diagonals).
---
--- @param x number Center X coordinate (1-based)
--- @param y number Center Y coordinate (1-based)
--- @return table[] Array of neighbor objects with {x, y, tile} fields
function Battlefield:getNeighbors(x, y)
    local neighbors = {}
    local directions = {
        {-1, -1}, {0, -1}, {1, -1},
        {-1, 0},           {1, 0},
        {-1, 1},  {0, 1},  {1, 1}
    }

    for _, dir in ipairs(directions) do
        local nx, ny = x + dir[1], y + dir[2]
        if self:isValidPosition(nx, ny) then
            table.insert(neighbors, {x = nx, y = ny, tile = self:getTile(nx, ny)})
        end
    end

    return neighbors
end

--- Calculates the Manhattan distance between two points using hex coordinates.
---
--- @param x1 number First point X coordinate (1-based)
--- @param y1 number First point Y coordinate (1-based)
--- @param x2 number Second point X coordinate (1-based)
--- @param y2 number Second point Y coordinate (1-based)
--- @return number Hex distance between the points
function Battlefield:getManhattanDistance(x1, y1, x2, y2)
    local HexMath = require("utils.hex_math")
    local q1, r1 = HexMath.offsetToAxial(x1, y1)
    local q2, r2 = HexMath.offsetToAxial(x2, y2)
    return HexMath.distance(q1, r1, q2, r2)
end

--- Calculates the Euclidean distance between two points (kept for compatibility).
---
--- @param x1 number First point X coordinate
--- @param y1 number First point Y coordinate
--- @param x2 number Second point X coordinate
--- @param y2 number Second point Y coordinate
--- @return number Euclidean distance between the points
function Battlefield:getEuclideanDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx*dx + dy*dy)
end

return Battlefield
