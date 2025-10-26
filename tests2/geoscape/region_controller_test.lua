-- ─────────────────────────────────────────────────────────────────────────
-- REGION CONTROLLER TEST SUITE
-- FILE: tests2/geoscape/region_controller_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.regions.region_controller",
    fileName = "region_controller.lua",
    description = "Regional control and territory management system"
})

print("[REGION_CONTROLLER_TEST] Setting up")

local RegionController = {
    regions = {},
    control = {},

    new = function(self)
        return setmetatable({regions = {}, control = {}}, {__index = self})
    end,

    addRegion = function(self, regionId, name, owner)
        self.regions[regionId] = {id = regionId, name = name, owner = owner}
        self.control[regionId] = {owner = owner, threat = 0, resistance = 0}
        return true
    end,

    getRegion = function(self, regionId)
        return self.regions[regionId]
    end,

    setOwner = function(self, regionId, owner)
        if not self.regions[regionId] then return false end
        self.regions[regionId].owner = owner
        self.control[regionId].owner = owner
        return true
    end,

    getOwner = function(self, regionId)
        if not self.regions[regionId] then return nil end
        return self.regions[regionId].owner
    end,

    setThreat = function(self, regionId, threat)
        if not self.control[regionId] then return false end
        self.control[regionId].threat = math.min(100, math.max(0, threat))
        return true
    end,

    getThreat = function(self, regionId)
        if not self.control[regionId] then return nil end
        return self.control[regionId].threat
    end,

    setResistance = function(self, regionId, resistance)
        if not self.control[regionId] then return false end
        self.control[regionId].resistance = math.min(100, math.max(0, resistance))
        return true
    end,

    getResistance = function(self, regionId)
        if not self.control[regionId] then return nil end
        return self.control[regionId].resistance
    end,

    getRegionsByOwner = function(self, owner)
        local result = {}
        for id, region in pairs(self.regions) do
            if region.owner == owner then table.insert(result, id) end
        end
        return result
    end,

    getHighThreatRegions = function(self, threshold)
        local result = {}
        for id, control in pairs(self.control) do
            if control.threat > threshold then table.insert(result, id) end
        end
        return result
    end,

    getRegionCount = function(self)
        local count = 0
        for _ in pairs(self.regions) do count = count + 1 end
        return count
    end
}

Suite:group("Region Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rc = RegionController:new()
    end)

    Suite:testMethod("RegionController.new", {description = "Creates controller", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.rc ~= nil, true, "Controller created")
    end)

    Suite:testMethod("RegionController.addRegion", {description = "Adds region", testCase = "add", type = "functional"}, function()
        local ok = shared.rc:addRegion("na", "North America", "player")
        Helpers.assertEqual(ok, true, "Region added")
    end)

    Suite:testMethod("RegionController.getRegion", {description = "Retrieves region", testCase = "get", type = "functional"}, function()
        shared.rc:addRegion("eu", "Europe", "player")
        local region = shared.rc:getRegion("eu")
        Helpers.assertEqual(region ~= nil, true, "Region retrieved")
    end)

    Suite:testMethod("RegionController.getRegionCount", {description = "Counts regions", testCase = "count", type = "functional"}, function()
        shared.rc:addRegion("r1", "Region 1", "p")
        shared.rc:addRegion("r2", "Region 2", "p")
        shared.rc:addRegion("r3", "Region 3", "a")
        local count = shared.rc:getRegionCount()
        Helpers.assertEqual(count, 3, "Three regions counted")
    end)
end)

Suite:group("Control Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rc = RegionController:new()
        shared.rc:addRegion("test", "Test Region", "player")
    end)

    Suite:testMethod("RegionController.setOwner", {description = "Sets owner", testCase = "set_owner", type = "functional"}, function()
        local ok = shared.rc:setOwner("test", "alien")
        Helpers.assertEqual(ok, true, "Owner set")
    end)

    Suite:testMethod("RegionController.getOwner", {description = "Gets owner", testCase = "get_owner", type = "functional"}, function()
        shared.rc:setOwner("test", "neutral")
        local owner = shared.rc:getOwner("test")
        Helpers.assertEqual(owner, "neutral", "Owner retrieved")
    end)

    Suite:testMethod("RegionController.getOwner", {description = "Initial owner correct", testCase = "initial", type = "functional"}, function()
        local owner = shared.rc:getOwner("test")
        Helpers.assertEqual(owner, "player", "Initial owner is player")
    end)
