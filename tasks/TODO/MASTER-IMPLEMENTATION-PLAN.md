# MASTER IMPLEMENTATION PLAN
## AlienFall Development Roadmap - Optimized for Quality and Integration

**Created:** October 13, 2025  
**Last Updated:** October 13, 2025  
**Status:** Active Planning Document

---

## Executive Summary

This master plan organizes all 36 tasks in the TODO backlog into 6 functional categories and provides an optimized implementation order that:
- **Minimizes dependencies** and blockers
- **Maximizes parallel development** opportunities
- **Builds stable foundations** before advanced features
- **Enables incremental testing** at each milestone
- **Prioritizes core gameplay loops** over polish

**Total Estimated Time:** ~520-650 hours (13-16 weeks for solo developer, 6-8 weeks with small team)

---

## Task Organization Overview

### Folder Structure

```
tasks/TODO/
├── 01-BATTLESCAPE/          (10 tasks) - Tactical combat layer
├── 02-GEOSCAPE/             (16 tasks) - Strategic world management
├── 03-BASESCAPE/            (4 tasks)  - Base management
├── 04-INTERCEPTION/         (1 task)   - Craft interception
├── 05-ECONOMY/              (4 tasks)  - Economic systems
└── 06-DOCUMENTATION/        (7 docs)   - Reference materials
```

### Task Categories

**01-BATTLESCAPE (10 tasks):**
- 3D rendering system (3 tasks)
- Combat mechanics (4 tasks)
- Map generation (1 task)
- Battle objectives (1 task)
- Hex tactical combat (1 task)

**02-GEOSCAPE (16 files):**
- Master implementation (1 task)
- Lore/campaign systems (2 tasks)
- Mission systems (3 tasks)
- Relations system (1 task)
- Documentation (9 reference docs)

**03-BASESCAPE (4 tasks):**
- Facility system (1 task)
- Research system (1 task)
- Manufacturing system (1 task)
- Unit recovery/progression (1 task)

**04-INTERCEPTION (1 task):**
- Interception screen (1 task)

**05-ECONOMY (4 tasks):**
- Marketplace/suppliers (1 task)
- Black market (1 task)
- Fame/karma/reputation (1 task)
- Economy master plan (1 doc)

**06-DOCUMENTATION (7 docs):**
- Engine restructure references
- Map generation guides
- Implementation summaries

---

## PHASE 1: FOUNDATION SYSTEMS (Weeks 1-3)
### Goal: Establish core strategic layer and connect game modes

**Priority:** CRITICAL - Nothing else works without these foundations

### 1.1 Geoscape Core (Week 1) - 80 hours
**Task:** `02-GEOSCAPE/TASK-025-geoscape-master-implementation.md`

**Why First?**
- Central hub connecting ALL game modes
- Required for mission spawning, craft deployment, time progression
- Dependencies: Calendar system, world map, province graph, hex pathfinding

**Deliverables:**
- [ ] 80×40 hex world map (500km/tile)
- [ ] Province graph with biomes
- [ ] Hex pathfinding for craft travel
- [ ] Calendar system (1 turn = 1 day)
- [ ] Basic UI (world view, province info, craft deployment)
- [ ] Integration with existing state manager

**Test:** Can navigate world, see provinces, advance time

---

### 1.2 Map Generation System (Week 2) - 60 hours
**Task:** `01-BATTLESCAPE/TASK-031-map-generation-system.md`

**Why Second?**
- Bridges Geoscape (strategic) → Battlescape (tactical)
- Required before any tactical missions can be played
- Dependencies: Geoscape biomes, existing MapBlock system

**Deliverables:**
- [ ] Biome → Terrain → MapScript → MapBlock pipeline
- [ ] Procedural battlefield generation (4×4 to 7×7)
- [ ] Team placement algorithm (player, ally, enemy, neutral)
- [ ] MapBlock transformations (rotation, mirroring)
- [ ] Integration with existing battlescape

**Test:** Launch mission from Geoscape, get procedurally generated battlefield

---

### 1.3 Mission Detection & Campaign Loop (Week 3) - 45 hours
**Task:** `02-GEOSCAPE/TASK-027-mission-detection-campaign-loop.md`

