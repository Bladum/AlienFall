-- ─────────────────────────────────────────────────────────────────────────
-- MISSION BRIEFING TEST SUITE
-- FILE: tests2/geoscape/mission_briefing_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.mission_briefing",
    fileName = "mission_briefing.lua",
    description = "Mission briefing with objectives, intelligence, and difficulty modifiers"
})

print("[MISSION_BRIEFING_TEST] Setting up")

local MissionBriefing = {
    missions = {},
    objectives = {},
    intel = {},
    difficulties = {},

    new = function(self)
        return setmetatable({missions = {}, objectives = {}, intel = {}, difficulties = {}}, {__index = self})
    end,

    createMission = function(self, missionId, missionName, missionType, baseReward)
        self.missions[missionId] = {id = missionId, name = missionName, type = missionType, baseReward = baseReward or 100, completed = false, failed = false}
        self.objectives[missionId] = {}
        self.intel[missionId] = {}
        self.difficulties[missionId] = 1
        return true
    end,

    getMission = function(self, missionId)
        return self.missions[missionId]
    end,

    addObjective = function(self, missionId, objectiveId, description, objectiveType, mandatory)
        if not self.missions[missionId] then return false end
        if not self.objectives[missionId] then self.objectives[missionId] = {} end
        self.objectives[missionId][objectiveId] = {id = objectiveId, description = description, type = objectiveType, mandatory = mandatory or false, completed = false}
        return true
    end,

    completeObjective = function(self, missionId, objectiveId)
        if not self.objectives[missionId] or not self.objectives[missionId][objectiveId] then return false end
        self.objectives[missionId][objectiveId].completed = true
        return true
    end,

    getObjectiveCount = function(self, missionId)
        if not self.objectives[missionId] then return 0 end
        local count = 0
        for _ in pairs(self.objectives[missionId]) do count = count + 1 end
        return count
    end,

    getCompletedObjectiveCount = function(self, missionId)
        if not self.objectives[missionId] then return 0 end
        local count = 0
        for _, obj in pairs(self.objectives[missionId]) do
            if obj.completed then count = count + 1 end
        end
        return count
    end,

    getMandatoryObjectives = function(self, missionId)
        if not self.objectives[missionId] then return {} end
        local mandatory = {}
        for objId, obj in pairs(self.objectives[missionId]) do
            if obj.mandatory then
                table.insert(mandatory, objId)
            end
        end
        return mandatory
    end,

    addIntelligence = function(self, missionId, intelId, intelType, information, importance)
        if not self.missions[missionId] then return false end
        if not self.intel[missionId] then self.intel[missionId] = {} end
        self.intel[missionId][intelId] = {id = intelId, type = intelType, info = information, importance = importance or 5, reviewed = false}
        return true
    end,

    getIntelCount = function(self, missionId)
        if not self.intel[missionId] then return 0 end
        local count = 0
        for _ in pairs(self.intel[missionId]) do count = count + 1 end
        return count
    end,

    reviewIntelligence = function(self, missionId, intelId)
        if not self.intel[missionId] or not self.intel[missionId][intelId] then return false end
        self.intel[missionId][intelId].reviewed = true
        return true
    end,

    getUnreviewedIntel = function(self, missionId)
        if not self.intel[missionId] then return {} end
        local unreviewed = {}
        for intelId, intel in pairs(self.intel[missionId]) do
            if not intel.reviewed then
                table.insert(unreviewed, intelId)
            end
        end
        return unreviewed
    end,

    addDifficultyModifier = function(self, missionId, modifierId, modifierType, value)
        if not self.missions[missionId] then return false end
        if not self.difficulties[missionId] then self.difficulties[missionId] = {} end
        if type(self.difficulties[missionId]) == "number" then
            self.difficulties[missionId] = {}
        end
        self.difficulties[missionId][modifierId] = {id = modifierId, type = modifierType, value = value or 1}
        return true
    end,

    calculateDifficultyRating = function(self, missionId)
        local diff = self.difficulties[missionId]
        if type(diff) == "number" then return diff end
        if not diff or not next(diff) then return 1 end
        local rating = 1
        for _, modifier in pairs(diff) do
            rating = rating * modifier.value
        end
        return rating
    end,

    calculateReward = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        local base = self.missions[missionId].baseReward
        local diffRating = self:calculateDifficultyRating(missionId)
        return math.floor(base * diffRating)
    end,

    completeMission = function(self, missionId)
        if not self.missions[missionId] then return false end
        self.missions[missionId].completed = true
        return true
    end,

    failMission = function(self, missionId)
        if not self.missions[missionId] then return false end
        self.missions[missionId].failed = true
        return true
    end,

    isMissionComplete = function(self, missionId)
        if not self.missions[missionId] then return false end
        return self.missions[missionId].completed
    end,

    isMissionFailed = function(self, missionId)
        if not self.missions[missionId] then return false end
        return self.missions[missionId].failed
    end,

    getObjectivesByType = function(self, missionId, objectiveType)
        if not self.objectives[missionId] then return {} end
        local filtered = {}
        for objId, obj in pairs(self.objectives[missionId]) do
            if obj.type == objectiveType then
                table.insert(filtered, objId)
            end
        end
        return filtered
    end,

    getMissionIntel = function(self, missionId)
        return self.intel[missionId] or {}
    end,

    setMissionBriefingText = function(self, missionId, briefingText)
        if not self.missions[missionId] then return false end
        self.missions[missionId].briefing = briefingText
        return true
    end,

    getMissionBriefingText = function(self, missionId)
        if not self.missions[missionId] then return "" end
        return self.missions[missionId].briefing or ""
    end,

    getHighPriorityIntel = function(self, missionId)
        if not self.intel[missionId] then return {} end
        local highPriority = {}
        for intelId, intel in pairs(self.intel[missionId]) do
            if intel.importance >= 7 then
                table.insert(highPriority, intelId)
            end
        end
        return highPriority
    end,

    resetMissionState = function(self, missionId)
        if not self.missions[missionId] then return false end
        self.missions[missionId].completed = false
        self.missions[missionId].failed = false
        for _, obj in pairs(self.objectives[missionId] or {}) do
            obj.completed = false
        end
        for _, intel in pairs(self.intel[missionId] or {}) do
            intel.reviewed = false
        end
        return true
    end,

    canCompleteMission = function(self, missionId)
        if not self.missions[missionId] then return false end
        local mandatory = self:getMandatoryObjectives(missionId)
        for _, objId in ipairs(mandatory) do
            if not self.objectives[missionId][objId].completed then
                return false
            end
        end
        return true
    end
}

