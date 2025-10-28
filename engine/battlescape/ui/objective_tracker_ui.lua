---ObjectiveTrackerUI - Real-Time Mission Objective Display
---
---Displays current mission objectives with progress tracking and status indicators.
---Shows primary and secondary objectives, completion status, and progress bars.
---Part of mission setup and deployment systems (Batch 8).
---
---Features:
---  - Real-time objective tracking during battle
---  - Progress bars for quantifiable objectives
---  - Status indicators (pending, active, complete, failed)
---  - Primary vs secondary objective distinction
---  - Notification system for objective updates
---  - Compact overlay design (top-right corner)
---
---Key Exports:
---  - init(): Initialize/reset objective tracker
---  - addObjective(obj): Add new objective to track
---  - updateStatus(objectiveId, newStatus): Update objective completion status
---  - updateProgress(objectiveId, progress): Update objective progress
---  - removeObjective(objectiveId): Remove completed objective
---  - showNotification(message): Display temporary notification
---  - update(dt): Update notification timers
---  - draw(): Render objective tracker overlay
---
---Dependencies:
---  - require("widgets"): UI widget library for panels and progress bars
---
---@module battlescape.ui.objective_tracker_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ObjectiveTrackerUI = require("battlescape.ui.objective_tracker_ui")
---  ObjectiveTrackerUI.init()
---  ObjectiveTrackerUI.addObjective({
---      id = "eliminate_enemies",
---      description = "Eliminate all enemy forces",
---      type = "PRIMARY",
---      maxProgress = 10
---  })
---
---@see battlescape.ui.mission_brief_ui For pre-mission objective briefing
---@see battlescape.ui.combat_log_system For detailed battle event logging

-- Objective Tracker UI System
-- Real-time objective tracking during battle
-- Part of Batch 8: Mission Setup & Deployment Systems

local ObjectiveTrackerUI = {}

-- Configuration
local PANEL_WIDTH = 240
local PANEL_HEIGHT = 200
local PANEL_X = 960 - PANEL_WIDTH - 12
local PANEL_Y = 12 + 72  -- Below mission timer
local LINE_HEIGHT = 16
local OBJECTIVE_SPACING = 4

-- Colors
local COLORS = {
    BACKGROUND = {r=30, g=30, b=40, a=220},
    BORDER = {r=80, g=100, b=120},
    HEADER = {r=220, g=220, b=240},
    TEXT = {r=200, g=200, b=200},
    OBJECTIVE_PENDING = {r=160, g=160, b=160},
    OBJECTIVE_ACTIVE = {r=220, g=220, b=240},
    OBJECTIVE_COMPLETE = {r=100, g=220, b=100},
    OBJECTIVE_FAILED = {r=255, g=80, b=60},
    PROGRESS_BG = {r=40, g=40, b=50},
    PROGRESS_FILL = {r=100, g=180, b=220},
    PRIMARY = {r=255, g=200, b=60},
    SECONDARY = {r=180, g=200, b=255},
    BONUS = {r=180, g=255, b=180}
}

-- Objective types
local OBJECTIVE_TYPES = {
    PRIMARY = "PRIMARY",
    SECONDARY = "SECONDARY",
    BONUS = "BONUS"
}

-- Objective status
local STATUS = {
    PENDING = "PENDING",
    ACTIVE = "ACTIVE",
    COMPLETE = "COMPLETE",
    FAILED = "FAILED"
}

-- State
local visible = true
local objectives = {}  -- {id, description, type, status, progress, maxProgress}
local notifications = {}  -- {message, time, duration}
local notificationDuration = 3.0

--- Initialize objective tracker
function ObjectiveTrackerUI.init()
    visible = true
    objectives = {}
    notifications = {}
end

--- Add objective
-- @param obj Table {id, description, type, status, progress, maxProgress}
function ObjectiveTrackerUI.addObjective(obj)
    table.insert(objectives, {
        id = obj.id,
        description = obj.description,
        type = obj.type or OBJECTIVE_TYPES.PRIMARY,
        status = obj.status or STATUS.PENDING,
        progress = obj.progress or 0,
        maxProgress = obj.maxProgress or 1
    })
end

