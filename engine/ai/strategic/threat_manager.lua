---Threat Manager - Campaign Pressure and Difficulty Scaling
---
---Manages campaign threat level based on player performance and time progression.
---Increases threat when player succeeds, decreases when struggling. Creates dynamic
---difficulty curve that adapts to player skill level. Threat level feeds into
---alien activity generation, UFO waves, terror missions, and base attacks.
---
---Features:
---  - Time-based threat escalation
---  - Performance-based adaptive difficulty
---  - Phase-specific threat caps
---  - Threat-to-activity mapping (threat level determines mission frequency)
---  - Debug output for balancing
---
---Threat Level Scale:
---  - 0.0-0.2: Low activity (1-2 missions per week)
---  - 0.2-0.4: Moderate activity (3-5 missions per week)
---  - 0.4-0.6: High activity (6-10 missions per week)
---  - 0.6-0.8: Very High activity (11-20 missions per week)
---  - 0.8-1.0: Extreme activity (20+ missions per week, continuous pressure)
---
---Key Exports:
---  - ThreatManager.init(phase): Initialize for phase
---  - ThreatManager.getThreatLevel(): Current threat (0.0-1.0)
---  - ThreatManager.getMissionFrequency(): Missions per game day
---  - ThreatManager.recordMissionOutcome(success): Update threat on mission
---  - ThreatManager.update(delta_time): Update threat over time
---  - ThreatManager.save(): Serialize state
---  - ThreatManager.load(data): Deserialize state
---
---Dependencies:
---  - geoscape.campaign_manager: Check current phase
---
---@module ai.strategic.threat_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ThreatManager = require("ai.strategic.threat_manager")
---  ThreatManager.init(1)  -- Sky War phase
---  
---  -- During gameplay
---  ThreatManager.update(delta_time)
---  
---  -- After mission
---  ThreatManager.recordMissionOutcome(mission_won)
---  
---  -- Generate missions
---  local frequency = ThreatManager.getMissionFrequency()
---
---@see geoscape.campaign_manager For phase progression
---@see ai.strategic.faction_coordinator For alien activity

local ThreatManager = {}

-- Threat state
ThreatManager.threatLevel = 0.0  -- Current threat (0.0-1.0)
ThreatManager.baseThreatRate = 0.001  -- Base threat increase per second
ThreatManager.phaseMultiplier = 1.0   -- Phase-specific multiplier
ThreatManager.performanceMultiplier = 1.0  -- Win rate based scaling
ThreatManager.elapsedTime = 0  -- Time elapsed in current phase

-- Performance tracking
ThreatManager.missionsWon = 0
ThreatManager.missionsLost = 0
ThreatManager.winRate = 0.5

-- Phase threat caps
ThreatManager.PHASE_CONFIG = {
    [0] = { name = "Shadow War", threatCap = 0.4, baseRate = 0.0008, missionCap = 2 },
    [1] = { name = "Sky War", threatCap = 0.7, baseRate = 0.001, missionCap = 5 },
    [2] = { name = "Deep War", threatCap = 0.9, baseRate = 0.0012, missionCap = 8 },
    [3] = { name = "Dimensional War", threatCap = 1.0, baseRate = 0.0015, missionCap = 10 }
}

---Initialize threat manager for a phase
---@param phase number Campaign phase (0-3)
function ThreatManager.init(phase)
    print("[ThreatManager] Initializing for phase: " .. (ThreatManager.PHASE_CONFIG[phase].name or "Unknown"))
    
    local config = ThreatManager.PHASE_CONFIG[phase]
    if not config then return end
    
    ThreatManager.baseThreatRate = config.baseRate
    ThreatManager.threatLevel = 0.1  -- Start at 10%
    ThreatManager.elapsedTime = 0
    ThreatManager.missionsWon = 0
    ThreatManager.missionsLost = 0
    ThreatManager.winRate = 0.5
    ThreatManager.phaseMultiplier = 1.0
end

---Get current threat level
---@return number Threat level (0.0-1.0)
function ThreatManager.getThreatLevel()
    return ThreatManager.threatLevel
end

---Get mission frequency based on threat level
---Returns number of missions per game day
---@return number Missions per day (0.1 to 1.0)
function ThreatManager.getMissionFrequency()
    -- Map threat level to mission frequency
    -- 0.0 = 0.1 mission/day (1 mission/10 days)
    -- 0.5 = 0.5 mission/day (1 mission/2 days)
    -- 1.0 = 1.0 mission/day (1 mission/day minimum)
    
    return 0.1 + (ThreatManager.threatLevel * 0.9)
end

---Get threat-based UFO wave intensity
---@return number Wave intensity multiplier (0.5-3.0)
function ThreatManager.getUFOIntensity()
    -- 0.0 threat = 0.5x (rare UFOs)
    -- 0.5 threat = 1.0x (normal)
    -- 1.0 threat = 2.0x (many UFOs)
    
    return 0.5 + (ThreatManager.threatLevel * 1.5)
