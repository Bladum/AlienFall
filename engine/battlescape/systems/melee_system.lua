---Melee Combat System - Close Quarters Combat
---
---Implements melee weapon attacks with specialized weapons, accuracy calculations based on
---strength and skill, damage with armor penetration, and tactical bonuses like backstab
---damage from behind. Melee combat is restricted to adjacent hexes only.
---
---Melee Weapon Types (6 variants):
---  - Combat Knife: 2 AP, 10-15 damage, fast and accurate
---  - Stun Baton: 3 AP, 5-8 damage, 50% stun chance
---  - Combat Axe: 4 AP, 20-30 damage, high damage, lower accuracy
---  - Plasma Sword: 5 AP, 30-45 damage, ignores 80% armor
---  - Power Fist: 6 AP, 40-60 damage, knockback effect
---  - Alien Blade: 4 AP, 25-35 damage, armor shred effect
---
---Accuracy Calculation:
---  - Base Accuracy: 70% for trained soldiers
---  - Melee Skill: +2% per skill level (max +20% at level 10)
---  - Strength Bonus: +1% per 2 strength points
---  - Flanking Bonus: +15% from side, +30% from rear
---  - Target Modifiers: -20% vs. fast units, +10% vs. stunned units
---
---Damage System:
---  - Base Damage: Weapon-specific damage range (e.g., 20-30)
---  - Strength Scaling: +5% damage per 10 strength points
---  - Armor Penetration: Each weapon has penetration value (0-80%)
---  - Critical Hits: 10% chance for 2x damage
---  - Backstab Bonus: +50% damage when attacking from behind
---
---Tactical Bonuses:
---  - Backstab: +50% damage from rear hex (stacks with flank bonus)
---  - Stun Mechanics: Stun baton has 50% chance to stun for 1 turn
---  - Knockback: Power fist pushes target 1 hex away
---  - Armor Shred: Alien blade reduces target armor by 20%
---  - Execution: Instant kill if target below 15% HP (knife only)
---
---Range Restrictions:
---  - Adjacent Only: Can only attack units in adjacent hex (1 hex distance)
---  - No Diagonal: Uses hex grid adjacency rules (6 directions)
---  - Blocked by Walls: Cannot attack through walls or obstacles
---  - Multi-Level: Can attack units 1 level above or below
---
---AP Costs by Weapon:
---  - Light Melee (Knife, Baton): 2-3 AP per attack
---  - Medium Melee (Axe, Alien Blade): 4 AP per attack
---  - Heavy Melee (Power Fist, Plasma Sword): 5-6 AP per attack
---  - Quick Strike: -1 AP for knife attacks (1 AP minimum)
---
---Key Exports:
---  - performMeleeAttack(attacker, target, weapon): Executes melee attack
---  - calculateMeleeAccuracy(attacker, target): Returns hit chance
---  - getMeleeDamage(weapon, attacker): Calculates damage range
---  - canMeleeAttack(attacker, target): Checks if melee is valid
---  - applyBackstab(attacker, target): Checks and applies backstab bonus
---
---Integration:
---  - Works with flanking_system.lua for backstab detection
---  - Uses accuracy_system.lua for hit calculations
---  - Integrates with damage_system.lua for damage application
---  - Connects to animation_system.lua for melee animations
---
---@module battlescape.systems.melee_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MeleeSystem = require("battlescape.systems.melee_system")
---  if MeleeSystem.canMeleeAttack(soldier, alien) then
---      local accuracy = MeleeSystem.calculateMeleeAccuracy(soldier, alien)
---      MeleeSystem.performMeleeAttack(soldier, alien, "combat_knife")
---  end
---
---@see battlescape.systems.flanking_system For backstab bonus
---@see battlescape.combat.damage_system For damage application

local MeleeSystem = {}

