--- Foundry Facility Class
-- Metalworking and manufacturing facility
--
-- @classmod basescape.facilities.Foundry
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

Foundry = class('Foundry', Facility)

--- Create a new foundry facility
-- @param id Unique facility identifier
-- @return Foundry New foundry facility
function Foundry:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "foundry", "Foundry", 2, 2, {
        -- Capacity contributions
        manufacturing_slots = 3,   -- Manufacturing workstations
        metal_processing = 5,      -- Metal processing capacity
        alloy_production = 2       -- Alloy production capacity
    }, {
        -- Service tags
        "foundry",
        "manufacturing",
        "metalworking",
        "alloy_production"
    })

    -- Override properties
    self.armor = 3
    self.power_consumption = 18
    self.monthly_cost = 2500
    self.staffing_requirements = {
        engineers = 3,
        technicians = 2
    }

    self.construction_cost = 42000
    self.construction_days = 3
    self.construction_requirements = {
        alloys = 40,
        polymers = 15,
        electronics = 10
    }

    -- Tactical integration - manufacturing equipment and workstations
    self.tactical_blocks = {
        {type = "manufacturing_station", x = 0, y = 0}, -- Workstation
        {type = "manufacturing_station", x = 1, y = 0}, -- Workstation
        {type = "manufacturing_station", x = 0, y = 1}, -- Workstation
        {type = "manufacturing_station", x = 1, y = 1}, -- Workstation
        {type = "furnace", x = 0, y = 0},              -- Metal furnace
        {type = "furnace", x = 1, y = 0},              -- Metal furnace
        {type = "assembly_line", x = 0, y = 1},        -- Assembly equipment
        {type = "assembly_line", x = 1, y = 1}         -- Assembly equipment
    }
end

return Foundry
