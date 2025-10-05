--- WorldGenerator.lua
-- Procedural world generation system for Alien Fall
-- Generates worlds with provinces, countries, regions, and biome assignments

-- GROK: WorldGenerator creates complete world structures with provinces, countries, regions
-- GROK: Uses Voronoi-like partitioning for natural-looking province boundaries
-- GROK: Key methods: generateWorld(), generateProvinces(), assignCountries(), assignRegions()
-- GROK: Configurable parameters: province_count, country_count, region_count, water_percentage

local class = require 'lib.Middleclass'
local Province = require 'geoscape.Province'
local Country = require 'geoscape.Country'
local Region = require 'geoscape.Region'
local World = require 'geoscape.World'

WorldGenerator = class('WorldGenerator')

--- Initialize the world generator
-- @param rng Random number generator (love.math.RandomGenerator or RNG service)
-- @param config Configuration parameters
function WorldGenerator:initialize(rng, config)
    self.rng = rng or love.math.newRandomGenerator()
    self.config = config or {}
    
    -- Default configuration
    self.province_count = self.config.province_count or 100
    self.country_count = self.config.country_count or 12
    self.region_count = self.config.region_count or 6
    self.water_percentage = self.config.water_percentage or 0.3
    self.map_width = self.config.map_width or 800
    self.map_height = self.config.map_height or 600
    
    -- Biome distribution weights
    self.biome_weights = self.config.biome_weights or {
        temperate = 0.3,
        tropical = 0.15,
        arctic = 0.15,
        desert = 0.15,
        forest = 0.15,
        mountain = 0.1
    }
end

--- Generate a complete world with all geographic features
-- @param world_data Base world data (id, name, description)
-- @param biome_registry Registry of available biomes
-- @return World instance
function WorldGenerator:generateWorld(world_data, biome_registry)
    -- Create base world
    local world = World:new(world_data)
    
    -- Generate provinces
    local provinces = self:generateProvinces(world_data.id)
    
    -- Assign biomes to provinces
    self:assignBiomes(provinces, biome_registry)
    
    -- Generate countries and assign provinces
    local countries = self:generateCountries(world_data.id)
    self:assignProvinceOwnership(provinces, countries)
    
    -- Generate regions and assign provinces
    local regions = self:generateRegions(world_data.id)
    self:assignProvinceRegions(provinces, regions)
    
    -- Calculate province adjacencies
    self:calculateAdjacencies(provinces)
    
    -- Add all generated entities to world
    for _, province in ipairs(provinces) do
        world:addProvince(province)
    end
    
    for _, country in ipairs(countries) do
        world:addCountry(country)
    end
    
    for _, region in ipairs(regions) do
        world:addRegion(region)
    end
    
    return world
end

--- Generate provinces using Voronoi-like partitioning
-- @param world_id The world ID these provinces belong to
-- @return Array of Province instances
function WorldGenerator:generateProvinces(world_id)
    local provinces = {}
    
    -- Generate random province centers (Voronoi seeds)
    local centers = {}
    for i = 1, self.province_count do
        local x = self.rng:random() * self.map_width
        local y = self.rng:random() * self.map_height
        table.insert(centers, {x = x, y = y, index = i})
    end
    
    -- Create province instances
    for i, center in ipairs(centers) do
        local is_water = self.rng:random() < self.water_percentage
        
        local province_data = {
            id = string.format("%s_province_%03d", world_id, i),
            name = self:generateProvinceName(i, is_water),
            description = "",
            world_id = world_id,
            coordinates = {center.x, center.y},
            longitude = (center.x / self.map_width) * 360 - 180,  -- -180 to 180
            is_water = is_water,
            terrain_modifier = self.rng:random() * 0.4 + 0.8,  -- 0.8 to 1.2
            economy_value = is_water and 10 or (self.rng:random(30, 100)),
            population = is_water and 0 or (self.rng:random(10000, 1000000)),
            controlled_by = "neutral",
            alien_activity = self.rng:random() * 0.3 + 0.3,  -- 0.3 to 0.6
            adjacencies = {},
            tags = is_water and {"water"} or {}
        }
        
        local province = Province:new(province_data)
        table.insert(provinces, province)
    end
    
    return provinces
end

