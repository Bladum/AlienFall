--- Battlescape AI System
-- Implements utility-based AI for tactical unit behavior
--
-- @classmod battlescape.BattlescapeAI

-- GROK: BattlescapeAI manages AI decision-making for enemy units using utility scoring
-- GROK: Key methods: evaluateActions(), selectBestAction(), updateTacticalAwareness()
-- GROK: Integrates with ActionSystem, CombatSystem, and unit personalities
-- GROK: Uses deterministic seeded randomness for reproducible behavior

local class = require 'lib.Middleclass'

--- BattlescapeAI class
-- @type BattlescapeAI
BattlescapeAI = class('BattlescapeAI')

--- AI personality types
-- @field AGGRESSIVE High offensive weighting, accepts risk for damage
-- @field CAUTIOUS Prioritizes self-preservation and defense
-- @field BALANCED Moderate risk tolerance, flexible adaptation
-- @field SNIPER Patient, long-range focused behavior
-- @field BERSERKER Reckless close-combat specialization
-- @field SUPPORT Team coordination and utility focus
BattlescapeAI.static.PERSONALITIES = {
    AGGRESSIVE = "aggressive",
    CAUTIOUS = "cautious",
    BALANCED = "balanced",
    SNIPER = "sniper",
    BERSERKER = "berserker",
    SUPPORT = "support"
}

--- Utility factors for decision scoring
-- @field SURVIVAL Self-preservation and risk assessment
-- @field LETHALITY Damage potential and target vulnerability
-- @field POSITIONING Tactical positioning and terrain advantage
-- @field OBJECTIVES Mission goals and strategic priorities
-- @field COORDINATION Team support and group tactics
BattlescapeAI.static.UTILITY_FACTORS = {
    SURVIVAL = "survival",
    LETHALITY = "lethality",
    POSITIONING = "positioning",
    OBJECTIVES = "objectives",
    COORDINATION = "coordination"
}

--- Create a new BattlescapeAI instance
-- @param battleState Current battle state
-- @param seed Random seed for deterministic behavior
-- @return BattlescapeAI instance
function BattlescapeAI:initialize(battleState, seed)
    self.battleState = battleState
    self.seed = seed or os.time()
    self.rng = love.math.newRandomGenerator(self.seed)

    -- AI state tracking
    self.threatMap = {} -- Track known enemy positions
    self.lastUpdate = 0
    self.decisionHistory = {} -- For telemetry and debugging

    -- Load personality configurations
    self.personalityWeights = self:loadPersonalityWeights()

    -- Tactical awareness
    self.tacticalAwareness = {
        visibleEnemies = {},
        recentActions = {},
        groupPositions = {},
        objectivePriorities = {}
    }
end

