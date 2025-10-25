---@meta

---Status Effects System
---Handles buffs, debuffs, and temporary status effects on units
---@module status_effects_system

local StatusEffectsSystem = {}

---@class StatusEffect
---@field id string Unique identifier (e.g., "haste_1")
---@field type string Effect type (haste, slow, shield, burning, poisoned, stunned, inspired, weakened)
---@field duration number Remaining turns
---@field intensity number Effect strength (1-10)
---@field source string|nil Who applied this effect
---@field stackable boolean Can this stack with same type?
---@field modifiers table Stat modifications

-- Effect type definitions
StatusEffectsSystem.EFFECT_TYPES = {
    HASTE = {
        name = "Haste",
        description = "Increased action points",
        stackable = false,
        applyMods = function(intensity)
            return {apBonus = intensity * 2} -- +2 AP per intensity
        end,
        icon = "⚡",
        color = {0.4, 0.8, 1.0},
    },
    SLOW = {
        name = "Slow",
        description = "Reduced action points",
        stackable = false,
        applyMods = function(intensity)
            return {apPenalty = intensity * 2} -- -2 AP per intensity
        end,
        icon = "🐌",
        color = {0.6, 0.4, 0.8},
    },
    SHIELD = {
        name = "Shield",
        description = "Damage absorption",
        stackable = true,
        applyMods = function(intensity)
            return {damageReduction = intensity * 5} -- -5 damage per intensity
        end,
        icon = "🛡️",
        color = {0.4, 0.6, 1.0},
    },
    BURNING = {
        name = "Burning",
        description = "Taking fire damage over time",
        stackable = true,
        applyMods = function(intensity)
            return {burnDamage = intensity} -- 1-10 damage per turn
        end,
        icon = "🔥",
        color = {1.0, 0.4, 0.2},
    },
    POISONED = {
        name = "Poisoned",
        description = "Taking poison damage over time",
        stackable = true,
        applyMods = function(intensity)
            return {poisonDamage = intensity} -- 1-10 damage per turn
        end,
        icon = "☠️",
        color = {0.4, 1.0, 0.4},
    },
    STUNNED = {
        name = "Stunned",
        description = "Cannot take actions",
        stackable = false,
        applyMods = function(intensity)
            return {cannotAct = true, apPenalty = 999}
        end,
        icon = "💫",
        color = {1.0, 1.0, 0.4},
    },
    INSPIRED = {
        name = "Inspired",
        description = "Increased accuracy and damage",
        stackable = false,
        applyMods = function(intensity)
            return {accuracyBonus = intensity * 10, damageBonus = intensity * 5}
        end,
        icon = "⭐",
        color = {1.0, 0.8, 0.2},
    },
    WEAKENED = {
        name = "Weakened",
        description = "Reduced accuracy and damage",
        stackable = false,
        applyMods = function(intensity)
            return {accuracyPenalty = intensity * 10, damagePenalty = intensity * 5}
        end,
        icon = "💀",
        color = {0.5, 0.5, 0.5},
    },
    MARKED = {
        name = "Marked",
        description = "Increased damage taken",
        stackable = false,
        applyMods = function(intensity)
            return {accuracyPenalty = intensity * 5, damageMultiplier = 1.2 + (intensity * 0.05)}
        end,
        icon = "🎯",
        color = {1.0, 0.3, 0.3},
    },
    SUPPRESSED = {
        name = "Suppressed",
        description = "Reduced action points",
        stackable = false,
        applyMods = function(intensity)
            return {apPenalty = intensity * 3, accuracyPenalty = intensity * 10}
        end,
        icon = "🔫",
        color = {0.8, 0.5, 0.3},
    },
    FORTIFIED = {
        name = "Fortified",
        description = "Damage reduction",
        stackable = false,
        applyMods = function(intensity)
            return {damageReduction = intensity * 0.1}  -- 10% reduction per intensity
        end,
        icon = "🛡️",
        color = {0.3, 0.7, 1.0},
    },
}

-- Private state: unitId -> list of effects
local activeEffects = {}

---Initialize effects for a unit
---@param unitId string Unit identifier
function StatusEffectsSystem.initUnit(unitId)
    activeEffects[unitId] = {}
end

---Remove unit from tracking
---@param unitId string Unit identifier
function StatusEffectsSystem.removeUnit(unitId)
    activeEffects[unitId] = nil
end

---Apply a status effect to a unit
---@param unitId string Target unit ID
---@param effectType string Effect type (HASTE, SLOW, etc.)
---@param duration number Duration in turns
---@param intensity number Effect strength (1-10)
---@param source string|nil Source of effect
---@return boolean success
function StatusEffectsSystem.applyEffect(unitId, effectType, duration, intensity, source)
    local effectDef = StatusEffectsSystem.EFFECT_TYPES[effectType]
    if not effectDef then
        print("[StatusEffects] Unknown effect type: " .. effectType)
        return false
    end

    -- Initialize if needed
    if not activeEffects[unitId] then
        StatusEffectsSystem.initUnit(unitId)
    end

    local effects = activeEffects[unitId]

    -- Check for existing effects of this type
    if not effectDef.stackable then
        -- Remove existing non-stackable effect
        for i = #effects, 1, -1 do
            if effects[i].type == effectType then
                table.remove(effects, i)
            end
        end
    end

    -- Create new effect
    local effectId = effectType .. "_" .. unitId .. "_" .. os.time()
    local effect = {
        id = effectId,
        type = effectType,
        duration = duration,
        intensity = math.max(1, math.min(10, intensity)),
        source = source,
        stackable = effectDef.stackable,
        modifiers = effectDef.applyMods(intensity),
    }

    table.insert(effects, effect)

    print(string.format("[StatusEffects] Applied %s to %s (duration=%d, intensity=%d)",
        effectType, unitId, duration, intensity))

    return true
