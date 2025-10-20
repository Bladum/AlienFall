---@meta

---Morale & Sanity System (NEW)
---Handles unit morale, sanity, and panic states for tactical combat
---Morale: Derived from BRAVERY stat (6-12), buffer during battle
---Sanity: Separate stat (6-12), psychological stability buffer
---Both systems apply AP modifiers when low, and panic when depleted
---@module morale_system

local MoraleSystem = {}

-- Configuration
MoraleSystem.CONFIG = {
    -- AP Modifier thresholds
    AP_MODIFIER_THRESHOLD_2 = 2,  -- When morale/sanity = 2: -1 AP
    AP_MODIFIER_THRESHOLD_1 = 1,  -- When morale/sanity = 1: -2 AP
    
    -- Stress event morale loss
    ALLY_DEATH_MORALE_LOSS = 1,  -- -1 morale when ally dies nearby
    CRITICAL_HIT_MORALE_LOSS = 1,  -- -1 morale when critically hit
    
    -- Sanity loss per mission (post-battle)
    SANITY_LOSS_STANDARD = 0,     -- Standard difficulty
    SANITY_LOSS_MODERATE = 1,     -- Moderate difficulty  
    SANITY_LOSS_HARD = 2,         -- Hard difficulty
    SANITY_LOSS_NIGHT_MISSION = 1,  -- Additional penalty for night missions
    SANITY_LOSS_PER_ALLY_KIA = 1,   -- Per ally killed
    
    -- Leadership bonuses
    LEADER_MORALE_BONUS = 1,       -- +1 morale to nearby allies per turn
    LEADER_RANGE = 5,              -- Within 5 hexes
    
    -- Rally action
    RALLY_MORALE_RESTORE = 2,      -- +2 morale
    RALLY_AP_COST = 4,
}

---@class PsychologicalState
---@field unitId string
---@field morale number Current morale (0-12, derived from bravery)
---@field maxMorale number Max morale (equals BRAVERY stat)
---@field sanity number Current sanity (0-12)
---@field maxSanity number Max sanity (base sanity stat)
---@field state string "normal", "stressed", "panicked"

-- Private state
local psychStates = {} -- unitId -> PsychologicalState

---Initialize morale/sanity for a unit
---@param unitId string Unit identifier
---@param bravery number Bravery stat (becomes max morale)
---@param sanity number Sanity stat (becomes max sanity)
function MoraleSystem.initUnit(unitId, bravery, sanity)
    bravery = math.max(1, math.min(12, bravery or 9))
    sanity = math.max(1, math.min(12, sanity or 9))
    
    psychStates[unitId] = {
        unitId = unitId,
        morale = bravery,              -- Start at max
        maxMorale = bravery,           -- Morale cannot exceed bravery
        sanity = sanity,               -- Start at max
        maxSanity = sanity,            -- Max sanity for this unit
        state = "normal",
    }
    
    print(string.format("[MoraleSystem] %s initialized: morale=%d (max %d), sanity=%d (max %d)",
        unitId, bravery, bravery, sanity, sanity))
end

---Remove unit from tracking
---@param unitId string Unit identifier
function MoraleSystem.removeUnit(unitId)
    psychStates[unitId] = nil
end

---Get psychological state for a unit
---@param unitId string Unit identifier
---@return PsychologicalState|nil state
function MoraleSystem.getState(unitId)
    return psychStates[unitId]
end

---Modify unit morale (loss from stress events)
---@param unitId string Unit identifier
---@param amount number Morale change (usually negative)
---@param reason string|nil Reason for change
function MoraleSystem.modifyMorale(unitId, amount, reason)
    local state = psychStates[unitId]
    if not state then
        print(string.format("[MoraleSystem] WARNING: Unit %s not initialized", unitId))
        return
    end
    
    local oldMorale = state.morale
    state.morale = math.max(0, math.min(state.maxMorale, state.morale + amount))
    
    print(string.format("[MoraleSystem] %s morale: %d -> %d (%s%d, %s)",
        unitId, oldMorale, state.morale,
        amount >= 0 and "+" or "", amount, reason or "unknown"))
    
    MoraleSystem.updateState(state)
end

---Modify unit sanity (loss from missions, recovery from base time)
---@param unitId string Unit identifier
---@param amount number Sanity change (negative for loss, positive for recovery)
---@param reason string|nil Reason for change
function MoraleSystem.modifySanity(unitId, amount, reason)
    local state = psychStates[unitId]
    if not state then
        print(string.format("[MoraleSystem] WARNING: Unit %s not initialized", unitId))
        return
    end
    
    local oldSanity = state.sanity
    state.sanity = math.max(0, math.min(state.maxSanity, state.sanity + amount))
    
    print(string.format("[MoraleSystem] %s sanity: %d -> %d (%s%d, %s)",
        unitId, oldSanity, state.sanity,
        amount >= 0 and "+" or "", amount, reason or "unknown"))
    
    MoraleSystem.updateState(state)
end

---Update psychological state based on morale/sanity values
---@param state PsychologicalState
function MoraleSystem.updateState(state)
    -- Panic if EITHER morale OR sanity reaches 0
    if state.morale == 0 or state.sanity == 0 then
        state.state = "panicked"
        print(string.format("[MoraleSystem] %s PANICKED (morale=%d, sanity=%d)", 
            state.unitId, state.morale, state.sanity))
    elseif state.morale <= 2 or state.sanity <= 2 then
        -- Stressed but functional
        state.state = "stressed"
    else
        state.state = "normal"
    end
end

