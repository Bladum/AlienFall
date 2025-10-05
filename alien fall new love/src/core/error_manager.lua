--- Error Manager Service for handling and displaying errors
-- Provides centralized error handling with user-friendly notifications
-- Integrates with event bus and logger for comprehensive error tracking
--
-- @module core.error_manager

local ErrorNotification = require("widgets.ErrorNotification")

local ErrorManager = {}
ErrorManager.__index = ErrorManager

--- Create new error manager instance
-- @param opts table: Configuration options
-- @param opts.registry table: Service registry for logger/event_bus access
-- @param opts.maxNotifications number: Max simultaneous notifications (default: 3)
-- @return ErrorManager: New instance
function ErrorManager.new(opts)
    local self = setmetatable({}, ErrorManager)
    opts = opts or {}
    
    self.registry = opts.registry
    self.maxNotifications = opts.maxNotifications or 3
    self.notifications = {}
    self.errorLog = {}  -- History of all errors
    self.maxLogSize = 100
    
    return self
end

--- Get logger instance
function ErrorManager:getLogger()
    if self.registry then
        return self.registry:resolve("logger")
    end
    return nil
end

--- Get event bus instance
function ErrorManager:getEventBus()
    if self.registry then
        return self.registry:resolve("event_bus")
    end
    return nil
end

--- Show an error notification to the user
-- @param opts table: Notification options (see ErrorNotification.new)
function ErrorManager:showError(opts)
    opts = opts or {}
    
    -- Log the error
    local logger = self:getLogger()
    if logger then
        local logLevel = opts.severity == "critical" and "error" or "warn"
        logger[logLevel](logger, string.format("[%s] %s: %s", 
            opts.severity or "error",
            opts.title or "Error",
            opts.message or "Unknown error"))
    end
    
    -- Add to error history
    table.insert(self.errorLog, 1, {
        timestamp = os.time(),
        severity = opts.severity or "error",
        title = opts.title,
        message = opts.message,
        context = opts.context
    })
    
    -- Trim log if too large
    while #self.errorLog > self.maxLogSize do
        table.remove(self.errorLog)
    end
    
    -- Publish error event
    local eventBus = self:getEventBus()
    if eventBus then
        eventBus:publish("error:occurred", {
            severity = opts.severity,
            title = opts.title,
            message = opts.message
        })
    end
    
    -- Remove oldest notification if at max capacity
    if #self.notifications >= self.maxNotifications then
        table.remove(self.notifications, 1)
    end
    
    -- Create notification with dismiss callback
    local originalDismiss = opts.onDismiss
    opts.onDismiss = function()
        self:removeNotification(notification)
        if originalDismiss then
            originalDismiss()
        end
    end
    
    local notification = ErrorNotification.new(opts)
    table.insert(self.notifications, notification)
    
    -- Stack notifications vertically
    self:repositionNotifications()
    
    return notification
end

--- Reposition all notifications in a stack
function ErrorManager:repositionNotifications()
    local y = 100
    local spacing = 10
    
    for i, notification in ipairs(self.notifications) do
        notification.x = (800 - notification.width) / 2
        notification.y = y
        y = y + notification.height + spacing
    end
end

--- Remove a specific notification
-- @param notification ErrorNotification: Notification to remove
function ErrorManager:removeNotification(notification)
    for i, notif in ipairs(self.notifications) do
        if notif == notification then
            table.remove(self.notifications, i)
            self:repositionNotifications()
            return true
        end
    end
    return false
end

--- Show info notification
-- @param message string: Info message
-- @param opts table: Optional additional options
function ErrorManager:showInfo(message, opts)
    opts = opts or {}
    opts.message = message
    opts.severity = ErrorNotification.SEVERITY.INFO
    opts.duration = opts.duration or 5  -- Auto-dismiss after 5s
    return self:showError(opts)
end

--- Show warning notification
-- @param message string: Warning message
-- @param opts table: Optional additional options
function ErrorManager:showWarning(message, opts)
    opts = opts or {}
    opts.message = message
    opts.severity = ErrorNotification.SEVERITY.WARNING
    opts.duration = opts.duration or 8  -- Auto-dismiss after 8s
    return self:showError(opts)
end

--- Show error notification
-- @param message string: Error message
-- @param opts table: Optional additional options
function ErrorManager:showCriticalError(message, opts)
    opts = opts or {}
    opts.message = message
    opts.severity = ErrorNotification.SEVERITY.CRITICAL
    opts.dismissible = opts.dismissible ~= false
    -- No auto-dismiss for critical errors
    return self:showError(opts)
end

--- Show error with retry option
-- @param message string: Error message
-- @param onRetry function: Retry callback
-- @param opts table: Optional additional options
function ErrorManager:showRetryableError(message, onRetry, opts)
    opts = opts or {}
    opts.message = message
    opts.onRetry = onRetry
    opts.severity = opts.severity or ErrorNotification.SEVERITY.ERROR
    return self:showError(opts)
end

--- Update all notifications
function ErrorManager:update(dt)
    for i = #self.notifications, 1, -1 do
        local notification = self.notifications[i]
        notification:update(dt)
        
        -- Remove if no longer visible
        if not notification.visible then
            table.remove(self.notifications, i)
        end
    end
    
    self:repositionNotifications()
end

--- Draw all notifications
function ErrorManager:draw()
    for _, notification in ipairs(self.notifications) do
        notification:draw()
    end
end

--- Handle mouse movement for all notifications
function ErrorManager:mousemoved(x, y)
    for _, notification in ipairs(self.notifications) do
        notification:mousemoved(x, y)
    end
end

--- Handle mouse press for all notifications
function ErrorManager:mousepressed(x, y, button)
    -- Process in reverse order (top notification first)
    for i = #self.notifications, 1, -1 do
        if self.notifications[i]:mousepressed(x, y, button) then
            return true  -- Event handled
        end
    end
    return false
end

--- Clear all notifications
function ErrorManager:clearAll()
    self.notifications = {}
end

--- Get error history
-- @param count number: Number of recent errors to retrieve (default: all)
-- @return table: Array of error log entries
function ErrorManager:getErrorHistory(count)
    count = count or #self.errorLog
    local history = {}
    for i = 1, math.min(count, #self.errorLog) do
        table.insert(history, self.errorLog[i])
    end
    return history
end

--- Get error statistics
-- @return table: Statistics about errors
function ErrorManager:getStats()
    local stats = {
        total = #self.errorLog,
        byType = {
            info = 0,
            warning = 0,
            error = 0,
            critical = 0
        },
        activeNotifications = #self.notifications
    }
    
    for _, entry in ipairs(self.errorLog) do
        local severity = entry.severity or "error"
        stats.byType[severity] = (stats.byType[severity] or 0) + 1
    end
    
    return stats
end

--- Shutdown and cleanup
function ErrorManager:shutdown()
    self:clearAll()
    self.errorLog = {}
end

return ErrorManager
