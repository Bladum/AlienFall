--- ManufacturingProject.lua
-- Manufacturing project system for Alien Fall
-- Tracks workshop production with engineer assignment and progress

-- GROK: ManufacturingProject manages active manufacturing projects with resource allocation
-- GROK: Handles engineer assignment, progress tracking, and completion detection
-- GROK: Key methods: assignEngineers(), updateProgress(), calculateCompletionTime(), completeProject()
-- GROK: Integrates with ManufacturingEntry for project definition and ManufacturingManager for coordination

local class = require 'lib.Middleclass'

ManufacturingProject = class('ManufacturingProject')

-- Project status constants
ManufacturingProject.STATUS_NOT_STARTED = "not_started"
ManufacturingProject.STATUS_ACTIVE = "active"
ManufacturingProject.STATUS_PAUSED = "paused"
ManufacturingProject.STATUS_COMPLETED = "completed"
ManufacturingProject.STATUS_CANCELLED = "cancelled"

--- Initialize a new manufacturing project
-- @param manufacturingEntry The ManufacturingEntry this project is based on
-- @param data Additional project data
function ManufacturingProject:initialize(manufacturingEntry, data)
    -- Core manufacturing data
    self.manufacturingEntry = manufacturingEntry
    self.id = manufacturingEntry.id
    self.name = manufacturingEntry.name

    -- Project status
    self.status = data.status or ManufacturingProject.STATUS_NOT_STARTED

    -- Resource allocation
    self.assignedEngineers = data.assignedEngineers or 0
    self.assignedWorkshops = data.assignedWorkshops or 0
    self.baseId = data.baseId  -- Which base this manufacturing is happening at

    -- Timing and progress
    self.startTime = data.startTime
    self.pauseTime = data.pauseTime
    self.completionTime = data.completionTime
    self.progress = data.progress or 0  -- 0-100 percentage
    self.manHoursCompleted = data.manHoursCompleted or 0
    self.estimatedCompletionTime = data.estimatedCompletionTime

    -- Cost tracking
    self.costPaid = data.costPaid or 0
    self.costRemaining = manufacturingEntry:getBaseCost() - (data.costPaid or 0)

    -- Milestone tracking
    self.completedMilestones = data.completedMilestones or {}  -- Set of completed milestone percentages

    -- Modifiers
    self.modifiers = data.modifiers or {}

    -- Event integration
    self.eventBus = self:_getEventBus()

    -- Validate data
    self:_validate()
end

--- Get the event bus for integration
function ManufacturingProject:_getEventBus()
    local registry = require 'services.registry'
    return registry:getService('eventBus')
end

--- Validate the manufacturing project data
function ManufacturingProject:_validate()
    assert(self.manufacturingEntry, "Manufacturing project must have a manufacturing entry")
    assert(self.id, "Manufacturing project must have an id")
    assert(self.name, "Manufacturing project must have a name")

    -- Validate status
    local validStatuses = {
        [ManufacturingProject.STATUS_NOT_STARTED] = true,
        [ManufacturingProject.STATUS_ACTIVE] = true,
        [ManufacturingProject.STATUS_PAUSED] = true,
        [ManufacturingProject.STATUS_COMPLETED] = true,
        [ManufacturingProject.STATUS_CANCELLED] = true
    }
    assert(validStatuses[self.status], "Invalid project status: " .. tostring(self.status))

    -- Validate resource allocation
    assert(type(self.assignedEngineers) == "number" and self.assignedEngineers >= 0,
           "Assigned engineers must be a non-negative number")
    assert(type(self.assignedWorkshops) == "number" and self.assignedWorkshops >= 0,
           "Assigned workshops must be a non-negative number")
end

--- Start this manufacturing project
-- @param assignedEngineers Number of engineers to assign
-- @param assignedWorkshops Number of workshops to assign
-- @param baseId The base where manufacturing is happening
function ManufacturingProject:startProject(assignedEngineers, assignedWorkshops, baseId)
    if self.status ~= ManufacturingProject.STATUS_NOT_STARTED then
        return false, "Project is not in a startable state"
    end

    self.assignedEngineers = assignedEngineers or 1
    self.assignedWorkshops = assignedWorkshops or 1
    self.baseId = baseId
    self.startTime = self:_getCurrentTime()
    self.status = ManufacturingProject.STATUS_ACTIVE

    -- Calculate estimated completion time
    self.estimatedCompletionTime = self:calculateCompletionTime()

    -- Reserve inputs
    self.manufacturingEntry:reserveInputs(baseId, {})

    -- Emit project started event
    self:_emitProjectStartedEvent()

    return true
