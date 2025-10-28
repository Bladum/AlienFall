--[[
  Geoscape Input Handler

  Handles mouse and keyboard input for the geoscape map.
  Manages hex selection, panning, zooming, and UI interactions.

  @module engine.geoscape.ui.geoscape_input
  @author AI Assistant
  @license MIT
]]

local GeoscapeInput = {}

--- Initialize input handler
-- @param renderer table GeoscapeRenderer reference
-- @param panels table UI panels table {calendar_display, mission_faction_panel, region_detail_panel, craft_indicators}
-- @return table Initialized input handler
function GeoscapeInput:initialize(renderer, panels)
  self.renderer = renderer
  self.panels = panels or {}

  -- Input state
  self.selected_hex = nil
  self.right_click_menu_visible = false
  self.right_click_position = {x = 0, y = 0}

  -- Context menu options
  self.context_menu_options = {}

  -- Input modes
  self.input_mode = "normal"  -- normal, selecting, panning
  self.last_mouse_x = 0
  self.last_mouse_y = 0
  self.pan_start_x = 0
  self.pan_start_y = 0

  -- Double-click detection
  self.last_click_time = 0
  self.last_click_hex = nil
  self.double_click_threshold = 0.3  -- seconds

  return self
end

--- Handle mouse button press
-- @param x number Mouse x
-- @param y number Mouse y
-- @param button number Mouse button (1=left, 2=right, 3=middle)
function GeoscapeInput:mousepressed(x, y, button)
  self.last_mouse_x = x
  self.last_mouse_y = y

  if button == 1 then
    -- Left click on map
    self:handleLeftClick(x, y)
  elseif button == 2 then
    -- Middle click for panning
    self.input_mode = "panning"
    self.pan_start_x = x
    self.pan_start_y = y
  elseif button == 3 then
    -- Right click for context menu
    self:handleRightClick(x, y)
  end
end

--- Handle mouse button release
-- @param x number Mouse x
-- @param y number Mouse y
-- @param button number Mouse button
function GeoscapeInput:mousereleased(x, y, button)
  if button == 2 then
    -- End panning
    self.input_mode = "normal"
  end
end

--- Handle mouse movement
-- @param x number Mouse x
-- @param y number Mouse y
-- @param dx number Delta x
-- @param dy number Delta y
function GeoscapeInput:mousemoved(x, y, dx, dy)
  self.last_mouse_x = x
  self.last_mouse_y = y

  if self.input_mode == "panning" then
    -- Pan map during middle mouse drag
    self.renderer:pan(-dx, -dy)
  end
end

--- Handle left mouse click on map
-- @param x number Mouse x
-- @param y number Mouse y
function GeoscapeInput:handleLeftClick(x, y)
  -- Check if click hit a UI panel first
  if self.panels.calendar_display and
     self:pointInRect(x, y, self.panels.calendar_display.x, self.panels.calendar_display.y,
                       self.panels.calendar_display.width, self.panels.calendar_display.height) then
    return
  end

  if self.panels.mission_faction_panel and
     self:pointInRect(x, y, self.panels.mission_faction_panel.x, self.panels.mission_faction_panel.y,
                       self.panels.mission_faction_panel.width, self.panels.mission_faction_panel.height) then
    if self.panels.mission_faction_panel.mousepressed then
      self.panels.mission_faction_panel:mousepressed(x, y)
    end
    return
  end

  if self.panels.region_detail_panel and
     self:pointInRect(x, y, self.panels.region_detail_panel.x, self.panels.region_detail_panel.y,
                       self.panels.region_detail_panel.width, self.panels.region_detail_panel.height) then
    return
  end

  -- Get hex under cursor
  local hex = self.renderer:getHexUnderMouse(x, y)

  if hex then
    -- Check for double-click
    local current_time = love.timer.getTime()
    local time_since_last = current_time - self.last_click_time

    if self.last_click_hex and
       self.last_click_hex.q == hex.q and
       self.last_click_hex.r == hex.r and
       time_since_last < self.double_click_threshold then
      -- Double click
      self:handleDoubleClick(hex)
    else
      -- Single click
      self:selectHex(hex)
    end

    self.last_click_time = current_time
    self.last_click_hex = hex
  else
    -- Deselect
    self:selectHex(nil)
  end

  -- Close context menu on click
  self.right_click_menu_visible = false
end

--- Handle right mouse click (context menu)
-- @param x number Mouse x
-- @param y number Mouse y
function GeoscapeInput:handleRightClick(x, y)
  -- Get hex under cursor
  local hex = self.renderer:getHexUnderMouse(x, y)

  if hex then
    self.right_click_menu_visible = true
    self.right_click_position = {x = x, y = y}

    -- Build context menu options
    self:buildContextMenu(hex)
  else
    self.right_click_menu_visible = false
  end
end

