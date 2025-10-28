# Task: Pilot-Craft System Redesign - Pilots as Unit Roles

**Status:** TODO  
**Priority:** High  
**Created:** 2025-10-28  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Complete architectural redesign of the pilot-craft relationship system. **Pilots are no longer separate entities** - they are Units with an assigned **pilot role**. Crafts do not collect experience or have ranks; all progression belongs to the pilots operating them. This unifies personnel management and allows pilots to function as soldiers during battlescape missions while providing bonuses to crafts during geoscape/interception.

---

## Purpose

### Current Problems
1. **Duplicate Systems**: Pilots and Units are separate entities with overlapping properties
2. **Craft Experience Confusion**: Crafts have their own XP/rank system separate from pilot progression
3. **Inefficient Personnel**: Pilots can't participate in ground combat despite being trained operatives
4. **Stat Misalignment**: Pilot stats don't align with craft operation needs (e.g., strength affecting craft performance)
5. **Complex Management**: Players must manage two separate pools of personnel (soldiers + pilots)

### Goals
1. **Unify Systems**: Pilots ARE units - no separate pilot entity class
2. **Role-Based Assignment**: Units can be assigned "pilot role" on a craft
3. **New Piloting Stat**: Add new stat for craft operation effectiveness (maneuverability, accuracy bonus)
4. **Pilot Classes**: Create unit class tree for pilot specializations (Fighter Pilot, Bomber Pilot, Transport Pilot)
5. **Dual Role Units**: Pilots can fight in battlescape when not operating craft
6. **Craft Stat Bonuses**: Craft performance derived from pilot(s) stats, not craft XP
7. **Flexible Assignment**: Units can switch between ground combat and pilot roles

---

## Requirements

### Functional Requirements
- [ ] Units can be assigned as pilots to crafts
- [ ] Crafts require minimum number of pilots to operate (varies by craft type)
- [ ] Pilot stats provide bonuses to craft performance (speed, accuracy, dodge)
- [ ] New "Piloting" stat added to all units (6-12 range for humans)
- [ ] Pilot class tree integrated into unit promotion system
- [ ] Pilots gain XP from interception combat (not ground combat when assigned as pilot)
- [ ] Pilots can be unassigned from craft and deployed to battlescape
- [ ] Craft cannot operate without required pilot crew
- [ ] Multiple pilots on same craft provide cumulative bonuses
- [ ] Pilot fatigue system affects craft performance over time

### Technical Requirements
- [ ] Remove separate Pilot entity system
- [ ] Extend Unit entity with piloting-related properties
- [ ] Remove experience/rank from Craft entity
- [ ] Add pilot assignment tracking to Craft entity
- [ ] Create pilot class definitions in unit class tree
- [ ] Implement stat bonus calculation from pilot(s) to craft
- [ ] Update UI to show pilot assignments on crafts
- [ ] Update UI to show craft bonuses from pilot stats
- [ ] Migrate existing pilot data to unit system (if any)
- [ ] Update all craft-related systems to use pilot stats instead of craft stats

### Design Requirements
- [ ] Define new "Piloting" stat and its effects
- [ ] Design pilot class tree (Fighter, Bomber, Transport, Naval, etc.)
- [ ] Define stat-to-craft-bonus formulas
- [ ] Define pilot requirements per craft type
- [ ] Design pilot fatigue mechanics
- [ ] Define XP gain rates for interception vs. ground combat
- [ ] Design UI/UX for pilot assignment workflow

### Acceptance Criteria
- [ ] Unit can be assigned to craft as pilot
- [ ] Craft performance changes based on pilot stats
- [ ] Pilot gains XP from interception missions
- [ ] Pilot can be unassigned and deployed to battlescape
- [ ] Craft without required pilots cannot launch
- [ ] Multiple pilots provide visible cumulative bonuses
- [ ] All tests pass (unit tests + integration tests)
- [ ] Game runs without errors (Exit Code 0)
- [ ] Documentation updated across all layers

---

## Reasoning & Analysis

### Why This Change?

**Current Architecture Issues:**
```
OLD SYSTEM:
Unit (soldier) ────────────┐
                           ├──> Battlescape Combat
Unit (soldier) ────────────┘

Pilot (separate) ──────────> Craft ──────> Interception Combat
   ↓
   Has own stats, XP, rank
   (cannot fight on ground)

PROBLEMS:
- Pilots are wasted resources when not flying
- Two separate personnel pools to manage
- Pilot stats don't make sense for craft operation (strength?)
- Craft XP independent of pilot skill
- No flexibility in role assignment
```

**New Architecture:**
```
NEW SYSTEM:
Unit (with Piloting stat) ─────┬──> Assigned as Pilot ──> Craft ──> Interception
                               │        ↓                    ↑
                               │     Provides bonuses        │
                               │                             │
                               └──> Deployed to Battlescape ─┘
                                    (when not piloting)

BENEFITS:
- Single personnel pool (all units are potential pilots)
- Units can switch roles (pilot ↔ soldier)
- Pilot progression matters for both roles
- Craft performance directly tied to pilot skill
- Specialized pilot classes optimize for craft types
- No wasted resources - all personnel multi-purpose
```

### New Stat: Piloting

**Purpose:** Represents a unit's ability to operate vehicles effectively.

