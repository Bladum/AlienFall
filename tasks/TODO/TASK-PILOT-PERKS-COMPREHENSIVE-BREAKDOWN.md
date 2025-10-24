# PILOT & PERKS SYSTEM - COMPREHENSIVE TASK BREAKDOWN

**Project:** AlienFall - PILOT Class & PERKS System Implementation  
**Created:** October 23, 2025  
**Total Tasks:** 20  
**Estimated Duration:** 50-66 hours  
**Priority:** HIGH (CRITICAL for Interception/Craft systems)

---

## 📋 Task List Summary

### CORE IMPLEMENTATION TASKS (1-9)

| # | Task | Status | Hours | Depends | Blocks |
|---|------|--------|-------|---------|--------|
| 1 | PILOT Class System | TODO | 4-5h | — | 2,3,7,8 |
| 2 | Craft Pilot Requirements | TODO | 6-8h | 1 | 3,17 |
| 3 | Craft Capacity Distribution | TODO | 4-5h | 1,2 | 17 |
| 4 | PERKS System Framework | TODO | 6-8h | — | 5,9,10 |
| 5 | Two-Weapon Dual-Wield | TODO | 3-4h | 4 | 11 |
| 6 | Pilot Bonus to Craft | TODO | 4-5h | 1,2,8 | 11,18 |
| 7 | Pilot Interception XP Gain | TODO | 5-7h | 1 | 8,18 |
| 8 | Pilot Experience & Ranks | TODO | 5-7h | 1,7 | 6,11,18 |
| 9 | 40+ Standard Perks | TODO | 2-3h | 4 | 10 |

### DOCUMENTATION & UI TASKS (10-17)

| # | Task | Status | Hours | Depends | Blocks |
|---|------|--------|-------|---------|--------|
| 10 | Update Unit Classes TOML | TODO | 3-4h | 9 | 12,14 |
| 11 | Pilot UI Display | TODO | 4-5h | 5,6,8 | 12,13 |
| 12 | PILOTS.md Documentation | TODO | 4-5h | 1,6,7,8 | — |
| 13 | PERKS.md Documentation | TODO | 4-5h | 4,9,10 | — |
| 14 | Update UNITS.md API | TODO | 3-4h | 1,4,12 | — |
| 15 | Update CRAFTS.md API | TODO | 3-4h | 2,3,6 | — |
| 16 | Pilot Recruitment System | TODO | 6-8h | 1,10 | 17 |
| 17 | Pilot Assignment System | TODO | 6-8h | 2,3,16 | 18,19 |

### TESTING TASKS (18-20)

| # | Task | Status | Hours | Depends | Blocks |
|---|------|--------|-------|---------|--------|
| 18 | Test Pilots in Interception | TODO | 4-5h | 1-8 | — |
| 19 | Test Perks System | TODO | 3-4h | 4,9,10 | — |
| 20 | Test Dual-Wield Mechanic | TODO | 3-4h | 5 | — |

**Total: 50-66 hours**

---

## 🎯 Task Descriptions

### TASK-PILOT-001: PILOT Class System (4-5h)
**Status:** Core Implementation | **Priority:** CRITICAL

Create PILOT class as new unit archetype. Add class definitions to TOML:
- PILOT: base class (SPEED 8, AIM 7, REACTION 8, HP 50)
- FIGHTER_PILOT: elite variant (higher speed/aim)
- BOMBER_PILOT: transport specialist (higher health/strength)
- HELICOPTER_PILOT: VTOL specialist

**Files:**
- `mods/core/rules/unit/classes.toml` - Add 4 pilot class definitions
- `engine/basescape/logic/unit_system.lua` - Verify pilot creation works

**Deliverable:** Pilots can be created and recruited

---

### TASK-PILOT-002: Craft Pilot Requirements (6-8h)
**Status:** Core Implementation | **Priority:** CRITICAL

Define pilot requirements per craft type. Each craft specifies:
- `pilotsRequired` (1-6)
- `pilotClasses` array (required specializations)
- `minPilotLevel` (0-3)
- `requiresOfficer` (bool, for large craft)

