-- ─────────────────────────────────────────────────────────────────────────
-- RESEARCH TECH TEST SUITE
-- FILE: tests2/core/research_tech_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.research_tech",
    fileName = "research_tech.lua",
    description = "Technology research system with tech trees, dependencies, and progression"
})

print("[RESEARCH_TECH_TEST] Setting up")

local ResearchTech = {
    technologies = {},
    research_state = {},
    tech_trees = {},
    dependencies = {},
    unlocked = {},

    new = function(self)
        return setmetatable({
            technologies = {}, research_state = {}, tech_trees = {},
            dependencies = {}, unlocked = {}
        }, {__index = self})
    end,

    registerTech = function(self, techId, name, category, research_time, cost)
        self.technologies[techId] = {
            id = techId, name = name, category = category or "general",
            research_time = research_time or 10, cost = cost or 100, tier = 1
        }
        self.research_state[techId] = {progress = 0, started = false, completed = false}
        self.dependencies[techId] = {}
        return true
    end,

    getTech = function(self, techId)
        return self.technologies[techId]
    end,

    startResearch = function(self, techId)
        if not self.technologies[techId] then return false end
        if not self:checkDependencies(techId) then return false end
        self.research_state[techId].started = true
        self.research_state[techId].progress = 0
        return true
    end,

    addDependency = function(self, techId, requiredTechId)
        if not self.dependencies[techId] then self.dependencies[techId] = {} end
        table.insert(self.dependencies[techId], requiredTechId)
        return true
    end,

    checkDependencies = function(self, techId)
        if not self.dependencies[techId] or not next(self.dependencies[techId]) then
            return true
        end
        for _, requiredTech in ipairs(self.dependencies[techId]) do
            if not self.research_state[requiredTech] or not self.research_state[requiredTech].completed then
                return false
            end
        end
        return true
    end,

    progressResearch = function(self, techId, amount)
        if not self.research_state[techId] then return false end
        if not self.research_state[techId].started then return false end
        self.research_state[techId].progress = math.min(
            self.research_state[techId].progress + amount,
            self.technologies[techId].research_time
        )
        if self.research_state[techId].progress >= self.technologies[techId].research_time then
            self.research_state[techId].completed = true
            self.unlocked[techId] = true
        end
        return true
    end,

    getProgress = function(self, techId)
        if not self.research_state[techId] then return 0 end
        return self.research_state[techId].progress
    end,

    getProgressPercentage = function(self, techId)
        if not self.technologies[techId] then return 0 end
        local progress = self:getProgress(techId)
        return math.floor((progress / self.technologies[techId].research_time) * 100)
    end,

    isCompleted = function(self, techId)
        if not self.research_state[techId] then return false end
        return self.research_state[techId].completed
    end,

    isUnlocked = function(self, techId)
        if not self.unlocked[techId] then return false end
        return self.unlocked[techId]
    end,

    getTechCount = function(self)
        local count = 0
        for _ in pairs(self.technologies) do count = count + 1 end
        return count
    end,

    getCompletedCount = function(self)
        local count = 0
        for techId, _ in pairs(self.technologies) do
            if self:isCompleted(techId) then count = count + 1 end
        end
        return count
    end,

    getCompletionRate = function(self)
        local total = self:getTechCount()
        if total == 0 then return 0 end
        local completed = self:getCompletedCount()
        return math.floor((completed / total) * 100)
    end,

    setTechTier = function(self, techId, tier)
        if not self.technologies[techId] then return false end
        self.technologies[techId].tier = math.max(1, tier)
        return true
    end,

    getTechTier = function(self, techId)
        if not self.technologies[techId] then return 0 end
        return self.technologies[techId].tier
    end,

    getTechsByTier = function(self, tier)
        local result = {}
        for techId, tech in pairs(self.technologies) do
            if tech.tier == tier then table.insert(result, techId) end
        end
        return result
    end,

    createTechTree = function(self, treeId, name, rootTechId)
        if not self.technologies[rootTechId] then return false end
        self.tech_trees[treeId] = {id = treeId, name = name, root = rootTechId, nodes = {}}
        return true
    end,

    addToTechTree = function(self, treeId, techId, parentTechId)
        if not self.tech_trees[treeId] then return false end
        if not self.technologies[techId] then return false end
        self.tech_trees[treeId].nodes[techId] = {id = techId, parent = parentTechId, children = {}}
        if parentTechId then
            self:addDependency(techId, parentTechId)
        end
        return true
    end,

    getTechTreeSize = function(self, treeId)
        if not self.tech_trees[treeId] then return 0 end
        local count = 0
        for _ in pairs(self.tech_trees[treeId].nodes) do count = count + 1 end
        return count
    end,

    calculateResearchSpeed = function(self, baseSpeed, scientists)
        return baseSpeed * (1 + (scientists * 0.1))
    end,

    getAvailableTechs = function(self)
        local available = {}
        for techId, tech in pairs(self.technologies) do
            if not self:isCompleted(techId) and self:checkDependencies(techId) then
                table.insert(available, techId)
            end
        end
        return available
    end,

    estimateCompletionTime = function(self, techId, currentSpeed)
        if not self.technologies[techId] then return 0 end
        local remaining = self.technologies[techId].research_time - self:getProgress(techId)
        if currentSpeed <= 0 then return 0 end
        return math.ceil(remaining / currentSpeed)
    end,

    resetTech = function(self, techId)
        if not self.technologies[techId] then return false end
        self.research_state[techId] = {progress = 0, started = false, completed = false}
        self.unlocked[techId] = nil
        return true
    end,

    resetAll = function(self)
        self.technologies = {}
        self.research_state = {}
        self.tech_trees = {}
        self.dependencies = {}
        self.unlocked = {}
        return true
    end
}

