---Facility Registry - Facility Type Management
---
---Central registry for facility type definitions. Manages loading, retrieval,
---and registration of facility types from data files.
---
---@module basescape.logic.facility_registry
---@author AlienFall Development Team

local FacilityType = require("basescape.logic.facility_type")

local FacilityRegistry = {}
FacilityRegistry.types = {}

---Register a facility type
---@param config table Facility type configuration
---@return FacilityType type Registered type
function FacilityRegistry.register(config)
    local facilityType = FacilityType.new(config)
    FacilityRegistry.types[config.id] = facilityType
    print(string.format("[FacilityRegistry] Registered: %s", config.id))
    return facilityType
end

---Get facility type by ID
---@param id string Facility type ID
---@return FacilityType|nil type Facility type or nil
function FacilityRegistry.get(id)
    return FacilityRegistry.types[id]
end

---Get all facility type IDs
---@return table ids Array of IDs
function FacilityRegistry.getAllIds()
    local result = {}
    for id, _ in pairs(FacilityRegistry.types) do
        table.insert(result, id)
    end
    table.sort(result)
    return result
end

---Check if facility type exists
---@param id string Facility type ID
---@return boolean exists True if exists
function FacilityRegistry.exists(id)
    return FacilityRegistry.types[id] ~= nil
end

---Get facility count
---@return number count Total registered types
function FacilityRegistry.getCount()
    local count = 0
    for _ in pairs(FacilityRegistry.types) do
        count = count + 1
    end
    return count
end

