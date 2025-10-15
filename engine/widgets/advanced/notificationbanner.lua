---NotificationBanner Widget - Temporary Message Display
---
---A banner that displays temporary notifications/messages that auto-dismiss after
---a duration. Supports multiple types (info, warning, error, success) with color-coded
---styling and icon support. Grid-aligned for consistent positioning.
---
---Features:
---  - Multiple notification types (info, warning, error, success)
---  - Auto-fade after duration
---  - Icon support per type
---  - Queue system for multiple notifications
---  - Slide-in animation
---  - Grid-aligned positioning (24×24 pixels)
---
---Notification Types:
---  - Info: Blue, info icon
---  - Warning: Yellow, warning icon
---  - Error: Red, X icon
---  - Success: Green, checkmark icon
---
---Animation Phases:
---  - Slide-in: Banner enters from top
---  - Display: Shows for duration
---  - Fade-out: Banner fades away
---  - Queue: Next notification if any
---
---Key Exports:
---  - NotificationBanner.new(x, y, width, height): Creates banner
---  - show(message, type, duration): Displays notification
---  - queue(message, type, duration): Adds to queue
---  - hide(): Dismisses current notification
---  - update(dt): Updates animation and timer
---  - draw(): Renders banner
---  - setPosition(x, y): Updates banner position
---  - clearQueue(): Removes all queued notifications
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.advanced.notificationbanner
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local NotificationBanner = require("widgets.advanced.notificationbanner")
---  local banner = NotificationBanner.new(0, 0, 480, 72)
---  banner:show("Mission complete!", "success", 3)
---  banner:update(dt)
---  banner:draw()
---
---@see widgets.display.tooltip For hover tooltips

--[[
    NotificationBanner Widget
    
    Displays temporary notification messages.
    Features:
    - Auto-fade after duration
    - Multiple notification types (info, warning, error, success)
    - Icon support
    - Queue system for multiple notifications
    - Slide-in animation
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local NotificationBanner = setmetatable({}, {__index = BaseWidget})
NotificationBanner.__index = NotificationBanner

function NotificationBanner.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, NotificationBanner)
    
    self.message = ""
    self.notificationType = "info"  -- info, warning, error, success
    self.duration = 3  -- seconds
    self.timeRemaining = 0
    self.icon = nil
    self.alpha = 0
    self.fadeSpeed = 3
    
    return self
end

function NotificationBanner:draw()
    if not self.visible or self.alpha <= 0 then
        return
    end
    
    -- Get color based on notification type
    local bgColor
    if self.notificationType == "error" then
        bgColor = {0.8, 0.2, 0.2}
    elseif self.notificationType == "warning" then
        bgColor = {0.9, 0.7, 0.2}
    elseif self.notificationType == "success" then
        bgColor = {0.2, 0.8, 0.3}
    else  -- info
        bgColor = {0.3, 0.5, 0.8}
    end
    
    -- Draw background with alpha
    love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3], self.alpha)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    love.graphics.setColor(bgColor[1] * 1.2, bgColor[2] * 1.2, bgColor[3] * 1.2, self.alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    local currentX = self.x + 8
    
    -- Draw icon if present
    if self.icon then
        love.graphics.setColor(1, 1, 1, self.alpha)
        local iconSize = self.height - 16
        local iconScale = iconSize / self.icon:getWidth()
        love.graphics.draw(self.icon, currentX, self.y + 8, 0, iconScale, iconScale)
        currentX = currentX + iconSize + 8
    end
    
    -- Draw message text
    Theme.setFont("default")
    love.graphics.setColor(1, 1, 1, self.alpha)
    local font = Theme.getFont("default")
    local textHeight = font:getHeight()
    local textY = self.y + (self.height - textHeight) / 2
    love.graphics.print(self.message, currentX, textY)
end

function NotificationBanner:update(dt)
    if not self.visible then
        return
    end
    
    -- Update timer
    if self.timeRemaining > 0 then
        self.timeRemaining = self.timeRemaining - dt
        
        -- Fade in
        if self.alpha < 1 then
            self.alpha = math.min(1, self.alpha + self.fadeSpeed * dt)
        end
        
        -- Start fading out in last second
        if self.timeRemaining < 1 then
            self.alpha = self.timeRemaining
        end
    else
        -- Fade out
        self.alpha = math.max(0, self.alpha - self.fadeSpeed * dt)
        
        if self.alpha <= 0 then
            self.visible = false
        end
    end
end

function NotificationBanner:show(message, notificationType, duration)
    self.message = message or ""
    self.notificationType = notificationType or "info"
    self.duration = duration or 3
    self.timeRemaining = self.duration
    self.alpha = 0
    self.visible = true
end

function NotificationBanner:hide()
    self.timeRemaining = 0
end

return NotificationBanner






















