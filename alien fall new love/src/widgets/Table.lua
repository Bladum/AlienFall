--- A sortable, scrollable table widget with row selection and column sorting.
--- @class Table
--- @description A comprehensive table widget supporting sorting, scrolling, and row selection.
--- Features include customizable column widths, visual row selection, scrollbar interaction,
--- and callback support for user interactions.
--- @field id string Unique identifier for the table
--- @field data table 2D array of table data: {{col1, col2, col3}, ...}
--- @field x number X position of the table
--- @field y number Y position of the table
--- @field cellWidth number Default width for all columns in pixels
--- @field columnWidths table Individual column widths override: {col1_width, col2_width, ...}
--- @field cellHeight number Height of each cell in pixels
--- @field visibleRows number Number of rows visible at once
--- @field font love.Font Font used for rendering table text
--- @field onSort function Callback for column sorting: function(column, ascending)
--- @field onCellClick function Callback for cell clicks: function(row, col, button)
--- @field onRowSelect function Callback for row selection: function(row)
--- @field cols number Number of columns in the table
--- @field rows number Number of rows in the table
--- @field scrollOffset number Current scroll position (row offset)
--- @field sortColumn number Currently sorted column index
--- @field sortAscending boolean Whether sorting is ascending
--- @field isDraggingScrollbar boolean Whether the scrollbar is being dragged
--- @field selectedRow number|nil Index of currently selected row
--- @field colors table Color configuration for table appearance

local class = require("lib.middleclass")

local Table = class('Table')

--- Creates a new Table instance.
--- @param options table Configuration options for the table
--- @field id string Unique identifier (defaults to "table")
--- @field data table 2D array of data with header row first
--- @field x number X position (defaults to 0)
--- @field y number Y position (defaults to 0)
--- @field cellWidth number Default column width (defaults to 120)
--- @field columnWidths table Per-column width overrides
--- @field cellHeight number Row height (defaults to 20)
--- @field visibleRows number Visible rows (defaults to 10)
--- @field font love.Font Font for text rendering
--- @field sortColumn number Initial sort column (defaults to 1)
--- @field sortAscending boolean Initial sort direction (defaults to true)
--- @field onSort function Sort callback: function(column, ascending)
--- @field onCellClick function Cell click callback: function(row, col, button)
--- @field onRowSelect function Row selection callback: function(row)
--- @return Table A new Table instance
--- @usage local table = Table:new({
---     data = {{"Name", "Age", "City"}, {"John", "25", "NYC"}, {"Jane", "30", "LA"}},
---     columnWidths = {100, 50, 80},
---     visibleRows = 5,
---     onRowSelect = function(row) print("Selected row:", row) end
--- })
function Table:initialize(options)
    options = options or {}

    -- Required options
    self.id = options.id or "table"
    self.data = options.data or {}  -- 2D array: {{col1, col2, col3}, ...}
    self.x = options.x or 0
    self.y = options.y or 0
    self.cellWidth = options.cellWidth or 120  -- Default width for all columns
    self.columnWidths = options.columnWidths or {}  -- Individual column widths
    self.cellHeight = options.cellHeight or 20
    self.visibleRows = options.visibleRows or 10
    self.font = options.font or love.graphics.newFont(14)

    -- Optional callbacks
    self.onSort = options.onSort  -- function(column, ascending)
    self.onCellClick = options.onCellClick  -- function(row, col, button)
    self.onRowSelect = options.onRowSelect  -- function(row)

    -- Internal state
    self.cols = #self.data[1] or 0
    self.rows = #self.data
    self.scrollOffset = 0
    self.sortColumn = options.sortColumn or 1
    self.sortAscending = options.sortAscending ~= false  -- default true
    self.isDraggingScrollbar = false  -- For scrollbar dragging
    self.selectedRow = nil  -- Selected row index

    -- Colors with professional dark theme
    self.colors = {
        background = {0.12, 0.18, 0.32, 0.8},
        header = {0.2, 0.3, 0.5, 1},
        rowEven = {0.08, 0.12, 0.2, 1},  -- Darker
        rowOdd = {0.06, 0.09, 0.15, 1},  -- Darker
        rowSelected = {0.15, 0.22, 0.18, 0.6},  -- Subtle green-tinted selection
        border = {0.05, 0.08, 0.1, 1},
        text = {1, 1, 1, 1},
        sortArrow = {1, 1, 0, 1},
        scrollbarTrack = {0.1, 0.1, 0.15, 1},
        scrollbarThumb = {0.3, 0.4, 0.6, 1}
    }
