--- Unit Generator
-- Generates procedural units with stats, equipment, and traits
--
-- @module procedure.UnitGenerator

local class = require 'lib.Middleclass'

--- Unit Generator
-- @type UnitGenerator
UnitGenerator = class('UnitGenerator')

--- Base stat ranges for different unit classes
UnitGenerator.BASE_STATS = {
    sectoid = {
        health = { 30, 50 },
        accuracy = { 40, 60 },
        reflexes = { 50, 70 },
        strength = { 20, 30 },
        mind = { 60, 80 },
        armor = { 0, 5 }
    },
    muton = {
        health = { 80, 120 },
        accuracy = { 50, 70 },
        reflexes = { 30, 50 },
        strength = { 60, 80 },
        mind = { 20, 40 },
        armor = { 10, 20 }
    },
    floater = {
        health = { 40, 60 },
        accuracy = { 60, 80 },
        reflexes = { 70, 90 },
        strength = { 25, 35 },
        mind = { 40, 60 },
        armor = { 5, 15 }
    },
    cyberdisc = {
        health = { 150, 200 },
        accuracy = { 70, 90 },
        reflexes = { 40, 60 },
        strength = { 80, 100 },
        mind = { 10, 20 },
        armor = { 30, 50 }
    },
    chryssalid = {
        health = { 60, 90 },
        accuracy = { 80, 100 },
        reflexes = { 80, 100 },
        strength = { 50, 70 },
        mind = { 5, 15 },
        armor = { 15, 25 }
    },
    berserker = {
        health = { 100, 150 },
        accuracy = { 30, 50 },
        reflexes = { 20, 40 },
        strength = { 90, 110 },
        mind = { 5, 15 },
        armor = { 20, 30 }
    },
    ethereal = {
        health = { 70, 100 },
        accuracy = { 70, 90 },
        reflexes = { 60, 80 },
        strength = { 40, 60 },
        mind = { 90, 110 },
        armor = { 10, 20 }
    }
}

--- Unit abilities by type
UnitGenerator.UNIT_ABILITIES = {
    sectoid = { 'mind_shield', 'psi_attack' },
    muton = { 'heavy_weapons', 'intimidate' },
    floater = { 'fly', 'sniper' },
    cyberdisc = { 'shield', 'energy_weapon' },
    chryssalid = { 'poison', 'regeneration' },
    berserker = { 'berserk', 'melee_specialist' },
    ethereal = { 'psi_master', 'teleport' }
}

--- Initialize unit generator
-- @param rng Random number generator
function UnitGenerator:initialize(rng)
    self.rng = rng
end

--- Generate units for a mission
-- @param requirements Unit requirements table
-- @return Array of generated unit data
function UnitGenerator:generateUnits(requirements)
    local units = {}

    -- Generate enemy units
    for i = 1, requirements.enemyCount do
        local unitType = self:selectUnitType(requirements.enemyTypes)
        local unit = self:generateUnit(unitType, requirements.enemyStrength or 1.0)
        unit.faction = 'enemy'
        unit.id = 'enemy_' .. i
        table.insert(units, unit)
    end

    -- Generate boss unit if required
    if requirements.bossChance then
        local bossType = self:selectBossType(requirements.enemyTypes)
        local boss = self:generateUnit(bossType, 1.5)
        boss.faction = 'enemy'
        boss.id = 'boss_1'
        boss.isBoss = true
        table.insert(units, boss)
    end

    return units
end

--- Generate encounter units
-- @param context Encounter context
-- @return Array of generated units
function UnitGenerator:generateEncounterUnits(context)
    local difficulty = context.difficulty or 3
    local unitCount = self.rng:random(2, 5) + (difficulty - 3)

    local units = {}
    for i = 1, unitCount do
        local unitType = self:selectRandomUnitType()
        local unit = self:generateUnit(unitType, difficulty * 0.3)
        unit.faction = 'enemy'
        unit.id = 'encounter_' .. i
        table.insert(units, unit)
    end

    return units
end

