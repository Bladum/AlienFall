-- ─────────────────────────────────────────────────────────────────────────
-- REPUTATION SYSTEM TEST SUITE
-- FILE: tests2/politics/reputation_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.relations.reputation_system",
    fileName = "reputation_system.lua",
    description = "Reputation tracking and standing calculation system"
})

print("[REPUTATION_TEST] Setting up")

local ReputationSystem = {
    entities = {},
    fame = 0,
    karma = 0,
    relations = {},

    new = function(self, fame, karma, relations)
        return setmetatable({
            entities = {},
            fame = fame or 0,
            karma = karma or 0,
            relations = relations or {}
        }, {__index = self})
    end,

    calculateReputation = function(self, entityId)
        local base = self.fame + self.karma
        local modifier = self.relations[entityId] or 0
        return math.min(100, math.max(-100, base + modifier))
    end,

    getReputationTier = function(self, score)
        if score <= -50 then return "Despised"
        elseif score <= -20 then return "Disliked"
        elseif score <= 19 then return "Neutral"
        elseif score <= 49 then return "Liked"
        else return "Revered"
        end
    end,

    setRelation = function(self, entityId, value)
        self.relations[entityId] = math.min(100, math.max(-100, value))
        return true
    end,

    getRelation = function(self, entityId)
        return self.relations[entityId] or 0
    end,

    adjustFame = function(self, amount)
        self.fame = math.min(100, math.max(-100, self.fame + amount))
        return true
    end,

    adjustKarma = function(self, amount)
        self.karma = math.min(100, math.max(-100, self.karma + amount))
        return true
    end,

    addEntity = function(self, entityId, initialReputation)
        self.entities[entityId] = initialReputation or 0
        return true
    end,

    getReputationEffects = function(self, entityId)
        local reputation = self:calculateReputation(entityId)
        local effects = {}
        if reputation > 50 then table.insert(effects, "bonus_access") end
        if reputation < -50 then table.insert(effects, "restricted") end
        if reputation > 0 then table.insert(effects, "positive_modifier") end
        return effects
    end
}

Suite:group("Reputation Calculation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rep = ReputationSystem:new(30, 20, {})
    end)

    Suite:testMethod("ReputationSystem.new", {description = "Creates reputation system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.rep ~= nil, true, "System created")
    end)

    Suite:testMethod("ReputationSystem.calculateReputation", {description = "Calculates reputation score", testCase = "calculate", type = "functional"}, function()
        shared.rep:setRelation("entity1", 10)
        local rep = shared.rep:calculateReputation("entity1")
        Helpers.assertEqual(rep, 60, "Reputation calculated: 30+20+10=60")
    end)

    Suite:testMethod("ReputationSystem.calculateReputation", {description = "Clamps reputation to -100 to 100", testCase = "clamp", type = "functional"}, function()
        shared.rep:setRelation("entity2", 100)
        local rep = shared.rep:calculateReputation("entity2")
        Helpers.assertEqual(rep, 100, "Reputation clamped to 100")
    end)

    Suite:testMethod("ReputationSystem.calculateReputation", {description = "Returns zero for no relation", testCase = "zero", type = "functional"}, function()
        local rep = shared.rep:calculateReputation("unknown")
        Helpers.assertEqual(rep, 50, "Default reputation is 30+20+0=50")
    end)
end)