**Stat Properties:**
- **Range:** 6-12 (human standard), 0-20 (potential aliens/robots)
- **Default:** 6 (untrained), 8-10 (trained pilot classes)
- **Effect on Craft:**
  - **Speed Bonus:** Each piloting point above 6 = +2% craft speed
  - **Accuracy Bonus:** Each piloting point above 6 = +3% craft weapon accuracy
  - **Dodge Bonus:** Each piloting point above 6 = +2% craft dodge chance
  - **Handling:** Higher piloting reduces fuel consumption by 1% per point

**Stat Synergies:**
- **Dexterity:** Affects reaction time (initiative in interception)
- **Perception:** Affects targeting systems (sensor range)
- **Intelligence:** Affects system management (power distribution)

**Example Calculation:**
```
Pilot with Piloting 10, Dexterity 9, Perception 8
Craft: Fighter (Base Speed 5, Base Accuracy 70%, Base Dodge 15%)

BONUSES:
- Speed: +8% (from Piloting 10: 4 points above 6 × 2%)
- Accuracy: +12% (from Piloting 10: 4 points × 3%)
- Dodge: +8% (from Piloting 10: 4 points × 2%)
- Initiative: +3 (from Dexterity 9)
- Sensor Range: +2 (from Perception 8)

FINAL CRAFT STATS:
- Speed: 5.4 (5 × 1.08)
- Accuracy: 82% (70% + 12%)
- Dodge: 23% (15% + 8%)
```

### Pilot Class Tree Design

**Integration with Unit System:**
```
Rank 0: Recruit (basic unit)
   ↓
Rank 1: Agent (choose role)
   ├─ Soldier Branch (ground combat specialists)
   ├─ Support Branch (medic, engineer)
   └─ Pilot Branch ──┐
                     │
Rank 2: Pilot Specialization
   ├─ Fighter Pilot (air-to-air combat)
   ├─ Bomber Pilot (air-to-ground)
   ├─ Transport Pilot (cargo, troops)
   ├─ Naval Pilot (sea/submarine)
   └─ Helicopter Pilot (VTOL craft)
                     │
Rank 3: Advanced Pilot
   ├─ Ace Fighter (elite air combat)
   ├─ Strategic Bomber (heavy ordnance)
   ├─ Assault Transport (combat drop)
   └─ etc.
```

**Class Requirements for Crafts:**
```
CRAFT TYPE          REQUIRED PILOT CLASS           CREW SIZE
-----------------------------------------------------------------
Scout               Any Pilot (Rank 1+)            1 pilot
Interceptor         Fighter Pilot (Rank 2+)        1 pilot
Fighter             Fighter Pilot (Rank 2+)        1 pilot
Bomber              Bomber Pilot (Rank 2+)         1 pilot + 1 crew
Transport           Transport Pilot (Rank 2+)      1 pilot + 1 co-pilot
Heavy Transport     Transport Pilot (Rank 3+)      1 pilot + 2 crew
Battleship          Naval Pilot (Rank 3+)          1 pilot + 3 crew
```

**Crew Positions:**
1. **Pilot (Primary):** Controls craft, primary stat bonuses apply
2. **Co-Pilot (Secondary):** Assists, provides 50% of stat bonuses
3. **Crew (Tertiary):** Support roles, provides 25% of stat bonuses

### Multiple Pilots - Cumulative Bonuses

**Example: Heavy Transport with 3 crew members**
```
Pilot 1 (Primary): Piloting 10 → +8% speed, +12% accuracy
Pilot 2 (Co-Pilot): Piloting 8 → +4% speed (50%), +6% accuracy (50%)
Pilot 3 (Crew): Piloting 6 → +0% speed (no bonus, base level)

TOTAL CRAFT BONUSES:
- Speed: +12% (8% + 4% + 0%)
- Accuracy: +18% (12% + 6% + 0%)
```

**Crew Roles:**
- Primary Pilot: Full bonus, controls craft
- Co-Pilot: 50% bonus, assists with systems
- Crew: 25% bonus, manages subsystems
- Additional Crew: Diminishing returns (10% per extra crew)

---

## Plan

### PHASE 1: Design Documentation (Design Layer)

**Goal:** Define complete game design for new pilot-craft system

#### Step 1.1: Update Units.md with Piloting Stat
**Description:** Add new "Piloting" stat to unit statistics section  
**Files to modify:**
- `design/mechanics/Units.md`
  - Add Piloting stat to "Unit Statistics" section
  - Define stat range, effects, progression
  - Add examples of piloting in combat
  - Document stat synergies with craft operation

**Estimated time:** 1 hour

#### Step 1.2: Update Units.md with Pilot Classes
**Description:** Add pilot class tree to class system section  
**Files to modify:**
- `design/mechanics/Units.md`
  - Extend "Class Hierarchy" section
  - Add pilot branch (Fighter, Bomber, Transport, Naval, Helicopter)
  - Define class requirements for crafts
  - Document progression paths
  - Add class-specific abilities/bonuses

**Estimated time:** 2 hours

