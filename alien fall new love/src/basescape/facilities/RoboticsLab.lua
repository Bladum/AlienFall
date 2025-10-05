--- Robotics Lab Facility Class
-- Robotics research and development facility
--
-- @classmod basescape.facilities.RoboticsLab
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

RoboticsLab = class('RoboticsLab', Facility)

--- Create a new robotics lab facility
-- @param id Unique facility identifier
-- @return RoboticsLab New robotics lab facility
function RoboticsLab:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "robotics_lab", "Robotics Lab", 2, 2, {
        -- Capacity contributions
        robotics_slots = 2,        -- Robotics workstations
        automation_research = 1,   -- Automation research capacity
        drone_production = 1       -- Drone manufacturing capacity
    }, {
        -- Service tags
        "robotics_lab",
        "research",
        "automation",
        "drone_production"
    })

    -- Override properties
    self.armor = 2
    self.power_consumption = 10
    self.monthly_cost = 2000
    self.staffing_requirements = {
        engineers = 2,
        scientists = 1
    }

    self.construction_cost = 35000
    self.construction_days = 3
    self.construction_requirements = {
        alloys = 25,
        electronics = 30,
        polymers = 15
    }

    -- Tactical integration - robotics workstations and testing areas
    self.tactical_blocks = {
        {type = "robotics_station", x = 0, y = 0},   -- Robotics workstation
        {type = "robotics_station", x = 1, y = 0},   -- Robotics workstation
        {type = "robotics_station", x = 0, y = 1},   -- Robotics workstation
        {type = "robotics_station", x = 1, y = 1},   -- Robotics workstation
        {type = "testing_area", x = 0, y = 0},       -- Testing area
        {type = "testing_area", x = 1, y = 0},       -- Testing area
        {type = "assembly_bay", x = 0, y = 1},       -- Assembly bay
        {type = "assembly_bay", x = 1, y = 1}        -- Assembly bay
    }
end

return RoboticsLab
