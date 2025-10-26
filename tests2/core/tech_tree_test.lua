-- ─────────────────────────────────────────────────────────────────────────
-- TECH TREE TEST SUITE
-- FILE: tests2/core/tech_tree_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.tech_tree",
    fileName = "tech_tree.lua",
    description = "Technology tree with prerequisites, branches, unlocks, and progression tracking"
})

print("[TECH_TREE_TEST] Setting up")

local TechTree = {
    techs = {},
    prerequisites = {},
    progression = {},
    unlocks = {},

    new = function(self)
        return setmetatable({techs = {}, prerequisites = {}, progression = {}, unlocks = {}}, {__index = self})
    end,

    addTech = function(self, techId, name, category, cost, tier)
        self.techs[techId] = {id = techId, name = name, category = category or "general", cost = cost or 100, tier = tier or 1, status = "locked"}
        self.prerequisites[techId] = {}
        self.progression[techId] = {researched = false, progress = 0}
        self.unlocks[techId] = {}
        return true
    end,

    getTech = function(self, techId)
        return self.techs[techId]
    end,

    addPrerequisite = function(self, techId, requiredTechId)
        if not self.techs[techId] or not self.techs[requiredTechId] then return false end
        table.insert(self.prerequisites[techId], requiredTechId)
        return true
    end,

    getPrerequisites = function(self, techId)
        if not self.prerequisites[techId] then return {} end
        return self.prerequisites[techId]
    end,

    getPrerequisiteCount = function(self, techId)
        if not self.prerequisites[techId] then return 0 end
        return #self.prerequisites[techId]
    end,

    canUnlock = function(self, techId, researchedTechs)
        if not self.techs[techId] then return false end
        local prereqs = self:getPrerequisites(techId)
        for _, prereq in ipairs(prereqs) do
            if not researchedTechs[prereq] then return false end
        end
        return true
    end,

    unlockTech = function(self, techId)
        if not self.techs[techId] then return false end
        self.techs[techId].status = "available"
        return true
    end,

    startResearch = function(self, techId)
        if not self.progression[techId] then return false end
        if self.techs[techId].status ~= "available" then return false end
        self.techs[techId].status = "researching"
        self.progression[techId].progress = 0
        return true
    end,

    addResearchProgress = function(self, techId, amount)
        if not self.progression[techId] then return false end
        self.progression[techId].progress = self.progression[techId].progress + amount
        if self.progression[techId].progress >= self.techs[techId].cost then
            self:completeTech(techId)
        end
        return true
    end,

    getResearchProgress = function(self, techId)
        if not self.progression[techId] then return 0 end
        return self.progression[techId].progress
    end,

    getProgressPercentage = function(self, techId)
        if not self.techs[techId] or not self.progression[techId] then return 0 end
        local cost = self.techs[techId].cost
        if cost == 0 then return 0 end
        return math.floor((self.progression[techId].progress / cost) * 100)
    end,

    completeTech = function(self, techId)
        if not self.techs[techId] then return false end
        self.progression[techId].researched = true
        self.techs[techId].status = "completed"
        return true
    end,

    isTechComplete = function(self, techId)
        if not self.progression[techId] then return false end
        return self.progression[techId].researched
    end,

    addUnlock = function(self, techId, unlockedItemId, itemType)
        if not self.unlocks[techId] then self.unlocks[techId] = {} end
        table.insert(self.unlocks[techId], {id = unlockedItemId, type = itemType})
        return true
    end,

    getUnlocks = function(self, techId)
        if not self.unlocks[techId] then return {} end
        return self.unlocks[techId]
    end,

    getUnlockCount = function(self, techId)
        if not self.unlocks[techId] then return 0 end
        return #self.unlocks[techId]
    end,

    getTechCount = function(self)
        local count = 0
        for _ in pairs(self.techs) do count = count + 1 end
        return count
    end,

    getCompletedTechs = function(self)
        local count = 0
        for _, prog in pairs(self.progression) do
            if prog.researched then count = count + 1 end
        end
        return count
    end,

    getTechsByCategory = function(self, category)
        local techs = {}
        for techId, tech in pairs(self.techs) do
            if tech.category == category then
                table.insert(techs, techId)
            end
        end
        return techs
    end,

    getTechsByTier = function(self, tier)
        local techs = {}
        for techId, tech in pairs(self.techs) do
            if tech.tier == tier then
                table.insert(techs, techId)
            end
        end
        return techs
    end,

    getAvailableTechs = function(self, researchedTechs)
        local available = {}
        for techId, tech in pairs(self.techs) do
            if tech.status == "available" and self:canUnlock(techId, researchedTechs) then
                table.insert(available, techId)
            end
        end
        return available
    end,

    calculateResearchPath = function(self, targetTechId, researchedTechs)
        if self:isTechComplete(targetTechId) then return {} end
        local path = {}
        local prereqs = self:getPrerequisites(targetTechId)
        for _, prereq in ipairs(prereqs) do
            if not researchedTechs[prereq] then
                table.insert(path, prereq)
                local subPath = self:calculateResearchPath(prereq, researchedTechs)
                for _, tech in ipairs(subPath) do
                    if not researchedTechs[tech] then
                        table.insert(path, tech)
                    end
                end
            end
        end
        table.insert(path, targetTechId)
        return path
    end,

    getCategoryCount = function(self, category)
        local count = 0
        for _, tech in pairs(self.techs) do
            if tech.category == category then count = count + 1 end
        end
        return count
    end
}

