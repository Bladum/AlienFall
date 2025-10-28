# add_map_script

Create or update procedural map generation script definitions in TOML format.

## Prefix
`mapscript_`

## Task Type
Content Creation / Modification

## Description
Create or update map script entries in `mods/core/mapscripts/` folder. Map scripts define procedural generation rules for creating dynamic tactical maps with terrain variation, object placement, and difficulty scaling.

## Inputs

### Required
- **Map Script ID**: Unique identifier (e.g., `script_urban_procedural`, `script_forest_biome`)
- **Script Name**: Display name for UI
- **Generation Type**: Category - `biome_based`, `urban`, `rural`, `alien`, `cave`, `hybrid`
- **Description**: What the script generates

### Optional
- **Generation Rules**: Procedural generation algorithms
- **Tile Distribution**: Terrain frequency rules
- **Object Placement**: How objects are distributed
- **Difficulty Parameters**: Scaling with difficulty
- **Variation Parameters**: Randomization settings
- **Constraints**: Hard rules for generation

## Scope

### Affected Files
- `mods/core/mapscripts/*.toml` (individual scripts)
- Related: Terrain definitions
- Related: Mapblock definitions (as fallback/reference)
- Related: Biome definitions

### Validation
- ✓ Script ID is unique
- ✓ All required TOML fields present
- ✓ Generation type matches valid category
- ✓ Terrain references exist
- ✓ Object references exist
- ✓ Probability values between 0-1
- ✓ Generation parameters are reasonable

## TOML Structure Template

```toml
[metadata]
id = "script_id"
name = "Map Script Display Name"
description = "Description of what this script generates"
generation_type = "biome_based|urban|rural|alien|cave|hybrid"
applicable_biomes = ["biome_id"]
author = "Creator Name"
version = "1.0.0"

[grid]
min_width = 15
max_width = 25
min_height = 15
max_height = 25
tile_size = 1

[terrain_generation]
primary_terrain = "terrain_id"
primary_frequency = 0.7
secondary_terrain = "terrain_id"
secondary_frequency = 0.2
tertiary_terrain = "terrain_id"
tertiary_frequency = 0.1

[terrain_rules]
terrain_clusters = true
cluster_size = 3
cluster_frequency = 0.3
erosion_enabled = true
smoothing_passes = 2

[obstacle_placement]
obstacle_density_base = 0.15
obstacle_density_min = 0.05
obstacle_density_max = 0.30
obstacle_types = ["terrain_id"]
clustered_obstacles = true

[[obstacles]]
type = "terrain_id"
probability = 0.4
min_count = 2
max_count = 8
clustering_radius = 3

[[obstacles]]
type = "terrain_id"
probability = 0.3
min_count = 1
max_count = 5

[object_placement]
object_density_base = 0.1
min_objects = 1
max_objects = 10
object_types = ["object_id"]

[[objects]]
object_id = "prop_id"
placement_probability = 0.3
min_count = 1
max_count = 3
prefer_near_spawn = false

[hazard_generation]
hazard_enabled = true
hazard_density = 0.05
hazard_types = ["fire", "toxic"]
hazard_clustering = true

[spawn_area]
player_spawn_distance = 5
enemy_spawn_distance = 5
spawn_area_padding = 2
spawn_area_clearance = true

[difficulty_scaling]
difficulty_min = 0.5
difficulty_max = 2.0
difficulty_affects_density = true
difficulty_affects_hazards = true
density_scaling_factor = 0.1

[constraints]
minimum_open_area = 0.2
maximum_wall_density = 0.5
accessible_area_minimum = 0.4
impassable_threshold = 0.7

[variation]
random_seed_base = 0
variation_amount = 0.3
placement_randomness = 0.5
terrain_transition_smoothness = 0.7
```

## Outputs

### Created/Modified
- Map script entry with generation rules
- Terrain distribution configured
- Object and hazard placement defined
- Difficulty scaling established
- Variation parameters set

### Validation Report
- ✓ TOML syntax verified
- ✓ Script ID uniqueness confirmed
- ✓ All terrain/object references valid
- ✓ Probability values valid (0-1)
- ✓ Difficulty scaling reasonable
- ✓ Generation parameters balanced
- ✓ Constraints satisfiable

## Process

1. **Define Generator Type**: Establish generation style
2. **Set Terrain Rules**: Configure primary/secondary terrain
3. **Add Obstacles**: Define obstacle placement
4. **Place Objects**: Configure interactive objects
5. **Add Hazards**: Set environmental threats
6. **Configure Scaling**: Set difficulty adjustments
7. **Set Constraints**: Define hard generation rules
8. **Validate**: Check TOML and generation logic
9. **Test**: Generate maps multiple times and verify variety
10. **Document**: Update map script documentation

## Testing Checklist

- [ ] Script loads without errors
- [ ] Maps generate successfully
- [ ] Generated maps are walkable
- [ ] Terrain variety is good
- [ ] Objects placed appropriately
- [ ] Hazards placed correctly
- [ ] Spawn areas are clear
- [ ] Difficulty scaling works
- [ ] Maps have good variation
- [ ] Performance is acceptable
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Multiple generations produce different maps

## References

- API: `docs/battlescape/map-generation/`
- Examples: `mods/core/mapscripts/`
- Balance Guide: `docs/battlescape/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
