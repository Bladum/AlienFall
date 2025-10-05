-- RadioBox widget for single selection from multiple options
--- @class RadioBox
--- @description A radio button widget that allows single selection from multiple options.
--- Each option is displayed with a circular radio button and text label.
--- @field x number X position of the radio box
--- @field y number Y position of the radio box
--- @field width number Width of the radio box
--- @field height number Height of the radio box
--- @field options table Array of option strings to display
--- @field selectedIndex number Index of currently selected option
--- @field callback function Callback function called when selection changes: function(index, option)
--- @field font love.Font Font used for rendering option text
--- @field textColor table Text color {r,g,b,a}
--- @field radioColor table Radio button background color {r,g,b,a}
--- @field selectedColor table Selected radio button fill color {r,g,b,a}
--- @field hoverColor table Hover highlight color {r,g,b,a}
--- @field hoveredIndex number|nil Index of currently hovered option
--- @field enabled boolean Whether the widget responds to input
--- @field visible boolean Whether the widget is drawn
--- @field itemHeight number Height of each radio button item
local class = require 'lib.Middleclass'

local RadioBox = class('RadioBox')

--- Creates a new RadioBox instance.
--- @param x number X position
--- @param y number Y position
--- @param width number Width of the radio box
--- @param height number Height of the radio box
--- @param options table Array of option strings
--- @param selectedIndex number Initially selected option index (defaults to 1)
--- @param callback function Selection callback: function(index, option)
--- @return RadioBox A new RadioBox instance
function RadioBox:initialize(x, y, width, height, options, selectedIndex, callback)
    -- Position and size
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- Options and selection
    self.options = options or {}
    self.selectedIndex = selectedIndex or 1
    self.callback = callback

    -- Styling
    self.font = love.graphics.newFont(16)
    self.textColor = {1, 1, 1, 1}
    self.radioColor = {0.8, 0.8, 0.8, 1}
    self.selectedColor = {0.2, 0.8, 0.2, 1}
    self.hoverColor = {1, 1, 0, 1}

    -- State flags
    self.hoveredIndex = nil
    self.enabled = true
    self.visible = true

    -- Calculate item height based on font and padding
    self.itemHeight = self.font:getHeight() + 8  -- Text height + padding
end

--- Updates the radio box state and hover detection.
--- @param dt number Delta time since last update
function RadioBox:update(dt)
    if not self.enabled or not self.visible then return end

    -- Get mouse position for hover detection
    local mouseX, mouseY = _G.mouseX, _G.mouseY

    -- Check hover for each option
    self.hoveredIndex = nil
    for i = 1, #self.options do
        local itemY = self.y + (i - 1) * self.itemHeight
        if mouseX >= self.x and mouseX <= self.x + self.width and
           mouseY >= itemY and mouseY <= itemY + self.itemHeight then
            self.hoveredIndex = i
            break
        end
    end
end

--- Handles mouse press events for option selection.
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param button number Mouse button (1 = left)
--- @return boolean True if an option was selected
function RadioBox:mousepressed(x, y, button)
    if not self.enabled or not self.visible or button ~= 1 then return end

    -- Check if click is on an option
    for i = 1, #self.options do
        local itemY = self.y + (i - 1) * self.itemHeight
        if x >= self.x and x <= self.x + self.width and
           y >= itemY and y <= itemY + self.itemHeight then
            self:setSelected(i)
            return true
        end
    end

    return false
end

--- Handles mouse release events (not used by RadioBox).
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param button number Mouse button
--- @return boolean Always returns false
function RadioBox:mousereleased(x, y, button)
    -- RadioBox handles selection on mousepressed, so mousereleased is not needed
    -- But we provide it for consistency with other widgets
    return false
end

--- Sets the selected option and triggers callback if provided.
--- @param index number The option index to select (1-based)
function RadioBox:setSelected(index)
    if index >= 1 and index <= #self.options then
        self.selectedIndex = index
        if self.callback then
            self.callback(index, self.options[index])
        end
    end
end

--- Gets the currently selected option index and value.
--- @return number, string The selected index and option string
function RadioBox:getSelected()
    return self.selectedIndex, self.options[self.selectedIndex]
end

--- Draws the radio box with all options and selection indicators.
function RadioBox:draw()
    if not self.visible then return end

    love.graphics.setFont(self.font)

    for i = 1, #self.options do
        local itemY = self.y + (i - 1) * self.itemHeight
        local isSelected = (i == self.selectedIndex)
        local isHovered = (i == self.hoveredIndex)

        -- Draw radio button circle
        local radioX = self.x + 10
        local radioY = itemY + self.itemHeight / 2
        local radioRadius = 8

        -- Radio button background
        love.graphics.setColor(self.radioColor)
        love.graphics.circle("fill", radioX, radioY, radioRadius)

        -- Selected indicator
        if isSelected then
            love.graphics.setColor(self.selectedColor)
            love.graphics.circle("fill", radioX, radioY, radioRadius * 0.6)
        elseif isHovered then
            love.graphics.setColor(self.hoverColor)
            love.graphics.circle("line", radioX, radioY, radioRadius + 2)
        end

        -- Draw text
        love.graphics.setColor(self.textColor)
        love.graphics.print(self.options[i], self.x + 30, itemY + 4)
    end
end

return RadioBox
