# HEX Grid Tactical Combat - Visual Implementation Guide

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                 ALIEN FALL - HEX GRID TACTICAL COMBAT SYSTEM                 ║
║                            Implementation Roadmap                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────────┐
│                              📚 DOCUMENTATION                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📋 Master Plan (Complete Specification)                                     │
│     → tasks/TODO/TASK-016-hex-tactical-combat-master-plan.md                │
│     • 21 systems detailed breakdown                                         │
│     • Architecture and algorithms                                           │
│     • Testing and performance                                               │
│                                                                              │
│  🎯 Quick Reference (Fast Navigation)                                        │
│     → tasks/HEX_COMBAT_QUICK_REFERENCE.md                                   │
│     • Implementation order                                                   │
│     • File organization                                                      │
│     • Testing requirements                                                   │
│                                                                              │
│  📝 Example Task (Template to Follow)                                        │
│     → tasks/TODO/TASK-016A-pathfinding-system.md                            │
│     • Detailed implementation steps                                          │
│     • Complete code examples                                                 │
│     • Testing strategy                                                       │
│                                                                              │
│  📊 Planning Summary (Overview)                                              │
│     → tasks/HEX_GRID_PLANNING_SUMMARY.md                                    │
│     • Feature coverage                                                       │
│     • Time estimates                                                         │
│     • Success metrics                                                        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                          🎯 IMPLEMENTATION PHASES                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: CORE GRID SYSTEMS (40 hours)                         Priority: 🔥  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016A: Pathfinding with Movement Costs          [16h] 🔥    │             │
│  │   Files: pathfinding.lua, movement_system.lua              │             │
│  │   Tests: test_pathfinding.lua                              │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016B: Distance & Area Calculations             [8h]  ⚡    │             │
│  │   Files: area_math.lua, hex_math.lua (enhance)             │             │
│  │   Tests: test_area_math.lua                                │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016C: Grid Query System                        [8h]  ⚡    │             │
│  │   Files: spatial_query.lua                                 │             │
│  │   Tests: test_spatial_query.lua                            │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016D: Height & Multi-Level Support             [8h]  ⚡    │             │
│  │   Files: height_math.lua, hex_system.lua                   │             │
│  │   Tests: test_height_math.lua                              │             │
│  └────────────────────────────────────────────────────────────┘             │
│                                                                              │
│  ✅ Deliverable: Units pathfind through complex terrain                     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ PHASE 2: LINE OF SIGHT & FIRE (48 hours)                      Priority: 🔥  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016E: Enhanced Line of Sight                   [12h] 🔥    │             │
│  │   Files: vision_system.lua, hex_line.lua                   │             │
│  │   Tests: test_vision_system.lua                            │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016F: Line of Fire System                      [12h] 🔥    │             │
│  │   Files: line_of_fire.lua                                  │             │
│  │   Tests: test_line_of_fire.lua                             │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016G: Cover System                             [12h] ⚡    │             │
│  │   Files: cover_system.lua, terrain_cover_data.lua          │             │
│  │   Tests: test_cover_system.lua                             │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016H: Raycasting System                        [8h]  ⚡    │             │
│  │   Files: raycast.lua                                       │             │
│  │   Tests: test_raycast.lua                                  │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016I: Partial Cover Shooting                   [4h]  💡    │             │
│  │   Files: cover_system.lua, partial_cover_data.lua          │             │
│  │   Tests: test_partial_cover.lua                            │             │
│  └────────────────────────────────────────────────────────────┘             │
│                                                                              │
│  ✅ Deliverable: Complete vision and targeting with cover                   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ PHASE 3: ENVIRONMENTAL EFFECTS (44 hours)                     Priority: ⚡  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016J: Smoke System Enhanced                    [12h] ⚡    │             │
│  │   Files: smoke_system.lua, smoke_cloud.lua                 │             │
│  │   Tests: test_smoke_system.lua                             │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016K: Fire System Enhanced                     [12h] ⚡    │             │
│  │   Files: fire_system.lua, terrain_flammability.lua         │             │
│  │   Tests: test_fire_system.lua                              │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016L: Destructible Terrain                     [12h] ⚡    │             │
│  │   Files: terrain_destruction.lua, terrain_durability.lua   │             │
│  │   Tests: test_terrain_destruction.lua                      │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016M: Explodable Terrain                       [8h]  💡    │             │
│  │   Files: terrain_destruction.lua, explodable_terrain.lua   │             │
│  │   Tests: test_explodable_terrain.lua                       │             │
│  └────────────────────────────────────────────────────────────┘             │
│                                                                              │
│  ✅ Deliverable: Dynamic battlefield with fire, smoke, destruction          │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ PHASE 4: ADVANCED COMBAT (52 hours)                           Priority: 🔥  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016N: Explosion & Area Damage                  [16h] 🔥    │             │
│  │   Files: explosion_system.lua, blast_propagation.lua       │             │
│  │   Tests: test_explosion_system.lua                         │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016O: Shrapnel System                          [12h] ⚡    │             │
│  │   Files: shrapnel_system.lua, shrapnel.lua                 │             │
│  │   Tests: test_shrapnel_system.lua                          │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016P: Beam Weapon System                       [8h]  ⚡    │             │
│  │   Files: beam_weapon.lua, beam_weapons.lua                 │             │
│  │   Tests: test_beam_weapon.lua                              │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016Q: Throwable Trajectory                     [8h]  ⚡    │             │
│  │   Files: trajectory.lua, throwing_system.lua               │             │
│  │   Tests: test_throwing_system.lua                          │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016R: Reaction Fire System                     [8h]  🔥    │             │
│  │   Files: reaction_fire.lua, movement_system.lua            │             │
│  │   Tests: test_reaction_fire.lua                            │             │
│  └────────────────────────────────────────────────────────────┘             │
│                                                                              │
│  ✅ Deliverable: All weapon types functional                                │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ PHASE 5: STEALTH & DETECTION (24 hours)                       Priority: 💡  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016S: Sound System                             [12h] 💡    │             │
│  │   Files: sound_system.lua, sound_event.lua, sound_levels   │             │
│  │   Tests: test_sound_system.lua                             │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016T: Hearing & Detection                      [8h]  💡    │             │
│  │   Files: detection_system.lua, ai_investigation.lua        │             │
│  │   Tests: test_detection_system.lua                         │             │
│  └────────────────────────────────────────────────────────────┘             │
│                           ↓                                                  │
│  ┌────────────────────────────────────────────────────────────┐             │
│  │ 016U: Stealth Mechanics                        [4h]  💡    │             │
│  │   Files: stealth_system.lua                                │             │
│  │   Tests: test_stealth_system.lua                           │             │
│  └────────────────────────────────────────────────────────────┘             │
│                                                                              │
│  ✅ Deliverable: Stealth gameplay with sound detection                      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                       🔧 PARALLEL DEVELOPMENT TRACKS                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

        Track A: Movement          Track B: Vision           Track C: Environment
        ────────────────           ───────────────           ────────────────────
           016A (16h)                 016E (12h)                  016J (12h)
              ↓                          ↓                           ↓
           016C (8h)                  016F (12h)                  016K (12h)
              ↓                          ↓                           ↓
           016D (8h)                  016G (12h)                  016L (12h)
                                         ↓                           ↓
                                      016H (8h)                   016M (8h)
                                         ↓
                                      016I (4h)

        Track D: Weapons           Track E: Stealth
        ────────────────           ────────────────
           016N (16h)                 016S (12h)
              ↓                          ↓
           016O (12h)                 016T (8h)
              ↓                          ↓
           016P (8h)                  016U (4h)
              ↓
           016Q (8h)
              ↓
           016R (8h)


