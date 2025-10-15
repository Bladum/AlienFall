---Mock Item and Equipment Data Generator
---
---Provides test data for inventory and equipment testing. Generates mock weapons,
---armor, items, and equipment for unit tests, integration tests, and UI development.
---Covers all item types used in the game.
---
---Mock Item Types:
---  - Weapons: PISTOL, RIFLE, SHOTGUN, SNIPER_RIFLE, ROCKET_LAUNCHER
---  - Armor: KEVLAR, CARAPACE, TITAN, GHOST
---  - Items: MEDKIT, GRENADE, SMOKE_GRENADE, MOTION_SCANNER
---  - Ammo: Various ammunition types
---  - Utility: Equipment and consumables
---
---Key Exports:
---  - MockItems.getWeapon(type): Creates mock weapon
---  - MockItems.getArmor(type): Creates mock armor
---  - MockItems.getItem(type): Creates mock item
---  - MockItems.getLoadout(class): Creates full loadout for class
---  - MockItems.randomItem(): Returns random item
---
---Dependencies:
---  - None (pure mock data generator)
---
---@module shared.items.items
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MockItems = require("shared.items.items")
---  local rifle = MockItems.getWeapon("RIFLE")
---  local armor = MockItems.getArmor("CARAPACE")
---  local loadout = MockItems.getLoadout("ASSAULT")
---
---@see tests For inventory test usage
---@see battlescape.combat.equipment_system For real equipment

local MockItems = {}

--- Get a mock weapon
-- @param type string Weapon type (default: "RIFLE")
-- @return table Mock weapon data
function MockItems.getWeapon(type)
    type = type or "RIFLE"
    
    local weapons = {
        PISTOL = {
            name = "Pistol",
            category = "WEAPON",
            damage = 18,
            accuracy = 60,
            range = 15,
            ammo = 15,
            weight = 2,
            cost = 100
        },
        RIFLE = {
            name = "Assault Rifle",
            category = "WEAPON",
            damage = 30,
            accuracy = 70,
            range = 25,
            ammo = 30,
            weight = 4,
            cost = 350
        },
        SNIPER = {
            name = "Sniper Rifle",
            category = "WEAPON",
            damage = 60,
            accuracy = 90,
            range = 40,
            ammo = 10,
            weight = 6,
            cost = 800
        },
        SHOTGUN = {
            name = "Shotgun",
            category = "WEAPON",
            damage = 45,
            accuracy = 50,
            range = 10,
            ammo = 8,
            weight = 5,
            cost = 400
        },
        SMG = {
            name = "SMG",
            category = "WEAPON",
            damage = 20,
            accuracy = 65,
            range = 18,
            ammo = 40,
            weight = 3,
            cost = 250
        }
    }
    
    return weapons[type] or weapons.RIFLE
end

--- Get mock armor
-- @param type string Armor type (default: "BODY_ARMOR")
-- @return table Mock armor data
function MockItems.getArmor(type)
    type = type or "BODY_ARMOR"
    
    local armors = {
        BODY_ARMOR = {
            name = "Body Armor",
            category = "ARMOR",
            protection = 12,
            weight = 8,
            cost = 500
        },
        POWER_ARMOR = {
            name = "Power Armor",
            category = "ARMOR",
            protection = 40,
            weight = 15,
            cost = 2000
        },
        FLYING_SUIT = {
            name = "Flying Suit",
            category = "ARMOR",
            protection = 30,
            weight = 10,
            canFly = true,
            cost = 3000
        }
    }
    
    return armors[type] or armors.BODY_ARMOR
end

--- Get mock grenade
-- @param type string Grenade type (default: "FRAG")
-- @return table Mock grenade data
function MockItems.getGrenade(type)
    type = type or "FRAG"
    
    local grenades = {
        FRAG = {
            name = "Frag Grenade",
            category = "GRENADE",
            damage = 50,
            radius = 3,
            weight = 1,
            cost = 50
        },
        SMOKE = {
            name = "Smoke Grenade",
            category = "GRENADE",
            damage = 0,
            radius = 4,
            smokeDuration = 5,
            weight = 1,
            cost = 30
        },
        INCENDIARY = {
            name = "Incendiary Grenade",
            category = "GRENADE",
            damage = 30,
            radius = 3,
            fireDuration = 4,
            weight = 1,
            cost = 80
        }
    }
    
    return grenades[type] or grenades.FRAG
end

--- Get mock medkit
-- @return table Mock medkit data
function MockItems.getMedkit()
    return {
        name = "Medikit",
        category = "MEDICAL",
        healAmount = 30,
        painkillerAmount = 20,
        stimulantAmount = 10,
        uses = 10,
        weight = 2,
        cost = 500
    }
end

--- Generate a basic loadout for a soldier
-- @param class string Soldier class
-- @return table Equipment loadout
function MockItems.generateLoadout(class)
    class = class or "ASSAULT"
    
    local loadouts = {
        ASSAULT = {
            primary = MockItems.getWeapon("RIFLE"),
            secondary = MockItems.getWeapon("PISTOL"),
            armor = MockItems.getArmor("BODY_ARMOR"),
            belt = {
                MockItems.getGrenade("FRAG"),
                MockItems.getGrenade("SMOKE")
            }
        },
        SNIPER = {
            primary = MockItems.getWeapon("SNIPER"),
            secondary = MockItems.getWeapon("PISTOL"),
            armor = MockItems.getArmor("BODY_ARMOR"),
            belt = {
                MockItems.getGrenade("SMOKE")
            }
        },
        MEDIC = {
            primary = MockItems.getWeapon("SMG"),
            secondary = MockItems.getWeapon("PISTOL"),
            armor = MockItems.getArmor("BODY_ARMOR"),
            belt = {
                MockItems.getMedkit(),
                MockItems.getMedkit(),
                MockItems.getGrenade("SMOKE")
            }
        },
        HEAVY = {
            primary = MockItems.getWeapon("SHOTGUN"),
            secondary = MockItems.getWeapon("PISTOL"),
            armor = MockItems.getArmor("POWER_ARMOR"),
            belt = {
                MockItems.getGrenade("FRAG"),
                MockItems.getGrenade("FRAG"),
                MockItems.getGrenade("INCENDIARY")
            }
        }
    }
    
    return loadouts[class] or loadouts.ASSAULT
end

--- Generate random inventory items
-- @param count number Number of items
-- @return table Array of items
function MockItems.generateInventory(count)
    count = count or 10
    local inventory = {}
    
    local types = {"RIFLE", "PISTOL", "SHOTGUN", "SNIPER", "SMG"}
    for i = 1, count do
        local type = types[math.random(1, #types)]
        table.insert(inventory, MockItems.getWeapon(type))
    end
    
    return inventory
end

return MockItems






















