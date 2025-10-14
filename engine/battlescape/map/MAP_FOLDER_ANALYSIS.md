# Map Folder Architecture Analysis

**Date:** October 13, 2025  
**Status:** Review for Integration with Phase 3-4 Systems

---

## Current State

The `engine/battlescape/map/` folder contains **10 files** with various states of completion:

### ✅ Complete and Production-Ready
1. **`mapblock_loader_v2.lua`** (~397 lines)
   - TOML-based Map Block loader
   - KEY validation, group/tag indexing
   - **Status:** Complete, tested, ready to use
   - **Dependencies:** Tilesets, MultiTile

### ⚠️ Partially Complete / Needs Update
2. **`map_generation_pipeline.lua`** (~432 lines)
   - Next-generation pipeline (Biome → Terrain → MapScript → Blocks)
   - **Issue:** Uses basic block placement, not MapScriptExecutor
   - **Fix Needed:** Replace `placeMapBlocks()` with `MapScriptExecutor.execute()`
   - **Status:** 70% complete, needs MapScript integration

3. **`mapblock_system.lua`** (~45 lines)
   - Hex grid MapBlock system
   - **Issue:** Has TODO stubs, not implemented
   - **Fix Needed:** Implement with MapBlockLoader v2
   - **Status:** Skeleton only

4. **`map_generator.lua`** (~351 lines)
   - Unified map generator (procedural + MapBlock)
   - **Issue:** Uses old procedural generation, no MapScript support
   - **Fix Needed:** Add MapScript generation method
   - **Status:** Procedural complete, MapBlock outdated

### 📦 Legacy / Deprecated
5. **`mapblock_loader.lua`** (old version)
   - **Status:** Superseded by `mapblock_loader_v2.lua`
   - **Action:** Can be removed or archived

### ✅ Utility / Standalone
6. **`grid_map.lua`**
   - Hex grid data structure
   - **Status:** Complete, used by MapBlock system

7. **`map_block.lua`**
   - MapBlock class definition
   - **Status:** Complete

8. **`pathfinding.lua`**
   - A* pathfinding
   - **Status:** Complete, standalone

9. **`trajectory.lua`**
   - Line-of-sight and projectile trajectory
   - **Status:** Complete, standalone

10. **`map_saver.lua`**
    - Save/load maps
    - **Status:** Complete

---

## Architecture Issues

### Issue 1: Two MapBlock Loaders
**Problem:** Both `mapblock_loader.lua` (old) and `mapblock_loader_v2.lua` (new) exist.

**Impact:** Confusion about which to use, possible conflicts.

**Solution:**
- ✅ Use `mapblock_loader_v2.lua` (TOML-based)
- ❌ Archive or remove `mapblock_loader.lua`
- Update all references to use v2

### Issue 2: MapScript Integration Missing
**Problem:** `map_generation_pipeline.lua` uses basic block placement, ignoring MapScriptExecutor.

**Current Code (line 169-189):**
```lua
function MapGenerationPipeline:placeMapBlocks(mapScriptId, options)
    local mapScript = self.mapScripts.get(mapScriptId)
    if not mapScript then
        return nil
    end
    
    local placedBlocks = {}
    
    -- Process each block position in MapScript
    for _, blockDef in ipairs(mapScript.blocks) do
        local blockId = self:selectMapBlockForPosition(blockDef, options)
        
        if blockDef.required and not blockId then
            return nil
        end
        
        if blockId then
            table.insert(placedBlocks, {
                x = blockDef.x,
                y = blockDef.y,
                blockId = blockId,
                rotation = math.random(0, 3)
            })
        end
    end
    
    return placedBlocks
end
```

**Problem:** This treats MapScript as static block list, not dynamic commands.

