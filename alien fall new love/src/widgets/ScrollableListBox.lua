-- Scrollable List Box widget - Updated for tooltip functionality
--- @class ScrollableListBox
--- @description A scrollable list box widget with tooltip support, item selection,
--- and mouse wheel scrolling. Supports hover effects and scrollbar interaction.
--- @field x number X position of the list box
--- @field y number Y position of the list box
--- @field width number Width of the list box
--- @field height number Height of the list box
--- @field sceneManager SceneManager Reference for global tooltip management
--- @field items table Array of item strings to display
--- @field tooltips table Array of tooltip strings corresponding to items
--- @field selectedIndex number Index of currently selected item
--- @field scrollOffset number Current scroll position in items
--- @field itemHeight number Height of each list item in pixels
--- @field visibleItems number Number of items visible at once
--- @field scrollSpeed number Number of items to scroll per wheel event
--- @field font love.Font Font used for rendering text
--- @field hoveredIndex number|nil Index of currently hovered item
--- @field enabled boolean Whether the widget responds to input
--- @field visible boolean Whether the widget is drawn
--- @field scrollbarDragging boolean Whether the scrollbar is being dragged
--- @field scrollbarDragOffset number Offset for scrollbar dragging
--- @field tooltip Tooltip The tooltip instance for hover information
local Tooltip = require "widgets.Tooltip"
local class = require 'lib.Middleclass'

local ScrollableListBox = class('ScrollableListBox')

--- Creates a new ScrollableListBox instance.
--- @param x number X position
--- @param y number Y position
--- @param width number Width of the list box
--- @param height number Height of the list box
--- @param items table Array of item strings
--- @param tooltips table Array of tooltip strings (optional)
--- @param sceneManager SceneManager Reference for tooltip management
--- @return ScrollableListBox A new ScrollableListBox instance
function ScrollableListBox:initialize(x, y, width, height, items, tooltips, sceneManager)
    -- Position and size
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- Scene manager reference for global tooltip management
    self.sceneManager = sceneManager

    -- Items and tooltips
    self.items = items or {}
    self.tooltips = tooltips or {}
    self.selectedIndex = 1

    -- Scrolling configuration
    self.scrollOffset = 0
    self.itemHeight = 25
    self.visibleItems = math.floor(height / self.itemHeight)
    self.scrollSpeed = 3

    -- Styling
    self.font = love.graphics.newFont(12)  -- Smaller font for list items
    self.textColor = {1, 1, 1, 1}
    self.backgroundColor = {0.1, 0.1, 0.1, 1}
    self.selectedColor = {0.3, 0.5, 0.7, 1}
    self.hoverColor = {0.2, 0.3, 0.4, 1}
    self.borderColor = {0.5, 0.5, 0.5, 1}

    -- State flags
    self.hoveredIndex = nil
    self.enabled = true
    self.visible = true

    -- Scrollbar state
    self.scrollbarDragging = false
    self.scrollbarDragOffset = 0

    -- Tooltip for hover information
    self.tooltip = Tooltip()
end

--- Updates the list box state and tooltip hover timing.
--- @param dt number Delta time since last update
function ScrollableListBox:update(dt)
    if not self.enabled or not self.visible then
        self.tooltip:hide()
        return
    end

    -- Update tooltip timing
    self.tooltip:update(dt)

    -- Get mouse position (use global coordinates that are already converted to internal resolution)
    local mouseX, mouseY = _G.mouseX, _G.mouseY

    -- Check hover state for tooltips
    self.hoveredIndex = nil
    if mouseX >= self.x and mouseX <= self.x + self.width and
       mouseY >= self.y and mouseY <= self.y + self.height then

        local relativeY = mouseY - self.y
        local itemIndex = math.floor(relativeY / self.itemHeight) + self.scrollOffset + 1

        if itemIndex >= 1 and itemIndex <= #self.items then
            self.hoveredIndex = itemIndex

            -- Handle tooltip hover timing
            local tooltipText = self.tooltips[itemIndex]
            if tooltipText and tooltipText ~= "" then
                -- Only start tooltip if we're not already showing a tooltip for this item
                if not self.tooltip.isHovering or self.tooltip.currentItem ~= itemIndex then
                    self.tooltip:setText(tooltipText)
                    -- Position tooltip to the right of the mouse, or left if it would go off screen
                    local tooltipX = mouseX + 15
                    local tooltipY = mouseY - 10

                    -- Keep tooltip on screen (use internal resolution)
                    if tooltipX + self.tooltip.width > 800 then  -- INTERNAL_WIDTH
                        tooltipX = mouseX - self.tooltip.width - 15
                    end
                    if tooltipY + self.tooltip.height > 600 then  -- INTERNAL_HEIGHT
                        tooltipY = 600 - self.tooltip.height - 10
                    end
                    if tooltipY < 10 then
                        tooltipY = 10
                    end

                    self.tooltip:setPosition(tooltipX, tooltipY)
                    self.tooltip:startHover()
                    self.tooltip.currentItem = itemIndex  -- Track which item this tooltip is for
                end
            else
                self.tooltip:stopHover()
                self.tooltip.currentItem = nil
            end
        else
            self.tooltip:stopHover()
            self.tooltip.currentItem = nil
        end
    else
        self.tooltip:stopHover()
        self.tooltip.currentItem = nil
    end
