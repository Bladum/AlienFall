# Tileset System

## Overview

The **Tileset System** organizes visual assets (PNG files) into thematic folders and associates them with **Map Tiles**. Each Map Tile represents a single hex cell in the battle map and can have complex behaviors like random variants, sprite animations, or autotile generation.

**Key Concepts:**
- **Tileset** = Thematic folder containing related PNG files (furnitures, weapons, farmland, city, ufo_ship)
- **Map Tile** = Definition of one hex cell in battle map, linked to PNG asset(s)
- **Multi-Tile** = PNG larger than 24×24 pixels, with special handling rules
- **Map Block** = 15×15 grid of Map Tile KEYs stored in TOML

---

## System Architecture

```
Tilesets (Folders)
    ↓
PNG Files (24×24 or larger)
    ↓
Map Tiles (TOML definitions with KEYs)
    ↓
Map Blocks (15×15 grids referencing Map Tile KEYs)
    ↓
Battlefield (Assembled map with rendered tiles)
```

### Directory Structure

```
mods/core/tilesets/
├── furnitures/              # Indoor furniture assets
│   ├── chair_wood.png      # 24×24 simple tile
│   ├── table_large.png     # 48×48 multi-tile (2×2 cells)
│   ├── shelf_variants_01.png  # 24×72 (3 variants)
│   └── tilesets.toml       # Tileset metadata
├── weapons/                 # Weapon props and crates
│   ├── crate_ammo.png
│   ├── weapon_rack.png
│   └── tilesets.toml
├── farmland/                # Rural terrain
│   ├── hay_bale.png
│   ├── fence_wood.png
│   ├── tree_pine_01.png    # 24×24 (multiple damage states)
│   └── tilesets.toml
├── city/                    # Urban terrain
│   ├── wall_brick.png
│   ├── road_straight.png
│   ├── road_corner.png     # Autotile compatible
│   └── tilesets.toml
├── ufo_ship/                # Alien structures
│   ├── wall_alien.png
│   ├── door_animated.png   # 24×96 (4 animation frames)
│   └── tilesets.toml
└── _common/                 # Shared utilities
    ├── grass.png
    ├── dirt.png
    └── tilesets.toml
```

---

## Map Tile Definitions

Map Tiles are defined in `tilesets.toml` within each tileset folder. Each Map Tile has a **KEY** used in Map Blocks.

### Basic Map Tile

```toml
[[maptile]]
key = "CHAIR_WOOD"           # Unique KEY for Map Blocks
name = "Wooden Chair"        # Human-readable name
tileset = "furnitures"       # Parent tileset folder
image = "chair_wood.png"     # PNG file (24×24)
passable = true              # Can units walk through?
blocksLOS = false            # Blocks line of sight?
cover = "none"               # "none", "light", "heavy", "full"
height = 0                   # Height offset in pixels
```

**Field Descriptions:**

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `key` | string | **Required.** Unique identifier used in Map Blocks. Use UPPER_SNAKE_CASE. | - |
| `name` | string | Display name for editor | - |
| `tileset` | string | Parent tileset folder name | - |
| `image` | string | PNG filename relative to tileset folder | - |
| `passable` | boolean | Can units walk through this tile? | `true` |
| `blocksLOS` | boolean | Blocks line of sight? | `false` |
| `cover` | string | Cover level: "none", "light", "heavy", "full" | `"none"` |
| `height` | integer | Vertical offset in pixels (for elevated objects) | `0` |
| `destructible` | boolean | Can be destroyed? | `false` |
| `health` | integer | Hit points (if destructible) | `0` |
| `flammable` | boolean | Can catch fire? | `false` |

---

## Multi-Tile System

PNG files **larger than 24×24 pixels** are "multi-tiles" with special behavior.

### Multi-Tile Dimensions

- **Width/Height must be multiples of 24** (24, 48, 72, 96, etc.)
- Multi-tiles occupy **multiple hex cells** on the battlefield
- Behavior depends on `multiTileMode` property

### Multi-Tile Modes

#### 1. Random Variant Selection

Use when multiple visual variants exist for aesthetic variety.

```toml
[[maptile]]
key = "TREE_PINE"
name = "Pine Tree"
tileset = "farmland"
image = "tree_pine_variants.png"  # 24×72 (3 variants stacked vertically)
multiTileMode = "random_variant"   # Pick one randomly when placed
variantCount = 3                   # Number of variants (auto-detected if omitted)
passable = true
blocksLOS = true
cover = "heavy"
```

**Usage:** Engine randomly selects one 24×24 section when placing tile. Adds visual variety without needing separate tile definitions.

