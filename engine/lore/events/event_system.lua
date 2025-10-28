--- Event system for pub-sub pattern game events
-- Allows systems to register event listeners and broadcast events
-- Enables loose coupling between faction, mission, terror, and campaign systems
--
-- @module EventSystem
-- @author AI Agent
-- @license MIT

local EventSystem = {}
EventSystem.__index = EventSystem

--- Event type constants
EventSystem.EVENT_TYPES = {
    FACTION_ACTIVITY_INCREASED = "faction_activity_increased",
    FACTION_ACTIVITY_DECREASED = "faction_activity_decreased",
    MISSION_GENERATED = "mission_generated",
    MISSION_STARTED = "mission_started",
    MISSION_COMPLETED = "mission_completed",
    MISSION_STOPPED = "mission_stopped",
    TERROR_ATTACK_STARTED = "terror_attack_started",
    TERROR_ATTACK_ESCALATED = "terror_attack_escalated",
    TERROR_ATTACK_STOPPED = "terror_attack_stopped",
    TERROR_LOCATION_CLEARED = "terror_location_cleared",
    CONTROL_LOST = "control_lost",
    CONTROL_GAINED = "control_gained",
    ALIEN_THREAT_ESCALATION = "alien_threat_escalation",
    ALIEN_THREAT_REDUCTION = "alien_threat_reduction",
    PLAYER_RESEARCH_PROGRESS = "player_research_progress",
    UFO_DETECTED = "ufo_detected",
    UFO_DESTROYED = "ufo_destroyed",
    REGION_MORALE_CHANGED = "region_morale_changed",
    REGION_ECONOMY_CHANGED = "region_economy_changed",
}

--- Create new event system
-- @return EventSystem - New event system instance
function EventSystem.new()
    local self = setmetatable({}, EventSystem)

    -- Map of event type -> array of callbacks
    self.listeners = {}

    -- Event history (last 100 events)
    self.history = {}
    self.history_max_size = 100

    return self
end

--- Register listener for event type
-- Multiple listeners can register for same event type
-- @param event_type string - Event type to listen for (use EventSystem.EVENT_TYPES constants)
-- @param callback function - Callback function(event_data) to execute
-- @return boolean - True if registered successfully
function EventSystem:register(event_type, callback)
    if not callback or type(callback) ~= "function" then
        print("[EventSystem] ERROR: Callback must be a function")
        return false
    end

    if not self.listeners[event_type] then
        self.listeners[event_type] = {}
    end

    table.insert(self.listeners[event_type], callback)
    return true
end

--- Unregister listener for event type
-- @param event_type string - Event type
-- @param callback function - Callback to remove
-- @return boolean - True if found and removed
function EventSystem:unregister(event_type, callback)
    if not self.listeners[event_type] then
        return false
    end

    for i, cb in ipairs(self.listeners[event_type]) do
        if cb == callback then
            table.remove(self.listeners[event_type], i)
            return true
        end
    end

    return false
end

--- Broadcast event to all registered listeners
-- Calls all callbacks registered for this event type with event data
-- @param event_type string - Event type
-- @param event_data table - Event data to pass to callbacks
-- @return number - Number of listeners called
function EventSystem:broadcast(event_type, event_data)
    event_data = event_data or {}
    event_data.type = event_type
    event_data.timestamp = 0  -- Will be set by caller (campaign turn)

    -- Add to history
    self:_addToHistory(event_data)

    -- Call all registered listeners
    local listener_count = 0
    if self.listeners[event_type] then
        for _, callback in ipairs(self.listeners[event_type]) do
            local ok, err = pcall(callback, event_data)
            if not ok then
                print("[EventSystem] ERROR in listener for " .. event_type .. ": " .. tostring(err))
            else
                listener_count = listener_count + 1
            end
        end
    end

    return listener_count
end

--- Get all listeners for event type
-- @param event_type string - Event type
-- @return number - Count of registered listeners
function EventSystem:getListenerCount(event_type)
    if not self.listeners[event_type] then
        return 0
    end
    return #self.listeners[event_type]
end

--- Add event to history (internal use)
-- @param event_data table - Event to record
function EventSystem:_addToHistory(event_data)
    table.insert(self.history, {
        type = event_data.type,
        timestamp = event_data.timestamp,
        data = event_data,
    })

    -- Keep only recent history
    while #self.history > self.history_max_size do
        table.remove(self.history, 1)
    end
end

--- Get event history for specific type
-- @param event_type string|nil - Event type (nil for all)
-- @return table - Array of events (most recent first)
function EventSystem:getHistory(event_type)
    local results = {}

    -- Iterate backwards for most recent first
    for i = #self.history, 1, -1 do
        local entry = self.history[i]
        if not event_type or entry.type == event_type then
            table.insert(results, entry)
        end
    end

    return results
end

--- Get recent events (last N)
-- @param count number - How many recent events to return
-- @return table - Array of recent events
function EventSystem:getRecentEvents(count)
    count = math.min(count or 10, #self.history)
    local results = {}

    for i = #self.history - count + 1, #self.history do
        if i >= 1 then
            table.insert(results, self.history[i])
        end
    end

    return results
end

--- Clear all history
function EventSystem:clearHistory()
    self.history = {}
end

--- Serialize event system for save/load
-- @return table - Serialized state
function EventSystem:serialize()
    return {
        history = self.history,
    }
end

--- Deserialize event system from save data
-- @param data table - Serialized state
-- @return EventSystem - Restored system
function EventSystem.deserialize(data)
    local self = setmetatable({}, EventSystem)

    self.listeners = {}
    self.history = data.history or {}
    self.history_max_size = 100

    return self
end

--- Get event statistics
-- @return table - Stats on events recorded
function EventSystem:getStatistics()
    local stats = {
        total_events = #self.history,
        event_types = {},
    }

    for _, entry in ipairs(self.history) do
        local event_type = entry.type
        stats.event_types[event_type] = (stats.event_types[event_type] or 0) + 1
    end

    return stats
end

--- Create standard event data structure
-- Helper for creating properly formatted event data
-- @param event_type string - Event type constant
-- @param data table - Additional data
-- @return table - Formatted event data
function EventSystem.createEventData(event_type, data)
    data = data or {}
    data.type = event_type
    return data
end

return EventSystem
