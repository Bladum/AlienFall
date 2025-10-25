---Province Graph System - Strategic Network and Pathfinding
---
---Manages province network (graph structure) and pathfinding between provinces.
---Provinces are connected in a graph where edges represent adjacency (shared borders
---or strategic connections). Provides A* pathfinding for craft movement and mission planning.
---
---Graph Structure:
---  - Nodes: Provinces (strategic locations)
---  - Edges: Connections (adjacency, travel routes)
---  - Weights: Distance or travel time between provinces
---  - Directed/Undirected: Bidirectional connections
---
---Key Operations:
---  - addProvince(province): Adds province to graph
---  - connectProvinces(id1, id2): Creates bidirectional edge
---  - getProvince(provinceId): Returns province entity
---  - getNeighbors(provinceId): Returns connected provinces
---  - pathfind(fromId, toId): A* pathfinding between provinces
---  - getDistance(id1, id2): Returns path distance
---
---Pathfinding:
---  - Algorithm: A* with Manhattan distance heuristic
---  - Cost: Distance between provinces
---  - Blocked: Provinces can be impassable (enemy territory)
---  - Output: Array of province IDs from start to goal
---
---Key Exports:
---  - ProvinceGraph.new(): Creates province graph
---  - addProvince(province): Registers province
---  - connectProvinces(id1, id2): Links provinces
---  - pathfind(fromId, toId, isWalkable): Returns path array
---  - getNeighbors(provinceId): Returns adjacent provinces
---
---Dependencies:
---  - geoscape.geography.province: Province entity
---  - geoscape.systems.hex_grid: Distance calculations
---
---@module geoscape.geography.province_graph
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ProvinceGraph = require("geoscape.geography.province_graph")
---  local graph = ProvinceGraph.new()
---  graph:addProvince(provinceEntity)
---  graph:connectProvinces("province_1", "province_2")
---  local path = graph:pathfind("province_1", "province_10")
---
---@see geoscape.geography.province For province entity
---@see geoscape.systems.hex_grid For pathfinding algorithm

local Province = require("geoscape.geography.province")
local HexGrid = require("geoscape.systems.hex_grid")

local ProvinceGraph = {}
ProvinceGraph.__index = ProvinceGraph

---Create a new province graph
---@return table ProvinceGraph instance
function ProvinceGraph.new()
    local self = setmetatable({}, ProvinceGraph)
    
    self.provinces = {}  -- Map of provinceId -> Province
    self.provincesByHex = {}  -- Map of "q,r" -> Province
    
    print("[ProvinceGraph] Created empty province graph")
    
    return self
end

---Add a province to the graph
---@param province table Province object
function ProvinceGraph:addProvince(province)
    if self.provinces[province.id] then
        print(string.format("[ProvinceGraph] Warning: Province %s already exists", province.id))
        return
    end
    
    self.provinces[province.id] = province
    local hexKey = string.format("%d,%d", province.q, province.r)
    self.provincesByHex[hexKey] = province
end

---Get province by ID
---@param provinceId string Province ID
---@return table? Province object or nil
function ProvinceGraph:getProvince(provinceId)
    return self.provinces[provinceId]
end

---Get province at hex coordinates
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return table? Province object or nil
function ProvinceGraph:getProvinceAtHex(q, r)
    local hexKey = string.format("%d,%d", q, r)
    return self.provincesByHex[hexKey]
end

---Add bidirectional connection between provinces
---@param provinceId1 string First province ID
---@param provinceId2 string Second province ID
---@param cost number? Travel cost (default 1)
function ProvinceGraph:addConnection(provinceId1, provinceId2, cost)
    local p1 = self.provinces[provinceId1]
    local p2 = self.provinces[provinceId2]
    
    if not p1 or not p2 then
        print(string.format("[ProvinceGraph] Warning: Cannot connect %s to %s - province not found",
            tostring(provinceId1), tostring(provinceId2)))
        return
    end
    
    cost = cost or 1
    p1:addConnection(provinceId2, cost)
    p2:addConnection(provinceId1, cost)
end

---Get all neighbors of a province
---@param provinceId string Province ID
---@return table List of neighbor Province objects
function ProvinceGraph:getNeighbors(provinceId)
    local province = self.provinces[provinceId]
    if not province then
        return {}
    end
    
    local neighbors = {}
    for _, conn in ipairs(province.connections) do
        local neighbor = self.provinces[conn.id]
        if neighbor then
            table.insert(neighbors, neighbor)
        end
    end
    
    return neighbors
