# Mission System Features - Visual Workflow Guide

**Date:** October 13, 2025  
**Related Tasks:** TASK-029, TASK-030  
**Total Implementation Time:** 108 hours (13.5 days)

---

## Complete Mission Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                         GEOSCAPE                                  │
│                                                                   │
│  Player selects mission from map                                 │
│  • Mission type (Site/UFO/Base)                                  │
│  • Location (Urban/Forest/Desert)                                │
│  • Difficulty rating                                             │
│  • Intel: Enemy type, civilian presence                          │
│                                                                   │
│                    [Launch Mission] ───────────┐                 │
└────────────────────────────────────────────────┼─────────────────┘
                                                  │
                                                  ▼
┌──────────────────────────────────────────────────────────────────┐
│              DEPLOYMENT PLANNING SCREEN (NEW)                     │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Map Grid Visualization (4×4 to 7×7 MapBlocks)          │    │
│  │                                                          │    │
│  │    [LZ] ← Landing Zone (Green)                           │    │
│  │    [O]  ← Objective Block (Yellow/Red/Blue)             │    │
│  │    [ ]  ← Empty MapBlock                                 │    │
│  │                                                          │    │
│  │  Example 5×5 Map:                                        │    │
│  │  [LZ] [ ] [ ] [ ] [ ]                                    │    │
│  │  [ ] [O] [ ] [ ] [ ]                                     │    │
│  │  [ ] [ ] [ ] [O] [ ]                                     │    │
│  │  [ ] [ ] [ ] [ ] [ ]                                     │    │
│  │  [ ] [ ] [ ] [ ] [LZ]                                    │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  Unit Roster:          Landing Zone Assignment:                 │
│  ☐ Soldier Alpha       LZ1 (NW): Soldier Alpha, Soldier Bravo   │
│  ☐ Soldier Bravo       LZ2 (SE): Soldier Charlie, Soldier Delta│
│  ☐ Soldier Charlie                                               │
│  ☐ Soldier Delta       [Assign Selected Unit to LZ]             │
│                                                                   │
│  [Cancel] ────────────────────────── [Start Battle] ────────┐   │
└─────────────────────────────────────────────────────────────┼───┘
                                                               │
                                                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                        BATTLESCAPE                                │
│                                                                   │
│  Turn-Based Tactical Combat                                      │
│  • Units spawn at assigned landing zones                         │
│  • Objectives visible on map                                     │
│  • Concealment budget tracked                                    │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Concealment Budget HUD:                                 │    │
│  │  ┌──────────────────────┐                                │    │
│  │  │ Budget: 1450/3000    │ ← Real-time tracking          │    │
│  │  │ [████████████░░░░]   │                                │    │
│  │  │ Status: COVERT       │                                │    │
│  │  └──────────────────────┘                                │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  Budget Consumption:                                             │
│  • Firearm shot: -1                                              │
│  • Grenade: -10                                                  │
│  • Explosion: -25                                                │
│  • Civilian death: -20 (×2 in urban)                             │
│                                                                   │
│  Combat continues until:                                         │
│  • All enemies eliminated (Victory)                              │
│  • All player units dead (Defeat)                                │
│  • Player retreats to landing zones (Tactical Defeat)            │
│  • Concealment budget exceeded (Covert Mission Failure)          │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                        │                    │
                        │                    │
                    Victory              Defeat
                        │                    │
                        ▼                    ▼
