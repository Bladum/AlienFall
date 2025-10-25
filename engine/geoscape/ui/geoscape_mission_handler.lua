--- Mission Click Handler & Acceptance Flow
-- Integrates mission selection with campaign manager
-- Handles player clicking on missions and transitioning to deployment
--
-- @module geoscape_mission_handler
-- @author AlienFall Team
-- @license MIT

local MissionHandler = {}

--- Initialize mission handler
-- @param geoscape_state GeoscapeState instance
-- @param integration CampaignGeoscapeIntegration instance
function MissionHandler:initialize(geoscape_state, integration)
    print("[MissionHandler] Initializing...")

    self.geoscape_state = geoscape_state or error("geoscape_state required")
    self.integration = integration or error("integration required")

    self.selected_mission_id = nil
    self.mission_details_visible = false

    print("[MissionHandler] Initialized")
    return self
end

--- Handle mission panel click
-- @param mission_id string mission identifier
function MissionHandler:onMissionClicked(mission_id)
    print("[MissionHandler] Mission clicked: " .. tostring(mission_id))

    self.selected_mission_id = mission_id
    self.mission_details_visible = true

    -- Get full mission details from campaign manager
    local mission = self.integration:getSelectedMissionDetails()

    if mission then
        print("[MissionHandler] Showing mission details for: " .. (mission.name or "Unknown"))
        self:_showMissionDetails(mission)
    end
end

--- Show mission details panel
-- @param mission table mission data
function MissionHandler:_showMissionDetails(mission)
    print("[MissionHandler] Displaying mission: " .. (mission.name or "Unknown"))

    -- This would integrate with mission_selection_ui.lua to show details
    -- For now, just track that we're showing details
    self.current_mission = mission
end

--- Accept mission and start deployment preparation
-- @return boolean success
function MissionHandler:acceptMission()
    if not self.selected_mission_id then return false end

    print("[MissionHandler] Accepting mission: " .. tostring(self.selected_mission_id))

    local success = self.integration:acceptMission(self.selected_mission_id)

    if success then
        print("[MissionHandler] Mission accepted")
        self:_transitionToDeployment()
        return true
    else
        print("[MissionHandler] Failed to accept mission")
        return false
    end
end

--- Decline mission
-- @return boolean success
function MissionHandler:declineMission()
    if not self.selected_mission_id then return false end

    print("[MissionHandler] Declining mission: " .. tostring(self.selected_mission_id))

    local success = self.integration:declineMission(self.selected_mission_id)

    if success then
        print("[MissionHandler] Mission declined")
        self.mission_details_visible = false
        self.selected_mission_id = nil
        return true
    end

    return false
end

--- Delay mission for later
-- @param days number days to delay (default 3)
-- @return boolean success
function MissionHandler:delayMission(days)
    if not self.selected_mission_id then return false end

    days = days or 3

    print("[MissionHandler] Delaying mission by " .. days .. " days")

    local success = self.integration:delayMission(self.selected_mission_id, days)

    if success then
        print("[MissionHandler] Mission delayed")
        self.mission_details_visible = false
        self.selected_mission_id = nil
        return true
    end

    return false
end

--- Transition to deployment screen
function MissionHandler:_transitionToDeployment()
    print("[MissionHandler] Transitioning to deployment...")

    local config = self.integration:prepareMissionDeployment(self.selected_mission_id)

    if not config then
        print("[MissionHandler] Failed to prepare mission for deployment")
        return false
    end

    print("[MissionHandler] Mission config prepared, ready for deployment")

    -- TODO: Transition to deployment_screen with config
    -- This would be handled by the main state manager

    return true
end

--- Update mission handler state
-- @param dt number delta time in seconds
function MissionHandler:update(dt)
    -- No continuous updates needed
end

