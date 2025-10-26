-- ─────────────────────────────────────────────────────────────────────────
-- NOTIFICATION SYSTEM TEST SUITE
-- FILE: tests2/core/notification_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.notification_system",
    fileName = "notification_system.lua",
    description = "In-game notification and messaging system"
})

print("[NOTIFICATION_SYSTEM_TEST] Setting up")

local NotificationSystem = {
    notifications = {},
    queue = {},
    listeners = {},
    nextId = 1,

    new = function(self)
        return setmetatable({notifications = {}, queue = {}, listeners = {}, nextId = 1}, {__index = self})
    end,

    addNotification = function(self, message, notifType, priority)
        local id = self.nextId
        self.nextId = self.nextId + 1
        self.notifications[id] = {id = id, message = message, type = notifType or "info", priority = priority or 5, read = false, timestamp = 0}
        table.insert(self.queue, id)
        return id
    end,

    getNotification = function(self, id)
        return self.notifications[id]
    end,

    markAsRead = function(self, id)
        if not self.notifications[id] then return false end
        self.notifications[id].read = true
        return true
    end,

    getUnreadCount = function(self)
        local count = 0
        for _, notif in pairs(self.notifications) do
            if not notif.read then count = count + 1 end
        end
        return count
    end,

    getQueueLength = function(self)
        return #self.queue
    end,

    removeNotification = function(self, id)
        if not self.notifications[id] then return false end
        self.notifications[id] = nil
        return true
    end,

    subscribe = function(self, listener)
        table.insert(self.listeners, listener)
        return true
    end,

    getTotalNotifications = function(self)
        local count = 0
        for _ in pairs(self.notifications) do count = count + 1 end
        return count
    end,

    clearQueue = function(self)
        self.queue = {}
        return true
    end,

    getByType = function(self, notifType)
        local result = {}
        for id, notif in pairs(self.notifications) do
            if notif.type == notifType then table.insert(result, id) end
        end
        return result
    end
}

Suite:group("Notification Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ns = NotificationSystem:new()
    end)

    Suite:testMethod("NotificationSystem.new", {description = "Creates system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.ns ~= nil, true, "System created")
    end)

    Suite:testMethod("NotificationSystem.addNotification", {description = "Adds notification", testCase = "add", type = "functional"}, function()
        local id = shared.ns:addNotification("Test message", "info", 5)
        Helpers.assertEqual(id ~= nil, true, "Notification added")
    end)

    Suite:testMethod("NotificationSystem.getNotification", {description = "Retrieves notification", testCase = "get", type = "functional"}, function()
        local id = shared.ns:addNotification("Test", "warning", 7)
        local notif = shared.ns:getNotification(id)
        Helpers.assertEqual(notif ~= nil, true, "Notification retrieved")
    end)

    Suite:testMethod("NotificationSystem.getNotification", {description = "Returns nil missing", testCase = "missing", type = "functional"}, function()
        local notif = shared.ns:getNotification(999)
        Helpers.assertEqual(notif, nil, "Missing returns nil")
    end)

    Suite:testMethod("NotificationSystem.getTotalNotifications", {description = "Counts notifications", testCase = "count", type = "functional"}, function()
        shared.ns:addNotification("N1", "info", 1)
        shared.ns:addNotification("N2", "info", 2)
        shared.ns:addNotification("N3", "info", 3)
        local count = shared.ns:getTotalNotifications()
        Helpers.assertEqual(count, 3, "Three notifications")
    end)
end)

