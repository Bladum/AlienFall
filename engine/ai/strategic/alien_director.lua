---Alien Director - Strategic AI Orchestrator
---
---Main strategic AI system that orchestrates alien activity across the campaign.
---Monitors player performance, adjusts difficulty, coordinates faction activities,
---generates UFO waves and missions. Acts as the "AI Dungeon Master" creating
---dramatic pacing and replayable campaigns.
---
---Subsystems:
---  - ThreatManager: Calculates threat level based on time and performance
---  - FactionCoordinator: Manages multi-faction activities
---  - Mission Generator: Creates missions matching current threat/factions
---
---Features:
---  - Dynamic difficulty scaling
---  - Adaptive mission generation
---  - Multi-faction coordination
---  - UFO wave planning
---  - Terror attack orchestration
---  - Base infiltration planning
---  - Strategic pressure escalation
---
---Key Exports:
---  - AlienDirector.init(): Start the AI system
---  - AlienDirector.update(delta_time): Update each frame
---  - AlienDirector.generateMission(): Create next mission
---  - AlienDirector.getThreatLevel(): Get current pressure
---  - AlienDirector.getActiveFactions(): Get current threats
---
---Dependencies:
---  - ai.strategic.threat_manager: Campaign pressure
---  - ai.strategic.faction_coordinator: Faction coordination
---  - geoscape.campaign_manager: Campaign phase
---  - lore.lore_manager: Faction and tech lore
---
---@module ai.strategic.alien_director
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local AlienDirector = require("ai.strategic.alien_director")
---  AlienDirector.init()
---  
---  -- During gameplay
---  AlienDirector.update(delta_time)
---  
---  -- Generate mission
---  local mission = AlienDirector.generateMission()
---
---@see ai.strategic.threat_manager For pressure calculation
---@see ai.strategic.faction_coordinator For faction activities

local AlienDirector = {}

-- Subsystems
AlienDirector.threatManager = nil
AlienDirector.factionCoordinator = nil
AlienDirector.missionQueue = {}  -- Pending missions
AlienDirector.lastMissionTime = 0
AlienDirector.missionGenerationRate = 1.0  -- Missions per game day

---Initialize alien director
---Sets up all subsystems for campaign
function AlienDirector.init()
    print("[AlienDirector] Initializing Alien Director strategic AI")
    
    local CampaignManager = require("geoscape.campaign_manager")
    local phase = CampaignManager.getCurrentPhase()
    
    -- Initialize threat manager
    AlienDirector.threatManager = require("ai.strategic.threat_manager")
    AlienDirector.threatManager.init(phase)
    
    -- Initialize faction coordinator
    AlienDirector.factionCoordinator = require("ai.strategic.faction_coordinator")
    AlienDirector.factionCoordinator.init()
    
    print("[AlienDirector] Initialization complete - Campaign Phase: " .. phase)
end

---Update alien director each frame
---Processes threat escalation, generates missions, coordinates faction activities
---@param delta_time number Time since last frame
function AlienDirector.update(delta_time)
    if not AlienDirector.threatManager then return end
    
    -- Update threat level
    AlienDirector.threatManager.update(delta_time)
    
    -- Check if we should generate new missions
    AlienDirector.lastMissionTime = AlienDirector.lastMissionTime + delta_time
    AlienDirector:_updateMissionGeneration()
    
    -- Periodically replan faction operations (every 30 game days = 1 month)
    if math.floor(AlienDirector.lastMissionTime / (86400 * 30)) % 1 == 0 then
        AlienDirector:_replanOperations()
    end
end

