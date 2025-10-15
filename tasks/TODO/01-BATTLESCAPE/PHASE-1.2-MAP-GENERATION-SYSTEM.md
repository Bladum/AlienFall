# PHASE 1.2: Map Generation System Implementation
## Procedural Battlescape Map Creation - Week 2

**Phase:** 1 (Foundation Systems)  
**Week:** 2  
**Priority:** CRITICAL  
**Status:** TODO  
**Estimated Time:** 60 hours  
**Created:** October 15, 2025  
**Dependencies:** Phase 1.1 (Geoscape Core - provides biome data)  
**Blocks:** Phase 1.3 (Mission system uses generated maps)

---

## 🎯 Overview

Implement the procedural mission map generation pipeline that converts Geoscape provinces (biome data) into tactical battlescape maps. This bridges strategic layer (where?) to tactical layer (what terrain?).

**Pipeline:** Geoscape Province (Biome) → Terrain Type → MapScript Selection → MapBlock Assembly → Tactical Map

**Core Deliverable:** Players can:
- Launch a mission from Geoscape
- See a procedurally generated 4×7 hex battlefield with appropriate terrain
- See squads placed (player, allies, enemies, civilians)
- Enter battlescape ready to play tactically

### Why This Phase?
- Connects strategic and tactical layers
- Cannot test combat without generated maps
- Mission system depends on working map generation
- Enables full gameplay loop: Geoscape → Mission → Battlescape

---

## 📋 Technical Requirements

### 1. Biome to Terrain Mapping (12 hours)

#### 1.1 Terrain Type System
**Objective:** Define how biomes translate to battlefield terrain types

**Terrain Types:**
- **Grass:** Open, high movement, low cover
- **Forest:** Dense, blocked LOS, high cover, difficult movement
- **Urban:** Buildings, high cover, blocked movement
- **Desert:** Open, difficult movement (sand), low cover
- **Ice:** Slippery movement, dangerous if not careful
- **Swamp:** Difficult movement, flooded terrain
- **Mountain:** Very difficult movement, high elevation
- **Ruin:** Destroyed buildings, lots of partial cover

**Implementation:**
- Create: `engine/battlescape/biome_terrain_mapper.lua`
- Create: `mods/core/data/biome_terrain_mapping.toml`

**Data Structure (TOML):**
```toml
[biome_to_terrain_mapping]

[biome_to_terrain_mapping.temperate]
# Temperate biome generates these terrain distributions
primary = ["grass", "forest"]
secondary = ["urban", "ruin"]
distribution = {grass=0.4, forest=0.3, urban=0.2, ruin=0.1}
elevation_range = [0, 2]  # Height variations
coverage = 0.3  # 30% cover structures

[biome_to_terrain_mapping.desert]
primary = ["desert"]
secondary = ["ruin"]
distribution = {desert=0.8, ruin=0.2}
elevation_range = [0, 1]
coverage = 0.1

[biome_to_terrain_mapping.jungle]
primary = ["forest"]
secondary = ["swamp"]
distribution = {forest=0.6, swamp=0.4}
elevation_range = [0, 2]
coverage = 0.7

[biome_to_terrain_mapping.tundra]
primary = ["ice"]
secondary = ["grass"]
distribution = {ice=0.7, grass=0.3}
elevation_range = [0, 3]  # More elevation variation
coverage = 0.05

[biome_to_terrain_mapping.mountain]
primary = ["mountain"]
secondary = ["forest"]
distribution = {mountain=0.6, forest=0.4}
elevation_range = [1, 4]
coverage = 0.4

[biome_to_terrain_mapping.urban]
primary = ["urban"]
secondary = ["ruin"]
distribution = {urban=0.7, ruin=0.3}
elevation_range = [0, 2]
coverage = 0.6
```

