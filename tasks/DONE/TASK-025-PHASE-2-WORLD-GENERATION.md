# TASK-025 Phase 2: World Generation

**Status:** ✅ COMPLETE
**Estimated:** 20 hours
**Start Date:** October 24, 2025
**Completion Date:** October 24, 2025

---

## Overview

Generate the 80×40 province grid using procedural generation (Perlin noise + cellular automata). Implement biome system with resource distribution. Create location/city placement system. All generation deterministic (seed-based) for replayability.

**Deliverables:**
- `engine/geoscape/world/world_map.lua` (250 lines)
- `engine/geoscape/world/biome_system.lua` (150 lines)
- `engine/geoscape/world/procedural_generator.lua` (300 lines)
- `engine/geoscape/world/location_system.lua` (150 lines)
- Performance: <100ms generation time
- Test suite: Unit + integration tests

---

## Requirements

### Functional Requirements

1. **World Generation**
   - 80×40 province grid
   - Seed-based (deterministic, repeatable)
   - Generates in <100ms at startup
   - Supports difficulty scaling (affects biome/alien density)

2. **Biome System**
   - 5 biome types: urban, desert, forest, arctic, water
   - Perlin noise for smooth distribution
   - Cellular automata for coherence
   - Properties: movement cost, resource yield, difficulty modifier

3. **Location System**
   - Place 15-20 regions (countries)
   - One capital per region
   - 5-10 major cities per region
   - Deterministic placement based on biome suitability

4. **Resource Distribution**
   - Minerals, energy, technology, rare materials
   - Clustered by biome (desert = minerals, arctic = tech, etc)
   - Affects economic value and targeting

### Technical Requirements

- Pure Lua implementation (no external libraries)
- Seed-based determinism for all generation
- Memory footprint: ~640 KB for entire world
- Generation time: <100ms measured with `os.clock()`
- All functions idempotent (same seed = same result)

---

## Detailed Plan

### Phase 2.1: World Map Foundation (4 hours)

**WorldMap class** - Core container and access patterns

```lua
-- engine/geoscape/world/world_map.lua

WorldMap = {
    width = 80,
    height = 40,
    provinces = {},     -- 1D array of 3200 provinces
    biomes = {},        -- Biome type per province
    elevation = {},     -- Height per province
    resources = {},     -- Resources per province
    locations = {},     -- Cities per province
}

function WorldMap.new(width, height)
    -- Initialize empty world
    -- Set up province grid
    -- Allocate memory
end

function WorldMap:getProvince(x, y)
    -- Validate bounds
    -- Return province at (x, y)
end

function WorldMap:setProvince(x, y, province)
    -- Store province
end

function WorldMap:getNeighbors(x, y, distance)
    -- Return provinces within N tiles
    -- Used for island detection, region expansion
end

function WorldMap:forEachProvince(fn)
    -- Iterate all provinces, call fn(x, y, province)
    -- Used in generation algorithms
end
```

**Deliverables:**
- WorldMap class with grid management
- Coordinate validation
- Neighbor queries
- Iterator support

### Phase 2.2: Biome System (4 hours)

**BiomeSystem class** - Biome generation, properties, distribution

```lua
-- engine/geoscape/world/biome_system.lua

local BIOME_TYPES = {
    "urban",    -- Cities, infrastructure
    "desert",   -- Arid, minerals
    "forest",   -- Trees, resources
    "arctic",   -- Ice, rare tech
    "water"     -- Oceans, impassable
}

local BIOME_PROPERTIES = {
    urban = {
        color = {200, 200, 200},
        difficulty_mod = 0.8,
        movement_cost = 1,
        resource_yield = 0.7,
        population_density = 0.9,
    },
    desert = {
        color = {200, 180, 100},
        difficulty_mod = 1.1,
        movement_cost = 1.5,
        resource_yield = 0.6,
        population_density = 0.3,
    },
    -- ... etc for all biomes
}

function BiomeSystem:generateMap(width, height, seed)
    -- Use Perlin noise to create smooth biome distribution
    -- Use cellular automata to improve coherence
    -- Return 2D biome array
    -- Time: <50ms for 80x40
end

function BiomeSystem:getProperties(biome)
    -- Return movement_cost, difficulty, resources, etc
end

function BiomeSystem:canPlaceCity(x, y, biome)
    -- Return true if suitable for city (urban/forest, not water)
end
```

**Algorithm:**
1. Perlin noise (0-1) → biome value
2. Cellular automata smoothing (3 passes)
3. Threshold mapping to 5 biome types
4. Water detection (islands)
5. Coastal smoothing

**Deliverables:**
- BiomeSystem class
- Perlin noise generator (simple)
- Cellular automata smoothing
- Biome properties table

### Phase 2.3: Procedural Generator (6 hours)

**ProceduralGenerator class** - Orchestrates full world generation