end

---Get terror mission likelihood
---@return number Probability 0-1 (0 = no terror, 1 = guaranteed)
function ThreatManager.getTerrorMissionChance()
    -- Only likely at high threat
    if ThreatManager.threatLevel < 0.3 then
        return 0  -- No terror missions at low threat
    end
    
    return math.max(0, ThreatManager.threatLevel - 0.3) / 0.7
end

---Update threat level each frame
---Increases threat based on time and phase
---@param delta_time number Time in seconds since last frame
function ThreatManager.update(delta_time)
    ThreatManager.elapsedTime = ThreatManager.elapsedTime + delta_time
    
    -- Calculate threat increase
    local phase = require("geoscape.campaign_manager").getCurrentPhase()
    local config = ThreatManager.PHASE_CONFIG[phase]
    
    if not config then return end
    
    -- Time-based threat increase
    local timeIncrease = delta_time * config.baseRate
    
    -- Apply performance multiplier
    -- Winning increases threat (AI gets harder)
    -- Losing decreases threat (AI gets easier)
    if ThreatManager.winRate > 0.7 then
        timeIncrease = timeIncrease * 1.1  -- +10% threat acceleration
    elseif ThreatManager.winRate < 0.4 then
        timeIncrease = timeIncrease * 0.9  -- -10% threat acceleration
    end
    
    ThreatManager.threatLevel = ThreatManager.threatLevel + timeIncrease
    
    -- Cap to phase maximum
    ThreatManager.threatLevel = math.min(ThreatManager.threatLevel, config.threatCap)
end

---Record mission outcome and adjust threat
---@param success boolean True if player won
function ThreatManager.recordMissionOutcome(success)
    if success then
        ThreatManager.missionsWon = ThreatManager.missionsWon + 1
    else
        ThreatManager.missionsLost = ThreatManager.missionsLost + 1
    end
    
    local total = ThreatManager.missionsWon + ThreatManager.missionsLost
    ThreatManager.winRate = ThreatManager.missionsWon / total
    
    -- Adjust threat immediately based on result
    if success then
        -- Winning increases threat (add 10% of current cap)
        local phase = require("geoscape.campaign_manager").getCurrentPhase()
        local config = ThreatManager.PHASE_CONFIG[phase]
        ThreatManager.threatLevel = ThreatManager.threatLevel + (config.threatCap * 0.1)
    else
        -- Losing decreases threat (subtract 5% of current level)
        ThreatManager.threatLevel = ThreatManager.threatLevel * 0.95
    end
    
    -- Ensure within bounds
    local phase = require("geoscape.campaign_manager").getCurrentPhase()
    local config = ThreatManager.PHASE_CONFIG[phase]
    ThreatManager.threatLevel = math.max(0, math.min(ThreatManager.threatLevel, config.threatCap))
    
    print(string.format("[ThreatManager] Mission %s | Win rate: %.1f%% | Threat: %.1f%%",
        success and "WON" or "LOST", ThreatManager.winRate * 100, ThreatManager.threatLevel * 100))
end

---Get debug information
---@return table Debug stats
function ThreatManager.getDebugInfo()
    return {
        threatLevel = ThreatManager.threatLevel,
        winRate = ThreatManager.winRate,
        missionsWon = ThreatManager.missionsWon,
        missionsLost = ThreatManager.missionsLost,
        missionFrequency = ThreatManager.getMissionFrequency(),
        ufoIntensity = ThreatManager.getUFOIntensity(),
        terrorChance = ThreatManager.getTerrorMissionChance(),
        elapsedTime = ThreatManager.elapsedTime
    }
end

---Save threat state
---@return table Serialized state
function ThreatManager.save()
    return {
        threatLevel = ThreatManager.threatLevel,
        missionsWon = ThreatManager.missionsWon,
        missionsLost = ThreatManager.missionsLost,
        winRate = ThreatManager.winRate,
        elapsedTime = ThreatManager.elapsedTime
    }
end

---Load threat state
---@param data table Serialized state
function ThreatManager.load(data)
    if not data then return end
    
    ThreatManager.threatLevel = data.threatLevel or 0.1
    ThreatManager.missionsWon = data.missionsWon or 0
    ThreatManager.missionsLost = data.missionsLost or 0
    ThreatManager.winRate = data.winRate or 0.5
    ThreatManager.elapsedTime = data.elapsedTime or 0
    
    print(string.format("[ThreatManager] Loaded - Threat: %.1f%%, Win rate: %.1f%%",
        ThreatManager.threatLevel * 100, ThreatManager.winRate * 100))
end

return ThreatManager