**Files:**
- `mods/core/rules/content/crafts.toml` - Add pilot fields to all crafts
- `engine/geoscape/logic/craft_system.lua` - Validation functions

**Example:**
```toml
pilotsRequired = 2
pilotClasses = ["pilot", "bomber_pilot"]
minPilotLevel = 0
requiresOfficer = false
```

**Deliverable:** Crafts can validate pilot requirements

---

### TASK-PILOT-003: Craft Capacity Distribution (4-5h)
**Status:** Core Implementation | **Priority:** HIGH

Implement 3 capacity types per craft:
- **PILOT**: Units serving as pilots (1-6 slots)
- **CREW**: Units serving as combat troops (0-N slots)
- **CARGO**: Items/weapons only (kg-based)

**Files:**
- `mods/core/rules/content/crafts.toml` - Add capacity object
- `engine/geoscape/logic/craft_system.lua` - Capacity tracking

**Example:**
```toml
[craft.capacity]
pilots = 2
crew = 8
cargo = 50
```

**Deliverable:** Crafts have 3-tier capacity system

---

### TASK-PILOT-004: PERKS System Framework (6-8h)
**Status:** Core Implementation | **Priority:** CRITICAL

Create boolean flag-based trait system. Perks are simple on/off flags that affect unit behavior.

**Files:**
- `engine/battlescape/systems/perks_system.lua` - New (300+ lines)
  - Register perks
  - Per-unit perk tracking
  - Enable/disable/toggle/check perks
  - Load from TOML
  
- `mods/core/rules/unit/perks.toml` - New (150+ lines)
  - 40+ perk definitions
  - Categories: basic, movement, combat, senses, survival, social, special

**API:**
```lua
PerkSystem.hasPerk(unitId, perkId)        -- Check if perk active
PerkSystem.enablePerk(unitId, perkId)     -- Enable perk
PerkSystem.disablePerk(unitId, perkId)    -- Disable perk
PerkSystem.getActivePerks(unitId)         -- Get all active perks
```

**Deliverable:** 40+ perks can be enabled/disabled per unit

---

### TASK-PILOT-005: Two-Weapon Dual-Wield (3-4h)
**Status:** Core Implementation | **Priority:** HIGH

Implement dual-wield special mechanic using perks system.

**Requirements:**
- Unit has `two_weapon_proficiency` perk ENABLED
- Unit has 2 weapons equipped
- Both weapons are same type (both rifles, both pistols, etc.)

**Mechanics:**
- Single AP cost (like normal shot)
- Both weapons' energy cost consumed (doubled)
- -10% accuracy penalty

**Files:**
- `engine/battlescape/systems/weapon_system.lua` - Add dual-wield firing
- `engine/battlescape/ui/action_menu_system.lua` - Add "Dual Fire" action
- `engine/battlescape/ui/target_selection_ui.lua` - Show -10% accuracy

**Deliverable:** Units can fire two identical weapons for 1 AP with energy doubled

---

### TASK-PILOT-006: Pilot Bonus to Craft (4-5h)
**Status:** Core Implementation | **Priority:** HIGH

Implement pilot stat → craft bonus transfer system.

**Stat Mappings:**
- Pilot SPEED → Craft speed bonus (+%)
- Pilot AIM → Craft accuracy bonus (+%)
- Pilot STRENGTH → Craft damage bonus (+%)
- Pilot ENERGY → Craft energy pool bonus (+%)
- Pilot REACTION → Craft dodge/evasion bonus (+%)
- Pilot WISDOM → Craft radar range bonus (+km)
- Pilot PSI → Craft psi defense bonus (+%)

**Formula:** `bonus = (pilot_stat - 5) / 100`
- Pilot stat 5: 0% bonus
- Pilot stat 8: +3% bonus
- Pilot stat 10: +5% bonus
- Pilot stat 15: +10% bonus

**Files:**
- `engine/geoscape/logic/craft_pilot_system.lua` - Calculate bonuses
- `docs/content/crafts/pilot_bonuses.md` - Bonus system design

**Deliverable:** Pilot stats grant bonuses to craft in interception

---

