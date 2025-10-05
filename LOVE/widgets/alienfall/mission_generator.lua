--[[
widgets/mission_generator.lua
Mission Generator widget for creating and customizing missions.


PURPOSE:
- Provide an interface for generating and customizing missions with various parameters, objectives, and difficulty settings in strategy games like OpenXCOM.

KEY FEATURES:
- Mission type selection (terror, abduction, research, etc.)
- Difficulty and threat level configuration
- Objective customization and weighting
- Terrain and environmental settings
- Alien race and unit composition
- Reward calculation and risk assessment
@see widgets.core
@see widgets.common.dropdown
]]

local core = require("widgets.core")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")
local Dropdown = require("widgets.common.dropdown")
local Slider = require("widgets.common.slider")

local MissionGenerator = {}
MissionGenerator.__index = MissionGenerator
setmetatable(MissionGenerator, { __index = core.Base })

-- Mission types
MissionGenerator.MISSION_TYPES = {
    "Terror Mission",
    "Abduction",
    "Research Site",
    "UFO Crash",
    "Alien Base",
    "Supply Raid"
}

-- Difficulty levels
MissionGenerator.DIFFICULTY_LEVELS = {
    "Rookie",
    "Veteran",
    "Superhuman",
    "Impossible"
}

function MissionGenerator:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    obj.options = options or {}

    -- Mission parameters
    obj.missionType = 1
    obj.difficulty = 1
    obj.objectiveCount = 3
    obj.alienCount = 10
    obj.terrainType = "Urban"

    -- UI Components
    obj:_createUI()

    -- Callbacks
    obj.onMissionGenerated = options.onMissionGenerated
    obj.onParameterChanged = options.onParameterChanged
    obj.onDifficultyAdjusted = options.onDifficultyAdjusted

    setmetatable(obj, self)
    return obj
end

function MissionGenerator:_createUI()
    local currentY = self.y + 20

    -- Mission Type Dropdown
    local typeLabel = Label:new(self.x + 10, currentY, 150, 25, "Mission Type:")
    self:addChild(typeLabel)

    self.typeDropdown = Dropdown:new(self.x + 170, currentY, 200, 25,
        self.MISSION_TYPES, self.missionType, function(index)
            self.missionType = index
            if self.onParameterChanged then
                self.onParameterChanged("missionType", index)
            end
        end)
    self:addChild(self.typeDropdown)
    currentY = currentY + 40

    -- Difficulty Dropdown
    local diffLabel = Label:new(self.x + 10, currentY, 150, 25, "Difficulty:")
    self:addChild(diffLabel)

    self.difficultyDropdown = Dropdown:new(self.x + 170, currentY, 200, 25,
        self.DIFFICULTY_LEVELS, self.difficulty, function(index)
            self.difficulty = index
            if self.onDifficultyAdjusted then
                self.onDifficultyAdjusted(index)
            end
        end)
    self:addChild(self.difficultyDropdown)
    currentY = currentY + 40

    -- Alien Count Slider
    local alienLabel = Label:new(self.x + 10, currentY, 150, 25,
        string.format("Alien Count: %d", self.alienCount))
    self:addChild(alienLabel)

    self.alienSlider = Slider:new(self.x + 170, currentY, 200, 25,
        self.alienCount, 1, 50, function(value)
            self.alienCount = value
            alienLabel:setText(string.format("Alien Count: %d", value))
            if self.onParameterChanged then
                self.onParameterChanged("alienCount", value)
            end
        end)
    self:addChild(self.alienSlider)
    currentY = currentY + 40

    -- Generate Button
    self.generateBtn = Button:new(self.x + self.w - 120, self.y + self.h - 40,
        100, 30, "Generate", function()
            local mission = self:_generateMissionData()
            if self.onMissionGenerated then
                self.onMissionGenerated(mission)
            end
        end)
    self:addChild(self.generateBtn)
end

function MissionGenerator:_generateMissionData()
    return {
        type = self.MISSION_TYPES[self.missionType],
        difficulty = self.DIFFICULTY_LEVELS[self.difficulty],
        alienCount = self.alienCount,
        objectives = self:_generateObjectives(),
        terrain = self.terrainType,
        rewards = self:_calculateRewards(),
        risks = self:_assessRisks()
    }
end

function MissionGenerator:_generateObjectives()
    local objectives = {}
    local objectiveTemplates = {
        "Eliminate all alien forces",
        "Rescue civilians",
        "Destroy alien technology",
        "Collect alien artifacts",
        "Secure crash site"
    }

    for i = 1, self.objectiveCount do
        table.insert(objectives, objectiveTemplates[math.random(#objectiveTemplates)])
    end

    return objectives
end

function MissionGenerator:_calculateRewards()
    local baseReward = 1000
    local difficultyMultiplier = self.difficulty * 0.5
    local alienMultiplier = self.alienCount * 10

    return baseReward + (baseReward * difficultyMultiplier) + alienMultiplier
end

function MissionGenerator:_assessRisks()
    local riskLevel = "Low"
    if self.difficulty >= 3 then
        riskLevel = "High"
    elseif self.difficulty >= 2 then
        riskLevel = "Medium"
    end

    return {
        level = riskLevel,
        soldierLoss = self.difficulty * 10,
        equipmentLoss = self.difficulty * 5
    }
end

function MissionGenerator:setDifficulty(level)
    self.difficulty = level
    self.difficultyDropdown:setSelected(level)
end

return MissionGenerator
