# Task: Battlescape Improvements - Bugs, Fire/Smoke System, and Hex Map Blocks

**Status:** TODO  
**Priority:** High  
**Created:** 2025-10-12  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

This task implements critical bug fixes and major new features for the battlescape system:
1. **Bug Fixes**: Middle mouse button map panning, fullscreen debug grid, PNG export, LOS terrain cost
2. **Fire & Smoke System**: Realistic fire spreading with terrain flammability, smoke dissipation, visibility/movement effects
3. **Hex Map Block System**: New procedural map generation using 15x15 tile blocks arranged in rotated hex grid (45° angle)

---

## Purpose

**Bug Fixes**: Improve user experience and fix regressions in core systems
**Fire/Smoke**: Add tactical depth with environmental hazards and dynamic battlefield conditions
**Hex Map Blocks**: Enable modular, procedurally generated battlefields with reusable map components

---

## Requirements

### Functional Requirements - Bugs
- [x] Middle mouse button (button 2) pans/drags the battlefield map
- [x] Debug grid overlay (F9) covers entire screen in all resolutions including fullscreen
- [x] Map PNG export (F5) works without errors and saves to TEMP directory
- [x] LOS system properly checks terrain sightCost property for visibility calculations

### Functional Requirements - Fire/Smoke
- [x] Fire has binary state (on/off) with no intensity levels
- [x] Fire can start randomly or triggered by gameplay events
- [x] Fire spreads to adjacent flammable tiles based on flammability property
- [x] Fire damages units standing in it (per turn)
- [x] Fire blocks movement completely (moveCost = 0)
- [x] Fire reduces visibility by +3 sight cost for that tile
- [x] Fire produces smoke in adjacent empty tiles
- [x] Smoke has 3 levels (1=light, 2=medium, 3=heavy)
- [x] Smoke spreads to adjacent empty tiles and dissipates over time
- [x] Smoke reduces visibility: +2 sight cost per level (level 3 = +6)
- [x] Smoke does not block movement
- [x] Smoke only exists on empty tiles (not walls), but can be on units
- [x] Smoke dissipates naturally when it spreads thin

### Functional Requirements - Hex Map Blocks
- [x] MapBlock class holds 15x15 hex tile data
- [x] MapBlock supports multi-size variants (e.g., 45x15 for larger structures)
- [x] MapBlock loaded from TOML configuration files
- [x] MapBlock contains mixed terrain (roads, buildings, forests, water, etc.)
- [x] GridMap class randomly selects 4x4 to 7x7 array of MapBlocks
- [x] GridMap assembles MapBlocks into complete battlescape using rotated hex coordinates
- [x] Hex grid uses 45° rotation as shown in reference image (red blocks)
- [x] Coordinate system properly handles offset hex grid with axial-to-offset conversion

### Technical Requirements
- [x] All systems use proper error handling with pcall
- [x] Fire/smoke state stored in tile.effects table
- [x] Fire/smoke updates processed in turn system
- [x] Terrain types extended with flammability property (0.0 to 1.0)
- [x] TOML parser integrated for MapBlock definitions
- [x] New coordinate system utilities for rotated hex grid
- [x] Performance optimized for 90x90 battlefield with effects

### Acceptance Criteria
- [x] Middle mouse drag smoothly pans map in all directions
- [x] Debug grid visible across entire screen at any resolution
- [x] F5 exports PNG to TEMP directory without errors
- [x] LOS properly blocked/reduced by terrain sightCost values
- [x] Fire spreads realistically and damages units
- [x] Smoke dissipates gradually creating tactical fog
- [x] Units cannot enter fire tiles
- [x] Visibility calculations include fire (+3) and smoke (+2/level) penalties
- [x] MapBlocks load from TOML and assemble into valid battlefields
- [x] Hex grid displays correctly with 45° rotation

---

## Plan

### Phase 1: Bug Fixes (HIGH PRIORITY)
**Estimated time:** 2 hours

