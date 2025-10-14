-- Biome System for Geoscape → Battlescape connection
-- Defines biomes with terrain weights for procedural map generation

local Biomes = {}

---@class Biome
---@field id string Unique biome identifier
---@field name string Display name
---@field description string Biome description
---@field terrains table Array of {id, weight} for terrain selection
---@field backgroundColor table RGB background color
---@field ambientLight table RGB ambient light multiplier

-- Biome registry
Biomes.registry = {}

---Register a biome
---@param biome Biome Biome definition
function Biomes.register(biome)
    if not biome.id then
        error("Biome must have an id")
    end
    
    Biomes.registry[biome.id] = biome
    print(string.format("[Biomes] Registered biome: %s (%s)", biome.id, biome.name))
end

---Get biome by ID
---@param biomeId string Biome ID
---@return Biome? Biome definition or nil
function Biomes.get(biomeId)
    return Biomes.registry[biomeId]
end

---Get all biome IDs
---@return table Array of biome IDs
function Biomes.getAllIds()
    local ids = {}
    for id, _ in pairs(Biomes.registry) do
        table.insert(ids, id)
    end
    return ids
end

-- Define standard biomes

Biomes.register({
    id = "forest",
    name = "Forest",
    description = "Dense woodland with trees and undergrowth",
    terrains = {
        {id = "dense_forest", weight = 50},
        {id = "light_forest", weight = 30},
        {id = "grassland", weight = 15},
        {id = "water", weight = 5}
    },
    backgroundColor = {r = 0.13, g = 0.55, b = 0.13},  -- Forest green
    ambientLight = {r = 0.8, g = 1.0, b = 0.8}
})

Biomes.register({
    id = "urban",
    name = "Urban",
    description = "City with buildings, roads, and infrastructure",
    terrains = {
        {id = "urban_street", weight = 40},
        {id = "urban_industrial", weight = 30},
        {id = "urban_residential", weight = 20},
        {id = "urban_commercial", weight = 10}
    },
    backgroundColor = {r = 0.3, g = 0.3, b = 0.3},  -- Gray
    ambientLight = {r = 1.0, g = 1.0, b = 1.0}
})

Biomes.register({
    id = "plains",
    name = "Plains",
    description = "Open grassland with scattered features",
    terrains = {
        {id = "grassland", weight = 60},
        {id = "dirt_road", weight = 20},
        {id = "farmland", weight = 15},
        {id = "water", weight = 5}
    },
    backgroundColor = {r = 0.56, g = 0.93, b = 0.56},  -- Light green
    ambientLight = {r = 1.0, g = 1.0, b = 0.9}
})

Biomes.register({
    id = "desert",
    name = "Desert",
    description = "Arid wasteland with sand and rocky outcrops",
    terrains = {
        {id = "sand", weight = 60},
        {id = "rocky_desert", weight = 25},
        {id = "dirt_road", weight = 10},
        {id = "oasis", weight = 5}
    },
    backgroundColor = {r = 0.93, g = 0.79, b = 0.47},  -- Sandy yellow
    ambientLight = {r = 1.0, g = 0.95, b = 0.8}
})

Biomes.register({
    id = "mountains",
    name = "Mountains",
    description = "Rocky mountainous terrain with cliffs",
    terrains = {
        {id = "rocky_mountain", weight = 50},
        {id = "mountain_path", weight = 25},
        {id = "light_forest", weight = 15},
        {id = "grassland", weight = 10}
    },
    backgroundColor = {r = 0.5, g = 0.5, b = 0.5},  -- Gray
    ambientLight = {r = 0.9, g = 0.9, b = 1.0}
})

Biomes.register({
    id = "arctic",
    name = "Arctic",
    description = "Frozen tundra with snow and ice",
    terrains = {
        {id = "snow", weight = 60},
        {id = "ice", weight = 25},
        {id = "arctic_rock", weight = 15}
    },
    backgroundColor = {r = 0.9, g = 0.9, b = 1.0},  -- Icy white
    ambientLight = {r = 0.9, g = 0.95, b = 1.0}
})

Biomes.register({
    id = "coastal",
    name = "Coastal",
    description = "Shoreline with beaches and water",
    terrains = {
        {id = "beach", weight = 40},
        {id = "water", weight = 30},
        {id = "grassland", weight = 20},
        {id = "coastal_urban", weight = 10}
    },
    backgroundColor = {r = 0.4, g = 0.6, b = 0.8},  -- Ocean blue
    ambientLight = {r = 0.95, g = 1.0, b = 1.0}
})

Biomes.register({
    id = "industrial",
    name = "Industrial",
    description = "Heavy industry with factories and warehouses",
    terrains = {
        {id = "industrial_complex", weight = 50},
        {id = "warehouse_district", weight = 30},
        {id = "urban_street", weight = 15},
        {id = "rail_yard", weight = 5}
    },
    backgroundColor = {r = 0.4, g = 0.4, b = 0.4},  -- Dark gray
    ambientLight = {r = 0.9, g = 0.9, b = 0.85}
})

Biomes.register({
    id = "rural",
    name = "Rural",
    description = "Countryside with farms and villages",
    terrains = {
        {id = "farmland", weight = 45},
        {id = "grassland", weight = 30},
        {id = "dirt_road", weight = 15},
        {id = "rural_village", weight = 10}
    },
    backgroundColor = {r = 0.6, g = 0.8, b = 0.4},  -- Farmland green
    ambientLight = {r = 1.0, g = 1.0, b = 0.95}
})

Biomes.register({
    id = "water",
    name = "Water",
    description = "Ocean or large body of water",
    terrains = {
        {id = "deep_water", weight = 70},
        {id = "shallow_water", weight = 20},
        {id = "underwater_terrain", weight = 10}
    },
    backgroundColor = {r = 0.0, g = 0.3, b = 0.6},  -- Deep blue
    ambientLight = {r = 0.7, g = 0.85, b = 1.0}
})

print(string.format("[Biomes] Registered %d biomes", #Biomes.getAllIds()))

return Biomes
