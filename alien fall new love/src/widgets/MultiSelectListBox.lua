-- Multi-Select List Box widget with ordering functionality
--- @class MultiSelectListBox
--- @description A dual-list widget allowing selection of multiple items from an available list
--- and reordering of selected items. Features include checkboxes, scrollbars, and up/down buttons.
--- @field x number X position of the widget
--- @field y number Y position of the widget
--- @field width number Width of the widget
--- @field height number Height of the widget
--- @field availableItems table Array of available items to select from
--- @field selectedItems table Array of currently selected items
--- @field availableLabel string Label for the available items section
--- @field selectedLabel string Label for the selected items section
--- @field font love.Font Font used for rendering text
--- @field itemHeight number Height of each list item
--- @field scrollOffset number Scroll position for available items
--- @field selectedScrollOffset number Scroll position for selected items
--- @field visibleItems number Number of visible items in available list
--- @field visibleSelectedItems number Number of visible items in selected list
--- @field hoveredIndex number|nil Index of currently hovered item
--- @field hoveredButton string|nil Name of currently hovered button
--- @field enabled boolean Whether the widget responds to input
--- @field visible boolean Whether the widget is drawn
--- @field onSelectionChanged function Callback when selection changes
local class = require 'lib.Middleclass'

local MultiSelectListBox = class('MultiSelectListBox')

--- Creates a new MultiSelectListBox instance.
--- @param options table Configuration options
--- @field x number X position (defaults to 0)
--- @field y number Y position (defaults to 0)
--- @field width number Width of widget (defaults to 200)
--- @field height number Height of widget (defaults to 200)
--- @field availableItems table Array of available items
--- @field selectedItems table Array of initially selected items
--- @field availableLabel string Label for available section (defaults to "Available Items:")
--- @field selectedLabel string Label for selected section (defaults to "Selected Items:")
--- @field onSelectionChanged function Callback when selection changes
--- @return MultiSelectListBox A new MultiSelectListBox instance
function MultiSelectListBox:initialize(options)
    options = options or {}

    -- Position and size
    self.x = options.x or 0
    self.y = options.y or 0
    self.width = options.width or 200
    self.height = options.height or 200

    -- Items
    self.availableItems = options.availableItems or {}
    self.selectedItems = options.selectedItems or {}

    -- Labels
    self.availableLabel = options.availableLabel or "Available Items:"
    self.selectedLabel = options.selectedLabel or "Selected Items:"

    -- Styling
    self.font = love.graphics.newFont(12)
    self.textColor = {1, 1, 1, 1}
    self.backgroundColor = {0.1, 0.1, 0.1, 1}
    self.selectedColor = {0.3, 0.5, 0.7, 1}
    self.hoverColor = {0.2, 0.3, 0.4, 1}
    self.borderColor = {0.5, 0.5, 0.5, 1}
    self.checkboxColor = {0.7, 0.7, 0.7, 1}
    self.buttonColor = {0.4, 0.4, 0.4, 1}
    self.scrollbarTrackColor = {0.1, 0.1, 0.15, 1}
    self.scrollbarThumbColor = {0.3, 0.4, 0.6, 1}

    -- Layout constants
    self.itemHeight = 25
    self.checkboxWidth = 20
    self.buttonWidth = 30
    self.buttonHeight = 20
    self.scrollbarWidth = 16

    -- Split height between available and selected sections
    local availableSectionHeight = math.floor(self.height * 0.6)  -- 60% for available
    local selectedSectionHeight = self.height - availableSectionHeight

    -- Scrolling for available items
    self.scrollOffset = 0
    self.visibleItems = math.floor((availableSectionHeight - 30) / self.itemHeight) -- Leave space for title

    -- Scrolling for selected items
    self.selectedScrollOffset = 0
    self.visibleSelectedItems = math.floor((selectedSectionHeight - 30) / self.itemHeight) -- Leave space for title

    -- Scrollbar state
    self.isDraggingScrollbar = false
    self.isDraggingSelectedScrollbar = false

    -- State flags
    self.hoveredIndex = nil
    self.hoveredButton = nil
    self.enabled = true
    self.visible = true

    -- Callbacks
    self.onSelectionChanged = options.onSelectionChanged
end

--- Updates the widget state (hover states are handled in mousemoved).
--- @param dt number Delta time since last update
function MultiSelectListBox:update(dt)
    if not self.enabled or not self.visible then return end

    -- Hover states are updated in mousemoved method
