---Morale Break & Panic System
---
---Implements psychological combat mechanics where units lose control at critical
---morale levels. Panic state causes unit to flee/act erratically, berserk causes
---aggressive actions. Recovery depends on leadership and safe conditions.
---
---Morale States:
---  - NORMAL: 70-100 morale (full control)
---  - SHAKEN: 30-69 morale (penalties to accuracy/AP)
---  - PANIC: 0-29 morale (50% chance to panic, lose control for 1-3 turns)
---  - BERSERK: -10-0 morale (30% chance, uncontrolled aggression for 1-2 turns)
---  - BROKEN: <-10 morale (cannot act at all, permanent unless healed)
---
---Panic Mechanics:
---  - Triggered at 0-29 morale when unit acts or takes damage
---  - Roll: 50% base + 5% per morale point below threshold
---  - Duration: 1-3 turns (random)
---  - Effect: Move away from threats, -50% accuracy, cannot use abilities
---  - Recovery: +10 morale when safely away from enemies
---
---Berserk Mechanics:
---  - Triggered at -10-0 morale under high stress
---  - Roll: 30% base + 5% per morale point below threshold
---  - Duration: 1-2 turns
---  - Effect: Attack nearest target regardless of strategy
---  - Recovery: -5 morale per round (goes deeper negative)
---
---Leadership Impact:
---  - Leaders (isLeader=true) grant +10 morale within 5 hexes
---  - Medical treatment: +20 morale when stabilized
---  - Success/morale events: +10 per objective achieved
---  - Retreat triggers: -30 morale
---
---Key Exports:
---  - MoraleBreakSystem.new(): Creates system
---  - processMoraleBreak(unit, situation): Checks for breakdown
---  - triggerPanic(unitId, duration): Forces panic
---  - triggerBerserk(unitId, duration): Forces berserk
---  - addMoraleEvent(unitId, event): Applies morale event
---  - getMoraleState(unitId): Gets current state
---
---Dependencies:
---  - battlescape.systems.morale_system: Base morale tracking
---  - battlescape.systems.unit_system: Unit management
---  - battlescape.systems.movement_system: Panic movement
---
---@module battlescape.systems.morale_break_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MoraleBreak = require("engine.battlescape.systems.morale_break_system")
---  local system = MoraleBreak.new()
---  local panic = system:processMoraleBreak(unit, "UNDER_FIRE")
---  if panic then
---    system:triggerPanic(unit.id, 2)
---  end

local MoraleBreakSystem = {}
MoraleBreakSystem.__index = MoraleBreakSystem

--- Create new morale break system
-- @return table New MoraleBreakSystem instance
function MoraleBreakSystem.new()
    local self = setmetatable({}, MoraleBreakSystem)

    self.panicStates = {}     -- Panic tracking: unitId -> {duration, remainingTurns}
    self.berserkStates = {}   -- Berserk tracking: unitId -> {duration, remainingTurns}
    self.brokenStates = {}    -- Broken tracking: unitId -> {isBroken}
    self.recoveryCounters = {}  -- Recovery tracking: unitId -> turns_safe

    print("[MoraleBreakSystem] Initialized morale break & panic system")

    return self
end

--- Define morale thresholds
local MORALE_THRESHOLDS = {
    NORMAL = 70,      -- No penalties
    SHAKEN = 30,      -- Increased stress
    PANIC_THRESHOLD = 0,     -- Can enter panic
    BERSERK_THRESHOLD = -10,  -- Can berserk
    BROKEN_THRESHOLD = -10,   -- Cannot act
}

--- Process morale break check (run when unit acts or takes damage)
-- @param unit table Unit entity
-- @param situation string Triggering situation
-- @return boolean Should trigger panic/berserk
function MoraleBreakSystem:processMoraleBreak(unit, situation)
    if not unit or unit.morale == nil then
        return false
    end

    local morale = unit.morale

    -- Check for berserk
    if morale <= MORALE_THRESHOLDS.BERSERK_THRESHOLD then
        local berserkChance = 30 + math.abs(morale - MORALE_THRESHOLDS.BERSERK_THRESHOLD) * 2
        if math.random(1, 100) <= berserkChance then
            print(string.format("[MoraleBreak] %s enters BERSERK state (morale: %d)", unit.name, morale))
            return "BERSERK"
        end
    end

    -- Check for panic
    if morale <= MORALE_THRESHOLDS.PANIC_THRESHOLD and morale > MORALE_THRESHOLDS.BERSERK_THRESHOLD then
        local panicChance = 50 - morale * 2  -- 50% at 0, scales downward
        panicChance = math.max(10, math.min(90, panicChance))  -- Clamp 10-90%

        if math.random(1, 100) <= panicChance then
            print(string.format("[MoraleBreak] %s enters PANIC state (morale: %d, roll: %d%%)",
                  unit.name, morale, panicChance))
            return "PANIC"
        end
    end

    -- Check for broken (permanent state)
    if morale < MORALE_THRESHOLDS.BROKEN_THRESHOLD then
        print(string.format("[MoraleBreak] %s is BROKEN (morale: %d)", unit.name, morale))
        self.brokenStates[unit.id] = true
        return "BROKEN"
    end

    return nil
