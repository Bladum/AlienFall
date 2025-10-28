-- ─────────────────────────────────────────────────────────────────────────
-- TECH TREE SYSTEM TEST SUITE
-- FILE: tests2/economy/tech_tree_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.tech_tree_system",
    fileName = "tech_tree_system.lua",
    description = "Technology tree progression and unlocking system"
})

print("[TECH_TREE_SYSTEM_TEST] Setting up")

local TechTreeSystem = {
    technologies = {},
    researched = {},
    dependencies = {},

    new = function(self)
        return setmetatable({technologies = {}, researched = {}, dependencies = {}}, {__index = self})
    end,

    addTechnology = function(self, techId, name, cost, category)
        self.technologies[techId] = {id = techId, name = name, cost = cost, category = category or "general", researched = false, timeToResearch = 100}
        self.dependencies[techId] = {}
        return true
    end,

    getTechnology = function(self, techId)
        return self.technologies[techId]
    end,

    addDependency = function(self, techId, dependsOn)
        if not self.technologies[techId] or not self.technologies[dependsOn] then return false end
        table.insert(self.dependencies[techId], dependsOn)
        return true
    end,

    researchTech = function(self, techId)
        if not self.technologies[techId] then return false end
        for _, dep in ipairs(self.dependencies[techId]) do
            if not self.researched[dep] then return false end
        end
        self.technologies[techId].researched = true
        self.researched[techId] = true
        return true
    end,

    isResearched = function(self, techId)
        if not self.technologies[techId] then return false end
        return self.technologies[techId].researched
    end,

    canResearch = function(self, techId)
        if not self.technologies[techId] then return false end
        if self.technologies[techId].researched then return false end
        for _, dep in ipairs(self.dependencies[techId]) do
            if not self.researched[dep] then return false end
        end
        return true
    end,

    getResearchedCount = function(self)
        local count = 0
        for _ in pairs(self.researched) do count = count + 1 end
        return count
    end,

    getTechCount = function(self)
        local count = 0
        for _ in pairs(self.technologies) do count = count + 1 end
        return count
    end,

    getDependencies = function(self, techId)
        return self.dependencies[techId] or {}
    end,

    getTechByCategory = function(self, category)
        local result = {}
        for id, tech in pairs(self.technologies) do
            if tech.category == category then table.insert(result, id) end
        end
        return result
    end,

    getUnresearchedCount = function(self)
        local count = 0
        for _, tech in pairs(self.technologies) do
            if not tech.researched then count = count + 1 end
        end
        return count
    end,

    unlockUpgrade = function(self, techId, upgradeId)
        if not self.technologies[techId] then return false end
        if not self.technologies[techId].researched then return false end
        if not self.technologies[techId].upgrades then self.technologies[techId].upgrades = {} end
        table.insert(self.technologies[techId].upgrades, upgradeId)
        return true
    end
}

Suite:group("Technology Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tts = TechTreeSystem:new()
    end)

    Suite:testMethod("TechTreeSystem.new", {description = "Creates system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.tts ~= nil, true, "System created")
    end)

    Suite:testMethod("TechTreeSystem.addTechnology", {description = "Adds technology", testCase = "add", type = "functional"}, function()
        local ok = shared.tts:addTechnology("rifle", "Rifle Technology", 500, "weapons")
        Helpers.assertEqual(ok, true, "Technology added")
    end)

    Suite:testMethod("TechTreeSystem.getTechnology", {description = "Retrieves technology", testCase = "get", type = "functional"}, function()
        shared.tts:addTechnology("armor", "Body Armor", 400, "defense")
        local tech = shared.tts:getTechnology("armor")
        Helpers.assertEqual(tech ~= nil, true, "Technology retrieved")
    end)

    Suite:testMethod("TechTreeSystem.getTechnology", {description = "Returns nil missing", testCase = "missing", type = "functional"}, function()
        local tech = shared.tts:getTechnology("nonexistent")
        Helpers.assertEqual(tech, nil, "Missing returns nil")
    end)

    Suite:testMethod("TechTreeSystem.getTechCount", {description = "Counts technologies", testCase = "count", type = "functional"}, function()
        shared.tts:addTechnology("t1", "T1", 100, "cat")
        shared.tts:addTechnology("t2", "T2", 200, "cat")
        shared.tts:addTechnology("t3", "T3", 300, "cat")
        local count = shared.tts:getTechCount()
        Helpers.assertEqual(count, 3, "Three technologies")
    end)
end)

Suite:group("Research", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tts = TechTreeSystem:new()
        shared.tts:addTechnology("basic_rifle", "Basic Rifle", 300, "weapons")
    end)

    Suite:testMethod("TechTreeSystem.researchTech", {description = "Researches tech", testCase = "research", type = "functional"}, function()
        local ok = shared.tts:researchTech("basic_rifle")
        Helpers.assertEqual(ok, true, "Researched")
    end)

    Suite:testMethod("TechTreeSystem.isResearched", {description = "Checks research", testCase = "check", type = "functional"}, function()
        shared.tts:researchTech("basic_rifle")
        local researched = shared.tts:isResearched("basic_rifle")
        Helpers.assertEqual(researched, true, "Is researched")
    end)

    Suite:testMethod("TechTreeSystem.isResearched", {description = "Not researched by default", testCase = "default", type = "functional"}, function()
        local researched = shared.tts:isResearched("basic_rifle")
        Helpers.assertEqual(researched, false, "Not researched initially")
    end)

    Suite:testMethod("TechTreeSystem.getResearchedCount", {description = "Counts researched", testCase = "count_researched", type = "functional"}, function()
        shared.tts:addTechnology("t2", "T2", 200, "cat")
        shared.tts:addTechnology("t3", "T3", 300, "cat")
        shared.tts:researchTech("basic_rifle")
        shared.tts:researchTech("t2")
        local count = shared.tts:getResearchedCount()
        Helpers.assertEqual(count, 2, "Two researched")
    end)
