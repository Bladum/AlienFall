--- UnitInfoPanel Widget
--- Displays detailed information about a selected unit in the battlescape.
---
--- Shows unit face, name, and stat bars for HP, EP, MP, AP, and Morale.
--- Bottom half displays hover information. Inspired by UFO: Enemy Unknown.
---
--- @class UnitInfoPanel
--- @field unit table The unit to display information for (nil for empty panel)
--- @field statBars table Array of StatBar widgets for each stat
--- @field faceImage any Unit face image
--- @field unitName string Display name of the unit
--- @field hoverText string Text to display in bottom hover area
---
--- @usage
---   local panel = UnitInfoPanel:new({
---     x = 480, y = 24,
---     width = 240, height = 576
---   })
---   panel:setUnit(selectedUnit)
---   panel:draw()

local BaseWidget = require("gui.widgets.core.base")
local StatBar = require("gui.widgets.display.stat_bar")

local UnitInfoPanel = setmetatable({}, {__index = BaseWidget})
UnitInfoPanel.__index = UnitInfoPanel

--- Create a new UnitInfoPanel widget.
---
--- @param options table Configuration options with fields: x, y, width, height
--- @return UnitInfoPanel New UnitInfoPanel instance
function UnitInfoPanel:new(options)
    local self = BaseWidget.new(self, options)

    -- Initialize stat bars
    self.statBars = {}
    self:createStatBars()

    -- Unit data
    self.unit = nil
    self.faceImage = nil
    self.unitName = ""
    self.hoverText = "Hover over units or terrain for information"

    return self
end

--- Create the stat bar widgets for each unit stat.
--- Sets up HP, EP, MP, AP, and Morale bars with appropriate colors.
function UnitInfoPanel:createStatBars()
    local theme = require("gui.widgets.theme")
    local barY = self.y + 72  -- Start below face/name area
    local barHeight = 24
    local barSpacing = 4

    -- Stat bar configurations
    local statConfigs = {
        {label = "HP", color = {1, 0, 0}},     -- Red for health
        {label = "EP", color = {0, 0.5, 1}},   -- Blue for energy
        {label = "MP", color = {0, 0.8, 0}},   -- Green for movement
        {label = "AP", color = {0, 1, 1}},     -- Cyan for actions
        {label = "Morale", color = {1, 0, 1}}  -- Magenta for morale
    }

    for i, config in ipairs(statConfigs) do
        local bar = StatBar:new({
            label = config.label,
            current = 0,
            max = 10,
            color = config.color,
            x = self.x + 8,
            y = barY + (i - 1) * (barHeight + barSpacing),
            width = self.width - 16,
            height = barHeight
        })
        table.insert(self.statBars, bar)
    end
end

--- Set the unit to display information for.
--- Updates all stat bars and loads unit face image.
---
--- @param unit table The unit entity to display (nil to clear panel)
function UnitInfoPanel:setUnit(unit)
    self.unit = unit

    if unit then
        self.unitName = unit.name or "Unknown Unit"

        -- Load face image
        self.faceImage = nil
        if unit.faceImage then
            local Assets = require("core.assets")
            self.faceImage = Assets:getImage(unit.faceImage)
        end

        -- Update stat bars
        if unit.stats then
            local stats = unit.stats
            self.statBars[1]:setValues(stats.health or 0, stats.maxHealth or 10)  -- HP
            self.statBars[2]:setValues(stats.energy or 0, stats.maxEnergy or 10)  -- EP
            self.statBars[3]:setValues(unit.movementPoints or 0, unit.maxMovementPoints or 10)  -- MP
            self.statBars[4]:setValues(unit.actionPoints or 0, unit.maxActionPoints or 4)  -- AP
            self.statBars[5]:setValues(stats.morale or 0, 10)  -- Morale
        end
    else
        -- Clear panel
        self.unitName = ""
        self.faceImage = nil
        for _, bar in ipairs(self.statBars) do
            bar:setValues(0, 10)
        end
    end
end

--- Set the hover text to display in the bottom area.
---
--- @param text string The hover information text
function UnitInfoPanel:setHoverText(text)
    self.hoverText = text or "Hover over units or terrain for information"
end

--- Render the unit info panel.
--- Draws the panel background, unit face, name, stat bars, and hover text.
function UnitInfoPanel:draw()
    if not self.visible then return end

    local theme = require("gui.widgets.theme")

    -- Panel background
    love.graphics.setColor(theme.colors.panelBackground or {0.1, 0.1, 0.15})
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Panel border
    love.graphics.setColor(theme.colors.border)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    if self.unit then
        -- Unit face (top-left)
        if self.faceImage then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.faceImage, self.x + 8, self.y + 8, 0, 48/self.faceImage:getWidth(), 48/self.faceImage:getHeight())
        end

        -- Unit name (top-right of face)
        love.graphics.setColor(theme.colors.text)
        love.graphics.setFont(theme.fonts.default)
        love.graphics.print(self.unitName, self.x + 64, self.y + 20)

        -- Draw stat bars
        for _, bar in ipairs(self.statBars) do
            bar:draw()
        end
    else
        -- Empty panel message
        love.graphics.setColor(theme.colors.textSecondary or {0.5, 0.5, 0.5})
        love.graphics.setFont(theme.fonts.small)
        local emptyText = "No unit selected"
        local textWidth = theme.fonts.small:getWidth(emptyText)
        love.graphics.print(emptyText, self.x + (self.width - textWidth) / 2, self.y + 100)
    end

    -- Hover text area (bottom half)
    local hoverY = self.y + self.height / 2 + 8
    love.graphics.setColor(theme.colors.text)
    love.graphics.setFont(theme.fonts.small)

    -- Word wrap hover text
    local wrappedText = self:wrapText(self.hoverText, self.width - 16)
    for i, line in ipairs(wrappedText) do
        love.graphics.print(line, self.x + 8, hoverY + (i - 1) * 16)
    end
end

--- Simple text wrapping utility.
---
--- @param text string Text to wrap
--- @param maxWidth number Maximum width in pixels
--- @return table Array of wrapped text lines
function UnitInfoPanel:wrapText(text, maxWidth)
    local theme = require("gui.widgets.theme")
    local font = theme.fonts.small
    local lines = {}
    local currentLine = ""

    for word in text:gmatch("%S+") do
        local testLine = currentLine .. (currentLine == "" and "" or " ") .. word
        if font:getWidth(testLine) > maxWidth then
            if currentLine ~= "" then
                table.insert(lines, currentLine)
                currentLine = word
            else
                table.insert(lines, word)
                currentLine = ""
            end
        else
            currentLine = testLine
        end
    end

    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end

    return lines
end

return UnitInfoPanel


























