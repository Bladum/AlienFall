--- Alien Base Mission Class
-- Represents an assault mission on an alien base
--
-- @classmod domain.missions.AlienBaseMission

-- GROK: AlienBaseMission handles base assault scenarios with structural integrity and defenses
-- GROK: Used by mission_system for tactical base destruction objectives
-- GROK: Key methods: update(), getStatusBriefing(), getDifficultyMultiplier()
-- GROK: Manages base integrity, defense destruction, and reinforcement waves

local Mission = require("lore.Mission")

local AlienBaseMission = setmetatable({}, {__index = Mission})
AlienBaseMission.__index = AlienBaseMission

--- Create a new alien base mission instance
-- @param data Mission data from TOML configuration
-- @return AlienBaseMission instance
function AlienBaseMission.new(data)
    local self = setmetatable(Mission.new(data), AlienBaseMission)

    -- Base-specific properties
    self.base_size = data.base_size or "medium"
    self.base_type = data.base_type or "outpost"
    self.base_layout = data.deployment.base_layout or "standard"
    self.reinforcement_waves = data.deployment.reinforcement_waves or 1

    -- Base mission threats
    self.threats = data.threats or {}

    -- Base mission state
    self.base_integrity = 100  -- 0-100% structural integrity
    self.defenses_destroyed = 0
    self.command_systems_eliminated = false
    self.reinforcements_called = false
    self.reinforcement_wave_count = 0

    return self
end

--- Start the alien base mission
-- @param start_time Current game time
function AlienBaseMission:start(start_time)
    Mission.start(self, start_time)
    self.base_integrity = 100  -- Base starts fully intact
end

--- Update alien base mission progress
-- @param current_time Current game time
function AlienBaseMission:update(current_time)
    Mission.update(self, current_time)

    if self.status ~= "active" then return end

    -- Simulate base assault progress
    local progress_ratio = self.progress

    -- Reduce base integrity over time
    self.base_integrity = math.max(0, 100 - (progress_ratio * 80))

    -- Destroy defenses
    self.defenses_destroyed = math.floor(progress_ratio * 12)  -- Assume 12 major defenses

    -- Command systems elimination
    if progress_ratio > 0.7 and not self.command_systems_eliminated then
        self.command_systems_eliminated = math.random() < 0.8  -- 80% chance
    end

    -- Reinforcement waves
    local expected_waves = math.floor(progress_ratio * self.reinforcement_waves)
    if expected_waves > self.reinforcement_wave_count then
        self.reinforcement_wave_count = expected_waves
        self.reinforcements_called = true
    end
end

--- Complete the alien base mission
function AlienBaseMission:complete()
    Mission.complete(self)

    -- Additional base-specific completion logic
    if self.base_integrity <= 20 then
        self.rewards.base_destruction_bonus = true
    end

    if self.command_systems_eliminated then
        self.rewards.command_elimination_bonus = true
    end

    if self.defenses_destroyed >= 10 then
        self.rewards.defense_elimination_bonus = true
    end
end

--- Get alien base mission status briefing
-- @return string Status briefing
function AlienBaseMission:getStatusBriefing()
    local briefing = Mission.getBriefing(self)

    briefing = briefing .. string.format("BASE SIZE: %s\n", string.upper(self.base_size))
    briefing = briefing .. string.format("BASE TYPE: %s\n", string.upper(self.base_type))
    briefing = briefing .. string.format("BASE INTEGRITY: %d%%\n", self.base_integrity)
    briefing = briefing .. string.format("DEFENSES DESTROYED: %d/12\n", self.defenses_destroyed)

    if self.command_systems_eliminated then
        briefing = briefing .. "COMMAND SYSTEMS: ELIMINATED\n"
    else
        briefing = briefing .. "COMMAND SYSTEMS: ACTIVE\n"
    end

    if self.reinforcements_called then
        briefing = briefing .. string.format("REINFORCEMENTS: %d waves arrived\n", self.reinforcement_wave_count)
    end

    -- Threat assessment
    if self.threats.base_defenses then
        briefing = briefing .. string.format("BASE DEFENSES: %s\n", string.upper(self.threats.base_defenses))
    end

    if self.threats.alien_presence then
        briefing = briefing .. string.format("ALIEN PRESENCE: %s\n", string.upper(self.threats.alien_presence))
    end

    return briefing
end

--- Calculate mission difficulty based on base size and defenses
-- @return number Difficulty multiplier
function AlienBaseMission:getDifficultyMultiplier()
    local multiplier = 1.0

    -- Base size multiplier
    local size_multipliers = {
        small = 1.0,
        medium = 1.3,
        large = 1.7,
        massive = 2.2
    }
    multiplier = multiplier * (size_multipliers[self.base_size] or 1.0)

    -- Defense multiplier
    if self.threats.base_defenses == "heavy" then
        multiplier = multiplier * 1.4
    elseif self.threats.base_defenses == "maximum" then
        multiplier = multiplier * 1.8
    end

    -- Alien presence multiplier
    if self.threats.alien_presence == "extreme" then
        multiplier = multiplier * 1.5
    elseif self.threats.alien_presence == "high" then
        multiplier = multiplier * 1.2
    end

    -- Reinforcement multiplier
    multiplier = multiplier * (1.0 + (self.reinforcement_waves * 0.1))

    return multiplier
end

return AlienBaseMission