---Load facility types from data
function FacilityRegistry.loadDefaults()
    -- HQ (Mandatory, always at center)
    FacilityRegistry.register({
        id = "hq",
        name = "Command Center (HQ)",
        description = "Command center. Always at grid center (2,2). Cannot be destroyed.",
        buildTime = 0,  -- Cannot be built
        buildCost = {credits = 0},
        requiredTech = {},
        requiredFacilities = {},
        size = {width = 1, height = 1},
        capacities = {
            item_storage = 100,
            unit_quarters = 10,
            research_capacity = 2,
            manufacturing_capacity = 1,
            defense_capacity = 50,
            healing_throughput = 5,
        },
        servicesProvided = {"command"},
        servicesRequired = {},
        maintenanceCost = 0,
        health = 200,
        armor = 20,
        maxPerBase = 1,
        category = "command",
    })
    
    -- Living Quarters
    FacilityRegistry.register({
        id = "living_quarters",
        name = "Living Quarters",
        description = "Housing for personnel. Provides unit quarters capacity.",
        buildTime = 14,
        buildCost = {credits = 100000},
        requiredTech = {},
        requiredFacilities = {},
        size = {width = 1, height = 1},
        capacities = {
            unit_quarters = 25,
            item_storage = 20,
        },
        servicesProvided = {},
        servicesRequired = {"power"},
        maintenanceCost = 5000,
        health = 100,
        armor = 5,
        category = "personnel",
    })
    
    -- Power Generator
    FacilityRegistry.register({
        id = "power_generator",
        name = "Power Generator",
        description = "Generates power for all facilities. Required by most buildings.",
        buildTime = 21,
        buildCost = {credits = 150000},
        requiredTech = {},
        requiredFacilities = {},
        size = {width = 1, height = 1},
        capacities = {},
        servicesProvided = {"power"},
        servicesRequired = {},
        maintenanceCost = 10000,
        health = 80,
        armor = 3,
        category = "power",
    })
    
    -- Laboratory
    FacilityRegistry.register({
        id = "laboratory",
        name = "Laboratory",
        description = "Advanced research facility. Provides research capacity.",
        buildTime = 28,
        buildCost = {credits = 200000},
        requiredTech = {},
        requiredFacilities = {"power_generator"},
        size = {width = 1, height = 1},
        capacities = {
            research_capacity = 3,
            item_storage = 50,
        },
        servicesProvided = {"laboratory", "power_research"},
        servicesRequired = {"power"},
        maintenanceCost = 15000,
        health = 90,
        armor = 5,
        category = "research",
    })
    
    -- Manufacturing Workshop
    FacilityRegistry.register({
        id = "workshop",
        name = "Manufacturing Workshop",
        description = "Equipment production facility. Provides manufacturing capacity.",
        buildTime = 35,
        buildCost = {credits = 250000},
        requiredTech = {},
        requiredFacilities = {"power_generator"},
        size = {width = 2, height = 2},
        capacities = {
            manufacturing_capacity = 4,
            item_storage = 100,
        },
        servicesProvided = {"manufacturing", "workshop"},
        servicesRequired = {"power"},
        maintenanceCost = 20000,
        health = 120,
        armor = 8,
        category = "manufacturing",
    })
    
    -- Hangar (Craft storage)
    FacilityRegistry.register({
        id = "hangar",
        name = "Aircraft Hangar",
        description = "Stores and maintains aircraft. Provides craft storage.",
        buildTime = 42,
        buildCost = {credits = 300000},
        requiredTech = {},
        requiredFacilities = {"power_generator"},
        size = {width = 2, height = 2},
        capacities = {
            craft_hangars = 4,
            craft_repair_throughput = 2,
        },
        servicesProvided = {"hangars", "craft_repair"},
        servicesRequired = {"power"},
        maintenanceCost = 25000,
        health = 150,
        armor = 10,
        category = "hangars",
    })
    
    -- Medical Bay
    FacilityRegistry.register({
        id = "medical_bay",
        name = "Medical Bay",
        description = "Heals wounded personnel. Provides healing capacity.",
        buildTime = 21,
        buildCost = {credits = 120000},
        requiredTech = {},
        requiredFacilities = {"power_generator"},
        size = {width = 1, height = 1},
        capacities = {
            healing_throughput = 10,
            sanity_recovery_throughput = 5,
        },
        servicesProvided = {"medical", "healing"},
        servicesRequired = {"power"},
        maintenanceCost = 8000,
        health = 100,
        armor = 5,
        category = "medical",
    })
    
    -- Containment Cell (Prisoner storage)
    FacilityRegistry.register({
        id = "containment",
        name = "Alien Containment",
        description = "Stores captured alien prisoners. Provides prisoner capacity.",
        buildTime = 28,
        buildCost = {credits = 180000},
        requiredTech = {},
        requiredFacilities = {"power_generator"},
        size = {width = 1, height = 1},
        capacities = {
            prisoner_capacity = 15,
        },
        servicesProvided = {"containment"},
        servicesRequired = {"power"},
        maintenanceCost = 12000,
        health = 110,
        armor = 8,
        category = "containment",
    })
    
    -- Storage Depot (Item storage)
    FacilityRegistry.register({
        id = "storage_depot",
        name = "Storage Depot",
        description = "General warehouse for equipment and items.",
        buildTime = 14,
        buildCost = {credits = 80000},
        requiredTech = {},
        requiredFacilities = {},
        size = {width = 2, height = 1},
        capacities = {
            item_storage = 200,
        },
        servicesProvided = {"storage"},
        servicesRequired = {},
        maintenanceCost = 3000,
        health = 80,
        armor = 3,
        category = "storage",
    })
    
    -- Radar Installation
    FacilityRegistry.register({
        id = "radar",
        name = "Radar Installation",
        description = "Detects UFOs and enemy movement. Provides radar range.",
        buildTime = 28,
        buildCost = {credits = 200000},
        requiredTech = {},
        requiredFacilities = {"power_generator"},
        size = {width = 1, height = 1},
        capacities = {
            radar_range = 500,  -- km radius
        },
        servicesProvided = {"radar"},
        servicesRequired = {"power"},
        maintenanceCost = 10000,
        health = 90,
        armor = 5,
        category = "radar",
    })
    
    -- Defense Tower
    FacilityRegistry.register({
        id = "defense_tower",
        name = "Defense Tower",
        description = "Armed tower for base defense. Provides defense capacity.",
        buildTime = 35,
        buildCost = {credits = 220000},
        requiredTech = {},
        requiredFacilities = {"power_generator"},
        size = {width = 1, height = 1},
        capacities = {
            defense_capacity = 100,
        },
        servicesProvided = {"defense"},
        servicesRequired = {"power"},
        maintenanceCost = 15000,
        health = 120,
        armor = 15,
        defenseUnits = {"defense_drone"},  -- Units that spawn in base defense
        category = "defense",
    })
    
    print(string.format("[FacilityRegistry] Loaded %d default facility types", 
        FacilityRegistry.getCount()))
end

return FacilityRegistry



