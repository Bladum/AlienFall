# Pilot-Craft System Redesign - Analysis & Reasoning

**Date:** 2025-10-28  
**Task:** TASK-001-PILOT-CRAFT-REDESIGN  
**Status:** Planning Complete

---

## Executive Summary

This document outlines the reasoning and analysis behind the complete architectural redesign of the pilot-craft relationship system in AlienFall. The redesign unifies pilot and unit entities, eliminates craft experience progression, and creates a role-based assignment system where units can dynamically serve as both pilots and soldiers.

---

## Problem Statement

### Current System Issues

**1. Duplicate Entity Management**
- Pilots exist as SEPARATE entities from Units
- Players must manage two distinct personnel pools (soldiers + pilots)
- Redundant properties (stats, XP, progression) across both systems
- Code duplication in progression, stat management, UI

**2. Inefficient Resource Utilization**
- Pilots can ONLY operate crafts - cannot fight on ground
- When crafts are not in use, pilots are idle resources
- No way to leverage pilot training in ground combat
- Forces players to maintain larger rosters than necessary

**3. Craft Experience Confusion**
- Crafts gain XP and rank independently of pilots
- Veteran craft with rookie pilot vs. rookie craft with ace pilot creates confusion
- Should craft stats improve, or pilot bonuses, or both?
- Unclear which system drives performance improvement

**4. Stat Misalignment**
- Current pilot stats include "strength" - why would strength affect craft maneuverability?
- Pilot stats are modified copies of unit stats, not optimized for craft operation
- No clear stat representing "piloting skill" - mixed signals from multiple stats

**5. Limited Flexibility**
- Cannot train soldier to become pilot (separate recruitment)
- Cannot deploy experienced pilot to ground combat when craft not needed
- Rigid role separation reduces strategic options

---

## Proposed Solution

### Core Concept: Pilots ARE Units

**Fundamental Shift:**
```
OLD: Pilot (separate entity) → operates → Craft
NEW: Unit (with pilot role) → assigned to → Craft → provides bonuses
```

**Key Principles:**
1. **Single Entity System**: Pilot is a Unit with `pilot_role` assignment
2. **Role Assignment**: Units can be assigned/unassigned to crafts dynamically
3. **Craft as Vehicle**: Craft is equipment operated by skilled personnel, not autonomous entity
4. **Stat-Driven Performance**: Craft performance comes from operator stats, not craft XP
5. **Dual Functionality**: Same personnel can pilot OR fight, based on assignment

---

## Architectural Changes

### 1. Unit Entity Extensions

**New Properties:**
```lua
Unit = {
  -- NEW: Piloting Properties
  piloting = number,              -- 6-12: Craft operation skill
  assigned_craft_id = string | nil,  -- Craft assignment
  pilot_role = string | nil,      -- "pilot", "co-pilot", "crew"
  pilot_xp = number,              -- XP from interception (separate tracking)
  pilot_fatigue = number,         -- 0-100: Performance degradation
}
```

**Why Separate `pilot_xp` from Unit XP?**
- Ground combat XP rewards combat skills (shooting, tactics)
- Interception XP rewards piloting skills (maneuvering, targeting)
- Allows dual progression: Unit can be Rank 3 Soldier + Rank 2 Pilot
- Different XP sources: ground missions vs. interception missions

### 2. Craft Entity Simplification

**REMOVED Properties:**
```lua
-- DELETE THESE:
experience = number,      -- No longer exists
rank = number,            -- No longer exists
kills = number,           -- Tracked per pilot now
missions_flown = number,  -- Tracked per pilot now
```

**NEW Properties:**
```lua
Craft = {
  -- NEW: Crew System
  crew = number[],              -- Array of Unit IDs (crew assignments)
  required_pilots = number,     -- Min crew to operate (1-4)
  crew_capacity = number,       -- Max crew size (1-6)
  crew_bonuses = {              -- Calculated from crew stats
    speed_bonus = number,       -- % bonus
    accuracy_bonus = number,    -- % bonus
    dodge_bonus = number,       -- % bonus
    initiative_bonus = number,  -- Turn order bonus
  },
  can_launch = boolean,         -- True if crew requirements met
}
```

