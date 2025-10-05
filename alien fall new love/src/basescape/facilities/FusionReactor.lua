--- Fusion Reactor Facility Class
-- Nuclear fusion power generation facility
--
-- @classmod basescape.facilities.FusionReactor
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

FusionReactor = class('FusionReactor', Facility)

--- Create a new fusion reactor facility
-- @param id Unique facility identifier
-- @return FusionReactor New fusion reactor facility
function FusionReactor:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "fusion_reactor", "Fusion Reactor", 3, 3, {
        -- Capacity contributions
        power_generation = 50,     -- Power generation capacity (MW)
        plasma_containment = 1,    -- Plasma containment systems
        fusion_research = 1        -- Fusion research capacity
    }, {
        -- Service tags
        "fusion_reactor",
        "power_generation",
        "nuclear_fusion",
        "energy_production"
    })

    -- Override properties
    self.armor = 8
    self.power_consumption = 5  -- Net power producer
    self.monthly_cost = 8000
    self.staffing_requirements = {
        nuclear_engineers = 6,
        plasma_physicists = 4,
        technicians = 8
    }

    self.construction_cost = 250000
    self.construction_days = 10
    self.construction_requirements = {
        alloys = 100,
        electronics = 80,
        alien_materials = 30,
        polymers = 50
    }

    -- Tactical integration - fusion reactor core and containment systems
    self.tactical_blocks = {
        {type = "fusion_core", x = 1, y = 1},         -- Main fusion core
        {type = "plasma_containment", x = 0, y = 0}, -- Containment field
        {type = "plasma_containment", x = 1, y = 0}, -- Containment field
        {type = "plasma_containment", x = 2, y = 0}, -- Containment field
        {type = "plasma_containment", x = 0, y = 1}, -- Containment field
        {type = "plasma_containment", x = 2, y = 1}, -- Containment field
        {type = "plasma_containment", x = 0, y = 2}, -- Containment field
        {type = "plasma_containment", x = 1, y = 2}, -- Containment field
        {type = "plasma_containment", x = 2, y = 2}, -- Containment field
        {type = "cooling_system", x = 0, y = 0},     -- Cooling systems
        {type = "cooling_system", x = 2, y = 0},     -- Cooling systems
        {type = "cooling_system", x = 0, y = 2},     -- Cooling systems
        {type = "cooling_system", x = 2, y = 2},     -- Cooling systems
        {type = "control_room", x = 1, y = 0},       -- Reactor control
        {type = "emergency_systems", x = 1, y = 2},  -- Emergency shutdown
        {type = "radiation_shielding", x = 0, y = 1}, -- Radiation protection
        {type = "radiation_shielding", x = 2, y = 1}  -- Radiation protection
    }
end

return FusionReactor