**Why Third?**
- Connects Geoscape time progression to mission spawning
- Creates the core gameplay loop: time → missions → deployment → battle → results
- Dependencies: Geoscape calendar, map generation

**Deliverables:**
- [ ] Mission detection system (daily checks per province)
- [ ] Mission spawning with types (site investigation, UFO crash, base defense, etc.)
- [ ] Mission urgency/expiration timers
- [ ] Campaign state tracking (score, victories, defeats)
- [ ] Mission reward system integration

**Test:** Advance time, missions spawn, can select and deploy to mission

---

### 🎯 PHASE 1 MILESTONE: Core Gameplay Loop Functional
**Total Time:** 185 hours (3 weeks)  
**Validation:** Can start game → see world → advance time → missions spawn → deploy → fight on generated battlefield

---

## PHASE 2: BASESCAPE MANAGEMENT (Weeks 4-5)
### Goal: Add strategic depth through base building and resource management

**Priority:** HIGH - Required for economy and progression systems

### 2.1 Basescape Facility System (Week 4) - 50 hours
**Task:** `03-BASESCAPE/TASK-029-basescape-facility-system.md`

**Why First in Phase?**
- Foundation for all other basescape systems
- Provides capacity system (items, units, crafts, etc.)
- Required by research/manufacturing
- Dependencies: Geoscape calendar (for build times)

**Deliverables:**
- [ ] 5×5 facility grid with mandatory HQ
- [ ] Facility construction with build queue
- [ ] Capacity aggregation system
- [ ] Service system (power, fuel, etc.)
- [ ] Maintenance costs (monthly)
- [ ] Inter-base transfers
- [ ] Base defense facility integration

**Test:** Build facilities, see construction progress over days, check capacities

---

### 2.2 Mission Deployment Planning Screen (Week 4-5) - 35 hours
**Task:** `02-GEOSCAPE/TASK-029-mission-deployment-planning-screen.md`

**Why Second?**
- Requires base system (select units/craft from base)
- Improves mission deployment UX before expanding mission types
- Dependencies: Basescape facilities, Geoscape missions

**Deliverables:**
- [ ] Craft selection with range visualization
- [ ] Unit/item loadout interface
- [ ] Fuel/supply calculations
- [ ] Deployment confirmation and validation
- [ ] Integration with mission system

**Test:** Select mission, choose craft, load units/items, validate and deploy

---

### 2.3 Research System (Week 5) - 40 hours
**Task:** `03-BASESCAPE/TASK-032-research-system.md`

**Why Third?**
- Enables tech progression
- Unlocks new facilities, units, items, crafts
- Dependencies: Basescape facilities (research capacity)

**Deliverables:**
- [ ] Research project definitions
- [ ] Research queue with prerequisites
- [ ] Scientist assignment
- [ ] Daily research progress
- [ ] Tech tree visualization
- [ ] Unlock notifications

**Test:** Start research project, assign scientists, advance days, complete research

---

### 🎯 PHASE 2 MILESTONE: Strategic Management Functional
**Total Time:** 125 hours (2 weeks)  
**Validation:** Can build bases → assign researchers → progress tech tree → deploy missions with custom loadouts

---

## PHASE 3: COMBAT DEPTH (Weeks 6-7)
### Goal: Enhance tactical combat with new mechanics and objectives

**Priority:** HIGH - Adds replayability and tactical complexity

### 3.1 Battle Objectives System (Week 6) - 40 hours
**Task:** `01-BATTLESCAPE/TASK-030-battle-objectives-system.md`

**Why First in Phase?**
- Framework for mission variety (not just "kill all enemies")
- Required for advanced mission types
- Dependencies: Existing battlescape, map generation

**Deliverables:**
- [ ] Objective types (kill, capture, rescue, defend, retrieve, escape, etc.)
- [ ] Objective tracking and UI
- [ ] Victory/defeat conditions
- [ ] Multi-objective missions
- [ ] Time-based objectives

**Test:** Mission with objectives (e.g., "Rescue VIP + Escape"), track progress, win/lose

---

### 3.2 Mission Salvage, Victory, Defeat (Week 6-7) - 35 hours
**Task:** `02-GEOSCAPE/TASK-030-mission-salvage-victory-defeat.md`

