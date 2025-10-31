---@class ResearchQueueUI
---@field base table Reference to base data
---@field researchSystem table Reference to research system
---@field uiOffsetX number X offset for UI positioning (grid-aligned)
---@field uiOffsetY number Y offset for UI positioning (grid-aligned)
---@field uiWidth number Width of the research queue interface
---@field uiHeight number Height of the research queue interface
---@field availableProjects table List of available research projects
---@field researchQueue table Current research queue
---@field selectedProject table Currently selected project for detailed view
---@field scientistAllocation number Number of scientists allocated to research
---@field totalScientists number Total scientists available
---@field scrollOffset number Current scroll position for project list
---@field onProjectQueued function Callback when project is queued
---@field onProjectDequeued function Callback when project is dequeued
---@field onAllocationChanged function Callback when scientist allocation changes
local ResearchQueueUI = {}
ResearchQueueUI.__index = ResearchQueueUI

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local PROJECT_HEIGHT = 60  -- Height of each project item in the list
local VISIBLE_PROJECTS = 5  -- Number of projects visible at once
local SCROLLBAR_WIDTH = 16
local ALLOCATION_SLIDER_WIDTH = 200

-- Research categories for organization
local RESEARCH_CATEGORIES = {
    "weapons",
    "armor",
    "alien_tech",
    "facilities",
    "support"
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

---@param base table Base data structure
---@return table New ResearchQueueUI instance
function ResearchQueueUI:new(base)
    local self = setmetatable({}, ResearchQueueUI)

    self.base = base or {}
    self.researchSystem = nil

    -- Position UI to the right side of the screen (grid-aligned)
    local windowWidth = love.graphics.getWidth()
    self.uiOffsetX = math.floor((windowWidth - 400) / 24) * 24  -- 400px width, grid-aligned
    self.uiOffsetY = 72  -- Below the view buttons
    self.uiWidth = 400
    self.uiHeight = 480

    self.availableProjects = {}
    self.researchQueue = {}
    self.selectedProject = nil
    self.scientistAllocation = 0
    self.totalScientists = 0
    self.scrollOffset = 0
    self.selectedCategory = "all"

    -- Initialize data
    self:updateAvailableProjects()
    self:updateScientistAllocation()

    return self
end

---@param base table Update the base reference
function ResearchQueueUI:setBase(base)
    self.base = base or {}
    self:updateAvailableProjects()
    self:updateScientistAllocation()
end

---@param researchSystem table Set the research system reference
function ResearchQueueUI:setResearchSystem(researchSystem)
    self.researchSystem = researchSystem
    self:updateAvailableProjects()
    self:updateScientistAllocation()
end

-- ============================================================================
-- DATA MANAGEMENT
-- ============================================================================

--- Update the list of available research projects
function ResearchQueueUI:updateAvailableProjects()
    self.availableProjects = {}

    if not self.researchSystem then
        -- Fallback: create sample projects
        self.availableProjects = {
            {
                id = "laser_weapons",
                name = "Laser Weapons",
                category = "weapons",
                description = "Advanced energy weapons technology",
                daysRequired = 20,
                prerequisites = {},
                completed = false,
                available = true
            },
            {
                id = "plasma_weapons",
                name = "Plasma Weapons",
                category = "weapons",
                description = "High-energy plasma-based weaponry",
                daysRequired = 30,
                prerequisites = {"laser_weapons"},
                completed = false,
                available = false
            },
            {
                id = "personal_armor",
                name = "Personal Armor",
                category = "armor",
                description = "Advanced protective suits",
                daysRequired = 15,
                prerequisites = {},
                completed = false,
                available = true
            },
            {
                id = "alien_materials",
                name = "Alien Materials",
                category = "alien_tech",
                description = "Study of extraterrestrial materials",
                daysRequired = 25,
                prerequisites = {},
                completed = false,
                available = true
            }
        }
        return
    end

    -- Get available projects from research system
    local projects = self.researchSystem:getAvailableProjects()
    for _, project in ipairs(projects) do
        table.insert(self.availableProjects, {
            id = project.id,
            name = project.name,
            category = project.category,
            description = project.description,
            daysRequired = project.daysRequired,
            prerequisites = project.prerequisites or {},
            completed = project.completed or false,
            available = project.available or true
        })
    end
end

--- Update scientist allocation information
function ResearchQueueUI:updateScientistAllocation()
    if self.researchSystem then
        self.totalScientists = self.researchSystem:getTotalScientists() or 0
        self.scientistAllocation = self.researchSystem:getAllocatedScientists() or 0
    else
        -- Fallback values
        self.totalScientists = 10
        self.scientistAllocation = 5
    end
end

--- Get filtered projects based on selected category
---@return table Filtered list of projects
function ResearchQueueUI:getFilteredProjects()
    if self.selectedCategory == "all" then
        return self.availableProjects
    end

    local filtered = {}
    for _, project in ipairs(self.availableProjects) do
        if project.category == self.selectedCategory then
            table.insert(filtered, project)
        end
    end
    return filtered
end

--- Check if a project can be queued
---@param projectId string Project identifier
---@return boolean, string Whether it can be queued and reason if not
function ResearchQueueUI:canQueueProject(projectId)
    -- Check if already in queue
    for _, queued in ipairs(self.researchQueue) do
        if queued.id == projectId then
            return false, "Already in queue"
        end
    end

    -- Check prerequisites
    local project = self:getProjectById(projectId)
    if not project then
        return false, "Project not found"
    end

    if not project.available then
        return false, "Prerequisites not met"
    end

    -- Check if already completed
    if project.completed then
        return false, "Already completed"
    end

    return true, ""
end

--- Get project by ID
---@param projectId string Project identifier
---@return table|nil Project data or nil if not found
function ResearchQueueUI:getProjectById(projectId)
    for _, project in ipairs(self.availableProjects) do
        if project.id == projectId then
            return project
        end
    end
    return nil
end

--- Add project to research queue
---@param projectId string Project identifier
---@return boolean Success
function ResearchQueueUI:queueProject(projectId)
    local canQueue, reason = self:canQueueProject(projectId)
    if not canQueue then
        print("[ResearchQueueUI] Cannot queue " .. projectId .. ": " .. reason)
        return false
    end

    local project = self:getProjectById(projectId)
    if not project then
        return false
    end

    table.insert(self.researchQueue, {
        id = project.id,
        name = project.name,
        category = project.category,
        daysRequired = project.daysRequired,
        daysCompleted = 0,
        progress = 0,
        allocatedScientists = 0
    })

    print(string.format("[ResearchQueueUI] Queued research: %s", project.name))
    if self.onProjectQueued then
        self.onProjectQueued(projectId)
    end

    return true
end

--- Remove project from research queue
---@param index number Queue position (1-based)
---@return boolean Success
function ResearchQueueUI:dequeueProject(index)
    if index < 1 or index > #self.researchQueue then
        return false
    end

    local project = table.remove(self.researchQueue, index)
    print(string.format("[ResearchQueueUI] Dequeued research: %s", project.name))

    if self.onProjectDequeued then
        self.onProjectDequeued(project.id)
    end

    return true
end

--- Update scientist allocation
---@param allocation number Number of scientists to allocate
function ResearchQueueUI:setScientistAllocation(allocation)
    allocation = math.max(0, math.min(self.totalScientists, allocation))
    self.scientistAllocation = allocation

    if self.onAllocationChanged then
        self.onAllocationChanged(allocation)
    end

    -- Distribute scientists to active projects
    self:distributeScientists()
end

--- Distribute allocated scientists among active projects
function ResearchQueueUI:distributeScientists()
    local activeProjects = 0
    for _, project in ipairs(self.researchQueue) do
        if project.daysCompleted < project.daysRequired then
            activeProjects = activeProjects + 1
        end
    end

    if activeProjects == 0 then return end

    local scientistsPerProject = math.floor(self.scientistAllocation / activeProjects)
    local remainder = self.scientistAllocation % activeProjects

    local projectIndex = 1
    for _, project in ipairs(self.researchQueue) do
        if project.daysCompleted < project.daysRequired then
            project.allocatedScientists = scientistsPerProject
            if remainder > 0 then
                project.allocatedScientists = project.allocatedScientists + 1
                remainder = remainder - 1
            end
            projectIndex = projectIndex + 1
        else
            project.allocatedScientists = 0
        end
    end
end

--- Update research progress
---@param dt number Delta time in seconds
function ResearchQueueUI:updateResearchProgress(dt)
    for _, project in ipairs(self.researchQueue) do
        if project.daysCompleted < project.daysRequired and project.allocatedScientists > 0 then
            -- Progress based on scientists allocated (simplified calculation)
            local progressRate = project.allocatedScientists * 0.01  -- Base progress per scientist per second
            project.daysCompleted = project.daysCompleted + progressRate * dt
            project.progress = math.min(1.0, project.daysCompleted / project.daysRequired)

            -- Check completion
            if project.daysCompleted >= project.daysRequired then
                project.daysCompleted = project.daysRequired
                project.progress = 1.0
                print(string.format("[ResearchQueueUI] Research completed: %s", project.name))

                if self.onProjectCompleted then
                    self.onProjectCompleted(project.id)
                end
            end
        end
    end
end

-- ============================================================================
-- RENDERING
-- ============================================================================

--- Render the research queue interface
function ResearchQueueUI:draw()
    -- Draw background panel
    self:drawBackground()

    -- Draw header with category filter
    self:drawHeader()

    -- Draw scientist allocation slider
    self:drawScientistAllocation()

    -- Draw available projects list
    self:drawAvailableProjects()

    -- Draw research queue
    self:drawResearchQueue()

    -- Draw project details if selected
    self:drawProjectDetails()

    -- Draw scrollbar if needed
    local filteredProjects = self:getFilteredProjects()
    if #filteredProjects > VISIBLE_PROJECTS then
        self:drawScrollbar()
    end
end

--- Draw the background panel
function ResearchQueueUI:drawBackground()
    -- Main panel background
    love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
    love.graphics.rectangle("fill", self.uiOffsetX, self.uiOffsetY, self.uiWidth, self.uiHeight)

    -- Border
    love.graphics.setColor(0.3, 0.3, 0.4, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.uiOffsetX, self.uiOffsetY, self.uiWidth, self.uiHeight)
end

--- Draw the header with category filter
function ResearchQueueUI:drawHeader()
    local headerY = self.uiOffsetY + 5

    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Research Management", self.uiOffsetX + 10, headerY)

    -- Category filter buttons
    local buttonY = headerY + 20
    local buttonWidth = 60
    local buttonHeight = 20
    local buttonSpacing = 5

    local categories = {"all", "weapons", "armor", "alien_tech", "facilities", "support"}
    for i, category in ipairs(categories) do
        local buttonX = self.uiOffsetX + 10 + (i - 1) * (buttonWidth + buttonSpacing)
        self:drawCategoryButton(category, buttonX, buttonY, buttonWidth, buttonHeight)
    end
end

--- Draw a category filter button
---@param category string Category name
---@param x number Button X position
---@param y number Button Y position
---@param width number Button width
---@param height number Button height
function ResearchQueueUI:drawCategoryButton(category, x, y, width, height)
    local isSelected = self.selectedCategory == category
    local isHovered = self:isButtonHovered(x, y, width, height)

    -- Button background
    if isSelected then
        love.graphics.setColor(0.3, 0.5, 0.7, 0.8)
    elseif isHovered then
        love.graphics.setColor(0.2, 0.3, 0.4, 0.7)
    else
        love.graphics.setColor(0.15, 0.2, 0.3, 0.6)
    end

    love.graphics.rectangle("fill", x, y, width, height)

    -- Button border
    love.graphics.setColor(0.4, 0.5, 0.6, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)

    -- Button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(9))
    local displayName = category == "all" and "ALL" or category:upper():sub(1, 3)
    local textWidth = love.graphics.getFont():getWidth(displayName)
    love.graphics.print(displayName, x + (width - textWidth) / 2, y + 3)
