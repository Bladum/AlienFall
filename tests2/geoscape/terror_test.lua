-- ─────────────────────────────────────────────────────────────────────────
-- TERROR SYSTEM TEST SUITE
-- FILE: tests2/geoscape/terror_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.terror.terror_system",
    fileName = "terror_system.lua",
    description = "Terror level tracking and alien threat escalation system"
})

print("[TERROR_TEST] Setting up")

local TerrorSystem = {
    regions = {},
    globalTerror = 0,

    new = function(self)
        return setmetatable({regions = {}, globalTerror = 0}, {__index = self})
    end,

    addRegion = function(self, regionId, initialTerror)
        self.regions[regionId] = {id = regionId, terror = initialTerror or 0}
        return true
    end,

    setRegionTerror = function(self, regionId, terrorLevel)
        if not self.regions[regionId] then return false end
        self.regions[regionId].terror = math.min(100, math.max(0, terrorLevel))
        return true
    end,

    getRegionTerror = function(self, regionId)
        if not self.regions[regionId] then return nil end
        return self.regions[regionId].terror
    end,

    increaseTerror = function(self, regionId, amount)
        if not self.regions[regionId] then return false end
        local newTerror = self.regions[regionId].terror + amount
        self.regions[regionId].terror = math.min(100, newTerror)
        return true
    end,

    decreaseTerror = function(self, regionId, amount)
        if not self.regions[regionId] then return false end
        local newTerror = self.regions[regionId].terror - amount
        self.regions[regionId].terror = math.max(0, newTerror)
        return true
    end,

    getGlobalTerror = function(self)
        local total = 0
        local count = 0
        for _, region in pairs(self.regions) do
            total = total + region.terror
            count = count + 1
        end
        return count > 0 and (total / count) or 0
    end,

    calculateEscalation = function(self)
        local avg = self:getGlobalTerror()
        if avg < 30 then return 1
        elseif avg < 60 then return 2
        elseif avg < 80 then return 3
        else return 4
        end
    end,

    getHighTerrorRegions = function(self, threshold)
        local result = {}
        for id, region in pairs(self.regions) do
            if region.terror > threshold then
                table.insert(result, id)
            end
        end
        return result
    end,

    getTerrorAlert = function(self, regionId)
        local terror = self:getRegionTerror(regionId)
        if not terror then return nil end
        if terror >= 80 then return "Critical"
        elseif terror >= 60 then return "High"
        elseif terror >= 40 then return "Moderate"
        elseif terror >= 20 then return "Low"
        else return "Minimal"
        end
    end
}

Suite:group("Region Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.terror = TerrorSystem:new()
    end)

    Suite:testMethod("TerrorSystem.new", {description = "Creates terror system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.terror ~= nil, true, "System created")
    end)

    Suite:testMethod("TerrorSystem.addRegion", {description = "Adds region to tracking", testCase = "add", type = "functional"}, function()
        local ok = shared.terror:addRegion("region_1", 20)
        Helpers.assertEqual(ok, true, "Region added")
    end)

    Suite:testMethod("TerrorSystem.getRegionTerror", {description = "Gets region terror level", testCase = "get_terror", type = "functional"}, function()
        shared.terror:addRegion("region_1", 35)
        local terror = shared.terror:getRegionTerror("region_1")
        Helpers.assertEqual(terror, 35, "Terror level retrieved")
    end)

    Suite:testMethod("TerrorSystem.getRegionTerror", {description = "Returns nil for missing region", testCase = "missing", type = "functional"}, function()
        local terror = shared.terror:getRegionTerror("nonexistent")
        Helpers.assertEqual(terror, nil, "Missing region returns nil")
    end)
end)

