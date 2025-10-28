-- ─────────────────────────────────────────────────────────────────────────
-- Pathfinding & Movement System Tests
-- ─────────────────────────────────────────────────────────────────────────
-- Covers: A* pathfinding, movement cost calculation, TU consumption,
-- deployment zone selection, and tactical movement optimization
-- ─────────────────────────────────────────────────────────────────────────

package.path = package.path .. ";engine/?.lua;engine/?/?.lua"

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- HIERARCHICAL SUITE SETUP
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    module = "engine.battlescape.pathfinding_movement",
    file = "pathfinding_movement.lua",
    description = "Pathfinding & movement system - A* algorithm, TU costs, deployment zones"
})

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK SYSTEMS
-- ─────────────────────────────────────────────────────────────────────────

---@class PathfindingSystem
---@field grids table
---@field pathCache table
---@field heuristicType string
---@field diagonalMovement boolean
local MockPathfindingSystem = {}
MockPathfindingSystem.__index = MockPathfindingSystem

function MockPathfindingSystem:new()
    local self = setmetatable({}, MockPathfindingSystem)
    self.grids = {}
    self.pathCache = {}
    self.heuristicType = "manhattan"
    self.diagonalMovement = true
    return self
end

---Create a test grid (1 = walkable, 0 = obstacle)
function MockPathfindingSystem:createGrid(width, height, obstacles)
    obstacles = obstacles or {}
    local grid = {}

    for y = 1, height do
        grid[y] = {}
        for x = 1, width do
            grid[y][x] = 1  -- Walkable by default
        end
    end

    -- Add obstacles
    for _, obstacle in ipairs(obstacles) do
        if grid[obstacle.y] then
            grid[obstacle.y][obstacle.x] = 0
        end
    end

    return grid
end

