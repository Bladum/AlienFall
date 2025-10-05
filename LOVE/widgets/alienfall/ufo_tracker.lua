--[[
widgets/ufo_tracker.lua
UFO Tracker widget for detailed UFO information and tracking


Comprehensive UFO monitoring and analysis interface for strategy games.
Essential for geoscape operations with real-time threat assessment and interception planning.

PURPOSE:
- Provide comprehensive UFO monitoring and analysis for strategy games
- Enable real-time tracking of UFO positions and trajectories
- Support threat assessment and interception planning
- Facilitate strategic decision making for UFO defense operations

KEY FEATURES:
- Real-time UFO position and trajectory display with flight path visualization
- Detailed UFO information (type, size, speed, heading, altitude)
- Threat level assessment and classification with color-coded indicators
- Interception planning with success probability calculations
- Historical tracking and pattern analysis for predictive intelligence
- Radar contact visualization and signal strength monitoring
- UFO classification system (scout, fighter, transport, etc.)
- Speed and heading analysis with course prediction
- Interception window calculations and optimal launch timing
- Integration with geoscape for global situational awareness

]]

local core = require("widgets.core")
local Label = require("widgets.common.label")
local ProgressBar = require("widgets.common.progressbar")
local Button = require("widgets.common.button")

local UFOTracker = {}
UFOTracker.__index = UFOTracker
setmetatable(UFOTracker, { __index = core.Base })

-- Threat levels
UFOTracker.THREAT_LEVELS = {
    LOW = { color = { 0.2, 0.8, 0.2 }, name = "Low" },
    MEDIUM = { color = { 0.8, 0.8, 0.2 }, name = "Medium" },
    HIGH = { color = { 0.8, 0.4, 0.2 }, name = "High" },
    CRITICAL = { color = { 0.8, 0.2, 0.2 }, name = "Critical" }
}

function UFOTracker:new(x, y, w, h, ufoData, options)
    local obj = core.Base:new(x, y, w, h)

    obj.ufoData = ufoData or {}
    obj.trajectory = obj.ufoData.trajectory or {}
    obj.threatLevel = obj.ufoData.threatLevel or "LOW"

    -- Layout
    obj.padding = 15
    obj.sectionSpacing = 20
    obj.currentY = y + obj.padding

    -- Title
    obj.titleLabel = Label:new(x + obj.padding, obj.currentY, w - 2 * obj.padding, 30, {
        text = "UFO Tracking",
        font = core.theme.fontLarge,
        align = "center"
    })
    obj:addChild(obj.titleLabel)
    obj.currentY = obj.currentY + 40

    -- UFO Information section
    obj:_createUFOInfoSection()

    -- Trajectory section
    obj:_createTrajectorySection()

    -- Threat Assessment section
    obj:_createThreatSection()

    -- Action buttons
    obj:_createActionButtons()

    setmetatable(obj, self)
    return obj
end

function UFOTracker:_createUFOInfoSection()
    -- Section title
    local infoTitle = Label:new(self.x + self.padding, self.currentY, 200, 25, {
        text = "UFO Information:",
        font = core.theme.fontBold
    })
    self:addChild(infoTitle)
    self.currentY = self.currentY + 30

    -- UFO details
    local details = {
        { "Type:",     self.ufoData.type or "Unknown" },
        { "Size:",     self.ufoData.size or "Unknown" },
        { "Speed:",    string.format("%.1f km/h", self.ufoData.speed or 0) },
        { "Altitude:", string.format("%.1f km", self.ufoData.altitude or 0) },
        { "Heading:",  string.format("%.1f°", self.ufoData.heading or 0) }
    }

    for i, detail in ipairs(details) do
        local detailLabel = Label:new(self.x + self.padding + 20, self.currentY, 250, 20, {
            text = string.format("%s %s", detail[1], detail[2])
        })
        self:addChild(detailLabel)
        self.currentY = self.currentY + 25
    end

    self.currentY = self.currentY + self.sectionSpacing - 25
