-- ─────────────────────────────────────────────────────────────────────────
-- BASE CONSTRUCTOR TEST SUITE
-- FILE: tests2/basescape/base_constructor_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.base_constructor",
    fileName = "base_constructor.lua",
    description = "Base construction with grid placement, facility interconnection, and adjacency bonuses"
})

print("[BASE_CONSTRUCTOR_TEST] Setting up")

local BaseConstructor = {
    bases = {},
    grid = {},
    facilities = {},
    connections = {},

    new = function(self)
        return setmetatable({bases = {}, grid = {}, facilities = {}, connections = {}}, {__index = self})
    end,

    createBase = function(self, baseId, name, gridWidth, gridHeight)
        self.bases[baseId] = {id = baseId, name = name, width = gridWidth, height = gridHeight, facilitiesCount = 0}
        self.grid[baseId] = {}
        self.facilities[baseId] = {}
        self.connections[baseId] = {}
        for x = 1, gridWidth do
            self.grid[baseId][x] = {}
            for y = 1, gridHeight do
                self.grid[baseId][x][y] = nil
            end
        end
        return true
    end,

    getBase = function(self, baseId)
        return self.bases[baseId]
    end,

    placeFacility = function(self, baseId, facilityId, x, y, facilityType, power, capacity)
        if not self.bases[baseId] or not self.grid[baseId][x] or not self.grid[baseId][x][y] then return false end
        if self.grid[baseId][x][y] ~= nil then return false end
        self.grid[baseId][x][y] = facilityId
        self.facilities[baseId][facilityId] = {id = facilityId, type = facilityType, x = x, y = y, power = power or 10, capacity = capacity or 100, operational = true}
        self.bases[baseId].facilitiesCount = self.bases[baseId].facilitiesCount + 1
        return true
    end,

    getFacility = function(self, baseId, facilityId)
        if not self.facilities[baseId] then return nil end
        return self.facilities[baseId][facilityId]
    end,

    removeFacility = function(self, baseId, facilityId)
        if not self.facilities[baseId] or not self.facilities[baseId][facilityId] then return false end
        local facility = self.facilities[baseId][facilityId]
        self.grid[baseId][facility.x][facility.y] = nil
        self.facilities[baseId][facilityId] = nil
        self.bases[baseId].facilitiesCount = self.bases[baseId].facilitiesCount - 1
        return true
    end,

    getFacilityCount = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        return self.bases[baseId].facilitiesCount
    end,

    getAdjacentFacilities = function(self, baseId, x, y)
        if not self.grid[baseId] then return {} end
        local adjacent = {}
        for dx = -1, 1 do
            for dy = -1, 1 do
                if dx ~= 0 or dy ~= 0 then
                    local nx, ny = x + dx, y + dy
                    if self.grid[baseId][nx] and self.grid[baseId][nx][ny] then
                        table.insert(adjacent, self.grid[baseId][nx][ny])
                    end
                end
            end
        end
        return adjacent
    end,

    connectFacilities = function(self, baseId, facilityId1, facilityId2)
        if not self.facilities[baseId][facilityId1] or not self.facilities[baseId][facilityId2] then return false end
        if not self.connections[baseId] then self.connections[baseId] = {} end
        local connectionId = facilityId1 .. "_" .. facilityId2
        self.connections[baseId][connectionId] = {from = facilityId1, to = facilityId2, active = true}
        return true
    end,

    getConnectionCount = function(self, baseId)
        if not self.connections[baseId] then return 0 end
        local count = 0
        for _ in pairs(self.connections[baseId]) do count = count + 1 end
        return count
    end,

    calculateAdjacencyBonus = function(self, baseId, facilityId)
        if not self.facilities[baseId] or not self.facilities[baseId][facilityId] then return 0 end
        local facility = self.facilities[baseId][facilityId]
        local adjacent = self:getAdjacentFacilities(baseId, facility.x, facility.y)
        local bonusPerAdjacent = 5
        return #adjacent * bonusPerAdjacent
    end,

    getTotalPowerRequirement = function(self, baseId)
        if not self.facilities[baseId] then return 0 end
        local total = 0
        for _, facility in pairs(self.facilities[baseId]) do
            if facility.operational then
                total = total + facility.power
            end
        end
        return total
    end,

    getTotalCapacity = function(self, baseId)
        if not self.facilities[baseId] then return 0 end
        local total = 0
        for _, facility in pairs(self.facilities[baseId]) do
            total = total + facility.capacity
        end
        return total
    end,

    isGridPositionValid = function(self, baseId, x, y)
        if not self.grid[baseId] then return false end
        return self.grid[baseId][x] and self.grid[baseId][x][y] ~= nil
    end,

    setFacilityOperational = function(self, baseId, facilityId, operational)
        if not self.facilities[baseId] or not self.facilities[baseId][facilityId] then return false end
        self.facilities[baseId][facilityId].operational = operational
        return true
    end,

    isFacilityOperational = function(self, baseId, facilityId)
        if not self.facilities[baseId] or not self.facilities[baseId][facilityId] then return false end
        return self.facilities[baseId][facilityId].operational
    end,

    getBaseArea = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        return self.bases[baseId].width * self.bases[baseId].height
    end,

    calculateUtilization = function(self, baseId)
        if not self.bases[baseId] then return 0 end
        local area = self:getBaseArea(baseId)
        if area == 0 then return 0 end
        local facilities = self:getFacilityCount(baseId)
        return math.floor((facilities / area) * 100)
    end,

    canPlaceFacility = function(self, baseId, x, y)
        if not self.bases[baseId] then return false end
        if x < 1 or x > self.bases[baseId].width or y < 1 or y > self.bases[baseId].height then return false end
        return self.grid[baseId][x][y] == nil
    end,

    getConnectedFacilities = function(self, baseId, facilityId)
        if not self.connections[baseId] then return {} end
        local connected = {}
        for _, conn in pairs(self.connections[baseId]) do
            if conn.from == facilityId then
                table.insert(connected, conn.to)
            elseif conn.to == facilityId then
                table.insert(connected, conn.from)
            end
        end
        return connected
    end
}

