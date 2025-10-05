--- InterceptionService.lua
-- Interception combat system for Alien Fall
-- Manages 3x3 grid engagements between crafts

local class = require 'lib.Middleclass'
local EventBus = require 'engine.event_bus'
local InterceptionAI = require 'interception.InterceptionAI'

local InterceptionService = class("InterceptionService")

--- Grid positions for 3x3 interception layout
InterceptionService.GRID_POSITIONS = {
    -- Player positions
    X = {x = 1, y = 1, layer = "air", owner = "player"},
    Y = {x = 1, y = 2, layer = "air", owner = "player"},
    Z = {x = 1, y = 3, layer = "air", owner = "player"},
    -- Alien positions
    A = {x = 3, y = 1, layer = "air", owner = "alien"},
    B = {x = 3, y = 2, layer = "air", owner = "alien"},
    C = {x = 3, y = 3, layer = "air", owner = "alien"}
}

--- Combat outcomes
InterceptionService.OUTCOMES = {
    VICTORY = "victory",
    STALEMATE = "stalemate",
    DEFEAT = "defeat"
}

function InterceptionService:initialize(registry)
    self.registry = registry
    self.eventBus = registry:eventBus()
    self.logger = registry:logger()

    -- Current interception state
    self.active = false
    self.round = 0
    self.maxRounds = 10
    self.timeoutRounds = 5

    -- Grid state (position -> craft/facility)
    self.grid = {}

    -- Combatants
    self.playerCrafts = {}
    self.alienCrafts = {}
    self.baseFacilities = {}

    -- Mission context
    self.missionId = nil
    self.missionType = nil
    self.detected = true -- Whether mission was detected

    -- AI system
    self.ai = nil

    -- Initialize grid
    self:_initializeGrid()

    self.logger:info("InterceptionService initialized")
end

function InterceptionService:_initializeGrid()
    -- Clear grid
    self.grid = {}

    -- Initialize all positions as empty
    for posId, posData in pairs(InterceptionService.GRID_POSITIONS) do
        self.grid[posId] = {
            occupied = false,
            occupant = nil,
            layer = posData.layer,
            owner = posData.owner
        }
    end
end

function InterceptionService:startInterception(missionId, missionType, playerCrafts, alienCrafts, detected)
    self.logger:info("Starting interception for mission: " .. missionId)

    self.active = true
    self.round = 0
    self.missionId = missionId
    self.missionType = missionType
    self.detected = detected or true

    -- Reset grid
    self:_initializeGrid()

    -- Set up combatants
    self.playerCrafts = playerCrafts or {}
    self.alienCrafts = alienCrafts or {}
    self.baseFacilities = {}

    -- Initialize AI
    local alienCraftIds = {}
    for _, craft in ipairs(self.alienCrafts) do
        table.insert(alienCraftIds, craft.id)
    end
    self.ai = InterceptionAI:new(missionId, alienCraftIds)

    -- Position player crafts (prefer air layer)
    self:_positionPlayerCrafts()

    -- Position alien crafts
    self:_positionAlienCrafts()

    -- If undetected, aliens get surprise round
    if not self.detected then
        self.logger:info("Mission undetected - aliens get surprise round")
        self:_processAlienTurn()
    end

    -- Publish event
    self.eventBus:publish("interception:started", {
        missionId = missionId,
        missionType = missionType,
        detected = detected,
        playerCrafts = #self.playerCrafts,
        alienCrafts = #self.alienCrafts
    })

    return true
end

function InterceptionService:_positionPlayerCrafts()
    local positions = {"X", "Y", "Z"}
    local posIndex = 1

    for _, craft in ipairs(self.playerCrafts) do
        if posIndex <= #positions then
            local posId = positions[posIndex]
            self:_placeCraft(craft, posId)
            posIndex = posIndex + 1
        end
    end
end

function InterceptionService:_positionAlienCrafts()
    local positions = {"A", "B", "C"}
    local posIndex = 1

    for _, craft in ipairs(self.alienCrafts) do
        if posIndex <= #positions then
            local posId = positions[posIndex]
            self:_placeCraft(craft, posId)
            posIndex = posIndex + 1
        end
    end
