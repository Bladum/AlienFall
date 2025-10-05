--[[
widgets/manufacturepanel.lua
Manufacture Panel widget for manufacturing management


Comprehensive interface for managing manufacturing queues, production facilities, and equipment creation.
Essential for base-building strategy games with complex production systems.

PURPOSE:
- Provide a comprehensive interface for managing manufacturing operations
- Enable production queue management and facility oversight
- Support resource allocation and engineer assignment
- Facilitate strategic production planning and optimization

KEY FEATURES:
- Manufacturing queue management with priority ordering
- Production facility status and capacity monitoring
- Resource requirements checking and availability display
- Equipment categories (weapons, armor, aircraft, vehicles, etc.)
- Production time estimation with completion notifications
- Engineer assignment and training level tracking
- Manufacturing templates and batch production
- Resource consumption tracking and optimization
- Production facility upgrades and specialization
- Integration with research and inventory management
- Cost-benefit analysis for production decisions

]]

local core = require("widgets.core")
local ProgressBar = require("widgets.common.progressbar")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")

local ManufacturePanel = {}
ManufacturePanel.__index = ManufacturePanel
setmetatable(ManufacturePanel, { __index = core.Base })

function ManufacturePanel:new(x, y, w, h, facilities, options)
    local obj = core.Base:new(x, y, w, h)

    obj.facilities = facilities or {}
    obj.options = options or {}

    -- Panel sections
    obj.headerHeight = 40
    obj.facilityHeight = 120
    obj.queueHeight = h - obj.headerHeight - (#obj.facilities * obj.facilityHeight) - 20

    -- Manufacturing queue
    obj.productionQueue = obj.options.productionQueue or {}

    -- Engineer allocation
    obj.totalEngineers = obj.options.totalEngineers or 0
    obj.assignedEngineers = obj.options.assignedEngineers or 0

    -- Production categories
    obj.categories = {
        "Weapons",
        "Armor",
        "Aircraft",
        "Equipment",
        "Facilities"
    }
    obj.selectedCategory = 1

    -- Progress bars for facilities
    obj.facilityProgress = {}
    obj:_createFacilityDisplays()

    -- Queue display
    obj.queueItems = {}
    obj:_createQueueDisplay()

    -- Control buttons
    obj.controlButtons = {}
    local buttonY = y + 10
    local produceBtn = Button:new(x + w - 110, buttonY, 100, 25, "Produce", function()
        if obj.onProductionStart then obj.onProductionStart() end
    end)
    table.insert(obj.controlButtons, produceBtn)
    obj:addChild(produceBtn)

    -- Callbacks
    obj.onProductionStart = options.onProductionStart
    obj.onProductionComplete = options.onProductionComplete
    obj.onResourceShortage = options.onResourceShortage
    obj.onEngineerAssign = options.onEngineerAssign

    setmetatable(obj, self)
    return obj
end

function ManufacturePanel:_createFacilityDisplays()
    local facilityY = self.y + self.headerHeight
    for i, facility in ipairs(self.facilities) do
        -- Facility status
        local statusLabel = Label:new(self.x + 10, facilityY + 10, 200, 20,
            string.format("%s: %s", facility.name, facility.status))
        self:addChild(statusLabel)

        -- Engineer assignment
        local engineerLabel = Label:new(self.x + 10, facilityY + 35, 200, 20,
            string.format("Engineers: %d/%d", facility.assignedEngineers or 0, facility.capacity or 0))
        self:addChild(engineerLabel)

        -- Current production
        if facility.currentProduction then
            local progressBar = ProgressBar:new(self.x + 10, facilityY + 60, self.w - 20, 20, {
                value = facility.currentProduction.progress or 0,
                maxValue = 100,
                showText = true,
                textFormat = string.format("%s: %d%%", facility.currentProduction.name,
                    facility.currentProduction.progress or 0)
            })
            table.insert(self.facilityProgress, progressBar)
            self:addChild(progressBar)
        end

        facilityY = facilityY + self.facilityHeight
    end
end

function ManufacturePanel:_createQueueDisplay()
    local queueY = self.y + self.headerHeight + (#self.facilities * self.facilityHeight) + 10

    -- Queue header
    local queueLabel = Label:new(self.x + 10, queueY, 200, 20, "Production Queue")
    self:addChild(queueLabel)

    -- Queue items
    queueY = queueY + 30
    for i, item in ipairs(self.productionQueue) do
        local itemLabel = Label:new(self.x + 20, queueY, self.w - 30, 20,
            string.format("%d. %s (x%d) - %s", i, item.name, item.quantity,
                self:_formatTimeRemaining(item.timeRemaining)))
        table.insert(self.queueItems, itemLabel)
        self:addChild(itemLabel)
        queueY = queueY + 25
    end
end

function ManufacturePanel:_formatTimeRemaining(seconds)
    if not seconds then return "Unknown" end
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    else
        return string.format("%dm", minutes)
    end
end

function ManufacturePanel:addToQueue(item, quantity)
    table.insert(self.productionQueue, {
        name = item.name,
        quantity = quantity or 1,
        timeRemaining = item.productionTime * (quantity or 1),
        progress = 0
    })
    self:_createQueueDisplay()
end

function ManufacturePanel:updateProgress(queueId, progress)
    if self.productionQueue[queueId] then
        self.productionQueue[queueId].progress = progress
        self:_createQueueDisplay()
    end
end

function ManufacturePanel:draw()
    core.Base.draw(self)

    -- Header
    love.graphics.setColor(unpack(core.theme.primary))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.headerHeight)
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.printf("Manufacturing", self.x + 10, self.y + 12, self.w - 20, "left")

    -- Engineer summary
    love.graphics.printf(string.format("Engineers: %d/%d", self.assignedEngineers, self.totalEngineers),
        self.x + 10, self.y + 30, self.w - 20, "left")
end

return ManufacturePanel






