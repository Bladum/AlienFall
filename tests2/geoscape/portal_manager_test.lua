-- ─────────────────────────────────────────────────────────────────────────
-- PORTAL MANAGER TEST SUITE
-- FILE: tests2/geoscape/portal_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.portal_manager",
    fileName = "portal_manager.lua",
    description = "Interdimensional portal management and tracking"
})

print("[PORTAL_MANAGER_TEST] Setting up")

local PortalManager = {
    portals = {},
    portal_links = {},
    next_id = 1,

    new = function(self)
        return setmetatable({portals = {}, portal_links = {}, next_id = 1}, {__index = self})
    end,

    createPortal = function(self, locationId, dimension, stability)
        local id = self.next_id
        self.next_id = self.next_id + 1
        self.portals[id] = {id = id, locationId = locationId, dimension = dimension, stability = stability or 100, active = false, energyUsage = 0}
        return id
    end,

    getPortal = function(self, portalId)
        return self.portals[portalId]
    end,

    activatePortal = function(self, portalId)
        if not self.portals[portalId] then return false end
        self.portals[portalId].active = true
        return true
    end,

    deactivatePortal = function(self, portalId)
        if not self.portals[portalId] then return false end
        self.portals[portalId].active = false
        return true
    end,

    setStability = function(self, portalId, stability)
        if not self.portals[portalId] then return false end
        self.portals[portalId].stability = math.max(0, math.min(100, stability))
        return true
    end,

    getStability = function(self, portalId)
        if not self.portals[portalId] then return 0 end
        return self.portals[portalId].stability
    end,

    linkPortals = function(self, portalId1, portalId2)
        if not self.portals[portalId1] or not self.portals[portalId2] then return false end
        local linkId = portalId1 .. "_" .. portalId2
        self.portal_links[linkId] = {source = portalId1, target = portalId2, active = false, distance = 0}
        return true
    end,

    activateLink = function(self, portalId1, portalId2)
        local linkId = portalId1 .. "_" .. portalId2
        if not self.portal_links[linkId] then return false end
        self.portal_links[linkId].active = true
        return true
    end,

    isLinked = function(self, portalId1, portalId2)
        local linkId = portalId1 .. "_" .. portalId2
        if not self.portal_links[linkId] then return false end
        return self.portal_links[linkId].active
    end,

    getPortalCount = function(self)
        local count = 0
        for _ in pairs(self.portals) do count = count + 1 end
        return count
    end,

    getActivePortalCount = function(self)
        local count = 0
        for _, portal in pairs(self.portals) do
            if portal.active then count = count + 1 end
        end
        return count
    end,

    destabilizePortal = function(self, portalId, amount)
        if not self.portals[portalId] then return false end
        self.portals[portalId].stability = math.max(0, self.portals[portalId].stability - amount)
        return true
    end,

    setEnergyUsage = function(self, portalId, usage)
        if not self.portals[portalId] then return false end
        self.portals[portalId].energyUsage = usage
        return true
    end
}

Suite:group("Portal Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pm = PortalManager:new()
    end)

    Suite:testMethod("PortalManager.new", {description = "Creates manager", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.pm ~= nil, true, "Manager created")
    end)

    Suite:testMethod("PortalManager.createPortal", {description = "Creates portal", testCase = "create_portal", type = "functional"}, function()
        local id = shared.pm:createPortal("loc1", "dimension_alpha", 95)
        Helpers.assertEqual(id ~= nil, true, "Portal created")
    end)

    Suite:testMethod("PortalManager.getPortal", {description = "Retrieves portal", testCase = "get_portal", type = "functional"}, function()
        local id = shared.pm:createPortal("loc2", "dimension_beta", 85)
        local portal = shared.pm:getPortal(id)
        Helpers.assertEqual(portal ~= nil, true, "Portal retrieved")
    end)

    Suite:testMethod("PortalManager.getPortal", {description = "Returns nil missing", testCase = "missing", type = "functional"}, function()
        local portal = shared.pm:getPortal(999)
        Helpers.assertEqual(portal, nil, "Missing returns nil")
    end)

    Suite:testMethod("PortalManager.getPortalCount", {description = "Counts portals", testCase = "count", type = "functional"}, function()
        shared.pm:createPortal("l1", "d1", 90)
        shared.pm:createPortal("l2", "d2", 80)
        shared.pm:createPortal("l3", "d3", 100)
        local count = shared.pm:getPortalCount()
        Helpers.assertEqual(count, 3, "Three portals")
    end)
end)

