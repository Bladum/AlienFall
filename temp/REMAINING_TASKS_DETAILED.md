# REMAINING MIGRATION TASKS - DETAILED CHECKLIST

**Updated:** 2025-10-28 (po częściowej migracji)  
**Status:** 20% Complete | 40+ files pozostało

---

## ✅ COMPLETED (10 files)

1. ✅ engine/battlescape/battle_ecs/hex_math.lua - COMPLETE (320 lines)
2. ✅ engine/geoscape/systems/grid/hex_grid.lua - COMPLETE
3. ✅ engine/battlescape/systems/pathfinding_system.lua - COMPLETE REWRITE (250 lines)
4. ✅ engine/battlescape/battle_ecs/vision_system.lua - HEADER + IMPORT
5. ✅ engine/battlescape/effects/explosion_system.lua - HEADER + calculatePropagation()
6. ✅ engine/battlescape/maps/grid_map.lua - HEADER + IMPORT
7. ✅ engine/battlescape/systems/los_system.lua - HEADER + IMPORT
8. ✅ tests2/utils/hex_math_vertical_axial_test.lua - COMPLETE
9. ✅ design/mechanics/hex_vertical_axial_system.md - COMPLETE
10. ✅ api/BATTLESCAPE.md + api/GEOSCAPE.md - UPDATED

---

## 🔴 HIGH PRIORITY (Must do first - 15 files)

### A. Map Generation (4 files) - CRITICAL
```
[ ] engine/battlescape/maps/map_generator.lua
    Action: Replace grid iteration with HexMath
    Pattern: for x,y loops → HexMath.hexesInRange()
    
[ ] engine/battlescape/maps/map_block.lua  
    Action: Update block transformations to use hex directions
    Pattern: Rotation → HexMath.DIRECTIONS indexing
    
[ ] engine/battlescape/maps/map_generation_pipeline.lua
    Action: Update pipeline to use axial coordinates
    
[ ] engine/battlescape/mapscripts/mapscript_executor.lua
    Action: Update script execution to use (q, r)
```

### B. Combat Ranges (6 files) - CRITICAL
```
[ ] engine/battlescape/battle_ecs/shooting_system.lua
    Action: Replace range checks with HexMath.distance()
    Pattern: distance calc → HexMath.distance(q1, r1, q2, r2)
    
[ ] engine/battlescape/systems/reaction_fire_system.lua
    Action: Update trigger range to use HexMath
    
[ ] engine/battlescape/systems/cover_system.lua
    Action: Update cover facing to use HexMath.getDirection()
    Pattern: direction calc → HexMath.getDirection(q1, r1, q2, r2)
    
[ ] engine/battlescape/systems/grenade_trajectory_system.lua
    Action: Update arc calculation with HexMath.hexLine()
    
[ ] engine/battlescape/systems/throwables_system.lua
    Action: Update range checks with HexMath.distance()
    
[ ] engine/battlescape/combat/psionics_system.lua
    Action: Update psionic range with HexMath.distance()
```

### C. Line of Sight (3 files) - CRITICAL
```
[ ] engine/battlescape/systems/line_of_sight.lua
    Action: Replace LOS algorithm with HexMath.hexLine()
    Pattern: raycast → HexMath.hexLine(q1, r1, q2, r2)
    
[ ] engine/battlescape/combat/los_optimized.lua
    Action: Update optimized LOS to use HexMath
    
[ ] engine/battlescape/rendering/renderer.lua
    Action: Update FOW rendering to use axial coordinates
    Pattern: tile loops → iterate over axial coords
```

### D. Fog of War (2 files) - CRITICAL
```
[ ] engine/battlescape/ui/minimap_system.lua
    Action: Update minimap coordinate conversions
    Pattern: screen→hex → use HexMath.pixelToHex()
    
[ ] engine/core/team.lua
    Action: Update FOW grid to use axial coordinates
    Pattern: [x][y] → [key] where key = "q,r"
```

---

## 🟡 MEDIUM PRIORITY (Should do next - 12 files)

### E. Movement & Detection (4 files)
```
[ ] engine/battlescape/systems/movement_3d.lua
    Action: Update movement to use (q, r)
    
[ ] engine/battlescape/systems/sound_detection_system.lua
    Action: Update sound propagation with HexMath.hexesInRange()
    
[ ] engine/battlescape/systems/concealment_detection.lua
    Action: Update detection radius with HexMath
    
[ ] engine/battlescape/systems/visibility_integration.lua
    Action: Update visibility checks
```

### F. World/Geoscape (4 files)
```
[ ] engine/geoscape/world/world.lua
    Action: Update world map to use axial coordinates
    Pattern: province positions → (q, r)
    
[ ] engine/geoscape/geography/province.lua
    Action: Update province neighbors with HexMath.getNeighbors()
    
[ ] engine/geoscape/geography/province_graph.lua
    Action: Update graph connections to use axial
    
[ ] engine/geoscape/logic/province_pathfinding.lua
    Action: Update A* to use HexMath.distance()
```