#### Step 1.3: Update Crafts.md with Pilot-Driven Performance
**Description:** Replace craft XP/rank system with pilot-driven bonuses  
**Files to modify:**
- `design/mechanics/Crafts.md`
  - **REMOVE** "Craft Experience & Progression" section
  - **ADD** "Pilot Assignment & Crew" section
  - Document crew requirements per craft type
  - Define stat bonus formulas (pilot stats → craft performance)
  - Document multiple pilot mechanics
  - Add pilot fatigue system

**Estimated time:** 2 hours

#### Step 1.4: Update Interception.md (if exists)
**Description:** Document how pilots gain XP from interception  
**Files to check/modify:**
- `design/mechanics/Interception.md`
  - Document XP gain from interception combat
  - Define XP rewards (kills, victories, etc.)
  - Document pilot fatigue from interception
  - Add examples of pilot progression

**Estimated time:** 1 hour

**PHASE 1 TOTAL:** 6 hours

---

### PHASE 2: API Documentation (API Layer)

**Goal:** Define technical contracts for new system

#### Step 2.1: Update UNITS.md API
**Description:** Add piloting properties and pilot-specific functions  
**Files to modify:**
- `api/UNITS.md`
  - Add `piloting` stat to Unit entity
  - Add `assigned_craft_id` property (nil if not assigned)
  - Add `pilot_role` property ("pilot", "co-pilot", "crew", nil)
  - Add `pilot_xp` property (separate from ground combat XP)
  - Document pilot assignment functions
  - Document pilot stat bonus calculation functions

**Content to add:**
```lua
Unit = {
  -- Existing properties...
  
  -- Piloting Properties
  piloting = number,              -- 6-12 (craft operation skill)
  assigned_craft_id = string | nil,  -- Craft ID if assigned as pilot
  pilot_role = string | nil,      -- "pilot", "co-pilot", "crew"
  pilot_xp = number,              -- XP from interception (separate)
  pilot_fatigue = number,         -- 0-100 (affects performance)
}

-- Pilot Assignment Functions
function Units.assignToCraft(unitId, craftId, role)
function Units.unassignFromCraft(unitId)
function Units.getPilotBonuses(unitId)
function Units.canOperateCraft(unitId, craftType)
```

**Estimated time:** 2 hours

#### Step 2.2: Update CRAFTS.md API
**Description:** Remove craft XP/rank, add pilot crew system  
**Files to modify:**
- `api/CRAFTS.md`
  - **REMOVE** `experience`, `rank`, `kills`, `missions_flown` properties
  - **ADD** `crew` array of Unit IDs
  - **ADD** `required_pilots` property
  - **ADD** `crew_bonuses` calculated property
  - Document crew management functions
  - Document stat bonus calculation from crew

**Content to add:**
```lua
Craft = {
  -- Remove: experience, rank, kills, missions_flown
  
  -- Crew System
  crew = number[],                -- Array of Unit IDs assigned as crew
  required_pilots = number,       -- Min pilots needed (1-4)
  crew_capacity = number,         -- Max crew size
  crew_bonuses = {                -- Calculated from crew stats
    speed_bonus = number,         -- % bonus from pilot stats
    accuracy_bonus = number,      -- % bonus from pilot stats
    dodge_bonus = number,         -- % bonus from pilot stats
    initiative_bonus = number,    -- Initiative from pilot reaction
  },
  can_launch = boolean,           -- True if minimum crew assigned
}

-- Crew Management Functions
function Crafts.assignCrew(craftId, unitId, role)
function Crafts.removeCrew(craftId, unitId)
function Crafts.calculateCrewBonuses(craftId)
function Crafts.hasRequiredCrew(craftId)
```

**Estimated time:** 2 hours

#### Step 2.3: Remove/Archive PILOTS.md API
**Description:** Pilot system no longer separate - merge into UNITS.md  
**Files to modify:**
- `api/PILOTS.md` → **DEPRECATED** (add deprecation notice, keep for reference)
- Add redirect notice to `api/UNITS.md`

**Content to add to PILOTS.md:**
```markdown
# DEPRECATED: Pilots API Reference

**Status:** ⛔ DEPRECATED (2025-10-28)  
**Replaced By:** [UNITS.md](UNITS.md) - Pilots are now Units

This API has been merged into the Units system. Pilots are no longer separate entities.

**See:**
- [UNITS.md](UNITS.md) - Complete unit system including pilot roles
- [CRAFTS.md](CRAFTS.md) - Crew assignment and bonuses

**Migration Guide:**
- Old: `Pilot` entity → New: `Unit` with `pilot_role` property
- Old: `pilot_rank`, `pilot_xp` → New: `Unit.pilot_xp` (separate from ground XP)
- Old: `assigned_craft` → New: `Unit.assigned_craft_id`
```

**Estimated time:** 30 minutes

#### Step 2.4: Update GAME_API.toml Schema
**Description:** Update TOML schema for new system  
**Files to modify:**
- `api/GAME_API.toml`
  - Add `piloting` field to `[unit]` schema
  - Add `assigned_craft_id`, `pilot_role`, `pilot_xp`, `pilot_fatigue` fields
  - Remove `experience`, `rank` from `[craft]` schema
  - Add `crew`, `required_pilots`, `crew_capacity` to `[craft]` schema
  - Add pilot class definitions to `[unit_class]` schema

**Estimated time:** 1 hour

**PHASE 2 TOTAL:** 5.5 hours

---

### PHASE 3: Architecture Updates (Architecture Layer - IF NEEDED)

