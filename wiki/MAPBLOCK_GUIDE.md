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

**Available Map Tile KEYs** (see [Tileset System](TILESET_SYSTEM.md) for complete list):

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

---

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

---

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
2. **Edit Metadata**: Set unique ID, name, biome, difficulty
3. **Design Layout**: Plan your 15×15 tile layout on paper or digitally
4. **Add Tiles**: Specify terrain for each non-grass tile
5. **Test**: Load in game and verify appearance
6. **Iterate**: Refine based on gameplay testing

### Design Principles

#### Balance

- **Mix Open and Dense**: Combine open areas with cover
- **Avoid Monoculture**: Use 3-5 different terrain types
- **Create Paths**: Include movement corridors
- **Strategic Points**: Add defensible positions

#### Gameplay

- **Cover Distribution**: 30-40% cover terrain for tactical options
- **Sightlines**: Create both long and short sight lines
- **Choke Points**: Add 2-3 natural choke points
- **Flanking Routes**: Enable multiple approach paths

#### Theme Consistency

- **Urban**: Focus on buildings, roads, fences
- **Forest**: Use trees, bushes, occasional clearings
- **Industrial**: Warehouses, containers, paved areas
- **Water**: Central water feature with muddy shores
- **Rural**: Fields (bushes), barns (wood_wall), dirt paths (mud)
- **Mixed**: Combine elements from multiple biomes

### Example: Urban Block

```toml
[metadata]
id = "urban_crossroads_01"
name = "City Crossroads"
description = "Intersection with buildings on corners"
width = 15
height = 15
biome = "urban"
difficulty = 2
author = "YourName"
tags = "urban, roads, buildings, medium"

[tiles]
# Horizontal road (center)
"7_0" = "road"
"7_1" = "road"
"7_2" = "road"
# ... (7_3 through 7_14)

# Vertical road (center)
"0_7" = "road"
"1_7" = "road"
"2_7" = "road"
# ... (3_7 through 14_7)

# Building (top-left corner)
"2_2" = "wall"
"2_3" = "wall"
"2_4" = "wall"
"3_2" = "wall"
"3_4" = "wall"
"4_2" = "wall"
"4_3" = "door"
"4_4" = "wall"
"3_3" = "floor"

# ... more buildings in other corners
```

---

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

### Non-Standard Dimensions

You can create blocks with asymmetric dimensions:

- **3×1** (45×15): Long road segment, river section
- **1×3** (15×45): Tall tower, vertical river
- **3×2** (45×30): Large warehouse
- **2×3** (30×45): Multi-story building

**Important:** Map Scripts must specify correct size to place these blocks:

```toml
[[commands]]
type = "addBlock"
groups = [15]
size = [3, 2]  # Must match block's actual size (45×30 tiles)
```

---

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

---

## Engine Integration

### Loading Map Blocks

```lua
local MapBlockLoader = require("battlescape.map.mapblock_loader")

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
local MapScriptExecutor = require("battlescape.logic.mapscript_executor")

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
local MapBlockRenderer = require("battlescape.rendering.mapblock_renderer")

-- Render single Map Block (for preview/editor)
MapBlockRenderer.draw(block, screenX, screenY, {
    scale = 2.0,
    showGrid = true,
    highlightTile = {x = 5, y = 5}
})

-- Render battlefield (assembled map)
local BattlefieldRenderer = require("battlescape.rendering.battlefield_renderer")
BattlefieldRenderer.draw(battlefield, cameraX, cameraY)
```

---

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

---

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

---

## See Also

- [Map Script Reference](MAP_SCRIPT_REFERENCE.md) - Assembling maps procedurally
- [Tileset System](TILESET_SYSTEM.md) - Creating and organizing Map Tiles
- [Map Editor Documentation](../engine/tools/map_editor/README.md) - Using the visual editor
- [API Reference](API.md) - Engine API for Map Blocks and generation
- [Hex Grid System](HEX_GRID.md) - Understanding hex coordinate systems
    forest = 0.25,    -- 25% forest blocks
    industrial = 0.2, -- 20% industrial blocks
    water = 0.1,      -- 10% water blocks
    rural = 0.1,      -- 10% rural blocks
    mixed = 0.05      -- 5% mixed blocks
})
```

- **Biome Preferences**: Weighted selection by biome
- **80/20 Split**: 80% primary biome, 20% variety
- **Filtering**: Selects blocks matching target biome
- **Fallback**: Uses any block if biome unavailable

### Coordinate Systems

GridMap uses three coordinate systems:

#### 1. Grid Coordinates

- **Range**: (0, 0) to (gridWidth-1, gridHeight-1)
- **Usage**: Addressing blocks in the grid
- **Example**: Block at grid position (2, 3)

```lua
local block = gridMap:getBlock(2, 3)
gridMap:setBlock(2, 3, mapBlock)
```

#### 2. World Coordinates

- **Range**: (1, 1) to (worldWidth, worldHeight)
- **Usage**: Final battlefield tile positions
- **Calculation**: `worldWidth = gridWidth * 15`

```lua
local terrainId = gridMap:getTileAt(45, 67)  -- World coordinates
```

#### 3. Local Coordinates

- **Range**: (1, 1) to (15, 15) within a block
- **Usage**: Accessing tiles within a specific block
- **Conversion**: `localX = worldX - blockWorldX + 1`

```lua
local gx, gy = gridMap:worldToBlock(worldX, worldY)
local localX, localY = gridMap:worldToLocal(worldX, worldY)
local block = gridMap:getBlock(gx, gy)
local tile = block:getTile(localX, localY)
```

### Methods

```lua
-- Constructor
local gridMap = GridMap.new(gridWidth, gridHeight)