end

--- Draw scientist allocation slider
function ResearchQueueUI:drawScientistAllocation()
    local sliderY = self.uiOffsetY + 50

    -- Label
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Scientists:", self.uiOffsetX + 10, sliderY)

    local allocationText = string.format("%d / %d", self.scientistAllocation, self.totalScientists)
    love.graphics.print(allocationText, self.uiOffsetX + self.uiWidth - 60, sliderY)

    -- Slider background
    local sliderX = self.uiOffsetX + 80
    local sliderWidth = ALLOCATION_SLIDER_WIDTH
    love.graphics.setColor(0.2, 0.2, 0.3, 0.8)
    love.graphics.rectangle("fill", sliderX, sliderY + 15, sliderWidth, 8)

    -- Slider fill
    local fillWidth = (self.scientistAllocation / self.totalScientists) * sliderWidth
    love.graphics.setColor(0.2, 0.8, 0.2, 0.9)
    love.graphics.rectangle("fill", sliderX, sliderY + 15, fillWidth, 8)

    -- Slider handle
    local handleX = sliderX + fillWidth - 4
    love.graphics.setColor(0.8, 0.8, 0.8, 1.0)
    love.graphics.rectangle("fill", handleX, sliderY + 12, 8, 14)
end

--- Draw available projects list
function ResearchQueueUI:drawAvailableProjects()
    local listStartY = self.uiOffsetY + 80
    local listHeight = PROJECT_HEIGHT * VISIBLE_PROJECTS

    -- Draw list background
    love.graphics.setColor(0.05, 0.05, 0.1, 0.8)
    love.graphics.rectangle("fill", self.uiOffsetX + 5, listStartY, self.uiWidth - 10 - SCROLLBAR_WIDTH, listHeight)

    -- Draw visible projects
    local filteredProjects = self:getFilteredProjects()
    local startIndex = math.floor(self.scrollOffset / PROJECT_HEIGHT) + 1
    local endIndex = math.min(startIndex + VISIBLE_PROJECTS - 1, #filteredProjects)

    for i = startIndex, endIndex do
        local project = filteredProjects[i]
        local itemY = listStartY + (i - startIndex) * PROJECT_HEIGHT
        self:drawProjectItem(project, self.uiOffsetX + 5, itemY, self.uiWidth - 10 - SCROLLBAR_WIDTH, PROJECT_HEIGHT)
    end
end

--- Draw a single project item
---@param project table Project data
---@param x number Item X position
---@param y number Item Y position
---@param width number Item width
---@param height number Item height
function ResearchQueueUI:drawProjectItem(project, x, y, width, height)
    local canQueue, reason = self:canQueueProject(project.id)
    local isSelected = self.selectedProject and self.selectedProject.id == project.id
    local isHovered = self:isItemHovered(x, y, width, height)

    -- Background color based on state
    if isSelected then
        love.graphics.setColor(0.3, 0.5, 0.7, 0.8)
    elseif not canQueue then
        love.graphics.setColor(0.2, 0.1, 0.1, 0.6)
    elseif isHovered then
        love.graphics.setColor(0.2, 0.2, 0.3, 0.7)
    else
        love.graphics.setColor(0.15, 0.15, 0.2, 0.6)
    end

    love.graphics.rectangle("fill", x, y, width, height)

    -- Border
    love.graphics.setColor(0.4, 0.4, 0.5, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)

    -- Project name
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print(project.name, x + 10, y + 5)

    -- Category indicator
    love.graphics.setFont(love.graphics.newFont(8))
    love.graphics.setColor(0.7, 0.8, 0.9)
    love.graphics.print("[" .. project.category:sub(1, 3):upper() .. "]", x + width - 40, y + 5)

    -- Days required
    love.graphics.setColor(0.9, 0.9, 0.2)
    love.graphics.print(project.daysRequired .. " days", x + 10, y + 20)

    -- Description (truncated)
    love.graphics.setColor(0.8, 0.8, 0.8)
    local desc = project.description
    if #desc > 30 then
        desc = desc:sub(1, 27) .. "..."
    end
    love.graphics.print(desc, x + 10, y + 35)

    -- Status indicator
    if project.completed then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.print("✓ COMPLETED", x + 10, y + 48)
    elseif not project.available then
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.print("LOCKED", x + 10, y + 48)
    elseif canQueue then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.print("AVAILABLE", x + 10, y + 48)
    else
        love.graphics.setColor(0.8, 0.6, 0.2)
        love.graphics.print(reason, x + 10, y + 48)
    end
end

--- Draw the research queue
function ResearchQueueUI:drawResearchQueue()
    local queueStartY = self.uiOffsetY + 80 + PROJECT_HEIGHT * VISIBLE_PROJECTS + 10

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Research Queue:", self.uiOffsetX + 10, queueStartY)

    if #self.researchQueue == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print("No projects in queue", self.uiOffsetX + 10, queueStartY + 15)
    else
        for i, project in ipairs(self.researchQueue) do
            local itemY = queueStartY + 15 + (i - 1) * 20
            self:drawQueueItem(project, self.uiOffsetX + 10, itemY, self.uiWidth - 20)
        end
    end
end

--- Draw a research queue item
---@param project table Queued project data
---@param x number Item X position
---@param y number Item Y position
---@param width number Item width
function ResearchQueueUI:drawQueueItem(project, x, y, width)
    -- Background
    love.graphics.setColor(0.2, 0.3, 0.4, 0.6)
    love.graphics.rectangle("fill", x, y, width, 16)

    -- Progress bar background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", x, y + 14, width, 4)

    -- Progress bar fill
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", x, y + 14, width * project.progress, 4)

    -- Text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(9))
    love.graphics.print(project.name, x + 5, y + 1)

    local progressText = string.format("%.1f%% (%d/%d sci)",
        project.progress * 100,
        project.allocatedScientists,
        project.daysRequired - project.daysCompleted)
    love.graphics.print(progressText, x + width - 100, y + 1)
