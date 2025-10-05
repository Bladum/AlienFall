--- Storage Facility Class
-- General storage and warehouse facility
--
-- @classmod basescape.facilities.Storage
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

Storage = class('Storage', Facility)

--- Create a new storage facility
-- @param id Unique facility identifier
-- @return Storage New storage facility
function Storage:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "storage", "Storage", 2, 1, {
        -- Capacity contributions
        item_storage = 50,         -- General item storage
        equipment_storage = 30,    -- Equipment storage
        material_storage = 40      -- Raw material storage
    }, {
        -- Service tags
        "storage",
        "warehouse",
        "inventory"
    })

    -- Override properties
    self.armor = 2
    self.power_consumption = 4
    self.monthly_cost = 1000
    self.staffing_requirements = {
        logistics = 1
    }

    self.construction_cost = 20000
    self.construction_days = 2
    self.construction_requirements = {
        alloys = 20,
        polymers = 25
    }

    -- Tactical integration - storage racks and access points
    self.tactical_blocks = {
        {type = "storage_rack", x = 0, y = 0},    -- Storage racks
        {type = "storage_rack", x = 1, y = 0},    -- Storage racks
        {type = "access_point", x = 0, y = 0},    -- Access point
        {type = "access_point", x = 1, y = 0}     -- Access point
    }
end

return Storage
