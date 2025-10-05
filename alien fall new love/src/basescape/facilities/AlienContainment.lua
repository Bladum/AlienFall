--- Alien Containment Facility Class
-- Alien specimen storage and research facility
--
-- @classmod basescape.facilities.AlienContainment
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

AlienContainment = class('AlienContainment', Facility)

--- Create a new alien containment facility
-- @param id Unique facility identifier
-- @return AlienContainment New alien containment facility
function AlienContainment:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "alien_containment", "Alien Containment", 2, 2, {
        -- Capacity contributions
        containment_cells = 6,     -- Alien containment cells
        research_slots = 2,        -- Research stations
        specimen_storage = 10      -- Specimen storage capacity
    }, {
        -- Service tags
        "alien_containment",
        "research",
        "specimen_storage",
        "biological"
    })

    -- Override properties
    self.armor = 6
    self.power_consumption = 16
    self.monthly_cost = 3500
    self.staffing_requirements = {
        scientists = 3,
        security = 4
    }

    self.construction_cost = 60000
    self.construction_days = 4
    self.construction_requirements = {
        alloys = 45,
        alien_materials = 25,
        polymers = 20,
        electronics = 15
    }

    -- Tactical integration - containment cells and research areas
    self.tactical_blocks = {
        {type = "containment_cell", x = 0, y = 0}, -- Containment cell
        {type = "containment_cell", x = 1, y = 0}, -- Containment cell
        {type = "containment_cell", x = 0, y = 1}, -- Containment cell
        {type = "containment_cell", x = 1, y = 1}, -- Containment cell
        {type = "research_station", x = 0, y = 0}, -- Research station
        {type = "research_station", x = 1, y = 0}, -- Research station
        {type = "specimen_prep", x = 0, y = 1},    -- Specimen preparation
        {type = "specimen_prep", x = 1, y = 1}     -- Specimen preparation
    }
end

return AlienContainment
