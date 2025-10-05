# Map Generation Pipeline

## Table of Contents
- [Overview](#overview)
- [Pipeline Stages](#pipeline-stages)
- [Related Wiki Pages](#related-wiki-pages)

## Overview

The Map Generation Pipeline integration document defines the procedural generation workflow for creating battlescape tactical maps from mission parameters, biome definitions, and terrain rules, transforming high-level mission specifications into playable combat environments with deterministic seed-based generation.  
**Related Systems:** Geoscape, Procedural Generation, Battlescape, World System

---

## Purpose

This document describes the **complete pipeline** for generating battle maps in AlienFall, from strategic province selection down to individual tactical tiles. Understanding this flow is essential for map generation, mission design, and biome/terrain integration.

**Key Insight:** Maps are generated through a 5-stage hierarchical process, each stage deriving from the previous one using deterministic seeds.

---

## Pipeline Overview

### Five-Stage Process

```
┌─────────────┐
│  PROVINCE   │ ← Strategic layer (Geoscape)
└──────┬──────┘
       │ Location context
       ↓
┌─────────────┐
│    BIOME    │ ← Climate + Terrain type
└──────┬──────┘
       │ Environmental rules
       ↓
┌─────────────┐
│   TERRAIN   │ ← Specific terrain features
└──────┬──────┘
       │ Tile palette + rules
       ↓
┌─────────────┐
│ MAP BLOCKS  │ ← Pre-fab map segments
└──────┬──────┘
       │ Block placement + stitching
       ↓
┌─────────────┐
│BATTLE TILES │ ← Final tactical grid
└─────────────┘
```

### Data Flow Summary

| Stage | Input | Output | Purpose |
|-------|-------|--------|---------|
| **Province** | Mission location (x, y) | Province type, climate zone | Strategic context |
| **Biome** | Province + Climate | Biome definition (Desert, Forest, etc.) | Environmental theme |
| **Terrain** | Biome + Mission type | Terrain features (rocks, trees, buildings) | Tactical variety |
| **Map Blocks** | Terrain palette + Layout seed | Pre-fab block arrangement | Map structure |
| **Battle Tiles** | Map blocks + Smoothing | Final tile grid (32×24 visible) | Playable battlefield |

---

## Stage 1: Province Selection

### Input Context

**Mission Location:**
```lua
mission = {
    location = {
        x = 145,  -- World coordinate (0-359 longitude)
        y = 67    -- World coordinate (0-179 latitude)
    },
    type = "terror"  -- Mission type
}
```

**Province Lookup:**
```lua
function get_province_at_location(world, x, y)
    for _, province in ipairs(world.provinces) do
        if point_in_polygon(x, y, province.boundary) then
            return province
        end
    end
    return world.ocean_province  -- Default for ocean tiles
end
```

### Province Data

**Province Structure:**
```lua
province = {
    id = 42,
    name = "Central Europe",
    type = "urban",  -- urban, rural, wilderness, polar, ocean
    climate_zone = "temperate",  -- tropical, temperate, polar
    population = 85000000,
    technology_level = 4,  -- 1-5 scale
    boundary = {...}  -- Polygon vertices
}
```

**Climate Zones:**
- **Tropical:** Equatorial regions (0-23° latitude)
- **Temperate:** Mid-latitude regions (23-66° latitude)
- **Polar:** Arctic/Antarctic regions (66-90° latitude)

**Province Types:**
- **Urban:** Cities, high population density
- **Rural:** Farmland, small towns
- **Wilderness:** Forests, deserts, mountains
- **Polar:** Tundra, ice sheets
- **Ocean:** Water bodies (special handling)

### Output

```lua
stage1_output = {
    province = province,
    climate = "temperate",
    province_type = "urban"
}
```

---

## Stage 2: Biome Selection

### Biome Determination

**Mapping Logic:**
```lua
function determine_biome(province_type, climate_zone, mission_type)
    local biome_table = {
        urban = {
            tropical = "tropical_city",
            temperate = "temperate_city",
            polar = "arctic_outpost"
        },
        rural = {
            tropical = "jungle",
            temperate = "farmland",
            polar = "tundra"
        },
        wilderness = {
            tropical = "rainforest",
            temperate = "forest",
            polar = "ice_field"
        },
        ocean = {
            tropical = "tropical_island",
            temperate = "coastal",
            polar = "ice_shelf"
        }
    }
    
    local biome_name = biome_table[province_type][climate_zone]
    
    -- Special overrides for mission types
    if mission_type == "ufo_crash" then
        biome_name = biome_name .. "_crash"
    elseif mission_type == "alien_base" then
        biome_name = "alien_base_interior"  -- Interior overrides biome
    end
    
    return load_biome_definition(biome_name)
end
```

### Biome Definitions

**Biome Structure:**
```toml
# data/biomes/temperate_city.toml

[biome]
name = "Temperate City"
climate = "temperate"
terrain_types = ["concrete", "asphalt", "building_wall", "glass", "metal"]
cover_density = "high"  # low, medium, high
lighting = "artificial"  # natural, artificial, mixed
ambient_sound = "city_ambience"

[terrain_palette]
floor_tiles = ["concrete_01", "concrete_02", "asphalt_01", "asphalt_cracked"]
wall_tiles = ["brick_wall", "glass_window", "metal_panel"]
object_tiles = ["car", "dumpster", "street_light", "fire_hydrant"]
cover_tiles = ["concrete_barrier", "mailbox", "parked_car"]

[generation_rules]
object_density = 0.15  # 15% of tiles have objects
cover_density = 0.25   # 25% of tiles provide cover
wall_density = 0.30    # 30% of tiles are walls/buildings
path_width = 2         # Minimum 2-tile wide paths
```

### Biome Categories

**Natural Biomes:**
- `forest` - Temperate woodland
- `jungle` - Tropical rainforest
- `desert` - Arid wasteland
- `tundra` - Arctic plains
- `mountains` - Rocky highlands
- `swamp` - Wetlands

**Urban Biomes:**
- `temperate_city` - Modern city
- `tropical_city` - Tropical metropolis
- `industrial` - Factory district
- `slums` - Dense low-income housing
- `suburbs` - Residential area

**Special Biomes:**
- `alien_base_interior` - UFO/base interior
- `military_base` - Human military facility
- `ufo_crash` - Crash site (any terrain + wreckage)

### Output

```lua
stage2_output = {
    biome = biome_definition,
    terrain_palette = biome.terrain_palette,
    generation_rules = biome.generation_rules
}
```

---

## Stage 3: Terrain Feature Selection

### Terrain Layer

**Feature Categories:**
```lua
terrain_features = {
    floor = {},      -- Base ground tiles
    walls = {},      -- Impassable vertical structures
    cover = {},      -- Half-cover/full-cover objects
    objects = {},    -- Interactive/destructible objects
    decorations = {} -- Pure visual elements
}
```

**Feature Placement:**
```lua
function select_terrain_features(biome, mission_type, map_seed)
    local rng = love.math.newRandomGenerator(map_seed)
    
    local features = {
        floor = weighted_sample(biome.terrain_palette.floor_tiles, rng),
        walls = weighted_sample(biome.terrain_palette.wall_tiles, rng),
        cover = weighted_sample(biome.terrain_palette.cover_tiles, rng),
        objects = weighted_sample(biome.terrain_palette.object_tiles, rng)
    }
    
    -- Mission-specific additions
    if mission_type == "terror" then
        table.insert(features.objects, "civilian")
    elseif mission_type == "ufo_crash" then
        table.insert(features.objects, "ufo_debris")
    end
    
    return features
end
```

### Terrain Rules

**Placement Constraints:**
```lua
terrain_rules = {
    min_path_width = 2,        -- Minimum 2 tiles wide for corridors
    max_wall_length = 8,       -- Break up long walls
    cover_spacing = 3,         -- Min 3 tiles between cover
    object_density = 0.15,     -- 15% of floor tiles
    LOS_blocking_ratio = 0.30  -- 30% of tiles block line of sight
}
```

**Tactical Considerations:**
```lua
function validate_tactical_layout(map, rules)
    -- Ensure minimum 50% of map is accessible
    local accessible = count_accessible_tiles(map)
    assert(accessible / map.total_tiles >= 0.5, "Map too cramped")
    
    -- Ensure no single cover dominates (max 40% of cover)
    local cover_distribution = analyze_cover_distribution(map)
    assert(max(cover_distribution) <= 0.4, "Cover too homogeneous")
    
    -- Ensure flanking routes exist (multiple paths between key points)
    local path_count = count_alternate_paths(map, key_points)
    assert(path_count >= 2, "No flanking routes")
end
```

### Output

```lua
stage3_output = {
    terrain_features = terrain_features,
    placement_rules = terrain_rules,
    tactical_constraints = tactical_validation_rules
}
```

---

## Stage 4: Map Block Assembly

### Map Block System

**Pre-Fabricated Blocks:**
```
Map Block = 8×8 tile segment with predefined layout
Full Map = 32×24 tiles = 4×3 grid of blocks (12 blocks total)
```

**Block Types:**
```lua
block_types = {
    "open",          -- Open ground, minimal cover
    "dense",         -- Heavy cover, many obstacles
    "corridor",      -- Linear path with side rooms
    "room_large",    -- Large open room
    "room_small",    -- Small enclosed room
    "junction",      -- Intersection/crossroads
    "entrance",      -- Map edge entry point
    "objective"      -- Mission objective location
}
```

**Block Library:**
```toml
# data/map_blocks/temperate_city/dense_01.toml

[block]
type = "dense"
biome = "temperate_city"
size = [8, 8]
valid_edges = ["north", "south", "east", "west"]  # Which edges can connect

[layout]
# . = floor, # = wall, C = cover, O = object
grid = [
    "########",
    "#......#",
    "#.CC...#",
    "#.O....#",
    "#...CC.#",
    "#......#",
    "#......#",
    "########"
]

[connections]
north = {x = 4, y = 0, type = "door"}
south = {x = 4, y = 7, type = "door"}
east = {x = 7, y = 4, type = "opening"}
west = {x = 0, y = 4, type = "opening"}
```

### Block Selection Algorithm

**Wave Function Collapse:**
```lua
function generate_map_layout(biome, mission_type, map_seed)
    local rng = love.math.newRandomGenerator(map_seed)
    local grid = {4, 3}  -- 4 wide, 3 tall (32×24 tiles)
    local blocks = {}
    
    -- Initialize with all possibilities
    for x = 1, grid[1] do
        blocks[x] = {}
        for y = 1, grid[2] do
            blocks[x][y] = get_compatible_blocks(biome)
        end
    end
    
    -- Place mandatory blocks first
    place_objective_block(blocks, mission_type, rng)
    place_entrance_blocks(blocks, rng)
    
    -- Collapse remaining cells
    while not all_collapsed(blocks) do
        local cell = select_lowest_entropy_cell(blocks)
        local chosen_block = collapse_cell(cell, rng)
        propagate_constraints(blocks, cell, chosen_block)
    end
    
    return blocks
end
```

**Constraint Propagation:**
```lua
function propagate_constraints(blocks, x, y, chosen_block)
    -- North neighbor
    if y > 1 and chosen_block.connections.north then
        remove_incompatible(blocks[x][y-1], "south", chosen_block.connections.north.type)
    end
    
    -- South neighbor
    if y < 3 and chosen_block.connections.south then
        remove_incompatible(blocks[x][y+1], "north", chosen_block.connections.south.type)
    end
    
    -- East/West similar...
end
```

### Block Stitching

**Seamless Connections:**
```lua
function stitch_blocks(block_grid, biome)
    local final_map = create_empty_map(32, 24)
    
    for block_x = 1, 4 do
        for block_y = 1, 3 do
            local block = block_grid[block_x][block_y]
            local tile_x = (block_x - 1) * 8
            local tile_y = (block_y - 1) * 8
            
            -- Copy block tiles to final map
            copy_block_to_map(final_map, block, tile_x, tile_y)
            
            -- Smooth connections between blocks
            if block_x < 4 then
                smooth_edge(final_map, tile_x + 7, tile_y, "vertical")
            end
            if block_y < 3 then
                smooth_edge(final_map, tile_x, tile_y + 7, "horizontal")
            end
        end
    end
    
    return final_map
end
```

### Output

```lua
stage4_output = {
    map_layout = block_grid,  -- 4×3 grid of blocks
    block_data = block_definitions,
    stitched_map = final_map  -- 32×24 tile grid
}
```

---

## Stage 5: Battle Tile Finalization

### Tile Assignment

**Tile Type Resolution:**
```lua
function finalize_battle_tiles(map, terrain_features)
    local battle_map = {}
    
    for y = 1, 24 do
        battle_map[y] = {}
        for x = 1, 32 do
            local tile_char = map[y][x]
            
            if tile_char == '.' then
                battle_map[y][x] = create_floor_tile(terrain_features.floor, x, y)
            elseif tile_char == '#' then
                battle_map[y][x] = create_wall_tile(terrain_features.walls, x, y)
            elseif tile_char == 'C' then
                battle_map[y][x] = create_cover_tile(terrain_features.cover, x, y)
            elseif tile_char == 'O' then
                battle_map[y][x] = create_object_tile(terrain_features.objects, x, y)
            end
        end
    end
    
    return battle_map
end
```

**Tile Properties:**
```lua
tile = {
    x = 10,
    y = 15,
    type = "floor",        -- floor, wall, cover, object
    sprite_id = "concrete_01",
    passable = true,
    cover_value = 0,       -- 0 = none, 50 = half, 100 = full
    blocks_los = false,
    height = 0,            -- Elevation (0 = ground level)
    destructible = false,
    health = nil           -- nil if indestructible
}
```

### Smoothing and Polish

**Tile Variation:**
```lua
function add_tile_variation(battle_map, rng)
    for y = 1, 24 do
        for x = 1, 32 do
            local tile = battle_map[y][x]
            
            -- Add visual variety (doesn't affect gameplay)
            if tile.type == "floor" then
                tile.rotation = rng:random(0, 3) * 90  -- Random rotation
                tile.variant = rng:random(1, 4)        -- Texture variant
            end
        end
    end
end
```

**Edge Smoothing:**
```lua
function smooth_tile_edges(battle_map)
    for y = 1, 24 do
        for x = 1, 32 do
            local tile = battle_map[y][x]
            
            -- Use autotiling for walls
            if tile.type == "wall" then
                tile.autotile_index = calculate_autotile(battle_map, x, y)
            end
        end
    end
end
```

**Autotiling:**
```
Autotile Index (bitmasked):
North = 1, East = 2, South = 4, West = 8

Example: Tile with walls on North and East = 1 + 2 = 3
Sprite sheet uses index 3 for that corner configuration
```

### Spawn Point Placement

**Unit Spawns:**
```lua
function place_spawn_points(battle_map, mission)
    -- Player spawn (entrance side)
    local player_spawns = find_entrance_tiles(battle_map, "south")
    mission.player_spawn_zone = select_spawn_area(player_spawns, 8)  -- 8 units
    
    -- Enemy spawns (distributed)
    local enemy_spawns = find_open_tiles(battle_map, mission.enemy_count)
    mission.enemy_spawn_points = filter_tactical_positions(enemy_spawns)
    
    -- Objective markers
    if mission.type == "terror" then
        mission.civilian_spawns = find_civilian_locations(battle_map, 10)
    elseif mission.type == "ufo_crash" then
        mission.ufo_location = find_crash_site(battle_map)
    end
end
```

### Output

```lua
stage5_output = {
    battle_map = finalized_battle_map,  -- 32×24 tactical grid
    spawn_points = {
        player = player_spawn_zone,
        enemies = enemy_spawn_points,
        civilians = civilian_spawns or nil,
        objectives = objective_markers or nil
    },
    metadata = {
        biome = biome_name,
        province = province_name,
        seed = map_seed
    }
}
```

---

## Complete Pipeline Example

### From Mission to Map

```lua
function generate_mission_map(world, mission)
    -- Stage 1: Province Selection
    local province = get_province_at_location(world, mission.location.x, mission.location.y)
    print("Province: " .. province.name .. " (" .. province.type .. ", " .. province.climate_zone .. ")")
    
    -- Stage 2: Biome Determination
    local biome = determine_biome(province.type, province.climate_zone, mission.type)
    print("Biome: " .. biome.name)
    
    -- Stage 3: Terrain Feature Selection
    local map_seed = derive_seed(mission.seed, hash("map"))
    local terrain = select_terrain_features(biome, mission.type, map_seed)
    print("Terrain Features: " .. #terrain.objects .. " objects, " .. #terrain.cover .. " cover types")
    
    -- Stage 4: Map Block Assembly
    local block_seed = derive_seed(map_seed, hash("blocks"))
    local block_layout = generate_map_layout(biome, mission.type, block_seed)
    local stitched_map = stitch_blocks(block_layout, biome)
    print("Map Layout: " .. count_blocks(block_layout) .. " blocks assembled")
    
    -- Stage 5: Battle Tile Finalization
    local battle_map = finalize_battle_tiles(stitched_map, terrain)
    local tile_seed = derive_seed(map_seed, hash("tiles"))
    local rng = love.math.newRandomGenerator(tile_seed)
    add_tile_variation(battle_map, rng)
    smooth_tile_edges(battle_map)
    place_spawn_points(battle_map, mission)
    print("Battle Map: 32×24 tiles finalized")
    
    -- Return complete mission data
    return {
        map = battle_map,
        province = province,
        biome = biome,
        spawns = mission.player_spawn_zone,
        enemies = mission.enemy_spawn_points,
        seed = mission.seed
    }
end
```

### Console Output Example

```
Generating mission map...
Province: Central Europe (urban, temperate)
Biome: Temperate City
Terrain Features: 12 objects, 5 cover types
Map Layout: 12 blocks assembled
Battle Map: 32×24 tiles finalized
Player Spawn: 8 positions at [South edge]
Enemy Spawn: 6 positions distributed
Mission ready!
```

---

## Debugging and Validation

### Visualization Tools

**Block Layout Viewer:**
```lua
function visualize_block_layout(block_grid)
    print("Map Block Layout (4×3):")
    for y = 1, 3 do
        local row = ""
        for x = 1, 4 do
            local block = block_grid[x][y]
            row = row .. string.format("[%-10s]", block.type)
        end
        print(row)
    end
end
```

**Tile Map ASCII Dump:**
```lua
function dump_tile_map_ascii(battle_map)
    for y = 1, 24 do
        local row = ""
        for x = 1, 32 do
            local tile = battle_map[y][x]
            if tile.type == "floor" then row = row .. "."
            elseif tile.type == "wall" then row = row .. "#"
            elseif tile.type == "cover" then row = row .. "C"
            else row = row .. "O"
            end
        end
        print(row)
    end
end
```

### Validation Checks

**Map Quality Assurance:**
```lua
function validate_map_quality(battle_map, spawns)
    local issues = {}
    
    -- Check accessibility
    local accessible = flood_fill(battle_map, spawns.player[1])
    if accessible < 384 then  -- Less than 50% of 768 tiles
        table.insert(issues, "Map too cramped: only " .. accessible .. " accessible tiles")
    end
    
    -- Check spawn safety
    for _, spawn in ipairs(spawns.player) do
        local nearby_cover = count_cover_in_radius(battle_map, spawn, 3)
        if nearby_cover < 2 then
            table.insert(issues, "Player spawn lacks cover at " .. spawn.x .. "," .. spawn.y)
        end
    end
    
    -- Check tactical balance
    local cover_ratio = count_cover_tiles(battle_map) / 768
    if cover_ratio < 0.15 then
        table.insert(issues, "Insufficient cover: " .. (cover_ratio * 100) .. "%")
    elseif cover_ratio > 0.40 then
        table.insert(issues, "Excessive cover: " .. (cover_ratio * 100) .. "%")
    end
    
    return issues
end
```

---

## Cross-References

**Related Systems:**
- [Geoscape World System](../geoscape/World.md) - Province structure and climate zones
- [Biomes](../geoscape/Climate_zones.md) - Biome definitions and environmental rules
- [Procedural Generation](../procedure/README.md) - Algorithms for map generation
- [Battlescape](../battlescape/README.md) - Tactical map rendering and gameplay
- [Determinism](../technical/Determinism.md) - Seed-based generation for reproducibility

**Implementation Files:**
- `src/procedure/map_generator.lua` - Main map generation pipeline
- `src/procedure/biome_mapper.lua` - Biome selection logic
- `src/procedure/block_assembler.lua` - Map block system
- `data/biomes/*.toml` - Biome definitions
- `data/map_blocks/**/*.toml` - Pre-fabricated map blocks

---

## Version History

- **v1.0 (2025-09-30):** Initial integration document defining 5-stage map generation pipeline
