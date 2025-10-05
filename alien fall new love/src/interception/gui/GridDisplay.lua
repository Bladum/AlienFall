--- GridDisplay class for rendering interception grid in interception gameplay.
-- @classmod interception.gui.GridDisplay
-- @field size number Grid size (width and height)
-- @field cellSize number Size of each grid cell in pixels
-- @field status table 2D array of cell statuses

local GridDisplay = {}
GridDisplay.__index = GridDisplay

--- Creates a new GridDisplay instance.
-- @param opts table Configuration options
-- @param opts.size number Grid size (default: 3)
-- @param opts.cellSize number Cell size in pixels (default: 96)
-- @return GridDisplay A new GridDisplay instance
function GridDisplay.new(opts)
    local self = setmetatable({}, GridDisplay)
    self.size = opts and opts.size or 3
    self.cellSize = opts and opts.cellSize or 96
    self.status = {}
    for row = 1, self.size do
        self.status[row] = {}
        for col = 1, self.size do
            self.status[row][col] = "empty"
        end
    end
    return self
end

--- Updates the grid display (currently a placeholder).
-- @param dt number Time delta since last update
function GridDisplay:update(dt)
end

function GridDisplay:draw(originX, originY)
    local size = self.size
    local cellSize = self.cellSize
    for row = 1, size do
        for col = 1, size do
            local x = originX + (col - 1) * cellSize
            local y = originY + (row - 1) * cellSize
            love.graphics.setColor(0.1, 0.4, 0.2, 1)
            love.graphics.rectangle("line", x, y, cellSize, cellSize)
            love.graphics.print(self.status[row][col], x + 12, y + 12)
        end
    end
end

return GridDisplay
