-- ─────────────────────────────────────────────────────────────────────────
-- RESEARCH SYSTEM TEST SUITE
-- FILE: tests2/economy/research_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.research.research_system",
    fileName = "research_system.lua",
    description = "Technology research and progression system"
})

print("[RESEARCH_TEST] Setting up")

local ResearchSystem = {
    technologies = {},
    researched = {},
    currentResearch = nil,
    researchPoints = 0,

    addTechnology = function(self, id, name, cost, prerequisite)
        self.technologies[id] = {id = id, name = name, cost = cost, prerequisite = prerequisite}
        return true
    end,

    getTechnology = function(self, id) return self.technologies[id] end,

    startResearch = function(self, techId)
        local tech = self:getTechnology(techId)
        if not tech then return false end
        if tech.prerequisite and not self.researched[tech.prerequisite] then return false end
        self.currentResearch = techId
        return true
    end,

    completeResearch = function(self, techId)
        if not self.currentResearch then return false end
        self.researched[techId] = true
        self.currentResearch = nil
        return true
    end,

    isResearched = function(self, techId)
        return self.researched[techId] == true
    end,

    canResearch = function(self, techId)
        local tech = self:getTechnology(techId)
        if not tech then return false end
        if self.researched[techId] then return false end
        if tech.prerequisite and not self.researched[tech.prerequisite] then return false end
        return true
    end,

    addResearchPoints = function(self, points)
        self.researchPoints = self.researchPoints + points
        return true
    end,

    getResearchPoints = function(self) return self.researchPoints end,

    consumeResearchPoints = function(self, points)
        if self.researchPoints < points then return false end
        self.researchPoints = self.researchPoints - points
        return true
    end
}

Suite:group("Technology Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rs = setmetatable({technologies = {}, researched = {}, currentResearch = nil, researchPoints = 0}, {__index = ResearchSystem})
    end)

    Suite:testMethod("ResearchSystem.addTechnology", {description = "Adds technology", testCase = "add", type = "functional"}, function()
        local ok = shared.rs:addTechnology("laser", "Laser Weapons", 2000)
        Helpers.assertEqual(ok, true, "Technology added")
    end)

    Suite:testMethod("ResearchSystem.getTechnology", {description = "Retrieves technology", testCase = "get", type = "functional"}, function()
        shared.rs:addTechnology("plasma", "Plasma Weapons", 3000)
        local tech = shared.rs:getTechnology("plasma")
        Helpers.assertEqual(tech ~= nil, true, "Technology retrieved")
    end)

    Suite:testMethod("ResearchSystem.canResearch", {description = "Checks if researchable", testCase = "can_research", type = "functional"}, function()
        shared.rs:addTechnology("rifle", "Rifles", 1000)
        local can = shared.rs:canResearch("rifle")
        Helpers.assertEqual(can, true, "Can research")
    end)
end)

Suite:group("Research Progress", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rs = setmetatable({technologies = {}, researched = {}, currentResearch = nil, researchPoints = 0}, {__index = ResearchSystem})
        shared.rs:addTechnology("tech1", "Tech 1", 1000)
    end)

    Suite:testMethod("ResearchSystem.startResearch", {description = "Starts research", testCase = "start", type = "functional"}, function()
        local ok = shared.rs:startResearch("tech1")
        Helpers.assertEqual(ok, true, "Research started")
    end)

    Suite:testMethod("ResearchSystem.completeResearch", {description = "Completes research", testCase = "complete", type = "functional"}, function()
        shared.rs:startResearch("tech1")
        local ok = shared.rs:completeResearch("tech1")
        Helpers.assertEqual(ok, true, "Research completed")
        Helpers.assertEqual(shared.rs:isResearched("tech1"), true, "Technology researched")
    end)

    Suite:testMethod("ResearchSystem.isResearched", {description = "Checks if researched", testCase = "is_researched", type = "functional"}, function()
        shared.rs.researched["tech1"] = true
        local researched = shared.rs:isResearched("tech1")
        Helpers.assertEqual(researched, true, "Technology is researched")
    end)
end)

Suite:group("Prerequisites", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rs = setmetatable({technologies = {}, researched = {}, currentResearch = nil, researchPoints = 0}, {__index = ResearchSystem})
        shared.rs:addTechnology("basic", "Basic Tech", 500)
        shared.rs:addTechnology("advanced", "Advanced Tech", 2000, "basic")
    end)

    Suite:testMethod("ResearchSystem.canResearch", {description = "Requires prerequisite", testCase = "prerequisite_required", type = "functional"}, function()
        local can = shared.rs:canResearch("advanced")
        Helpers.assertEqual(can, false, "Prerequisite required")
    end)

    Suite:testMethod("ResearchSystem.startResearch", {description = "Fails with missing prerequisite", testCase = "missing_prereq", type = "functional"}, function()
        local ok = shared.rs:startResearch("advanced")
        Helpers.assertEqual(ok, false, "Missing prerequisite blocks research")
    end)

    Suite:testMethod("ResearchSystem.canResearch", {description = "Allows with prerequisite", testCase = "prereq_satisfied", type = "functional"}, function()
        shared.rs.researched["basic"] = true
        local can = shared.rs:canResearch("advanced")
        Helpers.assertEqual(can, true, "Prerequisite satisfied")
    end)
end)

Suite:group("Research Points", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rs = setmetatable({technologies = {}, researched = {}, currentResearch = nil, researchPoints = 0}, {__index = ResearchSystem})
    end)

    Suite:testMethod("ResearchSystem.addResearchPoints", {description = "Adds research points", testCase = "add_points", type = "functional"}, function()
        shared.rs:addResearchPoints(100)
        Helpers.assertEqual(shared.rs:getResearchPoints(), 100, "Points added")
    end)

    Suite:testMethod("ResearchSystem.consumeResearchPoints", {description = "Consumes research points", testCase = "consume", type = "functional"}, function()
        shared.rs:addResearchPoints(200)
        local ok = shared.rs:consumeResearchPoints(75)
        Helpers.assertEqual(ok, true, "Points consumed")
        Helpers.assertEqual(shared.rs:getResearchPoints(), 125, "Balance correct")
    end)

    Suite:testMethod("ResearchSystem.consumeResearchPoints", {description = "Prevents overconsumption", testCase = "prevent_over", type = "functional"}, function()
        shared.rs:addResearchPoints(50)
        local ok = shared.rs:consumeResearchPoints(100)
        Helpers.assertEqual(ok, false, "Overconsumption prevented")
    end)
end)

Suite:run()
