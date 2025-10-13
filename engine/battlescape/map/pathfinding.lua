-- Pathfinding System for Hex Grid
-- Implements A* algorithm optimized for hexagonal grids with terrain costs
-- Supports Time Unit (TU) calculation and multi-turn movement planning

local Pathfinding = {}

--- Binary heap for priority queue (optimized A* open set)
local BinaryHeap = {}
BinaryHeap.__index = BinaryHeap

function BinaryHeap.new(compareFunc)
    local self = setmetatable({}, BinaryHeap)
    self.heap = {}
    self.compare = compareFunc or function(a, b) return a < b end
    return self
end

function BinaryHeap:push(value)
    table.insert(self.heap, value)
    self:bubbleUp(#self.heap)
end

function BinaryHeap:pop()
    if #self.heap == 0 then return nil end
    
    local root = self.heap[1]
    local last = table.remove(self.heap)
    
    if #self.heap > 0 then
        self.heap[1] = last
        self:bubbleDown(1)
    end
    
    return root
end

function BinaryHeap:bubbleUp(index)
    while index > 1 do
        local parentIndex = math.floor(index / 2)
        if self.compare(self.heap[index], self.heap[parentIndex]) then
            self.heap[index], self.heap[parentIndex] = self.heap[parentIndex], self.heap[index]
            index = parentIndex
        else
            break
        end
    end
end

function BinaryHeap:bubbleDown(index)
    local count = #self.heap
    while true do
        local leftChild = index * 2
        local rightChild = index * 2 + 1
        local smallest = index
        
        if leftChild <= count and self.compare(self.heap[leftChild], self.heap[smallest]) then
            smallest = leftChild
        end
        
        if rightChild <= count and self.compare(self.heap[rightChild], self.heap[smallest]) then
            smallest = rightChild
        end
        
        if smallest ~= index then
            self.heap[index], self.heap[smallest] = self.heap[smallest], self.heap[index]
            index = smallest
        else
            break
        end
    end
end

function BinaryHeap:isEmpty()
    return #self.heap == 0
end

--- Node pool for memory efficiency (reuse node objects)
local NodePool = {}
NodePool.__index = NodePool

function NodePool.new()
    local self = setmetatable({}, NodePool)
    self.pool = {}
    self.active = {}
    return self
end

function NodePool:acquire(x, y, g, h, parent)
    local node
    if #self.pool > 0 then
        node = table.remove(self.pool)
        node.x = x
        node.y = y
        node.g = g
        node.h = h
        node.f = g + h
        node.parent = parent
    else
        node = {
            x = x,
            y = y,
            g = g,
            h = h,
            f = g + h,
            parent = parent
        }
    end
    
    self.active[x .. "," .. y] = node
    return node
end

function NodePool:release(node)
    local key = node.x .. "," .. node.y
    self.active[key] = nil
    table.insert(self.pool, node)
end

function NodePool:releaseAll()
    for _, node in pairs(self.active) do
        table.insert(self.pool, node)
    end
    self.active = {}
end

--- Pathfinding main module
Pathfinding.NodePool = NodePool.new()

--- Hex distance heuristic (Manhattan distance for hex grid)
-- @param x1 number Start X
-- @param y1 number Start Y
-- @param x2 number Goal X
-- @param y2 number Goal Y
-- @return number Estimated distance
function Pathfinding.hexDistance(x1, y1, x2, y2)
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    return dx + dy
end

--- Get hex neighbors (6 adjacent tiles)
-- @param x number Center X
-- @param y number Center Y
-- @return table Array of {x, y} neighbors
function Pathfinding.getHexNeighbors(x, y)
    -- Standard hex grid neighbors (flat-top orientation)
    return {
        {x = x + 1, y = y},
        {x = x - 1, y = y},
        {x = x, y = y + 1},
        {x = x, y = y - 1},
        {x = x + 1, y = y - 1},
        {x = x - 1, y = y + 1}
    }
end

--- Check if a tile is walkable
-- @param battlefield table Battlefield reference
-- @param x number Tile X
-- @param y number Tile Y
-- @param ignoreUnits boolean Ignore units when checking
-- @return boolean True if walkable
function Pathfinding.isWalkable(battlefield, x, y, ignoreUnits)
    if not battlefield then
        return true  -- No battlefield = assume walkable
    end
    
    -- Check tile exists and is walkable
    local tile = battlefield:getTile(x, y)
    if not tile or tile.blocksMovement then
        return false
    end
    
    -- Check for units (unless ignoring them)
    if not ignoreUnits then
        local unit = battlefield:getUnitAt(x, y)
        if unit then
            return false
        end
    end
    
    return true
end

--- Get terrain movement cost
-- @param battlefield table Battlefield reference
-- @param x number Tile X
-- @param y number Tile Y
-- @param terrainCosts table Terrain cost lookup table
-- @return number Movement cost multiplier (1.0 = normal)
function Pathfinding.getTerrainCost(battlefield, x, y, terrainCosts)
    if not battlefield or not terrainCosts then
        return 1.0
    end
    
    local tile = battlefield:getTile(x, y)
    if not tile then
        return 1.0
    end
    
    local terrainType = tile.terrainType or "floor"
    return terrainCosts[terrainType] or 1.0
end

--- Find path using A* algorithm
-- @param battlefield table Battlefield reference
-- @param startX number Start X position
-- @param startY number Start Y position
-- @param goalX number Goal X position
-- @param goalY number Goal Y position
-- @param terrainCosts table Optional terrain cost lookup
-- @param maxCost number Optional maximum path cost (for TU limits)
-- @return table|nil Path as array of {x, y, cost} or nil if no path found
function Pathfinding.findPath(battlefield, startX, startY, goalX, goalY, terrainCosts, maxCost)
    local startTime = love.timer.getTime()
    
    print("[Pathfinding] Finding path from (" .. startX .. "," .. startY .. ") to (" .. 
          goalX .. "," .. goalY .. ")")
    
    -- Early exit if start == goal
    if startX == goalX and startY == goalY then
        return {{x = startX, y = startY, cost = 0}}
    end
    
    -- Early exit if goal is not walkable
    if not Pathfinding.isWalkable(battlefield, goalX, goalY, true) then
        print("[Pathfinding] Goal is not walkable")
        return nil
    end
    
    -- Initialize data structures
    local openSet = BinaryHeap.new(function(a, b) return a.f < b.f end)
    local closedSet = {}
    local nodePool = Pathfinding.NodePool
    nodePool:releaseAll()
    
    -- Create start node
    local startNode = nodePool:acquire(startX, startY, 0, 
                                       Pathfinding.hexDistance(startX, startY, goalX, goalY), nil)
    openSet:push(startNode)
    
    local nodesExplored = 0
    local pathFound = false
    
    -- A* main loop
    while not openSet:isEmpty() do
        local current = openSet:pop()
        nodesExplored = nodesExplored + 1
        
        -- Check if we reached the goal
        if current.x == goalX and current.y == goalY then
            pathFound = true
            
            -- Reconstruct path
            local path = {}
            local node = current
            while node do
                table.insert(path, 1, {x = node.x, y = node.y, cost = node.g})
                node = node.parent
            end
            
            local endTime = love.timer.getTime()
            local duration = (endTime - startTime) * 1000  -- Convert to ms
            
            print("[Pathfinding] Path found! Length=" .. #path .. ", Cost=" .. current.g .. 
                  ", Nodes explored=" .. nodesExplored .. ", Time=" .. 
                  string.format("%.2fms", duration))
            
            return path
        end
        
        -- Mark as closed
        closedSet[current.x .. "," .. current.y] = true
        
        -- Check all neighbors
        local neighbors = Pathfinding.getHexNeighbors(current.x, current.y)
        for _, neighbor in ipairs(neighbors) do
            local nx, ny = neighbor.x, neighbor.y
            local neighborKey = nx .. "," .. ny
            
            -- Skip if already closed or not walkable
            if not closedSet[neighborKey] and Pathfinding.isWalkable(battlefield, nx, ny, false) then
                -- Calculate cost
                local terrainCost = Pathfinding.getTerrainCost(battlefield, nx, ny, terrainCosts)
                local moveCost = 1.0 * terrainCost
                local newG = current.g + moveCost
                
                -- Skip if exceeds max cost
                if maxCost and newG > maxCost then
                    goto continue
                end
                
                -- Check if this path is better
                local existingNode = nodePool.active[neighborKey]
                if existingNode then
                    if newG < existingNode.g then
                        -- Update existing node
                        existingNode.g = newG
                        existingNode.f = newG + existingNode.h
                        existingNode.parent = current
                    end
                else
                    -- Create new node
                    local h = Pathfinding.hexDistance(nx, ny, goalX, goalY)
                    local newNode = nodePool:acquire(nx, ny, newG, h, current)
                    openSet:push(newNode)
                end
            end
            
            ::continue::
        end
    end
    
    local endTime = love.timer.getTime()
    local duration = (endTime - startTime) * 1000
    
    print("[Pathfinding] No path found. Nodes explored=" .. nodesExplored .. 
          ", Time=" .. string.format("%.2fms", duration))
    
    return nil
end

--- Calculate path cost in Time Units (TUs)
-- @param path table Path array
-- @param baseTUCost number Base TU cost per tile (default 4)
-- @return number Total TU cost
function Pathfinding.calculateTUCost(path, baseTUCost)
    if not path or #path == 0 then
        return 0
    end
    
    baseTUCost = baseTUCost or 4
    
    -- Sum up all movement costs
    local totalCost = 0
    for i = 2, #path do  -- Skip start position
        local tile = path[i]
        totalCost = totalCost + (tile.cost * baseTUCost)
    end
    
    return math.ceil(totalCost)
end

--- Split path into segments based on available TUs
-- @param path table Complete path
-- @param availableTUs number TUs available for movement
-- @param baseTUCost number Base TU cost per tile
-- @return table Current turn path, table Remaining path
function Pathfinding.splitPathByTUs(path, availableTUs, baseTUCost)
    if not path or #path <= 1 then
        return path, nil
    end
    
    baseTUCost = baseTUCost or 4
    local currentPath = {path[1]}  -- Start with first position
    local tuSpent = 0
    local splitIndex = 1
    
    for i = 2, #path do
        local moveCost = path[i].cost * baseTUCost
        
        if tuSpent + moveCost <= availableTUs then
            table.insert(currentPath, path[i])
            tuSpent = tuSpent + moveCost
            splitIndex = i
        else
            break
        end
    end
    
    -- Create remaining path
    local remainingPath = nil
    if splitIndex < #path then
        remainingPath = {}
        for i = splitIndex, #path do
            table.insert(remainingPath, path[i])
        end
    end
    
    return currentPath, remainingPath
end

--- Check if path is still valid (no new obstacles)
-- @param battlefield table Battlefield reference
-- @param path table Path to validate
-- @return boolean True if path is still valid
function Pathfinding.isPathValid(battlefield, path)
    if not path or #path == 0 then
        return false
    end
    
    for i = 2, #path do  -- Skip start position
        if not Pathfinding.isWalkable(battlefield, path[i].x, path[i].y, false) then
            return false
        end
    end
    
    return true
end

--- Get movement direction from one tile to next
-- @param fromX number From X
-- @param fromY number From Y
-- @param toX number To X
-- @param toY number To Y
-- @return string Direction name
function Pathfinding.getDirection(fromX, fromY, toX, toY)
    local dx = toX - fromX
    local dy = toY - fromY
    
    if dx > 0 and dy == 0 then return "east"
    elseif dx < 0 and dy == 0 then return "west"
    elseif dx == 0 and dy > 0 then return "south"
    elseif dx == 0 and dy < 0 then return "north"
    elseif dx > 0 and dy < 0 then return "northeast"
    elseif dx < 0 and dy > 0 then return "southwest"
    else return "unknown"
    end
end

return Pathfinding