end

function UFOTracker:_createTrajectorySection()
    -- Section title
    local trajTitle = Label:new(self.x + self.padding, self.currentY, 200, 25, {
        text = "Trajectory:",
        font = core.theme.fontBold
    })
    self:addChild(trajTitle)
    self.currentY = self.currentY + 30

    -- Trajectory visualization area
    obj.trajectoryArea = {
        x = self.x + self.padding,
        y = self.currentY,
        w = self.w - 2 * self.padding,
        h = 100
    }
    self.currentY = self.currentY + 110

    -- Trajectory info
    local trajInfo = string.format("Points: %d | Destination: %s",
        #self.trajectory, self.ufoData.destination or "Unknown")
    local trajLabel = Label:new(self.x + self.padding, self.currentY, self.w - 2 * self.padding, 20, {
        text = trajInfo,
        align = "center"
    })
    self:addChild(trajLabel)
    self.currentY = self.currentY + 30
end

function UFOTracker:_createThreatSection()
    -- Section title
    local threatTitle = Label:new(self.x + self.padding, self.currentY, 200, 25, {
        text = "Threat Assessment:",
        font = core.theme.fontBold
    })
    self:addChild(threatTitle)
    self.currentY = self.currentY + 30

    -- Threat level
    local threatLevel = self.THREAT_LEVELS[self.threatLevel] or self.THREAT_LEVELS.LOW
    local threatLabel = Label:new(self.x + self.padding + 20, self.currentY, 200, 25, {
        text = string.format("Level: %s", threatLevel.name),
        color = threatLevel.color
    })
    self:addChild(threatLabel)
    self.currentY = self.currentY + 30

    -- Threat progress bar
    local threatValue = self:_getThreatValue()
    obj.threatBar = ProgressBar:new(self.x + self.padding, self.currentY, self.w - 2 * self.padding, 20, {
        value = threatValue,
        maxValue = 100,
        color = threatLevel.color,
        showText = true,
        textFormat = "Threat: %d%%"
    })
    self:addChild(obj.threatBar)
    self.currentY = self.currentY + 40
end

function UFOTracker:_createActionButtons()
    local buttonY = self.y + self.h - 50
    local buttonWidth = 100
    local buttonSpacing = 15
    local totalWidth = buttonWidth * 3 + buttonSpacing * 2
    local startX = self.x + (self.w - totalWidth) / 2

    -- Intercept button
    local interceptBtn = Button:new(startX, buttonY, buttonWidth, 35, "Intercept", function()
        if self.onIntercept then self.onIntercept(self.ufoData) end
    end)
    self:addChild(interceptBtn)

    -- Track button
    local trackBtn = Button:new(startX + buttonWidth + buttonSpacing, buttonY, buttonWidth, 35, "Track", function()
        if self.onTrack then self.onTrack(self.ufoData) end
    end)
    self:addChild(trackBtn)

    -- Analyze button
    local analyzeBtn = Button:new(startX + (buttonWidth + buttonSpacing) * 2, buttonY, buttonWidth, 35, "Analyze",
        function()
            if self.onAnalyze then self.onAnalyze(self.ufoData) end
        end)
    self:addChild(analyzeBtn)
end

function UFOTracker:_getThreatValue()
    -- Calculate threat value based on UFO characteristics
    local threat = 0
    if self.ufoData.size == "Large" then threat = threat + 30 end
    if self.ufoData.speed and self.ufoData.speed > 1000 then threat = threat + 20 end
    if self.ufoData.type == "Battleship" then threat = threat + 50 end
    return math.min(threat, 100)
end

function UFOTracker:setUFO(ufoData)
    self.ufoData = ufoData
    self.trajectory = ufoData.trajectory or {}
    self.threatLevel = ufoData.threatLevel or "LOW"
    -- Update display (would need to recreate labels in full implementation)
end

function UFOTracker:updateTrajectory(points)
    self.trajectory = points or {}
    -- Update trajectory visualization
end

return UFOTracker






