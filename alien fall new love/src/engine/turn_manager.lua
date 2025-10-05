local TurnManager = {}
TurnManager.__index = TurnManager

-- Simplified game calendar constants
local DAYS_PER_WEEK = 6
local WEEKS_PER_MONTH = 5
local MONTHS_PER_QUARTER = 3
local QUARTERS_PER_YEAR = 4

local DAYS_PER_MONTH = DAYS_PER_WEEK * WEEKS_PER_MONTH  -- 30
local DAYS_PER_QUARTER = DAYS_PER_MONTH * MONTHS_PER_QUARTER  -- 90
local DAYS_PER_YEAR = DAYS_PER_QUARTER * QUARTERS_PER_YEAR  -- 360

local function advanceCalendar(date)
    local year = date.year
    local quarter = date.quarter
    local month = date.month
    local week = date.week
    local day = date.day + 1

    -- Advance day to week
    if day > DAYS_PER_WEEK then
        day = 1
        week = week + 1
    end

    -- Advance week to month
    if week > WEEKS_PER_MONTH then
        week = 1
        month = month + 1
    end

    -- Advance month to quarter
    if month > MONTHS_PER_QUARTER then
        month = 1
        quarter = quarter + 1
    end

    -- Advance quarter to year
    if quarter > QUARTERS_PER_YEAR then
        quarter = 1
        year = year + 1
    end

    return {
        year = year,
        quarter = quarter,
        month = month,
        week = week,
        day = day
    }
end

local function absoluteDay(date)
    -- Calculate absolute days since year 0
    local totalDays = 0
    totalDays = totalDays + (date.year * DAYS_PER_YEAR)
    totalDays = totalDays + ((date.quarter - 1) * DAYS_PER_QUARTER)
    totalDays = totalDays + ((date.month - 1) * DAYS_PER_MONTH)
    totalDays = totalDays + ((date.week - 1) * DAYS_PER_WEEK)
    totalDays = totalDays + date.day
    return totalDays
end

function TurnManager.new(opts)
    local self = setmetatable({}, TurnManager)
    self.eventBus = opts and opts.eventBus or nil
    self.telemetry = opts and opts.telemetry or nil
    self.current = {
        year = 2047,
        quarter = 1,
        month = 1,
        week = 1,
        day = 1
    }
    self.absolute = absoluteDay(self.current)
    self.queue = {}
    self.turnCount = 0
    return self
end

function TurnManager:setEventBus(bus)
    self.eventBus = bus
end

function TurnManager:setDate(year, quarter, month, week, day)
    assert(type(year) == "number" and type(quarter) == "number" and type(month) == "number" and
           type(week) == "number" and type(day) == "number",
        "setDate expects numeric year, quarter, month, week, day")
    self.current = {
        year = year,
        quarter = quarter,
        month = month,
        week = week,
        day = day
    }
    self.absolute = absoluteDay(self.current)
    self.turnCount = 0
end

function TurnManager:getDate()
    return {
        year = self.current.year,
        quarter = self.current.quarter,
        month = self.current.month,
        week = self.current.week,
        day = self.current.day
    }
end

function TurnManager:getWeek()
    return self.current.week
end

function TurnManager:getQuarter()
    return self.current.quarter
end

function TurnManager:getMonth()
    return self.current.month
end

function TurnManager:getYear()
    return self.current.year
end

function TurnManager:getDay()
    return self.current.day
end

function TurnManager:getAbsoluteDay()
    return self.absolute
end

local function sortQueue(queue)
    table.sort(queue, function(a, b)
        if a.trigger == b.trigger then
            return a.order < b.order
        end
        return a.trigger < b.trigger
    end)
end

function TurnManager:schedule(daysAhead, topic, payload)
    assert(type(daysAhead) == "number" and daysAhead >= 0, "schedule expects non-negative number of days")
    assert(type(topic) == "string" and topic ~= "", "schedule expects a topic string")
    local entry = {
        trigger = self.absolute + math.floor(daysAhead),
        topic = topic,
        payload = payload,
        order = #self.queue + 1
    }
    table.insert(self.queue, entry)
    sortQueue(self.queue)
    if self.telemetry then
        self.telemetry:recordEvent({
            type = "turn-scheduled",
            topic = topic,
            trigger = entry.trigger,
            payload = payload
        })
    end
    return entry
end

function TurnManager:advance(days)
    local steps = days or 1
    assert(type(steps) == "number" and steps >= 1, "advance expects positive number of days")

    local previousDate = {
        year = self.current.year,
        quarter = self.current.quarter,
        month = self.current.month,
        week = self.current.week,
        day = self.current.day
    }

    for _ = 1, math.floor(steps) do
        self.current = advanceCalendar(self.current)
        self.absolute = absoluteDay(self.current)
        self.turnCount = self.turnCount + 1

        if self.telemetry then
            self.telemetry:recordEvent({
                type = "turn-advanced",
                date = self:getDate(),
                absolute = self.absolute
            })
        end

        if self.eventBus then
            -- Emit day advanced event
            self.eventBus:publish("time:day_advanced", {
                date = self:getDate(),
                absolute = self.absolute,
                turn = self.turnCount
            })
            
            -- Emit day passed event (for systems that process per day)
            self.eventBus:publish("time:day_passed", {
                date = self:getDate(),
                day = self.current.day,
                absolute = self.absolute
            })
            
            -- Check for week transition
            if self.current.week ~= previousDate.week or 
               self.current.month ~= previousDate.month or
               self.current.quarter ~= previousDate.quarter or
               self.current.year ~= previousDate.year then
                self.eventBus:publish("time:week_passed", {
                    date = self:getDate(),
                    week = self.current.week,
                    absolute = self.absolute
                })
            end
            
            -- Check for month transition
            if self.current.month ~= previousDate.month or
               self.current.quarter ~= previousDate.quarter or
               self.current.year ~= previousDate.year then
                self.eventBus:publish("time:month_passed", {
                    date = self:getDate(),
                    month = self.current.month,
                    quarter = self.current.quarter,
                    absolute = self.absolute
                })
            end
            
            -- Check for quarter transition
            if self.current.quarter ~= previousDate.quarter or
               self.current.year ~= previousDate.year then
                self.eventBus:publish("time:quarter_passed", {
                    date = self:getDate(),
                    quarter = self.current.quarter,
                    absolute = self.absolute
                })
            end
            
            -- Check for year transition
            if self.current.year ~= previousDate.year then
                self.eventBus:publish("time:year_passed", {
                    date = self:getDate(),
                    year = self.current.year,
                    absolute = self.absolute
                })
            end
        end
        
        -- Update previous date for next iteration
        previousDate = {
            year = self.current.year,
            quarter = self.current.quarter,
            month = self.current.month,
            week = self.current.week,
            day = self.current.day
        }

        self:_processQueue()
    end
end

function TurnManager:_processQueue()
    if #self.queue == 0 then
        return
    end

    sortQueue(self.queue)

    while #self.queue > 0 do
        local entry = self.queue[1]
        if entry.trigger > self.absolute then
            break
        end

        table.remove(self.queue, 1)
        if self.eventBus then
            self.eventBus:publish(entry.topic, {
                date = self:getDate(),
                source = "turn_manager",
                payload = entry.payload
            })
        end

        if self.telemetry then
            self.telemetry:recordEvent({
                type = "turn-fired",
                topic = entry.topic,
                payload = entry.payload
            })
        end
    end
end

return TurnManager
