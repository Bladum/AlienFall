--[[
widgets/alertsystem.lua
AlertSystem widget for notification management


Notification management system for displaying contextual alerts and status messages.
Essential for turn-based strategy games requiring timely information delivery.

PURPOSE:
- Display contextual alerts, warnings, and status messages during gameplay
- Provide timely notifications for mission events and tactical situations
- Support multiple alert types with appropriate visual and audio feedback
- Enable non-intrusive information delivery without disrupting gameplay

KEY FEATURES:
- Multiple alert types (INFO, SUCCESS, WARNING, ERROR, CRITICAL) with distinct styling
- Positionable alert queues (top-right, bottom-left, center, custom positions)
- Smooth animations for alert appearance and dismissal
- Auto-dismissal with configurable durations and manual dismissal options
- Sound integration for audio feedback and accessibility
- Screen reader support for accessibility compliance
- Alert queuing system to prevent notification spam
- Customizable alert templates and styling
- Priority system for critical alerts
- Integration with game state and event system

]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")

local AlertSystem = {}
AlertSystem.__index = AlertSystem
setmetatable(AlertSystem, { __index = core.Base })

-- Alert types with default styling
AlertSystem.ALERT_TYPES = {
    INFO = {
        color = { 0.3, 0.6, 1.0 },
        icon = "ℹ",
        sound = nil,
        defaultDuration = 4.0
    },
    SUCCESS = {
        color = { 0.2, 0.8, 0.2 },
        icon = "✓",
        sound = nil,
        defaultDuration = 3.0
    },
    WARNING = {
        color = { 1.0, 0.8, 0.2 },
        icon = "⚠",
        sound = "warning",
        defaultDuration = 5.0
    },
    ERROR = {
        color = { 1.0, 0.3, 0.3 },
        icon = "✗",
        sound = "error",
        defaultDuration = 6.0
    },
    CRITICAL = {
        color = { 1.0, 0.1, 0.1 },
        icon = "‼",
        sound = "critical",
        defaultDuration = 0 -- Persistent until dismissed
    }
}

function AlertSystem:new(options)
    local obj = core.Base:new(0, 0, 400, 0)

    -- Configuration
    obj.position = (options and options.position) or
        "top-right" -- top-right, top-left, bottom-right, bottom-left, center
    obj.maxAlerts = (options and options.maxAlerts) or 5
    obj.alertHeight = (options and options.alertHeight) or 60
    obj.alertSpacing = (options and options.alertSpacing) or 8
    obj.margin = (options and options.margin) or { x = 20, y = 20 }
    obj.animationDuration = (options and options.animationDuration) or 0.3
    obj.enableSounds = (options and options.enableSounds) ~= false

    -- Visual styling
    obj.backgroundColor = (options and options.backgroundColor) or { 0, 0, 0, 0.85 }
    obj.borderColor = (options and options.borderColor) or { 1, 1, 1, 0.3 }
    obj.textColor = (options and options.textColor) or { 1, 1, 1 }
    obj.borderRadius = (options and options.borderRadius) or 6
    obj.iconSize = (options and options.iconSize) or 20

    -- State
    obj.alerts = {}
    obj.nextId = 1
    obj.screenWidth = love.graphics.getWidth()
    obj.screenHeight = love.graphics.getHeight()

    setmetatable(obj, self)
    obj:_updatePosition()
    return obj
end

function AlertSystem:addAlert(type, title, message, options)
    local alertType = self.ALERT_TYPES[type] or self.ALERT_TYPES.INFO
    local duration = (options and options.duration) or alertType.defaultDuration

    local alert = {
        id = self.nextId,
        type = type,
        title = title or "",
        message = message or "",
        duration = duration,
        timeLeft = duration,
        typeData = alertType,
        actions = (options and options.actions) or {},
        data = (options and options.data) or {},

        -- Animation state
        x = self.x + self.w, -- Start off-screen
        y = 0,
        alpha = 0,
        targetX = self.x,
        targetY = 0,
        targetAlpha = 1,

        -- Visual state
        progressWidth = 0,
        isHovered = false,
        isDismissing = false
    }

    self.nextId = self.nextId + 1

    -- Add to alerts list (sorted by priority)
    local inserted = false
    for i, existingAlert in ipairs(self.alerts) do
        if self:_getAlertPriority(type) > self:_getAlertPriority(existingAlert.type) then
            table.insert(self.alerts, i, alert)
            inserted = true
            break
        end
    end

    if not inserted then
        table.insert(self.alerts, alert)
    end

    -- Remove oldest alerts if exceeding maximum
    while #self.alerts > self.maxAlerts do
        local removed = table.remove(self.alerts, #self.alerts)
        if removed then
            self:_dismissAlert(removed, true)
        end
    end

    -- Play sound if enabled
    if self.enableSounds and alertType.sound then
        -- Sound playing would be implemented here
        -- love.audio.play(sounds[alertType.sound])
    end

    self:_updateAlertPositions()

    -- Animate in
    Animation:animate(alert, self.animationDuration, {
        x = alert.targetX,
        alpha = 1
    })

    return alert.id
end

function AlertSystem:_getAlertPriority(type)
    local priorities = {
        CRITICAL = 5,
        ERROR = 4,
        WARNING = 3,
        INFO = 2,
        SUCCESS = 1
    }
    return priorities[type] or 0
end

function AlertSystem:dismissAlert(alertId)
    for i, alert in ipairs(self.alerts) do
        if alert.id == alertId then
            self:_dismissAlert(alert)
            table.remove(self.alerts, i)
            self:_updateAlertPositions()
            break
        end
    end
end

function AlertSystem:_dismissAlert(alert, immediate)
    if alert.isDismissing then return end

    alert.isDismissing = true

    if immediate then
        -- Remove immediately
        return
    end

    -- Animate out
    Animation:animate(alert, self.animationDuration, {
        x = self.x + self.w,
        alpha = 0
    })
end

function AlertSystem:clearAll()
    for _, alert in ipairs(self.alerts) do
        self:_dismissAlert(alert, true)
    end
    self.alerts = {}
end

function AlertSystem:_updatePosition()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    if self.position == "top-right" then
        self.x = screenWidth - self.w - self.margin.x
        self.y = self.margin.y
    elseif self.position == "top-left" then
        self.x = self.margin.x
        self.y = self.margin.y
    elseif self.position == "bottom-right" then
        self.x = screenWidth - self.w - self.margin.x
        self.y = screenHeight - self:_getTotalHeight() - self.margin.y
    elseif self.position == "bottom-left" then
        self.x = self.margin.x
        self.y = screenHeight - self:_getTotalHeight() - self.margin.y
    elseif self.position == "center" then
        self.x = (screenWidth - self.w) / 2
        self.y = (screenHeight - self:_getTotalHeight()) / 2
    end

    self:_updateAlertPositions()
end

function AlertSystem:_getTotalHeight()
    return #self.alerts * (self.alertHeight + self.alertSpacing) - self.alertSpacing
end

function AlertSystem:_updateAlertPositions()
    for i, alert in ipairs(self.alerts) do
        alert.targetY = self.y + (i - 1) * (self.alertHeight + self.alertSpacing)
        alert.targetX = self.x

        if not alert.isDismissing then
            Animation:animate(alert, self.animationDuration, {
                y = alert.targetY
            })
        end
    end
end

function AlertSystem:update(dt)
    core.Base.update(self, dt)

    -- Update screen dimensions
    local newScreenWidth = love.graphics.getWidth()
    local newScreenHeight = love.graphics.getHeight()
    if newScreenWidth ~= self.screenWidth or newScreenHeight ~= self.screenHeight then
        self.screenWidth = newScreenWidth
        self.screenHeight = newScreenHeight
        self:_updatePosition()
    end

    -- Update alerts
    for i = #self.alerts, 1, -1 do
        local alert = self.alerts[i]

        -- Update timer
        if alert.duration > 0 and not alert.isDismissing then
            alert.timeLeft = alert.timeLeft - dt
            if alert.timeLeft <= 0 then
                self:_dismissAlert(alert)
                table.remove(self.alerts, i)
                self:_updateAlertPositions()
            else
                -- Update progress bar
                alert.progressWidth = (alert.timeLeft / alert.duration) * (self.w - 20)
            end
        end

        -- Remove fully dismissed alerts
        if alert.isDismissing and alert.alpha <= 0 then
            table.remove(self.alerts, i)
            self:_updateAlertPositions()
        end
    end
end

function AlertSystem:mousemoved(x, y)
    for _, alert in ipairs(self.alerts) do
        alert.isHovered = x >= alert.x and x <= alert.x + self.w and
            y >= alert.y and y <= alert.y + self.alertHeight
    end
end

function AlertSystem:mousepressed(x, y, button)
    if button == 1 then
        for i, alert in ipairs(self.alerts) do
            if x >= alert.x and x <= alert.x + self.w and
                y >= alert.y and y <= alert.y + self.alertHeight then
                -- Check dismiss button
                local dismissX = alert.x + self.w - 25
                local dismissY = alert.y + 5
                if x >= dismissX and x <= dismissX + 20 and
                    y >= dismissY and y <= dismissY + 20 then
                    self:dismissAlert(alert.id)
                    return true
                end

                -- Check action buttons
                local buttonY = alert.y + self.alertHeight - 25
                local buttonX = alert.x + 10
                for _, action in ipairs(alert.actions) do
                    local buttonWidth = core.theme.font:getWidth(action.text) + 16
                    if x >= buttonX and x <= buttonX + buttonWidth and
                        y >= buttonY and y <= buttonY + 20 then
                        if action.callback then
                            action.callback(alert.data)
                        end
                        if action.dismissOnClick ~= false then
                            self:dismissAlert(alert.id)
                        end
                        return true
                    end
                    buttonX = buttonX + buttonWidth + 8
                end

                return true
            end
        end
    end

    return false
end

function AlertSystem:draw()
    for _, alert in ipairs(self.alerts) do
        if alert.alpha > 0 then
            self:_drawAlert(alert)
        end
    end
end

function AlertSystem:_drawAlert(alert)
    local r, g, b, a = love.graphics.getColor()

    -- Background with hover effect
    local bgAlpha = (self.backgroundColor[4] or 1) * alert.alpha
    if alert.isHovered then bgAlpha = bgAlpha * 1.1 end

    love.graphics.setColor(self.backgroundColor[1], self.backgroundColor[2],
        self.backgroundColor[3], bgAlpha)
    love.graphics.rectangle("fill", alert.x, alert.y, self.w, self.alertHeight, self.borderRadius)

    -- Border with type color
    love.graphics.setColor(alert.typeData.color[1], alert.typeData.color[2],
        alert.typeData.color[3], alert.alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", alert.x, alert.y, self.w, self.alertHeight, self.borderRadius)

    -- Icon
    love.graphics.setColor(alert.typeData.color[1], alert.typeData.color[2],
        alert.typeData.color[3], alert.alpha)
    love.graphics.setFont(core.theme.fontBold)
    love.graphics.print(alert.typeData.icon, alert.x + 10, alert.y + 8)

    -- Title
    love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], alert.alpha)
    love.graphics.setFont(core.theme.fontBold)
    local titleY = alert.y + 8
    love.graphics.print(alert.title, alert.x + 35, titleY)

    -- Message
    love.graphics.setFont(core.theme.font)
    local messageY = titleY + core.theme.fontBold:getHeight() + 2
    love.graphics.print(alert.message, alert.x + 35, messageY)

    -- Dismiss button
    love.graphics.setColor(1, 1, 1, alert.alpha * 0.7)
    love.graphics.print("×", alert.x + self.w - 20, alert.y + 8)

    -- Progress bar (for timed alerts)
    if alert.duration > 0 and not alert.isDismissing then
        local progressY = alert.y + self.alertHeight - 4

        -- Background
        love.graphics.setColor(0.3, 0.3, 0.3, alert.alpha)
        love.graphics.rectangle("fill", alert.x + 10, progressY, self.w - 20, 2)

        -- Progress
        love.graphics.setColor(alert.typeData.color[1], alert.typeData.color[2],
            alert.typeData.color[3], alert.alpha)
        love.graphics.rectangle("fill", alert.x + 10, progressY, alert.progressWidth, 2)
    end

    -- Action buttons
    if #alert.actions > 0 then
        local buttonY = alert.y + self.alertHeight - 25
        local buttonX = alert.x + 10

        love.graphics.setFont(core.theme.font)
        for _, action in ipairs(alert.actions) do
            local buttonWidth = core.theme.font:getWidth(action.text) + 16

            -- Button background
            love.graphics.setColor(0.4, 0.4, 0.4, alert.alpha)
            love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, 20, 3)

            -- Button text
            love.graphics.setColor(1, 1, 1, alert.alpha)
            love.graphics.print(action.text, buttonX + 8, buttonY + 3)

            buttonX = buttonX + buttonWidth + 8
        end
    end

    -- Restore color
    love.graphics.setColor(r, g, b, a)