end

--- Gets the width of a specific column.
--- @param col number Column index
--- @return number Width of the column in pixels
function Table:getColumnWidth(col)
    return self.columnWidths[col] or self.cellWidth
end

--- Gets the total width of all columns combined.
--- @return number Total width of the table
function Table:getTotalWidth()
    local total = 0
    for col = 1, self.cols do
        total = total + self:getColumnWidth(col)
    end
    return total
end

--- Gets the currently selected row index.
--- @return number|nil Index of selected row or nil if none selected
function Table:getSelectedRow()
    return self.selectedRow
end

--- Clears the current row selection.
function Table:clearSelection()
    self.selectedRow = nil
end

--- Sets the selected row and triggers callback if provided.
--- @param row number Row index to select
function Table:setSelectedRow(row)
    self.selectedRow = row
    if self.onRowSelect then
        self.onRowSelect(row)
    end
end

--- Sorts the table data by the specified column.
--- @param column number Column index to sort by
--- @param ascending boolean Whether to sort in ascending order
function Table:sort(column, ascending)
    self.sortColumn = column
    self.sortAscending = ascending

    if not self.data or #self.data < 2 then return end

    -- Don't sort the header row - extract it first
    local header = table.remove(self.data, 1)

    -- Sort data rows by the specified column
    table.sort(self.data, function(a, b)
        local valA = a[column]
        local valB = b[column]

        -- Try numeric comparison first
        local numA = tonumber(valA)
        local numB = tonumber(valB)

        if numA and numB then
            if ascending then
                return numA < numB
            else
                return numA > numB
            end
        else
            -- String comparison as fallback
            if ascending then
                return valA < valB
            else
                return valA > valB
            end
        end
    end)

    -- Put header row back at the top
    table.insert(self.data, 1, header)

    -- Trigger sort callback if provided
    if self.onSort then
        self.onSort(column, ascending)
    end
end

--- Updates the table state (currently no animations needed).
--- @param dt number Delta time since last update
function Table:update(dt)
    -- No animation updates needed for basic table
end