**Fix Required:**
```lua
function MapGenerationPipeline:placeMapBlocks(mapScriptId, options)
    local MapScriptExecutor = require("battlescape.logic.mapscript_executor")
    local MapScriptsV2 = require("battlescape.data.mapscripts_v2")
    
    -- Get MapScript
    local script = MapScriptsV2.get(mapScriptId)
    if not script then
        print("[MapGenerationPipeline] MapScript not found: " .. mapScriptId)
        return nil
    end
    
    -- Execute MapScript with seed
    local seed = options.seed or os.time()
    local context = MapScriptExecutor.execute(script, seed)
    
    if not context then
        print("[MapGenerationPipeline] MapScript execution failed")
        return nil
    end
    
    -- Convert context.grid to block list
    return self:contextToBlocks(context)
end
```

### Issue 3: MapBlockSystem Stub Implementation
**Problem:** `mapblock_system.lua` has TODO stubs:

```lua
function MapBlockSystem.loadLibrary(directory)
    -- TODO: Implement TOML loading
    return {}
end

function MapBlockSystem.generateBattlefield(gridWidth, gridHeight, blockLibrary)
    -- TODO: Implement GridMap generation
    return nil
end
```

**Fix Required:**
```lua
function MapBlockSystem.loadLibrary(directory)
    local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")
    return MapBlockLoader.loadAll(directory)
end

function MapBlockSystem.generateBattlefield(gridWidth, gridHeight, blockLibrary)
    local MapScriptExecutor = require("battlescape.logic.mapscript_executor")
    local MapScriptsV2 = require("battlescape.data.mapscripts_v2")
    
    -- Select appropriate MapScript for size
    local script = MapScriptsV2.getBySize(gridWidth, gridHeight)
    if not script then
        print("[MapBlockSystem] No suitable MapScript found")
        return nil
    end
    
    -- Execute MapScript
    local context = MapScriptExecutor.execute(script, os.time())
    
    -- Convert to Battlefield
    return self:contextToBattlefield(context)
end
```

### Issue 4: map_generator.lua Outdated
**Problem:** Only supports procedural generation and old MapBlock method.

**Current Methods:**
- ✅ `generateProcedural()` - Works but basic
- ❌ `generateFromMapBlocks()` - Uses old system
- ❌ No MapScript support

**Fix Required:** Add new generation method:
```lua
function MapGenerator.generateFromMapScript(mapScriptId, seed)
    local MapScriptExecutor = require("battlescape.logic.mapscript_executor")
    local MapScriptsV2 = require("battlescape.data.mapscripts_v2")
    
    local script = MapScriptsV2.get(mapScriptId)
    if not script then
        print("[MapGenerator] MapScript not found: " .. mapScriptId)
        return nil
    end
    
    local context = MapScriptExecutor.execute(script, seed)
    if not context then
        print("[MapGenerator] MapScript execution failed")
        return nil
    end
    
    -- Convert context to Battlefield
    return self:contextToBattlefield(context)
end
```

---

## Dependency Graph

```
map_generation_pipeline.lua
├── biomes (battlescape.data.biomes)
├── terrains (battlescape.data.terrains)
├── mapScripts (battlescape.data.mapscripts) ❌ OLD
├── terrainSelector (battlescape.logic.terrain_selector)
├── mapScriptSelector (battlescape.logic.mapscript_selector)
└── mapBlockLoader (battlescape.map.mapblock_loader) ❌ OLD

SHOULD BE:
├── mapScripts (battlescape.data.mapscripts_v2) ✅ NEW
├── mapScriptExecutor (battlescape.logic.mapscript_executor) ✅ NEW
└── mapBlockLoader (battlescape.map.mapblock_loader_v2) ✅ NEW
```

---

## Recommended Actions

### Priority 1: Integration (High)
1. **Update `map_generation_pipeline.lua`**
   - Replace `mapScripts` with `mapScripts_v2`
   - Replace `placeMapBlocks()` with `MapScriptExecutor.execute()`
   - Add `contextToBlocks()` helper method
   - Test with existing biomes/terrains

2. **Implement `mapblock_system.lua`**
   - Replace TODO stubs with MapBlockLoader v2 calls
   - Add `contextToBattlefield()` conversion method
   - Test with hex grid integration

3. **Update `map_generator.lua`**
   - Add `generateFromMapScript()` method
   - Deprecate old `generateFromMapBlocks()` method
   - Update config to include "mapscript" option

