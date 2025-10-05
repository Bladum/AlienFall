--[[
widgets/animation.lua
Animation system for smooth transitions and effects


Comprehensive animation system providing smooth transitions and visual effects for all UI
elements in tactical strategy game interfaces. Essential for creating polished, responsive
user experiences in OpenXCOM-style games with smooth animations for unit movements,
UI state changes, and combat feedback.

PURPOSE:
- Provide smooth animations and transitions for UI elements
- Support various easing functions for natural motion
- Enable complex multi-property animations
- Manage active animations with automatic cleanup
- Enhance tactical gameplay with visual feedback

KEY FEATURES:
- Multiple easing functions: linear, ease-in/out, bounce, elastic
- Support for animating any numeric property (single values and tables)
- Active animation management with automatic cleanup
- Widget-specific convenience functions
- Multi-property simultaneous animations
- Animation stopping and cancellation
- Pre-built common animations (fade, scale, slide)
- Performance optimized with efficient updates

@see widgets.common.core.Base
@see widgets.common.button
@see widgets.common.panel
@see widgets.common.window
@see widgets.common.progressbar
]]
local Animation = {}

-- Animation types
Animation.types = {
    LINEAR = "linear",
    EASE_IN = "ease_in",
    EASE_OUT = "ease_out",
    EASE_IN_OUT = "ease_in_out",
    BOUNCE = "bounce",
    ELASTIC = "elastic"
}

-- Easing functions
local easingFunctions = {
    linear = function(t) return t end,
    ease_in = function(t) return t * t end,
    ease_out = function(t) return 1 - (1 - t) ^ 2 end,
    ease_in_out = function(t)
        return t < 0.5 and 2 * t * t or 1 - 2 * (1 - t) * (1 - t)
    end,
    bounce = function(t)
        if t < 1 / 2.75 then
            return 7.5625 * t * t
        elseif t < 2 / 2.75 then
            t = t - 1.5 / 2.75
            return 7.5625 * t * t + 0.75
        elseif t < 2.5 / 2.75 then
            t = t - 2.25 / 2.75
            return 7.5625 * t * t + 0.9375
        else
            t = t - 2.625 / 2.75
            return 7.5625 * t * t + 0.984375
        end
    end,
    elastic = function(t)
        if t == 0 or t == 1 then return t end
        local p = 0.3
        local s = p / 4
        return -(2 ^ (10 * (t - 1)) * math.sin((t - 1 - s) * (2 * math.pi) / p))
    end
}

-- Active animations
local activeAnimations = {}

--- Creates a new animation for a target object's property
--- @param target table The object whose property will be animated
--- @param property string The name of the property to animate
--- @param startValue number The starting value of the animation
--- @param endValue number The ending value of the animation
--- @param duration number The duration of the animation in seconds
--- @param easingType string The easing function to use (optional, defaults to LINEAR)
--- @param callback? function Callback function called when animation completes (optional)
--- @return number The animation ID for tracking/cancellation
function Animation.create(target, property, startValue, endValue, duration, easingType, callback)
    local animation = {
        target = target,
        property = property,
        startValue = startValue,
        endValue = endValue,
        duration = duration,
        elapsed = 0,
        easingType = easingType or Animation.types.LINEAR,
        callback = callback,
        id = math.random(1000000, 9999999)
    }

    activeAnimations[animation.id] = animation
    return animation.id
end

--- Updates all active animations by the given time delta
--- @param dt number Time delta since last update
function Animation.update(dt)
    for id, anim in pairs(activeAnimations) do
        anim.elapsed = anim.elapsed + dt
        local progress = math.min(anim.elapsed / anim.duration, 1)

        -- Apply easing
        local easedProgress = easingFunctions[anim.easingType](progress)

        -- Calculate current value
        local currentValue
        if type(anim.startValue) == "table" then
            currentValue = {}
            for i, startVal in ipairs(anim.startValue) do
                currentValue[i] = startVal + (anim.endValue[i] - startVal) * easedProgress
            end
        else
            currentValue = anim.startValue + (anim.endValue - anim.startValue) * easedProgress
        end

        -- Set the value
        anim.target[anim.property] = currentValue

        -- Check if animation is complete
        if progress >= 1 then
            if anim.callback then anim.callback() end
            activeAnimations[id] = nil
        end
    end
end

--- Stops and removes an animation by its ID
--- @param animationId number The ID of the animation to stop
function Animation.stop(animationId)
    activeAnimations[animationId] = nil
end

-- Stop all animations for a target
function Animation.stopAllForTarget(target)
    for id, anim in pairs(activeAnimations) do
        if anim.target == target then
            activeAnimations[id] = nil
        end
    end
end

--- Animates a widget property from its current value to a target value
--- @param widget table The widget object to animate
--- @param property string The property name to animate
--- @param targetValue number The target value to animate to
--- @param duration number The duration of the animation in seconds
--- @param easingType string The easing function to use (optional)
--- @param callback? function Callback function called when animation completes (optional)
--- @return number The animation ID
function Animation.animateWidget(widget, property, targetValue, duration, easingType, callback)
    local currentValue = widget[property]
    return Animation.create(widget, property, currentValue, targetValue, duration, easingType, callback)
end

-- Animate multiple properties simultaneously
function Animation.animateMultiple(widget, animations, callback)
    local animationIds = {}
    local completed = 0

    local function onComplete()
        completed = completed + 1
        if completed >= #animations and callback then
            callback()
        end
    end

    for _, anim in ipairs(animations) do
        local id = Animation.animateWidget(widget, anim.property, anim.targetValue,
            anim.duration, anim.easingType, onComplete)
        table.insert(animationIds, id)
    end

    return animationIds
end

--- Fades in a widget by animating its opacity from 0 to 1
--- @param widget table The widget to fade in
--- @param duration number The duration of the fade animation (optional, defaults to 0.3)
--- @param callback function Callback function called when fade completes (optional)
--- @return number The animation ID
function Animation.fadeIn(widget, duration, callback)
    widget.opacity = 0
    return Animation.animateWidget(widget, "opacity", 1, duration or 0.3, Animation.types.EASE_OUT, callback)
end

-- Fade out animation
function Animation.fadeOut(widget, duration, callback)
    return Animation.animateWidget(widget, "opacity", 0, duration or 0.3, Animation.types.EASE_IN, callback)
end

-- Scale animation
function Animation.scale(widget, targetScale, duration, callback)
    widget.scale = widget.scale or 1
    return Animation.animateWidget(widget, "scale", targetScale, duration or 0.2, Animation.types.EASE_OUT, callback)
end

-- Slide animation
function Animation.slide(widget, targetX, targetY, duration, callback)
    local animations = {}
    if targetX then table.insert(animations, { property = "x", targetValue = targetX, duration = duration }) end
    if targetY then table.insert(animations, { property = "y", targetValue = targetY, duration = duration }) end
    return Animation.animateMultiple(widget, animations, callback)
end

return Animation