--- Load personality weight configurations
-- @return table Personality weight tables
function BattlescapeAI:loadPersonalityWeights()
    -- Default personality configurations
    -- In production, these would be loaded from TOML files
    return {
        [self.PERSONALITIES.AGGRESSIVE] = {
            [self.UTILITY_FACTORS.SURVIVAL] = 0.3,
            [self.UTILITY_FACTORS.LETHALITY] = 0.4,
            [self.UTILITY_FACTORS.POSITIONING] = 0.1,
            [self.UTILITY_FACTORS.OBJECTIVES] = 0.1,
            [self.UTILITY_FACTORS.COORDINATION] = 0.1,
            riskTolerance = 0.7,
            aggressionBias = 0.8
        },
        [self.PERSONALITIES.CAUTIOUS] = {
            [self.UTILITY_FACTORS.SURVIVAL] = 0.5,
            [self.UTILITY_FACTORS.LETHALITY] = 0.2,
            [self.UTILITY_FACTORS.POSITIONING] = 0.2,
            [self.UTILITY_FACTORS.OBJECTIVES] = 0.05,
            [self.UTILITY_FACTORS.COORDINATION] = 0.05,
            riskTolerance = 0.2,
            aggressionBias = 0.1
        },
        [self.PERSONALITIES.BALANCED] = {
            [self.UTILITY_FACTORS.SURVIVAL] = 0.25,
            [self.UTILITY_FACTORS.LETHALITY] = 0.25,
            [self.UTILITY_FACTORS.POSITIONING] = 0.2,
            [self.UTILITY_FACTORS.OBJECTIVES] = 0.15,
            [self.UTILITY_FACTORS.COORDINATION] = 0.15,
            riskTolerance = 0.4,
            aggressionBias = 0.4
        },
        [self.PERSONALITIES.SNIPER] = {
            [self.UTILITY_FACTORS.SURVIVAL] = 0.4,
            [self.UTILITY_FACTORS.LETHALITY] = 0.3,
            [self.UTILITY_FACTORS.POSITIONING] = 0.25,
            [self.UTILITY_FACTORS.OBJECTIVES] = 0.03,
            [self.UTILITY_FACTORS.COORDINATION] = 0.02,
            riskTolerance = 0.3,
            aggressionBias = 0.2,
            preferredRange = "long"
        },
        [self.PERSONALITIES.BERSERKER] = {
            [self.UTILITY_FACTORS.SURVIVAL] = 0.1,
            [self.UTILITY_FACTORS.LETHALITY] = 0.5,
            [self.UTILITY_FACTORS.POSITIONING] = 0.1,
            [self.UTILITY_FACTORS.OBJECTIVES] = 0.2,
            [self.UTILITY_FACTORS.COORDINATION] = 0.1,
            riskTolerance = 0.9,
            aggressionBias = 0.9,
            preferredRange = "close"
        },
        [self.PERSONALITIES.SUPPORT] = {
            [self.UTILITY_FACTORS.SURVIVAL] = 0.3,
            [self.UTILITY_FACTORS.LETHALITY] = 0.1,
            [self.UTILITY_FACTORS.POSITIONING] = 0.2,
            [self.UTILITY_FACTORS.OBJECTIVES] = 0.1,
            [self.UTILITY_FACTORS.COORDINATION] = 0.3,
            riskTolerance = 0.4,
            aggressionBias = 0.2
        }
    }
end

--- Update AI state and tactical awareness
-- @param dt Time delta
function BattlescapeAI:update(dt)
    self.lastUpdate = self.lastUpdate + dt

    -- Update tactical awareness periodically
    if self.lastUpdate >= 0.5 then -- Update every 0.5 seconds
        self:updateTacticalAwareness()
        self.lastUpdate = 0
    end
end

--- Update tactical awareness of the battlefield
function BattlescapeAI:updateTacticalAwareness()
    local allUnits = self.battleState:getAllUnits()

    -- Clear previous awareness data
    self.tacticalAwareness.visibleEnemies = {}
    self.tacticalAwareness.groupPositions = {}

    -- Update visible enemies and group positions
    for _, unit in ipairs(allUnits) do
        if unit:getFaction() ~= "player" then
            self:updateUnitAwareness(unit)
        end
    end

    -- Update objective priorities
    self:updateObjectivePriorities()
end

--- Update awareness for a specific unit
-- @param unit The AI unit to update awareness for
function BattlescapeAI:updateUnitAwareness(unit)
    local unitPos = unit:getPosition()
    local visibleEnemies = {}

    -- Find visible enemies
    local allUnits = self.battleState:getAllUnits()
    for _, otherUnit in ipairs(allUnits) do
        if otherUnit:getFaction() == "player" and otherUnit:isAlive() then
            if self:hasLineOfSight(unitPos, otherUnit:getPosition()) then
                table.insert(visibleEnemies, {
                    unit = otherUnit,
                    distance = self:calculateDistance(unitPos, otherUnit:getPosition()),
                    threat = self:calculateThreatLevel(otherUnit)
                })
            end
        end
    end

    -- Store awareness data
    self.tacticalAwareness.visibleEnemies[unit:getId()] = visibleEnemies

    -- Update group positioning
    local groupId = unit:getGroupId() or unit:getId()
    if not self.tacticalAwareness.groupPositions[groupId] then
        self.tacticalAwareness.groupPositions[groupId] = {}
    end
    table.insert(self.tacticalAwareness.groupPositions[groupId], unitPos)
end