**Example:** Trees, bushes, rocks with slight visual differences.

---

#### 2. Sprite Animation

Use for animated objects (doors opening, fires burning, machinery operating).

```toml
[[maptile]]
key = "DOOR_ALIEN_ANIM"
name = "Alien Door (Animated)"
tileset = "ufo_ship"
image = "door_animated.png"       # 24×96 (4 frames)
multiTileMode = "animation"        # Animate through frames
frameCount = 4                     # Number of animation frames
frameDelay = 200                   # Milliseconds per frame
looping = true                     # Loop animation?
passable = false                   # Door starts closed
```

**Animation Properties:**

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `frameCount` | integer | Number of animation frames | Auto-detect |
| `frameDelay` | integer | Milliseconds per frame | `200` |
| `looping` | boolean | Loop animation continuously? | `true` |
| `pingpong` | boolean | Reverse direction at end? | `false` |

**Example Uses:**
- Doors opening/closing (4-8 frames)
- Fires burning (3-6 frames)
- Machinery operating (4-12 frames)
- Alien devices pulsing (2-4 frames)

---

#### 3. Autotile Generation

Use for seamless terrain transitions (roads, paths, walls, water edges).

```toml
[[maptile]]
key = "ROAD_ASPHALT"
name = "Asphalt Road"
tileset = "city"
image = "road_autotile.png"       # 120×120 (5×5 autotile template)
multiTileMode = "autotile"         # Generate tiles based on neighbors
autotileType = "blob"              # Autotile algorithm: "blob", "47tile", "16tile"
passable = true
blocksLOS = false
```

**Autotile Types:**

| Type | Template Size | Neighbors | Best For |
|------|---------------|-----------|----------|
| `blob` | 48×48 (2×2) | 4-directional | Simple paths, water |
| `16tile` | 96×96 (4×4) | 8-directional | Roads, floors |
| `47tile` | 168×168 (7×7) | 8-directional + corners | Walls, complex terrain |

**How It Works:**
1. Map editor/generator checks neighboring tiles
2. Selects appropriate sub-tile from template based on neighbor pattern
3. Creates seamless transitions automatically

**Example:** Road tiles automatically choose straight, corner, T-junction, or crossroad appearance based on adjacent road tiles.

---

#### 4. Multi-Cell Occupancy

Use for large objects spanning multiple hex cells (tables, vehicles, large rocks).

```toml
[[maptile]]
key = "TABLE_LARGE"
name = "Large Table"
tileset = "furnitures"
image = "table_large.png"         # 48×48 (2×2 cells)
multiTileMode = "occupy"           # Occupies multiple cells
cellWidth = 2                      # Cells wide
cellHeight = 2                     # Cells tall
anchorPoint = [0, 0]               # Origin cell (top-left)
passable = false
blocksLOS = true
cover = "light"
```

**Occupancy Properties:**

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `cellWidth` | integer | Hex cells wide | Auto-detect |
| `cellHeight` | integer | Hex cells tall | Auto-detect |
| `anchorPoint` | [x, y] | Which cell is the "main" tile | `[0, 0]` |
| `blockAllCells` | boolean | All cells block movement? | `true` |

**Important:** When placing in Map Blocks, only reference the anchor cell. Engine automatically reserves adjacent cells.

**Example Map Block:**
```toml
[tiles]
"5_5" = "TABLE_LARGE"  # Only specify anchor point
# Engine reserves (5,5), (6,5), (5,6), (6,6) automatically
```

---

## Damage States

Objects can have multiple damage states (intact → damaged → destroyed).

```toml
[[maptile]]
key = "WALL_WOOD"
name = "Wooden Wall"
tileset = "farmland"
image = "wall_wood_damage.png"    # 24×72 (3 states)
multiTileMode = "damage_states"    # Switch based on health
damageStates = 3                   # Number of states
destructible = true
health = 50
passable = false
blocksLOS = true
cover = "full"

# Damage thresholds (percent of max health)
damageThresholds = [
    { minHealth = 67, maxHealth = 100, frame = 0 },  # Intact
    { minHealth = 34, maxHealth = 66, frame = 1 },   # Damaged
    { minHealth = 0, maxHealth = 33, frame = 2 }     # Heavily damaged
]
```

**When damaged:**
- Health drops → Engine switches to appropriate frame
- At 0 health → Object destroyed (removed or becomes rubble)

**Example:** Tree has 3 states:
1. Full foliage (100-67% health)
2. Damaged foliage (66-34% health)
3. Bare trunk (33-1% health)
4. Removed completely (0% health)

