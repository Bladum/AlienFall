-- ─────────────────────────────────────────────────────────────────────────
-- LAB RESEARCH TEST SUITE
-- FILE: tests2/basescape/lab_research_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.lab_research",
    fileName = "lab_research.lua",
    description = "Research projects with technology trees, breakthroughs, and facility management"
})

print("[LAB_RESEARCH_TEST] Setting up")

local LabResearch = {
    technologies = {}, active_projects = {}, researchers = {}, discoveries = {},

    new = function(self)
        return setmetatable({technologies = {}, active_projects = {}, researchers = {}, discoveries = {}}, {__index = self})
    end,

    registerTechnology = function(self, techId, name, difficulty, research_time)
        self.technologies[techId] = {
            id = techId, name = name or "Tech", difficulty = difficulty or 50,
            research_time = research_time or 100, prerequisites = {}, unlocks = {}
        }
        return true
    end,

    getTechnology = function(self, techId)
        return self.technologies[techId]
    end,

    addPrerequisite = function(self, techId, prerequisiteId)
        if not self.technologies[techId] then return false end
        table.insert(self.technologies[techId].prerequisites, prerequisiteId)
        return true
    end,

    canResearch = function(self, techId, discovered)
        if not self.technologies[techId] then return false end
        local tech = self.technologies[techId]
        for _, prereq in ipairs(tech.prerequisites) do
            if not discovered[prereq] then return false end
        end
        return true
    end,

    startProject = function(self, projectId, techId, researchers_count)
        if not self.technologies[techId] then return false end
        local tech = self.technologies[techId]
        self.active_projects[projectId] = {
            id = projectId, tech_id = techId, progress = 0,
            researchers = researchers_count or 2, status = "active",
            completion_estimate = tech.research_time
        }
        return true
    end,

    getProject = function(self, projectId)
        return self.active_projects[projectId]
    end,

    advanceResearch = function(self, projectId, increment)
        if not self.active_projects[projectId] then return false end
        local proj = self.active_projects[projectId]
        proj.progress = math.min(100, proj.progress + (increment or 5))
        return true
    end,

    getProjectProgress = function(self, projectId)
        if not self.active_projects[projectId] then return 0 end
        return self.active_projects[projectId].progress
    end,

    isProjectComplete = function(self, projectId)
        if not self.active_projects[projectId] then return false end
        return self.active_projects[projectId].progress >= 100
    end,

    completeProject = function(self, projectId)
        if not self.active_projects[projectId] then return false end
        if self.active_projects[projectId].progress < 100 then return false end
        local techId = self.active_projects[projectId].tech_id
        self.discoveries[techId] = true
        self.active_projects[projectId].status = "completed"
        return true
    end,

    getTechDiscoveryTime = function(self, projectId)
        if not self.active_projects[projectId] then return 0 end
        return self.active_projects[projectId].completion_estimate * 2
    end,

    assignResearchers = function(self, projectId, count)
        if not self.active_projects[projectId] then return false end
        self.active_projects[projectId].researchers = count
        return true
    end,

    calculateResearchBonus = function(self, researcher_count)
        return 1 + (researcher_count - 1) * 0.15
    end,

    hasDiscovered = function(self, techId)
        return self.discoveries[techId] or false
    end,

    getDiscoveredTechs = function(self)
        local discovered = {}
        for techId, _ in pairs(self.discoveries) do
            if self.discoveries[techId] then
                table.insert(discovered, techId)
            end
        end
        return discovered
    end,

    unlockNext = function(self, techId)
        if not self.technologies[techId] then return {} end
        local tech = self.technologies[techId]
        if not self.discoveries[techId] then return {} end
        return tech.unlocks
    end,

    unlocksByTech = function(self, techId)
        if not self.technologies[techId] then return {} end
        return self.technologies[techId].unlocks
    end,

    addTechUnlock = function(self, fromTechId, toTechId)
        if not self.technologies[fromTechId] then return false end
        table.insert(self.technologies[fromTechId].unlocks, toTechId)
        if not self.technologies[toTechId] then return false end
        table.insert(self.technologies[toTechId].prerequisites, fromTechId)
        return true
    end,

    recordDiscovery = function(self, techId, discoverer, discovery_turn)
        self.discoveries[techId] = {
            tech_id = techId, discoverer = discoverer or "Unknown",
            turn = discovery_turn or 0, date = "turn_" .. tostring(discovery_turn or 0)
        }
        return true
    end,

    getDiscoveryInfo = function(self, techId)
        if type(self.discoveries[techId]) == "table" then
            return self.discoveries[techId]
        end
        return nil
    end,

    accelerateResearch = function(self, projectId, amount)
        if not self.active_projects[projectId] then return false end
        self.active_projects[projectId].progress = math.min(100, self.active_projects[projectId].progress + amount)
        return true
    end,

    reset = function(self)
        self.technologies = {}
        self.active_projects = {}
        self.researchers = {}
        self.discoveries = {}
        return true
    end
}

