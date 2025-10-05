--- Race Class
-- Represents a race/category for units, providing metadata for compatibility and organization
--
-- @classmod domain.races.Race

-- GROK: Race defines unit species with compatibility rules, recruitment requirements, and visual traits
-- GROK: Used by unit_system for alien race management and recruitment mechanics
-- GROK: Key methods: has_tag(), is_equipment_compatible(), check_recruitment_requirements()
-- GROK: Handles race tags, equipment compatibility, and unlock progression

local Race = {}
Race.__index = Race

--- Create a new race instance
-- @param data Race data from TOML configuration
-- @return Race instance
function Race.new(data)
    local self = setmetatable({}, Race)

    -- Basic race properties
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""
    self.category = data.category or "biological"

    -- Race tags for compatibility checking
    self.tags = data.tags or {}
    self.primary_tags = self.tags.primary or {}
    self.secondary_tags = self.tags.secondary or {}

    -- Compatibility information
    self.compatibility = data.compatibility or {}
    self.equipment_compatibility = self.compatibility.equipment or {}
    self.transformation_compatibility = self.compatibility.transformations or {}
    self.ability_compatibility = self.compatibility.abilities or {}

    -- Recruitment information
    self.recruitment = data.recruitment or {}
    self.base_difficulty = self.recruitment.base_difficulty or "medium"
    self.research_requirements = self.recruitment.research_requirements or {}
    self.facility_requirements = self.recruitment.facility_requirements or {}

    -- Visual information
    self.visual = data.visual or {}
    self.portrait_style = self.visual.portrait_style or "default"
    self.color_scheme = self.visual.color_scheme or "default"

    -- Race state
    self.is_available = false  -- Whether this race can be recruited
    self.unlock_progress = 0  -- Progress toward unlocking (0-100)

    return self
end

--- Check if this race has a specific tag
-- @param tag The tag to check for
-- @return true if the race has the tag, false otherwise
function Race:has_tag(tag)
    for _, race_tag in ipairs(self.primary_tags) do
        if race_tag == tag then
            return true
        end
    end

    for _, race_tag in ipairs(self.secondary_tags) do
        if race_tag == tag then
            return true
        end
    end

    return false
end

--- Check if this race is compatible with specific equipment
-- @param equipment_type The equipment type to check
-- @return true if compatible, false otherwise
function Race:is_equipment_compatible(equipment_type)
    for _, compatible_type in ipairs(self.equipment_compatibility) do
        if compatible_type == equipment_type then
            return true
        end
    end
    return false
end

--- Check if this race can undergo specific transformations
-- @param transformation_type The transformation type to check
-- @return true if compatible, false otherwise
function Race:is_transformation_compatible(transformation_type)
    for _, compatible_type in ipairs(self.transformation_compatibility) do
        if compatible_type == transformation_type then
            return true
        end
    end
    return false
end

--- Check if this race can use specific abilities
-- @param ability_type The ability type to check
-- @return true if compatible, false otherwise
function Race:is_ability_compatible(ability_type)
    for _, compatible_type in ipairs(self.ability_compatibility) do
        if compatible_type == ability_type then
            return true
        end
    end
    return false
end

--- Check if recruitment requirements are met
-- @param completed_research Table of completed research projects
-- @param available_facilities Table of available facilities
-- @return true if requirements met, false otherwise
function Race:check_recruitment_requirements(completed_research, available_facilities)
    -- Check research requirements
    for _, required_research in ipairs(self.research_requirements) do
        if not completed_research[required_research] then
            return false
        end
    end

    -- Check facility requirements
    for _, required_facility in ipairs(self.facility_requirements) do
        if not available_facilities[required_facility] then
            return false
        end
    end

    return true
end

--- Update race availability based on game state
-- @param completed_research Table of completed research projects
-- @param available_facilities Table of available facilities
function Race:update_availability(completed_research, available_facilities)
    self.is_available = self:check_recruitment_requirements(completed_research, available_facilities)

    if self.is_available then
        self.unlock_progress = 100
    else
        -- Calculate partial progress for UI display
        local research_progress = 0
        local total_research = #self.research_requirements

        if total_research > 0 then
            for _, required_research in ipairs(self.research_requirements) do
                if completed_research[required_research] then
                    research_progress = research_progress + 1
                end
            end
            self.unlock_progress = (research_progress / total_research) * 100
        else
            self.unlock_progress = 100  -- No research requirements
        end
    end
end

--- Get all tags for this race (primary and secondary combined)
-- @return Table of all race tags
function Race:get_all_tags()
    local all_tags = {}

    for _, tag in ipairs(self.primary_tags) do
        table.insert(all_tags, tag)
    end

    for _, tag in ipairs(self.secondary_tags) do
        table.insert(all_tags, tag)
    end

    return all_tags
end

--- Get race display information
-- @return Table with display information
function Race:get_display_info()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        category = self.category,
        is_available = self.is_available,
        unlock_progress = self.unlock_progress,
        portrait_style = self.portrait_style,
        color_scheme = self.color_scheme,
        tags = self:get_all_tags()
    }
end

--- Get recruitment information
-- @return Table with recruitment details
function Race:get_recruitment_info()
    return {
        difficulty = self.base_difficulty,
        research_requirements = self.research_requirements,
        facility_requirements = self.facility_requirements,
        is_available = self.is_available,
        unlock_progress = self.unlock_progress
    }
end

--- Get compatibility information
-- @return Table with compatibility details
function Race:get_compatibility_info()
    return {
        equipment = self.equipment_compatibility,
        transformations = self.transformation_compatibility,
        abilities = self.ability_compatibility
    }
end

return Race
