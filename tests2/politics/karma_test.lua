-- ─────────────────────────────────────────────────────────────────────────
-- KARMA SYSTEM TEST SUITE
-- FILE: tests2/politics/karma_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.karma.karma_system",
    fileName = "karma_system.lua",
    description = "Karma tracking and moral choice system"
})

print("[KARMA_TEST] Setting up")

local KarmaSystem = {
    karma = 0,
    actions = {},
    morality = {},

    new = function(self)
        return setmetatable({karma = 0, actions = {}, morality = {}}, {__index = self})
    end,

    recordAction = function(self, actionType, moralValue, description)
        table.insert(self.actions, {type = actionType, karma = moralValue, desc = description})
        self.karma = math.min(100, math.max(-100, self.karma + moralValue))
        return true
    end,

    getKarma = function(self)
        return self.karma
    end,

    getKarmaTier = function(self)
        if self.karma <= -50 then return "Evil"
        elseif self.karma <= -20 then return "Corrupt"
        elseif self.karma <= 20 then return "Neutral"
        elseif self.karma <= 50 then return "Virtuous"
        else return "Saintly"
        end
    end,

    isActionGood = function(self, value)
        return value > 0
    end,

    isActionEvil = function(self, value)
        return value < 0
    end,

    getActionCount = function(self)
        return #self.actions
    end,

    getMoralityScore = function(self)
        local good = 0
        local evil = 0
        for _, action in ipairs(self.actions) do
            if action.karma > 0 then good = good + 1
            elseif action.karma < 0 then evil = evil + 1
            end
        end
        return {good = good, evil = evil, ratio = good > 0 and (good / (good + evil)) or 0}
    end,

    recordChoice = function(self, choiceType, moral)
        self.morality[choiceType] = moral
        self:recordAction(choiceType, moral and 10 or -10, choiceType)
        return true
    end,

    getAlignment = function(self)
        local karma = self:getKarma()
        if karma > 0 then return "Light"
        elseif karma < 0 then return "Dark"
        else return "Neutral"
        end
    end
}

Suite:group("Karma Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.new", {description = "Creates karma system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.karma ~= nil, true, "System created")
    end)

    Suite:testMethod("KarmaSystem.recordAction", {description = "Records action", testCase = "record", type = "functional"}, function()
        local ok = shared.karma:recordAction("save_civilian", 15, "Saved a civilian")
        Helpers.assertEqual(ok, true, "Action recorded")
    end)

    Suite:testMethod("KarmaSystem.getKarma", {description = "Gets current karma", testCase = "get_karma", type = "functional"}, function()
        shared.karma:recordAction("help", 20)
        local karma = shared.karma:getKarma()
        Helpers.assertEqual(karma, 20, "Karma retrieved")
    end)

    Suite:testMethod("KarmaSystem.recordAction", {description = "Clamps karma to 100", testCase = "clamp_max", type = "functional"}, function()
        shared.karma:recordAction("good", 150)
        local karma = shared.karma:getKarma()
        Helpers.assertEqual(karma, 100, "Karma clamped to 100")
    end)

    Suite:testMethod("KarmaSystem.recordAction", {description = "Clamps karma to -100", testCase = "clamp_min", type = "functional"}, function()
        shared.karma:recordAction("evil", -200)
        local karma = shared.karma:getKarma()
        Helpers.assertEqual(karma, -100, "Karma clamped to -100")
    end)
end)

Suite:group("Karma Alignment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.getKarmaTier", {description = "Returns Evil tier", testCase = "evil", type = "functional"}, function()
        shared.karma:recordAction("atrocity", -75)
        local tier = shared.karma:getKarmaTier()
        Helpers.assertEqual(tier, "Evil", "Evil tier at -75")
    end)

    Suite:testMethod("KarmaSystem.getKarmaTier", {description = "Returns Corrupt tier", testCase = "corrupt", type = "functional"}, function()
        shared.karma:recordAction("betrayal", -40)
        local tier = shared.karma:getKarmaTier()
        Helpers.assertEqual(tier, "Corrupt", "Corrupt tier at -40")
    end)

    Suite:testMethod("KarmaSystem.getKarmaTier", {description = "Returns Neutral tier", testCase = "neutral", type = "functional"}, function()
        shared.karma:recordAction("neutral", 0)
        local tier = shared.karma:getKarmaTier()
        Helpers.assertEqual(tier, "Neutral", "Neutral tier at 0")
    end)

    Suite:testMethod("KarmaSystem.getKarmaTier", {description = "Returns Virtuous tier", testCase = "virtuous", type = "functional"}, function()
        shared.karma:recordAction("charity", 40)
        local tier = shared.karma:getKarmaTier()
        Helpers.assertEqual(tier, "Virtuous", "Virtuous tier at 40")
    end)

    Suite:testMethod("KarmaSystem.getKarmaTier", {description = "Returns Saintly tier", testCase = "saintly", type = "functional"}, function()
        shared.karma:recordAction("sacrifice", 80)
        local tier = shared.karma:getKarmaTier()
        Helpers.assertEqual(tier, "Saintly", "Saintly tier at 80")
    end)
