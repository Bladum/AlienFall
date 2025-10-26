-- ─────────────────────────────────────────────────────────────────────────
-- WORLD SYSTEM TEST SUITE
-- FILE: tests2/geoscape/world_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.world.world_system",
    fileName = "world_system.lua",
    description = "Geoscape world and geography system"
})

print("[WORLD_SYSTEM_TEST] Setting up")

local WorldSystem = {
    provinces = {},
    regions = {},
    countries = {},
    time = {day = 1, month = 1, year = 2035},

    createProvince = function(self, id, name, country)
        self.provinces[id] = {id = id, name = name, country = country, terror = 0}
        return self.provinces[id]
    end,

    getProvince = function(self, id) return self.provinces[id] end,

    getProvincesByCountry = function(self, country)
        local result = {}
        for _, prov in pairs(self.provinces) do
            if prov.country == country then
                table.insert(result, prov)
            end
        end
        return result
    end,

    setTerror = function(self, provinceId, level)
        local prov = self:getProvince(provinceId)
        if not prov then return false end
        prov.terror = math.min(100, math.max(0, level))
        return true
    end,

    getTerror = function(self, provinceId)
        local prov = self:getProvince(provinceId)
        return prov and prov.terror or nil
    end,

    advanceTime = function(self)
        self.time.day = self.time.day + 1
        if self.time.day > 30 then
            self.time.day = 1
            self.time.month = self.time.month + 1
        end
        if self.time.month > 12 then
            self.time.month = 1
            self.time.year = self.time.year + 1
        end
        return self.time
    end,

    getTime = function(self) return self.time end,

    getProvinceCount = function(self)
        local count = 0
        for _ in pairs(self.provinces) do count = count + 1 end
        return count
    end
}

Suite:group("Province Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = setmetatable({provinces = {}, regions = {}, countries = {}, time = {day = 1, month = 1, year = 2035}}, {__index = WorldSystem})
    end)

    Suite:testMethod("WorldSystem.createProvince", {description = "Creates province", testCase = "create", type = "functional"}, function()
        local prov = shared.ws:createProvince("north_america", "North America", "USA")
        Helpers.assertEqual(prov ~= nil, true, "Province created")
    end)

    Suite:testMethod("WorldSystem.getProvince", {description = "Retrieves province", testCase = "get", type = "functional"}, function()
        shared.ws:createProvince("europe", "Europe", "EU")
        local prov = shared.ws:getProvince("europe")
        Helpers.assertEqual(prov ~= nil, true, "Province retrieved")
    end)

    Suite:testMethod("WorldSystem.getProvincesByCountry", {description = "Filters by country", testCase = "filter_country", type = "functional"}, function()
        shared.ws:createProvince("california", "California", "USA")
        shared.ws:createProvince("texas", "Texas", "USA")
        shared.ws:createProvince("france", "France", "EU")
        local usa = shared.ws:getProvincesByCountry("USA")
        Helpers.assertEqual(#usa, 2, "Two USA provinces")
    end)

    Suite:testMethod("WorldSystem.getProvinceCount", {description = "Counts all provinces", testCase = "count", type = "functional"}, function()
        shared.ws:createProvince("p1", "Province 1", "Country A")
        shared.ws:createProvince("p2", "Province 2", "Country B")
        shared.ws:createProvince("p3", "Province 3", "Country A")
        local count = shared.ws:getProvinceCount()
        Helpers.assertEqual(count, 3, "Three provinces")
    end)
end)

Suite:group("Terror Level", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = setmetatable({provinces = {}, regions = {}, countries = {}, time = {day = 1, month = 1, year = 2035}}, {__index = WorldSystem})
        shared.ws:createProvince("test", "Test Province", "TestCountry")
    end)

    Suite:testMethod("WorldSystem.setTerror", {description = "Sets terror level", testCase = "set_terror", type = "functional"}, function()
        local ok = shared.ws:setTerror("test", 50)
        Helpers.assertEqual(ok, true, "Terror set")
    end)

    Suite:testMethod("WorldSystem.getTerror", {description = "Gets terror level", testCase = "get_terror", type = "functional"}, function()
        shared.ws:setTerror("test", 75)
        local terror = shared.ws:getTerror("test")
        Helpers.assertEqual(terror, 75, "Terror level correct")
    end)

    Suite:testMethod("WorldSystem.setTerror", {description = "Clamps terror to 0-100", testCase = "clamp_terror", type = "functional"}, function()
        shared.ws:setTerror("test", 150)
        local terror = shared.ws:getTerror("test")
        Helpers.assertEqual(terror, 100, "Terror clamped to 100")
    end)

    Suite:testMethod("WorldSystem.setTerror", {description = "Clamps negative terror", testCase = "clamp_negative", type = "functional"}, function()
        shared.ws:setTerror("test", -50)
        local terror = shared.ws:getTerror("test")
        Helpers.assertEqual(terror, 0, "Terror clamped to 0")
    end)
end)

Suite:group("Time System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = setmetatable({provinces = {}, regions = {}, countries = {}, time = {day = 1, month = 1, year = 2035}}, {__index = WorldSystem})
    end)

    Suite:testMethod("WorldSystem.getTime", {description = "Returns current time", testCase = "get_time", type = "functional"}, function()
        local time = shared.ws:getTime()
        Helpers.assertEqual(time.year, 2035, "Year correct")
    end)

    Suite:testMethod("WorldSystem.advanceTime", {description = "Advances day", testCase = "advance_day", type = "functional"}, function()
        shared.ws:advanceTime()
        Helpers.assertEqual(shared.ws.time.day, 2, "Day advanced")
    end)

    Suite:testMethod("WorldSystem.advanceTime", {description = "Month rolls over", testCase = "month_rollover", type = "functional"}, function()
        shared.ws.time.day = 30
        shared.ws:advanceTime()
        Helpers.assertEqual(shared.ws.time.day, 1, "Day reset")
        Helpers.assertEqual(shared.ws.time.month, 2, "Month advanced")
    end)

    Suite:testMethod("WorldSystem.advanceTime", {description = "Year rolls over", testCase = "year_rollover", type = "functional"}, function()
        shared.ws.time = {day = 30, month = 12, year = 2035}
        shared.ws:advanceTime()
        Helpers.assertEqual(shared.ws.time.day, 1, "Day reset")
        Helpers.assertEqual(shared.ws.time.month, 1, "Month reset")
        Helpers.assertEqual(shared.ws.time.year, 2036, "Year advanced")
    end)
end)

Suite:run()