**Why Remove Craft XP?**
- Craft is mechanical equipment - doesn't "learn"
- Performance improvement comes from operator skill
- Simplifies system - one progression path (pilots) not two (pilots + crafts)
- Easier to balance - buff pilot stats, not craft stats + pilot stats

### 3. New Stat: Piloting

**Purpose:** Represents unit's ability to operate vehicles effectively

**Stat Properties:**
| Property | Value |
|----------|-------|
| Range | 6-12 (human), 0-20 (alien/robot potential) |
| Default | 6 (untrained) |
| Trained | 8-10 (pilot classes) |
| Elite | 12+ (ace pilots) |

**Effect on Craft Performance:**
```
Piloting Stat → Craft Bonuses Formula:

Speed Bonus = (Piloting - 6) × 2%
Accuracy Bonus = (Piloting - 6) × 3%
Dodge Bonus = (Piloting - 6) × 2%
Fuel Efficiency = (Piloting - 6) × 1%

Example: Piloting 10
- Speed: +8% (4 points above base × 2%)
- Accuracy: +12% (4 points × 3%)
- Dodge: +8% (4 points × 2%)
- Fuel: +4% efficiency (4 points × 1%)
```

**Why New Stat Instead of Reusing Existing?**
- Dexterity: Affects ground combat accuracy, not vehicle control
- Perception: Affects detection, not maneuverability
- Intelligence: Affects tech abilities, not flying skill
- Strength: No logical connection to craft operation

**Piloting is distinct skill:** Vehicle operation requires spatial awareness, reflex coordination, mechanical understanding - different from infantry combat skills

### 4. Pilot Class Tree Integration

**Class Hierarchy:**
```
Rank 0: Recruit
   ↓
Rank 1: Agent → Choose Branch
   ├─ Soldier Branch (ground specialists)
   ├─ Support Branch (medic, engineer)
   └─ Pilot Branch ────────────────────┐
                                       ↓
Rank 2: Pilot Specialization
   ├─ Fighter Pilot (air-to-air)
   ├─ Bomber Pilot (air-to-ground)
   ├─ Transport Pilot (cargo/troops)
   ├─ Naval Pilot (sea/submarine)
   └─ Helicopter Pilot (VTOL)
                                       ↓
Rank 3: Advanced Pilot
   ├─ Ace Fighter (elite air combat)
   ├─ Strategic Bomber (heavy ordnance)
   └─ Assault Transport (combat drop)
```

**Why Integrate into Unit Classes?**
- Units and pilots share same class system architecture
- Natural progression: train soldier → promote to pilot → specialize
- Allows cross-training: Soldier/Rank 2 can demote, retrain as Pilot
- Unified progression UI - players understand existing system

**Class Requirements for Crafts:**
```
Craft Type          Required Class           Min Rank
-----------------------------------------------------------
Scout               Any Pilot                Rank 1
Interceptor         Fighter Pilot            Rank 2
Bomber              Bomber Pilot             Rank 2
Transport           Transport Pilot          Rank 2
Heavy Transport     Transport Pilot (Adv)    Rank 3
Battleship          Naval Pilot (Master)     Rank 4
```

**Why Class Requirements?**
- Prevents inexperienced pilots from flying advanced crafts
- Creates progression path: train on Scout → qualify for Fighter
- Strategic choice: invest in pilot training to unlock advanced crafts
- Balances powerful crafts: require rare, high-rank pilots

### 5. Multiple Pilots - Crew System

**Crew Positions:**
1. **Pilot (Primary):** 100% stat bonus contribution
2. **Co-Pilot (Secondary):** 50% stat bonus contribution
3. **Crew (Tertiary):** 25% stat bonus contribution
4. **Additional Crew:** 10% per extra (diminishing returns)

**Example: Heavy Transport with 3 Crew**
```
Crew Member      | Role      | Piloting | Contribution | Speed Bonus
------------------------------------------------------------------
Alice            | Pilot     | 10       | 100%         | +8%
Bob              | Co-Pilot  | 8        | 50%          | +2%
Charlie          | Crew      | 6        | 25%          | +0%
------------------------------------------------------------------
TOTAL CRAFT SPEED BONUS: +10%
```

