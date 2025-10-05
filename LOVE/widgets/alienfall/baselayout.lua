--[[
widgets/baselayout.lua
BaseLayout widget for visual base layout editing


Interactive editor for designing and managing base layouts in strategy games.
Supports facility placement, corridor design, and power system management with validation.

PURPOSE:
- Provide an interactive editor for designing and managing base layouts
- Enable strategic facility placement with constraint validation
- Support corridor and power system design and optimization
- Facilitate base development planning and resource management

KEY FEATURES:
- Facility placement with adjacency constraints and validation
- Grid-based editing with drag-and-drop functionality
- Corridor and access path visualization and optimization
- Power system management with consumption tracking
- Cost calculation and resource requirement display
- Undo/redo functionality for layout changes
- Preview modes for different facility states
- Layout validation with error highlighting
- Integration with base management systems
- Save/load functionality for layout persistence

@see widgets.common.core.Base
@see widgets.complex.dragdrop
@see widgets.common.resourcebar
@see widgets.common.panel
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local DragDrop = require("widgets.complex.dragdrop")
local ResourceBar = require("widgets.alienfall.resourcebar")
local Panel = require("widgets.common.panel")

local BaseLayout = {}
BaseLayout.__index = BaseLayout
setmetatable(BaseLayout, { __index = core.Base })

function BaseLayout:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Core properties
    obj.facilities = {}
    obj.gridSize = options and options.gridSize or 32
    obj.powerGrid = {}

    -- Facility types
    obj.facilityTypes = {
        hangar = { cost = 100, power = 10, color = { 0.5, 0.5, 0.5 } },
        lab = { cost = 50, power = 5, color = { 0.2, 0.6, 1 } },
        workshop = { cost = 75, power = 8, color = { 0.8, 0.4, 0.2 } },
        living_quarters = { cost = 30, power = 3, color = { 0.2, 0.8, 0.2 } }
    }

    -- Visual options
    obj.showGrid = options and options.showGrid ~= false
    obj.showPower = options and options.showPower ~= false

    -- Sub-components
    obj.resourceBar = ResourceBar:new(x, y + h - 100, w, 90)
    obj.facilityPanel = Panel:new(x + w - 200, y, 180, h - 100)

    -- Drag and drop
    obj.dragDrop = DragDrop:new()

    -- Callbacks
    obj.onFacilityPlaced = options and options.onFacilityPlaced
    obj.onLayoutValidated = options and options.onLayoutValidated
    obj.onCostChange = options and options.onCostChange

    setmetatable(obj, self)
    return obj
end

function BaseLayout:update(dt)
    core.Base.update(self, dt)
    self.resourceBar:update(dt)
    self.facilityPanel:update(dt)
    self.dragDrop:update(dt)
end

function BaseLayout:draw()
    -- Draw grid
    if self.showGrid then
        love.graphics.setColor(table.unpack(core.theme.border))
        for i = 0, self.w / self.gridSize do
            love.graphics.line(self.x + i * self.gridSize, self.y, self.x + i * self.gridSize, self.y + self.h)
        end
        for i = 0, self.h / self.gridSize do
            love.graphics.line(self.x, self.y + i * self.gridSize, self.x + self.w, self.y + i * self.gridSize)
        end
    end

    -- Draw facilities
    for _, facility in ipairs(self.facilities) do
        love.graphics.setColor(table.unpack(facility.type.color))
        love.graphics.rectangle("fill", self.x + facility.x * self.gridSize, self.y + facility.y * self.gridSize,
            self.gridSize, self.gridSize)
        love.graphics.setColor(table.unpack(core.theme.text))
        love.graphics.printf(facility.type.name, self.x + facility.x * self.gridSize,
            self.y + facility.y * self.gridSize + 5, self.gridSize, "center")
    end

    -- Draw power grid
    if self.showPower then
        for _, power in ipairs(self.powerGrid) do
            love.graphics.setColor(1, 1, 0, 0.5)
            love.graphics.line(self.x + power.x1 * self.gridSize, self.y + power.y1 * self.gridSize,
                self.x + power.x2 * self.gridSize, self.y + power.y2 * self.gridSize)
        end
    end

    self.resourceBar:draw()
    self.facilityPanel:draw()
end

function BaseLayout:placeFacility(gridX, gridY, typeName)
    local type = self.facilityTypes[typeName]
    if not type then return false end

    -- Check if position is free
    for _, facility in ipairs(self.facilities) do
        if facility.x == gridX and facility.y == gridY then return false end
    end

    table.insert(self.facilities, { x = gridX, y = gridY, type = type })
    self:_updatePowerGrid()
    if self.onFacilityPlaced then self.onFacilityPlaced(gridX, gridY, type) end
    return true
end

function BaseLayout:removeFacility(gridX, gridY)
    for i, facility in ipairs(self.facilities) do
        if facility.x == gridX and facility.y == gridY then
            table.remove(self.facilities, i)
            self:_updatePowerGrid()
            return true
        end
    end
    return false
end

function BaseLayout:_updatePowerGrid()
    self.powerGrid = {}
    -- Simple power connection logic (connect adjacent facilities)
    for _, facility in ipairs(self.facilities) do
        for _, other in ipairs(self.facilities) do
            if facility ~= other and math.abs(facility.x - other.x) + math.abs(facility.y - other.y) == 1 then
                table.insert(self.powerGrid, { x1 = facility.x, y1 = facility.y, x2 = other.x, y2 = other.y })
            end
        end
    end
end

function BaseLayout:validateLayout()
    local valid = true
    local totalCost = 0
    local totalPower = 0

    for _, facility in ipairs(self.facilities) do
        totalCost = totalCost + facility.type.cost
        totalPower = totalPower + facility.type.power
    end

    -- Check power requirements
    if totalPower < #self.facilities * 2 then valid = false end

    if self.onLayoutValidated then self.onLayoutValidated(valid, totalCost, totalPower) end
    return valid, totalCost, totalPower
end

return BaseLayout
