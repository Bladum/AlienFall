--- Manufacturing Service
-- Manages manufacturing queues, capacity allocation, and production across bases
--
-- @classmod economy.ManufacturingService

-- GROK: ManufacturingService manages production queues and resource allocation across all bases
-- GROK: Handles capacity planning, project queuing, and manufacturing completion
-- GROK: Key methods: startProject(), getAvailableCapacity(), updateProduction(), processQueue()
-- GROK: Integrates with base facilities, research unlocks, and resource management

local class = require 'lib.Middleclass'
local ManufacturingManager = require 'economy.ManufacturingManager'

--- ManufacturingService class
-- @type ManufacturingService
ManufacturingService = class('ManufacturingService')

--- Create a new ManufacturingService instance
-- @param registry Service registry for accessing other systems
-- @return ManufacturingService instance
function ManufacturingService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:eventBus() or nil

    -- Initialize manufacturing manager
    self.manager = ManufacturingManager:new({
        manufacturingEntries = {},
        activeProjects = {},
        projectQueue = {},
        baseCapacities = {},
        config = self:_getDefaultConfig()
    })

    -- Load manufacturing data
    self:_loadManufacturingData()

    -- Register with service registry
    if registry then
        registry:registerService('manufacturingService', self)
    end
end

--- Get default configuration for manufacturing
function ManufacturingService:_getDefaultConfig()
    return {
        baseCapacityMultiplier = 1.0,
        engineerEfficiency = 1.0,
        workshopEfficiency = 1.0,
        queueProcessingInterval = 24, -- hours
        maxQueuedProjects = 10
    }
end

--- Load manufacturing data from data registry
function ManufacturingService:_loadManufacturingData()
    local dataRegistry = self.registry and self.registry:resolve("data_registry")
    if not dataRegistry then
        if self.logger then
            self.logger:warn("Data registry not available for loading manufacturing data")
        end
        return
    end

    -- Load manufacturing entries from mod system
    local manufacturingData = dataRegistry:get("manufacturing_entry")
    if manufacturingData then
        self:_processManufacturingData({entries = manufacturingData})
    end
end

--- Process loaded manufacturing data
-- @param data The loaded TOML data
function ManufacturingService:_processManufacturingData(data)
    if data.entries then
        for _, entryData in ipairs(data.entries) do
            local entry = require('economy.ManufacturingEntry'):new(entryData)
            self.manager:addManufacturingEntry(entry)
        end
    end

    if data.base_capacities then
        self.manager.baseCapacities = data.base_capacities
    end
end

--- Get available manufacturing capacity for a base
-- @param baseId The base ID to check
-- @return table Capacity information {engineers, workshops}
function ManufacturingService:getAvailableCapacity(baseId)
    return self.manager:getAvailableCapacity(baseId)
end

--- Get all available manufacturing entries for a base
-- @param baseId The base ID to check
-- @return table Array of available ManufacturingEntry objects
function ManufacturingService:getAvailableEntries(baseId)
    return self.manager:getAvailableEntries(baseId)
end

--- Start a manufacturing project
-- @param entryId The manufacturing entry ID to start
-- @param baseId The base where manufacturing should happen
-- @param assignedEngineers Number of engineers to assign
-- @param assignedWorkshops Number of workshops to assign
-- @return boolean Success status
-- @return string Message describing result
function ManufacturingService:startProject(entryId, baseId, assignedEngineers, assignedWorkshops)
    local success, message = self.manager:startProject(entryId, baseId, assignedEngineers, assignedWorkshops)

    if success and self.eventBus then
        self.eventBus:emit('manufacturing:project_started', {
            entryId = entryId,
            baseId = baseId,
            assignedEngineers = assignedEngineers,
            assignedWorkshops = assignedWorkshops
        })
    end

    return success, message
end

--- Cancel a manufacturing project
-- @param projectId The project ID to cancel
-- @return boolean Success status
-- @return string Message describing result
function ManufacturingService:cancelProject(projectId)
    local success, message = self.manager:cancelProject(projectId)

    if success and self.eventBus then
        self.eventBus:emit('manufacturing:project_cancelled', {
            projectId = projectId
        })
    end

    return success, message
end

--- Get active manufacturing projects for a base
-- @param baseId The base ID to check
-- @return table Array of active ManufacturingProject objects
function ManufacturingService:getActiveProjects(baseId)
    local activeProjects = {}

    for _, project in ipairs(self.manager.activeProjects) do
        if project.baseId == baseId then
            table.insert(activeProjects, project)
        end
    end

    return activeProjects
end

--- Get queued manufacturing projects for a base
-- @param baseId The base ID to check
-- @return table Array of queued project data
function ManufacturingService:getQueuedProjects(baseId)
    local queuedProjects = {}

    for _, queued in ipairs(self.manager.projectQueue) do
        if queued.baseId == baseId then
            table.insert(queuedProjects, queued)
        end
    end

    return queuedProjects
end

--- Update manufacturing progress (called each game hour)
-- @param deltaTime Time elapsed in game hours (default 1)
-- @return number: Number of projects completed
function ManufacturingService:updateProduction(deltaTime)
    deltaTime = deltaTime or 1
    local completedCount = 0
    
    -- Update active projects
    for _, project in ipairs(self.manager.activeProjects) do
        project:updateProgress(deltaTime)

        if project:isComplete() then
            self:_completeProject(project)
            completedCount = completedCount + 1
        end
    end

    -- Process queued projects
    self.manager:processQueuedProjects()
    
    return completedCount
end

--- Complete a manufacturing project
-- @param project The completed ManufacturingProject
function ManufacturingService:_completeProject(project)
    -- Remove from active projects
    for i, activeProject in ipairs(self.manager.activeProjects) do
        if activeProject == project then
            table.remove(self.manager.activeProjects, i)
            break
        end
    end

    -- Process completion effects
    local results = project:getCompletionResults()

    -- Emit completion event
    if self.eventBus then
        self.eventBus:emit('manufacturing:project_completed', {
            projectId = project.id,
            entryId = project.entry.id,
            baseId = project.baseId,
            results = results
        })
    end
end

--- Get manufacturing statistics for a base
-- @param baseId The base ID to check
-- @return table Statistics including capacity usage, active projects, etc.
function ManufacturingService:getBaseStats(baseId)
    local capacity = self:getAvailableCapacity(baseId)
    local activeProjects = self:getActiveProjects(baseId)
    local queuedProjects = self:getQueuedProjects(baseId)

    return {
        capacity = capacity,
        activeProjects = #activeProjects,
        queuedProjects = #queuedProjects,
        totalProjects = #activeProjects + #queuedProjects
    }
end

--- Check if a manufacturing entry is available at a base
-- @param entryId The entry ID to check
-- @param baseId The base ID to check
-- @return boolean Whether the entry is available
function ManufacturingService:isEntryAvailable(entryId, baseId)
    local entries = self:getAvailableEntries(baseId)

    for _, entry in ipairs(entries) do
        if entry.id == entryId then
            return true
        end
    end

    return false
end

--- Get manufacturing state summary
-- @return table: Manufacturing state
function ManufacturingService:getState()
    local activeCount = #self.manager.activeProjects
    local queuedCount = #self.manager.projectQueue
    
    -- Calculate total capacity across all bases
    local totalCapacity = 0
    for _, capacity in pairs(self.manager.baseCapacities) do
        totalCapacity = totalCapacity + capacity
    end
    
    return {
        active = activeCount,
        queued = queuedCount,
        capacity = totalCapacity
    }
end

return ManufacturingService
