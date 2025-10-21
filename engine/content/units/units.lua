---Mock Unit Data Generator
---
---Provides test data for unit and soldier testing. Generates mock soldiers with
---customizable properties for unit tests, integration tests, and UI development.
---Used throughout the test suite for consistent unit data.
---
---Mock Data Types:
---  - Soldiers: ASSAULT, SNIPER, HEAVY, SUPPORT classes
---  - Aliens: SECTOID, MUTON, CHRYSSALID types
---  - Stats: HP, AP, accuracy, strength, will
---  - Equipment: Weapons, armor, items
---  - Status: Health, morale, conditions
---
---Key Exports:
---  - MockUnits.getSoldier(name, class): Creates mock soldier
---  - MockUnits.getAlien(type): Creates mock alien
---  - MockUnits.getSquad(size): Creates full squad
---  - MockUnits.withEquipment(unit, items): Adds equipment
---  - MockUnits.randomStats(unit): Randomizes stats
---
---Dependencies:
---  - None (pure mock data generator)
---
---@module shared.units.units
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MockUnits = require("shared.units.units")
---  local soldier = MockUnits.getSoldier("John Doe", "ASSAULT")
---  local squad = MockUnits.getSquad(6)
---  local alien = MockUnits.getAlien("SECTOID")
---
---@see tests For unit test usage
---@see battlescape.combat.unit For real unit implementation

local MockUnits = {}

--- Get a mock soldier with customizable properties
-- @param name string Optional name (default: "Test Soldier")
-- @param class string Optional class (default: "ASSAULT")
-- @return table Mock soldier data
function MockUnits.getSoldier(name, class)
    return {
        id = math.random(1000, 9999),
        name = name or "Test Soldier",
        class = class or "ASSAULT",
        rank = "ROOKIE",
        hp = 100,
        maxHp = 100,
        ap = 10,
        maxAp = 10,
        stats = {
            strength = 50,
            accuracy = 60,
            reactions = 55,
            throwing = 45,
            psiStrength = 0,
            psiSkill = 0,
            bravery = 60,
            health = 100
        },
        equipment = {},
        experience = 0,
        kills = 0,
        missions = 0
    }
end

--- Generate a full squad of soldiers
-- @param count number Number of soldiers (default: 8)
-- @return table Array of mock soldiers
function MockUnits.generateSquad(count)
    count = count or 8
    local squad = {}
    local classes = {"ASSAULT", "SNIPER", "MEDIC", "HEAVY", "SCOUT", "ENGINEER"}
    
    for i = 1, count do
        local class = classes[((i - 1) % #classes) + 1]
        table.insert(squad, MockUnits.getSoldier("Soldier " .. i, class))
    end
    
    return squad
end

--- Get a mock enemy unit
-- @param type string Enemy type (default: "SECTOID")
-- @return table Mock enemy data
function MockUnits.getEnemy(type)
    type = type or "SECTOID"
    
    local enemies = {
        SECTOID = {hp = 30, ap = 8, accuracy = 50, armor = 0},
        MUTON = {hp = 80, ap = 10, accuracy = 65, armor = 8},
        FLOATER = {hp = 50, ap = 12, accuracy = 55, armor = 4},
        CHRYSSALID = {hp = 60, ap = 16, accuracy = 80, armor = 6}
    }
    
    local stats = enemies[type] or enemies.SECTOID
    
    return {
        id = math.random(5000, 9999),
        name = type,
        type = type,
        faction = "ALIEN",
        hp = stats.hp,
        maxHp = stats.hp,
        ap = stats.ap,
        maxAp = stats.ap,
        stats = {
            strength = 40,
            accuracy = stats.accuracy,
            reactions = 50,
            armor = stats.armor
        },
        ai = "AGGRESSIVE"
    }
end

--- Generate a group of enemies
-- @param count number Number of enemies
-- @param types table Optional array of types to use
-- @return table Array of mock enemies
function MockUnits.generateEnemyGroup(count, types)
    count = count or 4
    types = types or {"SECTOID", "SECTOID", "MUTON", "FLOATER"}
    
    local group = {}
    for i = 1, count do
        local type = types[((i - 1) % #types) + 1]
        table.insert(group, MockUnits.getEnemy(type))
    end
    
    return group
end

--- Get wounded soldier for testing recovery
-- @param woundLevel number HP percentage (0.0 to 1.0, default: 0.3 = 30% HP)
-- @return table Wounded soldier
function MockUnits.getWoundedSoldier(woundLevel)
    woundLevel = woundLevel or 0.3
    local soldier = MockUnits.getSoldier("Wounded Soldier", "ASSAULT")
    soldier.hp = math.floor(soldier.maxHp * woundLevel)
    return soldier
end

--- Get veteran soldier with high stats
-- @return table Veteran soldier
function MockUnits.getVeteran()
    local veteran = MockUnits.getSoldier("Veteran", "SNIPER")
    veteran.rank = "CAPTAIN"
    veteran.stats.accuracy = 85
    veteran.stats.reactions = 75
    veteran.stats.strength = 65
    veteran.experience = 500
    veteran.kills = 25
    veteran.missions = 15
    return veteran
end

return MockUnits

























