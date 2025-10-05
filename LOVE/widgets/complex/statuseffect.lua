--[[
widgets/statuseffect.lua
StatusEffect widget for displaying temporary unit conditions and buffs/debuffs.


Visual representation widget for temporary unit status effects, buffs, and debuffs.
Displays active conditions with icons, durations, stacks, and animated transitions.

PURPOSE:
- Present active status effects (buffs/debuffs) with clear visual representation
- Communicate unit state changes through icons, timers, and animations
- Support stacking effects and duration tracking for complex game mechanics
- Provide intuitive feedback for temporary conditions and modifiers

KEY FEATURES:
- Icon-based display for different effect types
- Duration timers with visual countdown indicators
- Stacking/count indicators for multiple instances
- Tooltip support for detailed effect information
- Priority-based ordering and layout
- Animated transitions for effect changes
- Customizable styling per effect type
- Accessibility support for screen readers

@see widgets.common.core.Base
@see widgets.complex.animation
@see widgets.common.tooltip
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")

local StatusEffect = {}
StatusEffect.__index = StatusEffect
setmetatable(StatusEffect, { __index = core.Base })

-- Effect types with default styling
StatusEffect.EFFECT_TYPES = {
    BUFF = {
        borderColor = { 0.2, 0.8, 0.2 },
        backgroundColor = { 0.1, 0.4, 0.1, 0.8 },
        glowColor = { 0.3, 1.0, 0.3, 0.5 },
        priority = 1
    },
    DEBUFF = {
        borderColor = { 0.8, 0.2, 0.2 },
        backgroundColor = { 0.4, 0.1, 0.1, 0.8 },
        glowColor = { 1.0, 0.3, 0.3, 0.5 },
        priority = 2
    },
    NEUTRAL = {
        borderColor = { 0.6, 0.6, 0.6 },
        backgroundColor = { 0.3, 0.3, 0.3, 0.8 },
        glowColor = { 0.8, 0.8, 0.8, 0.3 },
        priority = 3
    },
    CRITICAL = {
        borderColor = { 1.0, 0.6, 0.0 },
        backgroundColor = { 0.5, 0.3, 0.0, 0.8 },
        glowColor = { 1.0, 0.8, 0.0, 0.7 },
        priority = 0
    }
}

function StatusEffect:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Configuration
    obj.effectSize = (options and options.effectSize) or 32
    obj.effectSpacing = (options and options.effectSpacing) or 4
    obj.maxEffectsPerRow = (options and options.maxEffectsPerRow) or 8
    obj.showDuration = (options and options.showDuration) ~= false
    obj.showStacks = (options and options.showStacks) ~= false
    obj.animateChanges = (options and options.animateChanges) ~= false
    obj.sortByPriority = (options and options.sortByPriority) ~= false

    -- Visual styling
    obj.backgroundColor = (options and options.backgroundColor) or { 0, 0, 0, 0 }
    obj.borderWidth = (options and options.borderWidth) or 2
    obj.cornerRadius = (options and options.cornerRadius) or 4
    obj.glowSize = (options and options.glowSize) or 2
    obj.durationFontSize = (options and options.durationFontSize) or 10
    obj.stackFontSize = (options and options.stackFontSize) or 12

    -- State
    obj.effects = {}
    obj.layout = {}
    obj.needsLayoutUpdate = true

    setmetatable(obj, self)
    return obj
end

function StatusEffect:addEffect(effectData)
    local effect = {
        id = effectData.id or (#self.effects + 1),
        name = effectData.name or "Unknown Effect",
        description = effectData.description or "",
        icon = effectData.icon,
        type = effectData.type or "NEUTRAL",
        duration = effectData.duration or 0, -- 0 = permanent
        maxDuration = effectData.maxDuration or effectData.duration or 0,
        stacks = effectData.stacks or 1,
        maxStacks = effectData.maxStacks or 1,

        -- Visual state
        x = self.x + self.w, -- Start off-screen for animation
        y = self.y,
        alpha = 0,
        scale = 0.5,
        targetX = 0,
        targetY = 0,

        -- Animation state
        isNew = true,
        isRemoving = false,
        glowPhase = 0,

        -- Custom properties
        data = effectData.data or {}
    }

    -- Check if effect already exists (for stacking)
    local existingIndex = self:_findEffectIndex(effect.id)
    if existingIndex then
        local existing = self.effects[existingIndex]
        existing.stacks = math.min(existing.stacks + (effect.stacks or 1), existing.maxStacks)
        existing.duration = math.max(existing.duration, effect.duration)

        -- Refresh animation
        if self.animateChanges then
            Animation.create(existing, "scale", existing.scale or 1, 1.2, 0.1)
            Animation.create(existing, "scale", 1.2, 1.0, 0.1)
        end
        return existing.id
    end

    -- Add new effect
    table.insert(self.effects, effect)

    -- Sort by priority if enabled
    if self.sortByPriority then
        table.sort(self.effects, function(a, b)
            local aPriority = self.EFFECT_TYPES[a.type] and self.EFFECT_TYPES[a.type].priority or 999
            local bPriority = self.EFFECT_TYPES[b.type] and self.EFFECT_TYPES[b.type].priority or 999
            return aPriority < bPriority
        end)
    end

    self:_updateLayout()

    -- Animate in
    if self.animateChanges then
        Animation:animate(effect, 0.3, {
            x = effect.targetX,
            y = effect.targetY,
            alpha = 1.0,
            scale = 1.0
        }, "easeOutBack")
    else
        effect.x = effect.targetX
        effect.y = effect.targetY
        effect.alpha = 1.0
        effect.scale = 1.0
    end

    return effect.id
end

function StatusEffect:removeEffect(effectId)
    local index = self:_findEffectIndex(effectId)
    if not index then return false end

    local effect = self.effects[index]
    effect.isRemoving = true

    if self.animateChanges then
        Animation:animate(effect, 0.2, {
            alpha = 0,
            scale = 0.5,
            y = effect.y - 10
        }, "easeInQuad", function()
            table.remove(self.effects, index)
            self:_updateLayout()
        end)
    else
        table.remove(self.effects, index)
        self:_updateLayout()
    end

    return true
end

function StatusEffect:updateEffect(effectId, newData)
    local index = self:_findEffectIndex(effectId)
    if not index then return false end

    local effect = self.effects[index]

    -- Update properties
    if newData.duration then effect.duration = newData.duration end
    if newData.stacks then effect.stacks = math.min(newData.stacks, effect.maxStacks) end
    if newData.description then effect.description = newData.description end
    if newData.data then
        for k, v in pairs(newData.data) do
            effect.data[k] = v
        end
    end

    return true
end

function StatusEffect:_findEffectIndex(effectId)
    for i, effect in ipairs(self.effects) do
        if effect.id == effectId then
            return i
        end
    end
    return nil
end

function StatusEffect:_updateLayout()
    local currentX = self.x
    local currentY = self.y
    local rowCount = 0

    for i, effect in ipairs(self.effects) do
        if not effect.isRemoving then
            effect.targetX = currentX
            effect.targetY = currentY

            currentX = currentX + self.effectSize + self.effectSpacing
            rowCount = rowCount + 1

            -- Wrap to next row
            if rowCount >= self.maxEffectsPerRow then
                currentX = self.x
                currentY = currentY + self.effectSize + self.effectSpacing
                rowCount = 0
            end

            -- Animate to new position if not new
            if not effect.isNew and self.animateChanges then
                Animation:animate(effect, 0.2, {
                    x = effect.targetX,
                    y = effect.targetY
                }, "easeOutQuad")
            end

            effect.isNew = false
        end
    end

    self.needsLayoutUpdate = false
end

function StatusEffect:update(dt)
    core.Base.update(self, dt)

    -- Update effect timers
    for i = #self.effects, 1, -1 do
        local effect = self.effects[i]

        -- Update duration
        if effect.duration > 0 then
            effect.duration = effect.duration - dt
            if effect.duration <= 0 then
                self:removeEffect(effect.id)
            end
        end

        -- Update glow animation
        effect.glowPhase = (effect.glowPhase + dt * 2) % (math.pi * 2)
    end

    -- Update layout if needed
    if self.needsLayoutUpdate then
        self:_updateLayout()
    end
end

function StatusEffect:draw()
    if not self.visible then return end

    local r, g, b, a = love.graphics.getColor()

    for _, effect in ipairs(self.effects) do
        if effect.alpha > 0 then
            self:_drawEffect(effect)
        end
    end

    -- Restore color
    love.graphics.setColor(r, g, b, a)
end

function StatusEffect:_drawEffect(effect)
    local effectType = self.EFFECT_TYPES[effect.type] or self.EFFECT_TYPES.NEUTRAL
    local size = self.effectSize * effect.scale
    local halfSize = size / 2
    local centerX = effect.x + halfSize
    local centerY = effect.y + halfSize

    -- Draw glow effect
    if effectType.glowColor then
        local glowIntensity = 0.5 + 0.3 * math.sin(effect.glowPhase)
        love.graphics.setColor(effectType.glowColor[1], effectType.glowColor[2],
            effectType.glowColor[3], (effectType.glowColor[4] or 1) * effect.alpha * glowIntensity)
        love.graphics.rectangle("fill", effect.x - self.glowSize, effect.y - self.glowSize,
            size + self.glowSize * 2, size + self.glowSize * 2, self.cornerRadius + self.glowSize)
    end

    -- Draw background
    love.graphics.setColor(effectType.backgroundColor[1], effectType.backgroundColor[2],
        effectType.backgroundColor[3], (effectType.backgroundColor[4] or 1) * effect.alpha)
    love.graphics.rectangle("fill", effect.x, effect.y, size, size, self.cornerRadius)

    -- Draw border
    love.graphics.setColor(effectType.borderColor[1], effectType.borderColor[2],
        effectType.borderColor[3], effect.alpha)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", effect.x, effect.y, size, size, self.cornerRadius)

    -- Draw icon
    if effect.icon then
        love.graphics.setColor(1, 1, 1, effect.alpha)
        local iconSize = size * 0.7
        local iconScale = iconSize / effect.icon:getWidth()
        love.graphics.draw(effect.icon, centerX, centerY, 0, iconScale, iconScale,
            effect.icon:getWidth() / 2, effect.icon:getHeight() / 2)
    else
        -- Draw text fallback
        love.graphics.setColor(1, 1, 1, effect.alpha)
        love.graphics.setFont(core.theme.font)
        local text = effect.name:sub(1, 2):upper()
        local textWidth = core.theme.font:getWidth(text)
        local textHeight = core.theme.font:getHeight()
        love.graphics.print(text, centerX - textWidth / 2, centerY - textHeight / 2)
    end

    -- Draw duration
    if self.showDuration and effect.duration > 0 then
        love.graphics.setColor(1, 1, 1, effect.alpha)
        love.graphics.setFont(core.theme.fontSmall or core.theme.font)
        local durationText = math.ceil(effect.duration)
        local textWidth = (core.theme.fontSmall or core.theme.font):getWidth(durationText)
        love.graphics.print(durationText, effect.x + size - textWidth - 2, effect.y + size - 12)
    end

    -- Draw stack count
    if self.showStacks and effect.stacks > 1 then
        love.graphics.setColor(1, 1, 0, effect.alpha)
        love.graphics.setFont(core.theme.fontBold or core.theme.font)
        local stackText = tostring(effect.stacks)
        love.graphics.print(stackText, effect.x + 2, effect.y + 2)
    end

    -- Draw duration bar
    if effect.duration > 0 and effect.maxDuration > 0 then
        local barHeight = 3
        local barY = effect.y + size - barHeight
        local progress = effect.duration / effect.maxDuration

        -- Background
        love.graphics.setColor(0.2, 0.2, 0.2, effect.alpha)
        love.graphics.rectangle("fill", effect.x, barY, size, barHeight)

        -- Progress
        local barColor = progress > 0.5 and { 0.2, 0.8, 0.2 } or
            progress > 0.25 and { 0.8, 0.8, 0.2 } or { 0.8, 0.2, 0.2 }
        love.graphics.setColor(barColor[1], barColor[2], barColor[3], effect.alpha)
        love.graphics.rectangle("fill", effect.x, barY, size * progress, barHeight)
    end
end

function StatusEffect:mousemoved(x, y)
    -- Check for tooltip display
    for _, effect in ipairs(self.effects) do
        if x >= effect.x and x <= effect.x + self.effectSize and
            y >= effect.y and y <= effect.y + self.effectSize then
            -- Show tooltip with effect details
            local tooltipText = effect.name
            if effect.description ~= "" then
                tooltipText = tooltipText .. "\n" .. effect.description
            end

            local options = {}
            if effect.duration > 0 then
                table.insert(options.stats or {}, {
                    name = "Duration",
                    value = math.ceil(effect.duration),
                    maxValue = effect.maxDuration > 0 and effect.maxDuration or nil
                })
            end

            if effect.stacks > 1 then
                table.insert(options.stats or {}, {
                    name = "Stacks",
                    value = effect.stacks,
                    maxValue = effect.maxStacks
                })
            end

            -- This would integrate with the Tooltip system
            -- widgets.Tooltip.showInstance(effect.name, effect.description, options)

            return true
        end
    end

    return false
end

function StatusEffect:clearEffects()
    if self.animateChanges then
        for _, effect in ipairs(self.effects) do
            self:removeEffect(effect.id)
        end
    else
        self.effects = {}
        self:_updateLayout()
    end
end

function StatusEffect:getEffects()
    return self.effects
end

function StatusEffect:hasEffect(effectId)
    return self:_findEffectIndex(effectId) ~= nil
end

function StatusEffect:getEffectCount()
    return #self.effects
end

return StatusEffect