--- Update objective priorities based on mission state
function BattlescapeAI:updateObjectivePriorities()
    local objectives = self.battleState:getMissionObjectives()
    self.tacticalAwareness.objectivePriorities = {}

    for _, objective in ipairs(objectives:getObjectives()) do
        if objective.state == objectives.OBJECTIVE_STATES.INCOMPLETE then
            local priority = 1.0
            if objective.type == objectives.OBJECTIVE_TYPES.PRIMARY then
                priority = 2.0
            elseif objective.type == objectives.OBJECTIVE_TYPES.SECONDARY then
                priority = 1.5
            end
            self.tacticalAwareness.objectivePriorities[objective.id] = priority
        end
    end
end

--- Check if there's line of sight between two positions
-- @param from Starting position
-- @param to Target position
-- @return boolean Whether line of sight exists
function BattlescapeAI:hasLineOfSight(from, to)
    -- Simplified line of sight check - in production would use proper raycasting
    local map = self.battleState:getMap()
    return map:hasClearLine(from.x, from.y, to.x, to.y)
end

--- Calculate distance between two positions
-- @param pos1 First position
-- @param pos2 Second position
-- @return number Distance
function BattlescapeAI:calculateDistance(pos1, pos2)
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    return math.sqrt(dx * dx + dy * dy)
end

--- Calculate threat level of a unit
-- @param unit The unit to assess
-- @return number Threat level (0-1)
function BattlescapeAI:calculateThreatLevel(unit)
    local threat = 0.5 -- Base threat

    -- Weapon threat
    if unit:getWeapon() then
        local weapon = unit:getWeapon()
        threat = threat + weapon:getDamage() * 0.1
        threat = threat + weapon:getAccuracy() * 0.05
    end

    -- Health factor
    local healthRatio = unit:getHealth() / unit:getMaxHealth()
    threat = threat * (0.5 + healthRatio * 0.5)

    -- Position factor (exposed units are more threatening)
    local cover = self:getCoverAtPosition(unit:getPosition())
    threat = threat * (1.0 + (1.0 - cover) * 0.3)

    return math.min(1.0, math.max(0.0, threat))
end

--- Get cover value at a position
-- @param position Position to check
-- @return number Cover value (0-1, where 1 is full cover)
function BattlescapeAI:getCoverAtPosition(position)
    local map = self.battleState:getMap()
    local tile = map:getTile(position.x, position.y)
    return tile and tile:getCover() or 0
end

--- Evaluate and select best action for a unit
-- @param unit The unit to decide for
-- @return table Best action data
function BattlescapeAI:selectBestAction(unit)
    local actions = self:generatePossibleActions(unit)
    local scoredActions = {}

    -- Score each action
    for _, action in ipairs(actions) do
        local score = self:scoreAction(unit, action)
        table.insert(scoredActions, {
            action = action,
            score = score,
            factors = self.lastScoringFactors -- For debugging
        })
    end

    -- Sort by score (highest first)
    table.sort(scoredActions, function(a, b) return a.score > b.score end)

    -- Select best action (with some randomness for tie-breaking)
    local bestAction = scoredActions[1]
    if bestAction then
        -- Log decision for telemetry
        self:logDecision(unit, bestAction)

        return bestAction.action
    end

    return nil
end

--- Generate possible actions for a unit
-- @param unit The unit
-- @return table List of possible actions
function BattlescapeAI:generatePossibleActions(unit)
    local actions = {}
    local unitPos = unit:getPosition()
    local personality = unit:getPersonality() or self.PERSONALITIES.BALANCED
    local actionSystem = self.battleState:getActionSystem()

    -- Movement actions
    local moveActions = self:generateMovementActions(unit)
    for _, action in ipairs(moveActions) do
        table.insert(actions, action)
    end

    -- Attack actions
    local attackActions = self:generateAttackActions(unit)
    for _, action in ipairs(attackActions) do
        table.insert(actions, action)
    end

    -- Special actions based on personality
    if personality == self.PERSONALITIES.SUPPORT then
        local supportActions = self:generateSupportActions(unit)
        for _, action in ipairs(supportActions) do
            table.insert(actions, action)
        end
    end

    -- Overwatch/defensive actions for cautious units
    if personality == self.PERSONALITIES.CAUTIOUS or personality == self.PERSONALITIES.SNIPER then
        table.insert(actions, {
            type = "overwatch",
            position = unitPos,
            priority = 0.7
        })
    end

    return actions