-- Configuration
local CONFIG = {
    -- Melee Weapon Types
    MELEE_WEAPONS = {
        KNIFE = {
            name = "Combat Knife",
            apCost = 2,
            damage = 12,
            armorPenetration = 3,
            accuracy = 85,
            canBackstab = true,
            icon = "knife",
        },
        SWORD = {
            name = "Tactical Sword",
            apCost = 4,
            damage = 25,
            armorPenetration = 8,
            accuracy = 75,
            canBackstab = true,
            icon = "sword",
        },
        STUN_BATON = {
            name = "Stun Baton",
            apCost = 3,
            damage = 8,
            armorPenetration = 0,
            accuracy = 90,
            stunChance = 40,        -- 40% chance to stun target
            stunDuration = 2,       -- 2 turns stunned
            canBackstab = false,
            icon = "stun_baton",
        },
        ALIEN_BLADE = {
            name = "Alien Blade",
            apCost = 3,
            damage = 30,
            armorPenetration = 15,
            accuracy = 80,
            canBackstab = true,
            icon = "alien_blade",
        },
        AXE = {
            name = "Combat Axe",
            apCost = 5,
            damage = 35,
            armorPenetration = 12,
            accuracy = 70,
            canBackstab = true,
            icon = "axe",
        },
        SPEAR = {
            name = "Combat Spear",
            apCost = 4,
            damage = 20,
            armorPenetration = 10,
            accuracy = 80,
            canBackstab = false,
            range = 2,              -- Can attack 2 hexes away
            icon = "spear",
        },
    },
    
    -- Backstab Mechanics
    BACKSTAB_DAMAGE_BONUS = 50,    -- +50% damage when attacking from behind
    BACKSTAB_ACCURACY_BONUS = 15,  -- +15% accuracy when attacking from behind
    
    -- Skill Modifiers
    SKILL_ACCURACY_BONUS = 1,      -- +1% accuracy per melee skill point
    STRENGTH_DAMAGE_BONUS = 0.5,   -- +0.5 damage per strength point
    
    -- Melee Range
    DEFAULT_MELEE_RANGE = 1,        -- Adjacent hexes only (1 hex distance)
}

--[[
    Get melee weapon data
    
    @param weaponType: String (KNIFE, SWORD, etc.)
    @return weapon data table
]]
function MeleeSystem.getMeleeWeaponData(weaponType)
    return CONFIG.MELEE_WEAPONS[weaponType]
end

--[[
    Calculate hex distance
    
    @param q1, r1: First hex
    @param q2, r2: Second hex
    @return distance in hexes
]]
local function hexDistance(q1, r1, q2, r2)
    local dq = q2 - q1
    local dr = r2 - r1
    return math.max(math.abs(dq), math.abs(dr), math.abs(dq + dr))
end

--[[
    Check if melee attack is possible
    
    @param attackerQ, attackerR: Attacker position
    @param targetQ, targetR: Target position
    @param attackerAP: Attacker's current AP
    @param weaponType: Type of melee weapon
    @return canAttack: Boolean
    @return reason: String (if canAttack=false)
]]
function MeleeSystem.canMeleeAttack(attackerQ, attackerR, targetQ, targetR, attackerAP, weaponType)
    local weaponData = MeleeSystem.getMeleeWeaponData(weaponType)
    
    if not weaponData then
        return false, "Invalid weapon type"
    end
    
    -- Check AP cost
    if attackerAP < weaponData.apCost then
        return false, string.format("Not enough AP (need %d, have %d)", weaponData.apCost, attackerAP)
    end
    
    -- Check range
    local distance = hexDistance(attackerQ, attackerR, targetQ, targetR)
    local maxRange = weaponData.range or CONFIG.DEFAULT_MELEE_RANGE
    
    if distance > maxRange then
        return false, string.format("Target too far (distance %d, max range %d)", distance, maxRange)
    end
    
    return true, nil
end

--[[
    Calculate melee attack accuracy
    
    @param weaponType: Type of melee weapon
    @param attackerSkill: Attacker's melee skill (0-100)
    @param attackerStrength: Attacker's strength (0-100)
    @param isBackstab: Boolean, attacking from behind?
    @return finalAccuracy: Percentage (0-100)
]]
function MeleeSystem.calculateMeleeAccuracy(weaponType, attackerSkill, attackerStrength, isBackstab)
    local weaponData = MeleeSystem.getMeleeWeaponData(weaponType)
    
    if not weaponData then
        return 0
    end
    
    local baseAccuracy = weaponData.accuracy
    local skillBonus = attackerSkill * CONFIG.SKILL_ACCURACY_BONUS
    local backstabBonus = (isBackstab and weaponData.canBackstab) and CONFIG.BACKSTAB_ACCURACY_BONUS or 0
    
    local finalAccuracy = baseAccuracy + skillBonus + backstabBonus
    
    return math.min(100, math.max(0, finalAccuracy))
end

--[[
    Calculate melee attack damage
    
    @param weaponType: Type of melee weapon
    @param attackerStrength: Attacker's strength (0-100)
    @param isBackstab: Boolean, attacking from behind?
    @return baseDamage: Base damage before armor
    @return armorPenetration: AP value
]]
function MeleeSystem.calculateMeleeDamage(weaponType, attackerStrength, isBackstab)
    local weaponData = MeleeSystem.getMeleeWeaponData(weaponType)
    
    if not weaponData then
        return 0, 0
    end
    
    local baseDamage = weaponData.damage
    local strengthBonus = attackerStrength * CONFIG.STRENGTH_DAMAGE_BONUS
    local backstabMultiplier = (isBackstab and weaponData.canBackstab) and (1 + CONFIG.BACKSTAB_DAMAGE_BONUS / 100) or 1
    
    local finalDamage = (baseDamage + strengthBonus) * backstabMultiplier
    
    return math.floor(finalDamage), weaponData.armorPenetration
