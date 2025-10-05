--- Battle Map
-- Manages the 2D grid of battle tiles and provides spatial queries
--
-- @classmod battlescape.BattleMap

-- GROK: BattleMap manages 40x30 logical tile grid with spatial queries and pathfinding support
-- GROK: Provides tile access, distance calculations, and boundary validation
-- GROK: Key methods: getTile(), isValidTile(), getDistance(), getAdjacentTiles()
-- GROK: Integrates with BattleTile for terrain properties and environmental effects

local class = require 'lib.Middleclass'
local BattleTile = require 'battlescape.BattleTile'

--- BattleMap class
-- @type BattleMap
BattleMap = class('BattleMap')

--- Create a new BattleMap instance
-- @param width Map width in tiles
-- @param height Map height in tiles
-- @return BattleMap instance
function BattleMap:initialize(width, height)
    self.width = width or 40
    self.height = height or 30
    self.tiles = {} -- 2D array of BattleTile instances

    -- Initialize empty map
    self:initializeEmptyMap()
end

--- Initialize empty map with default tiles
function BattleMap:initializeEmptyMap()
    for x = 1, self.width do
        self.tiles[x] = {}
        for y = 1, self.height do
            self.tiles[x][y] = BattleTile(x, y, {})
        end
    end
end

--- Get tile at coordinates
-- @param x X coordinate (1-based)
-- @param y Y coordinate (1-based)
-- @return BattleTile or nil
function BattleMap:getTile(x, y)
    if not self:isValidTile(x, y) then
        return nil
    end
    return self.tiles[x][y]
end

--- Set tile at coordinates
-- @param x X coordinate (1-based)
-- @param y Y coordinate (1-based)
-- @param tile BattleTile instance
function BattleMap:setTile(x, y, tile)
    if self:isValidTile(x, y) then
        self.tiles[x][y] = tile
    end
end

