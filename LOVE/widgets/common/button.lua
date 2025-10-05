--[[
widgets/button.lua
Button widget (clickable control with rich styling and behavior)


Interactive button widget providing rich styling, accessibility, and behavior options
for tactical strategy game interfaces. Supports multiple visual variants, icons,
keyboard navigation, loading states, and validation integration.

PURPOSE:
- Provide a flexible button component supporting multiple visual variants, icons,
  keyboard accessibility, loading state, and validation integration.
- Essential UI component for OpenXCOM-style interfaces requiring consistent,
  accessible button controls across geoscape, battlescape, and base screens.

KEY FEATURES:
- Multiple visual styles: default, primary, secondary, danger, success, warning
- Size variants: small, medium, large
- Visual variants: filled, outlined, ghost, link
- Icon support with configurable positioning
- Loading state with spinner animation
- Keyboard accessibility and focus management
- Validation integration
- Ripple effects and hover animations
- Toggle button functionality

@see widgets.common.core.Base
@see widgets.complex.animation
@see widgets.common.validation
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Validation = require("widgets.common.validation")
local Interactive = require("widgets.common.interactive_mixin")

local Button = {}
Button.__index = Button

--- Creates a new Button widget instance.
---
---@param x number The x-coordinate position.
---@param y number The y-coordinate position.
---@param w number The width of the button.
---@param h number The height of the button.
---@param text string|table The button text or options table.
---@param callback? function The function to call when button is clicked.
---@param options? table Optional configuration table for styling and behavior.
---@return table A new button widget instance.
function Button:new(x, y, w, h, text, callback, options)
    if type(text) == "table" then
        options = text
        text = options.text or "Button"
        callback = options.onClick or options.callback or function() end
    end
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    obj.text = text or "Button"
    obj.callback = callback or function() end
    obj.accessibilityLabel = obj.accessibilityLabel or obj.text
    obj.accessibilityHint = obj.accessibilityHint or "Press to activate"

    -- Enhanced styling options
    obj.style = options.style or "default"    -- default, primary, secondary, danger, success, warning
    obj.size = options.size or "medium"       -- small, medium, large
    obj.variant = options.variant or "filled" -- filled, outlined, ghost, link

    -- Icon support
    obj.icon = options.icon                           -- Icon text or path
    obj.iconPosition = options.iconPosition or "left" -- left, right, top, bottom, center
    obj.iconSize = options.iconSize or 16
    obj.iconSpacing = options.iconSpacing or 8

    -- Enhanced visual options
    obj.cornerRadius = options.cornerRadius or 4
    obj.borderWidth = options.borderWidth or 1
    obj.elevation = options.elevation or 0 -- Shadow depth
    obj.gradient = options.gradient        -- {start_color, end_color, direction}
    obj.rippleEffect = options.rippleEffect ~= false
    obj.glowEffect = options.glowEffect or false

    -- State and interaction
    obj.loading = false
    obj.loadingText = options.loadingText or "Loading..."
    obj.clickSound = options.clickSound
    obj.hapticFeedback = options.hapticFeedback ~= false

    -- Validation integration
    ---@type any
    obj.validator = options.validator
    obj.validationMessage = ""
    obj.validationState = "none" -- none, valid, invalid, warning

    -- Animation properties
    obj.animationDuration = options.animationDuration or 0.15
    obj.hoverScale = options.hoverScale or 1.05
    obj.pressScale = options.pressScale or 0.95
    obj.bounceOnClick = options.bounceOnClick or false

    -- Dynamic properties for animation
    obj.currentScale = 1
    obj.currentRotation = 0
    obj.currentAlpha = 1
    obj.ripples = {}

    -- Color configuration (enhanced)
    obj:_setupColors(options)

    -- Font setup
    obj.font = options.font or love.graphics.getFont()
    obj.textAlignment = options.textAlignment or "center"

    -- Event callbacks
    obj.onHoverStart = options.onHoverStart
    obj.onHoverEnd = options.onHoverEnd
    obj.onFocusGain = options.onFocusGain
    obj.onFocusLoss = options.onFocusLoss

    -- Attach interactive helpers (hover/press/focus/tooltip)
    Interactive.init(obj)

    setmetatable(obj, self)
    return obj
end

--- Sets up color scheme for the button based on style and options (private method).
---
---@param options table Configuration options containing custom colors.
function Button:_setupColors(options)
    local baseColors = self:_getStyleColors(self.style)

    self.colors = {
        normal = options.colors and options.colors.normal or baseColors.normal,
        hover = options.colors and options.colors.hover or baseColors.hover,
        pressed = options.colors and options.colors.pressed or baseColors.pressed,
        disabled = options.colors and options.colors.disabled or baseColors.disabled,
        text = options.colors and options.colors.text or baseColors.text,
        textDisabled = options.colors and options.colors.textDisabled or baseColors.textDisabled,
        border = options.colors and options.colors.border or baseColors.border,
        shadow = options.colors and options.colors.shadow or { 0, 0, 0, 0.3 },
        glow = options.colors and options.colors.glow or baseColors.glow,
        ripple = options.colors and options.colors.ripple or { 1, 1, 1, 0.3 }
    }
end

--- Gets the base color scheme for a given button style (private method).
---
---@param style string The button style name (default, primary, etc.).
---@return table Color configuration table with normal, hover, pressed, etc. colors.
function Button:_getStyleColors(style)
    local theme = core.theme
    local styles = {
        default = {
            normal = theme.surface,
            hover = theme.surfaceHover,
            pressed = theme.surfacePressed,
            text = theme.text,
            textDisabled = theme.textDisabled,
            border = theme.border,
            disabled = theme.surfaceDisabled,
            glow = theme.accent
        },
        primary = {
            normal = theme.primary,
            hover = theme.primaryHover,
            pressed = theme.primaryPressed,
            text = theme.textOnPrimary,
            textDisabled = theme.textDisabled,
            border = theme.primary,
            disabled = theme.primaryDisabled,
            glow = theme.primaryLight
        },
        secondary = {
            normal = theme.secondary,
            hover = theme.secondaryHover,
            pressed = theme.secondaryPressed,
            text = theme.textOnSecondary,
            textDisabled = theme.textDisabled,
            border = theme.secondary,
            disabled = theme.secondaryDisabled,
            glow = theme.secondaryLight
        },
        danger = {
            normal = theme.error,
            hover = theme.errorHover,
            pressed = theme.errorPressed,
            text = theme.textOnError,
            textDisabled = theme.textDisabled,
            border = theme.error,
            disabled = theme.errorDisabled,
            glow = theme.errorLight
        },
        success = {
            normal = theme.success,
            hover = theme.successHover,
            pressed = theme.successPressed,
            text = theme.textOnSuccess,
            textDisabled = theme.textDisabled,
            border = theme.success,
            disabled = theme.successDisabled,
            glow = theme.successLight
        },
        warning = {
            normal = theme.warning,
            hover = theme.warningHover,
            pressed = theme.warningPressed,
            text = theme.textOnWarning,
            textDisabled = theme.textDisabled,
            border = theme.warning,
            disabled = theme.warningDisabled,
            glow = theme.warningLight
        }
    }

    return styles[style] or styles.default
end

--- Updates the button state and animations
--- @param dt number Time delta since last update
function Button:update(dt)
    core.Base.update(self, dt)
    Animation.update(dt)

    local mx, my = love.mouse.getPosition()
    local wasHovered = self.hovered
    -- Use interactive mixin to update hovered state (keeps backward compatibility)
    local inside = false
    if self.enabled and self.visible then
        inside = self:_updateHover(mx, my)
    end
    self.hovered = inside

    -- Handle hover state changes
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
        ripple.alpha = math.max(0, ripple.alpha - dt * 2)

        if ripple.alpha <= 0 then
            table.remove(self.ripples, i)
        end
    end

    -- Show tooltip if hovered (mixin helper)
    if self.tooltip then
        self:_showTooltipWhenHovered()
    end

    -- Validate if needed
    if self.validator and self.validationState == "none" then
        self:validate()
    end
end

--- Handles hover start event and triggers animations (private method)
function Button:_onHoverStart()
    if self.onHoverStart then
        self.onHoverStart(self)
    end

    if self.tooltip then
        core.setTooltipWidget(self)
    end

    -- Animate hover scale
    if self.hoverScale ~= 1 then
        Animation.animateWidget(self, "currentScale", self.hoverScale, self.animationDuration, Animation.types.EASE_OUT)
    end

    -- Glow effect
    if self.glowEffect then
        Animation.animateWidget(self, "glowIntensity", 1, self.animationDuration, Animation.types.EASE_OUT)
    end
end

--- Handles hover end event and triggers animations (private method)
function Button:_onHoverEnd()
    if self.onHoverEnd then
        self.onHoverEnd(self)
    end

    if self.tooltip then
        core.setTooltipWidget(nil)
    end

    -- Animate back to normal scale
    Animation.animateWidget(self, "currentScale", 1, self.animationDuration, Animation.types.EASE_OUT)

    -- Remove glow effect
    if self.glowEffect then
        Animation.animateWidget(self, "glowIntensity", 0, self.animationDuration, Animation.types.EASE_OUT)
    end
end

--- Activates the button, triggering the callback if enabled
function Button:activate()
    if not self.enabled or not self.visible or self.loading then
        return
    end

    -- Validate before activation
    if self.validator and not self:validate() then
        return
    end

    -- Visual feedback
    if self.bounceOnClick then
        Animation.animateWidget(self, "currentScale", self.pressScale, 0.05, Animation.types.EASE_OUT,
            function()
                Animation.animateWidget(self, "currentScale", 1, 0.1, Animation.types.EASE_OUT)
            end)
    end

    -- Sound feedback
    if self.clickSound then
        -- Placeholder for sound system
        -- love.audio.play(self.clickSound)
    end

    -- Execute callback
    core.safeCall(self.callback, "Button callback", self)

    -- Accessibility announcement
    if core.config.enableAccessibility then
        core.announce("Activated: " .. self:getAccessibilityLabel())
    end
end

--- Validates the button's current state using the configured validator
--- @return boolean True if validation passes, false otherwise
function Button:validate()
    if not self.validator then
        self.validationState = "none"
        return true
    end

    local result = Validation.validateWidget(self, self.validator)
    self.validationState = result.state
    self.validationMessage = result.message or ""

    return result.state == "valid" or result.state == "none"
end

--- Handles keyboard input for the button
--- @param key string The key that was pressed
function Button:keypressed(key)
    if not self.focused then return core.Base.keypressed(self, key) end

    if key == "return" or key == "kpenter" or key == "space" then
        self:activate()
        return true
    end

    return core.Base.keypressed(self, key)
end

--- Draws the button and all its visual elements
function Button:draw()
    core.Base.draw(self)

    love.graphics.push()

    -- Apply transformations
    local centerX = self.x + self.w / 2
    local centerY = self.y + self.h / 2
    love.graphics.translate(centerX, centerY)
    love.graphics.scale(self.currentScale or 1)
    love.graphics.rotate(self.currentRotation or 0)
    love.graphics.translate(-centerX, -centerY)

    -- Draw shadow/elevation
    if self.elevation > 0 and not (self.variant == "ghost" or self.variant == "link") then
        self:_drawShadow()
    end

    -- Draw glow effect
    if self.glowEffect and (self.glowIntensity or 0) > 0 then
        self:_drawGlow()
    end

    -- Draw background
    self:_drawBackground()

    -- Draw border
    if self.variant ~= "ghost" and self.variant ~= "link" then
        self:_drawBorder()
    end

    -- Draw ripple effects
    if self.rippleEffect then
        self:_drawRipples()
    end

    -- Draw content (icon + text)
    self:_drawContent()

    -- Draw loading overlay
    if self.loading then
        self:_drawLoadingOverlay()
    end

    -- Draw validation indicator
    if self.validationState ~= "none" then
        self:_drawValidationIndicator()
    end

    love.graphics.pop()

    -- Draw focus ring outside transformation
    if self.focused then
        self:_drawFocusRing()
    end
end

--- Draws the button shadow effect (private method)
function Button:_drawShadow()
    local offset = self.elevation * 2
    love.graphics.setColor(table.unpack(self.colors.shadow))

    if self.cornerRadius > 0 then
        -- Rounded rectangle shadow (simplified)
        love.graphics.rectangle("fill", self.x + offset, self.y + offset,
            self.w, self.h, self.cornerRadius)
    else
        love.graphics.rectangle("fill", self.x + offset, self.y + offset, self.w, self.h)
    end
end

--- Draws the button glow effect (private method)
function Button:_drawGlow()
    local glowSize = 10 * (self.glowIntensity or 0)
    love.graphics.setColor(table.unpack(self.colors.glow))

    -- Simple glow effect
    for i = 1, 3 do
        local size = glowSize * i
        local alpha = (self.colors.glow[4] or 1) * (self.glowIntensity or 0) / (i * 2)
        love.graphics.setColor(self.colors.glow[1], self.colors.glow[2], self.colors.glow[3], alpha)

        if self.cornerRadius > 0 then
            love.graphics.rectangle("fill", self.x - size, self.y - size,
                self.w + size * 2, self.h + size * 2,
                self.cornerRadius + size)
        else
            love.graphics.rectangle("fill", self.x - size, self.y - size,
                self.w + size * 2, self.h + size * 2)
        end
    end
end

--- Draws the button background (private method)
function Button:_drawBackground()
    local color = self:_getCurrentBackgroundColor()

    if self.gradient and self.variant == "filled" then
        self:_drawGradientBackground(color)
    else
        love.graphics.setColor(table.unpack(color))

        if self.variant == "ghost" then
            -- Ghost buttons have transparent background
            love.graphics.setColor(color[1], color[2], color[3], 0.1)
        elseif self.variant == "link" then
            -- Link buttons have no background
            return
        end

        if self.cornerRadius > 0 then
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.cornerRadius)
        else
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        end
    end
end

--- Draws the button gradient background (private method)
--- @param baseColor table The base color for the gradient
function Button:_drawGradientBackground(baseColor)
    -- Simplified gradient using multiple rectangles
    local steps = 10
    local stepHeight = self.h / steps

    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        local startColor = self.gradient.start or baseColor
        local endColor = self.gradient.end_ or baseColor

        local r = startColor[1] + (endColor[1] - startColor[1]) * t
        local g = startColor[2] + (endColor[2] - startColor[2]) * t
        local b = startColor[3] + (endColor[3] - startColor[3]) * t
        local a = (startColor[4] or 1) + ((endColor[4] or 1) - (startColor[4] or 1)) * t

        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", self.x, self.y + i * stepHeight, self.w, stepHeight + 1)
    end
end

--- Draws the button border (private method)
function Button:_drawBorder()
    local borderColor = self:_getCurrentBorderColor()

    love.graphics.setColor(table.unpack(borderColor))
    love.graphics.setLineWidth(self.borderWidth)

    if self.cornerRadius > 0 then
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.cornerRadius)
    else
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    end

    love.graphics.setLineWidth(1)
