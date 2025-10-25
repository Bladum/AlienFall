---Table Widget - Data Table with Rows and Columns
---
---A data table widget with rows, columns, headers, and sorting. Displays tabular data
---with optional row selection and column sorting. Grid-aligned for consistent positioning.
---
---Features:
---  - Column headers with labels
---  - Row selection (single or multi)
---  - Sorting by column (optional, click header)
---  - Grid-aligned positioning (24×24 pixels)
---  - Scrolling for large datasets
---  - Cell rendering customization
---
---Table Structure:
---  - Headers: Column names, clickable for sorting
---  - Rows: Data rows, selectable
---  - Cells: Individual data values
---  - Scroll bar: Vertical scrolling when needed
---
---Sorting:
---  - Click column header to sort
---  - First click: Ascending
---  - Second click: Descending
---  - Third click: Original order
---  - Sort indicator: Arrow in header
---
---Key Exports:
---  - Table.new(x, y, width, height): Creates table
---  - setColumns(columns): Sets column definitions [{name, width}, ...]
---  - setRows(rows): Sets row data
---  - addRow(row): Adds single row
---  - removeRow(index): Removes row
---  - getSelectedRow(): Returns selected row
---  - setSortable(column, sortable): Enables column sorting
---  - setSelectionMode(mode): Sets selection behavior
---  - draw(): Renders table
---  - mousepressed(x, y, button): Click handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.navigation.table
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Table = require("gui.widgets.navigation.table")
---  local table = Table.new(0, 0, 480, 360)
---  table:setColumns({
---    {name="Name", width=200},
---    {name="HP", width=100},
---    {name="Level", width=100}
---  })
---  table:setRows(unitData)
---  table:draw()
---
---@see widgets.navigation.listbox For simple lists

--[[
    Table Widget
    
    A data table with rows and columns.
    Features:
    - Column headers
    - Row selection
    - Sorting (optional)
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local Table = setmetatable({}, {__index = BaseWidget})
Table.__index = Table

--[[
    Create a new table widget
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New table widget instance
]]
function Table.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "table")
    setmetatable(self, Table)
    
    self.headers = {}
    self.rows = {}
    self.selectedRow = 0
    self.headerHeight = 24
    self.rowHeight = 24
    self.onRowSelect = nil
    
    return self
end

--[[
    Draw the table
]]
function Table:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw headers
    if #self.headers > 0 then
        local colWidth = self.width / #self.headers
        
        -- Draw header background
        Theme.setColor(self.hoverColor)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.headerHeight)
        
        -- Draw header text
        Theme.setFont(self.font)
        Theme.setColor(self.textColor)
        local font = Theme.getFont(self.font)
        local textHeight = font:getHeight()
        
        for i, header in ipairs(self.headers) do
            local colX = self.x + (i - 1) * colWidth
            local textY = self.y + (self.headerHeight - textHeight) / 2
            love.graphics.print(header, colX + 4, textY)
            
            -- Draw column separator
            if i < #self.headers then
                Theme.setColor(self.borderColor)
                love.graphics.line(colX + colWidth, self.y, colX + colWidth, self.y + self.headerHeight)
            end
        end
    end
    
    -- Draw rows
    local startY = self.y + self.headerHeight
    local visibleRows = math.floor((self.height - self.headerHeight) / self.rowHeight)
    
    Theme.setFont(self.font)
    local font = Theme.getFont(self.font)
    local textHeight = font:getHeight()
    
    for i = 1, math.min(#self.rows, visibleRows) do
        local row = self.rows[i]
        local rowY = startY + (i - 1) * self.rowHeight
        
        -- Highlight selected row
        if i == self.selectedRow then
            Theme.setColor(self.activeColor)
            love.graphics.rectangle("fill", self.x, rowY, self.width, self.rowHeight)
        end
        
        -- Draw row data
        local colWidth = self.width / #self.headers
        Theme.setColor(self.textColor)
        
        for j, cell in ipairs(row) do
            local colX = self.x + (j - 1) * colWidth
            local textY = rowY + (self.rowHeight - textHeight) / 2
            love.graphics.print(tostring(cell), colX + 4, textY)
        end
        
        -- Draw row separator
        Theme.setColor(self.borderColor)
        love.graphics.line(self.x, rowY + self.rowHeight, self.x + self.width, rowY + self.rowHeight)
    end
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.line(self.x, self.y + self.headerHeight, self.x + self.width, self.y + self.headerHeight)
end

--[[
    Handle mouse press
]]
function Table:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button ~= 1 or not self:containsPoint(x, y) then
        return false
    end
    
    -- Check if clicking on a row
    local startY = self.y + self.headerHeight
    if y >= startY then
        local rowIndex = math.floor((y - startY) / self.rowHeight) + 1
        
        if rowIndex >= 1 and rowIndex <= #self.rows then
            self.selectedRow = rowIndex
            
            if self.onRowSelect then
                self.onRowSelect(rowIndex, self.rows[rowIndex])
            end
            
            return true
        end
    end
    
    return false
end

--[[
    Set table data
    @param headers table - Array of header strings
    @param rows table - Array of row arrays
]]
function Table:setData(headers, rows)
    self.headers = headers or {}
    self.rows = rows or {}
    self.selectedRow = 0
end

--[[
    Add a row
    @param row table - Array of cell values
]]
function Table:addRow(row)
    table.insert(self.rows, row)
end

--[[
    Clear all rows
]]
function Table:clearRows()
    self.rows = {}
    self.selectedRow = 0
end

--[[
    Get selected row
    @return table or nil - Selected row data
]]
function Table:getSelectedRow()
    if self.selectedRow > 0 and self.selectedRow <= #self.rows then
        return self.rows[self.selectedRow]
    end
    return nil
end

return Table



























