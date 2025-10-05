--[[
widgets/researchpanel.lua
Research Panel widget for displaying research progress and tree


Comprehensive interface for managing research projects, displaying progress, and navigating the tech tree.
Essential for tactical/strategy games with complex research dependencies and timelines.

PURPOSE:
- Provide a comprehensive interface for managing research projects, displaying progress, and navigating the tech tree
- Enable research queue management and scientist allocation
- Support tech tree visualization with prerequisites and unlocks
- Facilitate strategic decision making in research planning

KEY FEATURES:
- Research project display with progress bars and time remaining
- Tech tree visualization with prerequisites and unlocks
- Research queue management and prioritization
- Scientist assignment and allocation system
- Research categories (weapons, armor, aircraft, etc.)
- Project completion notifications and alerts
- Resource cost tracking and budget management
- Research dependency visualization
- Interactive tech tree navigation
- Progress tracking and ETA calculations

]]

local core = require("widgets.core")
local ProgressBar = require("widgets.common.progressbar")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")
local TechTree = require("widgets.complex.techtree")

local ResearchPanel = {}
ResearchPanel.__index = ResearchPanel
setmetatable(ResearchPanel, { __index = core.Base })

function ResearchPanel:new(x, y, w, h, researchData, options)
    local obj = core.Base:new(x, y, w, h)

    obj.researchData = researchData or {}
    obj.options = options or {}

    -- Panel sections
    obj.headerHeight = 40
    obj.queueHeight = 150
    obj.treeHeight = h - obj.headerHeight - obj.queueHeight - 20

    -- Current research projects
    obj.activeProjects = obj.researchData.activeProjects or {}
    obj.completedProjects = obj.researchData.completedProjects or {}

    -- Research queue
    obj.researchQueue = obj.researchData.queue or {}

    -- Scientist allocation
    obj.totalScientists = obj.researchData.totalScientists or 0
    obj.assignedScientists = obj.researchData.assignedScientists or 0

    -- Progress bars for active projects
    obj.progressBars = {}
    obj:updateProgressBars()

    -- Tech tree viewer
    obj.techTree = TechTree:new(x + 10, y + obj.headerHeight + obj.queueHeight + 10,
        w - 20, obj.treeHeight, obj.researchData.techTree, {
            showCompleted = true,
            showPrerequisites = true,
            onSelectTech = function(tech)
                if obj.onSelectTech then obj.onSelectTech(tech) end
            end
        })
    obj:addChild(obj.techTree)

    -- Control buttons
    obj.controlButtons = {}
    local buttonY = y + obj.headerHeight + 10
    local startBtn = Button:new(x + w - 110, buttonY, 100, 30, "Start Research", function()
        if obj.onStartResearch then obj.onStartResearch() end
    end)
    table.insert(obj.controlButtons, startBtn)
    obj:addChild(startBtn)

    -- Callbacks
    obj.onStartResearch = options.onStartResearch
    obj.onCancelResearch = options.onCancelResearch
    obj.onProjectComplete = options.onProjectComplete
    obj.onAssignScientists = options.onAssignScientists
    obj.onSelectTech = options.onSelectTech

    setmetatable(obj, self)
    return obj
end

function ResearchPanel:updateProgressBars()
    -- Clear existing progress bars
    for _, bar in ipairs(self.progressBars) do
        self:removeChild(bar)
    end
    self.progressBars = {}

    local barY = self.y + self.headerHeight + 40
    for i, project in ipairs(self.activeProjects) do
        local progressBar = ProgressBar:new(self.x + 10, barY, self.w - 20, 25, {
            value = project.progress or 0,
            maxValue = 100,
            showText = true,
            textFormat = string.format("%s: %d%% (%s)", project.name, project.progress or 0,
                self:formatTimeRemaining(project.timeRemaining))
        })
        table.insert(self.progressBars, progressBar)
        self:addChild(progressBar)
        barY = barY + 35
    end
end

function ResearchPanel:formatTimeRemaining(seconds)
    if not seconds then return "Unknown" end
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    else
        return string.format("%dm", minutes)
    end
end

function ResearchPanel:updateProgress(projectId, progress)
    for _, project in ipairs(self.activeProjects) do
        if project.id == projectId then
            project.progress = progress
            break
        end
    end
    self:updateProgressBars()
end

function ResearchPanel:completeProject(projectId)
    for i, project in ipairs(self.activeProjects) do
        if project.id == projectId then
            table.remove(self.activeProjects, i)
            table.insert(self.completedProjects, project)
            if self.onProjectComplete then
                self.onProjectComplete(project)
            end
            break
        end
    end
    self:updateProgressBars()
end

function ResearchPanel:draw()
    core.Base.draw(self)

    -- Header
    love.graphics.setColor(unpack(core.theme.primary))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.headerHeight)
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.printf("Research Lab", self.x + 10, self.y + 12, self.w - 20, "left")

    -- Scientist info
    love.graphics.printf(string.format("Scientists: %d/%d", self.assignedScientists, self.totalScientists),
        self.x + 10, self.y + 30, self.w - 20, "left")

    -- Queue section
    love.graphics.setColor(unpack(core.theme.secondary))
    love.graphics.rectangle("fill", self.x, self.y + self.headerHeight, self.w, self.queueHeight)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y + self.headerHeight, self.w, self.queueHeight)

    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.printf("Research Queue", self.x + 10, self.y + self.headerHeight + 10, self.w - 20, "left")

    -- Draw queue items
    local queueY = self.y + self.headerHeight + 35
    for i, project in ipairs(self.researchQueue) do
        love.graphics.printf(string.format("%d. %s", i, project.name),
            self.x + 20, queueY, self.w - 30, "left")
        queueY = queueY + 20
    end
end

return ResearchPanel