### G. Additional Combat (4 files)
```
[ ] engine/battlescape/systems/melee_system.lua
    Action: Update melee range (should be distance = 1)
    
[ ] engine/battlescape/systems/suppression_system.lua
    Action: Update suppression area with HexMath.hexesInRange()
    
[ ] engine/battlescape/systems/morale_system.lua
    Action: Update morale radius effects
    
[ ] engine/battlescape/systems/environmental_hazards.lua
    Action: Update hazard spread with HexMath
```

---

## 🟢 LOW PRIORITY (Can wait - 15+ files)

### H. Rendering & UI (5 files)
```
[ ] engine/battlescape/rendering/object_renderer_3d.lua
[ ] engine/battlescape/rendering/effects_renderer.lua
[ ] engine/battlescape/rendering/billboard_renderer.lua
[ ] engine/battlescape/ui/pathfinding_ui.lua
[ ] engine/gui/widgets/advanced/minimap.lua
```

### I. Secondary Systems (10+ files)
```
[ ] engine/battlescape/systems/camera_control_system.lua
[ ] engine/battlescape/systems/destructible_terrain_system.lua
[ ] engine/battlescape/systems/spatial_partitioning.lua
[ ] engine/battlescape/systems/status_effects_system.lua
[ ] engine/basescape/* (structure TBD)
[ ] ... and more
```

---

## 📋 STANDARD MIGRATION PROCEDURE

### For EACH file:

```bash
# 1. Open file
# 2. Add import at top (if not present):
local HexMath = require("engine.battlescape.battle_ecs.hex_math")

# 3. Update header:
---COORDINATE SYSTEM: Vertical Axial (Flat-Top Hexagons)
---@see engine.battlescape.battle_ecs.hex_math For hex mathematics

# 4. Find/Replace patterns:
#    - Function params: (x, y) → (q, r)
#    - Distance: math.abs(x1-x2) + math.abs(y1-y2) → HexMath.distance(q1, r1, q2, r2)
#    - Neighbors: custom loop → HexMath.getNeighbors(q, r)
#    - LOS: custom raycast → HexMath.hexLine(q1, r1, q2, r2)
#    - Range: custom radius → HexMath.hexesInRange(q, r, radius)

# 5. Test:
lovec "engine"  # Must load without errors

# 6. Commit:
git commit -m "feat(hex): Migrate [filename] to vertical axial"
```

---

## 🎯 WEEKLY GOALS

### Week 1 (Priority: Gameplay)
- [ ] Complete all HIGH PRIORITY files (15)
- [ ] Test: Units can move, see, and shoot
- [ ] Test: Maps generate correctly

### Week 2 (Priority: World)
- [ ] Complete MEDIUM PRIORITY files (12)
- [ ] Test: World map works
- [ ] Test: Province travel works

### Week 3 (Priority: Polish)
- [ ] Complete LOW PRIORITY files (15+)
- [ ] Full integration test
- [ ] Performance optimization

---

## 🔧 QUICK REFERENCE

### Common Replacements

```lua
-- OLD (Offset)
function move(x, y)
    for dx = -1, 1 do
        for dy = -1, 1 do
            local nx, ny = x + dx, y + dy
            if math.abs(nx-targetX) + math.abs(ny-targetY) < range then
                -- Do something
            end
        end
    end
end

-- NEW (Axial)
function move(q, r)
    local neighbors = HexMath.getNeighbors(q, r)
    for _, neighbor in ipairs(neighbors) do
        local nq, nr = neighbor.q, neighbor.r
        if HexMath.distance(nq, nr, targetQ, targetR) < range then
            -- Do something
        end
    end
end
```

### HexMath Quick API

```lua
-- Distance
local dist = HexMath.distance(q1, r1, q2, r2)

-- Neighbors (returns 6)
local neighbors = HexMath.getNeighbors(q, r)
for _, n in ipairs(neighbors) do
    print(n.q, n.r)
end

-- Line of sight
local line = HexMath.hexLine(q1, r1, q2, r2)
for _, hex in ipairs(line) do
    -- Check hex.q, hex.r
end

-- Range area
local hexes = HexMath.hexesInRange(centerQ, centerR, radius)
for _, hex in ipairs(hexes) do
    -- Process hex.q, hex.r
end

-- Direction
local dir = HexMath.getDirection(fromQ, fromR, toQ, toR)
-- Returns 0-5 or -1 if not adjacent

-- Pixel conversion
local x, y = HexMath.hexToPixel(q, r, hexSize)
local q, r = HexMath.pixelToHex(x, y, hexSize)
```

---

## 📊 PROGRESS TRACKING

**Current:** 20% (10/50 files)  
**Target Week 1:** 50% (25/50 files)  
**Target Week 2:** 75% (37/50 files)  
**Target Week 3:** 100% (50/50 files)

**Estimated time remaining:** 20-24 hours of focused work

---

## ✅ DONE TODAY (Session Summary)

1. Created hex_math.lua (320 lines)
2. Rewrote pathfinding_system.lua (250 lines)
3. Updated vision_system.lua header + import
4. Updated explosion_system.lua calculatePropagation()
5. Updated los_system.lua header + import
6. Updated grid_map.lua header + import
7. Created comprehensive documentation (7 files)
8. Created test suite (20+ tests)
9. Verified engine loads without errors

**Time invested:** ~3 hours  
**Value delivered:** Foundation complete, critical systems updated

---

**Next session: Start with HIGH PRIORITY Group A (Map Generation)**