#### Step 1.1: Middle Mouse Button Panning
**Files to modify:**
- `engine/modules/battlescape.lua` (add mousepressed/mousemoved handlers)
- `engine/systems/battle/camera.lua` (if camera drag methods needed)

**Implementation:**
- Add `self.isDragging` and `self.dragStartX/Y` state variables
- In `mousepressed`: detect button 2 (middle), store drag start position
- In `mousemoved`: if dragging, update camera.x/y based on delta
- In `mousereleased`: clear dragging state

#### Step 1.2: Fullscreen Debug Grid
**Files to modify:**
- `engine/widgets/grid.lua`

**Implementation:**
- Change `Grid.drawDebug()` to use `love.graphics.getWidth()` and `love.graphics.getHeight()` instead of fixed 960x720
- Calculate dynamic COLS and ROWS based on actual window size
- Update grid line drawing to cover entire screen

#### Step 1.3: PNG Export Fix
**Files to modify:**
- `engine/systems/battle/map_saver.lua`

**Implementation:**
- Verify TEMP directory access with proper error handling
- Add more detailed error logging
- Test with current battlefield structure
- Ensure pcall properly catches errors

#### Step 1.4: LOS Terrain Cost Fix
**Files to modify:**
- `engine/systems/los_optimized.lua`
- `engine/systems/los_system.lua` (if used)

**Implementation:**
- Review shadow casting algorithm to ensure sightCost is accumulated
- Add sightCost checking in visibility calculations
- Verify terrain types have correct sightCost values
- Test with various terrain combinations

**Testing:**
```lua
-- Test terrain sight costs
local terrains = {"wall", "bushes", "trees", "window"}
for _, t in ipairs(terrains) do
    local terrain = TerrainTypes.terrain[t]
    print(t .. " sightCost: " .. terrain.sightCost)
end

-- Test LOS through different terrains
local los = LOSOptimized.new()
local visible = los:calculateVisibilityForUnit(unit, battlefield, true)
-- Should respect sightCost accumulation
```

---

### Phase 2: Fire and Smoke System (MEDIUM PRIORITY)
**Estimated time:** 6 hours

#### Step 2.1: Core Fire/Smoke Data Structures
**Files to create:**
- `engine/systems/battle/fire_system.lua`
- `engine/systems/battle/smoke_system.lua`

**Files to modify:**
- `engine/data/terrain_types.lua` (add flammability property)
- `engine/systems/battle/battlefield.lua` (tile.effects table)

**Implementation:**
```lua
-- Terrain flammability (0.0 = non-flammable, 1.0 = highly flammable)
terrain.flammability = 0.5  -- 50% chance to catch fire from adjacent fire

-- Tile effects structure
tile.effects = {
    fire = false,  -- boolean: is tile on fire?
    smoke = 0,     -- 0-3: smoke level
    fireDuration = 0,  -- turns fire has been burning
    smokeAge = 0      -- turns since smoke appeared
}
```

#### Step 2.2: Fire System Implementation
**Files:** `engine/systems/battle/fire_system.lua`

**Components:**
```lua
local FireSystem = {}

function FireSystem.new()
    return setmetatable({
        activeFires = {},  -- list of {x, y} with fire
        fireSpreadChance = 0.3,  -- 30% per turn
        fireDamagePerTurn = 5
    }, {__index = FireSystem})
end

function FireSystem:update(battlefield, units)
    -- 1. Spread fire to adjacent flammable tiles
    -- 2. Damage units standing in fire
    -- 3. Produce smoke in adjacent empty tiles
    -- 4. Update fire duration
end

function FireSystem:startFire(battlefield, x, y)
    -- Ignite tile if flammable
end

function FireSystem:spreadFire(battlefield, x, y)
    -- Check 6 hex neighbors
    -- Roll against flammability for each
end

function FireSystem:damageUnitsInFire(units)
    -- Find units in fire tiles
    -- Apply damage per turn
end

function FireSystem:produceSmoke(battlefield, x, y)
    -- Create level 1 smoke in adjacent empty tiles
end
```

#### Step 2.3: Smoke System Implementation
**Files:** `engine/systems/battle/smoke_system.lua`

