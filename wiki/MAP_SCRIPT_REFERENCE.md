# Map Script Reference

## Overview

Map Scripts define **procedural assembly rules** for creating battlescape maps from Map Blocks. Inspired by OpenXCOM's map generation system, scripts use commands to place, check, and manipulate blocks according to conditional logic.

**Key Concepts:**
- Map Scripts are stored as **TOML files** in `mods/core/mapscripts/`
- Each script contains a **sequence of commands** executed in order
- Commands can be **conditional** based on previous command success/failure
- Map Blocks are organized into **groups** for flexible placement
- Scripts support **probabilistic execution** for variety

---

## File Structure

Map Scripts are defined in TOML format:

```toml
# Map Script Metadata
[metadata]
id = "urban_terror_site"
name = "Urban Terror Site"
description = "City streets with UFO crash site"
type = "terror_site"
mapSize = [5, 5]  # Grid dimensions in MapBlocks (75×75 tiles)

# Command sequence
[[commands]]
type = "addUFO"
UFOName = "small_scout"
label = 1
executionChances = 100

[[commands]]
type = "addLine"
direction = "horizontal"
groups = [2]
executionChances = 80
conditionals = [1]  # Only if UFO placed successfully

[[commands]]
type = "fillArea"
groups = [0, 1]
freqs = [70, 30]
```

---

## Map Script Structure

### Metadata Section

```toml
[metadata]
id = "unique_script_id"           # Required: Unique identifier
name = "Display Name"              # Required: Human-readable name
description = "Script description" # Optional: Brief description
type = "mission_type"              # Optional: Mission type association
mapSize = [width, height]          # Required: Map dimensions in MapBlocks (4-7 each)
```

**Map Size:**
- `[4, 4]` = 60×60 tiles (minimum, small skirmish)
- `[5, 5]` = 75×75 tiles (standard mission)
- `[6, 6]` = 90×90 tiles (large mission)
- `[7, 7]` = 105×105 tiles (maximum, epic battle)

---

## Command Types

All commands support these common properties:

```toml
[[commands]]
type = "command_name"              # Required: Command type
label = 1                          # Optional: Numeric label for conditionals (positive, unique)
conditionals = [1, -4]             # Optional: Execute if label 1 succeeded AND label 4 failed
executionChances = 80              # Optional: 0-100% probability (default: 100)
executions = 3                     # Optional: Repeat command N times (default: 1)
rects = [[x, y, w, h]]            # Optional: Restrict to specific map areas (default: entire map)
```

### Common Properties Explained

**label** (integer, default: 0)
- Positive, unique numeric identifier for this command
- Used by other commands to check success/failure
- Example: `label = 5` means other commands can reference this as `5` (success) or `-5` (failure)

**conditionals** (array of integers)
- Pre-conditions for command execution
- Positive values: command must have succeeded (e.g., `[1, 4]` means labels 1 AND 4 succeeded)
- Negative values: command must have failed (e.g., `[-2]` means label 2 failed)
- Allows building complex binary decision trees
- Unexecuted commands are always in "failed" state

**executionChances** (integer, 0-100, default: 100)
- Probability that command will execute
- `100` = always execute (if conditionals pass)
- `50` = 50% chance to execute
- Useful for optional features or variety

**executions** (integer, default: 1)
- Number of times to repeat the command
- Each execution is independent (can succeed/fail separately)
- Useful for placing multiple instances of same block type

**rects** (array of [x, y, width, height])
- Restricts command to specific map areas
- Coordinates in MapBlock grid units (not tiles)
- Multiple rects = random choice from list
- Example: `[[0, 0, 2, 2], [3, 3, 2, 2]]` = top-left or bottom-right corner only

---

## Command Reference

### addBlock

Places a specific Map Block or random block from group(s).

```toml
[[commands]]
type = "addBlock"
groups = [0, 1, 2]                 # Groups to select from
freqs = [50, 30, 20]               # Selection weights (default: equal)
maxUses = [10, 5, 3]               # Max uses per group (default: unlimited)
size = [1, 1]                      # Block size (default: 1×1)
blocks = [0, 5, 12]                # Alternative: specific block IDs (0-indexed)
markAsReinforcementsBlock = false  # Mark for alien reinforcements (default: false)
```

