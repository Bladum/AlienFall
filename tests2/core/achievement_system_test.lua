-- ─────────────────────────────────────────────────────────────────────────
-- ACHIEVEMENT SYSTEM TEST SUITE
-- FILE: tests2/core/achievement_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.achievement_system",
    fileName = "achievement_system.lua",
    description = "Player achievements and progression tracking"
})

print("[ACHIEVEMENT_SYSTEM_TEST] Setting up")

local AchievementSystem = {
    achievements = {},
    unlocked = {},
    stats = {},

    new = function(self)
        return setmetatable({achievements = {}, unlocked = {}, stats = {}}, {__index = self})
    end,

    registerAchievement = function(self, achId, name, description, requirement)
        self.achievements[achId] = {id = achId, name = name, description = description, requirement = requirement, unlocked = false, unlockedAt = 0}
        return true
    end,

    getAchievement = function(self, achId)
        return self.achievements[achId]
    end,

    unlockAchievement = function(self, achId)
        if not self.achievements[achId] then return false end
        self.achievements[achId].unlocked = true
        self.achievements[achId].unlockedAt = os.time()
        self.unlocked[achId] = true
        return true
    end,

    isUnlocked = function(self, achId)
        if not self.achievements[achId] then return false end
        return self.achievements[achId].unlocked
    end,

    getUnlockedCount = function(self)
        local count = 0
        for _ in pairs(self.unlocked) do count = count + 1 end
        return count
    end,

    getTotalAchievements = function(self)
        local count = 0
        for _ in pairs(self.achievements) do count = count + 1 end
        return count
    end,

    recordStat = function(self, statName, value)
        if not self.stats[statName] then self.stats[statName] = 0 end
        self.stats[statName] = self.stats[statName] + value
        return true
    end,

    getStat = function(self, statName)
        return self.stats[statName] or 0
    end,

    checkAchievementProgress = function(self, achId, currentValue, targetValue)
        if not self.achievements[achId] then return false end
        if currentValue >= targetValue then
            return true
        end
        return false
    end,

    getProgress = function(self, achId)
        if not self.achievements[achId] then return nil end
        return {achieved = self.achievements[achId].unlocked, requirement = self.achievements[achId].requirement}
    end,

    getUnlockedList = function(self)
        local result = {}
        for id, _ in pairs(self.unlocked) do
            table.insert(result, id)
        end
        return result
    end,

    getLockedList = function(self)
        local result = {}
        for id, achievement in pairs(self.achievements) do
            if not achievement.unlocked then
                table.insert(result, id)
            end
        end
        return result
    end
}

Suite:group("Achievement Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = AchievementSystem:new()
    end)

    Suite:testMethod("AchievementSystem.new", {description = "Creates system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.as ~= nil, true, "System created")
    end)

    Suite:testMethod("AchievementSystem.registerAchievement", {description = "Registers achievement", testCase = "register", type = "functional"}, function()
        local ok = shared.as:registerAchievement("first_win", "First Victory", "Win your first battle", "1_battle_won")
        Helpers.assertEqual(ok, true, "Achievement registered")
    end)

    Suite:testMethod("AchievementSystem.getAchievement", {description = "Retrieves achievement", testCase = "get", type = "functional"}, function()
        shared.as:registerAchievement("explorer", "Explorer", "Visit all locations", "all_locations_visited")
        local ach = shared.as:getAchievement("explorer")
        Helpers.assertEqual(ach ~= nil, true, "Achievement retrieved")
    end)

    Suite:testMethod("AchievementSystem.getAchievement", {description = "Returns nil missing", testCase = "missing", type = "functional"}, function()
        local ach = shared.as:getAchievement("nonexistent")
        Helpers.assertEqual(ach, nil, "Missing returns nil")
    end)

    Suite:testMethod("AchievementSystem.getTotalAchievements", {description = "Counts achievements", testCase = "count", type = "functional"}, function()
        shared.as:registerAchievement("a1", "A1", "Desc", "req1")
        shared.as:registerAchievement("a2", "A2", "Desc", "req2")
        shared.as:registerAchievement("a3", "A3", "Desc", "req3")
        local count = shared.as:getTotalAchievements()
        Helpers.assertEqual(count, 3, "Three achievements")
    end)
end)

