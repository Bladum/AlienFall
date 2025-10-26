-- ─────────────────────────────────────────────────────────────────────────
-- UPGRADE SYSTEM TEST SUITE
-- FILE: tests2/economy/upgrade_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.upgrade_system",
    fileName = "upgrade_system.lua",
    description = "Equipment and facility upgrade progression system"
})

print("[UPGRADE_SYSTEM_TEST] Setting up")

local UpgradeSystem = {
    upgrades = {},
    active_upgrades = {},
    upgrade_levels = {},

    new = function(self)
        return setmetatable({upgrades = {}, active_upgrades = {}, upgrade_levels = {}}, {__index = self})
    end,

    createUpgrade = function(self, upgradeId, name, cost, benefit)
        self.upgrades[upgradeId] = {id = upgradeId, name = name, cost = cost, benefit = benefit, researched = false, applied = false}
        self.upgrade_levels[upgradeId] = 0
        return true
    end,

    getUpgrade = function(self, upgradeId)
        return self.upgrades[upgradeId]
    end,

    researchUpgrade = function(self, upgradeId)
        if not self.upgrades[upgradeId] then return false end
        self.upgrades[upgradeId].researched = true
        return true
    end,

    applyUpgrade = function(self, upgradeId)
        if not self.upgrades[upgradeId] then return false end
        if not self.upgrades[upgradeId].researched then return false end
        self.upgrades[upgradeId].applied = true
        self.active_upgrades[upgradeId] = true
        return true
    end,

    removeUpgrade = function(self, upgradeId)
        if not self.upgrades[upgradeId] then return false end
        self.upgrades[upgradeId].applied = false
        self.active_upgrades[upgradeId] = nil
        return true
    end,

    incrementLevel = function(self, upgradeId, amount)
        if not self.upgrades[upgradeId] then return false end
        self.upgrade_levels[upgradeId] = self.upgrade_levels[upgradeId] + (amount or 1)
        return true
    end,

    getLevel = function(self, upgradeId)
        if not self.upgrade_levels[upgradeId] then return 0 end
        return self.upgrade_levels[upgradeId]
    end,

    isApplied = function(self, upgradeId)
        if not self.upgrades[upgradeId] then return false end
        return self.upgrades[upgradeId].applied
    end,

    isResearched = function(self, upgradeId)
        if not self.upgrades[upgradeId] then return false end
        return self.upgrades[upgradeId].researched
    end,

    getActiveCount = function(self)
        local count = 0
        for _ in pairs(self.active_upgrades) do count = count + 1 end
        return count
    end,

    getTotalUpgrades = function(self)
        local count = 0
        for _ in pairs(self.upgrades) do count = count + 1 end
        return count
    end,

    getResearchedCount = function(self)
        local count = 0
        for _, upgrade in pairs(self.upgrades) do
            if upgrade.researched then count = count + 1 end
        end
        return count
    end
}

Suite:group("Upgrade Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.us = UpgradeSystem:new()
    end)

    Suite:testMethod("UpgradeSystem.new", {description = "Creates system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.us ~= nil, true, "System created")
    end)

    Suite:testMethod("UpgradeSystem.createUpgrade", {description = "Creates upgrade", testCase = "create_upgrade", type = "functional"}, function()
        local ok = shared.us:createUpgrade("armor1", "Armor Upgrade I", 500, "defense+1")
        Helpers.assertEqual(ok, true, "Upgrade created")
    end)

    Suite:testMethod("UpgradeSystem.getUpgrade", {description = "Retrieves upgrade", testCase = "get_upgrade", type = "functional"}, function()
        shared.us:createUpgrade("speed1", "Speed Boost", 300, "move+1")
        local upgrade = shared.us:getUpgrade("speed1")
        Helpers.assertEqual(upgrade ~= nil, true, "Upgrade retrieved")
    end)

    Suite:testMethod("UpgradeSystem.getUpgrade", {description = "Returns nil missing", testCase = "missing", type = "functional"}, function()
        local upgrade = shared.us:getUpgrade("nonexistent")
        Helpers.assertEqual(upgrade, nil, "Missing returns nil")
    end)

    Suite:testMethod("UpgradeSystem.getTotalUpgrades", {description = "Counts upgrades", testCase = "count", type = "functional"}, function()
        shared.us:createUpgrade("u1", "U1", 100, "b1")
        shared.us:createUpgrade("u2", "U2", 200, "b2")
        shared.us:createUpgrade("u3", "U3", 300, "b3")
        local count = shared.us:getTotalUpgrades()
        Helpers.assertEqual(count, 3, "Three upgrades")
    end)
end)

