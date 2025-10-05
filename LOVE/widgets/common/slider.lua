--[[
widgets/slider.lua
Slider widget (versatile numeric input control with range support)


Versatile slider widget providing precise numeric input with single value or range selection,
rich visual customization, and accessibility features for tactical strategy game interfaces.
Essential for adjusting game settings, soldier stats, research priorities, and other numeric
parameters in OpenXCOM-style game configuration screens.

PURPOSE:
- Provide intuitive numeric input with visual feedback
- Support both single values and value ranges
- Enable precise control with stepping and snapping
- Offer rich visual customization for different contexts
- Core component for game configuration and parameter adjustment

KEY FEATURES:
- Single value and dual-handle range selection modes
- Horizontal and vertical orientations
- Stepping, precision control, and value snapping
- Tick marks and customizable labels
- Multiple handle shapes and visual styling
- Gradient fills and color customization
- Smooth animations and interaction effects
- Validation integration with visual feedback
- Accessibility support with keyboard navigation
- Performance optimized for real-time interaction

@see widgets.common.core.Base
@see widgets.common.validation
@see widgets.complex.animation
@see widgets.complex.rangeslider
@see widgets.common.spinner
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Validation = require("widgets.common.validation")

local Slider = {}
Slider.__index = Slider

function Slider:new(x, y, w, h, min, max, value, callback, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    -- Basic slider properties
    obj.min = min or 0
    obj.max = max or 100
    obj.value = value or min
    obj.callback = callback or function() end

    -- Range mode support
    obj.isRange = options.isRange or false
    obj.valueStart = options.valueStart or obj.value
    obj.valueEnd = options.valueEnd or obj.value
    obj.activeHandle = "none" -- none, start, end, single

    -- Stepping and precision
    obj.step = options.step or 1
    obj.precision = options.precision or 0
    obj.snap = options.snap ~= false

    -- Visual options
    obj.orientation = options.orientation or "horizontal" -- horizontal, vertical
    obj.trackHeight = options.trackHeight or 6
    obj.handleSize = options.handleSize or 12
    obj.handleShape = options.handleShape or "circle" -- circle, square, custom
    obj.trackRadius = options.trackRadius or 3

    -- Ticks and labels
    obj.showTicks = options.showTicks or false
    obj.tickCount = options.tickCount or 5
    obj.tickSize = options.tickSize or 4
    obj.tickLabels = options.tickLabels -- Custom tick labels array
    obj.showValue = options.showValue ~= false
    obj.showMinMax = options.showMinMax or false
    obj.valueFormat = options.valueFormat or "%.1f"
    obj.valuePosition = options.valuePosition or "above" -- above, below, handle, none

    -- Visual styling
    obj.trackColor = options.trackColor
    obj.fillColor = options.fillColor
    obj.handleColor = options.handleColor
    obj.tickColor = options.tickColor
    obj.textColor = options.textColor
    obj.disabledColor = options.disabledColor

    -- Gradient support
    obj.gradient = options.gradient -- {colors = {color1, color2, ...}, positions = {0, 0.5, 1}}

    -- Animation
    obj.animateValue = options.animateValue ~= false
    obj.animationDuration = options.animationDuration or 0.2
    obj.handleScale = 1
    obj.handleRotation = 0

    -- Interaction state
    obj.dragging = false
    obj.hoveredHandle = "none"
    obj.pressedHandle = "none"

    -- Validation
    obj.validator = options.validator
    obj.validationState = "none"
    obj.validationMessage = ""

    -- Events
    obj.onChange = options.onChange
    obj.onValueChange = options.onValueChange
    obj.onRangeChange = options.onRangeChange
    obj.onValidation = options.onValidation

    -- Font for labels
    obj.font = options.font or love.graphics.getFont()

    -- Calculate layout
    obj:_calculateLayout()

    -- Setup colors
    obj:_setupColors(options)

    setmetatable(obj, self)
    return obj
end

--- Sets up color scheme for the slider based on theme and options (private method)
--- @param options table Configuration options containing custom colors
function Slider:_setupColors(options)
    local theme = core.theme

    self.colors = {
        track = options.trackColor or theme.surfaceVariant,
        fill = options.fillColor or theme.accent,
        handle = options.handleColor or theme.primary,
        handleHover = options.handleHoverColor or theme.primaryHover,
        handlePressed = options.handlePressedColor or theme.primaryPressed,
        handleDisabled = options.handleDisabledColor or theme.surfaceDisabled,
        tick = options.tickColor or theme.border,
        text = options.textColor or theme.text,
        textDisabled = options.textDisabledColor or theme.textDisabled,
        disabled = options.disabledColor or theme.surfaceDisabled,

        -- Validation colors
        valid = theme.success,
        invalid = theme.error,
        warning = theme.warning
    }
end

--- Calculates the layout dimensions for slider components (private method)
function Slider:_calculateLayout()
    -- Calculate effective area for the slider track
    local padding = self.handleSize / 2

    if self.orientation == "horizontal" then
        self.trackX = self.x + padding
        self.trackY = self.y + (self.h - self.trackHeight) / 2
        self.trackW = self.w - padding * 2
        self.trackH = self.trackHeight
    else -- vertical
        self.trackX = self.x + (self.w - self.trackHeight) / 2
        self.trackY = self.y + padding
        self.trackW = self.trackHeight
        self.trackH = self.h - padding * 2
    end
end

function Slider:update(dt)
    core.Base.update(self, dt)
    Animation.update(dt)

    -- Handle dragging
    if self.dragging and self.enabled then
        local mx, my = love.mouse.getPosition()
        self:_updateValueFromPosition(mx, my)
    end

    -- Update hover state
    local mx, my = love.mouse.getPosition()
    if self.enabled and self:hitTest(mx, my) then
        self.hoveredHandle = self:_getHandleAtPosition(mx, my)

        if self.tooltip then
            core.setTooltipWidget(self)
        end
    else
        self.hoveredHandle = "none"
        if self.tooltip then
            core.setTooltipWidget(nil)
        end
    end

    -- Validate if needed
    if self.validator then
        self:validate()
    end
end

function Slider:draw()
    core.Base.draw(self)

    -- Draw track
    self:_drawTrack()

    -- Draw fill/progress
    self:_drawFill()

    -- Draw ticks
    if self.showTicks then
        self:_drawTicks()
    end

    -- Draw handles
    self:_drawHandles()

    -- Draw labels
    if self.showValue or self.showMinMax then
        self:_drawLabels()
    end

    -- Draw validation indicator
    if self.validationState ~= "none" then
        self:_drawValidationIndicator()
    end

    -- Draw focus ring
    if self.focused then
        self:_drawFocusRing()
    end
end

--- Draws the slider track background (private method)
function Slider:_drawTrack()
    local trackColor = self.enabled and self.colors.track or self.colors.disabled
    love.graphics.setColor(unpack(trackColor))

    if self.trackRadius > 0 then
        love.graphics.rectangle("fill", self.trackX, self.trackY, self.trackW, self.trackH, self.trackRadius)
    else
        love.graphics.rectangle("fill", self.trackX, self.trackY, self.trackW, self.trackH)
    end
end

--- Draws the filled portion of the slider track (private method)
function Slider:_drawFill()
    if not self.enabled then return end

    local fillColor = self.colors.fill

    -- Validation color override
    if self.validationState == "invalid" then
        fillColor = self.colors.invalid
    elseif self.validationState == "warning" then
        fillColor = self.colors.warning
    elseif self.validationState == "valid" then
        fillColor = self.colors.valid
    end

    if self.isRange then
        -- Draw range fill
        local startPos = self:_valueToPosition(self.valueStart)
        local endPos = self:_valueToPosition(self.valueEnd)

        if self.orientation == "horizontal" then
            local fillX = math.min(startPos.x, endPos.x)
            local fillW = math.abs(endPos.x - startPos.x)

            if self.gradient then
                self:_drawGradientFill(fillX, self.trackY, fillW, self.trackH)
            else
                love.graphics.setColor(unpack(fillColor))
                if self.trackRadius > 0 then
                    love.graphics.rectangle("fill", fillX, self.trackY, fillW, self.trackH, self.trackRadius)
                else
                    love.graphics.rectangle("fill", fillX, self.trackY, fillW, self.trackH)
                end
            end
        else -- vertical
            local fillY = math.min(startPos.y, endPos.y)
            local fillH = math.abs(endPos.y - startPos.y)

            if self.gradient then
                self:_drawGradientFill(self.trackX, fillY, self.trackW, fillH)
            else
                love.graphics.setColor(unpack(fillColor))
                if self.trackRadius > 0 then
                    love.graphics.rectangle("fill", self.trackX, fillY, self.trackW, fillH, self.trackRadius)
                else
                    love.graphics.rectangle("fill", self.trackX, fillY, self.trackW, fillH)
                end
            end
        end
    else
        -- Draw single value fill
        local valuePos = self:_valueToPosition(self.value)

        if self.orientation == "horizontal" then
            local fillW = valuePos.x - self.trackX

            if fillW > 0 then
                if self.gradient then
                    self:_drawGradientFill(self.trackX, self.trackY, fillW, self.trackH)
                else
                    love.graphics.setColor(unpack(fillColor))
                    if self.trackRadius > 0 then
                        love.graphics.rectangle("fill", self.trackX, self.trackY, fillW, self.trackH, self.trackRadius)
                    else
                        love.graphics.rectangle("fill", self.trackX, self.trackY, fillW, self.trackH)
                    end
                end
            end
        else -- vertical
            local fillH = (self.trackY + self.trackH) - valuePos.y

            if fillH > 0 then
                if self.gradient then
                    self:_drawGradientFill(self.trackX, valuePos.y, self.trackW, fillH)
                else
                    love.graphics.setColor(unpack(fillColor))
                    if self.trackRadius > 0 then
                        love.graphics.rectangle("fill", self.trackX, valuePos.y, self.trackW, fillH, self.trackRadius)
                    else
                        love.graphics.rectangle("fill", self.trackX, valuePos.y, self.trackW, fillH)
                    end
                end
            end
        end
    end
end

function Slider:_drawGradientFill(x, y, w, h)
    if not self.gradient or not self.gradient.colors then return end

    -- Simple gradient implementation
    local steps = 20
    local stepSize = (self.orientation == "horizontal") and (w / steps) or (h / steps)

    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        local color = self:_interpolateGradientColor(t)

        love.graphics.setColor(unpack(color))

        if self.orientation == "horizontal" then
            love.graphics.rectangle("fill", x + i * stepSize, y, stepSize + 1, h)
        else
            love.graphics.rectangle("fill", x, y + i * stepSize, w, stepSize + 1)
        end
    end
end

function Slider:_interpolateGradientColor(t)
    local colors = self.gradient.colors
    local positions = self.gradient.positions or {}

    -- Default positions if not provided
    if #positions == 0 then
        for i = 1, #colors do
            positions[i] = (i - 1) / (#colors - 1)
        end
    end

    -- Find the two colors to interpolate between
    for i = 1, #positions - 1 do
        if t >= positions[i] and t <= positions[i + 1] then
            local localT = (t - positions[i]) / (positions[i + 1] - positions[i])
            local color1 = colors[i]
            local color2 = colors[i + 1]

            return {
                color1[1] + (color2[1] - color1[1]) * localT,
                color1[2] + (color2[2] - color1[2]) * localT,
                color1[3] + (color2[3] - color1[3]) * localT,
                (color1[4] or 1) + ((color2[4] or 1) - (color1[4] or 1)) * localT
            }
        end
    end

    return colors[1]
end

function Slider:_drawTicks()
    love.graphics.setColor(unpack(self.colors.tick))

    for i = 0, self.tickCount - 1 do
        local t = i / (self.tickCount - 1)
        local value = self.min + t * (self.max - self.min)
        local pos = self:_valueToPosition(value)

        if self.orientation == "horizontal" then
            local tickY1 = self.trackY + self.trackH
            local tickY2 = tickY1 + self.tickSize
            love.graphics.line(pos.x, tickY1, pos.x, tickY2)

            -- Draw tick labels if provided
            if self.tickLabels and self.tickLabels[i + 1] then
                local label = self.tickLabels[i + 1]
                local textWidth = self.font:getWidth(label)
                love.graphics.setColor(unpack(self.colors.text))
                love.graphics.print(label, pos.x - textWidth / 2, tickY2 + 2)
                love.graphics.setColor(unpack(self.colors.tick))
            end
        else -- vertical
            local tickX1 = self.trackX + self.trackW
            local tickX2 = tickX1 + self.tickSize
            love.graphics.line(tickX1, pos.y, tickX2, pos.y)

            -- Draw tick labels if provided
            if self.tickLabels and self.tickLabels[i + 1] then
                local label = self.tickLabels[i + 1]
                local textHeight = self.font:getHeight()
                love.graphics.setColor(unpack(self.colors.text))
                love.graphics.print(label, tickX2 + 2, pos.y - textHeight / 2)
                love.graphics.setColor(unpack(self.colors.tick))
            end
        end
    end
end

--- Draws all slider handles (private method)
function Slider:_drawHandles()
    if self.isRange then
        self:_drawHandle(self.valueStart, "start")
        self:_drawHandle(self.valueEnd, "end")
    else
        self:_drawHandle(self.value, "single")
    end
end

function Slider:_drawHandle(value, handleType)
    local pos = self:_valueToPosition(value)

    -- Determine handle color
    local handleColor = self.colors.handle
    if not self.enabled then
        handleColor = self.colors.handleDisabled
    elseif self.pressedHandle == handleType or (self.dragging and self.activeHandle == handleType) then
        handleColor = self.colors.handlePressed
    elseif self.hoveredHandle == handleType then
        handleColor = self.colors.handleHover
    end

    love.graphics.push()

    -- Apply handle transformations
    love.graphics.translate(pos.x, pos.y)
    love.graphics.scale(self.handleScale)
    love.graphics.rotate(self.handleRotation)

    -- Draw handle based on shape
    if self.handleShape == "circle" then
        love.graphics.setColor(unpack(handleColor))
        love.graphics.circle("fill", 0, 0, self.handleSize / 2)

        -- Handle border
        love.graphics.setColor(unpack(self.colors.text))
        love.graphics.circle("line", 0, 0, self.handleSize / 2)
    elseif self.handleShape == "square" then
        local size = self.handleSize
        love.graphics.setColor(unpack(handleColor))
        love.graphics.rectangle("fill", -size / 2, -size / 2, size, size)

        -- Handle border
        love.graphics.setColor(unpack(self.colors.text))
        love.graphics.rectangle("line", -size / 2, -size / 2, size, size)
    end

    -- Draw value on handle if specified
    if self.valuePosition == "handle" and self.showValue then
        love.graphics.setColor(unpack(self.colors.text))
        local valueText = string.format(self.valueFormat, value)
        local textWidth = self.font:getWidth(valueText)
        local textHeight = self.font:getHeight()
        love.graphics.print(valueText, -textWidth / 2, -textHeight / 2)
    end

    love.graphics.pop()
end

function Slider:_drawLabels()
    love.graphics.setColor(unpack(self.enabled and self.colors.text or self.colors.textDisabled))
    love.graphics.setFont(self.font)

    if self.showMinMax then
        local minText = string.format(self.valueFormat, self.min)
        local maxText = string.format(self.valueFormat, self.max)

        if self.orientation == "horizontal" then
            -- Min label (left)
            love.graphics.print(minText, self.x, self.y + self.h + 5)

            -- Max label (right)
            local maxWidth = self.font:getWidth(maxText)
            love.graphics.print(maxText, self.x + self.w - maxWidth, self.y + self.h + 5)
        else -- vertical
            -- Min label (bottom)
            local textHeight = self.font:getHeight()
            love.graphics.print(minText, self.x + self.w + 5, self.y + self.h - textHeight)

            -- Max label (top)
            love.graphics.print(maxText, self.x + self.w + 5, self.y)
        end
    end

    if self.showValue and self.valuePosition ~= "handle" then
        if self.isRange then
            local startText = string.format(self.valueFormat, self.valueStart)
            local endText = string.format(self.valueFormat, self.valueEnd)
            local rangeText = startText .. " - " .. endText

            if self.valuePosition == "above" then
                local textWidth = self.font:getWidth(rangeText)
                love.graphics.print(rangeText, self.x + (self.w - textWidth) / 2, self.y - 20)
            elseif self.valuePosition == "below" then
                local textWidth = self.font:getWidth(rangeText)
                love.graphics.print(rangeText, self.x + (self.w - textWidth) / 2, self.y + self.h + 5)
            end
        else
            local valueText = string.format(self.valueFormat, self.value)

            if self.valuePosition == "above" then
                local textWidth = self.font:getWidth(valueText)
                love.graphics.print(valueText, self.x + (self.w - textWidth) / 2, self.y - 20)
            elseif self.valuePosition == "below" then
                local textWidth = self.font:getWidth(valueText)
                love.graphics.print(valueText, self.x + (self.w - textWidth) / 2, self.y + self.h + 5)
            end
        end
    end
end

function Slider:_drawValidationIndicator()
    local indicatorSize = 6
    local color

    if self.validationState == "valid" then
        color = self.colors.valid
    elseif self.validationState == "invalid" then
        color = self.colors.invalid
    elseif self.validationState == "warning" then
        color = self.colors.warning
    else
        return
    end

    local indicatorX = self.x + self.w - indicatorSize - 2
    local indicatorY = self.y + 2

    love.graphics.setColor(unpack(color))
    love.graphics.circle("fill", indicatorX + indicatorSize / 2, indicatorY + indicatorSize / 2, indicatorSize / 2)
end

function Slider:_drawFocusRing()
    love.graphics.setColor(unpack(core.focus.focusRingColor))
    love.graphics.setLineWidth(2)

    local padding = 2
    love.graphics.rectangle("line", self.x - padding, self.y - padding,
        self.w + padding * 2, self.h + padding * 2)

    love.graphics.setLineWidth(1)
end

-- Helper methods
function Slider:_valueToPosition(value)
    local normalizedValue = (value - self.min) / (self.max - self.min)

    if self.orientation == "horizontal" then
        local x = self.trackX + normalizedValue * self.trackW
        local y = self.trackY + self.trackH / 2
        return { x = x, y = y }
    else -- vertical
        local x = self.trackX + self.trackW / 2
        local y = self.trackY + self.trackH - (normalizedValue * self.trackH)
        return { x = x, y = y }
    end
end

function Slider:_positionToValue(x, y)
    local normalizedValue

    if self.orientation == "horizontal" then
        normalizedValue = (x - self.trackX) / self.trackW
    else -- vertical
        normalizedValue = (self.trackY + self.trackH - y) / self.trackH
    end

    normalizedValue = math.max(0, math.min(1, normalizedValue))
    local value = self.min + normalizedValue * (self.max - self.min)

    if self.snap then
        value = math.floor(value / self.step + 0.5) * self.step
    end

    return math.max(self.min, math.min(self.max, value))
end

function Slider:_getHandleAtPosition(x, y)
    local handleRadius = self.handleSize / 2 + 5 -- Add some tolerance

    if self.isRange then
        local startPos = self:_valueToPosition(self.valueStart)
        local endPos = self:_valueToPosition(self.valueEnd)

        local distToStart = math.sqrt((x - startPos.x) ^ 2 + (y - startPos.y) ^ 2)
        local distToEnd = math.sqrt((x - endPos.x) ^ 2 + (y - endPos.y) ^ 2)

        if distToStart <= handleRadius and distToEnd <= handleRadius then
            return self.activeHandle == "start" and "end" or "start"
        elseif distToStart <= handleRadius then
            return "start"
        elseif distToEnd <= handleRadius then
            return "end"
        end
    else
        local valuePos = self:_valueToPosition(self.value)
        local distToHandle = math.sqrt((x - valuePos.x) ^ 2 + (y - valuePos.y) ^ 2)

        if distToHandle <= handleRadius then
            return "single"
        end
    end

    return "none"
end

function Slider:_updateValueFromPosition(x, y)
    local newValue = self:_positionToValue(x, y)

    if self.isRange then
        if self.activeHandle == "start" then
            self.valueStart = math.min(newValue, self.valueEnd)
        elseif self.activeHandle == "end" then
            self.valueEnd = math.max(newValue, self.valueStart)
        end

        if self.onRangeChange then
            self.onRangeChange(self.valueStart, self.valueEnd, self)
        end
    else
        self.value = newValue

        if self.onValueChange then
            self.onValueChange(self.value, self)
        end
    end

    if self.onChange then
        self.onChange(self)
    end

    core.safeCall(self.callback, self.value, self)
end

-- Event handling
function Slider:mousepressed(x, y, button)
    if not self.enabled or button ~= 1 or not self:hitTest(x, y) then
        return false
    end

    core.setFocus(self)

    local handle = self:_getHandleAtPosition(x, y)

    if handle ~= "none" then
        self.dragging = true
        self.activeHandle = handle
        self.pressedHandle = handle

        -- Animate handle scale
        Animation.animateWidget(self, "handleScale", 1.2, 0.1, Animation.types.EASE_OUT)
    else
        -- Clicked on track, move nearest handle
        local newValue = self:_positionToValue(x, y)

        if self.isRange then
            local distToStart = math.abs(newValue - self.valueStart)
            local distToEnd = math.abs(newValue - self.valueEnd)

            if distToStart < distToEnd then
                self.activeHandle = "start"
                if self.animateValue then
                    Animation.animateWidget(self, "valueStart", newValue, self.animationDuration,
                        Animation.types.EASE_OUT)
                else
                    self.valueStart = newValue
                end
            else
                self.activeHandle = "end"
                if self.animateValue then
                    Animation.animateWidget(self, "valueEnd", newValue, self.animationDuration, Animation.types.EASE_OUT)
                else
                    self.valueEnd = newValue
                end
            end

            if self.onRangeChange then
                self.onRangeChange(self.valueStart, self.valueEnd, self)
            end
        else
            if self.animateValue then
                Animation.animateWidget(self, "value", newValue, self.animationDuration, Animation.types.EASE_OUT)
            else
                self.value = newValue
            end

            if self.onValueChange then
                self.onValueChange(self.value, self)
            end
        end

        if self.onChange then
            self.onChange(self)
        end
    end

    return true
end

function Slider:mousereleased(x, y, button)
    if button == 1 then
        self.dragging = false
        self.activeHandle = "none"
        self.pressedHandle = "none"

        -- Reset handle scale
        Animation.animateWidget(self, "handleScale", 1, 0.1, Animation.types.EASE_OUT)
    end
end

function Slider:keypressed(key)
    if not self.focused then return core.Base.keypressed(self, key) end
    if not self.enabled then return true end

    local step = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") and
        (self.step * 10) or self.step

    if key == "left" or key == "down" then
        if self.isRange then
            if self.activeHandle == "end" or self.activeHandle == "none" then
                self.valueEnd = math.max(self.min, self.valueEnd - step)
                self.activeHandle = "end"
            else
                self.valueStart = math.max(self.min, self.valueStart - step)
            end

            if self.onRangeChange then
                self.onRangeChange(self.valueStart, self.valueEnd, self)
            end
        else
            self.value = math.max(self.min, self.value - step)

            if self.onValueChange then
                self.onValueChange(self.value, self)
            end
        end

        if self.onChange then
            self.onChange(self)
        end

        return true
    elseif key == "right" or key == "up" then
        if self.isRange then
            if self.activeHandle == "start" or self.activeHandle == "none" then
                self.valueStart = math.min(self.max, self.valueStart + step)
                self.activeHandle = "start"
            else
                self.valueEnd = math.min(self.max, self.valueEnd + step)
            end

            if self.onRangeChange then
                self.onRangeChange(self.valueStart, self.valueEnd, self)
            end
        else
            self.value = math.min(self.max, self.value + step)

            if self.onValueChange then
                self.onValueChange(self.value, self)
            end
        end

        if self.onChange then
            self.onChange(self)
        end

        return true
    elseif key == "home" then
        if self.isRange then
            if self.activeHandle == "start" or self.activeHandle == "none" then
                self.valueStart = self.min
            else
                self.valueEnd = self.min
            end

            if self.onRangeChange then
                self.onRangeChange(self.valueStart, self.valueEnd, self)
            end
        else
            self.value = self.min

            if self.onValueChange then
                self.onValueChange(self.value, self)
            end
        end

        if self.onChange then
            self.onChange(self)
        end

        return true
    elseif key == "end" then
        if self.isRange then
            if self.activeHandle == "end" or self.activeHandle == "none" then
                self.valueEnd = self.max
            else
                self.valueStart = self.max
            end

            if self.onRangeChange then
                self.onRangeChange(self.valueStart, self.valueEnd, self)
            end
        else
            self.value = self.max

            if self.onValueChange then
                self.onValueChange(self.value, self)
            end
        end

        if self.onChange then
            self.onChange(self)
        end

        return true
    end

    return core.Base.keypressed(self, key)
end

-- Validation
function Slider:validate()
    if not self.validator then
        self.validationState = "none"
        return true
    end

    local result = Validation.validateWidget(self, self.validator)
    self.validationState = result.state
    self.validationMessage = result.message or ""

    if self.onValidation then
        self.onValidation(result, self)
    end

    return result.state == "valid" or result.state == "none"
end

-- Public API methods
function Slider:setValue(value, animate)
    local oldValue = self.value
    self.value = math.max(self.min, math.min(self.max, value))

    if oldValue ~= self.value then
        if animate and self.animateValue then
            Animation.animateWidget(self, "value", self.value, self.animationDuration, Animation.types.EASE_OUT)
        end

        if self.onValueChange then
            self.onValueChange(self.value, self)
        end

        if self.onChange then
            self.onChange(self)
        end
    end
end

function Slider:setRange(startValue, endValue, animate)
    local oldStart = self.valueStart
    local oldEnd = self.valueEnd

    self.valueStart = math.max(self.min, math.min(self.max, startValue))
    self.valueEnd = math.max(self.min, math.min(self.max, endValue))

    -- Ensure start <= end
    if self.valueStart > self.valueEnd then
        self.valueStart, self.valueEnd = self.valueEnd, self.valueStart
    end

    if oldStart ~= self.valueStart or oldEnd ~= self.valueEnd then
        if animate and self.animateValue then
            Animation.animateWidget(self, "valueStart", self.valueStart, self.animationDuration, Animation.types
                .EASE_OUT)
            Animation.animateWidget(self, "valueEnd", self.valueEnd, self.animationDuration, Animation.types.EASE_OUT)
        end

        if self.onRangeChange then
            self.onRangeChange(self.valueStart, self.valueEnd, self)
        end

        if self.onChange then
            self.onChange(self)
        end
    end
end

function Slider:getValue()
    if self.isRange then
        return self.valueStart, self.valueEnd
    else
        return self.value
    end
end

function Slider:setMinMax(min, max)
    self.min = min
    self.max = max

    -- Clamp current values
    if self.isRange then
        self.valueStart = math.max(min, math.min(max, self.valueStart))
        self.valueEnd = math.max(min, math.min(max, self.valueEnd))
    else
        self.value = math.max(min, math.min(max, self.value))
    end

    self:_calculateLayout()
end

function Slider:setStep(step)
    self.step = step
end

function Slider:setValidator(validator)
    self.validator = validator
    self.validationState = "none"
end

function Slider:getValidationState()
    return self.validationState, self.validationMessage
end

-- Serialization
function Slider:serialize()
    return {
        min = self.min,
        max = self.max,
        value = self.value,
        isRange = self.isRange,
        valueStart = self.valueStart,
        valueEnd = self.valueEnd,
        step = self.step,
        precision = self.precision,
        snap = self.snap,
        orientation = self.orientation,
        trackHeight = self.trackHeight,
        handleSize = self.handleSize,
        handleShape = self.handleShape,
        trackRadius = self.trackRadius,
        showTicks = self.showTicks,
        tickCount = self.tickCount,
        tickSize = self.tickSize,
        tickLabels = self.tickLabels,
        showValue = self.showValue,
        showMinMax = self.showMinMax,
        valueFormat = self.valueFormat,
        valuePosition = self.valuePosition,
        gradient = self.gradient,
        animateValue = self.animateValue,
        animationDuration = self.animationDuration,
        validationState = self.validationState,
        validationMessage = self.validationMessage
    }
end

function Slider:deserialize(data)
    self.min = data.min or 0
    self.max = data.max or 100
    self.value = data.value or self.min
    self.isRange = data.isRange or false
    self.valueStart = data.valueStart or self.value
    self.valueEnd = data.valueEnd or self.value
    self.step = data.step or 1
    self.precision = data.precision or 0
    self.snap = data.snap ~= false
    self.orientation = data.orientation or "horizontal"
    self.trackHeight = data.trackHeight or 6
    self.handleSize = data.handleSize or 12
    self.handleShape = data.handleShape or "circle"
    self.trackRadius = data.trackRadius or 3
    self.showTicks = data.showTicks or false
    self.tickCount = data.tickCount or 5
    self.tickSize = data.tickSize or 4
    self.tickLabels = data.tickLabels
    self.showValue = data.showValue ~= false
    self.showMinMax = data.showMinMax or false
    self.valueFormat = data.valueFormat or "%.1f"
    self.valuePosition = data.valuePosition or "above"
    self.gradient = data.gradient
    self.animateValue = data.animateValue ~= false
    self.animationDuration = data.animationDuration or 0.2
    self.validationState = data.validationState or "none"
    self.validationMessage = data.validationMessage or ""

    self:_calculateLayout()
end

return Slider
