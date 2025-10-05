--- Psi Lab Facility Class
-- Psionic research and training facility
--
-- @classmod basescape.facilities.PsiLab
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

PsiLab = class('PsiLab', Facility)

--- Create a new psi lab facility
-- @param id Unique facility identifier
-- @return PsiLab New psi lab facility
function PsiLab:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "psi_lab", "Psi Lab", 2, 2, {
        -- Capacity contributions
        psi_training_slots = 2,    -- Psionic training chambers
        psi_research_slots = 1,    -- Research stations
        containment_cells = 4      -- Psionic containment
    }, {
        -- Service tags
        "psi_lab",
        "psionic",
        "research",
        "training"
    })

    -- Override properties
    self.armor = 5
    self.power_consumption = 15
    self.monthly_cost = 4000
    self.staffing_requirements = {
        psi_specialists = 3,
        scientists = 2
    }

    self.construction_cost = 75000
    self.construction_days = 5
    self.construction_requirements = {
        alloys = 40,
        electronics = 35,
        alien_materials = 20,
        polymers = 25
    }

    -- Tactical integration - psi chambers and containment
    self.tactical_blocks = {
        {type = "psi_chamber", x = 0, y = 0},      -- Training chamber
        {type = "psi_chamber", x = 1, y = 0},      -- Training chamber
        {type = "containment_cell", x = 0, y = 1}, -- Containment
        {type = "containment_cell", x = 1, y = 1}, -- Containment
        {type = "research_station", x = 0, y = 1}, -- Research equipment
        {type = "research_station", x = 1, y = 1}  -- Research equipment
    }
end

return PsiLab