**Components:**
```lua
local SmokeSystem = {}

function SmokeSystem.new()
    return setmetatable({
        smokeSpreadRate = 0.7,  -- 70% chance to spread
        smokeDissipationRate = 0.2  -- 20% chance to dissipate per turn
    }, {__index = SmokeSystem})
end

function SmokeSystem:update(battlefield)
    -- 1. Spread smoke to adjacent tiles (reduces level)
    -- 2. Dissipate smoke naturally
    -- 3. Remove smoke from walls/obstacles
end

function SmokeSystem:spreadSmoke(battlefield, x, y, level)
    -- Smoke spreads to neighbors at level-1
    -- If level 1, spreads as level 1 (doesn't dissipate immediately)
end

function SmokeSystem:dissipateSmoke(battlefield)
    -- Random chance to reduce smoke level
    -- Remove smoke at level 0
end
```

#### Step 2.4: LOS Integration
**Files to modify:**
- `engine/systems/los_optimized.lua`

**Implementation:**
```lua
-- In visibility calculation
local tile = battlefield:getTile(x, y)
local sightCost = tile.terrain.sightCost

-- Add fire cost
if tile.effects and tile.effects.fire then
    sightCost = sightCost + 3
end

-- Add smoke cost
if tile.effects and tile.effects.smoke then
    sightCost = sightCost + (tile.effects.smoke * 2)  -- +2 per level
end

-- Accumulate sight cost along line
totalSightCost = totalSightCost + sightCost
if totalSightCost > maxSightRange then
    break  -- Vision blocked
end
```

#### Step 2.5: Movement Integration
**Files to modify:**
- `engine/systems/pathfinding.lua`
- `engine/systems/battle/systems/movement_system.lua`

**Implementation:**
```lua
-- In pathfinding cost calculation
local moveCost = tile.terrain.moveCost

-- Fire blocks movement
if tile.effects and tile.effects.fire then
    moveCost = 0  -- Impassable
end

-- Smoke does NOT affect movement
```

#### Step 2.6: Turn System Integration
**Files to modify:**
- `engine/systems/battle/turn_manager.lua`
- `engine/modules/battlescape.lua`

**Implementation:**
```lua
-- In turn end
function TurnManager:endTurn(units, battlefield)
    -- ... existing code ...
    
    -- Update fire and smoke
    if self.fireSystem then
        self.fireSystem:update(battlefield, units)
    end
    if self.smokeSystem then
        self.smokeSystem:update(battlefield)
    end
    
    -- Invalidate LOS cache (terrain changed)
    if self.losSystem and self.losSystem.cache then
        self.losSystem.cache:invalidateArea(1, 1, battlefield.width, battlefield.height)
    end
end
```

**Testing:**
```lua
-- Test fire spreading
local fire = FireSystem.new()
fire:startFire(battlefield, 45, 45)
-- Verify fire spreads based on flammability

-- Test smoke production
-- Verify smoke appears in adjacent tiles

-- Test smoke dissipation
-- Run multiple turns, verify smoke spreads and dissipates

-- Test visibility penalties
-- Unit should have reduced vision through smoke/fire

-- Test movement blocking
-- Unit should not be able to move into fire tile
```

---

### Phase 3: Hex Map Block System (COMPLEX)
**Estimated time:** 10 hours

#### Step 3.1: TOML Integration
**Files to create:**
- `engine/libs/toml.lua` (TOML parser library)

**Implementation:**
- Add TOML library (use existing Lua TOML parser like `toml.lua`)
- Test TOML parsing with sample files

#### Step 3.2: MapBlock Data Structure
**Files to create:**
- `engine/systems/battle/map_block.lua`