┌─────────────────────────────┐  ┌─────────────────────────────┐
│    SALVAGE SCREEN           │  │    DEFEAT SCREEN            │
│         (Victory)            │  │                             │
│                              │  │  Mission Failed             │
│  Mission Score: 1200         │  │  Score: -500                │
│  ├─ Base: 1000               │  │                             │
│  ├─ Objectives: +500         │  │  Units Lost (outside LZ):   │
│  ├─ Speed: +100              │  │  • Soldier Charlie          │
│  ├─ Civilians: -300          │  │  • Soldier Delta            │
│  └─ Concealment: -100        │  │                             │
│                              │  │  Units Survived (in LZ):    │
│  ┌────────────────────────┐ │  │  • Soldier Alpha            │
│  │ SALVAGE COLLECTED:     │ │  │  • Soldier Bravo            │
│  │                        │ │  │                             │
│  │ Corpses:               │ │  │  No salvage collected       │
│  │ • Sectoid × 8          │ │  │  No items recovered         │
│  │ • Floater × 4          │ │  │                             │
│  │                        │ │  │  Experience: 50 XP/survivor │
│  │ Items:                 │ │  │                             │
│  │ • Plasma Rifle × 5     │ │  │                             │
│  │ • Alien Grenade × 3    │ │  │  [Return to Base]           │
│  │                        │ │  └─────────────────────────────┘
│  │ Special:               │ │               │
│  │ • UFO Alloys × 50      │ │               │
│  │ • Elerium-115 × 20     │ │               │
│  │                        │ │               │
│  │ Casualties:            │ │               │
│  │ • Soldier Echo (KIA)   │ │               │
│  │   ⮡ Equipment returned │ │               │
│  └────────────────────────┘ │               │
│                              │               │
│  [Continue to Base]          │               │
└──────────────────────────────┘               │
            │                                   │
            └───────────────┬───────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│                         BASESCAPE                                 │
│                                                                   │
│  Salvage transferred to base inventory:                          │
│  • Corpses stored (available for research)                       │
│  • Items stored (available for manufacture/use)                  │
│  • Special salvage stored (research requirements)                │
│  • Ally casualties removed from roster                           │
│  • Survivors gain experience and medals                          │
│  • Mission score affects country relations                       │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Base Inventory Updated:                                 │    │
│  │                                                          │    │
│  │  [Alien Corpses]                                         │    │
│  │  • Sectoid Corpse: 8 (+8) ← NEW                          │    │
│  │  • Floater Corpse: 4 (+4) ← NEW                          │    │
│  │                                                          │    │
│  │  [Alien Weapons]                                         │    │
│  │  • Plasma Rifle: 12 (+5) ← NEW                           │    │
│  │  • Alien Grenade: 15 (+3) ← NEW                          │    │
│  │                                                          │    │
│  │  [Special Materials]                                     │    │
│  │  • UFO Alloys: 150 (+50) ← NEW                           │    │
│  │  • Elerium-115: 20 (+20) ← NEW                           │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  Next: Research, Manufacture, or return to Geoscape              │
│                                                                   │
│  [Return to Geoscape] ──────────────────────────────────────┐    │
└─────────────────────────────────────────────────────────────┼────┘
                                                               │
                                                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                     GEOSCAPE (Post-Mission)                       │
│                                                                   │
│  Mission complete, changes applied:                              │
│  • Country relations updated (based on score)                    │
│  • Funding adjusted (if relations changed)                       │
│  • Unit roster updated (casualties removed)                      │
│  • New research options (from corpses)                           │
│  • Campaign continues...                                         │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Map Size & Landing Zone Matrix

```
┌────────────┬────────────┬─────────────┬────────────┬──────────────┐
│  Map Size  │ Grid Size  │ Total Tiles │ LZ Count   │ Complexity   │
├────────────┼────────────┼─────────────┼────────────┼──────────────┤
│   Small    │   4 × 4    │  60 × 60    │     1      │     Low      │
│            │ MapBlocks  │   tiles     │            │              │
├────────────┼────────────┼─────────────┼────────────┼──────────────┤
│   Medium   │   5 × 5    │  75 × 75    │     2      │    Medium    │
│            │ MapBlocks  │   tiles     │            │              │
├────────────┼────────────┼─────────────┼────────────┼──────────────┤
│   Large    │   6 × 6    │  90 × 90    │     3      │     High     │
│            │ MapBlocks  │   tiles     │            │              │
├────────────┼────────────┼─────────────┼────────────┼──────────────┤
│   Huge     │   7 × 7    │ 105 × 105   │     4      │   Very High  │
│            │ MapBlocks  │   tiles     │            │              │
└────────────┴────────────┴─────────────┴────────────┴──────────────┘

Note: Each MapBlock = 15 × 15 tiles
```

---

## Concealment Budget Scale

