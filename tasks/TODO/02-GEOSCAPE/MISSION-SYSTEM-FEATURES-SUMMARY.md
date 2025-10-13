# Three-Feature Implementation Plan Summary

**Date:** October 13, 2025  
**Feature Group:** Mission System Enhancements  
**Total Estimated Time:** 108 hours (13.5 days)

---

## Overview

This document summarizes the implementation plan for three interconnected mission system features that will significantly enhance the tactical gameplay loop:

1. **Mission Deployment & Planning Screen** (TASK-029)
2. **Mission Salvage & Victory/Defeat Resolution** (TASK-030)
3. **Concealment Budget System** (Integrated into TASK-030)

---

## Feature 1: Mission Deployment & Planning Screen (TASK-029)

### Summary
Pre-battle planning screen where players assign units to multiple landing zones based on map size (small=1, medium=2, large=3, huge=4). Shows tactical information about objective sectors before combat.

### Key Points
- **Map Sizes:** 4×4, 5×5, 6×6, 7×7 MapBlock grids (each MapBlock = 15×15 tiles)
- **Landing Zones:** 1-4 zones depending on map size
- **Strategic Info:** Shows which MapBlocks contain objectives (defend/capture/critical)
- **Unit Assignment:** Drag-and-drop or list-based unit placement
- **Similar To:** Sudden Strike pre-mission planning panel

### Implementation Phases
1. Data structures & MapBlock metadata (6h)
2. Landing zone selection algorithm (8h)
3. Deployment planning game state (10h)
4. Deployment planning UI (12h)
5. Battlescape integration (8h)
6. State transition flow (4h)
7. Testing & validation (6h)

**Total Time:** 54 hours (6.75 days)

### Technical Requirements
- New game state: `deployment_planning`
- MapBlock metadata for objectives
- Landing zone selection algorithm
- Grid-based UI (24×24 pixel grid)
- State flow: Geoscape → Deployment → Battlescape

### Benefits
- Strategic depth through multi-point deployment
- Tactical foresight with objective visibility
- Scales naturally with mission difficulty
- Classic tactical game feel

---

## Feature 2: Mission Salvage & Victory/Defeat Resolution (TASK-030)

### Summary
Complete post-battle salvage system with different outcomes for victory vs defeat. Includes mission scoring with penalties for civilian casualties and property destruction.

### Key Points - Victory
- All enemy corpses → race-specific items (e.g., "Dead Sectoid")
- All enemy equipment collected (weapons, items)
- Ally casualties → corpse + equipment returned
- Special salvage from objects (UFO walls → alloys, elerium engines)
- Medals awarded for objectives
- Experience gained by survivors
- Full mission score calculated

### Key Points - Defeat
- Units outside landing zones lost permanently
- Units inside landing zones survive and return
- **No salvage collected** (total loss)
- **No corpses or items** obtained
- Experience still awarded (encourages learning)
- Negative mission score

### Key Points - Scoring
- Base score + objective bonuses
- Speed bonus (turn count)
- Civilian death penalty (higher in public missions)
- Neutral death penalty
- Property destruction penalty (public only)
- Public missions have 2× penalty multiplier

### Implementation Phases
1. Salvage data structures (4h)
2. Salvage collection system (8h)
3. Mission scoring system (6h)
4. Salvage screen UI (10h)
5. Base inventory integration (6h)
6. Concealment budget system (8h)
7. Integration & testing (8h)

**Total Time:** 50 hours (6.25 days)

### Technical Requirements
- Post-battle salvage state/screen
- Item collection from battlefield
- Corpse generation system
- Base inventory integration
- Landing zone boundary checking
- Mission scoring algorithm
- Concealment budget tracking

### Benefits
- Tangible rewards for victory
- Meaningful consequences for defeat
- Risk/reward balance (retreat vs. push)
- Drives research/manufacturing loop
- Penalizes careless tactics

---

## Feature 3: Concealment Budget System (Integrated into TASK-030)

### Summary
Stealth/publicity mechanic where missions have concealment budgets. Exceeding the budget can cause mission failure (covert ops) or heavy score penalties (public missions).

