--- Calendar.lua
-- Calendar system for Alien Fall
-- Manages time, seasons, and calendar events

-- GROK: Time management system - modify for different time scales or calendar types
-- GROK: Add new seasons or events by extending the data structure

local class = require 'lib.Middleclass'

Calendar = class('Calendar')

--- Initialize a new calendar
-- @param data The TOML data for this calendar
function Calendar:initialize(data)
    self.name = data.name
    self.description = data.description

    -- Time configuration
    self.time = data.time or {}

    -- Seasons
    self.seasons = data.seasons or {}

    -- Events
    self.events = data.events or {}

    -- Gameplay settings
    self.gameplay = data.gameplay or {}

    -- Validate data
    self:_validate()
end

--- Validate the calendar data
function Calendar:_validate()
    assert(self.name, "Calendar must have a name")

    -- Validate time configuration
    if self.time.days_per_month then
        assert(self.time.days_per_month > 0, "Days per month must be positive")
    end
    if self.time.months_per_year then
        assert(self.time.months_per_year > 0, "Months per year must be positive")
    end
end

--- Get the number of days in a month
-- @return Number of days per month
function Calendar:getDaysPerMonth()
    return self.time.days_per_month or 30
end

--- Get the number of months in a year
-- @return Number of months per year
function Calendar:getMonthsPerYear()
    return self.time.months_per_year or 12
end

--- Get season information for a given month
-- @param month The month number (1-12)
-- @return Season data or nil if not found
-- GROK: Seasonal effects - modify season data to change weather/combat modifiers
function Calendar:getSeasonForMonth(month)
    for seasonName, seasonData in pairs(self.seasons) do
        if seasonData.months then
            for _, seasonMonth in ipairs(seasonData.months) do
                if seasonMonth == month then
                    return {name = seasonName, data = seasonData}
                end
            end
        end
    end
    return nil
end

--- Get all events for a specific month and day
-- @param month The month number
-- @param day The day number
-- @return Array of events for that date
-- GROK: Calendar events - add new story events or seasonal activities here
function Calendar:getEventsForDate(month, day)
    local matchingEvents = {}

    -- Check holidays
    if self.events.holidays then
        for _, event in ipairs(self.events.holidays) do
            if event.month == month and event.day == day then
                table.insert(matchingEvents, event)
            end
        end
    end

    -- Check alien events
    if self.events.alien_events then
        for _, event in ipairs(self.events.alien_events) do
            if event.month == month and event.day == day then
                table.insert(matchingEvents, event)
            end
        end
    end

    return matchingEvents
end

--- Get all events of a specific type
-- @param eventType The type of events to get ("holiday", "alien", etc.)
-- @return Array of events of that type
function Calendar:getEventsByType(eventType)
    local events = {}

    if self.events.holidays and eventType == "holiday" then
        for _, event in ipairs(self.events.holidays) do
            table.insert(events, event)
        end
    end

    if self.events.alien_events and eventType == "alien" then
        for _, event in ipairs(self.events.alien_events) do
            table.insert(events, event)
        end
    end

    return events
end

--- Check if seasonal effects are enabled
-- @return true if seasonal effects are active
function Calendar:hasSeasonalEffects()
    return self.gameplay.seasonal_effects or false
end

--- Check if holiday bonuses are enabled
-- @return true if holiday bonuses are active
function Calendar:hasHolidayBonuses()
    return self.gameplay.holiday_bonuses or false
end

--- Get the time acceleration factor
-- @return Time acceleration multiplier
function Calendar:getTimeAcceleration()
    return self.gameplay.time_acceleration or 1.0
end

--- Calculate total days for a given number of months
-- @param months Number of months
-- @return Total number of days
function Calendar:monthsToDays(months)
    return months * self:getDaysPerMonth()
end

--- Calculate total months for a given number of years
-- @param years Number of years
-- @return Total number of months
function Calendar:yearsToMonths(years)
    return years * self:getMonthsPerYear()
end

--- Get a human-readable description of the calendar
-- @return String description
function Calendar:getDescription()
    local desc = self.name or "Unknown Calendar"
    desc = desc .. string.format(" (%d months/year, %d days/month)",
                                self:getMonthsPerYear(), self:getDaysPerMonth())

    if self:hasSeasonalEffects() then
        desc = desc .. " - Seasonal effects enabled"
    end

    return desc
end

--- Convert to string representation
-- @return String representation
function Calendar:__tostring()
    return string.format("Calendar{name='%s', months=%d, days=%d}",
                        self.name, self:getMonthsPerYear(), self:getDaysPerMonth())
end

return Calendar