**Algorithm:**
```lua
function BiomeTerrainMapper:generate_terrain_distribution(biome, map_size)
    local mapping = self:load_mapping(biome)
    local distribution = mapping.distribution
    
    -- Generate random terrain distribution for this map
    local terrain_map = {}
    for hex in each_hex(map_size) do
        local rand = math.random()
        local cumulative = 0
        for terrain_type, probability in pairs(distribution) do
            cumulative = cumulative + probability
            if rand <= cumulative then
                terrain_map[hex_key(hex)] = terrain_type
                break
            end
        end
    end
    
    return terrain_map
end
```

**Tests:**
- Verify terrain distribution matches target percentages
- Test all biome mappings
- Test randomness (distributions vary between calls)
- Verify terrain types are valid

#### 1.2 Elevation System
**Objective:** Add height variations for tactical gameplay

**Features:**
- Elevation affects movement cost and LOS
- Range: 0 (sea level) to 4 (mountain peak)
- Influences cover and defensive positions

**Implementation:**
- Modify: `engine/battlescape/terrain_system.lua` (add elevation)
- Reference: `docs/battlescape/combat-mechanics/` (height effects)

**Algorithm:**
```lua
function BiomeTerrainMapper:generate_elevation_map(terrain_map, biome)
    local mapping = self:load_mapping(biome)
    local elevation_range = mapping.elevation_range
    local elevation_map = {}
    
    -- Use Perlin noise for smooth elevation
    local noise = PerlinNoise.new(math.random(10000))
    
    for hex in each_hex_in_map(terrain_map) do
        local raw_noise = noise:at(hex.q / 5, hex.r / 5)  -- Scale noise
        local elevation = math.floor(
            raw_noise * (elevation_range[2] - elevation_range[1]) 
            + elevation_range[1]
        )
        elevation_map[hex_key(hex)] = math.max(0, math.min(4, elevation))
    end
    
    return elevation_map
end
```

**Tests:**
- Test elevation range compliance
- Test noise smoothness (neighbors have similar elevation)
- Test elevation affects movement cost

---

### 2. MapScript Selection (18 hours)

#### 2.1 MapScript System
**Objective:** Select appropriate map scripts based on terrain distribution

**MapScripts:** Pre-made terrain patterns (buildings, walls, vegetation) that get combined

**System:**
- Each MapScript has requirements (e.g., "needs 30-50% forest")
- Generator selects MapScripts that match terrain distribution
- Place multiple MapScripts on map and blend edges

**Implementation:**
- Study: `docs/battlescape/` (existing map generation)
- Reference: `engine/battlescape/mapblock_generator.lua` (MapBlock asset system)
- Create: `engine/battlescape/mapscript_selector.lua`
- Create: `mods/core/data/mapscripts.toml` (MapScript definitions)

**Data Structure (TOML):**
```toml
[mapscript_forest_dense]
name = "Dense Forest"
biome_requirements = ["temperate", "jungle"]
terrain_requirements = {forest=0.4, grass=0.3}  # Min/max percentages
density = 0.7  # How densely packed with assets
cover_rating = 8  # High cover
movement_difficulty = 3  # Hard to move
placement_offset = {x=0, y=0}
asset_list = ["tree", "tree", "log", "shrub", "shrub"]

[mapscript_urban_dense]
name = "Dense Urban"
biome_requirements = ["urban"]
terrain_requirements = {urban=0.6}
density = 0.8
cover_rating = 9
movement_difficulty = 4
asset_list = ["building", "building", "rubble", "barrel"]

[mapscript_clearing]
name = "Forest Clearing"
biome_requirements = ["temperate", "jungle"]
terrain_requirements = {grass=0.7}
density = 0.3
cover_rating = 3
movement_difficulty = 1
asset_list = ["shrub", "log"]
```

**Algorithm:**
```lua
function MapScriptSelector:select_scripts(terrain_distribution, biome)
    local candidates = self:load_scripts_for_biome(biome)
    local selected = {}
    
    for script in ipairs(candidates) do
        if self:matches_requirements(script, terrain_distribution) then
            table.insert(selected, script)
        end
    end
    
    -- Select 2-4 scripts to blend
    local primary = self:select_best_fit(selected, terrain_distribution)
    local secondary = self:select_complementary(selected, primary)
    
    return {primary, secondary}
end
```

