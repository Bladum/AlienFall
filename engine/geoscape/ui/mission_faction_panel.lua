--[[
  Mission & Faction Panel UI Component

  Displays active missions and faction status with threat levels.
  Located in bottom-left corner, scrollable with PageUp/PageDown.

  @module engine.geoscape.ui.mission_faction_panel
  @author AI Assistant
  @license MIT
]]

local MissionFactionPanel = {}

--- Initialize mission and faction panel
-- @param campaign table Campaign manager reference
-- @param event_scheduler table Event scheduler reference (optional)
-- @return table Initialized panel
function MissionFactionPanel:initialize(campaign, event_scheduler)
  self.campaign = campaign
  self.event_scheduler = event_scheduler

  -- Position and size
  self.x = 10
  self.y = 300
  self.width = 200
  self.height = 250

  -- Scrolling
  self.scroll_offset = 0
  self.visible_items = 8

  -- Colors
  self.background_color = {0.1, 0.1, 0.15, 0.8}
  self.text_color = {1, 1, 1}
  self.threat_colors = {
    low = {0.2, 0.9, 0.2},      -- Green
    medium = {0.9, 0.9, 0.2},   -- Yellow
    high = {0.9, 0.5, 0.2},     -- Orange
    critical = {0.9, 0.2, 0.2}  -- Red
  }

  -- Display data
  self.missions = {}
  self.factions = {}
  self.selected_mission = nil

  -- Update display
  self:updateMissions()
  self:updateFactions()

  return self
end

--- Update mission list from campaign
function MissionFactionPanel:updateMissions()
  self.missions = {}

  if not self.campaign or not self.campaign.missions then
    return
  end

  -- Get active missions (first 10)
  local count = 0
  for i, mission in ipairs(self.campaign.missions) do
    if mission and mission.active ~= false and count < 10 then
      table.insert(self.missions, {
        id = i,
        name = mission.name or "Unknown Mission",
        type = mission.type or "UNKNOWN",
        location = mission.location or "Unknown",
        turns_remaining = mission.turns_remaining or 0,
        threat = mission.threat or "medium",
        status = mission.status or "active"
      })
      count = count + 1
    end
  end
end

--- Update faction list from campaign
function MissionFactionPanel:updateFactions()
  self.factions = {}

  if not self.campaign or not self.campaign.factions then
    return
  end

  -- Get faction status (first 5)
  local count = 0
  for name, faction in pairs(self.campaign.factions) do
    if faction and count < 5 then
      table.insert(self.factions, {
        name = name,
        activity = faction.activity_level or 0.5,
        threat = faction.threat_level or "medium",
        standing = faction.standing or 0
      })
      count = count + 1
    end
  end

  -- Sort by threat level
  table.sort(self.factions, function(a, b)
    local threat_order = {critical = 4, high = 3, medium = 2, low = 1}
    return (threat_order[a.threat] or 0) > (threat_order[b.threat] or 0)
  end)
end