### Priority 2: Cleanup (Medium)
4. **Remove or Archive Old Files**
   - Archive `mapblock_loader.lua` to `map/legacy/`
   - Update all references to use v2
   - Add deprecation warnings

5. **Documentation**
   - Add docstrings to all public methods
   - Create MAP_GENERATION_GUIDE.md
   - Update API.md with new methods

### Priority 3: Testing (High)
6. **Integration Tests**
   - Test full pipeline: Biome → Terrain → MapScript → Executor → Map
   - Test with all 5 example MapScripts
   - Verify Love2D console output
   - Check memory usage and performance

7. **Unit Tests**
   - Test `contextToBlocks()` conversion
   - Test `contextToBattlefield()` conversion
   - Test MapBlockSystem with different grid sizes

---

## File-by-File Recommendations

| File | Status | Action | Priority |
|------|--------|--------|----------|
| `mapblock_loader_v2.lua` | ✅ Complete | None | - |
| `mapblock_loader.lua` | ❌ Deprecated | Archive to legacy/ | Medium |
| `map_generation_pipeline.lua` | ⚠️ Needs update | Integrate MapScriptExecutor | **HIGH** |
| `mapblock_system.lua` | ⚠️ Stub only | Implement with v2 loader | **HIGH** |
| `map_generator.lua` | ⚠️ Outdated | Add MapScript method | Medium |
| `grid_map.lua` | ✅ Complete | None | - |
| `map_block.lua` | ✅ Complete | None | - |
| `pathfinding.lua` | ✅ Complete | None | - |
| `trajectory.lua` | ✅ Complete | None | - |
| `map_saver.lua` | ✅ Complete | None | - |

---

## Code Changes Required

### 1. map_generation_pipeline.lua

**Add to top:**
```lua
local MapScriptExecutor = require("battlescape.logic.mapscript_executor")
local MapScriptsV2 = require("battlescape.data.mapscripts_v2")
local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")
```

**Replace placeMapBlocks() (lines ~169-203):**
```lua
---Place MapBlocks according to MapScript commands
---@param mapScriptId string MapScript ID
---@param options GenerationOptions Generation parameters
---@return table? context Execution context or nil on failure
function MapGenerationPipeline:placeMapBlocks(mapScriptId, options)
    local script = MapScriptsV2.get(mapScriptId)
    if not script then
        print("[MapGenerationPipeline] MapScript not found: " .. mapScriptId)
        return nil
    end
    
    -- Execute MapScript with seed
    local seed = options.seed or os.time()
    print(string.format("[MapGenerationPipeline] Executing MapScript '%s' with seed %d", mapScriptId, seed))
    
    local context = MapScriptExecutor.execute(script, seed)
    
    if not context then
        print("[MapGenerationPipeline] MapScript execution failed")
        return nil
    end
    
    -- Log statistics
    local stats = MapScriptExecutor.getStats(context)
    print(string.format("[MapGenerationPipeline] Map generated: %d%% filled", stats.fillPercentage))
    
    return context
end
```

**Add helper method:**
```lua
---Convert execution context to block list for compatibility
---@param context table MapScript execution context
---@return table blocks Array of {x, y, blockId, key}
function MapGenerationPipeline:contextToBlocks(context)
    local blocks = {}
    
    for y = 1, context.height do
        for x = 1, context.width do
            local key = string.format("%d_%d", x - 1, y - 1)
            local tileKey = context.grid[key]
            
            if tileKey and tileKey ~= "EMPTY" then
                table.insert(blocks, {
                    x = x - 1,
                    y = y - 1,
                    blockId = "map_tile", -- Placeholder
                    key = tileKey
                })
            end
        end
    end
    
    return blocks
end
```

### 2. mapblock_system.lua

