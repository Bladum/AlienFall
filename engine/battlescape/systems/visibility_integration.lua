---Visibility & Detection Integration Layer
---
---Integration point between Line of Sight (LOS) and Concealment Detection systems.
---Provides unified visibility checking with both geometric LOS and detection chances.
---
---This module acts as a middleware between:
---  - Geometric visibility (LOS system: can you see the hex?)
---  - Concealment mechanics (Detection system: is the unit actually visible?)
---  - Unit awareness (perception, stealth levels, environmental factors)
---
---Features:
---  - Combined LOS + detection checks
---  - Visibility state tracking per observer-target pair
---  - Unit discovery events
---  - Stealth break conditions
---  - Integration hooks for combat systems
---
---@module battlescape.systems.visibility_integration
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local VisibilityIntegration = {}
VisibilityIntegration.__index = VisibilityIntegration

---Create new visibility integration layer
---@param losSystem table Line of Sight system reference
---@param concealmentSystem table Concealment Detection system reference
---@param battleSystem table Battle system reference
---@return table New VisibilityIntegration instance
function VisibilityIntegration.new(losSystem, concealmentSystem, battleSystem)
    local self = setmetatable({}, VisibilityIntegration)
    
    self.losSystem = losSystem
    self.concealmentSystem = concealmentSystem
    self.battleSystem = battleSystem
    
    -- Visibility state tracking: {observerId: {targetId: {visible, lastSeen, detectionChance}}}
    self.visibilityState = {}
    
    -- Detection events for logging
    self.detectionEvents = {}
    
    print("[VisibilityIntegration] Initialized visibility integration layer")
    
    return self
end

---Perform complete visibility check (LOS + detection)
---@param observer table Observer unit {id, pos, faction, ...}
---@param target table Target unit {id, pos, concealment, ...}
---@param environment table Environment data {timeOfDay, weather, terrain}
---@return boolean True if target is visible to observer
---@return string Visibility reason ("los_blocked", "concealed", "visible", "detected")
---@return number Detection chance (0.0-1.0) for concealed units
function VisibilityIntegration:checkVisibility(observer, target, environment)
    if not observer or not target then
        return false, "invalid_params", 0
    end
    
    -- Check basic LOS first (geometric visibility)
    local hasLOS = self.losSystem:hasLineOfSight(
        observer.pos,
        target.pos,
        self:getEffectiveVisionRange(observer, environment)
    )
    
    if not hasLOS then
        return false, "los_blocked", 0
    end
    
    -- Calculate detection chance based on concealment
    local detectionChance = self.concealmentSystem:calculateDetectionChance(
        observer,
        target,
        self:calculateDistance(observer.pos, target.pos),
        environment
    )
    
    -- Track visibility state
    self:updateVisibilityState(observer.id, target.id, detectionChance)
    
    -- Unit is visible if either:
    -- 1. Concealment is very low (< 5%)
    -- 2. Random detection succeeds (with detectionChance probability)
    local concealmentLevel = self.concealmentSystem:getConcealmentLevel(target.id)
    
    if concealmentLevel < 0.05 then
        return true, "visible", detectionChance
    end
    
    -- For concealed units, apply probabilistic detection
    local detected = math.random() < detectionChance
    
    if detected then
        self:recordDetectionEvent(observer.id, target.id, detectionChance, "detected")
        return true, "detected", detectionChance
    else
        return false, "concealed", detectionChance
    end
end

---Get all visible units from an observer's perspective
---@param observer table Observer unit {id, pos, faction, ...}
---@param allTargets table Array of all possible target units
---@param environment table Environment data {timeOfDay, weather, terrain}
---@return table Array of visible unit IDs
---@return table Visibility details {unitId: {visible, reason, detectionChance}}
function VisibilityIntegration:getVisibleUnits(observer, allTargets, environment)
    local visibleUnits = {}
    local visibilityDetails = {}
    
    for _, target in ipairs(allTargets) do
        if target.id ~= observer.id then  -- Don't check self
            local visible, reason, chance = self:checkVisibility(observer, target, environment)
            
            visibilityDetails[target.id] = {
                visible = visible,
                reason = reason,
                detectionChance = chance
            }
            
            if visible then
                table.insert(visibleUnits, target.id)
            end
        end
    end
    
    return visibleUnits, visibilityDetails
end