```
┌───────────────────┬──────────────┬──────────────────────────┐
│   Mission Type    │    Budget    │        Failure Mode      │
├───────────────────┼──────────────┼──────────────────────────┤
│  Normal/Forest    │   100,000    │  Effectively unlimited   │
│  (No witnesses)   │              │  No concealment concern  │
├───────────────────┼──────────────┼──────────────────────────┤
│  Public/Urban     │  1,000-5,000 │  Heavy score penalty     │
│  (Many witnesses) │              │  Relations damage        │
├───────────────────┼──────────────┼──────────────────────────┤
│  Covert Operation │    50-500    │  Immediate mission fail  │
│  (Must be secret) │              │  Complete loss           │
└───────────────────┴──────────────┴──────────────────────────┘

Budget Consumption Rate:
┌──────────────────┬──────────┬────────────────────────────┐
│      Action      │   Cost   │          Notes             │
├──────────────────┼──────────┼────────────────────────────┤
│  Firearm Shot    │    1     │  Suppressed = 0.5          │
│  Grenade Blast   │   10     │  Flashbang = 5             │
│  Rocket/Explosive│   25     │  Large explosion           │
│  Mass Destruction│   50     │  Building collapse         │
│  Civilian Death  │   20     │  ×2 in public mission      │
└──────────────────┴──────────┴────────────────────────────┘

Example Covert Mission (Budget: 200):
• 10 silenced shots = 5 budget ✓
• 1 grenade = 10 budget ✓
• 2 rocket = 50 budget ✓
• 5 more shots = 5 budget ✓
• Total: 70 budget used (130 remaining) ✓

Example Blown Cover:
• 20 shots = 20 budget
• 5 grenades = 50 budget
• 1 rocket = 25 budget
• Kill 1 civilian = 20 budget
• Another rocket = 25 budget
• 10 more shots = 10 budget
• Total: 150 budget → Mission Compromised! ✗
```

---

## Salvage Conversion Chart

```
┌─────────────────────────────────────────────────────────────────┐
│                      ENEMY UNIT SALVAGE                          │
├─────────────────────────────────────────────────────────────────┤
│  Enemy Killed → Corpse Item + All Equipment                     │
│                                                                  │
│  Sectoid (killed)   → Corpse_Sectoid + Plasma Pistol + Grenade │
│  Floater (killed)   → Corpse_Floater + Plasma Rifle            │
│  Muton (killed)     → Corpse_Muton + Heavy Plasma + Grenade    │
│  Cyberdisk (killed) → Corpse_Cyberdisk + Alien Alloys (parts)  │
│                                                                  │
│  Enemy Captured → No corpse (live specimen) + All Equipment    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     SPECIAL OBJECT SALVAGE                       │
├─────────────────────────────────────────────────────────────────┤
│  UFO Wall Section (destroyed) → UFO Alloys (5-10)               │
│  Elerium Engine (destroyed)   → Elerium-115 (10-20)             │
│                                 + UFO Power Source (1)           │
│  Alien Computer (destroyed)   → Alien Data Core (1)             │
│  Navigation Console (intact)  → UFO Navigation (1)              │
│                                 + Elerium-115 (5)                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      ALLY CASUALTY SALVAGE                       │
├─────────────────────────────────────────────────────────────────┤
│  Dead Ally → Corpse_Human + All Equipment Returned              │
│                                                                  │
│  Soldier Echo (KIA)  → Corpse_Human                             │
│                        + Assault Rifle                           │
│                        + Frag Grenade × 2                        │
│                        + Medkit                                  │
│                        + Personal Armor                          │
│                                                                  │
│  Note: Allies can be buried/memorialized at base                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Mission Score Breakdown Example

```
┌─────────────────────────────────────────────────────────────────┐
│            MISSION SCORE: URBAN TERROR SITE                      │
├─────────────────────────────────────────────────────────────────┤
│  Base Components:                                                │
│  ✓ Mission Completed               +1,000                       │
│  ✓ Objective 1: Secure Area        +  250                       │
│  ✓ Objective 2: Rescue Civilians   +  250                       │
│  ✗ Objective 3: Capture Leader     +    0 (failed)              │
│                                    ──────                        │
│  Base Score:                        1,500                        │
│                                                                  │
│  Performance Bonuses:                                            │
│  ✓ Speed (16 turns, under 20)      +  100                       │
│  ✓ No ally casualties               +  200                       │
│  ✗ Accuracy >75% (67%)              +    0                       │
│                                    ──────                        │
│  Bonus Score:                       +  300                       │
│                                                                  │
│  Penalties (×2 for urban):                                       │
│  ✗ 3 Civilians Killed (-100 each)   -  600 (×2 = -600)          │
│  ✗ 1 Neutral Killed (-50)           -  100 (×2 = -100)          │
│  ✗ Property Destruction (-10×15)    -  300 (×2 = -300)          │
│  ✗ Concealment Blown (-200)         -  400 (×2 = -400)          │
│                                    ──────                        │
│  Penalty Score:                     -1,400                       │
│                                                                  │
│  ═════════════════════════════════════════                       │
│  TOTAL MISSION SCORE:                  400                       │
│  ═════════════════════════════════════════                       │
│                                                                  │
│  Impact on Campaign:                                             │
│  • Country Relations: +2 (mission success)                       │
│  • Country Relations: -5 (high civilian casualties)              │
│  • Net Relations Change: -3 (relations worsened)                 │
│  • Monthly Funding: -10% next month                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Defeat Scenarios Visualized