### TASK-PILOT-007: Pilot Interception XP Gain (5-7h)
**Status:** Core Implementation | **Priority:** HIGH

Implement pilot experience gain during interception combat.

**When:** Pilots gain XP only during interception (not ground battles)

**How Much:** Based on enemy difficulty
- XP = (total enemy HP) / 10
- Example: 80 HP total enemies = 8 XP per pilot

**Files:**
- `engine/interception/logic/interception_system.lua` - Track pilots, award XP on victory
- `engine/basescape/logic/pilot_progression.lua` - New (250+ lines)

**Integration:**
```lua
local enemyHP = calculateTotalEnemyHP()
local xpReward = enemyHP / 10
for _, pilot in ipairs(interception.playerPilots) do
    PilotProgression.gainXP(pilot, xpReward)
end
```

**Deliverable:** Pilots gain XP from interception victories

---

### TASK-PILOT-008: Pilot Experience & Ranks (5-7h)
**Status:** Core Implementation | **Priority:** HIGH

Implement pilot progression system with 3 ranks.

**Ranks:**
| Rank | Name | XP Required | Speed Bonus | Aim Bonus | Reaction Bonus |
|------|------|-------------|-------------|-----------|-----------------|
| 0 | Rookie | 0 | +0 | +0 | +0 |
| 1 | Veteran | 100 | +1 | +2 | +1 |
| 2 | Ace | 300 | +2 | +4 | +2 |

**Files:**
- `engine/basescape/logic/pilot_progression.lua` - Rank system (250+ lines)
- `mods/core/rules/unit/pilot_ranks.toml` - Rank definitions

**Deliverable:** Pilots rank up and gain stat bonuses

---

### TASK-PILOT-009: 40+ Standard Perks (2-3h)
**Status:** Core Implementation | **Priority:** MEDIUM

Create comprehensive list of 40+ standard perks covering all gameplay aspects.

**Perk Categories:**
- **Basic (5):** can_move, can_run, can_climb, can_swim, can_breathe
- **Flight (3):** can_fly, hover, teleport
- **Combat (8):** can_shoot, can_melee, can_throw, can_use_psionics, can_use_heavy, two_weapon, quickdraw, ambidextrous
- **Senses (5):** darkvision, thermal_vision, x_ray_vision, keen_eyes, danger_sense
- **Defense (7):** regeneration, poison_immunity, fire_immunity, fear_immunity, pain_immunity, hardened, shield_use
- **Social (3):** leadership, inspire, no_morale_penalty
- **Special (6):** stealth, mimic, camouflage, self_destruct, mind_control, shapeshift

**Files:**
- `mods/core/rules/unit/perks.toml` - Extend with all 40+ perks

**Deliverable:** 40+ perks defined and available

---

### TASK-PILOT-010: Update Unit Classes TOML (3-4h)
**Status:** Documentation & Configuration | **Priority:** HIGH

Add default perks to all unit classes. Each class gets perks array.

**Examples:**
```toml
# RIFLEMAN
perks = ["can_move", "can_run", "can_shoot", "can_melee", "can_throw"]

# ALIEN_SECTOID
perks = ["can_move", "can_fly", "can_use_psionics", "psi_talent"]

# FLOATER
perks = ["can_move", "can_fly", "can_shoot"]

# PILOT
perks = ["can_move", "can_run", "can_shoot", "can_melee", "no_morale_penalty"]
```

**Files:**
- `mods/core/rules/unit/classes.toml` - Add perks array to all classes

**Deliverable:** All unit classes have appropriate default perks

---

### TASK-PILOT-011: Pilot UI Display (4-5h)
**Status:** UI & Display | **Priority:** HIGH

Create UI panels showing pilot information in craft and battle screens.

**Files:**
- `engine/geoscape/ui/craft_pilot_display.lua` - Show pilot in craft screen
- `engine/battlescape/ui/interception_hud.lua` - Show pilot in interception battle

**Display Elements:**
- Pilot name and rank
- XP progress bar
- Current bonuses applied to craft (green/red colored)
- Pilot portrait (24×24 or 48×48)
- Pilot perks icons
- Pilot level and experience

