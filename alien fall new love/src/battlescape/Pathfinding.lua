--- Pathfinding.lua
-- Implements A* pathfinding algorithm for tile-based movement
-- Supports movement costs, terrain modifiers, and deterministic tie-breaking
-- Used for unit movement planning and AI navigation

local Class = require("util.Class")
local PerformanceCache = require("utils.performance_cache")

---@class Pathfinding
---@field private _map table Reference to battle map
---@field private _movementCosts table Cached movement costs for tiles
---@field private _cache PerformanceCache Performance cache instance
---@field private _currentTurn number Current game turn (for cache invalidation)
local Pathfinding = Class()

---Initialize Pathfinding system
---@param map table Battle map reference
---@param cache PerformanceCache Optional performance cache (will create if not provided)
function Pathfinding:init(map, cache)
    self._map = map
    self._movementCosts = {}
    self._cache = cache or PerformanceCache()
    self._currentTurn = 0
end

---Calculate movement cost for a tile
---@param tile table Tile data
---@param unit table Unit attempting movement
---@return number cost Movement cost (higher = more expensive)
function Pathfinding:getMovementCost(tile, unit)
    local baseCosts = {
        open = 1,
        road = 0.5,
        rough = 2,
        difficult = 3,
        impassable = 999
    }

    local cost = baseCosts[tile.terrainType] or 1

    -- Apply unit modifiers
    if unit.movementType == "flying" then
        cost = cost * 0.5 -- Flying units ignore terrain
    elseif unit.movementType == "large" and tile.isNarrow then
        cost = 999 -- Large units can't use narrow passages
    end

    -- Apply environmental effects
    if tile.hasSmoke then
        cost = cost * 1.5
    end
    if tile.hasFire then
        cost = cost * 2.0
    end

    return cost
end

---Calculate heuristic distance (Manhattan distance)
---@param fromX number Start X
---@param fromY number Start Y
---@param toX number Goal X
---@param toY number Goal Y
---@return number heuristic
function Pathfinding:heuristic(fromX, fromY, toX, toY)
    return math.abs(toX - fromX) + math.abs(toY - fromY)
end

---Get valid neighbors for a tile
---@param x number Tile X
---@param y number Tile Y
---@param unit table Unit attempting movement
---@return table neighbors List of {x, y, cost}
function Pathfinding:getNeighbors(x, y, unit)
    local neighbors = {}
    local directions = {
        {0, 1, 1.0},   -- North
        {1, 0, 1.0},   -- East
        {0, -1, 1.0},  -- South
        {-1, 0, 1.0},  -- West
        {1, 1, 1.414}, -- Northeast (diagonal)
        {1, -1, 1.414}, -- Southeast
        {-1, 1, 1.414}, -- Northwest
        {-1, -1, 1.414} -- Southwest
    }

    for _, dir in ipairs(directions) do
        local nx, ny = x + dir[1], y + dir[2]
        local moveCost = dir[3]

        if self._map:isValidTile(nx, ny) then
            local tile = self._map:getTile(nx, ny)
            if tile and not tile.blocked then
                local terrainCost = self:getMovementCost(tile, unit)
                table.insert(neighbors, {
                    x = nx,
                    y = ny,
                    cost = moveCost * terrainCost
                })
            end
        end
    end

    return neighbors
end

---Find path using A* algorithm
---@param startX number Start tile X
---@param startY number Start tile Y
---@param goalX number Goal tile X
---@param goalY number Goal tile Y
---@param unit table Unit attempting movement
---@param maxDistance number Maximum path length (optional)
---@return table|nil path List of {x, y} coordinates, or nil if no path found
function Pathfinding:findPath(startX, startY, goalX, goalY, unit, maxDistance)
    -- Check cache first
    local unitId = unit.id or 0
    local cachedPath = self._cache:getPath(startX, startY, goalX, goalY, unitId, self._currentTurn)
    if cachedPath then
        return cachedPath
    end
    
    -- Open and closed sets
    local openSet = {}
    local closedSet = {}

    -- Cost tracking
    local gScore = {} -- Cost from start to current
    local fScore = {} -- Estimated total cost (g + heuristic)

    -- Parent tracking for path reconstruction
    local cameFrom = {}

    -- Helper functions
    local function getKey(x, y) return x .. "," .. y end
    local function getLowestFScore()
        local lowest = nil
        local lowestF = math.huge
        for _, node in ipairs(openSet) do
            local key = getKey(node.x, node.y)
            if fScore[key] < lowestF then
                lowestF = fScore[key]
                lowest = node
            end
        end
        return lowest
    end

    -- Initialize start node
    local startKey = getKey(startX, startY)
    openSet[startKey] = {x = startX, y = startY}
    gScore[startKey] = 0
    fScore[startKey] = self:heuristic(startX, startY, goalX, goalY)

    while next(openSet) do
        -- Get node with lowest f-score
        local current = getLowestFScore()
        if not current then break end

        local currentKey = getKey(current.x, current.y)

        -- Check if we reached the goal
        if current.x == goalX and current.y == goalY then
            -- Reconstruct path
            local path = {}
            local node = current
            while node do
                table.insert(path, 1, {x = node.x, y = node.y})
                local nodeKey = getKey(node.x, node.y)
                node = cameFrom[nodeKey]
            end
            
            -- Cache the result
            self._cache:cachePath(startX, startY, goalX, goalY, unitId, path, self._currentTurn)
            
            return path
        end

        -- Move current to closed set
        openSet[currentKey] = nil
        closedSet[currentKey] = true

        -- Check distance limit
        if maxDistance and gScore[currentKey] > maxDistance then
            goto continue
        end

        -- Explore neighbors
        local neighbors = self:getNeighbors(current.x, current.y, unit)
        for _, neighbor in ipairs(neighbors) do
            local neighborKey = getKey(neighbor.x, neighbor.y)

            if closedSet[neighborKey] then
                goto continueNeighbor
            end

            local tentativeGScore = gScore[currentKey] + neighbor.cost

            if not openSet[neighborKey] then
                openSet[neighborKey] = neighbor
            elseif tentativeGScore >= (gScore[neighborKey] or math.huge) then
                goto continueNeighbor
            end

            -- This path is better
            cameFrom[neighborKey] = current
            gScore[neighborKey] = tentativeGScore
            fScore[neighborKey] = tentativeGScore + self:heuristic(neighbor.x, neighbor.y, goalX, goalY)

            ::continueNeighbor::
        end

        ::continue::
    end

    -- No path found
    return nil
