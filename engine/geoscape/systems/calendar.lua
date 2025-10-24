--- Calendar system for Geoscape time management
-- Tracks game time with day/month/year progression
-- Supports seasonal calculation and date queries
--
-- @module Calendar
-- @author AI Agent
-- @license MIT

local Calendar = {}
Calendar.__index = Calendar

--- Days per month (non-leap year)
local DAYS_PER_MONTH = {
  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
}

--- Month names
local MONTH_NAMES = {
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
}

--- Day of week names
local DAY_NAMES = {
  "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
}

--- Season definitions (start month, start day, name)
local SEASONS = {
  { month = 12, day = 21, name = "Winter" },   -- Winter: Dec 21 - Mar 20
  { month = 3, day = 21, name = "Spring" },    -- Spring: Mar 21 - Jun 20
  { month = 6, day = 21, name = "Summer" },    -- Summer: Jun 21 - Sep 20
  { month = 9, day = 21, name = "Autumn" },    -- Autumn: Sep 21 - Dec 20
}

--- Create new calendar
-- @param start_year number - Starting year (default 1996)
-- @param start_month number - Starting month (1-12, default 1)
-- @param start_day number - Starting day (1-31, default 1)
-- @return Calendar - New calendar instance
function Calendar.new(start_year, start_month, start_day)
  local self = setmetatable({}, Calendar)

  self.year = start_year or 1996
  self.month = math.max(1, math.min(12, start_month or 1))
  self.day = math.max(1, math.min(31, start_day or 1))
  self.turn = 0

  return self
end

--- Check if year is leap year
-- @param year number - Year to check
-- @return boolean - True if leap year
function Calendar.isLeapYear(year)
  if year % 400 == 0 then return true end
  if year % 100 == 0 then return false end
  if year % 4 == 0 then return true end
  return false
end

--- Get days in current month
-- @return number - Days in month (28-31)
function Calendar:getDaysInMonth()
  local days = DAYS_PER_MONTH[self.month]
  if self.month == 2 and Calendar.isLeapYear(self.year) then
    return 29
  end
  return days
end

--- Advance calendar by N turns (1 turn = 1 day)
-- @param num_turns number - Number of days to advance
function Calendar:advance(num_turns)
  num_turns = num_turns or 1

  for _ = 1, num_turns do
    self.day = self.day + 1
    self.turn = self.turn + 1

    -- Check for month overflow
    if self.day > self:getDaysInMonth() then
      self.day = 1
      self.month = self.month + 1

      -- Check for year overflow
      if self.month > 12 then
        self.month = 1
        self.year = self.year + 1
      end
    end
  end
end

--- Get current month name
-- @return string - Month name
function Calendar:getMonthName()
  return MONTH_NAMES[self.month] or "Unknown"
end

--- Get current season name
-- @return string - Season name
function Calendar:getSeasonName()
  -- Get day of year for season comparison
  local day_of_year = self:getDayOfYear()

  -- Calculate which season (roughly)
  if day_of_year >= 355 or day_of_year <= 79 then
    return "Winter"
  elseif day_of_year <= 171 then
    return "Spring"
  elseif day_of_year <= 264 then
    return "Summer"
  else
    return "Autumn"
  end
end

--- Get day of year (1-366)
-- @return number - Day of year
function Calendar:getDayOfYear()
  local day_of_year = self.day

  -- Add days from previous months
  for m = 1, self.month - 1 do
    day_of_year = day_of_year + DAYS_PER_MONTH[m]
    if m == 2 and Calendar.isLeapYear(self.year) then
      day_of_year = day_of_year + 1
    end
  end

  return day_of_year
end

--- Get formatted date string
-- @return string - Date like "Jan 15, 1996"
function Calendar:getDateString()
  local month_abbr = self:getMonthName():sub(1, 3)
  return string.format("%s %d, %d", month_abbr, self.day, self.year)
end

--- Get quarter of year (Q1-Q4)
-- @return number - Quarter (1-4)
function Calendar:getQuarter()
  return math.ceil(self.month / 3)
end

--- Get day of week (Zeller's congruence)
-- @return string - Day name
function Calendar:getDayOfWeek()
  -- Zeller's congruence algorithm
  local m = self.month
  local d = self.day
  local y = self.year

  if m < 3 then
    m = m + 12
    y = y - 1
  end

  local k = y % 100
  local j = math.floor(y / 100)

  local h = (d + math.floor(13 * (m + 1) / 5) + k + math.floor(k / 4) + math.floor(j / 4) - 2 * j) % 7

  -- Convert to 1-7 where 1=Monday
  h = (h + 6) % 7 + 1
  return DAY_NAMES[h] or "Monday"
end

--- Days until specific date (same year)
-- @param target_month number - Target month
-- @param target_day number - Target day
-- @return number - Days until date (negative if past date)
function Calendar:daysUntil(target_month, target_day)
  local current_day_of_year = self:getDayOfYear()
  local target_day_of_year = target_day

  for m = 1, target_month - 1 do
    target_day_of_year = target_day_of_year + DAYS_PER_MONTH[m]
    if m == 2 and Calendar.isLeapYear(self.year) then
      target_day_of_year = target_day_of_year + 1
    end
  end

  return target_day_of_year - current_day_of_year
end

--- Get days since year start
-- @return number - Days into year (1-366)
function Calendar:getDaysThisYear()
  return self:getDayOfYear()
end

--- Get days remaining in year
-- @return number - Days left in year
function Calendar:getDaysRemainingInYear()
  local year_length = Calendar.isLeapYear(self.year) and 366 or 365
  return year_length - self:getDayOfYear() + 1
end

--- Get calendar info as table
-- @return table - Calendar state
function Calendar:getInfo()
  return {
    year = self.year,
    month = self.month,
    day = self.day,
    turn = self.turn,
    month_name = self:getMonthName(),
    season = self:getSeasonName(),
    day_of_week = self:getDayOfWeek(),
    day_of_year = self:getDayOfYear(),
    quarter = self:getQuarter(),
    date_string = self:getDateString(),
  }
end

--- Serialize calendar for save/load
-- @return table - Serialized state
function Calendar:serialize()
  return {
    year = self.year,
    month = self.month,
    day = self.day,
    turn = self.turn,
  }
end

--- Deserialize calendar from save data
-- @param data table - Serialized state
-- @return Calendar - Restored calendar
function Calendar.deserialize(data)
  local self = setmetatable({}, Calendar)

  self.year = data.year or 1996
  self.month = data.month or 1
  self.day = data.day or 1
  self.turn = data.turn or 0

  return self
end

return Calendar