**Tests:**
- Verify selected MapScripts match terrain distribution
- Test multiple biomes
- Test that at least 1 script found for each biome

#### 2.2 MapBlock Assembly
**Objective:** Convert selected MapScripts into MapBlock-based battlefield

**Process:**
1. Select MapScript
2. Decompose into MapBlocks (existing asset library)
3. Place MapBlocks on hex grid
4. Handle edge blending (smooth transitions)

**Implementation:**
- Reference: `engine/battlescape/mapblock_system.lua` (existing)
- Create: `engine/battlescape/mapscript_to_mapblock.lua` (converter)
- Modify: `engine/battlescape/map_generator.lua` (orchestrator)

**Algorithm:**
```lua
function MapScriptToMapBlock:decompose_script(script)
    -- MapScript (terrain pattern) → MapBlocks (asset library)
    local mapblocks = {}
    
    for asset in ipairs(script.asset_list) do
        local mapblock = self:find_mapblock_for_asset(asset)
        table.insert(mapblocks, mapblock)
    end
    
    return mapblocks
end

function MapScriptToMapBlock:place_on_grid(scripts, map_size)
    -- Place multiple scripts with blending
    local terrain_map = {}
    
    for script in ipairs(scripts) do
        local mapblocks = self:decompose_script(script)
        local placement = self:calculate_placement(script, mapblocks)
        
        for hex, mapblock in pairs(placement) do
            if not terrain_map[hex_key(hex)] then
                terrain_map[hex_key(hex)] = mapblock
            end
        end
    end
    
    return terrain_map
end
```

**Tests:**
- Test MapBlock availability for all assets
- Test MapBlock placement (no overlaps)
- Test grid coverage

---

### 3. Squad Placement (12 hours)

#### 3.1 Deployment Zones
**Objective:** Calculate where player, allies, enemies, and civilians spawn

**System:**
- Player gets deployment zone (one edge)
- Enemies get opposite edge
- Allies randomly positioned
- Civilians in neutral areas

**Implementation:**
- Create: `engine/battlescape/squad_placement.lua`
- Create: `mods/core/data/placement_rules.toml`

**Algorithm:**
```lua
function SquadPlacement:generate_deployment_zones(terrain_map, mission_type)
    local zones = {}
    
    -- Player zone: South edge, good cover, low elevation
    zones.player = self:find_zone(terrain_map, {
        edges = ["south"],
        cover_rating = {min=3, max=10},
        elevation = {min=0, max=2},
        count = 3  -- 3 hexes for squad
    })
    
    -- Enemy zone: North edge, good cover
    zones.enemy = self:find_zone(terrain_map, {
        edges = ["north"],
        cover_rating = {min=3, max=10},
        elevation = {min=0, max=3},
        count = 3
    })
    
    -- Neutral zones: Forest, buildings (for civilians, missions)
    zones.neutral = self:find_zones(terrain_map, {
        terrain = ["forest", "urban"],
        count = 5
    })
    
    return zones
end

function SquadPlacement:find_zone(terrain_map, requirements)
    -- Find connected hex group matching requirements
    local candidates = {}
    
    for hex in each_hex_in_map(terrain_map) do
        if self:matches_zone_requirements(hex, requirements, terrain_map) then
            table.insert(candidates, hex)
        end
    end
    
    -- Select best connected group
    return self:find_largest_connected_group(candidates)
end
```

**Tests:**
- Verify zones don't overlap
- Test each team gets deployment zone
- Test deployment zones on various terrains

#### 3.2 Unit Spawning
**Objective:** Place actual soldier units in deployment zones

**Features:**
- Configurable squad composition (from mission definition)
- Each unit has position and facing direction
- Units respect terrain walkability

**Implementation:**
- Create: `engine/battlescape/unit_spawning.lua`
- Reference: `docs/battlescape/unit-systems/` (unit definitions)