╔══════════════════════════════════════════════════════════════════════════════╗
║                           📊 PROGRESS TRACKING                               ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  Phase 1: Core Grid Systems        [░░░░░░░░░░] 0/4   (0%)   40h remaining  │
│  Phase 2: Line of Sight & Fire     [░░░░░░░░░░] 0/5   (0%)   48h remaining  │
│  Phase 3: Environmental Effects    [░░░░░░░░░░] 0/4   (0%)   44h remaining  │
│  Phase 4: Advanced Combat          [░░░░░░░░░░] 0/5   (0%)   52h remaining  │
│  Phase 5: Stealth & Detection      [░░░░░░░░░░] 0/3   (0%)   24h remaining  │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════    │
│  Total Progress:                   [░░░░░░░░░░] 0/21  (0%)  208h remaining  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                        🎯 QUICK COMMAND REFERENCE                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────────┐
│ RUN GAME                                                                     │
│   lovec "engine"                                                             │
│                                                                              │
│ CREATE NEW TASK                                                              │
│   copy tasks\TASK_TEMPLATE.md tasks\TODO\TASK-016X-name.md                  │
│                                                                              │
│ RUN TESTS                                                                    │
│   lovec "engine" --test test_name                                            │
│                                                                              │
│ DEBUG TOOLS                                                                  │
│   F9  - Toggle hex grid overlay                                             │
│   F12 - Toggle fullscreen                                                   │
│                                                                              │
│ GET TEMP DIRECTORY (Lua)                                                     │
│   local temp = os.getenv("TEMP")                                            │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                         📁 FILE ORGANIZATION                                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