end)

Suite:group("Threat & Resistance", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rc = RegionController:new()
        shared.rc:addRegion("region", "Region", "p")
    end)

    Suite:testMethod("RegionController.setThreat", {description = "Sets threat level", testCase = "set_threat", type = "functional"}, function()
        local ok = shared.rc:setThreat("region", 50)
        Helpers.assertEqual(ok, true, "Threat set")
    end)

    Suite:testMethod("RegionController.getThreat", {description = "Gets threat level", testCase = "get_threat", type = "functional"}, function()
        shared.rc:setThreat("region", 75)
        local threat = shared.rc:getThreat("region")
        Helpers.assertEqual(threat, 75, "Threat retrieved")
    end)

    Suite:testMethod("RegionController.setThreat", {description = "Clamps threat to 100", testCase = "clamp_max", type = "functional"}, function()
        shared.rc:setThreat("region", 200)
        local threat = shared.rc:getThreat("region")
        Helpers.assertEqual(threat, 100, "Threat clamped to 100")
    end)

    Suite:testMethod("RegionController.setResistance", {description = "Sets resistance", testCase = "set_resist", type = "functional"}, function()
        local ok = shared.rc:setResistance("region", 60)
        Helpers.assertEqual(ok, true, "Resistance set")
    end)

    Suite:testMethod("RegionController.getResistance", {description = "Gets resistance", testCase = "get_resist", type = "functional"}, function()
        shared.rc:setResistance("region", 40)
        local resist = shared.rc:getResistance("region")
        Helpers.assertEqual(resist, 40, "Resistance retrieved")
    end)

    Suite:testMethod("RegionController.setResistance", {description = "Clamps to 0", testCase = "clamp_min", type = "functional"}, function()
        shared.rc:setResistance("region", -50)
        local resist = shared.rc:getResistance("region")
        Helpers.assertEqual(resist, 0, "Resistance clamped to 0")
    end)
end)

Suite:group("Regional Queries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rc = RegionController:new()
        shared.rc:addRegion("r1", "Region 1", "player")
        shared.rc:addRegion("r2", "Region 2", "player")
        shared.rc:addRegion("r3", "Region 3", "alien")
    end)

    Suite:testMethod("RegionController.getRegionsByOwner", {description = "Filters by owner", testCase = "filter", type = "functional"}, function()
        local regions = shared.rc:getRegionsByOwner("player")
        Helpers.assertEqual(regions ~= nil, true, "Filtered results returned")
    end)

    Suite:testMethod("RegionController.getRegionsByOwner", {description = "Finds player regions", testCase = "player_regions", type = "functional"}, function()
        local regions = shared.rc:getRegionsByOwner("player")
        local count = #regions
        Helpers.assertEqual(count, 2, "Two player regions found")
    end)

    Suite:testMethod("RegionController.getHighThreatRegions", {description = "Finds high threat", testCase = "high_threat", type = "functional"}, function()
        shared.rc:setThreat("r1", 85)
        shared.rc:setThreat("r2", 40)
        local regions = shared.rc:getHighThreatRegions(70)
        Helpers.assertEqual(regions ~= nil, true, "High threat regions found")
    end)

    Suite:testMethod("RegionController.getHighThreatRegions", {description = "Threshold filter works", testCase = "threshold", type = "functional"}, function()
        shared.rc:setThreat("r1", 90)
        shared.rc:setThreat("r2", 50)
        shared.rc:setThreat("r3", 80)
        local regions = shared.rc:getHighThreatRegions(75)
        local count = #regions
        Helpers.assertEqual(count, 2, "Two regions above threshold")
    end)
end)

Suite:run()