**Algorithm:**
```lua
function UnitSpawning:spawn_squad(squad_definition, deployment_zone, terrain_map)
    local units = {}
    local zone_hexes = list_hexes_in_zone(deployment_zone)
    
    for i, unit_template in ipairs(squad_definition.units) do
        local spawn_hex = zone_hexes[((i-1) % #zone_hexes) + 1]
        local unit = self:create_unit(unit_template)
        
        unit.hex = spawn_hex
        unit.facing = self:calculate_facing(spawn_hex, deployment_zone)
        unit.elevation = terrain_map[hex_key(spawn_hex)].elevation
        
        table.insert(units, unit)
    end
    
    return units
end
```

**Tests:**
- Test unit placement in deployment zones
- Test units don't overlap
- Test correct team assignment

---

### 4. Map Generation Orchestration (12 hours)

#### 4.1 Complete Pipeline
**Objective:** Integrate all systems into one map generator

**Flowchart:**
```
Province (Biome) 
    ↓
[BiomeTerrainMapper]
    ↓
Terrain Distribution + Elevation
    ↓
[MapScriptSelector]
    ↓
MapScript Selection
    ↓
[MapScriptToMapBlock]
    ↓
MapBlock Grid
    ↓
[SquadPlacement]
    ↓
Deployment Zones
    ↓
[UnitSpawning]
    ↓
Complete Tactical Map (Ready for Battle)
```

**Implementation:**
- Create: `engine/battlescape/map_generator.lua` (orchestrator)
- Main function: `MapGenerator:generate(biome, mission_type, difficulty)`

**Algorithm:**
```lua
function MapGenerator:generate(biome, mission_type, difficulty)
    print("[MapGenerator] Starting map generation for " .. biome)
    
    -- Step 1: Terrain distribution
    local terrain_dist = self:generate_terrain_distribution(biome)
    local elevation = self:generate_elevation_map(terrain_dist)
    print("[MapGenerator] Terrain generated")
    
    -- Step 2: MapScript selection
    local scripts = self.script_selector:select_scripts(terrain_dist, biome)
    print("[MapGenerator] Selected " .. #scripts .. " MapScripts")
    
    -- Step 3: MapBlock assembly
    local mapblock_grid = self.script_converter:place_on_grid(scripts, 7, 4)
    print("[MapGenerator] MapBlocks placed")
    
    -- Step 4: Deployment zones
    local zones = self.placement:generate_deployment_zones(mapblock_grid, mission_type)
    print("[MapGenerator] Deployment zones created")
    
    -- Step 5: Unit spawning
    local player_units = self.spawning:spawn_squad(mission_type.player_squad, zones.player)
    local enemy_units = self.spawning:spawn_squad(mission_type.enemy_squad, zones.enemy)
    print("[MapGenerator] Units spawned: " .. #player_units .. " player, " .. #enemy_units .. " enemy")
    
    local map = {
        biome = biome,
        terrain = terrain_dist,
        elevation = elevation,
        mapblocks = mapblock_grid,
        player_units = player_units,
        enemy_units = enemy_units,
        zones = zones,
    }
    
    print("[MapGenerator] Map generation complete")
    return map
end
```

#### 4.2 Performance Optimization
**Objective:** Generation should complete in <2 seconds

**Targets:**
- Biome→Terrain: <100ms
- MapScript selection: <50ms
- MapBlock placement: <200ms
- Squad placement: <100ms
- Unit spawning: <50ms
- **Total: <1 second**

**Implementation:**
- Cache MapScript definitions
- Pre-calculate biome mappings
- Use lookup tables instead of searches
- Measure execution time

**Code:**
```lua
function MapGenerator:generate(biome, mission_type, difficulty)
    local start_time = love.timer.getTime()
    
    local map = {
        -- ... generation steps ...
    }
    
    local elapsed = love.timer.getTime() - start_time
    print("[Performance] Map generated in " .. elapsed .. "s")
    
    assert(elapsed < 2, "Generation took too long: " .. elapsed .. "s")
    
    return map
end
```

**Tests:**
- Measure generation time for 100 maps
- Verify <2 second target
- Profile bottlenecks

---

### 5. Integration with Battlescape (6 hours)

#### 5.1 Mission Launching
**Objective:** Launch tactical battle with generated map

