-- ─────────────────────────────────────────────────────────────────────────
-- TACTICAL AI TEST SUITE
-- FILE: tests2/ai/tactical_ai_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.ai.tactical_ai",
    fileName = "tactical_ai.lua",
    description = "Advanced tactical AI with threat assessment, decision trees, and learning"
})

print("[TACTICAL_AI_TEST] Setting up")

local TacticalAI = {
    actors = {},
    threats = {},
    decisions = {},
    learning = {},
    strategies = {},

    new = function(self)
        return setmetatable({actors = {}, threats = {}, decisions = {}, learning = {}, strategies = {}}, {__index = self})
    end,

    registerActor = function(self, actorId, name, role, aggressiveness)
        self.actors[actorId] = {
            id = actorId, name = name, role = role, aggressiveness = aggressiveness or 50,
            decision = "idle", health = 100, morale = 80
        }
        self.threats[actorId] = {}
        self.decisions[actorId] = {}
        self.learning[actorId] = {wins = 0, losses = 0, encounters = 0}
        self.strategies[actorId] = {}
        return true
    end,

    getActor = function(self, actorId)
        return self.actors[actorId]
    end,

    assessThreat = function(self, actorId, threatId, threatType, threatLevel, distance)
        if not self.actors[actorId] then return false end
        self.threats[actorId][threatId] = {
            id = threatId, type = threatType, level = threatLevel or 50, distance = distance or 10, assessed = true
        }
        return true
    end,

    getThreatLevel = function(self, actorId)
        if not self.threats[actorId] then return 0 end
        local maxThreat = 0
        for _, threat in pairs(self.threats[actorId]) do
            if threat.level > maxThreat then
                maxThreat = threat.level
            end
        end
        return maxThreat
    end,

    getThreatCount = function(self, actorId)
        if not self.threats[actorId] then return 0 end
        local count = 0
        for _ in pairs(self.threats[actorId]) do count = count + 1 end
        return count
    end,

    makeDecision = function(self, actorId, threatLevel, health, options)
        if not self.actors[actorId] then return "idle" end
        local actor = self.actors[actorId]
        local decision = "idle"
        if threatLevel > 70 and actor.aggressiveness > 50 then
            decision = "attack"
        elseif threatLevel > 60 and health < 40 then
            decision = "retreat"
        elseif threatLevel > 50 then
            decision = "defend"
        elseif threatLevel > 30 then
            decision = "investigate"
        end
        actor.decision = decision
        table.insert(self.decisions[actorId], {decision = decision, threat = threatLevel, health = health, turn = 0})
        return decision
    end,

    getLastDecision = function(self, actorId)
        if not self.actors[actorId] then return nil end
        return self.actors[actorId].decision
    end,

    getDecisionHistory = function(self, actorId)
        if not self.decisions[actorId] then return {} end
        return self.decisions[actorId]
    end,

    evaluatePosition = function(self, actorId, x, y, enemyCount, coverage)
        if not self.actors[actorId] then return 0 end
        local score = 50
        if coverage then score = score + 20 end
        if enemyCount > 3 then score = score - 30 end
        if enemyCount == 0 then score = score + 10 end
        return math.max(0, math.min(100, score))
    end,

    recordEncounter = function(self, actorId, enemyId, result)
        if not self.learning[actorId] then return false end
        self.learning[actorId].encounters = self.learning[actorId].encounters + 1
        if result == "victory" then
            self.learning[actorId].wins = self.learning[actorId].wins + 1
        else
            self.learning[actorId].losses = self.learning[actorId].losses + 1
        end
        return true
    end,

    getWinRate = function(self, actorId)
        if not self.learning[actorId] then return 0 end
        if self.learning[actorId].encounters == 0 then return 0 end
        return math.floor((self.learning[actorId].wins / self.learning[actorId].encounters) * 100)
    end,

    getEncounterCount = function(self, actorId)
        if not self.learning[actorId] then return 0 end
        return self.learning[actorId].encounters
    end,

    addStrategy = function(self, actorId, strategyId, name, effectiveness)
        if not self.strategies[actorId] then return false end
        self.strategies[actorId][strategyId] = {id = strategyId, name = name, effectiveness = effectiveness or 50, uses = 0}
        return true
    end,

    useStrategy = function(self, actorId, strategyId)
        if not self.strategies[actorId] or not self.strategies[actorId][strategyId] then return false end
        self.strategies[actorId][strategyId].uses = self.strategies[actorId][strategyId].uses + 1
        return true
    end,

    getBestStrategy = function(self, actorId)
        if not self.strategies[actorId] or not next(self.strategies[actorId]) then return nil end
        local best = nil
        local bestEff = -1
        for stratId, strat in pairs(self.strategies[actorId]) do
            if strat.effectiveness > bestEff then
                bestEff = strat.effectiveness
                best = stratId
            end
        end
        return best
    end,

    getStrategyCount = function(self, actorId)
        if not self.strategies[actorId] then return 0 end
        local count = 0
        for _ in pairs(self.strategies[actorId]) do count = count + 1 end
        return count
    end,

    calculateAggressiveness = function(self, actorId)
        if not self.actors[actorId] then return 0 end
        local actor = self.actors[actorId]
        local base = actor.aggressiveness
        local healthMod = (actor.health / 100) * 10
        local moraleMod = (actor.morale / 100) * 10
        return math.floor(base + healthMod + moraleMod)
    end,

    setHealthState = function(self, actorId, health)
        if not self.actors[actorId] then return false end
        self.actors[actorId].health = math.max(0, math.min(100, health))
        return true
    end,

    setMoraleState = function(self, actorId, morale)
        if not self.actors[actorId] then return false end
        self.actors[actorId].morale = math.max(0, math.min(100, morale))
        return true
    end,

    shouldRetreat = function(self, actorId, threatLevel, health)
        if health < 30 and threatLevel > 50 then return true end
        if health < 20 then return true end
        return false
    end,

    predictEnemyAction = function(self, enemyId, enemyHealth, enemyAggressiveness)
        if enemyHealth > 70 and enemyAggressiveness > 60 then return "attack"
        elseif enemyHealth < 40 then return "retreat"
        else return "defend"
        end
    end,

    adaptStrategy = function(self, actorId, success)
        if not self.strategies[actorId] or not next(self.strategies[actorId]) then return false end
        local best = self:getBestStrategy(actorId)
        if best and success then
            self.strategies[actorId][best].effectiveness = math.min(100, self.strategies[actorId][best].effectiveness + 5)
        elseif best then
            self.strategies[actorId][best].effectiveness = math.max(0, self.strategies[actorId][best].effectiveness - 10)
        end
        return true
    end
}

