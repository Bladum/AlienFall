# MapBlock System Guide

## Overview

The MapBlock system enables **procedural battlefield generation** from reusable **15×15 tile templates**. Maps are assembled by arranging multiple blocks in a grid (4×4 to 7×7), using **Map Scripts** to control layout. Each tile in a Map Block references a **Map Tile KEY** from the tileset system.

**Key Features:**
- Map Blocks are **multiples of 15×15** (can be 15×15, 30×15, 15×30, 30×30, etc.)
- Supports **hex grid** rendering (isometric display)
- Uses **Map Tile KEYs** instead of hardcoded terrain names
- Created with **built-in Map Editor** (visual tool)
- Assembled via **Map Scripts** (conditional placement logic)

## System Architecture

```
Tilesets (PNG assets + Map Tile definitions)
    ↓
Map Blocks (15×15 grids of Map Tile KEYs in TOML)
    ↓
Map Scripts (Assembly rules in TOML)
    ↓
Map Generation Pipeline
    ↓
Battlefield (Rendered hex map)
```

### Key Components

1. **Tileset**: Folder containing PNG files and Map Tile definitions (`tilesets.toml`)
2. **Map Tile**: Single hex cell definition with KEY, linking to PNG asset(s)
3. **Map Block**: 15×15 (or multiple) grid of Map Tile KEYs stored in TOML
4. **Map Script**: Procedural assembly rules defining how to place Map Blocks
5. **Map Editor**: Built-in visual tool for creating Map Blocks
6. **Map Generation Pipeline**: Executes Map Scripts to create final battlefield

## MapBlock Format

### File Structure

MapBlocks are stored as TOML files in `mods/core/mapblocks/`:

```toml
# Metadata section (required)
[metadata]
id = "unique_block_id"       # Required: Unique identifier
name = "Display Name"         # Required: Human-readable name
description = "Brief description"  # Optional: Block purpose/theme
width = 15                    # Required: Width in tiles (multiple of 15)
height = 15                   # Required: Height in tiles (multiple of 15)
group = 0                     # Required: Group ID for Map Scripts (0-99)
tags = "urban, building, medium"  # Optional: Search tags
author = "System"             # Optional: Creator name
difficulty = 2                # Optional: 1=easy, 2=medium, 3=hard, 4=very hard, 5=extreme

# Tiles section (optional - defaults to empty/grass)
[tiles]
"x_y" = "MAP_TILE_KEY"
"0_0" = "ROAD_ASPHALT"
"0_1" = "ROAD_ASPHALT"
"1_0" = "WALL_BRICK"
"1_1" = "FLOOR_WOOD"
"1_2" = "CHAIR_WOOD"
"2_2" = "TABLE_LARGE"  # Multi-tile (occupies multiple cells)
# ... more tiles
```

**Important Changes from Old System:**
- ❌ **No hardcoded terrain names** (e.g., "wall", "grass", "road")
- ✅ **Use Map Tile KEYs** (e.g., "WALL_BRICK", "ROAD_ASPHALT", "TREE_PINE")
- ✅ **Group ID required** for Map Script integration
- ✅ **Tags for filtering** instead of biome-only classification

### Coordinate System

- **Format**: `"x_y"` where x and y are 0-indexed integers
- **Origin**: Top-left corner is (0, 0)
- **Range**: X and Y from 0 to (width-1) and (height-1)
- **Hex Grid**: Coordinates map to hex cells when rendered
- **Omitted Tiles**: Any tile not specified is left empty (no tile)

**Example Coordinate Mapping:**
```
15×15 Map Block:
"0_0"   = Top-left corner
"14_0"  = Top-right corner
"0_14"  = Bottom-left corner
"14_14" = Bottom-right corner
"7_7"   = Center
```

### Map Tile KEYs

Map Tile KEYs reference definitions in `mods/core/tilesets/<tileset>/tilesets.toml`.

**Available Map Tile KEYs** (see [Tileset System](../../TILESET_SYSTEM.md) for complete list):