**Why Second?**
- Completes mission loop: deploy → fight → resolve → rewards
- Required for economy integration
- Dependencies: Battle objectives, existing battlescape

**Deliverables:**
- [ ] Victory/defeat detection
- [ ] Salvage collection from battlefield
- [ ] Unit casualties and injuries
- [ ] Mission scoring and rewards
- [ ] Campaign impact (country relations, funding)
- [ ] Post-mission summary screen

**Test:** Win mission, collect salvage, return to base, see rewards and casualties

---

### 3.3 Weapon Modes System (Week 7) - 30 hours
**Task:** `01-BATTLESCAPE/TASK-018-weapon-modes-system.md`

**Why Third?**
- Adds tactical depth to combat
- Simple enhancement with high impact
- Dependencies: Existing weapon system

**Deliverables:**
- [ ] Multiple fire modes per weapon (auto, burst, snap, aimed)
- [ ] Mode-specific stats (TU cost, accuracy, damage)
- [ ] Mode selection UI
- [ ] Animation/audio per mode

**Test:** Weapon with 3 modes, switch modes, fire, observe differences

---

### 🎯 PHASE 3 MILESTONE: Rich Tactical Combat
**Total Time:** 105 hours (2 weeks)  
**Validation:** Missions have objectives → complete objectives → collect salvage → earn rewards → weapon variety

---

## PHASE 4: 3D BATTLESCAPE (Weeks 8-10)
### Goal: Revolutionary first-person 3D tactical view

**Priority:** MEDIUM-HIGH - Major feature, high wow factor

### 4.1 3D Core Rendering (Week 8) - 80 hours
**Task:** `01-BATTLESCAPE/TASK-026-3d-battlescape-core-rendering.md`

**Why First in Phase?**
- Foundation for all 3D features
- Independent from other Phase 4 tasks
- Can be developed in parallel with other phases

**Deliverables:**
- [ ] First-person camera from unit position
- [ ] Hex raycasting (6-sided, not 4)
- [ ] Floor, wall, ceiling rendering
- [ ] Distance-based fog
- [ ] Day/night sky rendering
- [ ] Toggle 2D/3D with SPACE key
- [ ] Integration with existing tile data

**Test:** Enter battlescape, press SPACE, see first-person 3D view, toggle back to 2D

---

### 4.2 3D Unit Interaction (Week 9) - 90 hours
**Task:** `01-BATTLESCAPE/TASK-027-3d-battlescape-unit-interaction.md`

**Why Second?**
- Makes 3D view playable, not just pretty
- Dependencies: 3D core rendering

**Deliverables:**
- [ ] Billboard unit sprites (always face camera)
- [ ] WASD hex movement (W=forward, S=back, A/D=rotate 60°)
- [ ] Animated movement/rotation (200ms)
- [ ] Mouse picking (tiles, walls, units, items)
- [ ] Ground item rendering
- [ ] Minimap in 3D mode
- [ ] TAB to switch units
- [ ] Same GUI as 2D mode

**Test:** Move unit with WASD, rotate with A/D, pick up item, switch units with TAB

---

### 4.3 3D Effects & Advanced Features (Week 10) - 100 hours
**Task:** `01-BATTLESCAPE/TASK-028-3d-battlescape-effects-advanced.md`

**Why Third?**
- Completes 3D battlescape feature parity with 2D
- Dependencies: 3D core + unit interaction

**Deliverables:**
- [ ] Animated fire effects (billboard sprites)
- [ ] Semi-transparent smoke
- [ ] Object billboards (trees, tables, fences)
- [ ] LOS/FOW enforcement (only render visible)
- [ ] Day/night visibility ranges
- [ ] Right-click shooting with feedback
- [ ] Muzzle flash, bullet tracers
- [ ] Explosion animations
- [ ] Z-sorting for proper layering
- [ ] Full combat system integration

**Test:** See fire/smoke, shoot enemies in 3D, see muzzle flash and tracers, explosions work

---

### 🎯 PHASE 4 MILESTONE: 3D Battlescape Feature Complete
**Total Time:** 270 hours (3 weeks)  
**Validation:** Full tactical combat playable in 3D first-person view with feature parity to 2D mode

---

## PHASE 5: ADVANCED COMBAT MECHANICS (Weeks 11-12)
### Goal: Deep tactical systems for hardcore players