**Implementation:**
```lua
local MapBlock = {}

function MapBlock.new(id, width, height)
    return setmetatable({
        id = id,
        width = width,  -- typically 15
        height = height,  -- typically 15
        tiles = {},  -- [y][x] = terrain_id
        metadata = {
            name = "",
            description = "",
            biome = "",
            difficulty = 1
        }
    }, {__index = MapBlock})
end

function MapBlock:getTile(x, y)
    return self.tiles[y] and self.tiles[y][x]
end

function MapBlock:setTile(x, y, terrainId)
    if not self.tiles[y] then
        self.tiles[y] = {}
    end
    self.tiles[y][x] = terrainId
end

function MapBlock.loadFromTOML(filepath)
    -- Parse TOML file
    -- Create MapBlock instance
    -- Populate tiles from data
end

function MapBlock:saveToTOML(filepath)
    -- Export MapBlock to TOML format
end
```

**TOML Format Example:**
```toml
[metadata]
id = "urban_block_01"
name = "Urban Intersection"
description = "City block with roads and buildings"
biome = "urban"
difficulty = 2
width = 15
height = 15

[tiles]
# Format: "row_col" = "terrain_id"
"0_0" = "road"
"0_1" = "road"
"1_0" = "floor"
"1_1" = "wall"
# ... etc for all 225 tiles
```

#### Step 3.3: Rotated Hex Coordinate System
**Files to create:**
- `engine/systems/battle/utils/hex_rotated.lua`

**Implementation:**
```lua
-- Rotated hex grid (45° angle) coordinate utilities
local HexRotated = {}

-- Convert map block grid position to world hex coordinates
-- Uses "pointy-top" hex orientation rotated 45°
function HexRotated.blockToWorld(blockX, blockY, blockWidth, blockHeight)
    -- Each block is offset by its size in hex space
    -- Blocks arranged in hex grid pattern
    local worldX = blockX * blockWidth
    local worldY = blockY * blockHeight
    
    -- Offset for hex grid arrangement (every other row)
    if blockY % 2 == 1 then
        worldX = worldX + (blockWidth / 2)
    end
    
    return worldX, worldY
end

-- Get neighbors for a block position in grid
function HexRotated.getBlockNeighbors(blockX, blockY)
    -- Returns 6 neighbors in hex grid
    local neighbors = {}
    -- ... hex neighbor offsets
    return neighbors
end

-- Convert world tile to screen position with 45° rotation
function HexRotated.worldToScreen(worldX, worldY, tileSize, camera)
    -- Apply rotation transformation
    -- Apply camera offset
    return screenX, screenY
end
```

Reference: The attached image shows red hexes representing map blocks arranged in rotated hex grid, with blue hexes showing internal block structure.

#### Step 3.4: GridMap Builder
**Files to create:**
- `engine/systems/battle/grid_map.lua`

**Implementation:**
```lua
local GridMap = {}

function GridMap.new(gridWidth, gridHeight)
    return setmetatable({
        gridWidth = gridWidth,  -- 4-7 map blocks
        gridHeight = gridHeight,  -- 4-7 map blocks
        blocks = {},  -- [blockY][blockX] = MapBlock
        worldWidth = 0,
        worldHeight = 0
    }, {__index = GridMap})
end

function GridMap:generateRandom(blockPool)
    -- Randomly select blocks from pool
    -- Place in grid positions
    -- Track world dimensions
    
    for by = 1, self.gridHeight do
        self.blocks[by] = {}
        for bx = 1, self.gridWidth do
            local randomBlock = blockPool[math.random(1, #blockPool)]
            self.blocks[by][bx] = randomBlock
        end
    end
    
    -- Calculate world size
    self.worldWidth = self.gridWidth * 15  -- assuming 15x15 blocks
    self.worldHeight = self.gridHeight * 15
end

function GridMap:getTileAt(worldX, worldY)
    -- Convert world coords to block coords
    local blockX = math.floor((worldX - 1) / 15) + 1
    local blockY = math.floor((worldY - 1) / 15) + 1
    
    local block = self.blocks[blockY] and self.blocks[blockY][blockX]
    if not block then return nil end
    
    -- Get tile within block
    local localX = ((worldX - 1) % 15) + 1
    local localY = ((worldY - 1) % 15) + 1
    
    return block:getTile(localX, localY)
end

function GridMap:toBattlefield()
    -- Convert GridMap to Battlefield instance
    -- Assemble all blocks into single tile array
end
```

