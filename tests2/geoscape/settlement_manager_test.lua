-- ─────────────────────────────────────────────────────────────────────────
-- SETTLEMENT MANAGER TEST SUITE
-- FILE: tests2/geoscape/settlement_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.settlement_manager",
    fileName = "settlement_manager.lua",
    description = "Geoscape settlement and base location management"
})

print("[SETTLEMENT_MANAGER_TEST] Setting up")

local SettlementManager = {
    settlements = {},
    by_faction = {},
    by_type = {},

    new = function(self)
        return setmetatable({settlements = {}, by_faction = {}, by_type = {}}, {__index = self})
    end,

    createSettlement = function(self, settlementId, name, settlementType, faction, location)
        self.settlements[settlementId] = {id = settlementId, name = name, type = settlementType, faction = faction, location = location, population = 0, defenses = 0, resources = 0}
        if not self.by_faction[faction] then self.by_faction[faction] = {} end
        table.insert(self.by_faction[faction], settlementId)
        if not self.by_type[settlementType] then self.by_type[settlementType] = {} end
        table.insert(self.by_type[settlementType], settlementId)
        return true
    end,

    getSettlement = function(self, settlementId)
        return self.settlements[settlementId]
    end,

    getSettlementCount = function(self)
        local count = 0
        for _ in pairs(self.settlements) do count = count + 1 end
        return count
    end,

    setPopulation = function(self, settlementId, population)
        if not self.settlements[settlementId] then return false end
        self.settlements[settlementId].population = math.max(0, population)
        return true
    end,

    getPopulation = function(self, settlementId)
        if not self.settlements[settlementId] then return 0 end
        return self.settlements[settlementId].population
    end,

    setDefenses = function(self, settlementId, defenseLevel)
        if not self.settlements[settlementId] then return false end
        self.settlements[settlementId].defenses = math.max(0, defenseLevel)
        return true
    end,

    getDefenses = function(self, settlementId)
        if not self.settlements[settlementId] then return 0 end
        return self.settlements[settlementId].defenses
    end,

    addResources = function(self, settlementId, amount)
        if not self.settlements[settlementId] then return false end
        self.settlements[settlementId].resources = self.settlements[settlementId].resources + amount
        return true
    end,

    getResources = function(self, settlementId)
        if not self.settlements[settlementId] then return 0 end
        return self.settlements[settlementId].resources
    end,

    getSettlementsByFaction = function(self, faction)
        return self.by_faction[faction] or {}
    end,

    getSettlementsByType = function(self, settlementType)
        return self.by_type[settlementType] or {}
    end,

    getFactionsCount = function(self)
        local count = 0
        for _ in pairs(self.by_faction) do count = count + 1 end
        return count
    end,

    getTotalPopulation = function(self)
        local total = 0
        for _, settlement in pairs(self.settlements) do
            total = total + settlement.population
        end
        return total
    end,

    destroySettlement = function(self, settlementId)
        if not self.settlements[settlementId] then return false end
        local settlement = self.settlements[settlementId]
        for i, id in ipairs(self.by_faction[settlement.faction] or {}) do
            if id == settlementId then table.remove(self.by_faction[settlement.faction], i) break end
        end
        for i, id in ipairs(self.by_type[settlement.type] or {}) do
            if id == settlementId then table.remove(self.by_type[settlement.type], i) break end
        end
        self.settlements[settlementId] = nil
        return true
    end
}

Suite:group("Settlement Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SettlementManager:new()
    end)

    Suite:testMethod("SettlementManager.new", {description = "Creates manager", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.sm ~= nil, true, "Manager created")
    end)

    Suite:testMethod("SettlementManager.createSettlement", {description = "Creates settlement", testCase = "create_settlement", type = "functional"}, function()
        local ok = shared.sm:createSettlement("city1", "New York", "city", "player", "loc_1")
        Helpers.assertEqual(ok, true, "Settlement created")
    end)

    Suite:testMethod("SettlementManager.getSettlement", {description = "Retrieves settlement", testCase = "get", type = "functional"}, function()
        shared.sm:createSettlement("city2", "London", "city", "player", "loc_2")
        local settlement = shared.sm:getSettlement("city2")
        Helpers.assertEqual(settlement ~= nil, true, "Settlement retrieved")
    end)

    Suite:testMethod("SettlementManager.getSettlement", {description = "Returns nil missing", testCase = "missing", type = "functional"}, function()
        local settlement = shared.sm:getSettlement("nonexistent")
        Helpers.assertEqual(settlement, nil, "Missing returns nil")
    end)

    Suite:testMethod("SettlementManager.getSettlementCount", {description = "Counts settlements", testCase = "count", type = "functional"}, function()
        shared.sm:createSettlement("s1", "S1", "city", "faction", "loc")
        shared.sm:createSettlement("s2", "S2", "base", "faction", "loc")
        shared.sm:createSettlement("s3", "S3", "outpost", "faction", "loc")
        local count = shared.sm:getSettlementCount()
        Helpers.assertEqual(count, 3, "Three settlements")
    end)
end)