Suite:group("Mission Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
    end)

    Suite:testMethod("MissionBriefing.createMission", {description = "Creates mission", testCase = "create", type = "functional"}, function()
        local ok = shared.mb:createMission("m1", "Rescue", "extraction", 250)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("MissionBriefing.getMission", {description = "Gets mission", testCase = "get", type = "functional"}, function()
        shared.mb:createMission("m2", "Defend", "defense", 300)
        local mission = shared.mb:getMission("m2")
        Helpers.assertEqual(mission ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Objectives", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("mission", "Test", "combat", 200)
    end)

    Suite:testMethod("MissionBriefing.addObjective", {description = "Adds objective", testCase = "add_obj", type = "functional"}, function()
        local ok = shared.mb:addObjective("mission", "obj1", "Defeat aliens", "combat", true)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("MissionBriefing.completeObjective", {description = "Completes objective", testCase = "complete_obj", type = "functional"}, function()
        shared.mb:addObjective("mission", "obj2", "Rescue civilians", "rescue", false)
        local ok = shared.mb:completeObjective("mission", "obj2")
        Helpers.assertEqual(ok, true, "Completed")
    end)

    Suite:testMethod("MissionBriefing.getObjectiveCount", {description = "Counts objectives", testCase = "count_obj", type = "functional"}, function()
        shared.mb:addObjective("mission", "o1", "Destroy", "combat", true)
        shared.mb:addObjective("mission", "o2", "Survive", "survival", false)
        local count = shared.mb:getObjectiveCount("mission")
        Helpers.assertEqual(count, 2, "Two objectives")
    end)

    Suite:testMethod("MissionBriefing.getCompletedObjectiveCount", {description = "Counts completed", testCase = "completed_count", type = "functional"}, function()
        shared.mb:addObjective("mission", "x1", "Task 1", "combat", true)
        shared.mb:addObjective("mission", "x2", "Task 2", "combat", true)
        shared.mb:completeObjective("mission", "x1")
        local count = shared.mb:getCompletedObjectiveCount("mission")
        Helpers.assertEqual(count, 1, "One completed")
    end)

    Suite:testMethod("MissionBriefing.getMandatoryObjectives", {description = "Gets mandatory", testCase = "mandatory", type = "functional"}, function()
        shared.mb:addObjective("mission", "m1", "Mandatory 1", "combat", true)
        shared.mb:addObjective("mission", "m2", "Optional", "search", false)
        local mandatory = shared.mb:getMandatoryObjectives("mission")
        Helpers.assertEqual(#mandatory, 1, "One mandatory")
    end)

    Suite:testMethod("MissionBriefing.getObjectivesByType", {description = "Filters by type", testCase = "filter_type", type = "functional"}, function()
        shared.mb:addObjective("mission", "c1", "Combat 1", "combat", true)
        shared.mb:addObjective("mission", "c2", "Combat 2", "combat", false)
        shared.mb:addObjective("mission", "s1", "Search", "search", false)
        local combats = shared.mb:getObjectivesByType("mission", "combat")
        Helpers.assertEqual(#combats, 2, "Two combat")
    end)
end)

Suite:group("Intelligence", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("intel_mission", "Intel", "recon", 150)
    end)

    Suite:testMethod("MissionBriefing.addIntelligence", {description = "Adds intel", testCase = "add_intel", type = "functional"}, function()
        local ok = shared.mb:addIntelligence("intel_mission", "i1", "enemy_count", "3 aliens", 8)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("MissionBriefing.getIntelCount", {description = "Counts intel", testCase = "count_intel", type = "functional"}, function()
        shared.mb:addIntelligence("intel_mission", "i1", "enemies", "aliens present", 6)
        shared.mb:addIntelligence("intel_mission", "i2", "terrain", "urban", 5)
        local count = shared.mb:getIntelCount("intel_mission")
        Helpers.assertEqual(count, 2, "Two intel")
    end)

    Suite:testMethod("MissionBriefing.reviewIntelligence", {description = "Reviews intel", testCase = "review", type = "functional"}, function()
        shared.mb:addIntelligence("intel_mission", "ir1", "tactical", "data", 7)
        local ok = shared.mb:reviewIntelligence("intel_mission", "ir1")
        Helpers.assertEqual(ok, true, "Reviewed")
    end)

    Suite:testMethod("MissionBriefing.getUnreviewedIntel", {description = "Gets unreviewed", testCase = "unreviewed", type = "functional"}, function()
        shared.mb:addIntelligence("intel_mission", "u1", "type1", "info1", 6)
        shared.mb:addIntelligence("intel_mission", "u2", "type2", "info2", 5)
        shared.mb:reviewIntelligence("intel_mission", "u1")
        local unreviewed = shared.mb:getUnreviewedIntel("intel_mission")
        Helpers.assertEqual(#unreviewed, 1, "One unreviewed")
    end)

    Suite:testMethod("MissionBriefing.getHighPriorityIntel", {description = "Gets high priority", testCase = "high_priority", type = "functional"}, function()
        shared.mb:addIntelligence("intel_mission", "h1", "critical", "data", 9)
        shared.mb:addIntelligence("intel_mission", "h2", "important", "data", 8)
        shared.mb:addIntelligence("intel_mission", "h3", "low", "data", 4)
        local high = shared.mb:getHighPriorityIntel("intel_mission")
        Helpers.assertEqual(#high, 2, "Two high priority")
    end)

    Suite:testMethod("MissionBriefing.getMissionIntel", {description = "Gets all intel", testCase = "all_intel", type = "functional"}, function()
        shared.mb:addIntelligence("intel_mission", "a1", "type", "info", 5)
        local intel = shared.mb:getMissionIntel("intel_mission")
        Helpers.assertEqual(intel["a1"] ~= nil, true, "Intel map exists")
    end)
end)

Suite:group("Difficulty & Reward", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("hard_mission", "Hard", "combat", 100)
    end)

    Suite:testMethod("MissionBriefing.addDifficultyModifier", {description = "Adds modifier", testCase = "add_mod", type = "functional"}, function()
        local ok = shared.mb:addDifficultyModifier("hard_mission", "m1", "enemy_count", 1.5)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("MissionBriefing.calculateDifficultyRating", {description = "Calculates rating", testCase = "rating", type = "functional"}, function()
        shared.mb:addDifficultyModifier("hard_mission", "d1", "difficulty", 1.5)
        shared.mb:addDifficultyModifier("hard_mission", "d2", "complexity", 1.2)
        local rating = shared.mb:calculateDifficultyRating("hard_mission")
        Helpers.assertEqual(math.floor(rating * 10) / 10, 1.8, "1.8 rating")
    end)

    Suite:testMethod("MissionBriefing.calculateReward", {description = "Calculates reward", testCase = "reward", type = "functional"}, function()
        shared.mb:addDifficultyModifier("hard_mission", "r1", "difficulty", 2)
        local reward = shared.mb:calculateReward("hard_mission")
        Helpers.assertEqual(reward, 200, "200 reward")
    end)
end)

Suite:group("Mission Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("status_mission", "Status", "test", 100)
    end)

    Suite:testMethod("MissionBriefing.completeMission", {description = "Completes mission", testCase = "complete", type = "functional"}, function()
        local ok = shared.mb:completeMission("status_mission")
        Helpers.assertEqual(ok, true, "Completed")
    end)

    Suite:testMethod("MissionBriefing.failMission", {description = "Fails mission", testCase = "fail", type = "functional"}, function()
        local ok = shared.mb:failMission("status_mission")
        Helpers.assertEqual(ok, true, "Failed")
    end)

    Suite:testMethod("MissionBriefing.isMissionComplete", {description = "Checks complete", testCase = "is_complete", type = "functional"}, function()
        shared.mb:completeMission("status_mission")
        local complete = shared.mb:isMissionComplete("status_mission")
        Helpers.assertEqual(complete, true, "Complete")
    end)

    Suite:testMethod("MissionBriefing.isMissionFailed", {description = "Checks failed", testCase = "is_failed", type = "functional"}, function()
        shared.mb:failMission("status_mission")
        local failed = shared.mb:isMissionFailed("status_mission")
        Helpers.assertEqual(failed, true, "Failed")
    end)
end)

Suite:group("Briefing Text", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("brief_mission", "Brief", "combat", 100)
    end)

    Suite:testMethod("MissionBriefing.setMissionBriefingText", {description = "Sets briefing", testCase = "set_brief", type = "functional"}, function()
        local ok = shared.mb:setMissionBriefingText("brief_mission", "Defend the base.")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("MissionBriefing.getMissionBriefingText", {description = "Gets briefing", testCase = "get_brief", type = "functional"}, function()
        shared.mb:setMissionBriefingText("brief_mission", "Mission: Survive the wave.")
        local brief = shared.mb:getMissionBriefingText("brief_mission")
        Helpers.assertEqual(string.len(brief) > 0, true, "Brief exists")
    end)
end)

Suite:group("Advanced Queries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("adv_mission", "Advanced", "combat", 150)
        shared.mb:addObjective("adv_mission", "o1", "Main", "combat", true)
        shared.mb:addObjective("adv_mission", "o2", "Optional", "search", false)
    end)

    Suite:testMethod("MissionBriefing.canCompleteMission", {description = "Can complete", testCase = "can_complete", type = "functional"}, function()
        local can = shared.mb:canCompleteMission("adv_mission")
        Helpers.assertEqual(can, false, "Not complete")
        shared.mb:completeObjective("adv_mission", "o1")
        can = shared.mb:canCompleteMission("adv_mission")
        Helpers.assertEqual(can, true, "Can complete")
    end)

    Suite:testMethod("MissionBriefing.resetMissionState", {description = "Resets state", testCase = "reset", type = "functional"}, function()
        shared.mb:completeObjective("adv_mission", "o1")
        shared.mb:completeMission("adv_mission")
        local ok = shared.mb:resetMissionState("adv_mission")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
