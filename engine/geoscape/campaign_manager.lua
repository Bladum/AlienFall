---Campaign Manager - Strategic Campaign Phase Management
---
---Manages campaign phases, progression, and threat escalation. Controls transition
---between Shadow War → Sky War → Deep War → Dimensional War phases. Tracks player
---performance, adjusts threat levels, and coordinates faction activities.
---
---Campaign Phases:
---  - Phase 0: Shadow War (supernatural, conspiracy, government denial)
---  - Phase 1: Sky War (alien invasion, UFO waves, public awareness)
---  - Phase 2: Deep War (underground threats, aquatic species, deep operations)
---  - Phase 3: Dimensional War (reality-warping enemies, dimensional rifts)
---
---Features:
---  - Phase progression system with time and trigger-based transitions
---  - Threat level tracking (0.0 to 1.0 per phase)
---  - Phase-specific content (missions, technologies, factions)
---  - Performance-based difficulty scaling
---  - Event triggering on phase transitions
---  - Save/load support for campaign state
---
---Key Exports:
---  - CampaignManager.init(): Initialize campaign (called on game start)
---  - CampaignManager.getCurrentPhase(): Returns current phase (0-3)
---  - CampaignManager.getThreatLevel(): Returns threat level (0.0-1.0)
---  - CampaignManager.update(delta_time): Update campaign state
---  - CampaignManager.recordMissionOutcome(success): Track mission results
---  - CampaignManager.save(): Serialize campaign state
---  - CampaignManager.load(data): Deserialize campaign state
---
---Dependencies:
---  - mods.mod_manager: Load campaign TOML configuration
---  - core.data_loader: Load phase and faction data
---  - geoscape.threat_manager: Threat level management (created TASK-AI-001)
---
---@module geoscape.campaign_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CampaignManager = require("geoscape.campaign_manager")
---  CampaignManager.init()
---  
---  -- During gameplay loop
---  CampaignManager.update(delta_time)
---  
---  -- After mission
---  CampaignManager.recordMissionOutcome(mission_succeeded)
---
---@see geoscape.threat_manager For threat escalation
---@see geoscape.phase_manager For phase-specific content

local CampaignManager = {}

-- Campaign state
CampaignManager.currentPhase = 0  -- 0=Shadow War, 1=Sky War, 2=Deep War, 3=Dimensional War
CampaignManager.phaseTime = 0    -- Time spent in current phase
CampaignManager.threatLevel = 0.0 -- Threat level 0.0-1.0
CampaignManager.missionCount = 0 -- Total missions completed
CampaignManager.winRate = 0.5    -- Mission win rate (affects threat)
CampaignManager.phaseConfig = {} -- Phase configuration from TOML

-- Phase thresholds and properties
CampaignManager.PHASE_THRESHOLDS = {
    [0] = { name = "Shadow War", minTime = 0, threatCap = 0.4, nextTrigger = "discoveries" },
    [1] = { name = "Sky War", minTime = 86400, threatCap = 0.7, nextTrigger = "deepop" },
    [2] = { name = "Deep War", minTime = 172800, threatCap = 0.9, nextTrigger = "dimensional" },
    [3] = { name = "Dimensional War", minTime = 259200, threatCap = 1.0, nextTrigger = "none" }
}

---Initialize campaign at game start
---Sets up initial campaign state, loads phase configuration from mods
function CampaignManager.init()
    print("[CampaignManager] Initializing campaign")
    
    -- Load phase configuration from mods
    local ModManager = require("mods.mod_manager")
    CampaignManager.phaseConfig = ModManager:loadContent("campaign/phases") or {}
    
    -- Start in Shadow War
    CampaignManager.currentPhase = 0
    CampaignManager.phaseTime = 0
    CampaignManager.threatLevel = 0.1
    CampaignManager.missionCount = 0
    CampaignManager.winRate = 0.5
    
    print(string.format("[CampaignManager] Campaign started - Phase: %s", 
        CampaignManager.PHASE_THRESHOLDS[CampaignManager.currentPhase].name))
end

---Get current campaign phase
---@return number Current phase (0-3)
function CampaignManager.getCurrentPhase()
    return CampaignManager.currentPhase
end

---Get current threat level
---@return number Threat level (0.0-1.0)
function CampaignManager.getThreatLevel()
    return CampaignManager.threatLevel
end

---Get current phase name
---@return string Phase name (e.g., "Shadow War")
function CampaignManager.getPhaseName()
    return CampaignManager.PHASE_THRESHOLDS[CampaignManager.currentPhase].name
end

