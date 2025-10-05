--- Defense Turret Facility Class
-- Automated defense turret facility
--
-- @classmod basescape.facilities.DefenseTurret
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

DefenseTurret = class('DefenseTurret', Facility)

--- Create a new defense turret facility
-- @param id Unique facility identifier
-- @return DefenseTurret New defense turret facility
function DefenseTurret:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "defense_turret", "Defense Turret", 1, 1, {
        -- Capacity contributions
        defense_coverage = 3,      -- Defense coverage radius
        firepower = 2             -- Defensive firepower rating
    }, {
        -- Service tags
        "defense_turret",
        "defense",
        "automated_defense"
    })

    -- Override properties
    self.armor = 4
    self.power_consumption = 6
    self.monthly_cost = 1200
    self.staffing_requirements = {}  -- Automated

    self.construction_cost = 18000
    self.construction_days = 2
    self.construction_requirements = {
        alloys = 25,
        electronics = 15,
        weapon_parts = 10
    }

    -- Tactical integration - turret mount and targeting systems
    self.tactical_blocks = {
        {type = "turret_mount", x = 0, y = 0},     -- Turret mounting
        {type = "targeting_system", x = 0, y = 0}  -- Targeting computer
    }
end

return DefenseTurret
