--- Morale System
-- Manages unit morale, panic, and psychological effects in battles
--
-- @classmod battlescape.MoraleSystem

-- GROK: MoraleSystem tracks psychological state with 0-100 meter affecting behavior
-- GROK: Handles panic, berserk, surrender states with deterministic thresholds
-- GROK: Key methods: checkMorale(), applyMoraleDamage(), triggerPanic()
-- GROK: Integrates with action system and AI for behavioral changes

local class = require 'lib.Middleclass'

--- MoraleSystem class
-- @type MoraleSystem
MoraleSystem = class('MoraleSystem')

--- Morale thresholds and effects
-- @field MIN_MORALE Minimum morale value
-- @field MAX_MORALE Maximum morale value
-- @field PANIC_THRESHOLD Morale level that triggers panic
-- @field BERSERK_THRESHOLD Morale level that triggers berserk
-- @field SURRENDER_THRESHOLD Morale level that triggers surrender
MoraleSystem.static.MIN_MORALE = 0
MoraleSystem.static.MAX_MORALE = 100
MoraleSystem.static.PANIC_THRESHOLD = 20
MoraleSystem.static.BERSERK_THRESHOLD = 10
MoraleSystem.static.SURRENDER_THRESHOLD = 5

--- Create a new MoraleSystem instance
-- @param battleState Reference to the current battle state
-- @return MoraleSystem instance
function MoraleSystem:initialize(battleState)
    self.battleState = battleState
    self.moraleStates = {} -- Track morale for each unit
    self.moraleHistory = {} -- Track morale changes for debugging
end

--- Initialize morale for a unit
-- @param unit The unit to initialize morale for
function MoraleSystem:initializeUnitMorale(unit)
    local baseMorale = unit:getBaseMorale() or 50
    self.moraleStates[unit:getId()] = {
        current = baseMorale,
        base = baseMorale,
        state = "normal",
        modifiers = {}
    }
end

--- Get current morale for a unit
-- @param unit The unit
-- @return number Current morale value
function MoraleSystem:getMorale(unit)
    local moraleData = self.moraleStates[unit:getId()]
    return moraleData and moraleData.current or 50
end

--- Get morale state for a unit
-- @param unit The unit
-- @return string Current morale state (normal, panicked, berserk, surrendered)
function MoraleSystem:getMoraleState(unit)
    local moraleData = self.moraleStates[unit:getId()]
    return moraleData and moraleData.state or "normal"
end

--- Apply morale damage to a unit
-- @param unit The unit taking morale damage
-- @param damage Amount of morale damage
-- @param reason Reason for the morale damage
-- @return table Results of morale change
function MoraleSystem:applyMoraleDamage(unit, damage, reason)
    local unitId = unit:getId()
    if not self.moraleStates[unitId] then
        self:initializeUnitMorale(unit)
    end

    local moraleData = self.moraleStates[unitId]
    local oldMorale = moraleData.current
    local oldState = moraleData.state

    -- Apply damage
    moraleData.current = math.max(self.MIN_MORALE, moraleData.current - damage)

    -- Check for state changes
    local newState = self:calculateMoraleState(moraleData.current)

    -- Record change
    table.insert(self.moraleHistory, {
        unit = unit,
        oldMorale = oldMorale,
        newMorale = moraleData.current,
        damage = damage,
        reason = reason,
        oldState = oldState,
        newState = newState,
        turn = self.battleState:getCurrentTurn()
    })

    -- Handle state transition
    if newState ~= oldState then
        self:handleMoraleStateChange(unit, oldState, newState, reason)
        moraleData.state = newState
    end

    -- Trigger event
    self.battleState:triggerEvent('battlescape:unit_status_changed', {
        unit = unit,
        statusType = 'morale',
        oldValue = oldMorale,
        newValue = moraleData.current,
        oldState = oldState,
        newState = newState,
        reason = reason
    })

    return {
        oldMorale = oldMorale,
        newMorale = moraleData.current,
        damage = damage,
        stateChanged = newState ~= oldState,
        newState = newState
    }
end

