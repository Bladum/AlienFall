--[[
    Campaign Loop Orchestrator

    Central coordination hub for the entire campaign system. Orchestrates all Phase 6-9
    systems (Geoscape rendering, campaign integration, outcome handling, advanced features)
    into a unified campaign loop. Manages bidirectional data flow, state transitions,
    and system synchronization.

    The orchestrator handles:
    - Campaign initialization and state management
    - Mission generation with all systems factored in
    - Mission execution coordination
    - Outcome processing and campaign updates
    - System synchronization and data flow
    - Campaign phase transitions
]]

local CampaignOrchestrator = {}
CampaignOrchestrator.__index = CampaignOrchestrator

---
-- Initialize campaign orchestrator with all subsystems
-- @param initial_campaign_data: Campaign data table
-- @return: New CampaignOrchestrator instance
function CampaignOrchestrator.new(initial_campaign_data)
    local self = setmetatable({}, CampaignOrchestrator)

    self.campaignData = initial_campaign_data or {}
    self.state = "initializing"
    self.systems = {}
    self.campaign_phase = 1  -- 1-4 campaign phases
    self.current_mission = nil
    self.mission_history = {}
    self.system_state_log = {}
    self.orchestration_metrics = {}

    return self
end

---
-- Initialize all campaign subsystems
-- Loads and initializes: Mission Outcome Processor, Craft Return, Unit Recovery,
-- Difficulty Escalation, Salvage Processor, Alien Research, Base Expansion,
-- Faction Dynamics, Campaign Events, Difficulty Refinements
function CampaignOrchestrator:initializeAllSystems()
    print("[Orchestrator] Initializing all campaign systems...")

    -- Phase 6-7 Core Systems
    local MissionOutcomeProcessor = require("engine.geoscape.logic.mission_outcome_processor")
    local CraftReturnSystem = require("engine.geoscape.systems.craft_return_system")
    local UnitRecoveryProgression = require("engine.geoscape.unit_recovery_progression")
    local DifficultyEscalation = require("engine.geoscape.logic.difficulty_escalation")
    local SalvageProcessor = require("engine.geoscape.processing.salvage_processor")

    -- Phase 9 Advanced Systems
    local AlienResearchSystem = require("engine.geoscape.systems.alien_research_system")
    local BaseExpansionSystem = require("engine.geoscape.systems.base_expansion_system")
    local FactionDynamicsSystem = require("engine.geoscape.logic.faction_dynamics")
    local CampaignEventsSystem = require("engine.geoscape.processing.campaign_events_system")
    local DifficultyRefinementsSystem = require("engine.geoscape.difficulty_refinements")

    self.systems = {
        mission_outcome = MissionOutcomeProcessor.new(self.campaignData),
        craft_return = CraftReturnSystem.new(),
        unit_recovery = UnitRecoveryProgression.new(self.campaignData),
        difficulty_escalation = DifficultyEscalation.new(),
        salvage_processor = SalvageProcessor.new(self.campaignData),
        alien_research = AlienResearchSystem.new(self.campaignData),
        base_expansion = BaseExpansionSystem.new(self.campaignData),
        faction_dynamics = FactionDynamicsSystem.new(self.campaignData),
        campaign_events = CampaignEventsSystem.new(self.campaignData),
        difficulty_refinements = DifficultyRefinementsSystem.new(self.campaignData)
    }

    self.state = "ready"
    table.insert(self.system_state_log, {
        timestamp = os.time(),
        event = "systems_initialized",
        active_systems = 10
    })

    print("[Orchestrator] All 10 campaign systems initialized successfully ✓")
end

