local BaseState = require "screens.base_state"
local Button = require "widgets.Button"
local Checkbox = require "widgets.Checkbox"
local Combobox = require "widgets.ComboBox"
local Table = require "widgets.Table"

local TestState = {}
TestState.__index = TestState
setmetatable(TestState, { __index = BaseState })

local GRID_SIZE = 20
local GRID_COLS = 40
local GRID_ROWS = 30

function TestState.new(registry)
    local self = BaseState.new({
        name = "test",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, TestState)

    self.titleFont = love.graphics.newFont(24)
    self.labelFont = love.graphics.newFont(14)  -- Smaller font for widgets

    -- Test widgets
    self.testCheckbox = Checkbox:new({
        id = "test_checkbox",
        label = "Test Checkbox",
        checked = false,
        font = self.labelFont,
        onChange = function(checked)
            print("Checkbox changed to: " .. tostring(checked))
        end,
        width = 12 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    self.testCheckbox:setPosition(4 * GRID_SIZE, 6 * GRID_SIZE)

    self.testCombobox = Combobox:new({
        id = "test_combo",
        label = "Test Combo",
        options = {"Option 1", "Option 2", "Option 3"},
        selectedIndex = 1,
        font = self.labelFont,
        onChange = function(index, value)
            print("Combo selected: " .. value)
        end,
        width = 12 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    self.testCombobox:setPosition(4 * GRID_SIZE, 10 * GRID_SIZE)

    -- Generate large test table data (10x bigger)
    local tableData = {{"Name", "Value", "Status", "Category"}}
    local statuses = {"Active", "Inactive", "Pending", "Error"}
    local categories = {"UI", "Data", "Network", "System", "Debug"}
    
    for i = 1, 80 do
        local status = statuses[(i % #statuses) + 1]
        local category = categories[(i % #categories) + 1]
        table.insert(tableData, {
            "Item " .. i, 
            tostring(i * 10), 
            status,
            category
        })
    end

    -- Test table widget
    self.testTable = Table:new({
        id = "test_table",
        data = tableData,
        x = 19 * GRID_SIZE,  -- Moved 1 tile left (from 20 to 19)
        y = 6 * GRID_SIZE,
        cellWidth = 5 * GRID_SIZE,  -- Default width
        columnWidths = {
            6 * GRID_SIZE,  -- Column 1: Name (wider)
            3 * GRID_SIZE,  -- Column 2: Value (smaller)
            4 * GRID_SIZE,  -- Column 3: Status
            5 * GRID_SIZE   -- Column 4: Category
        },
        cellHeight = 1 * GRID_SIZE,
        visibleRows = 5,
        font = self.labelFont,
        onSort = function(column, ascending)
            print("Table sorted by column " .. column .. " " .. (ascending and "ascending" or "descending"))
        end,
        onCellClick = function(row, col, button)
            print("Cell clicked: row " .. row .. ", col " .. col .. ", button " .. button)
        end
    })

    -- Back button (left side)
    self.backButton = Button:new({
        id = "back",
        label = "Back",
        onClick = function()
            self.stack:pop({ cancelled = true })
        end,
        width = 6 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    self.backButton:setPosition(20, 600 - 20 - 2 * GRID_SIZE)

    return self
end

function TestState:sortTable(column, ascending)
    -- This method is now handled by the Table widget
    self.testTable:sort(column, ascending)
end

function TestState:update(dt)
    self.testCheckbox:update(dt)
    self.testCombobox:update(dt)
    self.testTable:update(dt)
    self.backButton:update(dt)
end

function TestState:draw()
    love.graphics.clear(0.07, 0.07, 0.1, 1)

    -- Draw subtle grid background
    love.graphics.setColor(0.1, 0.1, 0.15, 0.3)
    for x = 0, GRID_COLS - 1 do
        for y = 0, GRID_ROWS - 1 do
            if (x + y) % 2 == 0 then
                love.graphics.rectangle("fill", x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
            end
        end
    end

    -- Title
    love.graphics.setColor(0, 0.6, 0.9, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("UI TEST STATE", 0, 2 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")

    -- Test widgets
    self.testCheckbox:draw(false)
    self.testCombobox:draw(false)

    -- Draw test table
    love.graphics.setColor(0, 0.6, 0.9, 1)
    love.graphics.printf("Test Table:", 0, 4 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")
    self.testTable:draw()

    -- Draw back button
    self.backButton:draw(self.backButton.hovered)

    -- Draw combo box dropdown on top if expanded
    self.testCombobox:drawDropdown()
end

function TestState:mousepressed(x, y, button)
    if button ~= 1 and button ~= 2 then return false end
    
    if self.testCheckbox:mousepressed(x, y, button) then return true end
    if self.testCombobox:mousepressed(x, y, button) then return true end
    if self.testTable:mousepressed(x, y, button) then return true end
    if self.backButton:mousepressed(x, y, button) then return true end
    
    return false
end

function TestState:mousereleased(x, y, button)
    self.testCheckbox:mousereleased(x, y, button)
    self.testCombobox:mousereleased(x, y, button)
    self.testTable:mousereleased(x, y, button)
    self.backButton:mousereleased(x, y, button)
end

function TestState:mousemoved(x, y, dx, dy, istouch)
    self.testCheckbox:mousemoved(x, y)
    self.testCombobox:mousemoved(x, y)
    self.testTable:mousemoved(x, y, dx, dy, istouch)
    self.backButton:mousemoved(x, y)
end

function TestState:wheelmoved(x, y)
    self.testTable:wheelmoved(x, y)
end

return TestState
