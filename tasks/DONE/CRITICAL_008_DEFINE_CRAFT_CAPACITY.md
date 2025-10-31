# 🎯 CRITICAL_008: Define Craft Capacity Model

**Severity**: 🔴 CRITICAL
**Blocker For**: Squad composition, mission assignment, interception mechanics
**Estimated Effort**: 4 hours
**Dependencies**: C1 (Pilot stat scale), C5 (Unit stat ranges)

---

## OVERVIEW

**Problem**: Craft capacity specification is incomplete and contradictory:

1. **Missing Specification**:
   - How many pilots per craft? (1 or multiple?)
   - How many soldiers per mission squad? (Fixed at 4-6? Variable?)
   - What's the relationship between craft capacity and squad size?
   - Can squads exceed craft capacity? (Deploy via dropship?)

2. **Current Assumptions** (From scattered references):
   - Pilots.md: Implies 1 pilot per craft (Piloting stat per unit)
   - Units.md: Doesn't specify squad capacity
   - Missions.md: Squad size varies (3-12 soldiers?)
   - Geoscape.md: Multiple missions possible, unclear troop management

3. **Contradictions**:
   - Can multiple pilots crew one craft? (cooperative piloting?)
   - Is squad size bounded by craft, or separate system?
   - Multi-craft missions: How are squads divided?
   - Reinforcements: Can mid-mission reinforcements arrive?

4. **Impact**:
   - Squad composition strategy undefined
   - Pilot recruitment unclear (need many or few?)
   - Mission planning impossible (how many soldiers deploy?)
   - Base capacity unclear (how many pilots to train?)

**Solution**: Define comprehensive craft capacity and deployment model.

---

## DESIGN SPECIFICATION

### Section 1: Craft Types & Capacities

#### Fighter Craft (Interception)

```
Craft Type          Role                 Capacity      Notes
──────────────────────────────────────────────────────────
Avenger             Fast fighter         1 pilot       Interceptor
Interceptor         Assault fighter      1-2 pilots    With copilot option
Transport           Troop carrier        6-12 soldiers Dedicated dropship
                                         2 pilots      Copilot + transport pilot
```

#### Pilot Slots Model

**Model: One Primary Pilot + Optional Copilot**

```
Every craft has ONE required pilot (captain)
Some craft support ONE optional copilot

Interceptor (fighter):
  Primary Pilot slot: Required (mandatory)
  Copilot slot: Optional (1 slot)
  Uses: Flight combat, evasion

Transport (dropship):
  Primary Pilot slot: Required (mandatory)
  Copilot slot: Optional (1 slot)
  Uses: Planetary insertion, VTOL maneuvers

Benefits of copilot:
  - Primary pilot can focus on combat (fighter)
  - Better VTOL handling (transport)
  - Redundancy if pilot incapacitated
  - Pilot experience sharing?
```

#### Craft Capacity Matrix

```
Craft Class       Soldier Capacity    Pilot+Copilot    Total Aboard
─────────────────────────────────────────────────────────────────
Interceptor       0                   1 (+ 1 optional) 2 max
Transport         8                   2 (required)     10 total
                                      optional copilot  11 with copilot

Multi-drop:
Transport #1: 4 soldiers + pilot + copilot = 6 aboard
Transport #2: 4 soldiers + pilot + copilot = 6 aboard
Total deployed: 8 soldiers, 4 crew
```

### Section 2: Squad Composition & Deployment

#### Squad Size Specification

**Base Squad Size**:

```
Min squad:         3 soldiers (skeleton crew)
Standard squad:    4-6 soldiers (recommended)
Max squad:         8 soldiers (maximum capacity)
Transport size:    4 soldiers per transport

Examples:
  Small mission (rescue): 4 soldiers
  Medium mission (base clear): 6 soldiers
  Large mission (terror site): 8 soldiers (two transports)
```

#### Squad Composition Rules

**Role Requirements**:

