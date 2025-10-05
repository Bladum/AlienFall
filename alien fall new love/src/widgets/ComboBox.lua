--- A dropdown selection widget (combobox) with hover effects and keyboard navigation.
local class = require("lib.middleclass")

--- @class ComboBox
--- A dropdown selection widget (combobox) with hover effects and keyboard navigation.
--- @field id string Unique identifier for the combobox
--- @field label string Display label for the combobox
--- @field options table Array of selectable options
--- @field selectedIndex number Index of currently selected option
--- @field onChange function Callback when selection changes: function(index, value)
--- @field width number Width of the combobox in pixels
--- @field height number Height of the combobox in pixels
--- @field enabled boolean Whether the combobox is interactive
--- @field expanded boolean Whether the dropdown is currently expanded
--- @field hovered boolean Whether the mouse is hovering over the combobox
--- @field x number X position of the combobox
--- @field y number Y position of the combobox
--- @field font love.Font Font used for rendering text
local ComboBox = class('ComboBox')

--- Creates a new ComboBox instance.
--- @param opts table Configuration options for the combobox
--- @return ComboBox A new ComboBox instance
--- @usage local combo = ComboBox.new({
---     options = {"Option 1", "Option 2", "Option 3"},
---     selectedIndex = 1,
---     onChange = function(index, value) print("Selected:", value) end
--- })
function ComboBox:initialize(opts)
    self.id = opts.id
    self.label = opts.label or "Combobox"
    self.options = opts.options or {}
    self.selectedIndex = opts.selectedIndex or 1
    self.onChange = opts.onChange or function(index, value) end
    self.width = opts.width or 200
    self.height = opts.height or 40  -- 2 tiles height
    self.enabled = opts.enabled ~= false
    self.expanded = false
    self.hovered = false
    self.x = opts.x or 0
    self.y = opts.y or 0
    self.font = opts.font or love.graphics.newFont(14)  -- Default smaller font
end

--- Updates the combobox state (placeholder for animation hooks).
--- @param dt number Delta time since last update
function ComboBox:update(dt)
    -- placeholder for animation hooks
end

--- Sets the position of the combobox.
--- @param x number New x-coordinate
--- @param y number New y-coordinate
function ComboBox:setPosition(x, y)
    self.x = x
    self.y = y
end

--- Draws the main combobox button.
--- @param focused boolean Whether the combobox is currently focused
function ComboBox:draw(focused)
    local x = self.x
    local y = self.y
    local boxHeight = self.height

    -- Draw main box
    local boxColor = {0.12, 0.18, 0.32, 1}
    if self.hovered or focused then
        boxColor = {0.18, 0.28, 0.42, 1}
    end
    love.graphics.setColor(boxColor)
    love.graphics.rectangle("fill", x, y, self.width, boxHeight, 4, 4)
    love.graphics.setColor(0.05, 0.08, 0.1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, self.width, boxHeight, 4, 4)

    -- Draw selected text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.font)
    local selectedText = self.options[self.selectedIndex] or "Select..."
    local fontHeight = self.font:getHeight()
    love.graphics.printf(selectedText, x + 8, y + (boxHeight - fontHeight) / 2, self.width - 32, "left")

    -- Draw dropdown arrow
    love.graphics.setColor(1, 1, 1, 1)
    local arrowX = x + self.width - 20
    local arrowY = y + boxHeight / 2
    if self.expanded then
        love.graphics.polygon("fill", arrowX, arrowY + 4, arrowX + 8, arrowY - 4, arrowX + 16, arrowY + 4)
    else
        love.graphics.polygon("fill", arrowX, arrowY - 4, arrowX + 8, arrowY + 4, arrowX + 16, arrowY - 4)
    end
end

--- Draws the expanded dropdown options when the combobox is expanded.
function ComboBox:drawDropdown()
    if not self.expanded then return end
    
    local x = self.x
    local y = self.y
    local boxHeight = self.height
    
    love.graphics.setFont(self.font)
    
    -- Draw expanded options
    for i, option in ipairs(self.options) do
        local optionY = y + i * boxHeight
        local optionColor = {0.15, 0.22, 0.35, 1}
        if i == self.selectedIndex then
            optionColor = {0.25, 0.35, 0.5, 1}
        end
        love.graphics.setColor(optionColor)
        love.graphics.rectangle("fill", x, optionY, self.width, boxHeight)
        love.graphics.setColor(0.05, 0.08, 0.1, 1)
        love.graphics.rectangle("line", x, optionY, self.width, boxHeight)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(option, x + 8, optionY + (boxHeight - self.font:getHeight()) / 2, self.width - 16, "left")
    end
end

--- Checks if the given coordinates are within the combobox bounds.
--- @param x number X-coordinate to check
--- @param y number Y-coordinate to check
--- @return boolean True if the coordinates are within bounds, false otherwise
function ComboBox:contains(x, y)
    local boxHeight = self.height
    local totalHeight = self.expanded and (boxHeight + #self.options * boxHeight) or boxHeight
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + totalHeight
end

--- Handles mouse movement events and updates hover state.
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @return boolean True if the mouse is hovering over the combobox, false otherwise
function ComboBox:mousemoved(x, y)
    self.hovered = self:contains(x, y)
    return self.hovered
end

--- Handles mouse press events for combobox interaction.
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @param button number Mouse button number (1 = left click)
--- @return boolean True if the event was handled, false otherwise
function ComboBox:mousepressed(x, y, button)
    if button == 1 and self:contains(x, y) then
        if self.expanded then
            -- Check if clicked on an option
            local boxHeight = self.height
            local clickedIndex = math.floor((y - self.y) / boxHeight)
            if clickedIndex >= 1 and clickedIndex <= #self.options then
                self.selectedIndex = clickedIndex
                self:trigger()
            end
        end
        self.expanded = not self.expanded
        return true
    elseif self.expanded then
        -- Click outside closes dropdown
        self.expanded = false
        return true
    end
    return false
end

--- Handles mouse release events (provided for consistency).
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @param button number Mouse button number
function ComboBox:mousereleased(x, y, button)
    -- Handle mouse release if needed
end

--- Triggers the onChange callback with the current selection.
function ComboBox:trigger()
    if self.enabled and self.onChange then
        self.onChange(self.selectedIndex, self.options[self.selectedIndex])
    end
end

--- Sets the selected option by index.
--- @param index number The index of the option to select
function ComboBox:setSelectedIndex(index)
    self.selectedIndex = index
end

--- Gets the index of the currently selected option.
--- @return number The selected index
function ComboBox:getSelectedIndex()
    return self.selectedIndex
end

--- Gets the value of the currently selected option.
--- @return string The selected option value
function ComboBox:getSelectedValue()
    return self.options[self.selectedIndex]
end

return ComboBox
