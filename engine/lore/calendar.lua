---Calendar System for Strategic Layer
---
---Turn-based time management for the geoscape. Each turn represents one day.
---Manages date progression, day/night cycle, weekly/monthly events, and seasonal
---changes. Simplified calendar: 6 days/week, 30 days/month, 12 months/year.
---
---Calendar Structure:
---  - 1 turn = 1 day
---  - 6 days per week (no weekends in apocalypse!)
---  - 5 weeks per month = 30 days/month
---  - 12 months per year = 360 days/year
---  - 4 quarters per year (3 months each)
---
---Time-Based Events:
---  - Daily: Mission updates, facility construction, research progress
---  - Weekly: Mission generation, funding updates, soldier recovery
---  - Monthly: Country funding, research breakthroughs, campaign escalation
---  - Quarterly: Major story events, faction changes, difficulty increases
---
---Key Exports:
---  - Calendar.new(startDay, startMonth, startYear): Creates calendar instance
---  - advanceDay(): Progresses time by one day
---  - getCurrentDate(): Returns current day/month/year
---  - getDayOfWeek(): Returns day name (1-6)
---  - getDayOfMonth(): Returns day within month (1-30)
---  - getQuarter(): Returns current quarter (1-4)
---  - isMonday(): Checks if today is week start (mission generation day)
---
---Dependencies:
---  - geoscape.world.world_state: World time tracking
---  - lore.campaign.campaign_manager: Mission generation scheduling
---
---@module lore.calendar
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Calendar = require("lore.calendar")
---  local calendar = Calendar.new(1, 1, 2025)  -- Jan 1, 2025
---  calendar:advanceDay()
---  print(calendar:getCurrentDate())  -- "Day 2, Month 1, Year 2025"
---
---@see geoscape.world.world_state For world time management
---@see lore.campaign.campaign_manager For time-based mission generation

local Calendar = {}
Calendar.__index = Calendar

-- Calendar constants
local DAYS_PER_WEEK = 6
local WEEKS_PER_MONTH = 5
local DAYS_PER_MONTH = DAYS_PER_WEEK * WEEKS_PER_MONTH  -- 30
local MONTHS_PER_QUARTER = 3
local QUARTERS_PER_YEAR = 4
local MONTHS_PER_YEAR = MONTHS_PER_QUARTER * QUARTERS_PER_YEAR  -- 12
local DAYS_PER_YEAR = DAYS_PER_MONTH * MONTHS_PER_YEAR  -- 360

-- Month names
local MONTH_NAMES = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
}

-- Day names (6-day week)
local DAY_NAMES = {
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
}

---Create a new calendar instance
---@param startYear number? Starting year (default 1)
---@param startMonth number? Starting month (default 1)
---@param startDay number? Starting day (default 1)
---@return table Calendar instance
function Calendar.new(startYear, startMonth, startDay)
    local self = setmetatable({}, Calendar)
    
    self.year = startYear or 1
    self.month = startMonth or 1
    self.day = startDay or 1
    
    -- Calculate derived values
    self:recalculate()
    
    -- Event system
    self.events = {}  -- Scheduled events: {turn = X, callback = function()}
    self.listeners = {}  -- Event listeners by type
    
    print(string.format("[Calendar] Initialized at %s", self:getFullDate()))
    
    return self
end

---Recalculate all derived calendar values
function Calendar:recalculate()
    -- Calculate day of week (1-6)
    self.dayOfWeek = ((self.day - 1) % DAYS_PER_WEEK) + 1
    
    -- Calculate week of month (1-5)
    self.weekOfMonth = math.floor((self.day - 1) / DAYS_PER_WEEK) + 1
    
    -- Calculate quarter (1-4)
    self.quarter = math.floor((self.month - 1) / MONTHS_PER_QUARTER) + 1
    
    -- Calculate day of year (1-360)
    self.dayOfYear = (self.month - 1) * DAYS_PER_MONTH + self.day
    
    -- Calculate total days since epoch
    self.totalDays = (self.year - 1) * DAYS_PER_YEAR + self.dayOfYear
    
    -- Calculate turn number (same as totalDays)
    self.turn = self.totalDays
end

---Advance time by one day (one turn)
function Calendar:advanceTurn()
    self.day = self.day + 1
    
    -- Roll over to next month
    if self.day > DAYS_PER_MONTH then
        self.day = 1
        self.month = self.month + 1
        
        -- Roll over to next year
        if self.month > MONTHS_PER_YEAR then
            self.month = 1
            self.year = self.year + 1
        end
    end
    
    self:recalculate()
    self:processEvents()
    self:notifyListeners("turnAdvanced", self)
    
    return self
end

---Advance time by multiple days
---@param days number Number of days to advance
function Calendar:advanceDays(days)
    for i = 1, days do
        self:advanceTurn()
    end
    return self
end

---Get short date string (e.g., "Year 1, Month 3, Day 15")
---@return string Short date string
function Calendar:getShortDate()
    return string.format("Y%d M%d D%d", self.year, self.month, self.day)
end

---Get medium date string (e.g., "March 15, Year 1")
---@return string Medium date string
function Calendar:getMediumDate()
    return string.format("%s %d, Year %d", MONTH_NAMES[self.month], self.day, self.year)
end

---Get full date string (e.g., "Monday, March 15, Year 1, Q1")
---@return string Full date string
function Calendar:getFullDate()
    return string.format("%s, %s %d, Year %d, Q%d", 
        DAY_NAMES[self.dayOfWeek], MONTH_NAMES[self.month], 
        self.day, self.year, self.quarter)
end

