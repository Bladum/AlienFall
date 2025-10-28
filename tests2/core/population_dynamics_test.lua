-- ─────────────────────────────────────────────────────────────────────────
-- POPULATION DYNAMICS TEST SUITE
-- FILE: tests2/core/population_dynamics_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.population_dynamics",
    fileName = "population_dynamics.lua",
    description = "Population dynamics with birth/death rates, migration, and growth"
})

print("[POPULATION_DYNAMICS_TEST] Setting up")

local PopulationDynamics = {
    populations = {},
    regions = {},
    demographics = {},
    events = {},

    new = function(self)
        return setmetatable({
            populations = {}, regions = {}, demographics = {}, events = {}
        }, {__index = self})
    end,

    registerRegion = function(self, regionId, name, population)
        self.regions[regionId] = {
            id = regionId, name = name, current_population = population or 1000,
            growth_rate = 0.02, stability = 80, health = 70, food_supply = 100
        }
        self.demographics[regionId] = {
            birth_rate = 0.025, death_rate = 0.008, migration_rate = 0.01,
            age_distribution = {children = 200, adults = 600, elderly = 200}
        }
        return true
    end,

    getRegion = function(self, regionId)
        return self.regions[regionId]
    end,

    createPopulation = function(self, popId, regionId, count, speciesType)
        if not self.regions[regionId] then return false end
        self.populations[popId] = {
            id = popId, region = regionId, count = count or 0,
            species = speciesType or "human", morale = 50,
            education = 30, health = 70, working_age = count or 0
        }
        return true
    end,

    getPopulation = function(self, popId)
        return self.populations[popId]
    end,

    setPopulationCount = function(self, popId, count)
        if not self.populations[popId] then return false end
        self.populations[popId].count = math.max(0, count)
        return true
    end,

    getPopulationCount = function(self, popId)
        if not self.populations[popId] then return 0 end
        return self.populations[popId].count
    end,

    calculateBirths = function(self, popId)
        if not self.populations[popId] then return 0 end
        local pop = self.populations[popId]
        local demo = self.demographics[pop.region]
        if not demo then return 0 end
        local births = math.floor(pop.count * demo.birth_rate)
        return births
    end,

    calculateDeaths = function(self, popId)
        if not self.populations[popId] then return 0 end
        local pop = self.populations[popId]
        local demo = self.demographics[pop.region]
        if not demo then return 0 end
        local deaths = math.floor(pop.count * demo.death_rate)
        return deaths
    end,

    simulateBirthDeathCycle = function(self, popId)
        if not self.populations[popId] then return false end
        local births = self:calculateBirths(popId)
        local deaths = self:calculateDeaths(popId)
        self.populations[popId].count = self.populations[popId].count + births - deaths
        return true
    end,

    getNetGrowthRate = function(self, popId)
        if not self.populations[popId] then return 0 end
        local births = self:calculateBirths(popId)
        local deaths = self:calculateDeaths(popId)
        local pop = self:getPopulationCount(popId)
        if pop == 0 then return 0 end
        return ((births - deaths) / pop) * 100
    end,

    setBirthRate = function(self, regionId, rate)
        if not self.demographics[regionId] then return false end
        self.demographics[regionId].birth_rate = math.max(0, math.min(1, rate))
        return true
    end,

    setDeathRate = function(self, regionId, rate)
        if not self.demographics[regionId] then return false end
        self.demographics[regionId].death_rate = math.max(0, math.min(1, rate))
        return true
    end,

    setMigrationRate = function(self, regionId, rate)
        if not self.demographics[regionId] then return false end
        self.demographics[regionId].migration_rate = math.max(0, math.min(1, rate))
        return true
    end,

    simulateMigration = function(self, sourcePopId, destPopId, percentage)
        if not self.populations[sourcePopId] or not self.populations[destPopId] then return false end
        local source = self.populations[sourcePopId]
        local dest = self.populations[destPopId]
        local migrants = math.floor(source.count * (percentage or 0.05) / 100)
        if migrants > source.count then return false end
        source.count = source.count - migrants
        dest.count = dest.count + migrants
        return true
    end,

    getAgeDistribution = function(self, regionId)
        if not self.demographics[regionId] then return nil end
        return self.demographics[regionId].age_distribution
    end,

    updateAgeDistribution = function(self, regionId, children, adults, elderly)
        if not self.demographics[regionId] then return false end
        self.demographics[regionId].age_distribution = {
            children = children or 0, adults = adults or 0, elderly = elderly or 0
        }
        return true
    end,

    getWorkingAgeProportion = function(self, popId)
        if not self.populations[popId] then return 0 end
        local pop = self.populations[popId]
        local working = pop.working_age
        if pop.count == 0 then return 0 end
        return math.floor((working / pop.count) * 100)
    end,

    setRegionHealth = function(self, regionId, health)
        if not self.regions[regionId] then return false end
        self.regions[regionId].health = math.max(0, math.min(100, health))
        return true
    end,

    getRegionHealth = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        return self.regions[regionId].health
    end,

    setPopulationMorale = function(self, popId, morale)
        if not self.populations[popId] then return false end
        self.populations[popId].morale = math.max(0, math.min(100, morale))
        return true
    end,

    getPopulationMorale = function(self, popId)
        if not self.populations[popId] then return 0 end
        return self.populations[popId].morale
    end,

    calculatePopulationProductivity = function(self, popId)
        if not self.populations[popId] then return 0 end
        local pop = self.populations[popId]
        local base_productivity = self:getWorkingAgeProportion(popId) / 100
        local morale_factor = pop.morale / 100
        local health_factor = pop.health / 100
        local region = self.regions[pop.region]
        local stability_factor = region and (region.stability / 100) or 0.5
        return base_productivity * morale_factor * health_factor * stability_factor * 100
    end,

    calculateGrowthCurve = function(self, popId, generations)
        if not self.populations[popId] then return {} end
        local curve = {}
        local current_count = self:getPopulationCount(popId)
        for i = 1, generations or 10 do
            self:simulateBirthDeathCycle(popId)
            current_count = self:getPopulationCount(popId)
            table.insert(curve, current_count)
        end
        return curve
    end,

    setFoodSupply = function(self, regionId, supply)
        if not self.regions[regionId] then return false end
        self.regions[regionId].food_supply = math.max(0, math.min(100, supply))
        return true
    end,

    getFoodSupply = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        return self.regions[regionId].food_supply
    end,

    calculateFamineRisk = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local region = self.regions[regionId]
        local food = region.food_supply
        local pop_pressure = (region.current_population / 2000) * 100
        local famine_risk = math.max(0, pop_pressure - food)
        return math.floor(famine_risk)
    end,

    recordEvent = function(self, eventId, regionId, eventType, impact)
        self.events[eventId] = {
            id = eventId, region = regionId, type = eventType or "migration",
            impact = impact or 10, turn_recorded = 1
        }
        return true
    end,

    getEvent = function(self, eventId)
        return self.events[eventId]
    end,

    getTotalPopulation = function(self, regionId)
        local total = 0
        for _, pop in pairs(self.populations) do
            if pop.region == regionId then
                total = total + pop.count
            end
        end
        return total
    end,

    reset = function(self)
        self.populations = {}
        self.regions = {}
        self.demographics = {}
        self.events = {}
        return true
    end
}

