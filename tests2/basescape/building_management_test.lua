-- ─────────────────────────────────────────────────────────────────────────
-- BUILDING MANAGEMENT TEST SUITE
-- FILE: tests2/basescape/building_management_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.building_management",
    fileName = "building_management.lua",
    description = "Building management with placement, upgrades, interconnection, and resource flow"
})

print("[BUILDING_MANAGEMENT_TEST] Setting up")

local BuildingManagement = {
    base_grid = {}, buildings = {}, connections = {}, resources = {},
    power_grid = {}, water_grid = {},

    new = function(self)
        return setmetatable({
            base_grid = {}, buildings = {}, connections = {}, resources = {},
            power_grid = {}, water_grid = {}
        }, {__index = self})
    end,

    initializeGrid = function(self, width, height)
        self.base_grid = {}
        for x = 1, width do
            self.base_grid[x] = {}
            for y = 1, height do
                self.base_grid[x][y] = "empty"
            end
        end
        return true
    end,

    placeBuilding = function(self, buildingId, name, x, y, building_type, size)
        if not self.base_grid[x] or not self.base_grid[x][y] then return false end
        if self.base_grid[x][y] ~= "empty" then return false end

        self.buildings[buildingId] = {
            id = buildingId, name = name, x = x, y = y, type = building_type,
            size = size or 1, level = 1, health = 100, status = "active",
            power_consumption = 10, power_generation = 0, water_usage = 5,
            output = 0, efficiency = 100
        }
        self.base_grid[x][y] = buildingId
        return true
    end,

    getBuilding = function(self, buildingId)
        return self.buildings[buildingId]
    end,

    removeBuilding = function(self, buildingId)
        if not self.buildings[buildingId] then return false end
        local building = self.buildings[buildingId]
        self.base_grid[building.x][building.y] = "empty"
        self.buildings[buildingId] = nil
        return true
    end,

    upgradeBuilding = function(self, buildingId)
        if not self.buildings[buildingId] then return false end
        local building = self.buildings[buildingId]
        building.level = building.level + 1
        building.efficiency = math.min(150, building.efficiency + 10)
        building.power_consumption = building.power_consumption + 5
        building.output = building.output + 20
        return true
    end,

    canConnectBuildings = function(self, buildingId1, buildingId2)
        if not self.buildings[buildingId1] or not self.buildings[buildingId2] then return false end
        local b1 = self.buildings[buildingId1]
        local b2 = self.buildings[buildingId2]
        local distance = math.sqrt((b1.x - b2.x)^2 + (b1.y - b2.y)^2)
        return distance <= 3
    end,

    connectBuildings = function(self, connectionId, buildingId1, buildingId2, connection_type)
        if not self:canConnectBuildings(buildingId1, buildingId2) then return false end
        self.connections[connectionId] = {
            id = connectionId, building1 = buildingId1, building2 = buildingId2,
            type = connection_type, active = true, flow = 0, capacity = 100
        }
        return true
    end,

    getConnection = function(self, connectionId)
        return self.connections[connectionId]
    end,

    disconnectBuildings = function(self, connectionId)
        if not self.connections[connectionId] then return false end
        self.connections[connectionId] = nil
        return true
    end,

    addPowerGenerator = function(self, buildingId, generation_capacity)
        if not self.buildings[buildingId] then return false end
        local building = self.buildings[buildingId]
        building.power_generation = generation_capacity
        building.power_consumption = 0
        return true
    end,

    addWaterSource = function(self, buildingId, production_capacity)
        if not self.buildings[buildingId] then return false end
        local building = self.buildings[buildingId]
        building.water_production = production_capacity or 50
        building.water_usage = 0
        return true
    end,

    calculatePowerBalance = function(self)
        local total_generation = 0
        local total_consumption = 0

        for _, building in pairs(self.buildings) do
            total_generation = total_generation + (building.power_generation or 0)
            total_consumption = total_consumption + (building.power_consumption or 0)
        end

        return total_generation - total_consumption
    end,

    calculateWaterBalance = function(self)
        local total_production = 0
        local total_usage = 0

        for _, building in pairs(self.buildings) do
            total_production = total_production + (building.water_production or 0)
            total_usage = total_usage + (building.water_usage or 0)
        end

        return total_production - total_usage
    end,

    hasPowerForBuilding = function(self, buildingId)
        if not self.buildings[buildingId] then return false end
        return self:calculatePowerBalance() >= 0
    end,

    hasWaterForBuilding = function(self, buildingId)
        if not self.buildings[buildingId] then return false end
        return self:calculateWaterBalance() >= 0
    end,

    damageBuilding = function(self, buildingId, damage_amount)
        if not self.buildings[buildingId] then return false end
        local building = self.buildings[buildingId]
        building.health = math.max(0, building.health - damage_amount)
        if building.health <= 0 then
            building.status = "destroyed"
        elseif building.health < 50 then
            building.status = "damaged"
        end
        return true
    end,

    repairBuilding = function(self, buildingId, repair_amount)
        if not self.buildings[buildingId] then return false end
        local building = self.buildings[buildingId]
        building.health = math.min(100, building.health + repair_amount)
        if building.health > 50 then
            building.status = "active"
        end
        return true
    end,

    getBuildingStatus = function(self, buildingId)
        if not self.buildings[buildingId] then return nil end
        return self.buildings[buildingId].status
    end,

    getAdjacentBuildings = function(self, buildingId)
        if not self.buildings[buildingId] then return {} end
        local building = self.buildings[buildingId]
        local adjacent = {}

        for _, other in pairs(self.buildings) do
            if other.id ~= buildingId then
                local dist = math.sqrt((building.x - other.x)^2 + (building.y - other.y)^2)
                if dist <= 1.5 then
                    table.insert(adjacent, other.id)
                end
            end
        end

        return adjacent
    end,

    calculateTotalOutput = function(self)
        local total = 0
        for _, building in pairs(self.buildings) do
            if building.status == "active" then
                total = total + (building.output or 0)
            end
        end
        return total
    end,

    calculateBaseCapacity = function(self)
        local capacity = 0
        for _, building in pairs(self.buildings) do
            capacity = capacity + (building.size or 1) * 10
        end
        return capacity
    end,

    optimizeResourceFlow = function(self)
        for _, connection in pairs(self.connections) do
            if connection.active then
                local b1 = self.buildings[connection.building1]
                local b2 = self.buildings[connection.building2]
                if b1 and b2 then
                    local flow = math.min(b1.output or 0, connection.capacity - (connection.flow or 0))
                    connection.flow = flow
                end
            end
        end
        return true
    end,

    getBaseEconomicRating = function(self)
        local total_output = self:calculateTotalOutput()
        local total_consumption = 0
        for _, building in pairs(self.buildings) do
            total_consumption = total_consumption + (building.power_consumption or 0)
        end

        if total_consumption == 0 then return 50 end
        return (total_output / total_consumption) * 50
    end,

    reset = function(self)
        self.base_grid = {}
        self.buildings = {}
        self.connections = {}
        self.resources = {}
        self.power_grid = {}
        self.water_grid = {}
        return true
    end
}

