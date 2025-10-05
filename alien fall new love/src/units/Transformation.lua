--- Transformation.lua
-- Unit transformations system for Alien Fall
-- Defines permanent or temporary modifications to unit capabilities

-- GROK: Transformation represents unit modifications with stat changes, ability grants, and costs
-- GROK: Used by unit_system for cybernetic enhancements and alien mutations
-- GROK: Key methods: applyToUnit(), canAfford(), meetsRequirements()
-- GROK: Handles transformation compatibility, costs, and duration mechanics

local class = require 'lib.Middleclass'

Transformation = class('Transformation')

--- Initialize a new transformation
-- @param data The TOML data for this transformation
function Transformation:initialize(data)
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""

    -- Transformation category
    self.category = data.category or "enhancement"

    -- Duration type
    self.duration_type = data.duration_type or "permanent"

    -- Stat modifications
    self.stat_modifications = data.stat_modifications or {}

    -- Ability grants
    self.ability_grants = data.ability_grants or {}

    -- Visual changes
    self.visual_changes = data.visual_changes or {}

    -- Requirements
    self.requirements = data.requirements or {}

    -- Costs
    self.costs = data.costs or {}

    -- Effects
    self.effects = data.effects or {}

    -- Validate data
    self:_validate()
end

--- Validate the transformation data
function Transformation:_validate()
    assert(self.id, "Transformation must have an id")
    assert(self.name, "Transformation must have a name")

    -- Validate duration type
    local validTypes = {permanent = true, temporary = true, conditional = true}
    assert(validTypes[self.duration_type], "Invalid duration type: " .. tostring(self.duration_type))
end

--- Check if this transformation is permanent
-- @return true if permanent
function Transformation:isPermanent()
    return self.duration_type == "permanent"
end

--- Check if this transformation is temporary
-- @return true if temporary
function Transformation:isTemporary()
    return self.duration_type == "temporary"
end

--- Check if this transformation is conditional
-- @return true if conditional
function Transformation:isConditional()
    return self.duration_type == "conditional"
end

--- Get the duration in days (for temporary transformations)
-- @return Duration in days or 0 for permanent
function Transformation:getDuration()
    return self.effects.duration_days or 0
end

--- Get stat modifications
-- @return Table of stat modifications {stat_name = modification_value}
function Transformation:getStatModifications()
    return self.stat_modifications
end

--- Get ability grants
-- @return Array of ability IDs granted by this transformation
function Transformation:getAbilityGrants()
    return self.ability_grants
end

--- Get visual changes
-- @return Table of visual change descriptions
function Transformation:getVisualChanges()
    return self.visual_changes
end

--- Get research requirements
-- @return Array of required research IDs
function Transformation:getResearchRequirements()
    return self.requirements.research or {}
end

--- Get facility requirements
-- @return Array of required facility IDs
function Transformation:getFacilityRequirements()
    return self.requirements.facility or {}
end

--- Get race compatibility
-- @return Array of compatible race tags
function Transformation:getCompatibleRaces()
    return self.requirements.compatible_races or {}
end

--- Get class compatibility
-- @return Array of compatible class tags
function Transformation:getCompatibleClasses()
    return self.requirements.compatible_classes or {}
end

--- Check if this transformation is compatible with a race
-- @param raceTags Array of race tags
-- @return true if compatible
function Transformation:isCompatibleWithRace(raceTags)
    local compatible = self:getCompatibleRaces()
    if #compatible == 0 then return true end  -- No restrictions

    for _, raceTag in ipairs(raceTags) do
        for _, compatibleTag in ipairs(compatible) do
            if raceTag == compatibleTag then
                return true
            end
        end
    end
    return false
end