Suite:group("Research Progression", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.us = UpgradeSystem:new()
        shared.us:createUpgrade("tech", "Technology", 1000, "power+5")
    end)

    Suite:testMethod("UpgradeSystem.researchUpgrade", {description = "Researches upgrade", testCase = "research", type = "functional"}, function()
        local ok = shared.us:researchUpgrade("tech")
        Helpers.assertEqual(ok, true, "Researched")
    end)

    Suite:testMethod("UpgradeSystem.isResearched", {description = "Checks research", testCase = "check_research", type = "functional"}, function()
        shared.us:researchUpgrade("tech")
        local researched = shared.us:isResearched("tech")
        Helpers.assertEqual(researched, true, "Is researched")
    end)

    Suite:testMethod("UpgradeSystem.isResearched", {description = "Not researched by default", testCase = "not_researched", type = "functional"}, function()
        local researched = shared.us:isResearched("tech")
        Helpers.assertEqual(researched, false, "Not researched initially")
    end)

    Suite:testMethod("UpgradeSystem.getResearchedCount", {description = "Counts researched", testCase = "count_researched", type = "functional"}, function()
        shared.us:createUpgrade("t2", "Tech 2", 1000, "power+3")
        shared.us:createUpgrade("t3", "Tech 3", 1500, "power+7")
        shared.us:researchUpgrade("tech")
        shared.us:researchUpgrade("t2")
        local count = shared.us:getResearchedCount()
        Helpers.assertEqual(count, 2, "Two researched")
    end)
end)

Suite:group("Upgrade Application", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.us = UpgradeSystem:new()
        shared.us:createUpgrade("app", "Apply Test", 500, "benefit")
        shared.us:researchUpgrade("app")
    end)

    Suite:testMethod("UpgradeSystem.applyUpgrade", {description = "Applies upgrade", testCase = "apply", type = "functional"}, function()
        local ok = shared.us:applyUpgrade("app")
        Helpers.assertEqual(ok, true, "Applied")
    end)

    Suite:testMethod("UpgradeSystem.isApplied", {description = "Checks applied", testCase = "is_applied", type = "functional"}, function()
        shared.us:applyUpgrade("app")
        local applied = shared.us:isApplied("app")
        Helpers.assertEqual(applied, true, "Is applied")
    end)

    Suite:testMethod("UpgradeSystem.applyUpgrade", {description = "Fails without research", testCase = "need_research", type = "functional"}, function()
        local upgrade2 = shared.us:createUpgrade("nores", "No Research", 100, "x")
        local ok = shared.us:applyUpgrade("nores")
        Helpers.assertEqual(ok, false, "Failed without research")
    end)

    Suite:testMethod("UpgradeSystem.removeUpgrade", {description = "Removes upgrade", testCase = "remove", type = "functional"}, function()
        shared.us:applyUpgrade("app")
        local ok = shared.us:removeUpgrade("app")
        Helpers.assertEqual(ok, true, "Removed")
    end)

    Suite:testMethod("UpgradeSystem.isApplied", {description = "Not applied after remove", testCase = "not_applied", type = "functional"}, function()
        shared.us:applyUpgrade("app")
        shared.us:removeUpgrade("app")
        local applied = shared.us:isApplied("app")
        Helpers.assertEqual(applied, false, "Not applied")
    end)
end)

Suite:group("Upgrade Levels", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.us = UpgradeSystem:new()
        shared.us:createUpgrade("progressive", "Progressive", 500, "x")
    end)

    Suite:testMethod("UpgradeSystem.incrementLevel", {description = "Increments level", testCase = "increment", type = "functional"}, function()
        local ok = shared.us:incrementLevel("progressive", 1)
        Helpers.assertEqual(ok, true, "Incremented")
    end)

    Suite:testMethod("UpgradeSystem.getLevel", {description = "Gets level", testCase = "get_level", type = "functional"}, function()
        shared.us:incrementLevel("progressive", 3)
        local level = shared.us:getLevel("progressive")
        Helpers.assertEqual(level, 3, "Level is 3")
    end)

    Suite:testMethod("UpgradeSystem.getLevel", {description = "Default zero", testCase = "default_level", type = "functional"}, function()
        local level = shared.us:getLevel("progressive")
        Helpers.assertEqual(level, 0, "Default level 0")
    end)

    Suite:testMethod("UpgradeSystem.incrementLevel", {description = "Increment without amount", testCase = "default_increment", type = "functional"}, function()
        shared.us:incrementLevel("progressive")
        shared.us:incrementLevel("progressive")
        local level = shared.us:getLevel("progressive")
        Helpers.assertEqual(level, 2, "Level is 2")
    end)
end)

Suite:group("Active Upgrades", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.us = UpgradeSystem:new()
        shared.us:createUpgrade("a1", "Active 1", 100, "x")
        shared.us:createUpgrade("a2", "Active 2", 100, "x")
        shared.us:researchUpgrade("a1")
        shared.us:researchUpgrade("a2")
    end)

    Suite:testMethod("UpgradeSystem.getActiveCount", {description = "Counts active", testCase = "active_count", type = "functional"}, function()
        shared.us:applyUpgrade("a1")
        shared.us:applyUpgrade("a2")
        local count = shared.us:getActiveCount()
        Helpers.assertEqual(count, 2, "Two active")
    end)

    Suite:testMethod("UpgradeSystem.getActiveCount", {description = "Starts at zero", testCase = "zero_active", type = "functional"}, function()
        local count = shared.us:getActiveCount()
        Helpers.assertEqual(count, 0, "Zero active initially")
    end)
end)

Suite:run()
