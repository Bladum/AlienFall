-- ─────────────────────────────────────────────────────────────────────────
-- FACTION AI TEST SUITE
-- FILE: tests2/ai/faction_ai_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.ai.faction_ai",
    fileName = "faction_ai.lua",
    description = "AI decision-making for faction strategy, diplomacy, and threat response"
})

print("[FACTION_AI_TEST] Setting up")

local FactionAI = {
    factions = {},
    strategies = {},
    threats = {},
    decisions = {},

    new = function(self)
        return setmetatable({factions = {}, strategies = {}, threats = {}, decisions = {}}, {__index = self})
    end,

    registerFaction = function(self, factionId, aggressiveness, resources)
        self.factions[factionId] = {id = factionId, aggression = aggressiveness or 5, resources = resources or 100, active = true}
        self.strategies[factionId] = {}
        self.threats[factionId] = {}
        self.decisions[factionId] = {}
        return true
    end,

    getFaction = function(self, factionId)
        return self.factions[factionId]
    end,

    setStrategy = function(self, factionId, strategyType, parameters)
        if not self.factions[factionId] then return false end
        self.strategies[factionId].current = strategyType
        self.strategies[factionId].params = parameters or {}
        return true
    end,

    getStrategy = function(self, factionId)
        if not self.strategies[factionId] then return nil end
        return self.strategies[factionId].current
    end,

    assessThreat = function(self, factionId, enemyId, threatLevel)
        if not self.factions[factionId] then return false end
        self.threats[factionId][enemyId] = {enemy = enemyId, level = threatLevel or 50, detected = true, timestamp = love.timer.getTime()}
        return true
    end,

    getThreatLevel = function(self, factionId, enemyId)
        if not self.threats[factionId] or not self.threats[factionId][enemyId] then return 0 end
        return self.threats[factionId][enemyId].level
    end,

    getMaxThreat = function(self, factionId)
        if not self.threats[factionId] or not next(self.threats[factionId]) then return 0 end
        local max = 0
        for _, threat in pairs(self.threats[factionId]) do
            if threat.level > max then max = threat.level end
        end
        return max
    end,

    recordDecision = function(self, factionId, decisionType, details)
        if not self.factions[factionId] then return false end
        table.insert(self.decisions[factionId], {type = decisionType, details = details, timestamp = love.timer.getTime()})
        return true
    end,

    getDecisionCount = function(self, factionId)
        if not self.decisions[factionId] then return 0 end
        return #self.decisions[factionId]
    end,

    calculateAggression = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        local baseAgg = self.factions[factionId].aggression
        local maxThreat = self:getMaxThreat(factionId)
        local resourceMultiplier = self.factions[factionId].resources / 100
        return math.floor(baseAgg + (maxThreat * 0.1) + (resourceMultiplier * 2))
    end,

    shouldAttack = function(self, factionId, targetId)
        if not self.factions[factionId] then return false end
        local aggression = self:calculateAggression(factionId)
        local targetThreat = self:getThreatLevel(factionId, targetId)
        return aggression > 50 and targetThreat < 80
    end,

    shouldRetreat = function(self, factionId)
        if not self.factions[factionId] then return false end
        local maxThreat = self:getMaxThreat(factionId)
        local resources = self.factions[factionId].resources
        return maxThreat > 70 or resources < 30
    end,

    shouldAlly = function(self, factionId, otherId)
        if not self.factions[factionId] or not self.factions[otherId] then return false end
        local threat = self:getMaxThreat(factionId)
        local resources = self.factions[factionId].resources
        return threat > 60 and resources >= 50
    end,

    getActiveFactions = function(self)
        local count = 0
        for _, faction in pairs(self.factions) do
            if faction.active then count = count + 1 end
        end
        return count
    end,

    setResourceLevel = function(self, factionId, amount)
        if not self.factions[factionId] then return false end
        self.factions[factionId].resources = amount
        return true
    end,

    getResourceLevel = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        return self.factions[factionId].resources
    end,

    getThreatCount = function(self, factionId)
        if not self.threats[factionId] then return 0 end
        local count = 0
        for _ in pairs(self.threats[factionId]) do count = count + 1 end
        return count
    end
}

Suite:group("Faction Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = FactionAI:new()
    end)

    Suite:testMethod("FactionAI.registerFaction", {description = "Registers faction", testCase = "register", type = "functional"}, function()
        local ok = shared.ai:registerFaction("faction1", 5, 100)
        Helpers.assertEqual(ok, true, "Faction registered")
    end)

    Suite:testMethod("FactionAI.getFaction", {description = "Retrieves faction", testCase = "get", type = "functional"}, function()
        shared.ai:registerFaction("faction2", 7, 150)
        local faction = shared.ai:getFaction("faction2")
        Helpers.assertEqual(faction ~= nil, true, "Faction retrieved")
    end)

    Suite:testMethod("FactionAI.getActiveFactions", {description = "Counts active", testCase = "active_count", type = "functional"}, function()
        shared.ai:registerFaction("f1", 5, 100)
        shared.ai:registerFaction("f2", 6, 120)
        shared.ai:registerFaction("f3", 8, 180)
        local count = shared.ai:getActiveFactions()
        Helpers.assertEqual(count, 3, "Three active")
    end)
end)

