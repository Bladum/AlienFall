# Code TODO/FIXME Inventory - October 23, 2025

**Document Purpose:** Catalog all TODO/FIXME markers in engine code and cross-reference with task tracking system.
**Analysis Date:** October 23, 2025
**Total TODOs Found:** 32 action items across 17 files
**Status:** ✅ Complete inventory with prioritization and task mapping

---

## 📊 Summary Statistics

| Category | Count | Priority | Status |
|----------|-------|----------|--------|
| **Battlescape Combat** | 9 | 🔴 HIGH | Most critical |
| **Geoscape Systems** | 5 | 🟠 MEDIUM | Campaign integration |
| **Economy Systems** | 6 | 🟠 MEDIUM | Feature completion |
| **Base Management** | 4 | 🟡 LOW | Non-blocking |
| **Other Systems** | 8 | 🟡 LOW | Polish/refinement |
| **Total** | 32 | — | Ready for task creation |

---

## 🔴 CRITICAL PRIORITY TODOs (BLOCKING GAMEPLAY)

### Battlescape Abilities - Must Implement

**1. Turret Unit Creation**
- **File:** `engine/battlescape/systems/abilities_system.lua:96`
- **Code:** `-- TODO: Create turret unit`
- **Impact:** ⚠️ HIGH - Ability incomplete, no turret deployment
- **Context:** Support class ability needs implementation
- **Task Recommendation:** Create `TASK-ABS-001-turret-ability.md`
- **Effort Estimate:** 3-4 hours
- **Depends On:** Unit spawning system

```lua
-- Line 96
if ability.type == "create_turret" then
    -- TODO: Create turret unit
    return false
end
```

---

**2. Marked Status Effect**
- **File:** `engine/battlescape/systems/abilities_system.lua:132`
- **Code:** `-- TODO: Apply marked status effect`
- **Impact:** ⚠️ HIGH - Status effect system incomplete
- **Context:** Scout/Support ability - marks targets for increased damage
- **Task Recommendation:** Create `TASK-ABS-002-marked-status.md`
- **Effort Estimate:** 2-3 hours
- **Depends On:** Status effect framework

```lua
-- Line 132
if ability.type == "mark_target" then
    -- TODO: Apply marked status effect
    return false
end
```

---

**3. Suppression Status Effect**
- **File:** `engine/battlescape/systems/abilities_system.lua:167`
- **Code:** `-- TODO: Apply suppression status effect to enemies in area`
- **Impact:** ⚠️ HIGH - Heavy class ability incomplete
- **Context:** Area effect suppression - reduces enemy action points
- **Task Recommendation:** Create `TASK-ABS-003-suppression-status.md`
- **Effort Estimate:** 2-3 hours
- **Depends On:** Status effect framework, area effect system

```lua
-- Line 167
if ability.type == "suppression_fire" then
    -- TODO: Apply suppression status effect to enemies in area
    return false
end
```

---

**4. Fortify Status Effect**
- **File:** `engine/battlescape/systems/abilities_system.lua:234`
- **Code:** `-- TODO: Apply fortify status effect`
- **Impact:** ⚠️ HIGH - Defense ability incomplete
- **Context:** Heavy class defensive stance - increases armor/resistance
- **Task Recommendation:** Create `TASK-ABS-004-fortify-status.md`
- **Effort Estimate:** 2-3 hours
- **Depends On:** Status effect framework, defense calculation

```lua
-- Line 234
if ability.type == "fortify" then
    -- TODO: Apply fortify status effect
    return false
end
```

---

**5. Team Placement Algorithm**
- **File:** `engine/battlescape/mission_map_generator.lua:262`
- **Code:** `-- TODO: Implement team placement`
- **Impact:** ⚠️ HIGH - Mission startup incomplete
- **Context:** Initial unit positioning on generated maps
- **Task Recommendation:** Create `TASK-GEN-001-team-placement.md`
- **Effort Estimate:** 3-4 hours
- **Depends On:** Map generation, unit spawning