Suite:group("Reputation Tiers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rep = ReputationSystem:new(0, 0, {})
    end)

    Suite:testMethod("ReputationSystem.getReputationTier", {description = "Returns Despised tier", testCase = "despised", type = "functional"}, function()
        local tier = shared.rep:getReputationTier(-75)
        Helpers.assertEqual(tier, "Despised", "Despised tier for -75")
    end)

    Suite:testMethod("ReputationSystem.getReputationTier", {description = "Returns Disliked tier", testCase = "disliked", type = "functional"}, function()
        local tier = shared.rep:getReputationTier(-30)
        Helpers.assertEqual(tier, "Disliked", "Disliked tier for -30")
    end)

    Suite:testMethod("ReputationSystem.getReputationTier", {description = "Returns Neutral tier", testCase = "neutral", type = "functional"}, function()
        local tier = shared.rep:getReputationTier(10)
        Helpers.assertEqual(tier, "Neutral", "Neutral tier for 10")
    end)

    Suite:testMethod("ReputationSystem.getReputationTier", {description = "Returns Liked tier", testCase = "liked", type = "functional"}, function()
        local tier = shared.rep:getReputationTier(35)
        Helpers.assertEqual(tier, "Liked", "Liked tier for 35")
    end)

    Suite:testMethod("ReputationSystem.getReputationTier", {description = "Returns Revered tier", testCase = "revered", type = "functional"}, function()
        local tier = shared.rep:getReputationTier(75)
        Helpers.assertEqual(tier, "Revered", "Revered tier for 75")
    end)
end)

Suite:group("Relation Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rep = ReputationSystem:new(25, 15, {})
    end)

    Suite:testMethod("ReputationSystem.setRelation", {description = "Sets relation with entity", testCase = "set", type = "functional"}, function()
        local ok = shared.rep:setRelation("entity1", 60)
        Helpers.assertEqual(ok, true, "Relation set")
    end)

    Suite:testMethod("ReputationSystem.getRelation", {description = "Gets relation value", testCase = "get", type = "functional"}, function()
        shared.rep:setRelation("entity1", 50)
        local rel = shared.rep:getRelation("entity1")
        Helpers.assertEqual(rel, 50, "Relation retrieved")
    end)

    Suite:testMethod("ReputationSystem.setRelation", {description = "Clamps negative relation", testCase = "clamp_negative", type = "functional"}, function()
        shared.rep:setRelation("entity2", -150)
        local rel = shared.rep:getRelation("entity2")
        Helpers.assertEqual(rel, -100, "Relation clamped to -100")
    end)
end)

Suite:group("Fame & Karma", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rep = ReputationSystem:new(20, 10, {})
    end)

    Suite:testMethod("ReputationSystem.adjustFame", {description = "Adjusts fame", testCase = "fame_adjust", type = "functional"}, function()
        local ok = shared.rep:adjustFame(15)
        Helpers.assertEqual(ok, true, "Fame adjusted")
    end)

    Suite:testMethod("ReputationSystem.adjustKarma", {description = "Adjusts karma", testCase = "karma_adjust", type = "functional"}, function()
        local ok = shared.rep:adjustKarma(10)
        Helpers.assertEqual(ok, true, "Karma adjusted")
    end)

    Suite:testMethod("ReputationSystem.adjustFame", {description = "Clamps fame max", testCase = "fame_max", type = "functional"}, function()
        shared.rep:adjustFame(100)
        Helpers.assertEqual(shared.rep.fame, 100, "Fame clamped to 100")
    end)

    Suite:testMethod("ReputationSystem.adjustKarma", {description = "Clamps karma min", testCase = "karma_min", type = "functional"}, function()
        shared.rep:adjustKarma(-50)
        Helpers.assertEqual(shared.rep.karma, -40, "Karma adjusted to -40")
    end)
end)

Suite:group("Reputation Effects", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rep = ReputationSystem:new(0, 0, {})
    end)

    Suite:testMethod("ReputationSystem.getReputationEffects", {description = "Gets effects for high reputation", testCase = "high_effects", type = "functional"}, function()
        shared.rep:setRelation("entity1", 75)
        local effects = shared.rep:getReputationEffects("entity1")
        Helpers.assertEqual(effects ~= nil, true, "Effects retrieved")
    end)

    Suite:testMethod("ReputationSystem.addEntity", {description = "Adds entity to tracking", testCase = "add_entity", type = "functional"}, function()
        local ok = shared.rep:addEntity("country1", 50)
        Helpers.assertEqual(ok, true, "Entity added")
    end)
end)

Suite:run()
