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

    if minMoraleSanity == 0 then
        return -4  -- Panic: lose all AP
    elseif minMoraleSanity <= cfg.AP_MODIFIER_THRESHOLD_1 then
        return -2  -- -2 AP
    elseif minMoraleSanity <= cfg.AP_MODIFIER_THRESHOLD_2 then
        return -1  -- -1 AP
    else
        return 0   -- No modifier
    end
end

---Get morale accuracy penalty
---@param unitId string Unit identifier
---@return number penalty (0 to -50)
function MoraleSystem.getMoraleAccuracyPenalty(unitId)
    local state = psychStates[unitId]
    if not state then return 0 end

    -- Granular accuracy penalties based on morale
    if state.morale == 0 then return -50
    elseif state.morale == 1 then return -25
    elseif state.morale == 2 then return -15
    elseif state.morale == 3 then return -10
    elseif state.morale <= 5 then return -5
    else return 0
    end
end

---Get sanity accuracy penalty
---@param unitId string Unit identifier
---@return number penalty (0 to -25)
function MoraleSystem.getSanityAccuracyPenalty(unitId)
    local state = psychStates[unitId]
    if not state then return 0 end

    -- Sanity-based accuracy penalties
    if state.sanity <= 2 then return -25
    elseif state.sanity <= 4 then return -15
    elseif state.sanity <= 6 then return -10
    elseif state.sanity <= 9 then return -5
    else return 0
    end
end

---Get starting morale modifier from sanity
---@param unitId string Unit identifier
---@return number modifier (0 to -3)
function MoraleSystem.getSanityMoraleModifier(unitId)
    local state = psychStates[unitId]
    if not state then return 0 end

    -- Low sanity reduces starting morale
    if state.sanity <= 2 then return -3
    elseif state.sanity <= 4 then return -2
    elseif state.sanity <= 6 then return -1
    else return 0
    end
end

---Get morale status string
---@param unitId string Unit identifier
---@return string status
function MoraleSystem.getMoraleStatus(unitId)
    local state = psychStates[unitId]
    if not state then return "unknown" end

    if state.morale == 0 then return "panic"
    elseif state.morale == 1 then return "panicking"
    elseif state.morale == 2 then return "shaken"
    elseif state.morale == 3 then return "stressed"
    elseif state.morale <= 5 then return "steady"
    else return "confident"
    end
end

---Get sanity status string
---@param unitId string Unit identifier
---@return string status
function MoraleSystem.getSanityStatus(unitId)
    local state = psychStates[unitId]
    if not state then return "unknown" end

    if state.sanity == 0 then return "broken"
    elseif state.sanity <= 2 then return "unstable"
    elseif state.sanity <= 4 then return "breaking"
    elseif state.sanity <= 6 then return "fragile"
    elseif state.sanity <= 9 then return "strained"
    else return "stable"
    end
end

---Check if unit can deploy (sanity > 0)
---@param unitId string Unit identifier
---@return boolean canDeploy
---@return string|nil reason
function MoraleSystem.canDeploy(unitId)
    local state = psychStates[unitId]
    if not state then return true end

    if state.sanity == 0 then
        return false, "Unit is broken - requires psychological treatment"
    end

    return true
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

---MORALE EVENT: Ally killed nearby
---@param unitId string Unit observing death
---@param distance number Distance to death in hexes
function MoraleSystem.onAllyKilled(unitId, distance)
    local cfg = MoraleSystem.CONFIG
    if distance <= 5 then
        MoraleSystem.modifyMorale(unitId, -cfg.ALLY_DEATH_MORALE_LOSS, "ally death nearby")
    end
end

---MORALE EVENT: Unit takes damage
---@param unitId string Unit taking damage
function MoraleSystem.onTakeDamage(unitId)
    MoraleSystem.modifyMorale(unitId, -1, "taking damage")
end

---MORALE EVENT: Unit receives critical hit
---@param unitId string Unit receiving critical
function MoraleSystem.onCriticalHit(unitId)
    local cfg = MoraleSystem.CONFIG
    MoraleSystem.modifyMorale(unitId, -cfg.CRITICAL_HIT_MORALE_LOSS, "critical hit")
end

---MORALE EVENT: Unit is flanked by enemies
---@param unitId string Unit being flanked
function MoraleSystem.onFlanked(unitId)
    MoraleSystem.modifyMorale(unitId, -1, "flanked by enemies")
end