```lua
-- Line 262
-- TODO: Implement team placement
-- Currently units don't have starting positions
```

---

### Battlescape Rendering

**6. 3D Map Integration**
- **File:** `engine/battlescape/rendering/renderer_3d.lua:251`
- **Code:** `-- TODO: Integrate with actual battlescape map system`
- **Impact:** 🟠 MEDIUM - 3D renderer incomplete
- **Context:** 3D rendering layer not connected to game maps
- **Task Recommendation:** Create `TASK-REN-001-3d-map-integration.md`
- **Effort Estimate:** 4-5 hours
- **Depends On:** Map rendering system, camera system

```lua
-- Line 251
-- TODO: Integrate with actual battlescape map system
```

---

**7. Unit Sprite Rendering**
- **File:** `engine/battlescape/rendering/renderer_3d.lua:296`
- **Code:** `-- TODO: Implement unit sprite rendering`
- **Impact:** 🟠 MEDIUM - 3D unit visuals incomplete
- **Context:** Units not visible in 3D rendered scenes
- **Task Recommendation:** Create `TASK-REN-002-unit-sprite-rendering.md`
- **Effort Estimate:** 3-4 hours
- **Depends On:** Sprite system, animation system

```lua
-- Line 296
-- TODO: Implement unit sprite rendering
```

---

### Throwables System

**8. Obstacle Detection for Throwables**
- **File:** `engine/battlescape/systems/throwables_system.lua:147`
- **Code:** `-- TODO: Check for obstacles/ceiling in arc path`
- **Impact:** 🟠 MEDIUM - Physics incomplete
- **Context:** Grenades should collide with terrain/ceiling
- **Task Recommendation:** Create `TASK-THR-001-throwable-physics.md`
- **Effort Estimate:** 2-3 hours
- **Depends On:** Terrain collision system

```lua
-- Line 147
-- TODO: Check for obstacles/ceiling in arc path
```

---

**9. Stun Status Effect for Throwables**
- **File:** `engine/battlescape/systems/throwables_system.lua:279`
- **Code:** `-- TODO: Apply STUNNED status effect to units in affected tiles`
- **Impact:** 🟠 MEDIUM - Grenade effect incomplete
- **Context:** Stun grenades need to apply stun status
- **Task Recommendation:** Create `TASK-THR-002-stun-effect.md`
- **Effort Estimate:** 1-2 hours
- **Depends On:** Status effect framework

```lua
-- Line 279
-- TODO: Apply STUNNED status effect to units in affected tiles
```

---

**10. Robotic Unit Disabling**
- **File:** `engine/battlescape/systems/throwables_system.lua:290`
- **Code:** `-- TODO: Disable robotic units, electronics`
- **Impact:** 🟠 MEDIUM - EMP grenade incomplete
- **Context:** EMP grenades should disable mechanical enemies
- **Task Recommendation:** Create `TASK-THR-003-emp-effect.md`
- **Effort Estimate:** 2-3 hours
- **Depends On:** Unit classification, status effect system

```lua
-- Line 290
-- TODO: Disable robotic units, electronics
```

---

## 🟠 HIGH PRIORITY TODOs (CAMPAIGN/GEOSCAPE INTEGRATION)

### Campaign Manager Integration

**11. Faction Relations for Mission Generation**
- **File:** `engine/lore/campaign/campaign_manager.lua:169`
- **Code:** `-- TODO: Base this on faction relations when FactionManager/RelationsManager exist`
- **Impact:** 🟠 MEDIUM - Campaign logic incomplete
- **Context:** Mission selection should reflect faction relationships
- **Task Recommendation:** Depends on `TASK-CLS` (Campaign/Lore systems)
- **Effort Estimate:** 2-3 hours (after FactionManager)
- **Blocking:** Campaign phase logic

