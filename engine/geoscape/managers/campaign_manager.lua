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
---  - geoscape.systems.calendar: Date tracking (Phase 5)
---  - geoscape.systems.season_system: Seasonal modifiers (Phase 5)
---  - geoscape.systems.event_scheduler: Event scheduling (Phase 5)
---  - geoscape.systems.turn_advancer: Turn orchestration (Phase 5)
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

-- Phase 5 systems (Time & Turn Management)
CampaignManager.calendar = nil       -- Calendar system
CampaignManager.season_system = nil  -- Seasonal modifier system
CampaignManager.event_scheduler = nil -- Event scheduling system
CampaignManager.turn_advancer = nil  -- Turn orchestration system

-- Phase thresholds and properties
CampaignManager.PHASE_THRESHOLDS = {
    [0] = { name = "Shadow War", minTime = 0, threatCap = 0.4, nextTrigger = "discoveries" },
    [1] = { name = "Sky War", minTime = 86400, threatCap = 0.7, nextTrigger = "deepop" },
    [2] = { name = "Deep War", minTime = 172800, threatCap = 0.9, nextTrigger = "dimensional" },
    [3] = { name = "Dimensional War", minTime = 259200, threatCap = 1.0, nextTrigger = "none" }
}

---Initialize campaign at game start
---Sets up initial campaign state, loads phase configuration from mods
---Initializes Phase 5 systems: Calendar, SeasonSystem, EventScheduler, TurnAdvancer
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

    -- Initialize Phase 5 systems (Time & Turn Management)
    CampaignManager:_initializePhase5Systems()
end

---Internal: Initialize Phase 5 systems
---Sets up Calendar, SeasonSystem, EventScheduler, and TurnAdvancer
---Registers callbacks for turn progression
function CampaignManager:_initializePhase5Systems()
    print("[CampaignManager] Initializing Phase 5 systems (Time & Turn Management)")

    -- Load Phase 5 systems
    local Calendar = require("engine.geoscape.systems.calendar")
    local SeasonSystem = require("engine.geoscape.systems.season_system")
    local EventScheduler = require("engine.geoscape.systems.event_scheduler")
    local TurnAdvancer = require("engine.geoscape.systems.turn_advancer")

    -- Initialize each system
    self.calendar = Calendar.new(1996)  -- Start campaign in 1996
    self.season_system = SeasonSystem.new()
    self.event_scheduler = EventScheduler.new()
    self.turn_advancer = TurnAdvancer.new()

    -- Wire calendar to season system
    self.season_system.calendar = self.calendar

    -- Register phase callbacks with turn advancer
    self.turn_advancer:registerPhaseCallback(
        TurnAdvancer.PHASES.CALENDAR_ADVANCE,
        function(turn, advancer) self:_phaseCalendarAdvance() end,
        "campaign_calendar_advance"
    )

    self.turn_advancer:registerPhaseCallback(
        TurnAdvancer.PHASES.EVENT_FIRE,
        function(turn, advancer) self:_phaseEventFire(turn) end,
        "campaign_event_fire"
    )

    self.turn_advancer:registerPhaseCallback(
        TurnAdvancer.PHASES.SEASONAL_EFFECTS,
        function(turn, advancer) self:_phaseSeasonalEffects(turn) end,
        "campaign_seasonal_effects"
    )

    -- Register global post-turn callback for logging
    self.turn_advancer:registerGlobalCallback(
        function(turn, advancer)
            if turn % 30 == 0 then  -- Log every 30 turns (~1 month)
                print(string.format("[Campaign] Day %d: %s, Season: %s, Threat: %.1f%%",
                    self.calendar.turn,
                    self.calendar:getDateString(),
                    self.season_system.calendar:getSeasonName(),
                    self.threatLevel * 100))
            end
        end,
        "campaign_turn_logging"
    )

    print("[CampaignManager] Phase 5 systems initialized and wired")
end

---Internal: Calendar advancement phase callback
---Advances calendar by 1 day
function CampaignManager:_phaseCalendarAdvance()
    if self.calendar then
        self.calendar:advance(1)
    end
end

---Internal: Event firing phase callback
---Updates and fires scheduled events
---@param turn number Current turn
function CampaignManager:_phaseEventFire(turn)
    if self.event_scheduler and self.calendar then
        self.event_scheduler:updateAndFire(turn, self.calendar)
    end
end

---Internal: Seasonal effects phase callback
---Applies seasonal modifiers to game systems
---@param turn number Current turn
function CampaignManager:_phaseSeasonalEffects(turn)
    if self.season_system then
        -- Apply seasonal effects (would be integrated with other systems)
        -- For now, just tracking that seasonal effects are applied
    end
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

    -- Dynamically adjust threat escalation based on mission frequency (win rate)
    CampaignManager:_updateThreatEscalation(delta_time)
