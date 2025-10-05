--- Error notification widget for displaying user-friendly error messages
-- Provides dismissible error notifications with severity levels
--
-- @module widgets.ErrorNotification

local class = require("lib.middleclass")

local ErrorNotification = class('ErrorNotification')

--- Severity levels for error notifications
ErrorNotification.static.SEVERITY = {
    INFO = "info",
    WARNING = "warning",
    ERROR = "error",
    CRITICAL = "critical"
}

--- Create a new error notification
-- @param opts table: Configuration options
-- @param opts.message string: Error message to display
-- @param opts.severity string: Severity level (INFO, WARNING, ERROR, CRITICAL)
-- @param opts.title string: Optional title (default based on severity)
-- @param opts.dismissible boolean: Can user dismiss this? (default: true)
-- @param opts.duration number: Auto-dismiss after seconds (nil = manual only)
-- @param opts.onDismiss function: Callback when dismissed
-- @param opts.onRetry function: Optional retry action
-- @param opts.x number: X position (default: centered)
-- @param opts.y number: Y position (default: 100)
-- @param opts.width number: Width in pixels (default: 600)
-- @return ErrorNotification: New notification instance
function ErrorNotification:initialize(opts)
    opts = opts or {}
    
    self.message = opts.message or "An error occurred"
    self.severity = opts.severity or ErrorNotification.static.SEVERITY.ERROR
    self.title = opts.title or self:getDefaultTitle()
    self.dismissible = opts.dismissible ~= false
    self.duration = opts.duration
    self.onDismiss = opts.onDismiss
    self.onRetry = opts.onRetry
    
    self.width = opts.width or 600
    self.height = 0  -- Calculated based on content
    self.padding = 20
    self.buttonHeight = 40
    self.buttonWidth = 120
    
    -- Calculate height based on content
    self.font = love.graphics.newFont(14)
    self.titleFont = love.graphics.newFont(16)
    
    local _, wrappedText = self.font:getWrap(self.message, self.width - self.padding * 2)
    local textHeight = #wrappedText * self.font:getHeight() * 1.2
    self.height = self.padding * 2 + self.titleFont:getHeight() + 10 + textHeight
    
    if self.dismissible or self.onRetry then
        self.height = self.height + self.buttonHeight + self.padding
    end
    
    -- Center horizontally by default
    self.x = opts.x or (800 - self.width) / 2
    self.y = opts.y or 100
    
    self.visible = true
    self.elapsed = 0
    self.hoverDismiss = false
    self.hoverRetry = false
end

--- Get default title based on severity
function ErrorNotification:getDefaultTitle()
    local titles = {
        info = "Information",
        warning = "Warning",
        error = "Error",
        critical = "Critical Error"
    }
    return titles[self.severity] or "Notification"
end

--- Get colors for severity level
function ErrorNotification:getColors()
    local colors = {
        info = {
            bg = {0.2, 0.4, 0.8, 0.95},
            border = {0.3, 0.5, 0.9, 1},
            text = {1, 1, 1, 1}
        },
        warning = {
            bg = {0.8, 0.6, 0.2, 0.95},
            border = {0.9, 0.7, 0.3, 1},
            text = {0.1, 0.1, 0.1, 1}
        },
        error = {
            bg = {0.8, 0.2, 0.2, 0.95},
            border = {0.9, 0.3, 0.3, 1},
            text = {1, 1, 1, 1}
        },
        critical = {
            bg = {0.6, 0.1, 0.1, 0.98},
            border = {0.9, 0.2, 0.2, 1},
            text = {1, 1, 1, 1}
        }
    }
    return colors[self.severity] or colors.error
end

--- Update notification (handle auto-dismiss)
function ErrorNotification:update(dt)
    if not self.visible then
        return
    end
    
    if self.duration then
        self.elapsed = self.elapsed + dt
        if self.elapsed >= self.duration then
            self:dismiss()
        end
    end
end

