--- Missile Defense Facility Class
-- Missile interception and defense facility
--
-- @classmod basescape.facilities.MissileDefense
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

MissileDefense = class('MissileDefense', Facility)

--- Create a new missile defense facility
-- @param id Unique facility identifier
-- @return MissileDefense New missile defense facility
function MissileDefense:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "missile_defense", "Missile Defense", 2, 2, {
        -- Capacity contributions
        missile_interception = 4,  -- Missile interception capacity
        defense_coverage = 8,      -- Defense coverage radius
        ammo_storage = 20         -- Missile storage capacity
    }, {
        -- Service tags
        "missile_defense",
        "defense",
        "interception",
        "anti_air"
    })

    -- Override properties
    self.armor = 5
    self.power_consumption = 14
    self.monthly_cost = 2800
    self.staffing_requirements = {
        technicians = 2,
        operators = 1
    }

    self.construction_cost = 45000
    self.construction_days = 3
    self.construction_requirements = {
        alloys = 40,
        electronics = 30,
        weapon_parts = 25,
        polymers = 15
    }

    -- Tactical integration - missile launchers and radar systems
    self.tactical_blocks = {
        {type = "missile_launcher", x = 0, y = 0}, -- Missile launcher
        {type = "missile_launcher", x = 1, y = 0}, -- Missile launcher
        {type = "missile_launcher", x = 0, y = 1}, -- Missile launcher
        {type = "missile_launcher", x = 1, y = 1}, -- Missile launcher
        {type = "radar_system", x = 0, y = 0},     -- Tracking radar
        {type = "radar_system", x = 1, y = 0},     -- Tracking radar
        {type = "control_center", x = 0, y = 1},   -- Fire control
        {type = "control_center", x = 1, y = 1}    -- Fire control
    }
end

return MissileDefense
