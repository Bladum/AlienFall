--[[
  Craft Indicators UI Component

  Displays craft locations on the geoscape map with health bars.
  Shows UFO positions and base locations with facility counts.

  @module engine.geoscape.ui.craft_indicators
  @author AI Assistant
  @license MIT
]]

local CraftIndicators = {}

--- Initialize craft indicators
-- @param campaign table Campaign manager reference
-- @param renderer table GeoscapeRenderer reference
-- @return table Initialized indicators
function CraftIndicators:initialize(campaign, renderer)
  self.campaign = campaign
  self.renderer = renderer

  -- Display data
  self.player_crafts = {}
  self.ufos = {}
  self.bases = {}

  -- Visual settings
  self.craft_color = {0.2, 0.8, 0.2}    -- Green
  self.ufo_color = {0.9, 0.2, 0.2}      -- Red
  self.base_color = {0.9, 0.9, 0.2}     -- Yellow

  self.indicator_size = 6
  self.health_bar_height = 3

  -- Update data
  self:updateIndicators()

  return self
end

--- Update craft and UFO positions from campaign
function CraftIndicators:updateIndicators()
  self.player_crafts = {}
  self.ufos = {}
  self.bases = {}

  if not self.campaign then return end

  -- Get player crafts
  if self.campaign.crafts then
    for i, craft in ipairs(self.campaign.crafts) do
      if craft and craft.location then
        table.insert(self.player_crafts, {
          id = i,
          name = craft.name or ("Craft " .. i),
          location = craft.location,
          health = craft.health or 100,
          max_health = craft.max_health or 100,
          status = craft.status or "ready"
        })
      end
    end
  end

  -- Get UFO positions
  if self.campaign.ufos then
    for i, ufo in ipairs(self.campaign.ufos) do
      if ufo and ufo.location and ufo.active ~= false then
        table.insert(self.ufos, {
          id = i,
          name = ufo.type or "UFO",
          location = ufo.location,
          threat = ufo.threat or "medium",
          health = ufo.health or 50,
          max_health = ufo.max_health or 100
        })
      end
    end
  end

  -- Get base locations
  if self.campaign.bases then
    for i, base in ipairs(self.campaign.bases) do
      if base and base.location then
        local facility_count = 0
        if base.facilities then
          for _, facility in ipairs(base.facilities) do
            if facility and facility.built then
              facility_count = facility_count + 1
            end
          end
        end

        table.insert(self.bases, {
          id = i,
          name = base.name or ("Base " .. i),
          location = base.location,
          facilities = facility_count
        })
      end
    end
  end
end

--- Draw all craft indicators on map
function CraftIndicators:draw()
  -- Draw player crafts (green circles)
  for _, craft in ipairs(self.player_crafts) do
    self:drawCraftIndicator(craft)
  end

  -- Draw UFOs (red triangles)
  for _, ufo in ipairs(self.ufos) do
    self:drawUFOIndicator(ufo)
  end

  -- Draw bases (yellow squares)
  for _, base in ipairs(self.bases) do
    self:drawBaseIndicator(base)
  end
end

--- Draw a single craft indicator
-- @param craft table Craft data
function CraftIndicators:drawCraftIndicator(craft)
  local x, y = self:getIndicatorPixelPosition(craft.location)

  if not x or not y then return end

  -- Draw main circle
  love.graphics.setColor(self.craft_color)
  love.graphics.circle("fill", x, y, self.indicator_size)

  -- Draw border
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.circle("line", x, y, self.indicator_size)

  -- Draw health bar above
  self:drawHealthBar(x, y, craft.health, craft.max_health)

  -- Draw status indicator
  if craft.status == "damaged" then
    love.graphics.setColor(0.9, 0.5, 0.2)
    love.graphics.circle("line", x, y, self.indicator_size + 2)
  end
end

--- Draw a single UFO indicator
-- @param ufo table UFO data
function CraftIndicators:drawUFOIndicator(ufo)
  local x, y = self:getIndicatorPixelPosition(ufo.location)

  if not x or not y then return end

  -- Draw triangle (UFO shape)
  love.graphics.setColor(self.ufo_color)
  local size = self.indicator_size + 2
  local tri_x1 = x
  local tri_y1 = y - size
  local tri_x2 = x - size
  local tri_y2 = y + size / 2
  local tri_x3 = x + size
  local tri_y3 = y + size / 2

  love.graphics.polygon("fill", tri_x1, tri_y1, tri_x2, tri_y2, tri_x3, tri_y3)

  -- Draw border
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.polygon("line", tri_x1, tri_y1, tri_x2, tri_y2, tri_x3, tri_y3)

  -- Draw health bar
  self:drawHealthBar(x, y, ufo.health, ufo.max_health)

  -- Draw threat indicator (size variation)
  if ufo.threat == "high" then
    love.graphics.setColor(0.9, 0.2, 0.2)
    love.graphics.polygon("line", tri_x1, tri_y1, tri_x2, tri_y2, tri_x3, tri_y3)
  end