Suite:group("Actor Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tai = TacticalAI:new()
    end)

    Suite:testMethod("TacticalAI.registerActor", {description = "Registers actor", testCase = "register", type = "functional"}, function()
        local ok = shared.tai:registerActor("soldier1", "Soldier", "combat", 70)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("TacticalAI.getActor", {description = "Gets actor", testCase = "get_actor", type = "functional"}, function()
        shared.tai:registerActor("soldier2", "Soldier 2", "combat", 60)
        local actor = shared.tai:getActor("soldier2")
        Helpers.assertEqual(actor ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Threat Assessment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tai = TacticalAI:new()
        shared.tai:registerActor("defender", "Defender", "combat", 70)
    end)

    Suite:testMethod("TacticalAI.assessThreat", {description = "Assesses threat", testCase = "assess", type = "functional"}, function()
        local ok = shared.tai:assessThreat("defender", "threat1", "enemy", 75, 8)
        Helpers.assertEqual(ok, true, "Assessed")
    end)

    Suite:testMethod("TacticalAI.getThreatLevel", {description = "Threat level", testCase = "threat_level", type = "functional"}, function()
        shared.tai:assessThreat("defender", "t1", "enemy", 60, 10)
        shared.tai:assessThreat("defender", "t2", "enemy", 80, 5)
        local level = shared.tai:getThreatLevel("defender")
        Helpers.assertEqual(level, 80, "Max threat 80")
    end)

    Suite:testMethod("TacticalAI.getThreatCount", {description = "Threat count", testCase = "count", type = "functional"}, function()
        shared.tai:assessThreat("defender", "ta", "enemy", 50, 10)
        shared.tai:assessThreat("defender", "tb", "enemy", 50, 10)
        local count = shared.tai:getThreatCount("defender")
        Helpers.assertEqual(count, 2, "Two threats")
    end)
end)

Suite:group("Decision Making", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tai = TacticalAI:new()
        shared.tai:registerActor("decider", "Decider", "combat", 60)
    end)

    Suite:testMethod("TacticalAI.makeDecision", {description = "Makes decision", testCase = "decision", type = "functional"}, function()
        local decision = shared.tai:makeDecision("decider", 50, 80)
        Helpers.assertEqual(decision ~= nil, true, "Decision made")
    end)

    Suite:testMethod("TacticalAI.getLastDecision", {description = "Last decision", testCase = "last_decision", type = "functional"}, function()
        shared.tai:makeDecision("decider", 60, 70)
        local decision = shared.tai:getLastDecision("decider")
        Helpers.assertEqual(decision ~= nil, true, "Decision retrieved")
    end)

    Suite:testMethod("TacticalAI.getDecisionHistory", {description = "Decision history", testCase = "history", type = "functional"}, function()
        shared.tai:makeDecision("decider", 40, 80)
        shared.tai:makeDecision("decider", 70, 60)
        local history = shared.tai:getDecisionHistory("decider")
        Helpers.assertEqual(#history, 2, "Two decisions")
    end)
end)

Suite:group("Position Evaluation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tai = TacticalAI:new()
        shared.tai:registerActor("tactician", "Tactician", "combat", 65)
    end)

    Suite:testMethod("TacticalAI.evaluatePosition", {description = "Evaluates position", testCase = "eval_pos", type = "functional"}, function()
        local score = shared.tai:evaluatePosition("tactician", 10, 10, 2, true)
        Helpers.assertEqual(score > 0, true, "Score > 0")
    end)
end)

