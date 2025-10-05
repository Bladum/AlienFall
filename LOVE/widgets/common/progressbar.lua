--[[
widgets/progressbar.lua
ProgressBar widget (versatile progress indicator with animations and effects)


Versatile progress bar widget providing visual progress indication with rich animations,
multiple orientations, and visual effects for tactical strategy game interfaces.
Essential for displaying research progress, manufacturing queues, soldier health,
mission timers, and resource levels in OpenXCOM-style games.

PURPOSE:
- Display progress or fill levels with smooth animations
- Support multiple visual orientations and styling options
- Provide visual feedback for long-running operations
- Enable accessibility with value announcements
- Core component for progress tracking in strategy games

KEY FEATURES:
- Multiple orientations: horizontal, vertical, circular
- Smooth animated value transitions with easing
- Gradient fills and glow effects for visual appeal
- Pulse animation for attention-grabbing states
- Text display with customizable formatting
- Color theming and customization
- Accessibility support with screen reader announcements
- Performance optimized with efficient rendering

@see widgets.common.core.Base
@see widgets.complex.animation
@see widgets.common.label
@see widgets.common.panel
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar:new(x, y, w, h, value, min, max, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    obj.value = value or 0
    obj.min = min or 0
    obj.max = max or 100
    obj.animatedValue = obj.value

    -- Visual options
    obj.showText = options.showText ~= false
    obj.textFormat = options.textFormat or "%d%%"
    obj.orientation = options.orientation or "horizontal" -- horizontal, vertical, circular
    obj.gradient = options.gradient
    obj.pulseAnimation = options.pulseAnimation or false
    obj.glowEffect = options.glowEffect or false

    -- Animation options
    obj.animateChanges = options.animateChanges ~= false
    obj.animationDuration = options.animationDuration or 0.3
    obj.animationEasing = options.animationEasing or Animation.types.EASE_OUT

    -- Color theming
    obj.colors = {
        background = options.colors and options.colors.background or core.theme.secondary,
        fill = options.colors and options.colors.fill or core.theme.accent,
        border = options.colors and options.colors.border or core.theme.border,
        text = options.colors and options.colors.text or core.theme.text,
        glow = options.colors and options.colors.glow or
            { core.theme.accent[1], core.theme.accent[2], core.theme.accent[3], 0.3 }
    }

    -- Pulse animation state
    obj.pulseTime = 0
    obj.glowIntensity = 0

    setmetatable(obj, self)
    return obj
end

function ProgressBar:setValue(value, animate)
    local oldValue = self.value
    self.value = math.max(self.min, math.min(self.max, value))

    if animate ~= false and self.animateChanges and oldValue ~= self.value then
        Animation.animateWidget(self, "animatedValue", self.value, self.animationDuration, self.animationEasing)
    else
        self.animatedValue = self.value
    end
end

function ProgressBar:update(dt)
    core.Base.update(self, dt)

    -- Pulse animation
    if self.pulseAnimation then
        self.pulseTime = self.pulseTime + dt * 3
        self.glowIntensity = (math.sin(self.pulseTime) + 1) * 0.5
    end
end

function ProgressBar:draw()
    core.Base.draw(self)

    if self.orientation == "circular" then
        self:_drawCircular()
    elseif self.orientation == "vertical" then
        self:_drawVertical()
    else
        self:_drawHorizontal()
    end
end

--- Draws a horizontal progress bar (private method)
function ProgressBar:_drawHorizontal()
    local progress = (self.animatedValue - self.min) / (self.max - self.min)
    progress = math.max(0, math.min(1, progress))

    -- Background
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Glow effect
    if self.glowEffect then
        local glowAlpha = self.colors.glow[4] * (self.glowIntensity or 0.5)
        love.graphics.setColor(self.colors.glow[1], self.colors.glow[2], self.colors.glow[3], glowAlpha)
        love.graphics.rectangle("fill", self.x - 2, self.y - 2, (self.w + 4) * progress, self.h + 4)
    end

    -- Progress fill
    if progress > 0 then
        if self.gradient then
            self:_drawGradient(self.x, self.y, self.w * progress, self.h, self.gradient)
        else
            love.graphics.setColor(unpack(self.colors.fill))
            love.graphics.rectangle("fill", self.x, self.y, self.w * progress, self.h)
        end
    end

    -- Border
    love.graphics.setColor(unpack(self.colors.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Text
    if self.showText then
        self:_drawText(progress)
    end
end

--- Draws a vertical progress bar (private method)
function ProgressBar:_drawVertical()
    local progress = (self.animatedValue - self.min) / (self.max - self.min)
    progress = math.max(0, math.min(1, progress))

    -- Background
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Progress fill (from bottom)
    if progress > 0 then
        local fillHeight = self.h * progress
        local fillY = self.y + self.h - fillHeight

        if self.gradient then
            self:_drawGradient(self.x, fillY, self.w, fillHeight, self.gradient)
        else
            love.graphics.setColor(unpack(self.colors.fill))
            love.graphics.rectangle("fill", self.x, fillY, self.w, fillHeight)
        end
    end

    -- Border
    love.graphics.setColor(unpack(self.colors.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Text
    if self.showText then
        self:_drawText(progress)
    end
end

--- Draws a circular progress bar (private method)
function ProgressBar:_drawCircular()
    local progress = (self.animatedValue - self.min) / (self.max - self.min)
    progress = math.max(0, math.min(1, progress))

    local centerX = self.x + self.w / 2
    local centerY = self.y + self.h / 2
    local radius = math.min(self.w, self.h) / 2 - 5

    -- Background circle
    love.graphics.setColor(unpack(self.colors.background))
    love.graphics.circle("line", centerX, centerY, radius, 32)

    -- Progress arc
    if progress > 0 then
        love.graphics.setColor(unpack(self.colors.fill))
        love.graphics.arc("line", centerX, centerY, radius, -math.pi / 2, -math.pi / 2 + progress * 2 * math.pi, 32)
    end

    -- Text in center
    if self.showText then
        love.graphics.setColor(unpack(self.colors.text))
        local text = string.format(self.textFormat, progress * 100)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        love.graphics.print(text, centerX - textWidth / 2, centerY - textHeight / 2)
    end
end

--- Draws a gradient fill effect (private method)
--- @param x number The x-coordinate of the gradient area
--- @param y number The y-coordinate of the gradient area
--- @param w number The width of the gradient area
--- @param h number The height of the gradient area
--- @param gradient table Gradient configuration with start and stop colors
function ProgressBar:_drawGradient(x, y, w, h, gradient)
    -- Simple gradient approximation using multiple rectangles
    local steps = 20
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        local color = {
            gradient.start[1] + (gradient.stop[1] - gradient.start[1]) * t,
            gradient.start[2] + (gradient.stop[2] - gradient.start[2]) * t,
            gradient.start[3] + (gradient.stop[3] - gradient.start[3]) * t,
            gradient.start[4] and (gradient.start[4] + (gradient.stop[4] - gradient.start[4]) * t) or 1
        }
        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", x + i * w / steps, y, w / steps + 1, h)
    end
end

--- Draws the progress text overlay (private method)
--- @param progress number The current progress value (0-1)
function ProgressBar:_drawText(progress)
    love.graphics.setColor(unpack(self.colors.text))
    local text = string.format(self.textFormat, progress * 100)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    love.graphics.print(text, self.x + self.w / 2 - textWidth / 2, self.y + self.h / 2 - textHeight / 2)
end

return ProgressBar