---Get compact date for UI (e.g., "Y1 M3 D15")
---@return string Compact date string
function Calendar:getCompactDate()
    return string.format("Y%d M%d D%d", self.year, self.month, self.day)
end

---Get day name (e.g., "Monday")
---@return string Day name
function Calendar:getDayName()
    return DAY_NAMES[self.dayOfWeek]
end

---Get month name (e.g., "March")
---@return string Month name
function Calendar:getMonthName()
    return MONTH_NAMES[self.month]
end

---Check if it's the start of a new week
---@return boolean True if day is 1, 7, 13, 19, or 25
function Calendar:isStartOfWeek()
    return self.dayOfWeek == 1
end

---Check if it's the end of a week
---@return boolean True if day is 6, 12, 18, 24, or 30
function Calendar:isEndOfWeek()
    return self.dayOfWeek == DAYS_PER_WEEK
end

---Check if it's the start of a new month
---@return boolean True if day is 1
function Calendar:isStartOfMonth()
    return self.day == 1
end

---Check if it's the end of a month
---@return boolean True if day is 30
function Calendar:isEndOfMonth()
    return self.day == DAYS_PER_MONTH
end

---Check if it's the start of a new quarter
---@return boolean True if month is 1, 4, 7, or 10 and day is 1
function Calendar:isStartOfQuarter()
    return self.day == 1 and ((self.month - 1) % MONTHS_PER_QUARTER == 0)
end

---Check if it's the end of a quarter
---@return boolean True if month is 3, 6, 9, or 12 and day is 30
function Calendar:isEndOfQuarter()
    return self.day == DAYS_PER_MONTH and (self.month % MONTHS_PER_QUARTER == 0)
end

---Check if it's the start of a new year
---@return boolean True if month and day are both 1
function Calendar:isStartOfYear()
    return self.month == 1 and self.day == 1
end

---Check if it's the end of a year
---@return boolean True if month is 12 and day is 30
function Calendar:isEndOfYear()
    return self.month == MONTHS_PER_YEAR and self.day == DAYS_PER_MONTH
end

---Schedule an event for a future turn
---@param daysFromNow number Number of days in the future
---@param callback function Function to call when event triggers
---@param data table? Optional data to pass to callback
function Calendar:scheduleEvent(daysFromNow, callback, data)
    local targetTurn = self.turn + daysFromNow
    table.insert(self.events, {
        turn = targetTurn,
        callback = callback,
        data = data
    })
    
    -- Sort events by turn
    table.sort(self.events, function(a, b) return a.turn < b.turn end)
end

---Process scheduled events for current turn
function Calendar:processEvents()
    local i = 1
    while i <= #self.events do
        local event = self.events[i]
        if event.turn <= self.turn then
            -- Execute event callback
            local success, err = pcall(event.callback, event.data, self)
            if not success then
                print(string.format("[Calendar] Event callback error: %s", err))
            end
            -- Remove processed event
            table.remove(self.events, i)
        else
            -- Events are sorted, so we can stop here
            break
        end
    end
end

---Register an event listener
---@param eventType string Event type (e.g., "turnAdvanced", "monthStarted")
---@param callback function Function to call when event occurs
function Calendar:addEventListener(eventType, callback)
    if not self.listeners[eventType] then
        self.listeners[eventType] = {}
    end
    table.insert(self.listeners[eventType], callback)
end

---Notify all listeners of an event
---@param eventType string Event type
---@param data any Event data
function Calendar:notifyListeners(eventType, data)
    if self.listeners[eventType] then
        for _, callback in ipairs(self.listeners[eventType]) do
            local success, err = pcall(callback, data)
            if not success then
                print(string.format("[Calendar] Listener error for '%s': %s", eventType, err))
            end
        end
    end
end

---Get calendar state for serialization
---@return table Calendar state
function Calendar:serialize()
    return {
        year = self.year,
        month = self.month,
        day = self.day,
        turn = self.turn
    }
end

---Load calendar state from serialization
---@param data table Calendar state
function Calendar:deserialize(data)
    self.year = data.year
    self.month = data.month
    self.day = data.day
    self:recalculate()
end

---Get days remaining in current month
---@return number Days remaining (including current day)
function Calendar:daysRemainingInMonth()
    return DAYS_PER_MONTH - self.day + 1
end

---Get days remaining in current quarter
---@return number Days remaining (including current day)
function Calendar:daysRemainingInQuarter()
    local monthsRemaining = MONTHS_PER_QUARTER - ((self.month - 1) % MONTHS_PER_QUARTER)
    local daysInRemainingMonths = (monthsRemaining - 1) * DAYS_PER_MONTH
    return daysInRemainingMonths + self:daysRemainingInMonth()
end

---Get days remaining in current year
---@return number Days remaining (including current day)
function Calendar:daysRemainingInYear()
    return DAYS_PER_YEAR - self.dayOfYear + 1
end

-- Export constants for external use
Calendar.DAYS_PER_WEEK = DAYS_PER_WEEK
Calendar.WEEKS_PER_MONTH = WEEKS_PER_MONTH
Calendar.DAYS_PER_MONTH = DAYS_PER_MONTH
Calendar.MONTHS_PER_QUARTER = MONTHS_PER_QUARTER
Calendar.QUARTERS_PER_YEAR = QUARTERS_PER_YEAR
Calendar.MONTHS_PER_YEAR = MONTHS_PER_YEAR
Calendar.DAYS_PER_YEAR = DAYS_PER_YEAR
Calendar.MONTH_NAMES = MONTH_NAMES
Calendar.DAY_NAMES = DAY_NAMES

return Calendar






















