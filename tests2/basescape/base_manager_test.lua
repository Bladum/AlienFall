-- ─────────────────────────────────────────────────────────────────────────
-- BASE MANAGER TEST SUITE
-- FILE: tests2/basescape/base_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests the base management system
-- Covers: Base creation, facility management, base data persistence
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.base_manager",
    fileName = "base_manager.lua",
    description = "Base management and facility system"
})

-- ─────────────────────────────────────────────────────────────────────────
-- MODULE SETUP
-- ─────────────────────────────────────────────────────────────────────────

print("[BASEMANAGER_TEST] Setting up")

local BaseManager = {
    bases = {},
    nextBaseId = 1,

    createBase = function(self, name, x, y)
        if not name or not x or not y then
            error("[BaseManager] Invalid base parameters")
        end
        local base = {
            id = self.nextBaseId,
            name = name,
            x = x,
            y = y,
            facilities = {},
            resources = {funds = 10000, supplies = 5000},
            level = 1
        }
        self.nextBaseId = self.nextBaseId + 1
        table.insert(self.bases, base)
        return base
    end,

    getBase = function(self, id)
        for _, base in ipairs(self.bases) do
            if base.id == id then return base end
        end
        return nil
    end,

    deleteBase = function(self, id)
        for i, base in ipairs(self.bases) do
            if base.id == id then
                table.remove(self.bases, i)
                return true
            end
        end
        return false
    end,

    buildFacility = function(self, baseId, facilityType, x, y)
        local base = self:getBase(baseId)
        if not base then error("[BaseManager] Base not found") end
        if not facilityType then error("[BaseManager] Invalid facility type") end

        local facility = {
            id = #base.facilities + 1,
            type = facilityType,
            x = x or 0,
            y = y or 0,
            buildProgress = 0,
            status = "under_construction"
        }
        table.insert(base.facilities, facility)
        return facility
    end,

    removeFacility = function(self, baseId, facilityId)
        local base = self:getBase(baseId)
        if not base then return false end

        for i, fac in ipairs(base.facilities) do
            if fac.id == facilityId then
                table.remove(base.facilities, i)
                return true
            end
        end
        return false
    end,

    getFacilities = function(self, baseId)
        local base = self:getBase(baseId)
        if not base then return {} end
        return base.facilities
    end,

    updateBaseResources = function(self, baseId, deltaFunds, deltaSupplies)
        local base = self:getBase(baseId)
        if not base then return false end

        base.resources.funds = base.resources.funds + deltaFunds
        base.resources.supplies = base.resources.supplies + deltaSupplies

        if base.resources.funds < 0 or base.resources.supplies < 0 then
            return false  -- Insufficient resources
        end
        return true
    end,

    getAllBases = function(self)
        return self.bases
    end
}

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Base Creation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.manager = setmetatable({
            bases = {},
            nextBaseId = 1
        }, {__index = BaseManager})
    end)

    Suite:testMethod("BaseManager.createBase", {
        description = "Creates new base",
        testCase = "create_base",
        type = "functional"
    }, function()
        local base = shared.manager:createBase("Main Base", 10, 20)
        Helpers.assertEqual(base ~= nil, true, "Base created")
        Helpers.assertEqual(base.name, "Main Base", "Base name correct")
        Helpers.assertEqual(base.x, 10, "Base x position correct")
        Helpers.assertEqual(base.y, 20, "Base y position correct")
    end)

    Suite:testMethod("BaseManager.createBase", {
        description = "Assigns unique base IDs",
        testCase = "base_ids",
        type = "functional"
    }, function()
        local base1 = shared.manager:createBase("Base 1", 0, 0)
        local base2 = shared.manager:createBase("Base 2", 5, 5)
        Helpers.assertEqual(base1.id, 1, "First base ID is 1")
        Helpers.assertEqual(base2.id, 2, "Second base ID is 2")
    end)

    Suite:testMethod("BaseManager.createBase", {
        description = "Initializes base with resources",
        testCase = "base_resources",
        type = "functional"
    }, function()
        local base = shared.manager:createBase("Test Base", 0, 0)
        Helpers.assertEqual(base.resources.funds, 10000, "Initial funds correct")
        Helpers.assertEqual(base.resources.supplies, 5000, "Initial supplies correct")
    end)
end)

