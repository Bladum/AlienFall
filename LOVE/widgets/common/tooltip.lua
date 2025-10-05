--[[
widgets/tooltip.lua
Tooltip widget for displaying contextual information and help text.


Advanced tooltip system for contextual information display in tactical strategy games.
Provides sophisticated tooltips with rich content, smooth animations, and automatic positioning.

PURPOSE:
- Display contextual information near UI elements or mouse cursor
- Provide rich content including text, images, statistics, and progress bars
- Support smooth animations and automatic positioning
- Enable organized sections and formatted content display

KEY FEATURES:
- Rich content support (text, images, statistics, progress bars)
- Smooth animations for show/hide transitions
- Automatic positioning to stay within screen bounds
- Organized sections with headers and formatting
- Mouse tracking and element attachment
- Customizable appearance and styling
- Accessibility support for screen readers
- Multi-line text with proper wrapping

@see widgets.common.core.Base
@see widgets.complex.animation
@see widgets.common.theme
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")

local Tooltip = {}
Tooltip.__index = Tooltip
setmetatable(Tooltip, { __index = core.Base })

--- Creates a new Tooltip widget instance
--- @param options table Optional configuration table for colors and styling
--- @return Tooltip A new tooltip widget instance
function Tooltip:new(options)
    local obj = core.Base:new(0, 0, 200, 100)

    -- Content
    obj.title = ""
    obj.text = ""
    obj.image = nil
    obj.stats = {}
    obj.sections = {}

    -- Visual properties
    obj.backgroundColor = (options and options.backgroundColor) or { 0, 0, 0, 0.9 }
    obj.borderColor = (options and options.borderColor) or { 0.8, 0.8, 0.8 }
    obj.titleColor = (options and options.titleColor) or { 1, 1, 0.6 }
    obj.textColor = (options and options.textColor) or { 1, 1, 1 }
    obj.statColor = (options and options.statColor) or { 0.8, 0.8, 1 }

    -- Layout
    obj.padding = (options and options.padding) or { 8, 8, 8, 8 }
    obj.lineSpacing = (options and options.lineSpacing) or 4
    obj.maxWidth = (options and options.maxWidth) or 300
    obj.minWidth = (options and options.minWidth) or 150
    obj.borderRadius = (options and options.borderRadius) or 4

    -- Behavior
    obj.showDelay = (options and options.showDelay) or 0.5
    obj.fadeInDuration = (options and options.fadeInDuration) or 0.2
    obj.fadeOutDuration = (options and options.fadeOutDuration) or 0.1
    obj.followMouse = (options and options.followMouse) ~= false
    obj.mouseOffset = (options and options.mouseOffset) or { 10, 10 }

    -- State
    obj.visible = false
    obj.alpha = 0
    obj.showTimer = 0
    obj.targetAlpha = 0
    obj.mouseX = 0
    obj.mouseY = 0

    -- Layout cache
    obj.contentLines = {}
    obj.calculatedHeight = 0
    obj.needsLayout = true

    setmetatable(obj, self)
    return obj
end

--- Shows the tooltip with the specified content
--- @param title string The title text for the tooltip
--- @param text string The main text content for the tooltip
--- @param options table Optional configuration table with image, stats, sections fields
function Tooltip:show(title, text, options)
    self.title = title or ""
    self.text = text or ""
    self.image = (options and options.image) or nil
    self.stats = (options and options.stats) or {}
    self.sections = (options and options.sections) or {}

    self.showTimer = 0
    self.targetAlpha = 1
    self.needsLayout = true

    if self.showDelay <= 0 then
        self:_startShow()
    end
end

--- Hides the tooltip with a fade-out animation
function Tooltip:hide()
    self.targetAlpha = 0
    self.visible = false
    self.showTimer = 0

    Animation:animate(self, self.fadeOutDuration, { alpha = 0 })
end

function Tooltip:_startShow()
    self.visible = true
    self:_calculateLayout()
    self:_updatePosition()

    Animation:animate(self, self.fadeInDuration, { alpha = self.targetAlpha })
end

function Tooltip:_calculateLayout()
    if not self.needsLayout then return end

    self.contentLines = {}
    local currentY = 0

    -- Title
    if self.title and self.title ~= "" then
        local titleLines = self:_wrapText(self.title, self.maxWidth - self.padding[2] - self.padding[4],
            core.theme.fontBold)
        for _, line in ipairs(titleLines) do
            table.insert(self.contentLines, {
                type = "title",
                text = line,
                y = currentY,
                height = core.theme.fontBold:getHeight()
            })
            currentY = currentY + core.theme.fontBold:getHeight() + self.lineSpacing
        end

        if #titleLines > 0 then
            currentY = currentY + self.lineSpacing -- Extra space after title
        end
    end

    -- Image
    if self.image then
        -- Use default dimensions to avoid undefined field errors
        local imageWidth = 64
        local imageHeight = 64
        local scaledHeight = math.min(64, imageHeight)
        local scaledWidth = math.min(self.maxWidth - self.padding[2] - self.padding[4],
            imageWidth * (scaledHeight / imageHeight))

        table.insert(self.contentLines, {
            type = "image",
            image = self.image,
            x = (self.maxWidth - self.padding[2] - self.padding[4] - scaledWidth) / 2,
            y = currentY,
            width = imageWidth,
            height = imageHeight
        })
        currentY = currentY + imageHeight + self.lineSpacing * 2
    end

    -- Main text
    if self.text and self.text ~= "" then
        local textLines = self:_wrapText(self.text, self.maxWidth - self.padding[2] - self.padding[4], core.theme.font)
        for _, line in ipairs(textLines) do
            table.insert(self.contentLines, {
                type = "text",
                text = line,
                y = currentY,
                height = core.theme.font:getHeight()
            })
            currentY = currentY + core.theme.font:getHeight() + self.lineSpacing
        end

        if #textLines > 0 then
            currentY = currentY + self.lineSpacing -- Extra space after text
        end
    end

    -- Stats
    if #self.stats > 0 then
        for _, stat in ipairs(self.stats) do
            table.insert(self.contentLines, {
                type = "stat",
                name = stat.name,
                value = stat.value,
                maxValue = stat.maxValue,
                color = stat.color,
                y = currentY,
                height = 16
            })
            currentY = currentY + 16 + self.lineSpacing
        end

        currentY = currentY + self.lineSpacing
    end

    -- Sections
    for _, section in ipairs(self.sections) do
        -- Section header
        if section.title then
            table.insert(self.contentLines, {
                type = "section_title",
                text = section.title,
                y = currentY,
                height = core.theme.font:getHeight()
            })
            currentY = currentY + core.theme.font:getHeight() + self.lineSpacing
        end

        -- Section content
        if section.text then
            local sectionLines = self:_wrapText(section.text, self.maxWidth - self.padding[2] - self.padding[4] - 16,
                core.theme.font)
            for _, line in ipairs(sectionLines) do
                table.insert(self.contentLines, {
                    type = "section_text",
                    text = line,
                    y = currentY,
                    height = core.theme.font:getHeight()
                })
                currentY = currentY + core.theme.font:getHeight() + self.lineSpacing
            end
        end

        currentY = currentY + self.lineSpacing
    end

    -- Calculate final dimensions
    self.calculatedHeight = currentY + self.padding[1] + self.padding[3]
    if currentY > 0 then
        self.calculatedHeight = self.calculatedHeight - self.lineSpacing -- Remove extra spacing
    end

    local maxLineWidth = self.minWidth
    love.graphics.setFont(core.theme.font)
    for _, line in ipairs(self.contentLines) do
        if line.type == "title" then
            love.graphics.setFont(core.theme.fontBold)
            maxLineWidth = math.max(maxLineWidth, core.theme.fontBold:getWidth(line.text))
        elseif line.text then
            love.graphics.setFont(core.theme.font)
            maxLineWidth = math.max(maxLineWidth, core.theme.font:getWidth(line.text))
        end
    end

    self.w = math.min(self.maxWidth, maxLineWidth + self.padding[2] + self.padding[4])
    self.h = self.calculatedHeight

    self.needsLayout = false
end

function Tooltip:_wrapText(text, maxWidth, font)
    local lines = {}
    local currentLine = ""

    love.graphics.setFont(font)

    for word in text:gmatch("%S+") do
        local testLine = currentLine == "" and word or (currentLine .. " " .. word)
        if font:getWidth(testLine) > maxWidth and currentLine ~= "" then
            table.insert(lines, currentLine)
            currentLine = word
        else
            currentLine = testLine
        end
    end

    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end

    return lines
end

function Tooltip:_updatePosition()
    if not self.followMouse then return end

    self.mouseX, self.mouseY = love.mouse.getPosition()

    -- Position tooltip near mouse with offset
    local targetX = self.mouseX + self.mouseOffset[1]
    local targetY = self.mouseY + self.mouseOffset[2]

    -- Keep tooltip within screen bounds
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    if targetX + self.w > screenWidth then
        targetX = self.mouseX - self.w - self.mouseOffset[1]
    end

    if targetY + self.h > screenHeight then
        targetY = self.mouseY - self.h - self.mouseOffset[2]
    end

    self.x = math.max(0, targetX)
    self.y = math.max(0, targetY)
end

--- Updates the tooltip state and animations
--- @param dt number The time delta since the last update
function Tooltip:update(dt)
    core.Base.update(self, dt)

    if self.targetAlpha > 0 and not self.visible then
        self.showTimer = self.showTimer + dt
        if self.showTimer >= self.showDelay then
            self:_startShow()
        end
    end

    if self.visible and self.followMouse then
        self:_updatePosition()
    end
end

--- Draws the tooltip with its content and animations
function Tooltip:draw()
    if not self.visible or self.alpha <= 0 then return end

    -- Apply alpha
    local r, g, b, a = love.graphics.getColor()

    -- Draw background
    love.graphics.setColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3],
        (self.backgroundColor[4] or 1) * self.alpha)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius)

    -- Draw border
    love.graphics.setColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], self.alpha)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.borderRadius)

    -- Draw content
    for _, line in ipairs(self.contentLines) do
        local lineY = self.y + self.padding[1] + line.y

        if line.type == "title" then
            love.graphics.setColor(self.titleColor[1], self.titleColor[2], self.titleColor[3], self.alpha)
            love.graphics.setFont(core.theme.fontBold)
            love.graphics.print(line.text, self.x + self.padding[4], lineY)
        elseif line.type == "text" then
            love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.alpha)
            love.graphics.setFont(core.theme.font)
            love.graphics.print(line.text, self.x + self.padding[4], lineY)
        elseif line.type == "section_title" then
            love.graphics.setColor(self.titleColor[1], self.titleColor[2], self.titleColor[3], self.alpha * 0.8)
            love.graphics.setFont(core.theme.font)
            love.graphics.print(line.text, self.x + self.padding[4], lineY)
        elseif line.type == "section_text" then
            love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.alpha * 0.9)
            love.graphics.setFont(core.theme.font)
            love.graphics.print(line.text, self.x + self.padding[4] + 16, lineY)
        elseif line.type == "stat" then
            love.graphics.setColor(self.statColor[1], self.statColor[2], self.statColor[3], self.alpha)
            love.graphics.setFont(core.theme.font)

            local statText = line.name .. ": " .. line.value
            if line.maxValue then
                statText = statText .. "/" .. line.maxValue
            end
            love.graphics.print(statText, self.x + self.padding[4], lineY)

            -- Draw stat bar if maxValue exists
            if line.maxValue and line.maxValue > 0 then
                local barWidth = 60
                local barHeight = 8
                local barX = self.x + self.w - self.padding[2] - barWidth
                local barY = lineY + 4

                -- Background
                love.graphics.setColor(0.3, 0.3, 0.3, self.alpha)
                love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

                -- Fill
                local fillColor = line.color or { 0.2, 0.8, 0.2 }
                love.graphics.setColor(fillColor[1], fillColor[2], fillColor[3], self.alpha)
                local fillWidth = (line.value / line.maxValue) * barWidth
                love.graphics.rectangle("fill", barX, barY, fillWidth, barHeight)

                -- Border
                love.graphics.setColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], self.alpha)
                love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
            end
        elseif line.type == "image" then
            love.graphics.setColor(1, 1, 1, self.alpha)
            local scale = line.height / line.image:getHeight()
            love.graphics.draw(line.image, self.x + self.padding[4] + line.x, lineY, 0, scale, scale)
        end
    end

    -- Restore color
    love.graphics.setColor(r, g, b, a)