--- Generate province name
-- @param index Province index
-- @param is_water Whether this is a water province
-- @return Province name
function WorldGenerator:generateProvinceName(index, is_water)
    if is_water then
        local water_names = {
            "Ocean", "Sea", "Bay", "Gulf", "Strait", 
            "Channel", "Sound", "Lake", "Fjord"
        }
        local water_type = water_names[self.rng:random(1, #water_names)]
        return string.format("%s Zone %d", water_type, index)
    else
        local land_prefixes = {
            "North", "South", "East", "West", "Central",
            "Upper", "Lower", "Inner", "Outer", "New"
        }
        local land_suffixes = {
            "Plains", "Highlands", "Valley", "Territory", "Region",
            "Province", "District", "Sector", "Zone", "Area"
        }
        local prefix = land_prefixes[self.rng:random(1, #land_prefixes)]
        local suffix = land_suffixes[self.rng:random(1, #land_suffixes)]
        return string.format("%s %s %d", prefix, suffix, index)
    end
end

--- Assign biomes to provinces
-- @param provinces Array of Province instances
-- @param biome_registry Registry of available biomes
function WorldGenerator:assignBiomes(provinces, biome_registry)
    local biome_ids = {}
    
    -- Get available biomes from registry or use defaults
    if biome_registry then
        for biome_id, _ in pairs(biome_registry.biomes or {}) do
            table.insert(biome_ids, biome_id)
        end
    end
    
    -- If no biomes in registry, use default biome IDs
    if #biome_ids == 0 then
        biome_ids = {"temperate", "tropical", "arctic", "desert", "forest", "mountain", "ocean"}
    end
    
    -- Assign biomes based on weights and province type
    for _, province in ipairs(provinces) do
        if province.is_water then
            province.biome_id = "ocean"
        else
            -- Weighted random selection
            local biome = biome_ids[self.rng:random(1, #biome_ids)]
            province.biome_id = biome
        end
    end
end

--- Generate countries
-- @param world_id The world ID
-- @return Array of Country instances
function WorldGenerator:generateCountries(world_id)
    local countries = {}
    
    for i = 1, self.country_count do
        local country_data = {
            id = string.format("%s_country_%02d", world_id, i),
            name = self:generateCountryName(i),
            description = "",
            world_id = world_id,
            government_type = self:selectGovernmentType(),
            funding_level = self.rng:random(1000000, 10000000),
            happiness = self.rng:random() * 0.4 + 0.3,  -- 0.3 to 0.7
            provinces = {},
            population = 0,  -- Will be calculated from provinces
            economy_value = 0,  -- Will be calculated from provinces
            alien_activity = self.rng:random() * 0.3 + 0.2  -- 0.2 to 0.5
        }
        
        local country = Country:new(country_data)
        table.insert(countries, country)
    end
    
    return countries
end

--- Generate country name
-- @param index Country index
-- @return Country name
function WorldGenerator:generateCountryName(index)
    local adjectives = {
        "United", "Federal", "Democratic", "People's", "Royal",
        "Imperial", "Free", "Grand", "Republic of", "Kingdom of"
    }
    local nouns = {
        "States", "Federation", "Union", "Alliance", "League",
        "Coalition", "Commonwealth", "Confederation", "Territory", "Nation"
    }
    
    local adj = adjectives[self.rng:random(1, #adjectives)]
    local noun = nouns[self.rng:random(1, #nouns)]
    
    return string.format("%s %s %d", adj, noun, index)
end

--- Select government type
-- @return Government type string
function WorldGenerator:selectGovernmentType()
    local types = {"democracy", "autocracy", "federation", "oligarchy", "theocracy"}
    return types[self.rng:random(1, #types)]
end

--- Assign provinces to countries using growth algorithm
-- @param provinces Array of Province instances
-- @param countries Array of Country instances
function WorldGenerator:assignProvinceOwnership(provinces, countries)
    -- Filter out water provinces
    local land_provinces = {}
    for _, province in ipairs(provinces) do
        if not province.is_water then
            table.insert(land_provinces, province)
        end
    end
    
    -- Assign seed provinces to each country (one per country)
    local seeds = {}
    for i, country in ipairs(countries) do
        local province = land_provinces[self.rng:random(1, #land_provinces)]
        province.country_id = country.id
        country:addProvince(province)
        table.insert(seeds, province)
    end
    
    -- Growth algorithm: expand countries from seeds
    local unassigned = {}
    for _, province in ipairs(land_provinces) do
        if not province.country_id then
            table.insert(unassigned, province)
        end
    end
    
    -- Assign remaining provinces to nearest country
    while #unassigned > 0 do
        local province = table.remove(unassigned, 1)
        local nearest_country = self:findNearestCountry(province, countries)
        
        if nearest_country then
            province.country_id = nearest_country.id
            nearest_country:addProvince(province)
        end
    end
    
    -- Calculate country statistics
    for _, country in ipairs(countries) do
        country:calculateStatistics()
    end
end

--- Find nearest country to a province
-- @param province Province to check
-- @param countries Array of countries
-- @return Nearest country or nil
function WorldGenerator:findNearestCountry(province, countries)
    local min_distance = math.huge
    local nearest_country = nil
    
    for _, country in ipairs(countries) do
        -- Find closest province in this country
        local country_provinces = country:getProvinces()
        for _, country_province in ipairs(country_provinces) do
            local distance = self:calculateDistance(
                province.coordinates,
                country_province.coordinates
            )
            
            if distance < min_distance then
                min_distance = distance
                nearest_country = country
            end
        end
    end
    
    return nearest_country
end

--- Generate regions
-- @param world_id The world ID
-- @return Array of Region instances
function WorldGenerator:generateRegions(world_id)
    local regions = {}
    
    for i = 1, self.region_count do
        local region_data = {
            id = string.format("%s_region_%02d", world_id, i),
            name = self:generateRegionName(i),
            description = "",
            world_id = world_id,
            countries = {},
            provinces = {},
            alien_threat = self.rng:random() * 0.5 + 0.2,  -- 0.2 to 0.7
            stability = self.rng:random() * 0.4 + 0.4  -- 0.4 to 0.8
        }
        
        local region = Region:new(region_data)
        table.insert(regions, region)
    end
    
    return regions
end

--- Generate region name
-- @param index Region index
-- @return Region name
function WorldGenerator:generateRegionName(index)
    local directions = {"Northern", "Southern", "Eastern", "Western", "Central", "Pacific"}
    local types = {"Hemisphere", "Sector", "Zone", "Region", "Territory", "Area"}
    
    local direction = directions[self.rng:random(1, #directions)]
    local type = types[self.rng:random(1, #types)]
    
    return string.format("%s %s", direction, type)
end

--- Assign provinces to regions
-- @param provinces Array of Province instances
-- @param regions Array of Region instances
function WorldGenerator:assignProvinceRegions(provinces, regions)
    -- Simple approach: divide provinces by longitude
    local provinces_per_region = math.ceil(#provinces / #regions)
    
    -- Sort provinces by longitude
    table.sort(provinces, function(a, b)
        return a.longitude < b.longitude
    end)
    
    -- Assign to regions
    local region_index = 1
    local count_in_region = 0
    
    for _, province in ipairs(provinces) do
        local region = regions[region_index]
        province.region_id = region.id
        region:addProvince(province)
        
        count_in_region = count_in_region + 1
        if count_in_region >= provinces_per_region and region_index < #regions then
            region_index = region_index + 1
            count_in_region = 0
        end
    end
end

--- Calculate adjacencies between provinces using distance threshold
-- @param provinces Array of Province instances
function WorldGenerator:calculateAdjacencies(provinces)
    -- Distance threshold for adjacency (about 10% of map width)
    local threshold = self.map_width * 0.1
    
    for i, province1 in ipairs(provinces) do
        for j, province2 in ipairs(provinces) do
            if i ~= j then
                local distance = self:calculateDistance(
                    province1.coordinates,
                    province2.coordinates
                )
                
                -- Adjacent if within threshold
                if distance <= threshold then
                    -- Add to adjacency list (no duplicates)
                    local already_adjacent = false
                    for _, adj_id in ipairs(province1.adjacencies) do
                        if adj_id == province2.id then
                            already_adjacent = true
                            break
                        end
                    end
                    
                    if not already_adjacent then
                        table.insert(province1.adjacencies, province2.id)
                        province1.connection_costs[province2.id] = distance
                    end
                end
            end
        end
    end
end

--- Calculate Euclidean distance between two points
-- @param coord1 First coordinate {x, y}
-- @param coord2 Second coordinate {x, y}
-- @return Distance
function WorldGenerator:calculateDistance(coord1, coord2)
    local dx = coord1[1] - coord2[1]
    local dy = coord1[2] - coord2[2]
    return math.sqrt(dx * dx + dy * dy)
end

--- Generate quick test world for development
-- @param world_id World ID
-- @return World instance
function WorldGenerator:generateQuickWorld(world_id)
    local world_data = {
        id = world_id or "test_world",
        name = "Test World",
        description = "Procedurally generated test world",
        config = {
            rotation_period = 24
        }
    }
    
    return self:generateWorld(world_data, nil)
end

return WorldGenerator
