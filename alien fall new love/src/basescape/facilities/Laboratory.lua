--- Laboratory Facility Class
-- Research facility for scientific advancement
--
-- @classmod basescape.facilities.Laboratory
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

Laboratory = class('Laboratory', Facility)

--- Create a new laboratory facility
-- @param id Unique facility identifier
-- @return Laboratory New laboratory facility
function Laboratory:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "laboratory", "Laboratory", 2, 2, {
        -- Capacity contributions
        research_points = 15,       -- Research throughput per day
        item_storage = 30           -- Sample storage
    }, {
        -- Service tags
        "research",
        "medical"  -- Basic medical analysis
    })

    -- Override properties
    self.armor = 2
    self.power_consumption = 8
    self.monthly_cost = 3000
    self.staffing_requirements = {
        scientist = 2
    }

    self.construction_cost = 100000
    self.construction_days = 7
    self.construction_requirements = {
        alloys = 30,
        electronics = 40,
        polymers = 20
    }

    -- Tactical integration - high value research data
    self.tactical_blocks = {
        {type = "console", x = 0, y = 0},      -- Research terminal
        {type = "console", x = 1, y = 0},      -- Analysis station
        {type = "specimen_tank", x = 0, y = 1}, -- Alien specimens
        {type = "cover", x = 1, y = 1}         -- Equipment racks
    }
end

return Laboratory