**Priority:** MEDIUM - Polish and depth, not critical path

### 5.1 Damage Models System (Week 11) - 35 hours
**Task:** `01-BATTLESCAPE/TASK-017-damage-models-system.md`

**Why First in Phase?**
- Foundation for advanced combat
- Used by critical hits and psionics
- Dependencies: Existing combat system

**Deliverables:**
- [ ] Multiple damage types (kinetic, explosive, fire, chemical, plasma, psionic, etc.)
- [ ] Armor resistance per damage type
- [ ] Damage calculation pipeline
- [ ] Status effects (fire, poison, stun)

**Test:** Fire kinetic vs fire vs explosive damage, observe different effects on armored targets

---

### 5.2 Enhanced Critical Hits (Week 11) - 30 hours
**Task:** `01-BATTLESCAPE/TASK-020-enhanced-critical-hits.md`

**Why Second?**
- Adds excitement and unpredictability
- Dependencies: Damage models

**Deliverables:**
- [ ] Critical hit calculation (luck, weapon stats)
- [ ] Critical effects (extra damage, armor bypass, wound, stun, instant kill)
- [ ] Critical feedback (animation, sound, UI)

**Test:** Shoot repeatedly, observe crits with special effects

---

### 5.3 Psionics System (Week 12) - 45 hours
**Task:** `01-BATTLESCAPE/TASK-019-psionics-system.md`

**Why Third?**
- Unique tactical option
- Dependencies: Damage models, existing action system

**Deliverables:**
- [ ] Psi stats (strength, defense, skill)
- [ ] Psi powers (mind control, panic, fear, confusion, psi blast, etc.)
- [ ] Psi LOS and range calculation
- [ ] Psi action costs (TU, psi points)
- [ ] Psi resistance and defense
- [ ] Visual effects and feedback

**Test:** Use psi unit, panic enemy, mind control enemy, use psi blast

---

### 🎯 PHASE 5 MILESTONE: Advanced Combat Systems
**Total Time:** 110 hours (2 weeks)  
**Validation:** Damage types matter → crits happen with special effects → psionic powers work

---

## PHASE 6: ECONOMY & PROGRESSION (Weeks 13-14)
### Goal: Long-term strategic depth and player agency

**Priority:** MEDIUM - Important for campaign longevity

### 6.1 Manufacturing System (Week 13) - 40 hours
**Task:** `03-BASESCAPE/TASK-033-manufacturing-system.md`

**Why First in Phase?**
- Enables player-driven equipment production
- Dependencies: Basescape facilities, research system

**Deliverables:**
- [ ] Manufacturing project definitions
- [ ] Manufacturing queue with prerequisites
- [ ] Engineer assignment
- [ ] Daily manufacturing progress
- [ ] Resource consumption
- [ ] Manufactured item delivery

**Test:** Research item, start manufacturing, assign engineers, advance days, receive items

---

### 6.2 Marketplace & Supplier System (Week 13-14) - 50 hours
**Task:** `05-ECONOMY/TASK-034-marketplace-supplier-system.md`

**Why Second?**
- Primary economy interface for buying/selling
- Dependencies: Geoscape regions, basescape facilities

**Deliverables:**
- [ ] Regional marketplaces with supply/demand
- [ ] Supplier system with reputation
- [ ] Buy/sell interface with pricing
- [ ] Delivery times and costs
- [ ] Market price fluctuations
- [ ] Integration with base storage

**Test:** Open marketplace, buy items, wait for delivery, sell salvage

---

### 6.3 Unit Recovery & Progression (Week 14) - 35 hours
**Task:** `03-BASESCAPE/TASK-026-unit-recovery-progression-system.md`

**Why Third?**
- Adds RPG-like progression to units
- Makes units more valuable and player attached
- Dependencies: Basescape facilities, existing unit system

**Deliverables:**
- [ ] Injury system (wounds, recovery time)
- [ ] Sanity/morale system
- [ ] Experience and leveling
- [ ] Stat improvements on level up
- [ ] Recovery facilities (infirmary, psych ward)
- [ ] Unit history tracking

**Test:** Unit gets wounded in battle, recovers over days, gains experience, levels up

---

