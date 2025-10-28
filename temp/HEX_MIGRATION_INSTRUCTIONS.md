# Hex Vertical Axial - Migration Status & Instructions

**Date:** 2025-10-28  
**Status:** Core systems migrated, remaining systems documented for migration

---

## ✅ COMPLETED MIGRATIONS

### Core Hex Mathematics
1. **engine/battlescape/battle_ecs/hex_math.lua** - COMPLETE
   - Universal hex math module
   - Direction vectors: E, SE, SW, W, NW, NE
   - Distance, neighbors, line-of-sight, range calculations
   - Pixel conversion with odd column offset
   - 320 lines, fully documented

2. **engine/geoscape/systems/grid/hex_grid.lua** - UPDATED
   - Header references vertical axial
   - Direction vectors match hex_math.lua
   - Pixel conversion formulas corrected

3. **engine/battlescape/maps/grid_map.lua** - HEADER UPDATED
   - Added HexMath import
   - Header documentation references vertical axial
   - Ready for coordinate migration

4. **engine/battlescape/systems/pathfinding_system.lua** - PARTIALLY UPDATED
   - Header updated with vertical axial reference
   - HexMath import path corrected
   - Node class uses axial (q, r) coordinates
   - Heuristic function uses HexMath.distance()
   - **Needs:** Update findPath() function body to use axial throughout

### Documentation
1. **design/mechanics/hex_vertical_axial_system.md** - COMPLETE
2. **api/BATTLESCAPE.md** - UPDATED
3. **api/GEOSCAPE.md** - UPDATED
4. **design/mechanics/battlescape.md** - UPDATED

### Tests
1. **tests2/utils/hex_math_vertical_axial_test.lua** - COMPLETE
   - 8 test groups, 20+ test cases

---

## 🔄 MIGRATION INSTRUCTIONS

### Standard Migration Pattern

For EVERY file that deals with hex coordinates, follow these steps:

#### Step 1: Add HexMath Import
```lua
-- At top of file, after existing requires
local HexMath = require("engine.battlescape.battle_ecs.hex_math")
```

#### Step 2: Update Function Signatures
**BEFORE (offset coordinates):**
```lua
function findPath(startX, startY, goalX, goalY)
function getNeighbors(x, y)
function calculateDistance(x1, y1, x2, y2)
```

**AFTER (axial coordinates):**
```lua
function findPath(startQ, startR, goalQ, goalR)
function getNeighbors(q, r)
function calculateDistance(q1, r1, q2, r2)
```

#### Step 3: Replace Direction Logic
**BEFORE (custom directions):**
```lua
local directions = {
    {dx = 1, dy = 0},
    {dx = 0, dy = 1},
    -- ... etc
}
```

**AFTER (use HexMath):**
```lua
-- Just use HexMath.DIRECTIONS - no local copy needed
local neighbors = HexMath.getNeighbors(q, r)
```

#### Step 4: Replace Distance Calculations
**BEFORE:**
```lua
local dist = math.abs(x1 - x2) + math.abs(y1 - y2)  -- Wrong!
```

**AFTER:**
```lua
local dist = HexMath.distance(q1, r1, q2, r2)  -- Correct hex distance
```

#### Step 5: Replace Neighbor Queries
**BEFORE:**
```lua
for dx = -1, 1 do
    for dy = -1, 1 do
        local nx, ny = x + dx, y + dy
        -- Check neighbor...
    end
end
```

**AFTER:**
```lua
local neighbors = HexMath.getNeighbors(q, r)
for _, neighbor in ipairs(neighbors) do
    local nq, nr = neighbor.q, neighbor.r
    -- Check neighbor...
end
```

#### Step 6: Replace Line-of-Sight
**BEFORE (custom implementation):**
```lua
-- Complex Bresenham or ray-casting code
```

**AFTER:**
```lua
local hexLine = HexMath.hexLine(q1, r1, q2, r2)
for _, hex in ipairs(hexLine) do
    -- Check each hex along line
end
```

#### Step 7: Replace Range Queries
**BEFORE:**
```lua
for x = centerX - range, centerX + range do
    for y = centerY - range, centerY + range do
        if distance(x, y, centerX, centerY) <= range then
            -- In range...
        end
    end
end
```

**AFTER:**
```lua
local hexes = HexMath.hexesInRange(centerQ, centerR, range)
for _, hex in ipairs(hexes) do
    -- Process hex in range...
end
```

#### Step 8: Update Header Documentation
Add to file header:
```lua
---COORDINATE SYSTEM: Vertical Axial (Flat-Top Hexagons)
---  - All positions use axial coordinates {q, r}
---  - Distance: HexMath.distance(q1, r1, q2, r2)
---  - Neighbors: HexMath.getNeighbors(q, r)
---  - Line-of-sight: HexMath.hexLine(q1, r1, q2, r2)
---
---DESIGN REFERENCE: design/mechanics/hex_vertical_axial_system.md
---
---@see engine.battlescape.battle_ecs.hex_math For hex mathematics
```

---

## 📋 PRIORITY MIGRATION QUEUE

### HIGH PRIORITY (Core Gameplay)

1. **engine/battlescape/systems/pathfinding_system.lua**
   - Update findPath() body to use axial coordinates
   - Update reconstructPath() to return axial coordinates
   - Update helper functions (getLowestFScore, inList, etc.)

2. **engine/battlescape/battle_ecs/vision_system.lua**
   - Update calculateLineOfSight() to use HexMath.hexLine()
   - Update visibility calculations to use HexMath.distance()
   - Update neighbor checks to use HexMath.getNeighbors()