engine/
├── battle/
│   ├── utils/                 ← Pure algorithms, no game state
│   │   ├── hex_math.lua       ✅ DONE - Basic hex math
│   │   ├── pathfinding.lua    ⬜ NEW  - A* pathfinding
│   │   ├── area_math.lua      ⬜ NEW  - Area calculations
│   │   ├── height_math.lua    ⬜ NEW  - Elevation math
│   │   ├── hex_line.lua       ⬜ NEW  - Line algorithms
│   │   ├── raycast.lua        ⬜ NEW  - Ray intersection
│   │   ├── trajectory.lua     ⬜ ENH  - Arc trajectories
│   │   └── blast_propagation.lua ⬜ NEW - Explosion waves
│   │
│   ├── systems/               ← Game logic and state
│   │   ├── hex_system.lua     ✅ DONE - Grid management
│   │   ├── movement_system.lua ⬜ ENH - Add pathfinding
│   │   ├── vision_system.lua  ⬜ ENH  - Enhanced LOS
│   │   ├── spatial_query.lua  ⬜ NEW  - Grid queries
│   │   ├── line_of_fire.lua   ⬜ NEW  - Fire trajectory
│   │   ├── cover_system.lua   ⬜ NEW  - Cover calculation
│   │   ├── smoke_system.lua   ⬜ ENH  - Smoke propagation
│   │   ├── terrain_destruction.lua ⬜ NEW - Destructible terrain
│   │   ├── explosion_system.lua ⬜ ENH - Area damage
│   │   ├── shrapnel_system.lua ⬜ NEW - Shrapnel
│   │   ├── beam_weapon.lua    ⬜ NEW  - Laser weapons
│   │   ├── throwing_system.lua ⬜ NEW - Grenades
│   │   ├── reaction_fire.lua  ⬜ NEW  - Opportunity fire
│   │   ├── sound_system.lua   ⬜ NEW  - Sound events
│   │   ├── detection_system.lua ⬜ NEW - Multi-sensor
│   │   └── stealth_system.lua ⬜ NEW  - Stealth
│   │
│   ├── entities/              ← Entity definitions
│   │   ├── smoke_cloud.lua    ⬜ NEW  - Smoke entity
│   │   ├── shrapnel.lua       ⬜ NEW  - Shrapnel projectile
│   │   └── sound_event.lua    ⬜ NEW  - Sound occurrence
│   │
│   └── tests/                 ← Test files
│       ├── test_pathfinding.lua ⬜ 21 test files total
│       └── ... (more tests)
│
└── data/                      ← Configuration data
    ├── terrain_movement_costs.lua ⬜ NEW
    ├── terrain_cover_data.lua     ⬜ NEW
    ├── partial_cover_data.lua     ⬜ NEW
    ├── terrain_flammability.lua   ⬜ NEW
    ├── terrain_durability.lua     ⬜ NEW
    ├── explodable_terrain.lua     ⬜ NEW
    └── sound_levels.lua           ⬜ NEW