end

--- Generate movement actions
-- @param unit The unit
-- @return table Movement actions
function BattlescapeAI:generateMovementActions(unit)
    local actions = {}
    local unitPos = unit:getPosition()
    local map = self.battleState:getMap()
    local personality = unit:getPersonality() or self.PERSONALITIES.BALANCED

    -- Generate moves to nearby positions
    local range = 3 -- Base movement range
    if personality == self.PERSONALITIES.CAUTIOUS then
        range = 2
    elseif personality == self.PERSONALITIES.AGGRESSIVE then
        range = 4
    end

    for dx = -range, range do
        for dy = -range, range do
            if dx ~= 0 or dy ~= 0 then
                local newX = unitPos.x + dx
                local newY = unitPos.y + dy

                if map:isValidPosition(newX, newY) and map:getTile(newX, newY):isWalkable() then
                    table.insert(actions, {
                        type = "move",
                        from = unitPos,
                        to = {x = newX, y = newY},
                        distance = math.abs(dx) + math.abs(dy)
                    })
                end
            end
        end
    end

    return actions
end

--- Generate attack actions
-- @param unit The unit
-- @return table Attack actions
function BattlescapeAI:generateAttackActions(unit)
    local actions = {}
    local visibleEnemies = self.tacticalAwareness.visibleEnemies[unit:getId()] or {}

    for _, enemyData in ipairs(visibleEnemies) do
        local enemy = enemyData.unit
        local distance = enemyData.distance

        -- Check if unit can attack this enemy
        if unit:canAttack(enemy) then
            table.insert(actions, {
                type = "attack",
                target = enemy,
                distance = distance,
                expectedDamage = self:calculateExpectedDamage(unit, enemy)
            })
        end
    end

    return actions
end

--- Generate support actions
-- @param unit The unit
-- @return table Support actions
function BattlescapeAI:generateSupportActions(unit)
    local actions = {}
    local unitPos = unit:getPosition()

    -- Suppression fire
    table.insert(actions, {
        type = "suppress",
        position = unitPos,
        area = {x = unitPos.x, y = unitPos.y, radius = 3}
    })

    -- Smoke deployment (if unit has smoke grenades)
    if unit:hasSmokeGrenades() then
        table.insert(actions, {
            type = "smoke",
            position = unitPos,
            targetArea = self:findOptimalSmokePosition(unit)
        })
    end

    return actions
end

--- Calculate expected damage from attack
-- @param attacker Attacking unit
-- @param target Target unit
-- @return number Expected damage
function BattlescapeAI:calculateExpectedDamage(attacker, target)
    local weapon = attacker:getWeapon()
    if not weapon then return 0 end

    local baseDamage = weapon:getDamage()
    local accuracy = weapon:getAccuracy() / 100.0

    -- Distance modifier
    local distance = self:calculateDistance(attacker:getPosition(), target:getPosition())
    local rangeModifier = weapon:getRangeModifier(distance)

    -- Cover modifier
    local cover = self:getCoverAtPosition(target:getPosition())
    local coverModifier = 1.0 - (cover * 0.3) -- 30% reduction max

    return baseDamage * accuracy * rangeModifier * coverModifier
end

--- Score an action using utility factors
-- @param unit The unit performing the action
-- @param action The action to score
-- @return number Utility score
function BattlescapeAI:scoreAction(unit, action)
    local personality = unit:getPersonality() or self.PERSONALITIES.BALANCED
    local weights = self.personalityWeights[personality]
    local score = 0

    self.lastScoringFactors = {}

    -- Survival factor
    local survivalScore = self:scoreSurvival(unit, action)
    score = score + survivalScore * weights[self.UTILITY_FACTORS.SURVIVAL]
    self.lastScoringFactors.survival = survivalScore

    -- Lethality factor
    local lethalityScore = self:scoreLethality(unit, action)
    score = score + lethalityScore * weights[self.UTILITY_FACTORS.LETHALITY]
    self.lastScoringFactors.lethality = lethalityScore

    -- Positioning factor
    local positioningScore = self:scorePositioning(unit, action)
    score = score + positioningScore * weights[self.UTILITY_FACTORS.POSITIONING]
    self.lastScoringFactors.positioning = positioningScore

    -- Objectives factor
    local objectivesScore = self:scoreObjectives(unit, action)
    score = score + objectivesScore * weights[self.UTILITY_FACTORS.OBJECTIVES]
    self.lastScoringFactors.objectives = objectivesScore

    -- Coordination factor
    local coordinationScore = self:scoreCoordination(unit, action)
    score = score + coordinationScore * weights[self.UTILITY_FACTORS.COORDINATION]
    self.lastScoringFactors.coordination = coordinationScore

    -- Personality-specific modifiers
    score = score + self:applyPersonalityModifiers(unit, action, score)

    return score
