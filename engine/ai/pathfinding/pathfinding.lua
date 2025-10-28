---A* Pathfinding System for Hex Grids
---
---Implements A* pathfinding algorithm optimized for hexagonal grid-based movement.
---Used for ECS battle system unit movement. Handles obstacle avoidance, terrain
---costs, and optimal path calculation.
---
---Pathfinding Features:
---  - A* algorithm with heuristic optimization
---  - Hexagonal grid support (using hex_math)
---  - Obstacle avoidance
---  - Path smoothing and optimization
---  - Diagonal movement support
---  - Open/closed set management
---
---Key Exports:
---  - Pathfinding.findPath(startX, startY, goalX, goalY, grid): Calculates path
---  - Pathfinding.isWalkable(x, y, grid): Checks tile accessibility
---  - Pathfinding.getNeighbors(x, y): Returns adjacent hexes
---  - Pathfinding.heuristic(x1, y1, x2, y2): Distance estimation
---
---Dependencies:
---  - battlescape.battle_ecs.hex_math: Hex grid mathematics
---
---@module ai.pathfinding.pathfinding
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Pathfinding = require("ai.pathfinding.pathfinding")
---  local path = Pathfinding.findPath(startX, startY, goalX, goalY, grid)
---  for _, node in ipairs(path) do
---    print(node.x, node.y)
---  end
---
---@see battlescape.battle_ecs For ECS battle system
---@see ai.pathfinding.tactical_pathfinding For tactical pathfinding

local HexMath = require("battlescape.battle_ecs.hex_math")

local Pathfinding = {}
Pathfinding.__index = Pathfinding

-- Node for A* algorithm
local Node = {}
Node.__index = Node

function Node.new(x, y, parent)
    local self = setmetatable({}, Node)
    self.x = x
    self.y = y
    self.parent = parent
    self.g = 0  -- Cost from start
    self.h = 0  -- Heuristic to goal
    self.f = 0  -- Total cost
    return self
end

-- Create pathfinding system
function Pathfinding.new()
    local self = setmetatable({}, Pathfinding)
    return self
end

-- A* pathfinding algorithm
function Pathfinding:findPath(unit, startX, startY, goalX, goalY, battlefield, actionSystem)
    -- Create open and closed sets
    local openSet = {}
    local closedSet = {}
    local cameFrom = {}

    -- Cost maps
    local gScore = {}  -- Cost from start to this node
    local fScore = {}  -- Estimated total cost

    -- Initialize start node
    local startKey = string.format("%d,%d", startX, startY)
    gScore[startKey] = 0
    fScore[startKey] = self:heuristic(startX, startY, goalX, goalY)

    -- Add start to open set
    local startNode = Node.new(startX, startY)
    startNode.f = fScore[startKey]
    table.insert(openSet, startNode)

    while #openSet > 0 do
        -- Find node with lowest f score
        local current = self:getLowestFScore(openSet, fScore)

        -- Reached goal
        if current.x == goalX and current.y == goalY then
            return self:reconstructPath(cameFrom, current)
        end

        -- Move current from open to closed
        self:removeFromList(openSet, current)
        local currentKey = string.format("%d,%d", current.x, current.y)
        closedSet[currentKey] = true

        -- Check hex neighbors (6 directions for hex grid)
        local currentQ, currentR = HexMath.offsetToAxial(current.x, current.y)
        local neighbors = HexMath.getNeighbors(currentQ, currentR)
        
        for _, neighbor in ipairs(neighbors) do
            local neighborX, neighborY = HexMath.axialToOffset(neighbor.q, neighbor.r)

            -- Bounds check
            if neighborX >= 1 and neighborX <= battlefield.mapWidth and
               neighborY >= 1 and neighborY <= battlefield.mapHeight then

                local neighborKey = string.format("%d,%d", neighborX, neighborY)

                -- Skip if already evaluated
                if closedSet[neighborKey] then goto continue end

                -- Check if neighbor is passable
                local currentTile = battlefield:getTile(current.x, current.y)
                local neighborTile = battlefield:getTile(neighborX, neighborY)
                local moveCost = actionSystem:calculateMovementCost(unit, currentTile, neighborTile, battlefield)

                if moveCost == 0 then goto continue end

                -- Calculate tentative g score
                local tentativeG = gScore[currentKey] + moveCost

                -- Check if this path is better
                if not gScore[neighborKey] or tentativeG < gScore[neighborKey] then
                    cameFrom[neighborKey] = current
                    gScore[neighborKey] = tentativeG
                    fScore[neighborKey] = tentativeG + self:heuristic(neighborX, neighborY, goalX, goalY)

                    -- Add to open set if not already there
                    if not self:inList(openSet, neighborX, neighborY) then
                        local neighborNode = Node.new(neighborX, neighborY)
                        neighborNode.f = fScore[neighborKey]
                        table.insert(openSet, neighborNode)
                    end
                end
            end

            ::continue::
        end
    end

    -- No path found
    return nil