**Replace entire file:**
```lua
-- Map Block System
-- Manages MapBlock-based map generation using TOML definitions

local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")
local MapScriptExecutor = require("battlescape.logic.mapscript_executor")
local MapScriptsV2 = require("battlescape.data.mapscripts_v2")

local MapBlockSystem = {}

---Load MapBlock library from directory
---@param directory string Path to MapBlock directory
---@return number count Number of blocks loaded
function MapBlockSystem.loadLibrary(directory)
    print(string.format("[MapBlockSystem] Loading block library from: %s", directory))
    
    local count = MapBlockLoader.loadAll(directory)
    
    print(string.format("[MapBlockSystem] Loaded %d blocks", count))
    return count
end

---Generate battlefield using MapScript
---@param gridWidth number Grid width in blocks
---@param gridHeight number Grid height in blocks
---@param mapScriptId string? Optional MapScript ID (auto-selects if nil)
---@return table? context Execution context or nil on failure
function MapBlockSystem.generateBattlefield(gridWidth, gridHeight, mapScriptId)
    print(string.format("[MapBlockSystem] Generating %dx%d battlefield", gridWidth, gridHeight))
    
    -- Auto-select MapScript if not provided
    if not mapScriptId then
        local scripts = MapScriptsV2.getAll()
        for id, script in pairs(scripts) do
            if script.size.width == gridWidth and script.size.height == gridHeight then
                mapScriptId = id
                break
            end
        end
    end
    
    if not mapScriptId then
        print("[MapBlockSystem] No suitable MapScript found for size")
        return nil
    end
    
    -- Get MapScript
    local script = MapScriptsV2.get(mapScriptId)
    if not script then
        print("[MapBlockSystem] MapScript not found: " .. tostring(mapScriptId))
        return nil
    end
    
    -- Execute MapScript
    local seed = os.time()
    local context = MapScriptExecutor.execute(script, seed)
    
    if not context then
        print("[MapBlockSystem] MapScript execution failed")
        return nil
    end
    
    print("[MapBlockSystem] Generation complete")
    return context
end

return MapBlockSystem
```

### 3. map_generator.lua

**Add new method (after generateFromMapBlocks):**
```lua
---Generate map using MapScript system (recommended)
---@param mapScriptId string MapScript ID to execute
---@param seed number? Optional seed for reproducibility
---@return table? context Execution context or nil on failure
function MapGenerator.generateFromMapScript(mapScriptId, seed)
    print(string.format("[MapGenerator] Generating map from MapScript: %s", mapScriptId))
    
    local MapScriptExecutor = require("battlescape.logic.mapscript_executor")
    local MapScriptsV2 = require("battlescape.data.mapscripts_v2")
    
    local script = MapScriptsV2.get(mapScriptId)
    if not script then
        print("[MapGenerator] MapScript not found: " .. mapScriptId)
        return nil
    end
    
    seed = seed or os.time()
    print(string.format("[MapGenerator] Using seed: %d", seed))
    
    local context = MapScriptExecutor.execute(script, seed)
    
    if not context then
        print("[MapGenerator] MapScript execution failed")
        return nil
    end
    
    local stats = MapScriptExecutor.getStats(context)
    print(string.format("[MapGenerator] Map generated: %dx%d blocks, %.1f%% filled",
        context.width, context.height, stats.fillPercentage))
    
    return context
end
```

---

## Testing Checklist

After making changes, verify:

- [ ] `map_generation_pipeline.lua` uses MapScriptExecutor
- [ ] `mapblock_system.lua` loads blocks with MapBlockLoader v2
- [ ] `map_generator.lua` has `generateFromMapScript()` method
- [ ] Old `mapblock_loader.lua` archived or removed
- [ ] All 5 example MapScripts execute without errors
- [ ] Love2D console shows proper logging
- [ ] No memory leaks after 100 generations
- [ ] Map statistics are accurate
- [ ] Integration with hex grid works

---

## Summary

**Current State:**
- 3 files need updates (pipeline, system, generator)
- 1 file needs archiving (old loader)
- 6 files are complete and ready

**Required Work:**
- ~200 lines of code changes
- ~2-3 hours of implementation
- ~1 hour of testing

**Benefits:**
- Full MapScript system integration
- Unified map generation architecture
- Better performance and maintainability
- Ready for Phase 5 (Map Editor)

**Next Step:** Update `map_generation_pipeline.lua` first (highest priority).