-- Block management
gridMap:setBlock(gridX, gridY, mapBlock)
local block = gridMap:getBlock(gridX, gridY)

-- Coordinate conversion
local gridX, gridY = gridMap:worldToBlock(worldX, worldY)
local worldX, worldY = gridMap:blockToWorld(gridX, gridY)
local localX, localY = gridMap:worldToLocal(worldX, worldY)

-- Tile access
local terrainId = gridMap:getTileAt(worldX, worldY)

-- Generation
gridMap:generateRandom(blockPool, seed)
gridMap:generateThemed(blockPool, biomePreferences)

-- Conversion
local battlefield = gridMap:toBattlefield()

-- Visualization
local ascii = gridMap:toASCII()
local stats = gridMap:getStats()
```

## MapBlock Class

### Creating MapBlocks

```lua
-- Constructor
local block = MapBlock.new(id, width, height)

-- Set metadata
block.metadata = {
    id = "my_block_01",
    name = "My Block",
    biome = "urban",
    difficulty = 2
}

-- Set tiles
block:setTile(5, 5, "wall")
block:setTile(6, 5, "door")

-- Save to file
block:saveToTOML("mods/core/mapblocks/my_block_01.toml")
```

### Loading MapBlocks

```lua
-- Load single block
local block = MapBlock.loadFromTOML("mods/core/mapblocks/urban_block_01.toml")

-- Load all blocks from directory
local blockPool = MapBlock.loadAll("mods/core/mapblocks")

-- Check what was loaded
for i, block in ipairs(blockPool) do
    print(string.format("%d. %s (%s)", 
        i, block.metadata.name, block.metadata.biome))
end
```

### Methods

```lua
-- Tile access
local terrainId = block:getTile(x, y)  -- Returns terrain ID string
block:setTile(x, y, terrainId)

-- Serialization
block:saveToTOML(filepath)
local block = MapBlock.loadFromTOML(filepath)
local blocks = MapBlock.loadAll(directory)

-- Utilities
local ascii = block:toASCII()  -- ASCII representation
block:validate()                -- Check for errors

-- Defaults
local defaults = MapBlock.createDefaults()  -- 3 default blocks
```

## Integration with Battlescape

### Initialization

```lua
-- In battlescape:enter()
local blockPool = MapBlock.loadAll("mods/core/mapblocks")
local gridSize = math.random(4, 7)
local gridMap = GridMap.new(gridSize, gridSize)

gridMap:generateThemed(blockPool, {
    urban = 0.3,
    forest = 0.25,
    industrial = 0.2,
    water = 0.1,
    rural = 0.1,
    mixed = 0.05
})

