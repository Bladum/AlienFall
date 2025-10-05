--[[
widgets/soldierroster.lua
Soldier Roster widget for managing soldier assignments and stats


Comprehensive interface for managing soldiers, their assignments, stats, and equipment.
Essential for base-building/strategy games with detailed personnel management.

PURPOSE:
- Provide a comprehensive interface for managing soldiers, their assignments, stats, and equipment
- Enable personnel allocation for missions and base defense
- Support soldier development through training and promotions
- Facilitate strategic personnel management decisions

KEY FEATURES:
- Soldier list with comprehensive stats display (health, aim, strength, etc.)
- Assignment management (active duty, training, wounded, etc.)
- Equipment and loadout visualization and management
- Sorting and filtering by rank, class, status, and performance
- Promotion and training tracking with progress indicators
- Personnel allocation for missions and base facilities
- Integration with base facilities and research projects
- Soldier health and recovery monitoring
- Performance metrics and combat statistics
- Custom soldier classes and specialization tracking

]]

local core = require("widgets.core")
local UnitPanel = require("widgets.complex.unitpanel")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")

local SoldierRoster = {}
SoldierRoster.__index = SoldierRoster
setmetatable(SoldierRoster, { __index = core.Base })

-- Soldier status types
SoldierRoster.STATUS = {
    ACTIVE = "active",
    WOUNDED = "wounded",
    TRAINING = "training",
    DEAD = "dead",
    MIA = "mia"
}

function SoldierRoster:new(x, y, w, h, soldiers, options)
    local obj = core.Base:new(x, y, w, h)

    obj.soldiers = soldiers or {}
    obj.options = options or {}

    -- Layout configuration
    obj.headerHeight = 40
    obj.soldierHeight = 80
    obj.scrollOffset = 0
    obj.visibleSoldiers = math.floor((h - obj.headerHeight) / obj.soldierHeight)

    -- Sorting and filtering
    obj.sortBy = options.sortBy or "name" -- name, rank, aim, health, status
    obj.sortAsc = true
    obj.filterStatus = nil                -- nil for all, or specific status

    -- Selection
    obj.selectedSoldier = nil
    obj.multiSelect = options.multiSelect or false
    obj.selectedSoldiers = {}

    -- Stats display
    obj.showStats = options.showStats ~= false
    obj.showEquipment = options.showEquipment ~= false
    obj.showAssignments = options.showAssignments ~= false

    -- Soldier panels (cached for performance)
    obj.soldierPanels = {}

    -- Control buttons
    obj.controlButtons = {}
    local buttonY = y + 10
    local sortBtn = Button:new(x + w - 110, buttonY, 100, 25, "Sort: Name", function()
        obj:toggleSort()
    end)
    table.insert(obj.controlButtons, sortBtn)
    obj:addChild(sortBtn)

    -- Callbacks
    obj.onSoldierSelect = options.onSoldierSelect
    obj.onAssignmentChange = options.onAssignmentChange
    obj.onPromotion = options.onPromotion
    obj.onTrainingComplete = options.onTrainingComplete

    setmetatable(obj, self)
    obj:_sortSoldiers()
    obj:_createSoldierPanels()
    return obj
end

function SoldierRoster:toggleSort()
    if self.sortBy == "name" then
        self.sortBy = "rank"
    elseif self.sortBy == "rank" then
        self.sortBy = "aim"
    elseif self.sortBy == "aim" then
        self.sortBy = "health"
    else
        self.sortBy = "name"
    end

    self:_sortSoldiers()
    self:_createSoldierPanels()

    -- Update button text
    for _, btn in ipairs(self.controlButtons) do
        if btn.text:find("Sort:") then
            btn:setText("Sort: " .. self.sortBy:gsub("^%l", string.upper))
        end
    end
end

function SoldierRoster:_sortSoldiers()
    table.sort(self.soldiers, function(a, b)
        local aVal = a[self.sortBy] or 0
        local bVal = b[self.sortBy] or 0

        if self.sortAsc then
            return aVal < bVal
        else
            return aVal > bVal
        end
    end)
end

function SoldierRoster:_createSoldierPanels()
    -- Clear existing panels
    for _, panel in ipairs(self.soldierPanels) do
        self:removeChild(panel)
    end
    self.soldierPanels = {}

    local startY = self.y + self.headerHeight
    for i = 1, math.min(self.visibleSoldiers, #self.soldiers) do
        local soldier = self.soldiers[i + self.scrollOffset]
        if soldier then
            local panel = UnitPanel:new(self.x + 10, startY + (i - 1) * self.soldierHeight,
                self.w - 20, self.soldierHeight - 5, soldier, {
                    compact = true,
                    showStats = self.showStats,
                    showEquipment = self.showEquipment,
                    onClick = function()
                        self:_selectSoldier(soldier)
                    end
                })
            table.insert(self.soldierPanels, panel)
            self:addChild(panel)
        end
    end
end

function SoldierRoster:_selectSoldier(soldier)
    self.selectedSoldier = soldier
    if self.onSoldierSelect then
        self.onSoldierSelect(soldier)
    end
end

function SoldierRoster:updateSoldier(soldierId, newStats)
    for _, soldier in ipairs(self.soldiers) do
        if soldier.id == soldierId then
            for key, value in pairs(newStats) do
                soldier[key] = value
            end
            break
        end
    end
    self:_sortSoldiers()
    self:_createSoldierPanels()
end

function SoldierRoster:draw()
    core.Base.draw(self)

    -- Header
    love.graphics.setColor(unpack(core.theme.primary))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.headerHeight)
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.printf("Soldier Roster", self.x + 10, self.y + 12, self.w - 20, "left")

    -- Stats summary
    local activeCount = 0
    local woundedCount = 0
    for _, soldier in ipairs(self.soldiers) do
        if soldier.status == self.STATUS.ACTIVE then
            activeCount = activeCount + 1
        elseif soldier.status == self.STATUS.WOUNDED then
            woundedCount = woundedCount + 1
        end
    end

    love.graphics.printf(string.format("Active: %d | Wounded: %d | Total: %d",
            activeCount, woundedCount, #self.soldiers),
        self.x + 10, self.y + 30, self.w - 20, "left")
end

return SoldierRoster
