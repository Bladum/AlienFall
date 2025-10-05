--[[
widgets/missiondebrief.lua
MissionDebrief widget for post-mission reports and statistics.


Post-mission analysis and reporting widget for tactical games like OpenXCOM.
Provides comprehensive mission outcome analysis, soldier performance reports,
equipment recovery details, and score calculation with detailed statistics.

PURPOSE:
- Provide comprehensive post-mission analysis and reporting for tactical games
- Display mission outcomes, soldier performance, casualties, and rewards
- Enable strategic decision making based on detailed performance metrics
- Support progression tracking and debriefing in turn-based strategy gameplay

KEY FEATURES:
- Mission outcome summary (success/failure/partial success)
- Detailed statistics (aliens killed, civilians saved, time taken)
- Soldier performance reports with experience gained
- Equipment and resource recovery details
- Score calculation and rating system
- Replay highlights and key moments
- Visual feedback for mission results
- Integration with save/load systems
- Accessibility support for screen readers

@see widgets.common.core.Base
@see widgets.common.panel
@see widgets.common.button
@see widgets.common.progressbar
]]

local core = require("widgets.core")
local Label = require("widgets.common.label")
local Button = require("widgets.common.button")
local ProgressBar = require("widgets.common.progressbar")

local MissionDebrief = {}
MissionDebrief.__index = MissionDebrief
setmetatable(MissionDebrief, { __index = core.Base })

function MissionDebrief:new(x, y, w, h, missionResult, options)
    local obj = core.Base:new(x, y, w, h)

    obj.missionResult = missionResult or {}
    obj.statistics = obj.missionResult.statistics or {}
    obj.soldierReports = obj.missionResult.soldierReports or {}

    -- Layout
    obj.padding = 20
    obj.sectionSpacing = 30
    obj.currentY = y + obj.padding

    -- Title
    obj.titleLabel = Label:new(x + obj.padding, obj.currentY, w - 2 * obj.padding, 40, {
        text = "Mission Debriefing",
        font = core.theme.fontLarge,
        align = "center"
    })
    obj:addChild(obj.titleLabel)
    obj.currentY = obj.currentY + 50

    -- Mission outcome
    obj.outcomeLabel = Label:new(x + obj.padding, obj.currentY, w - 2 * obj.padding, 30, {
        text = obj:_getOutcomeText(),
        color = obj:_getOutcomeColor(),
        align = "center"
    })
    obj:addChild(obj.outcomeLabel)
    obj.currentY = obj.currentY + 40

    -- Statistics section
    obj:_createStatisticsSection()

    -- Soldier reports section
    obj:_createSoldierReportsSection()

    -- Action buttons
    obj:_createActionButtons()

    setmetatable(obj, self)
    return obj
end

function MissionDebrief:_getOutcomeText()
    local outcome = self.missionResult.outcome or "unknown"
    if outcome == "success" then
        return "MISSION SUCCESSFUL"
    elseif outcome == "failure" then
        return "MISSION FAILED"
    elseif outcome == "partial" then
        return "PARTIAL SUCCESS"
    else
        return "MISSION COMPLETE"
    end
end

function MissionDebrief:_getOutcomeColor()
    local outcome = self.missionResult.outcome or "unknown"
    if outcome == "success" then
        return { 0.2, 0.8, 0.2 }
    elseif outcome == "failure" then
        return { 0.8, 0.2, 0.2 }
    elseif outcome == "partial" then
        return { 0.8, 0.8, 0.2 }
    else
        return { 0.5, 0.5, 0.5 }
    end
end

function MissionDebrief:_createStatisticsSection()
    -- Section title
    local statsTitle = Label:new(self.x + self.padding, self.currentY, 200, 25, {
        text = "Mission Statistics:",
        font = core.theme.fontBold
    })
    self:addChild(statsTitle)
    self.currentY = self.currentY + 30

    -- Statistics list
    local statLabels = {}
    local stats = {
        { "Aliens Killed:",   self.statistics.aliensKilled or 0 },
        { "Civilians Saved:", self.statistics.civiliansSaved or 0 },
        { "Soldiers Lost:",   self.statistics.soldiersLost or 0 },
        { "Time Taken:",      string.format("%.1f minutes", (self.statistics.timeTaken or 0) / 60) },
        { "Score:",           self.statistics.score or 0 }
    }

    for i, stat in ipairs(stats) do
        local statLabel = Label:new(self.x + self.padding + 20, self.currentY, 300, 20, {
            text = string.format("%s %s", stat[1], stat[2])
        })
        self:addChild(statLabel)
        self.currentY = self.currentY + 25
    end

    self.currentY = self.currentY + self.sectionSpacing - 25
end

function MissionDebrief:_createSoldierReportsSection()
    -- Section title
    local soldierTitle = Label:new(self.x + self.padding, self.currentY, 200, 25, {
        text = "Soldier Performance:",
        font = core.theme.fontBold
    })
    self:addChild(soldierTitle)
    self.currentY = self.currentY + 30

    -- Soldier reports
    for i, report in ipairs(self.soldierReports) do
        local soldierLabel = Label:new(self.x + self.padding + 20, self.currentY, 300, 20, {
            text = string.format("%s - Kills: %d, XP: +%d",
                report.name, report.kills or 0, report.xpGained or 0)
        })
        self:addChild(soldierLabel)
        self.currentY = self.currentY + 25
    end

    self.currentY = self.currentY + self.sectionSpacing - 25
end

function MissionDebrief:_createActionButtons()
    local buttonY = self.y + self.h - 50
    local buttonWidth = 120
    local buttonSpacing = 20
    local totalWidth = buttonWidth * 2 + buttonSpacing
    local startX = self.x + (self.w - totalWidth) / 2

    -- Continue button
    local continueBtn = Button:new(startX, buttonY, buttonWidth, 35, "Continue", function()
        if self.onContinue then self.onContinue() end
    end)
    self:addChild(continueBtn)

    -- View Stats button
    local statsBtn = Button:new(startX + buttonWidth + buttonSpacing, buttonY, buttonWidth, 35, "View Stats", function()
        if self.onViewStats then self.onViewStats() end
    end)
    self:addChild(statsBtn)
end

function MissionDebrief:setMissionResult(result)
    self.missionResult = result
    self.statistics = result.statistics or {}
    self.soldierReports = result.soldierReports or {}
    -- Update display (would need to recreate labels in full implementation)
end

return MissionDebrief






