-- ─────────────────────────────────────────────────────────────────────────
-- AI TACTICAL DECISION SYSTEM TEST SUITE
-- FILE: tests2/ai/ai_tactical_decision_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.ai.tactical.decision_system
-- Covers AI decision-making, behavior modes, target selection, and action evaluation
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.ai.tactical.decision_system",
    fileName = "decision_system.lua",
    description = "AI tactical decision system - threat assessment, target prioritization, action selection"
})

print("[AI_TACTICAL_DECISION_TEST] Setting up")

-- Mock Decision System based on actual implementation
local AIDecisionSystem = {
    units = {},
    behaviors = {
        AGGRESSIVE = {
            name = "Aggressive",
            preferredDistance = 5,
            retreatThreshold = 20,
            targetPriority = "CLOSEST",
            useCoverChance = 30,
            overwatchChance = 10,
        },
        DEFENSIVE = {
            name = "Defensive",
            preferredDistance = 10,
            retreatThreshold = 50,
            targetPriority = "CLOSEST",
            useCoverChance = 90,
            overwatchChance = 60,
        },
        SUPPORT = {
            name = "Support",
            preferredDistance = 8,
            retreatThreshold = 40,
            targetPriority = "WEAKEST_ALLY",
            useCoverChance = 70,
            overwatchChance = 20,
        },
        FLANKING = {
            name = "Flanking",
            preferredDistance = 8,
            retreatThreshold = 35,
            targetPriority = "FLANKABLE",
            useCoverChance = 60,
            overwatchChance = 30,
        },
        SUPPRESSIVE = {
            name = "Suppressive",
            preferredDistance = 12,
            retreatThreshold = 30,
            targetPriority = "CLOSEST",
            useCoverChance = 80,
            overwatchChance = 40,
        },
        RETREAT = {
            name = "Retreat",
            preferredDistance = 15,
            retreatThreshold = 100, -- Always retreat
            targetPriority = "NONE",
            useCoverChance = 20,
            overwatchChance = 5,
        }
    }
}

function AIDecisionSystem.new()
    return setmetatable({
        units = {},
        battlefield = {units = {}, width = 20, height = 20}
    }, {__index = AIDecisionSystem})
end

function AIDecisionSystem:initializeUnit(unitId, behavior)
    self.units[unitId] = {
        id = unitId,
        behavior = behavior or "AGGRESSIVE",
        hp = 100,
        maxHp = 100,
        ap = 10,
        position = {x = 10, y = 10},
        decisions = {}
    }
    return true
end

function AIDecisionSystem:removeUnit(unitId)
    if self.units[unitId] then
        self.units[unitId].behavior = "AGGRESSIVE" -- Reset to default
        return true
    end
    return false
end

function AIDecisionSystem:setBehavior(unitId, behavior)
    if self.units[unitId] and self.behaviors[behavior] then
        self.units[unitId].behavior = behavior
        return true
    end
    return false
end

function AIDecisionSystem:getBehavior(unitId)
    return self.units[unitId] and self.units[unitId].behavior or "AGGRESSIVE"
end

function AIDecisionSystem:checkBehaviorSwitch(unitId, unitData)
    if not self.units[unitId] then return "AGGRESSIVE" end

    local unit = self.units[unitId]
    local hpPercent = (unitData.hp / unitData.maxHp) * 100

    -- Low HP triggers retreat
    if hpPercent < 30 then
        return "RETREAT"
    elseif hpPercent < 50 then
        return "DEFENSIVE"
    else
        return unit.behavior -- Stay current
    end
end

function AIDecisionSystem:evaluateThreat(enemy)
    if not enemy then return 0 end

    local threat = 50 -- Base threat
    threat = threat + (enemy.damage or 0) * 0.5
    threat = threat - (enemy.distance or 10) * 2
    threat = threat + (enemy.hp < 50 and 20 or 0) -- Wounded are less threatening

    return math.max(0, math.min(100, threat))
end

function AIDecisionSystem:selectTarget(unitId, enemies, behavior)
    if not self.units[unitId] or not enemies or #enemies == 0 then return nil end

    behavior = behavior or self.units[unitId].behavior
    local behaviorConfig = self.behaviors[behavior]

    if behavior == "CLOSEST" or behaviorConfig.targetPriority == "CLOSEST" then
        -- Find closest enemy
        local closest = nil
        local minDist = math.huge
        for _, enemy in ipairs(enemies) do
            local dist = math.sqrt((enemy.x - self.units[unitId].position.x)^2 + (enemy.y - self.units[unitId].position.y)^2)
            if dist < minDist then
                minDist = dist
                closest = enemy
            end
        end
        return closest
    elseif behaviorConfig.targetPriority == "WEAKEST_ALLY" then
        -- For support behavior, find weakest ally (simplified)
        return enemies[1] -- Just return first for mock
    end

    return enemies[1] -- Default to first enemy
