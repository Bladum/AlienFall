--- ResearchProject.lua
-- Research project system for Alien Fall
-- Tracks ongoing research with scientist assignment and progress

-- GROK: ResearchProject manages active research projects with resource allocation
-- GROK: Handles scientist assignment, progress tracking, and completion detection
-- GROK: Key methods: assignScientists(), updateProgress(), calculateCompletionTime(), completeProject()
-- GROK: Integrates with ResearchEntry for project definition and ResearchTree for dependencies

local class = require 'lib.Middleclass'

ResearchProject = class('ResearchProject')

-- Project status constants
ResearchProject.STATUS_NOT_STARTED = "not_started"
ResearchProject.STATUS_ACTIVE = "active"
ResearchProject.STATUS_PAUSED = "paused"
ResearchProject.STATUS_COMPLETED = "completed"
ResearchProject.STATUS_CANCELLED = "cancelled"

--- Initialize a new research project
-- @param researchEntry The ResearchEntry this project is based on
-- @param data Additional project data
function ResearchProject:initialize(researchEntry, data)
    -- Core research data
    self.researchEntry = researchEntry
    self.id = researchEntry.id
    self.name = researchEntry.name

    -- Project status
    self.status = data.status or ResearchProject.STATUS_NOT_STARTED

    -- Resource allocation
    self.assignedScientists = data.assignedScientists or 0
    self.assignedLabs = data.assignedLabs or 0
    self.baseId = data.baseId  -- Which base this research is happening at

    -- Timing and progress
    self.startTime = data.startTime
    self.pauseTime = data.pauseTime
    self.completionTime = data.completionTime
    self.progress = data.progress or 0  -- 0-100 percentage
    self.estimatedCompletionTime = data.estimatedCompletionTime

    -- Cost tracking
    self.costPaid = data.costPaid or 0
    self.costRemaining = researchEntry:getCost() - (data.costPaid or 0)

    -- Modifiers
    self.modifiers = data.modifiers or {}

    -- Event integration
    self.eventBus = self:_getEventBus()

    -- Validate data
    self:_validate()
end

--- Get the event bus for integration
function ResearchProject:_getEventBus()
    local registry = require 'services.registry'
    return registry:getService('eventBus')
end

--- Validate the research project data
function ResearchProject:_validate()
    assert(self.researchEntry, "Research project must have a research entry")
    assert(self.id, "Research project must have an id")
    assert(self.name, "Research project must have a name")

    -- Validate status
    local validStatuses = {
        [ResearchProject.STATUS_NOT_STARTED] = true,
        [ResearchProject.STATUS_ACTIVE] = true,
        [ResearchProject.STATUS_PAUSED] = true,
        [ResearchProject.STATUS_COMPLETED] = true,
        [ResearchProject.STATUS_CANCELLED] = true
    }
    assert(validStatuses[self.status], "Invalid project status: " .. tostring(self.status))

    -- Validate resource allocation
    assert(type(self.assignedScientists) == "number" and self.assignedScientists >= 0,
           "Assigned scientists must be a non-negative number")
    assert(type(self.assignedLabs) == "number" and self.assignedLabs >= 0,
           "Assigned labs must be a non-negative number")
end

--- Start this research project
-- @param assignedScientists Number of scientists to assign
-- @param assignedLabs Number of labs to assign
-- @param baseId The base where research is happening
function ResearchProject:startProject(assignedScientists, assignedLabs, baseId)
    if self.status ~= ResearchProject.STATUS_NOT_STARTED then
        return false, "Project is not in a startable state"
    end

    self.assignedScientists = assignedScientists or 1
    self.assignedLabs = assignedLabs or 1
    self.baseId = baseId
    self.startTime = self:_getCurrentTime()
    self.status = ResearchProject.STATUS_ACTIVE

    -- Calculate estimated completion time
    self.estimatedCompletionTime = self:calculateCompletionTime()

    -- Start the research entry
    self.researchEntry:startResearch(self.startTime)

    -- Emit project started event
    self:_emitProjectStartedEvent()

    return true
end

--- Pause this research project
function ResearchProject:pauseProject()
    if self.status ~= ResearchProject.STATUS_ACTIVE then
        return false, "Project is not active"
    end

    self.status = ResearchProject.STATUS_PAUSED
    self.pauseTime = self:_getCurrentTime()

    -- Emit project paused event
    self:_emitProjectPausedEvent()

    return true
