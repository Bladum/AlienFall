--- Terraforming Lab Facility Class
-- Planetary modification research facility
--
-- @classmod basescape.facilities.TerraformingLab
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

TerraformingLab = class('TerraformingLab', Facility)

--- Create a new terraforming lab facility
-- @param id Unique facility identifier
-- @return TerraformingLab New terraforming lab facility
function TerraformingLab:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "terraforming_lab", "Terraforming Lab", 2, 2, {
        -- Capacity contributions
        terraforming_research = 1, -- Terraforming research capacity
        ecological_analysis = 2,   -- Ecological analysis capacity
        atmospheric_processing = 1 -- Atmospheric processing capacity
    }, {
        -- Service tags
        "terraforming_lab",
        "research",
        "planetary_modification",
        "ecological"
    })

    -- Override properties
    self.armor = 3
    self.power_consumption = 14
    self.monthly_cost = 3500
    self.staffing_requirements = {
        ecologists = 3,
        planetary_scientists = 2,
        engineers = 1
    }

    self.construction_cost = 65000
    self.construction_days = 5
    self.construction_requirements = {
        alloys = 35,
        electronics = 25,
        polymers = 20,
        alien_materials = 10
    }

    -- Tactical integration - terraforming research stations and analysis equipment
    self.tactical_blocks = {
        {type = "terraforming_station", x = 0, y = 0}, -- Research station
        {type = "terraforming_station", x = 1, y = 0}, -- Research station
        {type = "terraforming_station", x = 0, y = 1}, -- Research station
        {type = "terraforming_station", x = 1, y = 1}, -- Research station
        {type = "ecological_analyzer", x = 0, y = 0},  -- Ecological analysis
        {type = "ecological_analyzer", x = 1, y = 0},  -- Ecological analysis
        {type = "atmospheric_processor", x = 0, y = 1}, -- Atmospheric processing
        {type = "atmospheric_processor", x = 1, y = 1}  -- Atmospheric processing
    }
end

return TerraformingLab
