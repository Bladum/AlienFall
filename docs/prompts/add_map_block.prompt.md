# add_map_block

Create or update individual map block definitions in TOML format.

## Prefix
`mapblock_`

## Task Type
Content Creation / Modification

## Description
Create or update mapblock entries in `mods/core/mapblocks/` folder. Mapblocks are reusable tactical maps with specific terrain, structures, and layouts used as locations for battles and missions.

## Inputs

### Required
- **Mapblock ID**: Unique identifier (e.g., `mapblock_urban_01`, `mapblock_farm_field_01`)
- **Mapblock Name**: Display name for UI and editors
- **Mapblock Theme**: Category - `urban`, `rural`, `industrial`, `alien`, `underground`, `nature`
- **Description**: Map characteristics and layout

### Optional
- **Grid Dimensions**: Map width and height
- **Tile Configuration**: Specific tile placements
- **Difficulty**: Challenge level
- **Spawn Points**: Unit starting locations
- **Objects/Props**: Destructible and interactive objects
- **Environmental Hazards**: Hazards and special terrain
- **Author Information**: Creator and version

## Scope

### Affected Files
- `mods/core/mapblocks/*.toml` (individual files per map)
- Related: Terrain definitions
- Related: Biome definitions
- Related: Mission system

### Validation
- ✓ Mapblock ID is unique
- ✓ All required TOML fields present
- ✓ Theme matches valid category
- ✓ Grid dimensions are positive integers
- ✓ Tile references are valid
- ✓ Spawn points are within bounds
- ✓ No impossible terrain combinations

## TOML Structure Template

```toml
[metadata]
id = "mapblock_id"
name = "Mapblock Display Name"
description = "Description of map layout and terrain"
theme = "urban|rural|industrial|alien|underground|nature"
group = 1
tags = ["tag1", "tag2"]
author = "Creator Name"
difficulty = 1

[dimensions]
width = 20
height = 20
accessible_area = 350

[tiles]
# Format: "x_y" = "TILE_ID"
"0_0" = "GRASS_PLAIN"
"1_0" = "GRASS_PLAIN"
"10_10" = "TREE_PINE"
"15_15" = "BUILDING_BRICK"

[spawn_points]
player_spawn_area = {x = 5, y = 5, radius = 2}
enemy_spawn_area = {x = 15, y = 15, radius = 2}
civilian_zones = [{x = 10, y = 10, radius = 1}]

[objects]
# Destructible/interactive objects
[[objects.items]]
id = "obj_1"
type = "destructible|interactive|prop"
tile_id = "CRATE_WOOD"
position = {x = 8, y = 8}
hp = 20
loot = ["item_id"]

[[objects.items]]
id = "obj_2"
type = "prop"
tile_id = "BARREL_METAL"
position = {x = 12, y = 12}
hp = 40

[hazards]
fire_sources = [{x = 5, y = 5, intensity = 2}]
toxic_zones = [{x = 15, y = 5, radius = 3}]
radiation_zones = []

[lighting]
ambient_light = 0.8
lighting_style = "natural|artificial|mixed"
shadows_enabled = true

[performance]
complexity = "low|medium|high"
entity_limit = 50
vegetation_density = 0.5

[gameplay]
recommended_squad_size = 6
difficulty_modifier = 1.0
victory_condition = "eliminate_all_enemies"
loss_condition = "all_squaddies_killed"

[aesthetics]
visual_style = "style_name"
color_palette = "palette_name"
ambient_effects = ["effect_id"]
```

## Outputs

### Created/Modified
- Mapblock entry in TOML with complete layout
- Tile grid properly defined
- Spawn points set appropriately
- Objects and hazards configured
- Visual atmosphere established

### Validation Report
- ✓ TOML syntax verified
- ✓ Mapblock ID uniqueness confirmed
- ✓ All tile references valid
- ✓ Grid dimensions consistent
- ✓ Spawn points within bounds
- ✓ No overlapping objects
- ✓ Hazards don't block all movement
- ✓ Balanced layout

## Process

1. **Design Layout**: Sketch map arrangement
2. **Set Dimensions**: Establish grid size
3. **Place Tiles**: Configure terrain and buildings
4. **Add Spawn Points**: Define unit placement areas
5. **Place Objects**: Add destructible and interactive items
6. **Add Hazards**: Configure environmental threats
7. **Set Lighting**: Configure visual atmosphere
8. **Validate**: Check TOML and map consistency
9. **Test**: Load map in-game and verify appearance
10. **Document**: Update mapblock documentation

## Testing Checklist

- [ ] Mapblock loads without errors
- [ ] Map displays correctly in battlescape
- [ ] Tiles render properly
- [ ] Spawn points are accessible
- [ ] Objects appear at correct positions
- [ ] Hazards function properly
- [ ] Map is navigable
- [ ] Performance is acceptable
- [ ] Lighting looks correct
- [ ] Units can spawn without clipping
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Map balances difficulty appropriately

## References

- API: `docs/battlescape/map-system/`
- Examples: `mods/core/mapblocks/`
- Balance Guide: `docs/battlescape/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