end

-- Static instance for global use
AlertSystem.instance = nil

function AlertSystem.getInstance()
    if not AlertSystem.instance then
        AlertSystem.instance = AlertSystem:new()
    end
    return AlertSystem.instance
end

-- Global convenience functions
function AlertSystem.info(title, message, options)
    return AlertSystem.getInstance():addAlert("INFO", title, message, options)
end

function AlertSystem.success(title, message, options)
    return AlertSystem.getInstance():addAlert("SUCCESS", title, message, options)
end

function AlertSystem.warning(title, message, options)
    return AlertSystem.getInstance():addAlert("WARNING", title, message, options)
end

function AlertSystem.error(title, message, options)
    return AlertSystem.getInstance():addAlert("ERROR", title, message, options)
end

function AlertSystem.critical(title, message, options)
    return AlertSystem.getInstance():addAlert("CRITICAL", title, message, options)
end

function AlertSystem.dismiss(alertId)
    AlertSystem.getInstance():dismissAlert(alertId)
end

function AlertSystem.clear()
    AlertSystem.getInstance():clearAll()
end

function AlertSystem.updateInstance(dt)
    if AlertSystem.instance then
        AlertSystem.instance:update(dt)
    end
end

function AlertSystem.drawInstance()
    if AlertSystem.instance then
        AlertSystem.instance:draw()
    end
end

function AlertSystem.mousemovedInstance(x, y)
    if AlertSystem.instance then
        AlertSystem.instance:mousemoved(x, y)
    end
end

function AlertSystem.mousepressedInstance(x, y, button)
    if AlertSystem.instance then
        return AlertSystem.instance:mousepressed(x, y, button)
    end
    return false
end

return AlertSystem