3. **engine/battlescape/systems/los_system.lua**
   - Update LOS calculations to use HexMath.hexLine()
   - Update FOW updates to use axial coordinates
   - Update visibility range checks

4. **engine/battlescape/effects/explosion_system.lua**
   - Update blast radius to use HexMath.hexesInRange()
   - Update damage fall-off to use HexMath.distance()

5. **engine/battlescape/maps/map_generator.lua**
   - Ensure map block placement uses axial coordinates
   - Update terrain generation

### MEDIUM PRIORITY (Combat Systems)

6. **engine/battlescape/battle_ecs/shooting_system.lua**
   - Update firing range checks to use HexMath.distance()
   - Update LOS checks to use HexMath.hexLine()

7. **engine/battlescape/systems/reaction_fire_system.lua**
   - Update trigger range to use HexMath.distance()
   - Update vision cone to use HexMath directions

8. **engine/battlescape/systems/cover_system.lua**
   - Update cover calculations based on hex direction
   - Use HexMath.getDirection() for cover facing

9. **engine/battlescape/combat/psionics_system.lua**
   - Update psionic range to use HexMath.distance()
   - Update LOS requirement checks

10. **engine/battlescape/systems/grenade_trajectory_system.lua**
    - Update arc calculations
    - Update blast radius with HexMath.hexesInRange()

### MEDIUM PRIORITY (World Systems)

11. **engine/geoscape/geography/province.lua**
    - Update province neighbors to use HexMath.getNeighbors()
    - Update border calculations

12. **engine/geoscape/geography/province_graph.lua**
    - Update graph connections to use axial coordinates
    - Update pathfinding to use HexMath.distance()

13. **engine/geoscape/logic/province_pathfinding.lua**
    - Update A* to use HexMath functions
    - Update travel distance calculations

14. **engine/geoscape/world/world.lua**
    - Update world map coordinate system
    - Ensure all province positioning uses axial

### LOW PRIORITY (Rendering & UI)

15. **engine/battlescape/rendering/renderer.lua**
    - Update FOW rendering to use axial coordinates
    - Update tile rendering loops

16. **engine/battlescape/ui/minimap_system.lua**
    - Update minimap coordinate conversions
    - Update FOW display

17. **engine/battlescape/systems/visibility_integration.lua**
    - Update visibility calculations

18. **engine/battlescape/systems/sound_detection_system.lua**
    - Update sound propagation to use HexMath.hexesInRange()

---

## 🧪 TESTING CHECKLIST

After migrating each file, verify:

1. **Engine Loads**
   ```bash
   lovec "engine"
   ```
   - No syntax errors
   - No import errors
   - All modules load

2. **Maps Generate**
   - Start battlescape
   - Verify map generates correctly
   - Check hex layout appears correct

3. **Pathfinding Works**
   - Click to move unit
   - Verify path displays
   - Verify unit follows path

4. **LOS Works**
   - Check unit vision ranges
   - Verify FOW updates correctly
   - Check shooting range indicators

5. **Combat Works**
   - Fire weapon
   - Throw grenade
   - Check explosion radius
   - Verify range calculations

6. **World Map Works**
   - Open geoscape
   - Check province layout
   - Verify craft travel
   - Check pathfinding

---

## 🔧 COMMON ISSUES & SOLUTIONS

### Issue: "attempt to index nil value (field 'q')"
**Cause:** Forgot to convert offset (x, y) to axial (q, r)  
**Solution:** Use HexMath functions that return axial coordinates

### Issue: "Wrong neighbor count (expected 6, got 8)"
**Cause:** Using square grid neighbor logic instead of hex  
**Solution:** Use `HexMath.getNeighbors(q, r)` which returns exactly 6 neighbors

### Issue: "Distance calculation incorrect"
**Cause:** Using Manhattan distance instead of hex distance  
**Solution:** Always use `HexMath.distance(q1, r1, q2, r2)`

### Issue: "Map looks rotated/skewed"
**Cause:** This is correct! Vertical axial creates skewed appearance  
**Solution:** This is intentional - see design doc

### Issue: "Explosion doesn't cover correct area"
**Cause:** Using square radius instead of hex range  
**Solution:** Use `HexMath.hexesInRange(q, r, radius)`

---

## 📚 REFERENCE DOCUMENTS

- **Design:** design/mechanics/hex_vertical_axial_system.md
- **API Battle:** api/BATTLESCAPE.md (coordinate system section)
- **API Geoscape:** api/GEOSCAPE.md (coordinate system section)
- **Core Module:** engine/battlescape/battle_ecs/hex_math.lua
- **Tests:** tests2/utils/hex_math_vertical_axial_test.lua

---

## 🎯 SUCCESS CRITERIA

Migration is complete when:
- [ ] All 18+ priority files migrated
- [ ] Engine loads without errors
- [ ] Maps generate correctly
- [ ] Pathfinding works
- [ ] LOS/FOW works
- [ ] Combat works (shooting, grenades, explosions)
- [ ] World travel works
- [ ] All tests pass
- [ ] No performance regressions

---

## 💡 TIPS

1. **Migrate incrementally** - One file at a time
2. **Test after each file** - Catch errors early
3. **Use HexMath everywhere** - Never implement custom hex math
4. **Document as you go** - Update file headers
5. **Run tests frequently** - Ensure nothing breaks
6. **Ask for help** - Check design doc if confused

---

## 🚀 NEXT STEPS

1. Complete pathfinding_system.lua migration (findPath() function)
2. Migrate vision_system.lua
3. Migrate los_system.lua
4. Migrate explosion_system.lua
5. Test each system thoroughly
6. Continue down priority list

**Estimated time for full migration:** 4-6 hours

**Current progress:** ~10% (core infrastructure complete)

