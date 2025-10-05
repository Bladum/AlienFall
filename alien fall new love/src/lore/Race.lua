--- Race Class
-- Represents racial categories for units in Alien Fall
--
-- @classmod domain.lore.Race

-- GROK: Race provides categorical metadata for units, controlling equipment compatibility and content access
-- GROK: Used by unit_system for filtering, compatibility checks, and faction composition
-- GROK: Key methods: isCompatible(), getDisplayInfo(), checkRequirements()
-- GROK: Manages race tags, compatibility rules, and recruitment prerequisites

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
    self.faction = data.faction or "neutral"

    -- Race tags and categories
    self.tags = data.tags or {}
    self.primary_tag = data.primary_tag or self.id

    -- Compatibility and access rules
    self.compatibility = data.compatibility or {}
    self.allowed_equipment = self.compatibility.allowed_equipment or {}
    self.restricted_equipment = self.compatibility.restricted_equipment or {}
    self.allowed_transformations = self.compatibility.allowed_transformations or {}

    -- Recruitment and availability
    self.recruitment = data.recruitment or {}
    self.prerequisites = self.recruitment.prerequisites or {}
    self.recruitment_weight = self.recruitment.weight or 1.0
    self.unlock_requirements = self.recruitment.unlock_requirements or {}

    -- Visual and UI properties
    self.visual = data.visual or {}
    self.icon = self.visual.icon or "default_race_icon"
    self.color = self.visual.color or {128, 128, 128}

    -- Lore and background
    self.lore = data.lore or {}
    self.background = self.lore.background or ""
    self.relations = self.lore.relations or {}

    return self
end

--- Check if this race is compatible with given equipment
-- @param equipment_id Equipment ID to check
-- @param equipment_tags Equipment tags
-- @return boolean True if compatible
function Race:isCompatible(equipment_id, equipment_tags)
    -- Check explicit restrictions first
    for _, restricted in ipairs(self.restricted_equipment) do
        if restricted == equipment_id then
            return false
        end
    end

    -- Check allowed equipment list (if specified)
    if #self.allowed_equipment > 0 then
        for _, allowed in ipairs(self.allowed_equipment) do
            if allowed == equipment_id then
                return true
            end
        end
        return false  -- Not in allowed list
    end

    -- Check tag-based compatibility
    for _, equip_tag in ipairs(equipment_tags or {}) do
        for _, race_tag in ipairs(self.tags) do
            if equip_tag == race_tag then
                return true
            end
        end
    end

    -- Default to compatible if no specific rules
    return true
end

--- Check if this race can use a specific transformation
-- @param transformation_id Transformation ID to check
-- @return boolean True if allowed
function Race:canTransform(transformation_id)
    for _, allowed in ipairs(self.allowed_transformations) do
        if allowed == transformation_id then
            return true
        end
    end
    return false
end

--- Check if recruitment prerequisites are met
-- @param game_state Current game state
-- @return boolean True if available for recruitment
function Race:checkRequirements(game_state)
    -- Check research prerequisites
    if self.prerequisites.research then
        for _, research_id in ipairs(self.prerequisites.research) do
            if not game_state:hasCompletedResearch(research_id) then
                return false
            end
        end
    end

    -- Check facility prerequisites
    if self.prerequisites.facilities then
        for _, facility_id in ipairs(self.prerequisites.facilities) do
            if not game_state:hasFacility(facility_id) then
                return false
            end
        end
    end

    -- Check campaign progress prerequisites
    if self.prerequisites.campaign_progress then
        local required_progress = self.prerequisites.campaign_progress
        if game_state.campaign_progress < required_progress then
            return false
        end
    end

    return true
end

--- Get recruitment weight for this race
-- @param game_state Current game state
-- @return number Recruitment weight (0 = unavailable)
function Race:getRecruitmentWeight(game_state)
    if not self:checkRequirements(game_state) then
        return 0
    end
    return self.recruitment_weight
end

--- Get display information for UI
-- @return table Display data
function Race:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        faction = self.faction,
        icon = self.icon,
        color = self.color,
        tags = self.tags,
        background = self.background
    }
end

--- Get compatibility information
-- @return table Compatibility data
function Race:getCompatibilityInfo()
    return {
        allowed_equipment = self.allowed_equipment,
        restricted_equipment = self.restricted_equipment,
        allowed_transformations = self.allowed_transformations,
        tags = self.tags
    }
end

--- Get lore information
-- @return table Lore data
function Race:getLoreInfo()
    return {
        background = self.background,
        relations = self.relations,
        faction = self.faction
    }
end

--- Check if this race has a specific tag
-- @param tag Tag to check for
-- @return boolean True if race has the tag
function Race:hasTag(tag)
    for _, race_tag in ipairs(self.tags) do
        if race_tag == tag then
            return true
        end
    end
    return false
end

--- Get primary tag for this race
-- @return string Primary race tag
function Race:getPrimaryTag()
    return self.primary_tag
end

return Race
