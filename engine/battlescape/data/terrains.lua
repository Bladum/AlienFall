---Terrains - Terrain System for Map Generation
---
---Defines terrain types with MapBlock associations and MapScript references. Each
---terrain specifies which MapBlocks can be used and which MapScripts are compatible.
---Links biomes (geoscape) to map generation (battlescape).
---
---Features:
---  - Terrain type definitions
---  - MapBlock tag filtering
---  - MapScript selection weights
---  - Difficulty ranges
---  - Biome-to-terrain mapping
---
---Terrain Properties:
---  - id: Unique identifier (e.g., "urban_residential")
---  - name: Display name (e.g., "Urban Residential")
---  - description: Lore/flavor text
---  - mapBlockTags: Array of tags for block filtering
---  - mapScripts: Array of {id, weight} for script selection
---  - difficulty: {min, max} difficulty range (1-10)
---
---MapBlock Tag System:
---  - Tags filter which blocks are valid for terrain
---  - Example: "urban", "industrial", "park", "building"
---  - Multiple tags = AND logic (block must have all)
---
---MapScript Weights:
---  - Higher weight = more likely to be selected
---  - Typical range: 1-10
---  - Weight 0 = disabled
---
---Key Exports:
---  - Terrains.register(terrain): Adds terrain to registry
---  - Terrains.get(id): Returns terrain definition
---  - Terrains.getAll(): Returns all terrains
---  - Terrains.getMapBlocks(terrainId): Returns valid MapBlocks
---  - Terrains.selectMapScript(terrainId): Returns random MapScript
---
---Dependencies:
---  - None (pure data registry)
---
---@module battlescape.data.terrains
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Terrains = require("battlescape.data.terrains")
---  local terrain = Terrains.get("urban_residential")
---  local blocks = Terrains.getMapBlocks("urban_residential")
---
---@see battlescape.data.mapscripts For MapScript system
---@see battlescape.maps.mapblock_system For MapBlock system

-- Terrain System for Map Generation
-- Defines terrain types with MapBlock associations and MapScript references

local Terrains = {}

---@class Terrain
---@field id string Unique terrain identifier
---@field name string Display name
---@field description string Terrain description
---@field mapBlockTags table Array of tags for MapBlock filtering
---@field mapScripts table Array of {id, weight} for MapScript selection
---@field difficulty table Min/max difficulty range {min, max}

-- Terrain registry
Terrains.registry = {}

---Register a terrain
---@param terrain Terrain Terrain definition
function Terrains.register(terrain)
    if not terrain.id then
        error("Terrain must have an id")
    end
    
    Terrains.registry[terrain.id] = terrain
    print(string.format("[Terrains] Registered terrain: %s (%s)", terrain.id, terrain.name))
end

---Get terrain by ID
---@param terrainId string Terrain ID
---@return Terrain? Terrain definition or nil
function Terrains.get(terrainId)
    return Terrains.registry[terrainId]
end

---Get all terrain IDs
---@return table Array of terrain IDs
function Terrains.getAllIds()
    local ids = {}
    for id, _ in pairs(Terrains.registry) do
        table.insert(ids, id)
    end
    return ids
end

-- Define standard terrains

-- Forest terrains
Terrains.register({
    id = "dense_forest",
    name = "Dense Forest",
    description = "Heavy tree coverage with limited visibility",
    mapBlockTags = {"forest", "trees", "dense", "natural"},
    mapScripts = {
        {id = "forest_clearing", weight = 30},
        {id = "forest_random", weight = 40},
        {id = "forest_path", weight = 20},
        {id = "forest_river", weight = 10}
    },
    difficulty = {min = 1, max = 5}
})

Terrains.register({
    id = "light_forest",
    name = "Light Forest",
    description = "Scattered trees with open areas",
    mapBlockTags = {"forest", "trees", "sparse", "natural"},
    mapScripts = {
        {id = "forest_clearing", weight = 40},
        {id = "forest_random", weight = 30},
        {id = "forest_path", weight = 20},
        {id = "grassland_mix", weight = 10}
    },
    difficulty = {min = 1, max = 4}
})

-- Urban terrains
Terrains.register({
    id = "urban_street",
    name = "Urban Street",
    description = "City streets with buildings and roads",
    mapBlockTags = {"urban", "street", "buildings", "paved"},
    mapScripts = {
        {id = "urban_crossroads", weight = 30},
        {id = "urban_grid", weight = 40},
        {id = "urban_plaza", weight = 20},
        {id = "urban_random", weight = 10}
    },
    difficulty = {min = 2, max = 5}
})

