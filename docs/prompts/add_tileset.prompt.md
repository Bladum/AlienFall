# add_tileset

Create or update tileset definitions for map rendering in TOML format.

## Prefix
`tileset_`

## Task Type
Content Creation / Modification

## Description
Create or update tileset entries in `mods/core/tilesets/` folder. Tilesets define collections of visual tile sprites used to render tactical maps with consistent visual themes.

## Inputs

### Required
- **Tileset ID**: Unique identifier (e.g., `tileset_urban`, `tileset_forest`)
- **Tileset Name**: Display name for UI and editors
- **Visual Theme**: Category - `urban`, `rural`, `industrial`, `alien`, `nature`, `abstract`
- **Description**: Tileset characteristics and usage

### Optional
- **Sprite References**: Sprite IDs for each tile type
- **Color Palette**: Base colors used
- **Animation Sets**: Animated tile definitions
- **Variant Generation**: How tiles vary
- **Compatibility**: Which biomes/mapblocks use this

## Scope

### Affected Files
- `mods/core/tilesets/*.toml` (individual tileset definitions)
- Related: Sprite definitions
- Related: Terrain definitions
- Related: Biome definitions

### Validation
- ✓ Tileset ID is unique
- ✓ All required TOML fields present
- ✓ Theme matches valid category
- ✓ Sprite references exist
- ✓ Animation references valid
- ✓ Color values valid
- ✓ Tile coverage complete

## TOML Structure Template

```toml
[tileset]
id = "tileset_id"
name = "Tileset Display Name"
description = "Description of tileset theme and usage"
visual_theme = "urban|rural|industrial|alien|nature|abstract"
compatible_biomes = ["biome_id"]
author = "Creator Name"
version = "1.0.0"

[metadata]
sprite_sheet_id = "spritesheet_name"
tile_size = 24  # pixels
color_depth = 256
animation_capable = true

[color_palette]
primary_color = "hsl(120, 100%, 50%)"
secondary_color = "hsl(240, 100%, 50%)"
accent_color = "hsl(0, 100%, 50%)"
shadow_color = "hsl(0, 0%, 20%)"
highlight_color = "hsl(0, 0%, 80%)"

[[tiles]]
terrain_type = "grass"
sprite_id = "sprite_grass_01"
tile_id = "GRASS"
walkable = true
cover_value = 0

[[tiles]]
terrain_type = "grass"
sprite_id = "sprite_grass_02"
tile_id = "GRASS_ALT"
walkable = true
cover_value = 0

[[tiles]]
terrain_type = "stone"
sprite_id = "sprite_stone_wall"
tile_id = "STONE_WALL"
walkable = false
cover_value = 100

[[animated_tiles]]
tile_id = "WATER_FLOWING"
sprite_id = "sprite_water"
animation_frames = 4
animation_speed = 0.1
loop = true

[[variants]]
base_tile = "GRASS"
variant_sprites = ["sprite_grass_variant_01", "sprite_grass_variant_02"]
variant_probability = 0.3
random_rotation_enabled = true

[lighting]
lighting_style = "flat|shaded|complex"
shadow_enabled = true
reflection_enabled = false
ambient_light_level = 0.7

[compatibility]
supported_resolutions = ["480x360", "960x720", "1920x1440"]
pixel_scale_factor = 2  # 12x12 art scaled to 24x24
edge_blending = true

[visual_effects]
fog_of_war_style = "standard"
minimap_supported = true
transition_smooth = true
```

## Outputs

### Created/Modified
- Tileset entry with sprite mapping
- Color palette defined
- Animation configurations set
- Variant rules established
- Compatibility information listed

### Validation Report
- ✓ TOML syntax verified
- ✓ Tileset ID uniqueness confirmed
- ✓ All sprite references exist
- ✓ Color values valid
- ✓ Animation frames valid
- ✓ Terrain types covered
- ✓ Variant probabilities sum correctly

## Process

1. **Define Visual Theme**: Establish tileset aesthetics
2. **Create/Collect Sprites**: Gather or create sprite assets
3. **Define Tile Mapping**: Map terrain types to sprites
4. **Set Color Palette**: Establish color scheme
5. **Configure Animations**: Set up animated tiles
6. **Create Variants**: Add visual variation
7. **Validate**: Check TOML and sprite consistency
8. **Test**: Render maps using tileset
9. **Document**: Update tileset documentation

## Testing Checklist

- [ ] Tileset loads without errors
- [ ] All tile sprites render
- [ ] Tiles display at correct size
- [ ] Animation plays smoothly
- [ ] Variants generate properly
- [ ] Lighting applies correctly
- [ ] Color palette is cohesive
- [ ] Maps render with tileset
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Minimap displays correctly (if supported)
- [ ] Visual appearance is polished

## References

- API: `docs/rendering/` and `docs/assets/graphics.md`
- Examples: `mods/core/tilesets/`
- Pixel Art Guide: `docs/design/pixel_art/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