**Goal:** Update system relationships and diagrams

#### Step 3.1: Review Architecture Impact
**Description:** Determine if architecture docs need updates  

**Questions:**
- Does this change system dependencies?
  - **YES**: Crafts now depend on Units for crew
  - **YES**: Units can be assigned to Crafts (bidirectional relationship)
- Does this affect module relationships?
  - **YES**: Geoscape (crafts) now interacts with Basescape (units)
- Does this change data flows?
  - **YES**: Interception XP flows to Units, not Crafts

**Conclusion:** Architecture updates needed

**Estimated time:** 30 minutes (analysis)

#### Step 3.2: Update architecture/layers/GEOSCAPE.md
**Description:** Update craft system diagrams to show crew dependency  
**Files to modify:**
- `architecture/layers/GEOSCAPE.md`
  - Update craft management diagrams
  - Show crew assignment relationship
  - Document stat bonus calculation flow
  - Add crew management state machine

**Estimated time:** 1.5 hours

#### Step 3.3: Update architecture/systems/UNITS.md (if exists)
**Description:** Add pilot role assignment to unit lifecycle  
**Files to check/modify:**
- `architecture/systems/` (check for UNITS.md or similar)
  - Add pilot assignment to unit state machine
  - Document unit-craft relationship
  - Show dual-role mechanics (pilot ↔ soldier)

**Estimated time:** 1 hour

**PHASE 3 TOTAL:** 3 hours

---

### PHASE 4: Engine Implementation (Engine Layer)

**Goal:** Implement new system in production code

#### Step 4.1: Extend Unit Entity
**Description:** Add piloting properties to unit data structure  
**Files to modify:**
- `engine/core/entities/unit.lua` (or wherever Unit is defined)
  - Add `piloting` stat (default 6)
  - Add `assigned_craft_id` (default nil)
  - Add `pilot_role` (default nil)
  - Add `pilot_xp` (default 0)
  - Add `pilot_fatigue` (default 0)

**Estimated time:** 1 hour

#### Step 4.2: Create Pilot Assignment System
**Description:** Create manager for assigning units to crafts as pilots  
**Files to create:**
- `engine/geoscape/logic/pilot_manager.lua`
  - `PilotManager.assignToCraft(unitId, craftId, role)`
  - `PilotManager.unassignFromCraft(unitId)`
  - `PilotManager.canOperateCraft(unitId, craftType)` (check class requirements)
  - `PilotManager.calculatePilotBonuses(unitId)` (convert stats to bonuses)
  - `PilotManager.validateCrew(craftId)` (check minimum crew)

**Estimated time:** 3 hours

#### Step 4.3: Update Craft Entity
**Description:** Remove XP/rank, add crew tracking  
**Files to modify:**
- `engine/geoscape/entities/craft.lua` (or similar)
  - **REMOVE** `experience`, `rank`, `kills`, `missions_flown`
  - **ADD** `crew` (array of unit IDs)
  - **ADD** `required_pilots` (from craft type definition)
  - **ADD** `crew_capacity` (max crew size)

**Estimated time:** 1 hour

#### Step 4.4: Create Crew Bonus Calculator
**Description:** Calculate craft performance bonuses from crew stats  
**Files to create:**
- `engine/geoscape/logic/crew_bonus_calculator.lua`
  - `CrewBonusCalculator.calculate(craftId)` → returns bonus table
  - Logic: sum bonuses from pilot (100%), co-pilot (50%), crew (25%)
  - Apply diminishing returns for extra crew
  - Consider pilot fatigue modifiers

**Estimated time:** 2 hours

#### Step 4.5: Update Craft Management System
**Description:** Integrate crew system into craft operations  
**Files to modify:**
- `engine/geoscape/managers/craft_manager.lua` (or similar)
  - Update `canLaunch()` to check crew requirements
  - Update craft stats calculation to include crew bonuses
  - Add crew validation before mission launch
  - Update fuel consumption with pilot efficiency bonuses

**Estimated time:** 2 hours

#### Step 4.6: Update Interception System
**Description:** Award XP to pilots instead of craft  
**Files to modify:**
- `engine/interception/interception_manager.lua` (or similar location)
  - **REMOVE** craft XP gain logic
  - **ADD** pilot XP gain logic
  - Award XP to all crew members (scaled by role)
  - Update pilot fatigue after interception
  - Trigger pilot rank-up checks

**Estimated time:** 2 hours

#### Step 4.7: Remove Old Pilot Progression System
**Description:** Deprecate standalone pilot system  
**Files to modify/remove:**
- `engine/basescape/logic/pilot_progression.lua`
  - Add deprecation notice
  - Keep file for reference but disable functionality
  - OR: Migrate useful logic to unit progression system

**Estimated time:** 1 hour

#### Step 4.8: Create Pilot Class Definitions
**Description:** Define pilot classes in unit class system  
**Files to create/modify:**
- `engine/content/units/unit_classes.lua` (or similar)
  - Add Pilot branch to class tree
  - Define Fighter Pilot, Bomber Pilot, Transport Pilot, Naval Pilot classes
  - Add class requirements for craft operation
  - Define stat bonuses per class

**Estimated time:** 2 hours

