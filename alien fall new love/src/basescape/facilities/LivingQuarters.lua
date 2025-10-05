--- Living Quarters Facility Class
-- Personnel accommodation facility
--
-- @classmod basescape.facilities.LivingQuarters
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

LivingQuarters = class('LivingQuarters', Facility)

--- Create a new living quarters facility
-- @param id Unique facility identifier
-- @return LivingQuarters New living quarters facility
function LivingQuarters:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "living_quarters", "Living Quarters", 2, 1, {
        -- Capacity contributions
        personnel_quarters = 8,     -- Personnel beds
        item_storage = 20           -- Personal storage
    }, {
        -- Service tags
        "living_quarters",
        "medical"  -- Basic medical facilities
    })

    -- Override properties
    self.armor = 2
    self.power_consumption = 6
    self.monthly_cost = 1500
    self.staffing_requirements = {}  -- Self-maintaining

    self.construction_cost = 25000
    self.construction_days = 2
    self.construction_requirements = {
        alloys = 20,
        polymers = 15
    }

    -- Tactical integration - defender spawning
    self.tactical_blocks = {
        {type = "bunks", x = 0, y = 0},        -- Personnel bunks
        {type = "bunks", x = 1, y = 0},        -- More bunks
        {type = "defender_spawn", x = 0, y = 0}, -- Spawn point
        {type = "defender_spawn", x = 1, y = 0}  -- Spawn point
    }
end

return LivingQuarters
