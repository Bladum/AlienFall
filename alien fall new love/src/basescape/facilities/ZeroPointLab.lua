--- Zero Point Lab Facility Class
-- Zero point energy research facility
--
-- @classmod basescape.facilities.ZeroPointLab
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

ZeroPointLab = class('ZeroPointLab', Facility)

--- Create a new zero point lab facility
-- @param id Unique facility identifier
-- @return ZeroPointLab New zero point lab facility
function ZeroPointLab:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "zero_point_lab", "Zero Point Lab", 2, 2, {
        -- Capacity contributions
        zero_point_research = 1,   -- Zero point energy research
        energy_harvesting = 1,     -- Energy harvesting capacity
        containment_fields = 3     -- Energy containment capacity
    }, {
        -- Service tags
        "zero_point_lab",
        "research",
        "zero_point_energy",
        "energy_harvesting"
    })

    -- Override properties
    self.armor = 6
    self.power_consumption = 20
    self.monthly_cost = 10000
    self.staffing_requirements = {
        energy_physicists = 5,
        containment_specialists = 3,
        technicians = 2
    }

    self.construction_cost = 180000
    self.construction_days = 7
    self.construction_requirements = {
        alloys = 50,
        electronics = 70,
        alien_materials = 40,
        polymers = 30
    }

    -- Tactical integration - zero point research chambers and containment systems
    self.tactical_blocks = {
        {type = "zero_point_chamber", x = 0, y = 0}, -- Research chamber
        {type = "zero_point_chamber", x = 1, y = 0}, -- Research chamber
        {type = "zero_point_chamber", x = 0, y = 1}, -- Research chamber
        {type = "zero_point_chamber", x = 1, y = 1}, -- Research chamber
        {type = "energy_containment", x = 0, y = 0}, -- Energy containment
        {type = "energy_containment", x = 1, y = 0}, -- Energy containment
        {type = "energy_containment", x = 0, y = 1}, -- Energy containment
        {type = "energy_containment", x = 1, y = 1}, -- Energy containment
        {type = "harvesting_array", x = 0, y = 0},   -- Energy harvesting
        {type = "harvesting_array", x = 1, y = 0},   -- Energy harvesting
        {type = "stabilization_system", x = 0, y = 1}, -- System stabilization
        {type = "stabilization_system", x = 1, y = 1}  -- System stabilization
    }
end

return ZeroPointLab
