---Morale Actions System
---
---Provides player-initiated actions to restore and boost morale during combat.
---Includes Rest action, Leader Rally, and Leader Aura passive effect.
---
---Key Features:
---  - Rest Action: 2 AP → +1 morale (self-recovery)
---  - Leader Rally: 4 AP → +2 morale to target within 5 hexes (requires Leadership trait)
---  - Leader Aura: +1 morale/turn to units within 8 hexes (passive, always active)
---
---Key Exports:
---  - MoraleActions.restAction(unitId, battleState): Rest to restore morale
---  - MoraleActions.leaderRally(leaderId, targetId, battleState): Rally nearby ally
---  - MoraleActions.applyLeaderAura(battleState): Apply passive morale boost
---
---Dependencies:
---  - battlescape.systems.morale_system: Morale modification
---  - battlescape.combat.unit: Unit actions and traits
---
---@module battlescape.morale_actions
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local MoraleActions = {}

-- Configuration
MoraleActions.CONFIG = {
    REST_AP_COST = 2,
    REST_MORALE_GAIN = 1,

    RALLY_AP_COST = 4,
    RALLY_MORALE_GAIN = 2,
    RALLY_RANGE = 5,  -- hexes

    AURA_RANGE = 8,  -- hexes
    AURA_MORALE_GAIN = 1,
}

---Rest Action: Unit composes themselves to restore morale
---Cost: 2 AP, Effect: +1 morale
---@param unitId string Unit performing rest
---@param battleState table Current battle state
---@return boolean success
---@return string|nil reason
function MoraleActions.restAction(unitId, battleState)
    local cfg = MoraleActions.CONFIG

    -- Get unit
    local unit = battleState:getUnit(unitId)
    if not unit then
        return false, "Unit not found"
    end

    -- Check AP availability
    if unit.action_points < cfg.REST_AP_COST then
        return false, "Insufficient AP (need " .. cfg.REST_AP_COST .. ")"
    end

    -- Check morale (cannot rest if already at max)
    local MoraleSystem = require("engine.battlescape.systems.morale_system")
    local state = MoraleSystem.getState(unitId)
    if not state then
        return false, "Unit not initialized in morale system"
    end

    if state.morale >= state.maxMorale then
        return false, "Morale already at maximum"
    end

    -- Consume AP
    unit.action_points = unit.action_points - cfg.REST_AP_COST

    -- Restore morale
    MoraleSystem.modifyMorale(unitId, cfg.REST_MORALE_GAIN, "rest action")

    print(string.format("[MoraleActions] %s used Rest action: -2 AP, +1 morale", unitId))
    return true
end

---Leader Rally: Leader boosts morale of nearby ally
---Cost: 4 AP, Effect: +2 morale to target within 5 hexes
---Requirement: Leader must have "Leadership" trait
---@param leaderId string Unit performing rally
---@param targetId string Unit receiving morale boost
---@param battleState table Current battle state
---@return boolean success
---@return string|nil reason
function MoraleActions.leaderRally(leaderId, targetId, battleState)
    local cfg = MoraleActions.CONFIG

    -- Get leader unit
    local leader = battleState:getUnit(leaderId)
    if not leader then
        return false, "Leader not found"
    end

    -- Check if leader has Leadership trait
    local hasLeadership = false
    if leader.traits then
        for _, trait in ipairs(leader.traits) do
            if trait == "leadership" or trait == "Leadership" then
                hasLeadership = true
                break
            end
        end
    end

    if not hasLeadership then
        return false, "Unit does not have Leadership trait"
    end

    -- Check AP availability
    if leader.action_points < cfg.RALLY_AP_COST then
        return false, "Insufficient AP (need " .. cfg.RALLY_AP_COST .. ")"
    end

    -- Get target unit
    local target = battleState:getUnit(targetId)
    if not target then
        return false, "Target not found"
    end

    -- Check range (leader and target must be within 5 hexes)
    local distance = battleState:getDistance(leader.position, target.position)
    if distance > cfg.RALLY_RANGE then
        return false, "Target out of range (max " .. cfg.RALLY_RANGE .. " hexes)"
    end

    -- Check target morale
    local MoraleSystem = require("engine.battlescape.systems.morale_system")
    local targetState = MoraleSystem.getState(targetId)
    if not targetState then
        return false, "Target not initialized in morale system"
    end

    if targetState.morale >= targetState.maxMorale then
        return false, "Target morale already at maximum"
    end

    -- Consume AP
    leader.action_points = leader.action_points - cfg.RALLY_AP_COST

    -- Rally target
    MoraleSystem.modifyMorale(targetId, cfg.RALLY_MORALE_GAIN, "leader rally")

    print(string.format("[MoraleActions] %s rallied %s: -4 AP, +2 morale to target", leaderId, targetId))
    return true
end