### 🎯 PHASE 6 MILESTONE: Economy & Progression Systems
**Total Time:** 125 hours (2 weeks)  
**Validation:** Can manufacture items → trade in marketplace → units progress and recover

---

## PHASE 7: STRATEGIC DEPTH (Weeks 15-16)
### Goal: Diplomacy, lore, and advanced strategic features

**Priority:** MEDIUM-LOW - Polish and immersion, not critical path

### 7.1 Relations System (Week 15) - 40 hours
**Task:** `02-GEOSCAPE/TASK-026-relations-system.md`

**Why First in Phase?**
- Foundation for diplomacy and politics
- Dependencies: Geoscape countries

**Deliverables:**
- [ ] Country relations tracking
- [ ] Faction system
- [ ] Diplomatic actions
- [ ] Relations impact on funding and missions
- [ ] Events affecting relations

**Test:** Complete mission, see country relations improve, funding increases

---

### 7.2 Lore & Campaign System (Week 15-16) - 50 hours
**Task:** `02-GEOSCAPE/TASK-026-geoscape-lore-campaign-system.md`

**Why Second?**
- Adds narrative framework
- Dependencies: Geoscape, mission system

**Deliverables:**
- [ ] Campaign stage progression
- [ ] Lore events and story beats
- [ ] Scripted missions
- [ ] Cutscenes or story panels
- [ ] Campaign victory conditions

**Test:** Play campaign, trigger story events, progress through campaign stages

---

### 7.3 Fame, Karma, Reputation System (Week 16) - 40 hours
**Task:** `05-ECONOMY/TASK-036-fame-karma-reputation-system.md`

**Why Third?**
- Meta-progression system
- Dependencies: Mission system, economy

**Deliverables:**
- [ ] Fame tracking (global reputation)
- [ ] Karma system (moral choices)
- [ ] Reputation per faction/country
- [ ] Fame/karma effects on missions and economy
- [ ] Public opinion system

**Test:** Complete missions, gain fame, make moral choices, see karma effects

---

### 🎯 PHASE 7 MILESTONE: Strategic Depth Complete
**Total Time:** 130 hours (2 weeks)  
**Validation:** Countries have relations → campaign has story → fame/karma affect gameplay

---

## PHASE 8: FINAL SYSTEMS (Week 17+)
### Goal: Complete remaining features for 1.0 release

**Priority:** VARIES - Mix of important and nice-to-have

### 8.1 Interception Screen (1-2 days) - 30 hours
**Task:** `04-INTERCEPTION/TASK-028-interception-screen.md`

**Why Priority?**
- Connects Geoscape craft deployment to tactical combat
- Required for UFO interception gameplay loop

**Deliverables:**
- [ ] Turn-based interception minigame
- [ ] Craft vs craft combat
- [ ] Weapon selection and firing
- [ ] Damage and escape mechanics

**Test:** Intercept UFO, engage in turn-based combat, shoot down or escape

---

### 8.2 Black Market System (2-3 days) - 35 hours
**Task:** `05-ECONOMY/TASK-035-black-market-system.md`

**Why Priority?**
- Alternative economy route
- Moral choice system

**Deliverables:**
- [ ] Black market contacts
- [ ] Illegal items and services
- [ ] Risk/reward system
- [ ] Law enforcement consequences

**Test:** Access black market, buy illegal items, face consequences

---

### 8.3 Hex Tactical Combat Master Plan (Week 18+) - TBD
**Task:** `01-BATTLESCAPE/TASK-016-hex-tactical-combat-master-plan.md`

**Why Last?**
- Major architectural change (square → hex)
- Non-critical if square grid works well
- Should be evaluated after Phase 1-7 complete

**Decision Point:** Assess if hex conversion is worth the effort vs. polish/content

---

### 🎯 PHASE 8 MILESTONE: Feature Complete for 1.0
**Total Time:** 65+ hours  
**Validation:** All core systems implemented, game is playable end-to-end

---

## Implementation Order Summary

### Critical Path (Minimum Viable Game)
1. ✅ **Geoscape Core** (Week 1) - World map, time, provinces
2. ✅ **Map Generation** (Week 2) - Procedural battlefields
3. ✅ **Mission Loop** (Week 3) - Detection, spawning, deployment
4. ✅ **Base Facilities** (Week 4) - Construction, capacity
5. ✅ **Battle Objectives** (Week 6) - Mission variety
6. ✅ **Mission Resolution** (Week 6-7) - Salvage, rewards