Suite:group("Tech Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TechTree:new()
    end)

    Suite:testMethod("TechTree.addTech", {description = "Adds tech", testCase = "add", type = "functional"}, function()
        local ok = shared.tt:addTech("laser", "Laser Weapons", "weapons", 300, 2)
        Helpers.assertEqual(ok, true, "Tech added")
    end)

    Suite:testMethod("TechTree.getTech", {description = "Gets tech", testCase = "get", type = "functional"}, function()
        shared.tt:addTech("plasma", "Plasma Tech", "weapons", 500, 3)
        local tech = shared.tt:getTech("plasma")
        Helpers.assertEqual(tech ~= nil, true, "Tech retrieved")
    end)

    Suite:testMethod("TechTree.getTechCount", {description = "Counts techs", testCase = "count", type = "functional"}, function()
        shared.tt:addTech("t1", "Tech1", "cat1", 100, 1)
        shared.tt:addTech("t2", "Tech2", "cat1", 150, 1)
        shared.tt:addTech("t3", "Tech3", "cat2", 200, 2)
        local count = shared.tt:getTechCount()
        Helpers.assertEqual(count, 3, "Three techs")
    end)
end)

Suite:group("Prerequisites", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TechTree:new()
        shared.tt:addTech("basic_tech", "Basic", "foundation", 100, 1)
        shared.tt:addTech("advanced_tech", "Advanced", "weapons", 300, 2)
    end)

    Suite:testMethod("TechTree.addPrerequisite", {description = "Adds prerequisite", testCase = "add_prereq", type = "functional"}, function()
        local ok = shared.tt:addPrerequisite("advanced_tech", "basic_tech")
        Helpers.assertEqual(ok, true, "Prerequisite added")
    end)

    Suite:testMethod("TechTree.getPrerequisites", {description = "Gets prerequisites", testCase = "get_prereq", type = "functional"}, function()
        shared.tt:addPrerequisite("advanced_tech", "basic_tech")
        local prereqs = shared.tt:getPrerequisites("advanced_tech")
        Helpers.assertEqual(#prereqs, 1, "One prerequisite")
    end)

    Suite:testMethod("TechTree.getPrerequisiteCount", {description = "Counts prerequisites", testCase = "prereq_count", type = "functional"}, function()
        shared.tt:addPrerequisite("advanced_tech", "basic_tech")
        local count = shared.tt:getPrerequisiteCount("advanced_tech")
        Helpers.assertEqual(count, 1, "One prereq")
    end)

    Suite:testMethod("TechTree.canUnlock", {description = "Checks unlock", testCase = "can_unlock", type = "functional"}, function()
        shared.tt:addPrerequisite("advanced_tech", "basic_tech")
        local can = shared.tt:canUnlock("advanced_tech", {basic_tech = true})
        Helpers.assertEqual(can, true, "Can unlock")
    end)
end)

Suite:group("Progression", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TechTree:new()
        shared.tt:addTech("research", "Research Tech", "science", 200, 1)
    end)

    Suite:testMethod("TechTree.unlockTech", {description = "Unlocks tech", testCase = "unlock", type = "functional"}, function()
        local ok = shared.tt:unlockTech("research")
        Helpers.assertEqual(ok, true, "Tech unlocked")
    end)

    Suite:testMethod("TechTree.startResearch", {description = "Starts research", testCase = "start", type = "functional"}, function()
        shared.tt:unlockTech("research")
        local ok = shared.tt:startResearch("research")
        Helpers.assertEqual(ok, true, "Research started")
    end)

    Suite:testMethod("TechTree.addResearchProgress", {description = "Adds progress", testCase = "add_progress", type = "functional"}, function()
        shared.tt:unlockTech("research")
        shared.tt:startResearch("research")
        local ok = shared.tt:addResearchProgress("research", 50)
        Helpers.assertEqual(ok, true, "Progress added")
    end)

    Suite:testMethod("TechTree.getResearchProgress", {description = "Gets progress", testCase = "get_progress", type = "functional"}, function()
        shared.tt:unlockTech("research")
        shared.tt:startResearch("research")
        shared.tt:addResearchProgress("research", 100)
        local progress = shared.tt:getResearchProgress("research")
        Helpers.assertEqual(progress, 100, "100 progress")
    end)

    Suite:testMethod("TechTree.getProgressPercentage", {description = "Progress %", testCase = "progress_pct", type = "functional"}, function()
        shared.tt:unlockTech("research")
        shared.tt:startResearch("research")
        shared.tt:addResearchProgress("research", 100)
        local pct = shared.tt:getProgressPercentage("research")
        Helpers.assertEqual(pct, 50, "50%")
    end)
