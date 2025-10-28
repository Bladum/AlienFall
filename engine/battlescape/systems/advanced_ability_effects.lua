---Advanced Ability Effects System
---
---Extends base ability system with complex, multi-target effects including:
---  - Area of Effect (AOE) with falloff damage
---  - Status effect application with stacking
---  - Chain reactions (mark -> chain damage on marked targets)
---  - Conditional effects (only apply if target has status X)
---  - Combo effects (bonus damage if paired with other ability)
---  - Resource costs (ammo, charges, mana)
---
---Ability Effect Types:
---  1. SINGLE_TARGET - Standard attack on one unit
---  2. AOE - Affects all targets in radius with falloff
---  3. LINE_AOE - Affects all targets in line (projectile path)
---  4. CHAIN - Bounces between targets (5 bounces max)
---  5. PERSISTENT - Leaves effect area that damages/stuns over time
---  6. CONDITIONAL - Only works if condition met (target has status, range check, etc.)
---  7. COMBO - Enhanced effect when paired with previous ability
---
---Status Effect Application:
---  - Application chance: 50-100% based on ability
---  - Duration: 2-6 turns (effect-dependent)
---  - Stacking: Up to 3 stacks per effect (each stack adds +20% intensity)
---  - Immunity: Certain effects don't stack (FORTIFY overwrites)
---
---Exports:
---  - AdvancedAbilityEffects.new(): Creates system
---  - applyAOEDamage(center, radius, baseDamage, unit): AOE with falloff
---  - applyLineAOE(start, end, damage, unit): Projectile line damage
---  - applyChainEffect(target, damage, bounces, unit): Chain bouncing
---  - applyPersistentEffect(area, duration, effect, unit): Field effect
---  - applyConditionalEffect(target, condition, effect, unit): Conditional
---  - applyComboEffect(unit1, ability, unit2, enhancement): Paired ability
---  - getEffectIntensity(stacks): Get damage/duration multiplier
---
---Dependencies:
---  - battlescape.systems.status_effects_system
---  - battlescape.systems.unit_system
---  - battlescape.systems.movement_system (for distance)
---  - battlescape.systems.abilities_system
---
---@module battlescape.systems.advanced_ability_effects
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local AdvancedAbilityEffects = {}
AdvancedAbilityEffects.__index = AdvancedAbilityEffects

--- Create new advanced ability effects system
-- @return table New AdvancedAbilityEffects instance
function AdvancedAbilityEffects.new()
    local self = setmetatable({}, AdvancedAbilityEffects)

    self.persistentEffects = {}   -- Active persistent effects on map
    self.statusStacks = {}         -- Status stacks per unit: unitId -> {effectId -> count}
    self.comboTracker = {}         -- Last ability used: unitId -> {abilityId, turn}
    self.chainBounces = {}         -- Chain tracking: abilityInstanceId -> {targets, bounces}

    print("[AdvancedAbilityEffects] Initialized advanced ability effects system")

    return self
end

--- Define effect profiles
local EFFECT_PROFILES = {
    MARK_TARGET = {
        type = "CONDITIONAL",
        statusEffect = "MARKED",
        statusChance = 85,
        baseDamage = 5,
        aoe = false,
    },
    SUPPRESSING_FIRE = {
        type = "AOE",
        statusEffect = "SUPPRESSED",
        statusChance = 70,
        baseDamage = 12,
        radius = 2,
        falloff = 0.5,
        aoe = true,
    },
    FORTIFY = {
        type = "CONDITIONAL",
        statusEffect = "FORTIFIED",
        statusChance = 100,
        defenseBuff = 0.5,  -- +50% defense
        aoe = false,
    },
    CHAIN_LIGHTNING = {
        type = "CHAIN",
        baseDamage = 20,
        bounces = 5,
        chainRadius = 4,
        statusEffect = "STUNNED",
        statusChance = 60,
        aoe = false,
    },
    SPREAD_FIRE = {
        type = "LINE_AOE",
        baseDamage = 15,
        lineWidth = 1,
        statusEffect = "BURNING",
        statusChance = 75,
        aoe = true,
    },
}