end

function InterceptionService:_placeCraft(craft, positionId)
    if not self.grid[positionId] then return false end

    -- Check if position is suitable for craft
    local posData = InterceptionService.GRID_POSITIONS[positionId]
    if not self:_canCraftOccupyPosition(craft, posData) then
        return false
    end

    self.grid[positionId].occupied = true
    self.grid[positionId].occupant = craft

    self.logger:debug("Placed craft " .. craft.id .. " at position " .. positionId)
    return true
end

function InterceptionService:_canCraftOccupyPosition(craft, posData)
    -- Check if craft can operate in this layer
    if posData.layer == "subsurface" then
        return craft:hasTag("underwater") or craft:hasTag("naval")
    end

    return true -- Air layer is accessible to all
end

function InterceptionService:processRound(playerActions)
    if not self.active then return false end

    self.round = self.round + 1
    self.logger:info("Processing interception round " .. self.round)

    -- Process player actions
    self:_processPlayerActions(playerActions)

    -- Check for round resolution
    if self:_checkRoundEndConditions() then
        self:_resolveRound()
        return self:_checkCombatEndConditions()
    end

    -- Process alien turn
    self:_processAlienTurn()

    -- Check for round resolution again
    if self:_checkRoundEndConditions() then
        self:_resolveRound()
        return self:_checkCombatEndConditions()
    end

    -- Check timeout
    if self.round >= self.timeoutRounds then
        self.logger:info("Interception timed out")
        return self:_endInterception(InterceptionService.OUTCOMES.STALEMATE)
    end

    return true -- Continue combat
end

function InterceptionService:_processPlayerActions(actions)
    -- Process player craft actions
    for _, action in ipairs(actions or {}) do
        self:_executeAction(action, "player")
    end
end

function InterceptionService:_processAlienTurn()
    -- Use AI to evaluate actions for all alien crafts
    local actions = self.ai:evaluateActions(self)

    -- Execute the actions
    for craftId, action in pairs(actions) do
        if action then
            self:_executeAction(action, "alien")
        end
    end
end

function InterceptionService:_generateAlienAction(craft, positionId)
    -- Simple AI: prefer attacking nearby targets
    local targets = self:_findNearbyTargets(positionId, "player")

    if #targets > 0 then
        -- Attack closest target
        local targetPos = targets[1]
        return {
            type = "attack",
            craftId = craft.id,
            fromPosition = positionId,
            targetPosition = targetPos,
            weaponIndex = 1
        }
    else
        -- Move toward player positions
        local moveTarget = self:_findMovementTarget(positionId, "player")
        if moveTarget then
            return {
                type = "move",
                craftId = craft.id,
                fromPosition = positionId,
                toPosition = moveTarget
            }
        end
    end

    return nil
end

function InterceptionService:_findNearbyTargets(fromPos, targetOwner)
    local targets = {}
    local fromData = InterceptionService.GRID_POSITIONS[fromPos]

    for posId, slot in pairs(self.grid) do
        if slot.occupied and slot.owner == targetOwner then
            local distance = self:_calculateGridDistance(fromData, InterceptionService.GRID_POSITIONS[posId])
            if distance <= 2 then -- Within attack range
                table.insert(targets, posId)
            end
        end
    end

    return targets
end

function InterceptionService:_findMovementTarget(fromPos, targetOwner)
    -- Find position closer to target owner
    local fromData = InterceptionService.GRID_POSITIONS[fromPos]
    local targetColumn = (targetOwner == "player") and 1 or 3
    local currentColumn = fromData.x

    if currentColumn == targetColumn then
        return nil -- Already in target column
    end

    -- Move one column toward target
    local newX = (currentColumn < targetColumn) and (currentColumn + 1) or (currentColumn - 1)

    -- Find available position in new column
    for posId, posData in pairs(InterceptionService.GRID_POSITIONS) do
        if posData.x == newX and not self.grid[posId].occupied then
            return posId
        end
    end

    return nil