--- Draws the table with header, data rows, and scrollbar.
function Table:draw()
    if not self.data or #self.data == 0 then return end

    local tableWidth = self:getTotalWidth()
    local tableHeight = (self.visibleRows + 1) * self.cellHeight  -- +1 for header

    -- Table background with rounded corners
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", self.x, self.y, tableWidth, tableHeight, 4, 4)
    love.graphics.setColor(unpack(self.colors.border))
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, tableWidth, tableHeight, 4, 4)

    -- Set font for text rendering
    love.graphics.setFont(self.font)
    local fontHeight = self.font:getHeight()

    -- Draw header row (always row 0, data[1])
    local headerY = self.y
    love.graphics.setColor(unpack(self.colors.header))
    love.graphics.rectangle("fill", self.x, headerY, tableWidth, self.cellHeight)

    local currentX = self.x
    for col = 1, self.cols do
        local colWidth = self:getColumnWidth(col)
        local cellData = self.data[1] and self.data[1][col] or ""

        love.graphics.setColor(unpack(self.colors.border))
        love.graphics.rectangle("line", currentX, headerY, colWidth, self.cellHeight)

        love.graphics.setColor(unpack(self.colors.text))
        love.graphics.printf(cellData, currentX + 4, headerY + (self.cellHeight - fontHeight) / 2, colWidth - 8, "left")

        -- Draw sort indicator arrow on header
        if col == self.sortColumn then
            love.graphics.setColor(unpack(self.colors.sortArrow))
            local arrowX = currentX + colWidth - 12
            local arrowY = headerY + self.cellHeight / 2
            if self.sortAscending then
                love.graphics.polygon("fill", arrowX, arrowY - 4, arrowX + 8, arrowY - 4, arrowX + 4, arrowY + 4)
            else
                love.graphics.polygon("fill", arrowX, arrowY + 4, arrowX + 8, arrowY + 4, arrowX + 4, arrowY - 4)
            end
        end

        currentX = currentX + colWidth
    end

    -- Draw data rows with alternating colors and selection highlight
    for row = 1, self.visibleRows do
        local dataRow = row + self.scrollOffset
        if dataRow >= self.rows then break end

        local rowY = self.y + row * self.cellHeight

        -- Data row background colors
        if dataRow == self.selectedRow then
            love.graphics.setColor(unpack(self.colors.rowSelected))
        elseif row % 2 == 1 then
            love.graphics.setColor(unpack(self.colors.rowEven))
        else
            love.graphics.setColor(unpack(self.colors.rowOdd))
        end
        love.graphics.rectangle("fill", self.x, rowY, tableWidth, self.cellHeight)

        -- Draw individual cells
        currentX = self.x
        for col = 1, self.cols do
            local colWidth = self:getColumnWidth(col)
            local cellData = self.data[dataRow + 1] and self.data[dataRow + 1][col] or ""

            love.graphics.setColor(unpack(self.colors.border))
            love.graphics.rectangle("line", currentX, rowY, colWidth, self.cellHeight)

            love.graphics.setColor(unpack(self.colors.text))
            love.graphics.printf(cellData, currentX + 4, rowY + (self.cellHeight - fontHeight) / 2, colWidth - 8, "left")

            currentX = currentX + colWidth
        end
    end

    -- Draw scrollbar if content exceeds visible area
    if self.rows > self.visibleRows + 1 then  -- +1 for header
        local scrollbarWidth = 16
        local scrollbarX = self.x + tableWidth + 4
        local scrollbarHeight = tableHeight
        local scrollbarY = self.y

        -- Scrollbar track background
        love.graphics.setColor(unpack(self.colors.scrollbarTrack))
        love.graphics.rectangle("fill", scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight, 4, 4)

        -- Scrollbar thumb indicating current scroll position
        local visibleDataRows = self.visibleRows
        local totalDataRows = self.rows - 1  -- Subtract header
        local thumbHeight = (visibleDataRows / totalDataRows) * scrollbarHeight
        local thumbY = scrollbarY + (self.scrollOffset / (totalDataRows - visibleDataRows)) * (scrollbarHeight - thumbHeight)
        love.graphics.setColor(unpack(self.colors.scrollbarThumb))
        love.graphics.rectangle("fill", scrollbarX, thumbY, scrollbarWidth, thumbHeight, 4, 4)
    end
end