```
Squad Role          Min Count    Recommended    Max Count
──────────────────────────────────────────────────────────
Leader/Commander    1            1              1
Combat soldiers     2            3              5
Support (medic)     1            1              2
Specialist          0            1              2
```

**Squad Allocation Model**:

```
Squad 1 (Primary):
  - 4-6 soldiers + leader
  - Mix of roles

Squad 2 (Optional):
  - 2-4 soldiers (reinforcement)
  - Support focused

Reinforcement system:
  Mid-mission reinforcements possible?
  (Design decision needed: Yes/No)
```

### Section 3: Transport Logistics

#### Single vs. Multi-Transport Missions

**Single Transport**:

```
Mission Type         Squad Size    Transports Needed
──────────────────────────────────────────────────
Small extraction     3-4           1 transport
Medium engagement    5-6           2 transports (one per craft)
```

**Multi-Transport Deployment**:

```
Large mission example:
  Transport A: 4 soldiers + pilot + copilot
  Transport B: 4 soldiers + pilot + copilot
  Total: 8 soldiers, 4 crew members

Deployment sequence:
  T+0:00 Transports enter airspace
  T+0:30 Transport A lands, 4 soldiers deploy
  T+0:45 Transport B lands, 4 soldiers deploy (or holds?)
  T+END: Both transports available for extraction

Questions:
  Can transports land simultaneously?
  Can one hold while other deploys?
  Extraction sequence matters for wounded?
```

#### Pilot Requirements

**Crew Requirement Formula**:

```
Pilots needed = Number of transports for mission + 1 reserve

Examples:
  1 transport = 1 primary + 1 backup pilot (2 total)
  2 transports = 2 pilots + 1 backup (3 total)
  3 transports = 3 pilots + 1 backup (4 total)

Rationale:
  Always have backup pilot in case primary injured
  More transports = more pilots needed
  Creates strategic bottleneck (limited pilots)
```

### Section 4: Craft Availability & Scheduling

#### Craft Assignment Model

**Limited Craft Constraint**:

```
Base can build:        1-5 transports (expensive)
Interceptors:         2-8 fighters (for airspace)

Concurrent missions:
  Maximum simultaneous: Limited by craft + pilots

  Example with 2 transports + 4 pilots:
    Mission 1: 2 pilots needed (2 available)
    Mission 2: 0 pilots available (blocked)

    So: Typical 1-2 concurrent missions maximum
```

**Craft Maintenance Downtime**:

```
After each mission:
  Damaged craft: 1-5 days repair (depending on damage)
  Intact craft: Ready for next mission immediately

Result: Craft availability varies based on mission results
```

#### Pilot Availability

**Pilot Injury & Recovery**:

```
Pilot takes injury:     Temporarily unavailable (2-5 days recovery)
Pilot incapacitated:    1-3 weeks recovery
Pilot kills others:     Morale hit to whole pilot corps
Pilot stress/panic:     Combat fatigue, needs rest days
```

**Pilot Stress System** (if implemented):

```
Each mission flown:     Pilot gains 1 stress
Rest day in base:       -1 stress
Stress level effects:
  1-2: No penalty
  3-5: -1 Piloting stat (temporary)
  5+: Cannot fly (mandatory rest)

Prevents: Veteran pilots flying every mission
Forces: Rotation and rest
```

### Section 5: Inter-Base Craft Assignment

#### Multi-Base Logistics

**Craft Ownership**:

```
Each base owns specific craft
  Base A: 2 transports
  Base B: 1 transport + interceptors
  Base C: 1 interceptor

Transfer possible?
  Transports: Slow (1-2 days by air)
  Interceptors: Only for patrol/interception (not deployment)

Reality: Each base mostly self-sufficient
```

**Pilot Assignment**:

```
Pilots assigned to base
  Can be reassigned (1-3 day travel)
  Training facility determines skill

Regional strategy:
  Base A (many threats): 4 pilots, 2 transports
  Base B (quiet): 2 pilots, 1 transport
```