end

--- Draw a single base indicator
-- @param base table Base data
function CraftIndicators:drawBaseIndicator(base)
  local x, y = self:getIndicatorPixelPosition(base.location)

  if not x or not y then return end

  -- Draw square
  local size = self.indicator_size
  love.graphics.setColor(self.base_color)
  love.graphics.rectangle("fill", x - size, y - size, size * 2, size * 2)

  -- Draw border
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.rectangle("line", x - size, y - size, size * 2, size * 2)

  -- Draw facility count inside
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.printf(base.facilities, x - size, y - size + 2, size * 2, "center")
end

--- Draw health bar above indicator
-- @param x number Center x position
-- @param y number Center y position
-- @param health number Current health
-- @param max_health number Maximum health
function CraftIndicators:drawHealthBar(x, y, health, max_health)
  if not health or not max_health or max_health == 0 then return end

  local bar_width = self.indicator_size * 2 + 4
  local bar_height = self.health_bar_height

  local bar_x = x - bar_width / 2
  local bar_y = y - self.indicator_size - 6

  -- Background (dark)
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", bar_x, bar_y, bar_width, bar_height)

  -- Health fill
  local health_percentage = math.max(0, math.min(1, health / max_health))
  local fill_width = bar_width * health_percentage

  -- Color based on health
  if health_percentage > 0.66 then
    love.graphics.setColor(0.2, 0.8, 0.2)  -- Green
  elseif health_percentage > 0.33 then
    love.graphics.setColor(0.8, 0.8, 0.2)  -- Yellow
  else
    love.graphics.setColor(0.8, 0.2, 0.2)  -- Red
  end

  love.graphics.rectangle("fill", bar_x, bar_y, fill_width, bar_height)

  -- Border
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle("line", bar_x, bar_y, bar_width, bar_height)
end

--- Get pixel position for indicator (converts hex location to screen coords)
-- @param location table Location {q, r} or {x, y}
-- @return number, number Pixel x and y or nil if off-screen
function CraftIndicators:getIndicatorPixelPosition(location)
  if not location or not self.renderer then return nil, nil end

  -- If location has q,r use that (hex coordinates)
  if location.q and location.r then
    return self.renderer:hexToPixel(location.q, location.r)
  end

  -- If location has x,y use that (pixel coordinates)
  if location.x and location.y then
    return location.x, location.y
  end

  return nil, nil
end

--- Called when turn advances to update positions
function CraftIndicators:onTurnAdvance()
  self:updateIndicators()
end

--- Register callbacks with turn advancer
-- @param turn_advancer table TurnAdvancer system reference
function CraftIndicators:registerCallbacks(turn_advancer)
  if turn_advancer then
    turn_advancer:registerPostTurnCallback(function()
      self:onTurnAdvance()
    end)
  end
end

--- Get craft at pixel position (for mouse selection)
-- @param pixel_x number Pixel x
-- @param pixel_y number Pixel y
-- @return table Craft data or nil
function CraftIndicators:getCraftAtPosition(pixel_x, pixel_y)
  local click_radius = self.indicator_size + 5

  -- Check player crafts first
  for _, craft in ipairs(self.player_crafts) do
    local x, y = self:getIndicatorPixelPosition(craft.location)
    if x and y then
      local dist = math.sqrt((pixel_x - x)^2 + (pixel_y - y)^2)
      if dist < click_radius then
        return craft
      end
    end
  end

  return nil
end

--- Get UFO at pixel position (for mouse selection)
-- @param pixel_x number Pixel x
-- @param pixel_y number Pixel y
-- @return table UFO data or nil
function CraftIndicators:getUFOAtPosition(pixel_x, pixel_y)
  local click_radius = (self.indicator_size + 2) * 1.5 + 5

  for _, ufo in ipairs(self.ufos) do
    local x, y = self:getIndicatorPixelPosition(ufo.location)
    if x and y then
      local dist = math.sqrt((pixel_x - x)^2 + (pixel_y - y)^2)
      if dist < click_radius then
        return ufo
      end
    end
  end

  return nil
end

--- Serialize state for saving
-- @return table Serializable state
function CraftIndicators:serialize()
  return {
    -- Indicator positions are derived from campaign state,
    -- so we don't need to save them explicitly
  }
end

--- Deserialize state from save
-- @param state table Saved state
function CraftIndicators:deserialize(state)
  self:updateIndicators()
end

return CraftIndicators