### Scenario 1: Total Defeat (All Units Die)
```
Before Retreat:
┌─────────────────────────┐
│ [LZ]  [ ]  [ ]  [ ]  [ ]│
│  ✓    X    X    X    X  │ ✓ = In LZ, X = Outside LZ
│  ✓                      │
│ [LZ]                    │
└─────────────────────────┘

All units dead → Total defeat
• Lost: All units
• Survived: None
• Salvage: None
• Score: Heavy negative penalty
```

### Scenario 2: Tactical Retreat (Some Survive)
```
Before Retreat:
┌─────────────────────────┐
│ [LZ]  [ ]  [ ]  [ ]  [ ]│
│  A    X    X            │ A = Soldier Alpha (in LZ)
│  B              X    X  │ B = Soldier Bravo (in LZ)
│ [LZ]                    │ C,D,E,F = Outside LZ (lost)
└─────────────────────────┘

Retreat to landing zones:
• Lost: Soldiers C, D, E, F (outside LZ)
• Survived: Soldiers A, B (in LZ)
• Salvage: None (defeat)
• Score: Moderate negative penalty
• Experience: 50 XP for survivors
```

### Scenario 3: Victory with Casualties
```
After Victory:
┌─────────────────────────┐
│ [LZ]  [ ]  [ ]  [ ]  [ ]│
│  A    ☠    D    E       │ A,D,E = Survived
│  B                   F  │ B,F = Survived
│ [LZ]                    │ C = KIA (☠)
└─────────────────────────┘

Mission success:
• Lost: Soldier C (KIA)
• Survived: A, B, D, E, F
• Salvage: Full collection
• Corpse: Soldier C → Human Corpse + Equipment
• Score: Positive with small penalty
• Experience: Full XP for survivors, bonus for objectives
```

---

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT PHASE                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
                  DeploymentConfig
                  ┌───────────────┐
                  │ • missionId   │
                  │ • mapSize     │
                  │ • landingZones│ ──┐
                  │ • objectives  │   │
                  │ • unitRoster  │   │
                  └───────────────┘   │
                         │            │
                         ▼            │
┌─────────────────────────────────────┼───────────────────────────┐
│                  BATTLE PHASE       │                            │
└────────────────────────┬────────────┼────────────────────────────┘
                         │            │
                         ▼            │
                  Battlefield         │
                  ┌───────────────┐   │
                  │ • units       │   │
                  │ • terrain     │   │
                  │ • objectives  │   │
                  │ • turn count  │   │
                  └───────────────┘   │
                         │            │
                         │            │
           ┌─────────────┴────────┐   │
           │                      │   │
           ▼                      ▼   │
       Victory                Defeat  │
           │                      │   │
           │                      │   │
           ▼                      ▼   │
    SalvageCollector     DefeatProcessor
    ┌───────────────┐    ┌───────────────┐
    │ • scan field  │    │ • check LZs   │◄┘ Uses landing zones
    │ • corpses     │    │ • lost units  │   from deployment
    │ • items       │    │ • survivors   │
    │ • special     │    │ • no salvage  │
    └───────────────┘    └───────────────┘
           │                      │
           │                      │
           └──────────┬───────────┘
                      ▼
                MissionScorer
                ┌───────────────┐
                │ • base score  │
                │ • bonuses     │
                │ • penalties   │
                │ • total       │
                └───────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                   SALVAGE SCREEN                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
                  MissionResult
                  ┌───────────────┐
                  │ • victory     │
                  │ • score       │
                  │ • salvage     │
                  │ • casualties  │
                  │ • survivors   │
                  └───────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                     BASESCAPE                                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
                  BaseInventory
                  ┌───────────────┐
                  │ • add corpses │
                  │ • add items   │
                  │ • add special │
                  │ • save()      │
                  └───────────────┘
                         │
                         ▼
                    UnitRoster
                  ┌───────────────┐
                  │ • remove KIA  │
                  │ • add XP      │
                  │ • add medals  │
                  └───────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GEOSCAPE                                    │