| Tileset | Example KEYs | Usage |
|---------|-------------|-------|
| **city** | `WALL_BRICK`, `ROAD_ASPHALT`, `SIDEWALK`, `STREETLIGHT` | Urban buildings |
| **farmland** | `FENCE_WOOD`, `HAY_BALE`, `TREE_PINE`, `BARN_WALL` | Rural areas |
| **furnitures** | `CHAIR_WOOD`, `TABLE_LARGE`, `SHELF`, `BED` | Indoor props |
| **weapons** | `CRATE_AMMO`, `WEAPON_RACK`, `LOCKER` | Military equipment |
| **ufo_ship** | `WALL_ALIEN`, `DOOR_ALIEN`, `CONSOLE_ALIEN` | Alien structures |
| **_common** | `GRASS`, `DIRT`, `WATER`, `ROCK` | Generic terrain |

**Engine automatically resolves KEYs to PNG files** - no hardcoded paths in Map Blocks.

### Group System

Map Blocks are organized into **groups** for Map Script selection:

| Group ID | Typical Purpose | Examples |
|----------|----------------|----------|
| 0 | Generic filler blocks | Open fields, empty lots |
| 1 | Objective blocks | Craft landing sites, UFOs, mission targets |
| 2 | Horizontal connectors | Horizontal roads, rivers |
| 3 | Vertical connectors | Vertical roads, rivers |
| 4 | Intersections | Crossroads, bridges, junctions |
| 5-19 | Themed buildings | Houses, shops, warehouses |
| 20-29 | Natural features | Forest clearings, hills, ponds |
| 30-39 | Special structures | Alien bases, military installations |
| 40-99 | Custom/mod groups | Mod-specific content |

**Usage in Map Scripts:**
```toml
# Map Script selects blocks by group
[[commands]]
type = "addBlock"
groups = [5, 6, 7]  # Randomly select from groups 5, 6, or 7
```

## Creating MapBlocks

### Using the Map Editor (Recommended)

The game includes a **built-in visual Map Editor** accessible from the main menu.

**Launch Editor:**
1. Start game
2. Click **"MAP EDITOR"** on main menu
3. Create new Map Block or load existing

**Editor Features:**
- **Hex Grid Display**: Shows 15×15 (or larger) hex grid
- **Tileset Browser**: Browse Map Tiles by tileset (city, farmland, etc.)
- **Paint Tool**: Click hex cells to place tiles
- **Multi-Tile Preview**: See how multi-tiles will appear
- **Group Assignment**: Set Map Block group for Map Scripts
- **Save/Load**: Export to TOML, import existing Map Blocks
- **Tag Editor**: Add descriptive tags for filtering

**Workflow:**
1. **New Map Block**: Click "New" and set dimensions (15×15, 30×15, etc.)
2. **Select Tileset**: Choose tileset from dropdown (city, farmland, furnitures, etc.)
3. **Pick Map Tile**: Click tile in palette
4. **Paint Grid**: Click hex cells to place selected tile
5. **Preview**: Toggle preview mode to see multi-tiles, animations
6. **Set Metadata**: Fill in ID, name, group, tags, difficulty
7. **Save**: Export to `mods/core/mapblocks/yourblock.toml`

**Keyboard Shortcuts:**
- **Left Click**: Place tile
- **Right Click**: Erase tile
- **Space**: Toggle grid overlay
- **Ctrl+S**: Save
- **Ctrl+L**: Load
- **Ctrl+Z**: Undo
- **Ctrl+Y**: Redo
- **Mouse Wheel**: Zoom

### Manual TOML Creation

If you prefer text editing:

1. **Copy Template**: Start from `mods/core/mapblocks/template.toml`
2. **Edit Metadata**: Set unique ID, name, group, difficulty
3. **Design Layout**: Plan your 15×15 tile layout on paper
4. **Add Tiles**: Specify Map Tile KEYs for each non-empty tile
5. **Test**: Load in Map Editor or generate in-game
6. **Iterate**: Refine based on visual testing

### Design Principles

#### Balance