end

--- Resume this research project
function ResearchProject:resumeProject()
    if self.status ~= ResearchProject.STATUS_PAUSED then
        return false, "Project is not paused"
    end

    self.status = ResearchProject.STATUS_ACTIVE

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

--- Cancel this research project
function ResearchProject:cancelProject()
    if self.status == ResearchProject.STATUS_COMPLETED or self.status == ResearchProject.STATUS_CANCELLED then
        return false, "Project cannot be cancelled"
    end

    self.status = ResearchProject.STATUS_CANCELLED

    -- Cancel the research entry
    self.researchEntry:cancelResearch()

    -- Emit project cancelled event
    self:_emitProjectCancelledEvent()

    return true
end

--- Update project progress
-- @param currentTime Current time (optional, uses system time if not provided)
function ResearchProject:updateProgress(currentTime)
    if self.status ~= ResearchProject.STATUS_ACTIVE then
        return
    end

    currentTime = currentTime or self:_getCurrentTime()

    -- Update the research entry progress
    self.researchEntry:updateProgress(currentTime, self.assignedScientists, self.assignedLabs)

    -- Update our progress
    self.progress = self.researchEntry.progress

    -- Check if completed
    if self.researchEntry:isResearchCompleted() then
        self:completeProject()
    end
end

--- Complete this research project
function ResearchProject:completeProject()
    if self.status ~= ResearchProject.STATUS_ACTIVE then
        return false
    end

    self.status = ResearchProject.STATUS_COMPLETED
    self.completionTime = self:_getCurrentTime()
    self.progress = 100

    -- The research entry completion is handled by the entry itself

    -- Emit project completed event
    self:_emitProjectCompletedEvent()

    return true
end

--- Reassign scientists to this project
-- @param newScientistCount New number of scientists
function ResearchProject:reassignScientists(newScientistCount)
    if self.status ~= ResearchProject.STATUS_ACTIVE then
        return false, "Can only reassign scientists to active projects"
    end

    local oldCount = self.assignedScientists
    self.assignedScientists = newScientistCount

    -- Recalculate estimated completion time
    self.estimatedCompletionTime = self:calculateCompletionTime()

    -- Emit reassignment event
    self:_emitScientistReassignmentEvent(oldCount, newScientistCount)

    return true
end

--- Reassign labs to this project
-- @param newLabCount New number of labs
function ResearchProject:reassignLabs(newLabCount)
    if self.status ~= ResearchProject.STATUS_ACTIVE then
        return false, "Can only reassign labs to active projects"
    end

    local oldCount = self.assignedLabs
    self.assignedLabs = newLabCount

    -- Recalculate estimated completion time
    self.estimatedCompletionTime = self:calculateCompletionTime()

    -- Emit reassignment event
    self:_emitLabReassignmentEvent(oldCount, newLabCount)

    return true
end

--- Calculate the estimated completion time
function ResearchProject:calculateCompletionTime()
    if self.status ~= ResearchProject.STATUS_ACTIVE then
        return nil
    end

    local timeToComplete = self.researchEntry:calculateTime(
        self.assignedScientists,
        self.assignedLabs,
        self.modifiers
    )

    -- Adjust for current progress
    local remainingProgress = 1 - (self.progress / 100)
    local adjustedTime = timeToComplete * remainingProgress

    return self.startTime + adjustedTime
end

--- Get the remaining time to completion
function ResearchProject:getRemainingTime()
    if self.status ~= ResearchProject.STATUS_ACTIVE then
        return nil
    end

    local currentTime = self:_getCurrentTime()
    if self.estimatedCompletionTime then
        return math.max(0, self.estimatedCompletionTime - currentTime)
    end

    return nil
end

--- Get the daily progress rate
function ResearchProject:getDailyProgressRate()
    if self.assignedScientists <= 0 then return 0 end

    -- Simplified calculation: progress per day based on scientists and labs
    local labEfficiency = math.min(self.assignedLabs, 3) * 0.8 + 0.4
    local researchRate = self.assignedScientists * labEfficiency

    -- Convert to daily progress percentage
    local totalCost = self.researchEntry:getCost()
    local progressPerDay = (researchRate / totalCost) * 100

    return progressPerDay
end