--- Apply morale recovery to a unit
-- @param unit The unit gaining morale
-- @param recovery Amount of morale recovery
-- @param reason Reason for the morale recovery
-- @return table Results of morale change
function MoraleSystem:applyMoraleRecovery(unit, recovery, reason)
    local unitId = unit:getId()
    if not self.moraleStates[unitId] then
        self:initializeUnitMorale(unit)
    end

    local moraleData = self.moraleStates[unitId]
    local oldMorale = moraleData.current
    local oldState = moraleData.state

    -- Apply recovery
    moraleData.current = math.min(self.MAX_MORALE, moraleData.current + recovery)

    -- Check for state changes (recovery might change state back to normal)
    local newState = self:calculateMoraleState(moraleData.current)

    -- Record change
    table.insert(self.moraleHistory, {
        unit = unit,
        oldMorale = oldMorale,
        newMorale = moraleData.current,
        recovery = recovery,
        reason = reason,
        oldState = oldState,
        newState = newState,
        turn = self.battleState:getCurrentTurn()
    })

    -- Handle state transition
    if newState ~= oldState then
        self:handleMoraleStateChange(unit, oldState, newState, reason)
        moraleData.state = newState
    end

    return {
        oldMorale = oldMorale,
        newMorale = moraleData.current,
        recovery = recovery,
        stateChanged = newState ~= oldState,
        newState = newState
    }
end

--- Calculate morale state based on current morale value
-- @param morale Current morale value
-- @return string Morale state
function MoraleSystem:calculateMoraleState(morale)
    if morale <= self.SURRENDER_THRESHOLD then
        return "surrendered"
    elseif morale <= self.BERSERK_THRESHOLD then
        return "berserk"
    elseif morale <= self.PANIC_THRESHOLD then
        return "panicked"
    else
        return "normal"
    end
end

--- Handle morale state changes
-- @param unit The unit whose morale state changed
-- @param oldState Previous morale state
-- @param newState New morale state
-- @param reason Reason for the change
function MoraleSystem:handleMoraleStateChange(unit, oldState, newState, reason)
    if newState == "panicked" then
        self:triggerPanic(unit, reason)
    elseif newState == "berserk" then
        self:triggerBerserk(unit, reason)
    elseif newState == "surrendered" then
        self:triggerSurrender(unit, reason)
    elseif newState == "normal" and oldState ~= "normal" then
        self:recoverFromMoraleState(unit, oldState, reason)
    end
end

--- Trigger panic state for a unit
-- @param unit The unit entering panic
-- @param reason Reason for panic
function MoraleSystem:triggerPanic(unit, reason)
    -- Panic effects: reduced accuracy, random movement, etc.
    unit:setStatusEffect("panicked", true)

    -- Force end turn or random action
    if self.battleState:getCurrentUnit() == unit then
        self.battleState:endUnitTurn(unit)
    end

    -- Trigger event
    self.battleState:triggerEvent('battlescape:unit_panicked', {
        unit = unit,
        reason = reason
    })
end

--- Trigger berserk state for a unit
-- @param unit The unit entering berserk
-- @param reason Reason for berserk
function MoraleSystem:triggerBerserk(unit, reason)
    -- Berserk effects: increased damage, ignores suppression, etc.
    unit:setStatusEffect("berserk", true)

    -- Trigger event
    self.battleState:triggerEvent('battlescape:unit_berserk', {
        unit = unit,
        reason = reason
    })
end

--- Trigger surrender for a unit
-- @param unit The unit surrendering
-- @param reason Reason for surrender
function MoraleSystem:triggerSurrender(unit, reason)
    -- Surrender effects: unit becomes inactive
    unit:setStatusEffect("surrendered", true)
    unit:setAlive(false) -- For battle purposes

    -- Trigger event
    self.battleState:triggerEvent('battlescape:unit_surrendered', {
        unit = unit,
        reason = reason
    })
end

--- Recover from morale state
-- @param unit The unit recovering
-- @param oldState The state they were in
-- @param reason Reason for recovery
function MoraleSystem:recoverFromMoraleState(unit, oldState, reason)
    -- Clear status effects
    if oldState == "panicked" then
        unit:setStatusEffect("panicked", false)
    elseif oldState == "berserk" then
        unit:setStatusEffect("berserk", false)
    end

    -- Trigger event
    self.battleState:triggerEvent('battlescape:unit_recovered', {
        unit = unit,
        fromState = oldState,
        reason = reason
    })
end