**Deliverable:** Pilots visible in craft and interception UI

---

### TASK-PILOT-012: PILOTS.md Documentation (4-5h)
**Status:** Documentation | **Priority:** MEDIUM

Create comprehensive guide for pilot system. 1000+ lines covering:
- Pilot class definition and stats
- Recruitment process and costs
- Experience gain system (interception only)
- Rank progression and bonuses
- Pilot requirements per craft
- Bonus calculations and examples
- Specialist pilot classes
- Pilot assignment UI
- Cockpit/crew distinction
- Career progression

**File:** `docs/content/units/pilots.md`

**Deliverable:** Complete pilot system documentation

---

### TASK-PILOT-013: PERKS.md Documentation (4-5h)
**Status:** Documentation | **Priority:** MEDIUM

Create comprehensive guide for perks system. 1000+ lines covering:
- System overview and philosophy
- 40+ perks with descriptions and effects
- Per-class default perks
- Dual-wield special mechanic
- Perk activation/deactivation
- UI display and icons
- Modding guide
- Examples

**File:** `docs/content/unit_systems/perks.md`

**Deliverable:** Complete perks system documentation

---

### TASK-PILOT-014: Update UNITS.md API (3-4h)
**Status:** Documentation | **Priority:** MEDIUM

Update API reference with pilot and perks sections.

**Add to `api/UNITS.md`:**
- Pilot entity definition
- Pilot stat mappings to craft bonuses
- Perks system documentation
- Examples: pilot progression, perks in use

**Deliverable:** UNITS.md includes pilot and perk information

---

### TASK-PILOT-015: Update CRAFTS.md API (3-4h)
**Status:** Documentation | **Priority:** MEDIUM

Update API reference with craft pilot features.

**Add to `api/CRAFTS.md`:**
- Craft pilot requirements section
- Capacity system (PILOT/CREW/CARGO)
- Pilot bonus calculations
- Pilot-specific features
- Craft operation with/without pilots

**Deliverable:** CRAFTS.md includes pilot system information

---

### TASK-PILOT-016: Pilot Recruitment System (6-8h)
**Status:** UI & Systems | **Priority:** MEDIUM

Implement UI and mechanics for recruiting pilots.

**Mechanics:**
- Convert soldier → pilot (role change)
- Cost: 5000 credits
- Training time: 30 days
- Generated pilots: random skill distribution (3-10 per stat)

**Files:**
- `engine/basescape/ui/recruit_pilot_ui.lua` - Recruitment screen
- `engine/basescape/logic/pilot_recruitment.lua` - Cost/availability logic

**Deliverable:** Pilots can be recruited from soldiers

---

### TASK-PILOT-017: Pilot Assignment System (6-8h)
**Status:** UI & Systems | **Priority:** MEDIUM

Implement UI and mechanics for assigning pilots to craft.

**Features:**
- Show craft with required pilot slots
- Display assigned pilots
- Allow assigning pilots from base roster
- Validate all required classes assigned
- Block missions without full pilot crew
- Show warnings for missing specialists

**Files:**
- `engine/geoscape/ui/craft_crew_assignment.lua` - Assignment screen
- `engine/geoscape/logic/craft_assignment.lua` - Validation

**Deliverable:** Pilots can be assigned to craft with validation

---

### TASK-PILOT-018: Test Pilots in Interception (4-5h)
**Status:** Testing | **Priority:** HIGH

Integration test: pilots work correctly in interception combat.

**Test Cases:**
- [ ] Pilot gains XP on victory (+50 XP example)
- [ ] Pilot rank-ups when XP threshold crossed
- [ ] Rank-up increases pilot stats (+speed, +aim, +reaction)
- [ ] Stat bonuses apply to craft
- [ ] Craft performs better with high-rank pilots
- [ ] Bonuses shown in interception HUD
- [ ] Multiple pilots' bonuses stack correctly

**Manual Test:**
1. Equip 2 pilots on craft
2. Engage UFO in interception
3. Win battle
4. Check pilot XP gained
5. Verify speed bonus applied to craft

**Deliverable:** Pilot interception system tested and working

---

