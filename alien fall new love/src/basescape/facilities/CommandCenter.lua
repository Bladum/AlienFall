--- Command Center Facility Class
-- Base command and control facility
--
-- @classmod basescape.facilities.CommandCenter
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

CommandCenter = class('CommandCenter', Facility)

--- Create a new command center facility
-- @param id Unique facility identifier
-- @return CommandCenter New command center facility
function CommandCenter:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "command_center", "Command Center", 2, 2, {
        -- Capacity contributions
        command_slots = 1,          -- Command staff positions
        communication_range = 50,   -- Communication range in km
        satellite_uplink = 1        -- Satellite control capacity
    }, {
        -- Service tags
        "command_center",
        "communications",
        "satellite_control",
        "base_command"
    })

    -- Override properties
    self.armor = 4
    self.power_consumption = 10
    self.monthly_cost = 2500
    self.staffing_requirements = {
        officers = 2,
        technicians = 1
    }

    self.construction_cost = 40000
    self.construction_days = 3
    self.construction_requirements = {
        alloys = 35,
        electronics = 30,
        polymers = 15
    }

    -- Tactical integration - command posts and communications
    self.tactical_blocks = {
        {type = "command_post", x = 0, y = 0},   -- Main command post
        {type = "command_post", x = 1, y = 0},   -- Secondary command post
        {type = "communications", x = 0, y = 1}, -- Communications array
        {type = "communications", x = 1, y = 1}  -- Backup communications
    }
end

return CommandCenter