self.battlefield = gridMap:toBattlefield()
```

### Rotation (45° Transform)

The system rotates the grid 45° to create hex-friendly layouts:

```
Original Grid          Rotated View (45°)
+---+---+              +---+
| A | B |             / A / \
+---+---+      →     +---+---+
| C | D |             \ C \ D \
+---+---+              +---+---+
```

This rotation:
- Creates diagonal alignment for hex grids
- Improves visual variety
- Enables more natural terrain flow
- **Note**: Not yet implemented - planned feature

## File Organization

### Directory Structure

```
mods/core/mapblocks/
├── open_field_01.toml        # Sparse vegetation
├── urban_block_01.toml       # City block with building
├── urban_residential_01.toml # Suburban houses
├── dense_forest_01.toml      # Heavy tree coverage
├── forest_clearing_01.toml   # Open area in forest
├── industrial_warehouse_01.toml # Warehouse district
├── industrial_yard_01.toml   # Storage yard
├── water_lake_01.toml        # Lake with shores
├── mixed_terrain_01.toml     # Varied features
└── rural_farm_01.toml        # Farmland with barn
```

### Naming Convention

- **Format**: `{biome}_{descriptor}_{version}.toml`
- **Biome**: urban, forest, industrial, water, rural, mixed
- **Descriptor**: Short name describing the block
- **Version**: 01, 02, 03... for variations

### Version Control

- **Track in Git**: All TOML files should be versioned
- **Review Changes**: Coordinate changes to avoid conflicts
- **Testing**: Test after modifying existing blocks
- **Backup**: Keep backups before major changes

## Advanced Techniques

### Block Variations

Create multiple versions of similar blocks:

- `urban_block_01.toml` - Large central building
- `urban_block_02.toml` - Two small buildings
- `urban_block_03.toml` - Building with parking lot

### Transition Blocks

Design blocks that blend biomes:

- `forest_edge_01.toml` - Trees on one side, grass on other
- `urban_rural_01.toml` - Buildings transitioning to fields
- `water_shore_01.toml` - Water gradually transitioning to land

### Symmetric vs Asymmetric

- **Symmetric**: Same layout on both axes (easier to place)
- **Asymmetric**: Unique features (more interesting)
- **Mix**: Combine both for best results

### Difficulty Tuning

Adjust difficulty through cover and openness:

- **Easy (1)**: Lots of cover, open paths, simple layout
- **Medium (2)**: Mixed cover, some choke points
- **Hard (3)**: Dense terrain, limited cover, complex layout

## Debugging and Testing

### Visualization

```lua
-- ASCII visualization
local ascii = gridMap:toASCII()
print(ascii)

-- Statistics
local stats = gridMap:getStats()
print("Blocks placed: " .. stats.blocksPlaced)
print("Empty slots: " .. stats.emptySlots)
for biome, count in pairs(stats.biomes) do
    print(biome .. ": " .. count)
end
```

### Console Output

Enable console output in `conf.lua`:

```lua
t.console = true  -- Shows debug output on Windows
```

Look for these messages:

```
[Battlescape] Loaded 10 MapBlock templates
[Battlescape] Creating 5x5 GridMap
[Battlescape] Generated battlefield: 75x75 tiles
```

### Common Issues

#### "Block not loaded"

- Check file path: `mods/core/mapblocks/filename.toml`
- Verify TOML syntax: Use TOML validator
- Check console for parsing errors

#### "Conflicting keys"

- Duplicate tile coordinates in TOML
- Example: `"5_5" = "wall"` appears twice
- Solution: Remove duplicate, use unique coordinates

#### "Invalid terrain type"

- Terrain ID doesn't match `terrain_types.lua`
- Check spelling: `"tree"` not `"trees"`
- Case sensitive: Use lowercase

#### "Map too small/large"

- Grid size outside 4-7 range
- Block pool empty (no blocks loaded)
- Solution: Verify block directory, check loadAll() output

## Performance

### Loading Time

- **Block Loading**: ~1-5 ms per block
- **10 Blocks**: ~10-50 ms total
- **Grid Generation**: ~5-15 ms
- **Battlefield Conversion**: ~10-30 ms
- **Total**: ~25-95 ms (negligible)

### Memory Usage

- **Per MapBlock**: ~2-5 KB (15×15 tiles)
- **10 Blocks**: ~20-50 KB
- **GridMap (5×5)**: ~50-125 KB
- **Final Battlefield**: ~150-300 KB
- **Total**: < 500 KB (minimal)

### Optimization Tips

1. **Lazy Loading**: Load blocks only when needed
2. **Block Caching**: Reuse loaded blocks across battles
3. **Sparse Storage**: Only store non-grass tiles in TOML
4. **Batch Generation**: Generate multiple maps in background

## Future Enhancements

### Planned Features

1. **Rotation**: 45° rotation for hex alignment
2. **Edge Matching**: Ensure adjacent blocks have compatible edges
3. **Mission-Specific Blocks**: Blocks designed for specific objectives
4. **Dynamic Obstacles**: Destructible terrain, moving hazards
5. **Weather Effects**: Rain, snow, fog affecting visibility
6. **Block Editor**: GUI tool for creating/editing MapBlocks
7. **Procedural Blocks**: Algorithm-generated blocks
8. **Block Tags**: Advanced filtering by gameplay features

### Community Contributions

We welcome MapBlock submissions!

1. **Create**: Design your MapBlock following this guide
2. **Test**: Load and play on your block
3. **Submit**: Create PR with TOML file and description
4. **Review**: Maintainers review for balance and quality
5. **Merge**: Block added to core collection

## See Also

- [Fire and Smoke Mechanics](FIRE_SMOKE_MECHANICS.md) - Environmental effects
- [API Documentation](API.md) - Complete API reference
- [FAQ](FAQ.md) - Common questions about map generation
- [TOML Specification](https://toml.io/) - TOML format details
