-- Mock Geoscape Data Generator
-- Provides test data for world, provinces, missions, and strategic layer tests

local MockGeoscape = {}

-- Generate a province
function MockGeoscape.getProvince(provinceName)
    provinceName = provinceName or "Test Province"
    
    return {
        id = "province_" .. math.random(1000, 9999),
        name = provinceName,
        
        -- Hex coordinates (array of tiles)
        hexes = {
            {q = 10, r = 15},
            {q = 11, r = 15},
            {q = 10, r = 16}
        },
        
        -- Political info
        country = "USA",
        region = "North America",
        population = 5000000,
        
        -- Status
        controlled = true,
        panic = 2,
        satisfaction = 7,
        
        -- Resources
        income = 50000,
        supplies = 100,
        
        -- Strategic
        facilities = {},
        missions = {},
        ufos = {}
    }
end

-- Generate a country
function MockGeoscape.getCountry(countryName)
    countryName = countryName or "USA"
    
    local countries = {
        USA = {
            id = "country_usa",
            name = "United States",
            code = "USA",
            capital = {q = 15, r = 20},
            population = 330000000,
            funding = 200000,
            panic = 2,
            satisfaction = 8,
            provinces = {}
        },
        UK = {
            id = "country_uk",
            name = "United Kingdom",
            code = "UK",
            capital = {q = 40, r = 25},
            population = 67000000,
            funding = 150000,
            panic = 1,
            satisfaction = 9,
            provinces = {}
        },
        GERMANY = {
            id = "country_germany",
            name = "Germany",
            code = "GER",
            capital = {q = 42, r = 27},
            population = 83000000,
            funding = 180000,
            panic = 3,
            satisfaction = 7,
            provinces = {}
        },
        JAPAN = {
            id = "country_japan",
            name = "Japan",
            code = "JPN",
            capital = {q = 70, r = 30},
            population = 126000000,
            funding = 120000,
            panic = 2,
            satisfaction = 8,
            provinces = {}
        },
        RUSSIA = {
            id = "country_russia",
            name = "Russia",
            code = "RUS",
            capital = {q = 50, r = 35},
            population = 144000000,
            funding = 150000,
            panic = 4,
            satisfaction = 6,
            provinces = {}
        }
    }
    
    return countries[countryName] or countries.USA
end

-- Generate world data
function MockGeoscape.getWorld(size)
    size = size or {width = 80, height = 60}
    
    return {
        width = size.width,
        height = size.height,
        scale = 32,
        
        -- Grid data
        tiles = {},
        
        -- Political divisions
        provinces = {},
        countries = {},
        regions = {},
        
        -- Time
        date = {year = 2025, month = 1, day = 1},
        turn = 1,
        
        -- Strategic assets
        bases = {},
        crafts = {},
        
        -- Active missions
        activeMissions = {},
        
        -- UFO activity
        ufos = {},
        
        -- World state
        globalPanic = 3,
        alienActivity = 5
    }
end

-- Generate a UFO
function MockGeoscape.getUFO(ufoType)
    ufoType = ufoType or "SCOUT"
    
    local ufos = {
        SCOUT = {
            id = "ufo_" .. math.random(1000, 9999),
            type = "SCOUT",
            size = "SMALL",
            position = {q = 25, r = 30},
            speed = 5,
            hp = 50,
            maxHp = 50,
            detected = true,
            mission = "RESEARCH",
            behavior = "PATROL"
        },
        FIGHTER = {
            id = "ufo_" .. math.random(1000, 9999),
            type = "FIGHTER",
            size = "SMALL",
            position = {q = 30, r = 35},
            speed = 8,
            hp = 80,
            maxHp = 80,
            detected = true,
            mission = "HUNT",
            behavior = "AGGRESSIVE"
        },
        HARVESTER = {
            id = "ufo_" .. math.random(1000, 9999),
            type = "HARVESTER",
            size = "MEDIUM",
            position = {q = 20, r = 25},
            speed = 4,
            hp = 150,
            maxHp = 150,
            detected = true,
            mission = "HARVEST",
            behavior = "EVASIVE"
        },
        BATTLESHIP = {
            id = "ufo_" .. math.random(1000, 9999),
            type = "BATTLESHIP",
            size = "LARGE",
            position = {q = 35, r = 40},
            speed = 3,
            hp = 500,
            maxHp = 500,
            detected = false,
            mission = "TERROR",
            behavior = "AGGRESSIVE"
        }
    }
    
    return ufos[ufoType] or ufos.SCOUT