Suite:group("Population Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SettlementManager:new()
        shared.sm:createSettlement("pop_test", "Pop City", "city", "player", "loc")
    end)

    Suite:testMethod("SettlementManager.setPopulation", {description = "Sets population", testCase = "set_pop", type = "functional"}, function()
        local ok = shared.sm:setPopulation("pop_test", 10000)
        Helpers.assertEqual(ok, true, "Population set")
    end)

    Suite:testMethod("SettlementManager.getPopulation", {description = "Gets population", testCase = "get_pop", type = "functional"}, function()
        shared.sm:setPopulation("pop_test", 5000)
        local pop = shared.sm:getPopulation("pop_test")
        Helpers.assertEqual(pop, 5000, "Population 5000")
    end)

    Suite:testMethod("SettlementManager.getPopulation", {description = "Default zero", testCase = "default_pop", type = "functional"}, function()
        local pop = shared.sm:getPopulation("pop_test")
        Helpers.assertEqual(pop, 0, "Default pop 0")
    end)

    Suite:testMethod("SettlementManager.getTotalPopulation", {description = "Sums all", testCase = "total_pop", type = "functional"}, function()
        shared.sm:createSettlement("p2", "City 2", "city", "player", "loc")
        shared.sm:setPopulation("pop_test", 3000)
        shared.sm:setPopulation("p2", 2000)
        local total = shared.sm:getTotalPopulation()
        Helpers.assertEqual(total, 5000, "Total 5000")
    end)
end)

Suite:group("Defense Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SettlementManager:new()
        shared.sm:createSettlement("fort", "Fortress", "city", "player", "loc")
    end)

    Suite:testMethod("SettlementManager.setDefenses", {description = "Sets defense", testCase = "set_def", type = "functional"}, function()
        local ok = shared.sm:setDefenses("fort", 50)
        Helpers.assertEqual(ok, true, "Defense set")
    end)

    Suite:testMethod("SettlementManager.getDefenses", {description = "Gets defense", testCase = "get_def", type = "functional"}, function()
        shared.sm:setDefenses("fort", 75)
        local def = shared.sm:getDefenses("fort")
        Helpers.assertEqual(def, 75, "Defense 75")
    end)

    Suite:testMethod("SettlementManager.getDefenses", {description = "Default zero", testCase = "default_def", type = "functional"}, function()
        local def = shared.sm:getDefenses("fort")
        Helpers.assertEqual(def, 0, "Default def 0")
    end)
end)

Suite:group("Resource Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SettlementManager:new()
        shared.sm:createSettlement("res", "Resource Hub", "city", "player", "loc")
    end)

    Suite:testMethod("SettlementManager.addResources", {description = "Adds resources", testCase = "add_res", type = "functional"}, function()
        local ok = shared.sm:addResources("res", 500)
        Helpers.assertEqual(ok, true, "Resources added")
    end)

    Suite:testMethod("SettlementManager.getResources", {description = "Gets resources", testCase = "get_res", type = "functional"}, function()
        shared.sm:addResources("res", 300)
        local res = shared.sm:getResources("res")
        Helpers.assertEqual(res, 300, "Resources 300")
    end)

    Suite:testMethod("SettlementManager.addResources", {description = "Accumulates", testCase = "accumulate", type = "functional"}, function()
        shared.sm:addResources("res", 100)
        shared.sm:addResources("res", 200)
        local res = shared.sm:getResources("res")
        Helpers.assertEqual(res, 300, "Resources 300")
    end)
end)

Suite:group("Faction Organization", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SettlementManager:new()
        shared.sm:createSettlement("p1", "Player City", "city", "player", "loc")
        shared.sm:createSettlement("a1", "Alien Base", "base", "aliens", "loc")
        shared.sm:createSettlement("a2", "Alien Outpost", "outpost", "aliens", "loc")
    end)

    Suite:testMethod("SettlementManager.getSettlementsByFaction", {description = "Filters faction", testCase = "faction", type = "functional"}, function()
        local alien_settlements = shared.sm:getSettlementsByFaction("aliens")
        Helpers.assertEqual(alien_settlements ~= nil, true, "Faction filter works")
    end)

    Suite:testMethod("SettlementManager.getSettlementsByFaction", {description = "Correct count", testCase = "faction_count", type = "functional"}, function()
        local alien_settlements = shared.sm:getSettlementsByFaction("aliens")
        local count = #alien_settlements
        Helpers.assertEqual(count, 2, "Two alien settlements")
    end)

    Suite:testMethod("SettlementManager.getFactionsCount", {description = "Counts factions", testCase = "faction_count_total", type = "functional"}, function()
        local count = shared.sm:getFactionsCount()
        Helpers.assertEqual(count, 2, "Two factions")
    end)
end)

Suite:group("Settlement Types", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SettlementManager:new()
        shared.sm:createSettlement("t1", "City A", "city", "faction", "loc")
        shared.sm:createSettlement("t2", "City B", "city", "faction", "loc")
        shared.sm:createSettlement("t3", "Base A", "base", "faction", "loc")
    end)

    Suite:testMethod("SettlementManager.getSettlementsByType", {description = "Filters type", testCase = "type", type = "functional"}, function()
        local cities = shared.sm:getSettlementsByType("city")
        Helpers.assertEqual(cities ~= nil, true, "Type filter works")
    end)

    Suite:testMethod("SettlementManager.getSettlementsByType", {description = "Correct type", testCase = "type_count", type = "functional"}, function()
        local cities = shared.sm:getSettlementsByType("city")
        local count = #cities
        Helpers.assertEqual(count, 2, "Two cities")
    end)
end)

Suite:group("Settlement Destruction", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SettlementManager:new()
        shared.sm:createSettlement("destroy_me", "Doomed", "city", "player", "loc")
    end)

    Suite:testMethod("SettlementManager.destroySettlement", {description = "Destroys settlement", testCase = "destroy", type = "functional"}, function()
        local ok = shared.sm:destroySettlement("destroy_me")
        Helpers.assertEqual(ok, true, "Settlement destroyed")
    end)

    Suite:testMethod("SettlementManager.destroySettlement", {description = "Gone after", testCase = "gone", type = "functional"}, function()
        shared.sm:destroySettlement("destroy_me")
        local settlement = shared.sm:getSettlement("destroy_me")
        Helpers.assertEqual(settlement, nil, "Settlement gone")
    end)
end)

Suite:run()