**Parameters:**
- **groups**: Array of group IDs to choose from
- **blocks**: Alternative to groups - explicit list of Map Block sequential IDs (0-indexed)
- **freqs**: Weight distribution for groups/blocks (higher = more likely)
- **maxUses**: Maximum times each group/block can be used (-1 = unlimited)
- **size**: Dimensions of blocks to place `[width, height]` in MapBlocks
- **markAsReinforcementsBlock**: If true, aliens/civilians can spawn here during battle

**Example:**
```toml
# Place 2-3 large buildings (3×2 MapBlocks)
[[commands]]
type = "addBlock"
groups = [5]           # Building group
size = [3, 2]          # 3×2 MapBlocks = 45×30 tiles
executions = 3         # Try 3 times
executionChances = 70  # 70% chance per attempt
```

---

### addLine

Creates a line (road, river, path) using connected Map Blocks.

```toml
[[commands]]
type = "addLine"
direction = "both"                 # "horizontal", "vertical", or "both"
horizontalGroup = 2                # Group for horizontal segments (default: 2)
verticalGroup = 3                  # Group for vertical segments (default: 3)
crossingGroup = 4                  # Group for intersections (default: 4)
```

**Parameters:**
- **direction**: Line orientation
  - `"horizontal"`: East-west line
  - `"vertical"`: North-south line
  - `"both"`: Connected horizontal and vertical segments
- **horizontalGroup**: Map Block group for horizontal road pieces
- **verticalGroup**: Map Block group for vertical road pieces
- **crossingGroup**: Map Block group for crossroads/intersections

**Usage:**
Lines are fundamental for road networks, rivers, paths. The system automatically selects appropriate blocks for straight segments vs. crossings.

**Example:**
```toml
# Create intersecting roads
[[commands]]
type = "addLine"
direction = "both"
horizontalGroup = 2  # Horizontal road blocks
verticalGroup = 3    # Vertical road blocks
crossingGroup = 4    # Intersection blocks
executionChances = 90
```

---

### addCraft

Places X-Com craft landing site (required for player spawn).

```toml
[[commands]]
type = "addCraft"
craftName = "skyranger"            # Craft type to place
craftGroups = [1]                  # Only execute if craft with this group deployed
```

**Parameters:**
- **craftName**: String ID of craft (e.g., "skyranger", "lightning")
- **craftGroups**: Command only executes if craft with matching group was deployed

**Notes:**
- **Every map must have a craft placement** (or equivalent spawn area)
- Craft placement uses blocks from **group 1** by default
- If craft placement fails, game will crash with "Cannot place X-Com units"

**Example:**
```toml
# Place player's Skyranger
[[commands]]
type = "addCraft"
craftName = "skyranger"
label = 1
executionChances = 100  # Must succeed
```

---

### addUFO

Places UFO/objective structure on map.

```toml
[[commands]]
type = "addUFO"
UFOName = "small_scout"            # UFO type to place
canBeSkipped = false               # Can command fail without crash? (default: true)
```

**Parameters:**
- **UFOName**: String ID of UFO or structure (e.g., "small_scout", "alien_base")
- **canBeSkipped**: If false and placement fails, game crashes (use for debugging)

**Notes:**
- UFO placement uses blocks from **group 1** by default
- Can be used for any single large structure (alien bases, mission objectives)
- Set `canBeSkipped = false` during testing to ensure valid scripts

**Example:**
```toml
# Place crashed UFO
[[commands]]
type = "addUFO"
UFOName = "medium_fighter"
label = 2
executionChances = 100
canBeSkipped = false  # Crash if fails (testing)
```

---

### fillArea

Fills remaining empty spaces with random blocks.

```toml
[[commands]]
type = "fillArea"
groups = [0, 1, 2]                 # Groups to fill with
freqs = [60, 30, 10]               # Selection weights
maxUses = [-1, 20, 10]             # Max uses per group
size = [1, 1]                      # Block size
```

**Parameters:**
- Same as `addBlock` but applied to **all empty map positions**
- **groups**: Groups to randomly select from
- **freqs**: Distribution weights
- **maxUses**: Limit uses per group (-1 = unlimited)

**Usage:**
Typically the **last command** in a script to ensure no empty spaces remain.