end

--- Handles mouse press events for item selection and button interactions.
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param button number Mouse button (1 = left)
--- @return boolean True if the event was handled
function MultiSelectListBox:mousepressed(x, y, button)
    if not self.enabled or not self.visible or button ~= 1 then return false end

    -- Check available items selection
    local availableSectionHeight = math.floor(self.height * 0.6)
    local availableY = self.y + 25  -- Account for title area
    if x >= self.x and x <= self.x + self.width and
       y >= availableY and y <= self.y + availableSectionHeight then  -- Use available section height

        local relativeY = y - availableY
        local itemIndex = math.floor(relativeY / self.itemHeight) + self.scrollOffset + 1

        if itemIndex >= 1 and itemIndex <= #self.availableItems then
            self:toggleSelection(itemIndex)
            return true
        end
    end

    -- Check scrollbar clicks for available items
    if #self.availableItems > self.visibleItems then
        local scrollbarWidth = self.scrollbarWidth
        local scrollbarX = self.x + self.width - scrollbarWidth - 2
        local scrollbarHeight = availableSectionHeight - 30  -- Account for header
        local scrollbarY = self.y + 25

        if x >= scrollbarX and x <= scrollbarX + scrollbarWidth and y >= scrollbarY and y <= scrollbarY + scrollbarHeight then
            -- Calculate scroll position based on click
            local clickRatio = (y - scrollbarY) / scrollbarHeight
            local totalItems = #self.availableItems
            local visibleItems = self.visibleItems
            self.scrollOffset = math.floor(clickRatio * (totalItems - visibleItems))
            self.scrollOffset = math.max(0, math.min(self.scrollOffset, totalItems - visibleItems))
            self.isDraggingScrollbar = true
            return true
        end
    end

    -- Check selected items section
    local selectedSectionY = self.y + availableSectionHeight
    local selectedSectionHeight = self.height - availableSectionHeight
    local selectedY = selectedSectionY + 25

    if x >= self.x and x <= self.x + self.width and
       y >= selectedY and y <= self.y + self.height then

        local relativeY = y - selectedY
        local itemIndex = math.floor(relativeY / self.itemHeight) + self.selectedScrollOffset + 1

        if itemIndex >= 1 and itemIndex <= #self.selectedItems then
            local itemY = selectedY + (itemIndex - self.selectedScrollOffset - 1) * self.itemHeight

            -- Check up button
            if x >= self.x + self.width - self.buttonWidth * 2 - 5 and x <= self.x + self.width - self.buttonWidth - 5 and
               y >= itemY + 2 and y <= itemY + 2 + self.buttonHeight then
                self:moveItemUp(itemIndex)
                return true
            end

            -- Check down button
            if x >= self.x + self.width - self.buttonWidth - 5 and x <= self.x + self.width - 5 and
               y >= itemY + 2 and y <= itemY + 2 + self.buttonHeight then
                self:moveItemDown(itemIndex)
                return true
            end
        end
    end

    -- Check scrollbar clicks for selected items
    if #self.selectedItems > self.visibleSelectedItems then
        local scrollbarWidth = self.scrollbarWidth
        local scrollbarX = self.x + self.width - scrollbarWidth - 2
        local scrollbarHeight = selectedSectionHeight - 30  -- Account for header
        local scrollbarY = selectedSectionY + 25

        if x >= scrollbarX and x <= scrollbarX + scrollbarWidth and y >= scrollbarY and y <= scrollbarY + scrollbarHeight then
            -- Calculate scroll position based on click
            local clickRatio = (y - scrollbarY) / scrollbarHeight
            local totalItems = #self.selectedItems
            local visibleItems = self.visibleSelectedItems
            self.selectedScrollOffset = math.floor(clickRatio * (totalItems - visibleItems))
            self.selectedScrollOffset = math.max(0, math.min(self.selectedScrollOffset, totalItems - visibleItems))
            self.isDraggingSelectedScrollbar = true
            return true
        end
    end

    return false
end