**Why Multiple Pilots?**
- Large crafts (bombers, transports, battleships) need larger crews
- Simulates real-world aviation: pilot + co-pilot + crew
- Strategic choice: assign multiple pilots for performance boost vs. save pilots for other crafts
- Crew composition matters: 2 ace pilots >> 4 rookie pilots

**Why Diminishing Returns?**
- Prevents stacking infinite pilots on one craft
- Forces strategic distribution of pilot resources
- Balances large vs. small crafts (small craft = 1 elite pilot, large craft = 3-4 average pilots)

---

## Stat Bonus Calculation Formula

### Base Formula

```lua
function calculateCrewBonuses(craftId)
  local crew = craft.crew  -- Array of Unit IDs
  local bonuses = { speed = 0, accuracy = 0, dodge = 0, initiative = 0 }
  
  for i, unitId in ipairs(crew) do
    local unit = getUnit(unitId)
    local role_multiplier = getRoleMultiplier(i)  -- 1.0, 0.5, 0.25, 0.1...
    
    -- Piloting stat bonuses
    local piloting_bonus = (unit.piloting - 6) * role_multiplier
    bonuses.speed = bonuses.speed + (piloting_bonus * 2)      -- 2% per point
    bonuses.accuracy = bonuses.accuracy + (piloting_bonus * 3) -- 3% per point
    bonuses.dodge = bonuses.dodge + (piloting_bonus * 2)       -- 2% per point
    
    -- Secondary stat bonuses
    bonuses.initiative = bonuses.initiative + (unit.dexterity * role_multiplier * 0.5)
  end
  
  -- Apply fatigue penalty
  local avg_fatigue = calculateAverageFatigue(crew)
  local fatigue_multiplier = 1.0 - (avg_fatigue / 200)  -- Max -50% at 100 fatigue
  
  for key, value in pairs(bonuses) do
    bonuses[key] = value * fatigue_multiplier
  end
  
  return bonuses
end

function getRoleMultiplier(position)
  if position == 1 then return 1.0 end      -- Pilot
  if position == 2 then return 0.5 end      -- Co-Pilot
  if position == 3 then return 0.25 end     -- Crew
  return 0.1                                 -- Additional crew (diminishing)
end
```

### Why This Formula?

**Progressive Bonuses:**
- Each piloting point above 6 = noticeable improvement
- 4 points (10 piloting) = +8% speed, +12% accuracy, +8% dodge
- High but not game-breaking (max ~20-30% bonuses from elite crew)

**Role-Based Scaling:**
- Primary pilot matters most (100% contribution)
- Co-pilot provides significant help (50%)
- Additional crew provides marginal benefit (25%, 10%)
- Encourages quality over quantity

**Fatigue Penalty:**
- Prevents pilot exploitation (spam interception missions)
- Simulates exhaustion affecting performance
- Forces crew rotation (rest pilots to recover)
- Max penalty -50% at full fatigue (100)

---

## XP and Progression

### Dual XP Tracking

**Unit XP (Ground Combat):**
- Gained from: Battlescape missions, training, base activities
- Used for: Unit rank progression (Soldier → Specialist → Elite)
- Rewards: Ground combat stats (aim, reaction, strength)

**Pilot XP (Interception):**
- Gained from: Interception missions, aerial combat, flight training
- Used for: Pilot rank progression (Rookie → Veteran → Ace)
- Rewards: Piloting stat, craft bonuses, pilot abilities

**Why Separate XP Pools?**
- Different skill domains: ground combat ≠ aerial combat
- Prevents exploitation: Can't farm XP in one mode to progress in other
- Allows specialization: Unit can be Master Soldier + Rookie Pilot
- Realistic: Real-world pilots train separately from infantry

**Example Progression:**
```
Unit "Alice" (Recruited at Rank 1 Agent)
├─ Ground Combat: 200 XP → Rank 2 Rifleman → 350 XP → Rank 3 Marksman
└─ Pilot Training: 0 XP → Retrain as Pilot → 100 XP → Rank 2 Fighter Pilot

Final: Alice is Rank 3 Marksman (ground) + Rank 2 Fighter Pilot (air)
- Can fight in Battlescape as elite marksman
- Can pilot Interceptor with Fighter Pilot bonuses
```

### XP Gain Rates

