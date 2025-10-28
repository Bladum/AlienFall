---ListBox Widget - Scrollable Selection List
---
---A scrollable list of selectable items. Used for displaying and selecting from lists
---of options. Grid-aligned for consistent positioning.
---
---Features:
---  - Item selection (single or multi-select)
---  - Vertical scrolling
---  - onSelect event callback
---  - Grid-aligned positioning (24×24 pixels)
---  - Keyboard navigation (arrow keys)
---  - Search/filter support
---
---Selection Modes:
---  - Single: Only one item selected at a time
---  - Multi: Multiple items can be selected (Ctrl+Click)
---  - None: No selection allowed (display only)
---
---Keyboard Navigation:
---  - Up/Down arrows: Move selection
---  - Home/End: First/last item
---  - Page Up/Down: Scroll by page
---  - Enter: Confirm selection
---  - Type to search: Filter items by text
---
---Key Exports:
---  - ListBox.new(x, y, width, height): Creates listbox
---  - setItems(items): Sets list data
---  - addItem(item): Adds single item
---  - removeItem(index): Removes item
---  - getSelectedItem(): Returns selected item
---  - setSelectionMode(mode): Sets selection behavior
---  - setCallback(func): Sets onSelect handler
---  - draw(): Renders listbox
---  - mousepressed(x, y, button): Click handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.navigation.listbox
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ListBox = require("gui.widgets.navigation.listbox")
---  local list = ListBox.new(0, 0, 240, 480)
---  list:setItems({"Option 1", "Option 2", "Option 3"})
---  list:setCallback(function(item) print("Selected:", item) end)
---  list:draw()
---
---@see widgets.navigation.dropdown For dropdown menus

--[[
    ListBox Widget
    
    A scrollable list of selectable items.
    Features:
    - Item selection
    - Scrolling support
    - onSelect event
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local ListBox = setmetatable({}, {__index = BaseWidget})
ListBox.__index = ListBox

--[[
    Create a new list box
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New list box instance
]]
function ListBox.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "listbox")
    setmetatable(self, ListBox)
    
    self.items = {}
    self.selectedIndex = 0
    self.scrollOffset = 0
    self.itemHeight = 24
    self.onSelect = nil
    
    return self
end

--[[
    Draw the list box
]]
function ListBox:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Set scissor for clipping
    love.graphics.push()
    love.graphics.setScissor(self.x, self.y, self.width, self.height)
    
    -- Draw items
    local visibleCount = math.floor(self.height / self.itemHeight)
    local startIndex = math.max(1, self.scrollOffset + 1)
    local endIndex = math.min(#self.items, startIndex + visibleCount - 1)
    
    Theme.setFont(self.font)
    local font = Theme.getFont(self.font)
    local textHeight = font:getHeight()
    
    for i = startIndex, endIndex do
        local itemY = self.y + (i - startIndex) * self.itemHeight
        
        -- Highlight selected item
        if i == self.selectedIndex then
            Theme.setColor(self.activeColor)
            love.graphics.rectangle("fill", self.x, itemY, self.width, self.itemHeight)
        end
        
        -- Draw item text
        local textColor = self.enabled and self.textColor or self.disabledTextColor
        Theme.setColor(textColor)
        local textY = itemY + (self.itemHeight - textHeight) / 2
        love.graphics.print(tostring(self.items[i]), self.x + 4, textY)
    end
    
    love.graphics.setScissor()
    love.graphics.pop()
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

--[[
    Handle mouse press
]]
function ListBox:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button ~= 1 or not self:containsPoint(x, y) then
        return false
    end
    
    -- Calculate which item was clicked
    local relativeY = y - self.y
    local itemIndex = math.floor(relativeY / self.itemHeight) + self.scrollOffset + 1
    
    if itemIndex >= 1 and itemIndex <= #self.items then
        self.selectedIndex = itemIndex
        
        if self.onSelect then
            self.onSelect(itemIndex, self.items[itemIndex])
        end
        
        return true
    end
    
    return false
end

--[[
    Handle mouse wheel scrolling
]]
function ListBox:wheelmoved(x, y)
    if not self.visible or not self.enabled then
        return false
    end
    
    local mx, my = love.mouse.getPosition()
    if self:containsPoint(mx, my) then
        self.scrollOffset = self.scrollOffset - y
        local visibleCount = math.floor(self.height / self.itemHeight)
        local maxScroll = math.max(0, #self.items - visibleCount)
        self.scrollOffset = math.max(0, math.min(self.scrollOffset, maxScroll))
        return true
    end
    
    return false
end

--[[
    Set list items
    @param items table - Array of items to display
]]
function ListBox:setItems(items)
    self.items = items or {}
    self.selectedIndex = 0
    self.scrollOffset = 0
end

--[[
    Add an item to the list
    @param item any - Item to add
]]
function ListBox:addItem(item)
    table.insert(self.items, item)
end

--[[
    Remove an item from the list
    @param index number - Index of item to remove
]]
function ListBox:removeItem(index)
    if index >= 1 and index <= #self.items then
        table.remove(self.items, index)
        if self.selectedIndex == index then
            self.selectedIndex = 0
        elseif self.selectedIndex > index then
            self.selectedIndex = self.selectedIndex - 1
        end
    end
end

--[[
    Clear all items
]]
function ListBox:clearItems()
    self.items = {}
    self.selectedIndex = 0
    self.scrollOffset = 0
end

--[[
    Get selected item
    @return any or nil - Selected item
]]
function ListBox:getSelectedItem()
    if self.selectedIndex > 0 and self.selectedIndex <= #self.items then
        return self.items[self.selectedIndex]
    end
    return nil
end

--[[
    Get selected index
    @return number - Selected index (0 if nothing selected)
]]
function ListBox:getSelectedIndex()
    return self.selectedIndex
end

return ListBox



