```lua
-- Line 169
-- TODO: Base this on faction relations when FactionManager/RelationsManager exist
```

---

**12. Faction-Based Mission Generation**
- **File:** `engine/lore/campaign/campaign_manager.lua:187`
- **Code:** `-- TODO: Replace with faction-based generation when FactionManager exists`
- **Impact:** 🟠 MEDIUM - Campaign diversity limited
- **Context:** Missions should vary based on active factions
- **Task Recommendation:** Depends on `TASK-CLS` (Campaign/Lore systems)
- **Effort Estimate:** 2-3 hours (after FactionManager)

```lua
-- Line 187
-- TODO: Replace with faction-based generation when FactionManager exists
```

---

**13. Faction Assignment in Missions**
- **File:** `engine/lore/campaign/campaign_manager.lua:232`
- **Code:** `faction = "aliens",  -- TODO: Use actual faction when FactionManager exists`
- **Impact:** 🟠 MEDIUM - Missions hardcoded to aliens only
- **Context:** Enemy faction always hardcoded
- **Task Recommendation:** Depends on `TASK-CLS` (Campaign/Lore systems)
- **Effort Estimate:** 1-2 hours (after FactionManager)

```lua
-- Line 232
faction = "aliens",  -- TODO: Use actual faction when FactionManager exists
```

---

**14. Province Selection in Missions**
- **File:** `engine/lore/campaign/campaign_manager.lua:233`
- **Code:** `province = nil,  -- TODO: Select province when World system exists`
- **Impact:** 🟠 MEDIUM - Missions not geographically linked
- **Context:** Missions should reference actual world provinces
- **Task Recommendation:** Depends on `TASK-PGS` (World system)
- **Effort Estimate:** 1-2 hours (after World system)

```lua
-- Line 233
province = nil,  -- TODO: Select province when World system exists
```

---

### Detection System Integration

**15. Base/Craft Scanning Integration**
- **File:** `engine/geoscape/systems/detection_manager.lua:126`
- **Code:** `-- TODO: Replace with actual base/craft scanning when those systems are ready`
- **Impact:** 🟠 MEDIUM - Detection system incomplete
- **Context:** Radar detection hardcoded, should use base/craft sensors
- **Task Recommendation:** Depends on base/craft systems
- **Effort Estimate:** 2-3 hours (after base/craft managers)

```lua
-- Line 126
-- TODO: Replace with actual base/craft scanning when those systems are ready
```

---

**16. Province Graph Pathfinding**
- **File:** `engine/geoscape/systems/detection_manager.lua:268`
- **Code:** `-- TODO: Replace with province graph pathfinding when World system exists`
- **Impact:** 🟠 MEDIUM - Pathfinding simplified
- **Context:** UFO movement should use province connectivity
- **Task Recommendation:** Depends on `TASK-GSD` (World system)
- **Effort Estimate:** 2-3 hours (after World system)

```lua
-- Line 268
-- TODO: Replace with province graph pathfinding when World system exists
```

---

## 🟡 MEDIUM PRIORITY TODOs (FEATURE COMPLETION)

### Economy Systems

**17. Manufacturing - Inventory Integration (1/3)**
- **File:** `engine/economy/production/manufacturing_system.lua:197`
- **Code:** `-- TODO: Integrate with actual inventory system`
- **Impact:** 🟡 MEDIUM - Incomplete workflow
- **Context:** Manufacturing output not stored in base inventory
- **Task Recommendation:** Create `TASK-ECO-001-inventory-integration.md`
- **Effort Estimate:** 2-3 hours

```lua
-- Line 197
-- TODO: Integrate with actual inventory system
```

---

**18. Manufacturing - Inventory Integration (2/3)**
- **File:** `engine/economy/production/manufacturing_system.lua:205`
- **Code:** `-- TODO: Integrate with actual inventory system`
- **Impact:** 🟡 MEDIUM - Same as #17
- **Context:** Duplicate of above TODO

