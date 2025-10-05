--- Portal.lua
-- Portal systems for Alien Fall
-- Manages wormholes, gates, and dimensional rifts for inter-world travel

-- GROK: Portal represents dimensional gateways with stability, requirements, and travel mechanics
-- GROK: Used by world_system and mission_system for interstellar travel and alien incursions
-- GROK: Key methods: calculateTravelSuccess(), canBeDetected(), meetsResearchRequirements()
-- GROK: Handles portal states, travel risks, and activation requirements

local class = require 'lib.Middleclass'

Portal = class('Portal')

--- Initialize a new portal
-- @param data The TOML data for this portal
function Portal:initialize(data)
    self.id = data.id
    self.name = data.name or data.id  -- Use id as default name
    self.type = data.type or "wormhole"
    self.status = data.status or "inactive"

    -- Location information (province-based)
    self.location = data.location or {}
    self.location_province_id = data.location_province_id
    self.location_world_id = data.location_world_id

    -- Destination information (province-based)
    self.destination = data.destination or {}
    self.destination_province_id = data.destination_province_id
    self.destination_world_id = data.destination_world_id

    -- Portal properties
    self.properties = data.properties or {}
    self.stability = self.properties.stability or 1.0
    self.traffic_capacity = self.properties.traffic_capacity or 1
    self.energy_requirement = self.properties.energy_requirement or 0
    self.detection_difficulty = self.properties.detection_difficulty or "easy"

    -- Travel effects
    self.effects = data.effects or {}
    self.travel_time = self.effects.travel_time or self.properties.travel_time or 0
    self.fuel_cost = self.effects.fuel_cost or self.properties.fuel_cost or 0
    self.reliability = self.effects.reliability or 1.0

    -- Requirements
    self.requirements = data.requirements or {}

    -- Description
    self.description = data.description or {}

    -- World reference
    self.world = nil

    -- Event bus
    self.event_bus = nil

    -- Validate data
    self:_validate()
end

--- Validate the portal data
function Portal:_validate()
    assert(self.id, "Portal must have an id")
    assert(self.name, "Portal must have a name")
    assert(self.type, "Portal must have a type")

    -- Validate province connections
    if self.location_province_id and not self.location_world_id then
        assert(false, "Location world_id required when province_id is specified")
    end
    if self.destination_province_id and not self.destination_world_id then
        assert(false, "Destination world_id required when province_id is specified")
    end
end

--- Set the world reference
-- @param world The World instance
function Portal:setWorld(world)
    self.world = world
    self.event_bus = world.event_bus
end

--- Get the portal's location province
-- @return Province ID or nil
function Portal:getLocationProvinceId()
    return self.location_province_id
end

--- Get the portal's location world
-- @return World ID or nil
function Portal:getLocationWorldId()
    return self.location_world_id
end

--- Get the portal's destination province
-- @return Province ID or nil
function Portal:getDestinationProvinceId()
    return self.destination_province_id
end

--- Get the portal's destination world
-- @return World ID or nil
function Portal:getDestinationWorldId()
    return self.destination_world_id
end

--- Check if portal connects different worlds
-- @return true if inter-world portal
function Portal:isInterWorld()
    return self.location_world_id ~= self.destination_world_id
end

--- Check if the portal is active
-- @return true if the portal is active
function Portal:isActive()
    return self.status == "active"
end

--- Check if the portal is dormant
-- @return true if the portal is dormant
function Portal:isDormant()
    return self.status == "dormant"
end

--- Check if the portal is unstable
-- @return true if the portal is unstable
function Portal:isUnstable()
    return self.status == "unstable"
end

--- Get the portal type
-- @return Portal type ("wormhole", "gate", "rift", "tunnel", etc.)
function Portal:getType()
    return self.type
end

--- Get the portal stability
-- @return Stability value between 0 and 1
function Portal:getStability()
    return self.stability
end

--- Set portal stability
-- @param stability New stability value
function Portal:setStability(stability)
    self.stability = math.max(0, math.min(1, stability))
end

--- Get the traffic capacity
-- @return Maximum number of concurrent travelers
function Portal:getTrafficCapacity()
    return self.traffic_capacity
end

--- Get the energy requirement
-- @return Energy units required to use/maintain the portal
function Portal:getEnergyRequirement()
    return self.energy_requirement
end

--- Get the detection difficulty
-- @return Detection difficulty level
function Portal:getDetectionDifficulty()
    return self.detection_difficulty
end

--- Get the travel time in seconds
-- @return Travel time in seconds
function Portal:getTravelTime()
    return self.travel_time
end

--- Get the fuel cost
-- @return Fuel cost for travel
function Portal:getFuelCost()
    return self.fuel_cost
end

--- Get the reliability
-- @return Reliability percentage (0-1)
function Portal:getReliability()
    return self.reliability
end

--- Get the research requirements
-- @return Array of required research IDs
function Portal:getResearchRequirements()
    return self.requirements.research or {}
end

--- Get the detection requirements
-- @return Array of required detection technologies
function Portal:getDetectionRequirements()
    return self.requirements.detection or {}
end

--- Get the activation requirements
-- @return Array of required items/conditions for activation
function Portal:getActivationRequirements()
    return self.requirements.activation or {}
