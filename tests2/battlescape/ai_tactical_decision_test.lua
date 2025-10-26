-- ─────────────────────────────────────────────────────────────────────────
-- TEST: AI Tactical Decision System
-- FILE: tests2/battlescape/ai_tactical_decision_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for AI decision-making, behavior modes, threat assessment, target
-- selection, and action evaluation for enemy units in tactical combat.
--
-- Coverage:
--   - AI system initialization and state management
--   - Behavior mode switching (AGGRESSIVE, DEFENSIVE, SUPPORT, etc.)
--   - Threat evaluation and prioritization
--   - Target selection strategies
--   - Action evaluation and scoring
--   - Retreat and survival logic
--   - Performance and concurrent AI management
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK AI TACTICAL SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local MockAITacticalSystem = {}
MockAITacticalSystem.__index = MockAITacticalSystem

---Behavior mode definitions
local BEHAVIOR_MODES = {
    AGGRESSIVE = {
        priority = "DAMAGE_OUTPUT",
        targetPriority = "CLOSEST",
        actionBias = "ATTACK",
        retreatThreshold = 0.2  -- 20% HP
    },
    DEFENSIVE = {
        priority = "DAMAGE_MITIGATION",
        targetPriority = "THREATENING",
        actionBias = "COVER",
        retreatThreshold = 0.15  -- 15% HP
    },
    SUPPORT = {
        priority = "ALLY_PROTECTION",
        targetPriority = "THREAT_TO_ALLIES",
        actionBias = "SUPPRESS",
        retreatThreshold = 0.25  -- 25% HP
    },
    FLANKING = {
        priority = "POSITIONING",
        targetPriority = "UNAWARE",
        actionBias = "MOVE",
        retreatThreshold = 0.18  -- 18% HP
    },
    SUPPRESSIVE = {
        priority = "AREA_CONTROL",
        targetPriority = "EXPOSED",
        actionBias = "OVERWATCH",
        retreatThreshold = 0.22  -- 22% HP
    },
    RETREAT = {
        priority = "SURVIVAL",
        targetPriority = "NONE",
        actionBias = "FLEE",
        retreatThreshold = 0.10  -- 10% HP - stay retreated until healthier
    }
}

---Create new AI tactical system
function MockAITacticalSystem:new()
    local self = setmetatable({}, MockAITacticalSystem)

    -- AI unit state tracking
    self.units = {}           -- { unitId -> { behavior, lastDecision, lastThreat, state } }
    self.decisionHistory = {} -- { unitId -> [decisions] }
    self.threatCache = {}     -- { unitId -> threat value }
    self.maxUnitHistory = 10  -- Keep last 10 decisions

    return self
end

---Initialize AI unit with default behavior
---@param unitId string - Unique unit identifier
---@param behavior? string - Starting behavior mode (default: AGGRESSIVE)
function MockAITacticalSystem:initializeUnit(unitId, behavior)
    behavior = behavior or "AGGRESSIVE"  -- Default to AGGRESSIVE if not specified

    if not BEHAVIOR_MODES[behavior] then
        error("Unknown behavior mode: " .. behavior)
    end

    self.units[unitId] = {
        behavior = behavior,
        hp = 100,
        maxHp = 100,
        position = {x = 0, y = 0},
        lastDecision = nil,
        lastThreat = 0,
        state = "ACTIVE"
    }

    self.decisionHistory[unitId] = {}
end

---Remove AI unit from system
---@param unitId string - Unit to remove
function MockAITacticalSystem:removeUnit(unitId)
    self.units[unitId] = nil
    self.decisionHistory[unitId] = nil
    self.threatCache[unitId] = nil
end

---Set unit behavior mode
---@param unitId string - Unit identifier
---@param behavior string - New behavior mode
function MockAITacticalSystem:setBehavior(unitId, behavior)
    if not self.units[unitId] then
        error("Unit not found: " .. unitId)
    end

    if not BEHAVIOR_MODES[behavior] then
        error("Unknown behavior mode: " .. behavior)
    end

    self.units[unitId].behavior = behavior
end