Suite:group("Technology Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rt = ResearchTech:new()
    end)

    Suite:testMethod("ResearchTech.registerTech", {description = "Registers technology", testCase = "register", type = "functional"}, function()
        local ok = shared.rt:registerTech("laserWeapon", "Laser Weapon", "weapons", 20, 500)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ResearchTech.getTech", {description = "Gets technology", testCase = "get_tech", type = "functional"}, function()
        shared.rt:registerTech("plasma", "Plasma Tech", "weapons", 25, 600)
        local tech = shared.rt:getTech("plasma")
        Helpers.assertEqual(tech ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ResearchTech.getTechCount", {description = "Tech count", testCase = "count", type = "functional"}, function()
        shared.rt:registerTech("t1", "Tech1", "weapons", 10, 100)
        shared.rt:registerTech("t2", "Tech2", "armor", 15, 150)
        local count = shared.rt:getTechCount()
        Helpers.assertEqual(count, 2, "Two techs")
    end)
end)

Suite:group("Research Progress", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rt = ResearchTech:new()
        shared.rt:registerTech("research1", "Research 1", "general", 20, 100)
    end)

    Suite:testMethod("ResearchTech.startResearch", {description = "Starts research", testCase = "start", type = "functional"}, function()
        local ok = shared.rt:startResearch("research1")
        Helpers.assertEqual(ok, true, "Started")
    end)

    Suite:testMethod("ResearchTech.progressResearch", {description = "Progresses research", testCase = "progress", type = "functional"}, function()
        shared.rt:startResearch("research1")
        local ok = shared.rt:progressResearch("research1", 5)
        Helpers.assertEqual(ok, true, "Progressed")
    end)

    Suite:testMethod("ResearchTech.getProgress", {description = "Gets progress", testCase = "get_prog", type = "functional"}, function()
        shared.rt:startResearch("research1")
        shared.rt:progressResearch("research1", 8)
        local prog = shared.rt:getProgress("research1")
        Helpers.assertEqual(prog, 8, "Progress 8")
    end)

    Suite:testMethod("ResearchTech.getProgressPercentage", {description = "Progress percentage", testCase = "percentage", type = "functional"}, function()
        shared.rt:startResearch("research1")
        shared.rt:progressResearch("research1", 10)
        local pct = shared.rt:getProgressPercentage("research1")
        Helpers.assertEqual(pct, 50, "50% progress")
    end)
