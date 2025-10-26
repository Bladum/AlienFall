-- ─────────────────────────────────────────────────────────────────────────
-- CAMPAIGN PROGRESS TEST SUITE
-- FILE: tests2/geoscape/campaign_progress_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.campaign_progress",
    fileName = "campaign_progress.lua",
    description = "Campaign progression with milestones, objectives, and campaign state tracking"
})

print("[CAMPAIGN_PROGRESS_TEST] Setting up")

local CampaignProgress = {
    campaign = {},
    milestones = {},
    objectives = {},
    progress_state = {},
    achievements = {},
    turn_data = {},

    new = function(self)
        return setmetatable({
            campaign = {}, milestones = {}, objectives = {}, progress_state = {},
            achievements = {}, turn_data = {}
        }, {__index = self})
    end,

    startCampaign = function(self, campaignId, name, difficulty, targetDate)
        self.campaign = {
            id = campaignId, name = name, difficulty = difficulty or "normal",
            targetDate = targetDate or 365, startDate = 1, currentDate = 1, isActive = true
        }
        self.progress_state = {
            alienThreatLevel = 20, humanity_strength = 80, world_stability = 70
        }
        return true
    end,

    getCampaignName = function(self)
        return self.campaign.name
    end,

    getDaysRemaining = function(self)
        if not self.campaign.targetDate then return 0 end
        return math.max(0, self.campaign.targetDate - self.campaign.currentDate)
    end,

    advanceDay = function(self)
        if not self.campaign.isActive then return false end
        self.campaign.currentDate = self.campaign.currentDate + 1
        if self.campaign.currentDate > self.campaign.targetDate then
            self.campaign.isActive = false
            return false
        end
        table.insert(self.turn_data, {day = self.campaign.currentDate, threat = self.progress_state.alienThreatLevel, stability = self.progress_state.world_stability})
        return true
    end,

    getCurrentDay = function(self)
        return self.campaign.currentDate
    end,

    registerMilestone = function(self, milestoneId, name, targetDay, description)
        self.milestones[milestoneId] = {
            id = milestoneId, name = name, targetDay = targetDay,
            description = description or "", completed = false, completionDay = nil
        }
        return true
    end,

    completeMilestone = function(self, milestoneId)
        if not self.milestones[milestoneId] then return false end
        self.milestones[milestoneId].completed = true
        self.milestones[milestoneId].completionDay = self.campaign.currentDate
        return true
    end,

    isMilestoneCompleted = function(self, milestoneId)
        if not self.milestones[milestoneId] then return false end
        return self.milestones[milestoneId].completed
    end,

    getMilestoneCount = function(self)
        local count = 0
        for _ in pairs(self.milestones) do count = count + 1 end
        return count
    end,

    getMilestoneCompletionRate = function(self)
        if not next(self.milestones) then return 0 end
        local completed = 0
        for _, ms in pairs(self.milestones) do
            if ms.completed then completed = completed + 1 end
        end
        return math.floor((completed / self:getMilestoneCount()) * 100)
    end,

    addObjective = function(self, objectiveId, name, priority, reward)
        self.objectives[objectiveId] = {
            id = objectiveId, name = name, priority = priority or 1, reward = reward or 10,
            completed = false, progress = 0, max_progress = 100
        }
        return true
    end,

    updateObjectiveProgress = function(self, objectiveId, progress)
        if not self.objectives[objectiveId] then return false end
        self.objectives[objectiveId].progress = math.min(progress, self.objectives[objectiveId].max_progress)
        if self.objectives[objectiveId].progress >= self.objectives[objectiveId].max_progress then
            self.objectives[objectiveId].completed = true
        end
        return true
    end,

    getObjectiveProgress = function(self, objectiveId)
        if not self.objectives[objectiveId] then return 0 end
        return self.objectives[objectiveId].progress
    end,

    isObjectiveCompleted = function(self, objectiveId)
        if not self.objectives[objectiveId] then return false end
        return self.objectives[objectiveId].completed
    end,

    getObjectiveCount = function(self)
        local count = 0
        for _ in pairs(self.objectives) do count = count + 1 end
        return count
    end,

    getObjectivesByPriority = function(self, priority)
        local result = {}
        for objId, obj in pairs(self.objectives) do
            if obj.priority == priority then table.insert(result, objId) end
        end
        return result
    end,

    getTotalObjectiveReward = function(self)
        local total = 0
        for _, obj in pairs(self.objectives) do
            if obj.completed then total = total + obj.reward end
        end
        return total
    end,

    setAlienThreatLevel = function(self, threat)
        self.progress_state.alienThreatLevel = math.max(0, math.min(100, threat))
        return true
    end,

    getAlienThreatLevel = function(self)
        return self.progress_state.alienThreatLevel
    end,

    setHumanityStrength = function(self, strength)
        self.progress_state.humanity_strength = math.max(0, math.min(100, strength))
        return true
    end,

    getHumanityStrength = function(self)
        return self.progress_state.humanity_strength
    end,

    setWorldStability = function(self, stability)
        self.progress_state.world_stability = math.max(0, math.min(100, stability))
        return true
    end,

    getWorldStability = function(self)
        return self.progress_state.world_stability
    end,

    getThreatToStrengthRatio = function(self)
        local strength = self.progress_state.humanity_strength
        if strength == 0 then return 999 end
        return self.progress_state.alienThreatLevel / strength
    end,

    getGlobalProgress = function(self)
        return math.floor((self.campaign.currentDate / self.campaign.targetDate) * 100)
    end,

    unlockAchievement = function(self, achievementId, name, description)
        self.achievements[achievementId] = {id = achievementId, name = name, description = description, unlocked = true, date = self.campaign.currentDate}
        return true
    end,

    isAchievementUnlocked = function(self, achievementId)
        if not self.achievements[achievementId] then return false end
        return self.achievements[achievementId].unlocked
    end,

    getAchievementCount = function(self)
        local count = 0
        for _ in pairs(self.achievements) do count = count + 1 end
        return count
    end,

    calculateCampaignScore = function(self)
        local milestoneScore = self:getMilestoneCompletionRate() * 0.3
        local objectiveScore = math.floor((self:getTotalObjectiveReward() / 1000) * 100) * 0.4
        local threatScore = math.max(0, 100 - self.progress_state.alienThreatLevel) * 0.3
        return math.floor(milestoneScore + objectiveScore + threatScore)
    end,

    isCampaignWon = function(self)
        local threat = self.progress_state.alienThreatLevel
        local strength = self.progress_state.humanity_strength
        return threat < 20 and strength > 60 and self:getMilestoneCompletionRate() >= 80
    end,

    isCampaignLost = function(self)
        return self.progress_state.humanity_strength < 30 or self.progress_state.world_stability < 20
    end,

    endCampaign = function(self, won)
        self.campaign.isActive = false
        self.campaign.result = won and "victory" or "defeat"
        return true
    end,

    getTurnHistory = function(self)
        return self.turn_data
    end,

    getTotalTurns = function(self)
        return #self.turn_data
    end,

    simulateTimeSkip = function(self, days)
        for i = 1, days do
            if not self:advanceDay() then break end
        end
        return self:getCurrentDay()
    end,

    resetCampaign = function(self)
        self.campaign = {}
        self.milestones = {}
        self.objectives = {}
        self.progress_state = {}
        self.achievements = {}
        self.turn_data = {}
        return true
    end
}