#### Step 4.9: Update Unit Progression System
**Description:** Integrate pilot XP into unit progression  
**Files to modify:**
- `engine/basescape/logic/unit_progression.lua` (or similar)
  - Track pilot XP separately from ground combat XP
  - Allow pilot rank progression through interception
  - Maintain ground combat rank progression
  - Allow dual progression (pilot rank + soldier rank)

**Estimated time:** 2 hours

**PHASE 4 TOTAL:** 16 hours

---

### PHASE 5: Mods/Content Configuration (Mods Layer)

**Goal:** Define game content with new system

#### Step 5.1: Update Unit Class Definitions
**Description:** Add pilot classes to unit TOML  
**Files to modify:**
- `mods/core/rules/unit/classes.toml`
  - Add pilot class branch
  - Define class properties (stat bonuses, requirements)
  - Add craft operation requirements per class

**Example content:**
```toml
[classes.pilot]
name = "Pilot"
rank = 1
description = "Basic aircraft operator"
stat_bonuses = { piloting = 2 }
requirements = { rank = 1 }
promotion_options = ["fighter_pilot", "bomber_pilot", "transport_pilot"]

[classes.fighter_pilot]
name = "Fighter Pilot"
rank = 2
description = "Specialized in air-to-air combat"
stat_bonuses = { piloting = 3, dexterity = 1, perception = 1 }
requirements = { rank = 2, class = "pilot" }
can_operate_crafts = ["interceptor", "fighter", "scout"]
promotion_options = ["ace_fighter"]

[classes.ace_fighter]
name = "Ace Fighter"
rank = 3
description = "Elite air combat specialist"
stat_bonuses = { piloting = 5, dexterity = 2, perception = 2 }
requirements = { rank = 3, class = "fighter_pilot", pilot_xp = 500 }
can_operate_crafts = ["interceptor", "fighter", "scout", "heavy_fighter"]
special_abilities = ["evasive_maneuvers", "precision_targeting"]
```

**Estimated time:** 2 hours

#### Step 5.2: Update Craft Definitions
**Description:** Add crew requirements to craft TOML  
**Files to modify:**
- `mods/core/rules/crafts/*.toml`
  - Add `required_pilots` field
  - Add `crew_capacity` field
  - Add `required_pilot_class` field
  - Remove XP/progression-related fields

**Example content:**
```toml
[crafts.interceptor]
name = "Interceptor"
type = "fighter"
# ...existing stats...
required_pilots = 1
crew_capacity = 1
required_pilot_class = "fighter_pilot"  # Rank 2+ pilot

[crafts.bomber]
name = "Bomber"
type = "bomber"
# ...existing stats...
required_pilots = 1
crew_capacity = 2  # 1 pilot + 1 crew
required_pilot_class = "bomber_pilot"

[crafts.heavy_transport]
name = "Heavy Transport"
type = "transport"
# ...existing stats...
required_pilots = 1
crew_capacity = 4  # 1 pilot + 1 co-pilot + 2 crew
required_pilot_class = "transport_pilot"
```

**Estimated time:** 1.5 hours

#### Step 5.3: Create Pilot Perks/Traits
**Description:** Add pilot-specific traits to unit perks  
**Files to modify:**
- `mods/core/rules/unit/perks.toml`
  - Add pilot-specific perks
  - Define effects on craft operation

**Example content:**
```toml
[perks.ace_flyer]
name = "Ace Flyer"
description = "Natural talent for aerial combat"
effects = { piloting = 2, craft_accuracy_bonus = 5 }
cost = 2
requirements = { rank = 2, class = "pilot" }

[perks.steady_hands]
name = "Steady Hands"
description = "Exceptional craft control"
effects = { craft_dodge_bonus = 3, fuel_efficiency = 5 }
cost = 1
requirements = { rank = 1, class = "pilot" }

[perks.veteran_pilot]
name = "Veteran Pilot"
description = "Extensive flight experience"
effects = { pilot_fatigue_reduction = 20, craft_speed_bonus = 5 }
cost = 2
requirements = { rank = 3, pilot_xp = 1000 }
```

**Estimated time:** 1 hour

**PHASE 5 TOTAL:** 4.5 hours

---

### PHASE 6: Testing (Tests Layer)

**Goal:** Verify new system works correctly

#### Step 6.1: Update Existing Pilot Tests
**Description:** Modify pilot tests to work with unit system  
**Files to modify:**
- `tests2/basescape/pilots_perks_test.lua`
  - Update to test units with pilot roles
  - Test pilot assignment to crafts
  - Test crew bonus calculations
- `tests2/core/pilot_skills_test.lua`
  - Update to test piloting stat
  - Test stat bonus formulas

**Estimated time:** 2 hours

#### Step 6.2: Create Pilot Assignment Tests
**Description:** Test unit-craft assignment mechanics  
**Files to create:**
- `tests2/geoscape/pilot_assignment_test.lua`
  - Test `assignToCraft()` function
  - Test `unassignFromCraft()` function
  - Test crew validation
  - Test class requirements
  - Test crew capacity limits

**Estimated time:** 2 hours

#### Step 6.3: Create Crew Bonus Tests
**Description:** Test stat bonus calculations  
**Files to create:**
- `tests2/geoscape/crew_bonus_test.lua`
  - Test single pilot bonuses
  - Test multiple pilot cumulative bonuses
  - Test role-based bonus scaling (pilot 100%, co-pilot 50%, crew 25%)
  - Test fatigue effects on bonuses
  - Test edge cases (no pilot, over-crewed, etc.)