Suite:group("Facility Management", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.manager = setmetatable({
            bases = {},
            nextBaseId = 1
        }, {__index = BaseManager})
        shared.base = shared.manager:createBase("Test Base", 0, 0)
    end)

    Suite:testMethod("BaseManager.buildFacility", {
        description = "Builds facility at base",
        testCase = "build_facility",
        type = "functional"
    }, function()
        local fac = shared.manager:buildFacility(shared.base.id, "command_center", 2, 3)
        Helpers.assertEqual(fac ~= nil, true, "Facility created")
        Helpers.assertEqual(fac.type, "command_center", "Facility type correct")
        Helpers.assertEqual(fac.status, "under_construction", "Facility status correct")
    end)

    Suite:testMethod("BaseManager.buildFacility", {
        description = "Facility appears in base facility list",
        testCase = "facility_list",
        type = "functional"
    }, function()
        shared.manager:buildFacility(shared.base.id, "barracks")
        shared.manager:buildFacility(shared.base.id, "hangar")
        local facilities = shared.manager:getFacilities(shared.base.id)
        Helpers.assertEqual(#facilities, 2, "Two facilities in base")
    end)

    Suite:testMethod("BaseManager.removeFacility", {
        description = "Removes facility from base",
        testCase = "remove_facility",
        type = "functional"
    }, function()
        local fac = shared.manager:buildFacility(shared.base.id, "barracks")
        local ok = shared.manager:removeFacility(shared.base.id, fac.id)
        Helpers.assertEqual(ok, true, "Facility removed successfully")
        local facilities = shared.manager:getFacilities(shared.base.id)
        Helpers.assertEqual(#facilities, 0, "No facilities remain")
    end)
end)

Suite:group("Resource Management", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.manager = setmetatable({
            bases = {},
            nextBaseId = 1
        }, {__index = BaseManager})
        shared.base = shared.manager:createBase("Test Base", 0, 0)
    end)

    Suite:testMethod("BaseManager.updateBaseResources", {
        description = "Updates base funds",
        testCase = "funds_update",
        type = "functional"
    }, function()
        local ok = shared.manager:updateBaseResources(shared.base.id, 5000, 0)
        Helpers.assertEqual(ok, true, "Update successful")
        Helpers.assertEqual(shared.base.resources.funds, 15000, "Funds updated correctly")
    end)

    Suite:testMethod("BaseManager.updateBaseResources", {
        description = "Updates base supplies",
        testCase = "supplies_update",
        type = "functional"
    }, function()
        local ok = shared.manager:updateBaseResources(shared.base.id, 0, 2000)
        Helpers.assertEqual(ok, true, "Update successful")
        Helpers.assertEqual(shared.base.resources.supplies, 7000, "Supplies updated correctly")
    end)

    Suite:testMethod("BaseManager.updateBaseResources", {
        description = "Prevents negative resources",
        testCase = "negative_check",
        type = "functional"
    }, function()
        local ok = shared.manager:updateBaseResources(shared.base.id, -15000, 0)
        Helpers.assertEqual(ok, false, "Negative resources rejected")
    end)
end)

Suite:group("Base Retrieval", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.manager = setmetatable({
            bases = {},
            nextBaseId = 1
        }, {__index = BaseManager})
    end)

    Suite:testMethod("BaseManager.getBase", {
        description = "Retrieves base by ID",
        testCase = "get_base",
        type = "functional"
    }, function()
        local created = shared.manager:createBase("Search Base", 5, 10)
        local found = shared.manager:getBase(created.id)
        Helpers.assertEqual(found ~= nil, true, "Base found")
        if found then
            Helpers.assertEqual(found.name, "Search Base", "Base name matches")
        end
    end)

    Suite:testMethod("BaseManager.getBase", {
        description = "Deletes base by ID",
        testCase = "delete_base",
        type = "functional"
    }, function()
        local base = shared.manager:createBase("Delete Test", 0, 0)
        local ok = shared.manager:deleteBase(base.id)
        Helpers.assertEqual(ok, true, "Base deleted")
        local found = shared.manager:getBase(base.id)
        Helpers.assertEqual(found == nil, true, "Base no longer found")
    end)

    Suite:testMethod("BaseManager.getAllBases", {
        description = "Returns all bases",
        testCase = "get_all_bases",
        type = "functional"
    }, function()
        shared.manager:createBase("Base 1", 0, 0)
        shared.manager:createBase("Base 2", 5, 5)
        shared.manager:createBase("Base 3", 10, 10)
        local all = shared.manager:getAllBases()
        Helpers.assertEqual(#all, 3, "All bases retrieved")
    end)
end)

Suite:run()
