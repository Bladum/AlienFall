# Hex Vertical Axial - Complete Migration Plan

**Date:** 2025-10-28  
**Goal:** Migrate ALL game systems to vertical axial hex coordinate system

---

## Systems to Migrate

### ✅ COMPLETED
- [x] engine/battlescape/battle_ecs/hex_math.lua - Core hex mathematics
- [x] engine/geoscape/systems/grid/hex_grid.lua - Geoscape hex grid
- [x] design/mechanics/hex_vertical_axial_system.md - Design documentation
- [x] api/BATTLESCAPE.md - API documentation
- [x] api/GEOSCAPE.md - API documentation

### 🔄 IN PROGRESS - HIGH PRIORITY

#### Battle Map Generation
- [ ] engine/battlescape/maps/map_generator.lua - Map generation from scripts
- [ ] engine/battlescape/maps/grid_map.lua - Map block grid
- [ ] engine/battlescape/maps/map_block.lua - Individual map blocks
- [ ] engine/battlescape/maps/map_generation_pipeline.lua - Generation pipeline
- [ ] engine/battlescape/mapscripts/mapscript_executor.lua - Map script execution

#### Pathfinding Systems
- [ ] engine/battlescape/systems/pathfinding_system.lua - Battle pathfinding
- [ ] engine/battlescape/systems/pathfinding.lua - Alternative pathfinding
- [ ] engine/geoscape/logic/province_pathfinding.lua - World pathfinding
- [ ] engine/ai/pathfinding/pathfinding.lua - AI pathfinding

#### Line of Sight & Vision
- [ ] engine/battlescape/battle_ecs/vision_system.lua - ECS vision
- [ ] engine/battlescape/battle_ecs/vision.lua - Vision component
- [ ] engine/battlescape/systems/los_system.lua - LOS system
- [ ] engine/battlescape/systems/line_of_sight.lua - LOS calculations
- [ ] engine/battlescape/combat/los_optimized.lua - Optimized LOS

#### Fog of War
- [ ] engine/battlescape/rendering/renderer.lua - FOW rendering
- [ ] engine/battlescape/ui/minimap_system.lua - Minimap FOW
- [ ] engine/core/team.lua - Team FOW state

#### Range & Area Effects
- [ ] engine/battlescape/effects/explosion_system.lua - Explosions from epicenter
- [ ] engine/battlescape/systems/grenade_trajectory_system.lua - Grenade arcs
- [ ] engine/battlescape/systems/throwables_system.lua - Throwable items

#### Combat Systems
- [ ] engine/battlescape/combat/psionics_system.lua - Psionic range/LOS
- [ ] engine/battlescape/battle_ecs/shooting_system.lua - Firing range/LOS
- [ ] engine/battlescape/systems/reaction_fire_system.lua - Reaction fire
- [ ] engine/battlescape/systems/cover_system.lua - Cover calculations

#### Movement & Detection
- [ ] engine/battlescape/systems/movement_3d.lua - Unit movement
- [ ] engine/battlescape/systems/sound_detection_system.lua - Sound propagation
- [ ] engine/battlescape/systems/concealment_detection.lua - Stealth detection
- [ ] engine/battlescape/systems/visibility_integration.lua - Visibility

#### World/Geoscape
- [ ] engine/geoscape/world/world.lua - World map
- [ ] engine/geoscape/geography/province.lua - Province system
- [ ] engine/geoscape/geography/province_graph.lua - Province connections
- [ ] engine/geoscape/systems/travel_system.lua - Craft travel (if exists)

#### Base Management
- [ ] engine/basescape/ - Base hex grid layout (TBD - investigate structure)

---

## Migration Strategy

### Phase 1: Core Dependencies (DONE)
✅ hex_math.lua - Universal math module  
✅ hex_grid.lua - Geoscape grid  
✅ Documentation updates

### Phase 2: Map Generation (CURRENT)
1. Update grid_map.lua to use HexMath
2. Update map_block.lua transformations
3. Update map_generator.lua
4. Update mapscript_executor.lua

### Phase 3: Pathfinding
1. Update pathfinding_system.lua (battle)
2. Update province_pathfinding.lua (world)
3. Update AI pathfinding

### Phase 4: Vision & Detection
1. Update vision_system.lua
2. Update los_system.lua
3. Update FOW rendering

### Phase 5: Combat Systems
1. Update shooting_system.lua
2. Update explosion_system.lua
3. Update grenade trajectories
4. Update reaction fire

### Phase 6: World Systems
1. Update province.lua
2. Update province_graph.lua
3. Update travel system

### Phase 7: Testing
1. Run all tests
2. Validate map generation
3. Validate pathfinding
4. Validate combat
5. Validate world travel

---

## Standard Migration Pattern

### For each file:
1. **Add import:** `local HexMath = require("engine.battlescape.battle_ecs.hex_math")`
2. **Replace direction logic:** Use `HexMath.DIRECTIONS` and `HexMath.neighbor()`
3. **Replace distance:** Use `HexMath.distance(q1, r1, q2, r2)`
4. **Replace neighbors:** Use `HexMath.getNeighbors(q, r)`
5. **Replace line:** Use `HexMath.hexLine(q1, r1, q2, r2)`
6. **Replace range:** Use `HexMath.hexesInRange(q, r, range)`
7. **Update comments:** Reference vertical axial system
8. **Add doc reference:** Link to design/mechanics/hex_vertical_axial_system.md

### Remove:
- Local direction tables
- Custom hex math functions
- Offset coordinate conversions
- Old neighbor calculations

---

## Testing Checklist

After each phase:
- [ ] Engine loads without errors
- [ ] Maps generate correctly
- [ ] Pathfinding works
- [ ] LOS calculations correct
- [ ] FOW updates properly
- [ ] Combat ranges accurate
- [ ] World travel functional

---

## Progress Tracking

**Files migrated:** 5/50+ (10%)  
**Current phase:** Phase 2 (Map Generation)  
**Blockers:** None  
**ETA:** 2-3 hours for complete migration

