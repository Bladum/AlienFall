--- Sealed Environment Facility Class
-- Contained research environment facility
--
-- @classmod basescape.facilities.SealedEnvironment
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

SealedEnvironment = class('SealedEnvironment', Facility)

--- Create a new sealed environment facility
-- @param id Unique facility identifier
-- @return SealedEnvironment New sealed environment facility
function SealedEnvironment:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "sealed_environment", "Sealed Environment", 2, 2, {
        -- Capacity contributions
        containment_zones = 3,     -- Containment zones
        environmental_control = 2, -- Environmental control capacity
        isolation_chambers = 4     -- Isolation research chambers
    }, {
        -- Service tags
        "sealed_environment",
        "containment",
        "environmental_control",
        "isolation"
    })

    -- Override properties
    self.armor = 5
    self.power_consumption = 16
    self.monthly_cost = 2800
    self.staffing_requirements = {
        scientists = 2,
        technicians = 3
    }

    self.construction_cost = 48000
    self.construction_days = 4
    self.construction_requirements = {
        alloys = 35,
        polymers = 30,
        electronics = 20
    }

    -- Tactical integration - containment zones and environmental systems
    self.tactical_blocks = {
        {type = "containment_zone", x = 0, y = 0},   -- Containment zone
        {type = "containment_zone", x = 1, y = 0},   -- Containment zone
        {type = "containment_zone", x = 0, y = 1},   -- Containment zone
        {type = "containment_zone", x = 1, y = 1},   -- Containment zone
        {type = "environmental_system", x = 0, y = 0}, -- Environmental control
        {type = "environmental_system", x = 1, y = 0}, -- Environmental control
        {type = "isolation_chamber", x = 0, y = 1},  -- Isolation chamber
        {type = "isolation_chamber", x = 1, y = 1}   -- Isolation chamber
    }
end

return SealedEnvironment