---
-- Start new campaign with initial parameters
-- @param difficulty: "Easy", "Normal", "Classic", "Ironman"
-- @param funding: Starting monthly funding
-- @param soldiers: Starting soldier count
function CampaignOrchestrator:startNewCampaign(difficulty, funding, soldiers)
    difficulty = difficulty or "Normal"
    funding = funding or 2000
    soldiers = soldiers or 50

    print(string.format("[Orchestrator] Starting new campaign: %s difficulty", difficulty))

    self.campaignData = {
        days_elapsed = 0,
        threat_level = 0,
        campaign_phase = 1,
        difficulty = difficulty,
        funding = funding,
        soldiers = {},
        crafts = {},
        base_facilities = {},
        research_points = 0,
        missions_completed = 0,
        soldiers_killed = 0,
        soldiers_wounded = 0,
        missions_won = 0,
        missions_lost = 0,
        mission_history = {},
        status = "in_progress"
    }

    -- Initialize soldiers
    for i = 1, soldiers do
        table.insert(self.campaignData.soldiers, {
            id = i,
            name = "Soldier " .. i,
            rank = "Rookie",
            xp = 0,
            health = 100,
            status = "active"
        })
    end

    -- Initialize crafts (2 starting)
    for i = 1, 2 do
        table.insert(self.campaignData.crafts, {
            id = i,
            name = "Interceptor " .. i,
            type = "interceptor",
            damage = 0,
            fuel = 100,
            status = "operational"
        })
    end

    self:initializeAllSystems()
    self.state = "campaign_active"

    table.insert(self.system_state_log, {
        timestamp = os.time(),
        event = "campaign_started",
        difficulty = difficulty
    })
end

---
-- Update campaign for day progression
-- @param days_passed: Number of days to progress
function CampaignOrchestrator:updateCampaignDay(days_passed)
    days_passed = days_passed or 1

    if self.state ~= "campaign_active" then
        print("[Orchestrator] Campaign not active, cannot update")
        return
    end

    self.campaignData.days_elapsed = (self.campaignData.days_elapsed or 0) + days_passed

    -- Update all systems synchronously
    self:_updateAllSystems(days_passed)

    -- Check for campaign transitions
    self:_checkCampaignPhaseTransition()

    -- Check threat level thresholds
    self:_checkThreatLevelMilestones()
end

---
-- Internal: Update all systems
-- @param days_passed: Days elapsed
function CampaignOrchestrator:_updateAllSystems(days_passed)
    local threat = self.campaignData.threat_level or 0

    -- Order matters: some systems depend on others

    -- 1. Process unit recovery first
    if self.systems.unit_recovery then
        self.systems.unit_recovery:processUnitRecovery(days_passed, self.campaignData)
    end

    -- 2. Update craft repairs
    if self.systems.craft_return then
        self.systems.craft_return:updateCraftRepairSchedule(days_passed)
    end

    -- 3. Update alien research (independent)
    if self.systems.alien_research then
        self.systems.alien_research:updateAlienResearch(days_passed, threat)
    end

    -- 4. Update base expansion (depends on threat)
    if self.systems.base_expansion then
        self.systems.base_expansion:updateBaseExpansion(threat, days_passed)
    end

    -- 5. Update faction pressure (depends on threat)
    if self.systems.faction_dynamics then
        local avg_standing = self.systems.faction_dynamics:getAverageFactionStanding()
        self.systems.faction_dynamics:updateCouncilPressure(threat, avg_standing)
    end

    -- 6. Generate campaign events (depends on threat)
    if self.systems.campaign_events then
        local events = self.systems.campaign_events:generateEvents(threat, days_passed)
        if events and #events > 0 then
            table.insert(self.system_state_log, {
                timestamp = os.time(),
                event = "campaign_events_triggered",
                count = #events
            })
        end
    end

    -- 7. Update difficulty refinements (depends on threat and performance)
    if self.systems.difficulty_refinements then
        local performance = {
            wins = self.campaignData.missions_won or 0,
            losses = self.campaignData.missions_lost or 0,
            recent_casualties = self.campaignData.soldiers_killed or 0
        }
        self.systems.difficulty_refinements:updateDifficultyRefinements(threat, performance)
    end
end

---
-- Internal: Check for campaign phase transitions
function CampaignOrchestrator:_checkCampaignPhaseTransition()
    local threat = self.campaignData.threat_level or 0
    local new_phase = 1

    if threat >= 75 then
        new_phase = 4
    elseif threat >= 50 then
        new_phase = 3
    elseif threat >= 25 then
        new_phase = 2
    end

    if new_phase > self.campaign_phase then
        self.campaign_phase = new_phase
        table.insert(self.system_state_log, {
            timestamp = os.time(),
            event = "campaign_phase_transition",
            old_phase = self.campaign_phase - 1,
            new_phase = new_phase,
            threat = threat
        })
    end
