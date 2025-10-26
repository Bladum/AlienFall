-- ─────────────────────────────────────────────────────────────────────────
-- MOVEMENT SYSTEM TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Tests tactical movement, TU consumption, pathfinding integration, and terrain effects
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK BATTLE MAP
-- ─────────────────────────────────────────────────────────────────────────

local BattleMap = {}
BattleMap.__index = BattleMap

function BattleMap:new(width, height)
    local self = setmetatable({}, BattleMap)
    self.width = width or 24
    self.height = height or 24
    self.tiles = {}
    -- Initialize with default terrain
    for x = 1, self.width do
        self.tiles[x] = {}
        for y = 1, self.height do
            self.tiles[x][y] = {terrain = "open", cost = 1}
        end
    end
    return self
end

function BattleMap:isValidPosition(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

function BattleMap:getTerrainCost(x, y)
    if not self:isValidPosition(x, y) then return 999 end
    return self.tiles[x][y].cost
end

function BattleMap:setTerrain(x, y, terrain, cost)
    if self:isValidPosition(x, y) then
        self.tiles[x][y] = {terrain = terrain, cost = cost}
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK PATHFINDING SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local PathfindingSystem = {}
PathfindingSystem.__index = PathfindingSystem

function PathfindingSystem:new(map)
    local self = setmetatable({}, PathfindingSystem)
    self.map = map
    return self
end

function PathfindingSystem:findPath(startX, startY, endX, endY, unit)
    -- Simple mock pathfinding - just return direct path if possible
    local path = {}
    local currentX, currentY = startX, startY
    local steps = 0
    local maxSteps = 20

    while (currentX ~= endX or currentY ~= endY) and steps < maxSteps do
        if currentX < endX then currentX = currentX + 1
        elseif currentX > endX then currentX = currentX - 1 end

        if currentY < endY then currentY = currentY + 1
        elseif currentY > endY then currentY = currentY - 1 end

        table.insert(path, {x = currentX, y = currentY})
        steps = steps + 1
    end

    return path, #path
end

function PathfindingSystem:getPathCost(path)
    local totalCost = 0
    for _, step in ipairs(path) do
        totalCost = totalCost + self.map:getTerrainCost(step.x, step.y)
    end
    return totalCost
end

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK MOVEMENT SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local MovementSystem = {}
MovementSystem.__index = MovementSystem

function MovementSystem:new(battleMap)
    local self = setmetatable({}, MovementSystem)
    self.battleMap = battleMap
    self.pathfinding = PathfindingSystem:new(battleMap)
    self.units = {}
    return self
end

function MovementSystem:registerUnit(unitId, x, y, tu)
    self.units[unitId] = {
        id = unitId,
        x = x,
        y = y,
        tu = tu or 10,
        max_tu = tu or 10,
        status = "active"
    }
    return true
end

function MovementSystem:getUnit(unitId)
    return self.units[unitId]
end

function MovementSystem:calculateMovementCost(path)
    return self.pathfinding:getPathCost(path)
end

function MovementSystem:canMoveTo(unitId, targetX, targetY)
    local unit = self.units[unitId]
    if not unit or unit.status ~= "active" then return false end

    if not self.battleMap:isValidPosition(targetX, targetY) then return false end

    local path, length = self.pathfinding:findPath(unit.x, unit.y, targetX, targetY, unit)
    if length == 0 then return false end

    local cost = self:calculateMovementCost(path)
    return unit.tu >= cost
end

function MovementSystem:moveUnit(unitId, targetX, targetY)
    local unit = self.units[unitId]
    if not unit or unit.status ~= "active" then return false, "Invalid unit" end

    if not self.battleMap:isValidPosition(targetX, targetY) then return false, "Invalid position" end

    local path, length = self.pathfinding:findPath(unit.x, unit.y, targetX, targetY, unit)
    if length == 0 then return false, "No path found" end

    local cost = self:calculateMovementCost(path)
    if unit.tu < cost then return false, "Insufficient TU" end

    -- Execute movement
    unit.x = targetX
    unit.y = targetY
    unit.tu = unit.tu - cost

    return true
end

function MovementSystem:consumeTU(unitId, amount)
    local unit = self.units[unitId]
    if not unit then return false end

    if unit.tu < amount then return false end
    unit.tu = unit.tu - amount
    return true
end

function MovementSystem:restoreTU(unitId, amount)
    local unit = self.units[unitId]
    if not unit then return false end

    unit.tu = math.min(unit.max_tu, unit.tu + amount)
    return true
end

function MovementSystem:getRemainingTU(unitId)
    local unit = self.units[unitId]
    return unit and unit.tu or 0
end

function MovementSystem:getMovementRange(unitId)
    local unit = self.units[unitId]
    if not unit then return 0 end

    -- Simple range calculation based on remaining TU
    return math.floor(unit.tu / 1)  -- 1 TU per tile
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.movement_system",
    fileName = "movement_system.lua",
    description = "Tactical movement system with TU consumption, pathfinding integration, and terrain effects"
})