end

--- Pause this manufacturing project
function ManufacturingProject:pauseProject()
    if self.status ~= ManufacturingProject.STATUS_ACTIVE then
        return false, "Project is not active"
    end

    self.status = ManufacturingProject.STATUS_PAUSED
    self.pauseTime = self:_getCurrentTime()

    -- Emit project paused event
    self:_emitProjectPausedEvent()

    return true
end

--- Resume this manufacturing project
function ManufacturingProject:resumeProject()
    if self.status ~= ManufacturingProject.STATUS_PAUSED then
        return false, "Project is not paused"
    end

    self.status = ManufacturingProject.STATUS_ACTIVE

    -- Adjust start time to account for pause duration
    if self.pauseTime then
        local pauseDuration = self:_getCurrentTime() - self.pauseTime
        self.startTime = self.startTime + pauseDuration
        self.pauseTime = nil
    end

    -- Recalculate estimated completion time
    self.estimatedCompletionTime = self:calculateCompletionTime()

    -- Emit project resumed event
    self:_emitProjectResumedEvent()

    return true
end

--- Cancel this manufacturing project
function ManufacturingProject:cancelProject()
    if self.status == ManufacturingProject.STATUS_COMPLETED or self.status == ManufacturingProject.STATUS_CANCELLED then
        return false, "Project cannot be cancelled"
    end

    self.status = ManufacturingProject.STATUS_CANCELLED

    -- Release reserved inputs
    self.manufacturingEntry:releaseInputs(self.baseId, {})

    -- Emit project cancelled event
    self:_emitProjectCancelledEvent()

    return true
end

--- Update project progress
-- @param currentTime Current time (optional, uses system time if not provided)
-- @return boolean True if project is ready for completion
function ManufacturingProject:updateProgress(currentTime)
    if self.status ~= ManufacturingProject.STATUS_ACTIVE then
        return false
    end

    currentTime = currentTime or self:_getCurrentTime()

    -- Calculate man-hours completed today
    local manHoursToday = self:calculateDailyCapacity()
    self.manHoursCompleted = self.manHoursCompleted + manHoursToday

    -- Update progress percentage
    local totalManHours = self.manufacturingEntry:getManHours()
    local oldProgress = self.progress
    self.progress = math.min(100, math.floor((self.manHoursCompleted / totalManHours) * 100))

    -- Check for milestone completions
    self:_checkMilestones(oldProgress, self.progress)

    -- Check if completed
    if self.manHoursCompleted >= totalManHours then
        return true  -- Ready for completion
    end

    return false  -- Not ready for completion
end

--- Check for milestone completions and produce outputs
-- @param oldProgress Previous progress percentage
-- @param newProgress Current progress percentage
function ManufacturingProject:_checkMilestones(oldProgress, newProgress)
    local milestones = self.manufacturingEntry:getMilestones()

    for _, milestone in ipairs(milestones) do
        local milestonePercent = milestone.percentage

        -- Check if we crossed this milestone threshold
        if oldProgress < milestonePercent and newProgress >= milestonePercent then
            -- Milestone reached, produce outputs
            if not self.completedMilestones[milestonePercent] then
                self:_produceMilestoneOutputs(milestone)
                self.completedMilestones[milestonePercent] = true

                -- Emit milestone reached event
                self:_emitMilestoneReachedEvent(milestone)
            end
        end
    end
end

--- Produce outputs for a completed milestone
-- @param milestone The milestone that was reached
function ManufacturingProject:_produceMilestoneOutputs(milestone)
    for _, output in ipairs(milestone.outputs) do
        self:_addItem(output.id, output.type, output.quantity, self.baseId, {})
    end
end

--- Complete this manufacturing project
function ManufacturingProject:completeProject(overflowPolicy)
    if self.status ~= ManufacturingProject.STATUS_ACTIVE then
        return false
    end

    self.status = ManufacturingProject.STATUS_COMPLETED
    self.completionTime = self:_getCurrentTime()
    self.progress = 100

    -- Add outputs to inventory with overflow handling
    local success = self.manufacturingEntry:addOutputs(self.baseId, {}, overflowPolicy or "fail")
    if not success and overflowPolicy == "fail" then
        -- If overflow policy is fail and we couldn't add outputs, pause the project
        self.status = ManufacturingProject.STATUS_PAUSED
        return false
    end

    -- Emit project completed event
    self:_emitProjectCompletedEvent()

    return true
end