end

---
-- Internal: Check for threat level milestones
function CampaignOrchestrator:_checkThreatLevelMilestones()
    local threat = self.campaignData.threat_level or 0
    local milestones = {
        { level = 25, name = "Increased Activity" },
        { level = 50, name = "Global Crisis" },
        { level = 75, name = "Critical Emergency" },
        { level = 100, name = "Existential Threat" }
    }

    for _, milestone in ipairs(milestones) do
        if threat >= milestone.level and threat < milestone.level + 5 then
            table.insert(self.system_state_log, {
                timestamp = os.time(),
                event = "threat_milestone",
                level = milestone.level,
                name = milestone.name
            })
        end
    end
end

---
-- Generate next mission incorporating all systems
-- @return: Mission data table
function CampaignOrchestrator:generateNextMission()
    if self.state ~= "campaign_active" then
        print("[Orchestrator] Campaign not active, cannot generate mission")
        return nil
    end

    local threat = self.campaignData.threat_level or 0
    local mission = {
        id = (#self.mission_history or 0) + 1,
        generated_at_threat = threat,
        generated_at_day = self.campaignData.days_elapsed or 0,
        status = "active",
        difficulty = 1 + (threat / 25),
        complications = {}
    }

    -- Apply alien research composition
    if self.systems.alien_research then
        local composition = self.systems.alien_research:getAlienUnitComposition()
        mission.enemy_composition = composition
    end

    -- Apply difficulty escalation
    if self.systems.difficulty_escalation then
        local scaled = self.systems.difficulty_escalation:scaleMissionDifficulty(
            threat,
            self.campaignData.missions_won,
            self.campaignData.missions_lost
        )
        mission.enemy_count = scaled.enemy_count
        mission.enemy_types = scaled.enemy_types
    end

    -- Apply event complications if active
    if self.systems.campaign_events then
        local active_events = self.systems.campaign_events:getActiveEvents()
        for _, event in ipairs(active_events) do
            if event then
                table.insert(mission.complications, event.name)
                -- Apply complication effects to mission
                self.systems.campaign_events:applyMissionComplication(
                    event.name,
                    mission
                )
            end
        end
    end

    -- Apply difficulty refinements (leader/elite squads)
    if self.systems.difficulty_refinements then
        local leader = self.systems.difficulty_refinements:getAlienLeaderStatus()
        if leader then
            mission.alien_leader = leader
        end

        local squad = self.systems.difficulty_refinements:getEliteSquadDeployment()
        if squad then
            mission.elite_squad = squad
        end

        mission.tactical_modifier = self.systems.difficulty_refinements:getTacticalDifficultyModifier()
    end

    self.current_mission = mission
    table.insert(self.mission_history, mission)

    table.insert(self.system_state_log, {
        timestamp = os.time(),
        event = "mission_generated",
        mission_id = mission.id,
        threat = threat,
        complications = #mission.complications
    })

    return mission
end

---
-- Process mission outcome and update all campaign systems
-- @param mission_result: Result data {success, casualties, objectives, etc}
function CampaignOrchestrator:processMissionOutcome(mission_result)
    if not mission_result or not self.current_mission then
        print("[Orchestrator] Invalid mission result")
        return
    end

    local success = mission_result.success or false

    -- Update mission history
    if self.current_mission then
        self.current_mission.result = mission_result
        self.current_mission.status = success and "won" or "lost"
    end

    -- Update campaign statistics
    self.campaignData.missions_completed = (self.campaignData.missions_completed or 0) + 1
    if success then
        self.campaignData.missions_won = (self.campaignData.missions_won or 0) + 1
    else
        self.campaignData.missions_lost = (self.campaignData.missions_lost or 0) + 1
    end

    self.campaignData.soldiers_killed = (self.campaignData.soldiers_killed or 0) +
                                       (mission_result.casualties or 0)

    -- Process through all systems in order

    -- 1. Mission outcomes
    if self.systems.mission_outcome then
        self.systems.mission_outcome:processMissionOutcome(mission_result)

        -- Update threat from outcome
        local outcome_threat = mission_result.threat_change or 0
        self.campaignData.threat_level = math.max(0, math.min(100,
            (self.campaignData.threat_level or 0) + outcome_threat
        ))
    end

    -- 2. Craft damage and return
    if self.systems.craft_return and mission_result.craft_damage then
        self.systems.craft_return:processCraftReturn(mission_result.craft_damage)
    end

    -- 3. Unit recovery
    if self.systems.unit_recovery and mission_result.units_participating then
        self.systems.unit_recovery:processUnitRecovery(1, self.campaignData)
    end

    -- 4. Salvage processing
    if self.systems.salvage_processor and mission_result.salvage_items then
        self.systems.salvage_processor:processMissionSalvage(
            mission_result.salvage_items,
            self.campaignData
        )
    end

    -- 5. Faction relationships
    if self.systems.faction_dynamics then
        local favored = mission_result.favored_faction or "united_nations"
        self.systems.faction_dynamics:processMissionOutcome(mission_result, favored)
    end

    -- 6. Difficulty escalation
    if self.systems.difficulty_escalation then
        self.systems.difficulty_escalation:updateDifficultyAfterMission(
            mission_result,
            self.campaignData.threat_level
        )
    end

    -- 7. Check campaign stability
    if self.systems.faction_dynamics then
        local stability = self.systems.faction_dynamics:checkFactionStability()
        if stability.abandonments and #stability.abandonments > 0 then
            table.insert(self.system_state_log, {
                timestamp = os.time(),
                event = "faction_abandoned",
                count = #stability.abandonments
            })
        end
    end

    table.insert(self.system_state_log, {
        timestamp = os.time(),
        event = "mission_processed",
        mission_id = self.current_mission.id,
        success = success,
        threat_after = self.campaignData.threat_level,
        casualties = mission_result.casualties or 0
    })

    self.current_mission = nil
end

---
-- Get current campaign status for UI
-- @return: Campaign status table
function CampaignOrchestrator:getCampaignStatus()
    return {
        days_elapsed = self.campaignData.days_elapsed or 0,
        threat_level = self.campaignData.threat_level or 0,
        campaign_phase = self.campaign_phase,
        difficulty = self.campaignData.difficulty,
        funding = self.campaignData.funding or 0,
        soldiers_active = self:_countActiveSoldiers(),
        soldiers_total = #(self.campaignData.soldiers or {}),
        crafts_operational = self:_countOperationalCrafts(),
        missions_completed = self.campaignData.missions_completed or 0,
        missions_won = self.campaignData.missions_won or 0,
        missions_lost = self.campaignData.missions_lost or 0,
        win_rate = self:_calculateWinRate(),
        system_state = self.state,
        current_mission = self.current_mission
    }
end

---
-- Internal: Count active soldiers
-- @return: Count
function CampaignOrchestrator:_countActiveSoldiers()
    local count = 0
    for _, soldier in ipairs(self.campaignData.soldiers or {}) do
        if soldier.status == "active" then
            count = count + 1
        end
    end
    return count
end

---
-- Internal: Count operational crafts
-- @return: Count
function CampaignOrchestrator:_countOperationalCrafts()
    local count = 0
    for _, craft in ipairs(self.campaignData.crafts or {}) do
        if craft.status == "operational" then
            count = count + 1
        end
    end
    return count
end

---
-- Internal: Calculate win rate
-- @return: Win rate percentage
function CampaignOrchestrator:_calculateWinRate()
    local total = (self.campaignData.missions_won or 0) + (self.campaignData.missions_lost or 0)
    if total == 0 then return 0 end
    return ((self.campaignData.missions_won or 0) / total) * 100
end

---
-- Check if campaign is over (win or lose)
-- @return: {status: "active"/"won"/"lost", reason: string}
function CampaignOrchestrator:checkCampaignStatus()
    local threat = self.campaignData.threat_level or 0

    -- Victory condition: Achieve threat 100 and defeat leadership
    if threat >= 100 and (self.campaignData.final_mission_completed or false) then
        return {
            status = "won",
            reason = "Alien leadership defeated, threat eliminated"
        }
    end

    -- Defeat condition: All soldiers killed or critical funding loss
    local soldier_count = #(self.campaignData.soldiers or {})
    if soldier_count == 0 then
        return {
            status = "lost",
            reason = "All soldiers eliminated"
        }
    end

    -- Defeat condition: No factions remaining
    if self.systems.faction_dynamics then
        local standings = self.systems.faction_dynamics:getFactionStandings()
        local active_factions = 0
        for _, faction in pairs(standings) do
            if faction.status == "active" then
                active_factions = active_factions + 1
            end
        end

        if active_factions == 0 then
            return {
                status = "lost",
                reason = "All international support lost"
            }
        end
    end

    return {
        status = "active",
        reason = "Campaign ongoing"
    }
end

---
-- Serialize entire campaign state
-- @return: Serializable campaign data
function CampaignOrchestrator:serialize()
    return {
        campaignData = self.campaignData,
        state = self.state,
        campaign_phase = self.campaign_phase,
        mission_history = self.mission_history,
        current_mission = self.current_mission,
        systems = {
            mission_outcome = self.systems.mission_outcome and self.systems.mission_outcome:serialize(),
            craft_return = self.systems.craft_return and self.systems.craft_return:serialize(),
            unit_recovery = self.systems.unit_recovery and self.systems.unit_recovery:serialize(),
            difficulty_escalation = self.systems.difficulty_escalation and self.systems.difficulty_escalation:serialize(),
            salvage_processor = self.systems.salvage_processor and self.systems.salvage_processor:serialize(),
            alien_research = self.systems.alien_research and self.systems.alien_research:serialize(),
            base_expansion = self.systems.base_expansion and self.systems.base_expansion:serialize(),
            faction_dynamics = self.systems.faction_dynamics and self.systems.faction_dynamics:serialize(),
            campaign_events = self.systems.campaign_events and self.systems.campaign_events:serialize(),
            difficulty_refinements = self.systems.difficulty_refinements and self.systems.difficulty_refinements:serialize()
        }
    }
end

---
-- Deserialize entire campaign state
-- @param data: Serialized campaign data
function CampaignOrchestrator:deserialize(data)
    if not data then return end

    self.campaignData = data.campaignData or {}
    self.state = data.state or "ready"
    self.campaign_phase = data.campaign_phase or 1
    self.mission_history = data.mission_history or {}
    self.current_mission = data.current_mission

    -- Reinitialize systems and restore state
    self:initializeAllSystems()

    if data.systems then
        if data.systems.mission_outcome and self.systems.mission_outcome then
            self.systems.mission_outcome:deserialize(data.systems.mission_outcome)
        end
        if data.systems.craft_return and self.systems.craft_return then
            self.systems.craft_return:deserialize(data.systems.craft_return)
        end
        if data.systems.unit_recovery and self.systems.unit_recovery then
            self.systems.unit_recovery:deserialize(data.systems.unit_recovery)
        end
        if data.systems.difficulty_escalation and self.systems.difficulty_escalation then
            self.systems.difficulty_escalation:deserialize(data.systems.difficulty_escalation)
        end
        if data.systems.salvage_processor and self.systems.salvage_processor then
            self.systems.salvage_processor:deserialize(data.systems.salvage_processor)
        end
        if data.systems.alien_research and self.systems.alien_research then
            self.systems.alien_research:deserialize(data.systems.alien_research)
        end
        if data.systems.base_expansion and self.systems.base_expansion then
            self.systems.base_expansion:deserialize(data.systems.base_expansion)
        end
        if data.systems.faction_dynamics and self.systems.faction_dynamics then
            self.systems.faction_dynamics:deserialize(data.systems.faction_dynamics)
        end
        if data.systems.campaign_events and self.systems.campaign_events then
            self.systems.campaign_events:deserialize(data.systems.campaign_events)
        end
        if data.systems.difficulty_refinements and self.systems.difficulty_refinements then
            self.systems.difficulty_refinements:deserialize(data.systems.difficulty_refinements)
        end
    end
end

---
-- Get orchestration metrics for diagnostics
-- @return: Metrics table
function CampaignOrchestrator:getOrchestrationMetrics()
    return {
        campaign_days = self.campaignData.days_elapsed or 0,
        threat_level = self.campaignData.threat_level or 0,
        missions_total = #self.mission_history,
        mission_win_rate = self:_calculateWinRate(),
        system_state_log_size = #self.system_state_log,
        systems_active = 10,
        orchestration_state = self.state
    }
end

return CampaignOrchestrator


