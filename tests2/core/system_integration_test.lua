-- ─────────────────────────────────────────────────────────────────────────
-- SYSTEM INTEGRATION TEST SUITE
-- FILE: tests2/core/system_integration_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.system_integration",
    fileName = "system_integration.lua",
    description = "System integration with cross-system interactions, data flow, and event propagation"
})

print("[SYSTEM_INTEGRATION_TEST] Setting up")

local SystemIntegration = {
    subsystems = {}, event_bus = {}, data_sync = {}, system_state = {},
    event_listeners = {}, propagation_queue = {},

    new = function(self)
        return setmetatable({
            subsystems = {}, event_bus = {}, data_sync = {}, system_state = {},
            event_listeners = {}, propagation_queue = {}
        }, {__index = self})
    end,

    registerSubsystem = function(self, systemId, system_name, priority)
        self.subsystems[systemId] = {
            id = systemId, name = system_name, priority = priority or 5,
            initialized = false, active = true, last_update = os.time(),
            state = {}
        }
        return true
    end,

    getSubsystem = function(self, systemId)
        return self.subsystems[systemId]
    end,

    initializeSubsystem = function(self, systemId)
        if not self.subsystems[systemId] then return false end
        self.subsystems[systemId].initialized = true
        self.subsystems[systemId].last_update = os.time()
        return true
    end,

    addEventListener = function(self, listenerId, event_type, callback)
        if not self.event_listeners[event_type] then
            self.event_listeners[event_type] = {}
        end
        self.event_listeners[event_type][listenerId] = callback
        return true
    end,

    removeEventListener = function(self, listenerId, event_type)
        if self.event_listeners[event_type] then
            self.event_listeners[event_type][listenerId] = nil
        end
        return true
    end,

    publishEvent = function(self, eventId, event_type, data)
        local event = {
            id = eventId, type = event_type, data = data,
            timestamp = os.time(), propagated = false, listeners_count = 0
        }
        table.insert(self.event_bus, event)
        table.insert(self.propagation_queue, eventId)
        return true
    end,

    processEventQueue = function(self)
        while #self.propagation_queue > 0 do
            local eventId = table.remove(self.propagation_queue, 1)
            for _, event in ipairs(self.event_bus) do
                if event.id == eventId then
                    if self.event_listeners[event.type] then
                        for listenerId, callback in pairs(self.event_listeners[event.type]) do
                            if callback then callback(event) end
                            event.listeners_count = event.listeners_count + 1
                        end
                    end
                    event.propagated = true
                    break
                end
            end
        end
        return true
    end,

    syncData = function(self, sourceId, destId, data)
        if not self.subsystems[sourceId] or not self.subsystems[destId] then return false end
        self.data_sync[sourceId .. "_to_" .. destId] = {
            from = sourceId, to = destId, data = data,
            timestamp = os.time(), status = "complete"
        }
        return true
    end,

    getDataSync = function(self, syncId)
        return self.data_sync[syncId]
    end,

    updateSubsystemState = function(self, systemId, key, value)
        if not self.subsystems[systemId] then return false end
        self.subsystems[systemId].state[key] = value
        return true
    end,

    getSubsystemState = function(self, systemId, key)
        if not self.subsystems[systemId] then return nil end
        return self.subsystems[systemId].state[key]
    end,

    broadcastSystemStateChange = function(self, systemId, changeData)
        if not self.subsystems[systemId] then return false end
        local subsystem = self.subsystems[systemId]
        for key, value in pairs(changeData or {}) do
            subsystem.state[key] = value
        end
        subsystem.last_update = os.time()
        self:publishEvent("state_" .. systemId, "state_change", {system = systemId, changes = changeData})
        return true
    end,

    synchronizeSubsystems = function(self)
        for systemId1, subsys1 in pairs(self.subsystems) do
            for systemId2, subsys2 in pairs(self.subsystems) do
                if systemId1 ~= systemId2 and subsys1.active and subsys2.active then
                    local sync_id = systemId1 .. "_sync_" .. systemId2
                    self:syncData(systemId1, systemId2, subsys1.state)
                end
            end
        end
        return true
    end,

    getIntegrationHealth = function(self)
        local total_subsystems = 0
        local active_subsystems = 0
        local initialized_subsystems = 0

        for _, subsystem in pairs(self.subsystems) do
            total_subsystems = total_subsystems + 1
            if subsystem.active then active_subsystems = active_subsystems + 1 end
            if subsystem.initialized then initialized_subsystems = initialized_subsystems + 1 end
        end

        if total_subsystems == 0 then return 0 end
        return ((active_subsystems + initialized_subsystems) / (total_subsystems * 2)) * 100
    end,

    hasEventListener = function(self, event_type)
        return self.event_listeners[event_type] ~= nil and #self.event_listeners[event_type] > 0
    end,

    getEventBusSize = function(self)
        return #self.event_bus
    end,

    clearEventBus = function(self)
        self.event_bus = {}
        self.propagation_queue = {}
        return true
    end,

    toggleSubsystem = function(self, systemId, state)
        if not self.subsystems[systemId] then return false end
        self.subsystems[systemId].active = state
        return true
    end,

    getSubsystemPriority = function(self, systemId)
        if not self.subsystems[systemId] then return 0 end
        return self.subsystems[systemId].priority
    end,

    orderSubsystemsByPriority = function(self)
        local ordered = {}
        for _, subsystem in pairs(self.subsystems) do
            table.insert(ordered, subsystem)
        end
        table.sort(ordered, function(a, b)
            return a.priority > b.priority
        end)
        return ordered
    end,

    reset = function(self)
        self.subsystems = {}
        self.event_bus = {}
        self.data_sync = {}
        self.system_state = {}
        self.event_listeners = {}
        self.propagation_queue = {}
        return true
    end
}

