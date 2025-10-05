--- Time.lua
-- Time service for Alien Fall geoscape system
-- Handles deterministic time progression, scheduling, and event hooks

local class = require 'lib.Middleclass'

TimeService = class('TimeService')

--- Initialize a new TimeService instance
-- @param registry Service registry for accessing other systems
-- @return TimeService instance
function TimeService:initialize(registry)
    self.registry = registry

    -- Time configuration
    self.turn_duration = 1  -- 1 turn = 1 day
    self.week_duration = 6  -- 6 days per week
    self.month_duration = 30  -- 30 days per month
    self.quarter_duration = 90  -- 90 days per quarter
    self.year_duration = 360  -- 360 days per year

    -- Current time state
    self.current_turn = 0
    self.current_day = 0
    self.current_week = 0
    self.current_month = 0
    self.current_quarter = 0
    self.current_year = 0
    
    -- Time control
    self.paused = false
    self.timeScale = 1  -- Speed multiplier (1x, 5x, 30x)
    self.availableTimeScales = {1, 5, 30}
    self.accumulator = 0  -- Time accumulator for variable dt
    self.secondsPerDay = 5  -- At 1x speed, 5 seconds = 1 game day

    -- Time hooks registry
    self.hooks = {
        day_tick = {},
        week_tick = {},
        month_tick = {},
        quarter_tick = {},
        year_tick = {}
    }

    -- Register with service registry
    if registry then
        registry:registerService('timeService', self)
    end
end

--- Register a hook for a specific time period
-- @param hook_type The type of hook ('day_tick', 'week_tick', etc.)
-- @param hook_id Unique identifier for the hook
-- @param callback Function to call when hook triggers
-- @param priority Optional priority for hook ordering (higher numbers execute first)
function TimeService:registerHook(hook_type, hook_id, callback, priority)
    if not self.hooks[hook_type] then
        error("Invalid hook type: " .. hook_type)
    end

    self.hooks[hook_type][hook_id] = {
        callback = callback,
        priority = priority or 0
    }
end

--- Unregister a hook
-- @param hook_type The type of hook
-- @param hook_id The hook identifier to remove
function TimeService:unregisterHook(hook_type, hook_id)
    if self.hooks[hook_type] then
        self.hooks[hook_type][hook_id] = nil
    end
end

--- Advance time by one turn (day)
-- @param dt Delta time (unused, deterministic progression)
function TimeService:advanceTurn(dt)
    self.current_turn = self.current_turn + 1
    self.current_day = self.current_day + 1

    -- Execute day tick hooks
    self:_executeHooks('day_tick')

    -- Check for week transition
    if self.current_day % self.week_duration == 0 then
        self.current_week = self.current_week + 1
        self:_executeHooks('week_tick')
    end

    -- Check for month transition
    if self.current_day % self.month_duration == 0 then
        self.current_month = self.current_month + 1
        self:_executeHooks('month_tick')
    end

    -- Check for quarter transition
    if self.current_day % self.quarter_duration == 0 then
        self.current_quarter = self.current_quarter + 1
        self:_executeHooks('quarter_tick')
    end

    -- Check for year transition
    if self.current_day % self.year_duration == 0 then
        self.current_year = self.current_year + 1
        self:_executeHooks('year_tick')
    end
end

--- Execute hooks for a specific type, ordered by priority
-- @param hook_type The type of hooks to execute
function TimeService:_executeHooks(hook_type)
    local hooks = self.hooks[hook_type]
    if not hooks then return end

    -- Create sorted list of hooks by priority (highest first)
    local sorted_hooks = {}
    for hook_id, hook_data in pairs(hooks) do
        table.insert(sorted_hooks, {
            id = hook_id,
            data = hook_data
        })
    end

    table.sort(sorted_hooks, function(a, b)
        return a.data.priority > b.data.priority
    end)

    -- Execute hooks in order
    for _, hook_info in ipairs(sorted_hooks) do
        local success, error_msg = pcall(hook_info.data.callback)
        if not success then
            -- Log error but continue with other hooks
            local logger = self.registry and self.registry:getService('logger')
            if logger then
                logger:error("Time hook '" .. hook_info.id .. "' failed: " .. error_msg)
            end
        end
    end
end

--- Get current time information
-- @return Table with current time values
function TimeService:getCurrentTime()
    return {
        turn = self.current_turn,
        day = self.current_day,
        week = self.current_week,
        month = self.current_month,
        quarter = self.current_quarter,
        year = self.current_year
    }
end

--- Get the current day of the week (1-6)
-- @return Day of week (1 = Monday, 6 = Saturday)
function TimeService:getDayOfWeek()
    return ((self.current_day - 1) % self.week_duration) + 1
end

--- Get the current day of the month (1-30)
-- @return Day of month
function TimeService:getDayOfMonth()
    return ((self.current_day - 1) % self.month_duration) + 1
end

--- Get the current day of the quarter (1-90)
-- @return Day of quarter
function TimeService:getDayOfQuarter()
    return ((self.current_day - 1) % self.quarter_duration) + 1
end

