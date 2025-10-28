---Mission Briefing Screen
---
---Pre-mission briefing interface showing mission objectives, enemies, rewards,
---and tactical recommendations. Players review mission details before committing
---to deployment. Serves as bridge between Geoscape mission selection and
---Deployment/Battlescape entry.
---
---Features:
---  - Mission title and description
---  - Objectives and win conditions
---  - Enemy composition and strength estimate
---  - Location and time of day
---  - Financial and research rewards
---  - Difficulty rating (1-5 stars)
---  - Squad recommendations
---  - Tactical advisor suggestions
---
---Screen Flow:
---  1. Geoscape (mission selected) → Mission Briefing
---  2. Mission Briefing (review) → Accept/Decline
---  3. Accept → Deployment Screen
---  4. Deployment Screen (confirm) → Battlescape
---  5. Decline → Geoscape (return)
---
---Dependencies:
---  - widgets: UI components (buttons, panels, text)
---  - gui.scenes.geoscape_screen: Return target
---  - gui.scenes.deployment_screen: Next screen target
---  - ai.strategic.threat_manager: Difficulty info
---  - core.localization: Mission text localization
---
---@module gui.scenes.mission_briefing_screen
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MissionBriefing = require("gui.scenes.mission_briefing_screen")
---  MissionBriefing:enter({ mission = missionData })
---
---  -- In update/draw callbacks, the mission data persists
---  -- User clicks Accept → transitions to deployment_screen
---  -- User clicks Decline → transitions back to geoscape_screen

local MissionBriefing = {}
MissionBriefing.__index = MissionBriefing

-- Screen state
MissionBriefing.missionData = nil        -- Current mission being briefed
MissionBriefing.selectedSquad = nil      -- Pre-selected squad
MissionBriefing.difficultyRating = 0     -- 1-5 stars
MissionBriefing.scrollOffset = 0         -- For long descriptions
MissionBriefing.acceptButton = nil       -- UI button references
MissionBriefing.declineButton = nil

-- UI Layout constants
MissionBriefing.PANEL_WIDTH = 800
MissionBriefing.PANEL_HEIGHT = 600
MissionBriefing.PANEL_X = (1024 - 800) / 2
MissionBriefing.PANEL_Y = (768 - 600) / 2
MissionBriefing.PADDING = 16
MissionBriefing.LINE_HEIGHT = 24

---Enter mission briefing screen
---@param args table Screen arguments {mission: table}
function MissionBriefing:enter(args)
    print("[MissionBriefing] Entering mission briefing screen")

    if args and args.mission then
        self.missionData = args.mission
        print(string.format("[MissionBriefing] Mission data received: %s",
            self.missionData.id or "unnamed"))

        -- Calculate difficulty from threat level
        self.difficultyRating = self:_calculateDifficulty(self.missionData.threatLevel or 0.5)
    else
        print("[MissionBriefing] No mission data provided")
        self.missionData = self:_getDefaultMission()
    end

    self.scrollOffset = 0
end

---Exit mission briefing (return to geoscape or decline)
function MissionBriefing:exit()
    print("[MissionBriefing] Exiting mission briefing screen")
    self.missionData = nil
end

---Update mission briefing state
---@param delta_time number Delta time in seconds
function MissionBriefing:update(delta_time)
    -- Handle scroll input
    if love.keyboard.isDown("up") then
        self.scrollOffset = math.max(self.scrollOffset - 100 * delta_time, 0)
    elseif love.keyboard.isDown("down") then
        self.scrollOffset = math.min(self.scrollOffset + 100 * delta_time, 500)
    end
end