**Total Critical Path:** ~385 hours (6-7 weeks)

### High-Value Features (Maximum Impact)
7. ✅ **3D Battlescape** (Weeks 8-10) - Revolutionary feature
8. ✅ **Research System** (Week 5) - Tech progression
9. ✅ **Manufacturing** (Week 13) - Player-driven production
10. ✅ **Marketplace** (Week 13-14) - Economy depth

**Total with High-Value:** ~650 hours (10-11 weeks)

### Polish & Depth (For 1.0 Quality)
11. Weapon Modes (Week 7)
12. Damage Models (Week 11)
13. Critical Hits (Week 11)
14. Psionics (Week 12)
15. Unit Progression (Week 14)
16. Relations System (Week 15)
17. Campaign/Lore (Week 15-16)
18. Fame/Karma (Week 16)

**Total for Feature Complete:** ~1040 hours (16-17 weeks)

---

## Parallel Development Opportunities

### Can Work Simultaneously (No Dependencies)

**Track A: Strategic Layer**
- Geoscape → Mission System → Relations → Lore/Campaign
- Owner: Developer 1

**Track B: Tactical Layer**
- Map Generation → Battle Objectives → Weapon Modes → Damage Models
- Owner: Developer 2

**Track C: 3D Rendering**
- 3D Core → 3D Units → 3D Effects
- Owner: Developer 3 (can start after Week 1)

**Track D: Base Systems**
- Facilities → Research → Manufacturing → Unit Recovery
- Owner: Developer 4 (can start after Week 1)

**Track E: Economy**
- Marketplace → Black Market → Fame/Karma
- Owner: Developer 5 (can start after Week 5)

**Result:** With 5 developers, ~16 weeks solo becomes ~5-6 weeks parallel

---

## Quality Assurance Checkpoints

### After Each Phase
1. **Playtest:** Complete a full gameplay loop using new features
2. **Performance:** Check for frame drops, memory leaks (lovec console)
3. **Integration:** Verify new features work with existing systems
4. **Documentation:** Update API.md, FAQ.md, DEVELOPMENT.md
5. **Refactor:** Clean up code, remove debug prints, optimize

### Milestone Validation
- **Phase 1:** Can play a complete mission from start to finish
- **Phase 2:** Can build base and deploy custom loadouts
- **Phase 3:** Missions feel varied and tactical
- **Phase 4:** 3D mode is playable and fun
- **Phase 5:** Combat has depth and variety
- **Phase 6:** Economy feels balanced and meaningful
- **Phase 7:** Strategic layer has long-term goals
- **Phase 8:** Game is feature complete

---

## Risk Mitigation

### High-Risk Tasks
1. **3D Battlescape** (270 hours) - Complex rendering, hex raycasting
   - **Mitigation:** Prototype early, use g3d library, test frequently
   
2. **Map Generation** (60 hours) - Procedural generation bugs
   - **Mitigation:** Start with simple cases, add complexity gradually
   
3. **Geoscape Core** (80 hours) - Many interconnected systems
   - **Mitigation:** Build in layers, test each subsystem independently

### Dependency Chains
- **Geoscape → Everything** - If Geoscape is delayed, entire schedule shifts
  - **Mitigation:** Prioritize Geoscape, allocate best developer, test early
  
- **Map Generation → Tactical Combat** - Can't playtest missions without maps
  - **Mitigation:** Use simple test maps during Phase 1, complete map gen ASAP
  
- **Base Facilities → Research/Manufacturing** - Economy blocked without bases
  - **Mitigation:** Create minimal base system first, expand later

### Scope Creep Prevention
- **Hex Combat:** Defer to Phase 8+ (or never if square grid works)
- **Black Market:** Optional feature, can be cut for 1.0
- **Lore/Campaign:** Can be expanded post-1.0 with content updates
- **Psionics:** Optional system, can be simplified or cut

---

## Success Metrics

### Phase 1 Complete
- [ ] Can advance time and generate missions
- [ ] Can deploy to mission with generated battlefield
- [ ] Core gameplay loop functional (even if minimal)

