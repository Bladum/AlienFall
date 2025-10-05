--[[
widgets/alienfall/research_tracker.lua
Research Tracker widget for monitoring research progress and dependencies.

Provides a comprehensive interface for tracking research projects, their progress, dependencies, and completion status in strategy games like OpenXCOM.

PURPOSE:
- Provide a comprehensive interface for tracking research projects, their progress, dependencies, and completion status in strategy games like OpenXCOM

KEY FEATURES:
- Research project progress visualization with time estimates
- Dependency tree display showing prerequisite relationships
- Scientist allocation and efficiency tracking
- Research category organization (weapons, armor, aircraft, etc.)
- Breakthrough notifications and discovery announcements
- Integration with tech tree for long-term planning

@see widgets.core
@see widgets.complex.techtree
]]

local core = require("widgets.core")
local ProgressBar = require("widgets.common.progressbar")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")

local ResearchTracker = {}
ResearchTracker.__index = ResearchTracker
setmetatable(ResearchTracker, { __index = core.Base })

function ResearchTracker:new(x, y, w, h, researchData, options)
    local obj = core.Base:new(x, y, w, h)

    obj.researchData = researchData or {}
    obj.options = options or {}

    -- Research projects
    obj.projects = obj.researchData.projects or {}
    obj.activeProjects = obj.researchData.activeProjects or {}

    -- Scientist management
    obj.totalScientists = obj.options.totalScientists or 0
    obj.allocatedScientists = obj.options.allocatedScientists or 0

    -- Categories
    obj.categories = {
        "Weapons",
        "Armor",
        "Aircraft",
        "Equipment",
        "Facilities",
        "Alien Tech"
    }
    obj.selectedCategory = 1

    -- Progress tracking
    obj.projectProgress = {}
    obj:_createProgressDisplays()

    -- Control buttons
    obj.controlButtons = {}
    local buttonY = y + 10
    local startBtn = Button:new(x + w - 110, buttonY, 100, 25, "Start Research", function()
        if obj.onResearchStart then obj.onResearchStart() end
    end)
    table.insert(obj.controlButtons, startBtn)
    obj:addChild(startBtn)

    -- Callbacks
    obj.onResearchStart = options.onResearchStart
    obj.onProjectComplete = options.onProjectComplete
    obj.onScientistReassigned = options.onScientistReassigned

    setmetatable(obj, self)
    return obj
end

function ResearchTracker:_createProgressDisplays()
    local progressY = self.y + 50
    for i, project in ipairs(self.activeProjects) do
        if i > 5 then break end -- Limit display to 5 active projects

        -- Project name
        local nameLabel = Label:new(self.x + 10, progressY, 200, 20,
            string.format("%s (%s)", project.name, project.category))
        self:addChild(nameLabel)

        -- Progress bar
        local progressBar = ProgressBar:new(self.x + 220, progressY, self.w - 240, 20,
            project.progress or 0, 0, 100, {
                showText = true,
                textFormat = "%.1f%%"
            })
        self:addChild(progressBar)
        self.projectProgress[project.id] = progressBar

        -- Time remaining
        local timeLabel = Label:new(self.x + 10, progressY + 25, 200, 15,
            string.format("Time: %s", project.timeRemaining or "Unknown"))
        self:addChild(timeLabel)

        progressY = progressY + 50
    end
end

function ResearchTracker:addProject(project)
    table.insert(self.projects, project)
    -- Update display
end

function ResearchTracker:updateProgress(projectId, progress)
    if self.projectProgress[projectId] then
        self.projectProgress[projectId]:setValue(progress, true)
    end
end

return ResearchTracker
