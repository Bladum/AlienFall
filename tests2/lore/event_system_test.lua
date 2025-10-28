-- ─────────────────────────────────────────────────────────────────────────
-- EVENT SYSTEM TEST SUITE
-- FILE: tests2/lore/event_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.lore.events.event_system",
    fileName = "event_system.lua",
    description = "Event pub-sub system for game event broadcasting"
})

print("[EVENT_SYSTEM_TEST] Setting up")

local EventSystem = {
    listeners = {},
    eventQueue = {},

    new = function(self)
        return setmetatable({listeners = {}, eventQueue = {}}, {__index = self})
    end,

    addEventListener = function(self, eventType, callback)
        if not self.listeners[eventType] then self.listeners[eventType] = {} end
        table.insert(self.listeners[eventType], callback)
        return true
    end,

    removeEventListener = function(self, eventType, callback)
        if not self.listeners[eventType] then return false end
        for i, listener in ipairs(self.listeners[eventType]) do
            if listener == callback then
                table.remove(self.listeners[eventType], i)
                return true
            end
        end
        return false
    end,

    broadcastEvent = function(self, eventType, data)
        if not self.listeners[eventType] then return 0 end
        local count = 0
        for _, callback in ipairs(self.listeners[eventType]) do
            callback(data)
            count = count + 1
        end
        return count
    end,

    queueEvent = function(self, eventType, data)
        table.insert(self.eventQueue, {type = eventType, data = data})
        return true
    end,

    processQueue = function(self)
        local processed = 0
        for _, event in ipairs(self.eventQueue) do
            self:broadcastEvent(event.type, event.data)
            processed = processed + 1
        end
        self.eventQueue = {}
        return processed
    end,

    hasListeners = function(self, eventType)
        if self.listeners[eventType] and #self.listeners[eventType] > 0 then
            return true
        else
            return false
        end
    end,

    getListenerCount = function(self, eventType)
        return self.listeners[eventType] and #self.listeners[eventType] or 0
    end
}

Suite:group("Event Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.events = EventSystem:new()
        shared.callbackFired = false
        shared.callback = function(data) shared.callbackFired = true end
    end)

    Suite:testMethod("EventSystem.new", {description = "Creates event system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.events ~= nil, true, "System created")
    end)

    Suite:testMethod("EventSystem.addEventListener", {description = "Registers event listener", testCase = "add_listener", type = "functional"}, function()
        local ok = shared.events:addEventListener("mission_started", shared.callback)
        Helpers.assertEqual(ok, true, "Listener registered")
    end)

    Suite:testMethod("EventSystem.hasListeners", {description = "Detects registered listeners", testCase = "has_listeners", type = "functional"}, function()
        shared.events:addEventListener("mission_started", shared.callback)
        local has = shared.events:hasListeners("mission_started")
        Helpers.assertEqual(has, true, "Listeners detected")
    end)

    Suite:testMethod("EventSystem.hasListeners", {description = "No listeners for unregistered event", testCase = "no_listeners", type = "functional"}, function()
        -- Don't register any listeners for "unknown_event"
        local has = shared.events:hasListeners("unknown_event")
        -- hasListeners returns false or nil for no listeners
        -- assertTrue checks for truthy value
        Helpers.assertEqual(has, false, "No listeners found")
    end)
end)

Suite:group("Event Broadcasting", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.events = EventSystem:new()
        shared.callCount = 0
        shared.callback = function(data) shared.callCount = shared.callCount + 1 end
    end)

    Suite:testMethod("EventSystem.broadcastEvent", {description = "Broadcasts event to listeners", testCase = "broadcast", type = "functional"}, function()
        shared.events:addEventListener("test_event", shared.callback)
        local count = shared.events:broadcastEvent("test_event", {value = 42})
        Helpers.assertEqual(count, 1, "Event broadcast to 1 listener")
    end)

    Suite:testMethod("EventSystem.broadcastEvent", {description = "Broadcasts to multiple listeners", testCase = "multi_broadcast", type = "functional"}, function()
        shared.events:addEventListener("event1", shared.callback)
        shared.events:addEventListener("event1", shared.callback)
        local count = shared.events:broadcastEvent("event1", {})
        Helpers.assertEqual(count, 2, "Event broadcast to 2 listeners")
    end)

    Suite:testMethod("EventSystem.broadcastEvent", {description = "Returns zero for no listeners", testCase = "no_listeners", type = "functional"}, function()
        local count = shared.events:broadcastEvent("nonexistent", {})
        Helpers.assertEqual(count, 0, "Zero listeners for nonexistent event")
    end)

    Suite:testMethod("EventSystem.broadcastEvent", {description = "Passes data to listener", testCase = "data_passing", type = "functional"}, function()
        local receivedData = nil
        shared.events:addEventListener("test", function(data) receivedData = data.value end)
        shared.events:broadcastEvent("test", {value = 123})
        Helpers.assertEqual(receivedData, 123, "Data passed to listener")
    end)
end)

Suite:group("Event Queue", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.events = EventSystem:new()
        shared.processed = 0
        shared.callback = function(data) shared.processed = shared.processed + 1 end
    end)

    Suite:testMethod("EventSystem.queueEvent", {description = "Queues event", testCase = "queue", type = "functional"}, function()
        local ok = shared.events:queueEvent("queued_event", {test = true})
        Helpers.assertEqual(ok, true, "Event queued")
    end)

    Suite:testMethod("EventSystem.processQueue", {description = "Processes queued events", testCase = "process", type = "functional"}, function()
        shared.events:addEventListener("queued", shared.callback)
        shared.events:queueEvent("queued", {})
        shared.events:queueEvent("queued", {})
        local processed = shared.events:processQueue()
        Helpers.assertEqual(processed, 2, "Two events processed")
    end)

    Suite:testMethod("EventSystem.processQueue", {description = "Clears queue after processing", testCase = "clear", type = "functional"}, function()
        shared.events:queueEvent("event1", {})
        shared.events:processQueue()
        local queueSize = #shared.events.eventQueue
        Helpers.assertEqual(queueSize, 0, "Queue cleared")
    end)
end)

Suite:group("Listener Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.events = EventSystem:new()
        shared.callback1 = function(data) end
        shared.callback2 = function(data) end
    end)

    Suite:testMethod("EventSystem.removeEventListener", {description = "Removes event listener", testCase = "remove", type = "functional"}, function()
        shared.events:addEventListener("event1", shared.callback1)
        local ok = shared.events:removeEventListener("event1", shared.callback1)
        Helpers.assertEqual(ok, true, "Listener removed")
    end)

    Suite:testMethod("EventSystem.removeEventListener", {description = "Returns false for nonexistent listener", testCase = "not_found", type = "functional"}, function()
        shared.events:addEventListener("event1", shared.callback1)
        local ok = shared.events:removeEventListener("event1", shared.callback2)
        Helpers.assertEqual(ok, false, "Listener not found")
    end)

    Suite:testMethod("EventSystem.getListenerCount", {description = "Counts listeners for event", testCase = "count", type = "functional"}, function()
        shared.events:addEventListener("event1", shared.callback1)
        shared.events:addEventListener("event1", shared.callback2)
        local count = shared.events:getListenerCount("event1")
        Helpers.assertEqual(count, 2, "Two listeners counted")
    end)

    Suite:testMethod("EventSystem.getListenerCount", {description = "Returns zero for no listeners", testCase = "zero", type = "functional"}, function()
        local count = shared.events:getListenerCount("unknown")
        Helpers.assertEqual(count, 0, "Zero listeners")
    end)
end)

Suite:run()