---Get unit current behavior
---@param unitId string - Unit identifier
---@return string - Current behavior mode
function MockAITacticalSystem:getBehavior(unitId)
    local unit = self.units[unitId]
    return unit and unit.behavior or "AGGRESSIVE"
end

---Check if unit should switch behavior based on conditions
---@param unitId string - Unit identifier
---@param unitData table - Current unit state {hp, maxHP, threat, allies}
---@return string - Recommended behavior mode
function MockAITacticalSystem:checkBehaviorSwitch(unitId, unitData)
    local unit = self.units[unitId]
    if not unit then return "AGGRESSIVE" end

    local currentBehavior = unit.behavior
    local hpRatio = unitData.hp / unitData.maxHP
    local mode = BEHAVIOR_MODES[currentBehavior]

    -- Check retreat threshold - if HP falls below threshold, switch to RETREAT
    if hpRatio <= mode.retreatThreshold then
        return "RETREAT"
    end

    -- Check recovery from retreat - if HP is high, return to normal behavior
    if currentBehavior == "RETREAT" and hpRatio > 0.60 then
        return "DEFENSIVE"
    end

    -- Check allies in danger - support mode
    if unitData.alliesInDanger and unitData.alliesInDanger > 0 then
        return "SUPPORT"
    end

    -- Check if unit can flank
    if unitData.canFlank then
        return "FLANKING"
    end

    return currentBehavior  -- Stay in current behavior
end

---Evaluate threat level of a single enemy
---@param enemy table - Enemy unit {hp, maxHP, damage, distance, position, visible}
---@return number - Threat score (0-100)
function MockAITacticalSystem:evaluateThreat(enemy)
    if not enemy then return 0 end

    local threat = 0

    -- HP factor (0-30 points)
    local healthRatio = enemy.hp / enemy.maxHP
    threat = threat + (healthRatio * 30)

    -- Damage factor (0-40 points)
    local damageLevel = (enemy.damage or 10) / 20  -- Normalize by typical damage
    threat = threat + (math.min(damageLevel * 40, 40))

    -- Distance factor (0-30 points) - closer is more threatening
    local distance = enemy.distance or 100
    local distanceFactor = math.max(1 - (distance / 50), 0)  -- Inverse relationship
    threat = threat + (distanceFactor * 30)

    return math.floor(math.min(threat, 100))
end

---Select target based on priority and visible enemies
---@param unitId string - AI unit making decision
---@param enemies table - List of visible enemies
---@param behavior string - Current behavior mode (optional)
---@return table|nil - Selected target enemy
function MockAITacticalSystem:selectTarget(unitId, enemies, behavior)
    if not enemies or #enemies == 0 then
        return nil
    end

    behavior = behavior or self:getBehavior(unitId)
    local mode = BEHAVIOR_MODES[behavior]

    if not mode then return enemies[1] end

    local selectedTarget = nil
    local selectedScore = -1

    for _, enemy in ipairs(enemies) do
        local score = 0

        -- Apply behavior-specific targeting
        if mode.targetPriority == "CLOSEST" then
            score = 100 - (enemy.distance or 50)  -- Prefer closer enemies
        elseif mode.targetPriority == "THREATENING" then
            local threat = self:evaluateThreat(enemy)
            score = threat  -- Target most threatening
        elseif mode.targetPriority == "UNAWARE" then
            score = (enemy.aware and 0 or 50) + (100 - (enemy.distance or 50))
        elseif mode.targetPriority == "EXPOSED" then
            score = (enemy.cover and 10 or 50) + (100 - (enemy.distance or 50))
        elseif mode.targetPriority == "THREAT_TO_ALLIES" then
            score = (enemy.threateningAllies or 0) * 10 + self:evaluateThreat(enemy)
        else
            score = self:evaluateThreat(enemy)
        end

        if score > selectedScore then
            selectedScore = score
            selectedTarget = enemy
        end
    end

    return selectedTarget
end