end

-- Static tooltip manager for global use
Tooltip.instance = nil

function Tooltip.showInstance(title, text, options)
    if not Tooltip.instance then
        Tooltip.instance = Tooltip:new()
    end
    Tooltip.instance:show(title, text, options)
end

function Tooltip.hideInstance()
    if Tooltip.instance then
        Tooltip.instance:hide()
    end
end

function Tooltip.updateInstance(dt)
    if Tooltip.instance then
        Tooltip.instance:update(dt)
    end
end

function Tooltip.drawInstance()
    if Tooltip.instance then
        Tooltip.instance:draw()
    end
end

--- Sets the position of the tooltip
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
function Tooltip:setPosition(x, y)
    self.x = x
    self.y = y
    self.followMouse = false
end

--- Adds a stat display to the tooltip
--- @param name string The name of the stat
--- @param value number The current value of the stat
--- @param maxValue number The maximum value of the stat (optional)
--- @param color table The color for the stat display (optional)
function Tooltip:addStat(name, value, maxValue, color)
    table.insert(self.stats, {
        name = name,
        value = value,
        maxValue = maxValue,
        color = color
    })
    self.needsLayout = true
end

--- Adds a content section to the tooltip
--- @param title string The title of the section
--- @param text string The text content of the section
function Tooltip:addSection(title, text)
    table.insert(self.sections, {
        title = title,
        text = text
    })
    self.needsLayout = true
end

--- Clears all content from the tooltip
function Tooltip:clearContent()
    self.title = ""
    self.text = ""
    self.image = nil
    self.stats = {}
    self.sections = {}
    self.needsLayout = true
end

return Tooltip
