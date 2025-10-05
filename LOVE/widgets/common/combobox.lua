--[[
widgets/combobox.lua
ComboBox widget (dropdown selection with basic search)


Basic combobox widget providing dropdown selection with simple search functionality.
Currently implements core selection mechanics with placeholder for advanced features.
Suitable for small to medium-sized item lists in tactical strategy game interfaces.

PURPOSE:
- Provide dropdown selection from predefined item lists
- Support basic text-based filtering for item search
- Enable keyboard and mouse interaction for item selection
- Foundation for more advanced combobox implementations

KEY FEATURES:
- Dropdown list with mouse selection
- Basic text input for item filtering
- Keyboard cycling through options
- Callback system for selection changes
- Configurable options and theming
- Simple, lightweight implementation

@see widgets.common.core.Base
@see widgets.common.listbox
@see widgets.common.dropdown
@see widgets.complex.autocomplete
]]

local core = require("widgets.core")
local AutoCompleteMixin = require("widgets.common.autocomplete_mixin")
--- @class ComboBox
local ComboBox = {}
ComboBox.__index = ComboBox

function ComboBox:new(x, y, w, h, items, options)
    local obj = { x = x, y = y, w = w, h = h or 30, items = items or {}, selected = 1, options = options or {}, text = "" }
    setmetatable(obj, self)
    if options and options.autoComplete then
        AutoCompleteMixin.init(obj)
    end
    return obj
end

--- Draws the combobox widget
function ComboBox:draw()
    love.graphics.setColor(unpack(core.theme.secondary))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.print(self.items[self.selected] or "", self.x + 6, self.y + 4)
end

--- Handles mouse press events for the combobox
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean True if the event was handled, false otherwise
function ComboBox:mousepressed(x, y, button)
    -- basic select on click (cycle for demo)
    if button == 1 and core.isInside(x, y, self.x, self.y, self.w, self.h) then
        self.selected = (self.selected % #self.items) + 1
        if self.options.onSelectionChanged then
            pcall(self.options.onSelectionChanged, self.selected,
                self.items[self.selected])
        end
        return true
    end
    return false
end

--- Handles text input for search functionality
--- @param t string The text input character
function ComboBox:textinput(t)
    if self.options.searchable then
        self.text = (self.text or "") .. t
        -- naive filtering: find first match
        for i, it in ipairs(self.items) do
            if tostring(it):lower():find(self.text:lower(), 1, true) then
                self.selected = i; break
            end
        end
    end
end

return ComboBox
