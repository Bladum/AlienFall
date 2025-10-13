--[[
    Action Button Widget

    A specialized button for action panels with radio button behavior.
    Features:
    - Radio button group support (only one selected at a time)
    - Selected state highlighting
    - Icon + text support
    - Tooltip on hover
    - Enabled/disabled states
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local ActionButton = setmetatable({}, {__index = BaseWidget})
ActionButton.__index = ActionButton

--[[
    Create a new action button
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param actionId string - Unique action identifier
    @param text string - Button label text
    @param icon string - Optional icon identifier
    @return table - New action button instance
]]
function ActionButton.new(x, y, width, height, actionId, text, icon)
    local self = BaseWidget.new(x, y, width, height, "action_button")
    setmetatable(self, ActionButton)

    self.actionId = actionId
    self.text = text or ""
    self.icon = icon or nil
    self.tooltip = nil
    self.selected = false
    self.pressed = false
    self.radioGroup = nil  -- Reference to parent radio group

    return self
end

--[[
    Set the radio group this button belongs to
    @param radioGroup table - The radio group container
]]
function ActionButton:setRadioGroup(radioGroup)
    self.radioGroup = radioGroup
end

--[[
    Set selected state (for radio button behavior)
    @param selected boolean - Whether this button is selected
]]
function ActionButton:setSelected(selected)
    if self.selected ~= selected then
        self.selected = selected
        if self.onSelectionChanged then
            self.onSelectionChanged(self, selected)
        end
    end
end

--[[
    Get selected state
    @return boolean - Whether this button is selected
]]
function ActionButton:isSelected()
    return self.selected
end

--[[
    Set tooltip text
    @param tooltip string - Tooltip text to show on hover
]]
function ActionButton:setTooltip(tooltip)
    self.tooltip = tooltip
end

--[[
    Draw the action button
]]
function ActionButton:draw()
    if not self.visible then
        return
    end

    -- Determine button color based on state
    local bgColor, borderColor, textColor

    if not self.enabled then
        bgColor = Theme.colors.disabled
        borderColor = Theme.colors.disabledBorder
        textColor = Theme.colors.disabledText
    elseif self.selected then
        bgColor = Theme.colors.selected
        borderColor = Theme.colors.selectedBorder
        textColor = Theme.colors.selectedText
    elseif self.pressed then
        bgColor = Theme.colors.active
        borderColor = Theme.colors.activeBorder
        textColor = Theme.colors.activeText
    elseif self.hovered then
        bgColor = Theme.colors.hover
        borderColor = Theme.colors.hoverBorder
        textColor = Theme.colors.hoverText
    else
        bgColor = Theme.colors.button
        borderColor = Theme.colors.buttonBorder
        textColor = Theme.colors.buttonText
    end

    -- Draw background
    Theme.setColor(bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw border
    Theme.setColor(borderColor)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw selection indicator (extra border for selected state)
    if self.selected then
        Theme.setColor(Theme.colors.accent)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", self.x + 1, self.y + 1, self.width - 2, self.height - 2)
    end

    -- Draw icon if present
    local textX = self.x
    local textY = self.y
    local availableWidth = self.width

    if self.icon then
        -- TODO: Implement icon drawing when icon system is available
        -- For now, just adjust text positioning
        textX = textX + 4
        availableWidth = availableWidth - 8
    end

    -- Draw text
    Theme.setFont(Theme.fonts.button)
    Theme.setColor(textColor)

    local font = Theme.getFont(Theme.fonts.button)
    if font then
        local textWidth = font:getWidth(self.text)
        local textHeight = font:getHeight()

        -- Center text horizontally and vertically
        textX = textX + (availableWidth - textWidth) / 2
        textY = self.y + (self.height - textHeight) / 2

        love.graphics.print(self.text, textX, textY)
    end

    -- Draw tooltip if hovered
    if self.hovered and self.tooltip then
        self:drawTooltip()
    end
end

--[[
    Draw tooltip when hovered
]]
function ActionButton:drawTooltip()
    if not self.tooltip then return end

    local font = Theme.getFont(Theme.fonts.tooltip)
    if not font then return end

    local textWidth = font:getWidth(self.tooltip)
    local textHeight = font:getHeight()
    local padding = 4

    -- Position tooltip above button, centered
    local tooltipX = self.x + (self.width - textWidth - padding * 2) / 2
    local tooltipY = self.y - textHeight - padding * 2 - 4

    -- Ensure tooltip stays on screen
    if love and love.graphics then
        tooltipX = math.max(0, math.min(tooltipX, love.graphics.getWidth() - textWidth - padding * 2))
    end
    tooltipY = math.max(0, tooltipY)

    -- Draw tooltip background
    Theme.setColor(Theme.colors.tooltipBackground)
    love.graphics.rectangle("fill", tooltipX, tooltipY, textWidth + padding * 2, textHeight + padding * 2)

    -- Draw tooltip border
    Theme.setColor(Theme.colors.tooltipBorder)
    love.graphics.rectangle("line", tooltipX, tooltipY, textWidth + padding * 2, textHeight + padding * 2)

    -- Draw tooltip text
    Theme.setFont(Theme.fonts.tooltip)
    Theme.setColor(Theme.colors.tooltipText)
    love.graphics.print(self.tooltip, tooltipX + padding, tooltipY + padding)
end

--[[
    Handle mouse press
]]
function ActionButton:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end

    if self:containsPoint(x, y) and button == 1 then
        self.pressed = true

        -- Handle radio button behavior
        if self.radioGroup and not self.selected then
            self.radioGroup:selectButton(self)
        end

        return true
    end

    return false
end

--[[
    Handle mouse release
]]
function ActionButton:mousereleased(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end

    if self.pressed and button == 1 then
        self.pressed = false

        if self:containsPoint(x, y) then
            -- Call selection callback if this is a radio button selection
            if self.onSelect then
                self.onSelect(self)
            end

            -- Call click callback
            if self.onClick then
                self.onClick(self, x, y)
            end
        end

        return true
    end

    return false
end

--[[
    Set button text
    @param text string - New button text
]]
function ActionButton:setText(text)
    self.text = text or ""
end

--[[
    Get button text
    @return string - Button text
]]
function ActionButton:getText()
    return self.text
end

print("[ActionButton] Action button widget loaded")

return ActionButton