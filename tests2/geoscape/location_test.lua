-- ─────────────────────────────────────────────────────────────────────────
-- LOCATION SYSTEM TEST SUITE
-- FILE: tests2/geoscape/location_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.world.location_system",
    fileName = "location_system.lua",
    description = "Location and site management for geoscape world"
})

print("[LOCATION_TEST] Setting up")

local LocationSystem = {
    locations = {},
    occupants = {},

    new = function(self)
        return setmetatable({locations = {}, occupants = {}}, {__index = self})
    end,

    createLocation = function(self, locId, name, locType, x, y)
        self.locations[locId] = {id = locId, name = name, type = locType, x = x, y = y, active = true}
        self.occupants[locId] = {}
        return true
    end,

    getLocation = function(self, locId)
        return self.locations[locId]
    end,

    setActive = function(self, locId, active)
        if not self.locations[locId] then return false end
        self.locations[locId].active = active
        return true
    end,

    isActive = function(self, locId)
        if not self.locations[locId] then return nil end
        return self.locations[locId].active
    end,

    addOccupant = function(self, locId, occupantId)
        if not self.locations[locId] then return false end
        self.occupants[locId][occupantId] = true
        return true
    end,

    removeOccupant = function(self, locId, occupantId)
        if not self.locations[locId] then return false end
        self.occupants[locId][occupantId] = nil
        return true
    end,

    getOccupantCount = function(self, locId)
        if not self.locations[locId] then return 0 end
        local count = 0
        for _ in pairs(self.occupants[locId]) do count = count + 1 end
        return count
    end,

    getLocationsByType = function(self, locType)
        local result = {}
        for id, loc in pairs(self.locations) do
            if loc.type == locType then table.insert(result, id) end
        end
        return result
    end,

    getLocationCount = function(self)
        local count = 0
        for _ in pairs(self.locations) do count = count + 1 end
        return count
    end
}

Suite:group("Location Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.locs = LocationSystem:new()
    end)

    Suite:testMethod("LocationSystem.new", {description = "Creates location system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.locs ~= nil, true, "System created")
    end)

    Suite:testMethod("LocationSystem.createLocation", {description = "Creates location", testCase = "create_loc", type = "functional"}, function()
        local ok = shared.locs:createLocation("base1", "Base Alpha", "base", 10, 20)
        Helpers.assertEqual(ok, true, "Location created")
    end)

    Suite:testMethod("LocationSystem.getLocation", {description = "Retrieves location", testCase = "get_loc", type = "functional"}, function()
        shared.locs:createLocation("site1", "Site One", "research", 5, 5)
        local loc = shared.locs:getLocation("site1")
        Helpers.assertEqual(loc ~= nil, true, "Location retrieved")
    end)

    Suite:testMethod("LocationSystem.getLocation", {description = "Returns nil for missing", testCase = "missing", type = "functional"}, function()
        local loc = shared.locs:getLocation("nonexistent")
        Helpers.assertEqual(loc, nil, "Missing location returns nil")
    end)

    Suite:testMethod("LocationSystem.getLocationCount", {description = "Counts locations", testCase = "count", type = "functional"}, function()
        shared.locs:createLocation("l1", "Loc 1", "base", 0, 0)
        shared.locs:createLocation("l2", "Loc 2", "mission", 1, 1)
        shared.locs:createLocation("l3", "Loc 3", "base", 2, 2)
        local count = shared.locs:getLocationCount()
        Helpers.assertEqual(count, 3, "Three locations counted")
    end)
end)

Suite:group("Location Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.locs = LocationSystem:new()
        shared.locs:createLocation("active", "Active", "base", 0, 0)
    end)

    Suite:testMethod("LocationSystem.setActive", {description = "Sets active status", testCase = "set_active", type = "functional"}, function()
        local ok = shared.locs:setActive("active", false)
        Helpers.assertEqual(ok, true, "Status set")
    end)

    Suite:testMethod("LocationSystem.isActive", {description = "Gets active status", testCase = "check_active", type = "functional"}, function()
        local active = shared.locs:isActive("active")
        Helpers.assertEqual(active, true, "Location is active")
    end)

    Suite:testMethod("LocationSystem.setActive", {description = "Deactivates location", testCase = "deactivate", type = "functional"}, function()
        shared.locs:setActive("active", false)
        local active = shared.locs:isActive("active")
        Helpers.assertEqual(active, false, "Location deactivated")
    end)

    Suite:testMethod("LocationSystem.isActive", {description = "Returns nil for missing", testCase = "missing_status", type = "functional"}, function()
        local active = shared.locs:isActive("nonexistent")
        Helpers.assertEqual(active, nil, "Missing location returns nil")
    end)
end)

Suite:group("Location Occupants", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.locs = LocationSystem:new()
        shared.locs:createLocation("garrison", "Garrison", "base", 0, 0)
    end)

    Suite:testMethod("LocationSystem.addOccupant", {description = "Adds occupant", testCase = "add", type = "functional"}, function()
        local ok = shared.locs:addOccupant("garrison", "unit1")
        Helpers.assertEqual(ok, true, "Occupant added")
    end)

    Suite:testMethod("LocationSystem.getOccupantCount", {description = "Counts occupants", testCase = "count", type = "functional"}, function()
        shared.locs:addOccupant("garrison", "unit1")
        shared.locs:addOccupant("garrison", "unit2")
        local count = shared.locs:getOccupantCount("garrison")
        Helpers.assertEqual(count, 2, "Two occupants")
    end)

    Suite:testMethod("LocationSystem.removeOccupant", {description = "Removes occupant", testCase = "remove", type = "functional"}, function()
        shared.locs:addOccupant("garrison", "unit1")
        local ok = shared.locs:removeOccupant("garrison", "unit1")
        Helpers.assertEqual(ok, true, "Occupant removed")
    end)

    Suite:testMethod("LocationSystem.getOccupantCount", {description = "Count after removal", testCase = "count_after", type = "functional"}, function()
        shared.locs:addOccupant("garrison", "unit1")
        shared.locs:addOccupant("garrison", "unit2")
        shared.locs:removeOccupant("garrison", "unit1")
        local count = shared.locs:getOccupantCount("garrison")
        Helpers.assertEqual(count, 1, "One occupant after removal")
    end)
end)

Suite:group("Location Queries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.locs = LocationSystem:new()
        shared.locs:createLocation("base1", "Base 1", "base", 0, 0)
        shared.locs:createLocation("base2", "Base 2", "base", 1, 1)
        shared.locs:createLocation("mission1", "Mission 1", "mission", 2, 2)
    end)

    Suite:testMethod("LocationSystem.getLocationsByType", {description = "Filters by type", testCase = "filter", type = "functional"}, function()
        local bases = shared.locs:getLocationsByType("base")
        Helpers.assertEqual(bases ~= nil, true, "Filtered results returned")
    end)

    Suite:testMethod("LocationSystem.getLocationsByType", {description = "Finds two bases", testCase = "two_bases", type = "functional"}, function()
        local bases = shared.locs:getLocationsByType("base")
        local count = #bases
        Helpers.assertEqual(count, 2, "Two bases found")
    end)

    Suite:testMethod("LocationSystem.getLocationsByType", {description = "Returns empty for none", testCase = "no_match", type = "functional"}, function()
        local results = shared.locs:getLocationsByType("unknown")
        local count = #results
        Helpers.assertEqual(count, 0, "No unknown types found")
    end)
end)

Suite:run()