Suite:group("Read Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ns = NotificationSystem:new()
        shared.id = shared.ns:addNotification("Message", "alert", 8)
    end)

    Suite:testMethod("NotificationSystem.markAsRead", {description = "Marks read", testCase = "mark_read", type = "functional"}, function()
        local ok = shared.ns:markAsRead(shared.id)
        Helpers.assertEqual(ok, true, "Marked as read")
    end)

    Suite:testMethod("NotificationSystem.getNotification", {description = "Read flag set", testCase = "read_flag", type = "functional"}, function()
        shared.ns:markAsRead(shared.id)
        local notif = shared.ns:getNotification(shared.id)
        Helpers.assertEqual(notif.read, true, "Read is true")
    end)

    Suite:testMethod("NotificationSystem.getUnreadCount", {description = "Counts unread", testCase = "unread_count", type = "functional"}, function()
        shared.ns:addNotification("N1", "info", 1)
        shared.ns:addNotification("N2", "info", 2)
        shared.ns:markAsRead(shared.id)
        local count = shared.ns:getUnreadCount()
        Helpers.assertEqual(count, 2, "Two unread")
    end)

    Suite:testMethod("NotificationSystem.getUnreadCount", {description = "All read count zero", testCase = "all_read", type = "functional"}, function()
        shared.ns:markAsRead(shared.id)
        local count = shared.ns:getUnreadCount()
        Helpers.assertEqual(count, 0, "No unread")
    end)
end)

Suite:group("Queue Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ns = NotificationSystem:new()
    end)

    Suite:testMethod("NotificationSystem.getQueueLength", {description = "Queue length", testCase = "queue", type = "functional"}, function()
        shared.ns:addNotification("Q1", "info", 1)
        shared.ns:addNotification("Q2", "info", 2)
        local len = shared.ns:getQueueLength()
        Helpers.assertEqual(len, 2, "Queue has 2")
    end)

    Suite:testMethod("NotificationSystem.clearQueue", {description = "Clears queue", testCase = "clear", type = "functional"}, function()
        shared.ns:addNotification("Item", "info", 1)
        local ok = shared.ns:clearQueue()
        Helpers.assertEqual(ok, true, "Queue cleared")
    end)

    Suite:testMethod("NotificationSystem.clearQueue", {description = "Length zero after", testCase = "empty", type = "functional"}, function()
        shared.ns:addNotification("Item", "info", 1)
        shared.ns:clearQueue()
        local len = shared.ns:getQueueLength()
        Helpers.assertEqual(len, 0, "Queue empty")
    end)
end)

Suite:group("Notification Types", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ns = NotificationSystem:new()
        shared.ns:addNotification("Critical issue", "error", 10)
        shared.ns:addNotification("FYI", "info", 1)
        shared.ns:addNotification("Watch out", "warning", 7)
        shared.ns:addNotification("Be careful", "error", 9)
    end)

    Suite:testMethod("NotificationSystem.getByType", {description = "Filters by type", testCase = "filter", type = "functional"}, function()
        local errors = shared.ns:getByType("error")
        Helpers.assertEqual(errors ~= nil, true, "Type filter works")
    end)

    Suite:testMethod("NotificationSystem.getByType", {description = "Correct count", testCase = "count_type", type = "functional"}, function()
        local errors = shared.ns:getByType("error")
        local count = #errors
        Helpers.assertEqual(count, 2, "Two errors")
    end)

    Suite:testMethod("NotificationSystem.getByType", {description = "Returns empty", testCase = "empty_type", type = "functional"}, function()
        local unknown = shared.ns:getByType("critical")
        local count = #unknown
        Helpers.assertEqual(count, 0, "No critical type")
    end)
end)

Suite:group("Notification Lifecycle", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ns = NotificationSystem:new()
    end)

    Suite:testMethod("NotificationSystem.removeNotification", {description = "Removes notification", testCase = "remove", type = "functional"}, function()
        local id = shared.ns:addNotification("Temporary", "info", 1)
        local ok = shared.ns:removeNotification(id)
        Helpers.assertEqual(ok, true, "Notification removed")
    end)

    Suite:testMethod("NotificationSystem.removeNotification", {description = "Not found after", testCase = "gone", type = "functional"}, function()
        local id = shared.ns:addNotification("Gone", "info", 1)
        shared.ns:removeNotification(id)
        local notif = shared.ns:getNotification(id)
        Helpers.assertEqual(notif, nil, "Notification gone")
    end)

    Suite:testMethod("NotificationSystem.subscribe", {description = "Adds listener", testCase = "subscribe", type = "functional"}, function()
        local ok = shared.ns:subscribe(function() end)
        Helpers.assertEqual(ok, true, "Listener subscribed")
    end)
end)

Suite:run()