#### Step 3.5: MapBlock Library
**Files to create:**
- `mods/core/mapblocks/` (directory)
- `mods/core/mapblocks/urban_01.toml`
- `mods/core/mapblocks/forest_01.toml`
- `mods/core/mapblocks/open_01.toml`

**Content:** Create 10-15 diverse MapBlock templates:
- Urban: roads, buildings, parking lots
- Forest: trees, clearings, paths
- Industrial: warehouses, containers
- Rural: fields, barns, fences
- Mixed: various combinations

#### Step 3.6: Battlescape Integration
**Files to modify:**
- `engine/modules/battlescape.lua`

**Implementation:**
```lua
function Battlescape:generateMap()
    -- Load MapBlock templates
    local blockPool = MapBlock.loadAll("mods/core/mapblocks/")
    
    -- Create GridMap
    local gridSize = math.random(4, 7)
    local gridMap = GridMap.new(gridSize, gridSize)
    gridMap:generateRandom(blockPool)
    
    -- Convert to Battlefield
    self.battlefield = gridMap:toBattlefield()
    
    print(string.format("[Battlescape] Generated %dx%d map from %dx%d blocks",
        self.battlefield.width, self.battlefield.height, gridSize, gridSize))
end
```

**Testing:**
```lua
-- Test MapBlock loading
local block = MapBlock.loadFromTOML("mods/core/mapblocks/urban_01.toml")
assert(block.width == 15)
assert(block.height == 15)
assert(block:getTile(1, 1) ~= nil)

-- Test GridMap assembly
local gridMap = GridMap.new(4, 4)
gridMap:generateRandom(blockPool)
assert(gridMap.worldWidth == 60)  -- 4 * 15
assert(gridMap:getTileAt(1, 1) ~= nil)
assert(gridMap:getTileAt(60, 60) ~= nil)

-- Test coordinate conversion
local worldX, worldY = HexRotated.blockToWorld(1, 1, 15, 15)
assert(worldX == 15 and worldY == 15)

-- Test battlefield generation
local bf = gridMap:toBattlefield()
assert(bf.width == 60)
assert(bf:getTile(1, 1) ~= nil)
```

---

## Implementation Details

### Architecture

**Bug Fixes:**
- Middle mouse drag: Simple state machine (idle → dragging → idle)
- Debug grid: Dynamic sizing based on actual window dimensions
- PNG export: Enhanced error handling and logging
- LOS terrain cost: Accumulation algorithm in shadow casting

**Fire/Smoke System:**
- Component-based: separate FireSystem and SmokeSystem managers
- Turn-based updates: integrated into TurnManager
- Data-driven: flammability as terrain property
- Effect storage: tile.effects table for persistence

**Hex Map Blocks:**
- Data-driven: TOML configuration for all blocks
- Procedural generation: random GridMap assembly
- Modular design: MapBlock → GridMap → Battlefield pipeline
- Coordinate systems: world coords, block coords, local coords, screen coords

### Key Components

**FireSystem:**
- Manages active fire tiles
- Spreads fire based on flammability
- Damages units in fire
- Produces smoke

**SmokeSystem:**
- Manages smoke levels (0-3)
- Spreads and dissipates smoke
- Removes smoke from obstacles

**MapBlock:**
- Container for 15x15 tile template
- TOML serialization
- Tile accessors

**GridMap:**
- Arranges MapBlocks in rotated hex grid
- Random selection from block pool
- Coordinate conversion
- Battlefield assembly

### Dependencies

- `love.image` for PNG export
- TOML parser library (toml.lua)
- Existing: HexMath, Battlefield, TerrainTypes, LOS, Pathfinding, TurnManager

---

## Testing Strategy

### Unit Tests

