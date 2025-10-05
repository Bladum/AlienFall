--- Antimatter Reactor Facility Class
-- Antimatter energy generation facility
--
-- @classmod basescape.facilities.AntimatterReactor
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

AntimatterReactor = class('AntimatterReactor', Facility)

--- Create a new antimatter reactor facility
-- @param id Unique facility identifier
-- @return AntimatterReactor New antimatter reactor facility
function AntimatterReactor:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "antimatter_reactor", "Antimatter Reactor", 3, 3, {
        -- Capacity contributions
        power_generation = 100,    -- Power generation capacity (MW)
        antimatter_containment = 1, -- Antimatter containment systems
        energy_research = 1        -- Advanced energy research
    }, {
        -- Service tags
        "antimatter_reactor",
        "power_generation",
        "antimatter",
        "energy_production"
    })

    -- Override properties
    self.armor = 10
    self.power_consumption = 10  -- Net power producer
    self.monthly_cost = 15000
    self.staffing_requirements = {
        antimatter_specialists = 8,
        quantum_physicists = 5,
        security = 12
    }

    self.construction_cost = 500000
    self.construction_days = 12
    self.construction_requirements = {
        alloys = 150,
        electronics = 120,
        alien_materials = 80,
        polymers = 70
    }

    -- Tactical integration - antimatter reactor core and containment systems
    self.tactical_blocks = {
        {type = "antimatter_core", x = 1, y = 1},     -- Main antimatter core
        {type = "containment_field", x = 0, y = 0},  -- Magnetic containment
        {type = "containment_field", x = 1, y = 0},  -- Magnetic containment
        {type = "containment_field", x = 2, y = 0},  -- Magnetic containment
        {type = "containment_field", x = 0, y = 1},  -- Magnetic containment
        {type = "containment_field", x = 2, y = 1},  -- Magnetic containment
        {type = "containment_field", x = 0, y = 2},  -- Magnetic containment
        {type = "containment_field", x = 1, y = 2},  -- Magnetic containment
        {type = "containment_field", x = 2, y = 2},  -- Magnetic containment
        {type = "particle_accelerator", x = 0, y = 0}, -- Particle acceleration
        {type = "particle_accelerator", x = 2, y = 0}, -- Particle acceleration
        {type = "cooling_tower", x = 0, y = 2},      -- Advanced cooling
        {type = "cooling_tower", x = 2, y = 2},      -- Advanced cooling
        {type = "control_center", x = 1, y = 0},     -- Reactor control
        {type = "emergency_containment", x = 1, y = 2}, -- Emergency systems
        {type = "radiation_shield", x = 0, y = 1},   -- Radiation shielding
        {type = "radiation_shield", x = 2, y = 1},   -- Radiation shielding
        {type = "antimatter_storage", x = 0, y = 1}, -- Antimatter storage
        {type = "antimatter_storage", x = 2, y = 1}  -- Antimatter storage
    }
end

return AntimatterReactor
