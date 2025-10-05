--- Small Radar Facility Class
-- Compact detection facility
--
-- @classmod basescape.facilities.SmallRadar
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

SmallRadar = class('SmallRadar', Facility)

--- Create a new small radar facility
-- @param id Unique facility identifier
-- @return SmallRadar New small radar facility
function SmallRadar:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "small_radar", "Small Radar", 1, 1, {
        -- Capacity contributions
        detection_range = 15,       -- Detection range in km
        interception_range = 8      -- Interception range in km
    }, {
        -- Service tags
        "small_radar",
        "detection",
        "interception"
    })

    -- Override properties
    self.armor = 1
    self.power_consumption = 4
    self.monthly_cost = 1000
    self.staffing_requirements = {
        technicians = 1
    }

    self.construction_cost = 15000
    self.construction_days = 2
    self.construction_requirements = {
        alloys = 15,
        electronics = 12,
        polymers = 5
    }

    -- Tactical integration - compact radar tower
    self.tactical_blocks = {
        {type = "radar_tower", x = 0, y = 0}       -- Single radar tower
    }
end

return SmallRadar