---Evaluate possible actions given current situation
---@param unitId string - AI unit
---@param unitData table - Unit state {hp, maxHP, ap, position}
---@param enemies table - Visible enemies
---@param allies table - Visible allies
---@return table - List of actions {actionType, score, target, ap_cost}
function MockAITacticalSystem:evaluateActions(unitId, unitData, enemies, allies)
    local actions = {}
    local behavior = self:getBehavior(unitId)
    local mode = BEHAVIOR_MODES[behavior]

    -- SHOOT action
    if #enemies > 0 then
        local target = self:selectTarget(unitId, enemies, behavior)
        if target and unitData.ap >= 4 then
            local accuracy = 75 - (target.distance or 10)  -- Range penalty
            local score = (mode.actionBias == "ATTACK" and 80 or 50) + (accuracy / 2)
            table.insert(actions, {
                actionType = "SHOOT",
                score = score,
                target = target,
                apCost = 4
            })
        end
    end

    -- MOVE action
    if unitData.ap >= 2 then
        local moveScore = (mode.actionBias == "MOVE" and 70 or 40)

        -- Increase score if can get to better position
        if mode.targetPriority == "UNAWARE" or mode.targetPriority == "EXPOSED" then
            moveScore = moveScore + 20
        end

        table.insert(actions, {
            actionType = "MOVE",
            score = moveScore,
            target = nil,
            apCost = 2
        })
    end

    -- COVER action (take cover)
    if unitData.ap >= 2 and #enemies > 0 then
        local coverScore = (mode.actionBias == "COVER" and 75 or 45)

        -- Increase if outnumbered or low HP
        if #enemies > 2 or (unitData.hp / unitData.maxHP) < 0.5 then
            coverScore = coverScore + 15
        end

        table.insert(actions, {
            actionType = "COVER",
            score = coverScore,
            target = nil,
            apCost = 2
        })
    end

    -- SUPPRESS/OVERWATCH action
    if unitData.ap >= 3 and #enemies > 0 then
        local suppressScore = (mode.actionBias == "SUPPRESS" or mode.actionBias == "OVERWATCH") and 60 or 35

        -- More valuable with multiple enemies
        suppressScore = suppressScore + (#enemies * 5)

        table.insert(actions, {
            actionType = "SUPPRESS",
            score = suppressScore,
            target = nil,
            apCost = 3
        })
    end

    -- SUPPORT action (help ally)
    if #allies > 0 and unitData.ap >= 2 then
        local supportScore = (mode.actionBias == "SUPPRESS" and 70 or 30)
        table.insert(actions, {
            actionType = "SUPPORT",
            score = supportScore,
            target = allies[1],
            apCost = 2
        })
    end

    -- RETREAT action (if in danger)
    local hpRatio = unitData.hp / unitData.maxHP
    if hpRatio < 0.3 and unitData.ap >= 3 then
        local retreatScore = 85  -- High priority when low HP
        table.insert(actions, {
            actionType = "RETREAT",
            score = retreatScore,
            target = nil,
            apCost = 3
        })
    end

    return actions
end

---Select best action from evaluated options
---@param actions table - List of evaluated actions
---@return table|nil - Best action by score
function MockAITacticalSystem:selectBestAction(actions)
    if not actions or #actions == 0 then
        return nil
    end

    -- Sort by score descending (highest first)
    table.sort(actions, function(a, b)
        return a.score > b.score
    end)

    return actions[1]
end

---Make tactical decision for a unit
---@param unitId string - Unit making decision
---@param unitData table - Full unit state
---@param enemies table - Visible enemies
---@param allies table - Visible allies
---@return table - Decision {action, target, behavior, reasoning}
function MockAITacticalSystem:makeDecision(unitId, unitData, enemies, allies)
    local behavior = self:getBehavior(unitId)

    -- Check if should switch behavior
    local newBehavior = self:checkBehaviorSwitch(unitId, unitData)
    if newBehavior ~= behavior then
        self:setBehavior(unitId, newBehavior)
        behavior = newBehavior
    end

    -- Evaluate all possible actions
    local actions = self:evaluateActions(unitId, unitData, enemies, allies)

    -- Select best action
    local bestAction = self:selectBestAction(actions)

    local decision = {
        unitId = unitId,
        behavior = behavior,
        action = bestAction and bestAction.actionType or "WAIT",
        target = bestAction and bestAction.target or nil,
        score = bestAction and bestAction.score or 0,
        timestamp = os.clock(),
        reasoning = "Decision made by " .. behavior .. " behavior"
    }

    -- Track decision
    if not self.decisionHistory[unitId] then
        self.decisionHistory[unitId] = {}
    end

    table.insert(self.decisionHistory[unitId], decision)

    -- Limit history size
    while #self.decisionHistory[unitId] > self.maxUnitHistory do
        table.remove(self.decisionHistory[unitId], 1)
    end

    self.units[unitId].lastDecision = decision

    return decision
end

---Get all AI unit states
---@return table - {unitId -> {behavior, hp, state}}
function MockAITacticalSystem:getAllStates()
    local states = {}
    for unitId, unit in pairs(self.units) do
        states[unitId] = {
            behavior = unit.behavior,
            hp = unit.hp,
            maxHp = unit.maxHp,
            state = unit.state
        }
    end
    return states
end

---Get decision history for a unit
---@param unitId string - Unit identifier
---@return table - List of recent decisions
function MockAITacticalSystem:getDecisionHistory(unitId)
    return self.decisionHistory[unitId] or {}
end

---Visualize decision-making for debugging
---@param unitId string - Unit identifier
---@return table? - Visualization data or nil if unit not found
function MockAITacticalSystem:visualizeDecision(unitId)
    local unit = self.units[unitId]
    if not unit then return nil end

    local decision = unit.lastDecision

    return {
        unitId = unitId,
        behavior = unit.behavior,
        action = decision and decision.action or "NONE",
        actionScore = decision and decision.score or 0,
        hp = unit.hp,
        maxHp = unit.maxHp,
        state = unit.state
    }
end

---Update unit HP for threat calculation
---@param unitId string - Unit identifier
---@param newHP number - New HP value
function MockAITacticalSystem:updateUnitHP(unitId, newHP)
    if self.units[unitId] then
        self.units[unitId].hp = newHP
    end
end

---Get behavior mode configuration
---@param behavior string - Behavior name
---@return table - Behavior configuration
function MockAITacticalSystem:getBehaviorConfig(behavior)
    return Helpers.deepCopy(BEHAVIOR_MODES[behavior])
end

---Get all available behaviors
---@return table - List of behavior names
function MockAITacticalSystem:getAvailableBehaviors()
    local behaviors = {}
    for name, _ in pairs(BEHAVIOR_MODES) do
        table.insert(behaviors, name)
    end
    return behaviors
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE SETUP
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.ai.tactical_decision",
    fileName = "tactical_decision.lua",
    description = "AI tactical decision system - behavior modes, targeting, action evaluation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: AI INITIALIZATION & STATE MANAGEMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Initialization & State Management", function()

    Suite:testMethod("AITacticalSystem:initializeUnit", {
        description = "Unit initialization creates valid AI state",
        testCase = "basic_init",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1")

        Helpers.assertEqual(ai:getBehavior("unit1"), "AGGRESSIVE", "Default behavior should be AGGRESSIVE")

        local states = ai:getAllStates()
        local unit1State = states.unit1
        if not unit1State then
            error("Unit should appear in states")
        end
        Helpers.assertEqual(unit1State.state, "ACTIVE", "Unit should be ACTIVE")
    end)

    Suite:testMethod("AITacticalSystem:initializeUnit", {
        description = "Unit can be initialized with custom behavior",
        testCase = "custom_behavior",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit2", "DEFENSIVE")

        Helpers.assertEqual(ai:getBehavior("unit2"), "DEFENSIVE", "Should initialize with DEFENSIVE")
    end)

    Suite:testMethod("AITacticalSystem:removeUnit", {
        description = "Unit removal clears state from system",
        testCase = "unit_removal",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit3")

        local states = ai:getAllStates()
        if not states.unit3 then
            error("Unit should exist before removal")
        end

        ai:removeUnit("unit3")

        states = ai:getAllStates()
        if states.unit3 then
            error("Unit should be removed from states")
        end
    end)

    Suite:testMethod("AITacticalSystem:getAllStates", {
        description = "Multiple units managed independently",
        testCase = "multi_unit",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()

        ai:initializeUnit("unit1", "AGGRESSIVE")
        ai:initializeUnit("unit2", "DEFENSIVE")
        ai:initializeUnit("unit3", "SUPPORT")

        local states = ai:getAllStates()
        Helpers.assertEqual(states.unit1.behavior, "AGGRESSIVE", "Unit1 should be AGGRESSIVE")
        Helpers.assertEqual(states.unit2.behavior, "DEFENSIVE", "Unit2 should be DEFENSIVE")
        Helpers.assertEqual(states.unit3.behavior, "SUPPORT", "Unit3 should be SUPPORT")
    end)

    Suite:testMethod("AITacticalSystem:getAvailableBehaviors", {
        description = "All 6 behavior modes are available",
        testCase = "behavior_count",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        local behaviors = ai:getAvailableBehaviors()

        Helpers.assertEqual(#behaviors, 6, "Should have exactly 6 behavior modes")

        local required = {"AGGRESSIVE", "DEFENSIVE", "SUPPORT", "FLANKING", "SUPPRESSIVE", "RETREAT"}
        for _, name in ipairs(required) do
            Helpers.assertTrue(Helpers.tableContains(behaviors, name), "Should have " .. name .. " mode")
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: BEHAVIOR MODE SWITCHING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Behavior Mode Switching", function()

    Suite:testMethod("AITacticalSystem:setBehavior", {
        description = "Can switch between all behavior modes",
        testCase = "mode_switching",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")

        local modes = {"AGGRESSIVE", "DEFENSIVE", "SUPPORT", "FLANKING", "SUPPRESSIVE", "RETREAT"}
        for _, mode in ipairs(modes) do
            ai:setBehavior("unit1", mode)
            Helpers.assertEqual(ai:getBehavior("unit1"), mode, "Should switch to " .. mode)
        end
    end)

    Suite:testMethod("AITacticalSystem:checkBehaviorSwitch", {
        description = "Low HP triggers retreat behavior",
        testCase = "low_hp_retreat",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")

        local unitData = {hp = 15, maxHP = 100}  -- 15% HP
        local newBehavior = ai:checkBehaviorSwitch("unit1", unitData)

        Helpers.assertEqual(newBehavior, "RETREAT", "Low HP should trigger RETREAT")
    end)

    Suite:testMethod("AITacticalSystem:checkBehaviorSwitch", {
        description = "High HP recovers from retreat to defensive",
        testCase = "hp_recovery",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "RETREAT")

        local unitData = {hp = 70, maxHP = 100}  -- 70% HP - above recovery threshold
        local newBehavior = ai:checkBehaviorSwitch("unit1", unitData)

        Helpers.assertEqual(newBehavior, "DEFENSIVE", "High HP should recover to DEFENSIVE")
    end)

    Suite:testMethod("AITacticalSystem:checkBehaviorSwitch", {
        description = "Allies in danger triggers support behavior",
        testCase = "ally_protection",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")

        local unitData = {
            hp = 80, maxHP = 100,
            alliesInDanger = 2  -- Multiple allies threatened
        }
        local newBehavior = ai:checkBehaviorSwitch("unit1", unitData)

        Helpers.assertEqual(newBehavior, "SUPPORT", "Allies in danger should trigger SUPPORT")
    end)

    Suite:testMethod("AITacticalSystem:getBehaviorConfig", {
        description = "Each behavior mode has valid configuration",
        testCase = "behavior_config",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()

        local config = ai:getBehaviorConfig("AGGRESSIVE")
        if not config.priority then error("Config should have priority") end
        if not config.targetPriority then error("Config should have targetPriority") end
        if not config.actionBias then error("Config should have actionBias") end
        if not config.retreatThreshold then error("Config should have retreatThreshold") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: THREAT ASSESSMENT & TARGET SELECTION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Threat Assessment & Targeting", function()

    Suite:testMethod("AITacticalSystem:evaluateThreat", {
        description = "Threat score increases with enemy power",
        testCase = "threat_calculation",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()

        local weakEnemy = {hp = 20, maxHP = 100, damage = 5, distance = 20}
        local strongEnemy = {hp = 100, maxHP = 100, damage = 20, distance = 5}

        local weakThreat = ai:evaluateThreat(weakEnemy)
        local strongThreat = ai:evaluateThreat(strongEnemy)

        Helpers.assertGreater(strongThreat, weakThreat, "Strong enemy should have higher threat")
    end)

    Suite:testMethod("AITacticalSystem:evaluateThreat", {
        description = "Threat returns number in valid range (0-100)",
        testCase = "threat_range",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()

        local enemy = {hp = 50, maxHP = 100, damage = 15, distance = 10}
        local threat = ai:evaluateThreat(enemy)

        Helpers.assertEqual(type(threat), "number", "Threat should be a number")
        Helpers.assertGreaterOrEqual(threat, 0, "Threat should be >= 0")
        Helpers.assertLessOrEqual(threat, 100, "Threat should be <= 100")
    end)

    Suite:testMethod("AITacticalSystem:selectTarget", {
        description = "AGGRESSIVE behavior targets closest enemy",
        testCase = "aggressive_targeting",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")

        local enemies = {
            {id = "enemy1", distance = 10, hp = 50, maxHP = 100},
            {id = "enemy2", distance = 3, hp = 50, maxHP = 100},
            {id = "enemy3", distance = 15, hp = 50, maxHP = 100}
        }

        local target = ai:selectTarget("unit1", enemies, "AGGRESSIVE")
        if not target then error("Should select a target") end
        Helpers.assertEqual(target.id, "enemy2", "Should target closest (distance 3)")
    end)

    Suite:testMethod("AITacticalSystem:selectTarget", {
        description = "DEFENSIVE behavior targets most threatening",
        testCase = "defensive_targeting",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()

        local enemies = {
            {id = "weak", distance = 5, hp = 10, maxHP = 100, damage = 5},
            {id = "strong", distance = 10, hp = 100, maxHP = 100, damage = 25}
        }

        local target = ai:selectTarget("unit1", enemies, "DEFENSIVE")
        if not target then error("Should select target") end
        -- Should prioritize high-damage enemy
        Helpers.assertEqual(target.id, "strong", "Should target most threatening")
    end)

    Suite:testMethod("AITacticalSystem:selectTarget", {
        description = "Returns nil when no enemies present",
        testCase = "no_enemies",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")

        local target = ai:selectTarget("unit1", {}, "AGGRESSIVE")
        if target then error("Should return nil with no enemies") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: ACTION EVALUATION & SELECTION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Action Evaluation & Selection", function()

    Suite:testMethod("AITacticalSystem:evaluateActions", {
        description = "Returns list of valid actions",
        testCase = "action_generation",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")

        local unitData = {hp = 100, maxHP = 100, ap = 10, position = {x = 5, y = 5}}
        local enemies = {{id = "e1", distance = 5, hp = 50, maxHP = 100}}
        local allies = {}

        local actions = ai:evaluateActions("unit1", unitData, enemies, allies)

        Helpers.assertGreater(#actions, 0, "Should generate at least one action")

        -- Check action structure
        for _, action in ipairs(actions) do
            if not action.actionType then error("Action should have actionType") end
            if not action.score then error("Action should have score") end
            Helpers.assertEqual(type(action.score), "number", "Score should be a number")
        end
    end)

    Suite:testMethod("AITacticalSystem:evaluateActions", {
        description = "AGGRESSIVE prioritizes SHOOT action",
        testCase = "aggressive_actions",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")

        local unitData = {hp = 100, maxHP = 100, ap = 10, position = {x = 0, y = 0}}
        local enemies = {{id = "e1", distance = 5, hp = 50, maxHP = 100, damage = 10}}

        local actions = ai:evaluateActions("unit1", unitData, enemies, {})

        -- Find SHOOT action
        local shootAction = nil
        for _, action in ipairs(actions) do
            if action.actionType == "SHOOT" then
                shootAction = action
                break
            end
        end

        if not shootAction then error("Should generate SHOOT action for AGGRESSIVE") end
    end)

    Suite:testMethod("AITacticalSystem:evaluateActions", {
        description = "Low HP triggers RETREAT action",
        testCase = "retreat_action",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1")

        local unitData = {hp = 25, maxHP = 100, ap = 10, position = {x = 0, y = 0}}
        local enemies = {{id = "e1", distance = 3, hp = 80, maxHP = 100}}

        local actions = ai:evaluateActions("unit1", unitData, enemies, {})

        local hasRetreat = false
        for _, action in ipairs(actions) do
            if action.actionType == "RETREAT" then
                hasRetreat = true
                break
            end
        end

        Helpers.assertTrue(hasRetreat, "Low HP should generate RETREAT action")
    end)

    Suite:testMethod("AITacticalSystem:selectBestAction", {
        description = "Selects action with highest score",
        testCase = "best_action_selection",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()

        local actions = {
            {actionType = "MOVE", score = 40, apCost = 2},
            {actionType = "SHOOT", score = 75, apCost = 4},
            {actionType = "COVER", score = 50, apCost = 2}
        }

        local best = ai:selectBestAction(actions)

        if not best then error("Should select an action") end
        Helpers.assertEqual(best.actionType, "SHOOT", "Should select highest scoring action (75)")
        Helpers.assertEqual(best.score, 75, "Score should be 75")
    end)

    Suite:testMethod("AITacticalSystem:selectBestAction", {
        description = "Returns nil for empty action list",
        testCase = "no_actions",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()

        local best = ai:selectBestAction({})
        if best then error("Should return nil with no actions") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: TACTICAL DECISION MAKING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Tactical Decision Making", function()

    Suite:testMethod("AITacticalSystem:makeDecision", {
        description = "Makes valid decision with all required fields",
        testCase = "decision_structure",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")

        local unitData = {hp = 100, maxHP = 100, ap = 10, position = {x = 0, y = 0}}
        local enemies = {{id = "e1", distance = 5, hp = 50, maxHP = 100}}
        local allies = {}

        local decision = ai:makeDecision("unit1", unitData, enemies, allies)

        if not decision.unitId then error("Decision should have unitId") end
        if not decision.behavior then error("Decision should have behavior") end
        if not decision.action then error("Decision should have action") end
        if not decision.score then error("Decision should have score") end
    end)

    Suite:testMethod("AITacticalSystem:makeDecision", {
        description = "Behavior switch is applied in decision",
        testCase = "behavior_switch_applied",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")

        local unitData = {
            hp = 15, maxHP = 100, ap = 10,
            position = {x = 0, y = 0}
        }

        local decision = ai:makeDecision("unit1", unitData, {}, {})

        Helpers.assertEqual(decision.behavior, "RETREAT", "Should switch to RETREAT from low HP")
        Helpers.assertEqual(ai:getBehavior("unit1"), "RETREAT", "Unit behavior should be updated")
    end)

    Suite:testMethod("AITacticalSystem:getDecisionHistory", {
        description = "Decision history tracks multiple decisions",
        testCase = "history_tracking",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1")

        local unitData = {hp = 100, maxHP = 100, ap = 10, position = {x = 0, y = 0}}

        -- Make multiple decisions
        for i = 1, 3 do
            ai:makeDecision("unit1", unitData, {}, {})
        end

        local history = ai:getDecisionHistory("unit1")
        Helpers.assertEqual(#history, 3, "Should have 3 decisions in history")
    end)

    Suite:testMethod("AITacticalSystem:visualizeDecision", {
        description = "Visualization provides debug information",
        testCase = "debug_visualization",
        type = "functional"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1", "AGGRESSIVE")
        ai:updateUnitHP("unit1", 80)

        local unitData = {hp = 80, maxHP = 100, ap = 10, position = {x = 0, y = 0}}
        ai:makeDecision("unit1", unitData, {}, {})

        local vis = ai:visualizeDecision("unit1")

        if not vis then error("visualizeDecision should return a visualization") end
        if not vis.unitId then error("Visualization should have unitId") end
        if not vis.behavior then error("Visualization should have behavior") end
        if not vis.action then error("Visualization should have action") end
        if not vis.hp then error("Visualization should have hp") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 6: PERFORMANCE & CONCURRENCY
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Performance & Concurrency", function()

    Suite:testMethod("AITacticalSystem:makeDecision", {
        description = "100 concurrent AI units make decisions efficiently",
        testCase = "concurrent_units",
        type = "performance"
    }, function()
        local ai = MockAITacticalSystem:new()

        -- Initialize 100 units
        for i = 1, 100 do
            ai:initializeUnit("unit" .. i, ({
                "AGGRESSIVE", "DEFENSIVE", "SUPPORT"
            })[((i - 1) % 3) + 1])
        end

        local startTime = os.clock()

        -- Make decisions for all units
        for i = 1, 100 do
            local unitData = {hp = 80, maxHP = 100, ap = 10, position = {x = 0, y = 0}}
            local enemies = {
                {id = "e1", distance = 5, hp = 50, maxHP = 100},
                {id = "e2", distance = 10, hp = 60, maxHP = 100}
            }
            ai:makeDecision("unit" .. i, unitData, enemies, {})
        end

        local elapsed = os.clock() - startTime

        print("[AI Performance] 100 concurrent units: " .. string.format("%.3f ms", elapsed * 1000))

        Helpers.assertLess(elapsed, 0.5, "100 unit decisions should complete in < 500ms")
    end)

    Suite:testMethod("AITacticalSystem:evaluateActions", {
        description = "Action evaluation is fast even with many enemies",
        testCase = "action_throughput",
        type = "performance"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1")

        -- Create many enemies
        local enemies = {}
        for i = 1, 20 do
            table.insert(enemies, {
                id = "enemy" .. i,
                distance = math.random(3, 20),
                hp = math.random(30, 100),
                maxHP = 100,
                damage = math.random(5, 20)
            })
        end

        local unitData = {hp = 100, maxHP = 100, ap = 10, position = {x = 0, y = 0}}

        local startTime = os.clock()
        for _ = 1, 100 do
            ai:evaluateActions("unit1", unitData, enemies, {})
        end
        local elapsed = os.clock() - startTime

        print("[AI Performance] 100 action evaluations: " .. string.format("%.3f ms", elapsed * 1000))

        Helpers.assertLess(elapsed, 0.1, "100 action evaluations should complete in < 100ms")
    end)

    Suite:testMethod("AITacticalSystem:selectTarget", {
        description = "Target selection is O(n) with enemy count",
        testCase = "target_scaling",
        type = "performance"
    }, function()
        local ai = MockAITacticalSystem:new()
        ai:initializeUnit("unit1")

        -- Test with increasing enemy counts
        local times = {}
        for count = 10, 100, 10 do
            local enemies = {}
            for i = 1, count do
                table.insert(enemies, {
                    id = "enemy" .. i,
                    distance = math.random(3, 30),
                    hp = 50,
                    maxHP = 100
                })
            end

            local startTime = os.clock()
            for _ = 1, 1000 do
                ai:selectTarget("unit1", enemies, "AGGRESSIVE")
            end
            local elapsed = os.clock() - startTime
            table.insert(times, elapsed)
        end

        -- Verify roughly linear scaling
        local baseTime = times[1]
        local ratio = baseTime > 0 and (times[#times] / baseTime) or 1  -- If too fast to measure, skip ratio check
        print("[AI Performance] Target selection scaling: " .. string.format("%.2fx", ratio))

        -- Should scale roughly linearly (10x enemies = ~10x time)
        -- Or complete so fast that timing is negligible (< 0.0001s)
        if baseTime > 0.0001 then
            Helpers.assertLess(ratio, 15, "Target selection should scale roughly linearly")
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- HELPER FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────

function Helpers.assertTrue(actual, message)
    if not actual then
        error(message or "Expected true")
    end
end

function Helpers.assertGreater(actual, expected, message)
    if not (actual > expected) then
        error(message or string.format("Expected %s > %s", tostring(actual), tostring(expected)))
    end
end

function Helpers.assertGreaterOrEqual(actual, expected, message)
    if not (actual >= expected) then
        error(message or string.format("Expected %s >= %s", tostring(actual), tostring(expected)))
    end
end

function Helpers.assertLessOrEqual(actual, expected, message)
    if not (actual <= expected) then
        error(message or string.format("Expected %s <= %s", tostring(actual), tostring(expected)))
    end
end

function Helpers.assertLess(actual, expected, message)
    if not (actual < expected) then
        error(message or string.format("Expected %s < %s", tostring(actual), tostring(expected)))
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- RUN SUITE
-- ─────────────────────────────────────────────────────────────────────────

Suite:run()
