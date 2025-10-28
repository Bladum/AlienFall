---Event Tracker - Track gameplay events for analytics
---
---Records and categorizes game events including combat, movement, research,
---economy events, etc. Used for gameplay analytics and metrics collection.
---
---@module event_tracker
---@author AlienFall Development Team
---@license Open Source

local EventTracker = {}
EventTracker.__index = EventTracker

function EventTracker.new()
    local self = setmetatable({}, EventTracker)

    self.events = {}
    self.eventQueue = {}
    self.categories = {
        "combat",
        "movement",
        "research",
        "economy",
        "diplomacy",
        "facility",
        "unit",
        "mission",
        "ai_decision",
    }

    print("[EventTracker] Event tracker initialized")
    return self
end

---Record a gameplay event
---
---@param category string Event category
---@param data table Event data
function EventTracker:recordEvent(category, data)
    if not table.concat(self.categories, ","):find(category) then
        print("[EventTracker] WARNING: Unknown category: " .. category)
    end

    local event = {
        category = category,
        timestamp = love.timer.getTime(),
        data = data,
    }

    table.insert(self.eventQueue, event)
end

---Get recorded events
---
---@return table Array of recorded events
function EventTracker:getEvents()
    return self.events
end

---Clear event queue
function EventTracker:flush()
    for _, event in ipairs(self.eventQueue) do
        table.insert(self.events, event)
    end
    self.eventQueue = {}
end

return EventTracker