--- Check if coordinates are valid
-- @param x X coordinate
-- @param y Y coordinate
-- @return boolean Whether coordinates are valid
function BattleMap:isValidTile(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

--- Get map dimensions
-- @return number width, number height
function BattleMap:getDimensions()
    return self.width, self.height
end

--- Get Manhattan distance between two positions
-- @param pos1 First position (table with x,y)
-- @param pos2 Second position (table with x,y)
-- @return number Distance
function BattleMap:getDistance(pos1, pos2)
    return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
end

--- Get Chebyshev distance (diagonal movement)
-- @param pos1 First position
-- @param pos2 Second position
-- @return number Distance
function BattleMap:getChebyshevDistance(pos1, pos2)
    return math.max(math.abs(pos1.x - pos2.x), math.abs(pos1.y - pos2.y))
end

--- Get Euclidean distance
-- @param pos1 First position
-- @param pos2 Second position
-- @return number Distance
function BattleMap:getEuclideanDistance(pos1, pos2)
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    return math.sqrt(dx * dx + dy * dy)
end

--- Get adjacent tiles (orthogonal and diagonal)
-- @param x Center X coordinate
-- @param y Center Y coordinate
-- @param includeDiagonals Whether to include diagonal tiles
-- @return table List of adjacent tiles
function BattleMap:getAdjacentTiles(x, y, includeDiagonals)
    local adjacent = {}

    for dx = -1, 1 do
        for dy = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                if includeDiagonals or math.abs(dx) + math.abs(dy) == 1 then
                    local nx, ny = x + dx, y + dy
                    if self:isValidTile(nx, ny) then
                        table.insert(adjacent, self.tiles[nx][ny])
                    end
                end
            end
        end
    end

    return adjacent
end

--- Get orthogonal adjacent tiles (no diagonals)
-- @param x Center X coordinate
-- @param y Center Y coordinate
-- @return table List of orthogonal adjacent tiles
function BattleMap:getOrthogonalAdjacentTiles(x, y)
    return self:getAdjacentTiles(x, y, false)
end

--- Check if there's a clear line between two tiles (for line of sight/fire)
-- @param startX Starting X coordinate
-- @param startY Starting Y coordinate
-- @param endX Ending X coordinate
-- @param endY Ending Y coordinate
-- @return boolean Whether line is clear
function BattleMap:hasClearLine(startX, startY, endX, endY)
    -- Bresenham's line algorithm
    local dx = math.abs(endX - startX)
    local dy = math.abs(endY - startY)
    local sx = startX < endX and 1 or -1
    local sy = startY < endY and 1 or -1
    local err = dx - dy

    local x, y = startX, startY

    while true do
        -- Check if current tile blocks vision
        local tile = self:getTile(x, y)
        if tile and tile:blocksVision() then
            return false
        end

        if x == endX and y == endY then
            break
        end

        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x = x + sx
        end
        if e2 < dx then
            err = err + dx
            y = y + sy
        end
    end

    return true
end

--- Get tiles in a rectangle
-- @param startX Starting X coordinate
-- @param startY Starting Y coordinate
-- @param endX Ending X coordinate
-- @param endY Ending Y coordinate
-- @return table List of tiles in rectangle
function BattleMap:getTilesInRectangle(startX, startY, endX, endY)
    local tiles = {}
    local minX, maxX = math.min(startX, endX), math.max(startX, endX)
    local minY, maxY = math.min(startY, endY), math.max(startY, endY)

    for x = minX, maxX do
        for y = minY, maxY do
            local tile = self:getTile(x, y)
            if tile then
                table.insert(tiles, tile)
            end
        end
    end

    return tiles
end

--- Get tiles in a circle
-- @param centerX Center X coordinate
-- @param centerY Center Y coordinate
-- @param radius Circle radius
-- @return table List of tiles in circle
function BattleMap:getTilesInCircle(centerX, centerY, radius)
    local tiles = {}

    for x = centerX - radius, centerX + radius do
        for y = centerY - radius, centerY + radius do
            if self:getDistance({x = centerX, y = centerY}, {x = x, y = y}) <= radius then
                local tile = self:getTile(x, y)
                if tile then
                    table.insert(tiles, tile)
                end
            end
        end
    end

    return tiles
end

--- Find path between two points using A*
-- @param startX Starting X coordinate
-- @param startY Starting Y coordinate
-- @param endX Ending X coordinate
-- @param endY Ending Y coordinate
-- @param unit Unit doing the pathfinding (for movement costs)
-- @return table Path as list of positions, or nil if no path found
function BattleMap:findPath(startX, startY, endX, endY, unit)
    -- A* pathfinding implementation
    local openSet = {}
    local closedSet = {}
    local cameFrom = {}
    local gScore = {} -- Cost from start to current
    local fScore = {} -- Estimated total cost

    local function getKey(x, y) return string.format("%d,%d", x, y) end

    -- Initialize
    local startKey = getKey(startX, startY)
    openSet[startKey] = true
    gScore[startKey] = 0
    fScore[startKey] = self:getDistance({x = startX, y = startY}, {x = endX, y = endY})

    while next(openSet) do
        -- Find node with lowest fScore
        local currentKey, lowestF = nil, math.huge
        for key in pairs(openSet) do
            if fScore[key] < lowestF then
                currentKey = key
                lowestF = fScore[key]
            end
        end

        if not currentKey then break end

        local currentX, currentY = currentKey:match("(%d+),(%d+)")
        currentX, currentY = tonumber(currentX), tonumber(currentY)

        if currentX == endX and currentY == endY then
            -- Reconstruct path
            return self:reconstructPath(cameFrom, currentKey)
        end

        openSet[currentKey] = nil
        closedSet[currentKey] = true

        -- Check neighbors
        for _, neighbor in ipairs(self:getOrthogonalAdjacentTiles(currentX, currentY)) do
            local neighborKey = getKey(neighbor.x, neighbor.y)

            if closedSet[neighborKey] then goto continue end

            -- Check if tile is walkable
            if not neighbor:isWalkable() then goto continue end

            local tentativeG = gScore[currentKey] + neighbor:getMovementCost()

            if not openSet[neighborKey] then
                openSet[neighborKey] = true
            elseif tentativeG >= (gScore[neighborKey] or math.huge) then
                goto continue
            end

            cameFrom[neighborKey] = currentKey
            gScore[neighborKey] = tentativeG
            fScore[neighborKey] = tentativeG + self:getDistance(
                {x = neighbor.x, y = neighbor.y},
                {x = endX, y = endY}
            )

            ::continue::
        end
    end

    return nil -- No path found
end

--- Reconstruct path from A* cameFrom map
-- @param cameFrom Came from map
-- @param currentKey Current node key
-- @return table Path as list of positions
function BattleMap:reconstructPath(cameFrom, currentKey)
    local path = {}
    local current = currentKey

    while current do
        local x, y = current:match("(%d+),(%d+)")
        table.insert(path, 1, {x = tonumber(x), y = tonumber(y)})
        current = cameFrom[current]
    end

    return path
end

--- Get all walkable tiles
-- @return table List of all walkable tiles
function BattleMap:getWalkableTiles()
    local walkable = {}

    for x = 1, self.width do
        for y = 1, self.height do
            local tile = self.tiles[x][y]
            if tile:isWalkable() then
                table.insert(walkable, tile)
            end
        end
    end

    return walkable
end

--- Get tiles with specific property
-- @param property Property to check
-- @param value Expected value (optional)
-- @return table List of tiles with property
function BattleMap:getTilesWithProperty(property, value)
    local matching = {}

    for x = 1, self.width do
        for y = 1, self.height do
            local tile = self.tiles[x][y]
            local tileValue = tile[property]

            if value == nil then
                if tileValue then
                    table.insert(matching, tile)
                end
            elseif tileValue == value then
                table.insert(matching, tile)
            end
        end
    end

    return matching
end

--- Apply environmental effect to area
-- @param centerX Center X coordinate
-- @param centerY Center Y coordinate
-- @param radius Effect radius
-- @param effectType Type of effect
-- @param intensity Effect intensity
function BattleMap:applyAreaEffect(centerX, centerY, radius, effectType, intensity)
    local affectedTiles = self:getTilesInCircle(centerX, centerY, radius)

    for _, tile in ipairs(affectedTiles) do
        tile:applyEnvironmentalEffect(effectType, intensity)
    end
end

--- Get map data for serialization
-- @return table Map data
function BattleMap:getData()
    local data = {
        width = self.width,
        height = self.height,
        tiles = {}
    }

    for x = 1, self.width do
        data.tiles[x] = {}
        for y = 1, self.height do
            data.tiles[x][y] = self.tiles[x][y]:getData()
        end
    end

    return data
end

--- Load map from data
-- @param data Map data
function BattleMap:loadFromData(data)
    self.width = data.width
    self.height = data.height

    for x = 1, self.width do
        self.tiles[x] = {}
        for y = 1, self.height do
            self.tiles[x][y] = BattleTile(x, y, data.tiles[x][y] or {})
        end
    end
end

--- Get map statistics for debugging
-- @return table Map statistics
function BattleMap:getStatistics()
    local stats = {
        totalTiles = self.width * self.height,
        walkableTiles = 0,
        blockedTiles = 0,
        destroyedTiles = 0,
        onFireTiles = 0,
        smokyTiles = 0,
        coverTiles = {0, 0, 0, 0, 0}, -- Index by cover value
        materialCounts = {}
    }

    for x = 1, self.width do
        for y = 1, self.height do
            local tile = self.tiles[x][y]

            if tile:isWalkable() then
                stats.walkableTiles = stats.walkableTiles + 1
            else
                stats.blockedTiles = stats.blockedTiles + 1
            end

            if tile:isDestroyed() then
                stats.destroyedTiles = stats.destroyedTiles + 1
            end

            if tile:isOnFire() then
                stats.onFireTiles = stats.onFireTiles + 1
            end

            if tile:isSmoky() then
                stats.smokyTiles = stats.smokyTiles + 1
            end

            local cover = tile:getCover()
            if cover >= 0 and cover <= 4 then
                stats.coverTiles[cover + 1] = stats.coverTiles[cover + 1] + 1
            end

            local material = tile:getMaterial()
            stats.materialCounts[material] = (stats.materialCounts[material] or 0) + 1
        end
    end

    return stats
end

return BattleMap