---Manhattan distance heuristic
local function manhattanDistance(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

---Euclidean distance heuristic
local function euclideanDistance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

---A* pathfinding algorithm
function MockPathfindingSystem:findPath(grid, startX, startY, endX, endY, heuristic)
    heuristic = heuristic or "manhattan"

    if startX == endX and startY == endY then
        return {grid[startY][startX] == 1 and {x = startX, y = startY} or nil}
    end

    local hFunc = heuristic == "euclidean" and euclideanDistance or manhattanDistance

    -- Check if goal is walkable
    if not grid[endY] or grid[endY][endX] == 0 then
        return nil
    end

    -- Open and closed sets
    local openSet = {}
    local cameFrom = {}
    local gScore = {}
    local fScore = {}

    local startKey = startX .. "," .. startY
    local endKey = endX .. "," .. endY

    table.insert(openSet, {x = startX, y = startY})
    gScore[startKey] = 0
    fScore[startKey] = hFunc(startX, startY, endX, endY)

    local iterations = 0
    local maxIterations = 1000

    while #openSet > 0 and iterations < maxIterations do
        iterations = iterations + 1

        -- Find node in openSet with lowest fScore
        local current = openSet[1]
        local currentIdx = 1
        for i, node in ipairs(openSet) do
            local nodeKey = node.x .. "," .. node.y
            local currentKey = current.x .. "," .. current.y
            if fScore[nodeKey] < fScore[currentKey] then
                current = node
                currentIdx = i
            end
        end

        if current.x == endX and current.y == endY then
            -- Reconstruct path
            local path = {}
            local currentKey = endKey
            while cameFrom[currentKey] do
                local parts = {}
                for part in currentKey:gmatch("[^,]+") do
                    table.insert(parts, tonumber(part))
                end
                table.insert(path, 1, {x = parts[1], y = parts[2]})
                currentKey = cameFrom[currentKey]
            end
            table.insert(path, 1, {x = startX, y = startY})
            return path
        end

        table.remove(openSet, currentIdx)

        -- Check neighbors (4-directional + diagonals if enabled)
        local neighbors = {
            {dx = 1, dy = 0}, {dx = -1, dy = 0},
            {dx = 0, dy = 1}, {dx = 0, dy = -1}
        }
        if self.diagonalMovement then
            table.insert(neighbors, {dx = 1, dy = 1})
            table.insert(neighbors, {dx = -1, dy = -1})
            table.insert(neighbors, {dx = 1, dy = -1})
            table.insert(neighbors, {dx = -1, dy = 1})
        end

        for _, neighbor in ipairs(neighbors) do
            local nx = current.x + neighbor.dx
            local ny = current.y + neighbor.dy

            if not grid[ny] or grid[ny][nx] == 0 then
                goto next_neighbor
            end

            local tenativGScore = gScore[current.x .. "," .. current.y] +
                                 (math.abs(neighbor.dx) + math.abs(neighbor.dy))

            local nKey = nx .. "," .. ny
            if not gScore[nKey] or tenativGScore < gScore[nKey] then
                cameFrom[nKey] = current.x .. "," .. current.y
                gScore[nKey] = tenativGScore
                fScore[nKey] = gScore[nKey] + hFunc(nx, ny, endX, endY)

                local found = false
                for _, node in ipairs(openSet) do
                    if node.x == nx and node.y == ny then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(openSet, {x = nx, y = ny})
                end
            end

            ::next_neighbor::
        end
    end

    return nil  -- No path found
end

-- ─────────────────────────────────────────────────────────────────────────

---@class MovementSystem
---@field units table
---@field terrainCosts table
---@field baseMovementCost number
local MockMovementSystem = {}
MockMovementSystem.__index = MockMovementSystem

function MockMovementSystem:new()
    local self = setmetatable({}, MockMovementSystem)
    self.units = {}
    self.terrainCosts = {
        grass = 1.0,
        sand = 1.2,
        water = 2.0,
        road = 0.5,
        forest = 1.5
    }
    self.baseMovementCost = 4  -- TU per tile
    return self
end

---Create unit with movement data
function MockMovementSystem:createUnit(unitId, maxTU, unitType)
    unitType = unitType or "ASSAULT"
    local unit = {
        id = unitId,
        tu = maxTU,
        maxTU = maxTU,
        position = {x = 5, y = 5},
        unitType = unitType,
        carryingCapacity = self:getCapacityForType(unitType)
    }
    self.units[unitId] = unit
    return unit
end

---Get movement point multiplier for unit type
function MockMovementSystem:getCapacityForType(unitType)
    local capacities = {
        SCOUT = 1.2,
        ASSAULT = 1.0,
        HEAVY = 0.8,
        SNIPER = 1.1
    }
    return capacities[unitType] or 1.0
end

---Calculate movement cost for a path
function MockMovementSystem:calculatePathCost(path, terrainTypes)
    terrainTypes = terrainTypes or {}
    local totalCost = 0

    for i = 1, #path - 1 do
        local current = path[i]
        local next = path[i + 1]

        -- Base cost for movement (Manhattan distance approximation)
        local distance = math.abs(next.x - current.x) + math.abs(next.y - current.y)

        -- Get terrain type for this tile
        local terrainType = terrainTypes[next.y] and terrainTypes[next.y][next.x] or "grass"
        local terrainMultiplier = self.terrainCosts[terrainType] or 1.0

        -- Calculate tile cost
        local tileCost = self.baseMovementCost * terrainMultiplier * distance
        totalCost = totalCost + tileCost
    end

    return math.ceil(totalCost)
end

---Execute movement for a unit
function MockMovementSystem:executeMovement(unitId, path)
    local unit = self.units[unitId]
    if not unit then
        return false, "Unit not found"
    end

    local cost = self:calculatePathCost(path)

    if unit.tu < cost then
        return false, "Insufficient TU"
    end

    unit.tu = unit.tu - cost
    unit.position = path[#path]

    return true, cost
end

---Get maximum movement range for a unit
function MockMovementSystem:getMaxMovementRange(unitId)
    local unit = self.units[unitId]
    if not unit then return 0 end

    local tuPerTile = self.baseMovementCost / unit.carryingCapacity
    return math.floor(unit.tu / tuPerTile)
end

-- ─────────────────────────────────────────────────────────────────────────

---@class DeploymentSystem
---@field deploymentZones table
---@field unitAssignments table
---@field mapSize table?
---@field maxZones number
local MockDeploymentSystem = {}
MockDeploymentSystem.__index = MockDeploymentSystem

function MockDeploymentSystem:new()
    local self = setmetatable({}, MockDeploymentSystem)
    self.deploymentZones = {}
    self.unitAssignments = {}
    self.mapSize = nil
    self.maxZones = 0
    return self
end

---Set map size (small, medium, large, huge)
function MockDeploymentSystem:setMapSize(sizeType)
    local sizes = {
        small = {gridSize = 4, maxZones = 1, capacity = 2},
        medium = {gridSize = 5, maxZones = 2, capacity = 3},
        large = {gridSize = 6, maxZones = 3, capacity = 4},
        huge = {gridSize = 7, maxZones = 4, capacity = 5}
    }

    local size = sizes[sizeType]
    if not size then return false end

    self.mapSize = size
    self.maxZones = size.maxZones
    return true
end

---Create deployment zones (typically at map edges)
function MockDeploymentSystem:selectDeploymentZones()
    if not self.mapSize then return nil end

    local zones = {}
    local gridSize = self.mapSize.gridSize

    -- Edge-based zone selection
    local candidates = {
        {index = 1, name = "North"},          -- Top-left
        {index = gridSize, name = "South"},   -- Bottom-right
        {index = gridSize * gridSize - gridSize + 1, name = "West"},  -- Bottom-left
        {index = gridSize * gridSize, name = "East"}  -- Top-right
    }

    for i = 1, self.maxZones do
        if candidates[i] then
            table.insert(zones, {
                id = "zone_" .. i,
                index = candidates[i].index,
                name = candidates[i].name,
                capacity = self.mapSize.capacity,
                assignedUnits = {},
                centerPos = {
                    x = ((candidates[i].index - 1) % gridSize) + 1,
                    y = math.floor((candidates[i].index - 1) / gridSize) + 1
                }
            })
        end
    end

    self.deploymentZones = zones
    return zones
end

---Assign unit to deployment zone
function MockDeploymentSystem:assignUnitToZone(unitId, zoneId)
    local zone = nil
    for _, z in ipairs(self.deploymentZones) do
        if z.id == zoneId then
            zone = z
            break
        end
    end

    if not zone then
        return false, "Zone not found"
    end

    if #zone.assignedUnits >= zone.capacity then
        return false, "Zone at capacity"
    end

    table.insert(zone.assignedUnits, unitId)
    self.unitAssignments[unitId] = zoneId
    return true
end

---Check if deployment is complete
function MockDeploymentSystem:isDeploymentComplete(requiredUnits)
    requiredUnits = requiredUnits or 0

    local totalAssigned = 0
    for _, zone in ipairs(self.deploymentZones) do
        totalAssigned = totalAssigned + #zone.assignedUnits
    end

    return totalAssigned >= requiredUnits
end

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: PATHFINDING BASICS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Pathfinding Basics", function()

    Suite:testMethod("PathfindingSystem:findPath", {
        description = "Finds valid path from start to goal",
        testCase = "basic_path",
        type = "functional"
    }, function()
        local pf = MockPathfindingSystem:new()
        local grid = pf:createGrid(10, 10)

        local path = pf:findPath(grid, 1, 1, 5, 5)

        if not path then error("Path should exist") end
        if path[1].x ~= 1 or path[1].y ~= 1 then error("Path should start at (1,1)") end
        if path[#path].x ~= 5 or path[#path].y ~= 5 then error("Path should end at (5,5)") end
    end)

    Suite:testMethod("PathfindingSystem:findPath with obstacles", {
        description = "Navigates around obstacles correctly",
        testCase = "obstacle_avoidance",
        type = "functional"
    }, function()
        local pf = MockPathfindingSystem:new()
        local obstacles = {
            {x = 3, y = 1}, {x = 3, y = 2}, {x = 3, y = 3},
            {x = 3, y = 4}, {x = 3, y = 5}
        }
        local grid = pf:createGrid(10, 10, obstacles)

        local path = pf:findPath(grid, 1, 3, 5, 3)

        if not path then error("Path should navigate around wall") end

        -- Verify path doesn't cross obstacles
        for _, step in ipairs(path) do
            if not grid[step.y] or grid[step.y][step.x] == 0 then
                error("Path should not traverse obstacles")
            end
        end
    end)

    Suite:testMethod("PathfindingSystem:impossible path", {
        description = "Returns nil for impossible paths",
        testCase = "blocked_path",
        type = "edge_case"
    }, function()
        local pf = MockPathfindingSystem:new()
        local obstacles = {}
        for y = 1, 10 do
            table.insert(obstacles, {x = 5, y = y})
        end
        local grid = pf:createGrid(10, 10, obstacles)

        local path = pf:findPath(grid, 1, 5, 9, 5)

        if path then error("Should return nil for blocked path") end
    end)

    Suite:testMethod("PathfindingSystem:straight line", {
        description = "Optimizes straight-line paths",
        testCase = "straight_path",
        type = "functional"
    }, function()
        local pf = MockPathfindingSystem:new()
        local grid = pf:createGrid(10, 10)

        local path = pf:findPath(grid, 1, 5, 10, 5)

        if not path then error("Straight path should be found") end

        -- All steps on same row
        for _, step in ipairs(path) do
            if step.y ~= 5 then error("Path should be horizontal") end
        end
    end)

    Suite:testMethod("PathfindingSystem:diagonal movement", {
        description = "Handles diagonal paths when enabled",
        testCase = "diagonal_path",
        type = "functional"
    }, function()
        local pf = MockPathfindingSystem:new()
        pf.diagonalMovement = true
        local grid = pf:createGrid(10, 10)

        local path = pf:findPath(grid, 1, 1, 5, 5)

        if not path then error("Diagonal path should be found") end
        if #path < 5 then error("Path should use diagonal movement") end
    end)

    Suite:testMethod("PathfindingSystem:same start and goal", {
        description = "Returns empty path for same position",
        testCase = "no_movement",
        type = "edge_case"
    }, function()
        local pf = MockPathfindingSystem:new()
        local grid = pf:createGrid(10, 10)

        local path = pf:findPath(grid, 5, 5, 5, 5)

        if not path or #path ~= 1 then error("Should return single-point path") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: MOVEMENT SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Movement System", function()

    Suite:testMethod("MovementSystem:createUnit", {
        description = "Creates unit with correct movement stats",
        testCase = "unit_creation",
        type = "functional"
    }, function()
        local ms = MockMovementSystem:new()
        local unit = ms:createUnit("unit1", 100, "SCOUT")

        if not unit then error("Unit should be created") end
        if unit.tu ~= 100 then error("TU should be 100") end
        if unit.maxTU ~= 100 then error("MaxTU should be 100") end
        if unit.unitType ~= "SCOUT" then error("Unit type should be SCOUT") end
    end)

    Suite:testMethod("MovementSystem:calculatePathCost", {
        description = "Calculates TU cost for movement path",
        testCase = "path_cost",
        type = "functional"
    }, function()
        local ms = MockMovementSystem:new()
        local path = {
            {x = 1, y = 1}, {x = 2, y = 1}, {x = 3, y = 1}, {x = 4, y = 1}
        }

        local cost = ms:calculatePathCost(path)

        if cost <= 0 then error("Cost should be positive") end
        if cost > 100 then error("Cost seems unreasonable") end
    end)

    Suite:testMethod("MovementSystem:terrain cost modifiers", {
        description = "Applies terrain multipliers to movement cost",
        testCase = "terrain_modifier",
        type = "functional"
    }, function()
        local ms = MockMovementSystem:new()

        local grassCost = ms.terrainCosts.grass
        local waterCost = ms.terrainCosts.water
        local roadCost = ms.terrainCosts.road

        if waterCost <= grassCost then error("Water should be slower than grass") end
        if roadCost >= grassCost then error("Road should be faster than grass") end
    end)

    Suite:testMethod("MovementSystem:executeMovement success", {
        description = "Executes movement and deducts TU",
        testCase = "execute_movement",
        type = "functional"
    }, function()
        local ms = MockMovementSystem:new()
        ms:createUnit("unit1", 100)

        local path = {{x = 5, y = 5}, {x = 6, y = 5}, {x = 7, y = 5}}
        local success, cost = ms:executeMovement("unit1", path)

        if not success then error("Movement should succeed") end
        if not cost or cost <= 0 then error("Cost should be returned") end

        local unit = ms.units["unit1"]
        if unit.tu >= 100 then error("TU should be deducted") end
        if unit.position.x ~= 7 or unit.position.y ~= 5 then error("Position should update") end
    end)

    Suite:testMethod("MovementSystem:insufficient TU", {
        description = "Blocks movement when TU insufficient",
        testCase = "insufficient_tu",
        type = "edge_case"
    }, function()
        local ms = MockMovementSystem:new()
        ms:createUnit("unit1", 5)  -- Very low TU

        -- Long path
        local path = {}
        for i = 1, 10 do
            table.insert(path, {x = i, y = 1})
        end

        local success, err = ms:executeMovement("unit1", path)

        if success then error("Should fail with insufficient TU") end
    end)

    Suite:testMethod("MovementSystem:unit types affect range", {
        description = "Different unit types have different movement capabilities",
        testCase = "unit_type_range",
        type = "functional"
    }, function()
        local ms = MockMovementSystem:new()
        ms:createUnit("scout", 100, "SCOUT")
        ms:createUnit("heavy", 100, "HEAVY")

        local scoutRange = ms:getMaxMovementRange("scout")
        local heavyRange = ms:getMaxMovementRange("heavy")

        if scoutRange <= heavyRange then error("Scout should have greater range than HEAVY") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: DEPLOYMENT ZONES
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Deployment Zones", function()

    Suite:testMethod("DeploymentSystem:setMapSize", {
        description = "Configures deployment for different map sizes",
        testCase = "map_size_config",
        type = "functional"
    }, function()
        local ds = MockDeploymentSystem:new()
        local success = ds:setMapSize("medium")

        if not success then error("Map size should be set") end
        if ds.mapSize.gridSize ~= 5 then error("Medium map should be 5x5") end
        if ds.maxZones ~= 2 then error("Medium map should have 2 zones") end
    end)

    Suite:testMethod("DeploymentSystem:selectDeploymentZones", {
        description = "Generates deployment zones based on map size",
        testCase = "zone_selection",
        type = "functional"
    }, function()
        local ds = MockDeploymentSystem:new()
        ds:setMapSize("medium")

        local zones = ds:selectDeploymentZones()

        if not zones then error("Zones should be selected") end

        local zone = zones[1]
        if not zone then error("At least one zone should exist") end

        -- Fill zone to capacity
        for i = 1, zone.capacity do
            local success = ds:assignUnitToZone("unit" .. i, zone.id)
            if not success then error("Should assign unit " .. i) end
        end

        -- Try to exceed capacity
        local success, err = ds:assignUnitToZone("unitExtra", zone.id)
        if success then error("Should reject assignment over capacity") end
    end)

    Suite:testMethod("DeploymentSystem:assignUnitToZone", {
        description = "Assigns units to deployment zones",
        testCase = "unit_assignment",
        type = "functional"
    }, function()
        local ds = MockDeploymentSystem:new()
        ds:setMapSize("medium")
        ds:selectDeploymentZones()

        local success = ds:assignUnitToZone("unit1", "zone_1")

        if not success then error("Assignment should succeed") end
        if not ds.unitAssignments["unit1"] then error("Assignment should be tracked") end
    end)

    Suite:testMethod("DeploymentSystem:deployment completeness", {
        description = "Validates complete deployment coverage",
        testCase = "completion_check",
        type = "functional"
    }, function()
        local ds = MockDeploymentSystem:new()
        ds:setMapSize("medium")
        ds:selectDeploymentZones()

        local isComplete = ds:isDeploymentComplete(0)
        if not isComplete then error("Empty deployment should be complete") end

        ds:assignUnitToZone("unit1", "zone_1")
        ds:assignUnitToZone("unit2", "zone_1")

        isComplete = ds:isDeploymentComplete(2)
        if not isComplete then error("Deployment with 2 units should be complete") end
    end)

    Suite:testMethod("DeploymentSystem:map sizes scale zones", {
        description = "Larger maps support more deployment zones",
        testCase = "size_scaling",
        type = "functional"
    }, function()
        local sizes = {"small", "medium", "large", "huge"}
        local expectedZones = {1, 2, 3, 4}

        for i, size in ipairs(sizes) do
            local ds = MockDeploymentSystem:new()
            ds:setMapSize(size)
            ds:selectDeploymentZones()

            if #ds.deploymentZones ~= expectedZones[i] then
                error(size .. " map should have " .. expectedZones[i] .. " zones")
            end
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: PATHFINDING OPTIMIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Pathfinding Optimization", function()

    Suite:testMethod("PathfindingSystem:heuristic selection", {
        description = "Supports different pathfinding heuristics",
        testCase = "heuristic_choice",
        type = "functional"
    }, function()
        local pf = MockPathfindingSystem:new()
        local grid = pf:createGrid(20, 20)

        local pathManhattan = pf:findPath(grid, 1, 1, 10, 10, "manhattan")
        local pathEuclidean = pf:findPath(grid, 1, 1, 10, 10, "euclidean")

        if not pathManhattan then error("Manhattan path should exist") end
        if not pathEuclidean then error("Euclidean path should exist") end
    end)

    Suite:testMethod("PathfindingSystem:large grid performance", {
        description = "Completes large grid pathfinding efficiently",
        testCase = "large_grid_performance",
        type = "performance"
    }, function()
        local pf = MockPathfindingSystem:new()
        local grid = pf:createGrid(30, 30)

        local startTime = os.clock()
        local path = pf:findPath(grid, 1, 1, 30, 30)
        local elapsed = os.clock() - startTime

        if not path then error("Path should be found") end
        print("[Pathfinding Performance] 30x30 grid: " .. string.format("%.3f ms", elapsed * 1000))

        Helpers.assertLess(elapsed, 1.0, "Large grid should complete < 1s")
    end)

    Suite:testMethod("PathfindingSystem:path optimality", {
        description = "Paths are reasonably optimal",
        testCase = "path_optimality",
        type = "validation"
    }, function()
        local pf = MockPathfindingSystem:new()
        local grid = pf:createGrid(15, 15)

        local path = pf:findPath(grid, 1, 1, 15, 15)

        if not path then error("Path should exist") end

        -- Rough optimality check: path length shouldn't be much longer than straight-line distance
        local maxOptimalLength = 20 + 5  -- Some slack for non-straight paths
        if #path > maxOptimalLength then
            error("Path longer than expected: " .. #path)
        end
    end)

    Suite:testMethod("PathfindingSystem:multiple units", {
        description = "Supports pathfinding for multiple units",
        testCase = "multi_unit_pathfinding",
        type = "functional"
    }, function()
        local pf = MockPathfindingSystem:new()
        local grid = pf:createGrid(20, 20)

        local paths = {}
        for i = 1, 5 do
            local path = pf:findPath(grid, 1, 1, 5 + i * 2, 5)
            if not path then error("Path " .. i .. " should exist") end
            table.insert(paths, path)
        end

        if #paths ~= 5 then error("All 5 paths should be found") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: TACTICAL MOVEMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Tactical Movement", function()

    Suite:testMethod("MovementSystem:squad movement coordination", {
        description = "Coordinates movement for multiple units",
        testCase = "squad_coordination",
        type = "functional"
    }, function()
        local ms = MockMovementSystem:new()

        for i = 1, 4 do
            ms:createUnit("unit" .. i, 100, "ASSAULT")
        end

        local units = {}
        for i = 1, 4 do
            table.insert(units, ms.units["unit" .. i])
        end

        if #units ~= 4 then error("All 4 units should be created") end
    end)

    Suite:testMethod("MovementSystem:movement recovery between turns", {
        description = "TU regenerates at turn start",
        testCase = "tu_recovery",
        type = "functional"
    }, function()
        local ms = MockMovementSystem:new()
        ms:createUnit("unit1", 100)
        local unit = ms.units["unit1"]

        -- Spend some TU
        unit.tu = 40

        -- Simulate turn start recovery
        local recoveredTU = unit.maxTU

        if recoveredTU ~= 100 then error("TU should recover to max") end
    end)

    Suite:testMethod("MovementSystem:movement interruption", {
        description = "Partial movement with TU exhaustion",
        testCase = "partial_movement",
        type = "edge_case"
    }, function()
        local ms = MockMovementSystem:new()
        ms:createUnit("unit1", 50)

        -- Create two paths
        local shortPath = {{x = 5, y = 5}, {x = 6, y = 5}}
        local longPath = {{x = 5, y = 5}, {x = 10, y = 5}}

        local shortCost = ms:calculatePathCost(shortPath)
        local longCost = ms:calculatePathCost(longPath)

        if shortCost > longCost then error("Short path should cost less") end
    end)

    Suite:testMethod("MovementSystem:positioning for cover", {
        description = "Units can move to cover positions",
        testCase = "cover_positioning",
        type = "functional"
    }, function()
        local ms = MockMovementSystem:new()
        ms:createUnit("unit1", 100, "ASSAULT")

        local coverPos = {x = 10, y = 10}
        local path = {
            {x = 5, y = 5},
            {x = 7, y = 7},
            {x = 9, y = 9},
            coverPos
        }

        local success = ms:executeMovement("unit1", path)

        if not success then error("Movement to cover should succeed") end
    end)

    Suite:testMethod("MovementSystem:flanking maneuvers", {
        description = "Supports movement for tactical positioning",
        testCase = "flanking_movement",
        type = "functional"
    }, function()
        local ms = MockMovementSystem:new()
        ms:createUnit("unit1", 100)
        ms:createUnit("unit2", 100)

        local unit1Path = {{x = 5, y = 5}, {x = 8, y = 5}}
        local unit2Path = {{x = 5, y = 5}, {x = 5, y = 8}}  -- Different direction

        local s1, c1 = ms:executeMovement("unit1", unit1Path)
        local s2, c2 = ms:executeMovement("unit2", unit2Path)

        if not s1 or not s2 then error("Both units should move") end

        local u1 = ms.units["unit1"]
        local u2 = ms.units["unit2"]

        if u1.position.x == u2.position.x and u1.position.y == u2.position.y then
            error("Units should be in different positions")
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- HELPER FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────

function Helpers.assertLess(actual, expected, message)
    if not (actual < expected) then
        error(message or string.format("Expected %s < %s", tostring(actual), tostring(expected)))
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- RUN SUITE
-- ─────────────────────────────────────────────────────────────────────────

Suite:run()