--- Apply AOE damage with falloff
-- @param center table Center position {x, y, hex}
-- @param radius number AOE radius in hexes
-- @param baseDamage number Damage at center
-- @param attacker table Attacking unit
-- @param targets table Array of potential targets
-- @return table Array of {target, damage} hit
function AdvancedAbilityEffects:applyAOEDamage(center, radius, baseDamage, attacker, targets)
    if not center or not radius or not baseDamage then
        print("[AdvancedAbilityEffects] Invalid AOE parameters")
        return {}
    end

    local hits = {}

    for _, target in ipairs(targets or {}) do
        if target and target.position then
            -- Calculate distance (hex distance)
            local dist = self:calculateDistance(center, target.position)

            if dist <= radius then
                -- Calculate damage with falloff
                local falloff = math.max(0.2, 1.0 - (dist / radius) * 0.5)
                local damage = baseDamage * falloff

                table.insert(hits, {
                    target = target,
                    damage = damage,
                    distance = dist,
                    falloff = falloff,
                })

                print(string.format("[AdvancedAbilityEffects] AOE hit %s: %.1f damage (falloff: %.2f)",
                      target.name or target.id, damage, falloff))
            end
        end
    end

    return hits
end

--- Apply line AOE (projectile path)
-- @param startPos table Start position
-- @param endPos table End position
-- @param baseDamage number Base damage
-- @param attacker table Attacking unit
-- @param targets table Array of potential targets
-- @return table Array of {target, damage} hit
function AdvancedAbilityEffects:applyLineAOE(startPos, endPos, baseDamage, attacker, targets)
    if not startPos or not endPos or not baseDamage then
        print("[AdvancedAbilityEffects] Invalid line AOE parameters")
        return {}
    end

    local hits = {}
    local lineLength = self:calculateDistance(startPos, endPos)

    for _, target in ipairs(targets or {}) do
        if target and target.position then
            -- Check if target is on line (within 1 hex of line path)
            local distToLine = self:calculateDistanceToLine(startPos, endPos, target.position)

            if distToLine <= 1.0 then
                -- Calculate distance along line for damage scaling
                local distAlongLine = self:calculateDistanceAlongLine(startPos, endPos, target.position)
                local falloff = math.max(0.3, 1.0 - (distAlongLine / lineLength) * 0.4)
                local damage = baseDamage * falloff

                table.insert(hits, {
                    target = target,
                    damage = damage,
                    distToLine = distToLine,
                    falloff = falloff,
                })

                print(string.format("[AdvancedAbilityEffects] Line hit %s: %.1f damage",
                      target.name or target.id, damage))
            end
        end
    end

    return hits
end

--- Apply chain effect (bounces between targets)
-- @param initialTarget table First target
-- @param baseDamage number Starting damage
-- @param bounces number Number of bounces remaining
-- @param attacker table Attacking unit
-- @param allTargets table Array of potential targets
-- @param visited table Already hit targets (internal recursion tracking)
-- @return table Array of {target, damage, bounce} hit
function AdvancedAbilityEffects:applyChainEffect(initialTarget, baseDamage, bounces, attacker, allTargets, visited)
    visited = visited or {}
    local hits = {}

    if not initialTarget or bounces <= 0 or not baseDamage then
        return hits
    end

    visited[initialTarget.id] = true

    table.insert(hits, {
        target = initialTarget,
        damage = baseDamage,
        bounce = 6 - bounces,  -- 1 for first, 2 for second, etc.
    })

    print(string.format("[AdvancedAbilityEffects] Chain hit %s: %.1f damage (bounce %d)",
          initialTarget.name or initialTarget.id, baseDamage, 6 - bounces))

    -- Find next target for chain
    local nextTarget = nil
    local closestDist = 5  -- Max chain range

    for _, target in ipairs(allTargets or {}) do
        if target and target.id ~= initialTarget.id and not visited[target.id] then
            local dist = self:calculateDistance(initialTarget.position, target.position)

            if dist <= closestDist then
                closestDist = dist
                nextTarget = target
            end
        end
    end

    -- Recursive chain
    if nextTarget and bounces > 1 then
        local damageFalloff = baseDamage * 0.85  -- Each bounce deals 85% of previous
        local nextHits = self:applyChainEffect(nextTarget, damageFalloff, bounces - 1, attacker, allTargets, visited)

        for _, hit in ipairs(nextHits) do
            table.insert(hits, hit)
        end
    end

    return hits
end

--- Apply persistent area effect (stays on map)
-- @param area table Area definition {center, radius, duration}
-- @param effectType string Type of effect (BURNING_FIELD, STUN_CLOUD, etc.)
-- @param attacker table Attacking unit
-- @return string Persistent effect ID
function AdvancedAbilityEffects:applyPersistentEffect(area, effectType, attacker)
    if not area or not area.center or not area.radius then
        print("[AdvancedAbilityEffects] Invalid persistent effect parameters")
        return nil
    end

    local effectId = string.format("PERSIST_%s_%d", effectType, love.timer.getTime() * 1000)

    self.persistentEffects[effectId] = {
        type = effectType,
        center = area.center,
        radius = area.radius,
        duration = area.duration or 3,
        remainingTurns = area.duration or 3,
        attacker = attacker,
        damagePerTurn = area.damagePerTurn or 5,
        statusEffect = area.statusEffect or nil,
        turnCounter = 0,
    }

    print(string.format("[AdvancedAbilityEffects] Created persistent effect %s (%s, %d turns)",
          effectId, effectType, area.duration or 3))

    return effectId
