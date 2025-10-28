-- ─────────────────────────────────────────────────────────────────────────
-- MISSION GENERATOR TEST SUITE
-- FILE: tests2/geoscape/mission_generator_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.mission_generator",
    fileName = "mission_generator.lua",
    description = "Procedural mission generation with varied difficulty and objectives"
})

print("[MISSION_GENERATOR_TEST] Setting up")

local MissionGenerator = {
    missions = {},
    templates = {},
    objectives = {},
    next_id = 1,

    new = function(self)
        return setmetatable({missions = {}, templates = {}, objectives = {}, next_id = 1}, {__index = self})
    end,

    registerTemplate = function(self, templateId, name, baseReward, difficulty)
        self.templates[templateId] = {id = templateId, name = name, baseReward = baseReward, difficulty = difficulty, missionCount = 0}
        return true
    end,

    generateMission = function(self, templateId, location, difficulty)
        if not self.templates[templateId] then return nil end
        local id = self.next_id
        self.next_id = self.next_id + 1
        local reward = self.templates[templateId].baseReward * (1 + (difficulty or 0) * 0.1)
        self.missions[id] = {id = id, templateId = templateId, location = location, difficulty = difficulty or 1, reward = math.floor(reward), completed = false, objectives = {}}
        self.templates[templateId].missionCount = self.templates[templateId].missionCount + 1
        return id
    end,

    getMission = function(self, missionId)
        return self.missions[missionId]
    end,

    addObjective = function(self, missionId, objectiveType, description)
        if not self.missions[missionId] then return false end
        table.insert(self.missions[missionId].objectives, {type = objectiveType, description = description, completed = false})
        return true
    end,

    completeObjective = function(self, missionId, objectiveIndex)
        if not self.missions[missionId] or not self.missions[missionId].objectives[objectiveIndex] then return false end
        self.missions[missionId].objectives[objectiveIndex].completed = true
        return true
    end,

    completeMission = function(self, missionId)
        if not self.missions[missionId] then return false end
        self.missions[missionId].completed = true
        return true
    end,

    getMissionReward = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return self.missions[missionId].reward
    end,

    getObjectiveCount = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return #self.missions[missionId].objectives
    end,

    getCompletedObjectives = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        local count = 0
        for _, obj in ipairs(self.missions[missionId].objectives) do
            if obj.completed then count = count + 1 end
        end
        return count
    end,

    getMissionCount = function(self)
        local count = 0
        for _ in pairs(self.missions) do count = count + 1 end
        return count
    end,

    getTemplateCount = function(self)
        local count = 0
        for _ in pairs(self.templates) do count = count + 1 end
        return count
    end,

    getMissionDifficulty = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return self.missions[missionId].difficulty
    end,

    getCompletedMissions = function(self)
        local count = 0
        for _, mission in pairs(self.missions) do
            if mission.completed then count = count + 1 end
        end
        return count
    end
}

Suite:group("Mission Templates", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mg = MissionGenerator:new()
    end)

    Suite:testMethod("MissionGenerator.new", {description = "Creates generator", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.mg ~= nil, true, "Generator created")
    end)

    Suite:testMethod("MissionGenerator.registerTemplate", {description = "Registers template", testCase = "register", type = "functional"}, function()
        local ok = shared.mg:registerTemplate("rescue", "Rescue Mission", 500, 3)
        Helpers.assertEqual(ok, true, "Template registered")
    end)

    Suite:testMethod("MissionGenerator.getTemplateCount", {description = "Counts templates", testCase = "count", type = "functional"}, function()
        shared.mg:registerTemplate("t1", "T1", 100, 1)
        shared.mg:registerTemplate("t2", "T2", 200, 2)
        shared.mg:registerTemplate("t3", "T3", 300, 3)
        local count = shared.mg:getTemplateCount()
        Helpers.assertEqual(count, 3, "Three templates")
    end)
end)

