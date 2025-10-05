--[[
widgets/checkbox.lua
Checkbox widget (versatile selection control with rich states and animations)


Versatile checkbox widget supporting binary and indeterminate states with rich visual
styling, animations, and group behaviors for tactical strategy game interfaces.
Essential for toggling options, managing selections, and creating interactive forms
in base management, research, and soldier equipment screens.

PURPOSE:
- Provide accessible checkbox control with multiple visual variants
- Support binary (checked/unchecked) and indeterminate states
- Enable toggle switch functionality for modern UI preferences
- Facilitate group selections and radio-like behaviors
- Core component for OpenXCOM-style option toggling and selections

KEY FEATURES:
- State management: checked, unchecked, indeterminate
- Visual styles: default checkbox, toggle switch, custom styling
- Shape variants: square, rounded, circle
- Animation effects: bounce, ripple, checkmark animation, scaling
- Label positioning: left, right, top, bottom with customizable spacing
- Icon customization: custom checkmarks and indeterminate symbols
- Group behavior: radio-like exclusive selections
- Validation integration: required fields and custom validators
- Accessibility: screen reader support and keyboard navigation
- Theme integration: consistent colors and styling

@see widgets.common.core.Base
@see widgets.common.validation
@see widgets.complex.animation
@see widgets.common.radiobutton
@see widgets.common.form
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Validation = require("widgets.common.validation")

local Checkbox = {}
Checkbox.__index = Checkbox

function Checkbox:new(x, y, size, checked, callback, options)
    options = options or {}
    local obj = core.Base:new(x, y, size, size, options)

    -- Basic checkbox properties
    obj.size = size or 20
    obj.checked = checked or false
    obj.indeterminate = options.indeterminate or false
    obj.label = options.label
    obj.callback = callback or function() end

    -- Enhanced visual options
    obj.style = options.style or "default"    -- default, toggle, custom
    obj.variant = options.variant or "filled" -- filled, outlined
    obj.shape = options.shape or "square"     -- square, rounded, circle
    obj.cornerRadius = options.cornerRadius or 3
    obj.borderWidth = options.borderWidth or 1

    -- Animation properties
    obj.animationDuration = options.animationDuration or 0.2
    obj.bounceEffect = options.bounceEffect ~= false
    obj.rippleEffect = options.rippleEffect ~= false
    obj.checkAnimation = 0
    obj.scaleAnimation = 1
    obj.rotationAnimation = 0
    obj.ripples = {}

    -- Label positioning
    obj.labelPosition = options.labelPosition or "right" -- left, right, top, bottom
    obj.labelSpacing = options.labelSpacing or 8
    obj.font = options.font or love.graphics.getFont()

    -- Icon customization
    obj.checkIcon = options.checkIcon or "✓"
    obj.indeterminateIcon = options.indeterminateIcon or "−"
    obj.iconSize = options.iconSize or (size * 0.6)

    -- Toggle switch properties (for toggle style)
    obj.toggleWidth = options.toggleWidth or (size * 2)
    obj.toggleKnobSize = options.toggleKnobSize or (size * 0.8)
    obj.toggleAnimationPos = 0

    -- Validation
    obj.validator = options.validator
    obj.validationState = "none" -- none, valid, invalid, warning
    obj.validationMessage = ""
    obj.required = options.required or false

    -- Group behavior (radio-like)
    obj.group = options.group
    obj.exclusive = options.exclusive or false

    -- Colors setup
    obj:_setupColors(options)

    -- Event callbacks
    obj.onChange = options.onChange
    obj.onValidation = options.onValidation

    -- Accessibility
    obj.accessibilityLabel = obj.accessibilityLabel or obj.label or "Checkbox"
    obj.accessibilityHint = obj.accessibilityHint or "Toggle to change state"

    setmetatable(obj, self)
    return obj
end

--- Sets up color scheme for the checkbox based on theme and options (private method)
--- @param options table Configuration options containing custom colors
function Checkbox:_setupColors(options)
    local theme = core.theme
    local baseColors = {
        background = theme.surface,
        backgroundHover = theme.surfaceHover,
        backgroundChecked = theme.accent,
        backgroundIndeterminate = theme.warning,
        backgroundDisabled = theme.surfaceDisabled,
        border = theme.border,
        borderHover = theme.borderHover,
        borderChecked = theme.accent,
        borderFocused = theme.accent,
        text = theme.text,
        textDisabled = theme.textDisabled,
        checkmark = theme.textOnAccent,
        ripple = { 1, 1, 1, 0.3 },

        -- Toggle switch specific colors
        toggleTrack = theme.surfaceVariant,
        toggleTrackChecked = theme.accent,
        toggleKnob = theme.surface,
        toggleKnobChecked = theme.textOnAccent
    }

    self.colors = {}
    for key, value in pairs(baseColors) do
        self.colors[key] = (options.colors and options.colors[key]) or value
    end

    -- Validation colors
    self.colors.valid = theme.success
    self.colors.invalid = theme.error
    self.colors.warning = theme.warning
end

--- Updates the checkbox state and animations
--- @param dt number Time delta since last update
function Checkbox:update(dt)
    core.Base.update(self, dt)
    Animation.update(dt)

    -- Update hover state
    local mx, my = love.mouse.getPosition()
    local bounds = self:_getInteractionBounds()
    local wasHovered = self.hovered
    self.hovered = self.enabled and self.visible and
        mx >= bounds.x and mx <= bounds.x + bounds.w and
        my >= bounds.y and my <= bounds.y + bounds.h

    -- Hover animation
    if self.hovered and not wasHovered then
        self:_onHoverStart()
    elseif not self.hovered and wasHovered then
        self:_onHoverEnd()
    end

    -- Update ripple effects
    for i = #self.ripples, 1, -1 do
        local ripple = self.ripples[i]
        ripple.time = ripple.time + dt
        ripple.radius = ripple.radius + dt * ripple.speed
        ripple.alpha = math.max(0, ripple.alpha - dt * 3)

        if ripple.alpha <= 0 then
            table.remove(self.ripples, i)
        end
    end

    -- Validate if needed
    if self.validator then
        self:validate()
    end
end

--- Handles hover start event (private method)
function Checkbox:_onHoverStart()
    if self.tooltip then
        core.setTooltipWidget(self)
    end
end

--- Handles hover end event (private method)
function Checkbox:_onHoverEnd()
    if self.tooltip then
        core.setTooltipWidget(nil)
    end
end

--- Gets the interaction bounds for mouse events (private method)
--- @return table Bounds table with x, y, w, h
function Checkbox:_getInteractionBounds()
    if self.style == "toggle" then
        local totalW = self.toggleWidth
        local totalH = self.size

        if self.label then
            if self.labelPosition == "right" then
                totalW = totalW + self.labelSpacing + self.font:getWidth(self.label)
            elseif self.labelPosition == "left" then
                totalW = totalW + self.labelSpacing + self.font:getWidth(self.label)
            elseif self.labelPosition == "top" or self.labelPosition == "bottom" then
                totalW = math.max(totalW, self.font:getWidth(self.label))
                totalH = totalH + self.labelSpacing + self.font:getHeight()
            end
        end

        return { x = self.x, y = self.y, w = totalW, h = totalH }
    else
        local totalW = self.size
        local totalH = self.size

        if self.label then
            if self.labelPosition == "right" then
                totalW = totalW + self.labelSpacing + self.font:getWidth(self.label)
            elseif self.labelPosition == "left" then
                totalW = totalW + self.labelSpacing + self.font:getWidth(self.label)
            elseif self.labelPosition == "top" or self.labelPosition == "bottom" then
                totalW = math.max(totalW, self.font:getWidth(self.label))
                totalH = totalH + self.labelSpacing + self.font:getHeight()
            end
        end

        return { x = self.x, y = self.y, w = totalW, h = totalH }
    end
end

--- Draws the checkbox and all its visual elements
function Checkbox:draw()
    core.Base.draw(self)

    love.graphics.push()

    -- Apply scale animation
    if self.scaleAnimation ~= 1 then
        local centerX = self.x + self.size / 2
        local centerY = self.y + self.size / 2
        love.graphics.translate(centerX, centerY)
        love.graphics.scale(self.scaleAnimation)
        love.graphics.translate(-centerX, -centerY)
    end

    -- Draw based on style
    if self.style == "toggle" then
        self:_drawToggleSwitch()
    else
        self:_drawCheckbox()
    end

    -- Draw ripple effects
    if self.rippleEffect then
        self:_drawRipples()
    end

    love.graphics.pop()

    -- Draw label
    if self.label then
        self:_drawLabel()
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

--- Draws the checkbox control (private method)
function Checkbox:_drawCheckbox()
    local bgColor = self:_getBackgroundColor()
    local borderColor = self:_getBorderColor()

    -- Background
    love.graphics.setColor(unpack(bgColor))

    if self.shape == "circle" then
        love.graphics.circle("fill", self.x + self.size / 2, self.y + self.size / 2, self.size / 2)
    elseif self.shape == "rounded" or self.cornerRadius > 0 then
        love.graphics.rectangle("fill", self.x, self.y, self.size, self.size, self.cornerRadius)
    else
        love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
    end

    -- Border
    if self.variant == "outlined" or not self.checked then
        love.graphics.setColor(unpack(borderColor))
        love.graphics.setLineWidth(self.borderWidth)

        if self.shape == "circle" then
            love.graphics.circle("line", self.x + self.size / 2, self.y + self.size / 2, self.size / 2)
        elseif self.shape == "rounded" or self.cornerRadius > 0 then
            love.graphics.rectangle("line", self.x, self.y, self.size, self.size, self.cornerRadius)
        else
            love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
        end

        love.graphics.setLineWidth(1)
    end

    -- Draw check mark or indeterminate symbol
    if self.checked or self.indeterminate then
        self:_drawCheckMark()
    end
end

--- Draws the toggle switch control (private method)
function Checkbox:_drawToggleSwitch()
    local trackColor = self.checked and self.colors.toggleTrackChecked or self.colors.toggleTrack
    local knobColor = self.checked and self.colors.toggleKnobChecked or self.colors.toggleKnob

    -- Track
    love.graphics.setColor(unpack(trackColor))
    local trackRadius = self.size / 2
    love.graphics.rectangle("fill", self.x, self.y, self.toggleWidth, self.size, trackRadius)

    -- Knob
    local knobX = self.x + self.toggleAnimationPos * (self.toggleWidth - self.toggleKnobSize)
    local knobY = self.y + (self.size - self.toggleKnobSize) / 2

    love.graphics.setColor(unpack(knobColor))
    love.graphics.circle("fill", knobX + self.toggleKnobSize / 2, knobY + self.toggleKnobSize / 2, self.toggleKnobSize /
        2)

    -- Knob shadow
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.circle("fill", knobX + self.toggleKnobSize / 2 + 1, knobY + self.toggleKnobSize / 2 + 1,
        self.toggleKnobSize / 2)
end

--- Draws the check mark or indeterminate symbol (private method)
function Checkbox:_drawCheckMark()
    love.graphics.setColor(unpack(self.colors.checkmark))

    if self.indeterminate then
        -- Draw dash for indeterminate state
        love.graphics.setLineWidth(3)
        local y = self.y + self.size / 2
        love.graphics.line(self.x + self.size * 0.25, y, self.x + self.size * 0.75, y)
        love.graphics.setLineWidth(1)
    else
        -- Draw checkmark with animation
        if self.checkIcon and type(self.checkIcon) == "string" then
            -- Text-based icon
            love.graphics.setFont(self.font)
            local textW = self.font:getWidth(self.checkIcon)
            local textH = self.font:getHeight()
            local textX = self.x + (self.size - textW) / 2
            local textY = self.y + (self.size - textH) / 2
            love.graphics.print(self.checkIcon, textX, textY)
        else
            -- Animated checkmark path
            love.graphics.setLineWidth(2)
            local progress = self.checkAnimation

            local cx, cy = self.x + self.size * 0.2, self.y + self.size * 0.5
            local mx, my = self.x + self.size * 0.45, self.y + self.size * 0.75
            local ex, ey = self.x + self.size * 0.8, self.y + self.size * 0.25

            if progress <= 0.5 then
                local t = progress * 2
                love.graphics.line(cx, cy, cx + (mx - cx) * t, cy + (my - cy) * t)
            else
                love.graphics.line(cx, cy, mx, my)
                local t = (progress - 0.5) * 2
                love.graphics.line(mx, my, mx + (ex - mx) * t, my + (ey - my) * t)
            end

            love.graphics.setLineWidth(1)
        end
    end
end

--- Draws the ripple effects (private method)
function Checkbox:_drawRipples()
    for _, ripple in ipairs(self.ripples) do
        love.graphics.setColor(self.colors.ripple[1], self.colors.ripple[2],
            self.colors.ripple[3], ripple.alpha)
        love.graphics.circle("fill", ripple.x, ripple.y, ripple.radius)
    end
end

--- Draws the checkbox label (private method)
function Checkbox:_drawLabel()
    local textColor = self.enabled and self.colors.text or self.colors.textDisabled
    love.graphics.setColor(unpack(textColor))
    love.graphics.setFont(self.font)

    local labelX, labelY = self:_getLabelPosition()
    love.graphics.print(self.label, labelX, labelY)
end

--- Draws the validation state indicator (private method)
function Checkbox:_drawValidationIndicator()
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

    local bounds = self:_getInteractionBounds()
    local indicatorX = bounds.x + bounds.w - indicatorSize - 2
    local indicatorY = bounds.y + 2

    love.graphics.setColor(unpack(color))
    love.graphics.circle("fill", indicatorX + indicatorSize / 2, indicatorY + indicatorSize / 2, indicatorSize / 2)
end

--- Draws the focus ring for accessibility (private method)
function Checkbox:_drawFocusRing()
    love.graphics.setColor(unpack(core.focus.focusRingColor))
    love.graphics.setLineWidth(2)

    local padding = 2
    if self.style == "toggle" then
        love.graphics.rectangle("line", self.x - padding, self.y - padding,
            self.toggleWidth + padding * 2, self.size + padding * 2,
            self.size / 2 + padding)
    elseif self.shape == "circle" then
        love.graphics.circle("line", self.x + self.size / 2, self.y + self.size / 2,
            self.size / 2 + padding)
    else
        love.graphics.rectangle("line", self.x - padding, self.y - padding,
            self.size + padding * 2, self.size + padding * 2,
            self.cornerRadius + padding)
    end

    love.graphics.setLineWidth(1)
end

--- Gets the position for drawing the label (private method)
--- @return number, number The x and y coordinates for the label
function Checkbox:_getLabelPosition()
    local labelX, labelY

    if self.labelPosition == "right" then
        labelX = self.x + (self.style == "toggle" and self.toggleWidth or self.size) + self.labelSpacing
        labelY = self.y + (self.size - self.font:getHeight()) / 2
    elseif self.labelPosition == "left" then
        labelX = self.x - self.labelSpacing - self.font:getWidth(self.label)
        labelY = self.y + (self.size - self.font:getHeight()) / 2
    elseif self.labelPosition == "top" then
        labelX = self.x + (self.size - self.font:getWidth(self.label)) / 2
        labelY = self.y - self.labelSpacing - self.font:getHeight()
    elseif self.labelPosition == "bottom" then
        labelX = self.x + (self.size - self.font:getWidth(self.label)) / 2
        labelY = self.y + self.size + self.labelSpacing
    else -- default to right
        labelX = self.x + (self.style == "toggle" and self.toggleWidth or self.size) + self.labelSpacing
        labelY = self.y + (self.size - self.font:getHeight()) / 2
    end

    return labelX, labelY
end

-- Helper methods for color states
--- Gets the current background color based on state (private method)
--- @return table The current background color as RGBA table
function Checkbox:_getBackgroundColor()
    if not self.enabled then
        return self.colors.backgroundDisabled
    elseif self.indeterminate then
        return self.colors.backgroundIndeterminate
    elseif self.checked then
        return self.colors.backgroundChecked
    elseif self.hovered then
        return self.colors.backgroundHover
    else
        return self.colors.background
    end
end

--- Gets the current border color based on state (private method)
--- @return table The current border color as RGBA table
function Checkbox:_getBorderColor()
    if not self.enabled then
        return self.colors.backgroundDisabled
    elseif self.validationState == "invalid" then
        return self.colors.invalid
    elseif self.validationState == "warning" then
        return self.colors.warning
    elseif self.validationState == "valid" then
        return self.colors.valid
    elseif self.focused then
        return self.colors.borderFocused
    elseif self.checked or self.indeterminate then
        return self.colors.borderChecked
    elseif self.hovered then
        return self.colors.borderHover
    else
        return self.colors.border
    end
end

-- Event handling
--- Handles mouse press events
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean True if the event was handled, false otherwise
function Checkbox:mousepressed(x, y, button)
    if not self.enabled or button ~= 1 then return false end

    local bounds = self:_getInteractionBounds()
    if not (x >= bounds.x and x <= bounds.x + bounds.w and
            y >= bounds.y and y <= bounds.y + bounds.h) then
        return false
    end

    core.setFocus(self)
    self.pressed = true

    -- Create ripple effect
    if self.rippleEffect then
        local centerX = self.x + self.size / 2
        local centerY = self.y + self.size / 2

        table.insert(self.ripples, {
            x = centerX,
            y = centerY,
            radius = 0,
            speed = 100,
            alpha = self.colors.ripple[4] or 0.3,
            time = 0
        })
    end

    return true
end

--- Handles mouse release events
--- @param x number The x-coordinate of the mouse release
--- @param y number The y-coordinate of the mouse release
--- @param button number The mouse button that was released
--- @return boolean True if the event was handled, false otherwise
function Checkbox:mousereleased(x, y, button)
    if not self.enabled or button ~= 1 or not self.pressed then
        return false
    end

    self.pressed = false

    local bounds = self:_getInteractionBounds()
    if x >= bounds.x and x <= bounds.x + bounds.w and
        y >= bounds.y and y <= bounds.y + bounds.h then
        self:toggle()
    end

    return true
end

--- Handles keyboard input for the checkbox
--- @param key string The key that was pressed
--- @return boolean True if the event was handled, false otherwise
function Checkbox:keypressed(key)
    if not self.focused then return core.Base.keypressed(self, key) end
    if not self.enabled then return true end

    if key == "space" or key == "return" then
        self:toggle()
        return true
    end

    return core.Base.keypressed(self, key)
end

-- State management
--- Toggles the checkbox state
function Checkbox:toggle()
    if self.indeterminate then
        self.indeterminate = false
        self.checked = true
    else
        self.checked = not self.checked
    end

    self:_animateStateChange()
    self:_onStateChange()
end

--- Animates the state change (private method)
function Checkbox:_animateStateChange()
    -- Bounce effect
    if self.bounceEffect then
        Animation.animateWidget(self, "scaleAnimation", 1.2, 0.1, Animation.types.EASE_OUT,
            function()
                Animation.animateWidget(self, "scaleAnimation", 1, 0.1, Animation.types.EASE_OUT)
            end)
    end

    -- Check animation
    local targetAnimation = (self.checked or self.indeterminate) and 1 or 0
    Animation.animateWidget(self, "checkAnimation", targetAnimation,
        self.animationDuration, Animation.types.EASE_OUT)

    -- Toggle switch animation
    if self.style == "toggle" then
        local targetPos = self.checked and 1 or 0
        Animation.animateWidget(self, "toggleAnimationPos", targetPos,
            self.animationDuration, Animation.types.EASE_OUT)
    end
end

--- Handles state change events (private method)
function Checkbox:_onStateChange()
    -- Handle exclusive group behavior
    if self.group and self.checked and self.exclusive then
        -- Uncheck other checkboxes in the same group
        -- This would need to be implemented at the container level
        core.notifyGroupChange(self.group, self)
    end

    -- Call callbacks
    if self.onChange then
        self.onChange(self.checked, self)
    end

    core.safeCall(self.callback, self.checked, self)

    -- Validate
    if self.validator then
        self:validate()
    end

    -- Accessibility
    if core.config.enableAccessibility then
        local state = self.indeterminate and "indeterminate" or
            (self.checked and "checked" or "unchecked")
        core.announce(self:getAccessibilityLabel() .. " " .. state)
    end
end

-- Validation
--- Validates the checkbox's current state using the configured validator
--- @return boolean True if validation passes, false otherwise
function Checkbox:validate()
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
--- Sets the checked state of the checkbox
--- @param checked boolean The new checked state
--- @param animate boolean Whether to animate the change (default true)
function Checkbox:setChecked(checked, animate)
    local oldChecked = self.checked
    self.checked = checked
    self.indeterminate = false

    if oldChecked ~= checked then
        if animate ~= false then
            self:_animateStateChange()
        end

        if self.onChange then
            self.onChange(self.checked, self)
        end
    end
end

--- Sets the indeterminate state of the checkbox
--- @param indeterminate boolean The new indeterminate state
--- @param animate boolean Whether to animate the change (default true)
function Checkbox:setIndeterminate(indeterminate, animate)
    local oldIndeterminate = self.indeterminate
    self.indeterminate = indeterminate

    if indeterminate then
        self.checked = false
    end

    if oldIndeterminate ~= indeterminate then
        if animate ~= false then
            self:_animateStateChange()
        end

        if self.onChange then
            self.onChange(self.checked, self)
        end
    end
end

--- Gets the current state of the checkbox
--- @return string The state ("checked", "unchecked", or "indeterminate")
function Checkbox:getState()
    if self.indeterminate then
        return "indeterminate"
    elseif self.checked then
        return "checked"
    else
        return "unchecked"
    end
end

--- Sets the checkbox label
--- @param label string The new label text
function Checkbox:setLabel(label)
    self.label = label
    self.accessibilityLabel = label or self.accessibilityLabel
end

--- Sets the enabled state of the checkbox
--- @param enabled boolean Whether the checkbox should be enabled
function Checkbox:setEnabled(enabled)
    local wasEnabled = self.enabled
    self.enabled = enabled

    if not enabled then
        self.hovered = false
        self.pressed = false
        if self.focused then
            core.setFocus(nil)
        end

        -- Cancel animations
        Animation.cancelWidgetAnimations(self)
        self.scaleAnimation = 1
    end
end

--- Sets the validation function for the checkbox
--- @param validator function The validation function to use
function Checkbox:setValidator(validator)
    self.validator = validator
    self.validationState = "none"
end

--- Sets the group for radio-like behavior
--- @param group string The group name
--- @param exclusive boolean Whether the group should be exclusive
function Checkbox:setGroup(group, exclusive)
    self.group = group
    self.exclusive = exclusive or false
end

--- Gets the current validation state and message
--- @return string, string The validation state ("none", "valid", "invalid", "warning") and message
function Checkbox:getValidationState()
    return self.validationState, self.validationMessage
end

-- Serialization
--- Serializes the checkbox state for saving
--- @return table The serialized checkbox data
function Checkbox:serialize()
    return {
        checked = self.checked,
        indeterminate = self.indeterminate,
        label = self.label,
        style = self.style,
        variant = self.variant,
        shape = self.shape,
        size = self.size,
        cornerRadius = self.cornerRadius,
        borderWidth = self.borderWidth,
        labelPosition = self.labelPosition,
        labelSpacing = self.labelSpacing,
        toggleWidth = self.toggleWidth,
        toggleKnobSize = self.toggleKnobSize,
        checkIcon = self.checkIcon,
        indeterminateIcon = self.indeterminateIcon,
        animationDuration = self.animationDuration,
        bounceEffect = self.bounceEffect,
        rippleEffect = self.rippleEffect,
        required = self.required,
        group = self.group,
        exclusive = self.exclusive,
        validationState = self.validationState,
        validationMessage = self.validationMessage
    }
end

--- Deserializes checkbox state from saved data
--- @param data table The serialized checkbox data to restore
function Checkbox:deserialize(data)
    self.checked = data.checked or false
    self.indeterminate = data.indeterminate or false
    self.label = data.label
    self.style = data.style or "default"
    self.variant = data.variant or "filled"
    self.shape = data.shape or "square"
    self.size = data.size or 20
    self.cornerRadius = data.cornerRadius or 3
    self.borderWidth = data.borderWidth or 1
    self.labelPosition = data.labelPosition or "right"
    self.labelSpacing = data.labelSpacing or 8
    self.toggleWidth = data.toggleWidth or (self.size * 2)
    self.toggleKnobSize = data.toggleKnobSize or (self.size * 0.8)
    self.checkIcon = data.checkIcon or "✓"
    self.indeterminateIcon = data.indeterminateIcon or "−"
    self.animationDuration = data.animationDuration or 0.2
    self.bounceEffect = data.bounceEffect ~= false
    self.rippleEffect = data.rippleEffect ~= false
    self.required = data.required or false
    self.group = data.group
    self.exclusive = data.exclusive or false
    self.validationState = data.validationState or "none"
    self.validationMessage = data.validationMessage or ""

    -- Set initial animation state
    self.checkAnimation = (self.checked or self.indeterminate) and 1 or 0
    self.toggleAnimationPos = self.checked and 1 or 0
end

return Checkbox
