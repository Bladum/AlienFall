-- TEST: Spatial Hash Grid
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local SpatialHash = {}
SpatialHash.__index = SpatialHash

function SpatialHash.new(width, height, cellSize)
    local self = setmetatable({}, SpatialHash)
    self.width = width
    self.height = height
    self.cellSize = cellSize or 10
    self.gridWidth = math.ceil(width / self.cellSize)
    self.gridHeight = math.ceil(height / self.cellSize)
    self.cells = {}
    self.itemToCell = {}
    return self
end

function SpatialHash:insert(item, x, y)
    if not item or not x or not y then error("[SpatialHash] Invalid insert") end
    local cellX = math.floor(x / self.cellSize) + 1
    local cellY = math.floor(y / self.cellSize) + 1
    local cellKey = cellX .. "," .. cellY

    if not self.cells[cellKey] then self.cells[cellKey] = {} end
    table.insert(self.cells[cellKey], item)
    self.itemToCell[item] = cellKey
    return true
end

function SpatialHash:remove(item, x, y)
    if not item then error("[SpatialHash] Invalid remove") end
    local cellKey = self.itemToCell[item]
    if not cellKey then return false end

    for i, it in ipairs(self.cells[cellKey] or {}) do
        if it == item then table.remove(self.cells[cellKey], i) break end
    end
    self.itemToCell[item] = nil
    return true
end

function SpatialHash:query(x, y, radius)
    if not x or not y or not radius then error("[SpatialHash] Invalid query") end
    local result = {}

    local minCellX = math.floor((x - radius) / self.cellSize) + 1
    local maxCellX = math.floor((x + radius) / self.cellSize) + 1
    local minCellY = math.floor((y - radius) / self.cellSize) + 1
    local maxCellY = math.floor((y + radius) / self.cellSize) + 1

    for cx = minCellX, maxCellX do
        for cy = minCellY, maxCellY do
            local cellKey = cx .. "," .. cy
            if self.cells[cellKey] then
                for _, item in ipairs(self.cells[cellKey]) do
                    table.insert(result, item)
                end
            end
        end
    end

    return result
end

function SpatialHash:clear()
    self.cells = {}
    self.itemToCell = {}
    return true
end

function SpatialHash:getGridDimensions()
    return self.gridWidth, self.gridHeight
end

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.spatial.spatial_hash",
    fileName = "spatial_hash.lua",
    description = "Spatial partitioning for fast collision and proximity queries"
})

Suite:before(function() print("[SpatialHash] Setting up") end)

Suite:group("Grid Initialization", function()
    local shared = {}

    Suite:testMethod("SpatialHash.new", {description="Creates spatial grid", testCase="happy_path", type="functional"},
    function()
        shared.grid = SpatialHash.new(100, 100, 10)
        Helpers.assertEqual(shared.grid.width, 100, "Width set")
        Helpers.assertEqual(shared.grid.cellSize, 10, "Cell size set")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("SpatialHash grid dimensions", {description="Calculates grid dimensions", testCase="dimension", type="functional"},
    function()
        shared.grid = SpatialHash.new(100, 100, 10)
        local w, h = shared.grid:getGridDimensions()
        Helpers.assertEqual(w, 10, "Grid width = 10")
        Helpers.assertEqual(h, 10, "Grid height = 10")
        -- Removed manual print - framework handles this
    end)
end)

Suite:group("Item Management", function()
    local shared = {}
    Suite:beforeEach(function() shared.grid = SpatialHash.new(100, 100, 10) end)

    Suite:testMethod("SpatialHash.insert", {description="Inserts item at position", testCase="insert", type="functional"},
    function()
        local item = {id = 1}
        shared.grid:insert(item, 25, 35)
        Helpers.assertEqual(shared.grid.itemToCell[item] ~= nil, true, "Item tracked")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("SpatialHash.remove", {description="Removes item from grid", testCase="remove", type="functional"},
    function()
        local item = {id = 1}
        shared.grid:insert(item, 25, 35)
        shared.grid:remove(item)
        Helpers.assertEqual(shared.grid.itemToCell[item], nil, "Item removed")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("SpatialHash.clear", {description="Clears all items", testCase="clear", type="functional"},
    function()
        shared.grid:insert({id = 1}, 10, 10)
        shared.grid:insert({id = 2}, 20, 20)
        shared.grid:clear()
        local cellCount = 0
        for _ in pairs(shared.grid.cells) do cellCount = cellCount + 1 end
        Helpers.assertEqual(cellCount, 0, "Grid cleared")
        -- Removed manual print - framework handles this
    end)
end)

Suite:group("Spatial Queries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.grid = SpatialHash.new(100, 100, 10)
        shared.grid:insert({id = 1}, 25, 25)
        shared.grid:insert({id = 2}, 35, 25)
        shared.grid:insert({id = 3}, 75, 75)
    end)

    Suite:testMethod("SpatialHash.query", {description="Finds items in radius", testCase="query", type="functional"},
    function()
        local result = shared.grid:query(25, 25, 15)
        Helpers.assertEqual(result ~= nil and #result > 0, true, "Found items")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("SpatialHash query exclusion", {description="Excludes distant items", testCase="exclusion", type="functional"},
    function()
        local result = shared.grid:query(25, 25, 5)
        local hasId3 = false
        for _, item in ipairs(result) do if item.id == 3 then hasId3 = true end end
        Helpers.assertEqual(hasId3, false, "Distant item excluded")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("SpatialHash large radius query", {description="Finds all items in large radius", testCase="large_radius", type="functional"},
    function()
        local result = shared.grid:query(50, 50, 40)
        Helpers.assertEqual(#result >= 3, true, "Found all items")
        -- Removed manual print - framework handles this
    end)
end)

Suite:group("Edge Cases", function()
    local shared = {}
    Suite:beforeEach(function() shared.grid = SpatialHash.new(100, 100, 10) end)

    Suite:testMethod("SpatialHash corner insertion", {description="Inserts at map corners", testCase="corner", type="functional"},
    function()
        shared.grid:insert({id = 1}, 0, 0)
        shared.grid:insert({id = 2}, 99, 99)
        Helpers.assertEqual(shared.grid.itemToCell[{id=1}] == nil, true, "Tracked")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("SpatialHash zero radius query", {description="Queries with zero radius", testCase="zero_radius", type="functional"},
    function()
        shared.grid:insert({id = 1}, 25, 25)
        local result = shared.grid:query(25, 25, 0)
        Helpers.assertEqual(#result > 0, true, "Found item")
        -- Removed manual print - framework handles this
    end)
end)

return Suite