- **Mix Open and Dense**: Combine open areas with cover
- **Avoid Monoculture**: Use 3-5 different Map Tile types
- **Create Paths**: Include movement corridors
- **Strategic Points**: Add defensible positions

#### Gameplay

- **Cover Distribution**: 30-40% cover tiles for tactical options
- **Sightlines**: Create both long and short sight lines
- **Choke Points**: Add 2-3 natural choke points
- **Flanking Routes**: Enable multiple approach paths

#### Theme Consistency

Use Map Tiles from thematically related tilesets:

- **Urban Buildings**: city tileset (WALL_BRICK, ROAD_ASPHALT, SIDEWALK)
- **Forest**: farmland tileset (TREE_PINE, TREE_OAK, BUSHES, GRASS)
- **Indoor Spaces**: furnitures tileset (CHAIR_WOOD, TABLE_LARGE, SHELF)
- **Military**: weapons tileset (CRATE_AMMO, WEAPON_RACK, LOCKER)
- **Alien Sites**: ufo_ship tileset (WALL_ALIEN, DOOR_ALIEN, CONSOLE_ALIEN)

### Example: Urban Building Block

```toml
[metadata]
id = "urban_building_small_01"
name = "Small Urban Building"
description = "Two-story building with street access"
width = 15
height = 15
group = 5  # Building group
tags = "urban, building, small, residential"
author = "System"
difficulty = 2

[tiles]
# Exterior walls
"0_0" = "WALL_BRICK"
"1_0" = "WALL_BRICK"
"2_0" = "WALL_BRICK"
"3_0" = "WALL_BRICK"
"0_1" = "WALL_BRICK"
"3_1" = "WALL_BRICK"
"0_2" = "WALL_BRICK"
"3_2" = "WALL_BRICK"
"0_3" = "WALL_BRICK"
"1_3" = "DOOR_WOOD"
"2_3" = "WALL_BRICK"
"3_3" = "WALL_BRICK"

# Interior floor and furniture
"1_1" = "FLOOR_WOOD"
"2_1" = "FLOOR_WOOD"
"1_2" = "FLOOR_WOOD"
"2_2" = "FLOOR_WOOD"
"1_1" = "TABLE_LARGE"  # Multi-tile (also occupies 2_1, 1_2, 2_2)
"3_1" = "CHAIR_WOOD"

# Street access
"4_0" = "ROAD_ASPHALT"
"4_1" = "ROAD_ASPHALT"
"4_2" = "ROAD_ASPHALT"
"4_3" = "ROAD_ASPHALT"
"5_0" = "SIDEWALK"
"5_1" = "SIDEWALK"
"5_2" = "SIDEWALK"
"5_3" = "SIDEWALK"

# Empty tiles (grass/outdoor) are omitted
```

**Notes:**
- `TABLE_LARGE` is a 2×2 multi-tile - engine automatically reserves adjacent cells
- `ROAD_ASPHALT` uses autotile - appearance adapts to neighboring road tiles
- Empty tiles don't need to be specified (left empty for outdoor areas)

### Example: Forest Clearing Block

```toml
[metadata]
id = "forest_clearing_01"
name = "Forest Clearing"
description = "Small clearing surrounded by dense trees"
width = 15
height = 15
group = 20  # Natural features group
tags = "forest, clearing, natural, cover"
author = "System"
difficulty = 1

[tiles]
# Dense tree perimeter
"0_0" = "TREE_PINE"
"0_1" = "TREE_OAK"
"0_2" = "TREE_PINE"
"1_0" = "TREE_OAK"
"2_0" = "TREE_PINE"
"14_0" = "TREE_OAK"
"14_1" = "TREE_PINE"
# ... more trees around edges

# Bushes and undergrowth
"3_3" = "BUSHES"
"4_5" = "BUSHES"
"7_8" = "BUSHES"
"10_6" = "BUSHES"

# Center is open (empty tiles = grass)
# "7_7" is not specified, so it's empty/grass
```

## Multi-Sized Map Blocks

Map Blocks can be **larger than 15×15** for special structures.

### Valid Dimensions

