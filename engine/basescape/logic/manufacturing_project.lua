---ManufacturingProject - Active manufacturing instance
---
---Represents an active manufacturing project with:
---  - Progress tracking (man-days completed)
---  - Engineer allocation
---  - Input resource consumption
---  - Output production
---  - Pause/resume functionality
---
---@module basescape.logic.manufacturing_project
---@author AlienFall Development Team

local ManufacturingProject = {}

-- TASK-13.2: Calendar system integration for manufacturing project dates
local Calendar = require("engine.lore.calendar")

---Create a new manufacturing project
---@param data table Project data {entryId, baseId, quantityTotal, manDaysRequired}
---@return table ManufacturingProject instance
function ManufacturingProject.new(data)
    local id = data.id or ("mproj_" .. tostring(math.random(100000, 999999)))

    return {
        id = id,
        baseId = data.baseId or "base_alpha",
        entryId = data.entryId or "unknown",

        -- Progress
        manDaysRequired = data.manDaysRequired or 50,
        manDaysCompleted = data.manDaysCompleted or 0,
        progress = 0,

        -- Engineers
        engineersAssigned = data.engineersAssigned or 0,

        -- Quantity
        quantityTotal = data.quantityTotal or 1,
        quantityCompleted = data.quantityCompleted or 0,

        -- Status
        status = data.status or "active",  -- active, paused, completed, cancelled

        -- Dates
        startDate = data.startDate or {year = 1, month = 1, day = 1},
        estimatedCompletion = data.estimatedCompletion or nil,
        completedDate = data.completedDate or nil,
    }
end

---Update manufacturing progress daily
---@param project table The manufacturing project
---@param daysElapsed number Days to advance (default 1)
---@param calendar table|nil Calendar instance for date tracking
---@return boolean completed True if project just completed
function ManufacturingProject.update(project, daysElapsed, calendar)
    daysElapsed = daysElapsed or 1

    if project.status == "active" then
        -- Add man-days based on engineers (1 engineer = 1 man-day per day)
        local manDaysAdded = project.engineersAssigned * daysElapsed
        project.manDaysCompleted = project.manDaysCompleted + manDaysAdded
        project.progress = math.min(1.0, project.manDaysCompleted / project.manDaysRequired)

        -- Check if one unit completed
        if project.manDaysCompleted >= project.manDaysRequired then
            project.quantityCompleted = project.quantityCompleted + 1
            project.manDaysCompleted = 0

            -- Check if all units completed
            if project.quantityCompleted >= project.quantityTotal then
                project.status = "completed"
                project.progress = 1.0

                -- TASK-13.2: Set completion date from calendar if available
                if calendar then
                    project.completedDate = calendar:getCurrentDate()
                    print(string.format("[ManufacturingProject] %s completed on %s",
                        project.entryId, calendar:getFullDate()))
                else
                    -- Fallback: use placeholder date
                    project.completedDate = {year = 1, month = 1, day = 1}
                end

                return true
            else
                project.progress = 0
            end
        end
    end

    return false
end

---Pause manufacturing
---@param project table The manufacturing project
function ManufacturingProject.pause(project)
    project.status = "paused"
end

---Resume manufacturing
---@param project table The manufacturing project
function ManufacturingProject.resume(project)
    project.status = "active"
end

---Cancel manufacturing
---@param project table The manufacturing project
function ManufacturingProject.cancel(project)
    project.status = "cancelled"
    project.manDaysCompleted = 0
    project.progress = 0
end

---Allocate engineers to manufacturing
---@param project table The manufacturing project
---@param count number Number of engineers
function ManufacturingProject.assignEngineers(project, count)
    project.engineersAssigned = count
end

---Get estimated days to completion
---@param project table The manufacturing project
---@return number days Days remaining for all units (if engineers assigned)
function ManufacturingProject.getEstimatedDaysRemaining(project)
    if project.engineersAssigned == 0 then
        return math.huge
    end

    local unitsRemaining = project.quantityTotal - project.quantityCompleted
    local manDaysRemaining = (project.manDaysRequired - project.manDaysCompleted) +
                              (unitsRemaining - 1) * project.manDaysRequired

    return math.ceil(manDaysRemaining / project.engineersAssigned)
end

---Get manufacturing info string
---@param project table The manufacturing project
---@return string info Human-readable project info
function ManufacturingProject.getInfo(project)
    local percentUnit = math.floor(project.progress * 100)
    local percentTotal = math.floor((project.quantityCompleted / project.quantityTotal) * 100)
    local remaining = ManufacturingProject.getEstimatedDaysRemaining(project)

    if remaining == math.huge then
        return string.format("%s (%d/%d units, %d%%) - No engineers assigned",
            project.entryId, project.quantityCompleted, project.quantityTotal, percentTotal)
    else
        return string.format("%s (%d/%d units, %d%%) - %d days remaining",
            project.entryId, project.quantityCompleted, project.quantityTotal, percentTotal, remaining)
    end
end

return ManufacturingProject