---Draw mission briefing screen
function MissionBriefing:draw()
    if not self.missionData then return end

    love.graphics.clear(0.1, 0.1, 0.15)

    -- Draw background panel
    love.graphics.setColor(0.15, 0.15, 0.2, 0.95)
    love.graphics.rectangle("fill",
        self.PANEL_X, self.PANEL_Y,
        self.PANEL_WIDTH, self.PANEL_HEIGHT)

    -- Draw border
    love.graphics.setColor(0.4, 0.7, 1.0, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line",
        self.PANEL_X, self.PANEL_Y,
        self.PANEL_WIDTH, self.PANEL_HEIGHT)

    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.getFont())
    local title = string.format("MISSION BRIEFING: %s",
        self.missionData.name or "Unknown Operation")
    love.graphics.print(title,
        self.PANEL_X + self.PADDING,
        self.PANEL_Y + self.PADDING)

    -- Draw mission type and difficulty
    local y = self.PANEL_Y + self.PADDING + self.LINE_HEIGHT + 8
    love.graphics.setColor(0.8, 0.8, 0.8)

    local missionType = self.missionData.type or "Research"
    local typeStr = missionType:upper()
    love.graphics.print(string.format("Type: %s", typeStr),
        self.PANEL_X + self.PADDING, y)

    y = y + self.LINE_HEIGHT
    local difficulty = self:_getDifficultyStars()
    love.graphics.setColor(1, 0.84, 0)  -- Gold for difficulty
    love.graphics.print(string.format("Difficulty: %s (%d/5)",
        difficulty, self.difficultyRating),
        self.PANEL_X + self.PADDING, y)

    -- Draw objectives section
    y = y + self.LINE_HEIGHT * 1.5
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("OBJECTIVES:", self.PANEL_X + self.PADDING, y)

    y = y + self.LINE_HEIGHT
    love.graphics.setColor(0.9, 0.9, 0.9)

    local objectives = self.missionData.objectives or {"Eliminate all hostiles"}
    for _, obj in ipairs(objectives) do
        if type(obj) == "string" then
            love.graphics.print("• " .. obj, self.PANEL_X + self.PADDING * 2, y)
        else
            love.graphics.print("• " .. (obj.description or "Unknown"),
                self.PANEL_X + self.PADDING * 2, y)
        end
        y = y + self.LINE_HEIGHT
    end

    -- Draw enemy info
    y = y + 8
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("ENEMY COMPOSITION:", self.PANEL_X + self.PADDING, y)

    y = y + self.LINE_HEIGHT
    love.graphics.setColor(0.9, 0.9, 0.9)

    local enemies = self.missionData.enemies or {}
    if #enemies == 0 then
        love.graphics.print("• Research mission (no combat expected)",
            self.PANEL_X + self.PADDING * 2, y)
        y = y + self.LINE_HEIGHT
    else
        for _, enemy in ipairs(enemies) do
            local count = enemy.count or 1
            local name = enemy.name or "Unknown"
            love.graphics.print(string.format("• %d× %s", count, name),
                self.PANEL_X + self.PADDING * 2, y)
            y = y + self.LINE_HEIGHT
        end
    end

    -- Draw location and time
    y = y + 8
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("MISSION DETAILS:", self.PANEL_X + self.PADDING, y)

    y = y + self.LINE_HEIGHT
    love.graphics.setColor(0.9, 0.9, 0.9)

    local location = self.missionData.location or "Unknown"
    love.graphics.print(string.format("Location: %s", location),
        self.PANEL_X + self.PADDING * 2, y)

    y = y + self.LINE_HEIGHT
    local timeOfDay = self.missionData.timeOfDay or "Day"
    love.graphics.print(string.format("Time: %s", timeOfDay),
        self.PANEL_X + self.PADDING * 2, y)

    -- Draw rewards
    y = y + self.LINE_HEIGHT * 1.5
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("REWARDS:", self.PANEL_X + self.PADDING, y)

    y = y + self.LINE_HEIGHT
    love.graphics.setColor(0.8, 0.9, 0.2)  -- Green for money

    local rewards = self.missionData.rewards or {}
    local funds = rewards.funds or 0
    local xp = rewards.xp or 0

    love.graphics.print(string.format("• Credits: %d", funds),
        self.PANEL_X + self.PADDING * 2, y)

    y = y + self.LINE_HEIGHT
    love.graphics.print(string.format("• Experience: %d XP", xp),
        self.PANEL_X + self.PADDING * 2, y)

    -- Draw buttons
    local buttonY = self.PANEL_Y + self.PANEL_HEIGHT - 40

    -- Accept button
    love.graphics.setColor(0.2, 0.6, 0.2, 0.8)
    love.graphics.rectangle("fill",
        self.PANEL_X + self.PADDING,
        buttonY,
        150, 32)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("ACCEPT MISSION",
        self.PANEL_X + self.PADDING + 8,
        buttonY + 6)

    -- Decline button
    love.graphics.setColor(0.6, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill",
        self.PANEL_X + self.PANEL_WIDTH - 150 - self.PADDING,
        buttonY,
        150, 32)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("DECLINE MISSION",
        self.PANEL_X + self.PANEL_WIDTH - 150 - self.PADDING + 8,
        buttonY + 6)
end

---Calculate difficulty rating from threat level
---@param threat number Threat level (0.0-1.0)
---@return number Difficulty rating (1-5)
function MissionBriefing:_calculateDifficulty(threat)
    if threat < 0.2 then return 1
    elseif threat < 0.4 then return 2
    elseif threat < 0.6 then return 3
    elseif threat < 0.8 then return 4
    else return 5
    end
end

---Get visual difficulty stars
---@return string Star string (⭐ repeated)
function MissionBriefing:_getDifficultyStars()
    return string.rep("⭐", self.difficultyRating)
end

---Get default mission for testing
---@return table Default mission data
function MissionBriefing:_getDefaultMission()
    return {
        id = "mission_default",
        name = "Research Expedition",
        type = "research",
        threatLevel = 0.2,
        location = "Unknown",
        timeOfDay = "Day",
        objectives = {"Complete research objectives"},
        enemies = {},
        rewards = { funds = 100, xp = 50 }
    }
end

---Handle mouse click for button interaction
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button (1=left, 2=right, 3=middle)
function MissionBriefing:mousepressed(x, y, button)
    if button ~= 1 then return end

    -- Accept button
    if x >= self.PANEL_X + self.PADDING and
       x <= self.PANEL_X + self.PADDING + 150 and
       y >= self.PANEL_Y + self.PANEL_HEIGHT - 40 and
       y <= self.PANEL_Y + self.PANEL_HEIGHT - 8 then

        print("[MissionBriefing] Mission accepted: " .. (self.missionData.id or "unnamed"))
        -- Transition to deployment screen with mission data
        -- Note: Actual state transition handled by StateManager
        return "accept"
    end

    -- Decline button
    if x >= self.PANEL_X + self.PANEL_WIDTH - 150 - self.PADDING and
       x <= self.PANEL_X + self.PANEL_WIDTH - self.PADDING and
       y >= self.PANEL_Y + self.PANEL_HEIGHT - 40 and
       y <= self.PANEL_Y + self.PANEL_HEIGHT - 8 then

        print("[MissionBriefing] Mission declined")
        -- Transition back to geoscape
        return "decline"
    end
end

return MissionBriefing