Legend: ✅ Done  ⬜ To Do  🔧 In Progress  ⚡ Enhanced


╔══════════════════════════════════════════════════════════════════════════════╗
║                      ⚡ PERFORMANCE TARGETS                                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌────────────────────────────────────┬──────────┬────────────┬────────────────┐
│ System                             │ Target   │ Critical   │ Status         │
├────────────────────────────────────┼──────────┼────────────┼────────────────┤
│ Pathfinding (30 hexes)             │ < 5ms    │ < 10ms     │ ⬜ Not tested  │
│ LOS (per unit pair)                │ < 1ms    │ < 2ms      │ ⬜ Not tested  │
│ LOF calculation                    │ < 2ms    │ < 5ms      │ ⬜ Not tested  │
│ Explosion (8 hex radius)           │ < 10ms   │ < 20ms     │ ⬜ Not tested  │
│ Sound propagation                  │ < 2ms    │ < 5ms      │ ⬜ Not tested  │
│ Smoke dissipation                  │ < 1ms    │ < 2ms      │ ⬜ Not tested  │
│ Frame rate (20 units + effects)    │ 60 FPS   │ 30 FPS     │ ⬜ Not tested  │
└────────────────────────────────────┴──────────┴────────────┴────────────────┘


╔══════════════════════════════════════════════════════════════════════════════╗
║                         ✅ SUCCESS CHECKLIST                                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

Technical Success
  ⬜ All 21 systems implemented
  ⬜ All unit tests passing
  ⬜ All integration tests passing
  ⬜ Performance targets met
  ⬜ No memory leaks
  ⬜ No console errors

Gameplay Success
  ⬜ Pathfinding works intelligently
  ⬜ Cover provides tactical value
  ⬜ Fire/smoke create dynamic situations
  ⬜ Explosions feel powerful
  ⬜ Stealth is viable
  ⬜ Reaction fire adds tension

Quality Success
  ⬜ Code follows best practices
  ⬜ API documentation complete
  ⬜ FAQ explains mechanics
  ⬜ Developer guide ready
  ⬜ Clean git history


╔══════════════════════════════════════════════════════════════════════════════╗
║                           🚀 NEXT STEPS                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

1. 📖 READ: TASK-016-hex-tactical-combat-master-plan.md (complete spec)
2. 🔍 REVIEW: Existing hex_math.lua and hex_system.lua code
3. 🎯 START: TASK-016A (Pathfinding) - most critical foundation
4. 🧪 TEST: Write tests first (TDD approach)
5. 🔧 IMPLEMENT: Follow detailed task plan
6. 📊 PROFILE: Check performance targets
7. 📝 DOCUMENT: Update API and FAQ
8. ✅ COMPLETE: Mark in tasks.md and move to next


╔══════════════════════════════════════════════════════════════════════════════╗
║              📞 QUESTIONS? CHECK THESE RESOURCES                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

  📋 Master Plan ............ tasks/TODO/TASK-016-hex-tactical-combat-master-plan.md
  🎯 Quick Reference ........ tasks/HEX_COMBAT_QUICK_REFERENCE.md
  📊 Planning Summary ....... tasks/HEX_GRID_PLANNING_SUMMARY.md
  📝 Example Task ........... tasks/TODO/TASK-016A-pathfinding-system.md
  📚 API Documentation ...... wiki/API.md
  ❓ Game FAQ ............... wiki/FAQ.md
  🔧 Dev Guide .............. wiki/DEVELOPMENT.md
  🎮 X-COM Reference ........ https://www.ufopaedia.org/
  🔷 HEX Grid Math .......... https://www.redblobgames.com/grids/hexagons/


╔══════════════════════════════════════════════════════════════════════════════╗
║                      STATUS: READY TO IMPLEMENT ✅                           ║
╚══════════════════════════════════════════════════════════════════════════════╝
```