---

## Common Tileset Patterns

### Furnitures Tileset

**Contents:** Indoor objects (chairs, tables, shelves, beds, lockers)

```toml
# furnitures/tilesets.toml
[tileset]
id = "furnitures"
name = "Indoor Furniture"
description = "Common indoor furniture and props"

[[maptile]]
key = "CHAIR_WOOD"
name = "Wooden Chair"
image = "chair_wood.png"
passable = true
cover = "light"

[[maptile]]
key = "TABLE_LARGE"
name = "Large Table"
image = "table_large.png"
multiTileMode = "occupy"
cellWidth = 2
cellHeight = 2
passable = false
cover = "light"

[[maptile]]
key = "SHELF_VARIANTS"
name = "Storage Shelf"
image = "shelf_variants.png"
multiTileMode = "random_variant"
variantCount = 3
passable = false
blocksLOS = true
cover = "full"
```

---

### Weapons Tileset

**Contents:** Weapon racks, ammo crates, equipment lockers

```toml
# weapons/tilesets.toml
[tileset]
id = "weapons"
name = "Weapons and Equipment"
description = "Military equipment and weapon storage"

[[maptile]]
key = "CRATE_AMMO"
name = "Ammunition Crate"
image = "crate_ammo.png"
passable = false
cover = "heavy"
destructible = true
health = 30

[[maptile]]
key = "WEAPON_RACK"
name = "Weapon Rack"
image = "weapon_rack.png"
passable = false
blocksLOS = true
cover = "light"
```

---

### Farmland Tileset

**Contents:** Rural terrain (fences, hay, trees, crops)

```toml
# farmland/tilesets.toml
[tileset]
id = "farmland"
name = "Rural Farmland"
description = "Farm structures and natural features"

[[maptile]]
key = "HAY_BALE"
name = "Hay Bale"
image = "hay_bale.png"
passable = true
cover = "light"
flammable = true

[[maptile]]
key = "FENCE_WOOD"
name = "Wooden Fence"
image = "fence_wood.png"
passable = false
cover = "light"
destructible = true
health = 20

[[maptile]]
key = "TREE_PINE"
name = "Pine Tree"
image = "tree_pine_damage.png"
multiTileMode = "damage_states"
damageStates = 3
destructible = true
health = 80
passable = true
blocksLOS = true
cover = "heavy"
```

---

### City Tileset

**Contents:** Urban structures (walls, roads, sidewalks, streetlights)

```toml
# city/tilesets.toml
[tileset]
id = "city"
name = "Urban Cityscape"
description = "City streets and buildings"

[[maptile]]
key = "WALL_BRICK"
name = "Brick Wall"
image = "wall_brick_damage.png"
multiTileMode = "damage_states"
damageStates = 3
destructible = true
health = 100
passable = false
blocksLOS = true
cover = "full"

[[maptile]]
key = "ROAD_ASPHALT"
name = "Asphalt Road"
image = "road_autotile.png"
multiTileMode = "autotile"
autotileType = "16tile"
passable = true

[[maptile]]
key = "STREETLIGHT"
name = "Street Light"
image = "streetlight.png"
passable = true
height = 12  # Elevated above ground
```

---

### UFO Ship Tileset

**Contents:** Alien structures (alien walls, doors, consoles)

```toml
# ufo_ship/tilesets.toml
[tileset]
id = "ufo_ship"
name = "UFO Interior"
description = "Alien ship structures and technology"

[[maptile]]
key = "WALL_ALIEN"
name = "Alien Hull"
image = "wall_alien.png"
passable = false
blocksLOS = true
cover = "full"
destructible = true
health = 150

[[maptile]]
key = "DOOR_ALIEN"
name = "Alien Door"
image = "door_alien_anim.png"
multiTileMode = "animation"
frameCount = 4
frameDelay = 150
looping = false
passable = false  # Becomes true when opened

[[maptile]]
key = "CONSOLE_ALIEN"
name = "Alien Console"
image = "console_alien.png"
passable = false
cover = "heavy"
# Interactive object (not destructible)
```

---

## Map Block Integration

Map Blocks reference Map Tiles by their **KEY**:

```toml
# mods/core/mapblocks/urban_building_01.toml
[metadata]
id = "urban_building_01"
name = "Small Urban Building"
width = 15
height = 15

[tiles]
# Use Map Tile KEYs
"0_0" = "WALL_BRICK"
"0_1" = "WALL_BRICK"
"1_0" = "WALL_BRICK"
"1_1" = "FLOOR_WOOD"
"1_2" = "CHAIR_WOOD"
"2_2" = "TABLE_LARGE"  # Multi-tile (also occupies 3_2, 2_3, 3_3)
"4_4" = "ROAD_ASPHALT"  # Autotile (appearance depends on neighbors)
```

