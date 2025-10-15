---AI Decision System - Tactical Combat AI
---
---Implements tactical AI decision-making for enemy units in combat. Evaluates
---threats, prioritizes targets, selects actions, and coordinates squad behavior.
---Supports multiple behavior modes with dynamic switching based on unit state.
---
---AI Behavior Modes:
---  - AGGRESSIVE: Seek and destroy, prioritize closest enemies
---  - DEFENSIVE: Hold position, protect objectives, overwatch
---  - SUPPORT: Assist allies, use utility abilities, heal/buff
---  - FLANKING: Maneuver for advantageous positions, flank enemies
---  - SUPPRESSIVE: Pin down enemies with suppression fire
---  - RETREAT: Withdraw to safety, regroup, escape
---
---Decision Process:
---  1. Threat Assessment: Evaluate nearby enemies and danger level
---  2. Target Prioritization: Rank enemies by threat, distance, health
---  3. Action Selection: Choose best action (move, shoot, ability, overwatch)
---  4. Behavior Evaluation: Switch behavior if HP/morale changes
---  5. Execution: Perform selected action
---
---Target Priority Factors:
---  - Distance: Closer targets prioritized
---  - Threat Level: Dangerous weapons prioritized
---  - Health: Wounded targets easier to finish
---  - Cover: Exposed targets prioritized
---  - Line of Sight: Visible targets only
---
---Key Exports:
---  - DecisionSystem.new(battlefield): Creates AI decision system
---  - evaluateTurn(unit): Determines and executes AI action
---  - selectTarget(unit, enemies): Chooses best target
---  - selectAction(unit, target): Picks best action for situation
---  - switchBehavior(unit): Changes behavior based on state
---
---Dependencies:
---  - battlescape.battlefield: Battlefield state and unit access
---  - battlescape.combat.unit: Unit properties and actions
---  - ai.pathfinding: Movement path calculation
---  - battlescape.combat.action_system: Action execution
---
---@module ai.tactical.decision_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local DecisionSystem = require("ai.tactical.decision_system")
---  local ai = DecisionSystem.new(battlefield)
---  for _, enemyUnit in ipairs(enemyTeam.units) do
---    ai:evaluateTurn(enemyUnit)  -- AI takes its turn
---  end
---
---@see battlescape.combat.unit For unit implementation
---@see battlescape.battlefield For battlefield state

local AIDecisionSystem = {}

-- Configuration
local CONFIG = {
    -- Behavior Modes
    BEHAVIORS = {
        AGGRESSIVE = {
            name = "Aggressive",
            description = "Rush forward to engage enemies",
            preferredDistance = 5,          -- Prefers close combat
            retreatThreshold = 20,          -- Only retreats below 20% HP
            targetPriority = "CLOSEST",     -- Targets closest enemy
            useCoverChance = 30,            -- 30% chance to use cover
            overwatchChance = 10,           -- 10% chance to use overwatch
        },
        DEFENSIVE = {
            name = "Defensive",
            description = "Find cover and hold position",
            preferredDistance = 10,         -- Prefers medium range
            retreatThreshold = 50,          -- Retreats below 50% HP
            targetPriority = "CLOSEST",     -- Targets closest threat
            useCoverChance = 90,            -- 90% chance to use cover
            overwatchChance = 60,           -- 60% chance to use overwatch
        },
        SUPPORT = {
            name = "Support",
            description = "Heal and buff allies",
            preferredDistance = 8,          -- Stays behind front line
            retreatThreshold = 40,          -- Retreats below 40% HP
            targetPriority = "WEAKEST_ALLY", -- Helps weakest ally
            useCoverChance = 70,            -- 70% chance to use cover
            overwatchChance = 20,           -- 20% chance to use overwatch
        },
        FLANKING = {
            name = "Flanking",
            description = "Position for flank attacks",
            preferredDistance = 8,          -- Medium range for flanking
            retreatThreshold = 35,          -- Retreats below 35% HP
            targetPriority = "FLANKABLE",   -- Targets units it can flank
            useCoverChance = 60,            -- 60% chance to use cover
            overwatchChance = 30,           -- 30% chance to use overwatch
        },
        SUPPRESSIVE = {
            name = "Suppressive",
            description = "Pin down enemies with heavy fire",
            preferredDistance = 12,         -- Long range suppression
            retreatThreshold = 40,          -- Retreats below 40% HP
            targetPriority = "MOST_DANGEROUS", -- Targets biggest threat
            useCoverChance = 80,            -- 80% chance to use cover
            overwatchChance = 50,           -- 50% chance to use overwatch
        },
        RETREAT = {
            name = "Retreat",
            description = "Fall back when hurt",
            preferredDistance = 20,         -- Maximum distance
            retreatThreshold = 100,         -- Always retreating
            targetPriority = "NONE",        -- No targeting, just retreat
            useCoverChance = 100,           -- 100% use cover while retreating
            overwatchChance = 0,            -- No overwatch while retreating
        },
    },
    
    -- Target Priority Weights
    THREAT_WEIGHTS = {
        DISTANCE = 0.4,         -- 40% weight on distance
        DAMAGE = 0.3,           -- 30% weight on potential damage
        HP = 0.2,               -- 20% weight on target HP
        MORALE = 0.1,           -- 10% weight on target morale
    },
    
    -- Action Scores
    ACTION_SCORES = {
        SHOOT_VISIBLE = 80,     -- High priority to shoot visible enemies
        MOVE_TO_COVER = 60,     -- Medium-high priority for cover
        MOVE_TO_FLANK = 55,     -- Medium priority for flanking
        USE_ABILITY = 70,       -- High priority for abilities
        OVERWATCH = 50,         -- Medium priority for overwatch
        RETREAT = 90,           -- Very high priority when retreating
        HEAL_ALLY = 85,         -- Very high priority for healing
    },
}