end

---Find path between two provinces using A* algorithm
---@param fromId string Start province ID
---@param toId string End province ID
---@return table? List of province IDs in path, or nil if no path
---@return number? Total cost of path
function ProvinceGraph:findPath(fromId, toId)
    local startProvince = self.provinces[fromId]
    local goalProvince = self.provinces[toId]
    
    if not startProvince or not goalProvince then
        return nil, nil
    end
    
    if fromId == toId then
        return {fromId}, 0
    end
    
    -- A* implementation
    local openSet = {fromId}
    local cameFrom = {}
    local gScore = {[fromId] = 0}
    local fScore = {[fromId] = HexGrid.distance(startProvince.q, startProvince.r, goalProvince.q, goalProvince.r)}
    
    while #openSet > 0 do
        -- Find node in openSet with lowest fScore
        local current = openSet[1]
        local currentFScore = fScore[current]
        local currentIndex = 1
        
        for i = 2, #openSet do
            local nodeId = openSet[i]
            if fScore[nodeId] < currentFScore then
                current = nodeId
                currentFScore = fScore[nodeId]
                currentIndex = i
            end
        end
        
        if current == toId then
            -- Reconstruct path
            local path = {current}
            while cameFrom[current] do
                current = cameFrom[current]
                table.insert(path, 1, current)
            end
            return path, gScore[toId]
        end
        
        table.remove(openSet, currentIndex)
        
        -- Check all neighbors
        local currentProvince = self.provinces[current]
        for _, conn in ipairs(currentProvince.connections) do
            local neighborId = conn.id
            local neighbor = self.provinces[neighborId]
            
            if neighbor then
                local tentativeGScore = gScore[current] + conn.cost
                
                if not gScore[neighborId] or tentativeGScore < gScore[neighborId] then
                    cameFrom[neighborId] = current
                    gScore[neighborId] = tentativeGScore
                    fScore[neighborId] = tentativeGScore + HexGrid.distance(neighbor.q, neighbor.r, goalProvince.q, goalProvince.r)
                    
                    -- Add to openSet if not already present
                    local inOpenSet = false
                    for _, id in ipairs(openSet) do
                        if id == neighborId then
                            inOpenSet = true
                            break
                        end
                    end
                    
                    if not inOpenSet then
                        table.insert(openSet, neighborId)
                    end
                end
            end
        end
    end
    
    return nil, nil  -- No path found
end

---Get all provinces within range (cost budget)
---@param fromId string Start province ID
---@param maxCost number Maximum travel cost
---@return table Map of provinceId -> {cost, path}
function ProvinceGraph:getRange(fromId, maxCost)
    local startProvince = self.provinces[fromId]
    if not startProvince then
        return {}
    end
    
    local result = {}
    local visited = {[fromId] = {cost = 0, path = {fromId}}}
    local queue = {{id = fromId, cost = 0, path = {fromId}}}
    
    while #queue > 0 do
        local current = table.remove(queue, 1)
        local currentProvince = self.provinces[current.id]
        
        for _, conn in ipairs(currentProvince.connections) do
            local neighborId = conn.id
            local newCost = current.cost + conn.cost
            
            if newCost <= maxCost then
                if not visited[neighborId] or newCost < visited[neighborId].cost then
                    local newPath = {}
                    for _, id in ipairs(current.path) do
                        table.insert(newPath, id)
                    end
                    table.insert(newPath, neighborId)
                    
                    visited[neighborId] = {cost = newCost, path = newPath}
                    table.insert(queue, {id = neighborId, cost = newCost, path = newPath})
                end
            end
        end
    end
    
    return visited
end

---Get all province IDs
---@return table List of province IDs
function ProvinceGraph:getProvinceIds()
    local ids = {}
    for id, _ in pairs(self.provinces) do
        table.insert(ids, id)
    end
    return ids
end

---Get province count
---@return number Number of provinces
function ProvinceGraph:getProvinceCount()
    local count = 0
    for _ in pairs(self.provinces) do
        count = count + 1
    end
    return count
end

---Get all provinces as a list
---@return table List of Province objects
function ProvinceGraph:getAllProvinces()
    local list = {}
    for _, province in pairs(self.provinces) do
        table.insert(list, province)
    end
    return list
end

---Clear all provinces
function ProvinceGraph:clear()
    self.provinces = {}
    self.provincesByHex = {}
end

return ProvinceGraph


























