---@meta

---Reaction Fire & Overwatch System
---Handles overwatch mode, interrupt mechanics, reserved AP for reactions
---@module reaction_fire_system

local ReactionFireSystem = {}

---@class OverwatchState
---@field unitId string
---@field isActive boolean Overwatch currently active
---@field reservedAP number AP reserved for reaction shots
---@field watchSectors table List of {q, r, radius} watched areas
---@field triggerConditions table Conditions that trigger reaction {movement=bool, shooting=bool, opening_door=bool}
---@field fireMode string Fire mode for reactions (default "SNAP")
---@field remainingShots number Shots remaining this turn
---@field reactedThisTurn table List of unitIds already reacted to

-- Configuration
ReactionFireSystem.CONFIG = {
    -- AP costs
    OVERWATCH_ENABLE_AP = 2, -- Cost to enter overwatch
    REACTION_SHOT_AP = 3, -- AP cost per reaction shot (usually SNAP)
    
    -- Limits
    MAX_REACTIONS_PER_TURN = 3, -- Maximum reaction shots per turn
    MAX_WATCH_RADIUS = 15, -- Maximum overwatch radius
    
    -- Accuracy modifiers
    REACTION_ACCURACY_MULT = 0.8, -- 80% accuracy for reaction shots
    
    -- Trigger delays (for animation/gameplay feel)
    REACTION_DELAY = 0.2, -- seconds before reaction fires
}

-- Private state
local overwatchStates = {} -- unitId -> OverwatchState

---Initialize overwatch state for a unit
---@param unitId string Unit identifier
function ReactionFireSystem.initUnit(unitId)
    overwatchStates[unitId] = {
        unitId = unitId,
        isActive = false,
        reservedAP = 0,
        watchSectors = {},
        triggerConditions = {
            movement = true,
            shooting = false,
            opening_door = false,
        },
        fireMode = "SNAP",
        remainingShots = ReactionFireSystem.CONFIG.MAX_REACTIONS_PER_TURN,
        reactedThisTurn = {},
    }
end

---Remove unit from overwatch tracking
---@param unitId string Unit identifier
function ReactionFireSystem.removeUnit(unitId)
    overwatchStates[unitId] = nil
end

---Enter overwatch mode
---@param unitId string Unit entering overwatch
---@param unit table Unit object (for AP)
---@param watchQ number Center Q of watch area
---@param watchR number Center R of watch area
---@param radius number Watch radius
---@return boolean success, string|nil reason
function ReactionFireSystem.enterOverwatch(unitId, unit, watchQ, watchR, radius)
    local cfg = ReactionFireSystem.CONFIG
    local state = overwatchStates[unitId]
    
    if not state then
        ReactionFireSystem.initUnit(unitId)
        state = overwatchStates[unitId]
    end
    
    -- Check AP
    if unit.ap < cfg.OVERWATCH_ENABLE_AP then
        return false, "Not enough AP"
    end
    
    -- Validate radius
    if radius > cfg.MAX_WATCH_RADIUS then
        return false, "Watch radius too large"
    end
    
    -- Reserve AP for reaction shots
    local shotsAvailable = math.floor((unit.ap - cfg.OVERWATCH_ENABLE_AP) / cfg.REACTION_SHOT_AP)
    if shotsAvailable < 1 then
        return false, "Not enough AP for reaction shots"
    end
    
    -- Consume overwatch activation AP
    unit.ap = unit.ap - cfg.OVERWATCH_ENABLE_AP
    
    -- Set up overwatch
    state.isActive = true
    state.reservedAP = shotsAvailable * cfg.REACTION_SHOT_AP
    state.watchSectors = {{q = watchQ, r = watchR, radius = radius}}
    state.remainingShots = math.min(shotsAvailable, cfg.MAX_REACTIONS_PER_TURN)
    state.reactedThisTurn = {}
    
    print(string.format("[Reaction] %s entered overwatch: %d shots available, watching (%d,%d) radius %d", 
        unitId, state.remainingShots, watchQ, watchR, radius))
    
    return true