end

--- Score action based on survival factor
-- @param unit The unit
-- @param action The action
-- @return number Survival score (-1 to 1)
function BattlescapeAI:scoreSurvival(unit, action)
    if action.type == "move" then
        -- Moving to cover improves survival
        local newCover = self:getCoverAtPosition(action.to)
        local currentCover = self:getCoverAtPosition(unit:getPosition())
        return (newCover - currentCover) * 2.0 -- Scale to -1 to 1
    elseif action.type == "attack" then
        -- Attacking creates risk of return fire
        local threat = self.tacticalAwareness.visibleEnemies[unit:getId()]
        local maxThreat = 0
        for _, enemyData in ipairs(threat or {}) do
            maxThreat = math.max(maxThreat, enemyData.threat)
        end
        return -maxThreat * 0.5 -- Negative score for high threat
    elseif action.type == "overwatch" then
        -- Overwatch is defensive
        return 0.3
    end

    return 0
end

--- Score action based on lethality factor
-- @param unit The unit
-- @param action The action
-- @return number Lethality score (0 to 1)
function BattlescapeAI:scoreLethality(unit, action)
    if action.type == "attack" then
        local expectedDamage = action.expectedDamage or 0
        local targetHealth = action.target:getHealth()
        local killProbability = math.min(1.0, expectedDamage / targetHealth)
        return killProbability * 0.8 + (expectedDamage / 100.0) * 0.2
    end

    return 0
end

--- Score action based on positioning factor
-- @param unit The unit
-- @param action The action
-- @return number Positioning score (-1 to 1)
function BattlescapeAI:scorePositioning(unit, action)
    if action.type == "move" then
        local newPos = action.to
        local cover = self:getCoverAtPosition(newPos)
        local elevation = self:getElevationAtPosition(newPos)

        -- Prefer positions with good cover and elevation
        local score = cover * 0.6 + elevation * 0.4

        -- Check for flanking opportunities
        local flankingBonus = self:calculateFlankingBonus(unit, newPos)
        score = score + flankingBonus * 0.3

        return score
    end

    return 0
end

--- Score action based on objectives factor
-- @param unit The unit
-- @param action The action
-- @return number Objectives score (0 to 1)
function BattlescapeAI:scoreObjectives(unit, action)
    -- Check if action advances mission objectives
    local score = 0

    for objId, priority in pairs(self.tacticalAwareness.objectivePriorities) do
        if action.type == "attack" then
            -- Attacking might help kill objectives
            score = score + priority * 0.1
        elseif action.type == "move" then
            -- Moving toward objective locations
            local objectivePos = self:getObjectivePosition(objId)
            if objectivePos then
                local distance = self:calculateDistance(action.to, objectivePos)
                local currentDistance = self:calculateDistance(unit:getPosition(), objectivePos)
                if distance < currentDistance then
                    score = score + priority * 0.2
                end
            end
        end
    end

    return math.min(1.0, score)
end

--- Score action based on coordination factor
-- @param unit The unit
-- @param action The action
-- @return number Coordination score (-1 to 1)
function BattlescapeAI:scoreCoordination(unit, action)
    local groupId = unit:getGroupId()
    if not groupId then return 0 end

    local groupPositions = self.tacticalAwareness.groupPositions[groupId] or {}
    local score = 0

    if action.type == "move" then
        -- Check if move maintains or improves group cohesion
        local avgDistance = 0
        local count = 0

        for _, pos in ipairs(groupPositions) do
            if pos.x ~= unit:getPosition().x or pos.y ~= unit:getPosition().y then
                avgDistance = avgDistance + self:calculateDistance(action.to, pos)
                count = count + 1
            end
        end

        if count > 0 then
            avgDistance = avgDistance / count
            -- Prefer moves that keep unit within 3 tiles of group
            if avgDistance <= 3 then
                score = 0.5
            elseif avgDistance <= 6 then
                score = 0.2
            else
                score = -0.3
            end
        end
    elseif action.type == "suppress" then
        -- Suppression helps coordinate group advances
        score = 0.4
    end

    return score
