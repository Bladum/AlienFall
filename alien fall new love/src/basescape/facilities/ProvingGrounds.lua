--- Proving Grounds Facility Class
-- Weapon testing and evaluation facility
--
-- @classmod basescape.facilities.ProvingGrounds
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

ProvingGrounds = class('ProvingGrounds', Facility)

--- Create a new proving grounds facility
-- @param id Unique facility identifier
-- @return ProvingGrounds New proving grounds facility
function ProvingGrounds:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "proving_grounds", "Proving Grounds", 3, 2, {
        -- Capacity contributions
        testing_chambers = 2,      -- Testing chambers
        evaluation_slots = 4,      -- Equipment evaluation stations
        research_throughput = 3    -- Research testing capacity
    }, {
        -- Service tags
        "proving_grounds",
        "testing",
        "research",
        "weapon_testing"
    })

    -- Override properties
    self.armor = 4
    self.power_consumption = 12
    self.monthly_cost = 2200
    self.staffing_requirements = {
        scientists = 2,
        engineers = 2,
        technicians = 1
    }

    self.construction_cost = 38000
    self.construction_days = 3
    self.construction_requirements = {
        alloys = 35,
        electronics = 20,
        polymers = 25,
        weapon_parts = 15
    }

    -- Tactical integration - testing chambers and evaluation areas
    self.tactical_blocks = {
        {type = "testing_chamber", x = 0, y = 0},  -- Testing chamber
        {type = "testing_chamber", x = 1, y = 0},  -- Testing chamber
        {type = "testing_chamber", x = 2, y = 0},  -- Testing chamber
        {type = "evaluation_station", x = 0, y = 1}, -- Evaluation station
        {type = "evaluation_station", x = 1, y = 1}, -- Evaluation station
        {type = "evaluation_station", x = 2, y = 1}, -- Evaluation station
        {type = "observation_deck", x = 0, y = 0}, -- Observation area
        {type = "observation_deck", x = 1, y = 0}, -- Observation area
        {type = "observation_deck", x = 2, y = 0}  -- Observation area
    }
end

return ProvingGrounds
