---Research System
---
---Manages research projects, technology tree, prerequisites, and unlocks. Handles
---scientist allocation, laboratory capacity, research progress, and technology
---dependencies. Core system for campaign progression and equipment unlocks.
---
---Research Features:
---  - Tech tree with dependencies
---  - Multiple research projects in queue
---  - Scientist allocation to projects
---  - Laboratory capacity limits
---  - Research categories (weapons, armor, aircraft, aliens, misc)
---  - Technology unlocks (manufacturing, equipment, abilities)
---
---Research Status:
---  - LOCKED: Prerequisites not met
---  - AVAILABLE: Can be started
---  - IN_PROGRESS: Currently researching
---  - COMPLETE: Technology unlocked
---
---Key Exports:
---  - ResearchSystem.new(): Creates research system instance
---  - startResearch(projectId, scientists): Begins research project
---  - updateProgress(hours): Advances research by time
---  - completeResearch(projectId): Finishes and unlocks technology
---  - isAvailable(projectId): Checks if project can be started
---  - getAvailableProjects(): Returns researchable projects
---
---Dependencies:
---  - basescape.facilities: Laboratory buildings
---  - shared.units.units: Scientist management
---  - economy.production: Manufacturing unlocks
---
---@module economy.research.research_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ResearchSystem = require("basescape.research.research_system")
---  local research = ResearchSystem.new()
---  research:startResearch("laser_weapons", 5)  -- 5 scientists
---  research:updateProgress(24)  -- Advance 24 hours
---
---@see economy.production For manufacturing system
---@see scenes.basescape_screen For base management

local ResearchSystem = {}
ResearchSystem.__index = ResearchSystem

--- Research project status
ResearchSystem.STATUS = {
    LOCKED = "locked",         -- Prerequisites not met
    AVAILABLE = "available",   -- Can be researched
    IN_PROGRESS = "in_progress", -- Currently being researched
    COMPLETE = "complete"      -- Research finished
}

--- Research categories
ResearchSystem.CATEGORIES = {
    WEAPONS = "weapons",
    ARMOR = "armor",
    AIRCRAFT = "aircraft",
    FACILITIES = "facilities",
    ALIENS = "aliens",
    PSIONICS = "psionics"
}

--- Create new research system
-- @return table New ResearchSystem instance
function ResearchSystem.new()
    local self = setmetatable({}, ResearchSystem)
    
    self.projects = {}           -- All research projects
    self.activeProjects = {}     -- Currently researching
    self.completedProjects = {}  -- Finished research
    self.unlockedItems = {}      -- Items unlocked by research
    self.scientists = 0          -- Available scientists
    
    print("[ResearchSystem] Initialized research system")
    
    return self
end

--- Define a research project
-- @param projectId string Unique project identifier
-- @param definition table Project definition
function ResearchSystem:defineProject(projectId, definition)
    self.projects[projectId] = {
        id = projectId,
        name = definition.name or projectId,
        description = definition.description or "",
        category = definition.category or ResearchSystem.CATEGORIES.WEAPONS,
        cost = definition.cost or 100,               -- Research points needed
        prerequisites = definition.prerequisites or {}, -- Required projects
        unlocks = definition.unlocks or {},          -- Items/facilities unlocked
        status = ResearchSystem.STATUS.LOCKED,
        progress = 0
    }
    
    print(string.format("[ResearchSystem] Defined project '%s' (cost: %d)", 
          definition.name, definition.cost))
end

--- Start research project
-- @param projectId string Project to research
-- @param scientists number Number of scientists assigned
-- @return boolean True if started successfully
function ResearchSystem:startResearch(projectId, scientists)
    local project = self.projects[projectId]
    
    if not project then
        print("[ResearchSystem] ERROR: Project not found: " .. projectId)
        return false
    end
    
    -- Check prerequisites
    if not self:checkPrerequisites(projectId) then
        print("[ResearchSystem] ERROR: Prerequisites not met for " .. project.name)
        return false
    end
    
    -- Check if already researching
    for _, active in ipairs(self.activeProjects) do
        if active.id == projectId then
            print("[ResearchSystem] ERROR: Already researching " .. project.name)
            return false
        end
    end
    
    -- Start research
    project.status = ResearchSystem.STATUS.IN_PROGRESS
    project.scientists = scientists
    project.progress = 0
    
    table.insert(self.activeProjects, project)
    
    print(string.format("[ResearchSystem] Started research '%s' with %d scientists",
          project.name, scientists))
    
    return true
end

--- Check if project prerequisites are met
-- @param projectId string Project to check
-- @return boolean True if prerequisites met
function ResearchSystem:checkPrerequisites(projectId)
    local project = self.projects[projectId]
    
    if not project or not project.prerequisites then
        return true
    end
    
    for _, prereqId in ipairs(project.prerequisites) do
        if not self.completedProjects[prereqId] then
            return false
        end
    end
    
    return true
end