--- Reassign engineers to this project
-- @param newEngineerCount New number of engineers
function ManufacturingProject:reassignEngineers(newEngineerCount)
    if self.status ~= ManufacturingProject.STATUS_ACTIVE then
        return false, "Can only reassign engineers to active projects"
    end

    local oldCount = self.assignedEngineers
    self.assignedEngineers = newEngineerCount

    -- Recalculate estimated completion time
    self.estimatedCompletionTime = self:calculateCompletionTime()

    -- Emit reassignment event
    self:_emitEngineerReassignmentEvent(oldCount, newEngineerCount)

    return true
end

--- Reassign workshops to this project
-- @param newWorkshopCount New number of workshops
function ManufacturingProject:reassignWorkshops(newWorkshopCount)
    if self.status ~= ManufacturingProject.STATUS_ACTIVE then
        return false, "Can only reassign workshops to active projects"
    end

    local oldCount = self.assignedWorkshops
    self.assignedWorkshops = newWorkshopCount

    -- Recalculate estimated completion time
    self.estimatedCompletionTime = self:calculateCompletionTime()

    -- Emit reassignment event
    self:_emitWorkshopReassignmentEvent(oldCount, newWorkshopCount)

    return true
end

--- Calculate the estimated completion time
function ManufacturingProject:calculateCompletionTime()
    if self.status ~= ManufacturingProject.STATUS_ACTIVE then
        return nil
    end

    local remainingManHours = self.manufacturingEntry:getManHours() - self.manHoursCompleted
    local dailyCapacity = self:calculateDailyCapacity()

    if dailyCapacity <= 0 then
        return nil  -- Cannot complete
    end

    local daysRemaining = remainingManHours / dailyCapacity
    return self.startTime + daysRemaining
end

--- Calculate daily manufacturing capacity
function ManufacturingProject:calculateDailyCapacity()
    if self.assignedEngineers <= 0 then return 0 end

    -- Base capacity: engineers * hours per day
    local hoursPerDay = 8  -- Standard work day
    local baseCapacity = self.assignedEngineers * hoursPerDay

    -- Workshop efficiency bonus (diminishing returns)
    local workshopEfficiency = math.min(self.assignedWorkshops, 3) * 0.8 + 0.4
    local capacity = baseCapacity * workshopEfficiency

    -- Apply modifiers
    if self.modifiers.capacityMultiplier then
        capacity = capacity * self.modifiers.capacityMultiplier
    end

    return capacity
end

--- Get the remaining time to completion
function ManufacturingProject:getRemainingTime()
    if self.status ~= ManufacturingProject.STATUS_ACTIVE then
        return nil
    end

    local currentTime = self:_getCurrentTime()
    if self.estimatedCompletionTime then
        return math.max(0, self.estimatedCompletionTime - currentTime)
    end

    return nil
end

--- Get the daily progress rate
function ManufacturingProject:getDailyProgressRate()
    local totalManHours = self.manufacturingEntry:getManHours()
    local dailyCapacity = self:calculateDailyCapacity()

    if totalManHours <= 0 then return 0 end

    return (dailyCapacity / totalManHours) * 100
end

--- Check if the project can be started (resources available)
-- @param availableEngineers Total available engineers
-- @param availableWorkshops Total available workshops
function ManufacturingProject:canStartProject(availableEngineers, availableWorkshops)
    return self.assignedEngineers <= availableEngineers and
           self.assignedWorkshops <= availableWorkshops and
           self.status == ManufacturingProject.STATUS_NOT_STARTED and
           self.manufacturingEntry:hasRequiredInputs(self.baseId, {})
end

--- Get project status summary
function ManufacturingProject:getStatusSummary()
    return {
        id = self.id,
        name = self.name,
        status = self.status,
        progress = self.progress,
        assignedEngineers = self.assignedEngineers,
        assignedWorkshops = self.assignedWorkshops,
        baseId = self.baseId,
        startTime = self.startTime,
        estimatedCompletionTime = self.estimatedCompletionTime,
        remainingTime = self:getRemainingTime(),
        dailyProgressRate = self:getDailyProgressRate(),
        manHoursCompleted = self.manHoursCompleted,
        totalManHours = self.manufacturingEntry:getManHours()
    }
end

--- Get current time (days elapsed)
function ManufacturingProject:_getCurrentTime()
    local timeSystem = self:_getTimeSystem()
    return timeSystem and timeSystem:getDaysElapsed() or 0
end

--- Get the time system
function ManufacturingProject:_getTimeSystem()
    local registry = require 'services.registry'
    return registry:getService('timeSystem')
end

