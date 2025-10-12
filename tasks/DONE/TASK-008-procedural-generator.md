# Task: Procedural Map Generator Maintenance

**Status:** DONE  
**Priority:** Medium  
**Created:** October 12, 2025  
**Completed:** October 12, 2025  
**Assigned To:** AI Agent

---

## Overview

Ensure the procedural map generation option remains functional alongside the new mapblock-based generation system. Provide both generation methods as options in battlescape.

---

## Purpose

Maintain flexibility in map generation. Procedural generation is useful for testing, variety, and situations where specific mapblocks aren't needed. Don't lose functionality during mapblock implementation.

---

## Requirements

### Functional Requirements
- [ ] Procedural generation creates valid random maps
- [ ] Mapblock-based generation uses predefined maps
- [ ] Option to choose generation method
- [ ] Both methods produce compatible map data
- [ ] Smooth integration with battlescape

### Technical Requirements
- [ ] Refactor map generation into separate functions
- [ ] Common map data format for both methods
- [ ] Configuration option for generation method
- [ ] Seed support for reproducible procedural maps
- [ ] Performance comparable between methods

### Acceptance Criteria
- [ ] Can generate maps procedurally
- [ ] Can generate maps from mapblocks
- [ ] Both methods work in battlescape
- [ ] Config option controls method
- [ ] No conflicts between methods
- [ ] All terrain types usable in both

---

## Plan

### Step 1: Audit Current Map Generation
**Description:** Review existing generation code  
**Files to analyze:**
- `engine/modules/battlescape.lua` (generateMap function)
- Map generation logic

**Estimated time:** 30 minutes

### Step 2: Refactor Map Generation System
**Description:** Separate procedural and mapblock generation  
**Files to modify:**
- `engine/modules/battlescape.lua`

**Create structure:**
```lua
local MapGenerator = {
    generateProcedural = function(width, height, seed)
        -- Random generation
    end,
    
    generateFromMapblock = function(mapblockId)
        -- Load from TOML
    end,
    
    generate = function(method, params)
        -- Dispatch to appropriate method
    end
}
```

**Estimated time:** 1.5 hours

### Step 3: Implement Mapblock Generation
**Description:** Load and apply mapblock data  
**Files to modify:**
- `engine/modules/battlescape.lua`
- Create `engine/systems/mapblock_loader.lua`

**Features:**
- Load mapblock TOML
- Apply tile data to battlefield
- Handle metadata
- Error handling for invalid mapblocks

**Estimated time:** 1 hour

### Step 4: Add Generation Method Selection
**Description:** UI and config for choosing method  
**Files to modify:**
- `engine/modules/battlescape.lua`
- `engine/modules/menu.lua` or config

**Options:**
- "Random" - Procedural generation
- "Mapblock" - Select from list
- "Auto" - Choose based on mission type

**Estimated time:** 45 minutes

### Step 5: Ensure Compatibility
**Description:** Verify both methods produce valid maps  
**Files to test:**
- Battlescape with procedural maps
- Battlescape with mapblock maps
- All game systems (LOS, pathfinding, etc.)

**Estimated time:** 30 minutes

### Step 6: Add Configuration Options
**Description:** Make generation configurable  
**Config options:**
- Default generation method
- Procedural map size
- Procedural terrain mix
- Mapblock selection criteria

**Files to modify:**
- Create `engine/data/generation_config.lua` or TOML

**Estimated time:** 30 minutes

### Step 7: Testing
**Description:** Comprehensive testing of both methods  
**Test cases:**
- Generate 10 procedural maps
- Load 10 mapblocks
- Verify playability
- Check performance
- Test edge cases

**Estimated time:** 45 minutes

---

## Implementation Details

### Architecture
Map generation dispatcher pattern:
```lua
function Battlescape.generateMap(options)
    local method = options.method or "auto"
    
    if method == "procedural" then
        return MapGenerator.generateProcedural(
            options.width,
            options.height,
            options.seed
        )
    elseif method == "mapblock" then
        return MapGenerator.generateFromMapblock(
            options.mapblockId
        )
    elseif method == "auto" then
        -- Choose based on mission type, biome, etc.
        return MapGenerator.chooseAndGenerate(options)
    end
end
```

### Common Map Data Format
Both methods produce same structure:
```lua
{
    metadata = {
        width = 20,
        height = 20,
        biome = "urban",
        method = "procedural" or "mapblock",
        seed = 12345,  -- for procedural
        mapblockId = "urban_block_01"  -- for mapblock
    },
    tiles = {
        -- [y][x] = terrainId
    },
    spawnPoints = {
        player = {{x, y}, ...},
        enemy = {{x, y}, ...}
    }
}
```

