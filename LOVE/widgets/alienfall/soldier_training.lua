--[[
widgets/alienfall/soldier_training.lua
Soldier Training widget for skill development and promotion.

Provides comprehensive soldier training and skill development interface for tactical games like OpenXCOM.
Essential for base management, allowing players to train soldiers, assign specializations, and track progress.

PURPOSE:
- Provide comprehensive soldier training and skill development interface for tactical games like OpenXCOM
- Enable base management for training soldiers, assigning specializations, and tracking progress
- Support skill tree visualization, training progress, and resource management

KEY FEATURES:
- Skill tree visualization with prerequisites and unlocks
- Training progress tracking with time and resource costs
- Soldier specialization assignment (sniper, heavy weapons, medic, etc.)
- Experience point allocation and stat improvements
- Training facility management and queue system
- Performance-based recommendations

@see widgets.core
@see widgets.alienfall.soldier_stats
]]


local core = require("widgets.core")
local Label = require("widgets.common.label")
local Button = require("widgets.common.button")
local ProgressBar = require("widgets.common.progressbar")

local SoldierTraining = {}
SoldierTraining.__index = SoldierTraining
setmetatable(SoldierTraining, { __index = core.Base })

-- Soldier classes/specializations
SoldierTraining.CLASSES = {
    SNIPER = { name = "Sniper", color = { 0.8, 0.4, 0.2 }, skills = { "accuracy", "stealth", "long_range" } },
    HEAVY = { name = "Heavy Weapons", color = { 0.2, 0.4, 0.8 }, skills = { "strength", "explosives", "suppression" } },
    MEDIC = { name = "Medic", color = { 0.2, 0.8, 0.4 }, skills = { "medical", "revive", "stabilize" } },
    ASSAULT = { name = "Assault", color = { 0.8, 0.2, 0.4 }, skills = { "agility", "close_quarters", "breach" } },
    SUPPORT = { name = "Support", color = { 0.6, 0.6, 0.2 }, skills = { "hacking", "scanning", "psi" } }
}

function SoldierTraining:new(x, y, w, h, soldier, options)
    local obj = core.Base:new(x, y, w, h)

    obj.soldier = soldier or {}
    obj.skillTree = obj.soldier.skillTree or {}
    obj.trainingQueue = obj.soldier.trainingQueue or {}
    obj.availableXP = obj.soldier.xp or 0

    -- Layout
    obj.padding = 15
    obj.sectionSpacing = 20
    obj.currentY = y + obj.padding

    -- Title
    obj.titleLabel = Label:new(x + obj.padding, obj.currentY, w - 2 * obj.padding, 30, {
        text = string.format("Training: %s", obj.soldier.name or "Unknown"),
        font = core.theme.fontLarge,
        align = "center"
    })
    obj:addChild(obj.titleLabel)
    obj.currentY = obj.currentY + 40

    -- Soldier stats section
    obj:_createStatsSection()

    -- Skill tree section
    obj:_createSkillTreeSection()

    -- Training queue section
    obj:_createTrainingQueueSection()

    -- Action buttons
    obj:_createActionButtons()

    setmetatable(obj, self)
    return obj
end

function SoldierTraining:_createStatsSection()
    -- Section title
    local statsTitle = Label:new(self.x + self.padding, self.currentY, 200, 25, {
        text = "Soldier Stats:",
        font = core.theme.fontBold
    })
    self:addChild(statsTitle)
    self.currentY = self.currentY + 30

    -- Stats display
    local stats = {
        { "Level:",  self.soldier.level or 1 },
        { "XP:",     string.format("%d / %d", self.availableXP, self:_getXPForNextLevel()) },
        { "Class:",  self.CLASSES[self.soldier.class] and self.CLASSES[self.soldier.class].name or "Unassigned" },
        { "Health:", string.format("%d / %d", self.soldier.currentHealth or 100, self.soldier.maxHealth or 100) }
    }

    for i, stat in ipairs(stats) do
        local statLabel = Label:new(self.x + self.padding + 20, self.currentY, 250, 20, {
            text = string.format("%s %s", stat[1], stat[2])
        })
        self:addChild(statLabel)
        self.currentY = self.currentY + 25
    end

    -- XP progress bar
    local xpProgress = (self.availableXP / self:_getXPForNextLevel()) * 100
    obj.xpBar = ProgressBar:new(self.x + self.padding, self.currentY, self.w - 2 * self.padding, 20, {
        value = xpProgress,
        maxValue = 100,
        showText = true,
        textFormat = "XP Progress: %.1f%%"
    })
    self:addChild(obj.xpBar)
    self.currentY = self.currentY + 40