--- Check morale for situational triggers
-- @param unit The unit to check
-- @param situation The situation triggering the check
-- @return table Results of morale check
function MoraleSystem:checkMorale(unit, situation)
    local moraleData = self.moraleStates[unit:getId()]
    if not moraleData then
        self:initializeUnitMorale(unit)
        moraleData = self.moraleStates[unit:getId()]
    end

    -- Base morale check modifiers
    local modifiers = {
        ally_killed = -15,
        friendly_fire = -10,
        grenade_nearby = -8,
        psionic_attack = -12,
        heavy_casualties = -5,
        leader_killed = -20,
        objective_lost = -10,
        victory_near = 5,
        reinforcement_arrived = 8,
        cover_taken = 3
    }

    local modifier = modifiers[situation] or 0

    -- Apply unit-specific modifiers
    if unit:getTrait("brave") then
        modifier = modifier + 5
    elseif unit:getTrait("cowardly") then
        modifier = modifier - 5
    end

    -- Apply leadership bonuses
    local leaderBonus = self:getLeadershipBonus(unit)
    modifier = modifier + leaderBonus

    -- Calculate effective morale
    local effectiveMorale = math.max(0, math.min(100, moraleData.current + modifier))

    -- Determine outcome
    local outcome = "stable"
    local moraleChange = 0

    if effectiveMorale < 30 then
        outcome = "shaken"
        moraleChange = -math.random(5, 15)
    elseif effectiveMorale < 60 then
        outcome = "nervous"
        moraleChange = -math.random(0, 5)
    elseif effectiveMorale > 80 then
        outcome = "confident"
        moraleChange = math.random(0, 3)
    end

    -- Apply morale change if significant
    if moraleChange ~= 0 then
        self:applyMoraleDamage(unit, -moraleChange, situation .. "_check")
    end

    return {
        situation = situation,
        baseMorale = moraleData.current,
        effectiveMorale = effectiveMorale,
        modifier = modifier,
        outcome = outcome,
        moraleChange = moraleChange
    }
end

--- Get leadership bonus for a unit
-- @param unit The unit
-- @return number Leadership bonus
function MoraleSystem:getLeadershipBonus(unit)
    -- Check for nearby leaders
    local nearbyUnits = self.battleState:getUnitsInRadius(unit:getPosition(), 5)
    local bonus = 0

    for _, nearbyUnit in ipairs(nearbyUnits) do
        if nearbyUnit:getFaction() == unit:getFaction() and nearbyUnit:getRank() >= 3 then
            -- Leader bonus
            local distance = self.battleState:getMap():getDistance(unit:getPosition(), nearbyUnit:getPosition())
            bonus = bonus + math.max(0, 10 - distance)
        end
    end

    return bonus
end

--- Process end-of-turn morale recovery
-- @param unit The unit
function MoraleSystem:processTurnEndRecovery(unit)
    local recovery = 2 -- Base recovery per turn

    -- Apply modifiers
    if unit:getStance() == "cover" then
        recovery = recovery + 1
    end

    if unit:getTrait("resilient") then
        recovery = recovery + 1
    end

    if self:getMoraleState(unit) == "panicked" then
        recovery = recovery - 1 -- Harder to recover when panicked
    end

    if recovery > 0 then
        self:applyMoraleRecovery(unit, recovery, "turn_end_recovery")
    end
end

--- Get morale statistics for debugging
-- @return table Morale statistics
function MoraleSystem:getMoraleStats()
    local stats = {
        totalUnits = 0,
        normal = 0,
        panicked = 0,
        berserk = 0,
        surrendered = 0,
        averageMorale = 0
    }

    local totalMorale = 0

    for unitId, moraleData in pairs(self.moraleStates) do
        stats.totalUnits = stats.totalUnits + 1
        stats[moraleData.state] = stats[moraleData.state] + 1
        totalMorale = totalMorale + moraleData.current
    end

    if stats.totalUnits > 0 then
        stats.averageMorale = totalMorale / stats.totalUnits
    end

    return stats
end

--- Clear morale data (for new battle)
function MoraleSystem:clearMoraleData()
    self.moraleStates = {}
    self.moraleHistory = {}
end

--- Get morale history
-- @return table Morale change history
function MoraleSystem:getMoraleHistory()
    return self.moraleHistory
end

return MoraleSystem
