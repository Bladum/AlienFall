--- A tooltip widget that displays text information when hovering over UI elements.
--- @class Tooltip
--- @description A floating tooltip widget that displays contextual help text with
--- automatic positioning to stay within screen bounds and a pointing arrow.
--- @field text string The text content to display in the tooltip
--- @field font love.Font Font used for rendering tooltip text
--- @field maxWidth number Maximum width of the tooltip before text wrapping
--- @field x number Current X position of the tooltip
--- @field y number Current Y position of the tooltip
--- @field visible boolean Whether the tooltip is currently visible
--- @field padding number Padding around the text in pixels
--- @field colors table Color configuration for tooltip appearance (background, border, text)

local class = require("lib.middleclass")

local Tooltip = class('Tooltip')

--- Creates a new Tooltip instance.
--- @param options table Configuration options for the tooltip
--- @field text string The text content to display
--- @field font love.Font Font used for rendering (defaults to 12pt)
--- @field x number Initial X position (defaults to 0)
--- @field y number Initial Y position (defaults to 0)
--- @field maxWidth number Maximum width before text wrapping (defaults to 200)
--- @return Tooltip A new Tooltip instance
--- @usage local tooltip = Tooltip:new({
---     text = "This is helpful information",
---     maxWidth = 200,
---     font = love.graphics.newFont(12)
--- })
function Tooltip:initialize(options)
    options = options or {}

    -- Required options
    self.text = options.text or ""
    self.font = options.font or love.graphics.newFont(12)

    -- Positioning
    self.x = options.x or 0
    self.y = options.y or 0
    self.maxWidth = options.maxWidth or 200

    -- Colors with semi-transparent background
    self.colors = {
        background = {0.1, 0.1, 0.15, 0.95},
        border = {0.3, 0.4, 0.6, 1},
        text = {1, 1, 1, 1}
    }

    -- Internal state
    self.visible = false
    self.padding = 6
end

--- Sets the text content of the tooltip.
--- @param text string The new text to display
function Tooltip:setText(text)
    self.text = text or ""
end

--- Sets the position of the tooltip.
--- @param x number X coordinate
--- @param y number Y coordinate
function Tooltip:setPosition(x, y)
    self.x = x
    self.y = y
end

--- Makes the tooltip visible.
function Tooltip:show()
    self.visible = true
end

--- Hides the tooltip.
function Tooltip:hide()
    self.visible = false
end

--- Checks if the tooltip is currently visible.
--- @return boolean True if the tooltip is visible
function Tooltip:isVisible()
    return self.visible
end

--- Calculates the size of the tooltip based on its text content.
--- @return number, number Width and height of the tooltip
function Tooltip:getSize()
    love.graphics.setFont(self.font)
    local width, wrappedText = love.graphics.getFont():getWrap(self.text, self.maxWidth)
    local height = #wrappedText * love.graphics.getFont():getHeight()
    return width + self.padding * 2, height + self.padding * 2
end

--- Draws the tooltip if it is visible.
--- Automatically adjusts position to stay within screen bounds and adds a pointing arrow.
function Tooltip:draw()
    if not self.visible or not self.text or self.text == "" then
        return
    end

    love.graphics.setFont(self.font)

    -- Calculate tooltip dimensions
    local textWidth, wrappedText = love.graphics.getFont():getWrap(self.text, self.maxWidth)
    local textHeight = #wrappedText * love.graphics.getFont():getHeight()
    local tooltipWidth = textWidth + self.padding * 2
    local tooltipHeight = textHeight + self.padding * 2

    -- Adjust position if tooltip would go off screen
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local drawX = self.x
    local drawY = self.y

    if drawX + tooltipWidth > screenWidth then
        drawX = screenWidth - tooltipWidth - 5
    end

    if drawY + tooltipHeight > screenHeight then
        drawY = self.y - tooltipHeight - 5
    end

    -- Draw background with rounded corners
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", drawX, drawY, tooltipWidth, tooltipHeight, 4, 4)

    -- Draw border
    love.graphics.setColor(unpack(self.colors.border))
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", drawX, drawY, tooltipWidth, tooltipHeight, 4, 4)

    -- Draw text
    love.graphics.setColor(unpack(self.colors.text))
    love.graphics.printf(self.text, drawX + self.padding, drawY + self.padding, textWidth, "left")

    -- Draw small arrow pointing to the trigger position
    love.graphics.setColor(unpack(self.colors.background))
    if drawY < self.y then
        -- Arrow pointing down (tooltip above trigger)
        love.graphics.polygon("fill",
            self.x - 3, self.y - 3,
            self.x + 3, self.y - 3,
            self.x, self.y + 2)
        love.graphics.setColor(unpack(self.colors.border))
        love.graphics.setLineWidth(1)
        love.graphics.polygon("line",
            self.x - 3, self.y - 3,
            self.x + 3, self.y - 3,
            self.x, self.y + 2)
    else
        -- Arrow pointing up (tooltip below trigger)
        love.graphics.polygon("fill",
            self.x - 3, self.y + 3,
            self.x + 3, self.y + 3,
            self.x, self.y - 2)
        love.graphics.setColor(unpack(self.colors.border))
        love.graphics.setLineWidth(1)
        love.graphics.polygon("line",
            self.x - 3, self.y + 3,
            self.x + 3, self.y + 3,
            self.x, self.y - 2)
    end
end

return Tooltip
