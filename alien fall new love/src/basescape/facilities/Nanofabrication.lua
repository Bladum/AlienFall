--- Nanofabrication Facility Class
-- Advanced nanotechnology manufacturing facility
--
-- @classmod basescape.facilities.Nanofabrication
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

Nanofabrication = class('Nanofabrication', Facility)

--- Create a new nanofabrication facility
-- @param id Unique facility identifier
-- @return Nanofabrication New nanofabrication facility
function Nanofabrication:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "nanofabrication", "Nanofabrication", 2, 2, {
        -- Capacity contributions
        nano_manufacturing = 1,    -- Nanotech manufacturing capacity
        material_synthesis = 2,     -- Advanced material synthesis
        precision_fabrication = 3  -- High-precision manufacturing
    }, {
        -- Service tags
        "nanofabrication",
        "nanotechnology",
        "advanced_manufacturing",
        "precision_fabrication"
    })

    -- Override properties
    self.armor = 3
    self.power_consumption = 22
    self.monthly_cost = 6000
    self.staffing_requirements = {
        nanotechnicians = 4,
        scientists = 2,
        engineers = 1
    }

    self.construction_cost = 120000
    self.construction_days = 6
    self.construction_requirements = {
        alloys = 30,
        electronics = 50,
        alien_materials = 15,
        polymers = 20
    }

    -- Tactical integration - nanofabrication chambers and control systems
    self.tactical_blocks = {
        {type = "nano_chamber", x = 0, y = 0},       -- Fabrication chamber
        {type = "nano_chamber", x = 1, y = 0},       -- Fabrication chamber
        {type = "nano_chamber", x = 0, y = 1},       -- Fabrication chamber
        {type = "nano_chamber", x = 1, y = 1},       -- Fabrication chamber
        {type = "control_system", x = 0, y = 0},     -- Control system
        {type = "control_system", x = 1, y = 0},     -- Control system
        {type = "synthesis_unit", x = 0, y = 1},     -- Material synthesis
        {type = "synthesis_unit", x = 1, y = 1}      -- Material synthesis
    }
end

return Nanofabrication