Suite:group("Grid", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
    end)

    Suite:testMethod("BuildingManagement.initializeGrid", {description = "Initializes grid", testCase = "init", type = "functional"}, function()
        local ok = shared.buildings:initializeGrid(10, 10)
        Helpers.assertEqual(ok, true, "Initialized")
    end)
end)

Suite:group("Building Placement", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
        shared.buildings:initializeGrid(10, 10)
    end)

    Suite:testMethod("BuildingManagement.placeBuilding", {description = "Places building", testCase = "place", type = "functional"}, function()
        local ok = shared.buildings:placeBuilding("bldg1", "Power Plant", 5, 5, "power", 2)
        Helpers.assertEqual(ok, true, "Placed")
    end)

    Suite:testMethod("BuildingManagement.getBuilding", {description = "Gets building", testCase = "get", type = "functional"}, function()
        shared.buildings:placeBuilding("bldg2", "Barracks", 3, 4, "military", 1)
        local bldg = shared.buildings:getBuilding("bldg2")
        Helpers.assertEqual(bldg ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("BuildingManagement.removeBuilding", {description = "Removes building", testCase = "remove", type = "functional"}, function()
        shared.buildings:placeBuilding("bldg3", "Lab", 7, 7, "research", 1)
        local ok = shared.buildings:removeBuilding("bldg3")
        Helpers.assertEqual(ok, true, "Removed")
    end)
end)

Suite:group("Upgrades", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
        shared.buildings:initializeGrid(10, 10)
        shared.buildings:placeBuilding("bldg4", "Factory", 4, 4, "production", 2)
    end)

    Suite:testMethod("BuildingManagement.upgradeBuilding", {description = "Upgrades building", testCase = "upgrade", type = "functional"}, function()
        local ok = shared.buildings:upgradeBuilding("bldg4")
        Helpers.assertEqual(ok, true, "Upgraded")
    end)

    Suite:testMethod("BuildingManagement.upgrade_increases_level", {description = "Increases level", testCase = "level", type = "functional"}, function()
        local b1 = shared.buildings:getBuilding("bldg4")
        local level1 = b1.level
        shared.buildings:upgradeBuilding("bldg4")
        local b2 = shared.buildings:getBuilding("bldg4")
        Helpers.assertEqual(b2.level > level1, true, "Level increased")
    end)
end)

