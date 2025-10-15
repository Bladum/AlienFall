---@meta

---Morale & Panic System
---Handles unit morale, panic, berserk states, leadership, rally actions
---@module morale_system

local MoraleSystem = {}

-- Configuration
MoraleSystem.CONFIG = {
    -- Morale thresholds
    MORALE_PANIC_THRESHOLD = 30, -- Below 30 = panic risk
    MORALE_BERSERK_THRESHOLD = 20, -- Below 20 = berserk risk
    MORALE_BROKEN_THRESHOLD = 10, -- Below 10 = broken (cannot act)
    
    -- Panic/berserk chances
    PANIC_BASE_CHANCE = 0.5, -- 50% at threshold
    BERSERK_BASE_CHANCE = 0.3, -- 30% at berserk threshold
    
    -- Morale damage events
    ALLY_DEATH_MORALE_LOSS = 10,
    NEARBY_ALLY_DEATH_LOSS = 5, -- Within 5 hexes
    ENEMY_KILL_MORALE_GAIN = 5,
    DAMAGE_TAKEN_MORALE_LOSS = 2, -- Per 10% HP lost
    MISS_SHOT_MORALE_LOSS = 1,
    CRITICAL_HIT_MORALE_LOSS = 5,
    
    -- Leadership bonuses
    LEADER_MORALE_BONUS = 10, -- +10 morale to nearby allies
    LEADER_RANGE = 5, -- Within 5 hexes
    
    -- Rally action
    RALLY_MORALE_RESTORE = 20,
    RALLY_AP_COST = 4,
}

---@class MoraleState
---@field unitId string
---@field morale number Current morale (0-100)
---@field state string "normal", "shaken", "panic", "berserk", "broken"
---@field panicDuration number Turns remaining in panic
---@field berserkDuration number Turns remaining in berserk

-- Private state
local moraleStates = {} -- unitId -> MoraleState

---Initialize morale for a unit
---@param unitId string Unit identifier
---@param initialMorale number|nil Starting morale (default 70)
function MoraleSystem.initUnit(unitId, initialMorale)
    moraleStates[unitId] = {
        unitId = unitId,
        morale = initialMorale or 70,
        state = "normal",
        panicDuration = 0,
        berserkDuration = 0,
    }
end

---Remove unit from morale tracking
---@param unitId string Unit identifier
function MoraleSystem.removeUnit(unitId)
    moraleStates[unitId] = nil
end

---Get unit morale state
---@param unitId string Unit identifier
---@return MoraleState|nil state
function MoraleSystem.getState(unitId)
    return moraleStates[unitId]
end

---Modify unit morale
---@param unitId string Unit identifier
---@param amount number Morale change (positive or negative)
---@param reason string|nil Reason for change
function MoraleSystem.modifyMorale(unitId, amount, reason)
    local state = moraleStates[unitId]
    if not state then
        MoraleSystem.initUnit(unitId)
        state = moraleStates[unitId]
    end
    
    local oldMorale = state.morale
    state.morale = math.max(0, math.min(100, state.morale + amount))
    
    print(string.format("[Morale] %s morale: %d -> %d (%s%d, %s)", 
        unitId, oldMorale, state.morale, 
        amount >= 0 and "+" or "", amount, reason or "unknown"))
    
    -- Update state based on new morale
    MoraleSystem.updateState(state)
end

---Update morale state based on current morale value
---@param state MoraleState
function MoraleSystem.updateState(state)
    local cfg = MoraleSystem.CONFIG
    
    -- Already in special state (panic/berserk)
    if state.panicDuration > 0 then
        state.state = "panic"
        return
    end
    if state.berserkDuration > 0 then
        state.state = "berserk"
        return
    end
    
    -- Check thresholds
    if state.morale < cfg.MORALE_BROKEN_THRESHOLD then
        state.state = "broken"
    elseif state.morale < cfg.MORALE_BERSERK_THRESHOLD then
        -- Roll for berserk
        if math.random() < cfg.BERSERK_BASE_CHANCE then
            state.state = "berserk"
            state.berserkDuration = 2 -- 2 turns
            print(string.format("[Morale] %s went BERSERK!", state.unitId))
        else
            state.state = "shaken"
        end
    elseif state.morale < cfg.MORALE_PANIC_THRESHOLD then
        -- Roll for panic
        if math.random() < cfg.PANIC_BASE_CHANCE then
            state.state = "panic"
            state.panicDuration = 2 -- 2 turns
            print(string.format("[Morale] %s PANICKED!", state.unitId))
        else
            state.state = "shaken"
        end
    else
        state.state = "normal"
    end
end

---Process ally death morale impact
---@param deadUnitId string Dead unit ID
---@param deadUnitPos table {q, r} position
---@param allUnits table List of all units
function MoraleSystem.processAllyDeath(deadUnitId, deadUnitPos, allUnits)
    local cfg = MoraleSystem.CONFIG
    
    for _, unit in ipairs(allUnits) do
        if unit.id ~= deadUnitId and unit.team == allUnits.team then
            -- Calculate distance
            local distance = MoraleSystem.calculateDistance(
                unit.q, unit.r, deadUnitPos.q, deadUnitPos.r
            )
            
            if distance <= cfg.LEADER_RANGE then
                -- Nearby ally death
                MoraleSystem.modifyMorale(unit.id, -cfg.NEARBY_ALLY_DEATH_LOSS, "nearby ally death")
            else
                -- Distant ally death
                MoraleSystem.modifyMorale(unit.id, -cfg.ALLY_DEATH_MORALE_LOSS, "ally death")
            end
        end
    end