**Flow:**
1. Player selects mission in Geoscape
2. System generates map for that mission
3. Transition to Battlescape
4. Load generated map and render it
5. Display unit placement and wait for player input

**Implementation:**
- Modify: `engine/geoscape/mission_system.lua` (call generator)
- Modify: `engine/battlescape/battle_manager.lua` (load generated map)
- Reference: `engine/scenes/` (scene transitions)

**Code:**
```lua
function MissionSystem:launch_mission(mission_id)
    print("[Mission] Launching mission: " .. mission_id)
    
    -- Load mission definition
    local mission = self:load_mission_definition(mission_id)
    
    -- Generate map
    local map = self.map_generator:generate(
        mission.biome,
        mission.type,
        mission.difficulty
    )
    
    -- Verify map
    assert(map.mapblocks, "Map has no terrain")
    assert(#map.player_units > 0, "Map has no player units")
    assert(#map.enemy_units > 0, "Map has no enemies")
    
    -- Transition to battlescape with generated map
    self.state_manager:transition("battlescape", {map = map, mission = mission})
end
```

**Tests:**
- Test mission launch
- Test map loaded in battlescape
- Test units visible and positioned

---

## 🔄 Integration with Phase 1.1

**Dependencies from Geoscape Core:**
- Biome definitions (temperate, desert, jungle, etc.)
- Province data structure
- Province→Biome lookup

**Data passed from Geoscape:**
- Selected province object
- Biome classification
- Mission type and difficulty

**Integration Point:**
```lua
-- In geoscape_scene.lua
function on_mission_selected(mission)
    local province = get_selected_province()
    local biome = province.biome
    
    -- Generate map for this biome
    local map = map_generator:generate(biome, mission.type, mission.difficulty)
    
    -- Transition to battlescape
    transition_to_battlescape(map)
end
```

---

## 📊 Testing Strategy

### Unit Tests
```lua
-- tests/battlescape/test_map_generation.lua
function test_biome_terrain_mapping()
    local mapper = BiomeTerrainMapper.new()
    local dist = mapper:generate_terrain_distribution("temperate", {7, 4})
    
    assert(dist.forest + dist.grass + dist.urban + dist.ruin == 28)
    assert(dist.forest >= 8 and dist.forest <= 14)  -- ~40%
    assert(dist.grass >= 7 and dist.grass <= 12)    -- ~30%
end

function test_mapscript_selection()
    local selector = MapScriptSelector.new()
    local scripts = selector:select_scripts({forest=0.4, grass=0.3}, "temperate")
    
    assert(scripts, "Should find scripts")
    assert(#scripts > 0, "Should select at least one script")
end

function test_squad_placement()
    local placement = SquadPlacement.new()
    local zones = placement:generate_deployment_zones(terrain_map, "site_investigation")
    
    assert(zones.player, "Player zone required")
    assert(zones.enemy, "Enemy zone required")
    assert(zones.player ~= zones.enemy, "Zones should not overlap")
end
```

### Integration Tests
```lua
-- tests/integration/test_map_generation_flow.lua
function test_complete_map_generation()
    local gen = MapGenerator.new()
    local map = gen:generate("temperate", "site_investigation", 1)
    
    assert(map.mapblocks, "Map has terrain")
    assert(#map.player_units == 4, "Player squad spawned")
    assert(#map.enemy_units == 3, "Enemy squad spawned")
    assert(#map.player_units + #map.enemy_units == 7, "Correct total")
end

function test_multiple_biomes()
    local gen = MapGenerator.new()
    for biome in ipairs({"temperate", "desert", "jungle", "tundra"}) do
        local map = gen:generate(biome, "site_investigation", 1)
        assert(map, "Should generate map for " .. biome)
    end
end
```

### Manual Testing
```
1. In Geoscape, click "Launch Mission"
2. Check console for generation time (<2 seconds)
3. Map loads in Battlescape with generated terrain
4. Verify:
   - [ ] Terrain matches biome (forest for jungle, desert for desert, etc.)
   - [ ] Squad placement visible
   - [ ] No unit overlaps
   - [ ] Cover structures present
   - [ ] Elevation visible
   - [ ] Map renders at >60 FPS
```