end

--- Apply conditional effect (only if condition met)
-- @param target table Target unit
-- @param condition string Condition type
-- @param conditionData table Condition-specific data
-- @param effect table Effect to apply if condition met
-- @return boolean Condition met
function AdvancedAbilityEffects:applyConditionalEffect(target, condition, conditionData, effect)
    if not target or not condition or not effect then
        return false
    end

    local conditionMet = false

    -- Evaluate condition
    if condition == "HAS_STATUS" then
        -- Check if target has specific status
        local statusId = conditionData.statusId
        conditionMet = target.statusEffects and target.statusEffects[statusId] or false

    elseif condition == "IN_RANGE" then
        -- Check if in range
        local range = conditionData.range or 5
        local dist = self:calculateDistance(effect.attacker.position, target.position)
        conditionMet = dist <= range

    elseif condition == "HP_BELOW" then
        -- Check if target HP below threshold
        local threshold = conditionData.threshold or 50
        conditionMet = target.hp < threshold

    elseif condition == "IS_WEAKENED" then
        -- Check if target is debuffed
        local hasDebuff = target.statusEffects and (
            target.statusEffects.MARKED or
            target.statusEffects.SUPPRESSED or
            target.statusEffects.BURNING
        )
        conditionMet = hasDebuff or false
    end

    if conditionMet then
        print(string.format("[AdvancedAbilityEffects] Condition '%s' MET for %s, applying effect",
              condition, target.name or target.id))
        return true
    else
        print(string.format("[AdvancedAbilityEffects] Condition '%s' FAILED for %s",
              condition, target.name or target.id))
        return false
    end
end

--- Apply combo effect (bonus when paired with previous ability)
-- @param unit table Unit performing combo
-- @param currentAbility string Current ability ID
-- @param previousAbility string Previous ability ID (from tracker)
-- @param baseEffect table Base effect from current ability
-- @return table Enhanced effect
function AdvancedAbilityEffects:applyComboEffect(unit, currentAbility, previousAbility, baseEffect)
    if not unit or not currentAbility or not baseEffect then
        return baseEffect
    end

    -- Check if in combo window (last 2 turns)
    local tracker = self.comboTracker[unit.id] or {}
    local turnsSinceLast = (tracker.lastAbilityTurn or 0) - (tracker.currentTurn or 0)

    if turnsSinceLast > 2 or turnsSinceLast < 0 then
        print("[AdvancedAbilityEffects] No active combo window")
        return baseEffect
    end

    -- Define combo bonuses
    local combos = {
        MARK_TARGET_to_SUPPRESSING_FIRE = {
            bonus = 1.5,  -- 50% damage bonus
            name = "Marked Shot",
            additionalEffect = "INCREASED_ACCURACY",
        },
        FORTIFY_to_BUILD_TURRET = {
            bonus = 1.3,  -- 30% health bonus
            name = "Reinforced Position",
            additionalEffect = "INCREASED_DEFENSE",
        },
        SUPPRESSING_FIRE_to_CHAIN_LIGHTNING = {
            bonus = 1.4,  -- 40% damage
            name = "Chain Suppression",
            additionalEffect = "EXTENDED_CHAIN",
        },
    }

    local comboKey = previousAbility .. "_to_" .. currentAbility
    local comboBonus = combos[comboKey]

    if comboBonus then
        print(string.format("[AdvancedAbilityEffects] COMBO triggered: %s (%.1f%% bonus)",
              comboBonus.name, (comboBonus.bonus - 1.0) * 100))

        local enhanced = {}
        for k, v in pairs(baseEffect) do
            enhanced[k] = v
        end
        enhanced.damage = (enhanced.damage or 0) * comboBonus.bonus
        enhanced.comboBonus = comboBonus.bonus
        enhanced.comboName = comboBonus.name
        enhanced.additionalEffect = comboBonus.additionalEffect

        return enhanced
    else
        print(string.format("[AdvancedAbilityEffects] No combo available for %s -> %s",
              previousAbility, currentAbility))
        return baseEffect
    end
end

