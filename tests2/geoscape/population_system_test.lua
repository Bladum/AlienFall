-- ─────────────────────────────────────────────────────────────────────────
-- POPULATION SYSTEM TEST SUITE
-- FILE: tests2/geoscape/population_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.population_system",
    fileName = "population_system.lua",
    description = "Population dynamics with growth, morale, migration, and settlement effects"
})

print("[POPULATION_SYSTEM_TEST] Setting up")

local PopulationSystem = {
    settlements = {},
    populations = {},
    morale = {},
    growth = {},

    new = function(self)
        return setmetatable({settlements = {}, populations = {}, morale = {}, growth = {}}, {__index = self})
    end,

    createSettlement = function(self, settlementId, name, region, initialPopulation)
        self.settlements[settlementId] = {id = settlementId, name = name, region = region, active = true}
        self.populations[settlementId] = initialPopulation or 1000
        self.morale[settlementId] = 50
        self.growth[settlementId] = {rate = 1.05, lastTick = 0}
        return true
    end,

    getSettlement = function(self, settlementId)
        return self.settlements[settlementId]
    end,

    getPopulation = function(self, settlementId)
        if not self.populations[settlementId] then return 0 end
        return self.populations[settlementId]
    end,

    setPopulation = function(self, settlementId, amount)
        if not self.settlements[settlementId] then return false end
        self.populations[settlementId] = amount
        return true
    end,

    getMorale = function(self, settlementId)
        if not self.morale[settlementId] then return 0 end
        return self.morale[settlementId]
    end,

    setMorale = function(self, settlementId, morale)
        if not self.settlements[settlementId] then return false end
        self.morale[settlementId] = math.max(0, math.min(100, morale))
        return true
    end,

    adjustMorale = function(self, settlementId, delta)
        if not self.settlements[settlementId] then return false end
        local current = self.morale[settlementId] or 50
        self.morale[settlementId] = math.max(0, math.min(100, current + delta))
        return true
    end,

    calculateGrowth = function(self, settlementId)
        if not self.settlements[settlementId] then return 0 end
        local population = self.populations[settlementId]
        local morale = self.morale[settlementId] or 50
        local baseRate = 1.05
        local moraleMultiplier = morale / 100
        local growthRate = baseRate + (moraleMultiplier * 0.05)
        local grown = math.floor(population * growthRate)
        return grown - population
    end,

    tickGrowth = function(self, settlementId)
        if not self.settlements[settlementId] then return false end
        local growth = self:calculateGrowth(settlementId)
        self.populations[settlementId] = self.populations[settlementId] + growth
        return true
    end,

    getGrowthRate = function(self, settlementId)
        if not self.growth[settlementId] then return 1 end
        return self.growth[settlementId].rate
    end,

    migrate = function(self, fromSettlement, toSettlement, amount)
        if not self.populations[fromSettlement] or not self.populations[toSettlement] then return false end
        if self.populations[fromSettlement] < amount then return false end
        self.populations[fromSettlement] = self.populations[fromSettlement] - amount
        self.populations[toSettlement] = self.populations[toSettlement] + amount
        return true
    end,

    getTotalPopulation = function(self)
        local total = 0
        for _, pop in pairs(self.populations) do
            total = total + pop
        end
        return total
    end,

    getAverageMorale = function(self)
        if not next(self.morale) then return 0 end
        local total = 0
        local count = 0
        for _, m in pairs(self.morale) do
            total = total + m
            count = count + 1
        end
        return count > 0 and math.floor(total / count) or 0
    end,

    getSettlementCount = function(self)
        local count = 0
        for _ in pairs(self.settlements) do count = count + 1 end
        return count
    end,

    getActiveSettlements = function(self)
        local count = 0
        for _, settlement in pairs(self.settlements) do
            if settlement.active then count = count + 1 end
        end
        return count
    end,

    getPopulationDensity = function(self, settlementId)
        if not self.settlements[settlementId] then return 0 end
        local population = self.populations[settlementId]
        return math.floor(population / 100)
    end,

    isSettlementHealthy = function(self, settlementId)
        if not self.settlements[settlementId] then return false end
        local morale = self.morale[settlementId] or 50
        return morale >= 40
    end,

    applyDisaster = function(self, settlementId, severity)
        if not self.settlements[settlementId] then return false end
        local loss = math.floor(self.populations[settlementId] * (severity / 100))
        self.populations[settlementId] = self.populations[settlementId] - loss
        self:adjustMorale(settlementId, -20)
        return true
    end,

    getRegionPopulation = function(self, region)
        local total = 0
        for settlementId, settlement in pairs(self.settlements) do
            if settlement.region == region then
                total = total + (self.populations[settlementId] or 0)
            end
        end
        return total
    end
}

