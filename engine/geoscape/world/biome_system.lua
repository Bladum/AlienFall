---@class BiomeSystem
---Generates biome distribution and manages biome properties
---Uses Perlin noise + cellular automata for coherent distribution
local BiomeSystem = {}

---Biome types
local BIOME_TYPES = {
    "urban",
    "desert",
    "forest",
    "arctic",
    "water",
}

---Biome properties lookup table
local BIOME_PROPERTIES = {
    urban = {
        color = {200, 200, 200},
        difficulty_mod = 0.8,
        movement_cost = 1.0,
        resource_yield = 0.7,
        population_density = 0.9,
        can_place_city = true,
        visibility = 1.0,
        description = "Urban - Cities and infrastructure",
    },
    desert = {
        color = {200, 180, 100},
        difficulty_mod = 1.1,
        movement_cost = 1.5,
        resource_yield = 0.6,
        population_density = 0.3,
        can_place_city = false,
        visibility = 1.2,
        description = "Desert - Arid, mineral-rich",
        resources = {mineral = 0.8},
    },
    forest = {
        color = {100, 150, 100},
        difficulty_mod = 1.0,
        movement_cost = 1.2,
        resource_yield = 0.8,
        population_density = 0.5,
        can_place_city = true,
        visibility = 0.8,
        description = "Forest - Dense vegetation",
        resources = {energy = 0.7},
    },
    arctic = {
        color = {200, 220, 255},
        difficulty_mod = 1.3,
        movement_cost = 2.0,
        resource_yield = 0.4,
        population_density = 0.1,
        can_place_city = false,
        visibility = 0.9,
        description = "Arctic - Ice and tundra",
        resources = {tech = 0.9},
    },
    water = {
        color = {50, 100, 200},
        difficulty_mod = 2.0,
        movement_cost = 999,  -- Impassable
        resource_yield = 0.0,
        population_density = 0.0,
        can_place_city = false,
        visibility = 1.0,
        description = "Water - Ocean",
    },
}

---Create new biome system
---@return BiomeSystem
function BiomeSystem.new()
    return setmetatable({}, {__index = BiomeSystem})
end

---Simple Perlin noise implementation (2D, value noise)
---@param x number X coordinate
---@param y number Y coordinate
---@param seed number Random seed
---@return number Noise value (0-1)
local function perlinNoise(x, y, seed)
    -- Use multiple octaves for better distribution
    local value = 0.0
    local amplitude = 1.0
    local frequency = 1.0
    local max_value = 0.0

    for i = 1, 4 do
        local sx = x * frequency
        local sy = y * frequency

        local xi = math.floor(sx)
        local yi = math.floor(sy)
        local xf = sx - xi
        local yf = sy - yi

        -- Gradient hash (deterministic but varied)
        local h00 = math.sin((xi + yi * 73 + seed * 37) * 12.9898) * 43758.5453
        local h10 = math.sin((xi + 1 + yi * 73 + seed * 37) * 12.9898) * 43758.5453
        local h01 = math.sin((xi + (yi + 1) * 73 + seed * 37) * 12.9898) * 43758.5453
        local h11 = math.sin((xi + 1 + (yi + 1) * 73 + seed * 37) * 12.9898) * 43758.5453

        h00 = h00 - math.floor(h00)
        h10 = h10 - math.floor(h10)
        h01 = h01 - math.floor(h01)
        h11 = h11 - math.floor(h11)

        -- Smoothstep interpolation
        local u = xf * xf * (3.0 - 2.0 * xf)
        local v = yf * yf * (3.0 - 2.0 * yf)

        local n0 = h00 + (h10 - h00) * u
        local n1 = h01 + (h11 - h01) * u
        local n = n0 + (n1 - n0) * v

        value = value + n * amplitude
        max_value = max_value + amplitude

        amplitude = amplitude * 0.5
        frequency = frequency * 2.0
    end

    return math.max(0, math.min(1, value / max_value))
end