### Key Points
- **Mission Types:**
  - Normal: 100000 budget (effectively unlimited)
  - Covert: 50-500 budget (must stay quiet)
  - Public/Urban: 1000-5000 budget (witnesses matter)

- **Budget Consumption:**
  - Firearm shot: 1 point
  - Grenade explosion: 10 points
  - Rocket/explosive: 25 points
  - Large explosion: 50 points
  - Mass destruction: 100 points
  - Civilian death: 20 points (extra)

- **Public Mission Effects:**
  - Forest mission: No witnesses, high concealment budget
  - Urban mission: Many witnesses, low concealment budget
  - Civilian death in city: 2× score penalty
  - Property destruction visible to public
  - Lower concealment budget = harder stealth

- **Consequences:**
  - Covert mission budget exceeded = **automatic failure**
  - Public mission budget exceeded = **heavy score penalty** (-1000+)
  - Urban violence = **reputation damage**

### Implementation
Integrated into TASK-030 Phase 6 (8 hours)

### Technical Requirements
- ConcealmentTracker system
- Action cost table
- Public/private mission distinction
- Budget consumption hooks in combat
- Mission failure trigger
- Score penalty system

### Benefits
- Adds tactical depth (stealth vs. loud)
- Differentiates mission types
- Encourages careful tactics in cities
- Realistic consequences for public violence
- Strategic weapon selection matters

---

## Feature Integration & Dependencies

### Dependency Chain
```
TASK-029 (Deployment) → TASK-030 (Salvage)
         ↓                       ↓
   Landing Zones  ←──────  Defeat Survival Check
                            Concealment Budget
```

### Integration Points

1. **Deployment → Salvage:**
   - Landing zones determine unit survival on defeat
   - Deployment config passed to battlescape
   - Defeat checks unit positions vs. landing zones

2. **Salvage → Deployment:**
   - Map size (from deployment) affects salvage quantity
   - Objective blocks affect salvage types
   - Mission type affects concealment budget

3. **Concealment → Both:**
   - Mission location (urban/forest) set during deployment
   - Concealment budget affects salvage score
   - Public missions affect both deployment (intel) and salvage (penalties)

### Combined Workflow
```
1. Geoscape: Select mission
2. Deployment Planning: Assign units to landing zones, see objectives
3. Battlescape: Combat with concealment tracking
4. Victory/Defeat: Check landing zones for survival
5. Salvage Screen: Collect loot, calculate score (with concealment penalties)
6. Base: Receive salvage, update roster
7. Geoscape: Return with consequences
```

---

## Implementation Timeline

### Phase 1: Foundation (Week 1 - 40 hours)
- **TASK-029 Phases 1-3:** Data structures, algorithms, game state
- **TASK-030 Phases 1-2:** Salvage data structures, collection system
- **Result:** Core systems operational

### Phase 2: UI & Integration (Week 2 - 38 hours)
- **TASK-029 Phases 4-5:** Deployment UI, battlescape integration
- **TASK-030 Phases 3-4:** Mission scoring, salvage UI
- **Result:** Visual systems complete

### Phase 3: Advanced Features (Week 3 - 22 hours)
- **TASK-029 Phases 6-7:** State transitions, testing
- **TASK-030 Phases 5-6:** Inventory integration, concealment system
- **Result:** All features implemented

### Phase 4: Testing & Polish (Week 4 - 8 hours)
- **TASK-030 Phase 7:** Integration testing
- **Both tasks:** Cross-feature testing
- **Result:** Production-ready system

**Total Timeline:** ~3.5 weeks (108 hours)

---

## Testing Strategy

### Critical Test Scenarios

**Scenario 1: Covert Urban Mission**
- Small map (4×4) with 1 landing zone
- Low concealment budget (200 points)
- Objective: Extract VIP without alerting enemies
- Test: Silent takedowns OK, firearms blow cover
- Expected: Budget management critical, stealth tactics required

