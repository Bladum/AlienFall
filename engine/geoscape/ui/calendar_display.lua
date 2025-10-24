--[[
  Calendar Display UI Component

  Renders the current date, season, day of week, and turn counter.
  Located in top-left corner, auto-updates on turn advance.

  @module engine.geoscape.ui.calendar_display
  @author AI Assistant
  @license MIT
]]

local CalendarDisplay = {}

--- Initialize calendar display
-- @param calendar table Calendar system reference
-- @return table Initialized display component
function CalendarDisplay:initialize(calendar)
  self.calendar = calendar

  -- Position and size
  self.x = 10
  self.y = 10
  self.width = 180
  self.height = 100

  -- Colors
  self.background_color = {0.1, 0.1, 0.15, 0.8}
  self.text_color = {1, 1, 1}
  self.season_colors = {
    winter = {0.4, 0.6, 0.9},    -- Light blue
    spring = {0.4, 0.9, 0.6},    -- Light green
    summer = {0.9, 0.9, 0.4},    -- Light yellow
    autumn = {0.9, 0.7, 0.4}     -- Light orange
  }

  -- Display state
  self.date_string = ""
  self.season_string = ""
  self.day_of_week_string = ""
  self.turn_string = ""

  -- Update display
  self:updateDisplay()

  return self
end

--- Update display text from calendar
function CalendarDisplay:updateDisplay()
  if not self.calendar then return end

  -- Get current date components
  local year = self.calendar:getYear()
  local month = self.calendar:getMonth()
  local day = self.calendar:getDay()
  local turn = self.calendar:getTurn()

  -- Month names
  local months = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  }

  -- Format date string
  self.date_string = string.format("%s %d, %d",
    months[month], day, year)

  -- Get season
  local season = self.calendar:getSeason()
  self.season_string = season:sub(1, 1):upper() .. season:sub(2)

  -- Get day of week
  local dow = self.calendar:getDayOfWeek()
  local dow_names = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
  self.day_of_week_string = dow_names[dow]

  -- Format turn string
  self.turn_string = string.format("Turn: %d", turn)
end

--- Draw the calendar display
-- @param camera_x number For positional adjustment (optional)
function CalendarDisplay:draw()
  -- Draw background panel
  love.graphics.setColor(self.background_color)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

  -- Draw border
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

  -- Draw title
  love.graphics.setColor(0.7, 0.7, 1)
  love.graphics.printf("Calendar", self.x, self.y + 5, self.width, "center")

  -- Draw date
  love.graphics.setColor(self.text_color)
  love.graphics.setFont(love.graphics.getFont())
  love.graphics.printf(self.date_string,
    self.x + 5, self.y + 20, self.width - 10, "left")

  -- Draw season with color
  local season = self.calendar:getSeason()
  love.graphics.setColor(self.season_colors[season] or {1, 1, 1})
  love.graphics.printf("Season: " .. self.season_string,
    self.x + 5, self.y + 35, self.width - 10, "left")

  -- Draw day of week
  love.graphics.setColor(self.text_color)
  love.graphics.printf(self.day_of_week_string,
    self.x + 5, self.y + 50, self.width - 10, "left")

  -- Draw turn counter
  love.graphics.setColor(0.9, 0.9, 0.5)
  love.graphics.printf(self.turn_string,
    self.x + 5, self.y + 65, self.width - 10, "left")

  -- Draw moon phase indicator (if calendar supports it)
  self:drawMoonPhase()
end

--- Draw moon phase indicator
function CalendarDisplay:drawMoonPhase()
  love.graphics.setColor(1, 1, 1)

  local day = self.calendar:getDay()
  local month = self.calendar:getMonth()

  -- Simple moon phase: cycle through month
  local phase = (day - 1) % 30
  local moon_phase_name = ""

  if phase < 8 then
    moon_phase_name = "🌑" -- New
  elseif phase < 15 then
    moon_phase_name = "🌓" -- Waxing
  elseif phase < 22 then
    moon_phase_name = "🌕" -- Full
  else
    moon_phase_name = "🌗" -- Waning
  end

  love.graphics.printf("Moon: " .. (phase > 10 and "+" or "-"),
    self.x + 5, self.y + 82, self.width - 10, "left")
end

--- Called when turn advances (from turn advancer callback)
function CalendarDisplay:onTurnAdvance()
  self:updateDisplay()
end

--- Get the seasonal modifier as a visual indicator
-- @return string Single character indicator (↑ for boost, ↓ for penalty, - for neutral)
function CalendarDisplay:getSeasonalModifierIndicator()
  if not self.calendar then return "-" end

  local season = self.calendar:getSeason()
  -- This would connect to season system in full implementation

  return "-"
end

--- Show a season transition effect (visual feedback)
-- Called when season changes
function CalendarDisplay:onSeasonChange()
  -- Could trigger animation or flash effect
end

--- Register callbacks with turn advancer
-- @param turn_advancer table TurnAdvancer system reference
function CalendarDisplay:registerCallbacks(turn_advancer)
  if turn_advancer then
    turn_advancer:registerPostTurnCallback(function()
      self:onTurnAdvance()
    end)
  end
end

--- Serialize state for saving
-- @return table Serializable state
function CalendarDisplay:serialize()
  return {
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height
  }
end

--- Deserialize state from save
-- @param state table Saved state
function CalendarDisplay:deserialize(state)
  if state then
    self.x = state.x or self.x
    self.y = state.y or self.y
    self.width = state.width or self.width
    self.height = state.height or self.height
  end
  self:updateDisplay()
end

return CalendarDisplay