Suite:group("Resource Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = FactionAI:new()
        shared.ai:registerFaction("resource_test", 5, 100)
    end)

    Suite:testMethod("FactionAI.getResourceLevel", {description = "Gets resources", testCase = "get_resources", type = "functional"}, function()
        local resources = shared.ai:getResourceLevel("resource_test")
        Helpers.assertEqual(resources, 100, "100 resources")
    end)

    Suite:testMethod("FactionAI.setResourceLevel", {description = "Sets resources", testCase = "set_resources", type = "functional"}, function()
        local ok = shared.ai:setResourceLevel("resource_test", 250)
        Helpers.assertEqual(ok, true, "Resources set")
    end)
end)

Suite:group("Strategy System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = FactionAI:new()
        shared.ai:registerFaction("strat1", 6, 120)
    end)

    Suite:testMethod("FactionAI.setStrategy", {description = "Sets strategy", testCase = "set_strategy", type = "functional"}, function()
        local ok = shared.ai:setStrategy("strat1", "defensive", {holdLine = true})
        Helpers.assertEqual(ok, true, "Strategy set")
    end)

    Suite:testMethod("FactionAI.getStrategy", {description = "Gets strategy", testCase = "get_strategy", type = "functional"}, function()
        shared.ai:setStrategy("strat1", "aggressive", {expandTerritory = true})
        local strat = shared.ai:getStrategy("strat1")
        Helpers.assertEqual(strat, "aggressive", "Aggressive strategy")
    end)
end)

Suite:group("Threat Assessment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = FactionAI:new()
        shared.ai:registerFaction("threat1", 5, 100)
    end)

    Suite:testMethod("FactionAI.assessThreat", {description = "Assesses threat", testCase = "assess", type = "functional"}, function()
        local ok = shared.ai:assessThreat("threat1", "enemy1", 60)
        Helpers.assertEqual(ok, true, "Threat assessed")
    end)

    Suite:testMethod("FactionAI.getThreatLevel", {description = "Gets threat level", testCase = "threat_level", type = "functional"}, function()
        shared.ai:assessThreat("threat1", "enemy2", 75)
        local level = shared.ai:getThreatLevel("threat1", "enemy2")
        Helpers.assertEqual(level, 75, "Threat 75")
    end)

    Suite:testMethod("FactionAI.getMaxThreat", {description = "Gets max threat", testCase = "max_threat", type = "functional"}, function()
        shared.ai:assessThreat("threat1", "e1", 30)
        shared.ai:assessThreat("threat1", "e2", 70)
        shared.ai:assessThreat("threat1", "e3", 50)
        local max = shared.ai:getMaxThreat("threat1")
        Helpers.assertEqual(max, 70, "Max threat 70")
    end)

    Suite:testMethod("FactionAI.getThreatCount", {description = "Counts threats", testCase = "threat_count", type = "functional"}, function()
        shared.ai:assessThreat("threat1", "a", 40)
        shared.ai:assessThreat("threat1", "b", 50)
        local count = shared.ai:getThreatCount("threat1")
        Helpers.assertEqual(count, 2, "Two threats")
    end)
end)

Suite:group("Decision Recording", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = FactionAI:new()
        shared.ai:registerFaction("decisions", 5, 100)
    end)

    Suite:testMethod("FactionAI.recordDecision", {description = "Records decision", testCase = "record", type = "functional"}, function()
        local ok = shared.ai:recordDecision("decisions", "attack", {target = "enemy1"})
        Helpers.assertEqual(ok, true, "Decision recorded")
    end)

    Suite:testMethod("FactionAI.getDecisionCount", {description = "Counts decisions", testCase = "count", type = "functional"}, function()
        shared.ai:recordDecision("decisions", "defend", {position = "base"})
        shared.ai:recordDecision("decisions", "scout", {area = "north"})
        shared.ai:recordDecision("decisions", "negotiate", {party = "other_faction"})
        local count = shared.ai:getDecisionCount("decisions")
        Helpers.assertEqual(count, 3, "Three decisions")
    end)
end)

Suite:group("Tactical Decisions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = FactionAI:new()
        shared.ai:registerFaction("tactical", 6, 100)
    end)

    Suite:testMethod("FactionAI.calculateAggression", {description = "Calculates aggression", testCase = "calc_agg", type = "functional"}, function()
        shared.ai:assessThreat("tactical", "enemy", 30)
        local agg = shared.ai:calculateAggression("tactical")
        Helpers.assertEqual(agg >= 6, true, "Aggression calculated")
    end)

    Suite:testMethod("FactionAI.shouldAttack", {description = "Determines attack", testCase = "attack_decision", type = "functional"}, function()
        shared.ai:setResourceLevel("tactical", 200)
        shared.ai:assessThreat("tactical", "weak_enemy", 20)
        local should = shared.ai:shouldAttack("tactical", "weak_enemy")
        Helpers.assertEqual(should, true, "Should attack")
    end)

    Suite:testMethod("FactionAI.shouldRetreat", {description = "Determines retreat", testCase = "retreat_decision", type = "functional"}, function()
        shared.ai:setResourceLevel("tactical", 20)
        local should = shared.ai:shouldRetreat("tactical")
        Helpers.assertEqual(should, true, "Should retreat")
    end)

    Suite:testMethod("FactionAI.shouldAlly", {description = "Determines alliance", testCase = "ally_decision", type = "functional"}, function()
        shared.ai:registerFaction("other", 5, 100)
        shared.ai:assessThreat("tactical", "big_threat", 80)
        local should = shared.ai:shouldAlly("tactical", "other")
        Helpers.assertEqual(should, true, "Should ally")
    end)
end)

Suite:run()