-- Unit AI state
-- Format: aiState[unitId] = { behavior, currentTarget, lastAction }
local aiState = {}

--[[
    Initialize AI for a unit
    
    @param unitId: Unit identifier
    @param behavior: Initial behavior mode (default AGGRESSIVE)
]]
function AIDecisionSystem.initializeUnit(unitId, behavior)
    aiState[unitId] = {
        behavior = behavior or "AGGRESSIVE",
        currentTarget = nil,
        lastAction = nil,
    }
    print(string.format("[AIDecisionSystem] Initialized AI for unit %s with %s behavior",
        tostring(unitId), behavior or "AGGRESSIVE"))
end

--[[
    Remove unit from AI system
    
    @param unitId: Unit identifier
]]
function AIDecisionSystem.removeUnit(unitId)
    aiState[unitId] = nil
    print(string.format("[AIDecisionSystem] Removed unit %s from AI system", tostring(unitId)))
end

--[[
    Set AI behavior for a unit
    
    @param unitId: Unit identifier
    @param behavior: Behavior mode string
]]
function AIDecisionSystem.setBehavior(unitId, behavior)
    if not aiState[unitId] then
        AIDecisionSystem.initializeUnit(unitId)
    end
    
    aiState[unitId].behavior = behavior
    print(string.format("[AIDecisionSystem] Unit %s behavior set to %s", tostring(unitId), behavior))
end

--[[
    Get AI behavior for a unit
    
    @param unitId: Unit identifier
    @return behavior: Behavior mode string
]]
function AIDecisionSystem.getBehavior(unitId)
    if not aiState[unitId] then
        AIDecisionSystem.initializeUnit(unitId)
    end
    return aiState[unitId].behavior
end

--[[
    Evaluate threat level of a target
    
    @param targetUnit: Target unit data { hp, maxHP, damage, distance, morale }
    @return threatScore: 0-100
]]
function AIDecisionSystem.evaluateThreat(targetUnit)
    local distanceScore = math.max(0, 100 - (targetUnit.distance * 5))  -- Closer = higher threat
    local damageScore = math.min(100, targetUnit.damage or 50)           -- More damage = higher threat
    local hpScore = (targetUnit.hp / targetUnit.maxHP) * 100             -- More HP = higher threat
    local moraleScore = targetUnit.morale or 50                          -- Higher morale = higher threat
    
    local totalThreat = (distanceScore * CONFIG.THREAT_WEIGHTS.DISTANCE) +
                        (damageScore * CONFIG.THREAT_WEIGHTS.DAMAGE) +
                        (hpScore * CONFIG.THREAT_WEIGHTS.HP) +
                        (moraleScore * CONFIG.THREAT_WEIGHTS.MORALE)
    
    return totalThreat
end