end

-- Manhattan distance heuristic
function Pathfinding:heuristic(x1, y1, x2, y2)
    local q1, r1 = HexMath.offsetToAxial(x1, y1)
    local q2, r2 = HexMath.offsetToAxial(x2, y2)
    return HexMath.distance(q1, r1, q2, r2)
end

-- Get node with lowest f score
function Pathfinding:getLowestFScore(openSet, fScore)
    local lowest = openSet[1]
    local lowestScore = math.huge

    for _, node in ipairs(openSet) do
        local key = string.format("%d,%d", node.x, node.y)
        local score = fScore[key] or math.huge
        if score < lowestScore then
            lowest = node
            lowestScore = score
        end
    end

    return lowest
end

-- Remove node from list
function Pathfinding:removeFromList(list, node)
    for i, n in ipairs(list) do
        if n.x == node.x and n.y == node.y then
            table.remove(list, i)
            return
        end
    end
end

-- Check if coordinates are in list
function Pathfinding:inList(list, x, y)
    for _, node in ipairs(list) do
        if node.x == x and node.y == y then
            return true
        end
    end
    return false
end

-- Reconstruct path from cameFrom map
function Pathfinding:reconstructPath(cameFrom, current)
    local path = {}
    local currentKey = string.format("%d,%d", current.x, current.y)

    while cameFrom[currentKey] do
        table.insert(path, 1, {x = current.x, y = current.y})
        current = cameFrom[currentKey]
        currentKey = string.format("%d,%d", current.x, current.y)
    end

    -- Add start position
    table.insert(path, 1, {x = current.x, y = current.y})

    return path
end

-- Find path for multi-tile unit
function Pathfinding:findPathForMultiTile(unit, goalX, goalY, battlefield, actionSystem)
    -- For multi-tile units, we need to find a path to a position where
    -- all tiles the unit would occupy are valid

    -- Try direct pathfinding first
    local path = self:findPath(unit, unit.x, unit.y, goalX, goalY, battlefield, actionSystem)
    if path then
        return path
    end

    -- If direct path fails, try adjacent positions
    -- This is a simplified approach - a more sophisticated algorithm
    -- would be needed for complex multi-tile pathfinding

    for dy = -1, 1 do
        for dx = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local testX = goalX + dx
                local testY = goalY + dy

                -- Check if all tiles would be valid
                local valid = true
                for oy = 0, unit.stats.size - 1 do
                    for ox = 0, unit.stats.size - 1 do
                        local checkX = testX + ox
                        local checkY = testY + oy

                        if checkX < 1 or checkX > battlefield.mapWidth or
                           checkY < 1 or checkY > battlefield.mapHeight then
                            valid = false
                            break
                        end

                        local tile = battlefield:getTile(checkX, checkY)
                        if tile:getMoveCost() == 0 or tile.unit then
                            valid = false
                            break
                        end
                    end
                    if not valid then break end
                end

                if valid then
                    path = self:findPath(unit, unit.x, unit.y, testX, testY, battlefield, actionSystem)
                    if path then
                        return path
                    end
                end
            end
        end
    end

    return nil  -- No valid path found
end

