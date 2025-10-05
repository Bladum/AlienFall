--- Bio Lab Facility Class
-- Biological research and development facility
--
-- @classmod basescape.facilities.BioLab
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

BioLab = class('BioLab', Facility)

--- Create a new bio lab facility
-- @param id Unique facility identifier
-- @return BioLab New bio lab facility
function BioLab:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "bio_lab", "Bio Lab", 2, 2, {
        -- Capacity contributions
        biological_research = 2,   -- Biological research capacity
        genetic_analysis = 1,      -- Genetic analysis capacity
        bio_engineering = 1        -- Bio-engineering capacity
    }, {
        -- Service tags
        "bio_lab",
        "research",
        "biological",
        "genetics"
    })

    -- Override properties
    self.armor = 3
    self.power_consumption = 12
    self.monthly_cost = 3000
    self.staffing_requirements = {
        biologists = 3,
        geneticists = 2,
        technicians = 1
    }

    self.construction_cost = 55000
    self.construction_days = 4
    self.construction_requirements = {
        alloys = 30,
        medical_supplies = 25,
        electronics = 20,
        polymers = 15
    }

    -- Tactical integration - biological research stations and containment
    self.tactical_blocks = {
        {type = "bio_research_station", x = 0, y = 0}, -- Research station
        {type = "bio_research_station", x = 1, y = 0}, -- Research station
        {type = "bio_research_station", x = 0, y = 1}, -- Research station
        {type = "bio_research_station", x = 1, y = 1}, -- Research station
        {type = "genetic_sequencer", x = 0, y = 0},    -- Genetic analysis
        {type = "genetic_sequencer", x = 1, y = 0},    -- Genetic analysis
        {type = "bio_containment", x = 0, y = 1},      -- Biological containment
        {type = "bio_containment", x = 1, y = 1}       -- Biological containment
    }
end

return BioLab