end

---Process enemy kill morale boost
---@param killerUnitId string Killer unit ID
function MoraleSystem.processEnemyKill(killerUnitId)
    local cfg = MoraleSystem.CONFIG
    MoraleSystem.modifyMorale(killerUnitId, cfg.ENEMY_KILL_MORALE_GAIN, "enemy kill")
end

---Process damage taken morale loss
---@param unitId string Unit ID
---@param damagePercent number Damage as % of max HP (0-100)
function MoraleSystem.processDamageTaken(unitId, damagePercent)
    local cfg = MoraleSystem.CONFIG
    local moraleLoss = math.floor((damagePercent / 10) * cfg.DAMAGE_TAKEN_MORALE_LOSS)
    MoraleSystem.modifyMorale(unitId, -moraleLoss, "damage taken")
end

---Process missed shot morale loss
---@param unitId string Unit ID
function MoraleSystem.processMissedShot(unitId)
    local cfg = MoraleSystem.CONFIG
    MoraleSystem.modifyMorale(unitId, -cfg.MISS_SHOT_MORALE_LOSS, "missed shot")
end

---Process critical hit morale loss
---@param unitId string Unit ID
function MoraleSystem.processCriticalHit(unitId)
    local cfg = MoraleSystem.CONFIG
    MoraleSystem.modifyMorale(unitId, -cfg.CRITICAL_HIT_MORALE_LOSS, "critical hit")
end

---Apply leadership morale bonus
---@param leaderUnit table Leader unit
---@param allUnits table List of all units
function MoraleSystem.applyLeadershipBonus(leaderUnit, allUnits)
    local cfg = MoraleSystem.CONFIG
    
    if not leaderUnit.isLeader then return end
    
    for _, unit in ipairs(allUnits) do
        if unit.id ~= leaderUnit.id and unit.team == leaderUnit.team then
            local distance = MoraleSystem.calculateDistance(
                leaderUnit.q, leaderUnit.r, unit.q, unit.r
            )
            
            if distance <= cfg.LEADER_RANGE then
                -- Apply temporary bonus (not permanent morale gain)
                print(string.format("[Morale] %s inspired by leader %s (+%d morale)", 
                    unit.id, leaderUnit.id, cfg.LEADER_MORALE_BONUS))
            end
        end
    end
end

---Rally action: restore morale
---@param unitId string Unit performing rally
---@param targetUnitId string|nil Target unit (nil for self)
---@return boolean success
function MoraleSystem.rally(unitId, targetUnitId)
    local cfg = MoraleSystem.CONFIG
    local target = targetUnitId or unitId
    
    MoraleSystem.modifyMorale(target, cfg.RALLY_MORALE_RESTORE, "rally action")
    
    print(string.format("[Morale] %s rallied %s (+%d morale)", 
        unitId, target, cfg.RALLY_MORALE_RESTORE))
    
    return true
end

---Process turn end for morale (decay durations)
---@param unitId string Unit ID
function MoraleSystem.processTurnEnd(unitId)
    local state = moraleStates[unitId]
    if not state then return end
    
    -- Decay panic/berserk durations
    if state.panicDuration > 0 then
        state.panicDuration = state.panicDuration - 1
        if state.panicDuration == 0 then
            print(string.format("[Morale] %s recovered from panic", unitId))
            MoraleSystem.updateState(state)
        end
    end
    
    if state.berserkDuration > 0 then
        state.berserkDuration = state.berserkDuration - 1
        if state.berserkDuration == 0 then
            print(string.format("[Morale] %s recovered from berserk", unitId))
            MoraleSystem.updateState(state)
        end
    end
end

---Check if unit can act (not broken, not panicked)
---@param unitId string Unit ID
---@return boolean canAct, string|nil reason
function MoraleSystem.canAct(unitId)
    local state = moraleStates[unitId]
    if not state then return true end
    
    if state.state == "broken" then
        return false, "Broken morale - cannot act"
    end
    
    if state.state == "panic" then
        return false, "Panicking - cannot act normally"
    end
    
    return true
end

---Get morale color for UI
---@param morale number Morale value (0-100)
---@return table rgb {r, g, b}
function MoraleSystem.getMoraleColor(morale)
    if morale >= 70 then
        return {0.4, 1.0, 0.4} -- Green
    elseif morale >= 50 then
        return {1.0, 1.0, 0.4} -- Yellow
    elseif morale >= 30 then
        return {1.0, 0.6, 0.2} -- Orange
    else
        return {1.0, 0.2, 0.2} -- Red
    end
end

---Calculate hex distance
---@param q1 number Q1
---@param r1 number R1
---@param q2 number Q2
---@param r2 number R2
---@return number distance
function MoraleSystem.calculateDistance(q1, r1, q2, r2)
    local dq = math.abs(q2 - q1)
    local dr = math.abs(r2 - r1)
    local ds = math.abs((-q1 - r1) - (-q2 - r2))
    return math.floor((dq + dr + ds) / 2)
end

---Configure morale system parameters
---@param config table Configuration overrides
function MoraleSystem.configure(config)
    for k, v in pairs(config) do
        if MoraleSystem.CONFIG[k] ~= nil then
            MoraleSystem.CONFIG[k] = v
            print(string.format("[Morale] Config: %s = %s", k, tostring(v)))
        end
    end
end

---Reset entire system
function MoraleSystem.reset()
    moraleStates = {}
    print("[Morale] System reset")
end

return MoraleSystem






