**Scenario 2: Large Public Mission**
- Large map (6×6) with 3 landing zones
- Medium concealment budget (3000 points)
- Civilians present, property destructible
- Test: Heavy weapons cause public outcry
- Expected: Civilian deaths = 2× penalty, property damage tracked

**Scenario 3: Victory with Full Salvage**
- Medium map (5×5) with 2 landing zones
- Kill all enemies, no civilian casualties
- Test: Collect all corpses, items, special salvage
- Expected: All loot in base inventory, high score

**Scenario 4: Tactical Defeat**
- Huge map (7×7) with 4 landing zones
- Units spread across map, mission goes bad
- Test: Retreat to landing zones, abandon forward units
- Expected: Units in zones survive, others lost, no salvage

**Scenario 5: Special Salvage Mission**
- UFO crash site with elerium engine
- Destroy UFO components for salvage
- Test: Destroy engine → elerium salvage
- Expected: Elerium in inventory, can research

### Integration Tests
- Deployment → Battlescape unit spawning
- Battlescape → Salvage collection
- Salvage → Base inventory transfer
- Concealment budget → Mission score
- Landing zones → Defeat survival
- All state transitions smooth

---

## Data Requirements

### New Data Files Needed

**Items:**
```toml
# data/items/corpses.toml
[corpse_sectoid]
name = "Sectoid Corpse"
type = "corpse"
race = "sectoid"
research_value = 10
storage_size = 2
sale_value = 5000

[corpse_floater]
name = "Floater Corpse"
type = "corpse"
race = "floater"
research_value = 15
storage_size = 3
sale_value = 7000
```

**Special Salvage:**
```toml
# data/salvage/special_objects.toml
[ufo_wall_section]
salvage = [
    {item = "ufo_alloys", min = 5, max = 10}
]

[elerium_engine]
salvage = [
    {item = "elerium_115", min = 10, max = 20},
    {item = "ufo_power_source", quantity = 1}
]
```

**Mission Config:**
```toml
# data/missions/concealment.toml
[mission_types.covert]
concealment_budget = 200
failure_on_exceed = true

[mission_types.public]
concealment_budget = 3000
failure_on_exceed = false
publicity_multiplier = 2.0

[mission_types.normal]
concealment_budget = 100000
publicity_multiplier = 1.0
```

---

## UI Mockups

### Deployment Planning Screen
```
┌──────────────────────────────────────────┐
│ Mission: Sectoid Terror  Map Size: Large │
├──────────────────────────────────────────┤
│                                           │
│  ┌─────────────────┐                     │
│  │ MapBlock Grid   │   Unit Roster       │
│  │ [6×6 grid]      │   • Soldier 1       │
│  │                 │   • Soldier 2       │
│  │ LZ = Green      │   • Soldier 3       │
│  │ Obj = Yellow    │   • Soldier 4       │
│  └─────────────────┘                     │
│                                           │
│ LZ1: [2 units] LZ2: [1 unit] LZ3: [1]   │
├──────────────────────────────────────────┤
│ [Cancel]                  [Start Battle] │
└──────────────────────────────────────────┘
```

### Salvage Screen
```
┌──────────────────────────────────────────┐
│        MISSION COMPLETE - VICTORY        │
├──────────────────────────────────────────┤
│ Score: 1200                              │
│ Base: 1000 | Objectives: +500           │
│ Speed: +100 | Civilians: -300           │
├──────────────────────────────────────────┤
│ SALVAGE COLLECTED:                       │
│                                           │
│ Corpses:              Items:              │
│ • Sectoid × 8         • Plasma Rifle × 5 │
│ • Floater × 4         • Alien Grenade ×3│
│                                           │
│ Special:              Casualties:         │
│ • UFO Alloys × 50     • Soldier 3 (KIA) │
│ • Elerium-115 × 20    • 5 survived      │
│                                           │
├──────────────────────────────────────────┤
│                       [Continue to Base] │
└──────────────────────────────────────────┘
```

### Concealment HUD (During Battle)
```
┌─────────────────────┐
│ Concealment: 450/500 │ ← Budget remaining
│ [████████░░] 90%     │ ← Visual bar
│ Status: COVERT       │ ← Mission type
└─────────────────────┘
```