│  Campaign continues with updated state                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Priority Matrix

```
┌──────────────┬─────────────────────┬──────────┬──────────────┐
│   Feature    │      Importance     │ Effort   │   Priority   │
├──────────────┼─────────────────────┼──────────┼──────────────┤
│  Deployment  │  High (Strategic)   │   54h    │      1       │
│  Planning    │  New game state     │  6 days  │  Start First │
├──────────────┼─────────────────────┼──────────┼──────────────┤
│  Salvage     │  Critical (Rewards) │   50h    │      2       │
│  System      │  Core gameplay loop │ 6.25 days│  After #1    │
├──────────────┼─────────────────────┼──────────┼──────────────┤
│  Concealment │  Medium (Depth)     │   8h     │      3       │
│  Budget      │  Optional feature   │  1 day   │  Integrated  │
└──────────────┴─────────────────────┴──────────┴──────────────┘

Recommended Implementation Order:
1. TASK-029 Phases 1-3 (24h) - Core deployment system
2. TASK-030 Phases 1-2 (12h) - Core salvage system
3. TASK-029 Phases 4-5 (20h) - Deployment UI + Integration
4. TASK-030 Phases 3-4 (16h) - Scoring + Salvage UI
5. TASK-029 Phases 6-7 (10h) - State flow + Testing
6. TASK-030 Phases 5-6 (14h) - Inventory + Concealment
7. TASK-030 Phase 7 (8h) - Integration testing
Total: 104 hours (13 days)
```

---

## Success Metrics

### Player Experience Metrics
```
✓ Deployment feels strategic and meaningful
✓ Landing zone selection has tactical impact
✓ Mission intel helps planning
✓ Victory rewards feel satisfying
✓ Defeat consequences feel fair but harsh
✓ Concealment adds tension to covert missions
✓ Scoring system is transparent and understandable
✓ Salvage drives research progression
```

### Technical Metrics
```
✓ Zero console errors/warnings
✓ Smooth state transitions (<100ms)
✓ UI responsive to input (<16ms frame time)
✓ Salvage collection completes in <1 second
✓ All data structures properly serialized
✓ No memory leaks after mission cycle
✓ Grid snapping perfect (no off-pixel rendering)
```

### Gameplay Metrics
```
✓ 100% of enemy corpses collected (victory)
✓ 100% of items collected (victory)
✓ Landing zone survival check 100% accurate (defeat)
✓ Score calculation matches manual verification
✓ Concealment budget tracking error-free
✓ Base inventory updated correctly every mission
✓ Unit roster updated correctly (KIA/survivors)
```

---

## Risk Mitigation Strategies

### High Risk: State Transition Bugs
**Mitigation:**
- Comprehensive state machine testing
- Fallback states for error recovery
- State persistence for debugging
- Console logging for all transitions

### Medium Risk: Salvage Collection Errors
**Mitigation:**
- Unit testing for all collection scenarios
- Edge case handling (empty battlefield, no enemies)
- Verification pass after collection
- Debug mode to visualize collection

### Medium Risk: Landing Zone Detection False Negatives
**Mitigation:**
- Clear MapBlock boundary definitions
- Visual debug overlay for landing zones
- Unit position logging at defeat time
- Manual verification tests

### Low Risk: Performance Degradation
**Mitigation:**
- Efficient collection algorithms (single pass)
- Object pooling for UI elements
- Lazy loading for salvage screen
- Profiling during testing phase

---

*Generated: October 13, 2025*  
*Tasks: TASK-029, TASK-030*  
*Total Estimated Time: 108 hours (13.5 days)*  
*Status: Ready for Implementation*