### Section 6: Mission Squad Assignment

#### Squad Selection System

**UI/Game Flow**:

```
1. Select mission
   → Requires: 4-8 soldiers
   → Requires: 1-4 pilots (for transports)

2. Choose soldiers
   → Filter by: Role, equipment, health status
   → Show: Fatigue level, injury status
   → Limit: Squad size 3-8

3. Choose pilot(s)
   → Show: Piloting skill, stress level
   → Warn: "Pilot stressed" or "Pilot injured"
   → Auto-select if only one available

4. Confirm equipment
   → Show: Total weight vs. strength
   → Warn: Overloaded units
   → Adjust: Add/remove soldiers to fit

5. Launch
   → Transport #1: Soldiers 1-4 + Pilot A (+ Copilot?)
   → Transport #2: Soldiers 5-8 + Pilot B (if needed)
```

#### Squad Roster Limitations

**Squad Size Factors**:

```
Can always deploy:      4 soldiers (minimum viable)
Can deploy:             5-6 soldiers (with 2 transports)
Can deploy:             7-8 soldiers (with 2 transports)
Cannot deploy:          9+ soldiers (exceeds transport capacity)

Implied roster building:
  Early game: Need 8 soldiers minimum (4 + 4 backup)
  Mid game: Build to 12-16 soldiers (rotation + specialization)
  Late game: 16-20+ soldiers (all elite, specialization)
```

### Section 7: Special Deployment Scenarios

#### Reinforcements (Decision Needed)

**Question**: Can additional soldiers arrive mid-mission?

**Option A: No Reinforcements**
```
Squad deploys, fights until end
No additional soldiers arrive
Rescue mission: Must save soldiers in-field or they're lost
Advantage: Simpler, risk matters
```

**Option B: Reinforcements Available**
```
Initial squad: 4 soldiers
Turns 3+: Second transport can arrive with 2 more soldiers
Timing: Must request by radio (uses turns)
Cost: Transport fuel + pilot availability
Advantage: Rescue options, recovery mechanics
```

**Recommendation**: Option A (No reinforcements)
- Simpler design
- Increases mission tension
- Matches XCOM 1 model
- Can be added in expansion

#### Multi-Site Missions

**Question**: Can one mission span multiple map locations?

**Specification** (if implemented):

```
Example: Base assault + command center raid
  Phase 1: Infiltrate base perimeter
  Phase 2: Clear command center
  Phase 3: Extract

Squad: Remains same throughout
Transport: Stays on map (extraction point)
```

**Recommendation**: Design for Phase 1 (future expansion)
- Start with single-site missions
- Can add multi-site in DLC
- Simplifies initial implementation

---

## ACCEPTANCE CRITERIA

This task is complete when:

- ✅ Craft capacity defined for each craft type
- ✅ Squad size limits (3-8 soldiers) specified
- ✅ Pilot requirement formula documented
- ✅ Multi-transport logistics explained
- ✅ Craft availability & scheduling defined
- ✅ Multi-base assignments addressed
- ✅ Squad assignment UI flow specified
- ✅ Reinforcement policy decided
- ✅ Cross-references updated
- ✅ Designer review completed

---

## IMPLEMENTATION PLAN

### Step 1: Create Authoritative Document (1h)
1. Create `design/mechanics/CRAFT_CAPACITY_MODEL.md`
2. Include all sections from specification
3. Add UI mockups for squad selection
4. Add examples of deployment scenarios

### Step 2: Update Cross-References (0.5h)
1. Update Crafts.md: Reference capacity definitions
2. Update Missions.md: Reference squad size limits
3. Update Pilots.md: Reference pilot requirements
4. Update Geoscape.md: Reference mission assignment

### Step 3: Implement Squad System (1h)
1. Create `engine/battlescape/squad.lua`
2. Implement squad composition validation
3. Implement pilot assignment validation
4. Add capacity checking

### Step 4: Create UI Flow (1h)
1. Design squad selection screen
2. Design pilot assignment screen
3. Design equipment/capacity warning system
4. Create mockups for designer approval