--- Draw the mission and faction panel
function MissionFactionPanel:draw()
  -- Draw background panel
  love.graphics.setColor(self.background_color)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

  -- Draw border
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

  -- Draw title
  love.graphics.setColor(0.7, 1, 0.7)
  love.graphics.printf("Missions & Factions", self.x, self.y + 5, self.width, "center")

  -- Draw separator line
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.line(self.x + 5, self.y + 22, self.x + self.width - 5, self.y + 22)

  -- Draw missions section
  local current_y = self.y + 28
  local mission_count = 3

  love.graphics.setColor(0.8, 0.8, 1)
  love.graphics.printf("Missions (" .. #self.missions .. ")",
    self.x + 5, current_y, self.width - 10, "left")
  current_y = current_y + 15

  -- Draw mission list (scrollable)
  for i = self.scroll_offset + 1, math.min(self.scroll_offset + mission_count, #self.missions) do
    local mission = self.missions[i]
    self:drawMissionItem(mission, current_y, i == self.selected_mission)
    current_y = current_y + 35
  end

  -- Draw factions section
  current_y = current_y + 10
  love.graphics.setColor(0.8, 1, 0.8)
  love.graphics.printf("Factions (" .. #self.factions .. ")",
    self.x + 5, current_y, self.width - 10, "left")
  current_y = current_y + 15

  -- Draw faction list
  for i, faction in ipairs(self.factions) do
    if i > 3 then break end  -- Show max 3 factions
    self:drawFactionItem(faction, current_y)
    current_y = current_y + 20
  end

  -- Draw scroll indicator
  if #self.missions > mission_count then
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("▲ ▼ to scroll", self.x, self.y + self.height - 20, self.width, "center")
  end
end

--- Draw a single mission item
-- @param mission table Mission data
-- @param y number Y position on screen
-- @param selected boolean Whether this mission is selected
function MissionFactionPanel:drawMissionItem(mission, y, selected)
  -- Draw selection highlight
  if selected then
    love.graphics.setColor(0.3, 0.3, 0.5)
    love.graphics.rectangle("fill", self.x + 2, y - 2, self.width - 4, 32)
  end

  -- Draw threat indicator
  local threat_color = self.threat_colors[mission.threat] or {1, 1, 1}
  love.graphics.setColor(threat_color)
  love.graphics.rectangle("fill", self.x + 5, y, 3, 12)

  -- Draw mission name
  love.graphics.setColor(self.text_color)
  love.graphics.printf(mission.name, self.x + 12, y, self.width - 17, "left")

  -- Draw mission turns remaining
  love.graphics.setColor(0.9, 0.9, 0.5)
  love.graphics.printf("T:" .. mission.turns_remaining,
    self.x + 140, y, 50, "right")

  -- Draw mission type (smaller text)
  love.graphics.setColor(0.6, 0.6, 0.6)
  love.graphics.printf(mission.type, self.x + 12, y + 15, self.width - 17, "left")
end

--- Draw a single faction item
-- @param faction table Faction data
-- @param y number Y position on screen
function MissionFactionPanel:drawFactionItem(faction, y)
  -- Faction name with threat color
  local threat_color = self.threat_colors[faction.threat] or {1, 1, 1}
  love.graphics.setColor(threat_color)
  love.graphics.printf(faction.name, self.x + 5, y, self.width - 10, "left")

  -- Activity bar
  local bar_width = self.width - 10
  local bar_height = 4

  -- Background
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", self.x + 5, y + 10, bar_width, bar_height)

  -- Fill (activity level)
  local fill_width = bar_width * math.max(0, math.min(1, faction.activity))
  love.graphics.setColor(threat_color)
  love.graphics.rectangle("fill", self.x + 5, y + 10, fill_width, bar_height)

  -- Border
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle("line", self.x + 5, y + 10, bar_width, bar_height)
end

--- Handle mouse click to select mission
-- @param mouse_x number Mouse x position
-- @param mouse_y number Mouse y position
function MissionFactionPanel:mousepressed(mouse_x, mouse_y)
  -- Check if click is in panel bounds
  if mouse_x < self.x or mouse_x > self.x + self.width or
     mouse_y < self.y or mouse_y > self.y + self.height then
    return
  end

  -- Determine which mission was clicked
  local mission_start_y = self.y + 43
  local mission_height = 35
  local mission_count = 3

  for i = self.scroll_offset + 1, math.min(self.scroll_offset + mission_count, #self.missions) do
    local item_y = mission_start_y + (i - self.scroll_offset - 1) * mission_height

    if mouse_y >= item_y and mouse_y < item_y + mission_height then
      self.selected_mission = i
      return
    end
  end
end

--- Handle keyboard input (PageUp/PageDown for scrolling)
-- @param key string Key pressed
function MissionFactionPanel:keypressed(key)
  if key == "pageup" then
    self.scroll_offset = math.max(0, self.scroll_offset - 3)
  elseif key == "pagedown" then
    local max_offset = math.max(0, #self.missions - 3)
    self.scroll_offset = math.min(max_offset, self.scroll_offset + 3)
  end
end

--- Called when turn advances to update mission progress
function MissionFactionPanel:onTurnAdvance()
  self:updateMissions()
  self:updateFactions()
end

--- Register callbacks with turn advancer
-- @param turn_advancer table TurnAdvancer system reference
function MissionFactionPanel:registerCallbacks(turn_advancer)
  if turn_advancer then
    turn_advancer:registerPostTurnCallback(function()
      self:onTurnAdvance()
    end)
  end
end

--- Get currently selected mission (for details panel interaction)
-- @return table Mission data or nil
function MissionFactionPanel:getSelectedMission()
  if self.selected_mission and self.missions[self.selected_mission] then
    return self.missions[self.selected_mission]
  end
  return nil
end

--- Serialize state for saving
-- @return table Serializable state
function MissionFactionPanel:serialize()
  return {
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height,
    scroll_offset = self.scroll_offset,
    selected_mission = self.selected_mission
  }
end

--- Deserialize state from save
-- @param state table Saved state
function MissionFactionPanel:deserialize(state)
  if state then
    self.x = state.x or self.x
    self.y = state.y or self.y
    self.width = state.width or self.width
    self.height = state.height or self.height
    self.scroll_offset = state.scroll_offset or 0
    self.selected_mission = state.selected_mission
  end
  self:updateMissions()
  self:updateFactions()
end

return MissionFactionPanel