end

--- Apply personality-specific modifiers to action score
-- @param unit The unit
-- @param action The action
-- @param baseScore Base utility score
-- @return number Modified score
function BattlescapeAI:applyPersonalityModifiers(unit, action, baseScore)
    local personality = unit:getPersonality() or self.PERSONALITIES.BALANCED
    local modifier = 0

    if personality == self.PERSONALITIES.AGGRESSIVE then
        if action.type == "attack" then
            modifier = modifier + 0.3
        elseif action.type == "move" then
            -- Aggressive units prefer closing distance
            local visibleEnemies = self.tacticalAwareness.visibleEnemies[unit:getId()] or {}
            for _, enemyData in ipairs(visibleEnemies) do
                local newDistance = self:calculateDistance(action.to, enemyData.unit:getPosition())
                local currentDistance = enemyData.distance
                if newDistance < currentDistance then
                    modifier = modifier + 0.2
                end
            end
        end
    elseif personality == self.PERSONALITIES.CAUTIOUS then
        if action.type == "overwatch" then
            modifier = modifier + 0.4
        elseif action.type == "move" then
            -- Cautious units prefer maintaining distance
            local visibleEnemies = self.tacticalAwareness.visibleEnemies[unit:getId()] or {}
            for _, enemyData in ipairs(visibleEnemies) do
                local newDistance = self:calculateDistance(action.to, enemyData.unit:getPosition())
                local currentDistance = enemyData.distance
                if newDistance > currentDistance then
                    modifier = modifier + 0.2
                end
            end
        end
    elseif personality == self.PERSONALITIES.SNIPER then
        if action.type == "attack" then
            -- Snipers prefer long-range attacks
            if action.distance and action.distance >= 5 then
                modifier = modifier + 0.3
            end
        end
    elseif personality == self.PERSONALITIES.BERSERKER then
        if action.type == "attack" then
            -- Berserkers prefer close-range attacks
            if action.distance and action.distance <= 2 then
                modifier = modifier + 0.3
            end
        elseif action.type == "move" then
            -- Berserkers prefer closing distance quickly
            modifier = modifier + 0.1
        end
    end

    return modifier
end

--- Calculate flanking bonus for a position
-- @param unit The unit
-- @param position The position to check
-- @return number Flanking bonus (0-1)
function BattlescapeAI:calculateFlankingBonus(unit, position)
    local visibleEnemies = self.tacticalAwareness.visibleEnemies[unit:getId()] or {}
    local bonus = 0

    for _, enemyData in ipairs(visibleEnemies) do
        local enemy = enemyData.unit
        local enemyPos = enemy:getPosition()

        -- Check if position is behind enemy relative to other allies
        local allies = self:getNearbyAllies(unit, 3)
        for _, ally in ipairs(allies) do
            local allyPos = ally:getPosition()
            if self:isPositionBehindEnemy(position, enemyPos, allyPos) then
                bonus = bonus + 0.3
            end
        end
    end

    return math.min(1.0, bonus)
end

--- Get nearby allied units
-- @param unit The unit
-- @param radius Search radius
-- @return table Nearby allies
function BattlescapeAI:getNearbyAllies(unit, radius)
    local allies = {}
    local unitPos = unit:getPosition()
    local allUnits = self.battleState:getAllUnits()

    for _, otherUnit in ipairs(allUnits) do
        if otherUnit:getFaction() == unit:getFaction() and otherUnit ~= unit then
            local distance = self:calculateDistance(unitPos, otherUnit:getPosition())
            if distance <= radius then
                table.insert(allies, otherUnit)
            end
        end
    end

    return allies
end