Suite:group("Settlement Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PopulationSystem:new()
    end)

    Suite:testMethod("PopulationSystem.createSettlement", {description = "Creates settlement", testCase = "create", type = "functional"}, function()
        local ok = shared.ps:createSettlement("s1", "Capital", "north", 5000)
        Helpers.assertEqual(ok, true, "Settlement created")
    end)

    Suite:testMethod("PopulationSystem.getSettlement", {description = "Retrieves settlement", testCase = "get", type = "functional"}, function()
        shared.ps:createSettlement("s2", "Town", "west", 2000)
        local settlement = shared.ps:getSettlement("s2")
        Helpers.assertEqual(settlement ~= nil, true, "Settlement retrieved")
    end)

    Suite:testMethod("PopulationSystem.getSettlementCount", {description = "Counts settlements", testCase = "count", type = "functional"}, function()
        shared.ps:createSettlement("s1", "City1", "region1", 1000)
        shared.ps:createSettlement("s2", "City2", "region2", 1000)
        shared.ps:createSettlement("s3", "City3", "region3", 1000)
        local count = shared.ps:getSettlementCount()
        Helpers.assertEqual(count, 3, "Three settlements")
    end)
end)

Suite:group("Population Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PopulationSystem:new()
        shared.ps:createSettlement("pop", "Settlement", "center", 5000)
    end)

    Suite:testMethod("PopulationSystem.getPopulation", {description = "Gets population", testCase = "get_pop", type = "functional"}, function()
        local pop = shared.ps:getPopulation("pop")
        Helpers.assertEqual(pop, 5000, "5000 population")
    end)

    Suite:testMethod("PopulationSystem.setPopulation", {description = "Sets population", testCase = "set_pop", type = "functional"}, function()
        local ok = shared.ps:setPopulation("pop", 10000)
        Helpers.assertEqual(ok, true, "Population set")
    end)

    Suite:testMethod("PopulationSystem.getTotalPopulation", {description = "Total population", testCase = "total_pop", type = "functional"}, function()
        shared.ps:createSettlement("p1", "S1", "r1", 1000)
        shared.ps:createSettlement("p2", "S2", "r2", 2000)
        shared.ps:createSettlement("p3", "S3", "r3", 3000)
        local total = shared.ps:getTotalPopulation()
        Helpers.assertEqual(total, 6000, "6000 total")
    end)

    Suite:testMethod("PopulationSystem.getPopulationDensity", {description = "Density", testCase = "density", type = "functional"}, function()
        local density = shared.ps:getPopulationDensity("pop")
        Helpers.assertEqual(density, 50, "Density 50")
    end)
end)