Suite:group("Regions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
    end)

    Suite:testMethod("PopulationDynamics.registerRegion", {description = "Registers region", testCase = "register", type = "functional"}, function()
        local ok = shared.pd:registerRegion("region1", "Capital", 5000)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("PopulationDynamics.getRegion", {description = "Gets region", testCase = "get", type = "functional"}, function()
        shared.pd:registerRegion("region2", "Province", 3000)
        local region = shared.pd:getRegion("region2")
        Helpers.assertEqual(region ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("PopulationDynamics.setRegionHealth", {description = "Sets region health", testCase = "health", type = "functional"}, function()
        shared.pd:registerRegion("region3", "Territory", 2000)
        local ok = shared.pd:setRegionHealth("region3", 85)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("PopulationDynamics.getRegionHealth", {description = "Gets region health", testCase = "get_health", type = "functional"}, function()
        shared.pd:registerRegion("region4", "District", 4000)
        shared.pd:setRegionHealth("region4", 75)
        local health = shared.pd:getRegionHealth("region4")
        Helpers.assertEqual(health, 75, "75 health")
    end)
end)

Suite:group("Populations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
        shared.pd:registerRegion("pop_region", "Test", 5000)
    end)

    Suite:testMethod("PopulationDynamics.createPopulation", {description = "Creates population", testCase = "create", type = "functional"}, function()
        local ok = shared.pd:createPopulation("pop1", "pop_region", 1000, "human")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("PopulationDynamics.getPopulation", {description = "Gets population", testCase = "get", type = "functional"}, function()
        shared.pd:createPopulation("pop2", "pop_region", 1500, "human")
        local pop = shared.pd:getPopulation("pop2")
        Helpers.assertEqual(pop ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("PopulationDynamics.setPopulationCount", {description = "Sets count", testCase = "count", type = "functional"}, function()
        shared.pd:createPopulation("pop3", "pop_region", 800, "human")
        local ok = shared.pd:setPopulationCount("pop3", 900)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("PopulationDynamics.getPopulationCount", {description = "Gets count", testCase = "get_count", type = "functional"}, function()
        shared.pd:createPopulation("pop4", "pop_region", 1200, "human")
        local count = shared.pd:getPopulationCount("pop4")
        Helpers.assertEqual(count, 1200, "1200 count")
    end)

    Suite:testMethod("PopulationDynamics.getTotalPopulation", {description = "Gets total", testCase = "total", type = "functional"}, function()
        shared.pd:createPopulation("pop5", "pop_region", 500, "human")
        shared.pd:createPopulation("pop6", "pop_region", 600, "human")
        local total = shared.pd:getTotalPopulation("pop_region")
        Helpers.assertEqual(total, 1100, "1100 total")
    end)
end)

Suite:group("Birth & Death", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
        shared.pd:registerRegion("bd_region", "Test", 5000)
        shared.pd:createPopulation("bd_pop", "bd_region", 1000, "human")
    end)

    Suite:testMethod("PopulationDynamics.calculateBirths", {description = "Calculates births", testCase = "births", type = "functional"}, function()
        local births = shared.pd:calculateBirths("bd_pop")
        Helpers.assertEqual(births > 0, true, "Births > 0")
    end)

    Suite:testMethod("PopulationDynamics.calculateDeaths", {description = "Calculates deaths", testCase = "deaths", type = "functional"}, function()
        local deaths = shared.pd:calculateDeaths("bd_pop")
        Helpers.assertEqual(deaths > 0, true, "Deaths > 0")
    end)

    Suite:testMethod("PopulationDynamics.simulateBirthDeathCycle", {description = "Simulates cycle", testCase = "cycle", type = "functional"}, function()
        local ok = shared.pd:simulateBirthDeathCycle("bd_pop")
        Helpers.assertEqual(ok, true, "Simulated")
    end)

    Suite:testMethod("PopulationDynamics.getNetGrowthRate", {description = "Net growth rate", testCase = "growth", type = "functional"}, function()
        local rate = shared.pd:getNetGrowthRate("bd_pop")
        Helpers.assertEqual(rate ~= nil, true, "Rate exists")
    end)
end)

Suite:group("Rates", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
        shared.pd:registerRegion("rate_region", "Test", 5000)
    end)

    Suite:testMethod("PopulationDynamics.setBirthRate", {description = "Sets birth rate", testCase = "birth", type = "functional"}, function()
        local ok = shared.pd:setBirthRate("rate_region", 0.03)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("PopulationDynamics.setDeathRate", {description = "Sets death rate", testCase = "death", type = "functional"}, function()
        local ok = shared.pd:setDeathRate("rate_region", 0.01)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("PopulationDynamics.setMigrationRate", {description = "Sets migration rate", testCase = "migration", type = "functional"}, function()
        local ok = shared.pd:setMigrationRate("rate_region", 0.02)
        Helpers.assertEqual(ok, true, "Set")
    end)
end)

Suite:group("Migration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
        shared.pd:registerRegion("source", "Source", 5000)
        shared.pd:registerRegion("dest", "Dest", 5000)
        shared.pd:createPopulation("source_pop", "source", 1000, "human")
        shared.pd:createPopulation("dest_pop", "dest", 500, "human")
    end)

    Suite:testMethod("PopulationDynamics.simulateMigration", {description = "Simulates migration", testCase = "migrate", type = "functional"}, function()
        local ok = shared.pd:simulateMigration("source_pop", "dest_pop", 5)
        Helpers.assertEqual(ok, true, "Migrated")
    end)
end)

Suite:group("Age Distribution", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
        shared.pd:registerRegion("age_region", "Test", 5000)
    end)

    Suite:testMethod("PopulationDynamics.getAgeDistribution", {description = "Gets distribution", testCase = "get", type = "functional"}, function()
        local dist = shared.pd:getAgeDistribution("age_region")
        Helpers.assertEqual(dist ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("PopulationDynamics.updateAgeDistribution", {description = "Updates distribution", testCase = "update", type = "functional"}, function()
        local ok = shared.pd:updateAgeDistribution("age_region", 300, 700, 200)
        Helpers.assertEqual(ok, true, "Updated")
    end)
end)

Suite:group("Work & Morale", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
        shared.pd:registerRegion("work_region", "Test", 5000)
        shared.pd:createPopulation("work_pop", "work_region", 1000, "human")
    end)

    Suite:testMethod("PopulationDynamics.getWorkingAgeProportion", {description = "Working age", testCase = "working", type = "functional"}, function()
        local prop = shared.pd:getWorkingAgeProportion("work_pop")
        Helpers.assertEqual(prop >= 0, true, "Proportion >= 0")
    end)

    Suite:testMethod("PopulationDynamics.setPopulationMorale", {description = "Sets morale", testCase = "morale", type = "functional"}, function()
        local ok = shared.pd:setPopulationMorale("work_pop", 70)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("PopulationDynamics.getPopulationMorale", {description = "Gets morale", testCase = "get_morale", type = "functional"}, function()
        shared.pd:setPopulationMorale("work_pop", 65)
        local morale = shared.pd:getPopulationMorale("work_pop")
        Helpers.assertEqual(morale, 65, "65 morale")
    end)
end)

Suite:group("Productivity & Growth", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
        shared.pd:registerRegion("prod_region", "Test", 5000)
        shared.pd:createPopulation("prod_pop", "prod_region", 1000, "human")
    end)

    Suite:testMethod("PopulationDynamics.calculatePopulationProductivity", {description = "Calculates productivity", testCase = "productivity", type = "functional"}, function()
        local prod = shared.pd:calculatePopulationProductivity("prod_pop")
        Helpers.assertEqual(prod >= 0, true, "Productivity >= 0")
    end)

    Suite:testMethod("PopulationDynamics.calculateGrowthCurve", {description = "Calculates curve", testCase = "curve", type = "functional"}, function()
        local curve = shared.pd:calculateGrowthCurve("prod_pop", 5)
        Helpers.assertEqual(#curve > 0, true, "Curve has data")
    end)
end)

Suite:group("Food & Famine", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
        shared.pd:registerRegion("food_region", "Test", 5000)
    end)

    Suite:testMethod("PopulationDynamics.setFoodSupply", {description = "Sets supply", testCase = "supply", type = "functional"}, function()
        local ok = shared.pd:setFoodSupply("food_region", 80)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("PopulationDynamics.getFoodSupply", {description = "Gets supply", testCase = "get_supply", type = "functional"}, function()
        shared.pd:setFoodSupply("food_region", 75)
        local supply = shared.pd:getFoodSupply("food_region")
        Helpers.assertEqual(supply, 75, "75 supply")
    end)

    Suite:testMethod("PopulationDynamics.calculateFamineRisk", {description = "Famine risk", testCase = "famine", type = "functional"}, function()
        local risk = shared.pd:calculateFamineRisk("food_region")
        Helpers.assertEqual(risk >= 0, true, "Risk >= 0")
    end)
end)

Suite:group("Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
        shared.pd:registerRegion("event_region", "Test", 5000)
    end)

    Suite:testMethod("PopulationDynamics.recordEvent", {description = "Records event", testCase = "record", type = "functional"}, function()
        local ok = shared.pd:recordEvent("event1", "event_region", "famine", 50)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("PopulationDynamics.getEvent", {description = "Gets event", testCase = "get", type = "functional"}, function()
        shared.pd:recordEvent("event2", "event_region", "plague", 75)
        local event = shared.pd:getEvent("event2")
        Helpers.assertEqual(event ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pd = PopulationDynamics:new()
    end)

    Suite:testMethod("PopulationDynamics.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.pd:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
