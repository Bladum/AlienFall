--- ManufacturingManager.lua
-- Manufacturing manager system for Alien Fall
-- Coordinates all manufacturing projects and resource allocation

-- GROK: ManufacturingManager coordinates manufacturing projects across bases
-- GROK: Manages project queues, resource allocation, and capacity planning
-- GROK: Key methods: startProject(), allocateResources(), updateProjects(), getCapacity()
-- GROK: Integrates with ManufacturingEntry and ManufacturingProject for production management

local class = require 'lib.Middleclass'

ManufacturingManager = class('ManufacturingManager')

--- Initialize a new manufacturing manager
-- @param data The manufacturing manager configuration
function ManufacturingManager:initialize(data)
    -- Manufacturing entries and projects
    self.manufacturingEntries = data.manufacturingEntries or {}  -- Array of ManufacturingEntry objects
    self.activeProjects = data.activeProjects or {}  -- Array of ManufacturingProject objects
    self.projectQueue = data.projectQueue or {}  -- Queued projects waiting for resources

    -- Base-specific data
    self.baseCapacities = data.baseCapacities or {}  -- baseId -> {engineers, workshops}

    -- Global settings
    self.config = data.config or self:_getDefaultConfig()

    -- Overflow handling policies
    self.overflowPolicies = data.overflowPolicies or self:_getDefaultOverflowPolicies()

    -- Event integration
    self.eventBus = self:_getEventBus()

    -- Validate data
    self:_validate()
end

--- Get the event bus for integration
function ManufacturingManager:_getEventBus()
    local registry = require 'services.registry'
    return registry:getService('eventBus')
end

--- Validate the manufacturing manager data
function ManufacturingManager:_validate()
    -- Validate manufacturing entries
    for i, entry in ipairs(self.manufacturingEntries) do
        assert(entry.id, "Manufacturing entry " .. i .. " must have an id")
        assert(entry.name, "Manufacturing entry " .. i .. " must have a name")
    end

    -- Validate active projects
    for i, project in ipairs(self.activeProjects) do
        assert(project.id, "Active project " .. i .. " must have an id")
        assert(project.baseId, "Active project " .. i .. " must have a baseId")
    end
end

--- Add a manufacturing entry to the system
-- @param entry The ManufacturingEntry to add
function ManufacturingManager:addManufacturingEntry(entry)
    table.insert(self.manufacturingEntries, entry)

    -- Emit entry added event
    if self.eventBus then
        self.eventBus:emit("manufacturing:entry_added", {
            entryId = entry.id,
            entryName = entry.name,
            category = entry:getCategory()
        })
    end
end

--- Get all available manufacturing entries
-- @param baseId The base ID to check availability for
function ManufacturingManager:getAvailableEntries(baseId)
    local available = {}

    for _, entry in ipairs(self.manufacturingEntries) do
        if entry:isEntryUnlocked() and entry:meetsRequirements({}) then
            table.insert(available, entry)
        end
    end

    return available
end

--- Start a manufacturing project
-- @param entryId The manufacturing entry ID to start
-- @param baseId The base where manufacturing should happen
-- @param assignedEngineers Number of engineers to assign
-- @param assignedWorkshops Number of workshops to assign
function ManufacturingManager:startProject(entryId, baseId, assignedEngineers, assignedWorkshops)
    local entry = self:_getManufacturingEntry(entryId)
    if not entry then
        return false, "Manufacturing entry not found"
    end

    -- Check if entry is available
    if not entry:isEntryUnlocked() or not entry:meetsRequirements({}) then
        return false, "Manufacturing entry not available"
    end

    -- Check if base has required inputs
    if not entry:hasRequiredInputs(baseId, {}) then
        return false, "Insufficient inputs at base"
    end

    -- Check available capacity
    local availableCapacity = self:getAvailableCapacity(baseId)
    if assignedEngineers > availableCapacity.engineers or assignedWorkshops > availableCapacity.workshops then
        -- Queue the project if resources not available
        self:_queueProject(entryId, baseId, assignedEngineers, assignedWorkshops)
        return true, "Project queued - insufficient capacity"
    end

    -- Create and start the project
    local projectData = {
        status = "not_started",
        assignedEngineers = assignedEngineers,
        assignedWorkshops = assignedWorkshops,
        baseId = baseId
    }

    local project = require 'economy.ManufacturingProject'(entry, projectData)
    local success, errorMsg = project:startProject(assignedEngineers, assignedWorkshops, baseId)

    if success then
        table.insert(self.activeProjects, project)
        return true, "Project started successfully"
    else
        return false, errorMsg
    end
end