**Estimated time:** 2 hours

#### Step 6.4: Create Interception XP Tests
**Description:** Test pilot XP gain from interception  
**Files to create:**
- `tests2/interception/pilot_xp_test.lua`
  - Test XP awarded to pilots after interception
  - Test XP distribution among crew
  - Test pilot rank progression
  - Test dual XP tracking (pilot XP vs. ground XP)

**Estimated time:** 1.5 hours

#### Step 6.5: Integration Testing
**Description:** Test full workflow  
**Files to create:**
- `tests2/integration/pilot_craft_workflow_test.lua`
  - Test: Recruit unit → Train as pilot → Assign to craft → Launch mission → Gain XP → Rank up
  - Test: Pilot in combat → Unassign → Deploy to battlescape
  - Test: Craft without crew cannot launch
  - Test: Multiple pilots on heavy craft

**Estimated time:** 2 hours

#### Step 6.6: Run Full Test Suite
**Description:** Verify all tests pass  
**Command:** `lovec "tests2/runners" run_all`
**Expected:** 2500+ tests pass, <1s runtime

**Estimated time:** 30 minutes

**PHASE 6 TOTAL:** 10 hours

---

### PHASE 7: UI/UX Implementation (Engine/GUI Layer)

**Goal:** Create UI for pilot assignment and display

#### Step 7.1: Create Pilot Assignment UI
**Description:** UI for assigning units to craft as pilots  
**Files to create:**
- `engine/geoscape/ui/pilot_assignment_panel.lua`
  - List available units (filtered by pilot class)
  - Show craft crew slots
  - Drag-and-drop or click to assign
  - Display crew requirements
  - Show stat bonuses preview

**Estimated time:** 4 hours

#### Step 7.2: Update Craft Info UI
**Description:** Show crew and bonuses on craft display  
**Files to modify:**
- `engine/geoscape/ui/craft_info_panel.lua` (or similar)
  - Display assigned crew members
  - Show crew roles (pilot, co-pilot, crew)
  - Display calculated stat bonuses
  - Show "Ready" or "Needs Crew" status
  - Warning if craft cannot launch

**Estimated time:** 2 hours

#### Step 7.3: Update Unit Info UI
**Description:** Show pilot stats on unit display  
**Files to modify:**
- `engine/basescape/ui/unit_info_panel.lua` (or similar)
  - Display piloting stat
  - Show pilot XP (separate from ground XP)
  - Display assigned craft (if any)
  - Show pilot class and rank
  - Display craft operation bonuses

**Estimated time:** 2 hours

#### Step 7.4: Create Crew Management UI
**Description:** Base-wide view of pilot assignments  
**Files to create:**
- `engine/basescape/ui/crew_management_panel.lua`
  - List all crafts with crew status
  - List all pilots with assignments
  - Quick assign/unassign interface
  - Show crew readiness status

**Estimated time:** 3 hours

**PHASE 7 TOTAL:** 11 hours

---

### PHASE 8: Data Migration (If Existing Pilots)

**Goal:** Migrate any existing pilot data to unit system

#### Step 8.1: Create Migration Script
**Description:** Convert existing pilots to units  
**Files to create:**
- `tools/migrate_pilots_to_units.lua`
  - Load existing pilot data
  - Create unit entities from pilot data
  - Assign pilot class based on old pilot rank
  - Transfer XP, stats, assignments
  - Update save files

**Estimated time:** 3 hours (IF NEEDED)

#### Step 8.2: Test Migration
**Description:** Verify migration works correctly  
**Test:** Load old save → Run migration → Verify data integrity

**Estimated time:** 1 hour (IF NEEDED)

**PHASE 8 TOTAL:** 4 hours (OPTIONAL - only if existing pilots in saves)

---

### PHASE 9: Documentation Finalization

**Goal:** Update all remaining documentation

#### Step 9.1: Update README Files
**Description:** Update module README files  
**Files to modify:**
- `engine/geoscape/README.md` - Document crew system
- `engine/basescape/README.md` - Document pilot role in units
- `mods/core/rules/README.md` - Document pilot classes

**Estimated time:** 1 hour

#### Step 9.2: Update System Patterns (if needed)
**Description:** Check if docs/system/ needs updates  
**Files to check:**
- `docs/system/` - Unlikely to need changes (this is a game mechanic change)

**Estimated time:** 30 minutes

#### Step 9.3: Create Migration Guide
**Description:** Document changes for players and modders  
**Files to create:**
- `docs/PILOT_SYSTEM_MIGRATION.md`
  - Explain old vs. new system
  - List breaking changes
  - Provide migration steps for save files
  - Update modding guide for new pilot classes

**Estimated time:** 1.5 hours

**PHASE 9 TOTAL:** 3 hours

---

## Summary of Work

### Total Estimated Time: 62.5 - 66.5 hours (excluding optional migration)

**Breakdown by Phase:**
1. Design: 6 hours
2. API: 5.5 hours
3. Architecture: 3 hours
4. Engine: 16 hours
5. Mods: 4.5 hours
6. Tests: 10 hours
7. UI: 11 hours
8. Migration: 4 hours (OPTIONAL)
9. Documentation: 3 hours