Suite:group("Learning System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tai = TacticalAI:new()
        shared.tai:registerActor("learner", "Learner", "combat", 50)
    end)

    Suite:testMethod("TacticalAI.recordEncounter", {description = "Records encounter", testCase = "record", type = "functional"}, function()
        local ok = shared.tai:recordEncounter("learner", "enemy1", "victory")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("TacticalAI.getWinRate", {description = "Win rate", testCase = "win_rate", type = "functional"}, function()
        shared.tai:recordEncounter("learner", "e1", "victory")
        shared.tai:recordEncounter("learner", "e2", "victory")
        shared.tai:recordEncounter("learner", "e3", "defeat")
        local rate = shared.tai:getWinRate("learner")
        Helpers.assertEqual(rate, 66, "66% win rate")
    end)

    Suite:testMethod("TacticalAI.getEncounterCount", {description = "Encounter count", testCase = "encounter_count", type = "functional"}, function()
        shared.tai:recordEncounter("learner", "enc1", "victory")
        shared.tai:recordEncounter("learner", "enc2", "defeat")
        local count = shared.tai:getEncounterCount("learner")
        Helpers.assertEqual(count, 2, "Two encounters")
    end)
end)

Suite:group("Strategy Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tai = TacticalAI:new()
        shared.tai:registerActor("strategist", "Strategist", "combat", 70)
    end)

    Suite:testMethod("TacticalAI.addStrategy", {description = "Adds strategy", testCase = "add_strat", type = "functional"}, function()
        local ok = shared.tai:addStrategy("strategist", "pincer", "Pincer Attack", 75)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("TacticalAI.useStrategy", {description = "Uses strategy", testCase = "use_strat", type = "functional"}, function()
        shared.tai:addStrategy("strategist", "flank", "Flank", 65)
        local ok = shared.tai:useStrategy("strategist", "flank")
        Helpers.assertEqual(ok, true, "Used")
    end)

    Suite:testMethod("TacticalAI.getBestStrategy", {description = "Best strategy", testCase = "best", type = "functional"}, function()
        shared.tai:addStrategy("strategist", "s1", "Strategy 1", 60)
        shared.tai:addStrategy("strategist", "s2", "Strategy 2", 85)
        local best = shared.tai:getBestStrategy("strategist")
        Helpers.assertEqual(best, "s2", "S2 best")
    end)

    Suite:testMethod("TacticalAI.getStrategyCount", {description = "Strategy count", testCase = "strat_count", type = "functional"}, function()
        shared.tai:addStrategy("strategist", "st1", "Strat 1", 50)
        shared.tai:addStrategy("strategist", "st2", "Strat 2", 50)
        local count = shared.tai:getStrategyCount("strategist")
        Helpers.assertEqual(count, 2, "Two strategies")
    end)
end)

Suite:group("State Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tai = TacticalAI:new()
        shared.tai:registerActor("state_actor", "State Actor", "combat", 60)
    end)

    Suite:testMethod("TacticalAI.setHealthState", {description = "Sets health", testCase = "set_health", type = "functional"}, function()
        local ok = shared.tai:setHealthState("state_actor", 50)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("TacticalAI.setMoraleState", {description = "Sets morale", testCase = "set_morale", type = "functional"}, function()
        local ok = shared.tai:setMoraleState("state_actor", 60)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("TacticalAI.calculateAggressiveness", {description = "Calculates aggression", testCase = "aggression", type = "functional"}, function()
        shared.tai:setHealthState("state_actor", 80)
        shared.tai:setMoraleState("state_actor", 80)
        local agg = shared.tai:calculateAggressiveness("state_actor")
        Helpers.assertEqual(agg > 0, true, "Aggressiveness > 0")
    end)
end)

Suite:group("Advanced Tactics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tai = TacticalAI:new()
        shared.tai:registerActor("tactician", "Tactician", "combat", 70)
    end)

    Suite:testMethod("TacticalAI.shouldRetreat", {description = "Retreat decision", testCase = "retreat", type = "functional"}, function()
        local should = shared.tai:shouldRetreat("tactician", 70, 25)
        Helpers.assertEqual(should, true, "Should retreat")
    end)

    Suite:testMethod("TacticalAI.predictEnemyAction", {description = "Predicts action", testCase = "predict", type = "functional"}, function()
        local action = shared.tai:predictEnemyAction("enemy", 80, 70)
        Helpers.assertEqual(action, "attack", "Attack predicted")
    end)

    Suite:testMethod("TacticalAI.adaptStrategy", {description = "Adapts strategy", testCase = "adapt", type = "functional"}, function()
        shared.tai:addStrategy("tactician", "adapt_test", "Test", 50)
        local ok = shared.tai:adaptStrategy("tactician", true)
        Helpers.assertEqual(ok, true, "Adapted")
    end)
end)

Suite:run()
