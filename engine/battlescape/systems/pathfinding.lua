---Pathfinding System for Hex Grid Combat
---
---Implements A* pathfinding for hexagonal grids with terrain cost support.
---Handles movement planning, route calculation, and cost estimation.
---
---Features:
---  - A* pathfinding on hex grids
---  - Terrain movement costs (1x, 2x, 4x, infinite)
---  - TU/AP consumption calculation
---  - Multi-turn movement planning
---  - Path visualization
---  - Cache for repeated queries
---
---Movement Costs:
---  - Normal terrain: 1x normal movement
---  - Rough terrain: 2x normal movement
---  - Very rough: 4x normal movement
---  - Blocking: Impossible (impassable)
---
---Key Exports:
---  - Pathfinding.new(hex_grid, terrain_system)
---  - findPath(start, goal, max_distance)
---  - getMovementCost(from, to, unit_stats)
---  - canReach(start, goal, max_distance)
---  - getReachableHexes(start, max_distance)
---  - clearCache()
---
---Dependencies:
---  - battlescape.battle_ecs.hex_math: Hex coordinate math
---  - battlescape.systems.terrain: Terrain cost data
---
---@module battlescape.systems.pathfinding
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local Pathfinding = {}
Pathfinding.__index = Pathfinding

local HexMath = require("battlescape.battle_ecs.hex_math")

--- Create new pathfinding system
---@param hexGrid table Hex grid system reference
---@param terrainSystem table Terrain cost system reference
---@return table New Pathfinding instance
function Pathfinding.new(hexGrid, terrainSystem)
    local self = setmetatable({}, Pathfinding)
    
    self.hexGrid = hexGrid
    self.terrainSystem = terrainSystem
    
    -- Cache for path queries
    self.pathCache = {}
    self.cacheMaxSize = 100
    
    -- Terrain movement cost multipliers
    self.terrainCosts = {
        normal = 1,
        rough = 2,
        very_rough = 4,
        blocking = math.huge  -- Impassable
    }
    
    print("[Pathfinding] Initialized pathfinding system")
    
    return self
end

--- Find path using A* algorithm
---@param startPos table Start hex {q, r}
---@param goalPos table Goal hex {q, r}
---@param maxDistance number Maximum distance allowed (in movement points)
---@param unitStats table Unit stats including AP/TU (optional)
---@return table|nil Array of hex positions, or nil if no path found
function Pathfinding:findPath(startPos, goalPos, maxDistance, unitStats)
    -- Check cache first
    local cacheKey = string.format("%d,%d-%d,%d-%d",
        startPos.q, startPos.r, goalPos.q, goalPos.r, maxDistance)
    
    if self.pathCache[cacheKey] then
        print(string.format("[Pathfinding] Cache hit for path %s", cacheKey))
        return self.pathCache[cacheKey]
    end
    
    -- A* algorithm
    local openSet = {self:_makeNode(startPos, nil, 0, self:_heuristic(startPos, goalPos))}
    local closedSet = {}
    local nodeMap = {}
    nodeMap[self:_posKey(startPos)] = openSet[1]
    
    while #openSet > 0 do
        -- Find node with lowest f score
        local currentIdx = 1
        for i = 2, #openSet do
            if openSet[i].f < openSet[currentIdx].f then
                currentIdx = i
            end
        end
        
        local current = openSet[currentIdx]
        
        -- Goal reached
        if current.pos.q == goalPos.q and current.pos.r == goalPos.r then
            local path = self:_reconstructPath(current)
            self:_cacheResult(cacheKey, path)
            return path
        end
        
        table.remove(openSet, currentIdx)
        table.insert(closedSet, current)
        
        -- Check neighbors
        local neighbors = HexMath.getNeighbors(current.pos)
        for _, neighborPos in ipairs(neighbors) do
            local neighborKey = self:_posKey(neighborPos)
            
            -- Skip if in closed set
            local inClosed = false
            for _, n in ipairs(closedSet) do
                if n.pos.q == neighborPos.q and n.pos.r == neighborPos.r then
                    inClosed = true
                    break
                end
            end
            if inClosed then
                goto continue
            end
            
            -- Calculate movement cost
            local moveCost = self:getMovementCost(current.pos, neighborPos)
            if moveCost == math.huge then
                goto continue  -- Blocked
            end
            
            local tentativeG = current.g + moveCost
            
            -- Exceeds max distance
            if tentativeG > maxDistance then
                goto continue
            end
            
            -- Find in open set
            local neighborNode = nodeMap[neighborKey]
            if not neighborNode then
                neighborNode = self:_makeNode(
                    neighborPos,
                    current,
                    tentativeG,
                    self:_heuristic(neighborPos, goalPos)
                )
                nodeMap[neighborKey] = neighborNode
                table.insert(openSet, neighborNode)
            elseif tentativeG < neighborNode.g then
                -- Found better path
                neighborNode.g = tentativeG
                neighborNode.f = neighborNode.g + neighborNode.h
                neighborNode.parent = current
            end
            
            ::continue::
        end
    end
    
    -- No path found
    print(string.format("[Pathfinding] No path found from (%d,%d) to (%d,%d)",
        startPos.q, startPos.r, goalPos.q, goalPos.r))
    
    self:_cacheResult(cacheKey, nil)
    return nil
