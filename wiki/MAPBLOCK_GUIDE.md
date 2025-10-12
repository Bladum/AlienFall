# MapBlock System Guide

## Overview

The MapBlock system enables **procedural battlefield generation** from reusable 15×15 tile templates. Maps are assembled by arranging multiple blocks in a grid (4×4 to 7×7), then rotating them 45° to create varied hex-grid battlefields.

## System Architecture

```
MapBlock Templates (TOML files)
    ↓
MapBlock.loadAll() → blockPool
    ↓
GridMap.new(gridWidth, gridHeight)
    ↓
GridMap:generateThemed(blockPool, biomePreferences)
    ↓
GridMap:toBattlefield() → Battlefield (60-105 tiles)
    ↓
Used in Battlescape
```

### Key Components

1. **MapBlock**: 15×15 tile template with metadata (ID, biome, difficulty, etc.)
2. **GridMap**: Grid of MapBlocks with assembly and generation logic
3. **TOML Parser**: Reads MapBlock configuration files
4. **Battlefield**: Final playable map created from GridMap

## MapBlock Format

### File Structure

MapBlocks are stored as TOML files in `mods/core/mapblocks/`:

```toml
# Metadata section (required)
[metadata]
id = "unique_block_id"
name = "Display Name"
description = "Brief description of the block"
width = 15
height = 15
biome = "urban"      # urban, forest, industrial, water, rural, mixed
difficulty = 2       # 1=easy, 2=medium, 3=hard
author = "System"
tags = "descriptive, keywords, for, searching"

# Tiles section (optional - defaults to grass)
[tiles]
"x_y" = "terrain_type"
"0_0" = "road"
"0_1" = "road"
"1_0" = "wall"
"1_1" = "floor"
# ... more tiles
```

### Coordinate System

- **Format**: `"x_y"` where x and y are 0-indexed integers (0-14)
- **Origin**: Top-left corner is (0, 0)
- **Range**: X and Y from 0 to 14 (15 tiles in each dimension)
- **Omitted Tiles**: Any tile not specified defaults to "grass"

### Terrain Types

Available terrain types (must match `engine/data/terrain_types.lua`):

| Terrain ID    | Description                | Passable | Cover | Sight Cost |
|---------------|----------------------------|----------|-------|------------|
| `floor`       | Indoor flooring            | Yes      | None  | 1          |
| `grass`       | Open grassland             | Yes      | None  | 1          |
| `wall`        | Stone wall                 | No       | Full  | 10         |
| `wood_wall`   | Wooden wall                | No       | Full  | 10         |
| `door`        | Doorway                    | Yes      | None  | 1          |
| `tree`        | Large tree                 | Yes      | Heavy | 5          |
| `bushes`      | Dense bushes               | Yes      | Light | 3          |
| `rock`        | Boulder/rock formation     | No       | Full  | 10         |
| `water`       | Water tile                 | No       | None  | 2          |
| `mud`         | Muddy ground               | Yes      | None  | 2          |
| `road`        | Paved road                 | Yes      | None  | 1          |
| `fence`       | Wooden fence               | No       | Light | 3          |

### Biome Types

Biomes determine block selection during themed generation:

- **urban**: Cities, buildings, roads, residential areas
- **forest**: Trees, clearings, natural vegetation
- **industrial**: Warehouses, storage yards, factories
- **water**: Lakes, rivers, muddy shores
- **rural**: Farms, fields, barns
- **mixed**: Combination of multiple terrain types

## Creating MapBlocks

### Step-by-Step Guide

1. **Copy Template**: Start from `mods/core/mapblocks/open_field_01.toml`
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

## GridMap System

### Grid Sizes

- **Minimum**: 4×4 grid (60×60 tiles)
- **Maximum**: 7×7 grid (105×105 tiles)
- **Random**: Game randomly selects size each battle
- **World Size**: `gridSize * 15` tiles in each dimension

### Generation Modes

#### Random Generation

```lua
local gridMap = GridMap.new(5, 5)
gridMap:generateRandom(blockPool, seed)
```

- **Random Placement**: Fills grid with random blocks from pool
- **No Biome Filter**: Any block can appear anywhere
- **Seed**: Optional seed for reproducible maps

#### Themed Generation

```lua
local gridMap = GridMap.new(6, 6)
gridMap:generateThemed(blockPool, {
    urban = 0.3,      -- 30% urban blocks
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
