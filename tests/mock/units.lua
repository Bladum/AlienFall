-- Mock Unit Data Generator
-- Provides test data for soldiers, enemies, and unit management tests

local MockUnits = {}

-- Unit classes
MockUnits.CLASS_TYPES = {
    "ASSAULT",
    "HEAVY",
    "SNIPER",
    "SUPPORT",
    "SPECIALIST"
}

-- Enemy types
MockUnits.ENEMY_TYPES = {
    "SECTOID",
    "MUTON",
    "FLOATER",
    "CHRYSSALID",
    "BERSERKER",
    "THIN_MAN"
}

-- Generate a basic soldier
function MockUnits.getSoldier(name, class)
    name = name or "Soldier"
    class = class or "ASSAULT"
    
    return {
        id = "soldier_" .. math.random(1000, 9999),
        name = name,
        class = class,
        rank = "SQUADDIE",
        level = 1,
        
        -- Stats
        hp = 10,
        maxHp = 10,
        will = 40,
        aim = 65,
        defense = 0,
        mobility = 12,
        
        -- Status
        isAlive = true,
        isWounded = false,
        daysWounded = 0,
        stamina = 100,
        
        -- Equipment slots
        weapon = nil,
        armor = nil,
        utility1 = nil,
        utility2 = nil,
        
        -- Combat state
        tu = 12,
        maxTu = 12,
        energy = 100,
        morale = 100,
        
        -- Position (for battlescape)
        x = 0,
        y = 0,
        z = 0,
        facing = 0,
        
        -- Abilities
        abilities = {
            "RUN_AND_GUN",
            "OVERWATCH"
        },
        
        -- Experience
        xp = 0,
        kills = 0,
        missions = 0
    }
end

-- Generate a full squad
function MockUnits.generateSquad(count)
    count = count or 6
    local squad = {}
    
    local names = {
        "Rodriguez", "Chen", "Williams", "Ivanov", 
        "Schmidt", "Tanaka", "O'Brien", "Silva"
    }
    
    for i = 1, count do
        local class = MockUnits.CLASS_TYPES[((i - 1) % #MockUnits.CLASS_TYPES) + 1]
        local name = names[((i - 1) % #names) + 1]
        table.insert(squad, MockUnits.getSoldier(name, class))
    end
    
    return squad
end

-- Generate an enemy unit
function MockUnits.getEnemy(enemyType)
    enemyType = enemyType or "SECTOID"
    
    local stats = {
        SECTOID = {hp = 3, aim = 55, defense = 10, mobility = 12, damage = 3},
        MUTON = {hp = 10, aim = 65, defense = 0, mobility = 9, damage = 5},
        FLOATER = {hp = 4, aim = 60, defense = 10, mobility = 14, damage = 4},
        CHRYSSALID = {hp = 8, aim = 70, defense = 20, mobility = 17, damage = 8},
        BERSERKER = {hp = 20, aim = 0, defense = 0, mobility = 10, damage = 12},
        THIN_MAN = {hp = 6, aim = 70, defense = 15, mobility = 12, damage = 4}
    }
    
    local stat = stats[enemyType] or stats.SECTOID
    
    return {
        id = "enemy_" .. math.random(1000, 9999),
        name = enemyType,
        type = enemyType,
        faction = "ALIEN",
        
        -- Stats
        hp = stat.hp,
        maxHp = stat.hp,
        aim = stat.aim,
        defense = stat.defense,
        mobility = stat.mobility,
        damage = stat.damage,
        
        -- Status
        isAlive = true,
        stunned = false,
        
        -- Combat state
        tu = stat.mobility,
        maxTu = stat.mobility,
        
        -- Position
        x = 0,
        y = 0,
        z = 0,
        facing = 0,
        
        -- AI
        aiState = "PATROL",
        alertLevel = 0
    }
end

-- Generate a group of enemies
function MockUnits.generateEnemyGroup(count, types)
    count = count or 4
    types = types or MockUnits.ENEMY_TYPES
    local group = {}
    
    for i = 1, count do
        local enemyType = types[math.random(1, #types)]
        table.insert(group, MockUnits.getEnemy(enemyType))
    end
    
    return group
end

-- Generate a wounded soldier
function MockUnits.getWoundedSoldier(woundLevel)
    woundLevel = woundLevel or "LIGHT" -- LIGHT, MODERATE, SEVERE
    
    local soldier = MockUnits.getSoldier("Wounded", "ASSAULT")
    soldier.isWounded = true
    
    if woundLevel == "LIGHT" then
        soldier.hp = 7
        soldier.daysWounded = 3
    elseif woundLevel == "MODERATE" then
        soldier.hp = 4
        soldier.daysWounded = 7
    elseif woundLevel == "SEVERE" then
        soldier.hp = 1
        soldier.daysWounded = 14
    end
    
    return soldier
end

-- Generate a veteran soldier with high stats
function MockUnits.getVeteran()
    local veteran = MockUnits.getSoldier("Veteran", "SNIPER")
    veteran.rank = "COLONEL"
    veteran.level = 10
    veteran.hp = 15
    veteran.maxHp = 15
    veteran.aim = 95
    veteran.will = 80
    veteran.defense = 20
    veteran.mobility = 14
    veteran.kills = 50
    veteran.missions = 25
    veteran.xp = 10000
    
    veteran.abilities = {
        "SQUADSIGHT",
        "DEADSHOT",
        "LOW_PROFILE",
        "GUNSLINGER",
        "IN_THE_ZONE"
    }
    
    return veteran
end

-- Generate a unit with specific stats (for testing combat math)
function MockUnits.getUnitWithStats(stats)
    local unit = MockUnits.getSoldier()
    
    for k, v in pairs(stats) do
        unit[k] = v
    end
    
    return unit
end

-- Generate a civilian
function MockUnits.getCivilian(name)
    name = name or "Civilian"
    
    return {
        id = "civilian_" .. math.random(1000, 9999),
        name = name,
        type = "CIVILIAN",
        faction = "CIVILIAN",
        
        hp = 5,
        maxHp = 5,
        defense = 0,
        mobility = 10,
        
        isAlive = true,
        panicked = false,
        
        x = 0,
        y = 0,
        z = 0,
        
        aiState = "PANIC"
    }
end

return MockUnits



