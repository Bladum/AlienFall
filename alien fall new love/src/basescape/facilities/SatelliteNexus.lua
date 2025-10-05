--- Satellite Nexus Facility Class
-- Satellite control and launch facility
--
-- @classmod basescape.facilities.SatelliteNexus
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

SatelliteNexus = class('SatelliteNexus', Facility)

--- Create a new satellite nexus facility
-- @param id Unique facility identifier
-- @return SatelliteNexus New satellite nexus facility
function SatelliteNexus:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "satellite_nexus", "Satellite Nexus", 3, 3, {
        -- Capacity contributions
        satellite_uplink = 3,       -- Satellite control capacity
        launch_capacity = 1,        -- Satellite launch capability
        orbital_coverage = 25       -- Coverage radius in km
    }, {
        -- Service tags
        "satellite_nexus",
        "satellite_control",
        "launch_facility",
        "orbital"
    })

    -- Override properties
    self.armor = 4
    self.power_consumption = 18
    self.monthly_cost = 4500
    self.staffing_requirements = {
        engineers = 4,
        technicians = 3,
        orbital_specialists = 2
    }

    self.construction_cost = 80000
    self.construction_days = 5
    self.construction_requirements = {
        alloys = 60,
        electronics = 45,
        polymers = 30,
        rocket_parts = 20
    }

    -- Tactical integration - launch pad and control centers
    self.tactical_blocks = {
        {type = "launch_pad", x = 1, y = 0},       -- Main launch pad
        {type = "control_center", x = 0, y = 1},   -- Control center
        {type = "control_center", x = 1, y = 1},   -- Control center
        {type = "control_center", x = 2, y = 1},   -- Control center
        {type = "satellite_prep", x = 0, y = 2},   -- Preparation area
        {type = "satellite_prep", x = 1, y = 2},   -- Preparation area
        {type = "satellite_prep", x = 2, y = 2},   -- Preparation area
        {type = "antenna_array", x = 0, y = 0},    -- Communication array
        {type = "antenna_array", x = 2, y = 0}     -- Communication array
    }
end

return SatelliteNexus
