---@meta

---Unit Abilities & Skills System
---Class-specific abilities with cooldowns, AP costs, progression unlocks
---@module abilities_system

local AbilitiesSystem = {}

---@class Ability
---@field id string Ability identifier
---@field name string Display name
---@field class string Class that has this ability (medic, engineer, scout, assault, sniper, etc.)
---@field apCost number AP cost to use
---@field cooldown number Turns until can use again
---@field unlockLevel number XP level required to unlock (1-7)
---@field targetType string "self", "ally", "enemy", "tile", "area"
---@field range number Range in hexes
---@field effect function Function(user, target, params) -> result

---@class UnitAbilityState
---@field unitId string
---@field class string Unit class
---@field level number Current level (1-7)
---@field unlockedAbilities table List of ability IDs
---@field cooldowns table abilityId -> turns remaining

-- Ability definitions
AbilitiesSystem.ABILITIES = {
    -- MEDIC abilities
    FIELD_MEDIC = {
        id = "FIELD_MEDIC",
        name = "Field Medic",
        class = "medic",
        apCost = 4,
        cooldown = 0, -- No cooldown
        unlockLevel = 1,
        targetType = "ally",
        range = 1,
        effect = function(user, target, params)
            local healAmount = 5 + (user.level or 1) * 2
            target.hp = math.min((target.hp or 10) + healAmount, target.maxHP or 10)
            print(string.format("[Abilities] %s healed %s for %d HP", user.id, target.id, healAmount))
            return {success = true, healed = healAmount}
        end,
    },

    COMBAT_MEDIC = {
        id = "COMBAT_MEDIC",
        name = "Combat Medic",
        class = "medic",
        apCost = 6,
        cooldown = 3,
        unlockLevel = 3,
        targetType = "ally",
        range = 1,
        effect = function(user, target, params)
            -- Heal + remove wounds
            local healAmount = 10
            target.hp = math.min((target.hp or 10) + healAmount, target.maxHP or 10)
            target.wounds = {} -- Clear all wounds
            print(string.format("[Abilities] %s used Combat Medic on %s: healed %d HP, removed wounds",
                user.id, target.id, healAmount))
            return {success = true, healed = healAmount, woundsRemoved = true}
        end,
    },

    -- ENGINEER abilities
    REPAIR = {
        id = "REPAIR",
        name = "Repair",
        class = "engineer",
        apCost = 5,
        cooldown = 0,
        unlockLevel = 1,
        targetType = "tile",
        range = 1,
        effect = function(user, target, params)
            -- Repair destroyed terrain/objects
            print(string.format("[Abilities] %s repaired tile at (%d,%d)", user.id, target.q, target.r))
            return {success = true, repaired = true}
        end,
    },

    BUILD_TURRET = {
        id = "BUILD_TURRET",
        name = "Build Turret",
        class = "engineer",
        apCost = 8,
        cooldown = 5,
        unlockLevel = 4,
        targetType = "tile",
        range = 1,
        effect = function(user, target, params)
            -- Place automated turret
            print(string.format("[Abilities] %s built turret at (%d,%d)", user.id, target.q, target.r))
            -- Create turret unit
            local TurretUnit = require("engine.battlescape.entities.turret")
            local turret = TurretUnit.new({
                id = "turret_" .. user.id .. "_" .. os.time(),
                position = {q = target.q, r = target.r},
                team = user.team or "allies",
                owner = user.id,
                health = 20,
                maxHealth = 20,
                armor = 2,
                weapons = {{type = "turret_gun"}},
                duration = 3  -- Lasts 3 turns
            })
            print(string.format("[Abilities] Turret created: %s at position (%d,%d)", turret.id, target.q, target.r))
            return {success = true, turretPlaced = true, turretId = turret.id}
        end,
    },

    -- SCOUT abilities
    REVEAL_AREA = {
        id = "REVEAL_AREA",
        name = "Reveal Area",
        class = "scout",
        apCost = 3,
        cooldown = 2,
        unlockLevel = 1,
        targetType = "area",
        range = 20,
        effect = function(user, target, params)
            -- Reveal fog of war in radius
            local radius = 8 + (user.level or 1)
            print(string.format("[Abilities] %s revealed area at (%d,%d), radius %d",
                user.id, target.q, target.r, radius))
            return {success = true, radius = radius}
        end,
    },

    MARK_TARGET = {
        id = "MARK_TARGET",
        name = "Mark Target",
        class = "scout",
        apCost = 2,
        cooldown = 0,
        unlockLevel = 2,
        targetType = "enemy",
        range = 15,
        effect = function(user, target, params)
            -- Mark enemy for bonus accuracy
            print(string.format("[Abilities] %s marked %s (+20%% accuracy for allies)", user.id, target.id))
            -- Apply marked status effect
            local StatusEffects = require("engine.battlescape.systems.status_effects_system")
            StatusEffects.applyEffect(target.id, "MARKED", 2, 5, user.id)
            return {success = true, accuracyBonus = 20, targetId = target.id}
        end,
    },

    -- ASSAULT abilities
    RUSH = {
        id = "RUSH",
        name = "Rush",
        class = "assault",
        apCost = 2,
        cooldown = 3,
        unlockLevel = 1,
        targetType = "self",
        range = 0,
        effect = function(user, target, params)
            -- Grant extra movement
            user.ap = (user.ap or 12) + 4
            print(string.format("[Abilities] %s used Rush (+4 AP)", user.id))
            return {success = true, apBonus = 4}
        end,
    },

    SUPPRESSING_FIRE = {
        id = "SUPPRESSING_FIRE",
        name = "Suppressing Fire",
        class = "assault",
        apCost = 6,
        cooldown = 2,
        unlockLevel = 3,
        targetType = "area",
        range = 10,
        effect = function(user, target, params)
            -- Apply suppression debuff to area
            print(string.format("[Abilities] %s suppressed area at (%d,%d)", user.id, target.q, target.r))
            -- Apply suppression status effect to enemies in area
            local StatusEffects = require("engine.battlescape.systems.status_effects_system")
            local suppressedCount = 0
            -- In real implementation, would get units in area
            -- For now, apply to target if it's an enemy unit
            if target.id and target.team ~= user.team then
                StatusEffects.applyEffect(target.id, "SUPPRESSED", 2, 3, user.id)
                suppressedCount = 1
            end
            return {success = true, enemiesSuppressed = suppressedCount}
        end,
    },

    -- SNIPER abilities
    PRECISION_SHOT = {
        id = "PRECISION_SHOT",
        name = "Precision Shot",
        class = "sniper",
        apCost = 8,
        cooldown = 0,
        unlockLevel = 1,
        targetType = "enemy",
        range = 25,
        effect = function(user, target, params)
            -- Guaranteed critical hit
            print(string.format("[Abilities] %s used Precision Shot on %s (guaranteed crit)", user.id, target.id))
            return {success = true, guaranteedCrit = true}
        end,
    },

    HEADSHOT = {
        id = "HEADSHOT",
        name = "Headshot",
        class = "sniper",
        apCost = 10,
        cooldown = 4,
        unlockLevel = 5,
        targetType = "enemy",
        range = 30,
        effect = function(user, target, params)
            -- Instant kill if hit
            print(string.format("[Abilities] %s attempted Headshot on %s", user.id, target.id))
            return {success = true, instantKill = true}
        end,
    },

    -- HEAVY abilities
    ROCKET_LAUNCHER = {
        id = "ROCKET_LAUNCHER",
        name = "Rocket Launcher",
        class = "heavy",
        apCost = 8,
        cooldown = 5,
        unlockLevel = 2,
        targetType = "area",
        range = 15,
        effect = function(user, target, params)
            -- Explosive area attack
            print(string.format("[Abilities] %s fired rocket at (%d,%d)", user.id, target.q, target.r))
            return {success = true, damage = 40, radius = 3}
        end,
    },

    FORTIFY = {
        id = "FORTIFY",
        name = "Fortify",
        class = "heavy",
        apCost = 4,
        cooldown = 4,
        unlockLevel = 3,
        targetType = "self",
        range = 0,
        effect = function(user, target, params)
            -- Damage reduction buff
            print(string.format("[Abilities] %s fortified (-50%% damage for 2 turns)", user.id))
            -- Apply fortify status effect
            local StatusEffects = require("engine.battlescape.systems.status_effects_system")
            StatusEffects.applyEffect(user.id, "FORTIFIED", 2, 5, user.id)
            return {success = true, damageReduction = 0.5, duration = 2}
        end,
    },

    -- PSYCHIC abilities
    MIND_FRAY = {
        id = "MIND_FRAY",
        name = "Mind Fray",
        class = "psychic",
        apCost = 4,
        cooldown = 0,
        unlockLevel = 1,
        targetType = "enemy",
        range = 10,
        effect = function(user, target, params)
            -- Psionic damage
            local damage = 5 + (user.psiSkill or 50) / 10
            target.hp = (target.hp or 10) - damage
            print(string.format("[Abilities] %s Mind Frayed %s for %d damage", user.id, target.id, damage))
            return {success = true, damage = damage}
        end,
    },
}

