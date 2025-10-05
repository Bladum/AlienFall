--- Satellite Uplink Facility Class
-- Satellite communication facility
--
-- @classmod basescape.facilities.SatelliteUplink
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

SatelliteUplink = class('SatelliteUplink', Facility)

--- Create a new satellite uplink facility
-- @param id Unique facility identifier
-- @return SatelliteUplink New satellite uplink facility
function SatelliteUplink:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "satellite_uplink", "Satellite Uplink", 2, 1, {
        -- Capacity contributions
        satellite_uplink = 1,       -- Satellite control capacity
        communication_range = 30   -- Communication range in km
    }, {
        -- Service tags
        "satellite_uplink",
        "communications",
        "satellite_control"
    })

    -- Override properties
    self.armor = 2
    self.power_consumption = 6
    self.monthly_cost = 1800
    self.staffing_requirements = {
        technicians = 2
    }

    self.construction_cost = 25000
    self.construction_days = 2
    self.construction_requirements = {
        alloys = 20,
        electronics = 25,
        polymers = 10
    }

    -- Tactical integration - uplink arrays and control stations
    self.tactical_blocks = {
        {type = "uplink_array", x = 0, y = 0},     -- Main uplink
        {type = "uplink_array", x = 1, y = 0},     -- Secondary uplink
        {type = "control_station", x = 0, y = 0},  -- Control station
        {type = "control_station", x = 1, y = 0}   -- Control station
    }
end

return SatelliteUplink
