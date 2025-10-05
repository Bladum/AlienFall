-- Tooltip widget
--- @class GameTooltip
--- @description A tooltip widget that displays contextual help text with hover delay
--- and automatic positioning. Features rounded corners and configurable styling.
--- @field text string The text content to display
--- @field x number Current X position
--- @field y number Current Y position
--- @field width number Width of the tooltip
--- @field height number Height of the tooltip
--- @field visible boolean Whether the tooltip is currently visible
--- @field hoverStartTime number Time when hover started
--- @field hoverDelay number Delay before showing tooltip (seconds)
--- @field isHovering boolean Whether currently in hover state
--- @field font love.Font Font used for rendering
--- @field textColor table Text color {r,g,b,a}
--- @field backgroundColor table Background color {r,g,b,a}
--- @field borderColor table Border color {r,g,b,a}
--- @field padding number Padding around text
--- @field borderRadius number Radius for rounded corners
local class = require 'lib.Middleclass'

local GameTooltip = class('GameTooltip')

--- Creates a new GameTooltip instance.
--- @return GameTooltip A new GameTooltip instance
function GameTooltip:initialize()
    -- Properties
    self.text = ""
    self.x = 0
    self.y = 0
    self.width = 200
    self.height = 40
    self.visible = false

    -- Hover timing
    self.hoverStartTime = 0
    self.hoverDelay = 0.3 -- 300ms delay
    self.isHovering = false

    -- Styling
    self.font = love.graphics.getFont()  -- Use global font
    self.textColor = {1, 1, 1, 1}
    self.backgroundColor = {0.0, 0.0, 0.0, 0.95} -- More opaque black background
    self.borderColor = {0.8, 0.8, 0.8, 1}
    self.padding = 8
    self.borderRadius = 6  -- Rounded border radius
end

--- Sets the text content and recalculates tooltip dimensions.
--- @param text string The text to display
function GameTooltip:setText(text)
    self.text = text or ""

    -- Calculate dimensions based on text
    local font = love.graphics.getFont()
    love.graphics.setFont(self.font)

    -- Split text into lines and find the maximum width
    local lines = {}
    local maxWidth = 0
    for line in string.gmatch(self.text, "[^\n]+") do
        table.insert(lines, line)
        local lineWidth = love.graphics.getFont():getWidth(line)
        if lineWidth > maxWidth then
            maxWidth = lineWidth
        end
    end

    self.width = maxWidth + self.padding * 2
    self.height = #lines * love.graphics.getFont():getHeight() + self.padding * 2

    -- Ensure minimum width
    if self.width < 100 then
        self.width = 100
    end

    love.graphics.setFont(font)
end

--- Starts the hover timer for tooltip display.
function GameTooltip:startHover()
    self.isHovering = true
    self.hoverStartTime = love.timer.getTime()
end

--- Stops the hover state and hides the tooltip.
function GameTooltip:stopHover()
    self.isHovering = false
    self.visible = false
end

--- Updates the tooltip state and handles hover delay timing.
--- @param dt number Delta time since last update
function GameTooltip:update(dt)
    if self.isHovering and not self.visible then
        local currentTime = love.timer.getTime()
        if currentTime - self.hoverStartTime >= self.hoverDelay then
            self.visible = true
        end
    end
end

--- Draws the tooltip with rounded corners and border.
function GameTooltip:draw()
    if not self.visible or self.text == "" then return end

    local font = love.graphics.getFont()
    love.graphics.setFont(self.font)

    -- Draw background with rounded corners
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.borderRadius, self.borderRadius)

    -- Draw border with rounded corners
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.borderRadius, self.borderRadius)
    -- Draw a second border for better visibility
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x-1, self.y-1, self.width+2, self.height+2, self.borderRadius, self.borderRadius)

    -- Draw text
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.text, self.x + self.padding, self.y + self.padding)

    love.graphics.setFont(font)
end

--- Sets the position of the tooltip.
--- @param x number X coordinate
--- @param y number Y coordinate
function GameTooltip:setPosition(x, y)
    self.x = x
    self.y = y
end

--- Immediately shows the tooltip.
function GameTooltip:show()
    self.visible = true
end

--- Hides the tooltip and stops hover state.
function GameTooltip:hide()
    self.visible = false
    self.isHovering = false
end

return Tooltip
