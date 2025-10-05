--- Item Generator
-- Generates procedural items including weapons, armor, and equipment
--
-- @module procedure.ItemGenerator

local class = require 'lib.Middleclass'

--- Item Generator
-- @type ItemGenerator
ItemGenerator = class('ItemGenerator')

--- Weapon templates
ItemGenerator.WEAPON_TEMPLATES = {
    pistol = {
        damage = { 15, 25 },
        accuracy = { 60, 80 },
        range = { 8, 12 },
        ammo = { 12, 18 },
        weight = 1
    },
    rifle = {
        damage = { 25, 40 },
        accuracy = { 50, 75 },
        range = { 15, 25 },
        ammo = { 8, 12 },
        weight = 2
    },
    shotgun = {
        damage = { 35, 55 },
        accuracy = { 40, 60 },
        range = { 4, 8 },
        ammo = { 6, 10 },
        weight = 3
    },
    sniper = {
        damage = { 45, 70 },
        accuracy = { 70, 95 },
        range = { 25, 40 },
        ammo = { 4, 8 },
        weight = 4
    },
    heavy = {
        damage = { 60, 90 },
        accuracy = { 45, 65 },
        range = { 12, 20 },
        ammo = { 3, 6 },
        weight = 5
    }
}

--- Armor templates
ItemGenerator.ARMOR_TEMPLATES = {
    light = {
        defense = { 5, 15 },
        mobilityBonus = { 10, 20 },
        weight = 1
    },
    medium = {
        defense = { 15, 30 },
        mobilityBonus = { 0, 10 },
        weight = 3
    },
    heavy = {
        defense = { 30, 50 },
        mobilityBonus = { -10, 0 },
        weight = 5
    },
    power = {
        defense = { 40, 60 },
        mobilityBonus = { -5, 5 },
        weight = 4
    }
}

--- Item modifiers
ItemGenerator.MODIFIERS = {
    damage = { 'Accurate', 'Powerful', 'Reliable', 'Unreliable' },
    accuracy = { 'Precise', 'Steady', 'True', 'Wild' },
    defense = { 'Reinforced', 'Hardened', 'Tough', 'Flexible' },
    special = { 'Alien', 'Experimental', 'Prototype', 'Enhanced' }
}

--- Initialize item generator
-- @param rng Random number generator
function ItemGenerator:initialize(rng)
    self.rng = rng
end

--- Generate items for a mission
-- @param requirements Item requirements table
-- @return Array of generated items
function ItemGenerator:generateItems(requirements)
    local items = {}

    -- Generate weapons
    for i = 1, requirements.weapons do
        table.insert(items, self:generateWeapon())
    end

    -- Generate armor
    for i = 1, requirements.armor do
        table.insert(items, self:generateArmor())
    end

    -- Generate grenades
    for i = 1, requirements.grenades do
        table.insert(items, self:generateGrenade())
    end

    -- Generate medkits
    for i = 1, requirements.medkits do
        table.insert(items, self:generateMedkit())
    end

    return items
end

--- Generate rewards for mission completion
-- @param difficulty Mission difficulty
-- @return Array of reward items
function ItemGenerator:generateRewards(difficulty)
    local rewards = {}
    local numRewards = self.rng:random(1, difficulty)

    for i = 1, numRewards do
        local rewardType = self:selectRewardType(difficulty)
        local item

        if rewardType == 'weapon' then
            item = self:generateWeapon(difficulty)
        elseif rewardType == 'armor' then
            item = self:generateArmor(difficulty)
        elseif rewardType == 'grenade' then
            item = self:generateGrenade()
        elseif rewardType == 'medkit' then
            item = self:generateMedkit()
        elseif rewardType == 'artifact' then
            item = self:generateArtifact(difficulty)
        end

        if item then
            table.insert(rewards, item)
        end
    end

    return rewards
end

