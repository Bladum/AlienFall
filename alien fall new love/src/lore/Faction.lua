--- Faction Class
-- Represents a narrative adversary faction in the game
--
-- @classmod domain.factions.Faction

-- GROK: Faction represents alien adversaries with behavior profiles and mission spawning
-- GROK: Used by mission_system and world_system for dynamic threat generation
-- GROK: Key methods: getRegionSpawnWeight(), getBehaviorProfile(), shouldDeactivate()
-- GROK: Handles faction activation, progress tracking, and end conditions

local Faction = {}
Faction.__index = Faction

--- Create a new faction instance
-- @param data Faction data from TOML configuration
-- @return Faction instance
function Faction.new(data)
    local self = setmetatable({}, Faction)

    -- Basic faction properties
    self.id = data.id
    self.name = data.name
    self.description = data.description
    self.race = data.race

    -- Spawn configuration
    self.spawn = data.spawn or {}
    self.preferred_regions = self.spawn.preferred_regions or {}
    self.avoided_regions = self.spawn.avoided_regions or {}
    self.mission_templates = self.spawn.mission_templates or {}
    self.unit_pool = self.spawn.unit_pool or {}

    -- Behavior parameters
    self.behavior = data.behavior or {}
    self.aggression_level = self.behavior.aggression_level or 0.5
    self.stealth_preference = self.behavior.stealth_preference or 0.5
    self.technology_focus = self.behavior.technology_focus or 0.5
    self.expansion_rate = self.behavior.expansion_rate or 0.5

    -- Rewards
    self.rewards = data.rewards or {}
    self.score_multiplier = self.rewards.score_multiplier or 1.0
    self.research_points = self.rewards.research_points or 0
    self.special_items = self.rewards.special_items or {}
    self.narrative_unlocks = self.rewards.narrative_unlocks or {}

    -- End conditions
    self.end_conditions = data.end_conditions or {}
    self.required_missions_completed = self.end_conditions.required_missions_completed or 0
    self.required_research = self.end_conditions.required_research or {}
    self.time_limit_days = self.end_conditions.time_limit_days or 0

    -- Metadata
    self.metadata = data.metadata or {}
    self.tags = self.metadata.tags or {}
    self.difficulty_modifier = self.metadata.difficulty_modifier or 1.0
    self.threat_level = self.metadata.threat_level or "medium"

    -- Runtime state
    self.is_active = true
    self.missions_completed = 0
    self.research_completed = {}
    self.spawned_missions = {}
    self.activation_time = nil
    self.score_contribution = 0

    return self
end

--- Activate the faction
-- @param activation_time Current game time
function Faction:activate(activation_time)
    self.is_active = true
    self.activation_time = activation_time
end

--- Deactivate the faction
function Faction:deactivate()
    self.is_active = false
end

--- Check if faction should be deactivated based on end conditions
-- @param current_time Current game time
-- @param completed_research List of completed research
-- @return boolean Whether faction should be deactivated
function Faction:shouldDeactivate(current_time, completed_research)
    -- Check mission completion
    if self.missions_completed >= self.required_missions_completed then
        return true
    end

    -- Check research completion
    for _, required_research in ipairs(self.required_research) do
        local research_completed = false
        for _, completed in ipairs(completed_research) do
            if completed == required_research then
                research_completed = true
                break
            end
        end
        if not research_completed then
            return false
        end
    end

    -- Check time limit
    if self.time_limit_days > 0 and self.activation_time then
        local elapsed_days = (current_time - self.activation_time) / (24 * 3600)
        if elapsed_days >= self.time_limit_days then
            return true
        end
    end

    return false
end

--- Record mission completion
-- @param mission_id ID of completed mission
function Faction:recordMissionCompletion(mission_id)
    self.missions_completed = self.missions_completed + 1
    table.insert(self.spawned_missions, {id = mission_id, completed = true})
end

--- Record research completion
-- @param research_id ID of completed research
function Faction:recordResearchCompletion(research_id)
    table.insert(self.research_completed, research_id)
end

--- Calculate spawn weight for a region
-- @param region_id Region identifier
-- @return number Spawn weight multiplier
function Faction:getRegionSpawnWeight(region_id)
    -- Check preferred regions
    for _, preferred in ipairs(self.preferred_regions) do
        if preferred == region_id then
            return 1.5  -- 50% bonus for preferred regions
        end
    end

    -- Check avoided regions
    for _, avoided in ipairs(self.avoided_regions) do
        if avoided == region_id then
            return 0.3  -- 70% penalty for avoided regions
        end
    end

    return 1.0  -- Default weight
end

--- Get available mission templates for this faction
-- @return table List of mission template IDs
function Faction:getAvailableMissionTemplates()
    return self.mission_templates
end

--- Get available unit pool for this faction
-- @return table List of unit IDs
function Faction:getAvailableUnits()
    return self.unit_pool
end

--- Calculate difficulty modifier for missions spawned by this faction
-- @return number Difficulty multiplier
function Faction:getDifficultyModifier()
    return self.difficulty_modifier
end

--- Calculate score contribution from this faction
-- @return number Score points
function Faction:getScoreContribution()
    return self.score_contribution * self.score_multiplier
end

--- Add score contribution
-- @param score Amount of score to add
function Faction:addScoreContribution(score)
    self.score_contribution = self.score_contribution + score
end

--- Check if faction has a specific tag
-- @param tag Tag to check for
-- @return boolean Whether the faction has the tag
function Faction:hasTag(tag)
    for _, faction_tag in ipairs(self.tags) do
        if faction_tag == tag then
            return true
        end
    end
    return false
end

--- Get faction threat assessment
-- @return string Threat level
function Faction:getThreatLevel()
    return self.threat_level
end

--- Get faction behavior profile
-- @return table Behavior parameters
function Faction:getBehaviorProfile()
    return {
        aggression = self.aggression_level,
        stealth = self.stealth_preference,
        technology = self.technology_focus,
        expansion = self.expansion_rate
    }
end

return Faction