end

--- Draw project details panel
function ResearchQueueUI:drawProjectDetails()
    if not self.selectedProject then return end

    local panelX = self.uiOffsetX - 220  -- Left of main panel
    local panelY = self.uiOffsetY
    local panelWidth = 200
    local panelHeight = 200

    -- Panel background
    love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)

    -- Panel border
    love.graphics.setColor(0.3, 0.3, 0.4, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight)

    -- Project details
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print(self.selectedProject.name, panelX + 10, panelY + 10)

    love.graphics.setFont(love.graphics.newFont(9))
    love.graphics.setColor(0.8, 0.8, 0.8)

    -- Description
    local descY = panelY + 30
    local words = {}
    for word in self.selectedProject.description:gmatch("%S+") do
        table.insert(words, word)
    end

    local line = ""
    local lineY = descY
    for _, word in ipairs(words) do
        local testLine = line .. (line == "" and "" or " ") .. word
        if love.graphics.getFont():getWidth(testLine) > panelWidth - 20 then
            love.graphics.print(line, panelX + 10, lineY)
            line = word
            lineY = lineY + 12
        else
            line = testLine
        end
    end
    if line ~= "" then
        love.graphics.print(line, panelX + 10, lineY)
    end

    -- Prerequisites
    if #self.selectedProject.prerequisites > 0 then
        love.graphics.setColor(0.9, 0.9, 0.2)
        love.graphics.print("Prerequisites:", panelX + 10, lineY + 20)
        love.graphics.setColor(0.8, 0.8, 0.8)
        for i, prereq in ipairs(self.selectedProject.prerequisites) do
            love.graphics.print("• " .. prereq:gsub("_", " "):gsub("^%l", string.upper), panelX + 20, lineY + 32 + (i-1) * 12)
        end
    end