**Example:**
```toml
# Fill remaining map with generic blocks
[[commands]]
type = "fillArea"
groups = [0, 1]
freqs = [70, 30]      # 70% group 0, 30% group 1
maxUses = [-1, 15]    # Group 0 unlimited, group 1 max 15
```

---

### checkBlock

Tests if a block exists at position(s) without modifying the map.

```toml
[[commands]]
type = "checkBlock"
groups = [2, 3]                    # Groups to check for
size = [1, 1]                      # Block size to check
label = 5                          # Store result for conditionals
```

**Parameters:**
- **groups**: Check if block from these groups exists
- **size**: Size of block to check for
- **label**: Required - stores success/failure for later conditionals

**Usage:**
Enables conditional logic: "If road exists here, place building next to it."

**Example:**
```toml
# Check if road exists
[[commands]]
type = "checkBlock"
groups = [2, 3]  # Road groups
label = 10

# If road found, place building nearby
[[commands]]
type = "addBlock"
groups = [5]  # Building group
conditionals = [10]  # Only if checkBlock succeeded
```

---

### removeBlock

Removes blocks matching criteria from the map.

```toml
[[commands]]
type = "removeBlock"
groups = [1, 2]                    # Groups to remove
size = [1, 1]                      # Block size to remove
```

**Parameters:**
- **groups**: Remove blocks from these groups
- **size**: Size of blocks to remove

**Usage:**
Rarely used, but useful for creating clearings or removing placeholder blocks.

**Example:**
```toml
# Remove placeholder blocks
[[commands]]
type = "removeBlock"
groups = [99]  # Placeholder group
```

---

### digTunnel

Creates underground tunnels or caves by modifying terrain.

```toml
[[commands]]
type = "digTunnel"
direction = "both"                 # "horizontal", "vertical", or "both"
tunnelData = { level = 0, MCDReplacements = [] }
```

**Parameters:**
- **direction**: Tunnel direction
- **tunnelData**: Defines tunnel level and terrain replacement rules
  - **level**: Height level (0 = ground, 1+ = elevated)
  - **MCDReplacements**: Array of {from, to} terrain tile replacements

**Usage:**
Advanced command for creating multi-level maps with tunnels, basements, or cave systems.

**Example:**
```toml
# Dig horizontal tunnel at ground level
[[commands]]
type = "digTunnel"
direction = "horizontal"
tunnelData = { level = 0 }
executionChances = 60
```

---

### resize

Changes the map dimensions mid-generation.

```toml
[[commands]]
type = "resize"
size = [6, 6, 4]                   # [width, height, levels]
```

**Parameters:**
- **size**: New map dimensions `[width, height, verticalLevels]`
  - **width/height**: In MapBlocks (4-7)
  - **verticalLevels**: Number of height levels (1-6)

**Usage:**
Allows dynamic map sizing based on mission parameters or early command results.

**Example:**
```toml
# Expand map if UFO is large
[[commands]]
type = "resize"
size = [7, 7, 2]  # 105×105 tiles, 2 levels
conditionals = [5]  # Only if large UFO placed
```

---

## Advanced Features

### Conditional Execution

Build complex decision trees using labels and conditionals:

```toml
# Try to place UFO
[[commands]]
type = "addUFO"
UFOName = "small_scout"
label = 1

# If UFO placed, add crash damage
[[commands]]
type = "addBlock"
groups = [10]  # Crater/debris group
conditionals = [1]  # Only if UFO placed
label = 2

# If crash damage added, place fire
[[commands]]
type = "addBlock"
groups = [11]  # Fire/smoke group
conditionals = [1, 2]  # Only if UFO AND debris placed

# If UFO NOT placed, use mission site instead
[[commands]]
type = "addBlock"
groups = [12]  # Mission objective group
conditionals = [-1]  # Only if UFO failed
```

### Binary Tree Logic

Use flags to create branching logic:

```toml
# Check if roads exist
[[commands]]
type = "checkBlock"
groups = [2, 3]
label = 10  # Flag: roads exist

# Branch A: If roads exist, add urban buildings
[[commands]]
type = "addBlock"
groups = [20]  # Urban buildings
conditionals = [10]
executions = 5

# Branch B: If no roads, add rural structures
[[commands]]
type = "addBlock"
groups = [21]  # Rural buildings
conditionals = [-10]
executions = 3
```