---Get AP modifier based on morale/sanity
---Returns AP penalty that should be applied to unit
---@param unitId string Unit identifier
---@return number modifier (negative = AP penalty)
function MoraleSystem.getAPModifier(unitId)
    local state = psychStates[unitId]
    if not state then return 0 end
    
    local cfg = MoraleSystem.CONFIG
    local minMoraleSanity = math.min(state.morale, state.sanity)
    
    if minMoraleSanity <= cfg.AP_MODIFIER_THRESHOLD_1 then
        return -2  -- -2 AP
    elseif minMoraleSanity <= cfg.AP_MODIFIER_THRESHOLD_2 then
        return -1  -- -1 AP
    else
        return 0   -- No modifier
    end
end

---Check if unit can act (not panicked)
---@param unitId string Unit identifier
---@return boolean canAct
---@return string|nil reason
function MoraleSystem.canAct(unitId)
    local state = psychStates[unitId]
    if not state then return true end
    
    if state.state == "panicked" then
        return false, "Panicked - unit inactive"
    end
    
    return true
end

---Process ally death - applies morale loss to nearby units
---@param deadUnitId string Dead unit ID
---@param deadUnitTeam string Dead unit team
function MoraleSystem.processAllyDeath(deadUnitId, deadUnitTeam)
    local cfg = MoraleSystem.CONFIG
    
    for unitId, state in pairs(psychStates) do
        -- Only affect living allies
        if state.unitId ~= deadUnitId and unitId ~= deadUnitId then
            MoraleSystem.modifyMorale(unitId, -cfg.ALLY_DEATH_MORALE_LOSS, "ally death")
        end
    end
end

---Process critical hit - applies morale loss to hit unit
---@param targetUnitId string Target unit ID
function MoraleSystem.processCriticalHit(targetUnitId)
    local cfg = MoraleSystem.CONFIG
    MoraleSystem.modifyMorale(targetUnitId, -cfg.CRITICAL_HIT_MORALE_LOSS, "critical hit")
end

---Apply post-mission sanity loss
---@param unitId string Unit identifier
---@param missionDifficulty string "standard", "moderate", "hard", "horror"
---@param isNightMission boolean Whether mission was at night
---@param alliesKIA number Number of allies that died
function MoraleSystem.applyPostMissionSanityLoss(unitId, missionDifficulty, isNightMission, alliesKIA)
    local cfg = MoraleSystem.CONFIG
    local totalLoss = 0
    
    -- Base sanity loss by difficulty
    if missionDifficulty == "moderate" then
        totalLoss = cfg.SANITY_LOSS_MODERATE
    elseif missionDifficulty == "hard" or missionDifficulty == "horror" then
        totalLoss = cfg.SANITY_LOSS_HARD
    else
        totalLoss = cfg.SANITY_LOSS_STANDARD
    end
    
    -- Night mission penalty
    if isNightMission then
        totalLoss = totalLoss + cfg.SANITY_LOSS_NIGHT_MISSION
    end
    
    -- Per-ally penalty
    totalLoss = totalLoss + (alliesKIA or 0) * cfg.SANITY_LOSS_PER_ALLY_KIA
    
    if totalLoss > 0 then
        MoraleSystem.modifySanity(unitId, -totalLoss, 
            string.format("post-mission (%s, night=%s, KIA=%d)", missionDifficulty, 
                tostring(isNightMission), alliesKIA or 0))
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
    
    print(string.format("[MoraleSystem] %s rallied %s (+%d morale)", 
        unitId, target, cfg.RALLY_MORALE_RESTORE))
    
    return true
end

---Apply leader aura bonus (per turn)
---@param leaderUnitId string Leader unit ID
---@param nearbyUnitIds table List of nearby unit IDs
function MoraleSystem.applyLeadershipBonus(leaderUnitId, nearbyUnitIds)
    local cfg = MoraleSystem.CONFIG
    
    for _, unitId in ipairs(nearbyUnitIds) do
        if unitId ~= leaderUnitId then
            MoraleSystem.modifyMorale(unitId, cfg.LEADER_MORALE_BONUS, "leader aura")
        end
    end
end

---Get morale/sanity color for UI display
---@param value number Current value (0-12)
---@param maxValue number Max value (0-12)
---@return table rgb {r, g, b}
function MoraleSystem.getStateColor(value, maxValue)
    local ratio = value / maxValue
    
    if ratio >= 0.75 then
        return {0.4, 1.0, 0.4}  -- Green
    elseif ratio >= 0.5 then
        return {1.0, 1.0, 0.4}  -- Yellow
    elseif ratio >= 0.25 then
        return {1.0, 0.6, 0.2}  -- Orange
    else
        return {1.0, 0.2, 0.2}  -- Red
    end
end

---Get state string for display
---@param unitId string Unit identifier
---@return string stateString "NORMAL", "STRESSED", "PANICKED", or "UNKNOWN"
function MoraleSystem.getStateString(unitId)
    local state = psychStates[unitId]
    if not state then return "UNKNOWN" end
    
    if state.state == "panicked" then
        return "PANICKED"
    elseif state.state == "stressed" then
        return "STRESSED"
    else
        return "NORMAL"
    end
end

---Configure system parameters
---@param config table Configuration overrides
function MoraleSystem.configure(config)
    for k, v in pairs(config) do
        if MoraleSystem.CONFIG[k] ~= nil then
            MoraleSystem.CONFIG[k] = v
            print(string.format("[MoraleSystem] Config: %s = %s", k, tostring(v)))
        end
    end
end

---Reset entire system
function MoraleSystem.reset()
    psychStates = {}
    print("[MoraleSystem] System reset")
end

return MoraleSystem






