```lua
-- engine/geoscape/world/procedural_generator.lua

ProceduralGenerator = {}

function ProceduralGenerator.new(seed, difficulty)
    return {
        seed = seed,
        difficulty = difficulty,
        rng = math.random,  -- Seeded RNG
    }
end

function ProceduralGenerator:generate(width, height)
    -- Step 1: Generate biomes (Perlin + cellular automata)
    -- Step 2: Generate elevation map
    -- Step 3: Identify continents/islands
    -- Step 4: Distribute resources
    -- Step 5: Return full world data

    local world = WorldMap.new(width, height)

    -- Seed the RNG for determinism
    math.randomseed(self.seed)

    -- Generate biomes
    local biomes = self:generateBiomes(width, height)

    -- Generate elevation
    local elevation = self:generateElevation(width, height)

    -- Generate resources
    local resources = self:generateResources(width, height, biomes)

    -- Package into world
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local province = {
                x = x, y = y,
                biome = biomes[y * width + x + 1],
                elevation = elevation[y * width + x + 1],
                population = 0,
                region_id = 0,
                control = "neutral",
                has_city = false,
                resources = resources[y * width + x + 1],
                infrastructure = 0,
            }
            world:setProvince(x, y, province)
        end
    end

    return world
end

function ProceduralGenerator:generateBiomes(width, height)
    -- Perlin noise + cellular automata
    -- Time: <30ms
    local biome_system = BiomeSystem.new()
    return biome_system:generateMap(width, height, self.seed)
end

function ProceduralGenerator:generateElevation(width, height)
    -- Perlin noise for smooth height variation
    -- Range: 0-1 (flat to mountainous)
    -- Time: <20ms
end

function ProceduralGenerator:generateResources(width, height, biomes)
    -- Cluster resources by biome type
    -- Desert = minerals, Arctic = tech, Forest = energy, etc
    -- Time: <30ms
end
```

**Deliverables:**
- ProceduralGenerator orchestrator
- Biome generation (Perlin + cellular automata)
- Elevation generation (Perlin noise)
- Resource distribution (biome-based clustering)
- Total generation time: <100ms

### Phase 2.4: Location System (3 hours)

**LocationSystem class** - Place regions, capitals, cities

```lua
-- engine/geoscape/world/location_system.lua

LocationSystem = {}

function LocationSystem.new(world, seed)
    return {
        world = world,
        seed = seed,
        regions = {},
        cities = {},
    }
end

function LocationSystem:generateLocations()
    -- Step 1: Identify urban zones (cellular automata on urban biome)
    -- Step 2: Pick 15-20 region capitals
    -- Step 3: Expand regions via flood fill
    -- Step 4: Place 5-10 cities per region
    -- Step 5: Name regions and cities
end

function LocationSystem:identifyUrbanZones()
    -- Find connected urban provinces
    -- Return list of {provinces, center_point}
end

function LocationSystem:expandRegions()
    -- Flood fill from capitals
    -- Respect biome suitability
    -- Balance region sizes
end

function LocationSystem:placeCities()
    -- Place cities in suitable locations
    -- One capital per region
    -- 5-10 secondary cities
    -- Distance constraints (minimum spacing)
end

function LocationSystem:generateNames(region_id)
    -- Generate name for region based on geography
    -- Generate names for cities (deterministic, seed-based)
end
```

**Deliverables:**
- LocationSystem class
- Region capital identification
- Region expansion algorithm (flood fill)
- City placement with constraints
- Name generation (deterministic)

### Phase 2.5: Integration & Performance (2 hours)

**GeoMap wrapper** - Integrate all systems

```lua
-- engine/geoscape/world/geomap.lua

GeoMap = {}

function GeoMap.new(seed, difficulty, width, height)
    local generator = ProceduralGenerator.new(seed, difficulty)
    local start_time = os.clock()

    local world = generator:generate(width or 80, height or 40)

    local locations = LocationSystem.new(world, seed)
    locations:generateLocations()

    local gen_time = (os.clock() - start_time) * 1000
    print(string.format("[GeoMap] Generated %dx%d world in %.2fms",
        width or 80, height or 40, gen_time))

    return {
        world = world,
        locations = locations,
        gen_time = gen_time,
    }
end
```

**Performance Targets:**
- Biome generation: <30ms
- Elevation: <20ms
- Resources: <30ms
- Locations: <15ms
- Total: <100ms

---

## Implementation Checklist

- [ ] **WorldMap class** - Grid management, coordinate validation
  - [ ] `new()` - Initialize 80×40 grid
  - [ ] `getProvince(x, y)` - Retrieve province
  - [ ] `setProvince(x, y, province)` - Store province
  - [ ] `getNeighbors(x, y, distance)` - Query neighbors
  - [ ] `forEachProvince(fn)` - Iterator

- [ ] **BiomeSystem class** - Biome generation
  - [ ] Perlin noise generator
  - [ ] Cellular automata smoothing
  - [ ] Biome property lookup
  - [ ] City placement validation

- [ ] **ProceduralGenerator class** - Main orchestrator
  - [ ] Biome generation (Perlin + cellular)
  - [ ] Elevation generation
  - [ ] Resource distribution
  - [ ] Package into WorldMap

- [ ] **LocationSystem class** - Region/city placement
  - [ ] Urban zone identification
  - [ ] Region capital selection
  - [ ] Region expansion (flood fill)
  - [ ] City placement
  - [ ] Name generation

- [ ] **GeoMap wrapper** - System integration
  - [ ] Coordinate all systems
  - [ ] Performance measurement
  - [ ] Time reporting

- [ ] **Tests**
  - [ ] WorldMap unit tests (5 tests)
  - [ ] BiomeSystem unit tests (5 tests)
  - [ ] ProceduralGenerator integration (5 tests)
  - [ ] LocationSystem tests (4 tests)
  - [ ] Performance benchmark (2 tests)

---

## Success Criteria

✅ World generates in <100ms
✅ Biome distribution coherent and deterministic
✅ Resource clustering matches biome types
✅ 15-20 regions with capitals and cities
✅ All locations named deterministically
✅ Memory footprint <1 MB
✅ Seeded generation repeatable
✅ All tests passing (21 tests)
✅ No lint errors
✅ Exit Code 0

---

## Next Phase

Phase 3 (Regional Management) - 15 hours
- Region/country controller system
- Control tracking (player/alien/neutral)
- Infrastructure and economy per region
- Integration with Phase 2 locations

---

**Created:** October 24, 2025
**Phase Start:** October 24, 2025