---MORALE EVENT: Unit is outnumbered 3:1
---@param unitId string Unit outnumbered
function MoraleSystem.onOutnumbered(unitId)
    MoraleSystem.modifyMorale(unitId, -1, "outnumbered")
end

---MORALE EVENT: Commander/leader killed
---@param unitId string Unit witnessing commander death
function MoraleSystem.onCommanderKilled(unitId)
    MoraleSystem.modifyMorale(unitId, -2, "commander killed")
end

---MORALE EVENT: First encounter with new alien type
---@param unitId string Unit encountering alien
---@param alienType string Type of alien
function MoraleSystem.onNewAlienEncounter(unitId, alienType)
    MoraleSystem.modifyMorale(unitId, -1, "new alien: " .. alienType)
end

---MORALE EVENT: Night mission starts
---@param unitId string Unit on night mission
function MoraleSystem.onNightMission(unitId)
    MoraleSystem.modifyMorale(unitId, -1, "night mission")
end

---Process ally death - applies morale loss to nearby units
---@param deadUnitId string Dead unit ID
---@param deadUnitTeam string Dead unit team
function MoraleSystem.processAllyDeath(deadUnitId, deadUnitTeam)
    local cfg = MoraleSystem.CONFIG

    for unitId, state in pairs(psychStates) do
        -- Only affect living allies (not the dead unit itself)
        if unitId ~= deadUnitId then
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

---Reset morale to bravery value (mission end)
---@param unitId string Unit identifier
function MoraleSystem.resetMorale(unitId)
    local state = psychStates[unitId]
    if not state then return end

    state.morale = state.maxMorale
    print(string.format("[MoraleSystem] %s morale reset to %d (mission end)", unitId, state.morale))
    MoraleSystem.updateState(state)
end

---Apply post-mission sanity loss
---@param unitId string Unit identifier
---@param missionDifficulty string "standard", "moderate", "hard", "horror"
---@param isNightMission boolean Whether mission was at night
---@param alliesKIA number Number of allies that died
---@param missionFailed boolean Whether mission failed
function MoraleSystem.applyMissionTrauma(unitId, missionDifficulty, isNightMission, alliesKilled, missionFailed)
    local cfg = MoraleSystem.CONFIG
    local loss = 0

    -- Base sanity loss by difficulty
    if missionDifficulty == "horror" then
        loss = loss + 3
    elseif missionDifficulty == "hard" then
        loss = loss + 2
    elseif missionDifficulty == "moderate" then
        loss = loss + 1
    -- standard = 0
    end

    -- Additional factors
    if isNightMission then
        loss = loss + cfg.SANITY_LOSS_NIGHT_MISSION
    end

    if alliesKilled and alliesKilled > 0 then
        loss = loss + (alliesKilled * cfg.SANITY_LOSS_PER_ALLY_KIA)
    end

    if missionFailed then
        loss = loss + 2
    end

    if loss > 0 then
        MoraleSystem.modifySanity(unitId, -loss, "mission trauma")
    end
end

---Weekly base sanity recovery (+1 per week)
---@param unitId string Unit identifier
function MoraleSystem.weeklyBaseRecovery(unitId)
    MoraleSystem.modifySanity(unitId, 1, "base recovery")
end

---Weekly Temple sanity bonus (+1 per week if Temple exists)
---@param unitId string Unit identifier
function MoraleSystem.weeklyTempleRecovery(unitId)
    MoraleSystem.modifySanity(unitId, 1, "temple bonus")
end

---Medical treatment for sanity (+3 immediate, costs 10K)
---@param unitId string Unit identifier
---@return boolean success
function MoraleSystem.medicalTreatment(unitId)
    MoraleSystem.modifySanity(unitId, 3, "medical treatment")
    print(string.format("[MoraleSystem] %s received medical treatment (+3 sanity, 10,000 credits)", unitId))
    return true
end

---Leave/vacation for sanity (+5 over 2 weeks, costs 5K)
---@param unitId string Unit identifier
---@return boolean success
function MoraleSystem.leaveVacation(unitId)
    MoraleSystem.modifySanity(unitId, 5, "leave/vacation")
    print(string.format("[MoraleSystem] %s on leave (+5 sanity, 5,000 credits)", unitId))
    return true
end

---Apply post-mission sanity loss
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

    -- Check if target exists
    if not psychStates[target] then
        print(string.format("[MoraleSystem] WARNING: Cannot rally unknown unit %s", target))
        return false
    end

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
        if unitId ~= leaderUnitId and psychStates[unitId] then
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
