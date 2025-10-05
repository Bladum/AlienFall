-- ComboBox widget for dropdown selection
local class = require("lib.middleclass")

--- @class GameComboBox
--- A dropdown selection widget that displays a list of options in a scrollable menu.
--- Supports hover highlighting, keyboard navigation, and callback functions.
local GameComboBox = class('GameComboBox')

--- Creates a new GameComboBox instance.
--- @param x number The x-coordinate of the combobox
--- @param y number The y-coordinate of the combobox
--- @param width number The width of the combobox
--- @param height number The height of the combobox
--- @param options table Array of string options to display
--- @param selectedIndex number The initially selected option index (default: 1)
--- @param callback function Callback function called when selection changes (optional)
--- @return GameComboBox A new GameComboBox instance
function GameComboBox:initialize(x, y, width, height, options, selectedIndex, callback)
    -- Position and size
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- Options
    self.options = options or {}
    self.selectedIndex = selectedIndex or 1
    self.callback = callback

    -- Dropdown state
    self.isOpen = false
    self.dropdownHeight = 150  -- Max height of dropdown

    -- Styling
    self.font = love.graphics.newFont(16)
    self.textColor = {1, 1, 1, 1}
    self.backgroundColor = {0.2, 0.2, 0.2, 1}
    self.hoverColor = {0.4, 0.4, 0.4, 1}
    self.borderColor = {0.8, 0.8, 0.8, 1}
    self.arrowColor = {0.8, 0.8, 0.8, 1}

    -- State
    self.hoveredIndex = nil
    self.enabled = true
    self.visible = true

    -- Calculate item height
    self.itemHeight = self.font:getHeight() + 8  -- Text height + padding
end

--- Updates the combobox state based on mouse position.
--- Handles hover detection for both the main button and dropdown items.
--- @param dt number Delta time since last update (unused but included for consistency)
function GameComboBox:update(dt)
    if not self.enabled or not self.visible then return end

    -- Get mouse position
    local mouseX, mouseY = mouseX, mouseY

    self.hoveredIndex = nil

    if self.isOpen then
        -- Check hover in dropdown
        for i = 1, #self.options do
            local itemY = self.y + self.height + (i - 1) * self.itemHeight
            if mouseX >= self.x and mouseX <= self.x + self.width and
               mouseY >= itemY and mouseY <= itemY + self.itemHeight and
               itemY < self.y + self.height + self.dropdownHeight then
                self.hoveredIndex = i
                break
            end
        end
    else
        -- Check hover on main button
        if mouseX >= self.x and mouseX <= self.x + self.width and
           mouseY >= self.y and mouseY <= self.y + self.height then
            self.hoveredIndex = 0  -- Special value for main button
        end
    end
end

--- Handles mouse press events for combobox interaction.
--- Opens/closes dropdown and handles option selection.
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @param button number Mouse button number (1 = left click)
--- @return boolean True if the event was handled, false otherwise
function GameComboBox:mousepressed(x, y, button)
    if not self.enabled or not self.visible or button ~= 1 then return end

    if self.isOpen then
        -- Check if click is in dropdown
        for i = 1, #self.options do
            local itemY = self.y + self.height + (i - 1) * self.itemHeight
            if x >= self.x and x <= self.x + self.width and
               y >= itemY and y <= itemY + self.itemHeight and
               itemY < self.y + self.height + self.dropdownHeight then
                self:setSelected(i)
                self.isOpen = false
                return true
            end
        end

        -- Click outside dropdown closes it
        self.isOpen = false
    else
        -- Check if click is on main button
        if x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height then
            self.isOpen = true
            return true
        end
    end

    return false
end

--- Handles mouse release events (provided for consistency with other widgets).
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @param button number Mouse button number
--- @return boolean Always returns false as selection is handled on mousepressed
function GameComboBox:mousereleased(x, y, button)
    -- ComboBox handles selection on mousepressed, so mousereleased is not needed
    -- But we provide it for consistency with other widgets
    return false
end

--- Sets the selected option by index and triggers the callback.
--- @param index number The index of the option to select (1-based)
function GameComboBox:setSelected(index)
    if index >= 1 and index <= #self.options then
        self.selectedIndex = index
        if self.callback then
            self.callback(index, self.options[index])
        end
    end
end

--- Gets the currently selected option.
--- @return number, string The selected index and the selected option text
function GameComboBox:getSelected()
    return self.selectedIndex, self.options[self.selectedIndex]
end

--- Draws the combobox including the main button and dropdown if open.
--- Handles hover highlighting and arrow direction based on open state.
function GameComboBox:draw()
    if not self.visible then return end

    love.graphics.setFont(self.font)

    -- Draw main button background
    local mainBgColor = (self.hoveredIndex == 0) and self.hoverColor or self.backgroundColor
    love.graphics.setColor(mainBgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw main button border
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw selected text
    love.graphics.setColor(self.textColor)
    local selectedText = self.options[self.selectedIndex] or ""
    love.graphics.print(selectedText, self.x + 10, self.y + 6)

    -- Draw arrow
    love.graphics.setColor(self.arrowColor)
    local arrowX = self.x + self.width - 20
    local arrowY = self.y + self.height / 2
    if self.isOpen then
        -- Up arrow
        love.graphics.polygon("fill", arrowX, arrowY + 5, arrowX + 10, arrowY + 5, arrowX + 5, arrowY - 5)
    else
        -- Down arrow
        love.graphics.polygon("fill", arrowX, arrowY - 5, arrowX + 10, arrowY - 5, arrowX + 5, arrowY + 5)
    end

    -- Draw dropdown if open
    if self.isOpen then
        local dropdownY = self.y + self.height
        local dropdownH = math.min(self.dropdownHeight, #self.options * self.itemHeight)

        -- Dropdown background
        love.graphics.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", self.x, dropdownY, self.width, dropdownH)

        -- Dropdown border
        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle("line", self.x, dropdownY, self.width, dropdownH)

        -- Draw options
        for i = 1, #self.options do
            local itemY = dropdownY + (i - 1) * self.itemHeight
            if itemY + self.itemHeight <= dropdownY + dropdownH then
                -- Highlight hovered item
                if i == self.hoveredIndex then
                    love.graphics.setColor(self.hoverColor)
                    love.graphics.rectangle("fill", self.x, itemY, self.width, self.itemHeight)
                end

                -- Draw text
                love.graphics.setColor(self.textColor)
                love.graphics.print(self.options[i], self.x + 10, itemY + 4)
            end
        end
    end
end

--- Handles mouse movement events (provided for consistency with other widgets).
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @param dx number Change in x-coordinate
--- @param dy number Change in y-coordinate
--- @return boolean Always returns false as combobox doesn't need mouse movement handling
function GameComboBox:mousemoved(x, y, dx, dy)
    -- ComboBox doesn't need mouse movement handling, return false
    return false
end

--- Handles mouse wheel events (provided for consistency with other widgets).
--- @param x number Mouse wheel x-delta
--- @param y number Mouse wheel y-delta
--- @return boolean Always returns false as combobox doesn't need wheel handling
function GameComboBox:wheelmoved(x, y)
    -- ComboBox doesn't need wheel handling, return false
    return false
end

return GameComboBox