end

--- Draws the button ripple effects (private method)
function Button:_drawRipples()
    for _, ripple in ipairs(self.ripples) do
        love.graphics.setColor(self.colors.ripple[1], self.colors.ripple[2],
            self.colors.ripple[3], ripple.alpha)
        love.graphics.circle("fill", ripple.x, ripple.y, ripple.radius)
    end
end

--- Draws the button content (icon and text) (private method)
function Button:_drawContent()
    love.graphics.setFont(self.font)

    local textColor = self:_getCurrentTextColor()
    love.graphics.setColor(table.unpack(textColor))

    local contentX, contentY, contentW, contentH = self:_getContentBounds()

    if self.icon and self.text then
        self:_drawIconAndText(contentX, contentY, contentW, contentH)
    elseif self.icon then
        self:_drawIcon(contentX, contentY, contentW, contentH)
    elseif self.text then
        self:_drawText(contentX, contentY, contentW, contentH)
    end
end

--- Draws the button icon and text together (private method)
--- @param x number The x-coordinate for drawing
--- @param y number The y-coordinate for drawing
--- @param w number The width available for drawing
--- @param h number The height available for drawing
function Button:_drawIconAndText(x, y, w, h)
    local iconW, iconH = self.iconSize, self.iconSize
    local textW = self.font:getWidth(self:_getDisplayText())
    local textH = self.font:getHeight()

    local totalW, totalH
    local iconX, iconY, textX, textY

    if self.iconPosition == "left" or self.iconPosition == "right" then
        totalW = iconW + self.iconSpacing + textW
        totalH = math.max(iconH, textH)

        local startX = x + (w - totalW) / 2
        local centerY = y + h / 2

        if self.iconPosition == "left" then
            iconX = startX
            textX = startX + iconW + self.iconSpacing
        else
            textX = startX
            iconX = startX + textW + self.iconSpacing
        end

        iconY = centerY - iconH / 2
        textY = centerY - textH / 2
    elseif self.iconPosition == "top" or self.iconPosition == "bottom" then
        totalW = math.max(iconW, textW)
        totalH = iconH + self.iconSpacing + textH

        local centerX = x + w / 2
        local startY = y + (h - totalH) / 2

        if self.iconPosition == "top" then
            iconY = startY
            textY = startY + iconH + self.iconSpacing
        else
            textY = startY
            iconY = startY + textH + self.iconSpacing
        end

        iconX = centerX - iconW / 2
        textX = centerX - textW / 2
    else -- center
        iconX = x + (w - iconW) / 2
        iconY = y + (h - iconH) / 2
        textX = x
        textY = y + (h - textH) / 2
    end

    -- Draw icon
    love.graphics.print(self.icon, iconX, iconY)

    -- Draw text
    if self.iconPosition == "center" then
        love.graphics.printf(self:_getDisplayText(), textX, textY, w, "center")
    else
        love.graphics.print(self:_getDisplayText(), textX, textY)
    end