- **Width/Height**: Must be multiples of 15 (15, 30, 45, 60, etc.)
- **Examples**:
  - 15×15 = Standard block
  - 30×15 = Wide building (2× width)
  - 15×30 = Tall structure (2× height)
  - 30×30 = Large complex (2×2 in Map Block grid)
  - 45×15 = Very wide structure (3× width)
  - 15×45 = Very tall structure (3× height)

### Map Script Integration

Map Scripts handle multi-sized blocks automatically:

```toml
# Map Script command
[[commands]]
type = "addBlock"
groups = [10]  # Large structure group
size = [2, 2]  # 2×2 Map Block size (30×30 tiles)
executions = 1
```

**Engine Behavior:**
1. Selects Map Block from group 10
2. Checks that Map Block has width=30, height=30
3. Reserves 2×2 grid positions on map
4. Prevents other blocks from overlapping

### Example: Large UFO Block

```toml
[metadata]
id = "ufo_large_scout"
name = "Large UFO Landing Site"
description = "Crashed large scout ship spanning 2×2 grid"
width = 30  # 2× standard width
height = 30  # 2× standard height
group = 1   # Objective group
tags = "ufo, large, crash, objective"
difficulty = 4

[tiles]
# UFO hull (center area)
"14_14" = "WALL_ALIEN"
"15_14" = "WALL_ALIEN"
"16_14" = "WALL_ALIEN"
# ... more tiles across 30×30 grid

# Crash debris (scattered around)
"5_5" = "DEBRIS_METAL"
"8_3" = "FIRE_SMALL"
"22_18" = "DEBRIS_METAL"

# Landing scorch marks
"10_10" = "GROUND_SCORCHED"
"11_10" = "GROUND_SCORCHED"
# ... more scorch pattern
```

## Map Script Integration

Map Blocks are placed on the battlefield using **Map Scripts**. See [Map Script Reference](MAP_SCRIPT_REFERENCE.md) for detailed documentation.

### Quick Example

```toml
# urban_mission.toml (Map Script)
[metadata]
id = "urban_mission"
name = "Urban Patrol Mission"
mapSize = [5, 5]  # 75×75 tiles (5×5 Map Blocks)

# Place player craft (group 1)
[[commands]]
type = "addCraft"
craftName = "skyranger"
label = 1

# Add roads (groups 2, 3, 4)
[[commands]]
type = "addLine"
direction = "both"
conditionals = [1]  # Only if craft placed
label = 2

# Add buildings near roads (groups 5, 6)
[[commands]]
type = "addBlock"
groups = [5, 6]
conditionals = [2]  # Only if roads exist
executions = 8

# Fill remaining space with filler blocks (group 0)
[[commands]]
type = "fillArea"
groups = [0]
```

**Map Block Group Usage:**
- Group 0: Generic filler blocks
- Group 1: Craft landing site
- Groups 2-4: Road segments (horizontal, vertical, intersections)
- Groups 5-6: Buildings

## Engine Integration

### Loading Map Blocks

```lua
local MapBlockLoader = require("engine.battlescape.map.mapblock_loader")

-- Load all Map Blocks from mod
MapBlockLoader.loadAll("mods/core/mapblocks/")

-- Get specific Map Block
local block = MapBlockLoader.get("urban_building_small_01")
print(block.width)   -- 15
print(block.height)  -- 15
print(block.group)   -- 5

-- Get Map Blocks by group
local buildings = MapBlockLoader.getByGroup(5)
for _, block in ipairs(buildings) do
    print(block.id, block.name)
end

-- Get Map Blocks by tags
local urbanBlocks = MapBlockLoader.getByTags({"urban", "building"})
```

### Using in Map Generation

```lua
local MapScriptExecutor = require("engine.battlescape.logic.mapscript_executor")

-- Execute Map Script
local battlefield = MapScriptExecutor.execute({
    scriptId = "urban_mission",
    seed = 12345
})

-- Battlefield contains assembled map
print(battlefield.width)   -- 75 (5×15)
print(battlefield.height)  -- 75 (5×15)

-- Access tiles
for y = 0, battlefield.height - 1 do
    for x = 0, battlefield.width - 1 do
        local tile = battlefield:getTile(x, y)
        if tile then
            print(x, y, tile.mapTileKey)
        end
    end
end
```

