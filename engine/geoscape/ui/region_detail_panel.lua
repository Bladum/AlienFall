--[[
  Region Detail Panel UI Component

  Displays information about selected region (biome, control, resources, stability).
  Located in top-right corner, auto-closes after 5 seconds if not interacted.
  Draggable for repositioning.

  @module engine.geoscape.ui.region_detail_panel
  @author AI Assistant
  @license MIT
]]

local RegionDetailPanel = {}

--- Initialize region detail panel
-- @param world table World system reference
-- @return table Initialized panel
function RegionDetailPanel:initialize(world)
  self.world = world

  -- Position and size
  self.x = 1080
  self.y = 10
  self.width = 190
  self.height = 120

  -- Display state
  self.visible = false
  self.auto_close_timer = 0
  self.auto_close_threshold = 5.0  -- 5 seconds

  -- Dragging
  self.is_dragging = false
  self.drag_offset_x = 0
  self.drag_offset_y = 0

  -- Region data
  self.current_region = nil

  -- Colors
  self.background_color = {0.1, 0.1, 0.15, 0.85}
  self.text_color = {1, 1, 1}
  self.control_colors = {
    neutral = {0.6, 0.6, 0.6},
    player = {0.2, 0.8, 0.2},
    alien = {0.9, 0.2, 0.2},
    faction = {0.5, 0.5, 0.9}
  }

  return self
end

--- Show region information
-- @param hex table Hex coordinate {q, r}
function RegionDetailPanel:showRegion(hex)
  if not hex then
    self:hide()
    return
  end

  -- Get region data from world
  local region = nil
  if self.world and self.world.getProvinceAt then
    region = self.world:getProvinceAt(hex.q, hex.r)
  end

  -- If no region found, create placeholder
  if not region then
    region = {
      q = hex.q,
      r = hex.r,
      name = string.format("Region (%d, %d)", hex.q, hex.r),
      biome = "unknown",
      control = "neutral",
      resources = 0,
      stability = 50
    }
  end

  self.current_region = region
  self.visible = true
  self.auto_close_timer = 0  -- Reset timer on interaction
end

--- Hide the panel
function RegionDetailPanel:hide()
  self.visible = false
  self.current_region = nil
  self.auto_close_timer = 0
end

--- Update panel state
-- @param dt number Delta time
function RegionDetailPanel:update(dt)
  if not self.visible then return end

  -- Update auto-close timer
  self.auto_close_timer = self.auto_close_timer + dt
  if self.auto_close_timer > self.auto_close_threshold then
    self:hide()
  end
end

--- Draw the region detail panel
function RegionDetailPanel:draw()
  if not self.visible or not self.current_region then
    return
  end

  -- Draw background panel
  love.graphics.setColor(self.background_color)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

  -- Draw border
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

  -- Draw title bar
  love.graphics.setColor(0.2, 0.2, 0.3)
  love.graphics.rectangle("fill", self.x, self.y, self.width, 18)

  -- Draw region name in title
  love.graphics.setColor(0.7, 1, 0.7)
  love.graphics.setFont(love.graphics.getFont())
  local name = self.current_region.name or "Unknown Region"
  if #name > 20 then
    name = name:sub(1, 17) .. "..."
  end
  love.graphics.printf(name, self.x + 3, self.y + 2, self.width - 6, "left")

  -- Close button
  love.graphics.setColor(0.9, 0.3, 0.3)
  love.graphics.printf("×", self.x + self.width - 15, self.y + 1, 12, "center")

  local current_y = self.y + 22

  -- Biome
  self:drawInfoLine("Biome:", self:formatBiome(self.current_region.biome), current_y)
  current_y = current_y + 16

  -- Control status with color indicator
  local control = self.current_region.control or "neutral"
  local control_color = self.control_colors[control] or {1, 1, 1}

  -- Draw control indicator dot
  love.graphics.setColor(control_color)
  love.graphics.circle("fill", self.x + 7, current_y + 5, 3)

  -- Draw control label
  love.graphics.setColor(self.text_color)
  love.graphics.printf("Control:", self.x + 15, current_y, 50, "left")
  love.graphics.printf(self:formatControl(control), self.x + 65, current_y, self.width - 70, "left")
  current_y = current_y + 16

  -- Resources
  self:drawInfoLine("Resources:", self:formatResources(self.current_region.resources), current_y)
  current_y = current_y + 16

  -- Stability bar
  self:drawStabilityBar(current_y)
end

--- Draw a single info line
-- @param label string Label text
-- @param value string Value text
-- @param y number Y position
function RegionDetailPanel:drawInfoLine(label, value, y)
  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.printf(label, self.x + 5, y, 60, "left")

  love.graphics.setColor(self.text_color)
  love.graphics.printf(value, self.x + 70, y, self.width - 75, "left")