Suite:group("Base Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bc = BaseConstructor:new()
    end)

    Suite:testMethod("BaseConstructor.createBase", {description = "Creates base", testCase = "create", type = "functional"}, function()
        local ok = shared.bc:createBase("base1", "Main Base", 10, 10)
        Helpers.assertEqual(ok, true, "Base created")
    end)

    Suite:testMethod("BaseConstructor.getBase", {description = "Retrieves base", testCase = "get", type = "functional"}, function()
        shared.bc:createBase("base2", "Secondary Base", 8, 8)
        local base = shared.bc:getBase("base2")
        Helpers.assertEqual(base ~= nil, true, "Base retrieved")
    end)

    Suite:testMethod("BaseConstructor.getBaseArea", {description = "Gets area", testCase = "area", type = "functional"}, function()
        shared.bc:createBase("base3", "Test Base", 12, 15)
        local area = shared.bc:getBaseArea("base3")
        Helpers.assertEqual(area, 180, "180 area")
    end)
end)

Suite:group("Facility Placement", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bc = BaseConstructor:new()
        shared.bc:createBase("construction", "Build Base", 10, 10)
    end)

    Suite:testMethod("BaseConstructor.placeFacility", {description = "Places facility", testCase = "place", type = "functional"}, function()
        local ok = shared.bc:placeFacility("construction", "fac1", 5, 5, "command_center", 20, 100)
        Helpers.assertEqual(ok, true, "Facility placed")
    end)

    Suite:testMethod("BaseConstructor.getFacility", {description = "Gets facility", testCase = "get", type = "functional"}, function()
        shared.bc:placeFacility("construction", "fac2", 3, 3, "workshop", 15, 80)
        local facility = shared.bc:getFacility("construction", "fac2")
        Helpers.assertEqual(facility ~= nil, true, "Facility retrieved")
    end)

    Suite:testMethod("BaseConstructor.getFacilityCount", {description = "Counts facilities", testCase = "count", type = "functional"}, function()
        shared.bc:placeFacility("construction", "f1", 1, 1, "type1", 10, 50)
        shared.bc:placeFacility("construction", "f2", 2, 2, "type2", 15, 60)
        shared.bc:placeFacility("construction", "f3", 3, 3, "type3", 20, 70)
        local count = shared.bc:getFacilityCount("construction")
        Helpers.assertEqual(count, 3, "Three facilities")
    end)

    Suite:testMethod("BaseConstructor.removeFacility", {description = "Removes facility", testCase = "remove", type = "functional"}, function()
        shared.bc:placeFacility("construction", "to_remove", 4, 4, "temp", 10, 50)
        local ok = shared.bc:removeFacility("construction", "to_remove")
        Helpers.assertEqual(ok, true, "Facility removed")
    end)
end)

Suite:group("Grid Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bc = BaseConstructor:new()
        shared.bc:createBase("grid", "Grid Test", 8, 8)
    end)

    Suite:testMethod("BaseConstructor.canPlaceFacility", {description = "Can place", testCase = "can_place", type = "functional"}, function()
        local can = shared.bc:canPlaceFacility("grid", 4, 4)
        Helpers.assertEqual(can, true, "Can place")
    end)

    Suite:testMethod("BaseConstructor.canPlaceFacility", {description = "Blocks occupied", testCase = "occupied", type = "functional"}, function()
        shared.bc:placeFacility("grid", "occupier", 5, 5, "type", 10, 50)
        local can = shared.bc:canPlaceFacility("grid", 5, 5)
        Helpers.assertEqual(can, false, "Cannot place")
    end)