### Procedural Generation Algorithm
```lua
function MapGenerator.generateProcedural(width, height, seed)
    math.randomseed(seed or os.time())
    
    local map = {
        metadata = {width = width, height = height},
        tiles = {}
    }
    
    -- Initialize with floor
    for y = 1, height do
        map.tiles[y] = {}
        for x = 1, width do
            map.tiles[y][x] = "floor"
        end
    end
    
    -- Add random features
    addRandomWalls(map, 20)  -- 20% walls
    addRandomRough(map, 15)  -- 15% rough terrain
    addRandomRoads(map, 5)   -- 5% roads
    
    return map
end
```

### Mapblock Generation
```lua
function MapGenerator.generateFromMapblock(mapblockId)
    local path = ModManager.getContentPath("mapblocks", mapblockId .. ".toml")
    local mapblock = TOML.load(path)
    
    local map = {
        metadata = mapblock.metadata,
        tiles = {}
    }
    
    -- Convert mapblock format to battlefield format
    for y = 1, mapblock.metadata.height do
        map.tiles[y] = {}
        for x = 1, mapblock.metadata.width do
            local key = (y-1) .. "_" .. (x-1)
            map.tiles[y][x] = mapblock.tiles[key] or "floor"
        end
    end
    
    return map
end
```

### Key Components
- **MapGenerator:** Main generation dispatcher
- **MapblockLoader:** Loads mapblock TOML files
- **ProceduralGenerator:** Random map creation
- **MapValidator:** Ensures generated maps are valid

### Dependencies
- ModManager for mapblock paths
- TOML parser for mapblock loading
- DataLoader for terrain definitions
- Random number generator for procedural

---

## Testing Strategy

### Unit Tests
- Test procedural generation produces valid maps
- Test mapblock loading parses correctly
- Test both produce compatible formats
- Test seed reproducibility

### Integration Tests
- Test battlescape with procedural maps
- Test battlescape with mapblock maps
- Test switching between methods
- Test all terrain types work

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Enter battlescape with "procedural" method
3. Verify map generates randomly
4. Exit and re-enter with same seed
5. Verify map is identical
6. Enter battlescape with "mapblock" method
7. Select specific mapblock
8. Verify map matches mapblock definition
9. Play several turns on each type
10. Verify no errors in console

### Expected Results
- Both methods generate playable maps
- No console errors
- Performance is good
- Maps are visually distinct
- All game systems work with both

---

## How to Run/Debug

### Running with Procedural Generation
```lua
-- In battlescape initialization
local mapOptions = {
    method = "procedural",
    width = 20,
    height = 20,
    seed = 12345
}
self:generateMap(mapOptions)
```

### Running with Mapblock
```lua
local mapOptions = {
    method = "mapblock",
    mapblockId = "urban_block_01"
}
self:generateMap(mapOptions)
```

### Debugging
- Print generation method: `print("Using method: " .. method)`
- Verify map data structure
- Check tile assignments
- Validate spawn points
- Monitor performance

### Console Output
```
[Battlescape] Generating map with method: procedural
[MapGenerator] Seed: 12345
[MapGenerator] Size: 20x20
[MapGenerator] Generated 400 tiles
[MapGenerator] Added 80 walls, 60 rough, 20 roads
```

---

## Documentation Updates

### Files to Update
- [ ] `tasks/tasks.md` - Add task entry
- [ ] `wiki/API.md` - Document MapGenerator API
- [ ] `wiki/DEVELOPMENT.md` - Explain both methods
- [ ] `engine/docs/GAME_DESIGN_DOCUMENT.md` - Note generation options

---

## Notes

- Consider hybrid approach: mapblock with procedural variations
- Could add procedural mapblock selector (choose random mapblock)
- May want to add terrain density controls for procedural
- Think about biome-specific procedural rules

---

## Blockers

None. Both systems partially implemented, just need integration.

---

## Review Checklist

- [ ] Procedural generation works
- [ ] Mapblock generation works
- [ ] Both produce compatible data
- [ ] Config option implemented
- [ ] No conflicts between methods
- [ ] Performance acceptable
- [ ] Code is modular
- [ ] Documentation updated
- [ ] Tests written and passing
- [ ] Console logging clear

---

## Post-Completion

### What Worked Well
TBD

### What Could Be Improved
TBD

### Lessons Learned
TBD