Suite:group("Achievement Unlock", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = AchievementSystem:new()
        shared.as:registerAchievement("unlock_me", "Unlockable", "Description", "requirement")
    end)

    Suite:testMethod("AchievementSystem.unlockAchievement", {description = "Unlocks achievement", testCase = "unlock", type = "functional"}, function()
        local ok = shared.as:unlockAchievement("unlock_me")
        Helpers.assertEqual(ok, true, "Unlocked")
    end)

    Suite:testMethod("AchievementSystem.isUnlocked", {description = "Checks unlock", testCase = "check_unlock", type = "functional"}, function()
        shared.as:unlockAchievement("unlock_me")
        local unlocked = shared.as:isUnlocked("unlock_me")
        Helpers.assertEqual(unlocked, true, "Is unlocked")
    end)

    Suite:testMethod("AchievementSystem.isUnlocked", {description = "Locked by default", testCase = "default_locked", type = "functional"}, function()
        local unlocked = shared.as:isUnlocked("unlock_me")
        Helpers.assertEqual(unlocked, false, "Locked initially")
    end)

    Suite:testMethod("AchievementSystem.getUnlockedCount", {description = "Counts unlocked", testCase = "count_unlocked", type = "functional"}, function()
        shared.as:registerAchievement("a2", "A2", "D", "r")
        shared.as:registerAchievement("a3", "A3", "D", "r")
        shared.as:unlockAchievement("unlock_me")
        shared.as:unlockAchievement("a2")
        local count = shared.as:getUnlockedCount()
        Helpers.assertEqual(count, 2, "Two unlocked")
    end)
end)

Suite:group("Progress Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = AchievementSystem:new()
        shared.as:registerAchievement("killer", "Killer", "Kill 100 aliens", "kills_100")
    end)

    Suite:testMethod("AchievementSystem.checkAchievementProgress", {description = "Checks progress", testCase = "check", type = "functional"}, function()
        local ok = shared.as:checkAchievementProgress("killer", 50, 100)
        Helpers.assertEqual(ok, false, "Not yet achieved")
    end)

    Suite:testMethod("AchievementSystem.checkAchievementProgress", {description = "Complete at target", testCase = "complete", type = "functional"}, function()
        local ok = shared.as:checkAchievementProgress("killer", 100, 100)
        Helpers.assertEqual(ok, true, "Achieved")
    end)

    Suite:testMethod("AchievementSystem.checkAchievementProgress", {description = "Complete over target", testCase = "over", type = "functional"}, function()
        local ok = shared.as:checkAchievementProgress("killer", 150, 100)
        Helpers.assertEqual(ok, true, "Exceeded")
    end)

    Suite:testMethod("AchievementSystem.getProgress", {description = "Gets progress info", testCase = "progress", type = "functional"}, function()
        local progress = shared.as:getProgress("killer")
        Helpers.assertEqual(progress ~= nil, true, "Progress retrieved")
    end)
end)

Suite:group("Statistics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = AchievementSystem:new()
    end)

    Suite:testMethod("AchievementSystem.recordStat", {description = "Records stat", testCase = "record", type = "functional"}, function()
        local ok = shared.as:recordStat("kills", 5)
        Helpers.assertEqual(ok, true, "Stat recorded")
    end)

    Suite:testMethod("AchievementSystem.getStat", {description = "Gets stat", testCase = "get_stat", type = "functional"}, function()
        shared.as:recordStat("kills", 10)
        local kills = shared.as:getStat("kills")
        Helpers.assertEqual(kills, 10, "Kills 10")
    end)

    Suite:testMethod("AchievementSystem.recordStat", {description = "Accumulates", testCase = "accumulate", type = "functional"}, function()
        shared.as:recordStat("missions", 3)
        shared.as:recordStat("missions", 2)
        local missions = shared.as:getStat("missions")
        Helpers.assertEqual(missions, 5, "Missions 5")
    end)

    Suite:testMethod("AchievementSystem.getStat", {description = "Default zero", testCase = "default", type = "functional"}, function()
        local unknown = shared.as:getStat("unknown_stat")
        Helpers.assertEqual(unknown, 0, "Unknown stat 0")
    end)
end)

Suite:group("Achievement Lists", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.as = AchievementSystem:new()
        shared.as:registerAchievement("ach1", "A1", "D", "R")
        shared.as:registerAchievement("ach2", "A2", "D", "R")
        shared.as:registerAchievement("ach3", "A3", "D", "R")
        shared.as:unlockAchievement("ach1")
    end)

    Suite:testMethod("AchievementSystem.getUnlockedList", {description = "Lists unlocked", testCase = "unlocked_list", type = "functional"}, function()
        local list = shared.as:getUnlockedList()
        Helpers.assertEqual(list ~= nil, true, "List returned")
    end)

    Suite:testMethod("AchievementSystem.getUnlockedList", {description = "Correct content", testCase = "unlocked_count", type = "functional"}, function()
        local list = shared.as:getUnlockedList()
        local count = #list
        Helpers.assertEqual(count, 1, "One unlocked")
    end)

    Suite:testMethod("AchievementSystem.getLockedList", {description = "Lists locked", testCase = "locked_list", type = "functional"}, function()
        local list = shared.as:getLockedList()
        Helpers.assertEqual(list ~= nil, true, "Locked list returned")
    end)

    Suite:testMethod("AchievementSystem.getLockedList", {description = "Correct locked", testCase = "locked_count", type = "functional"}, function()
        local list = shared.as:getLockedList()
        local count = #list
        Helpers.assertEqual(count, 2, "Two locked")
    end)
end)

Suite:run()