function MultiSelectListBox:mousemoved(x, y, dx, dy, istouch)
    if not self.enabled or not self.visible then return false end

    self.hoveredIndex = nil
    self.hoveredSelectedIndex = nil
    self.hoveredButton = nil

    -- Check hover for available items
    local availableSectionHeight = math.floor(self.height * 0.6)
    local availableY = self.y + 25  -- Account for title area (same as mousepressed)
    if x >= self.x and x <= self.x + self.width and
       y >= availableY and y <= self.y + availableSectionHeight then  -- Use available section height

        local relativeY = y - availableY
        local itemIndex = math.floor(relativeY / self.itemHeight) + self.scrollOffset + 1

        if itemIndex >= 1 and itemIndex <= #self.availableItems then
            self.hoveredIndex = itemIndex
        end
    end

    -- Check hover for selected items
    local selectedSectionY = self.y + availableSectionHeight
    local selectedY = selectedSectionY + 25
    if x >= self.x and x <= self.x + self.width and
       y >= selectedY and y <= self.y + self.height then

        local relativeY = y - selectedY
        local itemIndex = math.floor(relativeY / self.itemHeight) + self.selectedScrollOffset + 1

        if itemIndex >= 1 and itemIndex <= #self.selectedItems then
            self.hoveredSelectedIndex = itemIndex
        end
    end

    -- Handle scrollbar dragging for available items
    if self.isDraggingScrollbar then
        local scrollbarWidth = self.scrollbarWidth
        local scrollbarX = self.x + self.width - scrollbarWidth - 2
        local scrollbarHeight = availableSectionHeight - 30  -- Account for header
        local scrollbarY = self.y + 25

        if x >= scrollbarX and x <= scrollbarX + scrollbarWidth and y >= scrollbarY and y <= scrollbarY + scrollbarHeight then
            -- Calculate scroll position based on drag position
            local dragRatio = (y - scrollbarY) / scrollbarHeight
            local totalItems = #self.availableItems
            local visibleItems = self.visibleItems
            self.scrollOffset = math.floor(dragRatio * (totalItems - visibleItems))
            self.scrollOffset = math.max(0, math.min(self.scrollOffset, totalItems - visibleItems))
        end
    end

    -- Handle scrollbar dragging for selected items
    if self.isDraggingSelectedScrollbar then
        local selectedSectionHeight = self.height - availableSectionHeight
        local scrollbarWidth = self.scrollbarWidth
        local scrollbarX = self.x + self.width - scrollbarWidth - 2
        local scrollbarHeight = selectedSectionHeight - 30  -- Account for header
        local scrollbarY = selectedSectionY + 25

        if x >= scrollbarX and x <= scrollbarX + scrollbarWidth and y >= scrollbarY and y <= scrollbarY + scrollbarHeight then
            -- Calculate scroll position based on drag position
            local dragRatio = (y - scrollbarY) / scrollbarHeight
            local totalItems = #self.selectedItems
            local visibleItems = self.visibleSelectedItems
            self.selectedScrollOffset = math.floor(dragRatio * (totalItems - visibleItems))
            self.selectedScrollOffset = math.max(0, math.min(self.selectedScrollOffset, totalItems - visibleItems))
        end
    end

    return self.hoveredIndex or self.hoveredSelectedIndex
end

function MultiSelectListBox:toggleSelection(index)
    local item = self.availableItems[index]
    local isSelected = false

    -- Check if already selected
    for i, selectedItem in ipairs(self.selectedItems) do
        if selectedItem.id == item.id then
            isSelected = true
            break
        end
    end

    if not isSelected then
        -- Add to selected items
        table.insert(self.selectedItems, item)
    else
        -- Remove from selected items
        for i = #self.selectedItems, 1, -1 do
            if self.selectedItems[i].id == item.id then
                table.remove(self.selectedItems, i)
                break
            end
        end
    end

    if self.onSelectionChanged then
        self.onSelectionChanged(self.selectedItems)
    end
end

function MultiSelectListBox:moveItemUp(index)
    if index > 1 then
        local temp = self.selectedItems[index]
        self.selectedItems[index] = self.selectedItems[index - 1]
        self.selectedItems[index - 1] = temp

        if self.onSelectionChanged then
            self.onSelectionChanged(self.selectedItems)
        end
    end
end

function MultiSelectListBox:moveItemDown(index)
    if index < #self.selectedItems then
        local temp = self.selectedItems[index]
        self.selectedItems[index] = self.selectedItems[index + 1]
        self.selectedItems[index + 1] = temp

        if self.onSelectionChanged then
            self.onSelectionChanged(self.selectedItems)
        end
    end
end