--- Check if this transformation is compatible with a class
-- @param classTags Array of class tags
-- @return true if compatible
function Transformation:isCompatibleWithClass(classTags)
    local compatible = self:getCompatibleClasses()
    if #compatible == 0 then return true end  -- No restrictions

    for _, classTag in ipairs(classTags) do
        for _, compatibleTag in ipairs(compatible) do
            if classTag == compatibleTag then
                return true
            end
        end
    end
    return false
end

--- Get the credit cost
-- @return Credit cost
function Transformation:getCreditCost()
    return self.costs.credits or 0
end

--- Get the resource costs
-- @return Table of resource costs {resource_name = amount}
function Transformation:getResourceCosts()
    return self.costs.resources or {}
end

--- Get the facility time required
-- @return Time required in hours
function Transformation:getFacilityTime()
    return self.costs.facility_time_hours or 0
end

--- Check if the player can afford this transformation
-- @param playerCredits Current player credits
-- @param playerResources Table of player resources {resource_name = amount}
-- @return true if affordable
function Transformation:canAfford(playerCredits, playerResources)
    -- Check credits
    if self:getCreditCost() > playerCredits then
        return false
    end

    -- Check resources
    local required = self:getResourceCosts()
    for resource, amount in pairs(required) do
        local available = playerResources[resource] or 0
        if available < amount then
            return false
        end
    end

    return true
end

--- Check if the player meets the requirements
-- @param availableResearch Table of completed research {research_id = true}
-- @param availableFacilities Table of available facilities {facility_id = true}
-- @return true if requirements are met
function Transformation:meetsRequirements(availableResearch, availableFacilities)
    -- Check research requirements
    local researchReqs = self:getResearchRequirements()
    for _, researchId in ipairs(researchReqs) do
        if not availableResearch[researchId] then
            return false
        end
    end

    -- Check facility requirements
    local facilityReqs = self:getFacilityRequirements()
    for _, facilityId in ipairs(facilityReqs) do
        if not availableFacilities[facilityId] then
            return false
        end
    end

    return true
end

--- Apply transformation effects to a unit
-- @param unit The unit to transform
function Transformation:applyToUnit(unit)
    -- Apply stat modifications
    for stat, modification in pairs(self.stat_modifications) do
        unit[stat] = (unit[stat] or 0) + modification
    end

    -- Grant abilities
    for _, abilityId in ipairs(self.ability_grants) do
        unit:addAbility(abilityId)
    end

    -- Apply visual changes (would affect unit portrait/appearance)
    -- This would be handled by the rendering system

    -- Record transformation in unit history
    unit.transformations = unit.transformations or {}
    table.insert(unit.transformations, {
        id = self.id,
        applied_date = os.date("%Y-%m-%d"),
        duration_type = self.duration_type,
        duration_days = self:getDuration()
    })
end

--- Check if a transformation has expired (for temporary ones)
-- @param appliedDate The date the transformation was applied
-- @param currentDate The current date
-- @return true if expired
function Transformation:hasExpired(appliedDate, currentDate)
    if self:isPermanent() then
        return false
    end

    -- Simplified date calculation (would use proper date library in real implementation)
    local duration = self:getDuration()
    if duration <= 0 then
        return false
    end

    -- This is a placeholder - real implementation would parse dates properly
    return false  -- Assume not expired for now
end

--- Get a human-readable description of the transformation
-- @return String description
function Transformation:getDescription()
    local desc = self.name
    if self.description and self.description ~= "" then
        desc = desc .. " - " .. self.description
    end

    desc = desc .. string.format(" (%s)", self.duration_type)

    if self:getCreditCost() > 0 then
        desc = desc .. string.format(" - Cost: %d credits", self:getCreditCost())
    end

    if #self.ability_grants > 0 then
        desc = desc .. " - Grants: " .. table.concat(self.ability_grants, ", ")
    end

    return desc
end

--- Convert to string representation
-- @return String representation
function Transformation:__tostring()
    return string.format("Transformation{id='%s', name='%s', type='%s'}",
                        self.id, self.name, self.duration_type)
end

return Transformation
