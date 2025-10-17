# add_biome

Create or update biome definitions in TOML format.

## Prefix
`biome_`

## Task Type
Content Creation / Modification

## Description
Create or update biome entries in `mods/core/geoscape/biomes.toml`. Biomes represent distinct environmental zones combining terrain, vegetation, structures, and weather with characteristic maps and visual themes.

## Inputs

### Required
- **Biome ID**: Unique identifier (e.g., `biome_urban`, `biome_desert`, `biome_alien_base`)
- **Biome Name**: Display name for UI and tooltips
- **Biome Type**: Category - `urban`, `rural`, `wilderness`, `industrial`, `alien`, `underground`
- **Description**: Environmental characteristics and appearance

### Optional
- **Terrain Composition**: Primary and secondary terrain types
- **Vegetation**: Flora present in biome
- **Structures**: Buildings and obstacles
- **Climate**: Temperature, precipitation, wind
- **Available Maps**: Mapblocks suitable for this biome
- **Weather Systems**: Dynamic weather effects
- **Ambient Effects**: Sound, particles, visual atmosphere

## Scope

### Affected Files
- `mods/core/geoscape/biomes.toml`
- Related: Terrain definitions
- Related: Map generation systems
- Related: Mapblock definitions

### Validation
- ✓ Biome ID is unique
- ✓ All required TOML fields present
- ✓ Biome type matches valid category
- ✓ Terrain composition references exist
- ✓ Vegetation references valid
- ✓ Available mapblock IDs exist
- ✓ Weather parameters reasonable
- ✓ Climate values in valid ranges

## TOML Structure Template

```toml
[[biomes]]
id = "biome_id"
name = "Biome Display Name"
description = "Description of biome environment and characteristics"
type = "urban|rural|wilderness|industrial|alien|underground"
category = "subcategory"
tags = ["tag1", "tag2"]

[appearance]
primary_color = "#808080"
secondary_color = "#A0A0A0"
accent_color = "#FFB000"
ambient_light = 0.8
ambient_sound = "sound_id"

[terrain]
primary_terrain = "terrain_id"
secondary_terrain = "terrain_id"
terrain_distribution = 0.7
obstacle_density = 0.3

[vegetation]
vegetation_type = "vegetation_id"
vegetation_density = 0.5
flora_variety = 3

[structures]
structure_types = ["structure_id"]
structure_density = 0.2
ruin_density = 0.1
small_props = true

[climate]
temperature_base = 20
temperature_variance = 10
precipitation_type = "none|rain|snow"
precipitation_chance = 0.2
wind_speed_average = 5

[weather]
weather_enabled = true
available_weather = ["clear", "rain", "storm"]
storm_intensity = 1.0
season_affected = true

[maps]
available_mapblocks = ["mapblock_id1", "mapblock_id2"]
map_generation_style = "procedural|preset|hybrid"
map_difficulty_base = 1

[environmental_effects]
visibility_range = 50
dust_effect = false
particle_effects = ["effect_id"]
ambient_particles = true

[atmosphere]
fog_density = 0.0
fog_color = "#FFFFFF"
sky_color = "#87CEEB"
lighting_style = "natural|artificial|mixed"

[gameplay]
mission_frequency = "common|rare|unique"
ufosighting_frequency = 1.0
danger_level = 1.0
```

## Outputs

### Created/Modified
- Biome entry in TOML with complete environmental definition
- Terrain and vegetation composition set
- Climate parameters configured
- Available mapblocks assigned
- Visual atmosphere defined

### Validation Report
- ✓ TOML syntax verified
- ✓ Biome ID uniqueness confirmed
- ✓ All terrain references valid
- ✓ All mapblock references exist
- ✓ Climate values reasonable
- ✓ Color values valid
- ✓ Vegetation types valid
- ✓ No conflicts with existing biomes

## Process

1. **Define Biome Concept**: Establish environmental theme and type
2. **Choose Terrain**: Select primary and secondary terrain types
3. **Configure Vegetation**: Add flora appropriate to biome
4. **Set Structures**: Place typical buildings/obstacles
5. **Configure Climate**: Set temperature and weather patterns
6. **Assign Mapblocks**: Choose or create suitable maps
7. **Add Atmosphere**: Configure visual and audio ambiance
8. **Validate**: Check TOML and consistency
9. **Test**: Generate missions in biome and verify appearance
10. **Document**: Update biome documentation

## Testing Checklist

- [ ] Biome loads without errors
- [ ] Terrain generates correctly
- [ ] Vegetation displays properly
- [ ] Structures appear as expected
- [ ] Color scheme is cohesive
- [ ] Mapblocks load from biome
- [ ] Weather effects work (if enabled)
- [ ] Ambient sound plays
- [ ] Particle effects render
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Biome balances with other biomes
- [ ] Visibility ranges work correctly

## References

- API: `docs/battlescape/map-system/`
- Examples: `mods/core/geoscape/biomes.toml`
- Balance Guide: `docs/battlescape/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
