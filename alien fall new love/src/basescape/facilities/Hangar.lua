--- Hangar Facility Class
-- Aircraft storage and maintenance facility
--
-- @classmod basescape.facilities.Hangar
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

Hangar = class('Hangar', Facility)

--- Create a new hangar facility
-- @param id Unique facility identifier
-- @return Hangar New hangar facility
function Hangar:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "hangar", "Hangar", 3, 2, {
        -- Capacity contributions
        craft_slots = 2,            -- Aircraft storage slots
        maintenance_slots = 2,      -- Maintenance bays
        fuel_storage = 100          -- Fuel capacity
    }, {
        -- Service tags
        "hangar",
        "craft_storage",
        "maintenance",
        "fuel_storage"
    })

    -- Override properties
    self.armor = 3
    self.power_consumption = 12
    self.monthly_cost = 3000
    self.staffing_requirements = {
        engineers = 3,
        technicians = 2
    }

    self.construction_cost = 50000
    self.construction_days = 4
    self.construction_requirements = {
        alloys = 50,
        polymers = 30,
        electronics = 20
    }

    -- Tactical integration - hangar bays and equipment
    self.tactical_blocks = {
        {type = "hangar_bay", x = 0, y = 0},     -- Main hangar bay
        {type = "hangar_bay", x = 1, y = 0},     -- Secondary bay
        {type = "hangar_bay", x = 2, y = 0},     -- Tertiary bay
        {type = "maintenance_bay", x = 0, y = 1}, -- Maintenance equipment
        {type = "maintenance_bay", x = 1, y = 1}, -- Maintenance equipment
        {type = "maintenance_bay", x = 2, y = 1}  -- Maintenance equipment
    }
end

return Hangar
