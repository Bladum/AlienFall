---ManufacturingManager - Per-base manufacturing management
---
---Manages manufacturing for a specific base:
---  - Active manufacturing projects
---  - Workshop capacity tracking
---  - Daily progression
---  - Engineer allocation
---
---@module basescape.logic.manufacturing_manager
---@author AlienFall Development Team

local ManufacturingEntry = require("basescape.logic.manufacturing_entry")
local ManufacturingProject = require("basescape.logic.manufacturing_project")
local ManufacturingRegistry = require("basescape.logic.manufacturing_registry")

local ManufacturingManager = {}

---Create a new manufacturing manager for a base
---@param baseId string Base ID
---@param workshopCapacity number Initial workshop capacity
---@return table manager Manager instance
function ManufacturingManager.new(baseId, workshopCapacity)
    return {
        baseId = baseId,
        activeProjects = {},  -- Map: project_id -> ManufacturingProject
        projectsArray = {},   -- Array for ordered access
        workshopCapacity = workshopCapacity or 10,
        usedCapacity = 0,
        totalEngineers = 0,
        availableEngineers = 0,
    }
end

---Start manufacturing project
---@param manager table The manager
---@param entryId string Manufacturing entry ID
---@param quantity number Items to manufacture
---@param enginesAssigned number Engineers to assign
---@return table? project The project or nil if failed
---@return string? error Error message if failed
function ManufacturingManager.startProject(manager, entryId, quantity, enginesAssigned)
    local entry = ManufacturingRegistry.getEntry(entryId)
    if not entry then
        return nil, "Unknown manufacturing entry: " .. entryId
    end
    
    -- Check if workshop has capacity
    if manager.usedCapacity + 1 > manager.workshopCapacity then
        return nil, "No workshop capacity available"
    end
    
    -- Create project
    local manDays = ManufacturingEntry.getRandomizedManDays(entry)
    local project = ManufacturingProject.new({
        baseId = manager.baseId,
        entryId = entryId,
        quantityTotal = quantity or 1,
        manDaysRequired = manDays,
        engineersAssigned = enginesAssigned or 0,
    })
    
    manager.activeProjects[project.id] = project
    table.insert(manager.projectsArray, project.id)
    manager.usedCapacity = manager.usedCapacity + 1
    
    print(string.format("[ManufacturingManager] Started %s (%s x%d, %d man-days per unit)", 
        entryId, manager.baseId, quantity, manDays))
    
    return project, nil
end

---Allocate engineers to a project
---@param manager table The manager
---@param projectId string Project ID
---@param count number Engineers to assign
---@return boolean success True if assigned
function ManufacturingManager.allocateEngineers(manager, projectId, count)
    local project = manager.activeProjects[projectId]
    if not project then
        return false
    end
    
    ManufacturingProject.assignEngineers(project, count)
    return true
end

---Update all active projects daily
---@param manager table The manager
---@param daysElapsed number Days to advance (default 1)
function ManufacturingManager.updateAllProjects(manager, daysElapsed)
    daysElapsed = daysElapsed or 1
    local completed = {}
    
    for i, projectId in ipairs(manager.projectsArray) do
        local project = manager.activeProjects[projectId]
        if project then
            local isDone = ManufacturingProject.update(project, daysElapsed)
            
            if isDone then
                print(string.format("[ManufacturingManager] Completed: %s", project.entryId))
                table.insert(completed, i)
            end
        end
    end
    
    -- Remove completed from array (in reverse)
    for i = #completed, 1, -1 do
        local projectId = manager.projectsArray[completed[i]]
        manager.activeProjects[projectId] = nil
        table.remove(manager.projectsArray, completed[i])
        manager.usedCapacity = manager.usedCapacity - 1
    end
end

---Get active projects
---@param manager table The manager
---@return table projectIds Array of active project IDs
function ManufacturingManager.getActiveProjects(manager)
    return manager.projectsArray
end

---Allocate available engineers (simple algorithm)
---@param manager table The manager
---@param engineerCount number Total engineers available
function ManufacturingManager.autoAllocateEngineers(manager, engineerCount)
    if #manager.projectsArray == 0 then
        return
    end
    
    local perProject = math.floor(engineerCount / #manager.projectsArray)
    
    for _, projectId in ipairs(manager.projectsArray) do
        local project = manager.activeProjects[projectId]
        if project then
            ManufacturingProject.assignEngineers(project, perProject)
        end
    end
    
    print(string.format("[ManufacturingManager] Allocated %d engineers to %d projects", 
        engineerCount, #manager.projectsArray))
end

---Print active manufacturing
---@param manager table The manager
function ManufacturingManager.printActiveManufacturing(manager)
    print(string.format("\n[ManufacturingManager] Active Manufacturing (%s)", manager.baseId))
    print("====================================")
    print(string.format("  Workshop Capacity: %d/%d", manager.usedCapacity, manager.workshopCapacity))
    
    for _, projectId in ipairs(manager.projectsArray) do
        local project = manager.activeProjects[projectId]
        if project then
            print("  " .. ManufacturingProject.getInfo(project))
        end
    end
    
    print("====================================\n")
end

return ManufacturingManager