-- Private state
local abilityStates = {} -- unitId -> UnitAbilityState

---Initialize abilities for a unit
---@param unitId string Unit identifier
---@param class string Unit class
---@param level number|nil Starting level (default 1)
function AbilitiesSystem.initUnit(unitId, class, level)
    level = level or 1

    local state = {
        unitId = unitId,
        class = class,
        level = level,
        unlockedAbilities = {},
        cooldowns = {},
    }

    -- Unlock abilities for current level
    for abilityId, ability in pairs(AbilitiesSystem.ABILITIES) do
        if ability.class == class and ability.unlockLevel <= level then
            table.insert(state.unlockedAbilities, abilityId)
            state.cooldowns[abilityId] = 0
        end
    end

    abilityStates[unitId] = state

    print(string.format("[Abilities] Initialized %s (%s, level %d): %d abilities unlocked",
        unitId, class, level, #state.unlockedAbilities))
end

---Remove unit from abilities tracking
---@param unitId string Unit identifier
function AbilitiesSystem.removeUnit(unitId)
    abilityStates[unitId] = nil
end

---Level up unit (unlock new abilities)
---@param unitId string Unit identifier
---@param newLevel number New level
function AbilitiesSystem.levelUp(unitId, newLevel)
    local state = abilityStates[unitId]
    if not state then return end

    local oldLevel = state.level
    state.level = newLevel

    -- Unlock new abilities
    local newAbilities = 0
    for abilityId, ability in pairs(AbilitiesSystem.ABILITIES) do
        if ability.class == state.class and
           ability.unlockLevel <= newLevel and
           ability.unlockLevel > oldLevel then
            table.insert(state.unlockedAbilities, abilityId)
            state.cooldowns[abilityId] = 0
            newAbilities = newAbilities + 1
            print(string.format("[Abilities] %s unlocked %s (level %d)", unitId, ability.name, newLevel))
        end
    end

    if newAbilities > 0 then
        print(string.format("[Abilities] %s leveled up to %d, unlocked %d new abilities",
            unitId, newLevel, newAbilities))
    end
end

---Check if ability can be used
---@param unitId string Unit identifier
---@param abilityId string Ability ID
---@param unit table Unit object (for AP check)
---@return boolean canUse, string|nil reason
function AbilitiesSystem.canUseAbility(unitId, abilityId, unit)
    local state = abilityStates[unitId]
    if not state then
        return false, "No ability state"
    end

    -- Check if unlocked
    local unlocked = false
    for _, id in ipairs(state.unlockedAbilities) do
        if id == abilityId then
            unlocked = true
            break
        end
    end
    if not unlocked then
        return false, "Ability not unlocked"
    end

    -- Check cooldown
    if state.cooldowns[abilityId] and state.cooldowns[abilityId] > 0 then
        return false, string.format("On cooldown (%d turns)", state.cooldowns[abilityId])
    end

    -- Check AP
    local ability = AbilitiesSystem.ABILITIES[abilityId]
    if not ability then
        return false, "Unknown ability"
    end

    if unit.ap < ability.apCost then
        return false, string.format("Not enough AP (%d required, %d available)", ability.apCost, unit.ap)
    end

    return true
end

---Use an ability
---@param unitId string Unit identifier
---@param abilityId string Ability ID
---@param user table User unit object
---@param target table Target (unit, tile, or area params)
---@return boolean success, table|nil result
function AbilitiesSystem.useAbility(unitId, abilityId, user, target)
    local canUse, reason = AbilitiesSystem.canUseAbility(unitId, abilityId, user)
    if not canUse then
        print(string.format("[Abilities] %s cannot use %s: %s", unitId, abilityId, reason or "unknown"))
        return false, nil
    end

    local ability = AbilitiesSystem.ABILITIES[abilityId]
    local state = abilityStates[unitId]

    -- Consume AP
    user.ap = user.ap - ability.apCost

    -- Execute ability effect
    local result = ability.effect(user, target, {})

    -- Set cooldown
    state.cooldowns[abilityId] = ability.cooldown

    print(string.format("[Abilities] %s used %s (cooldown: %d turns)",
        unitId, ability.name, ability.cooldown))

    return true, result
end

---Process turn end (reduce cooldowns)
---@param unitId string Unit identifier
function AbilitiesSystem.processTurnEnd(unitId)
    local state = abilityStates[unitId]
    if not state then return end

    for abilityId, cooldown in pairs(state.cooldowns) do
        if cooldown > 0 then
            state.cooldowns[abilityId] = cooldown - 1
        end
    end
end

---Get all unlocked abilities for a unit
---@param unitId string Unit identifier
---@return table abilities List of {abilityId, name, apCost, cooldown, available}
function AbilitiesSystem.getUnlockedAbilities(unitId)
    local state = abilityStates[unitId]
    if not state then return {} end

    local abilities = {}
    for _, abilityId in ipairs(state.unlockedAbilities) do
        local ability = AbilitiesSystem.ABILITIES[abilityId]
        if ability then
            table.insert(abilities, {
                abilityId = abilityId,
                name = ability.name,
                apCost = ability.apCost,
                cooldown = state.cooldowns[abilityId] or 0,
                available = state.cooldowns[abilityId] == 0,
            })
        end
    end

    return abilities
end

---Get ability state
---@param unitId string Unit identifier
---@return UnitAbilityState|nil state
function AbilitiesSystem.getState(unitId)
    return abilityStates[unitId]
end

---Reset entire system
function AbilitiesSystem.reset()
    abilityStates = {}
    print("[Abilities] System reset")
end

return AbilitiesSystem