end

---Exit overwatch mode (return reserved AP)
---@param unitId string Unit identifier
---@param unit table Unit object
function ReactionFireSystem.exitOverwatch(unitId, unit)
    local state = overwatchStates[unitId]
    if not state or not state.isActive then return end
    
    -- Return reserved AP
    unit.ap = unit.ap + state.reservedAP
    
    -- Clear overwatch
    state.isActive = false
    state.reservedAP = 0
    state.watchSectors = {}
    state.remainingShots = 0
    state.reactedThisTurn = {}
    
    print(string.format("[Reaction] %s exited overwatch, returned %d AP", unitId, state.reservedAP))
end

---Configure overwatch triggers
---@param unitId string Unit identifier
---@param triggers table {movement=bool, shooting=bool, opening_door=bool}
function ReactionFireSystem.setTriggers(unitId, triggers)
    local state = overwatchStates[unitId]
    if not state then return end
    
    for k, v in pairs(triggers) do
        state.triggerConditions[k] = v
    end
    
    print(string.format("[Reaction] %s triggers: movement=%s, shooting=%s, doors=%s", 
        unitId, 
        tostring(state.triggerConditions.movement),
        tostring(state.triggerConditions.shooting),
        tostring(state.triggerConditions.opening_door)))
end

---Set fire mode for reactions
---@param unitId string Unit identifier
---@param fireMode string Fire mode (SNAP, AIM, AUTO, etc.)
function ReactionFireSystem.setFireMode(unitId, fireMode)
    local state = overwatchStates[unitId]
    if not state then return end
    
    state.fireMode = fireMode
    print(string.format("[Reaction] %s reaction mode: %s", unitId, fireMode))
end

---Check if a target's action should trigger reaction
---@param observerUnitId string Observer (overwatch unit)
---@param targetUnitId string Target performing action
---@param actionType string Action type (movement, shooting, opening_door)
---@param targetQ number Target Q position
---@param targetR number Target R position
---@return boolean shouldReact
function ReactionFireSystem.checkTrigger(observerUnitId, targetUnitId, actionType, targetQ, targetR)
    local state = overwatchStates[observerUnitId]
    if not state or not state.isActive then return false end
    
    -- Check if we have shots remaining
    if state.remainingShots <= 0 then return false end
    
    -- Check if already reacted to this unit this turn
    for _, reactedId in ipairs(state.reactedThisTurn) do
        if reactedId == targetUnitId then
            return false
        end
    end
    
    -- Check if this action type triggers reaction
    if not state.triggerConditions[actionType] then return false end
    
    -- Check if target is in watched sector
    for _, sector in ipairs(state.watchSectors) do
        local distance = ReactionFireSystem.calculateDistance(
            sector.q, sector.r, targetQ, targetR
        )
        
        if distance <= sector.radius then
            print(string.format("[Reaction] %s triggered by %s %s at (%d,%d)", 
                observerUnitId, targetUnitId, actionType, targetQ, targetR))
            return true
        end
    end
    
    return false
end

---Execute reaction fire
---@param observerUnit table Observer unit (shooter)
---@param targetUnit table Target unit
---@param shootingSystem table Shooting system reference
---@return boolean success, table|nil result
function ReactionFireSystem.executeReaction(observerUnit, targetUnit, shootingSystem)
    local cfg = ReactionFireSystem.CONFIG
    local state = overwatchStates[observerUnit.id]
    
    if not state or not state.isActive or state.remainingShots <= 0 then
        return false, nil
    end
    
    -- Consume reaction shot
    state.remainingShots = state.remainingShots - 1
    state.reservedAP = state.reservedAP - cfg.REACTION_SHOT_AP
    
    -- Mark this target as reacted to
    table.insert(state.reactedThisTurn, targetUnit.id)
    
    print(string.format("[Reaction] %s firing reaction at %s (shots remaining: %d)", 
        observerUnit.id, targetUnit.id, state.remainingShots))
    
    -- Fire shot with accuracy penalty
    local result = shootingSystem.shoot(
        observerUnit, 
        targetUnit, 
        state.fireMode,
        cfg.REACTION_ACCURACY_MULT -- Accuracy modifier
    )
    
    -- Check if out of shots - exit overwatch
    if state.remainingShots <= 0 then
        print(string.format("[Reaction] %s out of reaction shots, exiting overwatch", observerUnit.id))
        ReactionFireSystem.exitOverwatch(observerUnit.id, observerUnit)
    end
    
    return true, result