end

function SoldierTraining:_createSkillTreeSection()
    -- Section title
    local skillTitle = Label:new(self.x + self.padding, self.currentY, 200, 25, {
        text = "Skill Tree:",
        font = core.theme.fontBold
    })
    self:addChild(skillTitle)
    self.currentY = self.currentY + 30

    -- Skill tree visualization area
    obj.skillTreeArea = {
        x = self.x + self.padding,
        y = self.currentY,
        w = self.w - 2 * self.padding,
        h = 150
    }
    self.currentY = self.currentY + 160

    -- Skill points info
    local skillPoints = self:_calculateSkillPoints()
    local skillLabel = Label:new(self.x + self.padding, self.currentY, self.w - 2 * self.padding, 20, {
        text = string.format("Available Skill Points: %d", skillPoints),
        align = "center"
    })
    self:addChild(skillLabel)
    self.currentY = self.currentY + 30
end

function SoldierTraining:_createTrainingQueueSection()
    -- Section title
    local queueTitle = Label:new(self.x + self.padding, self.currentY, 200, 25, {
        text = "Training Queue:",
        font = core.theme.fontBold
    })
    self:addChild(queueTitle)
    self.currentY = self.currentY + 30

    -- Training queue display
    for i, training in ipairs(self.trainingQueue) do
        local queueLabel = Label:new(self.x + self.padding + 20, self.currentY, self.w - 2 * self.padding - 20, 20, {
            text = string.format("%d. %s (%s remaining)", i, training.skill, training.timeRemaining or "Unknown")
        })
        self:addChild(queueLabel)
        self.currentY = self.currentY + 25
    end

    if #self.trainingQueue == 0 then
        local emptyLabel = Label:new(self.x + self.padding + 20, self.currentY, self.w - 2 * self.padding - 20, 20, {
            text = "No training in progress",
            color = { 0.5, 0.5, 0.5 }
        })
        self:addChild(emptyLabel)
        self.currentY = self.currentY + 25
    end

    self.currentY = self.currentY + self.sectionSpacing - 25
end

function SoldierTraining:_createActionButtons()
    local buttonY = self.y + self.h - 50
    local buttonWidth = 100
    local buttonSpacing = 15
    local totalWidth = buttonWidth * 2 + buttonSpacing
    local startX = self.x + (self.w - totalWidth) / 2

    -- Train button
    local trainBtn = Button:new(startX, buttonY, buttonWidth, 35, "Train Skill", function()
        if self.onTrainSkill then self.onTrainSkill(self.soldier) end
    end)
    self:addChild(trainBtn)

    -- Assign Class button
    local classBtn = Button:new(startX + buttonWidth + buttonSpacing, buttonY, buttonWidth, 35, "Assign Class",
        function()
            if self.onAssignClass then self.onAssignClass(self.soldier) end
        end)
    self:addChild(classBtn)
end

function SoldierTraining:_getXPForNextLevel()
    local level = self.soldier.level or 1
    return level * 100 -- Simple XP calculation
end

function SoldierTraining:_calculateSkillPoints()
    local level = self.soldier.level or 1
    return math.floor(level / 2) -- Simple skill point calculation
end

function SoldierTraining:setSoldier(soldier)
    self.soldier = soldier
    self.skillTree = soldier.skillTree or {}
    self.trainingQueue = soldier.trainingQueue or {}
    self.availableXP = soldier.xp or 0
    -- Update display (would need to recreate components in full implementation)
end

function SoldierTraining:unlockSkill(skill)
    if not self.skillTree[skill] then
        self.skillTree[skill] = { unlocked = true, level = 1 }
        if self.onSkillUnlock then self.onSkillUnlock(skill) end
    end
end

function SoldierTraining:startTraining(skill)
    table.insert(self.trainingQueue, {
        skill = skill,
        timeRemaining = 3600, -- 1 hour in seconds
        startTime = os.time()
    })
end

return SoldierTraining