**Priority Order:**
1. **CRITICAL**: Design + API (define the system)
2. **HIGH**: Engine implementation (make it work)
3. **MEDIUM**: Tests + UI (verify and present)
4. **LOW**: Migration + final docs (polish)

---

## Implementation Strategy

### Recommended Approach: Iterative Layers

**Iteration 1: Core System (20 hours)**
- Phase 1: Design (6h)
- Phase 2: API (5.5h)
- Phase 4.1-4.5: Basic engine implementation (9h)

**Deliverable:** Design docs complete, API defined, basic pilot assignment works

**Iteration 2: Integration & Content (15 hours)**
- Phase 4.6-4.9: Complete engine (8h)
- Phase 5: Mods/content (4.5h)
- Phase 3: Architecture (3h)

**Deliverable:** Full system functional, content defined, architecture documented

**Iteration 3: Quality & Polish (22 hours)**
- Phase 6: Tests (10h)
- Phase 7: UI (11h)
- Phase 9: Final docs (3h)

**Deliverable:** Tested, UI complete, documented

**Iteration 4: Migration (4 hours, if needed)**
- Phase 8: Data migration

**Deliverable:** Old saves work with new system

---

## Testing Strategy

### Unit Tests
- **Pilot Assignment**: Test unit-craft assignment logic
- **Crew Validation**: Test crew requirements and capacity
- **Bonus Calculation**: Test stat-to-bonus formulas
- **Fatigue System**: Test pilot fatigue mechanics
- **Class Requirements**: Test craft-class compatibility

### Integration Tests
- **Full Workflow**: Recruit → Train → Assign → Mission → XP → Rank
- **Dual Role**: Pilot ↔ Soldier switching
- **Multi-Crew**: Multiple pilots on same craft
- **Interception**: XP gain from interception missions

### Manual Tests
- **UI/UX**: Test pilot assignment interface
- **Visual Feedback**: Verify crew status display
- **Edge Cases**: Test empty crew, over-crew, wrong class
- **Performance**: Test with 50+ units, 20+ crafts

### Test Coverage Targets
- **Unit System**: 90%+ coverage (piloting stat, assignment)
- **Craft System**: 90%+ coverage (crew management, bonuses)
- **Integration**: 80%+ coverage (full workflows)

---

## Review Checklist

### Design Complete
- [ ] Units.md updated with Piloting stat
- [ ] Units.md updated with Pilot class tree
- [ ] Crafts.md updated with crew system
- [ ] Crafts.md removed craft XP/rank system
- [ ] Interception.md updated with pilot XP

### API Complete
- [ ] UNITS.md updated with pilot properties
- [ ] CRAFTS.md updated with crew system
- [ ] PILOTS.md deprecated with redirect
- [ ] GAME_API.toml updated with schemas

### Architecture Complete (if needed)
- [ ] GEOSCAPE.md updated with crew diagrams
- [ ] Unit lifecycle includes pilot assignment

### Engine Complete
- [ ] Unit entity has piloting properties
- [ ] Pilot assignment system created
- [ ] Craft entity updated (crew, no XP)
- [ ] Crew bonus calculator created
- [ ] Craft manager integrates crew system
- [ ] Interception awards pilot XP
- [ ] Old pilot system deprecated
- [ ] Pilot classes defined

### Mods Complete
- [ ] Pilot classes in classes.toml
- [ ] Craft crew requirements in crafts TOML
- [ ] Pilot perks in perks.toml

### Tests Complete
- [ ] Existing pilot tests updated
- [ ] Pilot assignment tests created
- [ ] Crew bonus tests created
- [ ] Interception XP tests created
- [ ] Integration tests created
- [ ] All tests pass (2500+)

### UI Complete
- [ ] Pilot assignment UI created
- [ ] Craft info UI shows crew
- [ ] Unit info UI shows pilot stats
- [ ] Crew management UI created

### Documentation Complete
- [ ] README files updated
- [ ] Migration guide created
- [ ] All cross-references valid

### Game Verification
- [ ] Game runs without errors: `lovec "engine"`
- [ ] Exit Code 0
- [ ] No console errors
- [ ] Pilot assignment functional
- [ ] Crew bonuses visible
- [ ] Interception awards pilot XP
- [ ] Units can switch pilot ↔ soldier roles

---

## Dependencies & Risks

### Dependencies
1. **Unit System**: Must be stable (pilots are units)
2. **Craft System**: Must support crew assignment
3. **Interception System**: Must award XP to crew
4. **Class System**: Must support pilot classes
5. **UI Framework**: Must support crew management panels

### Risks & Mitigations

**Risk 1: Breaking Existing Saves**
- **Impact:** High - players lose progress
- **Mitigation:** Create migration script (Phase 8)
- **Fallback:** Keep old pilot system parallel until migration tested

**Risk 2: Performance Issues with Bonus Calculations**
- **Impact:** Medium - lag when many crafts
- **Mitigation:** Cache crew bonuses, recalculate only on crew change
- **Fallback:** Simplify bonus formulas

**Risk 3: Complex UI for Crew Assignment**
- **Impact:** Medium - poor UX
- **Mitigation:** Prototype UI early, get feedback
- **Fallback:** Simple list-based assignment (no drag-and-drop)

