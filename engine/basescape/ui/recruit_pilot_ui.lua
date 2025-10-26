--- Pilot Recruitment UI
---
--- Manage pilot recruitment with costs and training time.
--- Recruits new pilots for 5000 credits, 30-day training period.
---
--- Features:
--- - Browse available pilot classes
--- - Recruit with cost/time validation
--- - Track training progress
--- - Assign to crafts after training
---
--- @module engine.basescape.ui.recruit_pilot_ui
--- @author AlienFall Development Team

local RecruitmentUI = {}
RecruitmentUI.__index = RecruitmentUI

--- Recruitment costs and times
RecruitmentUI.RECRUITMENT_COST = 5000
RecruitmentUI.TRAINING_DAYS = 30

RecruitmentUI.PILOT_CLASSES = {
    {id = "pilot", name = "Pilot", cost = 5000, days = 30},
    {id = "fighter_pilot", name = "Fighter Pilot", cost = 7500, days = 45},
    {id = "bomber_pilot", name = "Bomber Pilot", cost = 6500, days = 40},
    {id = "helicopter_pilot", name = "Helicopter Pilot", cost = 6000, days = 35}
}

--- Initialize recruitment UI
---@return table UI instance
function RecruitmentUI:new()
    local self = setmetatable({}, RecruitmentUI)

    self.visible = false
    self.selectedClass = nil
    self.recruitingPilots = {}  -- {pilot_id = {class, start_day, end_day}}
    self.availableFunds = 100000
    self.currentDay = 1

    return self
end

--- Show recruitment UI
---@return boolean Success
function RecruitmentUI:show()
    self.visible = true
    return true
end

--- Hide recruitment UI
---@return boolean Success
function RecruitmentUI:hide()
    self.visible = false
    return true
end

--- Get available pilot classes
---@return table Class definitions
function RecruitmentUI:getAvailableClasses()
    return self.PILOT_CLASSES
end

--- Check if can recruit pilot
---@param classId string Pilot class ID
---@return boolean, string Can recruit (true/false), reason if cannot
function RecruitmentUI:canRecruit(classId)
    local classData = nil

    for _, cls in ipairs(self.PILOT_CLASSES) do
        if cls.id == classId then
            classData = cls
            break
        end
    end

    if not classData then
        return false, "Unknown pilot class"
    end

    if self.availableFunds < classData.cost then
        return false, string.format("Insufficient funds: need %d, have %d",
            classData.cost, self.availableFunds)
    end

    return true, ""
end

--- Recruit new pilot
---@param classId string Pilot class ID
---@param name string Pilot name
---@return boolean Success, string pilot_id or error
function RecruitmentUI:recruitPilot(classId, name)
    local canRecruit, reason = self:canRecruit(classId)
    if not canRecruit then
        return false, reason
    end

    -- Find class data
    local classData = nil
    for _, cls in ipairs(self.PILOT_CLASSES) do
        if cls.id == classId then
            classData = cls
            break
        end
    end

    if not classData then
        return false, "Class data not found"
    end

    -- Deduct cost
    self.availableFunds = self.availableFunds - classData.cost

    -- Create recruitment entry
    local pilotId = "pilot_recruit_" .. os.time()
    self.recruitingPilots[pilotId] = {
        id = pilotId,
        name = name or ("Recruit " .. pilotId),
        class = classId,
        start_day = self.currentDay,
        end_day = self.currentDay + classData.days - 1,
        status = "training"
    }

    print(string.format("[RecruitmentUI] Recruited %s (%s) - Training until day %d",
        name or "Unknown", classId, self.recruitingPilots[pilotId].end_day))

    return true, pilotId
end

--- Update recruitment progress
---@param day number Current game day
---@return table Completed pilots {pilot_id, ...}
function RecruitmentUI:updateDay(day)
    self.currentDay = day
    local completed = {}

    for pilotId, recruitment in pairs(self.recruitingPilots) do
        if recruitment.status == "training" and day >= recruitment.end_day then
            recruitment.status = "ready"
            table.insert(completed, pilotId)

            print(string.format("[RecruitmentUI] %s training complete", recruitment.name))
        end
    end

    return completed
end

--- Get training progress for pilot
---@param pilotId string Pilot ID
---@return number|nil Progress 0-100, or nil if not recruiting
function RecruitmentUI:getTrainingProgress(pilotId)
    local recruitment = self.recruitingPilots[pilotId]
    if not recruitment then
        return nil
    end

    local total = recruitment.end_day - recruitment.start_day + 1
    local elapsed = self.currentDay - recruitment.start_day

    return math.floor((elapsed / total) * 100)
end

--- Get recruiting pilots
---@param status string|nil Filter by status ("training", "ready", nil for all)
---@return table Pilot list
function RecruitmentUI:getRecruitingPilots(status)
    local result = {}

    for pilotId, recruitment in pairs(self.recruitingPilots) do
        if not status or recruitment.status == status then
            table.insert(result, recruitment)
        end
    end

    return result
end

--- Assign completed pilot to craft
---@param pilotId string Pilot ID
---@param craftId string Craft ID
---@return boolean Success
function RecruitmentUI:assignPilotToCraft(pilotId, craftId)
    local recruitment = self.recruitingPilots[pilotId]
    if not recruitment then
        return false
    end

    if recruitment.status ~= "ready" then
        return false
    end

    recruitment.status = "assigned"
    recruitment.assigned_craft = craftId

    print(string.format("[RecruitmentUI] %s assigned to craft %s",
        recruitment.name, craftId))

    return true
end

--- Format recruitment info for display
---@param recruitment table Recruitment data
---@return string Formatted info
function RecruitmentUI:formatRecruitmentInfo(recruitment)
    if not recruitment then
        return "No recruitment data"
    end

    local status = recruitment.status
    if status == "training" then
        local progress = self:getTrainingProgress(recruitment.id)
        return string.format("%s (%s) - Training: %d%%",
            recruitment.name, recruitment.class, progress or 0)
    elseif status == "ready" then
        return string.format("%s (%s) - READY", recruitment.name, recruitment.class)
    elseif status == "assigned" then
        return string.format("%s (%s) - Assigned to %s",
            recruitment.name, recruitment.class, recruitment.assigned_craft or "unknown")
    end

    return string.format("%s (%s)", recruitment.name, recruitment.class)
end

--- Get recruitment cost for class
---@param classId string Pilot class ID
---@return number Cost in credits
function RecruitmentUI:getRecruitmentCost(classId)
    for _, cls in ipairs(self.PILOT_CLASSES) do
        if cls.id == classId then
            return cls.cost
        end
    end
    return self.RECRUITMENT_COST
end

--- Get training days for class
---@param classId string Pilot class ID
---@return number Days of training
function RecruitmentUI:getTrainingDays(classId)
    for _, cls in ipairs(self.PILOT_CLASSES) do
        if cls.id == classId then
            return cls.days
        end
    end
    return self.TRAINING_DAYS
end

--- Set available funds
---@param amount number Credits available
---@return boolean Success
function RecruitmentUI:setAvailableFunds(amount)
    self.availableFunds = amount or 0
    return true
end

--- Get available funds
---@return number Credits
function RecruitmentUI:getAvailableFunds()
    return self.availableFunds
end

return RecruitmentUI
