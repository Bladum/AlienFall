---@class ProceduralGenerator
---Orchestrates world generation from seed to complete world
---Coordinates all generation systems: biomes, elevation, resources
local ProceduralGenerator = {}

local WorldMap = require("engine.geoscape.world.world_map")
local BiomeSystem = require("engine.geoscape.world.biome_system")

---Create new procedural generator
---@param seed number Generation seed for determinism
---@param difficulty string Game difficulty: "easy", "normal", "hard", "ironman"
---@return ProceduralGenerator
function ProceduralGenerator.new(seed, difficulty)
    difficulty = difficulty or "normal"

    return setmetatable({
        seed = seed,
        difficulty = difficulty,
        biome_system = BiomeSystem.new(),
        start_time = os.clock(),
    }, {__index = ProceduralGenerator})
end

---Seeded random number generator for determinism
---@param min number Minimum value
---@param max number Maximum value
---@param seed number RNG seed
---@return number Random value
local function seededRandom(min, max, seed)
    -- Simple deterministic RNG
    local x = math.sin(seed) * 10000
    x = x - math.floor(x)
    return min + x * (max - min)
end

---Generate elevation map using Perlin noise
---@param width number Map width
---@param height number Map height
---@param seed number Generation seed
---@return number[] 1D array of elevation values (0-1)
function ProceduralGenerator:generateElevation(width, height, seed)
    local start = os.clock()
    local elevation = {}

    -- Simple deterministic height generation
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local idx = y * width + x + 1

            -- Use sine/cosine for smooth variation
            local elev = 0.0

            -- Add multiple frequency layers
            elev = elev + math.sin((x + seed) * 0.1) * 0.3
            elev = elev + math.sin((y + seed) * 0.1) * 0.2
            elev = elev + math.sin((x + y + seed) * 0.05) * 0.2

            -- Normalize to 0-1
            elev = (elev + 1.5) / 3.0
            elev = math.max(0, math.min(1, elev))

            elevation[idx] = elev
        end
    end

    local gen_time = (os.clock() - start) * 1000
    print(string.format("[ProceduralGenerator] Generated elevation in %.2fms", gen_time))

    return elevation
end

---Generate resource distribution by biome clustering
---@param width number Map width
---@param height number Map height
---@param biomes string[] Biome map
---@param seed number Generation seed
---@return table[] 1D array of resource tables
function ProceduralGenerator:generateResources(width, height, biomes, seed)
    local start = os.clock()
    local resources = {}

    -- Resource properties by biome
    local BIOME_RESOURCES = {
        desert = {mineral = 0.8, energy = 0.2, tech = 0.1, rare = 0.3},
        arctic = {mineral = 0.3, energy = 0.2, tech = 0.9, rare = 0.8},
        forest = {mineral = 0.2, energy = 0.7, tech = 0.3, rare = 0.2},
        urban = {mineral = 0.4, energy = 0.6, tech = 0.7, rare = 0.1},
        water = {mineral = 0.0, energy = 0.0, tech = 0.0, rare = 0.0},
    }

    math.randomseed(seed)

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local idx = y * width + x + 1
            local biome = biomes[idx]

            local biome_res = BIOME_RESOURCES[biome] or {}

            -- Apply variance (±20%)
            local variance = 0.8 + (math.random() * 0.4)

            resources[idx] = {
                mineral = (biome_res.mineral or 0) * variance,
                energy = (biome_res.energy or 0) * variance,
                tech = (biome_res.tech or 0) * variance,
                rare = (biome_res.rare or 0) * variance,
            }

            -- Clamp to 0-1
            for key, _ in pairs(resources[idx]) do
                resources[idx][key] = math.max(0, math.min(1, resources[idx][key]))
            end
        end
    end

    local gen_time = (os.clock() - start) * 1000
    print(string.format("[ProceduralGenerator] Generated resources in %.2fms", gen_time))

    return resources
end

