--[[
widgets/complex/rangeslider.lua
Range slider widget with dual handles for selecting ranges


The RangeSlider widget provides an interactive control for selecting numeric
ranges with two handles (minimum and maximum values). It supports dragging
individual handles, dragging the entire range, snapping to grid values,
animations, and comprehensive customization options.

PURPOSE:
- Provide an interactive control for selecting numeric ranges with dual handles
- Support dragging individual handles, range dragging, and grid snapping
- Enable smooth animations, tooltips, labels, and keyboard navigation
- Offer customizable appearance, callbacks, and accessibility features

KEY FEATURES:
- Dual handles for minimum and maximum value selection
- Range dragging (move entire selected range)
- Grid snapping for precise values
- Smooth animations and hover effects
- Tooltips showing current values
- Labels for min/max/current values
- Keyboard navigation support
- Customizable colors and appearance
- Callback system for value changes
- Focus management and accessibility

@see Slider
@see NumericInput
]]

local core = require("widgets.core")

-- RangeSlider class definition
local RangeSlider = {}
RangeSlider.__index = RangeSlider

function RangeSlider:new(x, y, w, h, min, max, valueMin, valueMax, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    obj.min = min or 0
    obj.max = max or 100
    obj.valueMin = valueMin or min or 0
    obj.valueMax = valueMax or max or 100

    -- Ensure values are in correct order
    if obj.valueMin > obj.valueMax then
        obj.valueMin, obj.valueMax = obj.valueMax, obj.valueMin
    end

    -- Drag state
    obj.dragging = nil -- nil, "min", "max", or "range"
    obj.dragStart = { x = 0, value = 0 }

    -- Visual options
    obj.handleRadius = options.handleRadius or 12
    obj.trackHeight = options.trackHeight or 6
    obj.showLabels = options.showLabels ~= false
    obj.showTooltips = options.showTooltips ~= false
    obj.snapToGrid = options.snapToGrid
    obj.gridSize = options.gridSize or 1

    -- Events
    obj.onMinChange = options.onMinChange
    obj.onMaxChange = options.onMaxChange
    obj.onRangeChange = options.onRangeChange

    -- Colors
    obj.colors = {
        track = options.colors and options.colors.track or core.theme.secondary,
        range = options.colors and options.colors.range or core.theme.accent,
        handle = options.colors and options.colors.handle or core.theme.primary,
        handleHover = options.colors and options.colors.handleHover or core.theme.primaryHover,
        border = options.colors and options.colors.border or core.theme.border,
        text = options.colors and options.colors.text or core.theme.text
    }

    -- Animation
    obj.animations = {
        minHandle = { scale = 1, targetScale = 1 },
        maxHandle = { scale = 1, targetScale = 1 }
    }

    setmetatable(obj, self)
    return obj
end

function RangeSlider:update(dt)
    core.Base.update(self, dt)

    local mx, my = love.mouse.getPosition()

    -- Handle dragging
    if self.dragging then
        local newValue = self:_positionToValue(mx)
        newValue = self:_snapValue(newValue)

        if self.dragging == "min" then
            self.valueMin = math.max(self.min, math.min(newValue, self.valueMax))
            if self.onMinChange then self.onMinChange(self.valueMin) end
        elseif self.dragging == "max" then
            self.valueMax = math.min(self.max, math.max(newValue, self.valueMin))
            if self.onMaxChange then self.onMaxChange(self.valueMax) end
        elseif self.dragging == "range" then
            local delta = newValue - self.dragStart.value
            local rangeSize = self.valueMax - self.valueMin

            self.valueMin = math.max(self.min, math.min(self.max - rangeSize, self.dragStart.valueMin + delta))
            self.valueMax = self.valueMin + rangeSize
        end

        if self.onRangeChange then
            self.onRangeChange(self.valueMin, self.valueMax)
        end
    end

    -- Handle hover animations
    local minHandlePos = self:_valueToPosition(self.valueMin)
    local maxHandlePos = self:_valueToPosition(self.valueMax)
    local trackY = self.y + self.h / 2

    local minHover = self:_pointInHandle(mx, my, minHandlePos, trackY)
    local maxHover = self:_pointInHandle(mx, my, maxHandlePos, trackY)

    -- Animate handle scales
    local targetMinScale = minHover and 1.2 or 1
    local targetMaxScale = maxHover and 1.2 or 1

    if self.animations.minHandle.targetScale ~= targetMinScale then
        self.animations.minHandle.targetScale = targetMinScale
        Animation.animateWidget(self.animations.minHandle, "scale", targetMinScale, 0.15, Animation.types.EASE_OUT)
    end

    if self.animations.maxHandle.targetScale ~= targetMaxScale then
        self.animations.maxHandle.targetScale = targetMaxScale
        Animation.animateWidget(self.animations.maxHandle, "scale", targetMaxScale, 0.15, Animation.types.EASE_OUT)
    end
end

function RangeSlider:draw()
    core.Base.draw(self)

    local trackY = self.y + self.h / 2
    local minPos = self:_valueToPosition(self.valueMin)
    local maxPos = self:_valueToPosition(self.valueMax)

    -- Track background
    love.graphics.setColor(unpack(self.colors.track))
    love.graphics.rectangle("fill", self.x, trackY - self.trackHeight / 2, self.w, self.trackHeight)

    -- Range fill
    love.graphics.setColor(unpack(self.colors.range))
    love.graphics.rectangle("fill", minPos, trackY - self.trackHeight / 2, maxPos - minPos, self.trackHeight)

    -- Min handle
    self:_drawHandle(minPos, trackY, self.animations.minHandle.scale, "min")

    -- Max handle
    self:_drawHandle(maxPos, trackY, self.animations.maxHandle.scale, "max")

    -- Labels
    if self.showLabels then
        self:_drawLabels()
    end

    -- Tooltips
    if self.showTooltips and (self.dragging or self.hovered) then
        self:_drawTooltips()
    end

    -- Focus ring
    if self.focused then
        love.graphics.setColor(unpack(core.focus.focusRingColor))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", self.x - 2, self.y - 2, self.w + 4, self.h + 4)
        love.graphics.setLineWidth(1)
    end
end

function RangeSlider:_drawHandle(x, y, scale, type)
    local radius = self.handleRadius * scale
    local mx, my = love.mouse.getPosition()
    local isHover = self:_pointInHandle(mx, my, x, y)

    -- Handle shadow
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.circle("fill", x + 1, y + 1, radius)

    -- Handle background
    local handleColor = isHover and self.colors.handleHover or self.colors.handle
    love.graphics.setColor(unpack(handleColor))
    love.graphics.circle("fill", x, y, radius)

    -- Handle border
    love.graphics.setColor(unpack(self.colors.border))
    love.graphics.circle("line", x, y, radius)

    -- Handle indicator
    love.graphics.setColor(unpack(self.colors.text))
    love.graphics.circle("fill", x, y, radius * 0.3)
end

function RangeSlider:_drawLabels()
    love.graphics.setColor(unpack(self.colors.text))
    local font = love.graphics.getFont()

    -- Min label
    local minText = string.format("%.1f", self.valueMin)
    local minWidth = font:getWidth(minText)
    love.graphics.print(minText, self.x, self.y + self.h + 5)

    -- Max label
    local maxText = string.format("%.1f", self.valueMax)
    local maxWidth = font:getWidth(maxText)
    love.graphics.print(maxText, self.x + self.w - maxWidth, self.y + self.h + 5)

    -- Range label (center)
    local rangeText = string.format("Range: %.1f", self.valueMax - self.valueMin)
    local rangeWidth = font:getWidth(rangeText)
    love.graphics.print(rangeText, self.x + self.w / 2 - rangeWidth / 2, self.y - font:getHeight() - 5)
end

function RangeSlider:_drawTooltips()
    local mx, my = love.mouse.getPosition()
    local trackY = self.y + self.h / 2
    local minPos = self:_valueToPosition(self.valueMin)
    local maxPos = self:_valueToPosition(self.valueMax)

    -- Tooltip background
    love.graphics.setColor(0, 0, 0, 0.8)

    if self:_pointInHandle(mx, my, minPos, trackY) then
        local text = string.format("Min: %.1f", self.valueMin)
        local font = love.graphics.getFont()
        local w, h = font:getWidth(text) + 10, font:getHeight() + 6
        love.graphics.rectangle("fill", mx - w / 2, my - h - 10, w, h)
        love.graphics.setColor(unpack(self.colors.text))
        love.graphics.print(text, mx - font:getWidth(text) / 2, my - h - 7)
    elseif self:_pointInHandle(mx, my, maxPos, trackY) then
        local text = string.format("Max: %.1f", self.valueMax)
        local font = love.graphics.getFont()
        local w, h = font:getWidth(text) + 10, font:getHeight() + 6
        love.graphics.rectangle("fill", mx - w / 2, my - h - 10, w, h)
        love.graphics.setColor(unpack(self.colors.text))
        love.graphics.print(text, mx - font:getWidth(text) / 2, my - h - 7)
    end
end

function RangeSlider:mousepressed(x, y, button)
    if button ~= 1 or not self:hitTest(x, y) then return false end

    local trackY = self.y + self.h / 2
    local minPos = self:_valueToPosition(self.valueMin)
    local maxPos = self:_valueToPosition(self.valueMax)

    -- Check handle hits
    if self:_pointInHandle(x, y, minPos, trackY) then
        self.dragging = "min"
        core.setFocus(self)
        return true
    elseif self:_pointInHandle(x, y, maxPos, trackY) then
        self.dragging = "max"
        core.setFocus(self)
        return true
    elseif x >= minPos and x <= maxPos and math.abs(y - trackY) <= self.trackHeight then
        -- Clicked on range - drag entire range
        self.dragging = "range"
        self.dragStart = {
            x = x,
            value = self:_positionToValue(x),
            valueMin = self.valueMin,
            valueMax = self.valueMax
        }
        core.setFocus(self)
        return true
    else
        -- Clicked on track - jump nearest handle
        local value = self:_positionToValue(x)
        local distToMin = math.abs(value - self.valueMin)
        local distToMax = math.abs(value - self.valueMax)

        if distToMin < distToMax then
            self.valueMin = self:_snapValue(value)
            if self.onMinChange then self.onMinChange(self.valueMin) end
        else
            self.valueMax = self:_snapValue(value)
            if self.onMaxChange then self.onMaxChange(self.valueMax) end
        end

        if self.onRangeChange then
            self.onRangeChange(self.valueMin, self.valueMax)
        end

        core.setFocus(self)
        return true
    end

    return false
end

function RangeSlider:mousereleased(x, y, button)
    if button == 1 then
        self.dragging = nil
        self.dragStart = { x = 0, value = 0 }
    end
end

function RangeSlider:keypressed(key)
    if not self.focused then return core.Base.keypressed(self, key) end

    local step = (self.max - self.min) * 0.01 -- 1% steps

    if key == "left" or key == "down" then
        self.valueMin = math.max(self.min, self.valueMin - step)
        if self.onMinChange then self.onMinChange(self.valueMin) end
        if self.onRangeChange then self.onRangeChange(self.valueMin, self.valueMax) end
        return true
    elseif key == "right" or key == "up" then
        self.valueMax = math.min(self.max, self.valueMax + step)
        if self.onMaxChange then self.onMaxChange(self.valueMax) end
        if self.onRangeChange then self.onRangeChange(self.valueMin, self.valueMax) end
        return true
    end

    return core.Base.keypressed(self, key)
end

-- Helper methods
function RangeSlider:_valueToPosition(value)
    local t = (value - self.min) / (self.max - self.min)
    return self.x + t * self.w
end

function RangeSlider:_positionToValue(x)
    local t = (x - self.x) / self.w
    return self.min + t * (self.max - self.min)
end

function RangeSlider:_pointInHandle(x, y, handleX, handleY)
    local distance = math.sqrt((x - handleX) ^ 2 + (y - handleY) ^ 2)
    return distance <= self.handleRadius
end

function RangeSlider:_snapValue(value)
    if self.snapToGrid then
        return math.floor((value + self.gridSize / 2) / self.gridSize) * self.gridSize
    end
    return value
end

-- Public methods
function RangeSlider:setRange(min, max, animate)
    self.valueMin = math.max(self.min, math.min(self.max, min))
    self.valueMax = math.max(self.min, math.min(self.max, max))

    if self.onRangeChange then
        self.onRangeChange(self.valueMin, self.valueMax)
    end
end

function RangeSlider:getRange()
    return self.valueMin, self.valueMax
end

return RangeSlider
