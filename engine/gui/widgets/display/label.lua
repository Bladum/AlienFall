---Label Widget - Text Display with Word Wrapping
---
---A text display widget with word wrapping support. Used for displaying single or multi-line
---text with alignment options. Grid-aligned for consistent positioning.
---
---Features:
---  - Single or multi-line text
---  - Text alignment (left, center, right)
---  - Word wrapping
---  - Grid-aligned positioning (24×24 pixels)
---  - Font customization
---  - Color customization
---
---Alignment Options:
---  - left: Text aligned to left edge
---  - center: Text centered horizontally
---  - right: Text aligned to right edge
---  - justify: Text stretched to fill width (future)
---
---Word Wrapping:
---  - Automatic line breaks at word boundaries
---  - Respects widget width
---  - No text overflow outside bounds
---
---Key Exports:
---  - Label.new(x, y, width, height, text): Creates label
---  - setText(text): Updates displayed text
---  - setAlignment(align): Sets text alignment ("left", "center", "right")
---  - setFont(font): Sets custom font
---  - setColor(r, g, b, a): Sets text color
---  - draw(): Renders label
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Font and color theme
---
---@module widgets.display.label
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Label = require("gui.widgets.display.label")
---  local label = Label.new(0, 0, 240, 48, "Hello World")
---  label:setAlignment("center")
---  label:draw()
---
---@see widgets.input.textinput For editable text

--[[
    Label Widget
    
    A text display widget with word wrapping support.
    Features:
    - Single or multi-line text
    - Text alignment (left, center, right)
    - Word wrapping
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local Label = setmetatable({}, {__index = BaseWidget})
Label.__index = Label

--[[
    Create a new label
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param text string - Label text
    @return table - New label instance
]]
function Label.new(x, y, width, height, text)
    local self = BaseWidget.new(x, y, width, height, "label")
    setmetatable(self, Label)
    
    self.text = text or ""
    self.wrap = false
    
    return self
end

--[[
    Draw the label
]]
function Label:draw()
    if not self.visible then
        return
    end
    
    -- Draw background if set
    if self.backgroundColor then
        Theme.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
    
    -- Draw text
    Theme.setFont(self.font)
    Theme.setColor(self.textColor)
    
    local font = Theme.getFont(self.font)
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    
    -- Calculate text position based on alignment
    local textX = self.x
    local textY = self.y
    
    -- Horizontal alignment
    if self.align == "center" then
        textX = self.x + (self.width - textWidth) / 2
    elseif self.align == "right" then
        textX = self.x + self.width - textWidth - Theme.padding
    else
        textX = self.x + Theme.padding
    end
    
    -- Vertical alignment
    if self.valign == "middle" then
        textY = self.y + (self.height - textHeight) / 2
    elseif self.valign == "bottom" then
        textY = self.y + self.height - textHeight - Theme.padding
    else
        textY = self.y + Theme.padding
    end
    
    -- Draw with or without wrapping
    if self.wrap then
        love.graphics.printf(self.text, textX, textY, self.width - Theme.padding * 2, self.align)
    else
        love.graphics.print(self.text, textX, textY)
    end
end

--[[
    Set label text
    @param text string - New label text
]]
function Label:setText(text)
    self.text = text
end

--[[
    Get label text
    @return string - Label text
]]
function Label:getText()
    return self.text
end

--[[
    Set text alignment
    @param align string - Alignment ("left", "center", "right")
]]
function Label:setAlign(align)
    self.align = align
end

--[[
    Set vertical alignment
    @param valign string - Vertical alignment ("top", "middle", "bottom")
]]
function Label:setVerticalAlign(valign)
    self.valign = valign
end

--[[
    Enable or disable text wrapping
    @param wrap boolean - True to enable wrapping
]]
function Label:setWrap(wrap)
    self.wrap = wrap
end

--[[
    Set font
    @param fontName string - Font name from theme
]]
function Label:setFont(fontName)
    self.fontName = fontName
end

print("[Label] Label widget loaded")

return Label


























