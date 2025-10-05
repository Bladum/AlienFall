--- Security Station Facility Class
-- Base security and monitoring facility
--
-- @classmod basescape.facilities.SecurityStation
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

SecurityStation = class('SecurityStation', Facility)

--- Create a new security station facility
-- @param id Unique facility identifier
-- @return SecurityStation New security station facility
function SecurityStation:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "security_station", "Security Station", 2, 1, {
        -- Capacity contributions
        security_personnel = 4,    -- Security staff capacity
        monitoring_stations = 2,   -- Security monitoring stations
        detention_cells = 2       -- Holding cells
    }, {
        -- Service tags
        "security_station",
        "security",
        "monitoring",
        "detention"
    })

    -- Override properties
    self.armor = 3
    self.power_consumption = 5
    self.monthly_cost = 1600
    self.staffing_requirements = {
        security = 4
    }

    self.construction_cost = 24000
    self.construction_days = 2
    self.construction_requirements = {
        alloys = 20,
        electronics = 15,
        polymers = 18
    }

    -- Tactical integration - security posts and monitoring equipment
    self.tactical_blocks = {
        {type = "security_post", x = 0, y = 0},    -- Security station
        {type = "security_post", x = 1, y = 0},    -- Security station
        {type = "monitoring_station", x = 0, y = 0}, -- Monitoring equipment
        {type = "monitoring_station", x = 1, y = 0}, -- Monitoring equipment
        {type = "detention_cell", x = 0, y = 0},   -- Holding cell
        {type = "detention_cell", x = 1, y = 0}    -- Holding cell
    }
end

return SecurityStation
