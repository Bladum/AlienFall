-- TEST: Progression Manager
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local ProgressionManager = {}
ProgressionManager.__index = ProgressionManager

function ProgressionManager:new()
    local self = setmetatable({}, ProgressionManager)
    self.level = 1
    self.experience = 0
    self.achievements = {}
    self.unlocks = {}
    return self
end

function ProgressionManager:addExperience(amount)
    if not amount or amount < 0 then error("[Progression] Invalid XP") end
    self.experience = self.experience + amount

    local nextThreshold = self.level * 100
    if self.experience >= nextThreshold then
        self.level = self.level + 1
        self.experience = 0
    end

    return self.experience
end

function ProgressionManager:unlockAchievement(id)
    if not id or self.achievements[id] then error("[Progression] Invalid achievement") end
    self.achievements[id] = true
    return true
end

function ProgressionManager:unlockFeature(featureId)
    if not featureId then error("[Progression] Invalid feature") end
    self.unlocks[featureId] = true
    return true
end

function ProgressionManager:isAchievementUnlocked(id)
    return self.achievements[id] or false
end

function ProgressionManager:getLevel()
    return self.level
end

function ProgressionManager:getProgress()
    return {
        level = self.level,
        experience = self.experience,
        achievements = self.achievements,
        unlocks = self.unlocks
    }
end

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.managers.progression_manager",
    fileName = "progression_manager.lua",
    description = "Progression tracking system"
})

Suite:before(function() print("[ProgressionManager] Setting up") end)

Suite:group("Progression Leveling", function()
    local shared = {}
    Suite:beforeEach(function() shared.prog = ProgressionManager:new() end)

    Suite:testMethod("ProgressionManager.addExperience", {description="Adds XP", testCase="happy_path", type="functional"},
    function()
        local xp = shared.prog:addExperience(50)
        Helpers.assertEqual(xp, 50, "Should have 50 XP")
        print("  ✓ XP added")
    end)

    Suite:testMethod("ProgressionManager.getLevel", {description="Gets current level", testCase="level", type="functional"},
    function()
        local level = shared.prog:getLevel()
        Helpers.assertEqual(level, 1, "Should be level 1")
        print("  ✓ Level retrieved")
    end)
end)

Suite:group("Progression Achievements", function()
    local shared = {}
    Suite:beforeEach(function() shared.prog = ProgressionManager:new() end)

    Suite:testMethod("ProgressionManager.unlockAchievement", {description="Unlocks achievement", testCase="achievement", type="functional"},
    function()
        shared.prog:unlockAchievement("first_mission")
        Helpers.assertEqual(shared.prog:isAchievementUnlocked("first_mission"), true, "Should be unlocked")
        print("  ✓ Achievement unlocked")
    end)

    Suite:testMethod("ProgressionManager.isAchievementUnlocked", {description="Checks unlock status", testCase="check", type="functional"},
    function()
        Helpers.assertEqual(shared.prog:isAchievementUnlocked("locked"), false, "Should be locked")
        print("  ✓ Status checked")
    end)
end)

Suite:group("Progression Features", function()
    local shared = {}
    Suite:beforeEach(function() shared.prog = ProgressionManager:new() end)

    Suite:testMethod("ProgressionManager.unlockFeature", {description="Unlocks feature", testCase="feature", type="functional"},
    function()
        shared.prog:unlockFeature("advanced_tactics")
        Helpers.assertEqual(shared.prog.unlocks["advanced_tactics"], true, "Should be unlocked")
        print("  ✓ Feature unlocked")
    end)

    Suite:testMethod("ProgressionManager.getProgress", {description="Gets full progress", testCase="progress", type="functional"},
    function()
        shared.prog:unlockAchievement("victory")
        shared.prog:unlockFeature("research")
        local prog = shared.prog:getProgress()
        Helpers.assertEqual(prog.level, 1, "Should report level")
        Helpers.assertEqual(prog.achievements["victory"], true, "Should report achievements")
        print("  ✓ Progress retrieved")
    end)
end)

return Suite
