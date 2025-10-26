---Health - Health and Armor Component (ECS)
---
---Pure data component storing unit health, armor, and damage state. Part of the
---ECS (Entity-Component-System) battle architecture. Tracks current/max HP,
---armor value, and damage taken.
---
---Features:
---  - Current and maximum HP tracking
---  - Armor value (damage reduction)
---  - Damage history
---  - Wounded/dead state
---  - Regeneration support
---
---Component Data:
---  - maxHP: Maximum hit points
---  - currentHP: Current hit points
---  - armor: Damage reduction value
---  - wounds: Array of wound records
---  - isDead: Boolean death flag
---
---Key Exports:
---  - Health.new(maxHP, armor): Creates health component
---  - takeDamage(health, amount): Applies damage
---  - heal(health, amount): Restores HP
---  - isDead(health): Returns true if HP <= 0
---  - getHealthPercent(health): Returns HP as percentage
---
---Dependencies:
---  - None (pure data component)
---
---@module battlescape.battle_ecs.health
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Health = require("battlescape.battle_ecs.health")
---  local health = Health.new(100, 10)
---  Health.takeDamage(health, 25)
---
---@see battlescape.battle_ecs.unit_entity For usage

-- health.lua
-- Health and armor data component (pure data)
-- Part of ECS architecture for battle system

local Health = {}

-- Create a new health component
-- @param maxHP number: Maximum hit points
-- @param armor number: Armor value (damage reduction)
-- @return table: Health component
function Health.new(maxHP, armor)
    return {
        maxHP = maxHP or 100,
        currentHP = maxHP or 100,
        armor = armor or 0,
        isDead = false,
        wounds = {}  -- Array of wound records for history
    }
end

-- Apply damage (returns actual damage dealt)
function Health.takeDamage(health, rawDamage, damageType)
    if health.isDead then
        return 0
    end

    -- Apply armor reduction
    local actualDamage = math.max(0, rawDamage - health.armor)
    health.currentHP = math.max(0, health.currentHP - actualDamage)

    -- Record wound
    table.insert(health.wounds, {
        damage = actualDamage,
        type = damageType or "kinetic",
        timestamp = os.time()
    })

    -- Check death
    if health.currentHP <= 0 then
        health.isDead = true
    end

    return actualDamage
end

-- Heal HP (cannot exceed maxHP)
function Health.heal(health, amount)
    if health.isDead then
        return 0
    end

    local oldHP = health.currentHP
    health.currentHP = math.min(health.maxHP, health.currentHP + amount)
    return health.currentHP - oldHP
end

-- Check if alive
function Health.isAlive(health)
    return not health.isDead and health.currentHP > 0
end

return Health