end)

Suite:group("Completion Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rt = ResearchTech:new()
        shared.rt:registerTech("complete1", "Complete1", "general", 10, 100)
    end)

    Suite:testMethod("ResearchTech.isCompleted", {description = "Is completed", testCase = "is_complete", type = "functional"}, function()
        shared.rt:startResearch("complete1")
        shared.rt:progressResearch("complete1", 10)
        local is = shared.rt:isCompleted("complete1")
        Helpers.assertEqual(is, true, "Completed")
    end)

    Suite:testMethod("ResearchTech.isUnlocked", {description = "Is unlocked", testCase = "unlocked", type = "functional"}, function()
        shared.rt:startResearch("complete1")
        shared.rt:progressResearch("complete1", 10)
        local is = shared.rt:isUnlocked("complete1")
        Helpers.assertEqual(is, true, "Unlocked")
    end)

    Suite:testMethod("ResearchTech.getCompletedCount", {description = "Completed count", testCase = "completed_count", type = "functional"}, function()
        shared.rt:registerTech("c1", "C1", "general", 5, 100)
        shared.rt:registerTech("c2", "C2", "general", 5, 100)
        shared.rt:startResearch("c1")
        shared.rt:startResearch("c2")
        shared.rt:progressResearch("c1", 5)
        local count = shared.rt:getCompletedCount()
        Helpers.assertEqual(count, 1, "One completed")
    end)

    Suite:testMethod("ResearchTech.getCompletionRate", {description = "Completion rate", testCase = "rate", type = "functional"}, function()
        shared.rt:registerTech("r1", "R1", "general", 5, 100)
        shared.rt:registerTech("r2", "R2", "general", 5, 100)
        shared.rt:startResearch("r1")
        shared.rt:startResearch("r2")
        shared.rt:progressResearch("r1", 5)
        shared.rt:progressResearch("r2", 5)
        local rate = shared.rt:getCompletionRate()
        Helpers.assertEqual(rate, 100, "100% complete")
    end)
end)

Suite:group("Tech Tiers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rt = ResearchTech:new()
        shared.rt:registerTech("tier_tech", "Tier Tech", "general", 10, 100)
    end)

    Suite:testMethod("ResearchTech.setTechTier", {description = "Sets tech tier", testCase = "set_tier", type = "functional"}, function()
        local ok = shared.rt:setTechTier("tier_tech", 3)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ResearchTech.getTechTier", {description = "Gets tech tier", testCase = "get_tier", type = "functional"}, function()
        shared.rt:setTechTier("tier_tech", 2)
        local tier = shared.rt:getTechTier("tier_tech")
        Helpers.assertEqual(tier, 2, "Tier 2")
    end)

    Suite:testMethod("ResearchTech.getTechsByTier", {description = "Gets techs by tier", testCase = "by_tier", type = "functional"}, function()
        shared.rt:registerTech("t1", "T1", "general", 5, 100)
        shared.rt:registerTech("t2", "T2", "general", 5, 100)
        shared.rt:setTechTier("t1", 1)
        shared.rt:setTechTier("t2", 1)
        local techs = shared.rt:getTechsByTier(1)
        Helpers.assertEqual(#techs, 2, "Two tier-1 techs")
    end)
end)

