--- Medical Bay Facility Class
-- Medical treatment and recovery facility
--
-- @classmod basescape.facilities.MedicalBay
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

MedicalBay = class('MedicalBay', Facility)

--- Create a new medical bay facility
-- @param id Unique facility identifier
-- @return MedicalBay New medical bay facility
function MedicalBay:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "medical_bay", "Medical Bay", 2, 1, {
        -- Capacity contributions
        medical_beds = 4,          -- Treatment beds
        recovery_slots = 6,        -- Recovery beds
        medical_throughput = 2     -- Simultaneous treatments
    }, {
        -- Service tags
        "medical_bay",
        "medical",
        "recovery",
        "treatment"
    })

    -- Override properties
    self.armor = 2
    self.power_consumption = 8
    self.monthly_cost = 2000
    self.staffing_requirements = {
        doctors = 2,
        nurses = 1
    }

    self.construction_cost = 30000
    self.construction_days = 2
    self.construction_requirements = {
        alloys = 25,
        medical_supplies = 20,
        polymers = 15
    }

    -- Tactical integration - medical stations and recovery areas
    self.tactical_blocks = {
        {type = "medical_station", x = 0, y = 0}, -- Treatment station
        {type = "medical_station", x = 1, y = 0}, -- Treatment station
        {type = "recovery_bed", x = 0, y = 0},    -- Recovery area
        {type = "recovery_bed", x = 1, y = 0}     -- Recovery area
    }
end

return MedicalBay