end

--- Draws the button icon (private method)
--- @param x number The x-coordinate for drawing
--- @param y number The y-coordinate for drawing
--- @param w number The width available for drawing
--- @param h number The height available for drawing
function Button:_drawIcon(x, y, w, h)
    local iconX = x + (w - self.iconSize) / 2
    local iconY = y + (h - self.iconSize) / 2

    love.graphics.print(self.icon, iconX, iconY)
end

--- Draws the button text (private method)
--- @param x number The x-coordinate for drawing
--- @param y number The y-coordinate for drawing
--- @param w number The width available for drawing
--- @param h number The height available for drawing
function Button:_drawText(x, y, w, h)
    local text = self:_getDisplayText()
    local textH = self.font:getHeight()
    local textY = y + (h - textH) / 2

    if self.textAlignment == "center" then
        love.graphics.printf(text, x, textY, w, "center")
    elseif self.textAlignment == "left" then
        love.graphics.print(text, x + 8, textY)
    elseif self.textAlignment == "right" then
        love.graphics.printf(text, x, textY, w - 8, "right")
    end
end

--- Draws the loading overlay with spinner (private method)
function Button:_drawLoadingOverlay()
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.5)

    if self.cornerRadius > 0 then
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.cornerRadius)
    else
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end

    -- Loading spinner (simple rotating dots)
    local time = love.timer.getTime()
    local centerX = self.x + self.w / 2
    local centerY = self.y + self.h / 2

    love.graphics.setColor(1, 1, 1, 1)
    for i = 0, 7 do
        local angle = (time * 2 + i * math.pi / 4) % (math.pi * 2)
        local x = centerX + math.cos(angle) * 8
        local y = centerY + math.sin(angle) * 8
        local alpha = 0.3 + 0.7 * ((i + 1) / 8)

        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.circle("fill", x, y, 2)
    end
