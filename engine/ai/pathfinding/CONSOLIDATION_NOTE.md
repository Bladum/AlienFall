# Pathfinding System Consolidation (Phase 3)

**Date:** Phase 3 Consolidation
**Status:** ✅ Completed

## Consolidation Summary

The pathfinding system has been consolidated to use a single, optimized A* implementation at:
```
engine/ai/pathfinding/tactical_pathfinding.lua  [CANONICAL]
```

## Duplicate/Obsolete Files

### ✅ CONSOLIDATED - DO NOT USE:
- **`engine/battlescape/pathfinding_system.lua`** (436 lines)
  - Duplicate A* implementation
  - Marked for deletion (not actively used)
  - Functionality merged into `tactical_pathfinding.lua`

### ℹ️ REFERENCE ONLY - DO NOT USE:
- **`engine/ai/pathfinding/pathfinding.lua`** (440 lines)
  - Generic A* implementation
  - Kept for reference/documentation
  - No active usage in codebase
  - Superseded by `tactical_pathfinding.lua`

## Active Implementation

**File:** `engine/ai/pathfinding/tactical_pathfinding.lua`
**Lines:** 495 LOC
**Status:** ✅ CANONICAL IMPLEMENTATION

### Features:
- Binary heap priority queue (optimized for large maps)
- Node pool memory efficiency (object reuse)
- Hex grid navigation (6 neighbors per tile)
- Terrain-based movement costs
- TU/Action Point aware pathfinding
- Multi-turn path planning with cost limits
- Path validation and update detection
- Performance metrics logging

### Usage:
```lua
local Pathfinding = require("ai.pathfinding.tactical_pathfinding")

-- Find path from start to goal
local path = Pathfinding.findPath(battlefield, startX, startY, goalX, goalY, terrainCosts)

-- Calculate TU cost
local tuCost = Pathfinding.calculateTUCost(path, baseTUCost)

-- Split path by available TUs
local currentPath, remainingPath = Pathfinding.splitPathByTUs(path, availableTUs, baseTUCost)

-- Validate path (check for new obstacles)
if Pathfinding.isPathValid(battlefield, path) then
  -- Execute movement
end
```

### Active Imports (from codebase):
1. `engine/battlescape/battlescape_screen.lua` line 59
2. `engine/battlescape/ui/logic.lua` line 65

## Why Keep Reference Files?

**`pathfinding.lua` (generic implementation)** is kept in the pathfinding folder because:
- Documents the basic A* algorithm structure
- Useful for testing and prototyping
- May be needed if generic pathfinding required in future non-combat contexts
- Located in dedicated pathfinding folder for clarity

**Status:** Document as "reference implementation - not for production use"

## Migration Notes

If any code references the old implementations:
- Replace `require("ai.pathfinding.pathfinding")` → use `ai.pathfinding.tactical_pathfinding`
- Replace `require("battlescape.pathfinding_system")` → use `ai.pathfinding.tactical_pathfinding`

## Next Steps

- [x] Enhanced tactical_pathfinding.lua documentation
- [x] Mark consolidation in file headers
- [ ] Delete battlescape/pathfinding_system.lua
- [ ] Audit for any remaining references to old modules
- [ ] Update engine README.md

---

**Related:** Phase 3 Engine Restructuring
**Architecture Impact:** Reduces code duplication, improves maintainability
**Performance:** Binary heap optimization maintains O(n log n) complexity