end

---Remove a specific effect
---@param unitId string Unit ID
---@param effectId string Effect ID to remove
function StatusEffectsSystem.removeEffect(unitId, effectId)
    local effects = activeEffects[unitId]
    if not effects then return end

    for i = #effects, 1, -1 do
        if effects[i].id == effectId then
            print(string.format("[StatusEffects] Removed %s from %s", effects[i].type, unitId))
            table.remove(effects, i)
            return
        end
    end
end

---Remove all effects of a specific type
---@param unitId string Unit ID
---@param effectType string Effect type to remove
function StatusEffectsSystem.removeEffectsByType(unitId, effectType)
    local effects = activeEffects[unitId]
    if not effects then return end

    for i = #effects, 1, -1 do
        if effects[i].type == effectType then
            table.remove(effects, i)
        end
    end
end

---Get all active effects for a unit
---@param unitId string Unit ID
---@return table effects List of active effects
function StatusEffectsSystem.getEffects(unitId)
    return activeEffects[unitId] or {}
end

---Check if unit has a specific effect type
---@param unitId string Unit ID
---@param effectType string Effect type to check
---@return boolean hasEffect
function StatusEffectsSystem.hasEffect(unitId, effectType)
    local effects = activeEffects[unitId]
    if not effects then return false end

    for _, effect in ipairs(effects) do
        if effect.type == effectType then
            return true
        end
    end

    return false
end

---Process end-of-turn effects (damage, duration decay)
---@param unitId string Unit ID
---@param unit table Unit object for applying damage
function StatusEffectsSystem.processTurnEnd(unitId, unit)
    local effects = activeEffects[unitId]
    if not effects then return end

    print(string.format("[StatusEffects] Processing %d effects for %s", #effects, unitId))

    -- Process each effect
    for i = #effects, 1, -1 do
        local effect = effects[i]

        -- Apply damage over time
        if effect.modifiers.burnDamage then
            unit.hp = (unit.hp or 10) - effect.modifiers.burnDamage
            print(string.format("[StatusEffects] %s takes %d burn damage", unitId, effect.modifiers.burnDamage))
        end

        if effect.modifiers.poisonDamage then
            unit.hp = (unit.hp or 10) - effect.modifiers.poisonDamage
            print(string.format("[StatusEffects] %s takes %d poison damage", unitId, effect.modifiers.poisonDamage))
        end

        -- Decrement duration
        effect.duration = effect.duration - 1

        -- Remove expired effects
        if effect.duration <= 0 then
            print(string.format("[StatusEffects] %s expired on %s", effect.type, unitId))
            table.remove(effects, i)
        end
    end
end

---Calculate aggregate modifiers from all active effects
---@param unitId string Unit ID
---@return table modifiers Aggregated stat modifiers
function StatusEffectsSystem.getAggregateModifiers(unitId)
    local effects = activeEffects[unitId]
    if not effects or #effects == 0 then
        return {}
    end

    local agg = {
        apBonus = 0,
        apPenalty = 0,
        damageReduction = 0,
        accuracyBonus = 0,
        accuracyPenalty = 0,
        damageBonus = 0,
        damagePenalty = 0,
        cannotAct = false,
    }

    for _, effect in ipairs(effects) do
        for k, v in pairs(effect.modifiers) do
            if type(v) == "number" then
                agg[k] = (agg[k] or 0) + v
            elseif type(v) == "boolean" then
                agg[k] = agg[k] or v
            end
        end
    end

    return agg
end

---Apply effects to unit stats
---@param unit table Unit object
---@return table modifiedUnit Unit with effects applied
function StatusEffectsSystem.applyToUnit(unit)
    local unitId = unit.id
    if not unitId then return unit end

    local mods = StatusEffectsSystem.getAggregateModifiers(unitId)

    -- Apply modifiers
    local modified = {}
    for k, v in pairs(unit) do
        modified[k] = v
    end

    -- AP modifications
    if mods.apBonus and mods.apBonus > 0 then
        modified.ap = (modified.ap or 12) + mods.apBonus
    end
    if mods.apPenalty and mods.apPenalty > 0 then
        modified.ap = math.max(0, (modified.ap or 12) - mods.apPenalty)
    end

    -- Store original modifiers for reference
    modified._statusEffectMods = mods

    return modified
end

---Get visual representation of effects (for UI)
---@param unitId string Unit ID
---@return table icons List of {icon, color, tooltip}
function StatusEffectsSystem.getVisualEffects(unitId)
    local effects = activeEffects[unitId]
    if not effects then return {} end

    local icons = {}
    for _, effect in ipairs(effects) do
        local effectDef = StatusEffectsSystem.EFFECT_TYPES[effect.type]
        if effectDef then
            table.insert(icons, {
                icon = effectDef.icon,
                color = effectDef.color,
                tooltip = string.format("%s (%d turns, intensity %d)",
                    effectDef.name, effect.duration, effect.intensity),
            })
        end
    end

    return icons
end

---Clear all effects from a unit
---@param unitId string Unit ID
function StatusEffectsSystem.clearAll(unitId)
    activeEffects[unitId] = {}
    print("[StatusEffects] Cleared all effects from " .. unitId)
end

---Reset entire system
function StatusEffectsSystem.reset()
    activeEffects = {}
    print("[StatusEffects] System reset")
end

return StatusEffectsSystem