end

--- Handles mouse press events for item selection and scrollbar interaction.
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param button number Mouse button (1 = left)
--- @return boolean True if the event was handled
function ScrollableListBox:mousepressed(x, y, button)
    if not self.enabled or not self.visible or button ~= 1 then return false end

    -- Check scrollbar interaction first
    if #self.items > self.visibleItems then
        local scrollbarWidth = 15
        local scrollbarX = self.x + self.width - scrollbarWidth
        if x >= scrollbarX and x <= scrollbarX + scrollbarWidth and
           y >= self.y and y <= self.y + self.height then

            -- Calculate scrollbar thumb position
            local scrollbarHeight = self.height
            local thumbHeight = (self.visibleItems / #self.items) * scrollbarHeight
            local thumbY = self.y + (self.scrollOffset / (#self.items - self.visibleItems)) * (scrollbarHeight - thumbHeight)

            if y >= thumbY and y <= thumbY + thumbHeight then
                -- Start dragging scrollbar
                self.scrollbarDragging = true
                self.scrollbarDragOffset = y - thumbY
                return true
            else
                -- Click above or below thumb to page up/down
                if y < thumbY then
                    -- Page up
                    self.scrollOffset = math.max(0, self.scrollOffset - self.visibleItems)
                else
                    -- Page down
                    local maxOffset = math.max(0, #self.items - self.visibleItems)
                    self.scrollOffset = math.min(maxOffset, self.scrollOffset + self.visibleItems)
                end
                return true
            end
        end
    end

    -- Check item selection
    if x >= self.x and x <= self.x + self.width and
       y >= self.y and y <= self.y + self.height then

        local relativeY = y - self.y
        local itemIndex = math.floor(relativeY / self.itemHeight) + self.scrollOffset + 1

        if itemIndex >= 1 and itemIndex <= #self.items then
            self.selectedIndex = itemIndex
            return true
        end
    end

    return false
end

--- Handles mouse release events.
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param button number Mouse button
--- @return boolean Always returns false
function ScrollableListBox:mousereleased(x, y, button)
    if button == 1 then
        self.scrollbarDragging = false
    end
    return false
end

--- Handles mouse movement events for scrollbar dragging.
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param dx number Mouse delta x
--- @param dy number Mouse delta y
--- @return boolean True if scrollbar is being dragged
function ScrollableListBox:mousemoved(x, y, dx, dy)
    if self.scrollbarDragging then
        -- Calculate new scroll position based on mouse position
        local scrollbarWidth = 15
        local scrollbarX = self.x + self.width - scrollbarWidth
        local scrollbarHeight = self.height
        local thumbHeight = (self.visibleItems / #self.items) * scrollbarHeight

        -- Calculate the relative position within the scrollbar track
        local relativeY = y - self.y - self.scrollbarDragOffset
        local trackHeight = scrollbarHeight - thumbHeight
        local scrollRatio = relativeY / trackHeight

        -- Clamp ratio between 0 and 1
        scrollRatio = math.max(0, math.min(1, scrollRatio))

        -- Calculate new scroll offset
        local maxOffset = math.max(0, #self.items - self.visibleItems)
        self.scrollOffset = math.floor(scrollRatio * maxOffset + 0.5) -- Round to nearest integer

        return true
    end
    return false
end

--- Handles mouse wheel events for scrolling.
--- @param x number Mouse wheel x delta (unused)
--- @param y number Mouse wheel y delta (positive = scroll up, negative = scroll down)
function ScrollableListBox:wheelmoved(x, y)
    if not self.enabled or not self.visible then return end

    -- Check if mouse is over the widget (use global coordinates)
    local mouseX, mouseY = _G.mouseX, _G.mouseY
    if mouseX < self.x or mouseX > self.x + self.width or
       mouseY < self.y or mouseY > self.y + self.height then
        return
    end

    -- Scroll up or down based on wheel movement
    if y > 0 then
        self.scrollOffset = math.max(0, self.scrollOffset - self.scrollSpeed)
    elseif y < 0 then
        local maxOffset = math.max(0, #self.items - self.visibleItems)
        self.scrollOffset = math.min(maxOffset, self.scrollOffset + self.scrollSpeed)
    end
end

--- Draws the list box with items, scrollbar, and selection highlighting.
function ScrollableListBox:draw()
    if not self.visible then return end

    love.graphics.setFont(self.font)

    -- Draw background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Calculate text area width (accounting for scrollbar and padding)
    local scrollbarWidth = #self.items > self.visibleItems and 15 or 0
    local textAreaWidth = self.width - scrollbarWidth - 10  -- 5px padding on each side

    -- Draw visible items
    for i = 1, math.min(self.visibleItems, #self.items - self.scrollOffset) do
        local itemIndex = i + self.scrollOffset
        local itemY = self.y + (i - 1) * self.itemHeight
        local item = self.items[itemIndex]

        if item then
            -- Background for selected/hovered items
            if itemIndex == self.selectedIndex then
                love.graphics.setColor(self.selectedColor)
                love.graphics.rectangle("fill", self.x + 2, itemY + 2, self.width - 4, self.itemHeight - 4)
            elseif itemIndex == self.hoveredIndex then
                love.graphics.setColor(self.hoverColor)
                love.graphics.rectangle("fill", self.x + 2, itemY + 2, self.width - 4, self.itemHeight - 4)
            end

            -- Draw text (cropped if necessary)
            love.graphics.setColor(self.textColor)
            local displayText = self:truncateText(item, textAreaWidth)
            love.graphics.print(displayText, self.x + 5, itemY + 5)
        end
    end

    -- Draw scrollbar if needed
    if #self.items > self.visibleItems then
        self:drawScrollbar()
    end

    -- Don't draw tooltip here - it will be drawn by the scene manager on top
    -- self.tooltip:draw()
end

--- Truncates text with ellipsis if it exceeds the maximum width.
--- @param text string The text to truncate
--- @param maxWidth number Maximum width in pixels
--- @return string The truncated text with ellipsis if needed
function ScrollableListBox:truncateText(text, maxWidth)
    local currentFont = love.graphics.getFont()
    local textWidth = currentFont:getWidth(text)

    if textWidth <= maxWidth then
        return text
    end

    -- Binary search to find the maximum number of characters that fit
    local low = 1
    local high = #text
    local bestFit = ""

    while low <= high do
        local mid = math.floor((low + high) / 2)
        local substring = text:sub(1, mid) .. "..."
        local width = currentFont:getWidth(substring)

        if width <= maxWidth then
            bestFit = substring
            low = mid + 1
        else
            high = mid - 1
        end
    end

    return bestFit
end

--- Draws the scrollbar with background and thumb.
function ScrollableListBox:drawScrollbar()
    local scrollbarWidth = 15
    local scrollbarX = self.x + self.width - scrollbarWidth
    local scrollbarHeight = self.height
    local thumbHeight = (self.visibleItems / #self.items) * scrollbarHeight
    local thumbY = self.y + (self.scrollOffset / (#self.items - self.visibleItems)) * (scrollbarHeight - thumbHeight)

    -- Scrollbar background
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", scrollbarX, self.y, scrollbarWidth, scrollbarHeight)

    -- Scrollbar thumb
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("fill", scrollbarX + 2, thumbY + 2, scrollbarWidth - 4, thumbHeight - 4)
end

--- Sets the list of items to display.
--- @param items table Array of item strings
function ScrollableListBox:setItems(items)
    self.items = items or {}
    self.selectedIndex = math.min(self.selectedIndex, #self.items)
    self.scrollOffset = 0
end

--- Gets the currently selected item index and value.
--- @return number, string The selected index and the selected item string
function ScrollableListBox:getSelected()
    return self.selectedIndex, self.items[self.selectedIndex]
end

return ScrollableListBox