**Engine Resolution:**
1. Map Block loader reads KEY (e.g., "WALL_BRICK")
2. Looks up Map Tile definition in tilesets
3. Resolves to PNG file (e.g., "city/wall_brick_damage.png")
4. Applies multi-tile logic (variant selection, animation, autotile, etc.)
5. Renders to battlefield

---

## Built-In Map Editor

The game includes a visual Map Block editor accessible from the main menu.

### Editor Features

- **Hex Grid Display**: Shows 15×15 hex grid
- **Tile Palette**: Browse all Map Tiles by tileset
- **Paint Tool**: Click to place tiles
- **Eraser**: Remove tiles
- **Preview Mode**: See multi-tile behavior in real-time
- **Save/Load**: Export to TOML, import existing Map Blocks
- **Tileset Filter**: Show only tiles from specific tilesets

### Launching the Editor

```lua
-- From main menu, click "MAP EDITOR"
-- Or programmatically:
StateManager.setState("map_editor")
```

### Editor Workflow

1. **Create New Map Block** or **Load Existing**
2. **Select Tileset** from dropdown (furnitures, city, farmland, etc.)
3. **Choose Map Tile** from palette
4. **Paint on Grid** by clicking hex cells
5. **Preview Multi-Tiles**: See variants, animations, autotiles in action
6. **Save to TOML**: Export to `mods/core/mapblocks/`

### Keyboard Shortcuts

- **Left Click**: Place selected tile
- **Right Click**: Erase tile
- **Mouse Wheel**: Zoom in/out
- **Space**: Toggle grid overlay
- **Ctrl+S**: Save Map Block
- **Ctrl+L**: Load Map Block
- **Ctrl+Z**: Undo
- **Ctrl+Y**: Redo

---

## Asset Creation Guidelines

### PNG File Requirements

**Dimensions:**
- Base size: **24×24 pixels** (one hex cell)
- Multi-tiles: **Multiples of 24** (48, 72, 96, 120, etc.)
- Autotiles: **Specific templates** (48×48 for blob, 96×96 for 16tile, 168×168 for 47tile)

**Color:**
- **24-bit RGB** or **32-bit RGBA** (use alpha for transparency)
- **Indexed color** NOT recommended (use full color)

**Transparency:**
- Use **alpha channel** for transparent areas
- Avoid partial transparency if possible (fully opaque or fully transparent)
- Transparency used for: shadows, vegetation, irregular shapes

**Style:**
- **Pixel art aesthetic** (16×16 upscaled to 32×32 was mentioned, but 24×24 is actual grid)
- **Consistent palette** within tileset
- **Readable at game resolution** (960×720)

### Naming Conventions

```
<category>_<object>_<variant>.png

Examples:
wall_brick_red.png
wall_brick_damaged.png
tree_pine_01.png
tree_oak_02.png
road_asphalt_straight.png
door_alien_anim.png (animation)
fence_wood_variants.png (multiple variants)
```

**Rules:**
- Lowercase with underscores
- Descriptive category prefix
- Numbered variants: `_01`, `_02`, etc.
- Damage states: `_damage`, `_damaged`, `_destroyed`
- Animations: `_anim`
- Variants: `_variants`

### Multi-Tile Layout

**Variants (horizontal or vertical):**
```
[Frame 1]
[Frame 2]
[Frame 3]
```
Each frame is 24×24, stacked vertically or horizontally.

**Animations (vertical):**
```
[Frame 1] ← First frame
[Frame 2]
[Frame 3]
[Frame 4] ← Last frame
```

**Multi-Cell Objects (left-to-right, top-to-bottom):**
```
2×2 object (48×48):
[Top-Left]  [Top-Right]
[Bot-Left]  [Bot-Right]
```

**Autotile Templates:**
See [Autotile Guide](AUTOTILE_GUIDE.md) for detailed templates.

---

## Performance Considerations

### Texture Atlas

Engine automatically packs PNG files into **texture atlases** at runtime for performance.

**Benefits:**
- Reduces draw calls (batch rendering)
- Improves GPU memory usage
- Faster map rendering

**Implementation:**
```lua
local Atlas = require("core.texture_atlas")

-- Load tileset
local atlas = Atlas.new("city")
atlas:loadFromFolder("mods/core/tilesets/city/")

-- Get tile sprite
local sprite = atlas:getSprite("wall_brick.png")
```

