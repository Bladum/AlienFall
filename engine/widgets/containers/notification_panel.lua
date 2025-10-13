--[[
    Notification Panel Widget

    A specialized panel for displaying tactical notifications during gameplay.
    Features:
    - Queue of notifications with different types (enemy spotted, ally wounded, etc.)
    - Numbered buttons for each notification
    - Click to acknowledge and center camera on notification location
    - Auto-dismiss after timeout
    - Grid-aligned positioning in bottom-right corner
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")
local Button = require("widgets.buttons.button")

local NotificationPanel = setmetatable({}, {__index = BaseWidget})
NotificationPanel.__index = NotificationPanel

-- Notification types
NotificationPanel.TYPES = {
    ENEMY_SPOTTED = "enemy_spotted",
    ALLY_WOUNDED = "ally_wounded",
    ENEMY_IN_RANGE = "enemy_in_range"
}

-- Notification type colors
NotificationPanel.TYPE_COLORS = {
    enemy_spotted = "error",
    ally_wounded = "warning",
    enemy_in_range = "caution"
}

-- Notification type icons (simple text symbols)
NotificationPanel.TYPE_ICONS = {
    enemy_spotted = "!",
    ally_wounded = "?",
    enemy_in_range = "*"
}

--[[
    Create a new notification panel
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New notification panel instance
]]
function NotificationPanel.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "NotificationPanel")
    setmetatable(self, NotificationPanel)

    -- Panel appearance
    self.backgroundColor = "backgroundDark"
    self.borderColor = "border"
    self.showBorder = true

    -- Notification queue
    self.notifications = {}
    self.maxNotifications = 5  -- Maximum notifications to display

    -- Auto-dismiss timer
    self.autoDismissTime = 10.0  -- Seconds before auto-dismiss
    self.notificationTimers = {}

    -- Button size (grid cells)
    self.buttonWidth = 1
    self.buttonHeight = 1

    -- Title
    self.title = "Notifications"
    self.titleFont = Theme.fonts.small

    return self
end

--[[
    Add a notification to the queue
    @param type string - Notification type (from TYPES)
    @param message string - Notification message
    @param location table - {x, y} coordinates for camera centering
    @param data table - Additional data (optional)
]]
function NotificationPanel:addNotification(type, message, location, data)
    local notification = {
        id = love.timer.getTime(),  -- Unique ID
        type = type,
        message = message,
        location = location,
        data = data or {},
        timestamp = love.timer.getTime()
    }

    table.insert(self.notifications, notification)
    self.notificationTimers[notification.id] = self.autoDismissTime

    -- Limit queue size
    if #self.notifications > self.maxNotifications then
        local removed = table.remove(self.notifications, 1)
        self.notificationTimers[removed.id] = nil
    end

    print(string.format("[NotificationPanel] Added %s notification: %s", type, message))
end

--[[
    Remove a notification by ID
    @param id number - Notification ID to remove
]]
function NotificationPanel:removeNotification(id)
    for i, notification in ipairs(self.notifications) do
        if notification.id == id then
            table.remove(self.notifications, i)
            self.notificationTimers[id] = nil
            print(string.format("[NotificationPanel] Removed notification %d", id))
            return true
        end
    end
    return false
end

--[[
    Clear all notifications
]]
function NotificationPanel:clearNotifications()
    self.notifications = {}
    self.notificationTimers = {}
    print("[NotificationPanel] Cleared all notifications")
end

--[[
    Update notification timers
    @param dt number - Delta time in seconds
]]
function NotificationPanel:update(dt)
    if not self.visible then return end

    -- Update auto-dismiss timers
    local toRemove = {}
    for id, timeLeft in pairs(self.notificationTimers) do
        self.notificationTimers[id] = timeLeft - dt
        if self.notificationTimers[id] <= 0 then
            table.insert(toRemove, id)
        end
    end

    -- Remove expired notifications
    for _, id in ipairs(toRemove) do
        self:removeNotification(id)
    end
end

--[[
    Draw the notification panel
]]
function NotificationPanel:draw()
    if not self.visible or #self.notifications == 0 then
        return
    end

    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw border
    if self.showBorder then
        Theme.setColor(self.borderColor)
        love.graphics.setLineWidth(Theme.borderWidth)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end

    -- Draw title
    Theme.setColor("text")
    love.graphics.setFont(self.titleFont)
    local titleX = self.x + Theme.padding
    local titleY = self.y + Theme.padding
    love.graphics.print(self.title, titleX, titleY)

    -- Draw notifications
    local currentY = titleY + self.titleFont:getHeight() + Theme.padding

    for i, notification in ipairs(self.notifications) do
        self:drawNotification(notification, i, currentY)
        currentY = currentY + 24  -- Move down one grid cell
    end
end

--[[
    Draw a single notification
    @param notification table - Notification data
    @param index number - Notification index (for numbering)
    @param y number - Y position to draw at
]]
function NotificationPanel:drawNotification(notification, index, y)
    local iconColor = self.TYPE_COLORS[notification.type] or "text"
    local icon = self.TYPE_ICONS[notification.type] or "?"

    -- Draw notification number button background
    Theme.setColor("primary")
    love.graphics.rectangle("fill", self.x + Theme.padding, y,
                          self.buttonWidth * 24, self.buttonHeight * 24)

    -- Draw notification number
    Theme.setColor("textLight")
    love.graphics.setFont(Theme.fonts.default)
    local numberText = tostring(index)
    local numberX = self.x + Theme.padding + 12 - Theme.fonts.default:getWidth(numberText) / 2
    local numberY = y + 12 - Theme.fonts.default:getHeight() / 2
    love.graphics.print(numberText, numberX, numberY)

    -- Draw icon
    Theme.setColor(iconColor)
    local iconX = self.x + Theme.padding + 24 + Theme.padding
    local iconY = y + 12 - Theme.fonts.default:getHeight() / 2
    love.graphics.print(icon, iconX, iconY)

    -- Draw message
    Theme.setColor("text")
    local messageX = iconX + 24 + Theme.padding
    local messageY = y + 12 - Theme.fonts.default:getHeight() / 2
    local maxWidth = self.width - messageX + self.x - Theme.padding
    love.graphics.printf(notification.message, messageX, messageY, maxWidth, "left")
end

--[[
    Handle mouse press events
    @param x number - Mouse X position
    @param y number - Mouse Y position
    @param button number - Mouse button
    @return boolean - True if event was handled
]]
function NotificationPanel:mousepressed(x, y, button)
    if not self.visible or button ~= 1 then return false end

    -- Check if click is within panel bounds
    if x < self.x or x > self.x + self.width or y < self.y or y > self.y + self.height then
        return false
    end

    -- Calculate which notification was clicked
    local titleHeight = self.titleFont:getHeight() + Theme.padding * 2
    local notificationY = self.y + titleHeight

    for i, notification in ipairs(self.notifications) do
        local buttonX = self.x + Theme.padding
        local buttonY = notificationY + (i - 1) * 24

        -- Check if click is on the number button
        if x >= buttonX and x <= buttonX + self.buttonWidth * 24 and
           y >= buttonY and y <= buttonY + self.buttonHeight * 24 then

            -- Handle notification click
            self:onNotificationClicked(notification, i)
            return true
        end
    end

    return false
end

--[[
    Handle notification button click
    @param notification table - The clicked notification
    @param index number - Notification index
]]
function NotificationPanel:onNotificationClicked(notification, index)
    print(string.format("[NotificationPanel] Clicked notification %d: %s", index, notification.message))

    -- Center camera on notification location if available
    if notification.location and self.onCenterCamera then
        self.onCenterCamera(notification.location.x, notification.location.y)
    end

    -- Remove the notification
    self:removeNotification(notification.id)

    -- Call custom click handler if set
    if self.onNotificationClick then
        self.onNotificationClick(notification)
    end
end

print("[NotificationPanel] Notification panel widget loaded")

return NotificationPanel