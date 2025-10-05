--- @class Checkbox
--- A checkbox widget for boolean selection with label and hover effects.
--- @field id string Unique identifier for the checkbox
--- @field label string Display label for the checkbox
--- @field onChange function Callback when checkbox state changes: function(checked)
--- @field width number Width of the checkbox in pixels
--- @field height number Height of the checkbox in pixels
--- @field enabled boolean Whether the checkbox is interactive
--- @field checked boolean Current checked state
--- @field hovered boolean Whether the mouse is hovering over the checkbox
--- @field x number X position of the checkbox
--- @field y number Y position of the checkbox
--- @field font love.Font Font used for rendering text
local class = require("lib.middleclass")

local Checkbox = class('Checkbox')

--- Creates a new Checkbox instance.
--- @param opts table Configuration options for the checkbox
--- @return Checkbox A new Checkbox instance
--- @usage local checkbox = Checkbox.new({
---     label = "Enable feature",
---     checked = false,
---     onChange = function(checked) print("Checked:", checked) end
--- })
function Checkbox:initialize(opts)
    self.id = opts.id
    self.label = opts.label or "Checkbox"
    self.onChange = opts.onChange or function(checked) end
    self.width = opts.width or 200
    self.height = opts.height or 40  -- 2 tiles height
    self.enabled = opts.enabled ~= false
    self.checked = opts.checked or false
    self.hovered = false
    self.x = opts.x or 0
    self.y = opts.y or 0
    self.font = opts.font or love.graphics.newFont(14)  -- Default smaller font
end

--- Updates the checkbox state (placeholder for animation hooks).
--- @param dt number Delta time since last update
function Checkbox:update(dt)
    -- placeholder for animation hooks
end

--- Sets the position of the checkbox.
--- @param x number New x-coordinate
--- @param y number New y-coordinate
function Checkbox:setPosition(x, y)
    self.x = x
    self.y = y
end

--- Draws the checkbox with box, checkmark (if checked), and label.
--- @param focused boolean Whether the checkbox is currently focused
function Checkbox:draw(focused)
    local x = self.x
    local y = self.y
    local boxSize = 16
    local boxY = y + (self.height - boxSize) / 2  -- Center the box vertically
    local labelX = x + boxSize + 8
    local labelWidth = self.width - boxSize - 8

    -- Draw checkbox box
    local boxColor = {0.12, 0.18, 0.32, 1}
    if self.hovered or focused then
        boxColor = {0.18, 0.28, 0.42, 1}
    end
    love.graphics.setColor(boxColor)
    love.graphics.rectangle("fill", x, boxY, boxSize, boxSize, 4, 4)
    love.graphics.setColor(0.05, 0.08, 0.1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, boxY, boxSize, boxSize, 4, 4)

    -- Draw check mark if checked
    if self.checked then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(3)
        local checkX = x + 3
        local checkY = boxY + 3
        love.graphics.line(checkX, checkY + 6, checkX + 4, checkY + 10)
        love.graphics.line(checkX + 4, checkY + 10, checkX + 10, checkY + 2)
    end

    -- Draw label
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.font)
    local fontHeight = self.font:getHeight()
    love.graphics.printf(self.label, labelX, y + (self.height - fontHeight) / 2, labelWidth, "left")
end

--- Checks if the given coordinates are within the checkbox bounds.
--- @param x number X-coordinate to check
--- @param y number Y-coordinate to check
--- @return boolean True if the coordinates are within bounds, false otherwise
function Checkbox:contains(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

--- Handles mouse movement events and updates hover state.
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @return boolean True if the mouse is hovering over the checkbox, false otherwise
function Checkbox:mousemoved(x, y)
    self.hovered = self:contains(x, y)
    return self.hovered
end

--- Handles mouse press events for checkbox interaction.
--- Toggles the checked state and triggers the callback.
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @param button number Mouse button number (1 = left click)
--- @return boolean True if the event was handled, false otherwise
function Checkbox:mousepressed(x, y, button)
    if button == 1 and self:contains(x, y) then
        self.checked = not self.checked
        self:trigger()
        return true
    end
    return false
end

--- Handles mouse release events (provided for consistency).
--- @param x number Mouse x-coordinate
--- @param y number Mouse y-coordinate
--- @param button number Mouse button number
function Checkbox:mousereleased(x, y, button)
    -- Handle mouse release if needed
end

--- Triggers the onChange callback with the current checked state.
function Checkbox:trigger()
    if self.enabled and self.onChange then
        self.onChange(self.checked)
    end
end

--- Sets the checked state of the checkbox.
--- @param checked boolean The new checked state
function Checkbox:setChecked(checked)
    self.checked = checked
end

--- Gets the current checked state of the checkbox.
--- @return boolean True if checked, false otherwise
function Checkbox:isChecked()
    return self.checked
end

return Checkbox
