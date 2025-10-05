--[[
widgets/calendar.lua
Calendar widget for date selection and timeline management


Interactive calendar widget providing date selection and timeline visualization for turn-based
strategy games. Essential for mission planning, research scheduling, and timeline management
in base operations for tactical strategy game interfaces.

PURPOSE:
- Provide date selection and timeline visualization for turn-based strategy games
- Enable mission planning, research scheduling, and timeline management
- Support date ranges and disabled dates for complex scheduling
- Facilitate strategic planning where timing is critical for tactical success

KEY FEATURES:
- Month/year navigation with date selection
- Support for date ranges and disabled dates
- Multi-selection capabilities for scheduling
- Range selection with visual feedback
- Integration with game timeline systems
- Customizable date formatting and localization
- Keyboard navigation and accessibility support
- Visual highlighting for today and selected dates
- Smooth month transitions and animations

]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")

local Calendar = {}
Calendar.__index = Calendar

-- Date utility functions
local function isLeapYear(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local function getDaysInMonth(month, year)
    local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if month == 2 and isLeapYear(year) then
        return 29
    end
    return days[month]
end

local function getFirstDayOfMonth(month, year)
    -- Returns day of week (1=Monday, 7=Sunday) for the first day of the month
    local a = math.floor((14 - month) / 12)
    local y = year - a
    local m = month + 12 * a - 2
    local d = 1

    return ((d + math.floor((13 * (m + 1)) / 5) + y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400)) % 7) +
        1
end

function Calendar:new(x, y, w, h, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    -- Current display date
    local currentDate = os.date("*t")
    obj.displayMonth = options.month or currentDate.month
    obj.displayYear = options.year or currentDate.year

    -- Selected date
    obj.selectedDate = nil
    if options.selectedDate then
        obj.selectedDate = {
            day = options.selectedDate.day,
            month = options.selectedDate.month,
            year = options.selectedDate.year
        }
    end

    -- Today's date
    obj.today = {
        day = currentDate.day,
        month = currentDate.month,
        year = currentDate.year
    }

    -- Display options
    obj.showWeekNumbers = options.showWeekNumbers or false
    obj.startMonday = options.startMonday ~= false -- Default to Monday first
    obj.highlightToday = options.highlightToday ~= false
    obj.showOtherMonths = options.showOtherMonths ~= false

    -- Locale settings
    obj.monthNames = options.monthNames or {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    }

    obj.dayNames = options.dayNames or
        (obj.startMonday and { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }
            or { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" })

    -- Date constraints
    obj.minDate = options.minDate
    obj.maxDate = options.maxDate
    obj.disabledDates = options.disabledDates or {}

    -- Multi-selection support
    obj.multiSelect = options.multiSelect or false
    obj.selectedDates = options.selectedDates or {}

    -- Range selection support
    obj.rangeSelect = options.rangeSelect or false
    obj.rangeStart = nil
    obj.rangeEnd = nil
    obj.rangeHover = nil

    -- Events
    obj.onDateSelect = options.onDateSelect
    obj.onMonthChange = options.onMonthChange
    obj.onDateHover = options.onDateHover

    -- Layout calculation
    obj.cellWidth = 0
    obj.cellHeight = 0
    obj.headerHeight = 30
    obj.dayHeaderHeight = 25
    obj.calendarStartY = 0

    -- Hover and interaction
    obj.hoveredDate = nil
    obj.pressedDate = nil

    -- Animation
    obj.monthTransition = 0
    obj.transitionDirection = 0

    setmetatable(obj, self)
    obj:_calculateLayout()
    return obj
end

function Calendar:_calculateLayout()
    local contentWidth = self.w - 10 -- Padding
    local contentHeight = self.h - self.headerHeight - self.dayHeaderHeight - 10

    self.cellWidth = contentWidth / 7
    self.cellHeight = contentHeight / 6 -- 6 weeks maximum

    self.calendarStartY = self.y + self.headerHeight + self.dayHeaderHeight + 5
end

function Calendar:setDate(year, month, day)
    if self:_isValidDate(year, month, day) and self:_isDateEnabled(year, month, day) then
        if self.multiSelect then
            -- Add to selection
            local dateKey = string.format("%d-%02d-%02d", year, month, day)
            if self.selectedDates[dateKey] then
                self.selectedDates[dateKey] = nil
            else
                self.selectedDates[dateKey] = { year = year, month = month, day = day }
            end
        elseif self.rangeSelect then
            -- Range selection
            if not self.rangeStart or (self.rangeStart and self.rangeEnd) then
                -- Start new range
                self.rangeStart = { year = year, month = month, day = day }
                self.rangeEnd = nil
            else
                -- Complete range
                self.rangeEnd = { year = year, month = month, day = day }
                -- Ensure start is before end
                if self:_compareDates(self.rangeEnd, self.rangeStart) < 0 then
                    self.rangeStart, self.rangeEnd = self.rangeEnd, self.rangeStart
                end
            end
        else
            -- Single selection
            self.selectedDate = { year = year, month = month, day = day }
        end

        if self.onDateSelect then
            self.onDateSelect(year, month, day)
        end
    end
end

function Calendar:getSelectedDate()
    if self.multiSelect then
        local dates = {}
        for _, date in pairs(self.selectedDates) do
            table.insert(dates, date)
        end
        return dates
    elseif self.rangeSelect then
        return self.rangeStart, self.rangeEnd
    else
        return self.selectedDate
    end
end

function Calendar:navigateMonth(delta)
    local oldMonth, oldYear = self.displayMonth, self.displayYear

    self.displayMonth = self.displayMonth + delta

    if self.displayMonth > 12 then
        self.displayMonth = self.displayMonth - 12
        self.displayYear = self.displayYear + 1
    elseif self.displayMonth < 1 then
        self.displayMonth = self.displayMonth + 12
        self.displayYear = self.displayYear - 1
    end

    -- Animate month transition
    self.transitionDirection = delta > 0 and 1 or -1
    Animation.animateWidget(self, "monthTransition", 0, 0.3, Animation.types.EASE_OUT,
        function() self.monthTransition = 0 end)

    if self.onMonthChange then
        self.onMonthChange(self.displayYear, self.displayMonth, oldYear, oldMonth)
    end
end

function Calendar:navigateYear(delta)
    self.displayYear = self.displayYear + delta

    if self.onMonthChange then
        self.onMonthChange(self.displayYear, self.displayMonth)
    end
end

function Calendar:goToToday()
    self.displayYear = self.today.year
    self.displayMonth = self.today.month

    if self.onMonthChange then
        self.onMonthChange(self.displayYear, self.displayMonth)
    end
end

function Calendar:update(dt)
    core.Base.update(self, dt)
    Animation.update(dt)

    -- Update hover
    local mx, my = love.mouse.getPosition()
    self.hoveredDate = nil
    self.rangeHover = nil

    if self:hitTest(mx, my) then
        local date = self:_getDateFromPosition(mx, my)
        if date then
            self.hoveredDate = date

            if self.rangeSelect and self.rangeStart and not self.rangeEnd then
                self.rangeHover = date
            end

            if self.onDateHover then
                self.onDateHover(date.year, date.month, date.day)
            end
        end
    end
end

function Calendar:draw()
    core.Base.draw(self)

    -- Background
    love.graphics.setColor(unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Header with month/year and navigation
    self:_drawHeader()

    -- Day headers
    self:_drawDayHeaders()

    -- Calendar grid
    self:_drawCalendarGrid()

    -- Border
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Focus ring
    if self.focused then
        love.graphics.setColor(unpack(core.focus.focusRingColor))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", self.x - 1, self.y - 1, self.w + 2, self.h + 2)
        love.graphics.setLineWidth(1)
    end
end

function Calendar:_drawHeader()
    local headerY = self.y + 5

    -- Background
    love.graphics.setColor(unpack(core.theme.primary))
    love.graphics.rectangle("fill", self.x + 5, headerY, self.w - 10, self.headerHeight)

    -- Navigation buttons
    local buttonSize = 20
    local leftButtonX = self.x + 10
    local rightButtonX = self.x + self.w - 30

    -- Previous month button
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.print("◀", leftButtonX, headerY + 5)

    -- Next month button
    love.graphics.print("▶", rightButtonX, headerY + 5)

    -- Month and year
    local monthYear = string.format("%s %d", self.monthNames[self.displayMonth], self.displayYear)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(monthYear)
    local textX = self.x + (self.w - textWidth) / 2

    love.graphics.setColor(unpack(core.theme.textOnPrimary))
    love.graphics.print(monthYear, textX, headerY + 5)
end

function Calendar:_drawDayHeaders()
    local headerY = self.y + self.headerHeight + 5

    -- Background
    love.graphics.setColor(unpack(core.theme.surface))
    love.graphics.rectangle("fill", self.x + 5, headerY, self.w - 10, self.dayHeaderHeight)

    -- Day names
    love.graphics.setColor(unpack(core.theme.text))
    for i, dayName in ipairs(self.dayNames) do
        local cellX = self.x + 5 + (i - 1) * self.cellWidth
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(dayName)
        love.graphics.print(dayName, cellX + (self.cellWidth - textWidth) / 2, headerY + 5)
    end
end

function Calendar:_drawCalendarGrid()
    local startY = self.calendarStartY

    -- Get the first day to display
    local firstDay = getFirstDayOfMonth(self.displayMonth, self.displayYear)
    if not self.startMonday then
        firstDay = firstDay % 7 + 1 -- Convert to Sunday first
    end

    -- Calculate the first date to show
    local startDate = 1 - (firstDay - 1)
    local daysInMonth = getDaysInMonth(self.displayMonth, self.displayYear)
    local daysInPrevMonth = self.displayMonth > 1 and
        getDaysInMonth(self.displayMonth - 1, self.displayYear) or
        getDaysInMonth(12, self.displayYear - 1)

    local currentDay = startDate
    local currentMonth = self.displayMonth
    local currentYear = self.displayYear

    -- Adjust for previous month days
    if currentDay <= 0 then
        currentDay = daysInPrevMonth + currentDay
        currentMonth = currentMonth - 1
        if currentMonth <= 0 then
            currentMonth = 12
            currentYear = currentYear - 1
        end
    end

    -- Draw 6 weeks
    for week = 0, 5 do
        for day = 1, 7 do
            local cellX = self.x + 5 + (day - 1) * self.cellWidth
            local cellY = startY + week * self.cellHeight

            self:_drawDateCell(currentDay, currentMonth, currentYear, cellX, cellY)

            -- Advance to next day
            currentDay = currentDay + 1
            if currentDay > getDaysInMonth(currentMonth, currentYear) then
                currentDay = 1
                currentMonth = currentMonth + 1
                if currentMonth > 12 then
                    currentMonth = 1
                    currentYear = currentYear + 1
                end
            end
        end
    end
end

function Calendar:_drawDateCell(day, month, year, cellX, cellY)
    local isCurrentMonth = (month == self.displayMonth and year == self.displayYear)
    local isToday = self:_isSameDate(day, month, year, self.today.day, self.today.month, self.today.year)
    local isSelected = self:_isDateSelected(day, month, year)
    local isHovered = self.hoveredDate and
        self:_isSameDate(day, month, year, self.hoveredDate.day, self.hoveredDate.month, self.hoveredDate.year)
    local isEnabled = self:_isDateEnabled(day, month, year)
    local isInRange = self:_isDateInRange(day, month, year)

    -- Don't draw other month days unless specified
    if not isCurrentMonth and not self.showOtherMonths then
        return
    end

    -- Cell background
    if isInRange then
        love.graphics.setColor(unpack(core.theme.accentLight))
        love.graphics.rectangle("fill", cellX, cellY, self.cellWidth, self.cellHeight)
    end

    if isSelected then
        love.graphics.setColor(unpack(core.theme.accent))
        love.graphics.rectangle("fill", cellX + 2, cellY + 2, self.cellWidth - 4, self.cellHeight - 4)
    elseif isHovered and isEnabled then
        love.graphics.setColor(unpack(core.theme.primaryHover))
        love.graphics.rectangle("fill", cellX + 2, cellY + 2, self.cellWidth - 4, self.cellHeight - 4)
    end

    -- Today highlight
    if isToday and self.highlightToday then
        love.graphics.setColor(unpack(core.theme.accent))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", cellX + 3, cellY + 3, self.cellWidth - 6, self.cellHeight - 6)
        love.graphics.setLineWidth(1)
    end

    -- Date text
    local textColor = core.theme.text
    if not isCurrentMonth then
        textColor = core.theme.textDisabled
    elseif not isEnabled then
        textColor = core.theme.textDisabled
    elseif isSelected then
        textColor = core.theme.textOnAccent
    end

    love.graphics.setColor(unpack(textColor))
    local dayText = tostring(day)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(dayText)
    local textHeight = font:getHeight()
    local textX = cellX + (self.cellWidth - textWidth) / 2
    local textY = cellY + (self.cellHeight - textHeight) / 2

    love.graphics.print(dayText, textX, textY)

    -- Cell border
    if isCurrentMonth then
        love.graphics.setColor(unpack(core.theme.border))
        love.graphics.rectangle("line", cellX, cellY, self.cellWidth, self.cellHeight)
    end
end

function Calendar:mousepressed(x, y, button)
    if button ~= 1 or not self:hitTest(x, y) then return false end

    core.setFocus(self)

    -- Check header navigation clicks
    local headerY = self.y + 5
    if y >= headerY and y < headerY + self.headerHeight then
        local leftButtonX = self.x + 10
        local rightButtonX = self.x + self.w - 30

        if x >= leftButtonX and x < leftButtonX + 20 then
            self:navigateMonth(-1)
            return true
        elseif x >= rightButtonX and x < rightButtonX + 20 then
            self:navigateMonth(1)
            return true
        end

        -- Click on month/year for quick selection (could expand to dropdown)
        return true
    end

    -- Check date cell clicks
    local date = self:_getDateFromPosition(x, y)
    if date then
        self.pressedDate = date
        self:setDate(date.year, date.month, date.day)
        return true
    end

    return false
end

function Calendar:keypressed(key)
    if not self.focused then return core.Base.keypressed(self, key) end

    local currentSelected = self.selectedDate or self.today

    if key == "left" then
        self:_navigateDay(currentSelected, -1)
        return true
    elseif key == "right" then
        self:_navigateDay(currentSelected, 1)
        return true
    elseif key == "up" then
        self:_navigateDay(currentSelected, -7)
        return true
    elseif key == "down" then
        self:_navigateDay(currentSelected, 7)
        return true
    elseif key == "pageup" then
        self:navigateMonth(-1)
        return true
    elseif key == "pagedown" then
        self:navigateMonth(1)
        return true
    elseif key == "home" then
        self:goToToday()
        return true
    elseif key == "return" or key == "space" then
        if currentSelected then
            self:setDate(currentSelected.year, currentSelected.month, currentSelected.day)
        end
        return true
    end

    return core.Base.keypressed(self, key)
end

function Calendar:_navigateDay(fromDate, delta)
    local newDate = self:_addDays(fromDate, delta)

    if self:_isDateEnabled(newDate.year, newDate.month, newDate.day) then
        -- Update display month if needed
        if newDate.month ~= self.displayMonth or newDate.year ~= self.displayYear then
            self.displayMonth = newDate.month
            self.displayYear = newDate.year
            if self.onMonthChange then
                self.onMonthChange(self.displayYear, self.displayMonth)
            end
        end

        self:setDate(newDate.year, newDate.month, newDate.day)
    end
end

function Calendar:_addDays(date, days)
    local totalDays = self:_dateToDays(date.year, date.month, date.day) + days
    return self:_daysToDate(totalDays)
end

function Calendar:_dateToDays(year, month, day)
    -- Simple conversion (not accounting for all edge cases)
    local days = 0

    -- Add years
    for y = 1, year - 1 do
        days = days + (isLeapYear(y) and 366 or 365)
    end

    -- Add months
    for m = 1, month - 1 do
        days = days + getDaysInMonth(m, year)
    end

    -- Add days
    days = days + day

    return days
end

function Calendar:_daysToDate(totalDays)
    local year = 1
    local month = 1
    local day = totalDays

    -- Find year
    while true do
        local yearDays = isLeapYear(year) and 366 or 365
        if day <= yearDays then break end
        day = day - yearDays
        year = year + 1
    end

    -- Find month
    while true do
        local monthDays = getDaysInMonth(month, year)
        if day <= monthDays then break end
        day = day - monthDays
        month = month + 1
    end

    return { year = year, month = month, day = day }
end

function Calendar:_getDateFromPosition(x, y)
    -- Check if in calendar area
    if y < self.calendarStartY then return nil end

    local relX = x - (self.x + 5)
    local relY = y - self.calendarStartY

    if relX < 0 or relX >= 7 * self.cellWidth or relY < 0 then return nil end

    local col = math.floor(relX / self.cellWidth)
    local row = math.floor(relY / self.cellHeight)

    if col >= 7 or row >= 6 then return nil end

    -- Calculate the date for this cell
    local firstDay = getFirstDayOfMonth(self.displayMonth, self.displayYear)
    if not self.startMonday then
        firstDay = firstDay % 7 + 1
    end

    local startDate = 1 - (firstDay - 1)
    local dayOffset = row * 7 + col
    local day = startDate + dayOffset

    local month = self.displayMonth
    local year = self.displayYear

    -- Adjust for previous/next month
    if day <= 0 then
        month = month - 1
        if month <= 0 then
            month = 12
            year = year - 1
        end
        local daysInPrevMonth = getDaysInMonth(month, year)
        day = daysInPrevMonth + day
    else
        local daysInMonth = getDaysInMonth(self.displayMonth, self.displayYear)
        if day > daysInMonth then
            day = day - daysInMonth
            month = month + 1
            if month > 12 then
                month = 1
                year = year + 1
            end
        end
    end

    return { year = year, month = month, day = day }
end

-- Utility methods
function Calendar:_isValidDate(year, month, day)
    if month < 1 or month > 12 then return false end
    if day < 1 or day > getDaysInMonth(month, year) then return false end
    return true
end

function Calendar:_isDateEnabled(year, month, day)
    local date = { year = year, month = month, day = day }

    -- Check min/max dates
    if self.minDate and self:_compareDates(date, self.minDate) < 0 then return false end
    if self.maxDate and self:_compareDates(date, self.maxDate) > 0 then return false end

    -- Check disabled dates
    for _, disabledDate in ipairs(self.disabledDates) do
        if self:_isSameDate(year, month, day, disabledDate.year, disabledDate.month, disabledDate.day) then
            return false
        end
    end

    return true
end

function Calendar:_isDateSelected(year, month, day)
    if self.multiSelect then
        local dateKey = string.format("%d-%02d-%02d", year, month, day)
        return self.selectedDates[dateKey] ~= nil
    elseif self.rangeSelect then
        return self:_isDateInRange(year, month, day)
    else
        return self.selectedDate and
            self:_isSameDate(year, month, day, self.selectedDate.year, self.selectedDate.month, self.selectedDate.day)
    end
end

function Calendar:_isDateInRange(year, month, day)
    if not self.rangeSelect or not self.rangeStart then return false end

    local date = { year = year, month = month, day = day }
    local endDate = self.rangeEnd or self.rangeHover

    if not endDate then return false end

    local start = self.rangeStart
    local finish = endDate

    -- Ensure start is before end
    if self:_compareDates(finish, start) < 0 then
        start, finish = finish, start
    end

    return self:_compareDates(date, start) >= 0 and self:_compareDates(date, finish) <= 0
end

function Calendar:_isSameDate(year1, month1, day1, year2, month2, day2)
    return year1 == year2 and month1 == month2 and day1 == day2
end

function Calendar:_compareDates(date1, date2)
    if date1.year ~= date2.year then return date1.year - date2.year end
    if date1.month ~= date2.month then return date1.month - date2.month end
    return date1.day - date2.day
end

-- Public API methods
function Calendar:clearSelection()
    self.selectedDate = nil
    self.selectedDates = {}
    self.rangeStart = nil
    self.rangeEnd = nil
end

function Calendar:setDisplayMonth(year, month)
    if month >= 1 and month <= 12 then
        self.displayYear = year
        self.displayMonth = month

        if self.onMonthChange then
            self.onMonthChange(year, month)
        end
    end
end

function Calendar:setMinDate(year, month, day)
    if self:_isValidDate(year, month, day) then
        self.minDate = { year = year, month = month, day = day }
    end
end

function Calendar:setMaxDate(year, month, day)
    if self:_isValidDate(year, month, day) then
        self.maxDate = { year = year, month = month, day = day }
    end
end

function Calendar:addDisabledDate(year, month, day)
    if self:_isValidDate(year, month, day) then
        table.insert(self.disabledDates, { year = year, month = month, day = day })
    end
end

function Calendar:clearDisabledDates()
    self.disabledDates = {}
end

return Calendar






