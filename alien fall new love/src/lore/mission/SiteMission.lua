--- Site Mission Class
-- Represents a ground mission at a specific site (crash site, terror site, etc.)
--
-- @classmod domain.missions.SiteMission

-- GROK: SiteMission handles ground-based tactical missions with terrain and extraction objectives
-- GROK: Used by mission_system for crash sites, terror attacks, and reconnaissance
-- GROK: Key methods: update(), getStatusBriefing(), getThreatMultiplier()
-- GROK: Manages site control, extraction zones, and civilian/alien interactions

local Mission = require("lore.Mission")

local SiteMission = setmetatable({}, {__index = Mission})
SiteMission.__index = SiteMission

--- Create a new site mission instance
-- @param data Mission data from TOML configuration
-- @return SiteMission instance
function SiteMission.new(data)
    local self = setmetatable(Mission.new(data), SiteMission)

    -- Site-specific properties
    self.terrain = data.terrain or "mixed"
    self.site_type = data.site_type or "crash_site"
    self.extraction_zones = data.deployment.extraction_zones or 1

    -- Site mission threats
    self.threats = data.threats or {}

    -- Site mission state
    self.site_control = 0  -- 0-100% control of the site
    self.extraction_points_secured = 0
    self.civilian_casualties = 0
    self.alien_forces_eliminated = 0

    return self
end

--- Start the site mission
-- @param start_time Current game time
function SiteMission:start(start_time)
    Mission.start(self, start_time)
    self.site_control = 10  -- Initial foothold established
end

--- Update site mission progress
-- @param current_time Current game time
function SiteMission:update(current_time)
    Mission.update(self, current_time)

    if self.status ~= "active" then return end

    -- Simulate site control and objectives
    local progress_ratio = self.progress

    -- Increase site control over time
    self.site_control = math.min(self.site_control + (progress_ratio * 20), 100)

    -- Secure extraction zones
    if progress_ratio > 0.4 and self.extraction_points_secured < self.extraction_zones then
        self.extraction_points_secured = math.min(
            self.extraction_points_secured + math.floor(progress_ratio * 2),
            self.extraction_zones
        )
    end

    -- Simulate alien forces and civilian interactions
    if self.threats.alien_presence == "high" then
        self.alien_forces_eliminated = math.floor(progress_ratio * 15)
    elseif self.threats.alien_presence == "medium" then
        self.alien_forces_eliminated = math.floor(progress_ratio * 8)
    else
        self.alien_forces_eliminated = math.floor(progress_ratio * 3)
    end

    -- Risk of civilian casualties in terror missions
    if self.site_type == "terror_attack" and self.threats.hostile_civilians then
        if math.random() < 0.1 then  -- 10% chance per update
            self.civilian_casualties = self.civilian_casualties + 1
        end
    end
end

--- Complete the site mission
function SiteMission:complete()
    Mission.complete(self)

    -- Additional site-specific completion logic
    if self.site_control >= 80 then
        self.rewards.site_control_bonus = true
    end

    if self.extraction_points_secured >= self.extraction_zones then
        self.rewards.full_extraction = true
    end
end

--- Get site mission status briefing
-- @return string Status briefing
function SiteMission:getStatusBriefing()
    local briefing = Mission.getBriefing(self)

    briefing = briefing .. string.format("TERRAIN: %s\n", string.upper(self.terrain))
    briefing = briefing .. string.format("SITE TYPE: %s\n", string.upper(self.site_type))
    briefing = briefing .. string.format("SITE CONTROL: %d%%\n", self.site_control)
    briefing = briefing .. string.format("EXTRACTION ZONES: %d/%d secured\n",
        self.extraction_points_secured, self.extraction_zones)

    if self.alien_forces_eliminated > 0 then
        briefing = briefing .. string.format("ALIEN FORCES ELIMINATED: %d\n", self.alien_forces_eliminated)
    end

    if self.civilian_casualties > 0 then
        briefing = briefing .. string.format("CIVILIAN CASUALTIES: %d\n", self.civilian_casualties)
    end

    -- Threat assessment
    if self.threats.alien_presence then
        briefing = briefing .. string.format("ALIEN PRESENCE: %s\n", string.upper(self.threats.alien_presence))
    end

    if self.threats.environmental_hazards then
        briefing = briefing .. string.format("HAZARDS: %s\n", string.upper(self.threats.environmental_hazards))
    end

    return briefing
end

--- Calculate mission difficulty based on threats
-- @return number Difficulty multiplier
function SiteMission:getThreatMultiplier()
    local multiplier = 1.0

    if self.threats.alien_presence == "high" then
        multiplier = multiplier * 1.5
    elseif self.threats.alien_presence == "medium" then
        multiplier = multiplier * 1.2
    end

    if self.threats.hostile_civilians then
        multiplier = multiplier * 1.3
    end

    if self.threats.environmental_hazards then
        multiplier = multiplier * 1.1
    end

    return multiplier
end

return SiteMission