### Probabilistic Variety

Create varied maps with probabilistic commands:

```toml
# 80% chance to add a river
[[commands]]
type = "addLine"
direction = "both"
groups = [8]  # River blocks
label = 20
executionChances = 80

# If river exists, add bridge (70% chance)
[[commands]]
type = "addBlock"
groups = [9]  # Bridge blocks
conditionals = [20]
executionChances = 70
```

### Multi-Sized Blocks

Handle blocks larger than 1×1 MapBlocks:

```toml
# Place large warehouse (3×2 MapBlocks = 45×30 tiles)
[[commands]]
type = "addBlock"
groups = [15]
size = [3, 2]  # Reserves 6 MapBlock positions
executions = 2  # Try placing 2 warehouses
```

**Important:** When placing multi-sized blocks, the system:
1. Reserves all required grid positions
2. Prevents overlap with other blocks
3. Works with non-standard dimensions (e.g., 3×1, 2×4)

### Terrain Override

Use alternate terrain for specific commands:

```toml
# Most of map is urban, but add forest clearing
[[commands]]
type = "addBlock"
groups = [0]
terrain = "light_forest"  # Override default terrain
executions = 3
```

**Special Constants:**
- `terrain = "globeTerrain"`: Use terrain matching globe texture at mission location
- `terrain = "baseTerrain"`: For base defense missions, use globe-defined terrain

### Random Terrain Selection

Choose terrain randomly from list:

```toml
[[commands]]
type = "fillArea"
groups = [0]
randomTerrain = ["urban_street", "urban_industrial", "urban_park"]
```

### Vertical Levels

Stack Map Blocks vertically for multi-story structures:

```toml
# Create 3-story building
[[commands]]
type = "addBlock"
groups = [25]
verticalLevels = [
    {group = 25, level = 0},  # Ground floor
    {group = 26, level = 1},  # Second floor
    {group = 27, level = 2}   # Third floor
]
```

---

## Group System

Map Blocks are organized into **groups** by their `group` property in TOML metadata. Scripts reference these groups to select appropriate blocks.

### Standard Group Conventions

| Group ID | Purpose | Example Blocks |
|----------|---------|----------------|
| 0 | Generic filler | Open fields, grass, empty lots |
| 1 | Objectives | Craft, UFOs, mission sites |
| 2 | Horizontal lines | Horizontal roads, rivers |
| 3 | Vertical lines | Vertical roads, rivers |
| 4 | Crossings | Intersections, bridges |
| 5+ | Themed content | Buildings, forests, special features |

**Note:** Group IDs are purely organizational. You can use any positive integer.

### Example Group Organization

```toml
# Urban terrain groups
# Group 0: Generic urban filler
# Group 1: UFO landing sites
# Group 2: Horizontal streets
# Group 3: Vertical streets
# Group 4: Intersections
# Group 5: Residential buildings
# Group 6: Commercial buildings
# Group 7: Industrial warehouses
# Group 8: Parks and plazas
```

---

## Best Practices

### Script Design

1. **Always place craft first** - Ensures player spawn point exists
2. **Use fillArea last** - Fills remaining empty spaces
3. **Test maxUses carefully** - Prevents generation failures when map expands
4. **Label critical commands** - Enables conditional logic
5. **Use executionChances for variety** - Creates different layouts each time

### Testing

```toml
# Enable strict checking during development
[[commands]]
type = "addUFO"
UFOName = "test_structure"
canBeSkipped = false  # Crash if fails - catches bad scripts early
label = 1

# Verify craft placement
[[commands]]
type = "addCraft"
craftName = "skyranger"
label = 2

# If either failed, script is broken
[[commands]]
type = "fillArea"
groups = [0]
conditionals = [1, 2]  # Only if both succeeded
```

### Performance

- **Limit executions**: High execution counts slow generation
- **Use rects strategically**: Restricting placement areas speeds up search
- **Avoid excessive conditionals**: Complex logic increases generation time
- **Balance group sizes**: Ensure enough blocks in each group to meet maxUses

### Compatibility

- **Don't hardcode terrain names** - Use group system for flexibility
- **Avoid tileset-specific logic** - Scripts should work with any tileset
- **Document group usage** - Comment which groups the script expects
- **Test with varying map sizes** - Ensure script scales properly

