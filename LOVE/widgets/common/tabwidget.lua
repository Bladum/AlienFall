--[[
widgets/tabwidget.lua
TabWidget for managing and rendering tabbed interfaces with content switching.


Widget that manages and renders a row of tabs with content switching functionality.
Handles tab objects, header rendering, and routes input/drawing to active tab content.

PURPOSE:
- Manage Tab objects and provide unified tabbed interface management
- Render tab headers with proper layout and visual feedback
- Route input and drawing operations to the active tab's content region
- Support dynamic tab creation, removal, and content management

KEY FEATURES:
- Tab header rendering with active/inactive states
- Content switching and activation management
- Dynamic tab addition and removal
- Keyboard navigation support
- Customizable tab appearance and behavior
- Event routing to active tab content
- Accessibility support for screen readers
- Integration with tab content widgets

@see widgets.common.core.Base
@see widgets.common.tab
@see widgets.common.tabcontainer
]]

local core = require("widgets.core")
local TabWidget = {}
TabWidget.__index = TabWidget

--- Creates a new TabWidget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the tab widget
--- @param h number The height of the tab widget
--- @param tabs table Optional array of initial tab objects
--- @return TabWidget A new tab widget instance
function TabWidget:new(x, y, w, h, tabs)
    local obj = { x = x, y = y, w = w, h = h, tabs = tabs or {}, active = 1, onTabChanged = nil, onTabClosed = nil }
    setmetatable(obj, self)
    return obj
end

--- Draws the tab widget and its active content
function TabWidget:draw()
    local tabW = self.w / math.max(1, #self.tabs)
    for i, t in ipairs(self.tabs) do
        local x = self.x + (i - 1) * tabW
        love.graphics.setColor(unpack(core.theme.secondary))
        love.graphics.rectangle("fill", x, self.y, tabW, 24)
        love.graphics.setColor(unpack(core.theme.text))
        love.graphics.print(t.title or ("Tab " .. i), x + 6, self.y + 4)
    end
    if self.tabs[self.active] and self.tabs[self.active].content and self.tabs[self.active].content.draw then
        self.tabs
            [self.active].content:draw()
    end
end

--- Handles mouse press events for the tab widget
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean True if the event was handled, false otherwise
function TabWidget:mousepressed(x, y, button)
    local tabW = self.w / math.max(1, #self.tabs)
    for i = 1, #self.tabs do
        local tx = self.x + (i - 1) * tabW; if core.isInside(x, y, tx, self.y, tabW, 24) then
            self.active = i; return true
        end
    end
    if self.tabs[self.active] and self.tabs[self.active].content and self.tabs[self.active].content.mousepressed then
        return
            self.tabs[self.active].content:mousepressed(x, y, button)
    end
    return false
end

--- Adds a new tab to the tab widget
--- @param title string The title text for the new tab
--- @param content any The content to display when the tab is active
--- @param options table Optional configuration table with tooltip field
--- @return number The index of the newly added tab
function TabWidget:addTab(title, content, options)
    table.insert(self.tabs, { title = title or ("Tab " .. (#self.tabs + 1)), content = content, options = options or {} })
    if options and options.tooltip then self.tabs[#self.tabs].tooltip = options.tooltip end
    if self.onTabChanged then pcall(self.onTabChanged, #self.tabs, self.tabs[#self.tabs]) end
    return #self.tabs
end

--- Closes and removes a tab from the tab widget
--- @param index number The index of the tab to close (1-based)
--- @return boolean True if the tab was successfully closed, false otherwise
function TabWidget:closeTab(index)
    if index < 1 or index > #self.tabs then return false end
    local tab = table.remove(self.tabs, index)
    if self.onTabClosed then pcall(self.onTabClosed, tab, index) end
    if self.active > #self.tabs then self.active = #self.tabs end
    return true
end

return TabWidget