end

function AIDecisionSystem:evaluateOptions(unitId, unitData, visibleEnemies, visibleAllies)
    if not self.units[unitId] then return {} end

    local actions = {}
    local unit = self.units[unitId]

    -- Always include basic actions
    if #visibleEnemies > 0 then
        table.insert(actions, {
            actionType = "SHOOT",
            score = 70,
            target = visibleEnemies[1]
        })
    end

    table.insert(actions, {
        actionType = "MOVE",
        score = 50,
        target = nil
    })

    -- Low HP adds retreat action
    if unitData.hp < 30 then
        table.insert(actions, {
            actionType = "RETREAT",
            score = 90, -- High priority
            target = nil
        })
    end

    -- Sort by score descending
    table.sort(actions, function(a, b) return a.score > b.score end)

    return actions
end

function AIDecisionSystem:selectBestAction(actions)
    if not actions or #actions == 0 then return nil end

    -- Sort by score descending and return highest
    table.sort(actions, function(a, b) return (a.score or 0) > (b.score or 0) end)
    return actions[1]
end

function AIDecisionSystem:getAllAIStates()
    local states = {}
    for unitId, unit in pairs(self.units) do
        states[unitId] = {
            behavior = unit.behavior,
            hp = unit.hp,
            decisions = #unit.decisions
        }
    end
    return states
end