Create `engine/tests/test_fire_smoke.lua`:
```lua
local FireSystem = require("systems.battle.fire_system")
local SmokeSystem = require("systems.battle.smoke_system")

function test_fire_spread()
    local fire = FireSystem.new()
    -- Test fire spreads to flammable neighbors
    -- Test fire does not spread to non-flammable
end

function test_smoke_dissipation()
    local smoke = SmokeSystem.new()
    -- Test smoke level reduces over time
    -- Test smoke spreads to neighbors
end

function test_visibility_penalties()
    -- Test LOS reduced by fire (+3)
    -- Test LOS reduced by smoke (+2 per level)
end
```

Create `engine/tests/test_map_blocks.lua`:
```lua
local MapBlock = require("systems.battle.map_block")
local GridMap = require("systems.battle.grid_map")

function test_mapblock_load()
    local block = MapBlock.loadFromTOML("test_block.toml")
    assert(block ~= nil)
    assert(block.width == 15)
end

function test_gridmap_assembly()
    local grid = GridMap.new(4, 4)
    -- Test block placement
    -- Test coordinate conversion
    -- Test battlefield export
end
```

### Integration Tests

Run full battlescape with fire/smoke active:
```lua
-- In battlescape:enter()
self.fireSystem = FireSystem.new()
self.smokeSystem = SmokeSystem.new()

-- Start test fire
self.fireSystem:startFire(self.battlefield, 45, 45)

-- Play several turns, verify:
-- - Fire spreads
-- - Smoke appears
-- - Units take damage in fire
-- - Visibility reduced
```

### Manual Testing Steps

**Bug Fixes:**
1. Launch game with `lovec "engine"`
2. Enter battlescape
3. Press F9 - verify grid covers entire screen
4. Press F12 to toggle fullscreen - verify grid still covers screen
5. Click and hold middle mouse button - drag map around
6. Press F5 - check console for PNG save confirmation, verify file in TEMP
7. Select unit, observe LOS - verify terrain blocks sight appropriately

**Fire/Smoke:**
1. Launch game
2. Enter battlescape
3. Press F6 to start test fire (add debug key)
4. End turn several times
5. Observe fire spreading to flammable tiles
6. Observe smoke appearing around fire
7. Move unit into fire - verify damage and blocked movement
8. Check visibility through smoke - should be reduced

**Hex Map Blocks:**
1. Launch game
2. Enter battlescape - should load from GridMap
3. Verify map looks correct with block boundaries visible
4. Check different runs produce different maps
5. Verify no gaps or overlaps between blocks

### Expected Results

- Smooth middle mouse panning
- Debug grid visible at all resolutions
- PNG export successful, file in TEMP folder
- LOS properly accounts for terrain sight costs
- Fire spreads realistically, damages units
- Smoke dissipates gradually
- Visibility penalties applied correctly
- Movement blocked by fire, allowed through smoke
- Maps generated from random block selection
- Blocks properly aligned in rotated hex grid

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or execute `run_xcom.bat` or use VS Code task: "Run XCOM Simple Game"

### Debugging

**Console Output:**
- All systems print initialization messages
- Fire/smoke updates logged each turn
- MapBlock loading logged with details
- Error messages show in console with stack traces

**Debug Keys:**
- F3: Toggle visible tile indicators
- F4: Toggle day/night
- F5: Export map to PNG
- F8: Toggle FOW display
- F9: Toggle debug grid overlay (FIXED to cover fullscreen)
- F10: Toggle debug mode
- F6: (NEW) Start test fire at camera center

**Print Debugging:**
```lua
print(string.format("[FireSystem] Fire at (%d, %d), spread to %d tiles", x, y, spreadCount))
print(string.format("[SmokeSystem] Smoke level %d at (%d, %d)", level, x, y))
print(string.format("[MapBlock] Loaded %s: %dx%d tiles", id, width, height))
print(string.format("[GridMap] Generated %dx%d blocks", gridWidth, gridHeight))
```

**On-Screen Debug:**
```lua
-- In battlescape:draw()
if Debug.enabled then
    love.graphics.print("Fire tiles: " .. #self.fireSystem.activeFires, 10, 30)
    love.graphics.print("Smoke tiles: " .. self.smokeSystem:count(), 10, 50)
end
```

### Temporary Files