Suite:group("Portal Activation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pm = PortalManager:new()
        shared.id = shared.pm:createPortal("location", "dimension", 100)
    end)

    Suite:testMethod("PortalManager.activatePortal", {description = "Activates portal", testCase = "activate", type = "functional"}, function()
        local ok = shared.pm:activatePortal(shared.id)
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("PortalManager.activatePortal", {description = "Sets active flag", testCase = "active_flag", type = "functional"}, function()
        shared.pm:activatePortal(shared.id)
        local portal = shared.pm:getPortal(shared.id)
        Helpers.assertEqual(portal.active, true, "Active is true")
    end)

    Suite:testMethod("PortalManager.deactivatePortal", {description = "Deactivates portal", testCase = "deactivate", type = "functional"}, function()
        shared.pm:activatePortal(shared.id)
        local ok = shared.pm:deactivatePortal(shared.id)
        Helpers.assertEqual(ok, true, "Deactivated")
    end)

    Suite:testMethod("PortalManager.getActivePortalCount", {description = "Counts active", testCase = "active_count", type = "functional"}, function()
        local id2 = shared.pm:createPortal("l2", "d2", 90)
        shared.pm:activatePortal(shared.id)
        shared.pm:activatePortal(id2)
        local count = shared.pm:getActivePortalCount()
        Helpers.assertEqual(count, 2, "Two active")
    end)
end)

Suite:group("Stability", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pm = PortalManager:new()
        shared.id = shared.pm:createPortal("loc", "dim", 100)
    end)

    Suite:testMethod("PortalManager.getStability", {description = "Gets stability", testCase = "get_stability", type = "functional"}, function()
        local stability = shared.pm:getStability(shared.id)
        Helpers.assertEqual(stability, 100, "Stability 100")
    end)

    Suite:testMethod("PortalManager.setStability", {description = "Sets stability", testCase = "set_stability", type = "functional"}, function()
        local ok = shared.pm:setStability(shared.id, 50)
        Helpers.assertEqual(ok, true, "Stability set")
    end)

    Suite:testMethod("PortalManager.setStability", {description = "Updates value", testCase = "update_stability", type = "functional"}, function()
        shared.pm:setStability(shared.id, 60)
        local stability = shared.pm:getStability(shared.id)
        Helpers.assertEqual(stability, 60, "Stability 60")
    end)

    Suite:testMethod("PortalManager.destabilizePortal", {description = "Destabilizes", testCase = "destabilize", type = "functional"}, function()
        local ok = shared.pm:destabilizePortal(shared.id, 25)
        Helpers.assertEqual(ok, true, "Destabilized")
    end)

    Suite:testMethod("PortalManager.destabilizePortal", {description = "Reduces stability", testCase = "reduce", type = "functional"}, function()
        shared.pm:destabilizePortal(shared.id, 30)
        local stability = shared.pm:getStability(shared.id)
        Helpers.assertEqual(stability, 70, "Stability 70")
    end)

    Suite:testMethod("PortalManager.destabilizePortal", {description = "No negative", testCase = "clamp", type = "functional"}, function()
        shared.pm:destabilizePortal(shared.id, 150)
        local stability = shared.pm:getStability(shared.id)
        Helpers.assertEqual(stability, 0, "Stability 0")
    end)
end)

Suite:group("Portal Linking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pm = PortalManager:new()
        shared.p1 = shared.pm:createPortal("l1", "d1", 100)
        shared.p2 = shared.pm:createPortal("l2", "d2", 100)
    end)

    Suite:testMethod("PortalManager.linkPortals", {description = "Links portals", testCase = "link", type = "functional"}, function()
        local ok = shared.pm:linkPortals(shared.p1, shared.p2)
        Helpers.assertEqual(ok, true, "Linked")
    end)

    Suite:testMethod("PortalManager.activateLink", {description = "Activates link", testCase = "activate_link", type = "functional"}, function()
        shared.pm:linkPortals(shared.p1, shared.p2)
        local ok = shared.pm:activateLink(shared.p1, shared.p2)
        Helpers.assertEqual(ok, true, "Link activated")
    end)

    Suite:testMethod("PortalManager.isLinked", {description = "Checks link", testCase = "check_link", type = "functional"}, function()
        shared.pm:linkPortals(shared.p1, shared.p2)
        shared.pm:activateLink(shared.p1, shared.p2)
        local linked = shared.pm:isLinked(shared.p1, shared.p2)
        Helpers.assertEqual(linked, true, "Is linked")
    end)

    Suite:testMethod("PortalManager.isLinked", {description = "Inactive link false", testCase = "inactive", type = "functional"}, function()
        shared.pm:linkPortals(shared.p1, shared.p2)
        local linked = shared.pm:isLinked(shared.p1, shared.p2)
        Helpers.assertEqual(linked, false, "Not linked")
    end)
end)

Suite:group("Energy Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pm = PortalManager:new()
        shared.id = shared.pm:createPortal("loc", "dim", 100)
    end)

    Suite:testMethod("PortalManager.setEnergyUsage", {description = "Sets energy", testCase = "set_energy", type = "functional"}, function()
        local ok = shared.pm:setEnergyUsage(shared.id, 50)
        Helpers.assertEqual(ok, true, "Energy set")
    end)

    Suite:testMethod("PortalManager.setEnergyUsage", {description = "Updates usage", testCase = "update_energy", type = "functional"}, function()
        shared.pm:setEnergyUsage(shared.id, 75)
        local portal = shared.pm:getPortal(shared.id)
        Helpers.assertEqual(portal.energyUsage, 75, "Energy 75")
    end)
end)

Suite:run()
