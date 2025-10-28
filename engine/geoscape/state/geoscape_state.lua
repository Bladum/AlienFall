--[[
  Geoscape State Manager

  Orchestrates all Phase 6 rendering and UI components for the strategic map view.
  Integrates: renderer, calendar display, mission panel, input handler, region detail, craft indicators.

  @module engine.geoscape.state.geoscape_state
  @author AI Assistant
  @license MIT
]]

local GeoscapeState = {}

--- Initialize geoscape state with all components
-- @param campaign table Campaign manager reference
-- @param world table World system reference
-- @return table Initialized geoscape state
function GeoscapeState:initialize(campaign, world)
  self.campaign = campaign
  self.world = world

  -- Screen dimensions
  self.screen_width = 1280
  self.screen_height = 720

  -- Load all Phase 6 modules
  local GeoscapeRenderer = require("engine.geoscape.rendering.geoscape_renderer")
  local CalendarDisplay = require("engine.geoscape.ui.calendar_display")
  local MissionFactionPanel = require("engine.geoscape.ui.mission_faction_panel")
  local GeoscapeInput = require("engine.geoscape.ui.geoscape_input")
  local RegionDetailPanel = require("engine.geoscape.ui.region_detail_panel")
  local CraftIndicators = require("engine.geoscape.ui.craft_indicators")

  -- Initialize calendar system (if not already done)
  local calendar = nil
  if campaign and campaign.calendar then
    calendar = campaign.calendar
  else
    local Calendar = require("engine.geoscape.systems.calendar")
    calendar = Calendar:initialize(1996, 1, 1)
  end
  self.calendar = calendar

  -- Initialize turn advancer (if not already done)
  local turn_advancer = nil
  if campaign and campaign.turn_advancer then
    turn_advancer = campaign.turn_advancer
  else
    local TurnAdvancer = require("engine.geoscape.systems.turn_advancer")
    turn_advancer = TurnAdvancer:initialize()
  end
  self.turn_advancer = turn_advancer

  -- Initialize all UI components
  self.renderer = GeoscapeRenderer:initialize(world, self.screen_width, self.screen_height)
  self.calendar_display = CalendarDisplay:initialize(calendar)
  self.mission_panel = MissionFactionPanel:initialize(campaign, nil)
  self.region_panel = RegionDetailPanel:initialize(world)
  self.craft_indicators = CraftIndicators:initialize(campaign, self.renderer)

  -- Initialize input with all panels for interaction detection
  local panels = {
    calendar_display = self.calendar_display,
    mission_faction_panel = self.mission_panel,
    region_detail_panel = self.region_panel,
    craft_indicators = self.craft_indicators
  }
  self.input_handler = GeoscapeInput:initialize(self.renderer, panels)

  -- Register callbacks with turn advancer
  self:registerCallbacks()

  return self
end

--- Register all callbacks with turn advancer
function GeoscapeState:registerCallbacks()
  if not self.turn_advancer then return end

  -- Calendar display updates on turn advance
  if self.calendar_display and self.calendar_display.registerCallbacks then
    self.calendar_display:registerCallbacks(self.turn_advancer)
  end

  -- Mission panel updates on turn advance
  if self.mission_panel and self.mission_panel.registerCallbacks then
    self.mission_panel:registerCallbacks(self.turn_advancer)
  end

  -- Craft indicators update on turn advance
  if self.craft_indicators and self.craft_indicators.registerCallbacks then
    self.craft_indicators:registerCallbacks(self.turn_advancer)
  end
end

--- Update all components
-- @param dt number Delta time
function GeoscapeState:update(dt)
  if self.renderer then
    self.renderer:update(dt)
  end

  if self.region_panel then
    self.region_panel:update(dt)
  end

  if self.input_handler then
    self.input_handler:update(dt)
  end
end

--- Draw all components
function GeoscapeState:draw()
  -- Draw map and renderer
  if self.renderer then
    self.renderer:draw()
  end

  -- Draw UI panels
  if self.calendar_display then
    self.calendar_display:draw()
  end

  if self.mission_panel then
    self.mission_panel:draw()
  end

  if self.region_panel then
    self.region_panel:draw()
  end

  -- Draw craft and UFO indicators
  if self.craft_indicators then
    self.craft_indicators:draw()
  end

  -- Draw input context menu (if visible)
  if self.input_handler then
    self.input_handler:drawContextMenu(self.screen_width, self.screen_height)
  end

  -- Draw debug info (optional)
  self:drawDebugInfo()