Terrains.register({
    id = "urban_industrial",
    name = "Urban Industrial",
    description = "Industrial district with factories and warehouses",
    mapBlockTags = {"urban", "industrial", "warehouse", "factory"},
    mapScripts = {
        {id = "industrial_complex", weight = 40},
        {id = "warehouse_rows", weight = 30},
        {id = "industrial_random", weight = 30}
    },
    difficulty = {min = 2, max = 6}
})

Terrains.register({
    id = "urban_residential",
    name = "Urban Residential",
    description = "Residential neighborhood with houses",
    mapBlockTags = {"urban", "residential", "houses", "neighborhood"},
    mapScripts = {
        {id = "suburban_grid", weight = 40},
        {id = "residential_random", weight = 60}
    },
    difficulty = {min = 1, max = 4}
})

Terrains.register({
    id = "urban_commercial",
    name = "Urban Commercial",
    description = "Commercial district with shops and offices",
    mapBlockTags = {"urban", "commercial", "shops", "offices"},
    mapScripts = {
        {id = "commercial_strip", weight = 40},
        {id = "urban_crossroads", weight = 30},
        {id = "urban_random", weight = 30}
    },
    difficulty = {min = 2, max = 5}
})

-- Plains terrains
Terrains.register({
    id = "grassland",
    name = "Grassland",
    description = "Open grass fields with minimal cover",
    mapBlockTags = {"plains", "grass", "open", "natural"},
    mapScripts = {
        {id = "plains_random", weight = 60},
        {id = "plains_features", weight = 40}
    },
    difficulty = {min = 1, max = 3}
})

Terrains.register({
    id = "farmland",
    name = "Farmland",
    description = "Agricultural fields with crops and fences",
    mapBlockTags = {"plains", "farm", "crops", "rural"},
    mapScripts = {
        {id = "farmland_grid", weight = 50},
        {id = "farmland_random", weight = 50}
    },
    difficulty = {min = 1, max = 4}
})

Terrains.register({
    id = "dirt_road",
    name = "Dirt Road",
    description = "Unpaved roads through countryside",
    mapBlockTags = {"plains", "road", "path", "rural"},
    mapScripts = {
        {id = "dirt_road_cross", weight = 30},
        {id = "dirt_road_straight", weight = 40},
        {id = "plains_random", weight = 30}
    },
    difficulty = {min = 1, max = 3}
})

-- Desert terrains
Terrains.register({
    id = "sand",
    name = "Sand",
    description = "Sandy desert with dunes",
    mapBlockTags = {"desert", "sand", "dunes", "arid"},
    mapScripts = {
        {id = "desert_dunes", weight = 60},
        {id = "desert_random", weight = 40}
    },
    difficulty = {min = 1, max = 4}
})

Terrains.register({
    id = "rocky_desert",
    name = "Rocky Desert",
    description = "Desert with rocky outcrops",
    mapBlockTags = {"desert", "rock", "outcrop", "arid"},
    mapScripts = {
        {id = "desert_rocks", weight = 50},
        {id = "desert_random", weight = 50}
    },
    difficulty = {min = 2, max = 5}
})

Terrains.register({
    id = "oasis",
    name = "Oasis",
    description = "Water source in desert",
    mapBlockTags = {"desert", "water", "oasis", "vegetation"},
    mapScripts = {
        {id = "desert_oasis", weight = 100}
    },
    difficulty = {min = 2, max = 4}
})

-- Mountain terrains
Terrains.register({
    id = "rocky_mountain",
    name = "Rocky Mountain",
    description = "Mountainous terrain with cliffs and rocks",
    mapBlockTags = {"mountain", "rock", "cliff", "natural"},
    mapScripts = {
        {id = "mountain_pass", weight = 40},
        {id = "mountain_random", weight = 60}
    },
    difficulty = {min = 2, max = 6}
})

Terrains.register({
    id = "mountain_path",
    name = "Mountain Path",
    description = "Winding paths through mountains",
    mapBlockTags = {"mountain", "path", "trail", "natural"},
    mapScripts = {
        {id = "mountain_trail", weight = 60},
        {id = "mountain_pass", weight = 40}
    },
    difficulty = {min = 2, max = 5}
})

