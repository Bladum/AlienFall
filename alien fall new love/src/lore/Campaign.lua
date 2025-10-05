--- Campaign Class
-- Represents a narrative campaign that sequences missions over time
--
-- @classmod domain.factions.Campaign

-- GROK: Campaign manages narrative mission sequences with waves and progression tracking
-- GROK: Used by mission_system for structured alien invasion scenarios and story arcs
-- GROK: Key methods: activate(), update(), processWaves(), getProgress()
-- GROK: Handles campaign prerequisites, wave spawning, and completion conditions

local Campaign = {}
Campaign.__index = Campaign

--- Create a new campaign instance
-- @param data Campaign data from TOML configuration
-- @return Campaign instance
function Campaign.new(data)
    local self = setmetatable({}, Campaign)

    -- Basic campaign properties
    self.id = data.id
    self.name = data.name
    self.description = data.description
    self.faction = data.faction

    -- Activation parameters
    self.activation = data.activation or {}
    self.weight = self.activation.weight or 1.0
    self.prerequisites = self.activation.prerequisites or {}
    self.max_instances = self.activation.max_instances or 1
    self.monthly_limit = self.activation.monthly_limit or 1

    -- Scope and targeting
    self.scope = data.scope or {}
    self.target_regions = self.scope.target_regions or {}
    self.duration_days = self.scope.duration_days or 30
    self.priority = self.scope.priority or "medium"

    -- Wave system
    self.waves = data.waves or {}
    self.start_delay_days = self.waves.start_delay_days or 0
    self.wave_definitions = self.waves.wave or {}

    -- End conditions
    self.end_conditions = data.end_conditions or {}

    -- Rewards
    self.rewards = data.rewards or {}
    self.score_bonus = self.rewards.score_bonus or 0
    self.research_unlocks = self.rewards.research_unlocks or {}
    self.special_items = self.rewards.special_items or {}

    -- Metadata
    self.metadata = data.metadata or {}
    self.tags = self.metadata.tags or {}
    self.difficulty = self.metadata.difficulty or "medium"
    self.narrative_theme = self.metadata.narrative_theme

    -- Runtime state
    self.status = "inactive"  -- inactive, active, paused, completed, failed
    self.activation_time = nil
    self.current_wave_index = 0
    self.spawned_missions = {}
    self.completed_waves = 0
    self.seed = nil  -- For deterministic behavior

    return self
end

--- Activate the campaign
-- @param activation_time Current game time
-- @param seed Random seed for deterministic behavior
function Campaign:activate(activation_time, seed)
    self.status = "active"
    self.activation_time = activation_time
    self.seed = seed
    self.current_wave_index = 0
end

--- Update campaign progress
-- @param current_time Current game time
function Campaign:update(current_time)
    if self.status ~= "active" then return end

    local elapsed_days = (current_time - self.activation_time) / (24 * 3600)

    -- Check for campaign timeout
    if elapsed_days >= self.duration_days then
        self.status = "failed"
        return
    end

    -- Process waves
    self:processWaves(current_time)
end

--- Process campaign waves
-- @param current_time Current game time
function Campaign:processWaves(current_time)
    local elapsed_days = (current_time - self.activation_time) / (24 * 3600)

    for i, wave in ipairs(self.wave_definitions) do
        local wave_activation_time = self.start_delay_days + wave.delay_days

        if elapsed_days >= wave_activation_time and i > self.current_wave_index then
            self:activateWave(i, wave, current_time)
            self.current_wave_index = i
        end
    end
end

--- Activate a specific wave
-- @param wave_index Index of the wave
-- @param wave_data Wave definition data
-- @param activation_time Time of activation
function Campaign:activateWave(wave_index, wave_data, activation_time)
    -- Spawn missions for this wave
    for _, mission_spec in ipairs(wave_data.missions) do
        self:spawnMission(mission_spec, activation_time)
    end
end

--- Spawn a mission for the campaign
-- @param mission_spec Mission specification
-- @param spawn_time Time to spawn the mission
function Campaign:spawnMission(mission_spec, spawn_time)
    local mission_instance = {
        template = mission_spec.template,
        region = mission_spec.region,
        spawn_time = spawn_time,
        campaign_id = self.id,
        wave_index = self.current_wave_index,
        status = "pending"
    }

    table.insert(self.spawned_missions, mission_instance)
end

--- Record mission completion
-- @param mission_id ID of completed mission
function Campaign:recordMissionCompletion(mission_id)
    for _, mission in ipairs(self.spawned_missions) do
        if mission.id == mission_id then
            mission.status = "completed"
            break
        end
    end

    -- Check if campaign should end
    self:checkCompletionConditions()
end

--- Check if campaign completion conditions are met
function Campaign:checkCompletionConditions()
    if self.end_conditions.all_waves_completed then
        local all_waves_done = true
        for _, wave in ipairs(self.wave_definitions) do
            local wave_completed = true
            for _, mission_spec in ipairs(wave.missions) do
                -- Check if all missions in this wave are completed
                local mission_found = false
                for _, spawned in ipairs(self.spawned_missions) do
                    if spawned.template == mission_spec.template and spawned.status == "completed" then
                        mission_found = true
                        break
                    end
                end
                if not mission_found then
                    wave_completed = false
                    break
                end
            end
            if not wave_completed then
                all_waves_done = false
                break
            end
        end

        if all_waves_done then
            self.status = "completed"
        end
    end
end

--- Get all active missions spawned by this campaign
-- @return table List of active mission instances
function Campaign:getActiveMissions()
    local active = {}
    for _, mission in ipairs(self.spawned_missions) do
        if mission.status == "active" or mission.status == "pending" then
            table.insert(active, mission)
        end
    end
    return active
end

--- Get campaign progress as a percentage
-- @return number Progress (0.0 to 1.0)
function Campaign:getProgress()
    if #self.wave_definitions == 0 then return 1.0 end

    local total_missions = 0
    local completed_missions = 0

    for _, wave in ipairs(self.wave_definitions) do
        for _ in ipairs(wave.missions) do
            total_missions = total_missions + 1
        end
    end

    for _, mission in ipairs(self.spawned_missions) do
        if mission.status == "completed" then
            completed_missions = completed_missions + 1
        end
    end

    return completed_missions / total_missions
end

--- Check if campaign prerequisites are met
-- @param completed_campaigns List of completed campaign IDs
-- @return boolean Whether prerequisites are met
function Campaign:checkPrerequisites(completed_campaigns)
    for _, prereq in ipairs(self.prerequisites) do
        local found = false
        for _, completed in ipairs(completed_campaigns) do
            if completed == prereq then
                found = true
                break
            end
        end
        if not found then
            return false
        end
    end
    return true
end

--- Get campaign priority level
-- @return string Priority level
function Campaign:getPriority()
    return self.priority
end

--- Get campaign difficulty
-- @return string Difficulty level
function Campaign:getDifficulty()
    return self.difficulty
end

--- Check if campaign has a specific tag
-- @param tag Tag to check for
-- @return boolean Whether the campaign has the tag
function Campaign:hasTag(tag)
    for _, campaign_tag in ipairs(self.tags) do
        if campaign_tag == tag then
            return true
        end
    end
    return false
end

--- Get campaign rewards
-- @return table Reward data
function Campaign:getRewards()
    return {
        score_bonus = self.score_bonus,
        research_unlocks = self.research_unlocks,
        special_items = self.special_items
    }
end

return Campaign
