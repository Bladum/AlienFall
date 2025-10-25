---Thermal & Heat Mechanics System for Interception Combat
---
---Manages weapon heat generation, dissipation, jamming, and accuracy penalties
---in craft-to-craft interception combat. Heat mechanics add tactical depth to
---combat by limiting sustained fire and encouraging tactical retreats/cooldowns.
---
---Features:
---  - Per-weapon heat accumulation and tracking
---  - Heat generation by weapon discharge and action type
---  - Heat dissipation over time (passive and active cooldown)
---  - Weapon jam mechanics when heat exceeds threshold
---  - Accuracy penalties based on heat level
---  - Thermal management strategies (alternating weapons, cooldown phases)
---  - Integration with interception combat system
---
---Heat Mechanics:
---  - Base heat generation: +5 to +20 per shot (by weapon type)
---  - Passive dissipation: -5 to -15 per turn
---  - Jam threshold: 100+ heat triggers weapon jam
---  - Accuracy penalty: -10% at 50+ heat, -20% at 75+ heat, -30% at 100+ heat
---  - Cooldown mode: -20/turn dissipation (doubles normal rate)
---  - Overheat recovery: 1-3 turns to recover after jam
---
---Weapon Categories:
---  - Light: +5 heat per shot, dissipates -15/turn (cool fast)
---  - Standard: +10 heat per shot, dissipates -10/turn (balanced)
---  - Heavy: +15 heat per shot, dissipates -5/turn (hot, powerful)
---  - Extreme: +20 heat per shot, dissipates -5/turn (very hot, rare)
---
---@module engine.interception.logic.thermal_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local ThermalSystem = {}
ThermalSystem.__index = ThermalSystem

---Configuration for thermal mechanics
local CONFIG = {
    -- Maximum heat points before forced cooldown
    maxHeat = 150,
    
    -- Jam threshold (weapon becomes jammed when exceeded)
    jamThreshold = 100,
    
    -- Heat generation by weapon type (per shot)
    heatGeneration = {
        light = 5,
        standard = 10,
        heavy = 15,
        extreme = 20
    },
    
    -- Heat dissipation rates
    dissipation = {
        passive = 10,           -- Normal dissipation per turn
        light = 15,             -- Light weapons cool faster
        heavy = 5,              -- Heavy weapons cool slower
        cooldown = 20,          -- Double dissipation in cooldown mode
    },
    
    -- Accuracy penalty thresholds
    accuracyPenalties = {
        {threshold = 50, penalty = 0.10},   -- 10% penalty at 50+ heat
        {threshold = 75, penalty = 0.20},   -- 20% penalty at 75+ heat
        {threshold = 100, penalty = 0.30},  -- 30% penalty at 100+ heat
    },
    
    -- Jam mechanics
    jam = {
        threshold = 100,        -- Heat level to trigger jam
        recoveryTime = 2,       -- Turns to recover from jam
        subsequentJamPenalty = 1.5,  -- Multiplier for damage after jam
    },
    
    -- Weapon type categories
    weaponTypes = {
        LIGHT = "light",
        STANDARD = "standard",
        HEAVY = "heavy",
        EXTREME = "extreme"
    }
}

---Create new thermal system instance
---@param combatSystem table Combat system reference for effects
---@return table New ThermalSystem instance
function ThermalSystem.new(combatSystem)
    local self = setmetatable({}, ThermalSystem)
    
    self.combatSystem = combatSystem
    
    -- Weapon heat levels: {weaponId: currentHeat}
    self.weaponHeat = {}
    
    -- Weapon jam status: {weaponId: {isJammed, recoveryTurnsRemaining}}
    self.weaponJamStatus = {}
    
    -- Weapon configurations: {weaponId: {type, heatGen, dissipationRate}}
    self.weaponConfig = {}
    
    -- Active cooldown mode: {weaponId: true/false}
    self.coolingWeapons = {}
    
    -- Heat history for debugging
    self.heatHistory = {}
    
    print("[ThermalSystem] Initialized with max heat: " .. CONFIG.maxHeat .. 
          ", jam threshold: " .. CONFIG.jamThreshold)
    
    return self
end

