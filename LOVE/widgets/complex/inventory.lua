--[[
widgets/inventory.lua
Grid-based inventory widget for item management


Simple grid-based inventory widget for displaying items and handling basic interactions.
Provides a compact UI for item management in strategy games and RPG interfaces.

PURPOSE:
- Provide a compact grid UI for displaying items and handling basic interactions
- Enable click-to-use functionality for inventory items
- Support item movement and organization within the grid
- Facilitate inventory management in tactical strategy games

KEY FEATURES:
- Grid layout with customizable cell size
- Add/remove/clear items functionality
- Click-to-use item interactions
- Callback hooks for item movement and usage
- Visual feedback for item states
- Integration with item system
- Support for different item types and categories
- Grid-based positioning and layout

]]
local core = require("widgets.core")
local Inventory = {}
Inventory.__index = Inventory

function Inventory:new(x, y, cols, rows, options)
    local cellSize = 48
    local onItemMove = nil
    local onItemUse = nil

    if type(options) == "number" then
        cellSize = options
    elseif type(options) == "table" then
        cellSize = options.cellSize or 48
        onItemMove = options.onItemMove
        onItemUse = options.onItemUse
    end

    local obj = {
        x = x,
        y = y,
        cols = cols or 5,
        rows = rows or 4,
        cellSize = cellSize,
        items = {},
        onItemMove = onItemMove,
        onItemUse = onItemUse
    }
    setmetatable(obj, self)
    return obj
end

function Inventory:draw()
    for r = 1, self.rows do
        for c = 1, self.cols do
            local idx = (r - 1) * self.cols + c; local x = self.x + (c - 1) * self.cellSize; local y = self.y +
                (r - 1) * self.cellSize; love.graphics.setColor(unpack(core.theme.secondary)); love.graphics.rectangle(
                "fill", x, y, self.cellSize, self.cellSize); love.graphics.setColor(unpack(core.theme.border)); love
                .graphics.rectangle("line", x, y, self.cellSize, self.cellSize); if self.items[idx] then
                love.graphics.setColor(1, 1, 1); love.graphics.print(self.items[idx].name or "", x + 4, y + 4)
            end
        end
    end
end

function Inventory:mousepressed(x, y, button)
    if button ~= 1 then return false end
    for r = 1, self.rows do
        for c = 1, self.cols do
            local idx = (r - 1) * self.cols + c
            local cellX = self.x + (c - 1) * self.cellSize
            local cellY = self.y + (r - 1) * self.cellSize
            if core.isInside(x, y, cellX, cellY, self.cellSize, self.cellSize) then
                if self.items[idx] and self.onItemUse then
                    self.onItemUse(self.items[idx], r, c)
                end
                return true
            end
        end
    end
    return false
end

function Inventory:update(dt) end

function Inventory:clear()
    self.items = {}
end

function Inventory:addItem(item, row, col)
    if not item then return false end
    local r = tonumber(row) or 1
    local c = tonumber(col) or 1
    if r < 1 or r > self.rows or c < 1 or c > self.cols then return false end
    local idx = (r - 1) * self.cols + c
    self.items[idx] = item
    return true
end

function Inventory:addItemToEmpty(item)
    for r = 1, self.rows do
        for c = 1, self.cols do
            local idx = (r - 1) * self.cols + c; if not self.items[idx] then
                self.items[idx] = item; return true
            end
        end
    end
    return false
end

return Inventory






