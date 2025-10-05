--- Power Plant Facility Class
-- Generates power for base operations
--
-- @classmod basescape.facilities.PowerPlant
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

PowerPlant = class('PowerPlant', Facility)

--- Create a new power plant facility
-- @param id Unique facility identifier
-- @return PowerPlant New power plant facility
function PowerPlant:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "power_plant", "Power Plant", 2, 2, {
        -- Capacity contributions
        power_generation = 50,      -- Significant power generation
        item_storage = 25           -- Fuel storage
    }, {
        -- Service tags
        "power"
    })

    -- Override properties
    self.armor = 3
    self.power_consumption = 5  -- Self-consumption
    self.monthly_cost = 2000
    self.staffing_requirements = {
        engineer = 1
    }

    self.construction_cost = 75000
    self.construction_days = 5
    self.construction_requirements = {
        alloys = 50,
        electronics = 25
    }

    -- Tactical integration - vulnerable target
    self.tactical_blocks = {
        {type = "generator", x = 0, y = 0},    -- Main generator
        {type = "console", x = 1, y = 0},      -- Control panel
        {type = "fuel_tank", x = 0, y = 1},    -- Fuel storage
        {type = "cover", x = 1, y = 1}         -- Equipment
    }
end

return PowerPlant