end

function InterceptionService:_calculateGridDistance(pos1, pos2)
    -- Manhattan distance on grid
    return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
end

function InterceptionService:_executeAction(action, owner)
    self.logger:debug("Executing " .. owner .. " action: " .. action.type)

    if action.type == "move" then
        self:_executeMoveAction(action)
    elseif action.type == "attack" then
        self:_executeAttackAction(action)
    end

    -- Publish event
    self.eventBus:publish("interception:action_executed", {
        action = action,
        owner = owner,
        round = self.round
    })
end

function InterceptionService:_executeMoveAction(action)
    local fromSlot = self.grid[action.fromPosition]
    local toSlot = self.grid[action.toPosition]

    if not fromSlot.occupied or toSlot.occupied then
        return false
    end

    -- Move craft
    toSlot.occupied = true
    toSlot.occupant = fromSlot.occupant

    fromSlot.occupied = false
    fromSlot.occupant = nil

    return true
end

function InterceptionService:_executeAttackAction(action)
    local attackerSlot = self.grid[action.fromPosition]
    local targetSlot = self.grid[action.targetPosition]

    if not attackerSlot.occupied or not targetSlot.occupied then
        return false
    end

    local attacker = attackerSlot.occupant
    local target = targetSlot.occupant

    -- Calculate damage (simplified)
    local damage = self:_calculateAttackDamage(attacker, target, action.weaponIndex)

    -- Apply damage
    local destroyed = target:takeDamage(damage)

    if destroyed then
        targetSlot.occupied = false
        targetSlot.occupant = nil

        self.eventBus:publish("interception:craft_destroyed", {
            craftId = target.id,
            position = action.targetPosition,
            round = self.round
        })
    end

    return true
end

function InterceptionService:_calculateAttackDamage(attacker, target, weaponIndex)
    -- Simplified damage calculation
    local baseDamage = 20
    local armorReduction = target:getArmorValue() * 0.1
    return math.max(1, baseDamage - armorReduction)
end

function InterceptionService:_checkRoundEndConditions()
    -- Check if all actions are complete
    -- For simplicity, assume round ends after both sides act
    return true
end

function InterceptionService:_resolveRound()
    -- Apply end-of-round effects
    self.eventBus:publish("interception:round_resolved", {
        round = self.round,
        gridState = self:getGridState()
    })
end

function InterceptionService:_checkCombatEndConditions()
    -- Check victory conditions
    local playerAlive = self:_countOccupants("player") > 0
    local alienAlive = self:_countOccupants("alien") > 0

    if not playerAlive and alienAlive then
        return self:_endInterception(InterceptionService.OUTCOMES.DEFEAT)
    elseif playerAlive and not alienAlive then
        return self:_endInterception(InterceptionService.OUTCOMES.VICTORY)
    elseif self.round >= self.maxRounds then
        return self:_endInterception(InterceptionService.OUTCOMES.STALEMATE)
    end

    return true -- Continue
end

function InterceptionService:_countOccupants(owner)
    local count = 0
    for _, slot in pairs(self.grid) do
        if slot.occupied and slot.owner == owner then
            count = count + 1
        end
    end
    return count
end

function InterceptionService:_endInterception(outcome)
    self.logger:info("Interception ended with outcome: " .. outcome)

    self.active = false

    -- Publish end event
    self.eventBus:publish("interception:ended", {
        missionId = self.missionId,
        outcome = outcome,
        rounds = self.round,
        gridState = self:getGridState()
    })

    return outcome
end

-- Public interface

function InterceptionService:isActive()
    return self.active
end

function InterceptionService:getCurrentRound()
    return self.round
end

function InterceptionService:getGridState()
    local state = {}
    for posId, slot in pairs(self.grid) do
        state[posId] = {
            occupied = slot.occupied,
            layer = slot.layer,
            owner = slot.owner,
            craftId = slot.occupant and slot.occupant.id or nil
        }
    end
    return state
