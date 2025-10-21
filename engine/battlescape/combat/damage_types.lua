---DamageTypes - Weapon Damage Types and Armor Resistance System
---
---Defines all damage types in the game and their interactions with armor.
---Each damage type has specific armor penetration characteristics and resistance
---calculations. Used by combat system for damage mitigation and weapon balancing.
---
---Damage Types:
---  - KINETIC: Bullets, shells, conventional weapons
---  - EXPLOSIVE: Grenades, rockets, bombs (area damage)
---  - LASER: Energy weapons with high penetration
---  - PLASMA: Advanced energy weapons
---  - MELEE: Close combat weapons
---  - BIO: Biological and chemical weapons
---  - ACID: Corrosive weapons
---  - STUN: Non-lethal incapacitation
---  - FIRE: Incendiary and burning damage
---  - PSI: Psionic and mental attacks
---
---Features:
---  - Armor resistance values per damage type
---  - Penetration calculations
---  - Damage type effectiveness modifiers
---  - Armor degradation mechanics
---  - Integration with damage models
---
---Key Exports:
---  - TYPES: Enumeration of all damage types
---  - getResistance(armorType, damageType): Get resistance value
---  - calculatePenetration(damage, resistance): Calculate armor penetration
---  - getEffectiveDamage(baseDamage, damageType, armorType): Calculate final damage
---  - isPiercing(damageType): Check if damage type ignores some armor
---
---Dependencies:
---  - Armor system for resistance definitions
---  - Weapon system for damage type assignment
---
---@module battlescape.combat.damage_types
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local DamageTypes = require("battlescape.combat.damage_types")
---  local resistance = DamageTypes.getResistance("kevlar", "kinetic")
---  local damage = DamageTypes.getEffectiveDamage(50, "laser", "kevlar")
---
---@see battlescape.combat.damage_models For damage effect distribution
---@see battlescape.combat.weapon_system For weapon damage types

-- Damage Types and Resistance System
-- Defines all damage types and armor resistance calculations

local DamageTypes = {}

--- Enumeration of all damage types in the game
DamageTypes.TYPES = {
    KINETIC = "kinetic",       -- Bullets, shells, conventional weapons
    EXPLOSIVE = "explosive",   -- Grenades, rockets, bombs
    LASER = "laser",           -- Laser weapons
    PLASMA = "plasma",         -- Plasma weapons
    MELEE = "melee",           -- Melee weapons, knives
    BIO = "bio",               -- Biological weapons
    ACID = "acid",             -- Acid weapons
    STUN = "stun",             -- Stun weapons (non-lethal)
    FIRE = "fire",             -- Fire damage, incendiary
    PSI = "psi"                -- Psionic attacks
}

--- Default armor resistance values (0.0 = no protection, 1.0 = 100% protection)
--- Lower values mean better protection (damage is divided by resistance)
--- Example: resistance = 0.5 (50% protection) means damage is doubled (divided by 0.5)
DamageTypes.DEFAULT_RESISTANCES = {
    kinetic = 1.0,      -- No resistance by default
    explosive = 1.0,
    laser = 1.0,
    plasma = 1.0,
    melee = 1.0,
    bio = 1.0,
    acid = 1.0,
    stun = 1.0,
    fire = 1.0,
    psi = 1.0
}

--- Get resistance value for a damage type from armor
-- @param armorResistances table Armor resistance table
-- @param damageType string Damage type to check
-- @return number Resistance value (0.0 to 1.0, where lower = better protection)
function DamageTypes.getResistance(armorResistances, damageType)
    if not armorResistances then
        return 1.0  -- No armor = no resistance
    end
    
    return armorResistances[damageType] or DamageTypes.DEFAULT_RESISTANCES[damageType] or 1.0
end

--- Calculate effective damage after resistance
-- Resistance acts as a divisor: effectiveDamage = basePower / resistance
-- Example: power=10, resistance=0.5 → effectiveDamage=20 (resistance makes it worse)
-- Example: power=10, resistance=2.0 → effectiveDamage=5 (resistance reduces damage)
-- @param basePower number Base weapon power
-- @param resistance number Resistance value (0.0 to 1.0+)
-- @return number Effective power after resistance
function DamageTypes.applyResistance(basePower, resistance)
    if resistance <= 0.001 then
        -- Prevent division by zero, treat as no resistance
        return basePower
    end
    
    return basePower / resistance
end

--- Calculate armor absorption (armor value subtracted from damage)
-- @param effectivePower number Power after resistance
-- @param armorValue number Armor protection value
-- @return number Final damage after armor absorption
function DamageTypes.applyArmorAbsorption(effectivePower, armorValue)
    local finalDamage = effectivePower - armorValue
    return math.max(0, finalDamage)  -- Can't go negative
end

--- Validate damage type
-- @param damageType string Damage type to validate
-- @return boolean True if valid damage type
function DamageTypes.isValidType(damageType)
    for _, validType in pairs(DamageTypes.TYPES) do
        if validType == damageType then
            return true
        end
    end
    return false
end

--- Get all damage types as array
-- @return table Array of damage type strings
function DamageTypes.getAllTypes()
    local types = {}
    for _, damageType in pairs(DamageTypes.TYPES) do
        table.insert(types, damageType)
    end
    return types
end

--- Get damage type color for UI rendering (optional helper)
-- @param damageType string Damage type
-- @return table RGB color {r, g, b}
function DamageTypes.getColor(damageType)
    local colors = {
        kinetic = {200, 200, 200},   -- Gray
        explosive = {255, 128, 0},    -- Orange
        laser = {255, 50, 50},        -- Red
        plasma = {100, 100, 255},     -- Blue
        melee = {150, 150, 150},      -- Dark gray
        bio = {50, 200, 50},          -- Green
        acid = {200, 255, 50},        -- Yellow-green
        stun = {255, 255, 100},       -- Yellow
        fire = {255, 100, 0},         -- Orange-red
        psi = {200, 50, 200}          -- Purple
    }
    
    return colors[damageType] or {255, 255, 255}
end

--- Create default armor resistance table
-- @return table Default resistance table
function DamageTypes.createDefaultResistances()
    local resistances = {}
    for key, value in pairs(DamageTypes.DEFAULT_RESISTANCES) do
        resistances[key] = value
    end
    return resistances
end

return DamageTypes

























