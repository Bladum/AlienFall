--- Workshop Facility Class
-- Manufacturing facility for production
--
-- @classmod basescape.facilities.Workshop
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

Workshop = class('Workshop', Facility)

--- Create a new workshop facility
-- @param id Unique facility identifier
-- @return Workshop New workshop facility
function Workshop:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "workshop", "Workshop", 2, 1, {
        -- Capacity contributions
        manufacturing_hours = 25,   -- Production throughput per day
        item_storage = 40           -- Material/component storage
    }, {
        -- Service tags
        "manufacturing",
        "fabrication"
    })

    -- Override properties
    self.armor = 4
    self.power_consumption = 12
    self.monthly_cost = 2500
    self.staffing_requirements = {
        engineer = 1
    }

    self.construction_cost = 80000
    self.construction_days = 6
    self.construction_requirements = {
        alloys = 60,
        electronics = 20,
        polymers = 30
    }

    -- Tactical integration - industrial equipment
    self.tactical_blocks = {
        {type = "workbench", x = 0, y = 0},    -- Main workbench
        {type = "console", x = 1, y = 0},      -- Control panel
        {type = "cover", x = 0, y = 0},        -- Equipment
        {type = "cover", x = 1, y = 0}         -- Machinery
    }
end

return Workshop