end

--- Trigger panic state on unit
-- @param unitId string Unit ID
-- @param durationTurns number Number of turns panic lasts (1-3)
function MoraleBreakSystem:triggerPanic(unitId, durationTurns)
    durationTurns = durationTurns or math.random(1, 3)

    self.panicStates[unitId] = {
        triggered = true,
        duration = durationTurns,
        remainingTurns = durationTurns,
        startTurn = 0,
    }

    print(string.format("[MoraleBreak] Triggered PANIC on unit %s (%d turns)", unitId, durationTurns))
end

--- Trigger berserk state on unit
-- @param unitId string Unit ID
-- @param durationTurns number Number of turns berserk lasts (1-2)
function MoraleBreakSystem:triggerBerserk(unitId, durationTurns)
    durationTurns = durationTurns or math.random(1, 2)

    self.berserkStates[unitId] = {
        triggered = true,
        duration = durationTurns,
        remainingTurns = durationTurns,
        startTurn = 0,
    }

    print(string.format("[MoraleBreak] Triggered BERSERK on unit %s (%d turns)", unitId, durationTurns))
end

--- Check if unit is in panic
-- @param unitId string Unit ID
-- @return boolean Is panicking
function MoraleBreakSystem:isPanicking(unitId)
    local state = self.panicStates[unitId]
    return state and state.triggered and state.remainingTurns > 0
end

--- Check if unit is berserk
-- @param unitId string Unit ID
-- @return boolean Is berserk
function MoraleBreakSystem:isBerserk(unitId)
    local state = self.berserkStates[unitId]
    return state and state.triggered and state.remainingTurns > 0
end

--- Check if unit is broken
-- @param unitId string Unit ID
-- @return boolean Is broken
function MoraleBreakSystem:isBroken(unitId)
    return self.brokenStates[unitId] or false
end

--- Get panic behavior for unit
-- @param unitId string Unit ID
-- @return string Action type or nil
function MoraleBreakSystem:getPanicAction(unitId)
    if not self:isPanicking(unitId) then
        return nil
    end

    -- Panic actions (in priority order)
    local actions = {
        "FLEE",           -- Move away from nearest enemy
        "CROUCH",         -- Take defensive posture
        "FREEZE",         -- Stand still
        "RANDOM_MOVE",    -- Random movement
    }

    -- Weight actions by probability
    local roll = math.random(1, 100)
    if roll <= 40 then
        return "FLEE"
    elseif roll <= 70 then
        return "CROUCH"
    elseif roll <= 90 then
        return "FREEZE"
    else
        return "RANDOM_MOVE"
    end
end

--- Get berserk behavior for unit
-- @param unitId string Unit ID
-- @return string Action type (usually attack nearest)
function MoraleBreakSystem:getBerserkAction(unitId)
    if not self:isBerserk(unitId) then
        return nil
    end

    -- Berserk units attack nearest target
    return "ATTACK_NEAREST"
end

--- Get accuracy penalty for morale state
-- @param unit table Unit entity
-- @return number Accuracy modifier (0.0-1.0)
function MoraleBreakSystem:getAccuracyModifier(unit)
    if not unit or unit.morale == nil then
        return 1.0
    end

    local morale = unit.morale

    -- Panic: -50% accuracy
    if morale <= MORALE_THRESHOLDS.PANIC_THRESHOLD then
        return 0.5
    end

    -- Shaken: -25% accuracy
    if morale < MORALE_THRESHOLDS.NORMAL then
        return 0.75
    end

    return 1.0
end

--- Get AP penalty for morale state
-- @param unit table Unit entity
-- @return number AP modifier (0.0-1.0)
function MoraleBreakSystem:getAPModifier(unit)
    if not unit or unit.morale == nil then
        return 1.0
    end

    local morale = unit.morale

    -- Panic: -50% AP
    if morale <= MORALE_THRESHOLDS.PANIC_THRESHOLD then
        return 0.5
    end

    -- Shaken: -25% AP
    if morale < MORALE_THRESHOLDS.NORMAL then
        return 0.75
    end

    return 1.0
end

--- Add morale event (apply morale changes)
-- @param unitId string Unit ID
-- @param eventType string Event type (KILL, CASUALTY, FEAR, SUCCESS, etc.)
-- @param magnitude number Magnitude of change
function MoraleBreakSystem:addMoraleEvent(unitId, eventType, magnitude)
    local events = {
        KILL_ENEMY = 10,
        KILL_ALLY = -30,
        TAKE_DAMAGE_LIGHT = -5,
        TAKE_DAMAGE_HEAVY = -15,
        UNDER_FIRE = -10,
        OBJECTIVE_SUCCESS = 20,
        OBJECTIVE_FAILURE = -20,
        LEADER_PRESENT = 10,
        LEADER_KILLED = -50,
        RETREAT = -30,
        HEALING = 15,
        SAFE = 5,
    }

    local change = events[eventType] or magnitude

    print(string.format("[MoraleBreak] Event '%s' on unit %s: %+d morale",
          eventType, unitId, change))

    return change