--- Emit project started event
function ManufacturingProject:_emitProjectStartedEvent()
    if self.eventBus then
        self.eventBus:emit("manufacturing_project:started", {
            projectId = self.id,
            projectName = self.name,
            assignedEngineers = self.assignedEngineers,
            assignedWorkshops = self.assignedWorkshops,
            baseId = self.baseId,
            estimatedCompletionTime = self.estimatedCompletionTime
        })
    end
end

--- Emit project paused event
function ManufacturingProject:_emitProjectPausedEvent()
    if self.eventBus then
        self.eventBus:emit("manufacturing_project:paused", {
            projectId = self.id,
            projectName = self.name,
            progress = self.progress
        })
    end
end

--- Emit project resumed event
function ManufacturingProject:_emitProjectResumedEvent()
    if self.eventBus then
        self.eventBus:emit("manufacturing_project:resumed", {
            projectId = self.id,
            projectName = self.name,
            estimatedCompletionTime = self.estimatedCompletionTime
        })
    end
end

--- Emit project completed event
function ManufacturingProject:_emitProjectCompletedEvent()
    if self.eventBus then
        self.eventBus:emit("manufacturing_project:completed", {
            projectId = self.id,
            projectName = self.name,
            completionTime = self.completionTime,
            baseId = self.baseId,
            outputs = self.manufacturingEntry:getOutputs()
        })
    end
end

--- Emit project cancelled event
function ManufacturingProject:_emitProjectCancelledEvent()
    if self.eventBus then
        self.eventBus:emit("manufacturing_project:cancelled", {
            projectId = self.id,
            projectName = self.name,
            progress = self.progress
        })
    end
end

--- Emit engineer reassignment event
function ManufacturingProject:_emitEngineerReassignmentEvent(oldCount, newCount)
    if self.eventBus then
        self.eventBus:emit("manufacturing_project:engineers_reassigned", {
            projectId = self.id,
            projectName = self.name,
            oldCount = oldCount,
            newCount = newCount,
            estimatedCompletionTime = self.estimatedCompletionTime
        })
    end
end

--- Emit workshop reassignment event
function ManufacturingProject:_emitWorkshopReassignmentEvent(oldCount, newCount)
    if self.eventBus then
        self.eventBus:emit("manufacturing_project:workshops_reassigned", {
            projectId = self.id,
            projectName = self.name,
            oldCount = oldCount,
            newCount = newCount,
            estimatedCompletionTime = self.estimatedCompletionTime
        })
    end
end

--- Check if project is active
function ManufacturingProject:isActive()
    return self.status == ManufacturingProject.STATUS_ACTIVE
end

--- Check if project is completed
function ManufacturingProject:isCompleted()
    return self.status == ManufacturingProject.STATUS_COMPLETED
end

--- Check if project is paused
function ManufacturingProject:isPaused()
    return self.status == ManufacturingProject.STATUS_PAUSED
end

--- Check if project is cancelled
function ManufacturingProject:isCancelled()
    return self.status == ManufacturingProject.STATUS_CANCELLED
end

--- Get assigned engineers
function ManufacturingProject:getAssignedEngineers()
    return self.assignedEngineers
end

--- Get assigned workshops
function ManufacturingProject:getAssignedWorkshops()
    return self.assignedWorkshops
end

--- Get base ID
function ManufacturingProject:getBaseId()
    return self.baseId
end

--- Get progress percentage
function ManufacturingProject:getProgress()
    return self.progress
end

--- Get man-hours completed
function ManufacturingProject:getManHoursCompleted()
    return self.manHoursCompleted
end

--- Get total man-hours required
function ManufacturingProject:getTotalManHours()
    return self.manufacturingEntry:getManHours()
end

--- Add an item to inventory (helper method)
function ManufacturingProject:_addItem(itemId, itemType, quantity, baseId, gameState)
    -- This would integrate with the inventory system
    if gameState.inventory and gameState.inventory[baseId] then
        local baseInventory = gameState.inventory[baseId]
        if not baseInventory[itemType] then baseInventory[itemType] = {} end
        baseInventory[itemType][itemId] = (baseInventory[itemType][itemId] or 0) + quantity
    end
end

--- Emit milestone reached event
function ManufacturingProject:_emitMilestoneReachedEvent(milestone)
    if self.eventBus then
        self.eventBus:emit("manufacturing_project:milestone_reached", {
            projectId = self.id,
            projectName = self.name,
            milestonePercentage = milestone.percentage,
            outputs = milestone.outputs,
            baseId = self.baseId,
            currentProgress = self.progress
        })
    end
end

return ManufacturingProject
