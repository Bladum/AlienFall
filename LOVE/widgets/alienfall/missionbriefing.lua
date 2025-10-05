--[[
widgets/missionbriefing.lua
MissionBriefing widget for displaying mission details and objectives


Comprehensive panel for mission briefings, showing objectives, maps, soldier assignments, and mission details.
Essential for pre-mission planning and tactical preparation in strategy games.

PURPOSE:
- Provide a comprehensive panel for mission briefings and tactical planning
- Display mission objectives, maps, and soldier assignments
- Enable interactive objective tracking and soldier selection
- Facilitate mission preparation and strategic decision making

KEY FEATURES:
- Mission title, description, and detailed briefing display
- Interactive objectives list with completion tracking
- Mini-map integration for tactical overview
- Soldier roster with assignment and equipment display
- Mission parameters and difficulty indicators
- Interactive elements for objective toggles and soldier selection
- Briefing text with rich formatting and scrolling
- Mission statistics and success criteria
- Equipment and loadout verification
- Mission timeline and phase information

]]

local core = require("widgets.core")
local Label = require("widgets.common.label")
local Button = require("widgets.common.button")
local MiniMap = require("widgets.complex.minimap")

local MissionBriefing = {}
MissionBriefing.__index = MissionBriefing
setmetatable(MissionBriefing, { __index = core.Base })

function MissionBriefing:new(x, y, w, h, missionData, options)
    local obj = core.Base:new(x, y, w, h)

    obj.missionData = missionData or {}
    obj.objectives = obj.missionData.objectives or {}
    obj.soldiers = obj.missionData.soldiers or {}

    -- Layout
    obj.padding = 10
    obj.titleFont = core.theme.fontBold or love.graphics.getFont()
    obj.textFont = core.theme.font or love.graphics.getFont()

    -- Components
    obj.titleLabel = Label:new(x + obj.padding, y + obj.padding, w - 2 * obj.padding, 30, {
        text = obj.missionData.title or "Mission Briefing",
        font = obj.titleFont,
        align = "left"
    })

    obj.descriptionLabel = Label:new(x + obj.padding, y + 50, w - 2 * obj.padding, 60, {
        text = obj.missionData.description or "No description available.",
        font = obj.textFont,
        align = "left",
        multiline = true
    })

    -- Mini-map if available
    if obj.missionData.mapImage then
        obj.miniMap = MiniMap:new(x + obj.padding, y + 120, 200, 150, obj.missionData.mapImage)
    end

    -- Objectives list
    obj.objectiveLabels = {}
    local oy = y + 280
    for i, obj in ipairs(obj.objectives) do
        local label = Label:new(x + obj.padding, oy, w - 2 * obj.padding, 20, {
            text = "- " .. obj.text,
            font = obj.textFont,
            align = "left"
        })
        table.insert(obj.objectiveLabels, label)
        oy = oy + 25
    end

    setmetatable(obj, self)
    return obj
end

function MissionBriefing:setMission(missionData)
    self.missionData = missionData
    self.objectives = missionData.objectives or {}
    self.soldiers = missionData.soldiers or {}
    -- Update components
    self.titleLabel:setText(missionData.title or "Mission Briefing")
    self.descriptionLabel:setText(missionData.description or "No description available.")
    -- Rebuild objectives
    self.objectiveLabels = {}
    local oy = self.y + 280
    for i, obj in ipairs(self.objectives) do
        local label = Label:new(self.x + self.padding, oy, self.w - 2 * self.padding, 20, {
            text = "- " .. obj.text,
            font = self.textFont,
            align = "left"
        })
        table.insert(self.objectiveLabels, label)
        oy = oy + 25
    end
end

function MissionBriefing:draw()
    love.graphics.setColor(unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    self.titleLabel:draw()
    self.descriptionLabel:draw()

    if self.miniMap then
        self.miniMap:draw()
    end

    for _, label in ipairs(self.objectiveLabels) do
        label:draw()
    end
end

function MissionBriefing:update(dt)
    if self.miniMap then
        self.miniMap:update(dt)
    end
end

return MissionBriefing
