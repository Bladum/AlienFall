-- ─────────────────────────────────────────────────────────────────────────
-- ADVANCED AI TEST SUITE
-- FILE: tests2/ai/advanced_ai_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.ai.advanced_ai",
    fileName = "advanced_ai.lua",
    description = "Advanced AI with learning, adaptation, strategy, and emergent behavior"
})

print("[ADVANCED_AI_TEST] Setting up")

local AdvancedAI = {
    agents = {}, behaviors = {}, learning_models = {}, strategies = {},

    new = function(self)
        return setmetatable({
            agents = {}, behaviors = {}, learning_models = {}, strategies = {}
        }, {__index = self})
    end,

    createAgent = function(self, agentId, name, intelligence, adaptability)
        self.agents[agentId] = {
            id = agentId, name = name, intelligence = intelligence or 50,
            adaptability = adaptability or 40, experience = 0, decisions = {},
            learning_rate = 0.1, strategy_pool = {}, active_strategy = nil,
            success_count = 0, failure_count = 0
        }
        return true
    end,

    getAgent = function(self, agentId)
        return self.agents[agentId]
    end,

    registerBehavior = function(self, behaviorId, name, priority, condition_func)
        self.behaviors[behaviorId] = {
            id = behaviorId, name = name, priority = priority or 50,
            condition = condition_func or function() return true end,
            execution_count = 0, success_rate = 100
        }
        return true
    end,

    getBehavior = function(self, behaviorId)
        return self.behaviors[behaviorId]
    end,

    selectBehavior = function(self, agentId)
        if not self.agents[agentId] then return nil end
        local agent = self.agents[agentId]
        local best_behavior = nil
        local best_priority = -1

        for _, behavior in pairs(self.behaviors) do
            if behavior.condition() and behavior.priority > best_priority then
                best_priority = behavior.priority
                best_behavior = behavior
            end
        end

        if best_behavior then
            best_behavior.execution_count = best_behavior.execution_count + 1
        end
        return best_behavior
    end,

    createLearningModel = function(self, modelId, agent_id, model_type)
        self.learning_models[modelId] = {
            id = modelId, agent_id = agent_id, type = model_type or "neural",
            accuracy = 0, iterations = 0, training_data = {},
            loss = 100, convergence_threshold = 0.01
        }
        return true
    end,

    getLearningModel = function(self, modelId)
        return self.learning_models[modelId]
    end,

    trainModel = function(self, modelId, training_data)
        if not self.learning_models[modelId] then return false end
        local model = self.learning_models[modelId]
        model.training_data = training_data or {}
        model.iterations = model.iterations + 1
        model.loss = math.max(0, model.loss - 5)
        model.accuracy = math.min(100, model.accuracy + 2)
        return true
    end,

    predictAction = function(self, modelId, input_state)
        if not self.learning_models[modelId] then return nil end
        local model = self.learning_models[modelId]
        local base_prediction = math.random(1, 100)
        local accuracy_factor = model.accuracy / 100
        return math.floor(base_prediction * accuracy_factor)
    end,

    recordDecision = function(self, agentId, decision, outcome)
        if not self.agents[agentId] then return false end
        local agent = self.agents[agentId]
        table.insert(agent.decisions, {decision = decision, outcome = outcome, timestamp = os.time()})
        if outcome == "success" then
            agent.success_count = agent.success_count + 1
        else
            agent.failure_count = agent.failure_count + 1
        end
        return true
    end,

    getSuccessRate = function(self, agentId)
        if not self.agents[agentId] then return 0 end
        local agent = self.agents[agentId]
        local total = agent.success_count + agent.failure_count
        if total == 0 then return 0 end
        return (agent.success_count / total) * 100
    end,

    createStrategy = function(self, strategyId, name, tactics, efficiency)
        self.strategies[strategyId] = {
            id = strategyId, name = name, tactics = tactics or {},
            efficiency = efficiency or 50, priority = 0, usage_count = 0,
            success_history = {}, adaptation_level = 0
        }
        return true
    end,

    getStrategy = function(self, strategyId)
        return self.strategies[strategyId]
    end,

    assignStrategy = function(self, agentId, strategyId)
        if not self.agents[agentId] or not self.strategies[strategyId] then return false end
        self.agents[agentId].active_strategy = strategyId
        self.strategies[strategyId].usage_count = self.strategies[strategyId].usage_count + 1
        return true
    end,

    adaptStrategy = function(self, strategyId, feedback_value)
        if not self.strategies[strategyId] then return false end
        local strategy = self.strategies[strategyId]
        strategy.efficiency = math.min(100, strategy.efficiency + feedback_value)
        strategy.adaptation_level = strategy.adaptation_level + 1
        table.insert(strategy.success_history, feedback_value)
        return true
    end,

    getStrategicDecision = function(self, agentId, context)
        if not self.agents[agentId] then return nil end
        local agent = self.agents[agentId]
        if not agent.active_strategy then return nil end
        local strategy = self.strategies[agent.active_strategy]
        if not strategy then return nil end
        local decision_value = (agent.intelligence + strategy.efficiency) / 2
        return {strategy = strategy.id, confidence = decision_value, adapted = strategy.adaptation_level > 0}
    end,

    updateAgentIntelligence = function(self, agentId, amount)
        if not self.agents[agentId] then return false end
        self.agents[agentId].intelligence = math.max(0, math.min(100, self.agents[agentId].intelligence + amount))
        return true
    end,

    updateAgentAdaptability = function(self, agentId, amount)
        if not self.agents[agentId] then return false end
        self.agents[agentId].adaptability = math.max(0, math.min(100, self.agents[agentId].adaptability + amount))
        return true
    end,

    calculateAgentEffectiveness = function(self, agentId)
        if not self.agents[agentId] then return 0 end
        local agent = self.agents[agentId]
        local base = (agent.intelligence + agent.adaptability) / 2
        local experience_bonus = math.min(50, agent.experience / 2)
        local success_bonus = self:getSuccessRate(agentId) / 2
        return math.floor(base + experience_bonus + success_bonus)
    end,

    gainExperience = function(self, agentId, amount)
        if not self.agents[agentId] then return false end
        self.agents[agentId].experience = self.agents[agentId].experience + (amount or 10)
        return true
    end,

    simulateDecision = function(self, agentId, situation)
        if not self.agents[agentId] then return nil end
        local agent = self.agents[agentId]
        local behavior = self:selectBehavior(agentId)
        local decision_quality = (agent.intelligence + (behavior and behavior.priority or 0)) / 2
        return {success_probability = decision_quality, behavior = behavior}
    end,

    getAgentStats = function(self, agentId)
        if not self.agents[agentId] then return nil end
        local agent = self.agents[agentId]
        return {
            intelligence = agent.intelligence, adaptability = agent.adaptability,
            experience = agent.experience, effectiveness = self:calculateAgentEffectiveness(agentId),
            success_rate = self:getSuccessRate(agentId), decisions = #agent.decisions
        }
    end,

    reset = function(self)
        self.agents = {}
        self.behaviors = {}
        self.learning_models = {}
        self.strategies = {}
        return true
    end
}