end

--- Draws the validation state indicator (private method)
function Button:_drawValidationIndicator()
    local indicatorSize = 8
    local indicatorX = self.x + self.w - indicatorSize - 2
    local indicatorY = self.y + 2

    local color
    if self.validationState == "valid" then
        color = core.theme.success
    elseif self.validationState == "invalid" then
        color = core.theme.error
    elseif self.validationState == "warning" then
        color = core.theme.warning
    else
        return
    end

    love.graphics.setColor(table.unpack(color))
    love.graphics.circle("fill", indicatorX + indicatorSize / 2, indicatorY + indicatorSize / 2, indicatorSize / 2)
end

--- Draws the focus ring for accessibility (private method)
function Button:_drawFocusRing()
    love.graphics.setColor(table.unpack(core.focus.focusRingColor))
    love.graphics.setLineWidth(2)

    local padding = 2
    if self.cornerRadius > 0 then
        love.graphics.rectangle("line", self.x - padding, self.y - padding,
            self.w + padding * 2, self.h + padding * 2,
            self.cornerRadius + padding)
    else
        love.graphics.rectangle("line", self.x - padding, self.y - padding,
            self.w + padding * 2, self.h + padding * 2)
    end

    love.graphics.setLineWidth(1)
end

-- Helper methods
--- Gets the current background color based on button state (private method)
--- @return table The current background color as RGBA table
function Button:_getCurrentBackgroundColor()
    if not self.enabled then
        return self.colors.disabled
    elseif self.pressed then
        return self.colors.pressed
    elseif self.hovered then
        return self.colors.hover
    else
        return self.colors.normal
    end