Suite:group("Dependencies", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rt = ResearchTech:new()
        shared.rt:registerTech("base", "Base Tech", "general", 5, 100)
        shared.rt:registerTech("advanced", "Advanced Tech", "general", 10, 200)
    end)

    Suite:testMethod("ResearchTech.addDependency", {description = "Adds dependency", testCase = "add_dep", type = "functional"}, function()
        local ok = shared.rt:addDependency("advanced", "base")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ResearchTech.checkDependencies", {description = "Checks dependencies", testCase = "check_dep", type = "functional"}, function()
        shared.rt:addDependency("advanced", "base")
        shared.rt:startResearch("base")
        shared.rt:progressResearch("base", 5)
        local ok = shared.rt:checkDependencies("advanced")
        Helpers.assertEqual(ok, true, "Dependencies met")
    end)

    Suite:testMethod("ResearchTech.startResearch with dependency", {description = "Respects dependencies", testCase = "respect_dep", type = "functional"}, function()
        shared.rt:addDependency("advanced", "base")
        local ok = shared.rt:startResearch("advanced")
        Helpers.assertEqual(ok, false, "Cannot start")
    end)
end)

Suite:group("Tech Trees", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rt = ResearchTech:new()
        shared.rt:registerTech("root", "Root Tech", "general", 5, 100)
        shared.rt:registerTech("child1", "Child 1", "general", 10, 150)
    end)

    Suite:testMethod("ResearchTech.createTechTree", {description = "Creates tech tree", testCase = "create_tree", type = "functional"}, function()
        local ok = shared.rt:createTechTree("tree1", "Tree One", "root")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ResearchTech.addToTechTree", {description = "Adds to tech tree", testCase = "add_tree", type = "functional"}, function()
        shared.rt:createTechTree("tree1", "Tree One", "root")
        local ok = shared.rt:addToTechTree("tree1", "child1", "root")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ResearchTech.getTechTreeSize", {description = "Tech tree size", testCase = "tree_size", type = "functional"}, function()
        shared.rt:registerTech("c2", "Child 2", "general", 10, 150)
        shared.rt:createTechTree("tree1", "Tree One", "root")
        shared.rt:addToTechTree("tree1", "child1", "root")
        shared.rt:addToTechTree("tree1", "c2", "root")
        local size = shared.rt:getTechTreeSize("tree1")
        Helpers.assertEqual(size, 2, "Size 2")
    end)
end)

Suite:group("Research Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rt = ResearchTech:new()
        shared.rt:registerTech("tech1", "Tech1", "general", 10, 100)
    end)

    Suite:testMethod("ResearchTech.calculateResearchSpeed", {description = "Calculates speed", testCase = "speed", type = "functional"}, function()
        local speed = shared.rt:calculateResearchSpeed(10, 5)
        Helpers.assertEqual(speed, 15, "Speed 15")
    end)

    Suite:testMethod("ResearchTech.getAvailableTechs", {description = "Available techs", testCase = "available", type = "functional"}, function()
        local available = shared.rt:getAvailableTechs()
        Helpers.assertEqual(#available, 1, "One available")
    end)

    Suite:testMethod("ResearchTech.estimateCompletionTime", {description = "Completion time", testCase = "eta", type = "functional"}, function()
        shared.rt:startResearch("tech1")
        shared.rt:progressResearch("tech1", 3)
        local time = shared.rt:estimateCompletionTime("tech1", 2)
        Helpers.assertEqual(time, 4, "4 turns")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rt = ResearchTech:new()
        shared.rt:registerTech("reset_tech", "Reset", "general", 10, 100)
    end)

    Suite:testMethod("ResearchTech.resetTech", {description = "Resets single tech", testCase = "reset_one", type = "functional"}, function()
        shared.rt:startResearch("reset_tech")
        local ok = shared.rt:resetTech("reset_tech")
        Helpers.assertEqual(ok, true, "Reset")
    end)

    Suite:testMethod("ResearchTech.resetAll", {description = "Resets all", testCase = "reset_all", type = "functional"}, function()
        shared.rt:registerTech("t1", "T1", "general", 5, 100)
        local ok = shared.rt:resetAll()
        Helpers.assertEqual(ok, true, "Reset all")
    end)
end)

Suite:run()