--- Update objective status
-- @param objectiveId Objective ID
-- @param newStatus New status (PENDING/ACTIVE/COMPLETE/FAILED)
function ObjectiveTrackerUI.updateStatus(objectiveId, newStatus)
    for _, obj in ipairs(objectives) do
        if obj.id == objectiveId then
            obj.status = newStatus
            
            -- Add notification
            if newStatus == STATUS.COMPLETE then
                ObjectiveTrackerUI.addNotification("Objective Complete: " .. obj.description)
            elseif newStatus == STATUS.FAILED then
                ObjectiveTrackerUI.addNotification("Objective Failed: " .. obj.description)
            elseif newStatus == STATUS.ACTIVE then
                ObjectiveTrackerUI.addNotification("New Objective: " .. obj.description)
            end
            break
        end
    end
end

--- Update objective progress
-- @param objectiveId Objective ID
-- @param progress Current progress value
function ObjectiveTrackerUI.updateProgress(objectiveId, progress)
    for _, obj in ipairs(objectives) do
        if obj.id == objectiveId then
            obj.progress = progress
            
            -- Auto-complete if progress >= maxProgress
            if obj.progress >= obj.maxProgress and obj.status ~= STATUS.COMPLETE then
                ObjectiveTrackerUI.updateStatus(objectiveId, STATUS.COMPLETE)
            end
            break
        end
    end
end

--- Increment objective progress
-- @param objectiveId Objective ID
-- @param amount Amount to increment (default 1)
function ObjectiveTrackerUI.incrementProgress(objectiveId, amount)
    amount = amount or 1
    for _, obj in ipairs(objectives) do
        if obj.id == objectiveId then
            obj.progress = obj.progress + amount
            if obj.progress >= obj.maxProgress and obj.status ~= STATUS.COMPLETE then
                ObjectiveTrackerUI.updateStatus(objectiveId, STATUS.COMPLETE)
            end
            break
        end
    end
end

--- Add notification
-- @param message Notification message
function ObjectiveTrackerUI.addNotification(message)
    table.insert(notifications, {
        message = message,
        time = love.timer.getTime(),
        duration = notificationDuration
    })
end

--- Get objective by ID
function ObjectiveTrackerUI.getObjective(objectiveId)
    for _, obj in ipairs(objectives) do
        if obj.id == objectiveId then
            return obj
        end
    end
    return nil
end

--- Get all objectives
function ObjectiveTrackerUI.getObjectives()
    return objectives
end

--- Check if all primary objectives complete
function ObjectiveTrackerUI.allPrimaryComplete()
    for _, obj in ipairs(objectives) do
        if obj.type == OBJECTIVE_TYPES.PRIMARY and obj.status ~= STATUS.COMPLETE then
            return false
        end
    end
    return true
end

--- Check if any primary objectives failed
function ObjectiveTrackerUI.anyPrimaryFailed()
    for _, obj in ipairs(objectives) do
        if obj.type == OBJECTIVE_TYPES.PRIMARY and obj.status == STATUS.FAILED then
            return true
        end
    end
    return false
end

--- Show/hide tracker
function ObjectiveTrackerUI.setVisible(isVisible)
    visible = isVisible
end

--- Update (called each frame for notifications)
function ObjectiveTrackerUI.update(dt)
    -- Remove expired notifications
    local currentTime = love.timer.getTime()
    for i = #notifications, 1, -1 do
        if currentTime - notifications[i].time > notifications[i].duration then
            table.remove(notifications, i)
        end
    end
end

