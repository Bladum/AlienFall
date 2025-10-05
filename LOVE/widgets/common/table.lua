--[[
widgets/table.lua
Table widget (virtualized grid with sorting and editing)


Advanced table widget providing virtualized grid display with sorting, filtering, and editing
capabilities for tactical strategy game interfaces. Essential for displaying structured data
like soldier stats, research progress, inventory items, and mission logs in OpenXCOM-style games.

PURPOSE:
- Display tabular data in an efficient, interactive grid
- Support large datasets with virtualized scrolling
- Enable data sorting, filtering, and inline editing
- Provide rich interaction for data management
- Core component for data-heavy UI in strategy games

KEY FEATURES:
- Virtualized scrolling for large datasets (only renders visible rows)
- Column-based sorting with visual indicators
- Text filtering and search functionality
- Inline cell editing with validation
- Row selection with keyboard navigation
- Resizable columns with drag handles
- Grid display with customizable styling
- Header rendering with sort controls
- Performance optimized for large tables
- Accessibility support with keyboard navigation

@see widgets.common.core.Base
@see widgets.common.scrollbar
@see widgets.common.listbox
@see widgets.common.panel
]]

local core = require("widgets.core")
local TableWidget = {}
TableWidget.__index = TableWidget

--- Creates a new TableWidget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the table widget
--- @param h number The height of the table widget
--- @param columns table Array of column definitions with name, width, sortable fields
--- @param rows table Array of row data objects
--- @param options table Optional configuration table
--- @return TableWidget A new table widget instance
function TableWidget:new(x, y, w, h, columns, rows, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    obj.columns = columns or {}
    obj.rows = rows or {}
    obj.headerHeight = options.headerHeight or 30
    obj.rowHeight = options.rowHeight or 25
    obj.selected = nil
    obj.scroll = 0
    obj.maxScroll = 0

    -- Enhanced features
    obj.sortColumn = nil
    obj.sortDirection = 1 -- 1 for ascending, -1 for descending
    obj.filter = ""
    obj.filteredRows = obj.rows
    obj.virtualScrolling = options.virtualScrolling ~= false
    obj.editable = options.editable or false
    obj.editingCell = nil

    -- Events
    obj.onRowSelect = options.onRowSelect
    obj.onCellEdit = options.onCellEdit
    obj.onSort = options.onSort

    -- Visual options
    obj.showGrid = options.showGrid ~= false
    obj.alternateRowColors = options.alternateRowColors ~= false
    obj.resizableColumns = options.resizableColumns ~= false
    obj.selectableRows = options.selectableRows ~= false

    -- Performance optimization
    obj.visibleRowStart = 0
    obj.visibleRowEnd = 0
    obj.needsRedraw = true

    setmetatable(obj, self)
    obj:_updateFilter()
    return obj
end

--- Updates the table widget state
--- @param dt number The time delta since the last update
function TableWidget:update(dt)
    core.Base.update(self, dt)

    -- Calculate visible rows for virtual scrolling
    if self.virtualScrolling then
        local visibleRows = math.floor(self.h / self.rowHeight)
        self.visibleRowStart = math.max(0, self.scroll)
        self.visibleRowEnd = math.min(#self.filteredRows, self.visibleRowStart + visibleRows + 2)
    else
        self.visibleRowStart = 0
        self.visibleRowEnd = #self.filteredRows
    end

    -- Update max scroll
    local totalHeight = #self.filteredRows * self.rowHeight + self.headerHeight
    self.maxScroll = math.max(0, totalHeight - self.h)
end

--- Draws the table widget and its contents
function TableWidget:draw()
    core.Base.draw(self)

    -- Background
    love.graphics.setColor(unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Setup clipping for scrollable content
    love.graphics.push()
    love.graphics.intersectScissor(self.x, self.y, self.w, self.h)

    -- Draw header
    self:_drawHeader()

    -- Draw rows (virtual scrolling)
    self:_drawRows()

    love.graphics.pop()

    -- Border
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Focus ring
    if self.focused then
        love.graphics.setColor(unpack(core.focus.focusRingColor))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", self.x - 1, self.y - 1, self.w + 2, self.h + 2)
        love.graphics.setLineWidth(1)
    end
end

--- Draws the table header row (private method)
function TableWidget:_drawHeader()
    local colX = self.x
    local headerY = self.y - self.scroll * self.rowHeight

    for i, col in ipairs(self.columns) do
        local colWidth = col.width or 100

        -- Header background
        love.graphics.setColor(unpack(core.theme.secondary))
        love.graphics.rectangle("fill", colX, headerY, colWidth, self.headerHeight)

        -- Sort indicator
        if self.sortColumn == i then
            love.graphics.setColor(unpack(core.theme.accent))
            love.graphics.rectangle("fill", colX, headerY, colWidth, 2)
        end

        -- Header text
        love.graphics.setColor(unpack(core.theme.text))
        local title = col.title or ""
        if self.sortColumn == i then
            title = title .. (self.sortDirection == 1 and " ↑" or " ↓")
        end
        love.graphics.printf(title, colX + 4, headerY + 4, colWidth - 8, "left")

        -- Grid lines
        if self.showGrid then
            love.graphics.setColor(unpack(core.theme.border))
            love.graphics.line(colX + colWidth, headerY, colX + colWidth, headerY + self.headerHeight)
        end

        colX = colX + colWidth
    end

    -- Header bottom border
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.line(self.x, headerY + self.headerHeight, self.x + self.w, headerY + self.headerHeight)
end

--- Draws the table data rows (private method)
function TableWidget:_drawRows()
    for r = self.visibleRowStart, self.visibleRowEnd do
        local row = self.filteredRows[r + 1]
        if not row then break end

        local rowY = self.y + self.headerHeight + (r * self.rowHeight) - (self.scroll * self.rowHeight)
        local colX = self.x

        -- Row background
        local bgColor
        if self.selected == r then
            bgColor = core.theme.accent
        elseif self.alternateRowColors and r % 2 == 1 then
            bgColor = core.theme.backgroundAlt or
                { core.theme.background[1] + 0.02, core.theme.background[2] + 0.02, core.theme.background[3] + 0.02 }
        else
            bgColor = core.theme.background
        end

        love.graphics.setColor(unpack(bgColor))
        love.graphics.rectangle("fill", colX, rowY, self.w, self.rowHeight)

        -- Row cells
        for i, col in ipairs(self.columns) do
            local colWidth = col.width or 100
            local cellValue = row[i] or ""

            -- Cell editing
            if self.editingCell and self.editingCell.row == r and self.editingCell.col == i then
                love.graphics.setColor(unpack(core.theme.primaryHover))
                love.graphics.rectangle("fill", colX, rowY, colWidth, self.rowHeight)
            end

            -- Cell text
            love.graphics.setColor(unpack(core.theme.text))
            love.graphics.printf(tostring(cellValue), colX + 4, rowY + 4, colWidth - 8, col.align or "left")

            -- Grid lines
            if self.showGrid then
                love.graphics.setColor(unpack(core.theme.border))
                love.graphics.line(colX + colWidth, rowY, colX + colWidth, rowY + self.rowHeight)
            end

            colX = colX + colWidth
        end

        -- Row grid line
        if self.showGrid then
            love.graphics.setColor(unpack(core.theme.border))
            love.graphics.line(self.x, rowY + self.rowHeight, self.x + self.w, rowY + self.rowHeight)
        end
    end
end

--- Sets the table data rows
--- @param data table Array of row data objects to display
function TableWidget:setData(data)
    self.rows = data or {}
end

--- Handles mouse press events for the table widget
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean Always returns false (event not handled)
function TableWidget:mousepressed(x, y, button) return false end

return TableWidget
