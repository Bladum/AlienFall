--- A clickable button widget with hover effects and tooltips.
-- @module widgets.Button

local class = require("lib.Middleclass")
local Tooltip = require 'widgets.Tooltip'

local Button = class('Button')

--- Creates a new Button instance.
-- @param opts table Configuration options for the button
-- @param opts.id string Unique identifier for the button
-- @param opts.label string Text displayed on the button
-- @param opts.onClick function Callback function called when button is clicked
-- @param opts.width number Width of the button in pixels (default: 260)
-- @param opts.height number Height of the button in pixels (default: 40)
-- @param opts.enabled boolean Whether the button is enabled (default: true)
-- @param opts.x number X position of the button (default: 0)
-- @param opts.y number Y position of the button (default: 0)
-- @param opts.font love.Font Font used for rendering button text
-- @param opts.tooltip string Optional tooltip text to display on hover
-- @return Button A new Button instance
function Button:initialize(opts)
    opts = opts or {}
    self.id = opts.id
    self.label = opts.label or "Button"
    self.onClick = opts.onClick or function() end
    self.width = opts.width or 260
    self.height = opts.height or 40
    self.enabled = opts.enabled ~= false
    self.hovered = false
    self.x = opts.x or 0
    self.y = opts.y or 0
    self.font = opts.font or love.graphics.getFont()
    self.tooltip = opts.tooltip  -- Tooltip text
    self.tooltipWidget = nil     -- Will be created when needed
end

--- Updates the button state. Currently a placeholder for animation hooks.
-- @param dt number Time delta since last update
function Button:update(dt)
    -- placeholder for animation hooks
end

--- Sets the position of the button.
-- @param x number X coordinate
-- @param y number Y coordinate
function Button:setPosition(x, y)
    self.x = x
    self.y = y
end

--- Draws the button with hover effects and tooltips.
-- @param focused boolean Whether the button has focus
function Button:draw(focused)
    local x = self.x
    local y = self.y
    local bgColor = {0.12, 0.18, 0.32, 1}
    if self.hovered or focused then
        bgColor = {0.18, 0.28, 0.42, 1}  -- Same as combobox hover effect
    end
    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", x, y, self.width, self.height, 8, 8)
    love.graphics.setColor(0.05, 0.08, 0.1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, self.width, self.height, 8, 8)

    love.graphics.setColor(1, 1, 1, 1)
    local oldFont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    local fontHeight = self.font:getHeight()
    love.graphics.printf(self.label, x, y + (self.height - fontHeight) / 2, self.width, "center")
    love.graphics.setFont(oldFont)

    -- Draw tooltip if visible
    if self.tooltipWidget and self.tooltipWidget:isVisible() then
        self.tooltipWidget:draw()
    end
end

--- Checks if the given coordinates are within the button bounds.
-- @param x number X coordinate to check
-- @param y number Y coordinate to check
-- @return boolean True if coordinates are within button bounds
function Button:contains(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

--- Handles mouse movement over the button, updating hover state and tooltips.
-- @param x number Current mouse X position
-- @param y number Current mouse Y position
-- @return boolean True if mouse is hovering over the button
function Button:mousemoved(x, y)
    local wasHovered = self.hovered
    self.hovered = self:contains(x, y)

    -- Handle tooltip
    if self.tooltip then
        if self.hovered and not wasHovered then
            -- Mouse entered - show tooltip
            if not self.tooltipWidget then
                self.tooltipWidget = Tooltip:new({
                    text = self.tooltip,
                    font = self.font,
                    maxWidth = 200
                })
            end
            self.tooltipWidget:setPosition(x + 15, y + 15)
            self.tooltipWidget:show()
        elseif not self.hovered and wasHovered then
            -- Mouse exited - hide tooltip
            if self.tooltipWidget then
                self.tooltipWidget:hide()
            end
        elseif self.hovered and self.tooltipWidget then
            -- Mouse moved while hovering - update tooltip position
            self.tooltipWidget:setPosition(x + 15, y + 15)
        end
    end

    return self.hovered
end

--- Handles mouse press events on the button.
-- @param x number Mouse X position
-- @param y number Mouse Y position
-- @param button number Mouse button number
-- @return boolean True if the button was clicked
function Button:mousepressed(x, y, button)
    if button == 1 and self:contains(x, y) then
        self:trigger()
        return true
    end
    return false
end

--- Handles mouse release events. Currently unused.
-- @param x number Mouse X position
-- @param y number Mouse Y position
-- @param button number Mouse button number
function Button:mousereleased(x, y, button)
    -- Handle mouse release if needed
end

--- Triggers the button's click callback.
function Button:trigger()
    if self.enabled and self.onClick then
        self.onClick()
    end
end

return Button
