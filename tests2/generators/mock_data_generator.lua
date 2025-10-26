-- ─────────────────────────────────────────────────────────────────────────
-- MOCK DATA GENERATOR FOR TESTS2
-- Generates realistic mock data for all game systems
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Create consistent test data for unit and integration tests
-- Usage:
--   local MockGen = require("tests2.generators.mock_data_generator")
--   local mockUnit = MockGen.generateUnit({class = "soldier"})
--   local mockCraft = MockGen.generateCraft({craftType = "interceptor"})
-- ─────────────────────────────────────────────────────────────────────────

local MockGen = {}

-- ─────────────────────────────────────────────────────────────────────────
-- UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Generate unique ID with prefix
---@param prefix string - ID prefix
---@return string - unique ID
local function generateId(prefix)
    prefix = prefix or "mock"
    local timestamp = os.time()
    local random = math.floor(math.random() * 1000000)
    return string.format("%s_%d_%d", prefix, timestamp, random)
end

---Random choice from array
---@param array table - array to choose from
---@return any - random element
local function randomChoice(array)
    if not array or #array == 0 then return nil end
    return array[math.random(1, #array)]
end

---Random integer in range
---@param min number - minimum value
---@param max number - maximum value
---@return number - random integer
local function randomRange(min, max)
    return math.random(min, max)
end

---Merge options with defaults
---@param opts table - options
---@param defaults table - default values
---@return table - merged options
local function mergeDefaults(opts, defaults)
    opts = opts or {}
    for k, v in pairs(defaults) do
        if opts[k] == nil then
            opts[k] = v
        end
    end
    return opts
end

-- ─────────────────────────────────────────────────────────────────────────
-- UNIT & SOLDIER GENERATION
-- ─────────────────────────────────────────────────────────────────────────

---Generate soldier/unit rank
---@param opts table - {minRank, maxRank}
---@return table - rank data
function MockGen.generateRank(opts)
    opts = mergeDefaults(opts, {minRank = 0, maxRank = 6})

    local ranks = {
        {id = "rank_rookie", name = "Rookie", level = 0},
        {id = "rank_veteran", name = "Veteran", level = 1},
        {id = "rank_sergeant", name = "Sergeant", level = 2},
        {id = "rank_lieutenant", name = "Lieutenant", level = 3},
        {id = "rank_captain", name = "Captain", level = 4},
        {id = "rank_major", name = "Major", level = 5},
        {id = "rank_colonel", name = "Colonel", level = 6},
    }

    local minIdx = math.min(opts.minRank + 1, #ranks)
    local maxIdx = math.min(opts.maxRank + 1, #ranks)
    return ranks[randomRange(minIdx, maxIdx)]
end

---Generate soldier class
---@param opts table - {side, classType}
---@return table - class data
function MockGen.generateClass(opts)
    opts = mergeDefaults(opts, {side = "human", classType = nil})

    if opts.side == "human" then
        return randomChoice({
            {id = "class_soldier", name = "Soldier", side = "human", role = "general"},
            {id = "class_heavy", name = "Heavy", side = "human", role = "tank"},
            {id = "class_sniper", name = "Sniper", side = "human", role = "support"},
            {id = "class_scout", name = "Scout", side = "human", role = "mobility"},
            {id = "class_support", name = "Support", side = "human", role = "utility"},
            {id = "class_leader", name = "Leader", side = "human", role = "command"},
        })
    else
        return randomChoice({
            {id = "class_sectoid", name = "Sectoid", side = "alien", role = "general"},
            {id = "class_muton", name = "Muton", side = "alien", role = "tank"},
            {id = "class_floater", name = "Floater", side = "alien", role = "mobility"},
            {id = "class_chryssalid", name = "Chryssalid", side = "alien", role = "melee"},
            {id = "class_ethereal", name = "Ethereal", side = "alien", role = "command"},
        })
    end
end

---Generate soldier stats
---@param opts table - {level, quality}
---@return table - stats
function MockGen.generateStats(opts)
    opts = mergeDefaults(opts, {level = 1, quality = "average"})

    local baseStats = {
        aim = 65,
        accuracy = 70,
        reactions = 60,
        speed = 75,
        mind = 50,
        melee = 55,
        armor = 0,
        sight = 80,
    }

    -- Adjust by level
    for k, v in pairs(baseStats) do
        baseStats[k] = v + (opts.level * 5)
    end

    -- Adjust by quality
    if opts.quality == "poor" then
        for k, v in pairs(baseStats) do
            baseStats[k] = v - randomRange(5, 15)
        end
    elseif opts.quality == "excellent" then
        for k, v in pairs(baseStats) do
            baseStats[k] = v + randomRange(5, 15)
        end
    end

    return baseStats
end

---Generate unit/soldier
---@param opts table - {id, name, class, faction, rank, xp}
---@return table - unit data
function MockGen.generateUnit(opts)
    opts = mergeDefaults(opts, {
        id = generateId("unit"),
        name = "Soldier",
        class = nil,
        faction = "xcom",
        rank = nil,
        xp = 0,
    })

    if not opts.class then
        opts.class = MockGen.generateClass({side = "human"})
    end

    if not opts.rank then
        opts.rank = MockGen.generateRank({minRank = 0, maxRank = 3})
    end

    return {
        id = opts.id,
        name = opts.name,
        class = opts.class,
        faction = opts.faction,
        rank = opts.rank,
        xp = opts.xp,
        health = 100,
        maxHealth = 100,
        stats = MockGen.generateStats({level = opts.rank.level}),
        inventory = {},
        skills = {},
        armor = nil,
        weapon = nil,
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- EQUIPMENT GENERATION
-- ─────────────────────────────────────────────────────────────────────────

---Generate weapon
---@param opts table - {tier, type}
---@return table - weapon data
function MockGen.generateWeapon(opts)
    opts = mergeDefaults(opts, {tier = 1, type = "rifle"})

    local weapons = {
        rifle = {
            {id = "rifle_conventional", name = "Conventional Rifle", damage = 50, accuracy = 70, ammo = 30},
            {id = "rifle_plasma", name = "Plasma Rifle", damage = 75, accuracy = 65, ammo = 25},
            {id = "rifle_laser", name = "Laser Rifle", damage = 65, accuracy = 85, ammo = 35},
        },
        pistol = {
            {id = "pistol_standard", name = "Combat Pistol", damage = 35, accuracy = 60, ammo = 15},
            {id = "pistol_plasma", name = "Plasma Pistol", damage = 55, accuracy = 55, ammo = 12},
        },
        heavy = {
            {id = "mg_standard", name = "Machine Gun", damage = 45, accuracy = 50, ammo = 60},
            {id = "rl_launcher", name = "Rocket Launcher", damage = 120, accuracy = 40, ammo = 6},
        },
        sniper = {
            {id = "sniper_conventional", name = "Sniper Rifle", damage = 90, accuracy = 95, ammo = 20},
            {id = "sniper_plasma", name = "Plasma Sniper", damage = 110, accuracy = 90, ammo = 15},
        },
    }

    local weaponList = weapons[opts.type] or weapons.rifle
    return randomChoice(weaponList)
end

---Generate armor
---@param opts table - {tier}
---@return table - armor data
function MockGen.generateArmor(opts)
    opts = mergeDefaults(opts, {tier = 1})

    local armors = {
        {id = "armor_light", name = "Light Armor", protection = 5, mobility = 100},
        {id = "armor_standard", name = "Standard Armor", protection = 10, mobility = 95},
        {id = "armor_heavy", name = "Heavy Armor", protection = 15, mobility = 90},
        {id = "armor_power", name = "Power Suit", protection = 20, mobility = 85},
        {id = "armor_plasma", name = "Plasma Armor", protection = 25, mobility = 88},
    }

    return armors[math.min(opts.tier, #armors)]
end

-- ─────────────────────────────────────────────────────────────────────────
-- FACILITY GENERATION
-- ─────────────────────────────────────────────────────────────────────────

---Generate facility
---@param opts table - {id, type, level}
---@return table - facility data
function MockGen.generateFacility(opts)
    opts = mergeDefaults(opts, {
        id = generateId("facility"),
        type = "quarters",
        level = 1,
    })

    local facilities = {
        quarters = {name = "Barracks", capacity = 50, cost = 300},
        hangar = {name = "Hangar", capacity = 5, cost = 600},
        workshop = {name = "Workshop", capacity = 30, cost = 400},
        laboratory = {name = "Laboratory", capacity = 20, cost = 500},
        surveillance = {name = "Surveillance Room", capacity = 1, cost = 400},
        power = {name = "Power Generator", capacity = 1, cost = 250},
    }

    local facilityType = facilities[opts.type] or facilities.quarters

    return {
        id = opts.id,
        type = opts.type,
        name = facilityType.name,
        level = opts.level,
        status = "operational",
        capacity = facilityType.capacity,
        occupied = randomRange(0, math.floor(facilityType.capacity / 2)),
        cost = facilityType.cost,
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- CRAFT GENERATION
-- ─────────────────────────────────────────────────────────────────────────

---Generate aircraft/craft
---@param opts table - {id, type, status}
---@return table - craft data
function MockGen.generateCraft(opts)
    opts = mergeDefaults(opts, {
        id = generateId("craft"),
        type = "interceptor",
        status = "idle",
    })

    local craftTypes = {
        interceptor = {name = "Interceptor", speed = 900, weapons = 2, crew = 1},
        transport = {name = "Troop Transport", speed = 750, weapons = 0, crew = 2},
        supply = {name = "Supply Carrier", speed = 600, weapons = 0, crew = 1},
        bomber = {name = "Bomber", speed = 800, weapons = 4, crew = 2},
    }

    local craftType = craftTypes[opts.type] or craftTypes.interceptor

    return {
        id = opts.id,
        name = craftType.name,
        type = opts.type,
        status = opts.status,
        location = "base",
        speed = craftType.speed,
        weapons = craftType.weapons,
        crew = craftType.crew,
        health = 100,
        maxHealth = 100,
        fuel = 100,
        maxFuel = 100,
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- MISSION & COMBAT GENERATION
-- ─────────────────────────────────────────────────────────────────────────

---Generate mission
---@param opts table - {id, type, status}
---@return table - mission data
function MockGen.generateMission(opts)
    opts = mergeDefaults(opts, {
        id = generateId("mission"),
        type = "combat",
        status = "planning",
    })

    local missionTypes = {
        combat = {name = "Combat Interception", difficulty = 5},
        rescue = {name = "Rescue Operation", difficulty = 7},
        investigation = {name = "UFO Investigation", difficulty = 6},
        supply = {name = "Supply Run", difficulty = 2},
    }

    local missionType = missionTypes[opts.type] or missionTypes.combat

    return {
        id = opts.id,
        name = missionType.name,
        type = opts.type,
        status = opts.status,
        difficulty = missionType.difficulty,
        location = "Unknown",
        objective = "Unknown",
        squad = {},
        rewards = {money = randomRange(500, 2000), tech = 1},
        deadline = os.time() + (randomRange(1, 7) * 86400),
    }
end

---Generate game state
---@param opts table - {year, month, funds}
---@return table - game state data
function MockGen.generateGameState(opts)
    opts = mergeDefaults(opts, {
        year = 2024,
        month = 1,
        funds = 10000,
    })

    return {
        gameId = generateId("game"),
        year = opts.year,
        month = opts.month,
        turn = randomRange(1, 100),
        phase = "geoscape",
        funds = opts.funds,
        population = randomRange(1000000, 9000000),
        panic = randomRange(0, 100),
        bases = {},
        crafts = {},
        units = {},
        missions = {},
        research = {},
        manufactoring = {},
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- BATCH GENERATION
-- ─────────────────────────────────────────────────────────────────────────

---Generate multiple units
---@param count number - how many units
---@param opts table - options for each unit
---@return table - array of units
function MockGen.generateUnits(count, opts)
    count = count or 10
    opts = opts or {}

    local units = {}
    for i = 1, count do
        local unitOpts = mergeDefaults(opts, {
            name = "Soldier #" .. i,
            faction = i % 2 == 0 and "xcom" or "aliens",
        })
        table.insert(units, MockGen.generateUnit(unitOpts))
    end
    return units
end

---Generate multiple crafts
---@param count number - how many crafts
---@param opts table - options for each craft
---@return table - array of crafts
function MockGen.generateCrafts(count, opts)
    count = count or 5
    opts = opts or {}

    local crafts = {}
    for i = 1, count do
        table.insert(crafts, MockGen.generateCraft(opts))
    end
    return crafts
end

---Generate multiple facilities
---@param count number - how many facilities
---@param opts table - options for each facility
---@return table - array of facilities
function MockGen.generateFacilities(count, opts)
    count = count or 10
    opts = opts or {}

    local facilities = {}
    local types = {"quarters", "hangar", "workshop", "laboratory", "surveillance", "power"}
    for i = 1, count do
        local facilityOpts = mergeDefaults(opts, {type = types[(i % #types) + 1]})
        table.insert(facilities, MockGen.generateFacility(facilityOpts))
    end
    return facilities
end

-- ─────────────────────────────────────────────────────────────────────────
-- PRESET COLLECTIONS (for common test scenarios)
-- ─────────────────────────────────────────────────────────────────────────

---Generate full base setup
---@param opts table - {baseId, unitCount, craftCount}
---@return table - complete base state
function MockGen.generateBase(opts)
    opts = mergeDefaults(opts, {
        baseId = generateId("base"),
        unitCount = 12,
        craftCount = 3,
    })

    return {
        id = opts.baseId,
        name = "Base Alpha",
        location = "Unknown",
        facilities = MockGen.generateFacilities(8, {}),
        units = MockGen.generateUnits(opts.unitCount, {}),
        crafts = MockGen.generateCrafts(opts.craftCount, {}),
        resources = {
            funds = 5000,
            supplies = 1000,
            alloys = 500,
        },
    }
end

return MockGen
