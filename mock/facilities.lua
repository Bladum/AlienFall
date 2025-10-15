-- Mock Facility Data Generator
-- Provides test data for base management and facility tests

local MockFacilities = {}

-- Get a base configuration
function MockFacilities.getBase(baseName)
    baseName = baseName or "Main Base"
    
    return {
        id = "base_" .. math.random(1000, 9999),
        name = baseName,
        location = {q = 10, r = 15},
        funds = 1000000,
        
        -- Grid
        gridWidth = 6,
        gridHeight = 6,
        
        -- Facilities (empty grid)
        facilities = {},
        
        -- Construction queue
        constructionQueue = {},
        
        -- Capacities
        capacity = {
            soldiers = 0,
            scientists = 0,
            engineers = 0,
            storage = 0,
            power = 0,
            hangars = 0
        },
        
        -- Usage
        usage = {
            soldiers = 0,
            scientists = 0,
            engineers = 0,
            storage = 0,
            power = 0,
            hangars = 0
        },
        
        -- Personnel
        soldiers = {},
        scientists = 20,
        engineers = 10,
        
        -- Vehicles
        crafts = {},
        
        -- Monthly costs
        monthlyMaintenance = 0
    }
end

-- Get a facility by type
function MockFacilities.getFacility(facilityType, x, y)
    facilityType = facilityType or "LIVING_QUARTERS"
    x = x or 2
    y = y or 2
    
    local facilities = {
        ACCESS_LIFT = {
            id = "facility_" .. math.random(1000, 9999),
            typeId = "ACCESS_LIFT",
            name = "Access Lift",
            x = x,
            y = y,
            construction = {
                complete = true,
                daysRemaining = 0
            },
            hp = 100,
            maxHp = 100,
            operational = true,
            buildCost = 0,
            buildTime = 0,
            maintenance = 0
        },
        LIVING_QUARTERS = {
            id = "facility_" .. math.random(1000, 9999),
            typeId = "LIVING_QUARTERS",
            name = "Living Quarters",
            x = x,
            y = y,
            construction = {
                complete = true,
                daysRemaining = 0
            },
            hp = 100,
            maxHp = 100,
            operational = true,
            buildCost = 100000,
            buildTime = 14,
            maintenance = 10000,
            capacity = {soldiers = 25}
        },
        LABORATORY = {
            id = "facility_" .. math.random(1000, 9999),
            typeId = "LABORATORY",
            name = "Laboratory",
            x = x,
            y = y,
            construction = {
                complete = true,
                daysRemaining = 0
            },
            hp = 100,
            maxHp = 100,
            operational = true,
            buildCost = 150000,
            buildTime = 20,
            maintenance = 15000,
            capacity = {scientists = 50}
        },
        WORKSHOP = {
            id = "facility_" .. math.random(1000, 9999),
            typeId = "WORKSHOP",
            name = "Workshop",
            x = x,
            y = y,
            construction = {
                complete = true,
                daysRemaining = 0
            },
            hp = 100,
            maxHp = 100,
            operational = true,
            buildCost = 120000,
            buildTime = 18,
            maintenance = 12000,
            capacity = {engineers = 50}
        },
        HANGAR = {
            id = "facility_" .. math.random(1000, 9999),
            typeId = "HANGAR",
            name = "Hangar",
            x = x,
            y = y,
            construction = {
                complete = true,
                daysRemaining = 0
            },
            hp = 100,
            maxHp = 100,
            operational = true,
            buildCost = 200000,
            buildTime = 25,
            maintenance = 20000,
            capacity = {hangars = 1}
        },
        POWER_GENERATOR = {
            id = "facility_" .. math.random(1000, 9999),
            typeId = "POWER_GENERATOR",
            name = "Power Generator",
            x = x,
            y = y,
            construction = {
                complete = true,
                daysRemaining = 0
            },
            hp = 100,
            maxHp = 100,
            operational = true,
            buildCost = 180000,
            buildTime = 22,
            maintenance = 18000,
            capacity = {power = 100}
        },
        STORAGE = {
            id = "facility_" .. math.random(1000, 9999),
            typeId = "STORAGE",
            name = "General Stores",
            x = x,
            y = y,
            construction = {
                complete = true,
                daysRemaining = 0
            },
            hp = 100,
            maxHp = 100,
            operational = true,
            buildCost = 80000,
            buildTime = 12,
            maintenance = 8000,
            capacity = {storage = 50}
        }
    }
    
    return facilities[facilityType] or facilities.LIVING_QUARTERS
end

-- Get an under-construction facility
function MockFacilities.getConstructionOrder(facilityType, x, y, daysRemaining)
    facilityType = facilityType or "LABORATORY"
    x = x or 3
    y = y or 3
    daysRemaining = daysRemaining or 15
    
    return {
        id = "construction_" .. math.random(1000, 9999),
        typeId = facilityType,
        x = x,
        y = y,
        daysRemaining = daysRemaining,
        totalDays = 20,
        cost = 150000
    }
end

-- Generate a starter base with basic facilities
function MockFacilities.getStarterBase()
    local base = MockFacilities.getBase("Starter Base")
    
    -- Add Access Lift (HQ)
    table.insert(base.facilities, MockFacilities.getFacility("ACCESS_LIFT", 2, 2))
    
    -- Add Living Quarters
    table.insert(base.facilities, MockFacilities.getFacility("LIVING_QUARTERS", 1, 2))
    table.insert(base.facilities, MockFacilities.getFacility("LIVING_QUARTERS", 3, 2))
    
    -- Add Storage
    table.insert(base.facilities, MockFacilities.getFacility("STORAGE", 2, 1))
    
    -- Add Power
    table.insert(base.facilities, MockFacilities.getFacility("POWER_GENERATOR", 2, 3))
    
    -- Calculate capacities
    base.capacity = {
        soldiers = 50,
        scientists = 0,
        engineers = 0,
        storage = 50,
        power = 100,
        hangars = 0
    }
    
    base.monthlyMaintenance = 38000
    
    return base
end

-- Generate a full base with all facility types
function MockFacilities.getFullBase()
    local base = MockFacilities.getStarterBase()
    base.name = "Full Base"
    
    -- Add research facilities
    table.insert(base.facilities, MockFacilities.getFacility("LABORATORY", 1, 1))
    table.insert(base.facilities, MockFacilities.getFacility("LABORATORY", 3, 1))
    
    -- Add engineering facilities
    table.insert(base.facilities, MockFacilities.getFacility("WORKSHOP", 1, 3))
    table.insert(base.facilities, MockFacilities.getFacility("WORKSHOP", 3, 3))
    
    -- Add hangars
    table.insert(base.facilities, MockFacilities.getFacility("HANGAR", 0, 0))
    table.insert(base.facilities, MockFacilities.getFacility("HANGAR", 4, 0))
    
    -- Update capacities
    base.capacity = {
        soldiers = 50,
        scientists = 100,
        engineers = 100,
        storage = 50,
        power = 100,
        hangars = 2
    }
    
    base.monthlyMaintenance = 142000
    
    return base
end

-- Get a damaged facility
function MockFacilities.getDamagedFacility(facilityType, damagePercent)
    facilityType = facilityType or "LABORATORY"
    damagePercent = damagePercent or 50
    
    local facility = MockFacilities.getFacility(facilityType)
    facility.hp = math.floor(facility.maxHp * (100 - damagePercent) / 100)
    
    if facility.hp < facility.maxHp * 0.5 then
        facility.operational = false
    end
    
    return facility
end

return MockFacilities