Suite:before(function() print("[MovementSystemTest] Setting up") end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: SYSTEM INITIALIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("System Initialization", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.movement = MovementSystem:new(shared.map)
    end)

    Suite:testMethod("MovementSystem.new", {description="Creates movement system instance", testCase="creation", type="functional"},
    function()
        Helpers.assertEqual(shared.movement ~= nil, true, "Movement system should be created")
        Helpers.assertEqual(shared.movement.battleMap ~= nil, true, "Should have battle map reference")
        Helpers.assertEqual(shared.movement.pathfinding ~= nil, true, "Should have pathfinding system")
        Helpers.assertEqual(type(shared.movement.units), "table", "Units table should exist")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: UNIT REGISTRATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Unit Registration", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.movement = MovementSystem:new(shared.map)
    end)

    Suite:testMethod("MovementSystem.registerUnit", {description="Registers unit with position and TU", testCase="registration", type="functional"},
    function()
        local ok = shared.movement:registerUnit("unit1", 5, 5, 10)
        Helpers.assertEqual(ok, true, "Should register unit successfully")

        local unit = shared.movement:getUnit("unit1")
        Helpers.assertEqual(unit ~= nil, true, "Unit should be retrievable")
        Helpers.assertEqual(unit.x, 5, "Unit x position should be set")
        Helpers.assertEqual(unit.y, 5, "Unit y position should be set")
        Helpers.assertEqual(unit.tu, 10, "Unit TU should be set")
        Helpers.assertEqual(unit.status, "active", "Unit status should be active")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.getUnit", {description="Retrieves registered unit", testCase="retrieval", type="functional"},
    function()
        shared.movement:registerUnit("unit2", 10, 10, 8)
        local unit = shared.movement:getUnit("unit2")
        Helpers.assertEqual(unit ~= nil, true, "Should retrieve registered unit")
        Helpers.assertEqual(unit.id, "unit2", "Should return correct unit")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: TU MANAGEMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("TU Management", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.movement = MovementSystem:new(shared.map)
        shared.movement:registerUnit("unit3", 5, 5, 10)
    end)

    Suite:testMethod("MovementSystem.consumeTU", {description="Consumes TU from unit", testCase="consumption", type="functional"},
    function()
        local initialTU = shared.movement:getRemainingTU("unit3")
        local ok = shared.movement:consumeTU("unit3", 3)
        Helpers.assertEqual(ok, true, "Should consume TU successfully")
        Helpers.assertEqual(shared.movement:getRemainingTU("unit3"), initialTU - 3, "TU should be reduced by consumed amount")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.consumeTU", {description="Fails when insufficient TU", testCase="insufficient_tu", type="functional"},
    function()
        local ok = shared.movement:consumeTU("unit3", 15)
        Helpers.assertEqual(ok, false, "Should fail with insufficient TU")
        Helpers.assertEqual(shared.movement:getRemainingTU("unit3"), 10, "TU should remain unchanged")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.restoreTU", {description="Restores TU to unit", testCase="restoration", type="functional"},
    function()
        shared.movement:consumeTU("unit3", 5)
        local ok = shared.movement:restoreTU("unit3", 3)
        Helpers.assertEqual(ok, true, "Should restore TU successfully")
        Helpers.assertEqual(shared.movement:getRemainingTU("unit3"), 8, "TU should be restored")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.restoreTU", {description="Caps TU at maximum", testCase="tu_capping", type="functional"},
    function()
        local ok = shared.movement:restoreTU("unit3", 5)
        Helpers.assertEqual(ok, true, "Should restore TU successfully")
        Helpers.assertEqual(shared.movement:getRemainingTU("unit3"), 10, "TU should be capped at maximum")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: MOVEMENT VALIDATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Movement Validation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.movement = MovementSystem:new(shared.map)
        shared.movement:registerUnit("unit4", 5, 5, 10)
    end)

    Suite:testMethod("MovementSystem.canMoveTo", {description="Validates movement to valid position", testCase="valid_movement", type="functional"},
    function()
        local canMove = shared.movement:canMoveTo("unit4", 7, 7)
        Helpers.assertEqual(canMove, true, "Should allow movement to valid position within TU")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.canMoveTo", {description="Rejects movement to invalid map position", testCase="invalid_position", type="functional"},
    function()
        local canMove = shared.movement:canMoveTo("unit4", 30, 30)
        Helpers.assertEqual(canMove, false, "Should reject movement to invalid map position")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.canMoveTo", {description="Rejects movement when insufficient TU", testCase="insufficient_tu_movement", type="functional"},
    function()
        local canMove = shared.movement:canMoveTo("unit4", 20, 20)
        Helpers.assertEqual(canMove, false, "Should reject movement when insufficient TU")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.getMovementRange", {description="Calculates movement range based on TU", testCase="movement_range", type="functional"},
    function()
        local range = shared.movement:getMovementRange("unit4")
        Helpers.assertEqual(range, 10, "Should calculate range based on remaining TU")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: UNIT MOVEMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Unit Movement", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.movement = MovementSystem:new(shared.map)
        shared.movement:registerUnit("unit5", 5, 5, 10)
    end)

    Suite:testMethod("MovementSystem.moveUnit", {description="Moves unit to valid position", testCase="successful_movement", type="functional"},
    function()
        local initialTU = shared.movement:getRemainingTU("unit5")
        local ok = shared.movement:moveUnit("unit5", 7, 7)
        Helpers.assertEqual(ok, true, "Should move unit successfully")

        local unit = shared.movement:getUnit("unit5")
        Helpers.assertEqual(unit.x, 7, "Unit x position should be updated")
        Helpers.assertEqual(unit.y, 7, "Unit y position should be updated")
        Helpers.assertEqual(shared.movement:getRemainingTU("unit5") < initialTU, true, "TU should be consumed")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.moveUnit", {description="Rejects movement to invalid position", testCase="invalid_movement", type="functional"},
    function()
        local ok, error = shared.movement:moveUnit("unit5", 30, 30)
        Helpers.assertEqual(ok, false, "Should reject movement to invalid position")
        Helpers.assertEqual(error, "Invalid position", "Should return correct error message")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.moveUnit", {description="Rejects movement with insufficient TU", testCase="tu_limited_movement", type="functional"},
    function()
        local ok, error = shared.movement:moveUnit("unit5", 20, 20)
        Helpers.assertEqual(ok, false, "Should reject movement with insufficient TU")
        Helpers.assertEqual(error, "Insufficient TU", "Should return correct error message")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 6: TERRAIN EFFECTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Terrain Effects", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.movement = MovementSystem:new(shared.map)
        shared.movement:registerUnit("unit6", 5, 5, 20)
        -- Set up different terrain types
        shared.map:setTerrain(6, 5, "rough", 2)  -- Rough terrain costs 2 TU
        shared.map:setTerrain(7, 5, "difficult", 3)  -- Difficult terrain costs 3 TU
    end)

    Suite:testMethod("MovementSystem.calculateMovementCost", {description="Calculates cost considering terrain", testCase="terrain_cost", type="functional"},
    function()
        local path = {{x=6, y=5}, {x=7, y=5}}  -- Path through rough and difficult terrain
        local cost = shared.movement:calculateMovementCost(path)
        Helpers.assertEqual(cost, 5, "Should calculate total terrain cost (2 + 3)")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.moveUnit", {description="Movement cost affected by terrain", testCase="terrain_movement", type="functional"},
    function()
        local initialTU = shared.movement:getRemainingTU("unit6")
        local ok = shared.movement:moveUnit("unit6", 6, 5)  -- Through rough terrain (cost 2)
        Helpers.assertEqual(ok, true, "Should move through terrain")
        Helpers.assertEqual(shared.movement:getRemainingTU("unit6"), initialTU - 2, "TU cost should reflect terrain")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 7: PATHFINDING INTEGRATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Pathfinding Integration", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.map = BattleMap:new(24, 24)
        shared.movement = MovementSystem:new(shared.map)
        shared.movement:registerUnit("unit7", 5, 5, 15)
    end)

    Suite:testMethod("MovementSystem.moveUnit", {description="Uses pathfinding for complex movement", testCase="pathfinding_movement", type="functional"},
    function()
        local ok = shared.movement:moveUnit("unit7", 10, 10)
        Helpers.assertEqual(ok, true, "Should use pathfinding for movement")

        local unit = shared.movement:getUnit("unit7")
        Helpers.assertEqual(unit.x, 10, "Unit should reach target x")
        Helpers.assertEqual(unit.y, 10, "Unit should reach target y")
        Helpers.assertEqual(shared.movement:getRemainingTU("unit7") < 15, true, "TU should be consumed for path")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MovementSystem.canMoveTo", {description="Pathfinding validation for movement", testCase="pathfinding_validation", type="functional"},
    function()
        local canMove = shared.movement:canMoveTo("unit7", 12, 12)
        Helpers.assertEqual(canMove, true, "Should validate path exists and is affordable")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
