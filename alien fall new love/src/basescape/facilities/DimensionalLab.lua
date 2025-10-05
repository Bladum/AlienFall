--- Dimensional Lab Facility Class
-- Dimensional physics and portal research facility
--
-- @classmod basescape.facilities.DimensionalLab
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

DimensionalLab = class('DimensionalLab', Facility)

--- Create a new dimensional lab facility
-- @param id Unique facility identifier
-- @return DimensionalLab New dimensional lab facility
function DimensionalLab:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "dimensional_lab", "Dimensional Lab", 3, 3, {
        -- Capacity contributions
        dimensional_research = 1,  -- Dimensional research capacity
        portal_studies = 1,        -- Portal technology studies
        dimensional_containment = 2 -- Dimensional containment capacity
    }, {
        -- Service tags
        "dimensional_lab",
        "research",
        "dimensional_physics",
        "portal_technology"
    })

    -- Override properties
    self.armor = 8
    self.power_consumption = 30
    self.monthly_cost = 12000
    self.staffing_requirements = {
        dimensional_physicists = 6,
        portal_specialists = 4,
        security = 8
    }

    self.construction_cost = 200000
    self.construction_days = 8
    self.construction_requirements = {
        alloys = 60,
        electronics = 80,
        alien_materials = 50,
        polymers = 40
    }

    -- Tactical integration - dimensional research chambers and containment systems
    self.tactical_blocks = {
        {type = "dimensional_chamber", x = 0, y = 0}, -- Research chamber
        {type = "dimensional_chamber", x = 1, y = 0}, -- Research chamber
        {type = "dimensional_chamber", x = 2, y = 0}, -- Research chamber
        {type = "dimensional_chamber", x = 0, y = 1}, -- Research chamber
        {type = "dimensional_chamber", x = 1, y = 1}, -- Research chamber
        {type = "dimensional_chamber", x = 2, y = 1}, -- Research chamber
        {type = "dimensional_chamber", x = 0, y = 2}, -- Research chamber
        {type = "dimensional_chamber", x = 1, y = 2}, -- Research chamber
        {type = "dimensional_chamber", x = 2, y = 2}, -- Research chamber
        {type = "containment_field", x = 0, y = 0},   -- Containment field
        {type = "containment_field", x = 1, y = 0},   -- Containment field
        {type = "containment_field", x = 2, y = 0},   -- Containment field
        {type = "portal_generator", x = 1, y = 1},    -- Portal technology
        {type = "dimensional_scanner", x = 0, y = 1}, -- Dimensional scanning
        {type = "dimensional_scanner", x = 2, y = 1}, -- Dimensional scanning
        {type = "emergency_shutdown", x = 0, y = 2},  -- Emergency systems
        {type = "emergency_shutdown", x = 1, y = 2},  -- Emergency systems
        {type = "emergency_shutdown", x = 2, y = 2}   -- Emergency systems
    }
end

return DimensionalLab