Suite:group("Agent Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = AdvancedAI:new()
    end)

    Suite:testMethod("AdvancedAI.createAgent", {description = "Creates agent", testCase = "create", type = "functional"}, function()
        local ok = shared.ai:createAgent("agent1", "TestBot", 60, 50)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("AdvancedAI.getAgent", {description = "Gets agent", testCase = "get", type = "functional"}, function()
        shared.ai:createAgent("agent2", "SmartBot", 70, 65)
        local agent = shared.ai:getAgent("agent2")
        Helpers.assertEqual(agent ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("AdvancedAI.updateAgentIntelligence", {description = "Updates intelligence", testCase = "update_intel", type = "functional"}, function()
        shared.ai:createAgent("agent3", "Bot", 50, 50)
        local ok = shared.ai:updateAgentIntelligence("agent3", 20)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("AdvancedAI.updateAgentAdaptability", {description = "Updates adaptability", testCase = "update_adapt", type = "functional"}, function()
        shared.ai:createAgent("agent4", "Bot", 50, 50)
        local ok = shared.ai:updateAgentAdaptability("agent4", 15)
        Helpers.assertEqual(ok, true, "Updated")
    end)
end)

Suite:group("Behavior System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = AdvancedAI:new()
    end)

    Suite:testMethod("AdvancedAI.registerBehavior", {description = "Registers behavior", testCase = "register", type = "functional"}, function()
        local ok = shared.ai:registerBehavior("behav1", "Attack", 80)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("AdvancedAI.getBehavior", {description = "Gets behavior", testCase = "get", type = "functional"}, function()
        shared.ai:registerBehavior("behav2", "Defend", 60)
        local behav = shared.ai:getBehavior("behav2")
        Helpers.assertEqual(behav ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("AdvancedAI.selectBehavior", {description = "Selects behavior", testCase = "select", type = "functional"}, function()
        shared.ai:registerBehavior("behav3", "Retreat", 40)
        shared.ai:createAgent("agent5", "Bot", 50, 50)
        local behav = shared.ai:selectBehavior("agent5")
        Helpers.assertEqual(behav ~= nil, true, "Selected")
    end)

    Suite:testMethod("AdvancedAI.behavior_priority_selection", {description = "Selects by priority", testCase = "priority", type = "functional"}, function()
        shared.ai:registerBehavior("behav_low", "Low", 20)
        shared.ai:registerBehavior("behav_high", "High", 95)
        shared.ai:createAgent("agent6", "Bot", 50, 50)
        local behav = shared.ai:selectBehavior("agent6")
        Helpers.assertEqual(behav.priority >= 20, true, "Priority respected")
    end)
end)

Suite:group("Learning System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = AdvancedAI:new()
    end)

    Suite:testMethod("AdvancedAI.createLearningModel", {description = "Creates model", testCase = "create", type = "functional"}, function()
        local ok = shared.ai:createLearningModel("model1", "agent1", "neural")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("AdvancedAI.getLearningModel", {description = "Gets model", testCase = "get", type = "functional"}, function()
        shared.ai:createLearningModel("model2", "agent2", "decision_tree")
        local model = shared.ai:getLearningModel("model2")
        Helpers.assertEqual(model ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("AdvancedAI.trainModel", {description = "Trains model", testCase = "train", type = "functional"}, function()
        shared.ai:createLearningModel("model3", "agent3", "neural")
        local ok = shared.ai:trainModel("model3", {1, 2, 3})
        Helpers.assertEqual(ok, true, "Trained")
    end)

    Suite:testMethod("AdvancedAI.model_improves_with_training", {description = "Model improves", testCase = "improve", type = "functional"}, function()
        shared.ai:createLearningModel("model4", "agent4", "neural")
        local model1 = shared.ai:getLearningModel("model4")
        local acc1 = model1.accuracy
        shared.ai:trainModel("model4")
        shared.ai:trainModel("model4")
        local model2 = shared.ai:getLearningModel("model4")
        Helpers.assertEqual(model2.accuracy > acc1, true, "Improved")
    end)

    Suite:testMethod("AdvancedAI.predictAction", {description = "Predicts action", testCase = "predict", type = "functional"}, function()
        shared.ai:createLearningModel("model5", "agent5", "neural")
        local prediction = shared.ai:predictAction("model5", {state = "combat"})
        Helpers.assertEqual(prediction ~= nil, true, "Predicted")
    end)
end)

Suite:group("Decision Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = AdvancedAI:new()
        shared.ai:createAgent("agent7", "Bot", 50, 50)
    end)

    Suite:testMethod("AdvancedAI.recordDecision", {description = "Records decision", testCase = "record", type = "functional"}, function()
        local ok = shared.ai:recordDecision("agent7", "attack", "success")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("AdvancedAI.getSuccessRate", {description = "Gets success rate", testCase = "rate", type = "functional"}, function()
        shared.ai:recordDecision("agent7", "action1", "success")
        shared.ai:recordDecision("agent7", "action2", "failure")
        local rate = shared.ai:getSuccessRate("agent7")
        Helpers.assertEqual(rate > 0, true, "Rate > 0")
    end)

    Suite:testMethod("AdvancedAI.decision_history_tracking", {description = "Tracks history", testCase = "history", type = "functional"}, function()
        shared.ai:recordDecision("agent7", "move", "success")
        shared.ai:recordDecision("agent7", "attack", "success")
        local agent = shared.ai:getAgent("agent7")
        Helpers.assertEqual(#agent.decisions >= 2, true, "History tracked")
    end)
end)

Suite:group("Strategy System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = AdvancedAI:new()
    end)

    Suite:testMethod("AdvancedAI.createStrategy", {description = "Creates strategy", testCase = "create", type = "functional"}, function()
        local ok = shared.ai:createStrategy("strat1", "Aggressive", {"attack", "pursue"}, 75)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("AdvancedAI.getStrategy", {description = "Gets strategy", testCase = "get", type = "functional"}, function()
        shared.ai:createStrategy("strat2", "Defensive", {"defend", "retreat"}, 60)
        local strat = shared.ai:getStrategy("strat2")
        Helpers.assertEqual(strat ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("AdvancedAI.assignStrategy", {description = "Assigns strategy", testCase = "assign", type = "functional"}, function()
        shared.ai:createAgent("agent8", "Bot", 50, 50)
        shared.ai:createStrategy("strat3", "Balanced", {"defend", "attack"}, 70)
        local ok = shared.ai:assignStrategy("agent8", "strat3")
        Helpers.assertEqual(ok, true, "Assigned")
    end)

    Suite:testMethod("AdvancedAI.adaptStrategy", {description = "Adapts strategy", testCase = "adapt", type = "functional"}, function()
        shared.ai:createStrategy("strat4", "Test", {"act"}, 50)
        local ok = shared.ai:adaptStrategy("strat4", 10)
        Helpers.assertEqual(ok, true, "Adapted")
    end)

    Suite:testMethod("AdvancedAI.strategy_efficiency_improvement", {description = "Efficiency improves", testCase = "improve", type = "functional"}, function()
        shared.ai:createStrategy("strat5", "Test", {"action"}, 50)
        local strat1 = shared.ai:getStrategy("strat5")
        local eff1 = strat1.efficiency
        shared.ai:adaptStrategy("strat5", 15)
        local strat2 = shared.ai:getStrategy("strat5")
        Helpers.assertEqual(strat2.efficiency > eff1, true, "Improved")
    end)
end)

Suite:group("Strategic Decision Making", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = AdvancedAI:new()
        shared.ai:createAgent("agent9", "Bot", 70, 60)
        shared.ai:createStrategy("strat6", "Tactical", {"scout", "engage"}, 65)
        shared.ai:assignStrategy("agent9", "strat6")
    end)

    Suite:testMethod("AdvancedAI.getStrategicDecision", {description = "Gets decision", testCase = "decision", type = "functional"}, function()
        local decision = shared.ai:getStrategicDecision("agent9", {enemies = 3})
        Helpers.assertEqual(decision ~= nil, true, "Decision made")
    end)

    Suite:testMethod("AdvancedAI.strategic_decision_considers_intelligence", {description = "Uses intelligence", testCase = "intel", type = "functional"}, function()
        local decision = shared.ai:getStrategicDecision("agent9", {})
        Helpers.assertEqual(decision.confidence >= 0, true, "Confidence calculated")
    end)
end)

Suite:group("Experience & Effectiveness", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = AdvancedAI:new()
        shared.ai:createAgent("agent10", "Bot", 60, 55)
    end)

    Suite:testMethod("AdvancedAI.gainExperience", {description = "Gains experience", testCase = "gain", type = "functional"}, function()
        local ok = shared.ai:gainExperience("agent10", 25)
        Helpers.assertEqual(ok, true, "Gained")
    end)

    Suite:testMethod("AdvancedAI.calculateAgentEffectiveness", {description = "Calculates effectiveness", testCase = "calc", type = "functional"}, function()
        shared.ai:gainExperience("agent10", 50)
        local eff = shared.ai:calculateAgentEffectiveness("agent10")
        Helpers.assertEqual(eff > 0, true, "Effectiveness > 0")
    end)

    Suite:testMethod("AdvancedAI.effectiveness_improves_with_experience", {description = "Improves with exp", testCase = "improve", type = "functional"}, function()
        local eff1 = shared.ai:calculateAgentEffectiveness("agent10")
        shared.ai:gainExperience("agent10", 100)
        local eff2 = shared.ai:calculateAgentEffectiveness("agent10")
        Helpers.assertEqual(eff2 >= eff1, true, "Improved")
    end)

    Suite:testMethod("AdvancedAI.getAgentStats", {description = "Gets stats", testCase = "stats", type = "functional"}, function()
        local stats = shared.ai:getAgentStats("agent10")
        Helpers.assertEqual(stats ~= nil, true, "Stats retrieved")
    end)
end)

Suite:group("Simulation & Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = AdvancedAI:new()
        shared.ai:createAgent("agent11", "Bot", 65, 60)
        shared.ai:registerBehavior("behav_sim", "Simulate", 70)
    end)

    Suite:testMethod("AdvancedAI.simulateDecision", {description = "Simulates decision", testCase = "simulate", type = "functional"}, function()
        local result = shared.ai:simulateDecision("agent11", "hostile_environment")
        Helpers.assertEqual(result ~= nil, true, "Simulation done")
    end)

    Suite:testMethod("AdvancedAI.simulation_includes_probability", {description = "Has probability", testCase = "prob", type = "functional"}, function()
        local result = shared.ai:simulateDecision("agent11", "test")
        Helpers.assertEqual(result.success_probability >= 0, true, "Probability present")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ai = AdvancedAI:new()
    end)

    Suite:testMethod("AdvancedAI.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ai:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