--- Get the current day of the year (1-360)
-- @return Day of year
function TimeService:getDayOfYear()
    return ((self.current_day - 1) % self.year_duration) + 1
end

--- Check if it's the start of a new week
-- @return True if current turn starts a new week
function TimeService:isStartOfWeek()
    return self.current_day % self.week_duration == 1
end

--- Check if it's the start of a new month
-- @return True if current turn starts a new month
function TimeService:isStartOfMonth()
    return self.current_day % self.month_duration == 1
end

--- Check if it's the start of a new quarter
-- @return True if current turn starts a new quarter
function TimeService:isStartOfQuarter()
    return self.current_day % self.quarter_duration == 1
end

--- Check if it's the start of a new year
-- @return True if current turn starts a new year
function TimeService:isStartOfYear()
    return self.current_day % self.year_duration == 1
end

--- Set the current time (for loading saved games)
-- @param time_data Table with time values to set
function TimeService:setCurrentTime(time_data)
    self.current_turn = time_data.turn or 0
    self.current_day = time_data.day or 0
    self.current_week = time_data.week or 0
    self.current_month = time_data.month or 0
    self.current_quarter = time_data.quarter or 0
    self.current_year = time_data.year or 0
end

--- Get time until next specific time period
-- @param period The period to check ('week', 'month', 'quarter', 'year')
-- @return Days until next period
function TimeService:getDaysUntilNext(period)
    local current = self.current_day

    if period == 'week' then
        local days_into_week = ((current - 1) % self.week_duration) + 1
        return self.week_duration - days_into_week + 1
    elseif period == 'month' then
        local days_into_month = ((current - 1) % self.month_duration) + 1
        return self.month_duration - days_into_month + 1
    elseif period == 'quarter' then
        local days_into_quarter = ((current - 1) % self.quarter_duration) + 1
        return self.quarter_duration - days_into_quarter + 1
    elseif period == 'year' then
        local days_into_year = ((current - 1) % self.year_duration) + 1
        return self.year_duration - days_into_year + 1
    end

    return 0
end

--- Format current time as a human-readable string
-- @return Formatted time string
function TimeService:formatCurrentTime()
    return string.format("Year %d, Quarter %d, Month %d, Week %d, Day %d",
        self.current_year + 1,
        self.current_quarter + 1,
        self.current_month + 1,
        self.current_week + 1,
        self:getDayOfWeek()
    )
end

--- Pause time progression
function TimeService:pause()
    self.paused = true
    
    -- Emit pause event
    local eventBus = self.registry and self.registry:getService('eventBus')
    if eventBus then
        eventBus:emit('time:paused', {})
    end
end

--- Resume time progression
function TimeService:resume()
    self.paused = false
    
    -- Emit resume event
    local eventBus = self.registry and self.registry:getService('eventBus')
    if eventBus then
        eventBus:emit('time:resumed', {})
    end
end

--- Toggle pause state
function TimeService:togglePause()
    if self.paused then
        self:resume()
    else
        self:pause()
    end
end

--- Check if time is paused
-- @return boolean: True if paused
function TimeService:isPaused()
    return self.paused
end

--- Set time scale (speed multiplier)
-- @param scale number: Time scale (1, 5, or 30)
function TimeService:setTimeScale(scale)
    -- Validate scale
    local validScale = false
    for _, availableScale in ipairs(self.availableTimeScales) do
        if scale == availableScale then
            validScale = true
            break
        end
    end
    
    if not validScale then
        local logger = self.registry and self.registry:getService('logger')
        if logger then
            logger:warn("Invalid time scale: " .. tostring(scale) .. ", using 1x")
        end
        scale = 1
    end
    
    self.timeScale = scale
    
    -- Emit scale change event
    local eventBus = self.registry and self.registry:getService('eventBus')
    if eventBus then
        eventBus:emit('time:scale_changed', {scale = scale})
    end
end

--- Get current time scale
-- @return number: Current time scale multiplier
function TimeService:getTimeScale()
    return self.timeScale
end

--- Cycle to next time scale
function TimeService:cycleTimeScale()
    local currentIndex = 1
    for i, scale in ipairs(self.availableTimeScales) do
        if scale == self.timeScale then
            currentIndex = i
            break
        end
    end
    
    -- Move to next scale (wrap around)
    local nextIndex = (currentIndex % #self.availableTimeScales) + 1
    self:setTimeScale(self.availableTimeScales[nextIndex])
end

--- Update time with real-time delta (called from love.update)
-- @param dt number: Delta time in seconds
function TimeService:update(dt)
    if self.paused then
        return
    end
    
    -- Apply time scale
    local scaledDt = dt * self.timeScale
    self.accumulator = self.accumulator + scaledDt
    
    -- Check if enough time has passed for a day
    local daysToAdvance = math.floor(self.accumulator / self.secondsPerDay)
    
    if daysToAdvance > 0 then
        self.accumulator = self.accumulator - (daysToAdvance * self.secondsPerDay)
        
        -- Advance by the number of days
        for i = 1, daysToAdvance do
            self:advanceTurn()
        end
    end
end

return TimeService