**Interception XP Sources:**
```
Kill enemy craft:        +50 XP
Assist in kill:          +25 XP
Survive interception:    +10 XP
Victory (force retreat): +30 XP
Perfect victory (no damage): +50 XP
```

**Ground Combat XP (unchanged):**
```
Kill enemy:              +5 XP
Damage dealt:            +0.5 XP per 10 damage
Objectives:              +10-50 XP
Mission completion:      +10 XP
```

**Why Higher XP for Interception?**
- Interception is riskier (craft damage = expensive repairs)
- Fewer interception opportunities than ground missions
- Encourages pilot specialization
- Balances progression rates: ground XP more frequent but smaller, pilot XP rare but larger

---

## Benefits Analysis

### Player Experience Benefits

**1. Simplified Personnel Management**
- **OLD:** Manage soldiers (barracks) + pilots (hangars) separately
- **NEW:** Single personnel roster - all units are potential pilots
- **Impact:** Reduced cognitive load, clearer strategic planning

**2. Flexible Role Assignment**
- **OLD:** Pilot cannot fight, soldier cannot fly
- **NEW:** Any unit can be pilot OR soldier based on assignment
- **Impact:** Tactical flexibility, respond to different mission needs

**3. Meaningful Progression**
- **OLD:** Craft levels up (unclear why mechanical improvement)
- **NEW:** Pilots level up (clear skill improvement)
- **Impact:** Player feels investment in personnel, not machines

**4. Strategic Depth**
- **OLD:** Buy craft, assign pilot, done
- **NEW:** Train pilots, assign optimal crew composition, manage fatigue
- **Impact:** More decisions = more engaging gameplay

**5. Resource Efficiency**
- **OLD:** Idle pilots are wasted resources
- **NEW:** Pilots can fight when not flying
- **Impact:** Better resource utilization, less roster bloat

### Technical Benefits

**1. Code Simplification**
- Remove duplicate pilot entity system
- Reuse existing unit progression code
- Single UI for personnel management

**2. Balancing Clarity**
- Buff pilot stats (clear, testable)
- Not craft stats + pilot stats (confusing interaction)
- Easier to identify balance issues

**3. Extensibility**
- New pilot classes easy to add (just unit classes)
- New crew requirements easy to define (TOML config)
- Modding-friendly (standard unit system)

**4. Performance**
- Fewer entity types = simpler state management
- No need to sync pilot/unit systems
- Reduced save file size (one entity pool, not two)

---

## Migration Strategy

### Existing Pilot Data

**IF existing pilots in saves:**
1. Load old Pilot entities
2. Create Unit entities with pilot properties
3. Transfer stats, XP, assignments
4. Map old pilot classes to new pilot classes
5. Delete old Pilot entities
6. Update Craft assignments to point to Unit IDs

**Migration Script (`tools/migrate_pilots_to_units.lua`):**
```lua
function migratePilotsToUnits(saveData)
  for _, oldPilot in ipairs(saveData.pilots) do
    local newUnit = {
      id = generateUnitId(),
      name = oldPilot.name,
      class = mapPilotClassToUnitClass(oldPilot.class),
      piloting = oldPilot.pilot_stats.speed,  -- Primary stat
      pilot_xp = oldPilot.total_xp_earned,
      pilot_role = oldPilot.crew_position,
      assigned_craft_id = oldPilot.assigned_craft,
      -- ... copy other relevant properties
    }
    table.insert(saveData.units, newUnit)
  end
  
  -- Update craft references
  for _, craft in ipairs(saveData.crafts) do
    craft.crew = findCrewUnitIds(craft.id, saveData.units)
    craft.experience = nil  -- Remove
    craft.rank = nil        -- Remove
  end
  
  -- Delete old pilot entities
  saveData.pilots = nil
end
```

### Breaking Changes

**For Players:**
- ⚠️ Old saves need migration (automatic on load)
- ⚠️ Craft stats change (pilot-driven, not craft XP)
- ⚠️ Pilot management UI relocated (in personnel, not craft screen)

**For Modders:**
- ⚠️ Pilot entity API deprecated
- ⚠️ Craft XP/rank properties removed
- ⚠️ New pilot class definitions required
- ⚠️ Crew bonus formulas in TOML config

---

## Risks and Mitigations