--- Check if point is inside notification
function ErrorNotification:contains(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

--- Handle mouse movement
function ErrorNotification:mousemoved(x, y)
    if not self.visible then
        return
    end
    
    -- Check dismiss button hover
    if self.dismissible then
        local dismissX = self.x + self.width - self.buttonWidth - self.padding
        local dismissY = self.y + self.height - self.buttonHeight - self.padding
        self.hoverDismiss = x >= dismissX and x <= dismissX + self.buttonWidth and
                           y >= dismissY and y <= dismissY + self.buttonHeight
    end
    
    -- Check retry button hover
    if self.onRetry then
        local retryX = self.x + self.width - self.buttonWidth * 2 - self.padding * 2
        local retryY = self.y + self.height - self.buttonHeight - self.padding
        self.hoverRetry = x >= retryX and x <= retryX + self.buttonWidth and
                         y >= retryY and y <= retryY + self.buttonHeight
    end
end

--- Handle mouse press
function ErrorNotification:mousepressed(x, y, button)
    if not self.visible or button ~= 1 then
        return false
    end
    
    -- Check dismiss button click
    if self.dismissible and self.hoverDismiss then
        self:dismiss()
        return true
    end
    
    -- Check retry button click
    if self.onRetry and self.hoverRetry then
        if self.onRetry() ~= false then
            self:dismiss()
        end
        return true
    end
    
    return false
end

--- Dismiss the notification
function ErrorNotification:dismiss()
    self.visible = false
    if self.onDismiss then
        self.onDismiss()
    end
end

--- Draw the notification
function ErrorNotification:draw()
    if not self.visible then
        return
    end
    
    local colors = self:getColors()
    
    -- Draw background
    love.graphics.setColor(colors.bg)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)
    
    -- Draw border
    love.graphics.setColor(colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5, 5)
    
    -- Draw title
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(colors.text)
    love.graphics.printf(self.title, self.x + self.padding, self.y + self.padding,
                        self.width - self.padding * 2, "left")
    
    -- Draw message
    love.graphics.setFont(self.font)
    local titleHeight = self.titleFont:getHeight()
    love.graphics.printf(self.message, self.x + self.padding,
                        self.y + self.padding + titleHeight + 10,
                        self.width - self.padding * 2, "left")
    
    -- Draw buttons
    local buttonY = self.y + self.height - self.buttonHeight - self.padding
    
    -- Retry button (if available)
    if self.onRetry then
        local retryX = self.x + self.width - self.buttonWidth * 2 - self.padding * 2
        local retryBg = self.hoverRetry and {0.3, 0.6, 0.3, 1} or {0.2, 0.5, 0.2, 1}
        
        love.graphics.setColor(retryBg)
        love.graphics.rectangle("fill", retryX, buttonY, self.buttonWidth, self.buttonHeight, 3, 3)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", retryX, buttonY, self.buttonWidth, self.buttonHeight, 3, 3)
        
        love.graphics.setFont(self.font)
        love.graphics.printf("Retry", retryX, buttonY + (self.buttonHeight - self.font:getHeight()) / 2,
                            self.buttonWidth, "center")
    end
    
    -- Dismiss button
    if self.dismissible then
        local dismissX = self.x + self.width - self.buttonWidth - self.padding
        local dismissBg = self.hoverDismiss and {0.6, 0.3, 0.3, 1} or {0.5, 0.2, 0.2, 1}
        
        love.graphics.setColor(dismissBg)
        love.graphics.rectangle("fill", dismissX, buttonY, self.buttonWidth, self.buttonHeight, 3, 3)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", dismissX, buttonY, self.buttonWidth, self.buttonHeight, 3, 3)
        
        love.graphics.setFont(self.font)
        love.graphics.printf("Dismiss", dismissX, buttonY + (self.buttonHeight - self.font:getHeight()) / 2,
                            self.buttonWidth, "center")
    end
    
    -- Draw auto-dismiss timer if applicable
    if self.duration and self.elapsed < self.duration then
        local remaining = math.ceil(self.duration - self.elapsed)
        local timerText = string.format("Auto-dismiss in %ds", remaining)
        love.graphics.setFont(self.font)
        love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.7)
        love.graphics.printf(timerText, self.x + self.padding, self.y + self.height - 15,
                            self.width - self.padding * 2, "left")
    end
end

return ErrorNotification