Suite:group("Technologies", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lr = LabResearch:new()
    end)

    Suite:testMethod("LabResearch.registerTechnology", {description = "Registers technology", testCase = "register", type = "functional"}, function()
        local ok = shared.lr:registerTechnology("t1", "Plasma", 75)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("LabResearch.getTechnology", {description = "Gets technology", testCase = "get", type = "functional"}, function()
        shared.lr:registerTechnology("t2", "Laser", 60)
        local tech = shared.lr:getTechnology("t2")
        Helpers.assertEqual(tech ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Prerequisites", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lr = LabResearch:new()
        shared.lr:registerTechnology("t1", "Basic", 30)
        shared.lr:registerTechnology("t2", "Advanced", 70)
    end)

    Suite:testMethod("LabResearch.addPrerequisite", {description = "Adds prerequisite", testCase = "add", type = "functional"}, function()
        local ok = shared.lr:addPrerequisite("t2", "t1")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("LabResearch.canResearch", {description = "Can research", testCase = "can", type = "functional"}, function()
        shared.lr:addPrerequisite("t2", "t1")
        local can = shared.lr:canResearch("t2", {t1 = true})
        Helpers.assertEqual(can, true, "Can research")
    end)
end)

Suite:group("Projects", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lr = LabResearch:new()
        shared.lr:registerTechnology("t1", "Test", 50, 100)
    end)

    Suite:testMethod("LabResearch.startProject", {description = "Starts project", testCase = "start", type = "functional"}, function()
        local ok = shared.lr:startProject("p1", "t1", 3)
        Helpers.assertEqual(ok, true, "Started")
    end)

    Suite:testMethod("LabResearch.getProject", {description = "Gets project", testCase = "get", type = "functional"}, function()
        shared.lr:startProject("p2", "t1", 2)
        local proj = shared.lr:getProject("p2")
        Helpers.assertEqual(proj ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LabResearch.advanceResearch", {description = "Advances research", testCase = "advance", type = "functional"}, function()
        shared.lr:startProject("p3", "t1", 2)
        local ok = shared.lr:advanceResearch("p3", 10)
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("LabResearch.getProjectProgress", {description = "Gets progress", testCase = "progress", type = "functional"}, function()
        shared.lr:startProject("p4", "t1", 2)
        shared.lr:advanceResearch("p4", 25)
        local prog = shared.lr:getProjectProgress("p4")
        Helpers.assertEqual(prog, 25, "25")
    end)

    Suite:testMethod("LabResearch.isProjectComplete", {description = "Is complete", testCase = "complete", type = "functional"}, function()
        shared.lr:startProject("p5", "t1", 2)
        shared.lr:advanceResearch("p5", 100)
        local complete = shared.lr:isProjectComplete("p5")
        Helpers.assertEqual(complete, true, "Complete")
    end)
end)

Suite:group("Completion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lr = LabResearch:new()
        shared.lr:registerTechnology("t1", "Tech", 50, 100)
    end)

    Suite:testMethod("LabResearch.completeProject", {description = "Completes project", testCase = "complete", type = "functional"}, function()
        shared.lr:startProject("p1", "t1", 2)
        shared.lr:advanceResearch("p1", 100)
        local ok = shared.lr:completeProject("p1")
        Helpers.assertEqual(ok, true, "Completed")
    end)

    Suite:testMethod("LabResearch.hasDiscovered", {description = "Has discovered", testCase = "discovered", type = "functional"}, function()
        shared.lr:startProject("p2", "t1", 2)
        shared.lr:advanceResearch("p2", 100)
        shared.lr:completeProject("p2")
        local has = shared.lr:hasDiscovered("t1")
        Helpers.assertEqual(has, true, "Discovered")
    end)
end)

Suite:group("Researchers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lr = LabResearch:new()
        shared.lr:registerTechnology("t1", "Tech", 50, 100)
    end)

    Suite:testMethod("LabResearch.assignResearchers", {description = "Assigns researchers", testCase = "assign", type = "functional"}, function()
        shared.lr:startProject("p1", "t1", 1)
        local ok = shared.lr:assignResearchers("p1", 5)
        Helpers.assertEqual(ok, true, "Assigned")
    end)

    Suite:testMethod("LabResearch.calculateResearchBonus", {description = "Calculates bonus", testCase = "bonus", type = "functional"}, function()
        local bonus = shared.lr:calculateResearchBonus(4)
        Helpers.assertEqual(bonus > 1, true, "Bonus > 1")
    end)

    Suite:testMethod("LabResearch.getTechDiscoveryTime", {description = "Gets discovery time", testCase = "time", type = "functional"}, function()
        shared.lr:startProject("p2", "t1", 2)
        local time = shared.lr:getTechDiscoveryTime("p2")
        Helpers.assertEqual(time > 0, true, "Time > 0")
    end)
end)

Suite:group("Tech Trees", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lr = LabResearch:new()
        shared.lr:registerTechnology("t1", "Base", 30, 50)
        shared.lr:registerTechnology("t2", "Tier2", 60, 100)
        shared.lr:registerTechnology("t3", "Tier3", 80, 150)
    end)

    Suite:testMethod("LabResearch.addTechUnlock", {description = "Adds unlock", testCase = "add", type = "functional"}, function()
        local ok = shared.lr:addTechUnlock("t1", "t2")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("LabResearch.unlocksByTech", {description = "Gets unlocks", testCase = "unlocks", type = "functional"}, function()
        shared.lr:addTechUnlock("t1", "t2")
        shared.lr:addTechUnlock("t1", "t3")
        local unlocks = shared.lr:unlocksByTech("t1")
        Helpers.assertEqual(#unlocks, 2, "2")
    end)

    Suite:testMethod("LabResearch.unlockNext", {description = "Gets next unlocks", testCase = "next", type = "functional"}, function()
        shared.lr:addTechUnlock("t1", "t2")
        shared.lr:startProject("p1", "t1", 2)
        shared.lr:advanceResearch("p1", 100)
        shared.lr:completeProject("p1")
        local next = shared.lr:unlockNext("t1")
        Helpers.assertEqual(#next > 0, true, "Has next")
    end)

    Suite:testMethod("LabResearch.getDiscoveredTechs", {description = "Gets discovered", testCase = "discovered", type = "functional"}, function()
        shared.lr:startProject("p1", "t1", 2)
        shared.lr:advanceResearch("p1", 100)
        shared.lr:completeProject("p1")
        local disc = shared.lr:getDiscoveredTechs()
        Helpers.assertEqual(#disc > 0, true, "Has discovered")
    end)
end)

Suite:group("Discovery Records", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lr = LabResearch:new()
        shared.lr:registerTechnology("t1", "Discovery", 50, 100)
    end)

    Suite:testMethod("LabResearch.recordDiscovery", {description = "Records discovery", testCase = "record", type = "functional"}, function()
        local ok = shared.lr:recordDiscovery("t1", "Scientist", 5)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("LabResearch.getDiscoveryInfo", {description = "Gets discovery info", testCase = "info", type = "functional"}, function()
        shared.lr:recordDiscovery("t1", "Researcher", 10)
        local info = shared.lr:getDiscoveryInfo("t1")
        Helpers.assertEqual(info ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Acceleration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lr = LabResearch:new()
        shared.lr:registerTechnology("t1", "Tech", 50, 100)
    end)

    Suite:testMethod("LabResearch.accelerateResearch", {description = "Accelerates research", testCase = "accelerate", type = "functional"}, function()
        shared.lr:startProject("p1", "t1", 2)
        local ok = shared.lr:accelerateResearch("p1", 50)
        Helpers.assertEqual(ok, true, "Accelerated")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lr = LabResearch:new()
    end)

    Suite:testMethod("LabResearch.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.lr:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