--- Generate a weapon
-- @param tier Item tier/rarity (1-5)
-- @return Generated weapon item
function ItemGenerator:generateWeapon(tier)
    tier = tier or self.rng:random(1, 3)

    -- Select weapon type
    local weaponTypes = { 'pistol', 'rifle', 'shotgun', 'sniper', 'heavy' }
    local weaponType = weaponTypes[self.rng:random(#weaponTypes)]

    local template = self.WEAPON_TEMPLATES[weaponType]
    local weapon = {
        type = 'weapon',
        subtype = weaponType,
        name = self:generateWeaponName(weaponType, tier),
        tier = tier,
        stats = {},
        modifiers = {}
    }

    -- Generate base stats
    for stat, range in pairs(template) do
        if stat ~= 'weight' then
            local baseValue = self.rng:random(range[1], range[2])
            weapon.stats[stat] = math.floor(baseValue * (1 + (tier - 1) * 0.2))
        end
    end

    -- Add tier-based modifiers
    if tier >= 2 then
        local numModifiers = math.min(tier - 1, 2)
        for i = 1, numModifiers do
            local modifierType = self.rng:random() < 0.7 and 'damage' or 'accuracy'
            local modifier = self.MODIFIERS[modifierType][self.rng:random(#self.MODIFIERS[modifierType])]
            table.insert(weapon.modifiers, modifier)
        end
    end

    -- Add special modifier for high tier items
    if tier >= 4 and self.rng:random() < 0.3 then
        table.insert(weapon.modifiers, self.MODIFIERS.special[self.rng:random(#self.MODIFIERS.special)])
    end

    weapon.weight = template.weight
    weapon.value = self:calculateItemValue(weapon)

    return weapon
end

--- Generate armor
-- @param tier Item tier/rarity (1-5)
-- @return Generated armor item
function ItemGenerator:generateArmor(tier)
    tier = tier or self.rng:random(1, 3)

    -- Select armor type
    local armorTypes = { 'light', 'medium', 'heavy', 'power' }
    local armorType = armorTypes[self.rng:random(#armorTypes)]

    local template = self.ARMOR_TEMPLATES[armorType]
    local armor = {
        type = 'armor',
        subtype = armorType,
        name = self:generateArmorName(armorType, tier),
        tier = tier,
        stats = {},
        modifiers = {}
    }

    -- Generate base stats
    for stat, range in pairs(template) do
        if stat ~= 'weight' then
            local baseValue = self.rng:random(range[1], range[2])
            armor.stats[stat] = math.floor(baseValue * (1 + (tier - 1) * 0.15))
        end
    end

    -- Add tier-based modifiers
    if tier >= 2 then
        local numModifiers = math.min(tier - 1, 2)
        for i = 1, numModifiers do
            local modifier = self.MODIFIERS.defense[self.rng:random(#self.MODIFIERS.defense)]
            table.insert(armor.modifiers, modifier)
        end
    end

    -- Add special modifier for high tier items
    if tier >= 4 and self.rng:random() < 0.3 then
        table.insert(armor.modifiers, self.MODIFIERS.special[self.rng:random(#self.MODIFIERS.special)])
    end

    armor.weight = template.weight
    armor.value = self:calculateItemValue(armor)

    return armor
end

--- Generate a grenade
-- @return Generated grenade item
function ItemGenerator:generateGrenade()
    local grenadeTypes = {
        {
            name = 'Frag Grenade',
            damage = 40,
            radius = 3,
            description = 'Explosive fragmentation grenade'
        },
        {
            name = 'Flash Grenade',
            damage = 0,
            radius = 4,
            description = 'Non-lethal stun grenade',
            effect = 'stun'
        },
        {
            name = 'Smoke Grenade',
            damage = 0,
            radius = 5,
            description = 'Creates smoke cover',
            effect = 'smoke'
        },
        {
            name = 'Alien Grenade',
            damage = 50,
            radius = 4,
            description = 'Experimental alien explosive',
            effect = 'corrosive'
        }
    }

    local grenadeData = grenadeTypes[self.rng:random(#grenadeTypes)]
    local grenade = {
        type = 'grenade',
        name = grenadeData.name,
        damage = grenadeData.damage,
        radius = grenadeData.radius,
        description = grenadeData.description,
        effect = grenadeData.effect,
        weight = 1,
        value = 25 + self.rng:random(-5, 5)
    }

    return grenade
end

--- Generate a medkit
-- @return Generated medkit item
function ItemGenerator:generateMedkit()
    local medkitTypes = {
        {
            name = 'Basic Medkit',
            healing = 30,
            uses = 3
        },
        {
            name = 'Advanced Medkit',
            healing = 50,
            uses = 2
        },
        {
            name = 'Alien Medkit',
            healing = 40,
            uses = 4,
            effect = 'regeneration'
        }
    }

    local medkitData = medkitTypes[self.rng:random(#medkitTypes)]
    local medkit = {
        type = 'medkit',
        name = medkitData.name,
        healing = medkitData.healing,
        uses = medkitData.uses,
        effect = medkitData.effect,
        weight = 1,
        value = 30 + self.rng:random(-5, 5)
    }

    return medkit
end

--- Generate an alien artifact
-- @param tier Item tier/rarity
-- @return Generated artifact item
function ItemGenerator:generateArtifact(tier)
    tier = tier or self.rng:random(2, 5)

    local artifactTypes = {
        'Psi Amplifier',
        'Elerium Crystal',
        'Alien Alloy',
        'Plasma Core',
        'Neural Implant'
    }

    local artifact = {
        type = 'artifact',
        name = artifactTypes[self.rng:random(#artifactTypes)],
        tier = tier,
        researchValue = tier * 50 + self.rng:random(0, 50),
        weight = self.rng:random(1, 3),
        value = tier * 100 + self.rng:random(-20, 20)
    }

    return artifact
end

--- Generate weapon name
-- @param weaponType Type of weapon
-- @param tier Item tier
-- @return Generated weapon name
function ItemGenerator:generateWeaponName(weaponType, tier)
    local prefixes = {
        [1] = { 'Rusty', 'Old', 'Basic' },
        [2] = { 'Standard', 'Improved', 'Enhanced' },
        [3] = { 'Advanced', 'Superior', 'Refined' },
        [4] = { 'Elite', 'Masterwork', 'Experimental' },
        [5] = { 'Legendary', 'Alien', 'Prototype' }
    }

    local baseNames = {
        pistol = { 'Pistol', 'Handgun', 'Sidearm' },
        rifle = { 'Rifle', 'Carbine', 'Assault Rifle' },
        shotgun = { 'Shotgun', 'Scattergun', 'Combat Shotgun' },
        sniper = { 'Sniper Rifle', 'Precision Rifle', 'Long Rifle' },
        heavy = { 'Heavy Cannon', 'Rocket Launcher', 'Heavy Weapon' }
    }

    local prefixList = prefixes[tier] or prefixes[1]
    local baseList = baseNames[weaponType] or { 'Weapon' }

    local prefix = prefixList[self.rng:random(#prefixList)]
    local base = baseList[self.rng:random(#baseList)]

    return prefix .. ' ' .. base
end

--- Generate armor name
-- @param armorType Type of armor
-- @param tier Item tier
-- @return Generated armor name
function ItemGenerator:generateArmorName(armorType, tier)
    local prefixes = {
        [1] = { 'Basic', 'Simple', 'Light' },
        [2] = { 'Reinforced', 'Tactical', 'Combat' },
        [3] = { 'Advanced', 'Military', 'Heavy' },
        [4] = { 'Elite', 'Power', 'Experimental' },
        [5] = { 'Legendary', 'Alien', 'Masterwork' }
    }

    local baseNames = {
        light = { 'Armor', 'Vest', 'Suit' },
        medium = { 'Combat Armor', 'Battle Suit', 'Tactical Gear' },
        heavy = { 'Heavy Armor', 'Power Armor', 'Assault Suit' },
        power = { 'Power Armor', 'Exoskeleton', 'Mech Suit' }
    }

    local prefixList = prefixes[tier] or prefixes[1]
    local baseList = baseNames[armorType] or { 'Armor' }

    local prefix = prefixList[self.rng:random(#prefixList)]
    local base = baseList[self.rng:random(#baseList)]

    return prefix .. ' ' .. base
end

--- Select reward type based on difficulty
-- @param difficulty Mission difficulty
-- @return Reward type string
function ItemGenerator:selectRewardType(difficulty)
    local rewardWeights = {
        weapon = 40 + difficulty * 10,
        armor = 30 + difficulty * 5,
        grenade = 20,
        medkit = 15,
        artifact = difficulty * 5
    }

    local total = 0
    for _, weight in pairs(rewardWeights) do
        total = total + weight
    end

    local roll = self.rng:random(1, total)
    local current = 0

    for rewardType, weight in pairs(rewardWeights) do
        current = current + weight
        if roll <= current then
            return rewardType
        end
    end

    return 'weapon' -- fallback
end

--- Calculate item value
-- @param item Item data
-- @return Calculated value
function ItemGenerator:calculateItemValue(item)
    local baseValue = 50

    -- Tier multiplier
    baseValue = baseValue * (1 + (item.tier - 1) * 0.5)

    -- Type modifiers
    if item.type == 'weapon' then
        baseValue = baseValue * 1.2
    elseif item.type == 'armor' then
        baseValue = baseValue * 1.1
    elseif item.type == 'artifact' then
        baseValue = baseValue * 2.0
    end

    -- Modifier bonuses
    if item.modifiers then
        baseValue = baseValue * (1 + #item.modifiers * 0.25)
    end

    return math.floor(baseValue + self.rng:random(-10, 10))
end

return ItemGenerator