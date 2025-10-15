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

## Metadata Section

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

## Common Command Properties

All commands support these properties:

```toml
[[commands]]
type = "command_name"              # Required: Command type
label = 1                          # Optional: Numeric label for conditionals (positive, unique)
conditionals = [1, -4]             # Optional: Execute if label 1 succeeded AND label 4 failed
executionChances = 80              # Optional: 0-100% probability (default: 100)
executions = 3                     # Optional: Repeat command N times (default: 1)
rects = [[x, y, w, h]]            # Optional: Restrict to specific map areas (default: entire map)
```

### Property Details

**label** (integer, default: 0)
- Positive, unique numeric identifier for this command
- Used by other commands to check success/failure
- Example: `label = 5` means other commands can reference this as `5` (success) or `-5` (failure)

**conditionals** (array of integers)
- Pre-conditions for command execution
- Positive values: command must have succeeded (e.g., `[1, 4]` means labels 1 AND 4 succeeded)
- Negative values: command must have failed (e.g., `[-2]` means label 2 failed)
- Allows building complex binary decision trees

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

### addCraft

Places X-Com craft landing site (required for player spawn).

```toml
[[commands]]
type = "addCraft"
craftName = "skyranger"            # Craft type to place
craftGroups = [1]                  # Only execute if craft with this group deployed
```

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

### addUFO

Places UFO/objective structure on map.

```toml
[[commands]]
type = "addUFO"
UFOName = "small_scout"            # UFO type to place
canBeSkipped = false               # Can command fail without crash? (default: true)
```

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

### checkBlock

Tests if a block exists at position(s) without modifying the map.

```toml
[[commands]]
type = "checkBlock"
groups = [2, 3]                    # Groups to check for
size = [1, 1]                      # Block size to check
label = 5                          # Store result for conditionals
```

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

### removeBlock

Removes blocks matching criteria from the map.

```toml
[[commands]]
type = "removeBlock"
groups = [1, 2]                    # Groups to remove
size = [1, 1]                      # Block size to remove
```

### digTunnel

Creates underground tunnels or caves by modifying terrain.

```toml
[[commands]]
type = "digTunnel"
direction = "both"                 # "horizontal", "vertical", or "both"
tunnelData = { level = 0, MCDReplacements = [] }
```

### resize

Changes the map dimensions mid-generation.

```toml
[[commands]]
type = "resize"
size = [6, 6, 4]                   # [width, height, levels]
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

---

## Best Practices

### Script Design

1. **Always place craft first** - Ensures player spawn point exists
2. **Use fillArea last** - Fills remaining empty spaces
3. **Test maxUses carefully** - Prevents generation failures when map expands
4. **Label critical commands** - Enables conditional logic
5. **Use executionChances for variety** - Creates different layouts each time

### Example Scripts

**Simple Urban Mission:**
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

---

## Integration with Engine

### Loading Map Scripts

```lua
local MapScripts = require("engine.battlescape.data.mapscripts")

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
local MapScriptExecutor = require("engine.battlescape.logic.mapscript_executor")

local battlefield = MapScriptExecutor.execute({
    script = script,
    blockPool = blockPool,
    seed = 12345
})
```

---

## See Also

- [MapBlock Guide](MAPBLOCK_GUIDE.md) - Creating Map Block TOML files
- [Tileset System](../../TILESET_SYSTEM.md) - Organizing graphics and tilesets
- [Map Tile Key Reference](TILE_KEY_REFERENCE.md) - Complete tile reference
- [API Reference](../../API.md) - Engine API for map generation