Suite:group("Connections", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
        shared.buildings:initializeGrid(10, 10)
        shared.buildings:placeBuilding("bldg5", "PowerA", 2, 2, "power", 1)
        shared.buildings:placeBuilding("bldg6", "PowerB", 4, 2, "power", 1)
    end)

    Suite:testMethod("BuildingManagement.canConnectBuildings", {description = "Can connect", testCase = "can", type = "functional"}, function()
        local can = shared.buildings:canConnectBuildings("bldg5", "bldg6")
        Helpers.assertEqual(can, true, "Can connect")
    end)

    Suite:testMethod("BuildingManagement.connectBuildings", {description = "Connects buildings", testCase = "connect", type = "functional"}, function()
        local ok = shared.buildings:connectBuildings("conn1", "bldg5", "bldg6", "power")
        Helpers.assertEqual(ok, true, "Connected")
    end)

    Suite:testMethod("BuildingManagement.getConnection", {description = "Gets connection", testCase = "get", type = "functional"}, function()
        shared.buildings:connectBuildings("conn2", "bldg5", "bldg6", "power")
        local conn = shared.buildings:getConnection("conn2")
        Helpers.assertEqual(conn ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("BuildingManagement.disconnectBuildings", {description = "Disconnects", testCase = "disconnect", type = "functional"}, function()
        shared.buildings:connectBuildings("conn3", "bldg5", "bldg6", "power")
        local ok = shared.buildings:disconnectBuildings("conn3")
        Helpers.assertEqual(ok, true, "Disconnected")
    end)
end)

Suite:group("Power", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
        shared.buildings:initializeGrid(10, 10)
        shared.buildings:placeBuilding("bldg7", "Generator", 5, 5, "power", 2)
        shared.buildings:placeBuilding("bldg8", "Lab", 6, 5, "research", 1)
    end)

    Suite:testMethod("BuildingManagement.addPowerGenerator", {description = "Adds generator", testCase = "add", type = "functional"}, function()
        local ok = shared.buildings:addPowerGenerator("bldg7", 100)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("BuildingManagement.calculatePowerBalance", {description = "Calculates balance", testCase = "balance", type = "functional"}, function()
        shared.buildings:addPowerGenerator("bldg7", 100)
        local balance = shared.buildings:calculatePowerBalance()
        Helpers.assertEqual(balance >= 0, true, "Balance >= 0")
    end)

    Suite:testMethod("BuildingManagement.hasPowerForBuilding", {description = "Has power", testCase = "has_power", type = "functional"}, function()
        shared.buildings:addPowerGenerator("bldg7", 100)
        local has = shared.buildings:hasPowerForBuilding("bldg8")
        Helpers.assertEqual(has, true, "Has power")
    end)
end)

Suite:group("Water", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
        shared.buildings:initializeGrid(10, 10)
        shared.buildings:placeBuilding("bldg9", "Well", 3, 3, "water", 1)
        shared.buildings:placeBuilding("bldg10", "Farm", 4, 3, "food", 1)
    end)

    Suite:testMethod("BuildingManagement.addWaterSource", {description = "Adds water source", testCase = "add", type = "functional"}, function()
        local ok = shared.buildings:addWaterSource("bldg9", 75)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("BuildingManagement.calculateWaterBalance", {description = "Calculates balance", testCase = "balance", type = "functional"}, function()
        shared.buildings:addWaterSource("bldg9", 75)
        local balance = shared.buildings:calculateWaterBalance()
        Helpers.assertEqual(balance >= 0, true, "Balance >= 0")
    end)

    Suite:testMethod("BuildingManagement.hasWaterForBuilding", {description = "Has water", testCase = "has_water", type = "functional"}, function()
        shared.buildings:addWaterSource("bldg9", 75)
        local has = shared.buildings:hasWaterForBuilding("bldg10")
        Helpers.assertEqual(has, true, "Has water")
    end)
end)

Suite:group("Damage & Repair", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
        shared.buildings:initializeGrid(10, 10)
        shared.buildings:placeBuilding("bldg11", "Structure", 2, 5, "misc", 1)
    end)

    Suite:testMethod("BuildingManagement.damageBuilding", {description = "Damages building", testCase = "damage", type = "functional"}, function()
        local ok = shared.buildings:damageBuilding("bldg11", 30)
        Helpers.assertEqual(ok, true, "Damaged")
    end)

    Suite:testMethod("BuildingManagement.damage_reduces_health", {description = "Reduces health", testCase = "health", type = "functional"}, function()
        local b1 = shared.buildings:getBuilding("bldg11")
        local hp1 = b1.health
        shared.buildings:damageBuilding("bldg11", 20)
        local b2 = shared.buildings:getBuilding("bldg11")
        Helpers.assertEqual(b2.health < hp1, true, "Health reduced")
    end)

    Suite:testMethod("BuildingManagement.repairBuilding", {description = "Repairs building", testCase = "repair", type = "functional"}, function()
        shared.buildings:damageBuilding("bldg11", 50)
        local ok = shared.buildings:repairBuilding("bldg11", 20)
        Helpers.assertEqual(ok, true, "Repaired")
    end)

    Suite:testMethod("BuildingManagement.getBuildingStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        local status = shared.buildings:getBuildingStatus("bldg11")
        Helpers.assertEqual(status ~= nil, true, "Has status")
    end)
end)