### Step 5: Integrate Mission Assignment (0.5h)
1. Connect mission selection to squad requirements
2. Implement capacity checking before launch
3. Prevent overloaded deployments
4. Add warnings and error messages

---

## TESTING STRATEGY

### Test Scenarios

**Scenario 1: Squad Size Limits**
```
Try to deploy 3 soldiers: ✓ Allowed (minimum)
Try to deploy 6 soldiers with 1 transport: ✓ Allowed (fits)
Try to deploy 8 soldiers with 1 transport: ✗ Blocked (too large)
Try to deploy 8 soldiers with 2 transports: ✓ Allowed (distributed)
Try to deploy 9 soldiers: ✗ Blocked (exceeds capacity)
```

**Scenario 2: Pilot Assignment**
```
2 transports needed: 2 pilots + 1 backup = 3 minimum
Base has 2 pilots: ✗ Cannot launch (insufficient crew)
Base has 3 pilots: ✓ Can launch (one rests)
Base has 4+ pilots: ✓ Can launch with rotation
```

**Scenario 3: Equipment Capacity**
```
Squad: 4 soldiers
  A: STR 7, capacity 54kg, carrying 52kg → ✓ OK
  B: STR 5, capacity 50kg, carrying 55kg → ✗ OVERLOADED
Squad cannot launch (soldier overloaded)
UI shows: "Remove equipment from soldier B"
```

**Scenario 4: Multi-Transport Deployment**
```
Mission requires 8 soldiers:
  Transport A: Carries 4 soldiers + 2 crew = 6 total
  Transport B: Carries 4 soldiers + 2 crew = 6 total
  Total: 4 pilots needed (2 primary + 2 copilots optional)
  Verify: UI shows transport distribution correctly
```

---

## DOCUMENTATION TO UPDATE

| File | Section | Change |
|------|---------|--------|
| design/mechanics/Crafts.md | Capacity | Reference capacity model |
| design/mechanics/Missions.md | Squad size | Reference squad limits |
| design/mechanics/Pilots.md | Requirements | Reference pilot assignments |
| design/mechanics/Geoscape.md | Missions | Reference mission deployment |
| api/GAME_API.toml | [unit.craft] | Add capacity specs |

---

## COMPLETION CHECKLIST

- [ ] Create authoritative capacity document
- [ ] Define craft capacity matrix
- [ ] Define squad size limits (3-8)
- [ ] Define pilot requirement formula
- [ ] Define multi-transport logistics
- [ ] Create UI flow mockups
- [ ] Implement squad validation code
- [ ] Implement pilot assignment validation
- [ ] Test capacity enforcement
- [ ] Get designer approval
- [ ] Brief team on capacity model

---

## DESIGN DECISIONS LOG ENTRY

**Decision**: Craft Capacity Model

**Question**: How many soldiers per craft? Pilots per craft?

**Options Considered**:
- A: 1 pilot per craft (current model - CHOSEN)
- B: Multiple pilots per craft (cooperative)
- C: Separate pilot/squad assignment (complex)

**Chosen**: Option A
- One primary pilot per craft (required)
- Optional copilot (support role)
- Squad deploys via transport (separate from pilot)
- Transport capacity: 4-8 soldiers + 2 crew

**Rationale**:
- Simpler design (one pilot focus)
- Creates bottleneck (limited pilots)
- Pilot skill matters (individual stat)
- Encourages pilot roster building

**Date**: October 31, 2025

---

## NOTES

**Depends On**: C1 (Pilot stat scale), C5 (Unit stat ranges)
**Coordinates With**: Mission system, pilot recruitment, logistics
**Impact**: Squad composition strategy, pilot roster planning, multi-transport complexity
**Future**: Reinforcements and multi-site missions deferred to expansion

---

**Created**: October 31, 2025
**Status**: READY FOR IMPLEMENTATION
**Approver**: Lead Game Designer