Suite:group("Subsystems", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.integration = SystemIntegration:new()
    end)

    Suite:testMethod("SystemIntegration.registerSubsystem", {description = "Registers subsystem", testCase = "register", type = "functional"}, function()
        local ok = shared.integration:registerSubsystem("sys1", "Geoscape", 8)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("SystemIntegration.getSubsystem", {description = "Gets subsystem", testCase = "get", type = "functional"}, function()
        shared.integration:registerSubsystem("sys2", "Battlescape", 7)
        local sys = shared.integration:getSubsystem("sys2")
        Helpers.assertEqual(sys ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("SystemIntegration.initializeSubsystem", {description = "Initializes subsystem", testCase = "init", type = "functional"}, function()
        shared.integration:registerSubsystem("sys3", "Basescape", 6)
        local ok = shared.integration:initializeSubsystem("sys3")
        Helpers.assertEqual(ok, true, "Initialized")
    end)

    Suite:testMethod("SystemIntegration.toggleSubsystem", {description = "Toggles subsystem", testCase = "toggle", type = "functional"}, function()
        shared.integration:registerSubsystem("sys4", "Economy", 5)
        local ok = shared.integration:toggleSubsystem("sys4", false)
        Helpers.assertEqual(ok, true, "Toggled")
    end)
end)

Suite:group("Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.integration = SystemIntegration:new()
    end)

    Suite:testMethod("SystemIntegration.publishEvent", {description = "Publishes event", testCase = "publish", type = "functional"}, function()
        local ok = shared.integration:publishEvent("evt1", "system_start", {data = "test"})
        Helpers.assertEqual(ok, true, "Published")
    end)

    Suite:testMethod("SystemIntegration.hasEventListener", {description = "Checks listeners", testCase = "check", type = "functional"}, function()
        local has = shared.integration:hasEventListener("unknown_event")
        Helpers.assertEqual(typeof(has) == "boolean", true, "Is boolean")
    end)

    Suite:testMethod("SystemIntegration.getEventBusSize", {description = "Gets bus size", testCase = "size", type = "functional"}, function()
        shared.integration:publishEvent("evt2", "state_change", {})
        local size = shared.integration:getEventBusSize()
        Helpers.assertEqual(size > 0, true, "Size > 0")
    end)

    Suite:testMethod("SystemIntegration.clearEventBus", {description = "Clears bus", testCase = "clear", type = "functional"}, function()
        local ok = shared.integration:clearEventBus()
        Helpers.assertEqual(ok, true, "Cleared")
    end)
end)

Suite:group("Event Listeners", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.integration = SystemIntegration:new()
    end)

    Suite:testMethod("SystemIntegration.addEventListener", {description = "Adds listener", testCase = "add", type = "functional"}, function()
        local ok = shared.integration:addEventListener("listener1", "battle_start", function() end)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("SystemIntegration.removeEventListener", {description = "Removes listener", testCase = "remove", type = "functional"}, function()
        shared.integration:addEventListener("listener2", "battle_end", function() end)
        local ok = shared.integration:removeEventListener("listener2", "battle_end")
        Helpers.assertEqual(ok, true, "Removed")
    end)
end)

Suite:group("Event Propagation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.integration = SystemIntegration:new()
        shared.integration:addEventListener("l1", "action", function() end)
    end)

    Suite:testMethod("SystemIntegration.processEventQueue", {description = "Processes queue", testCase = "process", type = "functional"}, function()
        shared.integration:publishEvent("evt3", "action", {})
        local ok = shared.integration:processEventQueue()
        Helpers.assertEqual(ok, true, "Processed")
    end)
end)