end)

Suite:group("Adjacency", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bc = BaseConstructor:new()
        shared.bc:createBase("adjacent", "Adjacent Test", 10, 10)
        shared.bc:placeFacility("adjacent", "center", 5, 5, "hub", 25, 150)
        shared.bc:placeFacility("adjacent", "north", 5, 4, "type1", 10, 50)
        shared.bc:placeFacility("adjacent", "south", 5, 6, "type2", 10, 50)
    end)

    Suite:testMethod("BaseConstructor.getAdjacentFacilities", {description = "Gets adjacent", testCase = "adjacent", type = "functional"}, function()
        local adjacent = shared.bc:getAdjacentFacilities("adjacent", 5, 5)
        Helpers.assertEqual(#adjacent, 2, "Two adjacent")
    end)

    Suite:testMethod("BaseConstructor.calculateAdjacencyBonus", {description = "Calculates bonus", testCase = "bonus", type = "functional"}, function()
        local bonus = shared.bc:calculateAdjacencyBonus("adjacent", "center")
        Helpers.assertEqual(bonus, 10, "10 bonus")
    end)
end)

Suite:group("Connections", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bc = BaseConstructor:new()
        shared.bc:createBase("connected", "Connection Test", 10, 10)
        shared.bc:placeFacility("connected", "src", 3, 3, "source", 15, 100)
        shared.bc:placeFacility("connected", "dst", 7, 7, "destination", 15, 100)
    end)

    Suite:testMethod("BaseConstructor.connectFacilities", {description = "Connects facilities", testCase = "connect", type = "functional"}, function()
        local ok = shared.bc:connectFacilities("connected", "src", "dst")
        Helpers.assertEqual(ok, true, "Connected")
    end)

    Suite:testMethod("BaseConstructor.getConnectionCount", {description = "Counts connections", testCase = "conn_count", type = "functional"}, function()
        shared.bc:connectFacilities("connected", "src", "dst")
        local count = shared.bc:getConnectionCount("connected")
        Helpers.assertEqual(count, 1, "One connection")
    end)

    Suite:testMethod("BaseConstructor.getConnectedFacilities", {description = "Gets connected", testCase = "get_connected", type = "functional"}, function()
        shared.bc:connectFacilities("connected", "src", "dst")
        local connected = shared.bc:getConnectedFacilities("connected", "src")
        Helpers.assertEqual(#connected, 1, "One connected")
    end)
end)

Suite:group("Power & Capacity", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bc = BaseConstructor:new()
        shared.bc:createBase("power", "Power Test", 10, 10)
        shared.bc:placeFacility("power", "p1", 1, 1, "type1", 20, 100)
        shared.bc:placeFacility("power", "p2", 2, 2, "type2", 30, 150)
    end)

    Suite:testMethod("BaseConstructor.getTotalPowerRequirement", {description = "Power req", testCase = "power", type = "functional"}, function()
        local power = shared.bc:getTotalPowerRequirement("power")
        Helpers.assertEqual(power, 50, "50 power")
    end)

    Suite:testMethod("BaseConstructor.getTotalCapacity", {description = "Total capacity", testCase = "capacity", type = "functional"}, function()
        local cap = shared.bc:getTotalCapacity("power")
        Helpers.assertEqual(cap, 250, "250 capacity")
    end)
end)

Suite:group("Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bc = BaseConstructor:new()
        shared.bc:createBase("ops", "Operations", 10, 10)
        shared.bc:placeFacility("ops", "facility", 5, 5, "test", 15, 100)
    end)

    Suite:testMethod("BaseConstructor.isFacilityOperational", {description = "Is operational", testCase = "operational", type = "functional"}, function()
        local op = shared.bc:isFacilityOperational("ops", "facility")
        Helpers.assertEqual(op, true, "Operational")
    end)

    Suite:testMethod("BaseConstructor.setFacilityOperational", {description = "Sets operational", testCase = "set_operational", type = "functional"}, function()
        local ok = shared.bc:setFacilityOperational("ops", "facility", false)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("BaseConstructor.calculateUtilization", {description = "Utilization %", testCase = "utilization", type = "functional"}, function()
        local util = shared.bc:calculateUtilization("ops")
        Helpers.assertEqual(util >= 1, true, "Calculated")
    end)
end)

Suite:run()
