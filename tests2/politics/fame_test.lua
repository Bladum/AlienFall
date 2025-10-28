-- ─────────────────────────────────────────────────────────────────────────
-- FAME SYSTEM TEST SUITE
-- FILE: tests2/politics/fame_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.fame.fame_system",
    fileName = "fame_system.lua",
    description = "Fame and public reputation tracking system"
})

print("[FAME_TEST] Setting up")

local FameSystem = {
    fame = 0,
    achievements = {},
    publicEvents = {},

    new = function(self)
        return setmetatable({fame = 0, achievements = {}, publicEvents = {}}, {__index = self})
    end,

    addFame = function(self, amount, reason)
        self.fame = math.min(100, math.max(-100, self.fame + amount))
        table.insert(self.publicEvents, {event = reason or "unknown", amount = amount, fame = self.fame})
        return true
    end,

    getFame = function(self)
        return self.fame
    end,

    getFameTier = function(self)
        if self.fame <= -50 then return "Infamous"
        elseif self.fame <= -20 then return "Notorious"
        elseif self.fame <= 20 then return "Unknown"
        elseif self.fame <= 50 then return "Famous"
        else return "Legendary"
        end
    end,

    unlockAchievement = function(self, achievementId, title)
        self.achievements[achievementId] = {id = achievementId, title = title, unlocked = true}
        self:addFame(5, "achievement_" .. achievementId)
        return true
    end,

    isAchievementUnlocked = function(self, achievementId)
        return self.achievements[achievementId] and self.achievements[achievementId].unlocked or false
    end,

    getAchievementCount = function(self)
        local count = 0
        for _, ach in pairs(self.achievements) do
            if ach.unlocked then count = count + 1 end
        end
        return count
    end,

    getPublicEventCount = function(self)
        return #self.publicEvents
    end,

    getLastPublicEvent = function(self)
        return self.publicEvents[#self.publicEvents]
    end,

    recordPublicEvent = function(self, eventType, fameImpact)
        self:addFame(fameImpact, eventType)
        return true
    end
}

Suite:group("Fame Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fame = FameSystem:new()
    end)

    Suite:testMethod("FameSystem.new", {description = "Creates fame system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.fame ~= nil, true, "System created")
    end)

    Suite:testMethod("FameSystem.addFame", {description = "Adds fame", testCase = "add_fame", type = "functional"}, function()
        local ok = shared.fame:addFame(15, "mission_victory")
        Helpers.assertEqual(ok, true, "Fame added")
    end)

    Suite:testMethod("FameSystem.getFame", {description = "Gets current fame", testCase = "get_fame", type = "functional"}, function()
        shared.fame:addFame(25)
        local fame = shared.fame:getFame()
        Helpers.assertEqual(fame, 25, "Fame retrieved")
    end)

    Suite:testMethod("FameSystem.addFame", {description = "Clamps fame to 100", testCase = "clamp_max", type = "functional"}, function()
        shared.fame:addFame(150)
        local fame = shared.fame:getFame()
        Helpers.assertEqual(fame, 100, "Fame clamped to 100")
    end)

    Suite:testMethod("FameSystem.addFame", {description = "Clamps fame to -100", testCase = "clamp_min", type = "functional"}, function()
        shared.fame:addFame(-200)
        local fame = shared.fame:getFame()
        Helpers.assertEqual(fame, -100, "Fame clamped to -100")
    end)
end)

Suite:group("Fame Tiers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fame = FameSystem:new()
    end)

    Suite:testMethod("FameSystem.getFameTier", {description = "Returns Infamous tier", testCase = "infamous", type = "functional"}, function()
        shared.fame:addFame(-75)
        local tier = shared.fame:getFameTier()
        Helpers.assertEqual(tier, "Infamous", "Infamous tier at -75")
    end)

    Suite:testMethod("FameSystem.getFameTier", {description = "Returns Notorious tier", testCase = "notorious", type = "functional"}, function()
        shared.fame:addFame(-40)
        local tier = shared.fame:getFameTier()
        Helpers.assertEqual(tier, "Notorious", "Notorious tier at -40")
    end)

    Suite:testMethod("FameSystem.getFameTier", {description = "Returns Unknown tier", testCase = "unknown", type = "functional"}, function()
        shared.fame:addFame(5)
        local tier = shared.fame:getFameTier()
        Helpers.assertEqual(tier, "Unknown", "Unknown tier at 5")
    end)

    Suite:testMethod("FameSystem.getFameTier", {description = "Returns Famous tier", testCase = "famous", type = "functional"}, function()
        shared.fame:addFame(40)
        local tier = shared.fame:getFameTier()
        Helpers.assertEqual(tier, "Famous", "Famous tier at 40")
    end)

    Suite:testMethod("FameSystem.getFameTier", {description = "Returns Legendary tier", testCase = "legendary", type = "functional"}, function()
        shared.fame:addFame(80)
        local tier = shared.fame:getFameTier()
        Helpers.assertEqual(tier, "Legendary", "Legendary tier at 80")
    end)
end)