end

function InterceptionService:getValidActions(craftId, positionId)
    -- Return list of valid actions for the given craft
    local actions = {}

    -- Move actions
    local moveTargets = self:_getValidMoveTargets(positionId)
    for _, targetPos in ipairs(moveTargets) do
        table.insert(actions, {
            type = "move",
            craftId = craftId,
            fromPosition = positionId,
            toPosition = targetPos
        })
    end

    -- Attack actions
    local attackTargets = self:_findNearbyTargets(positionId, "alien") -- Assuming player craft
    for _, targetPos in ipairs(attackTargets) do
        table.insert(actions, {
            type = "attack",
            craftId = craftId,
            fromPosition = positionId,
            targetPosition = targetPos,
            weaponIndex = 1
        })
    end

    return actions
end

function InterceptionService:_getValidMoveTargets(fromPos)
    local targets = {}
    local fromData = InterceptionService.GRID_POSITIONS[fromPos]

    -- Check adjacent positions (same column, adjacent rows)
    for posId, posData in pairs(InterceptionService.GRID_POSITIONS) do
        if posData.x == fromData.x and math.abs(posData.y - fromData.y) == 1 and not self.grid[posId].occupied then
            table.insert(targets, posId)
        end
    end

    return targets
end

--- AI Helper Methods ---

function InterceptionService:getCraft(craftId)
    for _, craft in ipairs(self.alienCrafts) do
        if craft.id == craftId then
            return craft
        end
    end
    for _, craft in ipairs(self.playerCrafts) do
        if craft.id == craftId then
            return craft
        end
    end
    return nil
end

function InterceptionService:getValidMoves(positionId)
    return self:_getValidMoveTargets(positionId)
end

function InterceptionService:getValidTargets(positionId)
    local targets = {}
    local fromData = InterceptionService.GRID_POSITIONS[positionId]

    -- Can target adjacent positions in same or adjacent columns
    for posId, posData in pairs(InterceptionService.GRID_POSITIONS) do
        if self.grid[posId].occupied and self.grid[posId].owner ~= self.grid[positionId].owner then
            if math.abs(posData.x - fromData.x) <= 1 and math.abs(posData.y - fromData.y) <= 1 then
                table.insert(targets, {position = posId, craft = self.grid[posId].occupant})
            end
        end
    end

    return targets
end

function InterceptionService:getCraftAt(positionId)
    if self.grid[positionId] and self.grid[positionId].occupied then
        return self.grid[positionId].occupant
    end
    return nil
end

function InterceptionService:getColumn(positionId)
    local posData = InterceptionService.GRID_POSITIONS[positionId]
    return posData and posData.x or 1
end

function InterceptionService:calculateRetaliationRisk(targetPos, attackerPos)
    -- Simple risk calculation - closer targets are riskier
    local targetData = InterceptionService.GRID_POSITIONS[targetPos]
    local attackerData = InterceptionService.GRID_POSITIONS[attackerPos]

    if not targetData or not attackerData then return 0.5 end

    local distance = math.abs(targetData.x - attackerData.x) + math.abs(targetData.y - attackerData.y)
    return math.max(0, 1.0 - distance / 4.0) -- Closer = higher risk
end

function InterceptionService:calculateExpectedDamage(action, craft)
    -- Placeholder damage calculation
    if action.type == "attack" and craft.weapons and craft.weapons[action.weaponIndex] then
        local weapon = craft.weapons[action.weaponIndex]
        return weapon.damage or 25
    end
    return 0
end

function InterceptionService:calculateTacticalAdvantage(positionId)
    local posData = InterceptionService.GRID_POSITIONS[positionId]
    if not posData then return 0.5 end

    -- Prefer positions closer to enemy (lower x for aliens)
    if posData.owner == "alien" then
        return (4 - posData.x) / 3.0 -- 0.33 to 1.0
    else
        return posData.x / 3.0 -- 0.33 to 1.0
    end
end

return InterceptionService