---Register a weapon for thermal tracking
---@param weaponId string Unique weapon identifier
---@param weaponType string Weapon category (light/standard/heavy/extreme)
---@param heatGeneration number|nil Custom heat generation (overrides type default)
---@return boolean Success
function ThermalSystem:registerWeapon(weaponId, weaponType, heatGeneration)
    if not weaponId then
        print("[ThermalSystem] ERROR: weaponId required")
        return false
    end
    
    weaponType = weaponType or CONFIG.weaponTypes.STANDARD
    
    local heatGen = heatGeneration or CONFIG.heatGeneration[weaponType] or 10
    local dissipationRate = CONFIG.dissipation[weaponType] or CONFIG.dissipation.passive
    
    self.weaponConfig[weaponId] = {
        type = weaponType,
        baseHeatGeneration = heatGen,
        dissipationRate = dissipationRate,
        registeredAt = love.timer.getTime()
    }
    
    self.weaponHeat[weaponId] = 0
    self.weaponJamStatus[weaponId] = {isJammed = false, recoveryTurnsRemaining = 0}
    self.coolingWeapons[weaponId] = false
    
    print("[ThermalSystem] Registered weapon: " .. weaponId .. " (type: " .. weaponType .. 
          ", heat gen: " .. heatGen .. ", dissipation: " .. dissipationRate .. ")")
    
    return true
end

---Get current heat level of a weapon
---@param weaponId string Unique weapon identifier
---@return number|nil Heat value (0-150) or nil if not tracked
function ThermalSystem:getHeatLevel(weaponId)
    return self.weaponHeat[weaponId]
end

---Get heat as percentage
---@param weaponId string Unique weapon identifier
---@return number|nil Heat percentage (0-100) or nil if not tracked
function ThermalSystem:getHeatPercent(weaponId)
    local heat = self.weaponHeat[weaponId]
    if heat then
        return math.max(0, math.min(100, (heat / CONFIG.maxHeat) * 100))
    end
    return nil
end

---Check if a weapon is jammed
---@param weaponId string Unique weapon identifier
---@return boolean True if weapon is jammed
function ThermalSystem:isJammed(weaponId)
    local jamStatus = self.weaponJamStatus[weaponId]
    return jamStatus and jamStatus.isJammed or false
end

---Check if weapon can fire (not jammed, not overheating)
---@param weaponId string Unique weapon identifier
---@return boolean True if weapon can fire
---@return string|nil Reason why weapon cannot fire
function ThermalSystem:canFire(weaponId)
    if not self.weaponHeat[weaponId] then
        return false, "weapon_not_tracked"
    end
    
    if self:isJammed(weaponId) then
        return false, "weapon_jammed"
    end
    
    if self.weaponHeat[weaponId] >= CONFIG.jamThreshold then
        return false, "weapon_overheating"
    end
    
    return true, nil
end

---Get accuracy penalty due to heat
---@param weaponId string Unique weapon identifier
---@return number Accuracy multiplier (0.7 to 1.0, where 1.0 = no penalty)
function ThermalSystem:getAccuracyModifier(weaponId)
    local heat = self:getHeatLevel(weaponId)
    
    if not heat then
        return 1.0
    end
    
    local penalty = 0.0
    
    for _, penaltyConfig in ipairs(CONFIG.accuracyPenalties) do
        if heat >= penaltyConfig.threshold then
            penalty = penaltyConfig.penalty
        end
    end
    
    return math.max(0.7, 1.0 - penalty)
end

---Get thermal status string for UI
---@param weaponId string Unique weapon identifier
---@return string Status description
function ThermalSystem:getThermalStatus(weaponId)
    local heat = self:getHeatLevel(weaponId)
    
    if not heat then
        return "unknown"
    end
    
    if heat <= 25 then
        return "cold"
    elseif heat <= 50 then
        return "warm"
    elseif heat <= 75 then
        return "hot"
    elseif heat <= 100 then
        return "very_hot"
    elseif heat <= 150 then
        return "critical"
    else
        return "dangerous"
    end
end

