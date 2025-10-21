-- Mock Item Data Generator
-- Provides test data for weapons, armor, equipment, and inventory tests

local MockItems = {}

-- Weapon types
MockItems.WEAPON_TYPES = {
    "PISTOL",
    "RIFLE",
    "SNIPER",
    "SHOTGUN",
    "HEAVY",
    "SWORD"
}

-- Armor types
MockItems.ARMOR_TYPES = {
    "KEVLAR",
    "CARAPACE",
    "TITAN",
    "GHOST"
}

-- Grenade types
MockItems.GRENADE_TYPES = {
    "FRAG",
    "SMOKE",
    "INCENDIARY",
    "ALIEN",
    "GAS"
}

-- Get a weapon by type
function MockItems.getWeapon(weaponType)
    weaponType = weaponType or "RIFLE"
    
    local weapons = {
        PISTOL = {
            id = "weapon_pistol",
            name = "Pistol",
            type = "PISTOL",
            damage = 3,
            range = 12,
            accuracy = 70,
            ammo = 8,
            maxAmmo = 8,
            tuCost = 4,
            weight = 2
        },
        RIFLE = {
            id = "weapon_rifle",
            name = "Assault Rifle",
            type = "RIFLE",
            damage = 4,
            range = 18,
            accuracy = 65,
            ammo = 30,
            maxAmmo = 30,
            tuCost = 6,
            weight = 4
        },
        SNIPER = {
            id = "weapon_sniper",
            name = "Sniper Rifle",
            type = "SNIPER",
            damage = 8,
            range = 30,
            accuracy = 80,
            ammo = 5,
            maxAmmo = 5,
            tuCost = 8,
            weight = 6
        },
        SHOTGUN = {
            id = "weapon_shotgun",
            name = "Shotgun",
            type = "SHOTGUN",
            damage = 6,
            range = 8,
            accuracy = 60,
            ammo = 6,
            maxAmmo = 6,
            tuCost = 5,
            weight = 5
        },
        HEAVY = {
            id = "weapon_heavy",
            name = "Heavy Cannon",
            type = "HEAVY",
            damage = 10,
            range = 20,
            accuracy = 50,
            ammo = 20,
            maxAmmo = 20,
            tuCost = 10,
            weight = 8,
            areaEffect = 2
        },
        SWORD = {
            id = "weapon_sword",
            name = "Arc Blade",
            type = "SWORD",
            damage = 9,
            range = 1,
            accuracy = 85,
            ammo = -1,
            maxAmmo = -1,
            tuCost = 4,
            weight = 3
        }
    }
    
    return weapons[weaponType] or weapons.RIFLE
end

-- Get armor by type
function MockItems.getArmor(armorType)
    armorType = armorType or "KEVLAR"
    
    local armors = {
        KEVLAR = {
            id = "armor_kevlar",
            name = "Kevlar Armor",
            type = "KEVLAR",
            defense = 2,
            hp = 2,
            mobility = 0,
            weight = 5
        },
        CARAPACE = {
            id = "armor_carapace",
            name = "Carapace Armor",
            type = "CARAPACE",
            defense = 4,
            hp = 4,
            mobility = -1,
            weight = 8
        },
        TITAN = {
            id = "armor_titan",
            name = "Titan Armor",
            type = "TITAN",
            defense = 6,
            hp = 8,
            mobility = -2,
            weight = 12
        },
        GHOST = {
            id = "armor_ghost",
            name = "Ghost Armor",
            type = "GHOST",
            defense = 3,
            hp = 3,
            mobility = 2,
            weight = 4,
            special = "STEALTH"
        }
    }
    
    return armors[armorType] or armors.KEVLAR
end