Suite:group("Campaign Setup", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
    end)

    Suite:testMethod("CampaignProgress.startCampaign", {description = "Starts campaign", testCase = "start", type = "functional"}, function()
        local ok = shared.cp:startCampaign("campaign1", "First Campaign", "hard", 365)
        Helpers.assertEqual(ok, true, "Started")
    end)

    Suite:testMethod("CampaignProgress.getCampaignName", {description = "Gets campaign name", testCase = "name", type = "functional"}, function()
        shared.cp:startCampaign("cp2", "Campaign Two", "normal")
        local name = shared.cp:getCampaignName()
        Helpers.assertEqual(name, "Campaign Two", "Name matches")
    end)
end)

Suite:group("Time Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
        shared.cp:startCampaign("cp_time", "Time Campaign", "normal", 100)
    end)

    Suite:testMethod("CampaignProgress.advanceDay", {description = "Advances day", testCase = "advance", type = "functional"}, function()
        local ok = shared.cp:advanceDay()
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("CampaignProgress.getCurrentDay", {description = "Gets current day", testCase = "day", type = "functional"}, function()
        shared.cp:advanceDay()
        shared.cp:advanceDay()
        local day = shared.cp:getCurrentDay()
        Helpers.assertEqual(day, 3, "Day 3")
    end)

    Suite:testMethod("CampaignProgress.getDaysRemaining", {description = "Days remaining", testCase = "remaining", type = "functional"}, function()
        shared.cp:advanceDay()
        local remaining = shared.cp:getDaysRemaining()
        Helpers.assertEqual(remaining, 99, "99 days")
    end)
end)