end

--- Gets the current border color based on button state (private method)
--- @return table The current border color as RGBA table
function Button:_getCurrentBorderColor()
    if self.variant == "outlined" then
        return self:_getCurrentBackgroundColor()
    else
        return self.colors.border
    end
end

--- Gets the current text color based on button state (private method)
--- @return table The current text color as RGBA table
function Button:_getCurrentTextColor()
    if not self.enabled then
        return self.colors.textDisabled
    elseif self.variant == "ghost" or self.variant == "link" then
        return self:_getCurrentBackgroundColor()
    else
        return self.colors.text
    end
end

--- Gets the text to display (loading text or regular text) (private method)
--- @return string The text to display on the button
function Button:_getDisplayText()
    if self.loading then
        return self.loadingText
    else
        return self.text
    end
end

--- Gets the bounds for content drawing (private method)
--- @return number, number, number, number The x, y, width, height for content area
function Button:_getContentBounds()
    local padding = 8
    return self.x + padding, self.y + padding,
        self.w - padding * 2, self.h - padding * 2
end

-- Event handlers
--- Handles mouse press events
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean True if the event was handled, false otherwise
function Button:mousepressed(x, y, button)
    if not self:hitTest(x, y) or button ~= 1 or not self.enabled then
        return false
    end

    core.setFocus(self)

    -- Use mixin helper to mark pressed state; still run existing visual feedback
    local handled = false
    if type(self._mousepressed) == "function" then
        handled = self:_mousepressed(x, y, button)
    else
        self._interactive.pressed = true
        handled = true
    end

    if handled then
        self.pressed = self._interactive.pressed

        -- Create ripple effect
        if self.rippleEffect then
            table.insert(self.ripples, {
                x = x,
                y = y,
                radius = 0,
                speed = 200,
                alpha = self.colors.ripple[4] or 0.3,
                time = 0
            })
        end

        -- Immediate press animation
        if not self.bounceOnClick then
            Animation.animateWidget(self, "currentScale", self.pressScale, 0.05, Animation.types.EASE_OUT)
        end

        return true
    end

    return false