---

## Documentation Updates Required

### Wiki Files
- [ ] `wiki/API.md` - All new APIs documented
- [ ] `wiki/FAQ.md` - Player guide for new systems
- [ ] `wiki/DEVELOPMENT.md` - Architecture documentation
- [ ] `wiki/wiki/missions.md` - Mission flow updated
- [ ] `wiki/wiki/maps.md` - Landing zone system
- [ ] `wiki/wiki/content.md` - Salvage generation rules

### New Wiki Pages
- [ ] `wiki/wiki/deployment.md` - Deployment system guide
- [ ] `wiki/wiki/salvage.md` - Salvage mechanics guide
- [ ] `wiki/wiki/concealment.md` - Stealth system guide

### Code Documentation
- [ ] All new modules fully commented
- [ ] Function documentation with parameters
- [ ] Usage examples in comments
- [ ] Architecture diagrams in comments

---

## Success Criteria

### TASK-029 Success
✅ Players can assign units to multiple landing zones  
✅ Map overview shows objectives clearly  
✅ Deployment transitions smoothly to battle  
✅ Units spawn at correct positions  
✅ System works with all map sizes  

### TASK-030 Success
✅ Victory collects all salvage correctly  
✅ Defeat applies appropriate losses  
✅ Mission scoring fair and transparent  
✅ Concealment system works as designed  
✅ Base inventory updated correctly  

### Overall Success
✅ All three features integrated seamlessly  
✅ Mission loop complete: Deploy → Battle → Salvage → Base  
✅ Tactical depth significantly increased  
✅ No console errors or warnings  
✅ Performance acceptable (no lag)  
✅ Documentation complete and accurate  

---

## Risk Assessment

### Technical Risks
- **MapBlock system complexity:** Mitigated by existing implementation
- **State transition bugs:** Mitigated by thorough testing
- **Performance with large battlefields:** Mitigated by efficient algorithms
- **UI responsiveness:** Mitigated by grid system and widgets

### Design Risks
- **Landing zone count balance:** Mitigated by testing with different map sizes
- **Concealment budget balance:** Mitigated by configurable values
- **Salvage economy balance:** Mitigated by configurable quantities
- **Score penalties too harsh:** Mitigated by player feedback iteration

### Mitigation Strategies
- Extensive unit testing for all components
- Integration testing for state transitions
- Manual playtesting for balance
- Configurable values for easy tuning
- Console debugging for all systems
- Fallback systems for edge cases

---

## Future Enhancements

### Post-Implementation Ideas
1. **AI-suggested deployments** based on mission intel
2. **Deployment templates** for quick setup
3. **Enemy spawn prediction** shown on deployment map
4. **Time-limited deployment** for added challenge
5. **Equipment loadout selection** in deployment screen
6. **Vehicle deployment** alongside infantry
7. **Salvage quality system** (damaged items)
8. **Black market** for selling salvage
9. **Salvage hauling capacity** limits
10. **Dynamic concealment** based on time of day

### Community Features
- Share deployment strategies
- Leaderboards for mission scores
- Challenge missions with fixed deployment
- Replay system for tactical analysis

---

## Conclusion

These three interconnected features represent a **major enhancement** to AlienFall's tactical gameplay:

1. **Deployment Planning** adds strategic depth pre-battle
2. **Salvage System** provides tangible rewards and consequences
3. **Concealment Budget** encourages tactical variety

Together, they create a complete mission loop that rivals classic X-COM while adding modern gameplay depth.

**Total Implementation Time:** 108 hours (13.5 days)  
**Difficulty:** Medium-High  
**Priority:** High  
**Impact:** Very High - Core gameplay loop

---

**Next Steps:**
1. Review and approve this plan
2. Create task entries in `tasks/tasks.md`
3. Begin Phase 1 implementation (Foundation)
4. Regular testing and iteration
5. Community feedback after Phase 2

---

*Generated: October 13, 2025*  
*Tasks: TASK-029, TASK-030*  
*Status: Ready for Implementation*