**Risk 4: Class System Not Flexible Enough**
- **Impact:** Medium - hard to add new pilot types
- **Mitigation:** Design extensible class tree, use TOML config
- **Fallback:** Hardcode initial classes, refactor later

**Risk 5: Dual XP Tracking Too Complex**
- **Impact:** Low - confusing for players
- **Mitigation:** Clear UI separation (Pilot XP vs. Combat XP)
- **Fallback:** Single XP pool with role-based bonuses

---

## Success Metrics

### Technical Success
- [ ] All tests pass (100%)
- [ ] Game runs without errors (Exit Code 0)
- [ ] No performance regression (<5% FPS drop)
- [ ] Code coverage maintained (75%+)

### Functional Success
- [ ] Units can be assigned as pilots
- [ ] Crafts require crew to launch
- [ ] Pilot stats affect craft performance
- [ ] Pilots gain XP from interception
- [ ] Pilots can deploy to battlescape

### Design Success
- [ ] System is intuitive (playtest feedback)
- [ ] Progression is meaningful (pilots improve crafts)
- [ ] Dual role is useful (pilots fight when not flying)
- [ ] Management is streamlined (single personnel pool)

---

## Post-Implementation Tasks

### Future Enhancements
1. **Pilot Traits**: Unique abilities for ace pilots
2. **Crew Cohesion**: Bonuses for pilots who fly together often
3. **Pilot Fatigue**: Detailed fatigue system with recovery
4. **Training Programs**: Accelerated pilot class training
5. **Named Aces**: Legendary pilots with unique bonuses
6. **Pilot Missions**: Special missions for pilot classes (reconnaissance, bombing runs)

### Modding Support
1. **Custom Pilot Classes**: Allow mods to add new pilot types
2. **Custom Craft Requirements**: Mods can define new crew requirements
3. **Custom Bonuses**: Mods can add new stat bonus types
4. **Custom UI**: Allow UI extensions for crew management

---

## Notes

### Design Philosophy
- **Simplicity**: Single personnel pool, no duplicate management
- **Flexibility**: Units can switch roles (pilot ↔ soldier)
- **Progression**: Both craft operation and ground combat benefit from unit growth
- **Strategy**: Player chooses specialists or generalists
- **Integration**: System fits naturally into existing unit progression

### Technical Philosophy
- **No Duplication**: Pilot properties extend Unit, not separate entity
- **Data-Driven**: All classes, bonuses, requirements in TOML
- **Performance**: Cache calculated bonuses, recalculate on change only
- **Testability**: Unit and integration tests at every layer
- **Maintainability**: Clear separation of concerns (assignment, calculation, display)

### Player Experience Philosophy
- **Clear Feedback**: UI shows exactly how pilots affect craft
- **Meaningful Choice**: Pilot specialization matters (fighter vs. bomber)
- **No Waste**: All personnel useful (pilots fight when not flying)
- **Progression**: Visible improvement as pilots gain experience
- **Strategy**: Crew composition affects mission success

---

## Final Verification Checklist

Before marking DONE:

### Documentation
- [ ] design/mechanics/Units.md - Piloting stat documented
- [ ] design/mechanics/Units.md - Pilot classes documented
- [ ] design/mechanics/Crafts.md - Crew system documented
- [ ] design/mechanics/Crafts.md - XP/rank system REMOVED
- [ ] api/UNITS.md - Pilot properties documented
- [ ] api/CRAFTS.md - Crew properties documented
- [ ] api/PILOTS.md - Deprecated with redirect
- [ ] api/GAME_API.toml - Schemas updated
- [ ] architecture/ - Diagrams updated (if needed)

### Implementation
- [ ] engine/ - Unit entity extended
- [ ] engine/ - Pilot assignment system created
- [ ] engine/ - Craft entity updated
- [ ] engine/ - Crew bonus calculator created
- [ ] engine/ - Interception awards pilot XP
- [ ] engine/ - Old pilot system deprecated

### Content
- [ ] mods/core/rules/unit/classes.toml - Pilot classes defined
- [ ] mods/core/rules/crafts/*.toml - Crew requirements added
- [ ] mods/core/rules/unit/perks.toml - Pilot perks added

### Testing
- [ ] tests2/ - All tests pass (2500+)
- [ ] tests2/ - New tests created (pilot assignment, crew bonuses, XP)
- [ ] Manual testing - Full workflow verified

### UI
- [ ] engine/geoscape/ui/ - Pilot assignment UI created
- [ ] engine/geoscape/ui/ - Craft info shows crew
- [ ] engine/basescape/ui/ - Unit info shows pilot stats
- [ ] engine/basescape/ui/ - Crew management UI created

### Game Verification
- [ ] Command: `lovec "engine"`
- [ ] Exit Code: 0
- [ ] No console errors
- [ ] Pilot assignment functional
- [ ] Crew bonuses visible
- [ ] Pilots gain XP from interception
- [ ] Units can deploy to battlescape when not piloting

---

**TASK READY FOR IMPLEMENTATION**

This task provides a complete roadmap for redesigning the pilot-craft system. Follow the phases sequentially, verify each phase before proceeding, and ensure all acceptance criteria are met before marking complete.