--- Queue a project for when resources become available
-- @param entryId The manufacturing entry ID
-- @param baseId The base ID
-- @param assignedEngineers Number of engineers
-- @param assignedWorkshops Number of workshops
function ManufacturingManager:_queueProject(entryId, baseId, assignedEngineers, assignedWorkshops)
    local queuedProject = {
        entryId = entryId,
        baseId = baseId,
        assignedEngineers = assignedEngineers,
        assignedWorkshops = assignedWorkshops,
        queuedTime = self:_getCurrentTime()
    }

    table.insert(self.projectQueue, queuedProject)

    -- Emit project queued event
    if self.eventBus then
        self.eventBus:emit("manufacturing:project_queued", {
            entryId = entryId,
            baseId = baseId,
            assignedEngineers = assignedEngineers,
            assignedWorkshops = assignedWorkshops
        })
    end
end

--- Process queued projects when resources become available
function ManufacturingManager:processQueuedProjects()
    local processed = 0

    for i = #self.projectQueue, 1, -1 do
        local queued = self.projectQueue[i]
        local availableCapacity = self:getAvailableCapacity(queued.baseId)

        if queued.assignedEngineers <= availableCapacity.engineers and
           queued.assignedWorkshops <= availableCapacity.workshops then

            -- Try to start the project
            local success, message = self:startProject(
                queued.entryId,
                queued.baseId,
                queued.assignedEngineers,
                queued.assignedWorkshops
            )

            if success then
                table.remove(self.projectQueue, i)
                processed = processed + 1
            end
        end
    end

    return processed
end

--- Cancel a manufacturing project
-- @param projectId The project ID to cancel
function ManufacturingManager:cancelProject(projectId)
    for i, project in ipairs(self.activeProjects) do
        if project.id == projectId then
            local success = project:cancelProject()
            if success then
                table.remove(self.activeProjects, i)
                return true, "Project cancelled"
            else
                return false, "Failed to cancel project"
            end
        end
    end

    return false, "Project not found"
end

--- Pause a manufacturing project
-- @param projectId The project ID to pause
function ManufacturingManager:pauseProject(projectId)
    local project = self:_getActiveProject(projectId)
    if project then
        return project:pauseProject()
    end
    return false
end

--- Resume a manufacturing project
-- @param projectId The project ID to resume
function ManufacturingManager:resumeProject(projectId)
    local project = self:_getActiveProject(projectId)
    if project then
        return project:resumeProject()
    end
    return false
end

--- Reassign resources to a project
-- @param projectId The project ID
-- @param engineers New number of engineers
-- @param workshops New number of workshops
function ManufacturingManager:reassignResources(projectId, engineers, workshops)
    local project = self:_getActiveProject(projectId)
    if not project then
        return false, "Project not found"
    end

    -- Check if new allocation is within available capacity
    local availableCapacity = self:getAvailableCapacity(project.baseId)
    local currentAllocation = self:_getCurrentAllocation(project.baseId)

    -- Calculate available after removing current project
    local availableEngineers = availableCapacity.engineers + project:getAssignedEngineers()
    local availableWorkshops = availableCapacity.workshops + project:getAssignedWorkshops()

    if engineers > availableEngineers or workshops > availableWorkshops then
        return false, "Insufficient capacity for reassignment"
    end

    -- Reassign resources
    local engineerSuccess = project:reassignEngineers(engineers)
    local workshopSuccess = project:reassignWorkshops(workshops)

    return engineerSuccess and workshopSuccess, "Resources reassigned"
end

--- Update all active projects (called daily)
function ManufacturingManager:updateProjects()
    for i = #self.activeProjects, 1, -1 do
        local project = self.activeProjects[i]
        local readyForCompletion = project:updateProgress()

        -- Handle project completion with overflow policy
        if readyForCompletion then
            local overflowPolicy = self.overflowPolicies.storageFull or "fail"
            local success = project:completeProject(overflowPolicy)

            if success then
                table.remove(self.activeProjects, i)
            else
                -- Completion failed due to overflow policy - keep in active list for retry
                -- Could implement retry logic or different handling here
            end
        elseif project:isCancelled() then
            table.remove(self.activeProjects, i)
        end
    end

    -- Process queued projects
    self:processQueuedProjects()
end

--- Get available manufacturing capacity for a base
-- @param baseId The base ID to check
function ManufacturingManager:getAvailableCapacity(baseId)
    local totalCapacity = self:getTotalCapacity(baseId)
    local currentAllocation = self:_getCurrentAllocation(baseId)

    return {
        engineers = math.max(0, totalCapacity.engineers - currentAllocation.engineers),
        workshops = math.max(0, totalCapacity.workshops - currentAllocation.workshops)
    }
end

--- Get total manufacturing capacity for a base
-- @param baseId The base ID to check
function ManufacturingManager:getTotalCapacity(baseId)
    local capacity = self.baseCapacities[baseId] or { engineers = 0, workshops = 0 }

    -- This would integrate with base management system
    -- For now, return configured capacity
    return capacity