### Phase 2 Complete
- [ ] Can build base facilities and manage resources
- [ ] Can research tech and unlock new content
- [ ] Strategic layer has depth

### Phase 3 Complete
- [ ] Missions have variety (objectives, enemies, maps)
- [ ] Combat feels tactical and rewarding
- [ ] Salvage and rewards system motivates continued play

### Phase 4 Complete
- [ ] 3D mode is playable and impressive
- [ ] Can complete full mission in 3D view
- [ ] Toggle between 2D/3D seamlessly

### Phase 5-7 Complete
- [ ] Combat has deep tactical options
- [ ] Economy is balanced and engaging
- [ ] Strategic layer has long-term goals

### Phase 8 Complete (1.0 Ready)
- [ ] All core features implemented
- [ ] Game is stable and polished
- [ ] Documentation is complete
- [ ] Ready for public release

---

## Next Steps

### Immediate Actions
1. **Review this plan** with team/stakeholders
2. **Assign tasks** to developers based on skills
3. **Set up project tracking** (update tasks.md weekly)
4. **Begin Phase 1** with Geoscape core implementation
5. **Establish testing routine** (daily lovec console checks)

### Weekly Cadence
- **Monday:** Review progress, update tasks.md, plan week
- **Wednesday:** Mid-week check-in, address blockers
- **Friday:** Playtest new features, document issues
- **Sunday:** Prepare next week's tasks, update this plan

### Monthly Review
- Assess progress vs. timeline
- Adjust priorities based on discoveries
- Update time estimates based on actual velocity
- Celebrate completed phases!

---

## Appendix: Task Cross-Reference

### By Priority
**CRITICAL:**
- TASK-025: Geoscape Master Implementation
- TASK-031: Map Generation System
- TASK-027: Mission Detection & Campaign Loop
- TASK-029: Basescape Facility System

**HIGH:**
- TASK-026/027/028: 3D Battlescape (all 3 phases)
- TASK-030: Battle Objectives System
- TASK-030: Mission Salvage/Victory/Defeat
- TASK-032: Research System
- TASK-033: Manufacturing System

**MEDIUM:**
- TASK-017/018/019/020: Combat Mechanics (damage, modes, psionics, crits)
- TASK-026: Unit Recovery & Progression
- TASK-034: Marketplace & Suppliers
- TASK-026: Relations System
- TASK-026: Lore & Campaign System
- TASK-028: Interception Screen

**LOW:**
- TASK-035: Black Market System
- TASK-036: Fame/Karma/Reputation
- TASK-016: Hex Tactical Combat (deferred)

### By Dependencies
**No Dependencies (Can Start Anytime):**
- TASK-026: 3D Battlescape Core Rendering
- TASK-034: Marketplace & Suppliers (needs geoscape regions)
- TASK-017: Damage Models System

**Depends on Geoscape:**
- TASK-031: Map Generation (needs biomes)
- TASK-027: Mission Detection (needs calendar)
- TASK-029: Mission Deployment Planning (needs crafts)
- TASK-026: Relations System (needs countries)
- TASK-026: Lore & Campaign (needs mission system)

**Depends on Basescape:**
- TASK-032: Research System (needs facilities)
- TASK-033: Manufacturing System (needs facilities)
- TASK-026: Unit Recovery (needs facilities)

**Depends on Other Tasks:**
- TASK-027: 3D Unit Interaction (needs TASK-026 3D Core)
- TASK-028: 3D Effects (needs TASK-027 3D Units)
- TASK-020: Enhanced Crits (needs TASK-017 Damage Models)
- TASK-019: Psionics (needs TASK-017 Damage Models)
- TASK-030: Mission Salvage (needs Battle Objectives)

---

## Document History

**Version 1.0** (October 13, 2025)
- Initial master plan created
- Organized 36 tasks into 6 categories
- Defined 8-phase implementation roadmap
- Estimated 520-650 hours total (13-16 weeks solo)

**Next Review:** After Phase 1 completion (Week 3)

---

## Contact & Feedback

This is a living document. Update after:
- Phase completions
- Major discoveries during implementation
- Timeline adjustments
- Scope changes

Always keep `tasks/tasks.md` in sync with this master plan.

---

**END OF MASTER PLAN**