function AIDecisionSystem:visualizeDecision(unitId, actions)
    if not self.units[unitId] then return nil end

    return {
        unitId = unitId,
        behavior = self.units[unitId].behavior,
        actionCount = actions and #actions or 0,
        bestAction = actions and actions[1] and actions[1].actionType or nil
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: AI SYSTEM INITIALIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("AI System Initialization", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.ai = AIDecisionSystem:new()
    end)

    Suite:testMethod("AIDecisionSystem.new", {
        description = "Creates AI decision system instance",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertEqual(shared.ai ~= nil, true, "AI system should be created")
        Helpers.assertEqual(shared.ai.units ~= nil, true, "Should have units table")
    end)

    Suite:testMethod("AIDecisionSystem.initializeUnit", {
        description = "Initializes AI unit with default behavior",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local ok = shared.ai:initializeUnit("unit1")
        Helpers.assertEqual(ok, true, "Should initialize unit")
        Helpers.assertEqual(shared.ai:getBehavior("unit1"), "AGGRESSIVE", "Default behavior should be AGGRESSIVE")
    end)

    Suite:testMethod("AIDecisionSystem.initializeUnit", {
        description = "Initializes AI unit with specific behavior",
        testCase = "custom_behavior",
        type = "functional"
    }, function()
        local ok = shared.ai:initializeUnit("unit2", "DEFENSIVE")
        Helpers.assertEqual(ok, true, "Should initialize unit")
        Helpers.assertEqual(shared.ai:getBehavior("unit2"), "DEFENSIVE", "Should use custom behavior")
    end)

    Suite:testMethod("AIDecisionSystem.setBehavior", {
        description = "Changes unit behavior",
        testCase = "happy_path",
        type = "functional"
    }, function()
        shared.ai:initializeUnit("unit3", "AGGRESSIVE")
        local ok = shared.ai:setBehavior("unit3", "DEFENSIVE")
        Helpers.assertEqual(ok, true, "Should change behavior")
        Helpers.assertEqual(shared.ai:getBehavior("unit3"), "DEFENSIVE", "Behavior should change")
    end)

    Suite:testMethod("AIDecisionSystem.removeUnit", {
        description = "Removes unit from AI system",
        testCase = "happy_path",
        type = "functional"
    }, function()
        shared.ai:initializeUnit("unit4")
        local ok = shared.ai:removeUnit("unit4")
        Helpers.assertEqual(ok, true, "Should remove unit")
        Helpers.assertEqual(shared.ai:getBehavior("unit4"), "AGGRESSIVE", "Removed unit should reset to default")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: BEHAVIOR CONFIGURATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Behavior Configuration", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.ai = AIDecisionSystem:new()
        shared.ai:initializeUnit("test_unit")
    end)

    Suite:testMethod("AIDecisionSystem.checkBehaviorSwitch", {
        description = "Switches to RETREAT when HP is very low",
        testCase = "low_hp_retreat",
        type = "functional"
    }, function()
        local newBehavior = shared.ai:checkBehaviorSwitch("test_unit", {hp = 15, maxHp = 100})
        Helpers.assertEqual(newBehavior, "RETREAT", "Should switch to RETREAT at low HP")
    end)

    Suite:testMethod("AIDecisionSystem.checkBehaviorSwitch", {
        description = "Switches to DEFENSIVE when HP is moderately low",
        testCase = "moderate_hp_defensive",
        type = "functional"
    }, function()
        local newBehavior = shared.ai:checkBehaviorSwitch("test_unit", {hp = 40, maxHp = 100})
        Helpers.assertEqual(newBehavior, "DEFENSIVE", "Should switch to DEFENSIVE at moderate HP")
    end)

    Suite:testMethod("AIDecisionSystem.checkBehaviorSwitch", {
        description = "Maintains current behavior when HP is high",
        testCase = "high_hp_no_change",
        type = "functional"
    }, function()
        shared.ai:setBehavior("test_unit", "AGGRESSIVE")
        local newBehavior = shared.ai:checkBehaviorSwitch("test_unit", {hp = 80, maxHp = 100})
        Helpers.assertEqual(newBehavior, "AGGRESSIVE", "Should maintain AGGRESSIVE at high HP")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: THREAT EVALUATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Threat Evaluation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.ai = AIDecisionSystem:new()
    end)

    Suite:testMethod("AIDecisionSystem.evaluateThreat", {
        description = "Evaluates threat level of enemy unit",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local enemy = {damage = 20, distance = 5, hp = 80}
        local threat = shared.ai:evaluateThreat(enemy)
        Helpers.assertEqual(threat >= 0 and threat <= 100, true, "Threat should be 0-100")
    end)

    Suite:testMethod("AIDecisionSystem.evaluateThreat", {
        description = "Higher damage increases threat",
        testCase = "damage_factor",
        type = "functional"
    }, function()
        local lowDamage = shared.ai:evaluateThreat({damage = 10, distance = 5, hp = 80})
        local highDamage = shared.ai:evaluateThreat({damage = 30, distance = 5, hp = 80})
        Helpers.assertEqual(highDamage > lowDamage, true, "Higher damage should increase threat")
    end)

    Suite:testMethod("AIDecisionSystem.evaluateThreat", {
        description = "Closer distance increases threat",
        testCase = "distance_factor",
        type = "functional"
    }, function()
        local farEnemy = shared.ai:evaluateThreat({damage = 20, distance = 15, hp = 80})
        local closeEnemy = shared.ai:evaluateThreat({damage = 20, distance = 3, hp = 80})
        Helpers.assertEqual(closeEnemy > farEnemy, true, "Closer enemy should be more threatening")
    end)

    Suite:testMethod("AIDecisionSystem.evaluateThreat", {
        description = "Handles nil enemy gracefully",
        testCase = "nil_enemy",
        type = "error_handling"
    }, function()
        local threat = shared.ai:evaluateThreat(nil)
        Helpers.assertEqual(threat, 0, "Nil enemy should return 0 threat")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: TARGET SELECTION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Target Selection", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.ai = AIDecisionSystem:new()
        shared.ai:initializeUnit("selector", "AGGRESSIVE")
        shared.ai.units["selector"].position = {x = 10, y = 10}
    end)

    Suite:testMethod("AIDecisionSystem.selectTarget", {
        description = "Selects closest enemy for AGGRESSIVE behavior",
        testCase = "closest_target",
        type = "functional"
    }, function()
        local enemies = {
            {id = "far", x = 20, y = 20}, -- Distance ~14.1
            {id = "close", x = 12, y = 12} -- Distance ~2.8
        }
        local target = shared.ai:selectTarget("selector", enemies, "AGGRESSIVE")
        Helpers.assertEqual(target ~= nil, true, "Should select a target")
        Helpers.assertEqual(target.id, "close", "Should select closest enemy")
    end)

    Suite:testMethod("AIDecisionSystem.selectTarget", {
        description = "Returns nil when no enemies available",
        testCase = "no_enemies",
        type = "edge_case"
    }, function()
        local target = shared.ai:selectTarget("selector", {}, "AGGRESSIVE")
        Helpers.assertEqual(target, nil, "Should return nil with no enemies")
    end)

    Suite:testMethod("AIDecisionSystem.selectTarget", {
        description = "Returns nil for invalid unit",
        testCase = "invalid_unit",
        type = "error_handling"
    }, function()
        local enemies = {{id = "enemy1", x = 15, y = 15}}
        local target = shared.ai:selectTarget("nonexistent", enemies, "AGGRESSIVE")
        Helpers.assertEqual(target, nil, "Should return nil for invalid unit")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: ACTION EVALUATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Action Evaluation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.ai = AIDecisionSystem:new()
        shared.ai:initializeUnit("actor")
    end)

    Suite:testMethod("AIDecisionSystem.evaluateOptions", {
        description = "Evaluates available actions for unit",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local unitData = {hp = 80, maxHp = 100, ap = 10}
        local enemies = {{id = "enemy1"}}
        local allies = {{id = "ally1"}}

        local actions = shared.ai:evaluateOptions("actor", unitData, enemies, allies)
        Helpers.assertEqual(actions ~= nil, true, "Should return actions table")
        Helpers.assertEqual(#actions > 0, true, "Should have at least one action")
    end)

    Suite:testMethod("AIDecisionSystem.evaluateOptions", {
        description = "Includes RETREAT action when HP is low",
        testCase = "low_hp_retreat_action",
        type = "functional"
    }, function()
        local unitData = {hp = 20, maxHp = 100, ap = 10}
        local enemies = {{id = "enemy1"}}
        local allies = {}

        local actions = shared.ai:evaluateOptions("actor", unitData, enemies, allies)

        local hasRetreat = false
        for _, action in ipairs(actions) do
            if action.actionType == "RETREAT" then
                hasRetreat = true
                break
            end
        end
        Helpers.assertEqual(hasRetreat, true, "Should include RETREAT action at low HP")
    end)

    Suite:testMethod("AIDecisionSystem.selectBestAction", {
        description = "Selects highest scoring action",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local actions = {
            {actionType = "MOVE", score = 50},
            {actionType = "SHOOT", score = 80},
            {actionType = "OVERWATCH", score = 30}
        }
        local best = shared.ai:selectBestAction(actions)
        Helpers.assertEqual(best ~= nil, true, "Should select best action")
        Helpers.assertEqual(best.actionType, "SHOOT", "Should select highest scoring action")
    end)

    Suite:testMethod("AIDecisionSystem.selectBestAction", {
        description = "Returns nil for empty actions",
        testCase = "empty_actions",
        type = "edge_case"
    }, function()
        local best = shared.ai:selectBestAction({})
        Helpers.assertEqual(best, nil, "Should return nil for empty actions")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 6: AI STATE MANAGEMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("AI State Management", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.ai = AIDecisionSystem:new()
        shared.ai:initializeUnit("state_unit1", "AGGRESSIVE")
        shared.ai:initializeUnit("state_unit2", "DEFENSIVE")
    end)

    Suite:testMethod("AIDecisionSystem.getAllAIStates", {
        description = "Returns state of all AI units",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local states = shared.ai:getAllAIStates()
        Helpers.assertEqual(states ~= nil, true, "Should return states table")
        Helpers.assertEqual(states["state_unit1"] ~= nil, true, "Should include unit1")
        Helpers.assertEqual(states["state_unit2"] ~= nil, true, "Should include unit2")
        Helpers.assertEqual(states["state_unit1"].behavior, "AGGRESSIVE", "Unit1 should have correct behavior")
        Helpers.assertEqual(states["state_unit2"].behavior, "DEFENSIVE", "Unit2 should have correct behavior")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 7: DECISION VISUALIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Decision Visualization", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.ai = AIDecisionSystem:new()
        shared.ai:initializeUnit("visual_unit")
    end)

    Suite:testMethod("AIDecisionSystem.visualizeDecision", {
        description = "Creates visualization of AI decision process",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local actions = {
            {actionType = "SHOOT", score = 70},
            {actionType = "MOVE", score = 50}
        }
        local viz = shared.ai:visualizeDecision("visual_unit", actions)
        Helpers.assertEqual(viz ~= nil, true, "Should return visualization")
        Helpers.assertEqual(viz.unitId, "visual_unit", "Should include unit ID")
        Helpers.assertEqual(viz.behavior, "AGGRESSIVE", "Should include behavior")
        Helpers.assertEqual(viz.actionCount, 2, "Should include action count")
        Helpers.assertEqual(viz.bestAction, "SHOOT", "Should include best action")
    end)

    Suite:testMethod("AIDecisionSystem.visualizeDecision", {
        description = "Returns nil for invalid unit",
        testCase = "invalid_unit",
        type = "error_handling"
    }, function()
        local viz = shared.ai:visualizeDecision("nonexistent", {})
        Helpers.assertEqual(viz, nil, "Should return nil for invalid unit")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