end

---Advance campaign turn (called once per turn in turn-based gameplay)
---Orchestrates all Phase 5 systems in proper sequence
---@return table Performance metrics from turn advancement
function CampaignManager.advanceTurn()
    if not self.turn_advancer then
        print("[CampaignManager] Turn advancer not initialized")
        return { total_time = 0, phase_times = {}, errors = {} }
    end

    return self.turn_advancer:advanceTurn()
end

---Internal: Apply dynamic threat escalation based on campaign performance
---Win rate affects UFO frequency and difficulty beyond base threat system
---@param delta_time number Delta time in seconds
function CampaignManager:_updateThreatEscalation(delta_time)
    local threshold = self.PHASE_THRESHOLDS[self.currentPhase]
    if not threshold then return end

    -- Base escalation per week (604800 seconds)
    local weekProgress = (delta_time / 604800)
    local baseEscalation = 0.01 * weekProgress  -- 1% per week base

    -- Adjust escalation based on win rate
    if self.winRate > 0.65 then
        -- Player winning: increase threat faster (alien adaptation)
        baseEscalation = baseEscalation * 1.2
    elseif self.winRate < 0.35 then
        -- Player losing: slow threat increase (aliens overconfident)
        baseEscalation = baseEscalation * 0.7
    end

    -- Cap threat to phase maximum
    local oldThreat = self.threatLevel
    self.threatLevel = math.min(self.threatLevel + baseEscalation, threshold.threatCap)

    -- Log significant escalations (0.05+ increase)
    if self.threatLevel - oldThreat >= 0.05 then
        print(string.format("[CampaignManager] Threat escalation: %.1f%% → %.1f%% (Win rate: %.1f%%)",
            oldThreat * 100, self.threatLevel * 100, self.winRate * 100))
    end
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
---Serializes campaign data plus all Phase 5 systems
---@return table Campaign state data
function CampaignManager.save()
    local phase5_data = {}

    -- Serialize Phase 5 systems
    if self.calendar then
        phase5_data.calendar = self.calendar:serialize()
    end
    if self.season_system then
        phase5_data.season_system = self.season_system:serialize()
    end
    if self.event_scheduler then
        phase5_data.event_scheduler = self.event_scheduler:serialize()
    end
    if self.turn_advancer then
        phase5_data.turn_advancer = self.turn_advancer:serialize()
    end

    return {
        currentPhase = CampaignManager.currentPhase,
        phaseTime = CampaignManager.phaseTime,
        threatLevel = CampaignManager.threatLevel,
        missionCount = CampaignManager.missionCount,
        winRate = CampaignManager.winRate,
        phase5_systems = phase5_data
    }
end

---Load campaign state from saved data
---Deserializes campaign data plus all Phase 5 systems
---@param data table Campaign state data (from save())
function CampaignManager.load(data)
    if not data then return end

    CampaignManager.currentPhase = data.currentPhase or 0
    CampaignManager.phaseTime = data.phaseTime or 0
    CampaignManager.threatLevel = data.threatLevel or 0.1
    CampaignManager.missionCount = data.missionCount or 0
    CampaignManager.winRate = data.winRate or 0.5

    -- Load Phase 5 systems if data present
    if data.phase5_systems then
        local Calendar = require("engine.geoscape.systems.calendar")
        local SeasonSystem = require("engine.geoscape.systems.season_system")
        local EventScheduler = require("engine.geoscape.systems.event_scheduler")
        local TurnAdvancer = require("engine.geoscape.systems.turn_advancer")

        if data.phase5_systems.calendar then
            CampaignManager.calendar = Calendar.deserialize(data.phase5_systems.calendar)
        end
        if data.phase5_systems.season_system then
            CampaignManager.season_system = SeasonSystem.deserialize(data.phase5_systems.season_system)
            if CampaignManager.calendar then
                CampaignManager.season_system.calendar = CampaignManager.calendar
            end
        end
        if data.phase5_systems.event_scheduler then
            CampaignManager.event_scheduler = EventScheduler.deserialize(data.phase5_systems.event_scheduler)
        end
        if data.phase5_systems.turn_advancer then
            CampaignManager.turn_advancer = TurnAdvancer.deserialize(data.phase5_systems.turn_advancer)
        end
    end

    print(string.format("[CampaignManager] Campaign loaded - Phase: %s, Threat: %.1f%%",
        CampaignManager.PHASE_THRESHOLDS[CampaignManager.currentPhase].name,
        CampaignManager.threatLevel * 100))
end

return CampaignManager