--- Check if position is behind enemy relative to reference point
-- @param position Position to check
-- @param enemyPos Enemy position
-- @param referencePos Reference position (e.g., ally position)
-- @return boolean Whether position is behind enemy
function BattlescapeAI:isPositionBehindEnemy(position, enemyPos, referencePos)
    -- Simplified check: if position is farther from reference than enemy is
    local enemyToReference = self:calculateDistance(enemyPos, referencePos)
    local positionToReference = self:calculateDistance(position, referencePos)

    return positionToReference > enemyToReference + 1
end

--- Get elevation at position
-- @param position Position to check
-- @return number Elevation value (0-1)
function BattlescapeAI:getElevationAtPosition(position)
    local map = self.battleState:getMap()
    local tile = map:getTile(position.x, position.y)
    return tile and tile:getElevation() or 0
end

--- Get objective position
-- @param objectiveId Objective ID
-- @return table Position or nil
function BattlescapeAI:getObjectivePosition(objectiveId)
    -- This would need to be implemented based on mission data
    -- For now, return nil (objectives don't have specific positions)
    return nil
end

--- Find optimal smoke grenade position
-- @param unit The unit
-- @return table Position for smoke
function BattlescapeAI:findOptimalSmokePosition(unit)
    -- Find position that blocks line of sight to most enemies
    local unitPos = unit:getPosition()
    local bestPos = unitPos
    local bestScore = 0

    local map = self.battleState:getMap()
    for dx = -2, 2 do
        for dy = -2, 2 do
            local testPos = {x = unitPos.x + dx, y = unitPos.y + dy}
            if map:isValidPosition(testPos.x, testPos.y) then
                local score = self:evaluateSmokePosition(testPos, unit)
                if score > bestScore then
                    bestScore = score
                    bestPos = testPos
                end
            end
        end
    end

    return bestPos
end

--- Evaluate smoke position effectiveness
-- @param position Position to evaluate
-- @param unit The unit deploying smoke
-- @return number Effectiveness score
function BattlescapeAI:evaluateSmokePosition(position, unit)
    local score = 0
    local visibleEnemies = self.tacticalAwareness.visibleEnemies[unit:getId()] or {}

    for _, enemyData in ipairs(visibleEnemies) do
        local enemy = enemyData.unit
        local enemyPos = enemy:getPosition()

        -- Check if smoke would block line of sight
        if self:wouldSmokeBlockSight(position, enemyPos, unit:getPosition()) then
            score = score + enemyData.threat
        end
    end

    return score
end

--- Check if smoke would block line of sight
-- @param smokePos Smoke position
-- @param enemyPos Enemy position
-- @param unitPos Unit position
-- @return boolean Whether smoke blocks sight
function BattlescapeAI:wouldSmokeBlockSight(smokePos, enemyPos, unitPos)
    -- Simplified: check if smoke is between unit and enemy
    local smokeToEnemy = self:calculateDistance(smokePos, enemyPos)
    local smokeToUnit = self:calculateDistance(smokePos, unitPos)
    local unitToEnemy = self:calculateDistance(unitPos, enemyPos)

    return smokeToEnemy + smokeToUnit <= unitToEnemy + 1.5 -- Close enough to block
end

--- Log AI decision for telemetry
-- @param unit The unit
-- @param actionData Action decision data
function BattlescapeAI:logDecision(unit, actionData)
    local logEntry = {
        unitId = unit:getId(),
        personality = unit:getPersonality(),
        action = actionData.action,
        score = actionData.score,
        factors = actionData.factors,
        timestamp = love.timer.getTime(),
        turn = self.battleState:getCurrentTurn()
    }

    table.insert(self.decisionHistory, logEntry)

    -- Keep only last 100 decisions for memory management
    if #self.decisionHistory > 100 then
        table.remove(self.decisionHistory, 1)
    end
end

--- Get AI decision history for debugging
-- @return table Decision history
function BattlescapeAI:getDecisionHistory()
    return self.decisionHistory
end

--- Set personality for a unit
-- @param unit The unit
-- @param personality Personality type
function BattlescapeAI:setUnitPersonality(unit, personality)
    unit:setPersonality(personality)
end

--- Get tactical awareness data
-- @return table Tactical awareness
function BattlescapeAI:getTacticalAwareness()
    return self.tacticalAwareness
end

return BattlescapeAI