end

--- Draw scrollbar for project list
function ResearchQueueUI:drawScrollbar()
    local scrollbarX = self.uiOffsetX + self.uiWidth - SCROLLBAR_WIDTH - 5
    local scrollbarY = self.uiOffsetY + 80
    local scrollbarHeight = PROJECT_HEIGHT * VISIBLE_PROJECTS

    -- Scrollbar background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", scrollbarX, scrollbarY, SCROLLBAR_WIDTH, scrollbarHeight)

    -- Scrollbar handle
    local filteredProjects = self:getFilteredProjects()
    local handleHeight = math.max(20, scrollbarHeight * (VISIBLE_PROJECTS / #filteredProjects))
    local handleY = scrollbarY + (self.scrollOffset / ((#filteredProjects - VISIBLE_PROJECTS) * PROJECT_HEIGHT)) * (scrollbarHeight - handleHeight)

    love.graphics.setColor(0.5, 0.5, 0.6, 0.8)
    love.graphics.rectangle("fill", scrollbarX, handleY, SCROLLBAR_WIDTH, handleHeight)
end

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

--- Update the UI state
---@param dt number Delta time
function ResearchQueueUI:update(dt)
    self:updateResearchProgress(dt)
end

--- Handle mouse press
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param button number Mouse button
function ResearchQueueUI:mousepressed(x, y, button)
    if button == 1 then  -- Left click
        -- Check category filter buttons
        local buttonY = self.uiOffsetY + 25
        local buttonWidth = 60
        local buttonSpacing = 5
        local categories = {"all", "weapons", "armor", "alien_tech", "facilities", "support"}

        for i, category in ipairs(categories) do
            local buttonX = self.uiOffsetX + 10 + (i - 1) * (buttonWidth + buttonSpacing)
            if self:isButtonHovered(buttonX, buttonY, buttonWidth, 20) then
                self.selectedCategory = category
                self.scrollOffset = 0  -- Reset scroll when changing categories
                return
            end
        end

        -- Check scientist allocation slider
        local sliderY = self.uiOffsetY + 50
        local sliderX = self.uiOffsetX + 80
        local sliderWidth = ALLOCATION_SLIDER_WIDTH
        if x >= sliderX and x <= sliderX + sliderWidth and y >= sliderY + 12 and y <= sliderY + 29 then
            local ratio = (x - sliderX) / sliderWidth
            local newAllocation = math.floor(ratio * self.totalScientists)
            self:setScientistAllocation(newAllocation)
            return
        end

        -- Check available projects list
        local listStartY = self.uiOffsetY + 80
        local listEndY = listStartY + PROJECT_HEIGHT * VISIBLE_PROJECTS

        if x >= self.uiOffsetX + 5 and x <= self.uiOffsetX + self.uiWidth - 5 - SCROLLBAR_WIDTH
           and y >= listStartY and y <= listEndY then

            local filteredProjects = self:getFilteredProjects()
            local itemIndex = math.floor((y - listStartY) / PROJECT_HEIGHT) + 1
            local actualIndex = math.floor(self.scrollOffset / PROJECT_HEIGHT) + itemIndex

            if actualIndex >= 1 and actualIndex <= #filteredProjects then
                local project = filteredProjects[actualIndex]
                self.selectedProject = project

                -- Double-click to queue
                if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    self:queueProject(project.id)
                end
            end
        end

        -- Check research queue for removal
        local queueStartY = self.uiOffsetY + 80 + PROJECT_HEIGHT * VISIBLE_PROJECTS + 10
        if x >= self.uiOffsetX + 10 and x <= self.uiOffsetX + self.uiWidth - 10
           and y >= queueStartY + 15 and y <= queueStartY + 15 + #self.researchQueue * 20 then

            local itemIndex = math.floor((y - (queueStartY + 15)) / 20) + 1
            if itemIndex >= 1 and itemIndex <= #self.researchQueue then
                if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    self:dequeueProject(itemIndex)
                end
            end
        end
    end
end

--- Handle mouse wheel for scrolling
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
function ResearchQueueUI:mousewheel(x, y)
    local filteredProjects = self:getFilteredProjects()
    if #filteredProjects > VISIBLE_PROJECTS then
        local maxScroll = math.max(0, (#filteredProjects - VISIBLE_PROJECTS) * PROJECT_HEIGHT)
        self.scrollOffset = math.max(0, math.min(maxScroll, self.scrollOffset - y * PROJECT_HEIGHT))
    end
end

--- Check if a button is hovered
---@param x number Button X position
---@param y number Button Y position
---@param width number Button width
---@param height number Button height
---@return boolean Whether the button is hovered
function ResearchQueueUI:isButtonHovered(x, y, width, height)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x + width and my >= y and my <= y + height
end

--- Check if an item is hovered
---@param x number Item X position
---@param y number Item Y position
---@param width number Item width
---@param height number Item height
---@return boolean Whether the item is hovered
function ResearchQueueUI:isItemHovered(x, y, width, height)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x + width and my >= y and my <= y + height
end

return ResearchQueueUI
