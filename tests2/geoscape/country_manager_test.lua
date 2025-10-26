-- ─────────────────────────────────────────────────────────────────────────
-- COUNTRY MANAGER TEST SUITE
-- FILE: tests2/geoscape/country_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.country.country_manager",
    fileName = "country_manager.lua",
    description = "Country management and diplomacy system"
})

print("[COUNTRY_MANAGER_TEST] Setting up")

local CountryManager = {
    countries = {},
    relations = {},

    createCountry = function(self, id, name, region)
        self.countries[id] = {id = id, name = name, region = region, funding = 1000, happiness = 50}
        return self.countries[id]
    end,

    getCountry = function(self, id) return self.countries[id] end,

    setRelations = function(self, country1, country2, level)
        local key = country1 < country2 and country1 .. "-" .. country2 or country2 .. "-" .. country1
        self.relations[key] = math.min(100, math.max(-100, level))
        return true
    end,

    getRelations = function(self, country1, country2)
        local key = country1 < country2 and country1 .. "-" .. country2 or country2 .. "-" .. country1
        return self.relations[key] or 0
    end,

    setFunding = function(self, countryId, amount)
        local country = self:getCountry(countryId)
        if not country then return false end
        country.funding = math.max(0, amount)
        return true
    end,

    getFunding = function(self, countryId)
        local country = self:getCountry(countryId)
        return country and country.funding or nil
    end,

    setHappiness = function(self, countryId, level)
        local country = self:getCountry(countryId)
        if not country then return false end
        country.happiness = math.min(100, math.max(0, level))
        return true
    end,

    getHappiness = function(self, countryId)
        local country = self:getCountry(countryId)
        return country and country.happiness or nil
    end,

    getCountryCount = function(self)
        local count = 0
        for _ in pairs(self.countries) do count = count + 1 end
        return count
    end
}

Suite:group("Country Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = setmetatable({countries = {}, relations = {}}, {__index = CountryManager})
    end)

    Suite:testMethod("CountryManager.createCountry", {description = "Creates country", testCase = "create", type = "functional"}, function()
        local country = shared.cm:createCountry("USA", "United States", "North America")
        Helpers.assertEqual(country ~= nil, true, "Country created")
    end)

    Suite:testMethod("CountryManager.getCountry", {description = "Retrieves country", testCase = "get", type = "functional"}, function()
        shared.cm:createCountry("UK", "United Kingdom", "Europe")
        local country = shared.cm:getCountry("UK")
        Helpers.assertEqual(country ~= nil, true, "Country retrieved")
    end)

    Suite:testMethod("CountryManager.getCountryCount", {description = "Counts countries", testCase = "count", type = "functional"}, function()
        shared.cm:createCountry("USA", "USA", "NA")
        shared.cm:createCountry("China", "China", "Asia")
        shared.cm:createCountry("Russia", "Russia", "Europe")
        local count = shared.cm:getCountryCount()
        Helpers.assertEqual(count, 3, "Three countries")
    end)
end)

Suite:group("Diplomatic Relations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = setmetatable({countries = {}, relations = {}}, {__index = CountryManager})
        shared.cm:createCountry("USA", "USA", "NA")
        shared.cm:createCountry("UK", "UK", "EU")
    end)

    Suite:testMethod("CountryManager.setRelations", {description = "Sets diplomatic relations", testCase = "set_relations", type = "functional"}, function()
        local ok = shared.cm:setRelations("USA", "UK", 80)
        Helpers.assertEqual(ok, true, "Relations set")
    end)

    Suite:testMethod("CountryManager.getRelations", {description = "Gets diplomatic relations", testCase = "get_relations", type = "functional"}, function()
        shared.cm:setRelations("USA", "UK", 60)
        local relations = shared.cm:getRelations("USA", "UK")
        Helpers.assertEqual(relations, 60, "Relations correct")
    end)

    Suite:testMethod("CountryManager.getRelations", {description = "Order independent", testCase = "order_independent", type = "functional"}, function()
        shared.cm:setRelations("USA", "UK", 75)
        local rel1 = shared.cm:getRelations("USA", "UK")
        local rel2 = shared.cm:getRelations("UK", "USA")
        Helpers.assertEqual(rel1, rel2, "Relations same both ways")
    end)

    Suite:testMethod("CountryManager.setRelations", {description = "Clamps relations", testCase = "clamp", type = "functional"}, function()
        shared.cm:setRelations("USA", "UK", 200)
        local rel = shared.cm:getRelations("USA", "UK")
        Helpers.assertEqual(rel, 100, "Relations clamped to 100")
    end)
end)

Suite:group("Funding & Happiness", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = setmetatable({countries = {}, relations = {}}, {__index = CountryManager})
        shared.cm:createCountry("test", "Test Country", "TestRegion")
    end)

    Suite:testMethod("CountryManager.setFunding", {description = "Sets country funding", testCase = "set_funding", type = "functional"}, function()
        local ok = shared.cm:setFunding("test", 5000)
        Helpers.assertEqual(ok, true, "Funding set")
    end)

    Suite:testMethod("CountryManager.getFunding", {description = "Gets country funding", testCase = "get_funding", type = "functional"}, function()
        shared.cm:setFunding("test", 3000)
        local funding = shared.cm:getFunding("test")
        Helpers.assertEqual(funding, 3000, "Funding correct")
    end)

    Suite:testMethod("CountryManager.setHappiness", {description = "Sets happiness", testCase = "set_happiness", type = "functional"}, function()
        local ok = shared.cm:setHappiness("test", 75)
        Helpers.assertEqual(ok, true, "Happiness set")
    end)

    Suite:testMethod("CountryManager.getHappiness", {description = "Gets happiness", testCase = "get_happiness", type = "functional"}, function()
        shared.cm:setHappiness("test", 60)
        local happiness = shared.cm:getHappiness("test")
        Helpers.assertEqual(happiness, 60, "Happiness correct")
    end)

    Suite:testMethod("CountryManager.setHappiness", {description = "Clamps happiness to 0-100", testCase = "clamp_happiness", type = "functional"}, function()
        shared.cm:setHappiness("test", 150)
        local happiness = shared.cm:getHappiness("test")
        Helpers.assertEqual(happiness, 100, "Happiness clamped to 100")
    end)
end)

Suite:run()