end

---Process movement trigger (call when unit moves)
---@param movingUnit table Unit that moved
---@param fromQ number Previous Q
---@param fromR number Previous R
---@param toQ number New Q
---@param toR number New R
---@param allUnits table All units on map
---@param shootingSystem table Shooting system reference
function ReactionFireSystem.processMovementTrigger(movingUnit, fromQ, fromR, toQ, toR, allUnits, shootingSystem)
    -- Check all units with active overwatch
    for _, unit in ipairs(allUnits) do
        if unit.id ~= movingUnit.id and unit.team ~= movingUnit.team then
            local shouldReact = ReactionFireSystem.checkTrigger(
                unit.id, movingUnit.id, "movement", toQ, toR
            )
            
            if shouldReact then
                -- TODO: Add interrupt/pause for reaction animation
                ReactionFireSystem.executeReaction(unit, movingUnit, shootingSystem)
            end
        end
    end
end

---Process shooting trigger (call when unit fires)
---@param shootingUnit table Unit that fired
---@param allUnits table All units on map
---@param shootingSystem table Shooting system reference
function ReactionFireSystem.processShootingTrigger(shootingUnit, allUnits, shootingSystem)
    -- Check all units with active overwatch
    for _, unit in ipairs(allUnits) do
        if unit.id ~= shootingUnit.id and unit.team ~= shootingUnit.team then
            local shouldReact = ReactionFireSystem.checkTrigger(
                unit.id, shootingUnit.id, "shooting", shootingUnit.q, shootingUnit.r
            )
            
            if shouldReact then
                ReactionFireSystem.executeReaction(unit, shootingUnit, shootingSystem)
            end
        end
    end
end

---Reset overwatch at turn end
---@param unitId string Unit identifier
function ReactionFireSystem.resetForNewTurn(unitId)
    local state = overwatchStates[unitId]
    if not state then return end
    
    -- Reset reaction counter
    local cfg = ReactionFireSystem.CONFIG
    state.remainingShots = cfg.MAX_REACTIONS_PER_TURN
    state.reactedThisTurn = {}
    
    print(string.format("[Reaction] %s overwatch reset for new turn", unitId))
end

---Get overwatch state for a unit
---@param unitId string Unit identifier
---@return OverwatchState|nil state
function ReactionFireSystem.getState(unitId)
    return overwatchStates[unitId]
end

---Check if unit is in overwatch
---@param unitId string Unit identifier
---@return boolean isInOverwatch
function ReactionFireSystem.isInOverwatch(unitId)
    local state = overwatchStates[unitId]
    return state and state.isActive or false
end

---Calculate hex distance
---@param q1 number Q1
---@param r1 number R1
---@param q2 number Q2
---@param r2 number R2
---@return number distance
function ReactionFireSystem.calculateDistance(q1, r1, q2, r2)
    local dq = math.abs(q2 - q1)
    local dr = math.abs(r2 - r1)
    local ds = math.abs((-q1 - r1) - (-q2 - r2))
    return math.floor((dq + dr + ds) / 2)
end

---Configure reaction fire system
---@param config table Configuration overrides
function ReactionFireSystem.configure(config)
    for k, v in pairs(config) do
        if ReactionFireSystem.CONFIG[k] ~= nil then
            ReactionFireSystem.CONFIG[k] = v
            print(string.format("[Reaction] Config: %s = %s", k, tostring(v)))
        end
    end
end

---Reset entire system
function ReactionFireSystem.reset()
    overwatchStates = {}
    print("[Reaction] System reset")
end

return ReactionFireSystem






