---Generate next mission for player
---Creates mission based on current threat, active factions, and campaign phase
---@return table Mission data {type, faction, threat, rewards}
function AlienDirector.generateMission()
    if not AlienDirector.threatManager then
        return {}
    end
    
    local threatLevel = AlienDirector.threatManager.getThreatLevel()
    local activeFactions = AlienDirector.factionCoordinator.getActiveFactions(threatLevel)
    
    if #activeFactions == 0 then
        -- No active factions, generate default research mission
        return AlienDirector:_createDefaultMission()
    end
    
    -- Select random active faction
    local factionId = activeFactions[math.random(1, #activeFactions)]
    local missionType = AlienDirector.factionCoordinator.getMissionType(factionId, threatLevel)
    
    local mission = {
        id = "mission_" .. os.time(),
        type = missionType,
        faction = factionId,
        threatLevel = threatLevel,
        ufos = AlienDirector.factionCoordinator.getUFOComposition(factionId, threatLevel),
        difficulty = AlienDirector:_calculateDifficulty(threatLevel),
        rewards = AlienDirector:_calculateRewards(threatLevel, missionType)
    }
    
    print(string.format("[AlienDirector] Generated mission: %s (%s) - Threat: %.1f%%",
        missionType, factionId, threatLevel * 100))
    
    return mission
end

---Get current threat level
---@return number Threat level (0.0-1.0)
function AlienDirector.getThreatLevel()
    if not AlienDirector.threatManager then return 0 end
    return AlienDirector.threatManager.getThreatLevel()
end

---Get active factions
---@return table Array of faction IDs
function AlienDirector.getActiveFactions()
    if not AlienDirector.factionCoordinator then return {} end
    return AlienDirector.factionCoordinator.getActiveFactions(AlienDirector.getThreatLevel())
end

---Record mission outcome and update AI
---@param missionId string Mission ID
---@param success boolean True if player won
function AlienDirector.recordMissionOutcome(missionId, success)
    if not AlienDirector.threatManager then return end
    
    AlienDirector.threatManager.recordMissionOutcome(success)
    
    -- Log for debug
    print(string.format("[AlienDirector] Mission outcome: %s | New threat: %.1f%%",
        success and "PLAYER WIN" or "PLAYER LOSS",
        AlienDirector.getThreatLevel() * 100))
end

---Get debug information
---@return table Debug info
function AlienDirector.getDebugInfo()
    return {
        threatLevel = AlienDirector.getThreatLevel(),
        threatInfo = AlienDirector.threatManager and AlienDirector.threatManager.getDebugInfo() or {},
        factionInfo = AlienDirector.factionCoordinator and AlienDirector.factionCoordinator.getDebugInfo() or {},
        missionQueue = AlienDirector.missionQueue
    }
end

---Save alien director state
---@return table Serialized state
function AlienDirector.save()
    return {
        threatManager = AlienDirector.threatManager and AlienDirector.threatManager.save() or {},
        missionQueue = AlienDirector.missionQueue,
        lastMissionTime = AlienDirector.lastMissionTime
    }
end

---Load alien director state
---@param data table Serialized state
function AlienDirector.load(data)
    if not data then return end
    
    if data.threatManager and AlienDirector.threatManager then
        AlienDirector.threatManager.load(data.threatManager)
    end
    
    AlienDirector.missionQueue = data.missionQueue or {}
    AlienDirector.lastMissionTime = data.lastMissionTime or 0
    
    print("[AlienDirector] State loaded")
end

---Internal: Update mission generation rate
function AlienDirector:_updateMissionGeneration()
    local missionFrequency = self.threatManager.getMissionFrequency()
    
    -- Generate missions if enough time has passed
    local timeBetweenMissions = 86400 / missionFrequency  -- Seconds between missions
    
    -- Placeholder for actual mission generation
    -- In full implementation, this would queue missions for geoscape to pick up
end

---Internal: Replan faction operations monthly
function AlienDirector:_replanOperations()
    local threatLevel = self.threatManager.getThreatLevel()
    self.factionCoordinator.planOperations(threatLevel)
    
    print("[AlienDirector] Operations replanned for all factions")
end

---Internal: Create default research mission (no alien threat)
---@return table Mission data
function AlienDirector:_createDefaultMission()
    return {
        id = "mission_default_" .. os.time(),
        type = "research",
        faction = "none",
        threatLevel = 0,
        ufos = {},
        difficulty = 1,
        rewards = {funds = 100, research = 1}
    }
end

---Internal: Calculate mission difficulty based on threat
---@param threat number Threat level
---@return number Difficulty 1-5
function AlienDirector:_calculateDifficulty(threat)
    if threat < 0.2 then return 1
    elseif threat < 0.4 then return 2
    elseif threat < 0.6 then return 3
    elseif threat < 0.8 then return 4
    else return 5
    end
end

---Internal: Calculate mission rewards
---@param threat number Threat level
---@param missionType string Type of mission
---@return table Rewards {funds, research, items}
function AlienDirector:_calculateRewards(threat, missionType)
    local baseReward = 500 + (threat * 1500)
    
    if missionType == "terror" then
        return {
            funds = baseReward * 2,
            research = 2,
            items = {"alien_alloy", "plasma_weapon"}
        }
    elseif missionType == "base_assault" then
        return {
            funds = baseReward * 1.5,
            research = 3,
            items = {"alien_technology", "genetic_material"}
        }
    else
        return {
            funds = baseReward,
            research = 1,
            items = {"alloy"}
        }
    end
end

return AlienDirector