end)

Suite:group("Dependencies", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tts = TechTreeSystem:new()
        shared.tts:addTechnology("basic", "Basic", 100, "weapons")
        shared.tts:addTechnology("advanced", "Advanced", 300, "weapons")
    end)

    Suite:testMethod("TechTreeSystem.addDependency", {description = "Adds dependency", testCase = "add_dep", type = "functional"}, function()
        local ok = shared.tts:addDependency("advanced", "basic")
        Helpers.assertEqual(ok, true, "Dependency added")
    end)

    Suite:testMethod("TechTreeSystem.getDependencies", {description = "Gets dependencies", testCase = "get_deps", type = "functional"}, function()
        shared.tts:addDependency("advanced", "basic")
        local deps = shared.tts:getDependencies("advanced")
        Helpers.assertEqual(deps ~= nil, true, "Dependencies retrieved")
    end)

    Suite:testMethod("TechTreeSystem.researchTech", {description = "Fails without dependency", testCase = "no_dep", type = "functional"}, function()
        shared.tts:addDependency("advanced", "basic")
        local ok = shared.tts:researchTech("advanced")
        Helpers.assertEqual(ok, false, "Failed without dependency")
    end)

    Suite:testMethod("TechTreeSystem.researchTech", {description = "Works with dependency", testCase = "with_dep", type = "functional"}, function()
        shared.tts:addDependency("advanced", "basic")
        shared.tts:researchTech("basic")
        local ok = shared.tts:researchTech("advanced")
        Helpers.assertEqual(ok, true, "Researched with dependency")
    end)
end)

Suite:group("Research Conditions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tts = TechTreeSystem:new()
        shared.tts:addTechnology("tech", "Tech", 200, "general")
    end)

    Suite:testMethod("TechTreeSystem.canResearch", {description = "Can research", testCase = "can_research", type = "functional"}, function()
        local ok = shared.tts:canResearch("tech")
        Helpers.assertEqual(ok, true, "Can research")
    end)

    Suite:testMethod("TechTreeSystem.canResearch", {description = "Cannot twice", testCase = "cannot_twice", type = "functional"}, function()
        shared.tts:researchTech("tech")
        local ok = shared.tts:canResearch("tech")
        Helpers.assertEqual(ok, false, "Cannot research twice")
    end)

    Suite:testMethod("TechTreeSystem.canResearch", {description = "Blocked by dependency", testCase = "blocked", type = "functional"}, function()
        shared.tts:addTechnology("locked", "Locked", 300, "general")
        shared.tts:addDependency("locked", "tech")
        local ok = shared.tts:canResearch("locked")
        Helpers.assertEqual(ok, false, "Blocked by dependency")
    end)
end)

Suite:group("Categories", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tts = TechTreeSystem:new()
        shared.tts:addTechnology("rifle", "Rifle", 100, "weapons")
        shared.tts:addTechnology("laser", "Laser", 200, "weapons")
        shared.tts:addTechnology("shield", "Shield", 150, "defense")
    end)

    Suite:testMethod("TechTreeSystem.getTechByCategory", {description = "Filters by category", testCase = "filter", type = "functional"}, function()
        local techs = shared.tts:getTechByCategory("weapons")
        Helpers.assertEqual(techs ~= nil, true, "Filtered results")
    end)

    Suite:testMethod("TechTreeSystem.getTechByCategory", {description = "Correct category", testCase = "correct", type = "functional"}, function()
        local techs = shared.tts:getTechByCategory("weapons")
        local count = #techs
        Helpers.assertEqual(count, 2, "Two weapons")
    end)

    Suite:testMethod("TechTreeSystem.getTechByCategory", {description = "Returns empty", testCase = "empty", type = "functional"}, function()
        local techs = shared.tts:getTechByCategory("unknown")
        local count = #techs
        Helpers.assertEqual(count, 0, "No unknown")
    end)
end)

Suite:group("Progress Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tts = TechTreeSystem:new()
        shared.tts:addTechnology("t1", "T1", 100, "cat")
        shared.tts:addTechnology("t2", "T2", 100, "cat")
        shared.tts:addTechnology("t3", "T3", 100, "cat")
        shared.tts:researchTech("t1")
    end)

    Suite:testMethod("TechTreeSystem.getUnresearchedCount", {description = "Counts unresearched", testCase = "unresearched", type = "functional"}, function()
        local count = shared.tts:getUnresearchedCount()
        Helpers.assertEqual(count, 2, "Two unresearched")
    end)

    Suite:testMethod("TechTreeSystem.getUnresearchedCount", {description = "All researched", testCase = "all_done", type = "functional"}, function()
        shared.tts:researchTech("t2")
        shared.tts:researchTech("t3")
        local count = shared.tts:getUnresearchedCount()
        Helpers.assertEqual(count, 0, "None unresearched")
    end)
end)

Suite:run()
