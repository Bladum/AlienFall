--[[
widgets/alienfall/soldier_stats.lua
Soldier Stats widget for detailed soldier information and performance tracking.

Provides a comprehensive interface for viewing and managing soldier statistics, skills, equipment, and performance history in strategy games like OpenXCOM.

PURPOSE:
- Provide a comprehensive interface for viewing and managing soldier statistics, skills, equipment, and performance history in strategy games like OpenXCOM

KEY FEATURES:
- Detailed stat breakdown (health, accuracy, strength, etc.)
- Skill progression and specialization tracking
- Equipment and weapon proficiency
- Mission performance history and statistics
- Promotion recommendations and training suggestions
- Comparison with other soldiers

@see widgets.core
@see widgets.alienfall.soldier_training
]]

local core = require("widgets.core")
local ProgressBar = require("widgets.common.progressbar")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")

local SoldierStats = {}
SoldierStats.__index = SoldierStats
setmetatable(SoldierStats, { __index = core.Base })

function SoldierStats:new(x, y, w, h, soldier, options)
    local obj = core.Base:new(x, y, w, h)

    obj.soldier = soldier or {}
    obj.options = options or {}

    -- Soldier stats
    obj.stats = obj.soldier.stats or {
        health = 100,
        accuracy = 50,
        strength = 40,
        bravery = 60,
        reactions = 45,
        psi = 0
    }

    -- Skills and experience
    obj.skills = obj.soldier.skills or {}
    obj.experience = obj.soldier.experience or 0
    obj.rank = obj.soldier.rank or "Rookie"

    -- Mission history
    obj.missionHistory = obj.soldier.missionHistory or {}

    -- UI Components
    obj:_createStatsDisplay()

    -- Callbacks
    obj.onStatChanged = options.onStatChanged
    obj.onPromotionReady = options.onPromotionReady
    obj.onSpecializationChanged = options.onSpecializationChanged

    setmetatable(obj, self)
    return obj
end

function SoldierStats:_createStatsDisplay()
    local currentY = self.y + 20

    -- Soldier name and rank
    local nameLabel = Label:new(self.x + 10, currentY, 300, 30,
        string.format("%s - %s", self.soldier.name or "Unknown", self.rank),
        { font = core.theme.fontLarge })
    self:addChild(nameLabel)
    currentY = currentY + 40

    -- Core stats
    local statLabels = {}
    local statNames = { "Health", "Accuracy", "Strength", "Bravery", "Reactions", "Psi" }

    for i, statName in ipairs(statNames) do
        local statValue = self.stats[string.lower(statName)] or 0

        -- Stat label
        local statLabel = Label:new(self.x + 10, currentY, 100, 20, statName .. ":")
        self:addChild(statLabel)

        -- Stat bar
        local statBar = ProgressBar:new(self.x + 120, currentY, 150, 20,
            statValue, 0, 100, {
                showText = true,
                textFormat = "%d"
            })
        self:addChild(statBar)

        currentY = currentY + 30
    end

    -- Experience and promotion
    local expLabel = Label:new(self.x + 10, currentY, 200, 20,
        string.format("Experience: %d", self.experience))
    self:addChild(expLabel)
    currentY = currentY + 30

    -- Mission count
    local missionLabel = Label:new(self.x + 10, currentY, 200, 20,
        string.format("Missions: %d", #self.missionHistory))
    self:addChild(missionLabel)
    currentY = currentY + 30

    -- Promotion button
    if self:_canPromote() then
        self.promoteBtn = Button:new(self.x + 10, currentY, 120, 30, "Promote", function()
            if self.onPromotionReady then
                self.onPromotionReady()
            end
        end)
        self:addChild(self.promoteBtn)
    end
end

function SoldierStats:updateStats(stats)
    self.stats = stats
    -- Update display bars
    if self.onStatChanged then
        for stat, value in pairs(stats) do
            self.onStatChanged(stat, value)
        end
    end
end

function SoldierStats:addMissionRecord(mission)
    table.insert(self.missionHistory, mission)
    -- Update mission count display
end

function SoldierStats:_canPromote()
    local expForNextRank = self:_getExpForNextRank()
    return self.experience >= expForNextRank
end

function SoldierStats:_getExpForNextRank()
    -- Simple experience calculation
    local rankExp = {
        ["Rookie"] = 0,
        ["Squaddie"] = 100,
        ["Sergeant"] = 250,
        ["Captain"] = 500,
        ["Colonel"] = 1000,
        ["Commander"] = 2000
    }
    return rankExp[self.rank] or 0
end

function SoldierStats:promoteSoldier()
    if self:_canPromote() then
        local ranks = { "Rookie", "Squaddie", "Sergeant", "Captain", "Colonel", "Commander" }
        local currentIndex = 1
        for i, rank in ipairs(ranks) do
            if rank == self.rank then
                currentIndex = i
                break
            end
        end

        if currentIndex < #ranks then
            self.rank = ranks[currentIndex + 1]
            -- Update display
        end
    end
end

return SoldierStats
