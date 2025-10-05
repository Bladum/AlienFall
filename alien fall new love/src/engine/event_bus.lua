--- Event Bus for decoupled communication between game systems
-- Provides publish-subscribe pattern for event-driven architecture
-- Supports prioritized listeners, one-time handlers, and telemetry
--
-- @module engine.event_bus

local EventBus = {}
EventBus.__index = EventBus

--- Validate that a topic name is valid
-- @param topic string: Topic name to validate
local function validateTopic(topic)
    assert(type(topic) == "string" and topic ~= "", "EventBus topic must be a non-empty string")
end

--- Create a new event bus instance
-- @param opts table: Configuration options
-- @param opts.telemetry table: Optional telemetry service for event tracking
-- @return EventBus: New event bus instance
function EventBus.new(opts)
    local self = setmetatable({}, EventBus)
    self.listeners = {}  -- topic -> array of listener objects
    self.telemetry = opts and opts.telemetry or nil
    self.nextId = 1  -- Monotonically increasing token generator
    return self
end

--- Subscribe to events on a specific topic
-- Listeners are sorted by priority (higher priority first)
-- @param topic string: Event topic to listen for
-- @param handler function: Function to call when event is published
-- @param options table: Optional listener configuration
-- @param options.once boolean: If true, handler is removed after first call
-- @param options.priority number: Sort priority (higher = called first)
-- @param options.scope string: Optional scope identifier for organization
-- @param options.owner any: Owner object for automatic cleanup (recommended)
-- @return number: Subscription token for unsubscribing
function EventBus:subscribe(topic, handler, options)
    validateTopic(topic)
    assert(type(handler) == "function", "EventBus handler must be a function")

    local token = self.nextId
    self.nextId = self.nextId + 1

    local listener = {
        handler = handler,
        token = token,
        once = options and options.once or false,
        priority = options and options.priority or 0,
        scope = options and options.scope or nil,
        owner = options and options.owner or nil
    }

    -- Initialize topic listener array if needed
    if not self.listeners[topic] then
        self.listeners[topic] = {}
    end

    -- Add listener and sort by priority (higher priority first)
    table.insert(self.listeners[topic], listener)
    table.sort(self.listeners[topic], function(a, b)
        if a.priority == b.priority then
            -- Stable sort by token for same priority
            return a.token < b.token
        end
        return a.priority > b.priority
    end)

    return token
end

--- Unsubscribe from events on a topic
-- @param topic string: Event topic
-- @param token number: Subscription token from subscribe()
-- @return boolean: True if subscription was found and removed
function EventBus:unsubscribe(topic, token)
    validateTopic(topic)
    if not self.listeners[topic] or not token then
        return false
    end

    local listeners = self.listeners[topic]
    -- Search from end to avoid index shifting issues during removal
    for idx = #listeners, 1, -1 do
        if listeners[idx].token == token then
            table.remove(listeners, idx)
            return true
        end
    end

    return false
end

--- Publish an event to all subscribers of a topic
-- Calls handlers in priority order, handles errors gracefully
-- @param topic string: Event topic to publish
-- @param payload any: Data to pass to event handlers
-- @return number: Number of handlers that were called
function EventBus:publish(topic, payload)
    validateTopic(topic)

    -- Record event in telemetry if available
    if self.telemetry then
        self.telemetry:recordEvent({
            type = "event",
            topic = topic,
            payload = payload
        })
    end

    local listeners = self.listeners[topic]
    if not listeners or #listeners == 0 then
        return 0
    end

    local dispatched = 0
    -- Create snapshot to prevent mutation during iteration
    local snapshot = {}
    for i = 1, #listeners do
        snapshot[i] = listeners[i]
    end

    -- Call each handler, removing one-time listeners after execution
    for _, listener in ipairs(snapshot) do
        if listener.once then
            self:unsubscribe(topic, listener.token)
        end

        -- Use pcall to prevent one failing handler from breaking others
        local ok, err = pcall(listener.handler, payload)
        if not ok and self.telemetry then
            self.telemetry:recordEvent({
                type = "event-error",
                topic = topic,
                error = err
            })
        end
        dispatched = dispatched + 1
    end

    return dispatched
end

--- Unsubscribe all listeners owned by a specific owner
-- Useful for automatic cleanup when objects are destroyed
-- @param owner any: Owner object to clean up
-- @return number: Number of subscriptions removed
function EventBus:unsubscribeAll(owner)
    if not owner then
        return 0
    end
    
    local removed = 0
    
    for topic, listeners in pairs(self.listeners) do
        for idx = #listeners, 1, -1 do
            if listeners[idx].owner == owner then
                table.remove(listeners, idx)
                removed = removed + 1
            end
        end
    end
    
    if self.telemetry and removed > 0 then
        self.telemetry:recordEvent({
            type = "event-cleanup",
            owner = tostring(owner),
            removed = removed
        })
    end
    
    return removed
end

--- Unsubscribe all listeners for a specific topic
-- @param topic string: Event topic to clear
-- @return number: Number of subscriptions removed
function EventBus:unsubscribeTopic(topic)
    validateTopic(topic)
    
    if not self.listeners[topic] then
        return 0
    end
    
    local count = #self.listeners[topic]
    self.listeners[topic] = {}
    
    return count
end

--- Get debug information about current subscriptions
-- @return table: Debug information about listeners
function EventBus:getDebugInfo()
    local info = {
        totalListeners = 0,
        byTopic = {}
    }
    
    for topic, listeners in pairs(self.listeners) do
        info.byTopic[topic] = {
            count = #listeners,
            listeners = {}
        }
        
        for _, listener in ipairs(listeners) do
            table.insert(info.byTopic[topic].listeners, {
                token = listener.token,
                priority = listener.priority,
                scope = listener.scope,
                owner = tostring(listener.owner),
                once = listener.once
            })
        end
        
        info.totalListeners = info.totalListeners + #listeners
    end
    
    return info
end

--- Clear all event subscriptions
-- Resets the event bus to initial state
function EventBus:clear()
    self.listeners = {}
    self.nextId = 1
end

return EventBus
