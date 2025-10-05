--[[
widgets/dropdown.lua
Dropdown widget for selection from predefined lists


Simple dropdown selection widget with expandable list for compact option selection.
Essential for forms and settings interfaces requiring predefined choice selection.

PURPOSE:
- Provide compact dropdown selection from predefined item lists
- Enable expandable list display for option selection
- Support keyboard and mouse interaction for accessibility
- Facilitate form-based interfaces with selection controls

KEY FEATURES:
- Compact display showing current selection
- Expandable list of all available options
- Mouse and keyboard interaction support
- Callback system for selection changes
- Theme integration for consistent styling

@see widgets.common.combobox
@see widgets.common.listbox
]]

local core = require("widgets.core")
local Dropdown = {}
Dropdown.__index = Dropdown

--- Creates a new Dropdown widget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the dropdown
--- @param h number The height of the dropdown
--- @param items table Array of items to display in the dropdown
--- @param selectedIndex number The initially selected item index
--- @param callback function The function to call when selection changes
--- @return Dropdown A new dropdown widget instance
function Dropdown:new(x, y, w, h, items, selectedIndex, callback)
    local obj = {
        x = x,
        y = y,
        w = w,
        h = h or 24,
        items = items or {},
        selected = selectedIndex or 1,
        open = false,
        callback =
            callback
    }
    setmetatable(obj, self)
    return obj
end

--- Updates the dropdown state
--- @param dt number Time delta since last update
function Dropdown:update(dt)
    local mx, my = love.mouse.getPosition()
    if self.open then core.setTooltipWidget(self) end
end

--- Draws the dropdown widget
function Dropdown:draw()
    love.graphics.setColor(unpack(core.theme.secondary))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.print(self.items[self.selected] or "", self.x + 4, self.y + 4)
    if self.open then
        for i, v in ipairs(self.items) do
            love.graphics.setColor(unpack(core.theme.background))
            love.graphics.rectangle("fill", self.x, self.y + i * self.h, self.w, self.h)
            love.graphics.setColor(unpack(core.theme.text))
            love.graphics.print(v, self.x + 4, self.y + i * self.h + 4)
            love.graphics.setColor(unpack(core.theme.border))
            love.graphics.rectangle("line", self.x, self.y + i * self.h, self.w, self.h)
        end
    end
end

--- Handles mouse press events for the dropdown
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean True if the event was handled, false otherwise
function Dropdown:mousepressed(x, y, button)
    if button ~= 1 then return false end
    if core.isInside(x, y, self.x, self.y, self.w, self.h) then
        self.open = not self.open; return true
    end
    if self.open then
        for i = 1, #self.items do
            if core.isInside(x, y, self.x, self.y + i * self.h, self.w, self.h) then
                self.selected = i; self.open = false; if self.callback then self.callback(i) end; return true
            end
        end
        self.open = false
    end
    return false
end

return Dropdown