end

--- Check if the player meets the research requirements
-- @param availableResearch Table of completed research {research_id = true}
-- @return true if requirements are met
function Portal:meetsResearchRequirements(availableResearch)
    local required = self:getResearchRequirements()
    for _, researchId in ipairs(required) do
        if not availableResearch[researchId] then
            return false
        end
    end
    return true
end

--- Check if the player can detect this portal
-- @param availableTech Table of available detection technologies
-- @return true if detectable
function Portal:canBeDetected(availableTech)
    local required = self:getDetectionRequirements()
    for _, techId in ipairs(required) do
        if not availableTech[techId] then
            return false
        end
    end
    return true
end

--- Check if the player can activate this portal
-- @param availableItems Table of available items {item_id = count}
-- @return true if activatable
function Portal:canBeActivated(availableItems)
    local required = self:getActivationRequirements()
    for _, itemId in ipairs(required) do
        local count = availableItems[itemId] or 0
        if count <= 0 then
            return false
        end
    end
    return true
end

--- Calculate travel success chance
-- @param pilotSkill Pilot skill level (0-100)
-- @param equipmentBonus Equipment bonus (0-50)
-- @return Success chance as percentage
function Portal:calculateTravelSuccess(pilotSkill, equipmentBonus)
    local baseChance = self:getReliability() * 100
    local skillBonus = pilotSkill * 0.5
    local totalChance = baseChance + skillBonus + equipmentBonus

    -- Stability affects success rate
    local stabilityPenalty = (1.0 - self:getStability()) * 30
    totalChance = totalChance - stabilityPenalty

    return math.max(5, math.min(95, totalChance))  -- Clamp between 5% and 95%
end

--- Activate the portal
-- @param activator The entity activating the portal
function Portal:activate(activator)
    if self.status ~= "active" then
        self.status = "active"

        -- Publish event
        if self.event_bus then
            self.event_bus:publish("portal:activated", {
                portal_id = self.id,
                activator = activator
            })
        end
    end
end

--- Deactivate the portal
function Portal:deactivate()
    if self.status == "active" then
        self.status = "dormant"

        -- Publish event
        if self.event_bus then
            self.event_bus:publish("portal:deactivated", {
                portal_id = self.id
            })
        end
    end
end

--- Travel through the portal
-- @param traveler The entity traveling
-- @param pilotSkill Pilot skill level
-- @param equipmentBonus Equipment bonus
-- @return true if travel successful, false otherwise
function Portal:travel(traveler, pilotSkill, equipmentBonus)
    if not self:isActive() then
        return false
    end

    local successChance = self:calculateTravelSuccess(pilotSkill, equipmentBonus)
    local roll = math.random(100)

    local success = roll <= successChance

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("portal:travel_attempted", {
            portal_id = self.id,
            traveler = traveler,
            success = success,
            success_chance = successChance,
            roll = roll
        })
    end

    -- Reduce stability slightly with each use
    if success then
        self:setStability(self.stability - 0.01)
    end

    return success
end

--- Get the short description
-- @return Short description string
function Portal:getShortDescription()
    return self.description.short or self.name
end

--- Get the long description
-- @return Long description string
function Portal:getLongDescription()
    return self.description.long or self:getShortDescription()
end

--- Get a formatted display string for UI
-- @return String for display in portal management screens
function Portal:getDisplayString()
    local display = string.format("%s (%s)", self.name, self.type)

    if self:isActive() then
        display = display .. " - Active"
    elseif self:isDormant() then
        display = display .. " - Dormant"
    elseif self:isUnstable() then
        display = display .. " - Unstable"
    end

    local stability = self:getStability()
    if stability < 1.0 then
        display = display .. string.format(" - Stability: %.1f%%", stability * 100)
    end

    if self:isInterWorld() then
        display = display .. " [Inter-World]"
    end

    return display
end

--- Get display information for UI
-- @return Table with display data
function Portal:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        type = self.type,
        status = self.status,
        location_province = self.location_province_id,
        location_world = self.location_world_id,
        destination_province = self.destination_province_id,
        destination_world = self.destination_world_id,
        is_inter_world = self:isInterWorld(),
        stability = self.stability,
        travel_time = self.travel_time,
        fuel_cost = self.fuel_cost,
        reliability = self.reliability,
        traffic_capacity = self.traffic_capacity,
        energy_requirement = self.energy_requirement,
        detection_difficulty = self.detection_difficulty
    }
end

--- Get display information for UI
-- @return Table with display data
function Portal:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        type = self.type,
        status = self.status,
        is_inter_world = self:isInterWorld(),
        stability = self.stability,
        travel_time = self.travel_time,
        fuel_cost = self.fuel_cost
    }
end

--- Convert to string representation
-- @return String representation
function Portal:__tostring()
    local connection = "intra-world"
    if self:isInterWorld() then
        connection = string.format("inter-world (%s->%s)",
                                 self.location_world_id, self.destination_world_id)
    end

    return string.format("Portal{id='%s', name='%s', type='%s', status='%s', connection='%s'}",
                        self.id, self.name, self.type, self.status, connection)
end

return Portal