---Add heat to a weapon (fire action)
---@param weaponId string Unique weapon identifier
---@param shotsFired number|nil Number of shots (default 1)
---@param fireIntensity number|nil Intensity multiplier (0.5 to 2.0, default 1.0)
---@return boolean Success
---@return number|nil New heat level
---@return boolean Jammed (true if heat exceeded jam threshold)
function ThermalSystem:addHeat(weaponId, shotsFired, fireIntensity)
    local currentHeat = self.weaponHeat[weaponId]
    
    if not currentHeat then
        print("[ThermalSystem] WARNING: Weapon " .. weaponId .. " not tracked")
        return false, nil, false
    end
    
    shotsFired = shotsFired or 1
    fireIntensity = fireIntensity or 1.0
    fireIntensity = math.max(0.5, math.min(2.0, fireIntensity))
    
    local weaponConfig = self.weaponConfig[weaponId]
    local heatPerShot = weaponConfig.baseHeatGeneration * fireIntensity
    local totalHeatAdded = heatPerShot * shotsFired
    
    local newHeat = math.min(CONFIG.maxHeat, currentHeat + totalHeatAdded)
    self.weaponHeat[weaponId] = newHeat
    
    -- Check for jam
    local wasJammed = self:isJammed(weaponId)
    local isNowJammed = newHeat >= CONFIG.jamThreshold
    
    if not wasJammed and isNowJammed then
        self.weaponJamStatus[weaponId].isJammed = true
        self.weaponJamStatus[weaponId].recoveryTurnsRemaining = CONFIG.jam.recoveryTime
        
        print("[ThermalSystem] Weapon " .. weaponId .. " JAMMED! Heat: " .. 
              math.ceil(newHeat) .. "/" .. CONFIG.maxHeat .. ", recovery: " .. 
              CONFIG.jam.recoveryTime .. " turns")
    end
    
    -- Track history
    if not self.heatHistory[weaponId] then
        self.heatHistory[weaponId] = {}
    end
    
    table.insert(self.heatHistory[weaponId], {
        timestamp = love.timer.getTime(),
        shotsFired = shotsFired,
        fireIntensity = fireIntensity,
        heatAdded = totalHeatAdded,
        newHeat = newHeat,
        jammed = isNowJammed
    })
    
    return true, newHeat, isNowJammed
end

---Dissipate heat from a weapon (passive or active cooling)
---@param weaponId string Unique weapon identifier
---@param activeCooling boolean|nil True for active cooldown mode (faster dissipation)
---@return boolean Success
---@return number|nil New heat level
function ThermalSystem:dissipateHeat(weaponId, activeCooling)
    local currentHeat = self.weaponHeat[weaponId]
    
    if not currentHeat then
        print("[ThermalSystem] WARNING: Weapon " .. weaponId .. " not tracked")
        return false, nil
    end
    
    local dissipationRate = CONFIG.dissipation.passive
    
    if activeCooling then
        dissipationRate = CONFIG.dissipation.cooldown
        self.coolingWeapons[weaponId] = true
    else
        self.coolingWeapons[weaponId] = false
    end
    
    local newHeat = math.max(0, currentHeat - dissipationRate)
    self.weaponHeat[weaponId] = newHeat
    
    -- Check for unjam
    if self:isJammed(weaponId) then
        self.weaponJamStatus[weaponId].recoveryTurnsRemaining = 
            self.weaponJamStatus[weaponId].recoveryTurnsRemaining - 1
        
        if self.weaponJamStatus[weaponId].recoveryTurnsRemaining <= 0 then
            self.weaponJamStatus[weaponId].isJammed = false
            print("[ThermalSystem] Weapon " .. weaponId .. " unjammed! Heat: " .. 
                  math.ceil(newHeat) .. "/" .. CONFIG.maxHeat)
        end
    end
    
    return true, newHeat
end

---Process heat phase (update all weapons)
---@param weaponIds table Array of weapon IDs to process
---@param activeWeapon string|nil Currently active weapon (receives faster dissipation if cooling)
---@return table Heat status for all weapons {weaponId: {heat, status, jammed, accuracy}}
function ThermalSystem:processHeatPhase(weaponIds, activeWeapon)
    weaponIds = weaponIds or {}
    local status = {}
    
    for _, weaponId in ipairs(weaponIds) do
        if self.weaponHeat[weaponId] then
            local activeCooling = activeWeapon == weaponId and self.coolingWeapons[weaponId]
            
            self:dissipateHeat(weaponId, activeCooling)
            
            status[weaponId] = {
                heat = self.weaponHeat[weaponId],
                heatPercent = self:getHeatPercent(weaponId),
                thermalStatus = self:getThermalStatus(weaponId),
                jammed = self:isJammed(weaponId),
                accuracyModifier = self:getAccuracyModifier(weaponId),
                canFire = self:canFire(weaponId)
            }
        end
    end
    
    return status