### Risk 1: Breaking Existing Saves
**Likelihood:** High  
**Impact:** High (players lose progress)  
**Mitigation:**
- Create robust migration script (test extensively)
- Backup saves before migration
- Provide manual fix instructions if migration fails
- Keep old pilot system code for 1 version (parallel compatibility)

### Risk 2: Performance Overhead
**Likelihood:** Medium  
**Impact:** Medium (lag with many crafts/pilots)  
**Mitigation:**
- Cache crew bonuses (recalculate only on crew change)
- Optimize crew lookup (index units by craft ID)
- Limit crew size (max 6 per craft)
- Profile and optimize hot paths

### Risk 3: UI Complexity
**Likelihood:** Medium  
**Impact:** Medium (confusing for players)  
**Mitigation:**
- Prototype UI early, test with users
- Provide clear tooltips (how bonuses calculated)
- Visual feedback (crew slot highlighting, bonus preview)
- Tutorial mission explaining pilot assignment

### Risk 4: Dual XP Confusion
**Likelihood:** Low  
**Impact:** Low (players might not understand two XP bars)  
**Mitigation:**
- Clear UI separation (Ground XP / Pilot XP)
- Tooltips explaining each XP type
- Separate progression displays (Ground Rank / Pilot Rank)
- In-game tutorial explaining dual progression

### Risk 5: Balance Issues
**Likelihood:** High (all redesigns have balance issues initially)  
**Impact:** Low (fixable with config changes)  
**Mitigation:**
- Extensive playtesting
- Adjustable formulas in config (not hardcoded)
- Monitor analytics (track pilot performance, craft usage)
- Iterative balancing patches

---

## Success Criteria

### Functional Success
- [ ] Units can be assigned to crafts as pilots
- [ ] Crafts cannot launch without required crew
- [ ] Pilot stats visibly affect craft performance
- [ ] Pilots gain XP from interception missions
- [ ] Pilots can be unassigned and deployed to battlescape
- [ ] Multiple pilots provide cumulative bonuses
- [ ] System works without errors (Exit Code 0)

### Design Success
- [ ] System is intuitive (playtest feedback > 7/10)
- [ ] Progression feels meaningful (pilots improve crafts)
- [ ] Management is streamlined (less clicks than old system)
- [ ] Strategic depth increased (crew composition matters)

### Technical Success
- [ ] All tests pass (100%)
- [ ] No performance regression (<5% FPS impact)
- [ ] Code coverage maintained (75%+)
- [ ] Migration script works (100% save conversion)

---

## Timeline Summary

**Total Estimated Effort:** 62.5 - 66.5 hours

**Phase Breakdown:**
1. Design (6h) - Define new system in docs
2. API (5.5h) - Document technical contracts
3. Architecture (3h) - Update system diagrams
4. Engine (16h) - Implement core logic
5. Mods (4.5h) - Configure content (pilot classes, crew requirements)
6. Tests (10h) - Verify system works
7. UI (11h) - Create crew management interface
8. Migration (4h, optional) - Convert old saves
9. Documentation (3h) - Finalize docs

**Recommended Approach:**
- **Week 1-2:** Design + API + Core Engine (26.5h)
- **Week 3:** Integration + Content + Tests (21h)
- **Week 4:** UI + Polish + Migration (18h)

---

## Conclusion

This redesign fundamentally simplifies the pilot-craft relationship by **unifying pilots into the unit system**. The change eliminates code duplication, improves player flexibility, and creates clearer progression. While the migration requires significant effort, the long-term benefits (code maintainability, player experience, strategic depth) justify the investment.

**Key Takeaways:**
1. **Pilots ARE units** - no separate entity system
2. **Crafts are vehicles** - performance comes from operators
3. **Role assignment is flexible** - units can pilot OR fight
4. **Progression is clear** - pilots improve, crafts don't
5. **Crew composition matters** - strategic crew assignment adds depth

**Next Steps:**
1. Review this analysis with stakeholders
2. Begin implementation following TASK-001 plan
3. Prototype UI early for user testing
4. Extensive testing before release
5. Provide migration path for existing players

---

**Document Version:** 1.0  
**Author:** AI Agent  
**Task Reference:** TASK-001-PILOT-CRAFT-REDESIGN.md