-- Get grenade by type
function MockItems.getGrenade(grenadeType)
    grenadeType = grenadeType or "FRAG"
    
    local grenades = {
        FRAG = {
            id = "grenade_frag",
            name = "Frag Grenade",
            type = "FRAG",
            damage = 5,
            radius = 3,
            tuCost = 6,
            weight = 1
        },
        SMOKE = {
            id = "grenade_smoke",
            name = "Smoke Grenade",
            type = "SMOKE",
            damage = 0,
            radius = 4,
            tuCost = 4,
            weight = 1,
            effect = "SMOKE"
        },
        INCENDIARY = {
            id = "grenade_incendiary",
            name = "Incendiary Grenade",
            type = "INCENDIARY",
            damage = 3,
            radius = 3,
            tuCost = 6,
            weight = 1,
            effect = "FIRE",
            duration = 3
        },
        ALIEN = {
            id = "grenade_alien",
            name = "Alien Grenade",
            type = "ALIEN",
            damage = 8,
            radius = 4,
            tuCost = 6,
            weight = 1
        },
        GAS = {
            id = "grenade_gas",
            name = "Gas Grenade",
            type = "GAS",
            damage = 2,
            radius = 4,
            tuCost = 6,
            weight = 1,
            effect = "POISON",
            duration = 4
        }
    }
    
    return grenades[grenadeType] or grenades.FRAG
end

-- Get medical kit
function MockItems.getMedkit()
    return {
        id = "item_medkit",
        name = "Medikit",
        type = "MEDKIT",
        charges = 3,
        maxCharges = 3,
        healAmount = 4,
        tuCost = 6,
        weight = 2
    }
end

-- Get scanner
function MockItems.getScanner()
    return {
        id = "item_scanner",
        name = "Motion Scanner",
        type = "SCANNER",
        range = 15,
        tuCost = 4,
        weight = 1
    }
end

-- Generate a class-specific loadout
function MockItems.generateLoadout(class)
    class = class or "ASSAULT"
    
    local loadouts = {
        ASSAULT = {
            primary = MockItems.getWeapon("RIFLE"),
            secondary = MockItems.getWeapon("PISTOL"),
            armor = MockItems.getArmor("KEVLAR"),
            utility1 = MockItems.getGrenade("FRAG"),
            utility2 = MockItems.getMedkit()
        },
        HEAVY = {
            primary = MockItems.getWeapon("HEAVY"),
            secondary = MockItems.getWeapon("PISTOL"),
            armor = MockItems.getArmor("CARAPACE"),
            utility1 = MockItems.getGrenade("FRAG"),
            utility2 = MockItems.getGrenade("SMOKE")
        },
        SNIPER = {
            primary = MockItems.getWeapon("SNIPER"),
            secondary = MockItems.getWeapon("PISTOL"),
            armor = MockItems.getArmor("KEVLAR"),
            utility1 = MockItems.getScanner(),
            utility2 = MockItems.getMedkit()
        },
        SUPPORT = {
            primary = MockItems.getWeapon("RIFLE"),
            secondary = MockItems.getWeapon("PISTOL"),
            armor = MockItems.getArmor("KEVLAR"),
            utility1 = MockItems.getMedkit(),
            utility2 = MockItems.getGrenade("SMOKE")
        },
        SPECIALIST = {
            primary = MockItems.getWeapon("SHOTGUN"),
            secondary = MockItems.getWeapon("PISTOL"),
            armor = MockItems.getArmor("GHOST"),
            utility1 = MockItems.getGrenade("GAS"),
            utility2 = MockItems.getScanner()
        }
    }
    
    return loadouts[class] or loadouts.ASSAULT
end

-- Generate random inventory items
function MockItems.generateInventory(count)
    count = count or 10
    local inventory = {}
    
    local allTypes = {"WEAPON", "ARMOR", "GRENADE", "UTILITY"}
    
    for i = 1, count do
        local category = allTypes[math.random(1, #allTypes)]
        
        if category == "WEAPON" then
            local weaponType = MockItems.WEAPON_TYPES[math.random(1, #MockItems.WEAPON_TYPES)]
            table.insert(inventory, MockItems.getWeapon(weaponType))
        elseif category == "ARMOR" then
            local armorType = MockItems.ARMOR_TYPES[math.random(1, #MockItems.ARMOR_TYPES)]
            table.insert(inventory, MockItems.getArmor(armorType))
        elseif category == "GRENADE" then
            local grenadeType = MockItems.GRENADE_TYPES[math.random(1, #MockItems.GRENADE_TYPES)]
            table.insert(inventory, MockItems.getGrenade(grenadeType))
        else
            table.insert(inventory, MockItems.getMedkit())
        end
    end
    
    return inventory
end

-- Get ammo item
function MockItems.getAmmo(weaponType)
    return {
        id = "ammo_" .. string.lower(weaponType),
        name = weaponType .. " Ammo",
        type = "AMMO",
        weaponType = weaponType,
        quantity = 50,
        weight = 1
    }
end

return MockItems