end

---Enable active cooling for a weapon (uses a turn to cool down)
---@param weaponId string Unique weapon identifier
---@return boolean Success
function ThermalSystem:startActiveCooling(weaponId)
    if not self.weaponHeat[weaponId] then
        return false
    end
    
    self.coolingWeapons[weaponId] = true
    print("[ThermalSystem] Weapon " .. weaponId .. " entering active cooldown mode")
    
    return true
end

---Get thermal state of all weapons
---@return table State information {weapons: {weaponId: details}, summary: {avgHeat, hottest, coldest, jammedCount}}
function ThermalSystem:getThermalState()
    local state = {
        weapons = {},
        summary = {
            total = 0,
            avgHeat = 0,
            hottest = {weaponId = nil, heat = 0},
            coldest = {weaponId = nil, heat = CONFIG.maxHeat},
            jammedCount = 0,
            overheatCount = 0
        }
    }
    
    local totalHeat = 0
    
    for weaponId, heat in pairs(self.weaponHeat) do
        local jamStatus = self.weaponJamStatus[weaponId]
        
        state.weapons[weaponId] = {
            heat = heat,
            heatPercent = self:getHeatPercent(weaponId),
            thermalStatus = self:getThermalStatus(weaponId),
            jammed = jamStatus.isJammed,
            recoveryTurnsRemaining = jamStatus.recoveryTurnsRemaining,
            canFire = self:canFire(weaponId),
            accuracyModifier = self:getAccuracyModifier(weaponId),
            cooling = self.coolingWeapons[weaponId]
        }
        
        state.summary.total = state.summary.total + 1
        totalHeat = totalHeat + heat
        
        if heat > state.summary.hottest.heat then
            state.summary.hottest = {weaponId = weaponId, heat = heat}
        end
        
        if heat < state.summary.coldest.heat then
            state.summary.coldest = {weaponId = weaponId, heat = heat}
        end
        
        if jamStatus.isJammed then
            state.summary.jammedCount = state.summary.jammedCount + 1
        end
        
        if heat >= CONFIG.jamThreshold then
            state.summary.overheatCount = state.summary.overheatCount + 1
        end
    end
    
    if state.summary.total > 0 then
        state.summary.avgHeat = totalHeat / state.summary.total
    end
    
    return state
end

---Reset all weapon heat (battle end or reset)
---@param weaponIds table|nil Array of weapon IDs, or nil for all
---@return boolean Success
function ThermalSystem:resetAllHeat(weaponIds)
    if weaponIds then
        for _, weaponId in ipairs(weaponIds) do
            if self.weaponHeat[weaponId] then
                self.weaponHeat[weaponId] = 0
                self.weaponJamStatus[weaponId] = {isJammed = false, recoveryTurnsRemaining = 0}
                self.coolingWeapons[weaponId] = false
            end
        end
    else
        for weaponId, _ in pairs(self.weaponHeat) do
            self.weaponHeat[weaponId] = 0
            self.weaponJamStatus[weaponId] = {isJammed = false, recoveryTurnsRemaining = 0}
            self.coolingWeapons[weaponId] = false
        end
    end
    
    print("[ThermalSystem] Heat reset for all weapons")
    return true
end

---Get detailed thermal report for debugging
---@return table Comprehensive thermal report
function ThermalSystem:getThermalReport()
    local report = {
        timestamp = love.timer.getTime(),
        config = {
            maxHeat = CONFIG.maxHeat,
            jamThreshold = CONFIG.jamThreshold,
            coolingRate = CONFIG.dissipation.cooldown
        },
        weaponStates = self:getThermalState(),
        recentEvents = {}
    }
    
    -- Add recent jam/unjam events
    local eventCount = 0
    for weaponId, history in pairs(self.heatHistory) do
        if #history > 0 then
            local recentEvent = history[#history]
            if recentEvent.jammed then
                table.insert(report.recentEvents, {
                    weapon = weaponId,
                    event = "jam",
                    time = recentEvent.timestamp,
                    heat = recentEvent.newHeat
                })
            end
        end
        eventCount = eventCount + 1
    end
    
    return report
end

return ThermalSystem