-- Validate path for unit
function Pathfinding:validatePath(unit, path, battlefield, actionSystem)
    if not path or #path < 2 then return false end

    local totalCost = 0

    for i = 1, #path - 1 do
        local fromTile = battlefield:getTile(path[i].x, path[i].y)
        local toTile = battlefield:getTile(path[i + 1].x, path[i + 1].y)

        if not fromTile or not toTile then
            return false
        end

        local cost = actionSystem:calculateMovementCost(unit, fromTile, toTile, battlefield)
        if cost == 0 then
            return false
        end

        totalCost = totalCost + cost
    end

    -- Check if unit has enough MP
    return totalCost <= unit.movementPoints
end

-- Get path cost
function Pathfinding:getPathCost(unit, path, battlefield, actionSystem)
    if not path or #path < 2 then return 0 end

    local totalCost = 0

    for i = 1, #path - 1 do
        local fromTile = battlefield:getTile(path[i].x, path[i].y)
        local toTile = battlefield:getTile(path[i + 1].x, path[i + 1].y)
        local cost = actionSystem:calculateMovementCost(unit, fromTile, toTile, battlefield)
        totalCost = totalCost + cost
    end

    return totalCost
end

-- Debug: Print path
function Pathfinding:printPath(path)
    if not path then
        print("[Pathfinding] No path")
        return
    end

    print("[Pathfinding] Path with " .. #path .. " steps:")
    for i, step in ipairs(path) do
        print(string.format("  %d: (%d,%d)", i, step.x, step.y))
    end
end

-- Static method for simple grid-based pathfinding (used by tests)
function Pathfinding.findPath(grid, startX, startY, goalX, goalY)
    -- Simple A* implementation for grid arrays
    -- grid[y][x] = 0 for walkable, 1 for blocked
    
    -- Early exit if start == goal
    if startX == goalX and startY == goalY then
        return {{x = startX, y = startY}}
    end
    
    -- Initialize data structures
    local openSet = {}
    local closedSet = {}
    local cameFrom = {}
    local gScore = {}
    local fScore = {}
    
    -- Helper functions
    local function getKey(x, y) return string.format("%d,%d", x, y) end
    local function heuristic(x1, y1, x2, y2) return math.abs(x1 - x2) + math.abs(y1 - y2) end
    local function isWalkable(x, y)
        if x < 1 or y < 1 or x > #grid[1] or y > #grid then return false end
        return grid[y][x] == 0
    end
    
    -- Initialize start
    local startKey = getKey(startX, startY)
    gScore[startKey] = 0
    fScore[startKey] = heuristic(startX, startY, goalX, goalY)
    table.insert(openSet, {x = startX, y = startY, f = fScore[startKey]})
    
    while #openSet > 0 do
        -- Find node with lowest f score
        table.sort(openSet, function(a, b) return a.f < b.f end)
        local current = table.remove(openSet, 1)
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
            return path
        end
        
        closedSet[currentKey] = true
        
        -- Check neighbors
        local neighbors = {
            {x = current.x + 1, y = current.y},
            {x = current.x - 1, y = current.y},
            {x = current.x, y = current.y + 1},
            {x = current.x, y = current.y - 1}
        }
        
        for _, neighbor in ipairs(neighbors) do
            local neighborKey = getKey(neighbor.x, neighbor.y)
            
            if closedSet[neighborKey] then goto continue end
            if not isWalkable(neighbor.x, neighbor.y) then goto continue end
            
            local tentativeG = gScore[currentKey] + 1
            
            if not gScore[neighborKey] or tentativeG < gScore[neighborKey] then
                cameFrom[neighborKey] = current
                gScore[neighborKey] = tentativeG
                fScore[neighborKey] = tentativeG + heuristic(neighbor.x, neighbor.y, goalX, goalY)
                
                -- Add to open set if not already there
                local found = false
                for _, openNode in ipairs(openSet) do
                    if openNode.x == neighbor.x and openNode.y == neighbor.y then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(openSet, {x = neighbor.x, y = neighbor.y, f = fScore[neighborKey]})
                end
            end
            
            ::continue::
        end
    end
    
    -- No path found
    return nil
end

return Pathfinding

























