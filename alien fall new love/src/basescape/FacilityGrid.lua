--- FacilityGrid class for managing base facility layout and rendering.
-- @classmod basescape.FacilityGrid
-- @field size number Grid size (width and height)
-- @field cells table Array of placed facilities
-- @field cellSize number Size of each grid cell in pixels

local FacilityGrid = {}
FacilityGrid.__index = FacilityGrid

--- Creates a new FacilityGrid instance.
-- @param opts table Configuration options
-- @param opts.size number Grid size (default: 6)
-- @return FacilityGrid A new FacilityGrid instance
function FacilityGrid.new(opts)
    local self = setmetatable({}, FacilityGrid)
    self.size = opts and opts.size or 6
    self.cells = {}
    self.cellSize = 48
    return self
end

--- Resets the facility grid, clearing all placed facilities.
function FacilityGrid:reset()
    self.cells = {}
end

--- Adds a facility to the grid.
-- @param facility table Facility object to add
function FacilityGrid:addFacility(facility)
    table.insert(self.cells, facility)
end

--- Draws the facility grid and all placed facilities.
-- @param originX number X coordinate of grid origin
-- @param originY number Y coordinate of grid origin
function FacilityGrid:draw(originX, originY)
    local size = self.size
    local cellSize = self.cellSize
    love.graphics.setColor(0.2, 0.25, 0.28, 1)
    for row = 0, size - 1 do
        for col = 0, size - 1 do
            local x = originX + col * cellSize
            local y = originY + row * cellSize
            love.graphics.rectangle("line", x, y, cellSize, cellSize)
        end
    end

    love.graphics.setColor(0.8, 0.85, 0.9, 1)
    for _, facility in ipairs(self.cells) do
        local x = originX + facility.x * cellSize
        local y = originY + facility.y * cellSize
        local width = (facility.width or 1) * cellSize
        local height = (facility.height or 1) * cellSize
        love.graphics.rectangle("fill", x + 2, y + 2, width - 4, height - 4)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(facility.label or "Facility", x + 6, y + 6)
        love.graphics.setColor(0.8, 0.85, 0.9, 1)
    end
end

return FacilityGrid