end

--- Handles mouse release events
--- @param x number The x-coordinate of the mouse release
--- @param y number The y-coordinate of the mouse release
--- @param button number The mouse button that was released
function Button:mousereleased(x, y, button)
    if button == 1 then
        if self.pressed and self:hitTest(x, y) then
            -- Preserve existing activation flow (validation + callbacks)
            self:activate()
        end

        -- Clear both legacy and mixin pressed flags
        self.pressed = false
        if self._interactive then self._interactive.pressed = false end

        -- Release animation
        if not self.bounceOnClick then
            local targetScale = self.hovered and self.hoverScale or 1
            Animation.animateWidget(self, "currentScale", targetScale, 0.1, Animation.types.EASE_OUT)
        end
    end
end

-- Public API methods
--- Sets the loading state of the button
--- @param loading boolean Whether the button should show loading state
function Button:setLoading(loading)
    self.loading = loading
end

--- Sets the button text
--- @param text string The new text to display on the button
function Button:setText(text)
    self.text = text or ""
    self.accessibilityLabel = self.accessibilityLabel or self.text
end

--- Sets the button icon and optional position
--- @param icon string|table The icon to display (text or image path)
--- @param position string Optional icon position ("left", "right", "top", "bottom", "center")
function Button:setIcon(icon, position)
    self.icon = icon
    if position then
        self.iconPosition = position
    end