---Generate alien base locations
---@param width number Map width
---@param height number Map height
---@param biomes string[] Biome map
---@param seed number Generation seed
---@return table[] Alien base locations
function ProceduralGenerator:generateAlienBases(width, height, biomes, seed)
    local bases = {}

    -- Difficulty affects alien presence
    local DIFFICULTY_ALIEN_COUNT = {
        easy = 2,
        normal = 4,
        hard = 6,
        ironman = 8,
    }

    local base_count = DIFFICULTY_ALIEN_COUNT[self.difficulty] or 4

    math.randomseed(seed + 1000)

    for i = 1, base_count do
        -- Find water-adjacent desert (typical alien base location)
        local found = false
        local attempts = 0

        while not found and attempts < 100 do
            local x = math.floor(math.random() * width)
            local y = math.floor(math.random() * height)
            local idx = y * width + x + 1

            local biome = biomes[idx]

            -- Prefer desert or remote areas
            if biome == "desert" or biome == "arctic" then
                table.insert(bases, {
                    x = x,
                    y = y,
                    strength = 0.5 + math.random() * 0.5,  -- 0.5-1.0
                    ufos = math.floor(2 + math.random() * 4),  -- 2-6
                })
                found = true
            end

            attempts = attempts + 1
        end
    end

    print(string.format("[ProceduralGenerator] Generated %d alien bases", #bases))

    return bases
end

---Main world generation function
---@param width number Map width (default: 80)
---@param height number Map height (default: 40)
---@return table Generated world data
function ProceduralGenerator:generate(width, height)
    width = width or 80
    height = height or 40

    local gen_start = os.clock()

    print(string.format("\n[ProceduralGenerator] Generating %dx%d world (seed: %d, difficulty: %s)",
        width, height, self.seed, self.difficulty))

    -- Step 1: Generate biomes (largest time investment)
    print("[ProceduralGenerator] Step 1: Generating biomes...")
    local biomes = self.biome_system:generateMap(width, height, self.seed)

    -- Step 2: Generate elevation
    print("[ProceduralGenerator] Step 2: Generating elevation...")
    local elevation = self:generateElevation(width, height, self.seed + 1)

    -- Step 3: Generate resources
    print("[ProceduralGenerator] Step 3: Distributing resources...")
    local resources = self:generateResources(width, height, biomes, self.seed + 2)

    -- Step 4: Generate alien bases
    print("[ProceduralGenerator] Step 4: Placing alien bases...")
    local alien_bases = self:generateAlienBases(width, height, biomes, self.seed + 3)

    -- Step 5: Create world map and populate provinces
    print("[ProceduralGenerator] Step 5: Creating world map...")
    local world = WorldMap.new(width, height)

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local idx = y * width + x + 1

            local province = {
                x = x,
                y = y,
                biome = biomes[idx],
                elevation = elevation[idx],
                population = 0,
                region_id = 0,
                control = "neutral",
                has_city = false,
                cities = {},
                infrastructure = 0.0,
                resources = resources[idx],
                military = {},
                economy = {
                    income = 0,
                    expenditure = 0,
                },
            }

            world:setProvince(x, y, province)
        end
    end

    local total_time = (os.clock() - gen_start) * 1000

    print(string.format("[ProceduralGenerator] Generation complete in %.2fms", total_time))

    if total_time > 100 then
        print("[ProceduralGenerator] WARNING: Generation exceeded 100ms target!")
    end

    return {
        world = world,
        biomes = biomes,
        elevation = elevation,
        resources = resources,
        alien_bases = alien_bases,
        seed = self.seed,
        difficulty = self.difficulty,
        gen_time_ms = total_time,
    }
end

---Debug: Print generator info
function ProceduralGenerator:debug()
    print("\n[ProceduralGenerator] Debug Information:")
    print(string.format("  Seed: %d", self.seed))
    print(string.format("  Difficulty: %s", self.difficulty))

    self.biome_system:debug()
end

return ProceduralGenerator