### Rendering Map Blocks

```lua
local MapBlockRenderer = require("engine.battlescape.rendering.mapblock_renderer")

-- Render single Map Block (for preview/editor)
MapBlockRenderer.draw(block, screenX, screenY, {
    scale = 2.0,
    showGrid = true,
    highlightTile = {x = 5, y = 5}
})

-- Render battlefield (assembled map)
local BattlefieldRenderer = require("engine.battlescape.rendering.battlefield_renderer")
BattlefieldRenderer.draw(battlefield, cameraX, cameraY)
```

## Best Practices

### Map Block Design

1. **Test in Map Editor**: Always preview blocks visually before using
2. **Use Appropriate Groups**: Follow group conventions for Map Script compatibility
3. **Add Descriptive Tags**: Enable filtering and search in editor
4. **Consider Adjacency**: Blocks should connect reasonably when placed side-by-side
5. **Balance Density**: Mix open and dense areas for tactical gameplay
6. **Theme Consistency**: Use Map Tiles from related tilesets

### Multi-Sized Blocks

1. **Reserve for Special Structures**: Use for UFOs, large buildings, special objectives
2. **Ensure Map Script Support**: Verify Map Scripts can place your block size
3. **Test Generation**: Ensure blocks don't cause generation failures
4. **Document Size**: Clearly indicate dimensions in name/description

### Performance

1. **Tile Count**: More tiles = more processing. Keep under 100 tiles per 15×15 block for optimal performance
2. **Multi-Tiles**: Heavy use of animations/autotiles increases rendering cost
3. **Empty Tiles**: Leaving tiles empty (not specified) is FREE - engine skips rendering

### Modding

1. **Unique IDs**: Use mod prefix (e.g., `mymod_urban_building_01`)
2. **Don't Override Core Blocks**: Create new blocks instead
3. **Document Group Usage**: Tell Map Script authors which groups your blocks use
4. **Test with Multiple Map Scripts**: Ensure blocks work in various contexts

## Troubleshooting

### Block Not Loading

**Check:**
1. TOML syntax is valid (use validator)
2. `id` is unique (no duplicates)
3. `width` and `height` are multiples of 15
4. File is in `mods/*/mapblocks/` directory
5. Mod is loaded before use

### Tiles Not Rendering

**Check:**
1. Map Tile KEYs exist in tileset definitions
2. Tileset is loaded before Map Block
3. Coordinates are within block bounds (0 to width-1, 0 to height-1)
4. Coordinate format is `"x_y"` (not `"x,y"` or other)

### Multi-Tile Not Working

**Check:**
1. Multi-tile Map Tile is defined correctly in tileset
2. Adjacent cells are NOT specified (engine reserves them automatically)
3. Enough space exists for multi-tile to fit
4. Multi-tile definition includes correct `multiTileMode`

### Block Not Selected by Map Script

**Check:**
1. `group` matches what Map Script expects
2. `tags` include keywords Map Script filters by
3. `width` and `height` match Map Script's `size` parameter
4. `difficulty` is within Map Script's range

### Generation Fails

**Check:**
1. Map Script has enough blocks in each group
2. `maxUses` is not too restrictive
3. Multi-sized blocks have correct `size` in Map Script
4. Map dimensions accommodate all required blocks

## See Also

- [Map Script Reference](MAP_SCRIPT_REFERENCE.md) - Assembling maps procedurally
- [Tileset System](../../TILESET_SYSTEM.md) - Creating and organizing Map Tiles
- [Map Tile Key Reference](TILE_KEY_REFERENCE.md) - Complete list of available tiles
- [Map Editor Documentation](../../../tools/map_editor/README.md) - Using the visual editor
- [API Reference](../../API.md) - Engine API for Map Blocks and generation
- [Hex Grid System](../../HEX_RENDERING_GUIDE.md) - Understanding hex coordinate systems