--- Add status effect with stacking
-- @param unitId string Target unit ID
-- @param statusId string Status effect ID
-- @param duration number Duration in turns
-- @return number Total stacks
function AdvancedAbilityEffects:addStatusWithStacking(unitId, statusId, duration)
    self.statusStacks[unitId] = self.statusStacks[unitId] or {}

    local currentStacks = self.statusStacks[unitId][statusId] or 0

    -- Cap at 3 stacks
    local newStacks = math.min(3, currentStacks + 1)
    self.statusStacks[unitId][statusId] = newStacks

    print(string.format("[AdvancedAbilityEffects] Status %s on unit %s: %d stacks (duration: %d)",
          statusId, unitId, newStacks, duration))

    return newStacks
end

--- Get effect intensity multiplier based on stacks
-- @param stacks number Number of stacks
-- @return number Intensity multiplier (1.0 + (stacks - 1) * 0.2)
function AdvancedAbilityEffects:getEffectIntensity(stacks)
    stacks = stacks or 1
    return 1.0 + (math.max(1, stacks) - 1) * 0.2  -- +20% per stack
end

--- Calculate hex distance between two points
-- @param pos1 table Position 1
-- @param pos2 table Position 2
-- @return number Distance in hexes
function AdvancedAbilityEffects:calculateDistance(pos1, pos2)
    if not pos1 or not pos2 then
        return 999
    end

    local dx = (pos2.x or 0) - (pos1.x or 0)
    local dy = (pos2.y or 0) - (pos1.y or 0)

    -- Hex distance (Manhattan variant)
    return math.max(math.abs(dx), math.abs(dy))
end

--- Calculate distance to line segment
-- @param lineStart table Line start position
-- @param lineEnd table Line end position
-- @param point table Point to check
-- @return number Distance to line
function AdvancedAbilityEffects:calculateDistanceToLine(lineStart, lineEnd, point)
    if not lineStart or not lineEnd or not point then
        return 999
    end

    -- Simplified: just use straight distance calculation
    local x1, y1 = lineStart.x or 0, lineStart.y or 0
    local x2, y2 = lineEnd.x or 0, lineEnd.y or 0
    local px, py = point.x or 0, point.y or 0

    local dx = x2 - x1
    local dy = y2 - y1

    if dx == 0 and dy == 0 then
        return self:calculateDistance(lineStart, point)
    end

    local t = math.max(0, math.min(1, ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)))
    local closestX = x1 + t * dx
    local closestY = y1 + t * dy

    return math.sqrt((px - closestX) ^ 2 + (py - closestY) ^ 2)
end

--- Calculate distance along line
-- @param lineStart table Start position
-- @param lineEnd table End position
-- @param point table Point on line
-- @return number Distance from start
function AdvancedAbilityEffects:calculateDistanceAlongLine(lineStart, lineEnd, point)
    local x1, y1 = lineStart.x or 0, lineStart.y or 0
    local x2, y2 = lineEnd.x or 0, lineEnd.y or 0
    local px, py = point.x or 0, point.y or 0

    return math.sqrt((px - x1) ^ 2 + (py - y1) ^ 2)
end

--- Get status effect profile
-- @param effectName string Effect name (e.g., "SUPPRESSING_FIRE")
-- @return table Profile or nil
function AdvancedAbilityEffects:getEffectProfile(effectName)
    return EFFECT_PROFILES[effectName]
end

--- Process persistent effects each turn
-- @param targets table Array of targets in area
-- @param turn number Current turn
function AdvancedAbilityEffects:processPersistentEffects(targets, turn)
    local effectsToRemove = {}

    for effectId, effect in pairs(self.persistentEffects) do
        effect.remainingTurns = effect.remainingTurns - 1

        -- Apply effect to all targets in range
        for _, target in ipairs(targets or {}) do
            if target.position then
                local dist = self:calculateDistance(effect.center, target.position)

                if dist <= effect.radius then
                    -- Apply damage/status
                    if effect.damagePerTurn then
                        target.hp = (target.hp or 100) - effect.damagePerTurn
                    end

                    if effect.statusEffect then
                        self:addStatusWithStacking(target.id, effect.statusEffect, effect.duration)
                    end

                    print(string.format("[AdvancedAbilityEffects] Persistent %s damages %s",
                          effectId, target.name or target.id))
                end
            end
        end

        -- Remove expired effects
        if effect.remainingTurns <= 0 then
            table.insert(effectsToRemove, effectId)
            print(string.format("[AdvancedAbilityEffects] Persistent effect %s expired", effectId))
        end
    end

    for _, effectId in ipairs(effectsToRemove) do
        self.persistentEffects[effectId] = nil
    end
end

return AdvancedAbilityEffects