**PNG Export:**
```lua
local tempDir = os.getenv("TEMP")
local filepath = tempDir .. "\\battlefield_" .. timestamp .. ".png"
```

**MapBlock Cache:**
If caching MapBlocks in memory, no temp files needed. If serializing intermediate data, use:
```lua
local tempPath = os.getenv("TEMP") .. "\\mapblock_cache.dat"
```

---

## Documentation Updates

### Files to Update

- [x] `wiki/API.md`
  - Add FireSystem API
  - Add SmokeSystem API
  - Add MapBlock API
  - Add GridMap API
  - Add HexRotated coordinate utilities

- [x] `wiki/FAQ.md`
  - How do fire and smoke work?
  - How do I create custom map blocks?
  - What is the rotated hex grid system?

- [x] `wiki/DEVELOPMENT.md`
  - MapBlock creation workflow
  - TOML format specification
  - GridMap generation process

- [x] `engine/systems/battle/fire_system.lua` - Inline documentation
- [x] `engine/systems/battle/smoke_system.lua` - Inline documentation
- [x] `engine/systems/battle/map_block.lua` - Inline documentation
- [x] `engine/systems/battle/grid_map.lua` - Inline documentation

### New Documentation Files

Create `wiki/MAPBLOCK_GUIDE.md`:
```markdown
# MapBlock Creation Guide

## Overview
MapBlocks are 15x15 tile templates used to procedurally generate battlefields.

## TOML Format
[Example format and structure]

## Creating Custom Blocks
[Step-by-step guide]

## Block Library Organization
[How to organize mapblock files]
```

Create `wiki/FIRE_SMOKE_MECHANICS.md`:
```markdown
# Fire and Smoke Mechanics

## Fire System
- Spreading rules
- Flammability values
- Damage calculations

## Smoke System
- Dissipation mechanics
- Visibility penalties
- Tactical considerations
```

---

## Notes

### Design Considerations

**Fire/Smoke Balance:**
- Fire spread chance should feel dynamic but not overwhelming (30% per turn)
- Smoke should create tactical opportunities (block LOS) without being permanent
- Fire damage should encourage unit relocation (5 HP per turn)

**Map Block Variety:**
- Need 10-15 diverse blocks for interesting maps
- Blocks should be self-contained but edge-compatible
- Consider thematic sets (urban, rural, industrial)

**Performance:**
- Fire/smoke updates O(n) where n = affected tiles (< 100 typically)
- GridMap assembly O(blocks * 225) = O(16 * 225) = ~3600 operations (fast)
- TOML parsing done once at load time

### Future Enhancements

**Fire/Smoke:**
- Fire can destroy destructible terrain
- Water tiles extinguish adjacent fire
- Wind affects smoke movement direction
- Explosions create instant fire/smoke

**Map Blocks:**
- Multi-level blocks (buildings with floors)
- Destructible block elements
- Dynamic block modification during battle
- Special blocks (objectives, spawn points)

---

## Blockers

None identified. All dependencies exist in current codebase.

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder (`os.getenv("TEMP")`)
- [ ] Console debugging statements added with [Module] prefixes
- [ ] Tests written and passing (unit + integration)
- [ ] Documentation updated (API.md, FAQ.md, DEVELOPMENT.md)
- [ ] Code reviewed for logic errors
- [ ] No warnings in Love2D console
- [ ] Grid snapping preserved (if applicable)
- [ ] Camera/viewport properly handles new systems
- [ ] LOS cache invalidation on terrain changes
- [ ] Turn system properly updates fire/smoke
- [ ] MapBlock TOML validation
- [ ] Coordinate conversion tested thoroughly

---

## Post-Completion

### What Worked Well
- [To be filled after completion]

### What Could Be Improved
- [To be filled after completion]

### Lessons Learned
- [To be filled after completion]

---

## Progress Log

### 2025-10-12
- Task created with comprehensive analysis
- Identified all bug fixes needed
- Designed fire/smoke system architecture
- Planned hex map block system with rotated coordinates
- Created test strategies and acceptance criteria