end

--- Draw debug information
function GeoscapeState:drawDebugInfo()
  love.graphics.setColor(0.5, 0.5, 0.5)

  local debug_y = self.screen_height - 40

  -- Show selected hex
  if self.input_handler and self.input_handler.selected_hex then
    local hex = self.input_handler.selected_hex
    love.graphics.printf("Selected: (" .. hex.q .. ", " .. hex.r .. ")",
      10, debug_y, 300, "left")
  end

  -- Show controls
  love.graphics.printf("Controls: Arrows=Pan | +/-=Zoom | M/C=Toggle | SPACE=Turn",
    10, debug_y + 15, 500, "left")
end

--- Handle mouse button press
-- @param x number Mouse x
-- @param y number Mouse y
-- @param button number Mouse button
function GeoscapeState:mousepressed(x, y, button)
  if self.input_handler then
    self.input_handler:mousepressed(x, y, button)
  end

  if self.mission_panel and self.mission_panel.mousepressed then
    self.mission_panel:mousepressed(x, y)
  end

  if self.region_panel and self.region_panel.mousepressed then
    self.region_panel:mousepressed(x, y, button)
  end
end

--- Handle mouse button release
-- @param x number Mouse x
-- @param y number Mouse y
-- @param button number Mouse button
function GeoscapeState:mousereleased(x, y, button)
  if self.input_handler then
    self.input_handler:mousereleased(x, y, button)
  end

  if self.region_panel and self.region_panel.mousereleased then
    self.region_panel:mousereleased(x, y, button)
  end
end

--- Handle mouse movement
-- @param x number Mouse x
-- @param y number Mouse y
-- @param dx number Delta x
-- @param dy number Delta y
function GeoscapeState:mousemoved(x, y, dx, dy)
  if self.input_handler then
    self.input_handler:mousemoved(x, y, dx, dy)
  end

  if self.region_panel and self.region_panel.mousemoved then
    self.region_panel:mousemoved(x, y)
  end
end

--- Handle keyboard input
-- @param key string Key pressed
function GeoscapeState:keypressed(key)
  if self.input_handler then
    self.input_handler:keypressed(key)
  end

  if self.mission_panel and self.mission_panel.keypressed then
    self.mission_panel:keypressed(key)
  end

  -- Handle global geoscape commands
  if key == "return" or key == "space" then
    self:advanceTurn()
  end
end

--- Advance turn through all systems
function GeoscapeState:advanceTurn()
  if not self.turn_advancer then return end

  -- Run turn advancement
  self.turn_advancer:advanceTurn()
end

--- Get current date
-- @return string Formatted date string
function GeoscapeState:getDateString()
  if self.calendar then
    local month_names = {
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    }

    local year = self.calendar:getYear()
    local month = self.calendar:getMonth()
    local day = self.calendar:getDay()

    return string.format("%s %d, %d", month_names[month], day, year)
  end

  return "Unknown Date"
end

--- Serialize state for saving
-- @return table Serializable state
function GeoscapeState:serialize()
  return {
    calendar = self.calendar and self.calendar:serialize() or nil,
    turn_advancer = self.turn_advancer and self.turn_advancer:serialize() or nil,
    renderer = self.renderer and self.renderer:serialize() or nil,
    calendar_display = self.calendar_display and self.calendar_display:serialize() or nil,
    mission_panel = self.mission_panel and self.mission_panel:serialize() or nil,
    region_panel = self.region_panel and self.region_panel:serialize() or nil,
    input_handler = self.input_handler and self.input_handler:serialize() or nil
  }
end

--- Deserialize state from save
-- @param state table Saved state
function GeoscapeState:deserialize(state)
  if not state then return end

  if state.calendar and self.calendar then
    self.calendar:deserialize(state.calendar)
  end

  if state.turn_advancer and self.turn_advancer then
    self.turn_advancer:deserialize(state.turn_advancer)
  end

  if state.renderer and self.renderer then
    self.renderer:deserialize(state.renderer)
  end

  if state.calendar_display and self.calendar_display then
    self.calendar_display:deserialize(state.calendar_display)
  end

  if state.mission_panel and self.mission_panel then
    self.mission_panel:deserialize(state.mission_panel)
  end

  if state.region_panel and self.region_panel then
    self.region_panel:deserialize(state.region_panel)
  end

  if state.input_handler and self.input_handler then
    self.input_handler:deserialize(state.input_handler)
  end
end

return GeoscapeState