--- Handles mouse press events for sorting, selection, and scrolling.
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param button number Mouse button (1 = left, 2 = right)
--- @return boolean True if the event was handled
function Table:mousepressed(x, y, button)
    if button ~= 1 and button ~= 2 then return false end

    -- Check if click is within table area
    local tableWidth = self:getTotalWidth()
    local tableHeight = (self.visibleRows + 1) * self.cellHeight

    if x >= self.x and x <= self.x + tableWidth and y >= self.y and y <= self.y + tableHeight then
        -- Check header clicks for sorting
        if y >= self.y and y <= self.y + self.cellHeight then
            -- Find which column was clicked
            local currentX = self.x
            for col = 1, self.cols do
                local colWidth = self:getColumnWidth(col)
                if x >= currentX and x <= currentX + colWidth then
                    if button == 1 then
                        self:sort(col, true)  -- LMB: ascending
                    elseif button == 2 then
                        self:sort(col, false)  -- RMB: descending
                    end
                    return true
                end
                currentX = currentX + colWidth
            end
        else
            -- Data row clicks for selection
            local row = math.floor((y - self.y) / self.cellHeight)
            local dataRow = row + self.scrollOffset

            if dataRow >= 1 and dataRow <= self.rows then
                -- Row selection (light rectangle highlight)
                self.selectedRow = dataRow

                -- Call row select callback if provided
                if self.onRowSelect then
                    self.onRowSelect(dataRow)
                end

                -- Check for cell-specific clicks
                local currentX = self.x
                local cellClicked = false
                for col = 1, self.cols do
                    local colWidth = self:getColumnWidth(col)
                    if x >= currentX and x <= currentX + colWidth then
                        if self.onCellClick then
                            self.onCellClick(dataRow, col, button)
                        end
                        cellClicked = true
                        break
                    end
                    currentX = currentX + colWidth
                end

                return true
            end
        end
    end

    -- Check scrollbar clicks for scrolling
    if self.rows > self.visibleRows + 1 then  -- +1 for header
        local scrollbarWidth = 16
        local scrollbarX = self.x + tableWidth + 4
        local scrollbarHeight = tableHeight
        local scrollbarY = self.y

        if x >= scrollbarX and x <= scrollbarX + scrollbarWidth and y >= scrollbarY and y <= scrollbarY + scrollbarHeight then
            -- Calculate scroll position based on click
            local clickRatio = (y - scrollbarY) / scrollbarHeight
            local totalDataRows = self.rows - 1  -- Subtract header
            local visibleDataRows = self.visibleRows
            self.scrollOffset = math.floor(clickRatio * (totalDataRows - visibleDataRows))
            self.scrollOffset = math.max(0, math.min(self.scrollOffset, totalDataRows - visibleDataRows))
            self.isDraggingScrollbar = true
            return true
        end
    end

    return false
end

--- Handles mouse release events.
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param button number Mouse button
function Table:mousereleased(x, y, button)
    self.isDraggingScrollbar = false
end

--- Handles mouse movement events for scrollbar dragging.
--- @param x number Mouse x coordinate
--- @param y number Mouse y coordinate
--- @param dx number Mouse delta x
--- @param dy number Mouse delta y
--- @param istouch boolean Whether this is a touch event
function Table:mousemoved(x, y, dx, dy, istouch)
    if self.isDraggingScrollbar then
        -- Handle scrollbar dragging
        local tableWidth = self:getTotalWidth()
        local tableHeight = (self.visibleRows + 1) * self.cellHeight
        local scrollbarWidth = 16
        local scrollbarX = self.x + tableWidth + 4
        local scrollbarHeight = tableHeight
        local scrollbarY = self.y

        if x >= scrollbarX and x <= scrollbarX + scrollbarWidth and y >= scrollbarY and y <= scrollbarY + scrollbarHeight then
            -- Calculate scroll position based on drag position
            local dragRatio = (y - scrollbarY) / scrollbarHeight
            local totalDataRows = self.rows - 1  -- Subtract header
            local visibleDataRows = self.visibleRows
            self.scrollOffset = math.floor(dragRatio * (totalDataRows - visibleDataRows))
            self.scrollOffset = math.max(0, math.min(self.scrollOffset, totalDataRows - visibleDataRows))
        end
    end
end

--- Handles mouse wheel events for scrolling.
--- @param x number Mouse wheel x delta (unused)
--- @param y number Mouse wheel y delta (positive = scroll up, negative = scroll down)
function Table:wheelmoved(x, y)
    if self.rows > self.visibleRows then
        self.scrollOffset = self.scrollOffset - y
        self.scrollOffset = math.max(0, math.min(self.scrollOffset, self.rows - self.visibleRows))
    end
end

return Table