```lua
-- Line 205
-- TODO: Integrate with actual inventory system
```

---

**19. Manufacturing - Research Integration**
- **File:** `engine/economy/production/manufacturing_system.lua:212`
- **Code:** `-- TODO: Integrate with research system`
- **Impact:** 🟡 MEDIUM - Unlock system incomplete
- **Context:** Cannot check if items are researched before manufacturing
- **Task Recommendation:** Create `TASK-ECO-002-research-unlock.md`
- **Effort Estimate:** 1-2 hours

```lua
-- Line 212
-- TODO: Integrate with research system
```

---

**20. Manufacturing - Material Refund**
- **File:** `engine/economy/production/manufacturing_system.lua:298`
- **Code:** `-- TODO: Implement material refund logic`
- **Impact:** 🟡 MEDIUM - Edge case handling
- **Context:** Canceling projects doesn't refund materials
- **Task Recommendation:** Create `TASK-ECO-003-refund-logic.md`
- **Effort Estimate:** 1-2 hours

```lua
-- Line 298
-- TODO: Implement material refund logic
```

---

**21. Marketplace - Credit Check**
- **File:** `engine/economy/marketplace/marketplace_system.lua:162`
- **Code:** `-- TODO: Check if player has enough credits`
- **Impact:** 🟡 MEDIUM - Missing validation
- **Context:** Can't verify purchase affordability
- **Task Recommendation:** Create `TASK-ECO-004-purchase-validation.md`
- **Effort Estimate:** 1 hour

```lua
-- Line 162
-- TODO: Check if player has enough credits
```

---

**22. Marketplace - Item Addition**
- **File:** `engine/economy/marketplace/marketplace_system.lua:220`
- **Code:** `-- TODO: Add items to base inventory`
- **Impact:** 🟡 MEDIUM - Purchased items not stored
- **Context:** After purchase, items disappear
- **Task Recommendation:** Part of `TASK-ECO-001` (inventory integration)
- **Effort Estimate:** 1-2 hours

```lua
-- Line 220
-- TODO: Add items to base inventory
```

---

**23. Marketplace - Research Integration**
- **File:** `engine/economy/marketplace/marketplace_system.lua:334`
- **Code:** `-- TODO: Integrate with research system`
- **Impact:** 🟡 MEDIUM - Same as #19
- **Context:** Cannot check research unlock for marketplace items
- **Task Recommendation:** Part of `TASK-ECO-002` (research integration)
- **Effort Estimate:** 1 hour

```lua
-- Line 334
-- TODO: Integrate with research system
```

---

### Base Management

**24. Base Research Check**
- **File:** `engine/basescape/logic/base.lua:175`
- **Code:** `-- TODO: Check research system`
- **Impact:** 🟡 MEDIUM - Missing validation
- **Context:** Cannot verify research is available
- **Task Recommendation:** Create `TASK-BASE-001-research-check.md`
- **Effort Estimate:** 1 hour

```lua
-- Line 175
-- TODO: Check research system
```

---

**25. Facility Maintenance System**
- **File:** `engine/basescape/logic/base.lua:270`
- **Code:** `-- TODO: Facilities should go offline due to lack of maintenance`
- **Impact:** 🟡 MEDIUM - Consequence system incomplete
- **Context:** Neglecting maintenance has no effect
- **Task Recommendation:** Create `TASK-BASE-002-maintenance-system.md`
- **Effort Estimate:** 2-3 hours

```lua
-- Line 270
-- TODO: Facilities should go offline due to lack of maintenance
```

---

### Battle Results

**26. Destroyed Object Tracking**
- **File:** `engine/battlescape/logic/mission_result.lua:90`
- **Code:** `result.propertyPenalty = 0  -- TODO: track destroyed objects`
- **Impact:** 🟡 MEDIUM - Consequences incomplete
- **Context:** Destroyed property doesn't affect score/funding
- **Task Recommendation:** Create `TASK-RES-001-damage-tracking.md`
- **Effort Estimate:** 1-2 hours