--[[
    Select best target based on behavior and priority
    
    @param unitId: AI unit identifier
    @param visibleEnemies: Table of visible enemy units
    @param behaviorMode: Behavior mode (optional, uses unit's current behavior)
    @return targetUnit: Best target or nil
]]
function AIDecisionSystem.selectTarget(unitId, visibleEnemies, behaviorMode)
    if not aiState[unitId] then
        AIDecisionSystem.initializeUnit(unitId)
    end
    
    behaviorMode = behaviorMode or aiState[unitId].behavior
    local behaviorData = CONFIG.BEHAVIORS[behaviorMode]
    
    if not behaviorData or #visibleEnemies == 0 then
        return nil
    end
    
    local priority = behaviorData.targetPriority
    
    -- Sort by priority
    if priority == "CLOSEST" then
        table.sort(visibleEnemies, function(a, b) return a.distance < b.distance end)
        return visibleEnemies[1]
    elseif priority == "WEAKEST" then
        table.sort(visibleEnemies, function(a, b) return a.hp < b.hp end)
        return visibleEnemies[1]
    elseif priority == "MOST_DANGEROUS" then
        local bestTarget = nil
        local highestThreat = 0
        for _, enemy in ipairs(visibleEnemies) do
            local threat = AIDecisionSystem.evaluateThreat(enemy)
            if threat > highestThreat then
                highestThreat = threat
                bestTarget = enemy
            end
        end
        return bestTarget
    elseif priority == "FLANKABLE" then
        -- Find unit that can be flanked (simplified - just returns closest for now)
        table.sort(visibleEnemies, function(a, b) return a.distance < b.distance end)
        return visibleEnemies[1]
    end
    
    return visibleEnemies[1]  -- Default: first visible enemy
end

--[[
    Evaluate possible actions for AI unit
    
    Returns scored list of possible actions
    
    @param unitId: AI unit identifier
    @param unitData: Unit data { hp, maxHP, ap, position, etc. }
    @param visibleEnemies: Table of visible enemies
    @param visibleAllies: Table of visible allies
    @return actions: Table of { actionType, score, target, details }
]]
function AIDecisionSystem.evaluateOptions(unitId, unitData, visibleEnemies, visibleAllies)
    if not aiState[unitId] then
        AIDecisionSystem.initializeUnit(unitId)
    end
    
    local behavior = aiState[unitId].behavior
    local behaviorData = CONFIG.BEHAVIORS[behavior]
    local actions = {}
    
    -- Check if should retreat
    local hpPercent = (unitData.hp / unitData.maxHP) * 100
    if hpPercent < behaviorData.retreatThreshold then
        table.insert(actions, {
            actionType = "RETREAT",
            score = CONFIG.ACTION_SCORES.RETREAT,
            target = nil,
            details = "HP below retreat threshold",
        })
    end
    
    -- Evaluate shooting visible enemies
    if #visibleEnemies > 0 then
        local target = AIDecisionSystem.selectTarget(unitId, visibleEnemies, behavior)
        if target then
            table.insert(actions, {
                actionType = "SHOOT",
                score = CONFIG.ACTION_SCORES.SHOOT_VISIBLE,
                target = target,
                details = "Shoot visible enemy",
            })
        end
    end
    
    -- Evaluate using cover
    local coverRoll = math.random(1, 100)
    if coverRoll <= behaviorData.useCoverChance then
        table.insert(actions, {
            actionType = "MOVE_TO_COVER",
            score = CONFIG.ACTION_SCORES.MOVE_TO_COVER,
            target = nil,
            details = "Move to cover position",
        })
    end
    
    -- Evaluate overwatch
    local overwatchRoll = math.random(1, 100)
    if overwatchRoll <= behaviorData.overwatchChance then
        table.insert(actions, {
            actionType = "OVERWATCH",
            score = CONFIG.ACTION_SCORES.OVERWATCH,
            target = nil,
            details = "Enter overwatch mode",
        })
    end
    
    -- Support behavior: evaluate healing
    if behavior == "SUPPORT" and #visibleAllies > 0 then
        for _, ally in ipairs(visibleAllies) do
            if ally.hp < ally.maxHP * 0.7 then  -- Ally below 70% HP
                table.insert(actions, {
                    actionType = "HEAL_ALLY",
                    score = CONFIG.ACTION_SCORES.HEAL_ALLY,
                    target = ally,
                    details = "Heal wounded ally",
                })
                break  -- Only one heal action
            end
        end
    end
    
    -- Sort by score
    table.sort(actions, function(a, b) return a.score > b.score end)
    
    return actions
end

--[[
    Select best action from evaluated options
    
    @param actions: Table of evaluated actions
    @return bestAction: Action table or nil
]]
function AIDecisionSystem.selectBestAction(actions)
    if #actions == 0 then
        return nil
    end
    
    -- Return highest scored action
    return actions[1]
end

--[[
    Check if AI should switch behavior dynamically
    
    @param unitId: AI unit identifier
    @param unitData: Unit data
    @return newBehavior: String or nil (if no change)
]]
function AIDecisionSystem.checkBehaviorSwitch(unitId, unitData)
    local hpPercent = (unitData.hp / unitData.maxHP) * 100
    local currentBehavior = AIDecisionSystem.getBehavior(unitId)
    
    -- Auto-switch to retreat if critically injured
    if hpPercent < 25 and currentBehavior ~= "RETREAT" then
        print(string.format("[AIDecisionSystem] Unit %s auto-switching to RETREAT behavior (HP=%d%%)",
            tostring(unitId), hpPercent))
        return "RETREAT"
    end
    
    -- Switch from retreat if healed
    if hpPercent > 60 and currentBehavior == "RETREAT" then
        print(string.format("[AIDecisionSystem] Unit %s recovering from RETREAT to DEFENSIVE behavior",
            tostring(unitId)))
        return "DEFENSIVE"
    end
    
    return nil  -- No behavior change
end

--[[
    Visualize AI decision for debugging
    
    @param unitId: AI unit identifier
    @param actions: Evaluated actions
    @return visualization data
]]
function AIDecisionSystem.visualizeDecision(unitId, actions)
    local behavior = AIDecisionSystem.getBehavior(unitId)
    local behaviorData = CONFIG.BEHAVIORS[behavior]
    local bestAction = AIDecisionSystem.selectBestAction(actions)
    
    return {
        unitId = unitId,
        behavior = behavior,
        behaviorDescription = behaviorData.description,
        actionCount = #actions,
        bestAction = bestAction,
        allActions = actions,
    }
end

--[[
    Get all AI state (for debugging)
    
    @return table of all AI states
]]
function AIDecisionSystem.getAllAIStates()
    return aiState
end

return AIDecisionSystem






















