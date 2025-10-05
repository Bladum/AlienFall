--- Quantum Lab Facility Class
-- Quantum physics research facility
--
-- @classmod basescape.facilities.QuantumLab
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

QuantumLab = class('QuantumLab', Facility)

--- Create a new quantum lab facility
-- @param id Unique facility identifier
-- @return QuantumLab New quantum lab facility
function QuantumLab:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "quantum_lab", "Quantum Lab", 2, 2, {
        -- Capacity contributions
        quantum_research = 1,      -- Quantum research capacity
        particle_acceleration = 1, -- Particle acceleration capacity
        quantum_computing = 1      -- Quantum computing capacity
    }, {
        -- Service tags
        "quantum_lab",
        "research",
        "quantum_physics",
        "advanced_science"
    })

    -- Override properties
    self.armor = 4
    self.power_consumption = 25
    self.monthly_cost = 8000
    self.staffing_requirements = {
        physicists = 5,
        quantum_specialists = 3,
        technicians = 2
    }

    self.construction_cost = 150000
    self.construction_days = 7
    self.construction_requirements = {
        alloys = 40,
        electronics = 60,
        alien_materials = 25,
        polymers = 25
    }

    -- Tactical integration - quantum chambers and research equipment
    self.tactical_blocks = {
        {type = "quantum_chamber", x = 0, y = 0},    -- Quantum research chamber
        {type = "quantum_chamber", x = 1, y = 0},    -- Quantum research chamber
        {type = "quantum_chamber", x = 0, y = 1},    -- Quantum research chamber
        {type = "quantum_chamber", x = 1, y = 1},    -- Quantum research chamber
        {type = "particle_accelerator", x = 0, y = 0}, -- Particle accelerator
        {type = "particle_accelerator", x = 1, y = 0}, -- Particle accelerator
        {type = "quantum_computer", x = 0, y = 1},   -- Quantum computer
        {type = "quantum_computer", x = 1, y = 1}    -- Quantum computer
    }
end

return QuantumLab