--- Draw mission details if visible
function MissionHandler:draw()
    if not self.mission_details_visible or not self.current_mission then return end

    local mission = self.current_mission

    -- Draw mission details panel overlay
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 960, 720)

    -- Panel
    love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
    love.graphics.rectangle("fill", 150, 80, 660, 560)

    -- Border
    love.graphics.setColor(0.3, 0.6, 0.9, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", 150, 80, 660, 560)

    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.getFont())
    love.graphics.print("MISSION BRIEFING", 170, 100)

    -- Mission name
    love.graphics.setColor(0.7, 1, 0.7, 1)
    love.graphics.print(mission.name or "Unknown", 170, 140)

    -- Type and location
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print("Type: " .. (mission.mission_type or "Unknown"), 170, 170)
    love.graphics.print("Location: " .. (mission.location or "Unknown"), 170, 195)

    -- Threat level
    local threat = mission.threat_level or 5
    local threat_color = {1, 0.2, 0.2}
    if threat <= 3 then threat_color = {0.2, 1, 0.2}
    elseif threat <= 6 then threat_color = {1, 1, 0.2}
    elseif threat <= 8 then threat_color = {1, 0.6, 0.2}
    end

    love.graphics.setColor(threat_color[1], threat_color[2], threat_color[3], 1)
    love.graphics.print("Threat Level: " .. threat .. "/10", 170, 220)

    -- Description
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Objectives:", 170, 260)

    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print(mission.description or "No description available", 180, 285)

    -- Rewards
    love.graphics.setColor(0.7, 1, 0.7, 1)
    love.graphics.print("Rewards:", 170, 360)

    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print("Credits: " .. (mission.reward or 0), 180, 385)

    -- Buttons
    local button_y = 500

    -- Accept button
    love.graphics.setColor(0.2, 0.5, 0.2, 0.8)
    love.graphics.rectangle("fill", 200, button_y, 120, 40)
    love.graphics.setColor(0.5, 1, 0.5, 1)
    love.graphics.rectangle("line", 200, button_y, 120, 40)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Accept (A)", 210, button_y + 10)

    -- Decline button
    love.graphics.setColor(0.5, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", 380, button_y, 120, 40)
    love.graphics.setColor(1, 0.5, 0.5, 1)
    love.graphics.rectangle("line", 380, button_y, 120, 40)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Decline (D)", 390, button_y + 10)

    -- Delay button
    love.graphics.setColor(0.2, 0.2, 0.5, 0.8)
    love.graphics.rectangle("fill", 560, button_y, 120, 40)
    love.graphics.setColor(0.5, 0.5, 1, 1)
    love.graphics.rectangle("line", 560, button_y, 120, 40)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Delay (E)", 575, button_y + 10)

    -- Reset
    love.graphics.setColor(1, 1, 1, 1)
end

--- Handle keyboard input
-- @param key string key identifier
function MissionHandler:keypressed(key)
    if not self.mission_details_visible then return end

    if key == "a" then
        self:acceptMission()
    elseif key == "d" then
        self:declineMission()
    elseif key == "e" then
        self:delayMission()
    elseif key == "escape" then
        self.mission_details_visible = false
    end
end

--- Handle mouse click
-- @param x number mouse x
-- @param y number mouse y
-- @param button number mouse button
function MissionHandler:mousepressed(x, y, button)
    if not self.mission_details_visible or button ~= 1 then return end

    -- Accept button (200, 500, 120, 40)
    if x >= 200 and x <= 320 and y >= 500 and y <= 540 then
        self:acceptMission()
    -- Decline button (380, 500, 120, 40)
    elseif x >= 380 and x <= 500 and y >= 500 and y <= 540 then
        self:declineMission()
    -- Delay button (560, 500, 120, 40)
    elseif x >= 560 and x <= 680 and y >= 500 and y <= 540 then
        self:delayMission()
    end
end

--- Get currently selected mission
-- @return table mission data or nil
function MissionHandler:getSelectedMission()
    return self.current_mission
end

--- Check if mission details are visible
-- @return boolean visibility state
function MissionHandler:isMissionDetailsVisible()
    return self.mission_details_visible
end

--- Close mission details panel
function MissionHandler:closeMissionDetails()
    self.mission_details_visible = false
    self.selected_mission_id = nil
    self.current_mission = nil
end

--- Serialize handler state
-- @return table serialized state
function MissionHandler:serialize()
    return {
        selected_mission_id = self.selected_mission_id,
        mission_details_visible = self.mission_details_visible,
    }
end

--- Deserialize handler state
-- @param data table serialized state
function MissionHandler:deserialize(data)
    if not data then return end

    self.selected_mission_id = data.selected_mission_id
    self.mission_details_visible = data.mission_details_visible or false

    print("[MissionHandler] State restored")
end

return MissionHandler

