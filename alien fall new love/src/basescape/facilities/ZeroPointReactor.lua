--- Zero Point Reactor Facility Class
-- Zero point energy power generation facility
--
-- @classmod basescape.facilities.ZeroPointReactor
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

ZeroPointReactor = class('ZeroPointReactor', Facility)

--- Create a new zero point reactor facility
-- @param id Unique facility identifier
-- @return ZeroPointReactor New zero point reactor facility
function ZeroPointReactor:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "zero_point_reactor", "Zero Point Reactor", 3, 3, {
        -- Capacity contributions
        power_generation = 200,    -- Power generation capacity (MW)
        zero_point_harvesting = 1, -- Zero point energy harvesting
        dimensional_stability = 1  -- Dimensional field stability
    }, {
        -- Service tags
        "zero_point_reactor",
        "power_generation",
        "zero_point_energy",
        "dimensional_power"
    })

    -- Override properties
    self.armor = 12
    self.power_consumption = 15  -- Net power producer
    self.monthly_cost = 25000
    self.staffing_requirements = {
        zero_point_engineers = 10,
        dimensional_physicists = 6,
        containment_specialists = 8
    }

    self.construction_cost = 750000
    self.construction_days = 15
    self.construction_requirements = {
        alloys = 200,
        electronics = 150,
        alien_materials = 120,
        polymers = 100
    }

    -- Tactical integration - zero point reactor core and dimensional containment
    self.tactical_blocks = {
        {type = "zero_point_core", x = 1, y = 1},     -- Main zero point core
        {type = "dimensional_containment", x = 0, y = 0}, -- Dimensional fields
        {type = "dimensional_containment", x = 1, y = 0}, -- Dimensional fields
        {type = "dimensional_containment", x = 2, y = 0}, -- Dimensional fields
        {type = "dimensional_containment", x = 0, y = 1}, -- Dimensional fields
        {type = "dimensional_containment", x = 2, y = 1}, -- Dimensional fields
        {type = "dimensional_containment", x = 0, y = 2}, -- Dimensional fields
        {type = "dimensional_containment", x = 1, y = 2}, -- Dimensional fields
        {type = "dimensional_containment", x = 2, y = 2}, -- Dimensional fields
        {type = "energy_harvester", x = 0, y = 0},    -- Energy harvesting array
        {type = "energy_harvester", x = 2, y = 0},    -- Energy harvesting array
        {type = "energy_harvester", x = 0, y = 2},    -- Energy harvesting array
        {type = "energy_harvester", x = 2, y = 2},    -- Energy harvesting array
        {type = "stabilization_matrix", x = 1, y = 0}, -- System stabilization
        {type = "emergency_shutdown", x = 1, y = 2},  -- Emergency systems
        {type = "reality_anchor", x = 0, y = 1},      -- Reality anchoring
        {type = "reality_anchor", x = 2, y = 1},      -- Reality anchoring
        {type = "quantum_flux_capacitor", x = 0, y = 1}, -- Energy storage
        {type = "quantum_flux_capacitor", x = 2, y = 1}  -- Energy storage
    }
end

return ZeroPointReactor