Suite:group("Milestones", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
        shared.cp:startCampaign("cp_ms", "Milestone Campaign", "normal", 200)
    end)

    Suite:testMethod("CampaignProgress.registerMilestone", {description = "Registers milestone", testCase = "register", type = "functional"}, function()
        local ok = shared.cp:registerMilestone("m1", "First Base", 10)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("CampaignProgress.completeMilestone", {description = "Completes milestone", testCase = "complete", type = "functional"}, function()
        shared.cp:registerMilestone("m2", "Build Base", 10)
        local ok = shared.cp:completeMilestone("m2")
        Helpers.assertEqual(ok, true, "Completed")
    end)

    Suite:testMethod("CampaignProgress.isMilestoneCompleted", {description = "Checks completed", testCase = "check_ms", type = "functional"}, function()
        shared.cp:registerMilestone("m3", "Milestone", 5)
        shared.cp:completeMilestone("m3")
        local is = shared.cp:isMilestoneCompleted("m3")
        Helpers.assertEqual(is, true, "Completed")
    end)

    Suite:testMethod("CampaignProgress.getMilestoneCount", {description = "Milestone count", testCase = "count", type = "functional"}, function()
        shared.cp:registerMilestone("m4", "M4", 5)
        shared.cp:registerMilestone("m5", "M5", 10)
        local count = shared.cp:getMilestoneCount()
        Helpers.assertEqual(count, 2, "Two milestones")
    end)

    Suite:testMethod("CampaignProgress.getMilestoneCompletionRate", {description = "Completion rate", testCase = "rate", type = "functional"}, function()
        shared.cp:registerMilestone("m6", "M6", 5)
        shared.cp:registerMilestone("m7", "M7", 10)
        shared.cp:completeMilestone("m6")
        local rate = shared.cp:getMilestoneCompletionRate()
        Helpers.assertEqual(rate, 50, "50% done")
    end)
end)