end

---Calculate path distance
---@param path table List of {x, y} coordinates
---@return number distance Total path distance
function Pathfinding:getPathDistance(path)
    if not path or #path < 2 then return 0 end

    local distance = 0
    for i = 2, #path do
        local dx = path[i].x - path[i-1].x
        local dy = path[i].y - path[i-1].y
        distance = distance + math.sqrt(dx*dx + dy*dy)
    end

    return distance
end

---Check if a path exists between two points
---@param startX number Start X
---@param startY number Start Y
---@param goalX number Goal X
---@param goalY number Goal Y
---@param unit table Unit attempting movement
---@return boolean hasPath
function Pathfinding:hasPath(startX, startY, goalX, goalY, unit)
    local path = self:findPath(startX, startY, goalX, goalY, unit, 50) -- Reasonable limit
    return path ~= nil
end

---Get movement range for a unit from a position
---@param startX number Start X
---@param startY number Start Y
---@param unit table Unit data
---@param maxAP number Maximum action points available
---@return table reachableTiles Map of reachable {x, y} -> cost
function Pathfinding:getMovementRange(startX, startY, unit, maxAP)
    local reachable = {}
    local visited = {}
    local queue = {{x = startX, y = startY, cost = 0}}

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local key = current.x .. "," .. current.y

        if visited[key] then goto continue end
        visited[key] = true

        reachable[key] = current.cost

        if current.cost < maxAP then
            local neighbors = self:getNeighbors(current.x, current.y, unit)
            for _, neighbor in ipairs(neighbors) do
                local neighborKey = neighbor.x .. "," .. neighbor.y
                if not visited[neighborKey] then
                    local newCost = current.cost + neighbor.cost
                    if newCost <= maxAP then
                        table.insert(queue, {
                            x = neighbor.x,
                            y = neighbor.y,
                            cost = newCost
                        })
                    end
                end
            end
        end

        ::continue::
    end

    return reachable
end

---Optimize path by removing unnecessary waypoints
---@param path table Original path
---@return table optimizedPath Simplified path
function Pathfinding:optimizePath(path)
    if not path or #path < 3 then return path end

    local optimized = {path[1]} -- Always include start

    for i = 2, #path - 1 do
        local prev = optimized[#optimized]
        local current = path[i]
        local next = path[i + 1]

        -- Check if we can skip current waypoint
        if not self:canSkipWaypoint(prev, current, next) then
            table.insert(optimized, current)
        end
    end

    table.insert(optimized, path[#path]) -- Always include goal

    return optimized
end

---Check if a waypoint can be skipped (straight line possible)
---@param prev table Previous waypoint
---@param current table Current waypoint
---@param next table Next waypoint
---@return boolean canSkip
function Pathfinding:canSkipWaypoint(prev, current, next)
    -- Simple check: if the line from prev to next doesn't pass through blocked tiles
    -- This is a simplified version - real implementation would do proper line checks
    local dx1 = current.x - prev.x
    local dy1 = current.y - prev.y
    local dx2 = next.x - current.x
    local dy2 = next.y - current.y

    -- If direction changes significantly, can't skip
    local dot = dx1 * dx2 + dy1 * dy2
    if dot < 0 then return false end -- Sharp turn

    return true -- For now, allow skipping if no sharp turn
end

---Update current turn (for cache invalidation)
---@param turn number Current game turn
function Pathfinding:setCurrentTurn(turn)
    self._currentTurn = turn
end

---Invalidate pathfinding cache (call when map changes)
function Pathfinding:invalidateCache()
    self._cache:invalidatePathCache()
end

---Get cache statistics
---@return table stats Cache performance statistics
function Pathfinding:getCacheStatistics()
    return self._cache:getStatistics()
end

return Pathfinding