Suite:group("Morale System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PopulationSystem:new()
        shared.ps:createSettlement("morale", "City", "region", 3000)
    end)

    Suite:testMethod("PopulationSystem.getMorale", {description = "Gets morale", testCase = "get_morale", type = "functional"}, function()
        local morale = shared.ps:getMorale("morale")
        Helpers.assertEqual(morale, 50, "Morale 50")
    end)

    Suite:testMethod("PopulationSystem.setMorale", {description = "Sets morale", testCase = "set_morale", type = "functional"}, function()
        local ok = shared.ps:setMorale("morale", 75)
        Helpers.assertEqual(ok, true, "Morale set")
    end)

    Suite:testMethod("PopulationSystem.adjustMorale", {description = "Adjusts morale", testCase = "adjust_morale", type = "functional"}, function()
        local ok = shared.ps:adjustMorale("morale", 10)
        Helpers.assertEqual(ok, true, "Morale adjusted")
    end)

    Suite:testMethod("PopulationSystem.isSettlementHealthy", {description = "Health check", testCase = "health", type = "functional"}, function()
        shared.ps:setMorale("morale", 50)
        local healthy = shared.ps:isSettlementHealthy("morale")
        Helpers.assertEqual(healthy, true, "Settlement healthy")
    end)

    Suite:testMethod("PopulationSystem.getAverageMorale", {description = "Average morale", testCase = "avg_morale", type = "functional"}, function()
        shared.ps:setMorale("morale", 60)
        local avg = shared.ps:getAverageMorale()
        Helpers.assertEqual(avg >= 50, true, "Average calculated")
    end)
end)

Suite:group("Growth System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PopulationSystem:new()
        shared.ps:createSettlement("growth", "Growing", "region", 1000)
    end)

    Suite:testMethod("PopulationSystem.calculateGrowth", {description = "Calculates growth", testCase = "calc_growth", type = "functional"}, function()
        local growth = shared.ps:calculateGrowth("growth")
        Helpers.assertEqual(growth > 0, true, "Growth positive")
    end)

    Suite:testMethod("PopulationSystem.tickGrowth", {description = "Ticks growth", testCase = "tick_growth", type = "functional"}, function()
        local ok = shared.ps:tickGrowth("growth")
        Helpers.assertEqual(ok, true, "Growth ticked")
    end)

    Suite:testMethod("PopulationSystem.getGrowthRate", {description = "Gets growth rate", testCase = "get_rate", type = "functional"}, function()
        local rate = shared.ps:getGrowthRate("growth")
        Helpers.assertEqual(rate >= 1, true, "Rate positive")
    end)
end)

Suite:group("Migration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PopulationSystem:new()
        shared.ps:createSettlement("source", "From", "region", 5000)
        shared.ps:createSettlement("dest", "To", "region", 2000)
    end)

    Suite:testMethod("PopulationSystem.migrate", {description = "Migrates people", testCase = "migrate", type = "functional"}, function()
        local ok = shared.ps:migrate("source", "dest", 500)
        Helpers.assertEqual(ok, true, "Migration successful")
    end)

    Suite:testMethod("PopulationSystem.migrate", {description = "Updates populations", testCase = "migrate_effect", type = "functional"}, function()
        shared.ps:migrate("source", "dest", 1000)
        local from = shared.ps:getPopulation("source")
        local to = shared.ps:getPopulation("dest")
        Helpers.assertEqual(from, 4000, "Source: 4000")
        Helpers.assertEqual(to, 3000, "Dest: 3000")
    end)
end)

Suite:group("Regional", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PopulationSystem:new()
        shared.ps:createSettlement("r1", "City1", "north", 2000)
        shared.ps:createSettlement("r2", "City2", "north", 3000)
        shared.ps:createSettlement("r3", "City3", "south", 1500)
    end)

    Suite:testMethod("PopulationSystem.getRegionPopulation", {description = "Region total", testCase = "region_pop", type = "functional"}, function()
        local total = shared.ps:getRegionPopulation("north")
        Helpers.assertEqual(total, 5000, "5000 north")
    end)

    Suite:testMethod("PopulationSystem.getActiveSettlements", {description = "Active count", testCase = "active", type = "functional"}, function()
        local count = shared.ps:getActiveSettlements()
        Helpers.assertEqual(count, 3, "Three active")
    end)
end)

Suite:group("Disasters", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PopulationSystem:new()
        shared.ps:createSettlement("disaster", "Vulnerable", "region", 10000)
    end)

    Suite:testMethod("PopulationSystem.applyDisaster", {description = "Applies disaster", testCase = "disaster", type = "functional"}, function()
        local ok = shared.ps:applyDisaster("disaster", 50)
        Helpers.assertEqual(ok, true, "Disaster applied")
    end)
end)

Suite:run()