### TASK-PILOT-019: Test Perks System (3-4h)
**Status:** Testing | **Priority:** MEDIUM

Integration test: perks system works correctly.

**Test Cases:**
- [ ] Units have default perks from class
- [ ] Can toggle perks on/off via API
- [ ] Disabled perks affect unit behavior
- [ ] Enabled perks grant capabilities
- [ ] Multiple perks work simultaneously
- [ ] Perks persist after save/load
- [ ] Modders can add custom perks

**Manual Test:**
1. Create rifleman unit
2. Verify has: can_move, can_run, can_shoot perks
3. Toggle can_move off
4. Verify movement blocked
5. Toggle can_move back on
6. Verify movement works

**Deliverable:** Perks system tested and working

---

### TASK-PILOT-020: Test Dual-Wield Mechanic (3-4h)
**Status:** Testing | **Priority:** MEDIUM

Integration test: dual-wield mechanic works correctly.

**Test Cases:**
- [ ] Unit with 2 same weapons + perk can fire both
- [ ] Single AP cost (not double)
- [ ] Both weapons' energy consumed (doubled)
- [ ] -10% accuracy penalty shown
- [ ] UI shows "Dual Fire" action available
- [ ] Only same weapon types allowed
- [ ] Accuracy penalty correctly calculated
- [ ] Damage from both weapons stacks

**Manual Test:**
1. Equip rifleman with 2 rifles + dual_wield perk
2. Click "Dual Fire" action
3. Select target
4. Verify:
   - 1 AP cost (not 2)
   - 2x energy consumed
   - -10% accuracy shown
   - Both rifles fire (visual effect)
   - Combined damage applied

**Deliverable:** Dual-wield mechanic tested and working

---

## 🔄 Execution Order

### Phase 1: Core Implementation (Hours 1-20)
1. TASK-PILOT-001: Pilot Class
2. TASK-PILOT-004: Perks Framework
3. TASK-PILOT-009: 40+ Perks
4. TASK-PILOT-002: Craft Requirements
5. TASK-PILOT-003: Capacity Distribution

### Phase 2: Pilot Mechanics (Hours 21-40)
6. TASK-PILOT-007: Interception XP
7. TASK-PILOT-008: Pilot Ranks
8. TASK-PILOT-006: Pilot Bonuses
9. TASK-PILOT-005: Dual-Wield
10. TASK-PILOT-010: Classes TOML

### Phase 3: UI & Systems (Hours 41-55)
11. TASK-PILOT-016: Recruitment
12. TASK-PILOT-017: Assignment
13. TASK-PILOT-011: UI Display
14. TASK-PILOT-012: PILOTS docs
15. TASK-PILOT-013: PERKS docs

### Phase 4: Documentation (Hours 56-60)
16. TASK-PILOT-014: Update UNITS.md
17. TASK-PILOT-015: Update CRAFTS.md

### Phase 5: Testing (Hours 61-66)
18. TASK-PILOT-018: Interception Test
19. TASK-PILOT-019: Perks Test
20. TASK-PILOT-020: Dual-Wield Test

---

## 📊 Key Metrics

- **Total Tasks:** 20
- **Total Estimated Hours:** 50-66 hours
- **Critical Path:** Tasks 1, 4, 7, 8 (24-28 hours minimum)
- **Parallelizable:** Some tasks can run in parallel:
  - Documentation (12-14, 14-15) can start after 1-2
  - Testing (18-20) can start after implementation
- **Dependencies:** 8 core tasks must complete before UI/testing

---

## 🚀 Success Criteria

- [ ] All 20 tasks completed
- [ ] 40+ perks defined and functional
- [ ] Pilots can be recruited and assigned to craft
- [ ] Pilots gain XP from interception combat
- [ ] Pilot stats grant bonuses to craft
- [ ] Dual-wield mechanic works correctly
- [ ] All documentation updated
- [ ] Game runs without errors
- [ ] All tests pass (18-20)
- [ ] No regression in existing systems

---

**Created:** October 23, 2025  
**Status:** READY FOR EXECUTION  
**Difficulty:** MEDIUM-HIGH  
**Scope:** LARGE (new system + extensive integration)

