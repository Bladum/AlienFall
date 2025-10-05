--- Gravlift Facility Class
-- Personnel and equipment transport facility
--
-- @classmod basescape.facilities.Gravlift
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

Gravlift = class('Gravlift', Facility)

--- Create a new gravlift facility
-- @param id Unique facility identifier
-- @return Gravlift New gravlift facility
function Gravlift:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "gravlift", "Gravlift", 1, 1, {
        -- Capacity contributions
        transport_capacity = 4,    -- Personnel transport capacity
        equipment_lift = 2        -- Equipment transport capacity
    }, {
        -- Service tags
        "gravlift",
        "transport",
        "vertical_transport"
    })

    -- Override properties
    self.armor = 3
    self.power_consumption = 8
    self.monthly_cost = 1500
    self.staffing_requirements = {
        technicians = 1
    }

    self.construction_cost = 22000
    self.construction_days = 2
    self.construction_requirements = {
        alloys = 18,
        electronics = 15,
        polymers = 12
    }

    -- Tactical integration - gravlift platform and controls
    self.tactical_blocks = {
        {type = "gravlift_platform", x = 0, y = 0}, -- Transport platform
        {type = "lift_controls", x = 0, y = 0}      -- Control systems
    }
end

return Gravlift