end

--- Set manufacturing capacity for a base
-- @param baseId The base ID
-- @param engineers Number of engineers
-- @param workshops Number of workshops
function ManufacturingManager:setBaseCapacity(baseId, engineers, workshops)
    self.baseCapacities[baseId] = {
        engineers = engineers,
        workshops = workshops
    }
end

--- Get current resource allocation for a base
-- @param baseId The base ID
function ManufacturingManager:_getCurrentAllocation(baseId)
    local allocation = { engineers = 0, workshops = 0 }

    for _, project in ipairs(self.activeProjects) do
        if project.baseId == baseId then
            allocation.engineers = allocation.engineers + project:getAssignedEngineers()
            allocation.workshops = allocation.workshops + project:getAssignedWorkshops()
        end
    end

    return allocation
end

--- Get all active projects for a base
-- @param baseId The base ID
function ManufacturingManager:getActiveProjects(baseId)
    local projects = {}

    for _, project in ipairs(self.activeProjects) do
        if project.baseId == baseId then
            table.insert(projects, project)
        end
    end

    return projects
end

--- Get queued projects for a base
-- @param baseId The base ID
function ManufacturingManager:getQueuedProjects(baseId)
    local queued = {}

    for _, project in ipairs(self.projectQueue) do
        if project.baseId == baseId then
            table.insert(queued, project)
        end
    end

    return queued
end

--- Get a manufacturing entry by ID
-- @param entryId The entry ID to find
function ManufacturingManager:_getManufacturingEntry(entryId)
    for _, entry in ipairs(self.manufacturingEntries) do
        if entry.id == entryId then
            return entry
        end
    end
    return nil
end

--- Get an active project by ID
-- @param projectId The project ID to find
function ManufacturingManager:_getActiveProject(projectId)
    for _, project in ipairs(self.activeProjects) do
        if project.id == projectId then
            return project
        end
    end
    return nil
end

--- Get current time (days elapsed)
function ManufacturingManager:_getCurrentTime()
    local timeSystem = self:_getTimeSystem()
    return timeSystem and timeSystem:getDaysElapsed() or 0
end

--- Get the time system
function ManufacturingManager:_getTimeSystem()
    local registry = require 'services.registry'
    return registry:getService('timeSystem')
end

--- Get manufacturing status summary
function ManufacturingManager:getStatusSummary()
    local summary = {
        totalEntries = #self.manufacturingEntries,
        activeProjects = #self.activeProjects,
        queuedProjects = #self.projectQueue,
        baseCapacities = {}
    }

    -- Summarize base capacities
    for baseId, capacity in pairs(self.baseCapacities) do
        local available = self:getAvailableCapacity(baseId)
        summary.baseCapacities[baseId] = {
            total = capacity,
            available = available,
            used = {
                engineers = capacity.engineers - available.engineers,
                workshops = capacity.workshops - available.workshops
            }
        }
    end

    return summary
end

--- Get production statistics
function ManufacturingManager:getProductionStats()
    local stats = {
        totalProjectsCompleted = 0,
        totalManHoursUsed = 0,
        averageProjectTime = 0,
        projectsByCategory = {},
        productionByBase = {}
    }

    -- This would track historical data
    -- For now, return basic stats
    for _, project in ipairs(self.activeProjects) do
        local category = project.manufacturingEntry:getCategory()
        stats.projectsByCategory[category] = (stats.projectsByCategory[category] or 0) + 1

        local baseId = project:getBaseId()
        stats.productionByBase[baseId] = (stats.productionByBase[baseId] or 0) + 1
    end

    return stats
end

--- Unlock a manufacturing entry
-- @param entryId The entry ID to unlock
function ManufacturingManager:unlockManufacturingEntry(entryId)
    local entry = self:_getManufacturingEntry(entryId)
    if entry then
        entry:unlockEntry()
        return true
    end
    return false
end

--- Check if a manufacturing entry is available
-- @param entryId The entry ID to check
-- @param baseId The base ID
function ManufacturingManager:isEntryAvailable(entryId, baseId)
    local entry = self:_getManufacturingEntry(entryId)
    if not entry then return false end

    return entry:isEntryUnlocked() and
           entry:meetsRequirements({}) and
           entry:hasRequiredInputs(baseId, {})
end

--- Get default configuration
function ManufacturingManager:_getDefaultConfig()
    return {
        baseCapacityMultiplier = 1.0,
        engineerEfficiency = 1.0,
        workshopEfficiency = 1.0,
        maxQueuedProjects = 10
    }
end

--- Get default overflow policies
function ManufacturingManager:_getDefaultOverflowPolicies()
    return {
        storageFull = "queue",  -- Options: "fail", "queue", "auto_sell", "auto_transfer"
        transferUnavailable = "fail"
    }
end

return ManufacturingManager
