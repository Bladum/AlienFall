---@meta

---Action Points Regeneration System
---Handles AP/EP regeneration for turn-based and real-time contexts
---@module regen_system

local RegenSystem = {}

-- Configuration constants
RegenSystem.CONFIG = {
    -- Turn-based regeneration
    TURN_AP_RESTORE = "full", -- "full" or number
    TURN_EP_RESTORE = "full", -- "full" or number
    
    -- Out-of-combat regeneration (per 5 seconds)
    OOC_AP_REGEN = 1,
    OOC_EP_REGEN = 2,
    OOC_CHECK_INTERVAL = 5.0, -- seconds
    
    -- Injury penalties
    INJURED_AP_MULT = 0.5, -- 50% regen when below 50% HP
    INJURED_EP_MULT = 0.5,
    INJURED_THRESHOLD = 0.5, -- Below 50% HP counts as injured
    
    -- Exhaustion system
    EXHAUSTION_THRESHOLD = 0.25, -- Below 25% EP counts as exhausted
    EXHAUSTION_AP_MULT = 0.5, -- 50% AP regen when exhausted
    EXHAUSTION_EP_MULT = 1.5, -- 150% EP regen when exhausted (recover faster)
    
    -- Combat status
    COMBAT_DURATION = 10.0, -- seconds after last combat action
}

-- Private state tracking
local lastCombatTime = {} -- unitId -> timestamp
local regenTimers = {} -- unitId -> timer

---Initialize regeneration for a unit
---@param unitId string Unit identifier
function RegenSystem.initUnit(unitId)
    lastCombatTime[unitId] = 0
    regenTimers[unitId] = 0
end

---Remove unit from regeneration tracking
---@param unitId string Unit identifier
function RegenSystem.removeUnit(unitId)
    lastCombatTime[unitId] = nil
    regenTimers[unitId] = nil
end

---Mark unit as entering combat
---@param unitId string Unit identifier
function RegenSystem.enterCombat(unitId)
    lastCombatTime[unitId] = love.timer.getTime()
end

---Check if unit is in combat
---@param unitId string Unit identifier
---@return boolean inCombat
function RegenSystem.isInCombat(unitId)
    local lastTime = lastCombatTime[unitId] or 0
    local currentTime = love.timer.getTime()
    return (currentTime - lastTime) < RegenSystem.CONFIG.COMBAT_DURATION
end

---Restore AP/EP at turn start (turn-based mode)
---@param unit table Unit object with ap, ep, maxAP, maxEP fields
function RegenSystem.restoreTurnBased(unit)
    local cfg = RegenSystem.CONFIG
    
    -- Restore AP
    if cfg.TURN_AP_RESTORE == "full" then
        unit.ap = unit.maxAP or 12
    else
        unit.ap = math.min((unit.ap or 0) + cfg.TURN_AP_RESTORE, unit.maxAP or 12)
    end
    
    -- Restore EP
    if cfg.TURN_EP_RESTORE == "full" then
        unit.ep = unit.maxEP or 50
    else
        unit.ep = math.min((unit.ep or 0) + cfg.TURN_EP_RESTORE, unit.maxEP or 50)
    end
    
    print(string.format("[RegenSystem] Turn restore for %s: AP=%d/%d, EP=%d/%d", 
        unit.id or "unknown", unit.ap, unit.maxAP or 12, unit.ep, unit.maxEP or 50))
end

---Update out-of-combat regeneration (real-time mode)
---@param unit table Unit object
---@param dt number Delta time in seconds
function RegenSystem.updateRealTime(unit, dt)
    local unitId = unit.id
    if not unitId then return end
    
    -- Initialize if needed
    if not regenTimers[unitId] then
        RegenSystem.initUnit(unitId)
    end
    
    -- Check if in combat
    if RegenSystem.isInCombat(unitId) then
        regenTimers[unitId] = 0
        return
    end
    
    -- Accumulate time
    regenTimers[unitId] = regenTimers[unitId] + dt
    
    -- Check if regen interval reached
    if regenTimers[unitId] >= RegenSystem.CONFIG.OOC_CHECK_INTERVAL then
        regenTimers[unitId] = regenTimers[unitId] - RegenSystem.CONFIG.OOC_CHECK_INTERVAL
        
        -- Apply regeneration
        RegenSystem.applyOutOfCombatRegen(unit)
    end
