---@meta

---Province Pathfinding System
---Handles A* pathfinding for UFO movement across province graphs
---Calculates routes between provinces considering accessibility, terrain, and faction presence
---@module province_pathfinding

local ProvincePathfinding = {}

---@class ProvinceNode
---@field id string Province identifier
---@field x number World X coordinate
---@field y number World Y coordinate
---@field connections table Adjacent province IDs
---@field terrain string Terrain type (land, water, air)
---@field controlledBy string|nil Faction ID that controls this province

---@class PathfindingResult
---@field found boolean Whether path exists
---@field path table List of province IDs from start to end
---@field distance number Total distance (hex distance)
---@field cost number Total movement cost
---@field difficulty number Difficulty of the path (terrain, defenses, etc.)

-- Cache for province graph connections
local provinceGraph = {}
local provinceCache = {}

---Initialize province graph from world system
---@param worldSystem table World system instance with provinces
function ProvincePathfinding.initialize(worldSystem)
    print("[ProvincePathfinding] Initializing province graph...")

    if not worldSystem or not worldSystem.provinces then
        print("[ProvincePathfinding] ERROR: World system not available, using empty graph")
        return
    end

    -- Build adjacency graph for provinces
    for provinceId, province in pairs(worldSystem.provinces) do
        provinceCache[provinceId] = {
            id = provinceId,
            x = province.x or 0,
            y = province.y or 0,
            terrain = province.terrain or "land",
            controlledBy = province.controlledBy
        }
    end

    -- Build connections (6-neighbors for hexagonal grid)
    for provinceId, province in pairs(provinceCache) do
        provinceGraph[provinceId] = {}

        for otherId, otherProvince in pairs(provinceCache) do
            if provinceId ~= otherId then
                local distance = ProvincePathfinding.hexDistance(
                    province.x, province.y,
                    otherProvince.x, otherProvince.y
                )

                -- Connect adjacent provinces (distance 1)
                if distance == 1 then
                    table.insert(provinceGraph[provinceId], otherId)
                end
            end
        end
    end

    print(string.format("[ProvincePathfinding] Built graph with %d provinces", #provinceCache))
end

---Calculate hex distance between two coordinates
---@param x1 number First X
---@param y1 number First Y
---@param x2 number Second X
---@param y2 number Second Y
---@return number Distance in hexes
function ProvincePathfinding.hexDistance(x1, y1, x2, y2)
    -- Hex distance in offset coordinates
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)

    -- Offset coordinate distance formula
    if (x1 % 2) ~= (x2 % 2) then
        return (dx + math.max(0, (dy - (dx + 1) / 2))) -- Adjusted for offset
    else
        return (dx + math.max(0, (dy - dx / 2)))
    end
end

---Get movement cost between two provinces
---@param fromId string Source province ID
---@param toId string Destination province ID
---@param faction string|nil Faction for alliance/hostility checks
---@return number Cost (1.0 = normal, >1.0 = difficult, <1.0 = fast)
function ProvincePathfinding.getMovementCost(fromId, toId, faction)
    local toProvince = provinceCache[toId]
    if not toProvince then
        return 2.0 -- Invalid destination = very expensive
    end

    local cost = 1.0

    -- Terrain costs
    if toProvince.terrain == "water" then
        cost = cost * 1.2 -- Water slightly slower
    elseif toProvince.terrain == "mountains" then
        cost = cost * 1.5 -- Mountains slower
    elseif toProvince.terrain == "air" then
        cost = cost * 0.8 -- Air faster (UFOs can fly)
    end

    -- Faction control costs
    if faction and toProvince.controlledBy then
        if toProvince.controlledBy == faction then
            cost = cost * 0.9 -- Friendly territory is slightly faster
        else
            cost = cost * 1.3 -- Hostile territory slower (evasion needed)
        end
    end

    return cost
end

---Find path from start to goal using A* algorithm
---@param startId string Source province ID
---@param goalId string Destination province ID
---@param faction string|nil Faction for cost calculation
---@return PathfindingResult Pathfinding result with path and metadata
function ProvincePathfinding.findPath(startId, goalId, faction)
    -- TASK-12.3: Province graph pathfinding for UFO movement

    if not provinceCache[startId] or not provinceCache[goalId] then
        print(string.format("[ProvincePathfinding] ERROR: Invalid start %s or goal %s",
            startId or "nil", goalId or "nil"))
        return {found = false, path = {}, distance = 0, cost = 0, difficulty = 0}
    end

    if startId == goalId then
        return {found = true, path = {startId}, distance = 0, cost = 0, difficulty = 0}
    end

    -- A* algorithm implementation
    local openSet = {}
    local cameFrom = {}
    local gScore = {} -- Cost from start
    local fScore = {} -- Estimated total cost

    -- Initialize
    openSet[startId] = true
    gScore[startId] = 0
    local startProv = provinceCache[startId]
    local goalProv = provinceCache[goalId]
    fScore[startId] = ProvincePathfinding.hexDistance(startProv.x, startProv.y, goalProv.x, goalProv.y)

    while next(openSet) do
        -- Find node in openSet with lowest fScore
        local current = nil
        local lowestF = math.huge

        for nodeId in pairs(openSet) do
            if (fScore[nodeId] or math.huge) < lowestF then
                current = nodeId
                lowestF = fScore[nodeId] or math.huge
            end
        end

        if current == goalId then
            -- Reconstruct path
            local path = {current}
            while cameFrom[current] do
                current = cameFrom[current]
                table.insert(path, 1, current)
            end

            -- Calculate total cost
            local totalCost = gScore[goalId] or 0
            local difficulty = ProvincePathfinding.calculatePathDifficulty(path, faction)
            local distance = #path - 1 -- Number of hops

            return {
                found = true,
                path = path,
                distance = distance,
                cost = totalCost,
                difficulty = difficulty
            }
        end

        if current then
            openSet[current] = nil
        end

        -- Check neighbors
        local neighbors = provinceGraph[current] or {}
        for _, neighborId in ipairs(neighbors) do
            local moveCost = ProvincePathfinding.getMovementCost(current, neighborId, faction)
            local tentativeG = (gScore[current] or 0) + moveCost

            if not gScore[neighborId] or tentativeG < gScore[neighborId] then
                cameFrom[neighborId] = current
                gScore[neighborId] = tentativeG

                local neighborProv = provinceCache[neighborId]
                local heuristic = ProvincePathfinding.hexDistance(
                    neighborProv.x, neighborProv.y,
                    goalProv.x, goalProv.y
                )
                fScore[neighborId] = tentativeG + heuristic

                openSet[neighborId] = true
            end
        end
    end

    -- No path found
    print(string.format("[ProvincePathfinding] No path found from %s to %s", startId, goalId))
    return {found = false, path = {}, distance = 0, cost = 0, difficulty = 0}
end

---Calculate difficulty of a path based on terrain and faction presence
---@param path table List of province IDs
---@param faction string|nil Faction for evaluation
---@return number Difficulty score (0-1, higher = harder)
function ProvincePathfinding.calculatePathDifficulty(path, faction)
    local difficulty = 0
    local count = 0

    for _, provinceId in ipairs(path) do
        local province = provinceCache[provinceId]

        -- Terrain difficulty
        if province.terrain == "mountains" then
            difficulty = difficulty + 0.3
        elseif province.terrain == "water" then
            difficulty = difficulty + 0.2
        end

        -- Faction control difficulty (passing through hostile territory)
        if faction and province.controlledBy and province.controlledBy ~= faction then
            difficulty = difficulty + 0.2
        end

        count = count + 1
    end

    if count > 0 then
        difficulty = difficulty / count
    end

    return math.min(1.0, difficulty)
end

---Get all neighbors of a province
---@param provinceId string Province identifier
---@return table List of neighboring province IDs
function ProvincePathfinding.getNeighbors(provinceId)
    return provinceGraph[provinceId] or {}
end

---Get province data
---@param provinceId string Province identifier
---@return table|nil Province data or nil if not found
function ProvincePathfinding.getProvince(provinceId)
    return provinceCache[provinceId]
end

---Check if path is clear (no blocking provinces)
---@param path table List of province IDs
---@param blockingFactions table|nil List of hostile factions that block path
---@return boolean true if path is clear
function ProvincePathfinding.isPathClear(path, blockingFactions)
    for _, provinceId in ipairs(path) do
        local province = provinceCache[provinceId]

        if blockingFactions then
            for _, hostileFaction in ipairs(blockingFactions) do
                if province.controlledBy == hostileFaction then
                    return false -- Blocked by hostile faction
                end
            end
        end
    end

    return true
end

---Calculate optimal movement for UFO from current to target province
---@param currentId string Current province ID
---@param targetId string Target province ID
---@param ufoPower number UFO relative power (affects avoidance behavior)---@return string|nil Next province ID to move to, or nil if at target
function ProvincePathfinding.getNextMove(currentId, targetId, ufoPower)
    if currentId == targetId then
        return nil -- Already at target
    end

    -- Find path to target
    local pathResult = ProvincePathfinding.findPath(currentId, targetId, "aliens")

    if not pathResult.found or #pathResult.path < 2 then
        return nil
    end

    -- Return next province in path
    return pathResult.path[2] -- [1] is current position
end

---Clear pathfinding caches
function ProvincePathfinding.reset()
    provinceGraph = {}
    provinceCache = {}
    print("[ProvincePathfinding] Caches cleared")
end

return ProvincePathfinding