--- Check if the project can be started (resources available)
-- @param availableScientists Total available scientists
-- @param availableLabs Total available labs
function ResearchProject:canStartProject(availableScientists, availableLabs)
    return self.assignedScientists <= availableScientists and
           self.assignedLabs <= availableLabs and
           self.status == ResearchProject.STATUS_NOT_STARTED
end

--- Get project status summary
function ResearchProject:getStatusSummary()
    return {
        id = self.id,
        name = self.name,
        status = self.status,
        progress = self.progress,
        assignedScientists = self.assignedScientists,
        assignedLabs = self.assignedLabs,
        baseId = self.baseId,
        startTime = self.startTime,
        estimatedCompletionTime = self.estimatedCompletionTime,
        remainingTime = self:getRemainingTime(),
        dailyProgressRate = self:getDailyProgressRate()
    }
end

--- Get current time (days elapsed)
function ResearchProject:_getCurrentTime()
    local timeSystem = self:_getTimeSystem()
    return timeSystem and timeSystem:getDaysElapsed() or 0
end

--- Get the time system
function ResearchProject:_getTimeSystem()
    local registry = require 'services.registry'
    return registry:getService('timeSystem')
end

--- Emit project started event
function ResearchProject:_emitProjectStartedEvent()
    if self.eventBus then
        self.eventBus:emit("research_project:started", {
            projectId = self.id,
            projectName = self.name,
            assignedScientists = self.assignedScientists,
            assignedLabs = self.assignedLabs,
            baseId = self.baseId,
            estimatedCompletionTime = self.estimatedCompletionTime
        })
    end
end

--- Emit project paused event
function ResearchProject:_emitProjectPausedEvent()
    if self.eventBus then
        self.eventBus:emit("research_project:paused", {
            projectId = self.id,
            projectName = self.name,
            progress = self.progress
        })
    end
end

--- Emit project resumed event
function ResearchProject:_emitProjectResumedEvent()
    if self.eventBus then
        self.eventBus:emit("research_project:resumed", {
            projectId = self.id,
            projectName = self.name,
            estimatedCompletionTime = self.estimatedCompletionTime
        })
    end
end

--- Emit project completed event
function ResearchProject:_emitProjectCompletedEvent()
    if self.eventBus then
        self.eventBus:emit("research_project:completed", {
            projectId = self.id,
            projectName = self.name,
            completionTime = self.completionTime,
            baseId = self.baseId
        })
    end
end

--- Emit project cancelled event
function ResearchProject:_emitProjectCancelledEvent()
    if self.eventBus then
        self.eventBus:emit("research_project:cancelled", {
            projectId = self.id,
            projectName = self.name,
            progress = self.progress
        })
    end
end

--- Emit scientist reassignment event
function ResearchProject:_emitScientistReassignmentEvent(oldCount, newCount)
    if self.eventBus then
        self.eventBus:emit("research_project:scientists_reassigned", {
            projectId = self.id,
            projectName = self.name,
            oldCount = oldCount,
            newCount = newCount,
            estimatedCompletionTime = self.estimatedCompletionTime
        })
    end
end

--- Emit lab reassignment event
function ResearchProject:_emitLabReassignmentEvent(oldCount, newCount)
    if self.eventBus then
        self.eventBus:emit("research_project:labs_reassigned", {
            projectId = self.id,
            projectName = self.name,
            oldCount = oldCount,
            newCount = newCount,
            estimatedCompletionTime = self.estimatedCompletionTime
        })
    end
end

--- Check if project is active
function ResearchProject:isActive()
    return self.status == ResearchProject.STATUS_ACTIVE
end

--- Check if project is completed
function ResearchProject:isCompleted()
    return self.status == ResearchProject.STATUS_COMPLETED
end

--- Check if project is paused
function ResearchProject:isPaused()
    return self.status == ResearchProject.STATUS_PAUSED
end

--- Check if project is cancelled
function ResearchProject:isCancelled()
    return self.status == ResearchProject.STATUS_CANCELLED
end

--- Get assigned scientists
function ResearchProject:getAssignedScientists()
    return self.assignedScientists
end

--- Get assigned labs
function ResearchProject:getAssignedLabs()
    return self.assignedLabs
end

--- Get base ID
function ResearchProject:getBaseId()
    return self.baseId
end

--- Get progress percentage
function ResearchProject:getProgress()
    return self.progress
end

return ResearchProject
