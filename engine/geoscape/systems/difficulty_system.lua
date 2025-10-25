---Difficulty System - Adaptive Campaign Difficulty
---
---Manages adaptive difficulty scaling across campaign lifecycle. Adjusts mission
---difficulty, enemy composition, UFO activity, and late-game escalation based on
---player performance. Includes both basic escalation and advanced refinements for
---high-threat late-game scenarios.
---
---CONSOLIDATED: Merged from difficulty_escalation.lua + difficulty_refinements.lua
---
---Difficulty Components:
---  - Basic Escalation: Win/loss tracking, threat level adjustment
---  - Mission Scaling: Difficulty applied to mission generation
---  - Enemy Composition: Alien unit types based on threat level
---  - UFO Activity: Mission frequency and behavior scaling
---  - Advanced Mechanics: Alien leaders, elite squads, psychological warfare
---  - Late-Game: Strategic deployment patterns, morale effects
---
---Threat Levels:
---  0-25:   Low (Early game, basic aliens)
---  25-50:  Medium (Mid game, mixed squads)
---  50-75:  High (Late game, commanders, leaders)
---  75-100: Critical (End game, elite squads, Ethereal)
---
---Key Exports:
---  - DifficultySystem.new(): Create instance
---  - DifficultySystem:updateDifficultyAfterMission(): Calculate threat change
---  - DifficultySystem:calculateThreatLevel(): Current threat (0-100)
---  - DifficultySystem:scaleMissionDifficulty(mission): Apply difficulty
---  - DifficultySystem:getEnemyComposition(threat): Alien squad composition
---  - DifficultySystem:adjustUFOActivity(threat): UFO frequency
---  - DifficultySystem:getAlienLeaders(threat): Leaders at threat level
---  - DifficultySystem:calculatePsychologicalPressure(): Morale effects
---
---Dependencies:
---  - geoscape.campaign_manager: Campaign state and threat level
---  - battlescape.combat.unit: Unit definitions and stats
---  - content/aliens: Alien unit data
---
---@module geoscape.difficulty_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local DifficultySystem = require("geoscape.difficulty_system")
---  local difficulty = DifficultySystem.new(campaignData)
---
---  -- After mission completion
---  local threatUpdate = difficulty:updateDifficultyAfterMission(mission, outcome)
---
---  -- For mission generation
---  local enemyComposition = difficulty:getEnemyComposition(currentThreat)
---  local scaledMission = difficulty:scaleMissionDifficulty(mission)
---
---  -- Advanced features
---  if threat > 65 then
---    local leader = difficulty:getAlienLeaderByThreat(threat)
---  end
---
---@see geoscape.difficulty_escalation (merged into this)
---@see geoscape.difficulty_refinements (merged into this)

local DifficultySystem = {}
DifficultySystem.__index = DifficultySystem

---Create new difficulty system instance
---@param campaign_data table Campaign state
---@return table DifficultySystem instance
function DifficultySystem.new(campaign_data)
    local self = setmetatable({}, DifficultySystem)

    self.campaignData = campaign_data or {
        wins = 0,
        losses = 0,
        retreats = 0,
        threat_level = 50,
        mission_frequency = 2,
        enemy_difficulty = "normal"
    }

    -- Basic escalation tracking
    self.threatLevel = self.campaignData.threat_level or 50
    self.missionCount = 0
    self.winStreak = 0

    -- Advanced refinements (late-game)
    self.alienLeader = nil
    self.eliteSquads = {}
    self.psychological_pressure = 0
    self.morale_effects = {}
    self.tactical_depth = 0
    self.strategic_patterns = {}

    print("[DifficultySystem] Initialized with threat level: " .. self.threatLevel)
    return self
end

---========== BASIC ESCALATION SYSTEM ==========
---Calculate threat level based on performance
---@return number Threat level (0-100)
function DifficultySystem:calculateThreatLevel()
    local threat = self.threatLevel

    -- Victory streak bonus
    if self.campaignData.wins >= 3 then
        threat = threat + (self.campaignData.wins - 2) * 2
    end

    -- Loss penalty reduction
    if self.campaignData.losses >= 3 then
        threat = threat - (self.campaignData.losses - 2) * 1
    end

    -- Clamp to 0-100
    return math.max(0, math.min(100, threat))
end

---Update difficulty after mission completion
---@param mission table Mission data
---@param outcome table Mission outcome
---@return table|nil Threat update info or nil if error
function DifficultySystem:updateDifficultyAfterMission(mission, outcome, campaignData)
    if not mission or not outcome then
        print("[DifficultySystem] ERROR: Missing mission or outcome data")
        return nil
    end

    campaignData = campaignData or self.campaignData

    local threatUpdate = {
        previous_threat = self.threatLevel,
        threat_change = 0,
        outcome = outcome.status,
        winning_streak = self.campaignData.wins,
        threat_factors = {}
    }

    print(string.format("[DifficultySystem] Updating after %s (threat: %d)",
        outcome.status, self.threatLevel))

    -- Mission outcome impact
    if outcome.status == "victory" then
        campaignData.wins = campaignData.wins + 1
        self.winStreak = self.winStreak + 1
        threatUpdate.threat_change = -5  -- Victory reduces threat
        table.insert(threatUpdate.threat_factors, "victory: -5")

        -- Winning streak escalation (3+ wins)
        if campaignData.wins >= 3 then
            threatUpdate.threat_change = threatUpdate.threat_change + 10
            table.insert(threatUpdate.threat_factors, "winning_streak_x3: +10")
        end

        -- Perfect mission (no losses)
        if outcome.player_casualties == 0 then
            threatUpdate.threat_change = threatUpdate.threat_change + 5
            table.insert(threatUpdate.threat_factors, "no_casualties: +5")
        end

    elseif outcome.status == "defeat" then
        campaignData.losses = campaignData.losses + 1
        self.winStreak = 0
        threatUpdate.threat_change = 15  -- Defeat escalates threat significantly
        table.insert(threatUpdate.threat_factors, "defeat: +15")

    elseif outcome.status == "retreat" then
        campaignData.retreats = campaignData.retreats + 1
        self.winStreak = 0
        threatUpdate.threat_change = 8
        table.insert(threatUpdate.threat_factors, "retreat: +8")
    end

    -- Enemy casualty factor
    if outcome.enemies_killed and outcome.enemies_killed > 20 then
        threatUpdate.threat_change = threatUpdate.threat_change - 3
        table.insert(threatUpdate.threat_factors, "heavy_alien_losses: -3")
    end

    -- Apply threat change
    self.threatLevel = math.max(0, math.min(100, self.threatLevel + threatUpdate.threat_change))
    threatUpdate.new_threat = self.threatLevel

    self.missionCount = self.missionCount + 1

    return threatUpdate