end

--- Sets the button style
--- @param style string The style name ("default", "primary", "secondary", "danger", "success", "warning")
function Button:setStyle(style)
    self.style = style
    self:_setupColors({})
end

--- Sets the button variant
--- @param variant string The variant name ("filled", "outlined", "ghost", "link")
function Button:setVariant(variant)
    self.variant = variant
end

--- Sets the enabled state of the button
--- @param enabled boolean Whether the button should be enabled
function Button:setEnabled(enabled)
    local wasEnabled = self.enabled
    self.enabled = enabled

    if not enabled then
        self.hovered = false
        self.pressed = false
        if self.focused then
            core.setFocus(nil)
        end
    end

    -- Reset animations
    if not enabled then
        Animation.cancelWidgetAnimations(self)
        self.currentScale = 1
        self.currentRotation = 0
        self.currentAlpha = 1
    end
end

--- Sets the validation function for the button
--- @param validator function The validation function to use
function Button:setValidator(validator)
    self.validator = validator
    self.validationState = "none"
end

--- Gets the current validation state and message
--- @return string, string The validation state ("none", "valid", "invalid", "warning") and message
function Button:getValidationState()
    return self.validationState, self.validationMessage
end

-- Serialization
--- Serializes the button state for saving
--- @return table The serialized button data
function Button:serialize()
    return {
        text = self.text,
        style = self.style,
        variant = self.variant,
        size = self.size,
        icon = self.icon,
        iconPosition = self.iconPosition,
        cornerRadius = self.cornerRadius,
        elevation = self.elevation,
        colors = self.colors,
        animationDuration = self.animationDuration,
        hoverScale = self.hoverScale,
        pressScale = self.pressScale,
        bounceOnClick = self.bounceOnClick,
        rippleEffect = self.rippleEffect,
        glowEffect = self.glowEffect
    }
end

--- Deserializes button state from saved data
--- @param data table The serialized button data to restore
function Button:deserialize(data)
    self.text = data.text or "Button"
    self.style = data.style or "default"
    self.variant = data.variant or "filled"
    self.size = data.size or "medium"
    self.icon = data.icon
    self.iconPosition = data.iconPosition or "left"
    self.cornerRadius = data.cornerRadius or 4
    self.elevation = data.elevation or 0
    self.colors = data.colors or self.colors
    self.animationDuration = data.animationDuration or 0.15
    self.hoverScale = data.hoverScale or 1.05
    self.pressScale = data.pressScale or 0.95
    self.bounceOnClick = data.bounceOnClick or false
    self.rippleEffect = data.rippleEffect ~= false
    self.glowEffect = data.glowEffect or false
end

return Button