---Generate biome map using Perlin noise + cellular automata
---@param width number Map width
---@param height number Map height
---@param seed number Generation seed
---@return string[] 1D array of biome types
function BiomeSystem:generateMap(width, height, seed)
    math.randomseed(seed)

    local start = os.clock()

    -- Step 1: Generate noise-based values (0-5 range for 5 biomes)
    local noise_map = {}
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local idx = y * width + x + 1

            -- Combine multiple noise functions for variety
            local n1 = perlinNoise(x * 0.1, y * 0.1, seed)
            local n2 = perlinNoise(x * 0.05, y * 0.05, seed + 100)

            -- Water tends to be in lower regions
            local water_bias = perlinNoise(x * 0.08, y * 0.08, seed + 200)

            local combined = (n1 * 0.6 + n2 * 0.4) * 5.0

            -- Water gets lower values (easier to threshold)
            if water_bias > 0.6 then
                combined = combined * 0.6
            end

            noise_map[idx] = combined
        end
    end

    -- Step 2: Cellular automata smoothing (3 passes)
    for pass = 1, 3 do
        local new_map = {}

        for y = 0, height - 1 do
            for x = 0, width - 1 do
                local idx = y * width + x + 1

                -- Average with neighbors
                local sum = noise_map[idx]
                local count = 1

                for dy = -1, 1 do
                    for dx = -1, 1 do
                        if dx == 0 and dy == 0 then
                            -- Skip center
                        else
                            local nx = x + dx
                            local ny = y + dy

                            if nx >= 0 and nx < width and ny >= 0 and ny < height then
                                local nidx = ny * width + nx + 1
                                sum = sum + noise_map[nidx]
                                count = count + 1
                            end
                        end
                    end
                end

                new_map[idx] = sum / count
            end
        end

        noise_map = new_map
    end

    -- Step 3: Threshold mapping to biome types
    local biome_map = {}
    for idx = 1, width * height do
        local value = noise_map[idx]

        -- Thresholds for 5 biome types (adjusted for reasonable distribution)
        local biome = "urban"

        if value < 0.8 then
            biome = "water"
        elseif value < 1.4 then
            biome = "arctic"
        elseif value < 2.0 then
            biome = "desert"
        elseif value < 3.2 then
            biome = "forest"
        else
            biome = "urban"
        end

        biome_map[idx] = biome
    end

    -- Step 4: Coastal smoothing (convert water-adjacent to coast)
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local idx = y * width + x + 1

            if biome_map[idx] ~= "water" then
                -- Check if adjacent to water
                local has_water_neighbor = false

                for dy = -1, 1 do
                    for dx = -1, 1 do
                        if dx == 0 and dy == 0 then
                            -- Skip center
                        else
                            local nx = x + dx
                            local ny = y + dy

                            if nx >= 0 and nx < width and ny >= 0 and ny < height then
                                local nidx = ny * width + nx + 1
                                if biome_map[nidx] == "water" then
                                    has_water_neighbor = true
                                    break
                                end
                            end
                        end
                    end
                    if has_water_neighbor then break end
                end

                -- Coastal smoothing: convert to desert if on coast
                if has_water_neighbor and biome_map[idx] == "arctic" then
                    biome_map[idx] = "desert"
                end
            end
        end
    end

    local gen_time = (os.clock() - start) * 1000
    print(string.format("[BiomeSystem] Generated %dx%d biome map in %.2fms",
        width, height, gen_time))

    return biome_map
end

---Get properties for a biome type
---@param biome string Biome type
---@return table Biome properties
function BiomeSystem:getProperties(biome)
    return BIOME_PROPERTIES[biome] or {
        color = {128, 128, 128},
        difficulty_mod = 1.0,
        movement_cost = 1.0,
        resource_yield = 0.5,
        population_density = 0.0,
        can_place_city = false,
        visibility = 1.0,
        description = "Unknown",
    }
end

---Check if biome is suitable for city placement
---@param biome string Biome type
---@return boolean Can place city here
function BiomeSystem:canPlaceCity(biome)
    local props = self:getProperties(biome)
    return props.can_place_city or false
end

---Get biome color for rendering
---@param biome string Biome type
---@return table Color as {r, g, b}
function BiomeSystem:getColor(biome)
    local props = self:getProperties(biome)
    return props.color or {128, 128, 128}
end

---Get difficulty modifier for biome
---@param biome string Biome type
---@return number Difficulty multiplier (0.5-2.0)
function BiomeSystem:getDifficultyMod(biome)
    local props = self:getProperties(biome)
    return props.difficulty_mod or 1.0
end

---Get movement cost for biome
---@param biome string Biome type
---@return number Movement cost multiplier
function BiomeSystem:getMovementCost(biome)
    local props = self:getProperties(biome)
    return props.movement_cost or 1.0
end

---Check if biome is water (impassable)
---@param biome string Biome type
---@return boolean Is water
function BiomeSystem:isWater(biome)
    return biome == "water"
end

---Check if biome is passable
---@param biome string Biome type
---@return boolean Is passable (not water)
function BiomeSystem:isPassable(biome)
    return biome ~= "water"
end

---Get all biome types
---@return string[] Array of biome type names
function BiomeSystem:getAllBiomes()
    return BIOME_TYPES
end

---Debug: Print biome properties
function BiomeSystem:debug()
    print("\n[BiomeSystem] Biome Properties:")
    for _, biome in ipairs(BIOME_TYPES) do
        local props = self:getProperties(biome)
        print(string.format("  %s:", biome))
        print(string.format("    Difficulty: %.1f, Movement: %.1f, Resources: %.1f",
            props.difficulty_mod, props.movement_cost, props.resource_yield))
        print(string.format("    City: %s, Density: %.1f",
            props.can_place_city and "yes" or "no", props.population_density))
    end
end

return BiomeSystem