---Update campaign state each frame
---Advances time, updates threat level, checks for phase transitions
---@param delta_time number Delta time in seconds
function CampaignManager.update(delta_time)
    CampaignManager.phaseTime = CampaignManager.phaseTime + delta_time
    
    -- Update threat level based on phase and performance
    CampaignManager:_updateThreatLevel()
    
    -- Check for phase transitions
    CampaignManager:_checkPhaseTransition()
end

---Record mission outcome and update statistics
---Success increases threat curve, failure decreases pressure
---@param success boolean Whether mission succeeded
function CampaignManager.recordMissionOutcome(success)
    CampaignManager.missionCount = CampaignManager.missionCount + 1
    
    if success then
        -- Recalculate win rate (weighted average)
        CampaignManager.winRate = (CampaignManager.winRate * (CampaignManager.missionCount - 1) + 1) / CampaignManager.missionCount
    else
        CampaignManager.winRate = (CampaignManager.winRate * (CampaignManager.missionCount - 1)) / CampaignManager.missionCount
    end
    
    print(string.format("[CampaignManager] Mission #%d %s | Win rate: %.1f%%",
        CampaignManager.missionCount, success and "WON" or "LOST", CampaignManager.winRate * 100))
end

---Internal: Update threat level based on phase and win rate
---Higher win rate → increased pressure
---Lower win rate → decreased pressure
function CampaignManager:_updateThreatLevel()
    local threshold = self.PHASE_THRESHOLDS[self.currentPhase]
    local baseThreat = self.threatLevel
    
    -- Base threat increases over time in phase
    local timeMultiplier = math.min(self.phaseTime / 604800, 1.0) -- Scale over 1 week
    baseThreat = baseThreat + (0.001 * timeMultiplier)
    
    -- Adjust based on win rate
    if self.winRate > 0.7 then
        baseThreat = baseThreat * 1.05  -- Increase pressure if winning
    elseif self.winRate < 0.4 then
        baseThreat = baseThreat * 0.95  -- Decrease pressure if losing
    end
    
    -- Cap to phase threshold
    self.threatLevel = math.min(baseThreat, threshold.threatCap)
end

---Internal: Check if phase transition should occur
---Transitions can be time-based or trigger-based
function CampaignManager:_checkPhaseTransition()
    if self.currentPhase >= 3 then
        return  -- Final phase, no transitions
    end
    
    local threshold = self.PHASE_THRESHOLDS[self.currentPhase]
    local nextThreshold = self.PHASE_THRESHOLDS[self.currentPhase + 1]
    
    -- Check time-based transition
    if self.phaseTime >= threshold.minTime and self.threatLevel >= threshold.threatCap then
        self:_transitionPhase()
    end
end

---Internal: Execute phase transition
---Triggers events, resets phase time, updates available content
function CampaignManager:_transitionPhase()
    local oldPhase = self.currentPhase
    local oldPhaseName = self.PHASE_THRESHOLDS[oldPhase].name
    
    self.currentPhase = self.currentPhase + 1
    self.phaseTime = 0
    self.threatLevel = 0.1  -- Reset threat for new phase
    
    local newPhaseName = self.PHASE_THRESHOLDS[self.currentPhase].name
    
    print(string.format("[CampaignManager] PHASE TRANSITION: %s → %s", oldPhaseName, newPhaseName))
    
    -- Trigger narrative events
    self:_triggerPhaseTransitionEvents(oldPhase, self.currentPhase)
end

---Internal: Trigger events on phase transition
---@param oldPhase number Previous phase
---@param newPhase number New phase
function CampaignManager:_triggerPhaseTransitionEvents(oldPhase, newPhase)
    -- This will be expanded when event system is fully implemented
    -- Fires narrative hooks, discoveries, interrogation results, etc.
    print(string.format("[CampaignManager] Triggering events for phase %d → %d transition", oldPhase, newPhase))
end

---Save campaign state for persistence
---@return table Campaign state data
function CampaignManager.save()
    return {
        currentPhase = CampaignManager.currentPhase,
        phaseTime = CampaignManager.phaseTime,
        threatLevel = CampaignManager.threatLevel,
        missionCount = CampaignManager.missionCount,
        winRate = CampaignManager.winRate
    }
end

---Load campaign state from saved data
---@param data table Campaign state data (from save())
function CampaignManager.load(data)
    if not data then return end
    
    CampaignManager.currentPhase = data.currentPhase or 0
    CampaignManager.phaseTime = data.phaseTime or 0
    CampaignManager.threatLevel = data.threatLevel or 0.1
    CampaignManager.missionCount = data.missionCount or 0
    CampaignManager.winRate = data.winRate or 0.5
    
    print(string.format("[CampaignManager] Campaign loaded - Phase: %s, Threat: %.1f%%",
        CampaignManager.PHASE_THRESHOLDS[CampaignManager.currentPhase].name,
        CampaignManager.threatLevel * 100))
end

return CampaignManager



