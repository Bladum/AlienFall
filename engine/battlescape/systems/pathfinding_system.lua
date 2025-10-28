---Pathfinding - A* Pathfinding for Unit Movement (Vertical Axial Hex)
---
---A* pathfinding algorithm for tactical unit movement on hex-based battlescape maps.
---Uses UNIVERSAL VERTICAL AXIAL coordinate system for all hex operations.
---
---COORDINATE SYSTEM: Vertical Axial (Flat-Top Hexagons)
---  - All hex calculations use axial coordinates {q, r}
---  - Distance: HexMath.distance(q1, r1, q2, r2)
---  - Neighbors: HexMath.getNeighbors(q, r) - returns 6 adjacent hexes
---  - Directions: E, SE, SW, W, NW, NE (HexMath.DIRECTIONS)
---
---DESIGN REFERENCE: design/mechanics/hex_vertical_axial_system.md
---
---@module battlescape.systems.pathfinding_system
---@see engine.battlescape.battle_ecs.hex_math For hex mathematics

local HexMath = require("engine.battlescape.battle_ecs.hex_math")

local Pathfinding = {}
Pathfinding.__index = Pathfinding

-- Node for A* algorithm (uses axial coordinates)
local Node = {}
Node.__index = Node

function Node.new(q, r, parent)
    local self = setmetatable({}, Node)
    self.q = q  -- Axial Q coordinate
    self.r = r  -- Axial R coordinate
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

-- A* pathfinding algorithm (axial coordinates)
function Pathfinding:findPath(unit, startQ, startR, goalQ, goalR, battlefield, actionSystem)
    local openSet = {}
    local closedSet = {}
    local cameFrom = {}
    local gScore = {}
    local fScore = {}

    -- Initialize start node
    local startKey = string.format("%d,%d", startQ, startR)
    gScore[startKey] = 0
    fScore[startKey] = self:heuristic(startQ, startR, goalQ, goalR)

    local startNode = Node.new(startQ, startR)
    startNode.f = fScore[startKey]
    table.insert(openSet, startNode)

    while #openSet > 0 do
        -- Find node with lowest f score
        local current = self:getLowestFScore(openSet, fScore)

        -- Reached goal
        if current.q == goalQ and current.r == goalR then
            return self:reconstructPath(cameFrom, current)
        end

        -- Move current from open to closed
        self:removeFromList(openSet, current)
        local currentKey = string.format("%d,%d", current.q, current.r)
        closedSet[currentKey] = true

        -- Check hex neighbors using HexMath
        local neighbors = HexMath.getNeighbors(current.q, current.r)

        for _, neighbor in ipairs(neighbors) do
            local nq, nr = neighbor.q, neighbor.r

            -- Bounds check (if battlefield has bounds)
            if battlefield.isInBounds and not battlefield:isInBounds(nq, nr) then
                goto continue
            end

            local neighborKey = string.format("%d,%d", nq, nr)

            -- Skip if already evaluated
            if closedSet[neighborKey] then
                goto continue
            end

            -- Check if neighbor is passable
            local moveCost = 1  -- Default cost
            if actionSystem and actionSystem.calculateMovementCost then
                local currentTile = battlefield:getTile(current.q, current.r)
                local neighborTile = battlefield:getTile(nq, nr)
                moveCost = actionSystem:calculateMovementCost(unit, currentTile, neighborTile, battlefield)
            elseif battlefield.getMovementCost then
                moveCost = battlefield:getMovementCost(nq, nr, unit)
            end

            if moveCost == 0 or moveCost == math.huge then
                goto continue
            end

            -- Calculate tentative g score
            local tentativeG = gScore[currentKey] + moveCost

            -- Check if this path is better
            if not gScore[neighborKey] or tentativeG < gScore[neighborKey] then
                cameFrom[neighborKey] = current
                gScore[neighborKey] = tentativeG
                fScore[neighborKey] = tentativeG + self:heuristic(nq, nr, goalQ, goalR)

                -- Add to open set if not already there
                if not self:inList(openSet, nq, nr) then
                    local neighborNode = Node.new(nq, nr)
                    neighborNode.f = fScore[neighborKey]
                    table.insert(openSet, neighborNode)
                end
            end

            ::continue::
        end
    end

    -- No path found
    return nil