### Tileset Loading

Tilesets are **lazy-loaded** - only loaded when needed.

```lua
local Tilesets = require("battlescape.data.tilesets")

-- Register tileset (metadata only)
Tilesets.register("city")

-- Load assets when entering battle
Tilesets.load("city")

-- Unload when leaving battle
Tilesets.unload("city")
```

### Animation Optimization

**Sprite Sheets:** Animations use sprite sheet rendering (all frames in one texture).

**Frame Skipping:** Low-priority animations skip frames if FPS drops.

**LOD (Level of Detail):** Distant tiles use simpler rendering.

---

## Engine Integration

### Loading Tilesets

```lua
local Tilesets = require("battlescape.data.tilesets")

-- Load all tilesets
Tilesets.loadAll("mods/core/tilesets/")

-- Get Map Tile by KEY
local tile = Tilesets.getTile("WALL_BRICK")
print(tile.image)  -- "city/wall_brick_damage.png"
print(tile.cover)  -- "full"

-- Get all tiles in tileset
local cityTiles = Tilesets.getTileset("city")
for key, tile in pairs(cityTiles) do
    print(key, tile.name)
end
```

### Rendering Map Tiles

```lua
local TileRenderer = require("battlescape.rendering.tile_renderer")

-- Render single tile
TileRenderer.draw(tile, x, y, {
    variant = 2,        -- For random_variant mode
    frame = 1,          -- For animation mode
    damagePercent = 50  -- For damage_states mode
})

-- Render with autotile
TileRenderer.drawAutotile(tile, x, y, neighbors)
```

### Handling Multi-Tiles

```lua
local MultiTile = require("battlescape.utils.multitile")

-- Check if tile is multi-tile
if MultiTile.isMultiTile(tile) then
    local width, height = MultiTile.getSize(tile)
    print(string.format("Occupies %dx%d cells", width, height))
end

-- Get random variant
local variant = MultiTile.selectVariant(tile, seed)

-- Get animation frame
local frame = MultiTile.getFrame(tile, elapsedTime)

-- Get autotile sprite
local sprite = MultiTile.getAutotileSprite(tile, neighbors)
```

---

## Modding Support

### Adding Custom Tilesets

1. Create folder: `mods/<yourmod>/tilesets/<tilesetname>/`
2. Add PNG files
3. Create `tilesets.toml` with Map Tile definitions
4. Register in mod's `init.lua`:

```lua
-- mods/yourmod/init.lua
local Tilesets = require("battlescape.data.tilesets")

Tilesets.registerTileset({
    id = "yourmod_custom",
    name = "Your Custom Tileset",
    path = "mods/yourmod/tilesets/custom/"
})
```

### Overriding Core Tiles

Mods can override core Map Tiles:

```toml
# mods/yourmod/tilesets/overrides/tilesets.toml
[[maptile]]
key = "WALL_BRICK"  # Override core tile
name = "Improved Brick Wall"
image = "wall_brick_hd.png"  # Use custom asset
# Other properties same as core
```

**Load Priority:** Mods loaded after core can override tile definitions.

---

## Troubleshooting

### Tile Not Rendering

**Check:**
1. KEY is correct in Map Block TOML
2. Map Tile is defined in tileset TOML
3. PNG file exists at specified path
4. PNG dimensions are multiples of 24
5. Tileset is loaded before use

### Animation Not Playing

**Check:**
1. `multiTileMode = "animation"` is set
2. `frameCount` matches number of frames in PNG
3. PNG height = 24 × frameCount
4. Animation is triggered (e.g., door opened)

### Autotile Not Working

**Check:**
1. `multiTileMode = "autotile"` is set
2. PNG matches autotile template size
3. `autotileType` is valid ("blob", "16tile", "47tile")
4. Neighboring tiles are checked correctly
5. Template is correctly formatted

### Multi-Cell Object Overlapping

**Check:**
1. Map Block doesn't place tiles in reserved cells
2. `cellWidth` and `cellHeight` are correct
3. `anchorPoint` is within object bounds
4. Map generation respects occupied cells

---

## See Also

- [MapBlock Guide](MAPBLOCK_GUIDE.md) - Creating Map Blocks
- [Map Script Reference](MAP_SCRIPT_REFERENCE.md) - Assembling maps with scripts
- [Autotile Guide](AUTOTILE_GUIDE.md) - Creating autotile templates
- [Asset Creation Guide](ASSET_CREATION.md) - General asset creation
- [Map Editor Documentation](../engine/tools/map_editor/README.md) - Using the visual editor
- [API Reference](API.md) - Engine API for tilesets
