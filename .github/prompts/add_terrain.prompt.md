# add_terrain

Create or update terrain tile definitions in TOML format.

## Prefix
`terrain_`

## Task Type
Content Creation / Modification

## Description
Create or update terrain entries in `mods/core/geoscape/biomes.toml` or dedicated terrain file. Terrain tiles define how the battlescape and maps are rendered with different ground types, obstacles, and walkability properties.

## Inputs

### Required
- **Terrain ID**: Unique identifier (e.g., `grass_plain`, `concrete_floor`, `alien_floor`)
- **Terrain Name**: Display name for UI and editors
- **Terrain Type**: Category - `floor`, `ground`, `vegetation`, `structure`, `water`, `lava`, `obstacle`
- **Description**: Visual and physical characteristics

### Optional
- **Visual Properties**: Sprite/texture, color, animation
- **Movement Properties**: Walkability, movement cost, cover value
- **Tactical Properties**: Line of sight blocking, damage effects
- **Environmental Effects**: Fire spreading, toxins, radiation
- **Interaction**: Destructibility, traversability rules

## Scope

### Affected Files
- `mods/core/geoscape/biomes.toml` (terrain definitions)
- Related: Tileset definitions
- Related: Map generation systems
- Related: Battlescape rendering

### Validation
- ✓ Terrain ID is unique
- ✓ All required TOML fields present
- ✓ Terrain type matches valid category
- ✓ Movement cost is positive number or zero
- ✓ Cover value between 0-100
- ✓ Visual properties defined
- ✓ No invalid physics combinations

## TOML Structure Template

```toml
[[terrain]]
id = "terrain_id"
name = "Terrain Display Name"
description = "Description of terrain appearance and characteristics"
type = "floor|ground|vegetation|structure|water|lava|obstacle"
category = "subcategory"
tags = ["tag1", "tag2"]

[visual]
sprite_id = "sprite_name"
color = "#FFFFFF"
animated = false
animation_frames = 1
animation_speed = 0.1

[movement]
walkable = true
movement_cost = 1.0
impassable = false
flying_only = false
water_traversal = false
dig_through = false

[tactical]
cover_value = 0
blocks_sight = false
concealment_value = 0
provides_height_advantage = false
entrenching_possible = true

[environmental]
fire_spread_rate = 0.0
toxic = false
radiation_level = 0
acid_damage = false
slippery = false
deep_water = false

[interaction]
destructible = false
destruction_hp = 0
leaves_debris = false
debris_type = "none"
interaction_type = "none"
interaction_text = ""

[physics]
friction = 1.0
damage_on_impact = 0
temperature = 20
humidity = 50

[visibility]
minimap_color = "#808080"
minimap_visible = true
fog_of_war_affects = true
```

## Outputs

### Created/Modified
- Terrain entry in TOML with full specification
- Visual properties defined
- Movement and tactical properties configured
- Environmental effects established
- Physics characteristics set

### Validation Report
- ✓ TOML syntax verified
- ✓ Terrain ID uniqueness confirmed
- ✓ All visual properties valid
- ✓ Movement cost reasonable
- ✓ Cover values in valid range
- ✓ No impossible property combinations
- ✓ Sprite references exist
- ✓ No conflicts

## Process

1. **Define Terrain Type**: Determine category and visual style
2. **Configure Movement**: Set walkability and cost
3. **Set Tactical Properties**: Establish cover and sight blocking
4. **Add Environmental Effects**: Configure any hazards
5. **Define Interactions**: Set destructibility and traversal rules
6. **Configure Physics**: Set friction and damage effects
7. **Validate**: Check TOML and property consistency
8. **Test**: Place terrain in maps and verify appearance/behavior
9. **Document**: Update terrain documentation

## Testing Checklist

- [ ] Terrain loads without errors
- [ ] Visual appearance correct in battlescape
- [ ] Movement cost applies properly
- [ ] Cover value blocks shots correctly
- [ ] Line of sight blocking works if enabled
- [ ] Environmental effects apply (if any)
- [ ] Units walk on terrain smoothly
- [ ] Destructibility works if enabled
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Terrain displays correctly in minimap
- [ ] Animation works (if animated)

## References

- API: `docs/battlescape/map-system/`
- Examples: `mods/core/geoscape/biomes.toml`
- Balance Guide: `docs/battlescape/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