end

---Scale mission difficulty based on threat level
---@param mission table Mission to scale
---@return table|nil Scaled mission or nil if error
function DifficultySystem:scaleMissionDifficulty(mission)
    if not mission then return nil end

    local threat = self:calculateThreatLevel()

    -- Difficulty scaling
    if threat < 25 then
        mission.difficulty = "easy"
        mission.alien_count_multiplier = 0.8
        mission.enemy_level_multiplier = 1.0
    elseif threat < 50 then
        mission.difficulty = "normal"
        mission.alien_count_multiplier = 1.0
        mission.enemy_level_multiplier = 1.1
    elseif threat < 75 then
        mission.difficulty = "hard"
        mission.alien_count_multiplier = 1.3
        mission.enemy_level_multiplier = 1.3
    else
        mission.difficulty = "impossible"
        mission.alien_count_multiplier = 1.5
        mission.enemy_level_multiplier = 1.5
    end

    return mission
end

---Get enemy composition based on threat level
---@param threat number Threat level (0-100)
---@return table Alien unit composition
function DifficultySystem:getEnemyComposition(threat)
    threat = threat or self.threatLevel

    local composition = {}

    if threat < 25 then
        composition = {
            {type = "sectoid", count = 3},
            {type = "floater", count = 1}
        }
    elseif threat < 50 then
        composition = {
            {type = "sectoid", count = 2},
            {type = "floater", count = 2},
            {type = "muton", count = 1}
        }
    elseif threat < 75 then
        composition = {
            {type = "sectoid", count = 1},
            {type = "muton", count = 2},
            {type = "ethereal", count = 1},
            {type = "sectoid_commander", count = 1}
        }
    else
        composition = {
            {type = "muton", count = 2},
            {type = "ethereal", count = 2},
            {type = "sectoid_commander", count = 1},
            {type = "ethereal_supreme", count = 1}
        }
    end

    return composition
end

---Adjust UFO activity based on threat
---@param threat number Threat level
---@return table UFO activity parameters
function DifficultySystem:adjustUFOActivity(threat)
    threat = threat or self.threatLevel

    return {
        frequency = math.ceil(threat / 20),  -- 0-5 missions per month
        escort_size = math.ceil(threat / 15),  -- 0-6 escort craft
        aggressiveness = threat / 100,  -- 0.0-1.0
        retaliation_chance = threat / 100  -- 0.0-1.0
    }
end

---========== ADVANCED REFINEMENT SYSTEM ==========
---Get alien leader templates
---@return table Leaders by threat level
function DifficultySystem:_getAlienLeaderTemplates()
    return {
        sectoid_commander = {
            name = "Sectoid Commander",
            threat_min = 65,
            threat_max = 85,
            emergence_threshold = 70,
            health_multiplier = 2.0,
            psi_power = 1.8,
            abilities = {"mind_control", "psionic_lance", "unit_coordination"},
            tactics = "supportive",
            morale_penalty = 20
        },

        ethereal_supreme = {
            name = "Ethereal Supreme Being",
            threat_min = 80,
            threat_max = 100,
            emergence_threshold = 85,
            health_multiplier = 3.0,
            psi_power = 2.5,
            abilities = {"reality_warp", "gateway_summoning", "elder_mind"},
            tactics = "overwhelming",
            morale_penalty = 50
        }
    }
end

---Get alien leader for given threat level
---@param threat number Threat level
---@return table|nil Leader template or nil
function DifficultySystem:getAlienLeaderByThreat(threat)
    if threat < 65 then
        return nil
    end

    local leaders = self:_getAlienLeaderTemplates()

    for _, leader in pairs(leaders) do
        if threat >= leader.threat_min and threat <= leader.threat_max then
            return leader
        end
    end

    return leaders.ethereal_supreme
end

---Calculate psychological pressure effects
---@return number Pressure level (0-100)
function DifficultySystem:calculatePsychologicalPressure()
    local pressure = 0

    -- Loss streak increases psychological pressure
    if self.campaignData.losses >= 2 then
        pressure = pressure + (self.campaignData.losses - 1) * 15
    end

    -- Threat level contribution
    pressure = pressure + (self.threatLevel / 100) * 50

    -- Clamp 0-100
    return math.max(0, math.min(100, pressure))
end

---Get system status
---@return table Status information
function DifficultySystem:getStatus()
    return {
        threat_level = self:calculateThreatLevel(),
        win_rate = self.campaignData.wins / (self.campaignData.wins + self.campaignData.losses + 1),
        mission_count = self.missionCount,
        win_streak = self.winStreak,
        current_leader = self.alienLeader,
        psychological_pressure = self:calculatePsychologicalPressure(),
        enemy_count = #self.eliteSquads,
    }
end

return DifficultySystem

