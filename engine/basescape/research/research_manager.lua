---ResearchManager - Global research management system
---
---Manages all research:
---  - Tech tree validation and unlocks
---  - Global research pool (shared across bases)
---  - Active research projects
---  - Daily progression
---  - Scientist pool management
---
---@module basescape.research.research_manager
---@author AlienFall Development Team

local ResearchEntry = require("basescape.research.research_entry")
local ResearchProject = require("basescape.research.research_project")
local TechTree = require("geoscape.logic.tech_tree")

local ResearchManager = {}

-- Singleton instance
ResearchManager.instance = nil

---Initialize the research manager
---@return table manager Manager instance
function ResearchManager.initialize()
    if ResearchManager.instance then
        return ResearchManager.instance
    end
    
    local manager = {
        techTree = TechTree.new(),
        activeProjects = {},  -- Map: project_id -> ResearchProject
        projectsArray = {},   -- Array for ordered access
        totalScientists = 0,
        availableScientists = 0,
    }
    
    -- Load default research entries
    ResearchManager._loadDefaultResearch(manager)
    
    ResearchManager.instance = manager
    print("[ResearchManager] Initialized")
    return manager
end

---Load default research entries
---@param manager table The manager
function ResearchManager._loadDefaultResearch(manager)
    local entries = {
        -- Basic Research
        {
            id = "basic_research",
            name = "Basic Research",
            description = "Foundation for all research",
            baselineManDays = 50,
            type = "technology",
            category = "foundation",
            unlocksResearch = {"alien_materials", "alien_biology"},
        },
        
        -- Alien Materials
        {
            id = "alien_materials",
            name = "Alien Materials",
            description = "Analyze alien alloys",
            baselineManDays = 100,
            dependsOn = {"basic_research"},
            category = "materials",
            unlocksResearch = {"plasma_weapons", "advanced_armor"},
        },
        
        -- Alien Biology
        {
            id = "alien_biology",
            name = "Alien Biology",
            description = "Study alien lifeforms",
            baselineManDays = 120,
            dependsOn = {"basic_research"},
            category = "biology",
            unlocksResearch = {"interrogation_techniques", "alien_genetics"},
        },
        
        -- Plasma Weapons
        {
            id = "plasma_weapons",
            name = "Plasma Weapons",
            description = "Harness alien energy weapons",
            baselineManDays = 150,
            dependsOn = {"alien_materials"},
            category = "weapons",
            unlocksManufacturing = {"plasma_rifle", "plasma_cannon"},
        },
        
        -- Advanced Armor
        {
            id = "advanced_armor",
            name = "Advanced Armor",
            description = "Alien armor technology",
            baselineManDays = 130,
            dependsOn = {"alien_materials"},
            category = "armor",
            unlocksManufacturing = {"plasma_armor", "combat_suit"},
        },
        
        -- Interrogation Techniques
        {
            id = "interrogation_techniques",
            name = "Interrogation Techniques",
            description = "Extract information from prisoners",
            baselineManDays = 80,
            dependsOn = {"alien_biology"},
            category = "tactics",
            unlocksResearch = {"alien_weaknesses"},
        },
        
        -- Alien Genetics
        {
            id = "alien_genetics",
            name = "Alien Genetics",
            description = "Understand alien DNA",
            baselineManDays = 180,
            dependsOn = {"alien_biology"},
            category = "biology",
            unlocksResearch = {"genetic_modification", "hybrid_soldiers"},
        },
        
        -- Alien Weaknesses
        {
            id = "alien_weaknesses",
            name = "Alien Weaknesses",
            description = "Exploit alien vulnerabilities",
            baselineManDays = 100,
            dependsOn = {"interrogation_techniques"},
            category = "tactics",
        },
        
        -- Genetic Modification
        {
            id = "genetic_modification",
            name = "Genetic Modification",
            description = "Modify genetic material",
            baselineManDays = 200,
            dependsOn = {"alien_genetics"},
            category = "biology",
            unlocksManufacturing = {"superhuman_soldier"},
        },
        
        -- Hybrid Soldiers
        {
            id = "hybrid_soldiers",
            name = "Hybrid Soldiers",
            description = "Create hybrid soldiers",
            baselineManDays = 250,
            dependsOn = {"alien_genetics"},
            category = "biology",
            unlocksManufacturing = {"hybrid_warrior"},
        },
    }
    
    for _, data in ipairs(entries) do
        local entry = ResearchEntry.new(data)
        TechTree.addEntry(manager.techTree, entry)
    end
    
    print("[ResearchManager] Loaded " .. #entries .. " research entries")
end

---Get singleton instance
---@return table manager The manager instance
function ResearchManager.getInstance()
    if not ResearchManager.instance then
        error("[ResearchManager] Not initialized! Call initialize() first")
    end
    return ResearchManager.instance
end

---Start a new research project
---@param researchId string Research entry ID
---@param scientistsAssigned number Scientists to assign (default 0)
---@return table? project The research project or nil if failed
---@return string? error Error message if failed
function ResearchManager.startResearch(researchId, scientistsAssigned)
    local manager = ResearchManager.getInstance()
    
    local entry = manager.techTree.entries[researchId]
    if not entry then
        return nil, "Unknown research: " .. researchId
    end
    
    -- Check if already completed
    if TechTree.isCompleted(manager.techTree, researchId) then
        return nil, "Research already completed: " .. researchId
    end
    
    -- Check prerequisites
    for _, depId in ipairs(entry.dependsOn) do
        if not TechTree.isCompleted(manager.techTree, depId) then
            return nil, "Missing prerequisite: " .. depId
        end
    end
    
    -- Create project
    local manDays = ResearchEntry.getRandomizedManDays(entry)
    local project = ResearchProject.new({
        entryId = researchId,
        manDaysRequired = manDays,
        scientistsAssigned = scientistsAssigned or 0,
    })
    
    manager.activeProjects[project.id] = project
    table.insert(manager.projectsArray, project.id)
    
    print(string.format("[ResearchManager] Started research: %s (%d man-days)", researchId, manDays))
    
    return project, nil
end

---Allocate scientists to a project
---@param projectId string Project ID
---@param count number Scientists to assign
---@return boolean success True if assigned
function ResearchManager.allocateScientists(projectId, count)
    local manager = ResearchManager.getInstance()
    
    local project = manager.activeProjects[projectId]
    if not project then
        return false
    end
    
    ResearchProject.assignScientists(project, count)
    return true
end

---Update all active research daily
---@param daysElapsed number Days to advance (default 1)
function ResearchManager.updateAllResearch(daysElapsed)
    local manager = ResearchManager.getInstance()
    
    daysElapsed = daysElapsed or 1
    local completed = {}
    
    -- Update all active projects
    for i, projectId in ipairs(manager.projectsArray) do
        local project = manager.activeProjects[projectId]
        if project then
            local isDone = ResearchProject.update(project, daysElapsed)
            
            if isDone then
                -- Mark research as completed in tech tree
                local unlocked = TechTree.completeResearch(manager.techTree, project.entryId)
                
                print(string.format("[ResearchManager] Completed: %s", project.entryId))
                
                -- Print unlocked research
                if #unlocked > 0 then
                    print("[ResearchManager] Unlocked: " .. table.concat(unlocked, ", "))
                end
                
                table.insert(completed, i)
            end
        end
    end
    
    -- Remove completed from array (in reverse)
    for i = #completed, 1, -1 do
        table.remove(manager.projectsArray, completed[i])
    end
end

---Get available research options
---@return table availableIds Array of research IDs that can be started
function ResearchManager.getAvailableResearch()
    local manager = ResearchManager.getInstance()
    return TechTree.getAvailable(manager.techTree)
end

---Get active research projects
---@return table projectIds Array of active project IDs
function ResearchManager.getActiveProjects()
    local manager = ResearchManager.getInstance()
    return manager.projectsArray
end

---Allocate available scientists (simple algorithm)
---@param scientistCount number Total scientists available
function ResearchManager.autoAllocateScientists(scientistCount)
    local manager = ResearchManager.getInstance()
    
    if #manager.projectsArray == 0 then
        return
    end
    
    local perProject = math.floor(scientistCount / #manager.projectsArray)
    
    for _, projectId in ipairs(manager.projectsArray) do
        local project = manager.activeProjects[projectId]
        if project then
            ResearchProject.assignScientists(project, perProject)
        end
    end
    
    print(string.format("[ResearchManager] Allocated %d scientists to %d projects", 
        scientistCount, #manager.projectsArray))
end

---Print all active research
function ResearchManager.printActiveResearch()
    local manager = ResearchManager.getInstance()
    
    print("\n[ResearchManager] Active Research")
    print("====================================")
    
    for _, projectId in ipairs(manager.projectsArray) do
        local project = manager.activeProjects[projectId]
        if project then
            print("  " .. ResearchProject.getInfo(project))
        end
    end
    
    print("====================================\n")
end

return ResearchManager