end

--- Get movement cost between adjacent hexes
---@param fromPos table From hex {q, r}
---@param toPos table To hex {q, r}
---@return number Movement cost (1-4, or infinity if blocked)
function Pathfinding:getMovementCost(fromPos, toPos)
    if not self.terrainSystem then
        return 1  -- Default cost if no terrain system
    end
    
    -- Check destination terrain
    local terrain = self.terrainSystem:getTerrain(toPos)
    if not terrain or terrain.blocked then
        return math.huge  -- Blocked
    end
    
    -- Get cost multiplier
    local costType = terrain.movementCost or "normal"
    local multiplier = self.terrainCosts[costType] or 1
    
    return multiplier
end

--- Check if position is reachable within distance
---@param startPos table Start hex {q, r}
---@param goalPos table Goal hex {q, r}
---@param maxDistance number Maximum movement distance
---@return boolean True if reachable
function Pathfinding:canReach(startPos, goalPos, maxDistance)
    local path = self:findPath(startPos, goalPos, maxDistance)
    return path ~= nil
end

--- Get all hexes reachable from start position
---@param startPos table Start hex {q, r}
---@param maxDistance number Maximum movement distance
---@return table Array of {pos, distance} for all reachable hexes
function Pathfinding:getReachableHexes(startPos, maxDistance)
    local reachable = {}
    local visited = {}
    local queue = {{pos = startPos, distance = 0}}
    local queueIndex = 1
    
    while queueIndex <= #queue do
        local current = queue[queueIndex]
        queueIndex = queueIndex + 1
        
        local key = self:_posKey(current.pos)
        if visited[key] then
            goto continue
        end
        visited[key] = true
        
        table.insert(reachable, {pos = current.pos, distance = current.distance})
        
        -- Add neighbors
        local neighbors = HexMath.getNeighbors(current.pos)
        for _, neighborPos in ipairs(neighbors) do
            local neighborKey = self:_posKey(neighborPos)
            if not visited[neighborKey] then
                local cost = self:getMovementCost(current.pos, neighborPos)
                if cost ~= math.huge then
                    local newDistance = current.distance + cost
                    if newDistance <= maxDistance then
                        table.insert(queue, {pos = neighborPos, distance = newDistance})
                    end
                end
            end
        end
        
        ::continue::
    end
    
    return reachable
end

--- Clear pathfinding cache
function Pathfinding:clearCache()
    self.pathCache = {}
    print("[Pathfinding] Cache cleared")
end

--- PRIVATE: Make A* node
function Pathfinding:_makeNode(pos, parent, g, h)
    return {
        pos = pos,
        parent = parent,
        g = g,  -- Actual distance from start
        h = h,  -- Heuristic distance to goal
        f = g + h  -- Total estimated distance
    }
end

--- PRIVATE: Heuristic (hex distance)
function Pathfinding:_heuristic(posA, posB)
    return HexMath.distance(posA, posB)
end

--- PRIVATE: Convert position to cache key
function Pathfinding:_posKey(pos)
    return string.format("%d,%d", pos.q, pos.r)
end

--- PRIVATE: Reconstruct path from goal node
function Pathfinding:_reconstructPath(node)
    local path = {}
    local current = node
    
    while current do
        table.insert(path, 1, {q = current.pos.q, r = current.pos.r})
        current = current.parent
    end
    
    return path
end

--- PRIVATE: Cache path result
function Pathfinding:_cacheResult(key, path)
    self.pathCache[key] = path
    
    -- Simple cache size management
    if next(self.pathCache, next(self.pathCache)) ~= nil then
        local count = 0
        for _ in pairs(self.pathCache) do count = count + 1 end
        
        if count > self.cacheMaxSize then
            self:clearCache()
        end
    end
end

return Pathfinding