---Get effective vision range considering environment and observer stats
---@param observer table Observer unit
---@param environment table Environment data
---@return number Adjusted vision range
function VisibilityIntegration:getEffectiveVisionRange(observer, environment)
    local baseRange = observer.visionRange or 15
    
    -- Adjust for time of day
    local timeModifier = 1.0
    if environment and environment.timeOfDay then
        if environment.timeOfDay == "night" then
            timeModifier = 0.5
        elseif environment.timeOfDay == "dusk" or environment.timeOfDay == "dawn" then
            timeModifier = 0.75
        end
    end
    
    -- Adjust for weather
    local weatherModifier = 1.0
    if environment and environment.weather then
        if environment.weather == "heavy_rain" then
            weatherModifier = 0.7
        elseif environment.weather == "rain" then
            weatherModifier = 0.85
        elseif environment.weather == "fog" then
            weatherModifier = 0.6
        end
    end
    
    return baseRange * timeModifier * weatherModifier
end

---Calculate distance between two hex positions
---@param pos1 table Hex position {q, r}
---@param pos2 table Hex position {q, r}
---@return number Distance in hexes
function VisibilityIntegration:calculateDistance(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    
    -- Cube distance formula for hex grids
    local q1, r1 = pos1.q or 0, pos1.r or 0
    local q2, r2 = pos2.q or 0, pos2.r or 0
    
    local s1 = -q1 - r1
    local s2 = -q2 - r2
    
    return (math.abs(q1 - q2) + math.abs(r1 - r2) + math.abs(s1 - s2)) / 2
end

---Update visibility state for an observer-target pair
---@param observerId string Observer unit ID
---@param targetId string Target unit ID
---@param detectionChance number Detection chance (0-1)
function VisibilityIntegration:updateVisibilityState(observerId, targetId, detectionChance)
    if not self.visibilityState[observerId] then
        self.visibilityState[observerId] = {}
    end
    
    self.visibilityState[observerId][targetId] = {
        visible = true,
        lastSeen = love.timer.getTime(),
        detectionChance = detectionChance
    }
end

---Record a detection event
---@param observerId string Observer unit ID
---@param targetId string Target unit ID
---@param detectionChance number Detection chance that succeeded
---@param reason string Detection reason
function VisibilityIntegration:recordDetectionEvent(observerId, targetId, detectionChance, reason)
    table.insert(self.detectionEvents, {
        timestamp = love.timer.getTime(),
        observer = observerId,
        target = targetId,
        detectionChance = detectionChance,
        reason = reason
    })
    
    -- Log to console for debugging
    print(string.format("[VisibilityIntegration] Detection: %s detected %s (%.1f%% chance, %s)",
        observerId, targetId, detectionChance * 100, reason))
end

---Check if concealment is broken by an action
---@param unit table Unit performing the action
---@param actionType string Type of action ("fire", "move", "ability", "melee")
---@param shouldBreak boolean True to apply break
---@return boolean Concealment was broken
function VisibilityIntegration:checkConcealmentBreak(unit, actionType, shouldBreak)
    if not unit or not actionType then
        return false
    end
    
    local concealmentLevel = self.concealmentSystem:getConcealmentLevel(unit.id)
    
    if concealmentLevel and concealmentLevel > 0.05 then  -- Unit is concealed
        if shouldBreak then
            -- Determine break severity
            local severity = "minor"
            if actionType == "fire" or actionType == "melee" then
                severity = "major"
            elseif actionType == "move" then
                severity = "minor"
            end
            
            self.concealmentSystem:breakConcealment(unit.id, severity)
            return true
        end
    end
    
    return false
end

---Process visibility update for entire battle
---@param observers table Array of observer units
---@param targets table Array of target units
---@param environment table Environment data
---@return table Complete visibility matrix {observerId: {targetId: visible}}
function VisibilityIntegration:updateBattleVisibility(observers, targets, environment)
    local visibilityMatrix = {}
    
    for _, observer in ipairs(observers) do
        local visibleUnits = self:getVisibleUnits(observer, targets, environment)
        visibilityMatrix[observer.id] = {}
        
        for _, targetId in ipairs(visibleUnits) do
            visibilityMatrix[observer.id][targetId] = true
        end
    end
    
    print("[VisibilityIntegration] Battle visibility updated for " .. 
          tostring(#observers) .. " observers")
    
    return visibilityMatrix
end

---Get visibility report for debugging
---@return table Report of all visibility states and recent detection events
function VisibilityIntegration:getVisibilityReport()
    local report = {
        timestamp = love.timer.getTime(),
        visibilityStates = self.visibilityState,
        recentDetections = {},
        summary = {
            totalStates = 0,
            activeDetections = 0
        }
    }
    
    -- Include last 20 detection events
    local startIdx = math.max(1, #self.detectionEvents - 19)
    for i = startIdx, #self.detectionEvents do
        table.insert(report.recentDetections, self.detectionEvents[i])
    end
    
    for _, targets in pairs(self.visibilityState) do
        for _, state in pairs(targets) do
            report.summary.totalStates = report.summary.totalStates + 1
            if state.visible then
                report.summary.activeDetections = report.summary.activeDetections + 1
            end
        end
    end
    
    return report
end

return VisibilityIntegration