---

## Example Scripts

### Simple Urban Mission

```toml
[metadata]
id = "urban_simple"
name = "Urban Patrol"
type = "patrol"
mapSize = [5, 5]

# Place player craft
[[commands]]
type = "addCraft"
craftName = "skyranger"
label = 1

# Add some roads
[[commands]]
type = "addLine"
direction = "both"
executionChances = 80
label = 2

# Place buildings near roads
[[commands]]
type = "addBlock"
groups = [5, 6]
conditionals = [2]
executions = 8
executionChances = 75

# Fill remaining space
[[commands]]
type = "fillArea"
groups = [0]
freqs = [100]
```

### UFO Crash Site

```toml
[metadata]
id = "ufo_crash_forest"
name = "UFO Crash - Forest"
type = "crash_site"
mapSize = [6, 6]

# Place crashed UFO
[[commands]]
type = "addUFO"
UFOName = "small_scout"
label = 1
canBeSkipped = false

# Add crash debris around UFO
[[commands]]
type = "addBlock"
groups = [10]  # Debris group
conditionals = [1]
rects = [[2, 2, 3, 3]]  # Center area only
executions = 5

# Place player craft away from crash
[[commands]]
type = "addCraft"
craftName = "skyranger"
rects = [[0, 0, 2, 2]]  # Corner only
label = 2

# Add forest coverage
[[commands]]
type = "addBlock"
groups = [15]  # Forest blocks
executions = 12
executionChances = 70

# Fill remaining
[[commands]]
type = "fillArea"
groups = [0]
```

### Terror Site with Conditional Logic

```toml
[metadata]
id = "terror_site_adaptive"
name = "Terror Site - Adaptive"
type = "terror"
mapSize = [5, 5]

# Place player craft
[[commands]]
type = "addCraft"
craftName = "skyranger"
label = 1

# Try to place UFO
[[commands]]
type = "addUFO"
UFOName = "terror_ship"
label = 2
executionChances = 70

# If UFO placed, add roads leading to it
[[commands]]
type = "addLine"
direction = "both"
conditionals = [2]
label = 3

# If no UFO, place mission site instead
[[commands]]
type = "addBlock"
groups = [20]  # Mission site group
conditionals = [-2]
label = 4

# Add civilians (if UFO or mission site exists)
[[commands]]
type = "addBlock"
groups = [30]  # Civilian spawn points
conditionals = [2]  # UFO path
executions = 10
markAsReinforcementsBlock = true

[[commands]]
type = "addBlock"
groups = [30]
conditionals = [-2, 4]  # Mission site path
executions = 10
markAsReinforcementsBlock = true

# Fill with urban blocks
[[commands]]
type = "fillArea"
groups = [0, 5, 6]
freqs = [50, 30, 20]
```

---

## Integration with Engine

### Loading Map Scripts

```lua
local MapScripts = require("battlescape.data.mapscripts")

-- Get script by ID
local script = MapScripts.get("urban_terror_site")

-- Find matching scripts
local matches = MapScripts.findMatching({
    biome = "urban",
    difficulty = 3,
    maxWidth = 6,
    maxHeight = 6
})
```

### Executing Map Scripts

```lua
local MapScriptExecutor = require("battlescape.logic.mapscript_executor")

local battlefield = MapScriptExecutor.execute({
    script = script,
    blockPool = blockPool,
    seed = 12345
})
```

**Note:** Do NOT store script names, terrain names, or tileset names in engine code. Always use IDs and dynamic lookup.

---

## Migration from Old System

If upgrading from previous map generation:

1. **Preserve existing Map Blocks** - TOML format unchanged
2. **Convert manual scripts to commands** - Replace procedural code with declarative commands
3. **Define groups** - Organize blocks into logical groups
4. **Test thoroughly** - Verify all mission types generate correctly
5. **Update documentation** - Document group conventions for modders

---

## See Also

- [MapBlock Guide](MAPBLOCK_GUIDE.md) - Creating Map Block TOML files
- [Tileset System](TILESET_SYSTEM.md) - Organizing graphics and tilesets
- [Map Editor](../engine/tools/map_editor/) - Visual Map Block editor
- [API Reference](API.md) - Engine API for map generation
