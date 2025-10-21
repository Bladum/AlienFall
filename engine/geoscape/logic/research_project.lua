---ResearchProject - Active research instance
---
---Represents an active research project with:
---  - Progress tracking (man-days completed)
---  - Scientist allocation
---  - Completion detection and unlocking
---  - Pause/resume functionality
---
---@module geoscape.logic.research_project
---@author AlienFall Development Team

local ResearchProject = {}

---Create a new research project
---@param data table Project data {entryId, manDaysRequired}
---@return table ResearchProject instance
function ResearchProject.new(data)
    return {
        id = data.id or "rproj_" .. tostring(math.random(100000, 999999)),
        entryId = data.entryId or "unknown",
        
        -- Progress
        manDaysRequired = data.manDaysRequired or 100,
        manDaysCompleted = data.manDaysCompleted or 0,
        progress = 0,
        
        -- Scientists
        scientistsAssigned = data.scientistsAssigned or 0,
        
        -- Status
        status = data.status or "active",  -- active, paused, completed, cancelled
        
        -- Dates
        startDate = data.startDate or {year = 1, month = 1, day = 1},
        estimatedCompletion = data.estimatedCompletion or nil,
        completedDate = data.completedDate or nil,
        
        -- Special (interrogations)
        attempts = data.attempts or 0,
        succeeded = data.succeeded or false,
    }
end

---Update research progress daily
---@param project table The research project
---@param daysElapsed number Days to advance (default 1)
---@return boolean completed True if research just completed
function ResearchProject.update(project, daysElapsed)
    daysElapsed = daysElapsed or 1
    
    if project.status == "active" then
        -- Add man-days based on scientists (1 scientist = 1 man-day per day)
        local manDaysAdded = project.scientistsAssigned * daysElapsed
        project.manDaysCompleted = project.manDaysCompleted + manDaysAdded
        project.progress = math.min(1.0, project.manDaysCompleted / project.manDaysRequired)
        
        -- Check completion
        if project.manDaysCompleted >= project.manDaysRequired then
            project.status = "completed"
            project.progress = 1.0
            project.completedDate = {year = 1, month = 1, day = 1}  -- TODO: use calendar
            return true
        end
    end
    
    return false
end

---Pause research
---@param project table The research project
function ResearchProject.pause(project)
    project.status = "paused"
end

---Resume research
---@param project table The research project
function ResearchProject.resume(project)
    project.status = "active"
end

---Cancel research
---@param project table The research project
function ResearchProject.cancel(project)
    project.status = "cancelled"
    project.manDaysCompleted = 0
    project.progress = 0
end

---Allocate scientists to research
---@param project table The research project
---@param count number Number of scientists
function ResearchProject.assignScientists(project, count)
    project.scientistsAssigned = count
end

---Get estimated days to completion
---@param project table The research project
---@return number days Days remaining (if scientists assigned)
function ResearchProject.getEstimatedDaysRemaining(project)
    if project.scientistsAssigned == 0 then
        return math.huge
    end
    
    local daysRemaining = project.manDaysRequired - project.manDaysCompleted
    return math.ceil(daysRemaining / project.scientistsAssigned)
end

---Get research info string
---@param project table The research project
---@return string info Human-readable project info
function ResearchProject.getInfo(project)
    local percent = math.floor(project.progress * 100)
    local remaining = ResearchProject.getEstimatedDaysRemaining(project)
    
    if remaining == math.huge then
        return string.format("%s (%d%%) - No scientists assigned", project.entryId, percent)
    else
        return string.format("%s (%d%%) - %d days remaining", project.entryId, percent, remaining)
    end
end

return ResearchProject