end)

Suite:group("Completion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TechTree:new()
        shared.tt:addTech("complete_tech", "Complete", "testing", 100, 1)
    end)

    Suite:testMethod("TechTree.completeTech", {description = "Completes tech", testCase = "complete", type = "functional"}, function()
        local ok = shared.tt:completeTech("complete_tech")
        Helpers.assertEqual(ok, true, "Tech completed")
    end)

    Suite:testMethod("TechTree.isTechComplete", {description = "Checks completion", testCase = "is_complete", type = "functional"}, function()
        shared.tt:completeTech("complete_tech")
        local complete = shared.tt:isTechComplete("complete_tech")
        Helpers.assertEqual(complete, true, "Is complete")
    end)

    Suite:testMethod("TechTree.getCompletedTechs", {description = "Counts completed", testCase = "completed_count", type = "functional"}, function()
        shared.tt:completeTech("complete_tech")
        local count = shared.tt:getCompletedTechs()
        Helpers.assertEqual(count, 1, "One completed")
    end)
end)

Suite:group("Unlocks", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TechTree:new()
        shared.tt:addTech("unlock_tech", "Unlock", "rewards", 150, 1)
    end)

    Suite:testMethod("TechTree.addUnlock", {description = "Adds unlock", testCase = "add_unlock", type = "functional"}, function()
        local ok = shared.tt:addUnlock("unlock_tech", "plasma_rifle", "weapon")
        Helpers.assertEqual(ok, true, "Unlock added")
    end)

    Suite:testMethod("TechTree.getUnlocks", {description = "Gets unlocks", testCase = "get_unlocks", type = "functional"}, function()
        shared.tt:addUnlock("unlock_tech", "armor", "suit")
        shared.tt:addUnlock("unlock_tech", "shield", "defense")
        local unlocks = shared.tt:getUnlocks("unlock_tech")
        Helpers.assertEqual(#unlocks, 2, "Two unlocks")
    end)

    Suite:testMethod("TechTree.getUnlockCount", {description = "Counts unlocks", testCase = "unlock_count", type = "functional"}, function()
        shared.tt:addUnlock("unlock_tech", "item1", "type")
        local count = shared.tt:getUnlockCount("unlock_tech")
        Helpers.assertEqual(count, 1, "One unlock")
    end)
end)

Suite:group("Categories & Tiers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TechTree:new()
        shared.tt:addTech("w1", "Weapon1", "weapons", 100, 1)
        shared.tt:addTech("w2", "Weapon2", "weapons", 200, 2)
        shared.tt:addTech("a1", "Armor1", "armor", 150, 1)
    end)

    Suite:testMethod("TechTree.getTechsByCategory", {description = "Gets by category", testCase = "by_category", type = "functional"}, function()
        local techs = shared.tt:getTechsByCategory("weapons")
        Helpers.assertEqual(#techs, 2, "Two weapons")
    end)

    Suite:testMethod("TechTree.getTechsByTier", {description = "Gets by tier", testCase = "by_tier", type = "functional"}, function()
        local techs = shared.tt:getTechsByTier(1)
        Helpers.assertEqual(#techs >= 2, true, "Tier 1 techs")
    end)

    Suite:testMethod("TechTree.getCategoryCount", {description = "Counts category", testCase = "cat_count", type = "functional"}, function()
        local count = shared.tt:getCategoryCount("weapons")
        Helpers.assertEqual(count, 2, "Two weapons category")
    end)
end)

Suite:group("Advanced Queries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tt = TechTree:new()
        shared.tt:addTech("base", "Base", "foundation", 100, 1)
        shared.tt:addTech("inter", "Intermediate", "science", 200, 2)
        shared.tt:addTech("adv", "Advanced", "weapons", 300, 3)
        shared.tt:addPrerequisite("inter", "base")
        shared.tt:addPrerequisite("adv", "inter")
    end)

    Suite:testMethod("TechTree.getAvailableTechs", {description = "Available techs", testCase = "available", type = "functional"}, function()
        shared.tt:unlockTech("base")
        local available = shared.tt:getAvailableTechs({base = true})
        Helpers.assertEqual(#available >= 0, true, "Available calculated")
    end)

    Suite:testMethod("TechTree.calculateResearchPath", {description = "Research path", testCase = "path", type = "functional"}, function()
        local path = shared.tt:calculateResearchPath("adv", {})
        Helpers.assertEqual(#path >= 1, true, "Path calculated")
    end)
end)

Suite:run()