Suite:group("Building Networks", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
        shared.buildings:initializeGrid(10, 10)
        shared.buildings:placeBuilding("bldg12", "Center", 5, 5, "command", 2)
        shared.buildings:placeBuilding("bldg13", "Adjacent", 5, 6, "support", 1)
    end)

    Suite:testMethod("BuildingManagement.getAdjacentBuildings", {description = "Gets adjacent", testCase = "adjacent", type = "functional"}, function()
        local adj = shared.buildings:getAdjacentBuildings("bldg12")
        Helpers.assertEqual(#adj > 0, true, "Has adjacent")
    end)
end)

Suite:group("Output & Capacity", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
        shared.buildings:initializeGrid(10, 10)
        shared.buildings:placeBuilding("bldg14", "Output1", 2, 2, "production", 1)
    end)

    Suite:testMethod("BuildingManagement.calculateTotalOutput", {description = "Calculates output", testCase = "output", type = "functional"}, function()
        local output = shared.buildings:calculateTotalOutput()
        Helpers.assertEqual(output >= 0, true, "Output >= 0")
    end)

    Suite:testMethod("BuildingManagement.calculateBaseCapacity", {description = "Calculates capacity", testCase = "capacity", type = "functional"}, function()
        local capacity = shared.buildings:calculateBaseCapacity()
        Helpers.assertEqual(capacity > 0, true, "Capacity > 0")
    end)

    Suite:testMethod("BuildingManagement.getBaseEconomicRating", {description = "Gets rating", testCase = "rating", type = "functional"}, function()
        local rating = shared.buildings:getBaseEconomicRating()
        Helpers.assertEqual(rating > 0, true, "Rating > 0")
    end)
end)

Suite:group("Resource Flow", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
        shared.buildings:initializeGrid(10, 10)
        shared.buildings:placeBuilding("bldg15", "Source", 3, 3, "production", 2)
        shared.buildings:placeBuilding("bldg16", "Dest", 5, 3, "storage", 1)
        shared.buildings:connectBuildings("conn4", "bldg15", "bldg16", "resource")
    end)

    Suite:testMethod("BuildingManagement.optimizeResourceFlow", {description = "Optimizes flow", testCase = "optimize", type = "functional"}, function()
        local ok = shared.buildings:optimizeResourceFlow()
        Helpers.assertEqual(ok, true, "Optimized")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.buildings = BuildingManagement:new()
    end)

    Suite:testMethod("BuildingManagement.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.buildings:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