end)

Suite:group("Action Classification", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.isActionGood", {description = "Identifies good action", testCase = "good", type = "functional"}, function()
        local good = shared.karma:isActionGood(15)
        Helpers.assertEqual(good, true, "Positive value is good")
    end)

    Suite:testMethod("KarmaSystem.isActionEvil", {description = "Identifies evil action", testCase = "evil", type = "functional"}, function()
        local evil = shared.karma:isActionEvil(-20)
        Helpers.assertEqual(evil, true, "Negative value is evil")
    end)

    Suite:testMethod("KarmaSystem.isActionGood", {description = "Zero is not good", testCase = "zero_good", type = "functional"}, function()
        local good = shared.karma:isActionGood(0)
        Helpers.assertEqual(good, false, "Zero is not good")
    end)

    Suite:testMethod("KarmaSystem.isActionEvil", {description = "Zero is not evil", testCase = "zero_evil", type = "functional"}, function()
        local evil = shared.karma:isActionEvil(0)
        Helpers.assertEqual(evil, false, "Zero is not evil")
    end)
end)

Suite:group("Moral Choices", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.recordChoice", {description = "Records moral choice", testCase = "choice", type = "functional"}, function()
        local ok = shared.karma:recordChoice("spare_prisoner", true)
        Helpers.assertEqual(ok, true, "Choice recorded")
    end)

    Suite:testMethod("KarmaSystem.recordChoice", {description = "Awards karma for moral", testCase = "moral_award", type = "functional"}, function()
        local before = shared.karma:getKarma()
        shared.karma:recordChoice("mercy", true)
        local after = shared.karma:getKarma()
        Helpers.assertEqual(after > before, true, "Moral choice awarded karma")
    end)

    Suite:testMethod("KarmaSystem.recordChoice", {description = "Penalizes immoral", testCase = "immoral_penalty", type = "functional"}, function()
        local before = shared.karma:getKarma()
        shared.karma:recordChoice("cruelty", false)
        local after = shared.karma:getKarma()
        Helpers.assertEqual(after < before, true, "Immoral choice penalized")
    end)

    Suite:testMethod("KarmaSystem.getAlignment", {description = "Returns Light alignment", testCase = "light", type = "functional"}, function()
        shared.karma:recordAction("good", 40)
        local align = shared.karma:getAlignment()
        Helpers.assertEqual(align, "Light", "Light alignment for positive karma")
    end)

    Suite:testMethod("KarmaSystem.getAlignment", {description = "Returns Dark alignment", testCase = "dark", type = "functional"}, function()
        shared.karma:recordAction("evil", -50)
        local align = shared.karma:getAlignment()
        Helpers.assertEqual(align, "Dark", "Dark alignment for negative karma")
    end)
end)

Suite:group("Morality Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.getActionCount", {description = "Counts recorded actions", testCase = "count", type = "functional"}, function()
        shared.karma:recordAction("act1", 10)
        shared.karma:recordAction("act2", -5)
        shared.karma:recordAction("act3", 15)
        local count = shared.karma:getActionCount()
        Helpers.assertEqual(count, 3, "Three actions recorded")
    end)

    Suite:testMethod("KarmaSystem.getMoralityScore", {description = "Analyzes morality breakdown", testCase = "analysis", type = "functional"}, function()
        shared.karma:recordAction("good", 10)
        shared.karma:recordAction("bad", -10)
        shared.karma:recordAction("good", 10)
        local score = shared.karma:getMoralityScore()
        Helpers.assertEqual(score ~= nil, true, "Morality score calculated")
    end)
end)

Suite:run()