--- Process daily research progress
-- @param scientists number Available scientists in labs
function ResearchSystem:processDailyProgress(scientists)
    if #self.activeProjects == 0 then
        return
    end
    
    print(string.format("[ResearchSystem] Processing research with %d scientists", scientists))
    
    for i = #self.activeProjects, 1, -1 do
        local project = self.activeProjects[i]
        
        -- Calculate progress (1 point per scientist per day)
        local dailyProgress = project.scientists or 1
        project.progress = project.progress + dailyProgress
        
        print(string.format("[ResearchSystem] '%s' progress: %d/%d (+%d)",
              project.name, project.progress, project.cost, dailyProgress))
        
        -- Check for completion
        if project.progress >= project.cost then
            self:completeResearch(projectId)
            table.remove(self.activeProjects, i)
        end
    end
end

--- Complete research project and apply unlocks
-- @param projectId string Project that was completed
function ResearchSystem:completeResearch(projectId)
    local project = self.projects[projectId]
    
    if not project then
        return
    end
    
    project.status = ResearchSystem.STATUS.COMPLETE
    self.completedProjects[projectId] = true
    
    -- Apply unlocks
    if project.unlocks then
        for _, unlock in ipairs(project.unlocks) do
            self.unlockedItems[unlock] = true
            print(string.format("[ResearchSystem] Unlocked: %s", unlock))
        end
    end
    
    -- Update other projects that are now available
    self:updateProjectAvailability()
    
    print(string.format("[ResearchSystem] RESEARCH COMPLETE: %s", project.name))
end

--- Update availability status of all projects
function ResearchSystem:updateProjectAvailability()
    for projectId, project in pairs(self.projects) do
        if project.status == ResearchSystem.STATUS.LOCKED then
            if self:checkPrerequisites(projectId) then
                project.status = ResearchSystem.STATUS.AVAILABLE
                print(string.format("[ResearchSystem] Project now available: %s", project.name))
            end
        end
    end
end

--- Check if item/facility is unlocked
-- @param itemId string Item or facility identifier
-- @return boolean True if unlocked
function ResearchSystem:isUnlocked(itemId)
    return self.unlockedItems[itemId] == true
end

--- Get available research projects
-- @return table Array of available projects
function ResearchSystem:getAvailableProjects()
    local available = {}
    
    for projectId, project in pairs(self.projects) do
        if project.status == ResearchSystem.STATUS.AVAILABLE then
            table.insert(available, project)
        end
    end
    
    return available
end

--- Get currently researching projects
-- @return table Array of active projects
function ResearchSystem:getActiveProjects()
    return self.activeProjects
end

--- Get completed research projects
-- @return table Array of completed project IDs
function ResearchSystem:getCompletedProjects()
    local completed = {}
    
    for projectId, _ in pairs(self.completedProjects) do
        local project = self.projects[projectId]
        if project then
            table.insert(completed, project)
        end
    end
    
    return completed
end

--- Cancel active research project
-- @param projectId string Project to cancel
-- @return boolean True if cancelled
function ResearchSystem:cancelResearch(projectId)
    for i, project in ipairs(self.activeProjects) do
        if project.id == projectId then
            project.status = ResearchSystem.STATUS.AVAILABLE
            project.progress = 0
            table.remove(self.activeProjects, i)
            
            print(string.format("[ResearchSystem] Cancelled research: %s", project.name))
            return true
        end
    end
    
    return false
end

--- Get research progress percentage
-- @param projectId string Project identifier
-- @return number Progress percentage (0-100)
function ResearchSystem:getProgress(projectId)
    local project = self.projects[projectId]
    
    if not project or project.progress == 0 then
        return 0
    end
    
    return math.floor((project.progress / project.cost) * 100)
end

--- Initialize default research projects
function ResearchSystem:initializeDefaultProjects()
    -- Basic weapons research
    self:defineProject("laser_weapons", {
        name = "Laser Weapons",
        description = "Develop laser-based weaponry",
        category = ResearchSystem.CATEGORIES.WEAPONS,
        cost = 200,
        prerequisites = {},
        unlocks = {"laser_pistol", "laser_rifle"}
    })
    
    self:defineProject("plasma_weapons", {
        name = "Plasma Weapons",
        description = "Research plasma technology",
        category = ResearchSystem.CATEGORIES.WEAPONS,
        cost = 400,
        prerequisites = {"laser_weapons"},
        unlocks = {"plasma_pistol", "plasma_rifle"}
    })
    
    -- Armor research
    self:defineProject("advanced_armor", {
        name = "Advanced Armor",
        description = "Develop improved protective armor",
        category = ResearchSystem.CATEGORIES.ARMOR,
        cost = 300,
        prerequisites = {},
        unlocks = {"medium_armour", "heavy_armour"}
    })
    
    -- Psionics research
    self:defineProject("psionics_basics", {
        name = "Psionics Basics",
        description = "Study psionic phenomena",
        category = ResearchSystem.CATEGORIES.PSIONICS,
        cost = 250,
        prerequisites = {},
        unlocks = {"psi_amp_basic"}
    })
    
    self:defineProject("advanced_psionics", {
        name = "Advanced Psionics",
        description = "Master advanced psionic techniques",
        category = ResearchSystem.CATEGORIES.PSIONICS,
        cost = 500,
        prerequisites = {"psionics_basics"},
        unlocks = {"psi_amp_advanced"}
    })
    
    -- Set initial availability
    self:updateProjectAvailability()
    
    print("[ResearchSystem] Initialized 5 default research projects")
end

return ResearchSystem

