```lua
-- Line 90
result.propertyPenalty = 0  -- TODO: track destroyed objects
```

---

### Calendar System

**27. Research Project Calendar**
- **File:** `engine/basescape/research/research_project.lua:61`
- **Code:** `project.completedDate = {year = 1, month = 1, day = 1}  -- TODO: use calendar`
- **Impact:** 🟡 MEDIUM - Date tracking placeholder
- **Context:** Completion dates hardcoded
- **Task Recommendation:** Create `TASK-CAL-001-project-calendar.md`
- **Effort Estimate:** 1 hour

```lua
-- Line 61
project.completedDate = {year = 1, month = 1, day = 1}  -- TODO: use calendar
```

---

**28. Manufacturing Project Calendar**
- **File:** `engine/basescape/logic/manufacturing_project.lua:68`
- **Code:** `project.completedDate = {year = 1, month = 1, day = 1}  -- TODO: use calendar`
- **Impact:** 🟡 MEDIUM - Same as #27
- **Context:** Duplicate of above TODO

```lua
-- Line 68
project.completedDate = {year = 1, month = 1, day = 1}  -- TODO: use calendar
```

---

### Salvage System

**29. Salvage Inventory Integration**
- **File:** `engine/battlescape/logic/salvage_processor.lua:150`
- **Code:** `-- TODO: Add to base inventory`
- **Impact:** 🟡 MEDIUM - Salvage lost after mission
- **Context:** Collected items don't transfer to base
- **Task Recommendation:** Part of `TASK-ECO-001` (inventory integration)
- **Effort Estimate:** 1-2 hours

```lua
-- Line 150
-- TODO: Add to base inventory
```

---

## 🟢 LOW PRIORITY TODOs (POLISH/OPTIMIZATION)

### Objectives System

**30. Sector Control Checking**
- **File:** `engine/battlescape/battlefield/objectives_system.lua:192`
- **Code:** `-- TODO: Implement sector control checking`
- **Impact:** 🟢 LOW - Optional gameplay feature
- **Context:** Sector control objective not functional
- **Task Recommendation:** Create `TASK-OBJ-001-sector-control.md`
- **Effort Estimate:** 2-3 hours

```lua
-- Line 192
-- TODO: Implement sector control checking
```

---

### Reaction Fire

**31. Reaction Animation Interrupt**
- **File:** `engine/battlescape/systems/reaction_fire_system.lua:258`
- **Code:** `-- TODO: Add interrupt/pause for reaction animation`
- **Impact:** 🟢 LOW - Animation polish
- **Context:** Reaction attacks play without pause/reaction
- **Task Recommendation:** Create `TASK-ANI-001-reaction-animation.md`
- **Effort Estimate:** 1-2 hours

```lua
-- Line 258
-- TODO: Add interrupt/pause for reaction animation
```

---

### Sound Detection

**32. Sound Detection Turn Tracking (1/2)**
- **File:** `engine/battlescape/systems/sound_detection_system.lua:102`
- **Code:** `turn = 0, -- TODO: Get from turn manager`
- **Impact:** 🟢 LOW - Data accuracy
- **Context:** Turn tracking hardcoded to 0
- **Task Recommendation:** Create `TASK-SND-001-turn-tracking.md`
- **Effort Estimate:** 1 hour

```lua
-- Line 102
turn = 0, -- TODO: Get from turn manager
```

---

**33. Sound Detection Turn Tracking (2/2)**
- **File:** `engine/battlescape/systems/sound_detection_system.lua:291`
- **Code:** `local currentTurn = 0 -- TODO: Get from turn manager`
- **Impact:** 🟢 LOW - Same as #32
- **Context:** Duplicate of above TODO

```lua
-- Line 291
local currentTurn = 0 -- TODO: Get from turn manager
```