end

-- Generate a craft
function MockGeoscape.getCraft(craftType)
    craftType = craftType or "INTERCEPTOR"
    
    local crafts = {
        INTERCEPTOR = {
            id = "craft_" .. math.random(1000, 9999),
            type = "INTERCEPTOR",
            name = "Raven-1",
            position = {q = 15, r = 20},
            baseId = "base_main",
            speed = 6,
            hp = 100,
            maxHp = 100,
            fuel = 100,
            maxFuel = 100,
            weapons = {"CANNON", "STINGRAY"},
            status = "HANGAR",
            mission = nil
        },
        SKYRANGER = {
            id = "craft_" .. math.random(1000, 9999),
            type = "SKYRANGER",
            name = "Skyranger-1",
            position = {q = 15, r = 20},
            baseId = "base_main",
            speed = 5,
            hp = 150,
            maxHp = 150,
            fuel = 100,
            maxFuel = 100,
            weapons = {},
            status = "HANGAR",
            mission = nil,
            cargo = {soldiers = 0, maxSoldiers = 8}
        },
        FIRESTORM = {
            id = "craft_" .. math.random(1000, 9999),
            type = "FIRESTORM",
            name = "Firestorm-1",
            position = {q = 15, r = 20},
            baseId = "base_main",
            speed = 10,
            hp = 250,
            maxHp = 250,
            fuel = 100,
            maxFuel = 100,
            weapons = {"PLASMA_CANNON", "EMP"},
            status = "HANGAR",
            mission = nil
        }
    }
    
    return crafts[craftType] or crafts.INTERCEPTOR
end

-- Generate a site mission
function MockGeoscape.getSiteMission()
    return {
        id = "mission_" .. math.random(1000, 9999),
        type = "SITE",
        name = "Alien Abduction",
        location = {q = 25, r = 30},
        country = "USA",
        detected = true,
        expiresIn = 24,
        difficulty = 3,
        reward = {
            funds = 50000,
            corpses = 5,
            fragments = 10
        },
        enemies = {
            {type = "SECTOID", count = 8},
            {type = "FLOATER", count = 4}
        }
    }
end

-- Generate a UFO crash/landing mission
function MockGeoscape.getUFOMission(isLanding)
    isLanding = isLanding or false
    
    return {
        id = "mission_" .. math.random(1000, 9999),
        type = isLanding and "UFO_LANDING" or "UFO_CRASH",
        name = isLanding and "UFO Landing Site" or "UFO Crash Site",
        location = {q = 30, r = 35},
        country = "Germany",
        detected = true,
        expiresIn = isLanding and 12 or 48,
        difficulty = 5,
        ufoType = "SCOUT",
        reward = {
            funds = 100000,
            ufoComponents = 1,
            corpses = 4,
            alloys = 15
        },
        enemies = {
            {type = "SECTOID", count = 6},
            {type = "THIN_MAN", count = 2}
        }
    }
end

-- Generate a terror mission
function MockGeoscape.getTerrorMission()
    return {
        id = "mission_" .. math.random(1000, 9999),
        type = "TERROR",
        name = "Terror Site",
        location = {q = 40, r = 25},
        country = "UK",
        city = "London",
        detected = true,
        expiresIn = 8,
        difficulty = 7,
        civilians = 18,
        reward = {
            funds = 150000,
            panicReduction = 5
        },
        enemies = {
            {type = "CHRYSSALID", count = 12},
            {type = "MUTON", count = 6}
        }
    }
end

-- Get all mission types
function MockGeoscape.getAllMissions()
    return {
        MockGeoscape.getSiteMission(),
        MockGeoscape.getUFOMission(false),
        MockGeoscape.getUFOMission(true),
        MockGeoscape.getTerrorMission()
    }
end

return MockGeoscape