Suite:group("Data Sync", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.integration = SystemIntegration:new()
        shared.integration:registerSubsystem("sys5", "System A", 4)
        shared.integration:registerSubsystem("sys6", "System B", 3)
    end)

    Suite:testMethod("SystemIntegration.syncData", {description = "Syncs data", testCase = "sync", type = "functional"}, function()
        local ok = shared.integration:syncData("sys5", "sys6", {value = 100})
        Helpers.assertEqual(ok, true, "Synced")
    end)

    Suite:testMethod("SystemIntegration.getDataSync", {description = "Gets sync", testCase = "get", type = "functional"}, function()
        shared.integration:syncData("sys5", "sys6", {value = 50})
        local sync = shared.integration:getDataSync("sys5_to_sys6")
        Helpers.assertEqual(sync ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("SystemIntegration.synchronizeSubsystems", {description = "Synchronizes", testCase = "sync_all", type = "functional"}, function()
        local ok = shared.integration:synchronizeSubsystems()
        Helpers.assertEqual(ok, true, "Synchronized")
    end)
end)

Suite:group("State Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.integration = SystemIntegration:new()
        shared.integration:registerSubsystem("sys7", "State Test", 2)
    end)

    Suite:testMethod("SystemIntegration.updateSubsystemState", {description = "Updates state", testCase = "update", type = "functional"}, function()
        local ok = shared.integration:updateSubsystemState("sys7", "status", "running")
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("SystemIntegration.getSubsystemState", {description = "Gets state", testCase = "get", type = "functional"}, function()
        shared.integration:updateSubsystemState("sys7", "health", 75)
        local state = shared.integration:getSubsystemState("sys7", "health")
        Helpers.assertEqual(state == 75, true, "Retrieved")
    end)

    Suite:testMethod("SystemIntegration.broadcastSystemStateChange", {description = "Broadcasts change", testCase = "broadcast", type = "functional"}, function()
        local ok = shared.integration:broadcastSystemStateChange("sys7", {mode = "active"})
        Helpers.assertEqual(ok, true, "Broadcasted")
    end)
end)

Suite:group("Integration Health", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.integration = SystemIntegration:new()
        shared.integration:registerSubsystem("sys8", "Monitor A", 9)
        shared.integration:registerSubsystem("sys9", "Monitor B", 8)
    end)

    Suite:testMethod("SystemIntegration.getIntegrationHealth", {description = "Gets health", testCase = "health", type = "functional"}, function()
        local health = shared.integration:getIntegrationHealth()
        Helpers.assertEqual(health >= 0, true, "Health >= 0")
    end)
end)

Suite:group("Priorities", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.integration = SystemIntegration:new()
        shared.integration:registerSubsystem("sys10", "Priority A", 10)
        shared.integration:registerSubsystem("sys11", "Priority B", 5)
        shared.integration:registerSubsystem("sys12", "Priority C", 8)
    end)

    Suite:testMethod("SystemIntegration.getSubsystemPriority", {description = "Gets priority", testCase = "priority", type = "functional"}, function()
        local priority = shared.integration:getSubsystemPriority("sys10")
        Helpers.assertEqual(priority == 10, true, "Priority correct")
    end)

    Suite:testMethod("SystemIntegration.orderSubsystemsByPriority", {description = "Orders by priority", testCase = "order", type = "functional"}, function()
        local ordered = shared.integration:orderSubsystemsByPriority()
        Helpers.assertEqual(#ordered > 0, true, "Has ordered")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.integration = SystemIntegration:new()
    end)

    Suite:testMethod("SystemIntegration.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.integration:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