---Apply Leader Aura: Passive morale boost to nearby units
---Effect: +1 morale/turn to units within 8 hexes of any leader
---Called automatically at start of player turn
---@param battleState table Current battle state
---@return number unitsAffected Number of units that received aura boost
function MoraleActions.applyLeaderAura(battleState)
    local cfg = MoraleActions.CONFIG
    local MoraleSystem = require("engine.battlescape.systems.morale_system")

    -- Find all leaders
    local leaders = {}
    local allUnits = battleState:getAllUnits()

    for _, unit in ipairs(allUnits) do
        if unit.team == "player" and unit.traits then
            for _, trait in ipairs(unit.traits) do
                if trait == "leadership" or trait == "Leadership" then
                    table.insert(leaders, unit)
                    break
                end
            end
        end
    end

    if #leaders == 0 then
        return 0  -- No leaders, no aura
    end

    -- Find all player units within range of any leader
    local affectedUnits = {}
    local unitsAffected = 0

    for _, unit in ipairs(allUnits) do
        if unit.team == "player" then
            -- Check if within range of any leader
            for _, leader in ipairs(leaders) do
                if unit.id ~= leader.id then  -- Don't affect leader themselves
                    local distance = battleState:getDistance(leader.position, unit.position)
                    if distance <= cfg.AURA_RANGE then
                        -- Check if already in affected list
                        if not affectedUnits[unit.id] then
                            affectedUnits[unit.id] = true

                            -- Apply morale boost
                            local state = MoraleSystem.getState(unit.id)
                            if state and state.morale < state.maxMorale then
                                MoraleSystem.modifyMorale(unit.id, cfg.AURA_MORALE_GAIN, "leader aura")
                                unitsAffected = unitsAffected + 1
                            end
                        end
                        break  -- Unit is affected, no need to check other leaders
                    end
                end
            end
        end
    end

    if unitsAffected > 0 then
        print(string.format("[MoraleActions] Leader aura affected %d units (+1 morale each)", unitsAffected))
    end

    return unitsAffected
end

---Get units within leader aura range (for UI display)
---@param leaderId string Leader unit ID
---@param battleState table Current battle state
---@return table units Array of units within aura range
function MoraleActions.getAuraUnits(leaderId, battleState)
    local cfg = MoraleActions.CONFIG

    local leader = battleState:getUnit(leaderId)
    if not leader then return {} end

    local auraUnits = {}
    local allUnits = battleState:getAllUnits()

    for _, unit in ipairs(allUnits) do
        if unit.team == "player" and unit.id ~= leaderId then
            local distance = battleState:getDistance(leader.position, unit.position)
            if distance <= cfg.AURA_RANGE then
                table.insert(auraUnits, unit)
            end
        end
    end

    return auraUnits
end

---Check if unit can use Rest action
---@param unitId string Unit ID
---@param battleState table Current battle state
---@return boolean canRest
---@return string|nil reason
function MoraleActions.canRest(unitId, battleState)
    local cfg = MoraleActions.CONFIG

    local unit = battleState:getUnit(unitId)
    if not unit then
        return false, "Unit not found"
    end

    if unit.action_points < cfg.REST_AP_COST then
        return false, "Insufficient AP"
    end

    local MoraleSystem = require("engine.battlescape.systems.morale_system")
    local state = MoraleSystem.getState(unitId)
    if not state then
        return false, "Unit not initialized"
    end

    if state.morale >= state.maxMorale then
        return false, "Morale at maximum"
    end

    return true
end

---Check if leader can rally target
---@param leaderId string Leader unit ID
---@param targetId string Target unit ID
---@param battleState table Current battle state
---@return boolean canRally
---@return string|nil reason
function MoraleActions.canRally(leaderId, targetId, battleState)
    local cfg = MoraleActions.CONFIG

    local leader = battleState:getUnit(leaderId)
    if not leader then
        return false, "Leader not found"
    end

    -- Check Leadership trait
    local hasLeadership = false
    if leader.traits then
        for _, trait in ipairs(leader.traits) do
            if trait == "leadership" or trait == "Leadership" then
                hasLeadership = true
                break
            end
        end
    end

    if not hasLeadership then
        return false, "No Leadership trait"
    end

    if leader.action_points < cfg.RALLY_AP_COST then
        return false, "Insufficient AP"
    end

    local target = battleState:getUnit(targetId)
    if not target then
        return false, "Target not found"
    end

    local distance = battleState:getDistance(leader.position, target.position)
    if distance > cfg.RALLY_RANGE then
        return false, "Out of range"
    end

    local MoraleSystem = require("engine.battlescape.systems.morale_system")
    local targetState = MoraleSystem.getState(targetId)
    if not targetState then
        return false, "Target not initialized"
    end

    if targetState.morale >= targetState.maxMorale then
        return false, "Target morale at maximum"
    end

    return true
end

return MoraleActions