end

--- Draw stability bar
-- @param y number Y position
function RegionDetailPanel:drawStabilityBar(y)
  local bar_width = self.width - 10
  local bar_height = 8

  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.printf("Stability:", self.x + 5, y - 2, 60, "left")

  -- Background bar
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", self.x + 70, y - 2, bar_width - 65, bar_height)

  -- Stability value (0-100)
  local stability = self.current_region.stability or 50
  stability = math.max(0, math.min(100, stability))

  -- Color based on stability
  if stability > 70 then
    love.graphics.setColor(0.2, 0.8, 0.2)  -- Green
  elseif stability > 40 then
    love.graphics.setColor(0.8, 0.8, 0.2)  -- Yellow
  else
    love.graphics.setColor(0.8, 0.2, 0.2)  -- Red
  end

  -- Fill bar
  local fill_width = (bar_width - 65) * (stability / 100)
  love.graphics.rectangle("fill", self.x + 70, y - 2, fill_width, bar_height)

  -- Border
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle("line", self.x + 70, y - 2, bar_width - 65, bar_height)

  -- Value percentage
  love.graphics.setColor(self.text_color)
  love.graphics.printf(stability .. "%", self.x + self.width - 30, y - 3, 25, "right")
end

--- Handle mouse press (for dragging or close button)
-- @param x number Mouse x
-- @param y number Mouse y
-- @param button number Mouse button
function RegionDetailPanel:mousepressed(x, y, button)
  if not self.visible then return end

  -- Reset auto-close timer on interaction
  self.auto_close_timer = 0

  -- Check close button
  if self:pointInRect(x, y, self.x + self.width - 15, self.y + 1, 12, 14) then
    self:hide()
    return
  end

  -- Check if click is in title bar (for dragging)
  if self:pointInRect(x, y, self.x, self.y, self.width, 18) then
    self.is_dragging = true
    self.drag_offset_x = x - self.x
    self.drag_offset_y = y - self.y
  end
end

--- Handle mouse release
-- @param x number Mouse x
-- @param y number Mouse y
-- @param button number Mouse button
function RegionDetailPanel:mousereleased(x, y, button)
  self.is_dragging = false
end

--- Handle mouse movement (for dragging)
-- @param x number Mouse x
-- @param y number Mouse y
function RegionDetailPanel:mousemoved(x, y)
  if not self.visible or not self.is_dragging then return end

  self.x = x - self.drag_offset_x
  self.y = y - self.drag_offset_y
end

--- Helper: Check if point is in rectangle
-- @param x number Point x
-- @param y number Point y
-- @param rect_x number Rectangle x
-- @param rect_y number Rectangle y
-- @param rect_w number Rectangle width
-- @param rect_h number Rectangle height
-- @return boolean True if point is in rectangle
function RegionDetailPanel:pointInRect(x, y, rect_x, rect_y, rect_w, rect_h)
  return x >= rect_x and x <= rect_x + rect_w and
         y >= rect_y and y <= rect_y + rect_h
end

--- Format biome name for display
-- @param biome string Biome type
-- @return string Formatted biome name
function RegionDetailPanel:formatBiome(biome)
  if biome == "grassland" then return "Grassland"
  elseif biome == "forest" then return "Forest"
  elseif biome == "mountain" then return "Mountain"
  elseif biome == "ocean" then return "Ocean"
  elseif biome == "desert" then return "Desert"
  else return "Unknown" end
end

--- Format control status for display
-- @param control string Control type
-- @return string Formatted control status
function RegionDetailPanel:formatControl(control)
  if control == "neutral" then return "Neutral"
  elseif control == "player" then return "Player"
  elseif control == "alien" then return "Alien"
  elseif control == "faction" then return "Faction"
  else return "Unknown" end
end

--- Format resources for display
-- @param resources number Resource value
-- @return string Formatted resources
function RegionDetailPanel:formatResources(resources)
  if resources == 0 then return "None"
  elseif resources < 3 then return "Low"
  elseif resources < 6 then return "Medium"
  else return "High" end
end

--- Serialize state for saving
-- @return table Serializable state
function RegionDetailPanel:serialize()
  return {
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height,
    visible = self.visible
  }
end

--- Deserialize state from save
-- @param state table Saved state
function RegionDetailPanel:deserialize(state)
  if state then
    self.x = state.x or self.x
    self.y = state.y or self.y
    self.width = state.width or self.width
    self.height = state.height or self.height
    self.visible = state.visible or false
  end
end

return RegionDetailPanel