-- Arctic terrains
Terrains.register({
    id = "snow",
    name = "Snow",
    description = "Snow-covered terrain",
    mapBlockTags = {"arctic", "snow", "cold", "frozen"},
    mapScripts = {
        {id = "arctic_random", weight = 100}
    },
    difficulty = {min = 2, max = 5}
})

Terrains.register({
    id = "ice",
    name = "Ice",
    description = "Frozen ice sheets",
    mapBlockTags = {"arctic", "ice", "frozen", "slippery"},
    mapScripts = {
        {id = "arctic_ice", weight = 100}
    },
    difficulty = {min = 3, max = 6}
})

Terrains.register({
    id = "arctic_rock",
    name = "Arctic Rock",
    description = "Rocky terrain in arctic environment",
    mapBlockTags = {"arctic", "rock", "cold", "natural"},
    mapScripts = {
        {id = "arctic_rocks", weight = 100}
    },
    difficulty = {min = 2, max = 5}
})

-- Coastal terrains
Terrains.register({
    id = "beach",
    name = "Beach",
    description = "Sandy shoreline",
    mapBlockTags = {"coastal", "sand", "beach", "shore"},
    mapScripts = {
        {id = "beach_random", weight = 100}
    },
    difficulty = {min = 1, max = 3}
})

Terrains.register({
    id = "water",
    name = "Water",
    description = "Shallow water areas",
    mapBlockTags = {"water", "shallow", "aquatic"},
    mapScripts = {
        {id = "water_random", weight = 100}
    },
    difficulty = {min = 2, max = 4}
})

Terrains.register({
    id = "coastal_urban",
    name = "Coastal Urban",
    description = "Coastal city with docks",
    mapBlockTags = {"coastal", "urban", "dock", "port"},
    mapScripts = {
        {id = "dock_district", weight = 60},
        {id = "coastal_city", weight = 40}
    },
    difficulty = {min = 2, max = 5}
})

-- Industrial terrains
Terrains.register({
    id = "industrial_complex",
    name = "Industrial Complex",
    description = "Large factory complex",
    mapBlockTags = {"industrial", "factory", "complex", "large"},
    mapScripts = {
        {id = "factory_complex", weight = 100}
    },
    difficulty = {min = 3, max = 6}
})

Terrains.register({
    id = "warehouse_district",
    name = "Warehouse District",
    description = "Area with warehouses and storage",
    mapBlockTags = {"industrial", "warehouse", "storage"},
    mapScripts = {
        {id = "warehouse_rows", weight = 100}
    },
    difficulty = {min = 2, max = 5}
})

Terrains.register({
    id = "rail_yard",
    name = "Rail Yard",
    description = "Railway depot and tracks",
    mapBlockTags = {"industrial", "rail", "tracks", "depot"},
    mapScripts = {
        {id = "rail_yard", weight = 100}
    },
    difficulty = {min = 2, max = 5}
})

-- Rural terrains
Terrains.register({
    id = "rural_village",
    name = "Rural Village",
    description = "Small village with houses",
    mapBlockTags = {"rural", "village", "houses", "settlement"},
    mapScripts = {
        {id = "village_random", weight = 100}
    },
    difficulty = {min = 1, max = 4}
})

-- Special terrains for missions
Terrains.register({
    id = "ufo_crash",
    name = "UFO Crash Site",
    description = "Crashed UFO with debris",
    mapBlockTags = {"ufo", "crash", "debris", "alien"},
    mapScripts = {
        {id = "ufo_small_crash", weight = 40},
        {id = "ufo_medium_crash", weight = 40},
        {id = "ufo_large_crash", weight = 20}
    },
    difficulty = {min = 3, max = 7}
})

Terrains.register({
    id = "ufo_landing",
    name = "UFO Landing",
    description = "Intact landed UFO",
    mapBlockTags = {"ufo", "landing", "intact", "alien"},
    mapScripts = {
        {id = "ufo_small_landing", weight = 40},
        {id = "ufo_medium_landing", weight = 40},
        {id = "ufo_large_landing", weight = 20}
    },
    difficulty = {min = 4, max = 8}
})

Terrains.register({
    id = "xcom_base",
    name = "XCOM Base",
    description = "XCOM facility interior",
    mapBlockTags = {"xcom", "base", "facility", "interior"},
    mapScripts = {
        {id = "xcom_base_defense", weight = 100}
    },
    difficulty = {min = 5, max = 9}
})

print(string.format("[Terrains] Registered %d terrains", #Terrains.getAllIds()))

return Terrains


























