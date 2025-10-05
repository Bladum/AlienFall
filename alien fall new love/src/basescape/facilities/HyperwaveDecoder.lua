--- Hyperwave Decoder Facility Class
-- Alien communication interception facility
--
-- @classmod basescape.facilities.HyperwaveDecoder
-- @extends basescape.Facility

local Facility = require 'basescape.Facility'
local class = require 'lib.Middleclass'

HyperwaveDecoder = class('HyperwaveDecoder', Facility)

--- Create a new hyperwave decoder facility
-- @param id Unique facility identifier
-- @return HyperwaveDecoder New hyperwave decoder facility
function HyperwaveDecoder:initialize(id)
    -- Call parent constructor
    Facility.initialize(self, id or "hyperwave_decoder", "Hyperwave Decoder", 2, 2, {
        -- Capacity contributions
        signal_interception = 1,   -- Alien signal interception
        decoder_slots = 3,         -- Simultaneous decoding operations
        intelligence_throughput = 5 -- Intelligence reports per day
    }, {
        -- Service tags
        "hyperwave_decoder",
        "communications",
        "intelligence",
        "alien_tech"
    })

    -- Override properties
    self.armor = 3
    self.power_consumption = 20
    self.monthly_cost = 5000
    self.staffing_requirements = {
        cryptographers = 4,
        linguists = 2,
        technicians = 3
    }

    self.construction_cost = 100000
    self.construction_days = 6
    self.construction_requirements = {
        alloys = 50,
        electronics = 40,
        alien_materials = 30,
        polymers = 20
    }

    -- Tactical integration - decoder arrays and analysis stations
    self.tactical_blocks = {
        {type = "decoder_array", x = 0, y = 0},    -- Main decoder
        {type = "decoder_array", x = 1, y = 0},    -- Secondary decoder
        {type = "decoder_array", x = 0, y = 1},    -- Tertiary decoder
        {type = "decoder_array", x = 1, y = 1},    -- Backup decoder
        {type = "analysis_station", x = 0, y = 0}, -- Analysis station
        {type = "analysis_station", x = 1, y = 0}, -- Analysis station
        {type = "analysis_station", x = 0, y = 1}, -- Analysis station
        {type = "analysis_station", x = 1, y = 1}  -- Analysis station
    }
end

return HyperwaveDecoder
