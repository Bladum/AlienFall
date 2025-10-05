--- InterceptionAI.lua
-- AI system for interception combat
-- Evaluates craft maneuvers, weapon fire, and mission objectives

local class = require 'lib.Middleclass'
local RngService = require 'engine.rng'

local InterceptionAI = class("InterceptionAI")

--- AI decision factors
InterceptionAI.FACTORS = {
    MISSION_SUCCESS = "mission_success",
    CRAFT_SURVIVAL = "craft_survival",
    TARGET_ELIMINATION = "target_elimination",
    POSITIONING = "positioning",
    ENERGY_CONSERVATION = "energy_conservation"
}

function InterceptionAI:initialize(missionId, craftIds)
    self.missionId = missionId
    self.craftIds = craftIds or {}
    self.rng = RngService:getScope("interception:" .. missionId)

    -- Load AI weights from config
    self:_loadWeights()
end

function InterceptionAI:_loadWeights()
    local success, TomlLoader = pcall(require, "core.util.toml_loader")
    if success and TomlLoader then
        self.weights = TomlLoader.load("data/ai/weights.toml")
    end
    if not self.weights then
        self.weights = {
            interception = {
                mission_success = 0.4,
                craft_survival = 0.3,
                target_elimination = 0.2,
                positioning = 0.05,
                energy_conservation = 0.05
            }
        }
    end
end

--- Evaluate actions for all alien crafts
-- @param interceptionService The interception service instance
-- @return table of actions keyed by craftId
function InterceptionAI:evaluateActions(interceptionService)
    local actions = {}

    for _, craftId in ipairs(self.craftIds) do
        local craft = interceptionService:getCraft(craftId)
        if craft and craft.owner == "alien" then
            actions[craftId] = self:_evaluateCraftActions(craft, interceptionService)
        end
    end

    return actions
end

function InterceptionAI:_evaluateCraftActions(craft, interceptionService)
    local possibleActions = self:_generatePossibleActions(craft, interceptionService)
    local bestAction = nil
    local bestScore = -math.huge

    for _, action in ipairs(possibleActions) do
        local score = self:_scoreAction(action, craft, interceptionService)
        if score > bestScore then
            bestScore = score
            bestAction = action
        end
    end

    return bestAction
end

function InterceptionAI:_generatePossibleActions(craft, interceptionService)
    local actions = {}

    -- Movement actions
    local movementTargets = interceptionService:getValidMoves(craft.position)
    for _, targetPos in ipairs(movementTargets) do
        table.insert(actions, {
            type = "move",
            craftId = craft.id,
            fromPosition = craft.position,
            toPosition = targetPos
        })
    end

    -- Attack actions
    local attackTargets = interceptionService:getValidTargets(craft.position)
    for _, target in ipairs(attackTargets) do
        for weaponIndex = 1, #craft.weapons do
            table.insert(actions, {
                type = "attack",
                craftId = craft.id,
                fromPosition = craft.position,
                targetPosition = target.position,
                weaponIndex = weaponIndex
            })
        end
    end

    -- Hold position (do nothing)
    table.insert(actions, {
        type = "hold",
        craftId = craft.id,
        position = craft.position
    })

    return actions
end

function InterceptionAI:_scoreAction(action, craft, interceptionService)
    local score = 0

    -- Mission success factor
    score = score + self.weights.interception.mission_success * self:_scoreMissionSuccess(action, interceptionService)

    -- Craft survival factor
    score = score + self.weights.interception.craft_survival * self:_scoreSurvival(action, craft, interceptionService)

    -- Target elimination factor
    score = score + self.weights.interception.target_elimination * self:_scoreTargetElimination(action, interceptionService)

    -- Positioning factor
    score = score + self.weights.interception.positioning * self:_scorePositioning(action, craft, interceptionService)

    -- Energy conservation factor
    score = score + self.weights.interception.energy_conservation * self:_scoreEnergy(action, craft)

    return score
end

function InterceptionAI:_scoreMissionSuccess(action, interceptionService)
    -- Prefer actions that advance toward mission objectives
    -- For now, prioritize attacking player crafts
    if action.type == "attack" then
        local target = interceptionService:getCraftAt(action.targetPosition)
        if target and target.owner == "player" then
            return 1.0
        end
    elseif action.type == "move" then
        -- Moving closer to player positions
        local fromCol = interceptionService:getColumn(action.fromPosition)
        local toCol = interceptionService:getColumn(action.toPosition)
        if toCol < fromCol then -- Moving left toward player
            return 0.7
        end
    end
    return 0.0
end

function InterceptionAI:_scoreSurvival(action, craft, interceptionService)
    -- Avoid actions that put craft at risk
    if action.type == "attack" then
        local target = interceptionService:getCraftAt(action.targetPosition)
        if target and target.owner == "player" then
            -- Check if target can retaliate
            local retaliationRisk = interceptionService:calculateRetaliationRisk(action.targetPosition, craft.position)
            return 1.0 - retaliationRisk
        end
    end
    return 1.0 -- Safe actions
end

function InterceptionAI:_scoreTargetElimination(action, interceptionService)
    if action.type == "attack" then
        local target = interceptionService:getCraftAt(action.targetPosition)
        if target and target.owner == "player" then
            -- Higher score for damaging key targets
            local damage = interceptionService:calculateExpectedDamage(action, craft)
            return damage / 100.0 -- Normalize to 0-1
        end
    end
    return 0.0
end

function InterceptionAI:_scorePositioning(action, craft, interceptionService)
    if action.type == "move" then
        -- Prefer positions with better tactical advantage
        local advantage = interceptionService:calculateTacticalAdvantage(action.toPosition)
        return advantage
    end
    return 0.5
end

function InterceptionAI:_scoreEnergy(action, craft)
    -- Prefer actions that conserve energy
    local energyCost = self:_calculateEnergyCost(action, craft)
    return 1.0 - (energyCost / craft.maxEnergy)
end

function InterceptionAI:_calculateEnergyCost(action, craft)
    -- Placeholder energy costs
    if action.type == "attack" then
        return 20
    elseif action.type == "move" then
        return 10
    else
        return 0
    end
end

return InterceptionAI