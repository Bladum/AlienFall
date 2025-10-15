---Facility Type Definitions - Base Building Blueprints
---
---Defines all available facility types for base construction in the Basescape layer.
---Each facility provides capacities (storage, accommodations, research, manufacturing),
---services (radar, medical, training), and defensive capabilities. Facilities can be
---built, upgraded, damaged, and destroyed.
---
---Facility Categories:
---  - Mandatory: Headquarters (always present, cannot be destroyed)
---  - Storage: Living Quarters, Stores, Hangar
---  - Research: Laboratory (unlocks alien technology)
---  - Manufacturing: Workshop (produces equipment)
---  - Defense: Radar System, Defense Turret, Missile Battery
---  - Utilities: Power Generator, Medical Bay, Training Room
---
---Facility Properties:
---  - buildTime: Days to construct
---  - cost: Credits and resources required
---  - maxHealth: Hit points before destruction
---  - armor: Damage reduction
---  - capacities: Storage/personnel limits
---  - services: Radar range, healing, training bonuses
---
---Key Exports:
---  - FacilityTypes.headquarters: Mandatory command center
---  - FacilityTypes.livingQuarters: Personnel capacity +50
---  - FacilityTypes.laboratory: Research capacity +50
---  - FacilityTypes.workshop: Manufacturing capacity +50
---  - FacilityTypes.hangar: Craft storage +2
---  - FacilityTypes.radarSystem: Radar range 1000km
---  - FacilityTypes[facilityId]: Access any facility type
---
---Dependencies:
---  - basescape.facilities.facility_system: Facility management
---
---@module basescape.facilities.facility_types
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FacilityTypes = require("basescape.facilities.facility_types")
---  local lab = FacilityTypes.laboratory
---  print(lab.name)  -- "Laboratory"
---  print(lab.capacities.research)  -- 50
---
---@see basescape.facilities.facility_system For facility management

local FacilityTypes = {}

--- Headquarters (mandatory, always present)
FacilityTypes.headquarters = {
    id = "headquarters",
    name = "Headquarters",
    description = "Command center for base operations",
    buildTime = 0, -- Instant (mandatory)
    cost = {credits = 0},
    maxHealth = 200,
    armor = 20,
    capacities = {
        units = 10,
        items = 100,
        crafts = 1
    },
    services = {
        provides = {"power", "command"},
        requires = {}
    },
    maintenance = 10000
}

--- Living Quarters
FacilityTypes.living_quarters = {
    id = "living_quarters",
    name = "Living Quarters",
    description = "Housing for personnel",
    buildTime = 14,
    cost = {credits = 100000},
    maxHealth = 100,
    armor = 5,
    capacities = {
        units = 20
    },
    services = {
        provides = {},
        requires = {"power"}
    },
    maintenance = 5000
}

--- Storage Warehouse
FacilityTypes.storage = {
    id = "storage",
    name = "Storage Warehouse",
    description = "Storage for items and equipment",
    buildTime = 10,
    cost = {credits = 75000},
    maxHealth = 80,
    armor = 3,
    capacities = {
        items = 200
    },
    services = {
        provides = {},
        requires = {}
    },
    maintenance = 2000
}

--- Hangar
FacilityTypes.hangar = {
    id = "hangar",
    name = "Hangar",
    description = "Storage and maintenance for aircraft",
    buildTime = 21,
    cost = {credits = 200000},
    maxHealth = 150,
    armor = 10,
    capacities = {
        crafts = 2,
        craftRepair = 1
    },
    services = {
        provides = {},
        requires = {"power", "fuel"}
    },
    maintenance = 15000
}

--- Laboratory
FacilityTypes.laboratory = {
    id = "laboratory",
    name = "Laboratory",
    description = "Research facility for scientists",
    buildTime = 21,
    cost = {credits = 150000},
    maxHealth = 100,
    armor = 5,
    capacities = {
        researchProjects = 2,
        units = 10 -- Scientists
    },
    services = {
        provides = {},
        requires = {"power"}
    },
    maintenance = 10000
}

--- Workshop
FacilityTypes.workshop = {
    id = "workshop",
    name = "Workshop",
    description = "Manufacturing facility for engineers",
    buildTime = 21,
    cost = {credits = 150000},
    maxHealth = 100,
    armor = 5,
    capacities = {
        manufacturingProjects = 2,
        units = 10 -- Engineers
    },
    services = {
        provides = {},
        requires = {"power"}
    },
    maintenance = 10000
}

--- Power Plant
FacilityTypes.power_plant = {
    id = "power_plant",
    name = "Power Plant",
    description = "Provides power to base facilities",
    buildTime = 14,
    cost = {credits = 120000},
    maxHealth = 120,
    armor = 8,
    capacities = {},
    services = {
        provides = {"power"},
        requires = {}
    },
    maintenance = 8000
}

--- Radar System
FacilityTypes.radar = {
    id = "radar",
    name = "Radar System",
    description = "Detects alien activity in nearby provinces",
    buildTime = 14,
    cost = {credits = 100000},
    maxHealth = 80,
    armor = 3,
    capacities = {
        radarRange = 5 -- Provinces
    },
    services = {
        provides = {},
        requires = {"power"}
    },
    maintenance = 7000
}

--- Defense System
FacilityTypes.defense = {
    id = "defense",
    name = "Defense System",
    description = "Provides defensive capabilities during base defense missions",
    buildTime = 18,
    cost = {credits = 180000},
    maxHealth = 150,
    armor = 15,
    capacities = {
        defense = 50 -- Defense power
    },
    services = {
        provides = {},
        requires = {"power"}
    },
    maintenance = 12000
}

--- Medical Bay
FacilityTypes.medical_bay = {
    id = "medical_bay",
    name = "Medical Bay",
    description = "Accelerates unit healing and wound recovery",
    buildTime = 14,
    cost = {credits = 130000},
    maxHealth = 100,
    armor = 5,
    capacities = {
        healing = 10, -- Healing rate bonus
        units = 5 -- Medical staff
    },
    services = {
        provides = {},
        requires = {"power"}
    },
    maintenance = 9000
}

--- Psi Lab
FacilityTypes.psi_lab = {
    id = "psi_lab",
    name = "Psi Lab",
    description = "Train soldiers in psionic abilities",
    buildTime = 28,
    cost = {credits = 250000},
    maxHealth = 100,
    armor = 8,
    capacities = {
        training = 10, -- Training slots
        units = 5 -- Instructors
    },
    services = {
        provides = {},
        requires = {"power"}
    },
    maintenance = 15000,
    requiredResearch = {"psionics_basics"}
}

--- Prison
FacilityTypes.prison = {
    id = "prison",
    name = "Alien Containment",
    description = "Hold alien prisoners for interrogation",
    buildTime = 21,
    cost = {credits = 200000},
    maxHealth = 150,
    armor = 20,
    capacities = {
        prisoners = 10
    },
    services = {
        provides = {},
        requires = {"power"}
    },
    maintenance = 10000
}

--- Get facility type definition
-- @param typeId string Facility type ID
-- @return table|nil Facility type definition
function FacilityTypes.get(typeId)
    return FacilityTypes[typeId]
end

--- Get all facility types
-- @return table Table of all facility types
function FacilityTypes.getAll()
    local types = {}
    for key, value in pairs(FacilityTypes) do
        if type(value) == "table" and value.id then
            types[key] = value
        end
    end
    return types
end

return FacilityTypes






