---

## 📦 Deliverables

### Code Files
- `engine/battlescape/biome_terrain_mapper.lua` - Biome→Terrain conversion
- `engine/battlescape/mapscript_selector.lua` - MapScript selection
- `engine/battlescape/mapscript_to_mapblock.lua` - Asset assembly
- `engine/battlescape/squad_placement.lua` - Deployment zone calculation
- `engine/battlescape/unit_spawning.lua` - Unit placement
- `engine/battlescape/map_generator.lua` - Orchestrator (main entry point)
- `engine/battlescape/elevation_system.lua` - Height handling (new or extend existing)

### Data Files
- `mods/core/data/biome_terrain_mapping.toml` - Biome→Terrain rules
- `mods/core/data/mapscripts.toml` - MapScript definitions (30-50 scripts)
- `mods/core/data/placement_rules.toml` - Squad placement rules
- `mods/core/data/mission_definitions.toml` - Mission templates

### Tests
- `tests/battlescape/test_biome_terrain_mapper.lua`
- `tests/battlescape/test_mapscript_selector.lua`
- `tests/battlescape/test_mapscript_to_mapblock.lua`
- `tests/battlescape/test_squad_placement.lua`
- `tests/battlescape/test_unit_spawning.lua`
- `tests/battlescape/test_map_generator.lua`
- `tests/integration/test_map_generation_flow.lua`

### Documentation
- Create: `docs/battlescape/map_generation.md` - System overview
- Create: `docs/battlescape/mapscript_system.md` - MapScript format
- Update: `docs/API.md` - Add MapGenerator API

---

## 🎬 How to Run & Debug

### Console Commands
```lua
-- Generate test map without launching mission
local gen = MapGenerator.new()
local map = gen:generate("temperate", "site_investigation", 1)
print("Generated map with " .. #map.player_units .. " player units")

-- Benchmark generation
local times = {}
for i=1,10 do
    local start = love.timer.getTime()
    gen:generate("temperate", "site_investigation", 1)
    table.insert(times, love.timer.getTime() - start)
end
print("Average generation time: " .. (sum(times) / #times) .. "s")
```

### Expected Output
```
[MapGenerator] Starting map generation for temperate
[MapGenerator] Terrain generated (temperate: 40% forest, 30% grass, 20% urban)
[MapGenerator] Selected 2 MapScripts (Dense Forest + Clearing)
[MapGenerator] MapBlocks placed (28 tiles)
[MapGenerator] Deployment zones created
[MapGenerator] Units spawned: 4 player, 3 enemy
[MapGenerator] Map generation complete (0.87s)
```

---

## ✅ Success Criteria

### Functional
- [x] Generates 4×7 hex battlefield from any biome
- [x] Terrain matches biome characteristics
- [x] Squad placement in non-overlapping zones
- [x] Units visible in battlescape
- [x] Can launch mission from geoscape and see generated map

### Performance
- [x] Map generation completes in <2 seconds
- [x] Pathfinding <500ms
- [x] MapBlock rendering >60 FPS
- [x] Memory usage <50MB per generated map

### Code Quality
- [x] All functions documented
- [x] Follows code standards
- [x] Unit tests pass
- [x] No console errors

---

## 📈 Milestone Validation

**Milestone:** Geoscape→Battlescape pipeline functional

**Verification:**
1. Select mission in Geoscape
2. Map generates (console shows <2s)
3. Transition to Battlescape
4. See generated terrain and units
5. Can proceed to combat

**Estimated Completion:** 60 hours (3.75 days at 16 hours/day)

---

**Status:** TODO - Depends on Phase 1.1  
**Next Phase:** 1.3 Mission Detection & Campaign Loop  
**Enables:** Full gameplay loop (Strategic → Tactical)

---

*Part of MASTER-IMPLEMENTATION-PLAN.md*  
*Created: October 15, 2025*  
*Phase 1 Week 2 Foundation Task*