end

--- Process turn-end recovery/duration updates
-- @param unitId string Unit ID
-- @param unit table Unit entity (for morale access)
function MoraleBreakSystem:processTurnEnd(unitId, unit)
    if not unit or unit.morale == nil then
        return
    end

    -- Update panic duration
    local panicState = self.panicStates[unitId]
    if panicState and panicState.triggered then
        panicState.remainingTurns = panicState.remainingTurns - 1

        if panicState.remainingTurns <= 0 then
            print(string.format("[MoraleBreak] Unit %s panic ended", unitId))
            panicState.triggered = false
        end
    end

    -- Update berserk duration
    local berserkState = self.berserkStates[unitId]
    if berserkState and berserkState.triggered then
        berserkState.remainingTurns = berserkState.remainingTurns - 1

        if berserkState.remainingTurns <= 0 then
            print(string.format("[MoraleBreak] Unit %s berserk ended", unitId))
            berserkState.triggered = false
        end
    end

    -- Natural morale recovery
    if not panicState or panicState.remainingTurns <= 0 then
        if not berserkState or berserkState.remainingTurns <= 0 then
            -- Safe conditions: +5 morale per turn
            unit.morale = unit.morale + 5
            print(string.format("[MoraleBreak] Unit %s recovered morale to %d (safe)", unitId, unit.morale))
        else
            -- Berserk: -5 morale per turn (gets worse)
            unit.morale = unit.morale - 5
            print(string.format("[MoraleBreak] Unit %s morale fell to %d (berserk)", unitId, unit.morale))
        end
    end
end

--- Get current morale state for display
-- @param unitId string Unit ID
-- @return string State description
function MoraleBreakSystem:getMoraleState(unitId)
    if self:isBroken(unitId) then
        return "BROKEN"
    elseif self:isBerserk(unitId) then
        return "BERSERK"
    elseif self:isPanicking(unitId) then
        return "PANIC"
    else
        return "STABLE"
    end
end

--- Get morale state color for UI
-- @param unitId string Unit ID
-- @return table RGB color
function MoraleBreakSystem:getMoraleColor(unitId)
    local state = self:getMoraleState(unitId)

    local colors = {
        BROKEN = {r = 0.5, g = 0.0, b = 0.0},      -- Dark red
        BERSERK = {r = 1.0, g = 0.0, b = 0.0},     -- Bright red
        PANIC = {r = 1.0, g = 0.5, b = 0.0},       -- Orange
        STABLE = {r = 0.2, g = 0.8, b = 0.2},      -- Green
    }

    return colors[state] or {r = 0.5, g = 0.5, b = 0.5}
end

--- Apply leadership bonus to nearby units
-- @param leaderId string Leader unit ID
-- @param allies table Array of ally unit entities
-- @return number Morale bonus applied to each ally
function MoraleBreakSystem:applyLeadershipBonus(leaderId, allies)
    local bonus = 10  -- +10 morale
    local range = 5   -- 5 hex radius

    local applied = 0
    for _, ally in ipairs(allies) do
        -- Distance check (placeholder - would integrate with actual hex system)
        local dist = math.random(1, 10)  -- Simulate distance calculation

        if dist <= range and ally.id ~= leaderId then
            ally.morale = (ally.morale or 0) + bonus
            applied = applied + 1
        end
    end

    print(string.format("[MoraleBreak] Leader %s applied +%d morale to %d allies",
          leaderId, bonus, applied))

    return bonus
end

--- Stabilize broken unit (requires medical attention)
-- @param unitId string Unit ID
-- @return boolean Success
function MoraleBreakSystem:stabilizeBrokenUnit(unitId)
    if not self:isBroken(unitId) then
        return false
    end

    self.brokenStates[unitId] = false

    print(string.format("[MoraleBreak] Unit %s stabilized from broken state", unitId))

    return true
end

--- Get panic state details
-- @param unitId string Unit ID
-- @return table Panic details or nil
function MoraleBreakSystem:getPanicDetails(unitId)
    local state = self.panicStates[unitId]

    if not state or not state.triggered then
        return nil
    end

    return {
        duration = state.duration,
        remainingTurns = state.remainingTurns,
        action = self:getPanicAction(unitId),
    }
end

--- Get berserk state details
-- @param unitId string Unit ID
-- @return table Berserk details or nil
function MoraleBreakSystem:getBerserkDetails(unitId)
    local state = self.berserkStates[unitId]

    if not state or not state.triggered then
        return nil
    end

    return {
        duration = state.duration,
        remainingTurns = state.remainingTurns,
        action = self:getBerserkAction(unitId),
    }
end

return MoraleBreakSystem
