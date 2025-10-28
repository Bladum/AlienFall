-- ─────────────────────────────────────────────────────────────────────────
-- DIFFICULTY MANAGER TEST SUITE
-- FILE: tests2/core/difficulty_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.difficulty_manager",
    fileName = "difficulty_manager.lua",
    description = "Game difficulty management system"
})

print("[DIFFICULTY_TEST] Setting up")

local DifficultyManager = {
    currentDifficulty = "normal",
    difficulties = {
        easy = {enemyDamage = 0.75, allyAccuracy = 1.1, rewards = 0.7},
        normal = {enemyDamage = 1.0, allyAccuracy = 1.0, rewards = 1.0},
        classic = {enemyDamage = 1.2, allyAccuracy = 0.9, rewards = 1.2},
        ironman = {enemyDamage = 1.5, allyAccuracy = 0.8, rewards = 1.5}
    },

    setDifficulty = function(self, diff)
        if not self.difficulties[diff] then return false end
        self.currentDifficulty = diff
        return true
    end,

    getDifficulty = function(self) return self.currentDifficulty end,

    getModifier = function(self, key)
        local diff = self.difficulties[self.currentDifficulty]
        return diff[key] or 1.0
    end,

    getAvailableDifficulties = function(self)
        local result = {}
        for name, _ in pairs(self.difficulties) do
            table.insert(result, name)
        end
        return result
    end,

    isDifficultyValid = function(self, diff)
        return self.difficulties[diff] ~= nil
    end
}

Suite:group("Difficulty Selection", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.dm = setmetatable({currentDifficulty = "normal", difficulties = {easy = {}, normal = {}, classic = {}, ironman = {}}}, {__index = DifficultyManager})
    end)

    Suite:testMethod("DifficultyManager.setDifficulty", {description = "Sets difficulty", testCase = "set", type = "functional"}, function()
        local ok = shared.dm:setDifficulty("hard")
        Helpers.assertEqual(ok, false, "Invalid difficulty rejected")
        ok = shared.dm:setDifficulty("classic")
        Helpers.assertEqual(ok, true, "Valid difficulty set")
    end)

    Suite:testMethod("DifficultyManager.getDifficulty", {description = "Gets current difficulty", testCase = "get", type = "functional"}, function()
        shared.dm:setDifficulty("ironman")
        local diff = shared.dm:getDifficulty()
        Helpers.assertEqual(diff, "ironman", "Difficulty retrieved")
    end)

    Suite:testMethod("DifficultyManager.isDifficultyValid", {description = "Validates difficulty", testCase = "validate", type = "functional"}, function()
        local valid = shared.dm:isDifficultyValid("normal")
        Helpers.assertEqual(valid, true, "Normal is valid")
        valid = shared.dm:isDifficultyValid("nightmare")
        Helpers.assertEqual(valid, false, "Nightmare is invalid")
    end)
end)

Suite:group("Modifiers", function()
    local shared = {}
    Suite:beforeEach(function()
        local diffs = {
            easy = {enemyDamage = 0.75, allyAccuracy = 1.1, rewards = 0.7},
            normal = {enemyDamage = 1.0, allyAccuracy = 1.0, rewards = 1.0},
            classic = {enemyDamage = 1.2, allyAccuracy = 0.9, rewards = 1.2},
            ironman = {enemyDamage = 1.5, allyAccuracy = 0.8, rewards = 1.5}
        }
        shared.dm = setmetatable({currentDifficulty = "normal", difficulties = diffs}, {__index = DifficultyManager})
    end)

    Suite:testMethod("DifficultyManager.getModifier", {description = "Gets difficulty modifier", testCase = "get_modifier", type = "functional"}, function()
        local mod = shared.dm:getModifier("enemyDamage")
        Helpers.assertEqual(mod, 1.0, "Normal damage modifier is 1.0")
    end)

    Suite:testMethod("DifficultyManager.getModifier", {description = "Easy difficulty reduces damage", testCase = "easy_modifier", type = "functional"}, function()
        shared.dm:setDifficulty("easy")
        local mod = shared.dm:getModifier("enemyDamage")
        Helpers.assertEqual(mod, 0.75, "Easy damage reduced")
    end)

    Suite:testMethod("DifficultyManager.getModifier", {description = "Ironman increases difficulty", testCase = "ironman_modifier", type = "functional"}, function()
        shared.dm:setDifficulty("ironman")
        local mod = shared.dm:getModifier("enemyDamage")
        Helpers.assertEqual(mod, 1.5, "Ironman damage increased")
    end)
end)

Suite:group("Difficulty List", function()
    local shared = {}
    Suite:beforeEach(function()
        local diffs = {easy = {}, normal = {}, classic = {}, ironman = {}}
        shared.dm = setmetatable({currentDifficulty = "normal", difficulties = diffs}, {__index = DifficultyManager})
    end)

    Suite:testMethod("DifficultyManager.getAvailableDifficulties", {description = "Lists all difficulties", testCase = "list", type = "functional"}, function()
        local diffs = shared.dm:getAvailableDifficulties()
        Helpers.assertEqual(#diffs >= 1, true, "Difficulties listed")
    end)
end)

Suite:run()
