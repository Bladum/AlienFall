--- Gym Facility Class
-- Physical training and fitness facility
--
-- @classmod basescape.facilities.Gym
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

Gym = class('Gym', Facility)

--- Create a new gym facility
-- @param id Unique facility identifier
-- @return Gym New gym facility
function Gym:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "gym", "Gym", 2, 1, {
        -- Capacity contributions
        training_slots = 6,        -- Simultaneous training capacity
        fitness_throughput = 12    -- Daily training throughput
    }, {
        -- Service tags
        "gym",
        "training",
        "fitness",
        "physical_training"
    })

    -- Override properties
    self.armor = 1
    self.power_consumption = 6
    self.monthly_cost = 1200
    self.staffing_requirements = {
        instructors = 1
    }

    self.construction_cost = 18000
    self.construction_days = 2
    self.construction_requirements = {
        alloys = 15,
        polymers = 20,
        electronics = 5
    }

    -- Tactical integration - training equipment and areas
    self.tactical_blocks = {
        {type = "training_equipment", x = 0, y = 0}, -- Weight training
        {type = "training_equipment", x = 1, y = 0}, -- Cardio equipment
        {type = "training_area", x = 0, y = 0},      -- Open training space
        {type = "training_area", x = 1, y = 0}       -- Open training space
    }
end

return Gym