end

---Apply out-of-combat regeneration
---@param unit table Unit object
function RegenSystem.applyOutOfCombatRegen(unit)
    local cfg = RegenSystem.CONFIG
    
    -- Calculate multipliers
    local apMult, epMult = RegenSystem.calculateRegenMultipliers(unit)
    
    -- Regenerate AP
    local apRegen = cfg.OOC_AP_REGEN * apMult
    unit.ap = math.min((unit.ap or 0) + apRegen, unit.maxAP or 12)
    
    -- Regenerate EP
    local epRegen = cfg.OOC_EP_REGEN * epMult
    unit.ep = math.min((unit.ep or 0) + epRegen, unit.maxEP or 50)
    
    print(string.format("[RegenSystem] OOC regen for %s: +%.1f AP, +%.1f EP (mult: %.1f AP, %.1f EP)", 
        unit.id or "unknown", apRegen, epRegen, apMult, epMult))
end

---Calculate regeneration multipliers based on unit state
---@param unit table Unit object
---@return number apMultiplier, number epMultiplier
function RegenSystem.calculateRegenMultipliers(unit)
    local cfg = RegenSystem.CONFIG
    local apMult = 1.0
    local epMult = 1.0
    
    -- Injury penalty
    local hpRatio = (unit.hp or 10) / (unit.maxHP or 10)
    if hpRatio < cfg.INJURED_THRESHOLD then
        apMult = apMult * cfg.INJURED_AP_MULT
        epMult = epMult * cfg.INJURED_EP_MULT
    end
    
    -- Exhaustion modifier
    local epRatio = (unit.ep or 50) / (unit.maxEP or 50)
    if epRatio < cfg.EXHAUSTION_THRESHOLD then
        apMult = apMult * cfg.EXHAUSTION_AP_MULT
        epMult = epMult * cfg.EXHAUSTION_EP_MULT
    end
    
    return apMult, epMult
end

---Get regeneration info for UI display
---@param unit table Unit object
---@return table info {apRegen, epRegen, apMult, epMult, isInjured, isExhausted, inCombat}
function RegenSystem.getRegenInfo(unit)
    local cfg = RegenSystem.CONFIG
    local apMult, epMult = RegenSystem.calculateRegenMultipliers(unit)
    
    local hpRatio = (unit.hp or 10) / (unit.maxHP or 10)
    local epRatio = (unit.ep or 50) / (unit.maxEP or 50)
    
    return {
        apRegen = cfg.OOC_AP_REGEN * apMult,
        epRegen = cfg.OOC_EP_REGEN * epMult,
        apMult = apMult,
        epMult = epMult,
        isInjured = hpRatio < cfg.INJURED_THRESHOLD,
        isExhausted = epRatio < cfg.EXHAUSTION_THRESHOLD,
        inCombat = RegenSystem.isInCombat(unit.id),
    }
end

---Configure regeneration parameters
---@param config table Configuration overrides
function RegenSystem.configure(config)
    for k, v in pairs(config) do
        if RegenSystem.CONFIG[k] ~= nil then
            RegenSystem.CONFIG[k] = v
            print(string.format("[RegenSystem] Config: %s = %s", k, tostring(v)))
        end
    end
end

---Reset all tracked units
function RegenSystem.reset()
    lastCombatTime = {}
    regenTimers = {}
    print("[RegenSystem] Reset all tracking")
end

return RegenSystem

























