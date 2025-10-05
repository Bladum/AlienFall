--- Access Lift Facility Class
-- Central access point for bases, provides basic power and crew quarters
--
-- @classmod basescape.facilities.AccessLift
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

AccessLift = class('AccessLift', Facility)

--- Create a new access lift facility
-- @param id Unique facility identifier
-- @return AccessLift New access lift facility
function AccessLift:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "access_lift", "Access Lift", 1, 1, {
        -- Capacity contributions
        power_generation = 10,      -- Basic power for small base
        personnel_quarters = 4,     -- Crew quarters
        item_storage = 50           -- Small storage
    }, {
        -- Service tags
        "power",
        "access",
        "living_quarters"
    })

    -- Override properties
    self.armor = 5
    self.power_consumption = 0  -- Generates power
    self.monthly_cost = 1000
    self.staffing_requirements = {}  -- Unstaffed

    self.construction_cost = 50000
    self.construction_days = 3

    -- Tactical integration
    self.tactical_blocks = {
        {type = "console", x = 0, y = 0},  -- Control console
        {type = "door", x = 0, y = -1}     -- Exit door
    }
end

return AccessLift