function MultiSelectListBox:removeItem(index)
    table.remove(self.selectedItems, index)

    if self.onSelectionChanged then
        self.onSelectionChanged(self.selectedItems)
    end
end

function MultiSelectListBox:draw()
    if not self.visible then return end

    love.graphics.setFont(self.font)

    -- Draw background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw available items section
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(self.availableLabel, self.x + 5, self.y + 5)

    local availableSectionHeight = math.floor(self.height * 0.6)
    local availableY = self.y + 25
    local textAreaWidth = self.width - self.checkboxWidth - 15

    for i = 1, math.min(self.visibleItems, #self.availableItems - self.scrollOffset) do
        local itemIndex = i + self.scrollOffset
        local itemY = availableY + (i - 1) * self.itemHeight
        local item = self.availableItems[itemIndex]

        if item then
            -- Background for hovered items
            if itemIndex == self.hoveredIndex then
                love.graphics.setColor(self.hoverColor)
                love.graphics.rectangle("fill", self.x + 2, itemY + 2, self.width - 4, self.itemHeight - 4)
            end

            -- Checkbox
            love.graphics.setColor(self.checkboxColor)
            love.graphics.rectangle("line", self.x + 5, itemY + 5, self.checkboxWidth - 10, self.checkboxWidth - 10)

            -- Check mark if selected
            local isSelected = false
            for _, selectedItem in ipairs(self.selectedItems) do
                if selectedItem.id == item.id then
                    isSelected = true
                    break
                end
            end

            if isSelected then
                love.graphics.setColor(0, 1, 0, 1)
                love.graphics.line(self.x + 7, itemY + 7, self.x + self.checkboxWidth - 7, itemY + self.checkboxWidth - 7)
                love.graphics.line(self.x + self.checkboxWidth - 7, itemY + 7, self.x + 7, itemY + self.checkboxWidth - 7)
            end

            -- Item text
            love.graphics.setColor(self.textColor)
            local displayText = self:truncateText(item.name or item.id, textAreaWidth)
            love.graphics.print(displayText, self.x + self.checkboxWidth + 5, itemY + 5)
        end
    end

    -- Draw scrollbar for available items
    if #self.availableItems > self.visibleItems then
        local scrollbarWidth = self.scrollbarWidth
        local scrollbarX = self.x + self.width - scrollbarWidth - 2
        local scrollbarHeight = availableSectionHeight - 30  -- Account for header
        local scrollbarY = self.y + 25

        -- Scrollbar track
        love.graphics.setColor(unpack(self.scrollbarTrackColor))
        love.graphics.rectangle("fill", scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight, 4, 4)

        -- Scrollbar thumb
        local visibleItems = self.visibleItems
        local totalItems = #self.availableItems
        local thumbHeight = (visibleItems / totalItems) * scrollbarHeight
        local thumbY = scrollbarY + (self.scrollOffset / (totalItems - visibleItems)) * (scrollbarHeight - thumbHeight)
        love.graphics.setColor(unpack(self.scrollbarThumbColor))
        love.graphics.rectangle("fill", scrollbarX, thumbY, scrollbarWidth, thumbHeight, 4, 4)
    end

    -- Draw selected items section
    local selectedSectionY = self.y + availableSectionHeight
    local selectedSectionHeight = self.height - availableSectionHeight

    -- Section separator
    love.graphics.setColor(self.borderColor)
    love.graphics.line(self.x, selectedSectionY, self.x + self.width, selectedSectionY)

    -- Selected items label
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(self.selectedLabel, self.x + 5, selectedSectionY + 5)

    local selectedY = selectedSectionY + 25
    local selectedTextAreaWidth = self.width - self.buttonWidth * 2 - 15  -- Space for up/down buttons

    for i = 1, math.min(self.visibleSelectedItems, #self.selectedItems - self.selectedScrollOffset) do
        local itemIndex = i + self.selectedScrollOffset
        local itemY = selectedY + (i - 1) * self.itemHeight
        local item = self.selectedItems[itemIndex]

        if item then
            -- Background for hovered selected items
            if itemIndex == self.hoveredSelectedIndex then
                love.graphics.setColor(self.hoverColor)
                love.graphics.rectangle("fill", self.x + 2, itemY + 2, self.width - 4, self.itemHeight - 4)
            end

            -- Item text
            love.graphics.setColor(self.textColor)
            local displayText = self:truncateText(item.name or item.id, selectedTextAreaWidth)
            love.graphics.print(displayText, self.x + 5, itemY + 5)

            -- Up button
            love.graphics.setColor(self.buttonColor)
            love.graphics.rectangle("fill", self.x + self.width - self.buttonWidth * 2 - 5, itemY + 2, self.buttonWidth, self.buttonHeight)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("↑", self.x + self.width - self.buttonWidth * 2 - 5 + 10, itemY + 2)

            -- Down button
            love.graphics.setColor(self.buttonColor)
            love.graphics.rectangle("fill", self.x + self.width - self.buttonWidth - 5, itemY + 2 + self.buttonHeight - self.buttonHeight, self.buttonWidth, self.buttonHeight)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("↓", self.x + self.width - self.buttonWidth - 5 + 10, itemY + 2 + self.buttonHeight - self.buttonHeight)
        end
    end

    -- Draw scrollbar for selected items
    if #self.selectedItems > self.visibleSelectedItems then
        local scrollbarWidth = self.scrollbarWidth
        local scrollbarX = self.x + self.width - scrollbarWidth - 2
        local scrollbarHeight = selectedSectionHeight - 30  -- Account for header
        local scrollbarY = selectedSectionY + 25

        -- Scrollbar track
        love.graphics.setColor(unpack(self.scrollbarTrackColor))
        love.graphics.rectangle("fill", scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight, 4, 4)

        -- Scrollbar thumb
        local visibleItems = self.visibleSelectedItems
        local totalItems = #self.selectedItems
        local thumbHeight = (visibleItems / totalItems) * scrollbarHeight
        local thumbY = scrollbarY + (self.selectedScrollOffset / (totalItems - visibleItems)) * (scrollbarHeight - thumbHeight)
        love.graphics.setColor(unpack(self.scrollbarThumbColor))
        love.graphics.rectangle("fill", scrollbarX, thumbY, scrollbarWidth, thumbHeight, 4, 4)
    end
end

function MultiSelectListBox:truncateText(text, maxWidth)
    local currentFont = love.graphics.getFont()
    local textWidth = currentFont:getWidth(text)

    if textWidth <= maxWidth then
        return text
    end

    -- Simple truncation
    local ellipsis = "..."
    local ellipsisWidth = currentFont:getWidth(ellipsis)
    local availableWidth = maxWidth - ellipsisWidth

    for i = #text, 1, -1 do
        local substring = text:sub(1, i)
        if currentFont:getWidth(substring) <= availableWidth then
            return substring .. ellipsis
        end
    end

    return ellipsis
end

function MultiSelectListBox:setAvailableItems(items)
    self.availableItems = items or {}
    self.scrollOffset = 0
end

function MultiSelectListBox:getSelectedItems()
    return self.selectedItems
end

function MultiSelectListBox:setSelectedItems(items)
    self.selectedItems = items or {}
    if self.onSelectionChanged then
        self.onSelectionChanged(self.selectedItems)
    end
end

function MultiSelectListBox:setPosition(x, y)
    self.x = x
    self.y = y
end

function MultiSelectListBox:mousereleased(x, y, button)
    -- Handle any drag operations if needed
    self.isDraggingScrollbar = false
    self.isDraggingSelectedScrollbar = false
    return false
end

function MultiSelectListBox:wheelmoved(x, y)
    local availableSectionHeight = math.floor(self.height * 0.6)
    local selectedSectionY = self.y + availableSectionHeight

    -- Check if mouse is over available items section
    if x >= self.x and x <= self.x + self.width and y >= self.y + 25 and y <= self.y + availableSectionHeight then
        if #self.availableItems > self.visibleItems then
            self.scrollOffset = self.scrollOffset - y
            self.scrollOffset = math.max(0, math.min(self.scrollOffset, #self.availableItems - self.visibleItems))
        end
    -- Check if mouse is over selected items section
    elseif x >= self.x and x <= self.x + self.width and y >= selectedSectionY + 25 and y <= self.y + self.height then
        if #self.selectedItems > self.visibleSelectedItems then
            self.selectedScrollOffset = self.selectedScrollOffset - y
            self.selectedScrollOffset = math.max(0, math.min(self.selectedScrollOffset, #self.selectedItems - self.visibleSelectedItems))
        end
    end
end

return MultiSelectListBox
