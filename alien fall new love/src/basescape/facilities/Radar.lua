--- Radar Facility Class
-- Detection and interception facility
--
-- @classmod basescape.facilities.Radar
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

Radar = class('Radar', Facility)

--- Create a new radar facility
-- @param id Unique facility identifier
-- @return Radar New radar facility
function Radar:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "radar", "Radar", 2, 2, {
        -- Capacity contributions
        detection_range = 25,       -- Detection range in km
        interception_range = 15     -- Interception range in km
    }, {
        -- Service tags
        "radar",
        "detection",
        "interception"
    })

    -- Override properties
    self.armor = 1
    self.power_consumption = 8
    self.monthly_cost = 2000
    self.staffing_requirements = {
        technicians = 2
    }

    self.construction_cost = 35000
    self.construction_days = 3
    self.construction_requirements = {
        alloys = 30,
        electronics = 25,
        polymers = 10
    }

    -- Tactical integration - radar tower
    self.tactical_blocks = {
        {type = "radar_tower", x = 0, y = 0},    -- Main radar tower
        {type = "radar_tower", x = 1, y = 0},    -- Secondary tower
        {type = "radar_tower", x = 0, y = 1},    -- Tertiary tower
        {type = "radar_tower", x = 1, y = 1}     -- Backup tower
    }
end

return Radar