--- Draw objective tracker
function ObjectiveTrackerUI.draw()
    if not visible then return end
    
    -- Panel background
    love.graphics.setColor(COLORS.BACKGROUND.r/255, COLORS.BACKGROUND.g/255, COLORS.BACKGROUND.b/255, COLORS.BACKGROUND.a/255)
    love.graphics.rectangle("fill", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Panel border
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Header
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("OBJECTIVES", PANEL_X + 4, PANEL_Y + 4)
    
    -- Objectives list
    local yPos = PANEL_Y + 24
    
    for _, obj in ipairs(objectives) do
        -- Type indicator color
        local typeColor = COLORS.PRIMARY
        if obj.type == OBJECTIVE_TYPES.SECONDARY then
            typeColor = COLORS.SECONDARY
        elseif obj.type == OBJECTIVE_TYPES.BONUS then
            typeColor = COLORS.BONUS
        end
        
        -- Status color
        local statusColor = COLORS.OBJECTIVE_PENDING
        if obj.status == STATUS.ACTIVE then
            statusColor = COLORS.OBJECTIVE_ACTIVE
        elseif obj.status == STATUS.COMPLETE then
            statusColor = COLORS.OBJECTIVE_COMPLETE
        elseif obj.status == STATUS.FAILED then
            statusColor = COLORS.OBJECTIVE_FAILED
        end
        
        -- Type indicator square
        love.graphics.setColor(typeColor.r/255, typeColor.g/255, typeColor.b/255)
        love.graphics.rectangle("fill", PANEL_X + 4, yPos, 8, 8)
        
        -- Description (truncated if too long)
        local desc = obj.description
        if #desc > 28 then
            desc = desc:sub(1, 25) .. "..."
        end
        
        love.graphics.setColor(statusColor.r/255, statusColor.g/255, statusColor.b/255)
        love.graphics.print(desc, PANEL_X + 16, yPos, 0, 0.7, 0.7)
        
        yPos = yPos + 12
        
        -- Progress bar (if has progress tracking)
        if obj.maxProgress > 1 then
            local progressPercent = math.min(1.0, obj.progress / obj.maxProgress)
            local barWidth = PANEL_WIDTH - 24
            local barHeight = 8
            
            -- Background
            love.graphics.setColor(COLORS.PROGRESS_BG.r/255, COLORS.PROGRESS_BG.g/255, COLORS.PROGRESS_BG.b/255)
            love.graphics.rectangle("fill", PANEL_X + 12, yPos, barWidth, barHeight)
            
            -- Fill
            love.graphics.setColor(COLORS.PROGRESS_FILL.r/255, COLORS.PROGRESS_FILL.g/255, COLORS.PROGRESS_FILL.b/255)
            love.graphics.rectangle("fill", PANEL_X + 12, yPos, barWidth * progressPercent, barHeight)
            
            -- Border
            love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", PANEL_X + 12, yPos, barWidth, barHeight)
            
            -- Progress text
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print(obj.progress .. " / " .. obj.maxProgress, PANEL_X + 14, yPos, 0, 0.6, 0.6)
            
            yPos = yPos + 12
        end
        
        yPos = yPos + OBJECTIVE_SPACING
        
        -- Stop if panel full
        if yPos > PANEL_Y + PANEL_HEIGHT - 12 then
            break
        end
    end
    
    -- Draw notifications
    drawNotifications()
end

--- Draw notifications
function drawNotifications()
    local notifY = 480  -- Center of screen vertically
    local currentTime = love.timer.getTime()
    
    for i, notif in ipairs(notifications) do
        local elapsed = currentTime - notif.time
        local alpha = 1.0
        
        -- Fade out in last 0.5 seconds
        if elapsed > notif.duration - 0.5 then
            alpha = (notif.duration - elapsed) / 0.5
        end
        
        local notifWidth = 400
        local notifHeight = 48
        local notifX = (960 - notifWidth) / 2
        local notifYPos = notifY + (i - 1) * (notifHeight + 8)
        
        -- Background
        love.graphics.setColor(COLORS.BACKGROUND.r/255, COLORS.BACKGROUND.g/255, COLORS.BACKGROUND.b/255, alpha * 0.9)
        love.graphics.rectangle("fill", notifX, notifYPos, notifWidth, notifHeight)
        
        -- Border
        love.graphics.setColor(COLORS.OBJECTIVE_ACTIVE.r/255, COLORS.OBJECTIVE_ACTIVE.g/255, COLORS.OBJECTIVE_ACTIVE.b/255, alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", notifX, notifYPos, notifWidth, notifHeight)
        
        -- Message
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255, alpha)
        love.graphics.print(notif.message, notifX + 12, notifYPos + 16)
    end
end

--- Clear all objectives
function ObjectiveTrackerUI.clear()
    objectives = {}
    notifications = {}
end

return ObjectiveTrackerUI


