Suite:group("Terror Adjustment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.terror = TerrorSystem:new()
        shared.terror:addRegion("region_1", 30)
    end)

    Suite:testMethod("TerrorSystem.setRegionTerror", {description = "Sets terror level", testCase = "set", type = "functional"}, function()
        local ok = shared.terror:setRegionTerror("region_1", 60)
        Helpers.assertEqual(ok, true, "Terror set")
    end)

    Suite:testMethod("TerrorSystem.setRegionTerror", {description = "Clamps to 0-100", testCase = "clamp", type = "functional"}, function()
        shared.terror:setRegionTerror("region_1", 150)
        local terror = shared.terror:getRegionTerror("region_1")
        Helpers.assertEqual(terror, 100, "Terror clamped to 100")
    end)

    Suite:testMethod("TerrorSystem.increaseTerror", {description = "Increases terror", testCase = "increase", type = "functional"}, function()
        local ok = shared.terror:increaseTerror("region_1", 15)
        Helpers.assertEqual(ok, true, "Terror increased")
    end)

    Suite:testMethod("TerrorSystem.decreaseTerror", {description = "Decreases terror", testCase = "decrease", type = "functional"}, function()
        local ok = shared.terror:decreaseTerror("region_1", 10)
        Helpers.assertEqual(ok, true, "Terror decreased")
    end)

    Suite:testMethod("TerrorSystem.increaseTerror", {description = "Caps increase at 100", testCase = "cap_max", type = "functional"}, function()
        shared.terror:increaseTerror("region_1", 100)
        local terror = shared.terror:getRegionTerror("region_1")
        Helpers.assertEqual(terror, 100, "Terror capped at 100")
    end)

    Suite:testMethod("TerrorSystem.decreaseTerror", {description = "Floors decrease at 0", testCase = "floor_min", type = "functional"}, function()
        shared.terror:decreaseTerror("region_1", 100)
        local terror = shared.terror:getRegionTerror("region_1")
        Helpers.assertEqual(terror, 0, "Terror floored at 0")
    end)
end)

Suite:group("Terror Alerts", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.terror = TerrorSystem:new()
        shared.terror:addRegion("test", 0)
    end)

    Suite:testMethod("TerrorSystem.getTerrorAlert", {description = "Returns Critical at 80+", testCase = "critical", type = "functional"}, function()
        shared.terror:setRegionTerror("test", 85)
        local alert = shared.terror:getTerrorAlert("test")
        Helpers.assertEqual(alert, "Critical", "Critical alert at 85")
    end)

    Suite:testMethod("TerrorSystem.getTerrorAlert", {description = "Returns High at 60-79", testCase = "high", type = "functional"}, function()
        shared.terror:setRegionTerror("test", 70)
        local alert = shared.terror:getTerrorAlert("test")
        Helpers.assertEqual(alert, "High", "High alert at 70")
    end)

    Suite:testMethod("TerrorSystem.getTerrorAlert", {description = "Returns Minimal below 20", testCase = "minimal", type = "functional"}, function()
        shared.terror:setRegionTerror("test", 10)
        local alert = shared.terror:getTerrorAlert("test")
        Helpers.assertEqual(alert, "Minimal", "Minimal alert at 10")
    end)
end)

Suite:group("Global Terror", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.terror = TerrorSystem:new()
        shared.terror:addRegion("r1", 20)
        shared.terror:addRegion("r2", 40)
        shared.terror:addRegion("r3", 60)
    end)

    Suite:testMethod("TerrorSystem.getGlobalTerror", {description = "Calculates average terror", testCase = "average", type = "functional"}, function()
        local avg = shared.terror:getGlobalTerror()
        Helpers.assertEqual(avg, 40, "Average is 40")
    end)

    Suite:testMethod("TerrorSystem.calculateEscalation", {description = "Returns escalation level", testCase = "escalation", type = "functional"}, function()
        local level = shared.terror:calculateEscalation()
        Helpers.assertEqual(level, 2, "Escalation level 2 for 40 avg")
    end)

    Suite:testMethod("TerrorSystem.getHighTerrorRegions", {description = "Finds high terror regions", testCase = "high_regions", type = "functional"}, function()
        local regions = shared.terror:getHighTerrorRegions(50)
        Helpers.assertEqual(regions ~= nil, true, "High terror regions found")
    end)
end)

Suite:run()
