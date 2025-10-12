-- Battlefield Module
-- Manages the tactical battle map, tiles, and spatial operations

local BattleTile = require("systems.battle_tile")
local DataLoader = require("systems.data_loader")

local Battlefield = {}
Battlefield.__index = Battlefield

-- Create a new battlefield
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

-- Generate battlefield map
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

-- OPTIMIZED: Add wooden room with walls (no bounds checks inside loops)
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

-- OPTIMIZED: Add stone wall cluster (pre-calculate random values)
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

-- OPTIMIZED: Add tree grove (pre-calculate random values)
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

-- OPTIMIZED: Add path (reduced tile checks, batch terrain updates)
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

-- Original methods kept for compatibility
function Battlefield:addWoodenRoom(startX, startY, width, height)
    return self:addWoodenRoomFast(startX, startY, width, height)
end

function Battlefield:addStoneWallCluster(startX, startY, width, height)
    return self:addStoneWallClusterFast(startX, startY, width, height)
end

function Battlefield:addTreeGrove(startX, startY, width, height)
    return self:addTreeGroveFast(startX, startY, width, height)
end

function Battlefield:addPath(x1, y1, x2, y2)
    return self:addPathFast(x1, y1, x2, y2)
end

-- Get tile at position
function Battlefield:getTile(x, y)
    if x >= 1 and x <= self.width and y >= 1 and y <= self.height then
        return self.map[y][x]
    end
    return nil
end

-- Check if position is valid
function Battlefield:isValidPosition(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

-- Check if position is walkable
function Battlefield:isWalkable(x, y)
    local tile = self:getTile(x, y)
    if not tile then return false end
    
    -- tile.terrain is already the terrain object from TerrainTypes
    return tile.terrain and not tile.terrain.blocksMovement
end

-- Check if position is occupied by a unit
function Battlefield:isOccupied(x, y, units)
    for _, unit in pairs(units) do
        if unit.alive and unit:occupiesTile(x, y) then
            return true
        end
    end
    return false
end

-- Get unit at position
function Battlefield:getUnitAt(x, y, units)
    for _, unit in pairs(units) do
        if unit.alive and unit:occupiesTile(x, y) then
            return unit
        end
    end
    return nil
end

-- Place unit on map
function Battlefield:placeUnit(unit)
    for _, tile in ipairs(unit:getOccupiedTiles()) do
        local mapTile = self:getTile(tile.x, tile.y)
        if mapTile then
            mapTile.unit = unit
        end
    end
end

-- Move unit to new position
function Battlefield:moveUnit(unit, newX, newY)
    -- Remove from old position
    self:removeUnit(unit)
    
    -- Update unit position
    unit.x = newX
    unit.y = newY
    
    -- Place at new position
    self:placeUnit(unit)
end

-- Remove unit from map
function Battlefield:removeUnit(unit)
    for _, tile in ipairs(unit:getOccupiedTiles()) do
        local mapTile = self:getTile(tile.x, tile.y)
        if mapTile and mapTile.unit == unit then
            mapTile.unit = nil
        end
    end
end

-- Get all tiles
function Battlefield:getAllTiles()
    local tiles = {}
    for y = 1, self.height do
        for x = 1, self.width do
            table.insert(tiles, self.map[y][x])
        end
    end
    return tiles
end

-- Get neighbors (8-directional)
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

-- Get distance between two points (hex distance)
function Battlefield:getManhattanDistance(x1, y1, x2, y2)
    local HexMath = require("utils.hex_math")
    local q1, r1 = HexMath.offsetToAxial(x1, y1)
    local q2, r2 = HexMath.offsetToAxial(x2, y2)
    return HexMath.distance(q1, r1, q2, r2)
end

-- Get distance between two points (Euclidean - kept for compatibility)
function Battlefield:getEuclideanDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx*dx + dy*dy)
end

return Battlefield
