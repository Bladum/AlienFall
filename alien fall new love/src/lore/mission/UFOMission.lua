--- UFO Mission Class
-- Represents a UFO interception mission
--
-- @classmod domain.missions.UFOMission

-- GROK: UFOMission handles aerial interception and combat with alien spacecraft
-- GROK: Used by mission_system for UFO encounters and dogfights
-- GROK: Key methods: update(), getStatusBriefing(), getInterceptDifficulty()
-- GROK: Manages UFO states, interception success, and recovery chances

local Mission = require("lore.Mission")

local UFOMission = setmetatable({}, {__index = Mission})
UFOMission.__index = UFOMission

--- Create a new UFO mission instance
-- @param data Mission data from TOML configuration
-- @return UFOMission instance
function UFOMission.new(data)
    local self = setmetatable(Mission.new(data), UFOMission)

    -- UFO-specific properties
    self.ufo_size = data.ufo_size or "medium"
    self.ufo_type = data.ufo_type or "scout"
    self.intercept_range = data.deployment.intercept_range or 100
    self.combat_range = data.deployment.combat_range or 50
    self.ufo_recovery_chance = data.rewards.ufo_recovery_chance or 0.5

    -- UFO mission state
    self.ufo_status = "approaching"  -- approaching, intercepted, engaged, fleeing, destroyed
    self.intercept_success = false
    self.recovery_success = false

    return self
end

--- Start the UFO mission
-- @param start_time Current game time
function UFOMission:start(start_time)
    Mission.start(self, start_time)
    self.ufo_status = "approaching"
end

--- Update UFO mission progress
-- @param current_time Current game time
function UFOMission:update(current_time)
    Mission.update(self, current_time)

    if self.status ~= "active" then return end

    -- Simulate UFO behavior based on progress
    local progress_ratio = self.progress

    if progress_ratio < 0.3 then
        self.ufo_status = "approaching"
    elseif progress_ratio < 0.6 then
        self.ufo_status = "intercepted"
        self.intercept_success = true
    elseif progress_ratio < 0.8 then
        self.ufo_status = "engaged"
    else
        -- Random chance of UFO fleeing or being destroyed
        if math.random() < 0.7 then
            self.ufo_status = "destroyed"
            self.recovery_success = math.random() < self.ufo_recovery_chance
        else
            self.ufo_status = "fleeing"
        end
    end
end

--- Complete the UFO mission
function UFOMission:complete()
    Mission.complete(self)

    -- Additional UFO-specific completion logic
    if self.ufo_status == "destroyed" and self.recovery_success then
        -- Award additional recovery rewards
        self.rewards.recovered_ufo = true
    end
end

--- Get UFO mission status briefing
-- @return string Status briefing
function UFOMission:getStatusBriefing()
    local briefing = Mission.getBriefing(self)

    briefing = briefing .. string.format("UFO SIZE: %s\n", string.upper(self.ufo_size))
    briefing = briefing .. string.format("UFO TYPE: %s\n", string.upper(self.ufo_type))
    briefing = briefing .. string.format("UFO STATUS: %s\n", string.upper(self.ufo_status))

    if self.intercept_success then
        briefing = briefing .. "INTERCEPT: SUCCESSFUL\n"
    end

    if self.recovery_success then
        briefing = briefing .. "RECOVERY: SUCCESSFUL - UFO debris recovered\n"
    end

    return briefing
end

--- Calculate interception difficulty based on UFO size
-- @return number Difficulty multiplier
function UFOMission:getInterceptDifficulty()
    local size_multipliers = {
        small = 0.8,
        medium = 1.0,
        large = 1.3,
        very_large = 1.6
    }

    return size_multipliers[self.ufo_size] or 1.0
end

return UFOMission
