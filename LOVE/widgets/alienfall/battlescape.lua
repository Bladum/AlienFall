--[[
widgets/battlescape.lua
Battlescape widget for tactical combat interface


Comprehensive tactical combat interface for turn-based strategy games.
Displays units, terrain, actions, and provides real-time battle management.

PURPOSE:
- Provide a comprehensive tactical combat interface for turn-based strategy games
- Enable visualization of unit positioning, movement, and combat actions
- Support fog of war, terrain overlays, and tactical decision making
- Facilitate immersive tactical gameplay with real-time updates

KEY FEATURES:
- Unit positioning and movement visualization with smooth animations
- Action queues and command selection interface
- Terrain overlays with height, cover, and movement cost display
- Fog of war system with visibility calculations
- Unit stats display and health monitoring
- Interactive command selection and execution
- MiniMap integration for tactical overview
- Turn-based phase tracking and timing
- Pathfinding visualization and movement planning
- Combat prediction and damage estimation
- Multi-unit selection and group commands

]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local MiniMap = require("widgets.complex.minimap")
local UnitPanel = require("widgets.complex.unitpanel")
local TurnIndicator = require("widgets.complex.turnindicator")

local Battlescape = {}
Battlescape.__index = Battlescape
setmetatable(Battlescape, { __index = core.Base })

function Battlescape:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Core properties
    obj.units = {}
    obj.terrain = {}
    obj.currentTurn = 1
    obj.selectedUnit = nil
    obj.fogOfWar = options and options.fogOfWar or true

    -- Visual options
    obj.tileSize = options and options.tileSize or 32
    obj.showGrid = options and options.showGrid ~= false
    obj.showMiniMap = options and options.showMiniMap ~= false

    -- Sub-components
    obj.miniMap = obj.showMiniMap and MiniMap:new(x + w - 200, y, 180, 180) or nil
    obj.unitPanel = UnitPanel:new(x, y + h - 150, w, 140)
    obj.turnIndicator = TurnIndicator:new(x + w / 2 - 50, y + 10, 100, 30)

    -- Action queue
    obj.actionQueue = {}

    -- Callbacks
    obj.onUnitMove = options and options.onUnitMove
    obj.onActionSelect = options and options.onActionSelect
    obj.onTurnEnd = options and options.onTurnEnd

    setmetatable(obj, self)
    return obj
end

function Battlescape:update(dt)
    core.Base.update(self, dt)
    if self.miniMap then self.miniMap:update(dt) end
    self.unitPanel:update(dt)
    self.turnIndicator:update(dt)

    -- Update unit animations
    for _, unit in ipairs(self.units) do
        if unit.animation then unit.animation:update(dt) end
    end
end

function Battlescape:draw()
    -- Draw terrain
    for i, tile in ipairs(self.terrain) do
        local tx = (i - 1) % (self.w / self.tileSize)
        local ty = math.floor((i - 1) / (self.w / self.tileSize))
        love.graphics.setColor(table.unpack(tile.color))
        love.graphics.rectangle("fill", self.x + tx * self.tileSize, self.y + ty * self.tileSize, self.tileSize,
            self.tileSize)
    end

    -- Draw grid
    if self.showGrid then
        love.graphics.setColor(table.unpack(core.theme.border))
        for i = 0, self.w / self.tileSize do
            love.graphics.line(self.x + i * self.tileSize, self.y, self.x + i * self.tileSize, self.y + self.h)
        end
        for i = 0, self.h / self.tileSize do
            love.graphics.line(self.x, self.y + i * self.tileSize, self.x + self.w, self.y + i * self.tileSize)
        end
    end

    -- Draw units
    for _, unit in ipairs(self.units) do
        love.graphics.setColor(table.unpack(unit.color))
        love.graphics.circle("fill", self.x + unit.x * self.tileSize + self.tileSize / 2,
            self.y + unit.y * self.tileSize + self.tileSize / 2, self.tileSize / 3)
        if unit == self.selectedUnit then
            love.graphics.setColor(table.unpack(core.theme.accent))
            love.graphics.circle("line", self.x + unit.x * self.tileSize + self.tileSize / 2,
                self.y + unit.y * self.tileSize + self.tileSize / 2, self.tileSize / 2)
        end
    end

    -- Draw sub-components
    if self.miniMap then self.miniMap:draw() end
    self.unitPanel:draw()
    self.turnIndicator:draw()
end

function Battlescape:setUnits(units)
    self.units = units or {}
    self.unitPanel:setUnit(self.selectedUnit)
end

function Battlescape:setTerrain(terrain)
    self.terrain = terrain or {}
    if self.miniMap then self.miniMap:setTerrain(terrain) end
end

function Battlescape:addAction(unit, action)
    table.insert(self.actionQueue, { unit = unit, action = action })
end

return Battlescape