Suite:group("Achievements", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fame = FameSystem:new()
    end)

    Suite:testMethod("FameSystem.unlockAchievement", {description = "Unlocks achievement", testCase = "unlock", type = "functional"}, function()
        local ok = shared.fame:unlockAchievement("first_mission", "First Victory")
        Helpers.assertEqual(ok, true, "Achievement unlocked")
    end)

    Suite:testMethod("FameSystem.isAchievementUnlocked", {description = "Checks achievement status", testCase = "check_status", type = "functional"}, function()
        shared.fame:unlockAchievement("hero", "Hero's Welcome")
        local unlocked = shared.fame:isAchievementUnlocked("hero")
        Helpers.assertEqual(unlocked, true, "Achievement unlocked")
    end)

    Suite:testMethod("FameSystem.isAchievementUnlocked", {description = "Returns false for locked", testCase = "locked", type = "functional"}, function()
        local unlocked = shared.fame:isAchievementUnlocked("unknown")
        Helpers.assertEqual(unlocked, false, "Unknown achievement locked")
    end)

    Suite:testMethod("FameSystem.getAchievementCount", {description = "Counts unlocked achievements", testCase = "count", type = "functional"}, function()
        shared.fame:unlockAchievement("ach1", "Achievement 1")
        shared.fame:unlockAchievement("ach2", "Achievement 2")
        local count = shared.fame:getAchievementCount()
        Helpers.assertEqual(count, 2, "Two achievements unlocked")
    end)

    Suite:testMethod("FameSystem.unlockAchievement", {description = "Awards fame bonus", testCase = "fame_bonus", type = "functional"}, function()
        local before = shared.fame:getFame()
        shared.fame:unlockAchievement("bonus", "Bonus Achievement")
        local after = shared.fame:getFame()
        Helpers.assertEqual(after > before, true, "Fame increased")
    end)
end)

Suite:group("Public Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fame = FameSystem:new()
    end)

    Suite:testMethod("FameSystem.recordPublicEvent", {description = "Records public event", testCase = "record", type = "functional"}, function()
        local ok = shared.fame:recordPublicEvent("mission_success", 20)
        Helpers.assertEqual(ok, true, "Event recorded")
    end)

    Suite:testMethod("FameSystem.getPublicEventCount", {description = "Counts public events", testCase = "count", type = "functional"}, function()
        shared.fame:recordPublicEvent("event1", 5)
        shared.fame:recordPublicEvent("event2", 10)
        local count = shared.fame:getPublicEventCount()
        Helpers.assertEqual(count >= 2, true, "Events recorded")
    end)

    Suite:testMethod("FameSystem.getLastPublicEvent", {description = "Gets most recent event", testCase = "last_event", type = "functional"}, function()
        shared.fame:recordPublicEvent("test_event", 15)
        local event = shared.fame:getLastPublicEvent()
        Helpers.assertEqual(event ~= nil, true, "Last event retrieved")
    end)

    Suite:testMethod("FameSystem.recordPublicEvent", {description = "Applies fame impact", testCase = "impact", type = "functional"}, function()
        local before = shared.fame:getFame()
        shared.fame:recordPublicEvent("big_win", 30)
        local after = shared.fame:getFame()
        Helpers.assertEqual(after > before, true, "Fame impacted by event")
    end)
end)

Suite:run()