Suite:group("Mission Generation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mg = MissionGenerator:new()
        shared.mg:registerTemplate("defend", "Defend Location", 400, 2)
    end)

    Suite:testMethod("MissionGenerator.generateMission", {description = "Generates mission", testCase = "generate", type = "functional"}, function()
        local id = shared.mg:generateMission("defend", "base_alpha", 1)
        Helpers.assertEqual(id ~= nil, true, "Mission generated")
    end)

    Suite:testMethod("MissionGenerator.getMission", {description = "Retrieves mission", testCase = "get", type = "functional"}, function()
        local id = shared.mg:generateMission("defend", "base_beta", 2)
        local mission = shared.mg:getMission(id)
        Helpers.assertEqual(mission ~= nil, true, "Mission retrieved")
    end)

    Suite:testMethod("MissionGenerator.getMissionReward", {description = "Scales reward", testCase = "reward", type = "functional"}, function()
        local id = shared.mg:generateMission("defend", "location", 1)
        local reward = shared.mg:getMissionReward(id)
        Helpers.assertEqual(reward, 440, "Reward 440")
    end)

    Suite:testMethod("MissionGenerator.getMissionDifficulty", {description = "Gets difficulty", testCase = "difficulty", type = "functional"}, function()
        local id = shared.mg:generateMission("defend", "loc", 3)
        local diff = shared.mg:getMissionDifficulty(id)
        Helpers.assertEqual(diff, 3, "Difficulty 3")
    end)

    Suite:testMethod("MissionGenerator.getMissionCount", {description = "Counts missions", testCase = "count", type = "functional"}, function()
        shared.mg:generateMission("defend", "l1", 1)
        shared.mg:generateMission("defend", "l2", 2)
        shared.mg:generateMission("defend", "l3", 3)
        local count = shared.mg:getMissionCount()
        Helpers.assertEqual(count, 3, "Three missions")
    end)
end)

Suite:group("Objectives", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mg = MissionGenerator:new()
        shared.mg:registerTemplate("assault", "Assault", 600, 3)
        shared.id = shared.mg:generateMission("assault", "sector_7", 2)
    end)

    Suite:testMethod("MissionGenerator.addObjective", {description = "Adds objective", testCase = "add_obj", type = "functional"}, function()
        local ok = shared.mg:addObjective(shared.id, "eliminate", "Eliminate all aliens")
        Helpers.assertEqual(ok, true, "Objective added")
    end)

    Suite:testMethod("MissionGenerator.getObjectiveCount", {description = "Counts objectives", testCase = "count_obj", type = "functional"}, function()
        shared.mg:addObjective(shared.id, "survive", "Survive 3 turns")
        shared.mg:addObjective(shared.id, "protect", "Protect VIP")
        shared.mg:addObjective(shared.id, "escape", "Escape area")
        local count = shared.mg:getObjectiveCount(shared.id)
        Helpers.assertEqual(count, 3, "Three objectives")
    end)

    Suite:testMethod("MissionGenerator.completeObjective", {description = "Completes objective", testCase = "complete_obj", type = "functional"}, function()
        shared.mg:addObjective(shared.id, "task", "Task description")
        local ok = shared.mg:completeObjective(shared.id, 1)
        Helpers.assertEqual(ok, true, "Objective completed")
    end)

    Suite:testMethod("MissionGenerator.getCompletedObjectives", {description = "Counts completed", testCase = "completed_count", type = "functional"}, function()
        shared.mg:addObjective(shared.id, "o1", "Desc 1")
        shared.mg:addObjective(shared.id, "o2", "Desc 2")
        shared.mg:addObjective(shared.id, "o3", "Desc 3")
        shared.mg:completeObjective(shared.id, 1)
        shared.mg:completeObjective(shared.id, 3)
        local count = shared.mg:getCompletedObjectives(shared.id)
        Helpers.assertEqual(count, 2, "Two completed")
    end)
end)

Suite:group("Mission Progress", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mg = MissionGenerator:new()
        shared.mg:registerTemplate("extract", "Extract", 700, 4)
        shared.id = shared.mg:generateMission("extract", "deep_site", 2)
    end)

    Suite:testMethod("MissionGenerator.completeMission", {description = "Completes mission", testCase = "complete", type = "functional"}, function()
        local ok = shared.mg:completeMission(shared.id)
        Helpers.assertEqual(ok, true, "Mission completed")
    end)

    Suite:testMethod("MissionGenerator.getCompletedMissions", {description = "Counts completed", testCase = "count_completed", type = "functional"}, function()
        local id1 = shared.mg:generateMission("extract", "s1", 1)
        local id2 = shared.mg:generateMission("extract", "s2", 2)
        local id3 = shared.mg:generateMission("extract", "s3", 3)
        shared.mg:completeMission(id1)
        shared.mg:completeMission(id3)
        local count = shared.mg:getCompletedMissions()
        Helpers.assertEqual(count, 2, "Two completed")
    end)
end)

Suite:run()