end

-- Hex distance heuristic (vertical axial)
function Pathfinding:heuristic(q1, r1, q2, r2)
    return HexMath.distance(q1, r1, q2, r2)
end

-- Get node with lowest f score
function Pathfinding:getLowestFScore(openSet, fScore)
    local lowest = openSet[1]
    local lowestScore = math.huge

    for _, node in ipairs(openSet) do
        local key = string.format("%d,%d", node.q, node.r)
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
        if n.q == node.q and n.r == node.r then
            table.remove(list, i)
            return
        end
    end
end

-- Check if coordinates are in list
function Pathfinding:inList(list, q, r)
    for _, node in ipairs(list) do
        if node.q == q and node.r == r then
            return true
        end
    end
    return false
end

-- Reconstruct path from cameFrom map
function Pathfinding:reconstructPath(cameFrom, current)
    local path = {}
    local currentKey = string.format("%d,%d", current.q, current.r)

    while cameFrom[currentKey] do
        table.insert(path, 1, {q = current.q, r = current.r})
        current = cameFrom[currentKey]
        currentKey = string.format("%d,%d", current.q, current.r)
    end

    -- Add start position
    table.insert(path, 1, {q = current.q, r = current.r})

    return path
end

-- Find path for multi-tile unit
function Pathfinding:findPathForMultiTile(unit, goalQ, goalR, battlefield, actionSystem)
    -- Get unit's current position
    local startQ, startR = unit.q or unit.x, unit.r or unit.y

    -- Try direct pathfinding first
    local path = self:findPath(unit, startQ, startR, goalQ, goalR, battlefield, actionSystem)
    if path then
        return path
    end

    -- If direct path fails, try adjacent positions
    local neighbors = HexMath.getNeighbors(goalQ, goalR)
    for _, neighbor in ipairs(neighbors) do
        path = self:findPath(unit, startQ, startR, neighbor.q, neighbor.r, battlefield, actionSystem)
        if path then
            return path
        end
    end

    return nil
end

-- Check if path is valid
function Pathfinding:isPathValid(path, unit, battlefield, actionSystem)
    if not path or #path == 0 then
        return false
    end

    for i = 1, #path - 1 do
        local current = path[i]
        local next = path[i + 1]

        -- Check if hexes are adjacent
        local dist = HexMath.distance(current.q, current.r, next.q, next.r)
        if dist ~= 1 then
            return false
        end

        -- Check if movement is possible
        if actionSystem and actionSystem.calculateMovementCost then
            local currentTile = battlefield:getTile(current.q, current.r)
            local nextTile = battlefield:getTile(next.q, next.r)
            local cost = actionSystem:calculateMovementCost(unit, currentTile, nextTile, battlefield)
            if cost == 0 or cost == math.huge then
                return false
            end
        end
    end

    return true
end

-- Calculate total path cost
function Pathfinding:getPathCost(path, unit, battlefield, actionSystem)
    if not path or #path <= 1 then
        return 0
    end

    local totalCost = 0
    for i = 1, #path - 1 do
        local current = path[i]
        local next = path[i + 1]

        local cost = 1
        if actionSystem and actionSystem.calculateMovementCost then
            local currentTile = battlefield:getTile(current.q, current.r)
            local nextTile = battlefield:getTile(next.q, next.r)
            cost = actionSystem:calculateMovementCost(unit, currentTile, nextTile, battlefield)
        end

        totalCost = totalCost + cost
    end

    return totalCost
end

return Pathfinding