---

## 📋 Task Creation Recommendations

### Group 1: CRITICAL ABILITY IMPLEMENTATIONS (Start Immediately)
- `TASK-ABS-001-turret-ability.md` (3-4h)
- `TASK-ABS-002-marked-status.md` (2-3h)
- `TASK-ABS-003-suppression-status.md` (2-3h)
- `TASK-ABS-004-fortify-status.md` (2-3h)
- `TASK-GEN-001-team-placement.md` (3-4h)
- **Subtotal: 12-17 hours** - ENABLES COMPLETE COMBAT

### Group 2: RENDERING & PHYSICS (After Group 1)
- `TASK-REN-001-3d-map-integration.md` (4-5h)
- `TASK-REN-002-unit-sprite-rendering.md` (3-4h)
- `TASK-THR-001-throwable-physics.md` (2-3h)
- `TASK-THR-002-stun-effect.md` (1-2h)
- `TASK-THR-003-emp-effect.md` (2-3h)
- **Subtotal: 12-17 hours** - ENHANCES COMBAT EXPERIENCE

### Group 3: ECONOMY INTEGRATION (Parallel with Group 2)
- `TASK-ECO-001-inventory-integration.md` (2-3h)
- `TASK-ECO-002-research-unlock.md` (1-2h)
- `TASK-ECO-003-refund-logic.md` (1-2h)
- `TASK-ECO-004-purchase-validation.md` (1h)
- `TASK-BASE-001-research-check.md` (1h)
- `TASK-BASE-002-maintenance-system.md` (2-3h)
- **Subtotal: 8-12 hours** - COMPLETES ECONOMY LOOPS

### Group 4: CAMPAIGN INTEGRATION (Blocked by Framework Tasks)
Depends on `TASK-CLS`, `TASK-GSD` being implemented first
- Campaign manager TODOs (7-9h total, after FactionManager)
- Detection system TODOs (4-6h total, after World system)

### Group 5: POLISH & OPTIMIZATION (After Core Features)
- Calendar system (2h total)
- Sector control (2-3h)
- Reaction animation (1-2h)
- Sound detection turn tracking (1h)
- **Subtotal: 6-8 hours**

---

## 🔄 Cross-References to Task Management

### Mapped to Existing Tasks

| TODO | Existing Task | Status |
|------|---------------|--------|
| Abilities (turret, marked, suppression, fortify) | TASK-PGS (battle features) | ✅ Mapped |
| Team placement | TASK-GEN-001 | 🆕 Create |
| 3D rendering | TASK-REN-001 | 🆕 Create |
| Campaign integration | TASK-CLS | ⏳ Blocked by framework |
| Detection system | TASK-GSD | ⏳ Blocked by framework |
| Economy integration | TASK-ECO-001 | 🆕 Create |

### New Tasks to Create (HIGH PRIORITY)

1. TASK-ABS-001 through TASK-ABS-004 (Ability implementations)
2. TASK-GEN-001 (Team placement)
3. TASK-REN-001 and TASK-REN-002 (Rendering)
4. TASK-THR-001 through TASK-THR-003 (Throwables)
5. TASK-ECO-001 through TASK-ECO-004 (Economy)
6. TASK-BASE-001 through TASK-BASE-002 (Base)

---

## 🎯 Conclusion

**Total Work Identified:** 32 TODOs across 17 files
**Critical Path:** 12-17 hours (Abilities + Team Placement)
**Full Implementation:** 40-60 hours (all groups 1-3)
**Framework-Blocked:** 11-15 hours (groups 4)
**Polish:** 6-8 hours (group 5)

**Recommendation:** Start with Group 1 (Abilities) immediately - these are blocking core combat gameplay. Run game tests after each task completion to ensure stability.

---

**Document Created:** October 23, 2025
**Status:** ✅ READY FOR TASK CREATION
**Next Step:** Create detailed task files from recommendations above
