---Campaign Stats Screen
---
---Display campaign progression statistics and achievements. Shows military stats,
---alien stats, base stats, and key milestones reached during the campaign.
---
---Key Exports:
---  - CampaignStatsScreen:enter(): Initialize stats display
---  - CampaignStatsScreen:draw(): Render stats UI
---  - CampaignStatsScreen:keypressed(key): Handle input (ESC to close)
---
---Stats Displayed:
---  - Campaign name and difficulty
---  - Days elapsed and current threat level
---  - Military: Units, losses, missions, accuracy
---  - Alien: Species encountered, kills, research
---  - Base: Facilities, research progress
---
---@module scenes.campaign_stats_screen
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local StateManager = require("core.state_manager")

local CampaignStatsScreen = {}

--- Initialize stats screen
function CampaignStatsScreen:enter()
    print("[CampaignStatsScreen] Entering campaign stats screen")

    -- Get campaign data from state manager
    self.campaign_data = StateManager:getGlobalData("campaign_data") or {}

    -- Calculate stats
    self:_calculateStats()

    -- UI state
    self.scroll_offset = 0
end

--- Calculate campaign statistics
function CampaignStatsScreen:_calculateStats()
    local data = self.campaign_data

    self.stats = {
        -- Campaign info
        name = data.campaign_name or "Unknown Campaign",
        difficulty = data.difficulty or "NORMAL",
        days_elapsed = data.campaign_day or 0,
        threat_level = data.threat_level or 1,
        start_date = data.start_date or os.date("%Y-%m-%d"),

        -- Military stats
        units_recruited = data.units_recruited or 24,
        units_lost = data.units_lost or 4,
        units_alive = data.units_alive or 20,
        missions_won = data.missions_won or 32,
        missions_lost = data.missions_lost or 3,
        avg_accuracy = data.avg_accuracy or 78,

        -- Alien stats
        species_encountered = data.species_encountered or 3,
        total_kills = data.total_kills or 342,
        highest_threat = data.highest_threat or 4,
        research_unlocked = data.research_unlocked or 12,

        -- Base stats
        facilities_built = data.facilities_built or 8,
        research_complete = data.research_complete or 12,
        manufacturing_items = data.manufacturing_items or 45,

        -- Achievements
        first_blood = data.first_blood or true,
        base_defense = data.base_defense or false,
        perfect_mission = data.perfect_mission or true,
        legendary_soldier = data.legendary_soldier or false,
    }
end

--- Update stats screen
function CampaignStatsScreen:update(dt)
    -- No continuous updates
end

--- Draw stats screen
function CampaignStatsScreen:draw()
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.getFont())
    love.graphics.printf("CAMPAIGN STATISTICS", 0, 2 * 24, 40 * 24, "center")

    -- Campaign header
    love.graphics.setColor(0.7, 0.9, 1, 1)
    love.graphics.printf(self.stats.name, 4 * 24, 5 * 24, 32 * 24, "left")

    love.graphics.setColor(0.6, 0.8, 0.9, 1)
    local header = string.format(
        "Difficulty: %s | Days: %d | Threat: %d/5",
        self.stats.difficulty,
        self.stats.days_elapsed,
        self.stats.threat_level
    )
    love.graphics.printf(header, 4 * 24, 6 * 24, 32 * 24, "left")

    -- Stats content
    local y = 8 * 24
    local line_height = 24

    -- Military Stats section
    love.graphics.setColor(1, 1, 0.7, 1)
    love.graphics.printf("MILITARY STATS", 4 * 24, y, 32 * 24, "left")
    y = y + line_height

    love.graphics.setColor(1, 1, 1, 1)
    y = self:_drawStatLine("Units Recruited", self.stats.units_recruited, y)
    y = self:_drawStatLine("Units Lost", self.stats.units_lost, y)
    y = self:_drawStatLine("Units Alive", self.stats.units_alive, y)
    y = self:_drawStatLine("Missions Won", self.stats.missions_won, y)
    y = self:_drawStatLine("Missions Lost", self.stats.missions_lost, y)
    y = self:_drawStatLine("AVG Accuracy", self.stats.avg_accuracy .. "%", y)

    y = y + line_height

    -- Alien Stats section
    love.graphics.setColor(1, 0.7, 1, 1)
    love.graphics.printf("ALIEN STATS", 4 * 24, y, 32 * 24, "left")
    y = y + line_height

    love.graphics.setColor(1, 1, 1, 1)
    y = self:_drawStatLine("Species Encountered", self.stats.species_encountered, y)
    y = self:_drawStatLine("Total Kills", self.stats.total_kills, y)
    y = self:_drawStatLine("Highest Threat", self.stats.highest_threat .. "/5", y)
    y = self:_drawStatLine("Research Unlocked", self.stats.research_unlocked .. "/18", y)

    y = y + line_height

    -- Base Stats section
    love.graphics.setColor(0.7, 1, 0.7, 1)
    love.graphics.printf("BASE STATS", 4 * 24, y, 32 * 24, "left")
    y = y + line_height

    love.graphics.setColor(1, 1, 1, 1)
    y = self:_drawStatLine("Facilities Built", self.stats.facilities_built, y)
    y = self:_drawStatLine("Research Complete", self.stats.research_complete, y)
    y = self:_drawStatLine("Manufacturing Items", self.stats.manufacturing_items, y)

    y = y + line_height

    -- Achievements section
    love.graphics.setColor(1, 1, 0.7, 1)
    love.graphics.printf("ACHIEVEMENTS", 4 * 24, y, 32 * 24, "left")
    y = y + line_height

    love.graphics.setColor(1, 1, 1, 1)
    y = self:_drawAchievement("First Blood", self.stats.first_blood, y)
    y = self:_drawAchievement("Base Defense Victory", self.stats.base_defense, y)
    y = self:_drawAchievement("Perfect Mission", self.stats.perfect_mission, y)
    y = self:_drawAchievement("Legendary Soldier", self.stats.legendary_soldier, y)

    -- Footer instructions
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.printf("Press ESC to return", 0, 28 * 24, 40 * 24, "center")
end

--- Draw a stat line
function CampaignStatsScreen:_drawStatLine(label, value, y)
    love.graphics.printf(label .. ":", 4 * 24, y, 20 * 24, "left")
    love.graphics.printf(tostring(value), 24 * 24, y, 12 * 24, "right")
    return y + 24
end

--- Draw achievement indicator
function CampaignStatsScreen:_drawAchievement(label, unlocked, y)
    local icon = unlocked and "✓" or "○"
    local color = unlocked and {0.2, 1, 0.2, 1} or {0.5, 0.5, 0.5, 1}

    love.graphics.setColor(unpack(color))
    love.graphics.printf(icon .. " " .. label, 4 * 24, y, 32 * 24, "left")

    return y + 24
end

--- Handle keyboard input
function CampaignStatsScreen:keypressed(key, scancode, isrepeat)
    if key == "escape" or key == "return" then
        StateManager.switch("geoscape")
    end
end

return CampaignStatsScreen
