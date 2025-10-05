--- CraftClass.lua
-- Craft class templates for Alien Fall
-- Defines base craft types with capabilities and requirements

-- GROK: Aircraft templates - modify stats and capabilities for new craft types
-- GROK: Add new equipment slots by extending the equipment table

local class = require 'lib.Middleclass'

CraftClass = class('CraftClass')

--- Initialize a new craft class
-- @param data The TOML data for this craft class
function CraftClass:initialize(data)
    self.id = data.id
    self.name = data.name
    self.type = data.type
    self.category = data.category

    -- Capability modifiers
    self.capabilities = data.capabilities or {}

    -- Base stats
    self.stats = data.stats or {}

    -- Equipment slots
    self.equipment = data.equipment or {}

    -- Requirements to build/use
    self.requirements = data.requirements or {}

    -- Validate data
    self:_validate()
end

--- Validate the craft class data
function CraftClass:_validate()
    assert(self.id, "Craft class must have an id")
    assert(self.name, "Craft class must have a name")
    assert(self.type, "Craft class must have a type")

    -- Validate capabilities
    if self.capabilities then
        for capability, value in pairs(self.capabilities) do
            assert(type(value) == "number", string.format("Capability %s must be a number", capability))
        end
    end
end

--- Get the capability value for a specific capability
-- @param capability The capability name (e.g., "speed", "armor")
-- @return The capability value (default 1.0 if not specified)
-- GROK: Capability modifiers - adjust these values to balance different craft types
function CraftClass:getCapability(capability)
    return self.capabilities[capability] or 1.0
end

--- Get the base stat value
-- @param stat The stat name (e.g., "fuel_capacity", "detection_range")
-- @return The stat value or nil if not defined
-- GROK: Base stats - modify for different craft performance characteristics
function CraftClass:getStat(stat)
    return self.stats[stat]
end

--- Get all equipment slots
-- @return Table of equipment slot definitions
-- GROK: Equipment configuration - add new slot types for modded equipment
function CraftClass:getEquipment()
    return self.equipment
end

--- Check if this craft class meets the given requirements
-- @param availableResearch Table of completed research {research_id = true}
-- @param availableFacilities Table of available facilities {facility_id = true}
-- @return true if requirements are met
-- GROK: Tech requirements - modify to change craft unlock conditions
function CraftClass:meetsRequirements(availableResearch, availableFacilities)
    if not self.requirements then return true end

    -- Check research requirements
    if self.requirements.research then
        for _, researchId in ipairs(self.requirements.research) do
            if not availableResearch[researchId] then
                return false
            end
        end
    end

    -- Check facility requirements
    if self.requirements.facility then
        for _, facilityId in ipairs(self.requirements.facility) do
            if not availableFacilities[facilityId] then
                return false
            end
        end
    end

    return true
end

--- Get the research requirements
-- @return Array of required research IDs
function CraftClass:getResearchRequirements()
    return self.requirements.research or {}
end

--- Get the facility requirements
-- @return Array of required facility IDs
function CraftClass:getFacilityRequirements()
    return self.requirements.facility or {}
end

--- Check if this craft class is compatible with a given craft type
-- @param craftType The craft type to check
-- @return true if compatible
function CraftClass:isCompatibleWithType(craftType)
    return self.type == craftType
end

--- Get a human-readable description of this craft class
-- @return String description
function CraftClass:getDescription()
    local desc = string.format("%s (%s)", self.name, self.category)

    if self.capabilities.speed then
        desc = desc .. string.format(" - Speed: %d", self.capabilities.speed)
    end

    if self.capabilities.armor then
        desc = desc .. string.format(" - Armor: %d", self.capabilities.armor)
    end

    if self.capabilities.passenger_capacity then
        desc = desc .. string.format(" - Passengers: %d", self.capabilities.passenger_capacity)
    end

    return desc
end

--- Get the maximum operational range in kilometers
-- @return Maximum range in km
function CraftClass:getMaxRange()
    return self.stats.max_range or 1000
end

--- Get fuel efficiency (fuel units per kilometer)
-- @return Fuel efficiency
function CraftClass:getFuelEfficiency()
    return self.stats.fuel_efficiency or 0.5
end

--- Get speed rating (missions per turn)
-- @return Speed rating
function CraftClass:getSpeedRating()
    return self.capabilities.speed or 1
end

--- Convert to string representation
-- @return String representation
function CraftClass:__tostring()
    return string.format("CraftClass{id='%s', name='%s', type='%s'}",
                        self.id, self.name, self.type)
end

return CraftClass
