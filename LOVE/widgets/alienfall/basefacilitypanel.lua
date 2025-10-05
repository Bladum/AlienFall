--[[
widgets/basefacilitypanel.lua
Base Facility Panel widget for facility management


Comprehensive interface for managing base facilities, construction, and maintenance.
Essential for base-building strategy games with complex facility management systems.

PURPOSE:
- Provide a comprehensive interface for managing base facilities
- Enable construction progress tracking and facility status monitoring
- Support personnel assignment and resource management
- Facilitate strategic base development and optimization

KEY FEATURES:
- Facility status display (building, operational, damaged, offline, destroyed)
- Construction progress tracking with time remaining and resource costs
- Resource consumption and production visualization
- Facility upgrade options with requirements and benefits
- Personnel assignment and staffing management
- Maintenance and repair scheduling with priority system
- Power consumption and grid integration
- Facility specialization and efficiency tracking
- Construction queue management and planning
- Integration with base layout and adjacency bonuses
- Cost-benefit analysis for facility decisions

]]

local core = require("widgets.core")
local ProgressBar = require("widgets.common.progressbar")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")

local BaseFacilityPanel = {}
BaseFacilityPanel.__index = BaseFacilityPanel
setmetatable(BaseFacilityPanel, { __index = core.Base })

-- Facility status types
BaseFacilityPanel.STATUS = {
    BUILDING = "building",
    OPERATIONAL = "operational",
    DAMAGED = "damaged",
    OFFLINE = "offline",
    DESTROYED = "destroyed"
}

function BaseFacilityPanel:new(x, y, w, h, facility, options)
    local obj = core.Base:new(x, y, w, h)

    obj.facility = facility or {}
    obj.options = options or {}

    -- Panel layout
    obj.titleHeight = 30
    obj.contentY = y + obj.titleHeight + 5
    obj.contentHeight = h - obj.titleHeight - 10

    -- Status colors
    obj.statusColors = {
        building = { 1, 0.8, 0.2 },
        operational = { 0.2, 1, 0.2 },
        damaged = { 1, 0.5, 0.2 },
        offline = { 0.5, 0.5, 0.5 },
        destroyed = { 1, 0.2, 0.2 }
    }

    -- Construction progress (if building)
    obj.constructionBar = nil
    if obj.facility.status == self.STATUS.BUILDING then
        obj.constructionBar = ProgressBar:new(x + 10, obj.contentY + 40, w - 20, 20, {
            value = obj.facility.constructionProgress or 0,
            maxValue = 100,
            showText = true,
            textFormat = "Construction: %d%%"
        })
        obj:addChild(obj.constructionBar)
    end

    -- Personnel assignment
    obj.personnelLabel = Label:new(x + 10, obj.contentY + 80, 200, 20,
        string.format("Personnel: %d/%d", obj.facility.assignedPersonnel or 0, obj.facility.requiredPersonnel or 0))
    obj:addChild(obj.personnelLabel)

    -- Resource consumption/production
    obj.resourceLabels = {}
    local resourceY = obj.contentY + 110
    if obj.facility.powerConsumption then
        local powerLabel = Label:new(x + 10, resourceY, 200, 20,
            string.format("Power: -%d", obj.facility.powerConsumption))
        table.insert(obj.resourceLabels, powerLabel)
        obj:addChild(powerLabel)
        resourceY = resourceY + 25
    end

    -- Action buttons
    obj.actionButtons = {}
    local buttonY = h - 40
    if obj.facility.status == self.STATUS.DAMAGED then
        local repairBtn = Button:new(x + 10, buttonY, 80, 30, "Repair", function()
            if obj.onRepair then obj.onRepair(obj.facility) end
        end)
        table.insert(obj.actionButtons, repairBtn)
        obj:addChild(repairBtn)
    end

    if obj.facility.upgradesAvailable then
        local upgradeBtn = Button:new(x + 100, buttonY, 80, 30, "Upgrade", function()
            if obj.onUpgrade then obj.onUpgrade(obj.facility) end
        end)
        table.insert(obj.actionButtons, upgradeBtn)
        obj:addChild(upgradeBtn)
    end

    -- Callbacks
    obj.onUpgrade = options.onUpgrade
    obj.onRepair = options.onRepair
    obj.onAssignPersonnel = options.onAssignPersonnel
    obj.onFacilityAction = options.onFacilityAction

    setmetatable(obj, self)
    return obj
end

function BaseFacilityPanel:updateFacility(facility)
    self.facility = facility

    -- Update construction progress
    if self.constructionBar and facility.status == self.STATUS.BUILDING then
        self.constructionBar:setValue(facility.constructionProgress or 0)
    end

    -- Update personnel
    if self.personnelLabel then
        self.personnelLabel:setText(string.format("Personnel: %d/%d",
            facility.assignedPersonnel or 0, facility.requiredPersonnel or 0))
    end
end

function BaseFacilityPanel:draw()
    core.Base.draw(self)

    -- Title bar
    love.graphics.setColor(table.unpack(core.theme.primary))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.titleHeight)
    love.graphics.setColor(table.unpack(core.theme.text))
    love.graphics.printf(self.facility.name or "Facility", self.x + 10, self.y + 8, self.w - 20, "left")

    -- Status indicator
    local statusColor = self.statusColors[self.facility.status] or self.statusColors.offline
    love.graphics.setColor(table.unpack(statusColor))
    love.graphics.rectangle("fill", self.x + self.w - 30, self.y + 5, 20, 20)

    -- Content area
    love.graphics.setColor(table.unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.contentY, self.w, self.contentHeight)
    love.graphics.setColor(table.unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.contentY, self.w, self.contentHeight)

    -- Facility info
    love.graphics.setColor(table.unpack(core.theme.text))
    love.graphics.printf(string.format("Type: %s", self.facility.type or "Unknown"),
        self.x + 10, self.contentY + 10, self.w - 20, "left")
    love.graphics.printf(string.format("Status: %s", self.facility.status or "Unknown"),
        self.x + 10, self.contentY + 25, self.w - 20, "left")
end

return BaseFacilityPanel