--- Build context menu for hex
-- @param hex table Hex coordinate {q, r}
function GeoscapeInput:buildContextMenu(hex)
  self.context_menu_options = {
    {label = "Send Craft Here", action = "send_craft"},
    {label = "View Details", action = "view_details"},
    {label = "View Missions", action = "view_missions"},
    {label = "Scout Region", action = "scout"}
  }
end

--- Select a hex (show region details)
-- @param hex table Hex coordinate {q, r} or nil to deselect
function GeoscapeInput:selectHex(hex)
  self.selected_hex = hex

  -- Notify region detail panel
  if self.panels.region_detail_panel then
    if hex then
      self.panels.region_detail_panel:showRegion(hex)
    else
      self.panels.region_detail_panel:hide()
    end
  end
end

--- Handle double-click (zoom to hex or show details)
-- @param hex table Hex coordinate {q, r}
function GeoscapeInput:handleDoubleClick(hex)
  -- Zoom map to selected hex
  self.renderer.camera_x = hex.q
  self.renderer.camera_y = hex.r

  print("[GeoscapeInput] Double-click zoom to hex: ", hex.q, hex.r)
end

--- Handle keyboard input
-- @param key string Key pressed
function GeoscapeInput:keypressed(key)
  if key == "escape" then
    -- Deselect hex and close menus
    self:selectHex(nil)
    self.right_click_menu_visible = false

  elseif key == "m" then
    -- Toggle mission panel
    if self.panels.mission_faction_panel then
      self.panels.mission_faction_panel.visible = not self.panels.mission_faction_panel.visible
    end

  elseif key == "c" then
    -- Toggle calendar
    if self.panels.calendar_display then
      self.panels.calendar_display.visible = not self.panels.calendar_display.visible
    end

  elseif key == "space" then
    -- Advance turn
    print("[GeoscapeInput] Space: Advance turn")

  elseif key == "pageup" or key == "pagedown" then
    -- Delegate to mission panel for scrolling
    if self.panels.mission_faction_panel and self.panels.mission_faction_panel.keypressed then
      self.panels.mission_faction_panel:keypressed(key)
    end

  elseif key == "tab" then
    -- Cycle selected hex between nearby hexes
    if self.selected_hex then
      self:selectNextHex()
    end
  end
end

--- Cycle to next nearby hex (with Tab key)
function GeoscapeInput:selectNextHex()
  if not self.selected_hex then return end

  local q, r = self.selected_hex.q, self.selected_hex.r

  -- Cycle through adjacent hexes
  local neighbors = {
    {q + 1, r},
    {q - 1, r},
    {q, r + 1},
    {q, r - 1},
    {q + 1, r - 1},
    {q - 1, r + 1}
  }

  -- For now, just select the first neighbor (could track and cycle)
  if neighbors[1] then
    self:selectHex({q = neighbors[1][1], r = neighbors[1][2]})
  end
end

--- Draw context menu
-- @param screen_width number Screen width
-- @param screen_height number Screen height
function GeoscapeInput:drawContextMenu(screen_width, screen_height)
  if not self.right_click_menu_visible then return end

  local menu_width = 150
  local menu_height = 25 + #self.context_menu_options * 20

  local menu_x = self.right_click_position.x
  local menu_y = self.right_click_position.y

  -- Keep menu on screen
  if menu_x + menu_width > screen_width then
    menu_x = screen_width - menu_width - 5
  end
  if menu_y + menu_height > screen_height then
    menu_y = screen_height - menu_height - 5
  end

  -- Draw background
  love.graphics.setColor(0.15, 0.15, 0.2, 0.95)
  love.graphics.rectangle("fill", menu_x, menu_y, menu_width, menu_height)

  -- Draw border
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle("line", menu_x, menu_y, menu_width, menu_height)

  -- Draw options
  local option_y = menu_y + 5
  for i, option in ipairs(self.context_menu_options) do
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(option.label, menu_x + 5, option_y, menu_width - 10, "left")
    option_y = option_y + 20
  end
end

--- Update input state
-- @param dt number Delta time
function GeoscapeInput:update(dt)
  -- Update based on current input mode
  -- Could handle continuous input like held keys
end

--- Helper: Check if point is in rectangle
-- @param x number Point x
-- @param y number Point y
-- @param rect_x number Rectangle x
-- @param rect_y number Rectangle y
-- @param rect_w number Rectangle width
-- @param rect_h number Rectangle height
-- @return boolean True if point is in rectangle
function GeoscapeInput:pointInRect(x, y, rect_x, rect_y, rect_w, rect_h)
  return x >= rect_x and x <= rect_x + rect_w and
         y >= rect_y and y <= rect_y + rect_h
end

--- Serialize state for saving
-- @return table Serializable state
function GeoscapeInput:serialize()
  return {
    input_mode = self.input_mode,
    selected_hex = self.selected_hex
  }
end

--- Deserialize state from save
-- @param state table Saved state
function GeoscapeInput:deserialize(state)
  if state then
    self.input_mode = state.input_mode or "normal"
    self.selected_hex = state.selected_hex
  end
end

return GeoscapeInput