--- Generate a single unit
-- @param unitType Type of unit to generate
-- @param strengthModifier Strength multiplier (1.0 = normal)
-- @return Generated unit data
function UnitGenerator:generateUnit(unitType, strengthModifier)
    strengthModifier = strengthModifier or 1.0

    local baseStats = self.BASE_STATS[unitType]
    if not baseStats then
        unitType = 'sectoid' -- fallback
        baseStats = self.BASE_STATS[unitType]
    end

    local unit = {
        type = unitType,
        name = self:generateUnitName(unitType),
        level = math.floor(strengthModifier * 3) + self.rng:random(0, 2),
        stats = {},
        abilities = {},
        equipment = {}
    }

    -- Generate stats with variation
    for stat, range in pairs(baseStats) do
        local baseValue = self.rng:random(range[1], range[2])
        unit.stats[stat] = math.floor(baseValue * strengthModifier + self.rng:random(-5, 5))
        unit.stats[stat] = math.max(1, unit.stats[stat]) -- minimum 1
    end

    -- Add abilities
    local possibleAbilities = self.UNIT_ABILITIES[unitType] or {}
    local numAbilities = math.min(#possibleAbilities, math.floor(strengthModifier) + 1)

    for i = 1, numAbilities do
        if #possibleAbilities > 0 then
            local abilityIndex = self.rng:random(#possibleAbilities)
            table.insert(unit.abilities, possibleAbilities[abilityIndex])
            table.remove(possibleAbilities, abilityIndex)
        end
    end

    -- Generate equipment
    unit.equipment = self:generateUnitEquipment(unitType, unit.level)

    -- Add traits
    unit.traits = self:generateUnitTraits(unitType, unit.level)

    return unit
end

--- Select unit type from available types
-- @param availableTypes Array of available unit types
-- @return Selected unit type
function UnitGenerator:selectUnitType(availableTypes)
    if not availableTypes or #availableTypes == 0 then
        return self:selectRandomUnitType()
    end

    return availableTypes[self.rng:random(#availableTypes)]
end

--- Select a random unit type
-- @return Random unit type
function UnitGenerator:selectRandomUnitType()
    local types = {}
    for typeName in pairs(self.BASE_STATS) do
        table.insert(types, typeName)
    end
    return types[self.rng:random(#types)]
end

--- Select boss unit type
-- @param availableTypes Array of available unit types
-- @return Boss unit type
function UnitGenerator:selectBossType(availableTypes)
    -- Prefer stronger unit types for bosses
    local bossTypes = { 'cyberdisc', 'berserker', 'ethereal', 'muton' }
    local validBossTypes = {}

    for _, bossType in ipairs(bossTypes) do
        if not availableTypes or self:tableContains(availableTypes, bossType) then
            table.insert(validBossTypes, bossType)
        end
    end

    if #validBossTypes > 0 then
        return validBossTypes[self.rng:random(#validBossTypes)]
    end

    -- Fallback to any available type
    return self:selectUnitType(availableTypes)
end

--- Generate unit name
-- @param unitType Type of unit
-- @return Generated name
function UnitGenerator:generateUnitName(unitType)
    local namePrefixes = {
        sectoid = { 'Thin', 'Slender', 'Small', 'Nimble' },
        muton = { 'Large', 'Strong', 'Heavy', 'Powerful' },
        floater = { 'Floating', 'Hovering', 'Aerial', 'Flying' },
        cyberdisc = { 'Mechanical', 'Robotic', 'Automated', 'Cybernetic' },
        chryssalid = { 'Horrific', 'Terrifying', 'Monstrous', 'Alien' },
        berserker = { 'Raging', 'Furious', 'Enraged', 'Savage' },
        ethereal = { 'Mysterious', 'Ethereal', 'Ghostly', 'Otherworldly' }
    }

    local prefixes = namePrefixes[unitType] or { 'Unknown' }
    local prefix = prefixes[self.rng:random(#prefixes)]

    return prefix .. ' ' .. unitType:gsub("^%l", string.upper)
end

--- Generate equipment for unit
-- @param unitType Type of unit
-- @param level Unit level
-- @return Equipment table
function UnitGenerator:generateUnitEquipment(unitType, level)
    local equipment = {}

    -- Primary weapon
    equipment.primaryWeapon = self:generateWeapon(unitType, level, 'primary')

    -- Secondary weapon (sometimes)
    if self.rng:random() < 0.4 + (level * 0.1) then
        equipment.secondaryWeapon = self:generateWeapon(unitType, level, 'secondary')
    end

    -- Armor
    equipment.armor = self:generateArmor(unitType, level)

    -- Grenades (sometimes)
    if self.rng:random() < 0.3 + (level * 0.05) then
        equipment.grenades = self.rng:random(1, 3)
    end

    return equipment
end

--- Generate weapon for unit
-- @param unitType Type of unit
-- @param level Unit level
-- @param slot Weapon slot ('primary' or 'secondary')
-- @return Weapon data
function UnitGenerator:generateWeapon(unitType, level, slot)
    local weaponTypes = {
        sectoid = { 'plasma_pistol', 'psi_amp' },
        muton = { 'heavy_plasma', 'light_plasma' },
        floater = { 'plasma_rifle', 'sniper_rifle' },
        cyberdisc = { 'plasma_cannon', 'drone_weapon' },
        chryssalid = { 'claws', 'poison_spit' },
        berserker = { 'power_fist', 'heavy_plasma' },
        ethereal = { 'psi_staff', 'mind_control' }
    }

    local weapons = weaponTypes[unitType] or { 'plasma_pistol' }
    local weaponType = weapons[self.rng:random(#weapons)]

    return {
        type = weaponType,
        damage = 20 + (level * 5) + self.rng:random(-5, 5),
        accuracy = 60 + (level * 3) + self.rng:random(-10, 10),
        range = slot == 'primary' and 15 or 8
    }
end

--- Generate armor for unit
-- @param unitType Type of unit
-- @param level Unit level
-- @return Armor data
function UnitGenerator:generateArmor(unitType, level)
    local armorTypes = {
        sectoid = 'light_armor',
        muton = 'heavy_armor',
        floater = 'flight_armor',
        cyberdisc = 'cyber_armor',
        chryssalid = 'chitin_armor',
        berserker = 'berserker_armor',
        ethereal = 'psi_armor'
    }

    local armorType = armorTypes[unitType] or 'light_armor'

    return {
        type = armorType,
        defense = 5 + (level * 2) + self.rng:random(-2, 2),
        mobilityPenalty = unitType == 'muton' and 2 or 0
    }
end

--- Generate traits for unit
-- @param unitType Type of unit
-- @param level Unit level
-- @return Array of trait strings
function UnitGenerator:generateUnitTraits(unitType, level)
    local traits = {}

    -- Base traits by unit type
    local baseTraits = {
        sectoid = { 'psi_sensitive', 'fragile' },
        muton = { 'strong', 'slow' },
        floater = { 'flying', 'light_armor' },
        cyberdisc = { 'armored', 'no_psi' },
        chryssalid = { 'poisonous', 'fast' },
        berserker = { 'berserk', 'tough' },
        ethereal = { 'psi_master', 'fragile' }
    }

    local typeTraits = baseTraits[unitType] or {}
    for _, trait in ipairs(typeTraits) do
        table.insert(traits, trait)
    end

    -- Random additional traits based on level
    local possibleTraits = { 'tough', 'fast', 'accurate', 'strong', 'psi_resistant', 'armored' }
    local numExtraTraits = math.min(level - 1, 2)

    for i = 1, numExtraTraits do
        if self.rng:random() < 0.4 then
            local trait = possibleTraits[self.rng:random(#possibleTraits)]
            if not self:tableContains(traits, trait) then
                table.insert(traits, trait)
            end
        end
    end

    return traits
end

--- Utility function to check if table contains value
-- @param table Table to search
-- @param value Value to find
-- @return Boolean indicating if found
function UnitGenerator:tableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

return UnitGenerator