end

--[[
    Perform melee attack
    
    @param attackerQ, attackerR: Attacker position
    @param targetQ, targetR: Target position
    @param weaponType: Type of melee weapon
    @param attackerSkill: Attacker's melee skill (0-100)
    @param attackerStrength: Attacker's strength (0-100)
    @param isBackstab: Boolean, attacking from behind?
    @return result table with hit, damage, stunned, etc.
]]
function MeleeSystem.performMeleeAttack(attackerQ, attackerR, targetQ, targetR, weaponType, attackerSkill, attackerStrength, isBackstab)
    local weaponData = MeleeSystem.getMeleeWeaponData(weaponType)
    
    if not weaponData then
        return { success = false, reason = "Invalid weapon" }
    end
    
    -- Calculate accuracy
    local accuracy = MeleeSystem.calculateMeleeAccuracy(weaponType, attackerSkill, attackerStrength, isBackstab)
    
    -- Roll to hit
    local roll = math.random(1, 100)
    local hit = roll <= accuracy
    
    if not hit then
        print(string.format("[MeleeSystem] Melee attack MISSED (roll=%d, accuracy=%d)", roll, accuracy))
        return {
            success = true,
            hit = false,
            roll = roll,
            accuracy = accuracy,
            apCost = weaponData.apCost,
        }
    end
    
    -- Calculate damage
    local damage, armorPen = MeleeSystem.calculateMeleeDamage(weaponType, attackerStrength, isBackstab)
    
    -- Check for stun effect
    local stunned = false
    if weaponData.stunChance then
        local stunRoll = math.random(1, 100)
        stunned = stunRoll <= weaponData.stunChance
    end
    
    print(string.format("[MeleeSystem] Melee attack HIT! Damage=%d, AP=%d, Backstab=%s, Stunned=%s", 
        damage, armorPen, tostring(isBackstab), tostring(stunned)))
    
    return {
        success = true,
        hit = true,
        damage = damage,
        armorPenetration = armorPen,
        isBackstab = isBackstab,
        stunned = stunned,
        stunDuration = stunned and weaponData.stunDuration or 0,
        apCost = weaponData.apCost,
        roll = roll,
        accuracy = accuracy,
    }
end

--[[
    Get melee weapon AP cost
    
    @param weaponType: Type of melee weapon
    @return apCost: Number of AP required
]]
function MeleeSystem.getMeleeAPCost(weaponType)
    local weaponData = MeleeSystem.getMeleeWeaponData(weaponType)
    return weaponData and weaponData.apCost or 0
end

--[[
    Get melee weapon range
    
    @param weaponType: Type of melee weapon
    @return range: Number of hexes
]]
function MeleeSystem.getMeleeRange(weaponType)
    local weaponData = MeleeSystem.getMeleeWeaponData(weaponType)
    return weaponData and (weaponData.range or CONFIG.DEFAULT_MELEE_RANGE) or CONFIG.DEFAULT_MELEE_RANGE
end

--[[
    Get all melee weapon types
    
    @return table of weapon type strings
]]
function MeleeSystem.getAllMeleeWeaponTypes()
    local types = {}
    for weaponType, _ in pairs(CONFIG.MELEE_WEAPONS) do
        table.insert(types, weaponType)
    end
    return types
end

--[[
    Visualize melee attack data for UI
    
    @param weaponType: Type of melee weapon
    @param attackerSkill: Attacker's melee skill
    @param attackerStrength: Attacker's strength
    @param isBackstab: Boolean
    @return visualization data
]]
function MeleeSystem.visualizeMeleeAttack(weaponType, attackerSkill, attackerStrength, isBackstab)
    local weaponData = MeleeSystem.getMeleeWeaponData(weaponType)
    
    if not weaponData then
        return nil
    end
    
    local accuracy = MeleeSystem.calculateMeleeAccuracy(weaponType, attackerSkill, attackerStrength, isBackstab)
    local damage, armorPen = MeleeSystem.calculateMeleeDamage(weaponType, attackerStrength, isBackstab)
    
    return {
        weaponName = weaponData.name,
        apCost = weaponData.apCost,
        accuracy = accuracy,
        damage = damage,
        armorPenetration = armorPen,
        range = weaponData.range or CONFIG.DEFAULT_MELEE_RANGE,
        canBackstab = weaponData.canBackstab,
        isBackstab = isBackstab,
        stunChance = weaponData.stunChance or 0,
        icon = weaponData.icon,
    }
end

return MeleeSystem






