Suite:group("Objectives", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
        shared.cp:startCampaign("cp_obj", "Objective Campaign", "normal", 150)
    end)

    Suite:testMethod("CampaignProgress.addObjective", {description = "Adds objective", testCase = "add", type = "functional"}, function()
        local ok = shared.cp:addObjective("obj1", "Secure Zone", 1, 50)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("CampaignProgress.updateObjectiveProgress", {description = "Updates progress", testCase = "update", type = "functional"}, function()
        shared.cp:addObjective("obj2", "Defend", 2, 100)
        local ok = shared.cp:updateObjectiveProgress("obj2", 50)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("CampaignProgress.getObjectiveProgress", {description = "Gets progress", testCase = "get_prog", type = "functional"}, function()
        shared.cp:addObjective("obj3", "Attack", 1, 75)
        shared.cp:updateObjectiveProgress("obj3", 60)
        local prog = shared.cp:getObjectiveProgress("obj3")
        Helpers.assertEqual(prog, 60, "Progress 60")
    end)

    Suite:testMethod("CampaignProgress.isObjectiveCompleted", {description = "Checks completed", testCase = "is_done", type = "functional"}, function()
        shared.cp:addObjective("obj4", "Research", 2, 80)
        shared.cp:updateObjectiveProgress("obj4", 100)
        local done = shared.cp:isObjectiveCompleted("obj4")
        Helpers.assertEqual(done, true, "Completed")
    end)

    Suite:testMethod("CampaignProgress.getObjectiveCount", {description = "Objective count", testCase = "obj_count", type = "functional"}, function()
        shared.cp:addObjective("o1", "Obj1", 1, 50)
        shared.cp:addObjective("o2", "Obj2", 1, 50)
        local count = shared.cp:getObjectiveCount()
        Helpers.assertEqual(count, 2, "Two objectives")
    end)

    Suite:testMethod("CampaignProgress.getObjectivesByPriority", {description = "By priority", testCase = "priority", type = "functional"}, function()
        shared.cp:addObjective("op1", "High", 1, 50)
        shared.cp:addObjective("op2", "Low", 3, 50)
        local high = shared.cp:getObjectivesByPriority(1)
        Helpers.assertEqual(#high, 1, "One high")
    end)

    Suite:testMethod("CampaignProgress.getTotalObjectiveReward", {description = "Total reward", testCase = "reward", type = "functional"}, function()
        shared.cp:addObjective("or1", "Obj1", 1, 100)
        shared.cp:addObjective("or2", "Obj2", 1, 200)
        shared.cp:updateObjectiveProgress("or1", 100)
        shared.cp:updateObjectiveProgress("or2", 100)
        local total = shared.cp:getTotalObjectiveReward()
        Helpers.assertEqual(total, 300, "Total 300")
    end)
end)

Suite:group("Campaign State", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
        shared.cp:startCampaign("cp_state", "State Campaign", "normal", 180)
    end)

    Suite:testMethod("CampaignProgress.setAlienThreatLevel", {description = "Sets threat", testCase = "threat", type = "functional"}, function()
        local ok = shared.cp:setAlienThreatLevel(50)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("CampaignProgress.getAlienThreatLevel", {description = "Gets threat", testCase = "get_threat", type = "functional"}, function()
        shared.cp:setAlienThreatLevel(65)
        local threat = shared.cp:getAlienThreatLevel()
        Helpers.assertEqual(threat, 65, "Threat 65")
    end)

    Suite:testMethod("CampaignProgress.setHumanityStrength", {description = "Sets strength", testCase = "strength", type = "functional"}, function()
        local ok = shared.cp:setHumanityStrength(75)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("CampaignProgress.getHumanityStrength", {description = "Gets strength", testCase = "get_strength", type = "functional"}, function()
        shared.cp:setHumanityStrength(85)
        local str = shared.cp:getHumanityStrength()
        Helpers.assertEqual(str, 85, "Strength 85")
    end)

    Suite:testMethod("CampaignProgress.setWorldStability", {description = "Sets stability", testCase = "stability", type = "functional"}, function()
        local ok = shared.cp:setWorldStability(70)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("CampaignProgress.getWorldStability", {description = "Gets stability", testCase = "get_stability", type = "functional"}, function()
        shared.cp:setWorldStability(60)
        local stab = shared.cp:getWorldStability()
        Helpers.assertEqual(stab, 60, "Stability 60")
    end)

    Suite:testMethod("CampaignProgress.getThreatToStrengthRatio", {description = "Threat/Strength", testCase = "ratio", type = "functional"}, function()
        shared.cp:setAlienThreatLevel(40)
        shared.cp:setHumanityStrength(80)
        local ratio = shared.cp:getThreatToStrengthRatio()
        Helpers.assertEqual(ratio, 0.5, "Ratio 0.5")
    end)
end)

Suite:group("Campaign Progress", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
        shared.cp:startCampaign("cp_prog", "Progress Campaign", "normal", 100)
    end)

    Suite:testMethod("CampaignProgress.getGlobalProgress", {description = "Global progress", testCase = "global", type = "functional"}, function()
        shared.cp:advanceDay()
        shared.cp:advanceDay()
        local prog = shared.cp:getGlobalProgress()
        Helpers.assertEqual(prog, 3, "3% progress")
    end)

    Suite:testMethod("CampaignProgress.calculateCampaignScore", {description = "Campaign score", testCase = "score", type = "functional"}, function()
        local score = shared.cp:calculateCampaignScore()
        Helpers.assertEqual(score >= 0, true, "Score >= 0")
    end)
end)

Suite:group("Achievements", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
        shared.cp:startCampaign("cp_ach", "Achievement Campaign", "normal", 150)
    end)

    Suite:testMethod("CampaignProgress.unlockAchievement", {description = "Unlocks achievement", testCase = "unlock", type = "functional"}, function()
        local ok = shared.cp:unlockAchievement("ach1", "First Victory", "Win first mission")
        Helpers.assertEqual(ok, true, "Unlocked")
    end)

    Suite:testMethod("CampaignProgress.isAchievementUnlocked", {description = "Checks unlocked", testCase = "is_unlocked", type = "functional"}, function()
        shared.cp:unlockAchievement("ach2", "Second Win", "Win second mission")
        local is = shared.cp:isAchievementUnlocked("ach2")
        Helpers.assertEqual(is, true, "Unlocked")
    end)

    Suite:testMethod("CampaignProgress.getAchievementCount", {description = "Achievement count", testCase = "ach_count", type = "functional"}, function()
        shared.cp:unlockAchievement("a1", "A1", "Desc")
        shared.cp:unlockAchievement("a2", "A2", "Desc")
        local count = shared.cp:getAchievementCount()
        Helpers.assertEqual(count, 2, "Two achievements")
    end)
end)

Suite:group("Victory Conditions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
        shared.cp:startCampaign("cp_victory", "Victory Campaign", "normal", 200)
    end)

    Suite:testMethod("CampaignProgress.isCampaignWon", {description = "Campaign won", testCase = "won", type = "functional"}, function()
        shared.cp:setAlienThreatLevel(10)
        shared.cp:setHumanityStrength(85)
        shared.cp:registerMilestone("vm1", "M1", 50)
        shared.cp:registerMilestone("vm2", "M2", 100)
        shared.cp:registerMilestone("vm3", "M3", 150)
        shared.cp:registerMilestone("vm4", "M4", 200)
        shared.cp:completeMilestone("vm1")
        shared.cp:completeMilestone("vm2")
        shared.cp:completeMilestone("vm3")
        shared.cp:completeMilestone("vm4")
        local won = shared.cp:isCampaignWon()
        Helpers.assertEqual(won, true, "Won")
    end)

    Suite:testMethod("CampaignProgress.isCampaignLost", {description = "Campaign lost", testCase = "lost", type = "functional"}, function()
        shared.cp:setHumanityStrength(20)
        local lost = shared.cp:isCampaignLost()
        Helpers.assertEqual(lost, true, "Lost")
    end)

    Suite:testMethod("CampaignProgress.endCampaign", {description = "Ends campaign", testCase = "end", type = "functional"}, function()
        local ok = shared.cp:endCampaign(true)
        Helpers.assertEqual(ok, true, "Ended")
    end)
end)

Suite:group("History Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
        shared.cp:startCampaign("cp_hist", "History Campaign", "normal", 50)
    end)

    Suite:testMethod("CampaignProgress.getTurnHistory", {description = "Turn history", testCase = "history", type = "functional"}, function()
        shared.cp:advanceDay()
        local hist = shared.cp:getTurnHistory()
        Helpers.assertEqual(#hist > 0, true, "Has history")
    end)

    Suite:testMethod("CampaignProgress.getTotalTurns", {description = "Total turns", testCase = "turns", type = "functional"}, function()
        shared.cp:advanceDay()
        shared.cp:advanceDay()
        local turns = shared.cp:getTotalTurns()
        Helpers.assertEqual(turns, 2, "Two turns")
    end)

    Suite:testMethod("CampaignProgress.simulateTimeSkip", {description = "Time skip", testCase = "skip", type = "functional"}, function()
        local day = shared.cp:simulateTimeSkip(10)
        Helpers.assertEqual(day, 11, "Day 11")
    end)
end)

Suite:group("Campaign Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cp = CampaignProgress:new()
    end)

    Suite:testMethod("CampaignProgress.resetCampaign", {description = "Resets campaign", testCase = "reset", type = "functional"}, function()
        shared.cp:startCampaign("cp_reset", "Reset", "normal")
        local ok = shared.cp:resetCampaign()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
