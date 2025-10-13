# Task: Unit Recovery, Progression, and Base Training System

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement comprehensive unit recovery, progression, and base training system including:
- **Health Recovery**: Units heal 1 HP per week in base, accelerated by medical facilities
- **Sanity Recovery**: Units recover 1 sanity per week in base, accelerated by support facilities
- **Craft Repairs**: Crafts repair 20% HP per week in base, accelerated by repair facilities
- **Base Training**: Units gain 1 XP per day (30 XP/month, 360 XP/year), enhanced by training facilities
- **Experience Levels**: 7 level system (0-6) with experience thresholds
- **Unit Traits**: Birth traits that modify unit capabilities permanently
- **Transformations**: Single transformation slot per unit from base operations
- **Medals**: One-time XP bonuses (50-150) for mission achievements
- **Wounds**: Critical wound system with extended recovery time (3 weeks per wound)
- **Sanity System**: Mental health system (4-12 range) affected by missions

---

## Purpose

This system creates depth and consequence to tactical decisions by:
1. **Strategic Resource Management**: Wounded units require time to recover, forcing roster rotation
2. **Long-term Investment**: Training and progression reward player investment in veteran units
3. **Psychological Warfare**: Sanity system simulates long-term psychological impact of combat
4. **Unit Differentiation**: Traits, transformations, and medals make each unit unique
5. **Risk/Reward Balance**: Critical wounds and sanity loss add weight to mission decisions
6. **Base Building Value**: Medical, training, and support facilities become strategically important

---

## Requirements

### Functional Requirements
- [ ] **Unit Health Recovery System**
  - [ ] Base healing: 1 HP per week
  - [ ] Medical facility bonuses stack
  - [ ] Wounded units cannot deploy on missions
  - [ ] Recovery time displayed in unit roster
  
- [ ] **Unit Sanity Recovery System**
  - [ ] Base sanity recovery: 1 point per week
  - [ ] Support facility bonuses stack
  - [ ] Low sanity affects AP in combat (same as morale)
  - [ ] Mission stress decreases sanity (0-3 range)
  
- [ ] **Craft Repair System**
  - [ ] Base repair: 20% HP per week
  - [ ] Repair facility bonuses stack
  - [ ] Damaged crafts cannot deploy
  - [ ] Repair time displayed in hangar
  
- [ ] **Base Training System**
  - [ ] Passive training: 1 XP per day (30/month)
  - [ ] Training facility bonuses stack
  - [ ] Training continues even when unit is wounded
  - [ ] Combat XP is separate and additional
  
- [ ] **Experience Level System**
  - [ ] 7 levels (0-6) with thresholds: 0, 100, 300, 600, 1000, 1500, 2100, 2800 XP
  - [ ] Level-up bonuses to stats
  - [ ] Class promotion system (Battle of Wesnoth style)
  - [ ] XP progress tracking and display
  
- [ ] **Unit Trait System**
  - [ ] Traits assigned at unit creation
  - [ ] Permanent and non-transferable
  - [ ] Examples: Smart (-20% XP needed), Fast (+1 AP), Pack Mule (+25% capacity), Lucky (+50% crit chance)
  - [ ] One trait per unit
  
- [ ] **Unit Transformation System**
  - [ ] One transformation slot per unit
  - [ ] Applied via base operations (facility + technology + service)
  - [ ] Permanent modifications with pros/cons
  - [ ] Extended recovery time after transformation
  - [ ] Examples: Cybernetic (+1 AP), Psionic Enhancement, Gene Modification
  
- [ ] **Medal System**
  - [ ] One-time XP bonuses (50-150 range)
  - [ ] Awarded for mission achievements
  - [ ] Same medal cannot be earned twice
  - [ ] Medal levels (Sniper I, Sniper II, etc.)
  - [ ] Medal display in unit roster
  
- [ ] **Wound System**
  - [ ] Wounds caused by critical hits in combat
  - [ ] 1 wound = 1 HP loss per turn in battle
  - [ ] Each wound adds 3 weeks recovery time post-battle
  - [ ] Total recovery = (HP lost × 1 week) + (wounds × 3 weeks)
  - [ ] Medical facilities reduce wound recovery time

### Technical Requirements
- [ ] Time progression system (daily ticks for training, weekly ticks for recovery)
- [ ] Calendar/time management integration
- [ ] Facility bonus aggregation system
- [ ] Unit state persistence (health, sanity, XP, traits, transformations, medals, wounds)
- [ ] Post-battle processing (wound calculation, sanity loss, XP awards)
- [ ] Unit roster management and filtering (available, wounded, training)
- [ ] Event system for level-ups, medal awards, recovery completion

### Acceptance Criteria
- [ ] Units heal properly over time with correct facility bonuses
- [ ] Sanity system functions correctly with mission impact and recovery
- [ ] Crafts repair at correct rate with facility bonuses
- [ ] Base training awards 1 XP per day with facility bonuses
- [ ] Level system correctly tracks XP and applies bonuses at thresholds
- [ ] Traits are correctly assigned and persist through save/load
- [ ] Transformations can be applied and affect unit stats correctly
- [ ] Medals award XP bonuses and prevent duplicate awards
- [ ] Wound system calculates recovery time correctly
- [ ] UI displays all recovery times, XP progress, traits, medals correctly

---

## Plan

### Step 1: Time Management Foundation (3 hours)
**Description:** Create calendar/time system with daily and weekly tick management

**Files to modify/create:**
- `engine/core/time_manager.lua` (new)
- `engine/core/calendar.lua` (new)

**Implementation:**
```lua
-- TimeManager handles game time progression
-- Daily ticks: training XP
-- Weekly ticks: HP/sanity/craft recovery
-- Monthly ticks: salaries, reports
```

**Details:**
- Day counter (starting from day 0)
- Week counter (7 days = 1 week)
- Month counter (30 days = 1 month)
- Event emission for daily/weekly/monthly ticks
- Configurable time speed (1x, 5x, 30x for testing)
- Pause/resume functionality

**Estimated time:** 3 hours

---

### Step 2: Facility Bonus System (2 hours)
**Description:** Create system to aggregate facility bonuses for healing, training, repairs

**Files to modify/create:**
- `engine/basescape/systems/facility_bonus_calculator.lua` (new)
- `engine/basescape/systems/medical_facility.lua` (new)
- `engine/basescape/systems/training_facility.lua` (new)
- `engine/basescape/systems/repair_facility.lua` (new)

**Implementation:**
```lua
-- FacilityBonusCalculator
-- Calculate total bonuses from all active facilities
-- Examples:
--   Medical Bay: +1 HP/week, +0.5 wound recovery
--   Training Ground: +5 XP/week bonus
--   Workshop: +10% craft repair speed
```

**Details:**
- Facility types define bonus types and amounts
- Bonuses are additive within same type
- Facility must be operational (not damaged/under construction)
- Query system for "get total healing bonus for base"
- Bonus caching with invalidation on facility changes

**Estimated time:** 2 hours

---

### Step 3: Unit Health Recovery System (4 hours)
**Description:** Implement HP recovery with wounds and medical facility bonuses

**Files to modify/create:**
- `engine/basescape/systems/unit_recovery_system.lua` (new)
- `engine/data/unit_recovery_config.lua` (new)
- Modify `engine/battle/entities/unit_entity.lua` (add wound tracking)

**Implementation:**
```lua
-- Unit recovery calculation:
-- Base: 1 HP per week
-- With facilities: 1 + facility_bonus HP per week
-- Wound recovery: 3 weeks per wound (reduced by facilities)
-- Total recovery time = (HP_lost * 1 week) + (wounds * 3 weeks)
```

**Details:**
- Track `unit.totalDamage` from battle (HP lost)
- Track `unit.wounds` count from critical hits
- Weekly processing: restore HP based on facility bonuses
- Recovery completion event
- Cannot deploy wounded units (health < maxHealth)
- UI indication of recovery time remaining

**Estimated time:** 4 hours

---

### Step 4: Sanity System (3 hours)
**Description:** Implement sanity tracking, mission stress, and recovery

**Files to modify/create:**
- `engine/basescape/systems/sanity_system.lua` (new)
- `engine/data/mission_stress_config.lua` (new)
- Modify `engine/battle/entities/unit_entity.lua` (add sanity component)
- Modify `engine/battlescape/logic/post_battle_processor.lua` (add sanity loss)

**Implementation:**
```lua
-- Sanity range: 4-12
-- Mission stress: 0-3 sanity loss (depends on mission type/events)
-- Recovery: 1 per week + facility bonuses
-- Combat effect: Low sanity reduces AP (same as morale)
--   sanity 3 -> AP 3, sanity 2 -> AP 2, etc.
```

**Details:**
- Sanity stat on unit (starting value 6-8 based on class)
- Post-battle: calculate mission stress, reduce sanity
- Mission stress factors: enemy types, civilian casualties, unit deaths, horror events
- Weekly recovery: +1 sanity + facility bonuses
- Sanity caps at maxSanity (increases with levels)
- Low sanity warning in UI

**Estimated time:** 3 hours

---

### Step 5: Craft Repair System (2 hours)
**Description:** Implement craft damage tracking and repair over time

**Files to modify/create:**
- `engine/geoscape/systems/craft_repair_system.lua` (new)
- Modify `engine/geoscape/entities/craft.lua` (add damage tracking)

**Implementation:**
```lua
-- Craft repair:
-- Base: 20% max HP per week
-- With facilities: 20% + facility_bonus per week
-- Damaged crafts cannot deploy
```

**Details:**
- Track `craft.currentHP` and `craft.maxHP`
- Craft takes damage from interceptions
- Weekly repair: restore 20% of maxHP + bonuses
- Round up to next full HP
- Repair completion event
- Cannot deploy if currentHP < maxHP (or threshold like 50%)
- UI shows repair time in hangar

**Estimated time:** 2 hours

---

### Step 6: Base Training System (3 hours)
**Description:** Implement passive XP gain for units in base

**Files to modify/create:**
- `engine/basescape/systems/training_system.lua` (new)
- Modify `engine/battle/entities/unit_entity.lua` (add XP tracking)

**Implementation:**
```lua
-- Training XP:
-- Base: 1 XP per day (30/month, 360/year)
-- With facilities: 1 + facility_bonus XP per day
-- Continues even when wounded
-- Separate from combat XP
```

**Details:**
- Daily tick: award training XP to all units in base
- Training XP accumulates even for wounded units
- Facility bonuses are additive (Training Ground +2 XP/day)
- XP gain event for UI updates
- Training log for unit history

**Estimated time:** 3 hours

---

### Step 7: Experience Level System (4 hours)
**Description:** Implement level progression with XP thresholds and stat bonuses

**Files to modify/create:**
- `engine/basescape/systems/experience_system.lua` (new)
- `engine/data/level_config.lua` (new)
- `engine/data/class_progression.lua` (new)

**Implementation:**
```lua
-- Level thresholds:
-- Level 0: 0 XP
-- Level 1: 100 XP
-- Level 2: 300 XP
-- Level 3: 600 XP
-- Level 4: 1000 XP
-- Level 5: 1500 XP
-- Level 6: 2100 XP
-- Level 7: 2800 XP

-- Level bonuses (example):
-- +5% HP per level
-- +1 stat point per level (distributed by class)
-- +1 max sanity per 2 levels
```

**Details:**
- Check for level-up after XP gain
- Apply stat bonuses automatically
- Class-based stat progression (soldiers get aim, medics get will)
- Level-up event with UI notification
- Class promotion at specific levels (level 3, level 5)
- XP progress bar in UI

**Estimated time:** 4 hours

---

### Step 8: Unit Trait System (3 hours)
**Description:** Implement birth traits that permanently modify units

**Files to modify/create:**
- `engine/basescape/systems/trait_system.lua` (new)
- `engine/data/traits_config.lua` (new)
- Modify `engine/battle/entities/unit_entity.lua` (add trait component)

**Implementation:**
```lua
-- Example traits:
-- Smart: -20% XP needed for level up
-- Fast: +1 AP
-- Pack Mule: +25% carrying capacity
-- Lucky: +50% critical hit chance
-- Brave: +2 Will
-- Eagle Eye: +1 Sight range
-- Survivor: +10% max HP
```

**Details:**
- Trait assigned at unit creation (random or based on class)
- One trait per unit
- Permanent and non-transferable
- Traits modify base stats or XP multipliers
- Trait display in unit details
- Trait icons/descriptions in UI
- 15-20 different traits defined in config

**Estimated time:** 3 hours

---

### Step 9: Unit Transformation System (4 hours)
**Description:** Implement permanent unit transformations via base operations

**Files to modify/create:**
- `engine/basescape/systems/transformation_system.lua` (new)
- `engine/data/transformations_config.lua` (new)
- `engine/basescape/ui/transformation_facility_ui.lua` (new)

**Implementation:**
```lua
-- Transformation examples:
-- Cybernetic Enhancement: +1 AP, -1 Will, 4 weeks recovery
-- Psionic Awakening: +5 Psi, +2 Sanity, 6 weeks recovery
-- Gene Modification: +2 Strength, +10% HP, 8 weeks recovery
-- Neural Interface: +2 Aim, +1 React, 5 weeks recovery
```

**Details:**
- One transformation slot per unit
- Requires: specific facility, technology researched, resources
- Transformation process takes time (operation time + recovery time)
- Unit unavailable during transformation
- Permanent stat changes (bonuses and penalties)
- Cannot be reversed or changed
- UI shows available transformations and requirements
- Post-transformation recovery period (extended wound time)

**Estimated time:** 4 hours

---

### Step 10: Medal System (3 hours)
**Description:** Implement achievement-based medals with XP rewards

**Files to modify/create:**
- `engine/basescape/systems/medal_system.lua` (new)
- `engine/data/medals_config.lua` (new)
- Modify `engine/battlescape/logic/post_battle_processor.lua` (award medals)

**Implementation:**
```lua
-- Medal examples:
-- Marksman I: 5 kills in one mission (50 XP)
-- Marksman II: 10 kills in one mission (100 XP)
-- Survivor: Complete mission with <10% HP (75 XP)
-- Protector: No civilians died (100 XP)
-- First Blood: First kill in first mission (50 XP)
-- Veteran: 10 missions completed (150 XP)
```

**Details:**
- Post-battle: check for medal conditions
- Award medal if conditions met and not already awarded
- One-time XP bonus per medal
- Same medal cannot be earned twice (except tiered medals)
- Medal history stored on unit
- Medal display in unit details (ribbon/icon)
- 20-30 different medals defined
- UI shows medal requirements and progress

**Estimated time:** 3 hours

---

### Step 11: Wound System Enhancement (3 hours)
**Description:** Implement critical wound system with extended recovery

**Files to modify/create:**
- `engine/battlescape/systems/wound_system.lua` (new)
- Modify `engine/battlescape/combat/damage_resolver.lua` (add critical hit wounds)
- Modify `engine/basescape/systems/unit_recovery_system.lua` (wound recovery)

**Implementation:**
```lua
-- Wound mechanics:
-- Critical hit chance: base 5%, modified by weapon and traits
-- Critical hit causes: 1 wound + 1 HP loss per turn until battle ends
-- Post-battle recovery:
--   HP recovery: HP_lost * 1 week
--   Wound recovery: wounds * 3 weeks
--   Total time: max(HP_recovery, wound_recovery)
-- Medical facilities reduce wound recovery time
```

**Details:**
- Track wounds separately from HP damage
- Wounds cause bleeding (1 HP/turn) during battle
- Can be stabilized by medic action
- Post-battle: sum all HP lost from wounds
- Recovery time calculation with facility bonuses
- Wound count display in unit status
- Critical hit log in battle events

**Estimated time:** 3 hours

---

### Step 12: UI Integration (8 hours)
**Description:** Create UI elements for all recovery and progression systems

**Files to modify/create:**
- `engine/basescape/ui/unit_roster_panel.lua` (modify)
- `engine/basescape/ui/unit_details_panel.lua` (new)
- `engine/basescape/ui/recovery_tracker.lua` (new)
- `engine/basescape/ui/training_panel.lua` (new)
- `engine/basescape/ui/medal_display.lua` (new)
- `engine/basescape/ui/hangar_panel.lua` (modify for repairs)

**UI Components:**
1. **Unit Roster Panel**
   - Unit list with status (available, wounded, training, transforming)
   - Health bars, sanity bars, XP progress bars
   - Recovery time remaining
   - Sort/filter options

2. **Unit Details Panel**
   - Full unit stats
   - Trait display with icon and description
   - Transformation status (if any)
   - Medal collection with icons
   - Level and XP progress
   - Wound count and recovery estimate

3. **Recovery Tracker**
   - List of all recovering units
   - Time remaining for each
   - Medical facility bonus display
   - Estimated completion dates

4. **Training Panel**
   - Daily XP gain rate
   - Training facility bonuses
   - XP to next level for all units
   - Training efficiency stats

5. **Hangar Panel** (repairs)
   - Craft health bars
   - Repair progress bars
   - Time to full repair
   - Repair facility bonuses

**Estimated time:** 8 hours

---

### Step 13: Post-Battle Processing (4 hours)
**Description:** Implement battle results processing for wounds, sanity, XP, medals

**Files to modify/create:**
- `engine/battlescape/logic/post_battle_processor.lua` (modify)
- `engine/basescape/systems/battle_results_analyzer.lua` (new)

**Implementation:**
```lua
-- Post-battle processing:
-- 1. Calculate total damage taken by each unit
-- 2. Count wounds (critical hits) per unit
-- 3. Calculate mission stress (0-3)
-- 4. Award combat XP based on performance
-- 5. Check for medal conditions
-- 6. Apply sanity loss
-- 7. Start recovery timers
-- 8. Generate battle report
```

**Details:**
- Battle statistics tracking (kills, damage dealt, damage taken, civilians saved)
- Mission stress calculation based on mission type and events
- XP formula: base XP + kill XP + objective XP + survival XP
- Medal condition checking
- Sanity loss application
- Recovery timer initialization
- Battle report generation with all details
- Save unit states

**Estimated time:** 4 hours

---

### Step 14: Data Configuration (2 hours)
**Description:** Create configuration files for all systems

**Files to create:**
- `engine/data/unit_recovery_config.lua`
- `engine/data/level_config.lua`
- `engine/data/traits_config.lua`
- `engine/data/transformations_config.lua`
- `engine/data/medals_config.lua`
- `engine/data/mission_stress_config.lua`
- `engine/data/facility_bonuses_config.lua`

**Configuration includes:**
- Recovery rates (HP, sanity, craft)
- XP thresholds for each level
- Stat bonuses per level per class
- All trait definitions
- All transformation definitions
- All medal definitions and conditions
- Mission stress factors
- Facility bonus amounts

**Estimated time:** 2 hours

---

### Step 15: Testing (6 hours)
**Description:** Comprehensive testing of all systems

**Files to create:**
- `engine/tests/test_unit_recovery.lua`
- `engine/tests/test_sanity_system.lua`
- `engine/tests/test_craft_repair.lua`
- `engine/tests/test_training_system.lua`
- `engine/tests/test_experience_levels.lua`
- `engine/tests/test_traits.lua`
- `engine/tests/test_transformations.lua`
- `engine/tests/test_medals.lua`
- `engine/tests/test_wounds.lua`

**Test cases:**
- Unit heals correctly over time
- Facility bonuses apply correctly
- Wound recovery calculation is accurate
- Sanity loss and recovery works
- Craft repairs at correct rate
- Training awards XP daily
- Level-ups occur at correct thresholds
- Traits apply correctly to stats
- Transformations work and have recovery time
- Medals award XP only once
- Critical hits cause wounds
- Time progression works correctly

**Estimated time:** 6 hours

---

## Implementation Details

### Architecture

**Component-Based Unit System:**
- `unit.health` - HP, maxHP, wounds, healing rate
- `unit.sanity` - current, max, recovery rate
- `unit.experience` - XP, level, next level threshold
- `unit.trait` - single trait with modifiers
- `unit.transformation` - single transformation (if any)
- `unit.medals` - array of earned medals
- `unit.recovery` - recovery timer and type

**Event-Driven Time System:**
- TimeManager emits events: `onDailyTick`, `onWeeklyTick`, `onMonthlyTick`
- Systems subscribe to relevant events
- Daily: training XP, time-based checks
- Weekly: HP/sanity recovery, craft repairs
- Monthly: salaries, reports, maintenance

**Facility Bonus Aggregation:**
- Each facility type defines bonuses
- FacilityBonusCalculator sums all active facility bonuses
- Cached results, invalidated on facility changes
- Query by bonus type: "medical", "training", "repair", "support"

**Post-Battle Pipeline:**
1. Battle ends → BattleResultsAnalyzer processes stats
2. Calculate damage, wounds, kills, objectives
3. Award combat XP based on performance
4. Check medal conditions → award medals → award XP bonuses
5. Calculate mission stress → reduce sanity
6. Calculate recovery time (HP + wounds)
7. Initialize recovery timers
8. Generate battle report
9. Return to base → update unit states

### Key Components

**TimeManager:**
- Tracks days, weeks, months
- Configurable time speed
- Pause/resume
- Event emission
- Save/load support

**UnitRecoverySystem:**
- Weekly HP recovery
- Wound recovery tracking
- Medical facility bonus application
- Recovery completion detection
- Status queries (isWounded, recoveryTimeRemaining)

**SanitySystem:**
- Sanity stat management
- Mission stress application
- Weekly recovery
- Support facility bonuses
- Low sanity effects on combat AP

**TrainingSystem:**
- Daily XP awards
- Training facility bonuses
- Training log
- XP gain events

**ExperienceSystem:**
- Level-up detection
- Stat bonus application
- Class promotion
- Level-up events

**TraitSystem:**
- Trait assignment at creation
- Stat modifier application
- Trait queries

**TransformationSystem:**
- Transformation operations
- Resource/tech requirements
- Operation time tracking
- Post-operation recovery
- Permanent stat changes

**MedalSystem:**
- Medal condition checking
- Award tracking (prevent duplicates)
- XP bonus application
- Medal display data

**CraftRepairSystem:**
- Weekly repair progress
- Repair facility bonuses
- Repair completion detection

### Dependencies

**Existing Systems:**
- `core/state_manager.lua` - State transitions
- `battle/entities/unit_entity.lua` - Base unit structure
- `geoscape/entities/craft.lua` - Craft structure
- `basescape/systems/facility_bonus_calculator.lua` - Facility bonuses
- `widgets/` - UI components

**New Systems:**
- Time management (calendar, ticks)
- Recovery tracking
- Experience progression
- Trait/transformation management

**Data Files:**
- Configuration for all systems
- Balance values
- Trait/transformation/medal definitions

---

## Testing Strategy

### Unit Tests

**Recovery System:**
- Test HP recovery rate (1/week base)
- Test facility bonus stacking
- Test wound recovery calculation
- Test recovery completion detection
- Test wounded unit deployment prevention

**Sanity System:**
- Test sanity loss from missions (0-3 range)
- Test weekly recovery (1/week base)
- Test facility bonuses
- Test low sanity AP reduction
- Test sanity stat increases with levels

**Training System:**
- Test daily XP gain (1/day base)
- Test facility bonuses
- Test XP gain for wounded units
- Test training continues during recovery

**Experience System:**
- Test level-up at correct XP thresholds
- Test stat bonuses application
- Test XP progress tracking
- Test class promotion

**Trait System:**
- Test trait assignment at creation
- Test trait stat modifiers
- Test Smart trait (-20% XP needed)
- Test Fast trait (+1 AP)
- Test trait persistence

**Transformation System:**
- Test transformation application
- Test resource requirements
- Test stat changes (bonus and penalty)
- Test recovery period
- Test one transformation limit

**Medal System:**
- Test medal condition detection
- Test XP award
- Test duplicate prevention
- Test tiered medals (I, II, III)

**Wound System:**
- Test critical hit wound assignment
- Test bleeding damage (1 HP/turn)
- Test wound recovery time (3 weeks/wound)
- Test total recovery calculation

### Integration Tests

**Time Progression:**
- Test daily tick triggers training XP
- Test weekly tick triggers recovery
- Test multiple weeks advance correctly
- Test time speeds (1x, 5x, 30x)

**Post-Battle Flow:**
- Test full battle → recovery flow
- Test multiple units wounded
- Test sanity loss application
- Test medal awards
- Test battle report generation

**UI Integration:**
- Test unit roster displays correctly
- Test recovery timers count down
- Test XP progress bars update
- Test medal display
- Test trait/transformation display

**Save/Load:**
- Test all unit states save correctly
- Test recovery timers persist
- Test XP/level persist
- Test traits/transformations persist
- Test medals persist

### Manual Testing Steps

1. **Basic Recovery:**
   - Start game, wound a unit in battle
   - Advance time 1 week
   - Verify unit gained 1 HP
   - Build medical facility
   - Advance time 1 week
   - Verify faster healing

2. **Training System:**
   - Check unit XP (e.g., 50)
   - Advance time 7 days
   - Verify unit has 57 XP (7 days × 1 XP/day)
   - Build training facility
   - Advance time 7 days
   - Verify accelerated XP gain

3. **Level Up:**
   - Set unit to 95 XP
   - Advance time 5 days (to 100 XP)
   - Verify level-up occurs
   - Check stat bonuses applied
   - Verify UI shows level 1

4. **Sanity System:**
   - Complete stressful mission
   - Verify sanity decreased (check UI)
   - Advance time 1 week
   - Verify sanity increased by 1
   - Test low sanity in combat (reduced AP)

5. **Wound System:**
   - Cause critical hit in battle
   - Verify wound assigned and bleeding occurs
   - After battle, verify recovery time = (HP lost × 1) + (wounds × 3) weeks
   - Advance time and verify recovery

6. **Medals:**
   - Complete mission with 5+ kills
   - Verify "Marksman I" medal awarded
   - Verify 50 XP bonus applied
   - Attempt to earn same medal again → verify it's not awarded

7. **Transformations:**
   - Build transformation facility
   - Research required tech
   - Apply cybernetic enhancement
   - Verify unit unavailable during operation
   - Verify stat changes after completion
   - Verify cannot apply second transformation

8. **Craft Repair:**
   - Damage craft in interception
   - Advance time 1 week
   - Verify 20% HP restored
   - Build repair facility
   - Advance time 1 week
   - Verify faster repair

### Expected Results

- All recovery systems advance correctly with time
- Facility bonuses apply and stack properly
- XP gains work for both training and combat
- Level-ups occur at correct thresholds with stat bonuses
- Traits affect units correctly and permanently
- Transformations apply with operation time and recovery
- Medals award XP bonuses once per type
- Wounds extend recovery time correctly
- Sanity affects mission outcomes and recovers over time
- UI displays all information correctly and updates in real-time
- Save/load preserves all states
- No crashes or errors in Love2D console

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging

**Love2D Console:**
- Console is enabled in `conf.lua` (t.console = true)
- Check console for debug output from all systems

**Debug Print Statements:**
```lua
print("[UnitRecovery] Unit " .. unit.name .. " healed 1 HP")
print("[Training] Unit " .. unit.name .. " gained " .. xp .. " XP")
print("[SanitySystem] Mission stress: " .. stress .. ", new sanity: " .. unit.sanity)
print("[MedalSystem] Awarded " .. medal.name .. " to " .. unit.name)
```

**Time System Debugging:**
```lua
-- Speed up time for testing
TimeManager.setSpeed(30) -- 30x speed

-- Jump forward in time
TimeManager.advanceDays(7) -- Jump 1 week

-- Check current time
print("[TimeManager] Day: " .. TimeManager.getCurrentDay())
```

**Recovery Debugging:**
```lua
-- Check recovery status
local time = UnitRecoverySystem.getRecoveryTime(unit)
print("[Debug] Unit recovery time remaining: " .. time .. " days")

-- Check facility bonuses
local bonus = FacilityBonusCalculator.getMedicalBonus(base)
print("[Debug] Medical bonus: " .. bonus .. " HP/week")
```

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")` or `love.filesystem.getSaveDirectory()`
- Never create temp files in project directories

### Test Commands
```lua
-- In-game debug console commands (if implemented)
/heal <unit_id> -- Fully heal unit
/xp <unit_id> <amount> -- Add XP
/advance <days> -- Advance time
/wound <unit_id> <count> -- Add wounds
/sanity <unit_id> <amount> -- Set sanity
/medal <unit_id> <medal_name> -- Award medal
```

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add TimeManager, UnitRecoverySystem, SanitySystem, ExperienceSystem APIs
- [x] `wiki/FAQ.md` - Add FAQ entries about recovery, training, levels, medals
- [x] `wiki/DEVELOPMENT.md` - Add development workflow for recovery/progression systems
- [ ] `wiki/wiki/units.md` - Update with detailed recovery, progression, trait, transformation, medal info
- [ ] `wiki/wiki/facilities.md` - Update with medical, training, support, repair facility details
- [ ] `wiki/wiki/time.md` - Create new doc for time management system
- [ ] `engine/basescape/systems/README.md` - Document all new systems
- [ ] Code comments - Add comprehensive inline documentation

---

## Notes

### Design Considerations

**Balance:**
- Recovery rates are deliberately slow to encourage roster rotation
- Training provides steady progression (360 XP/year = 3 levels)
- Wounds add significant penalty (3 weeks each) to emphasize tactical caution
- Sanity system creates long-term consequences for difficult missions
- Traits provide variety without being overpowered
- Transformations are powerful but limited (one per unit)
- Medals reward specific achievements with meaningful XP boosts

**Player Experience:**
- Clear feedback on recovery times and progress
- Multiple paths to unit improvement (combat, training, medals)
- Strategic depth through facility choices
- Long-term investment in veteran units
- Risk/reward in mission selection (sanity loss consideration)

**Integration with Existing Systems:**
- Works with existing unit/craft structures
- Extends battle system with post-battle processing
- Integrates with facility system for bonuses
- Compatible with save/load system
- Fits into basescape UI

**Moddability:**
- All rates configurable in data files
- Easy to add new traits/transformations/medals
- Facility bonuses defined in facility configs
- XP thresholds and level bonuses configurable
- Mission stress factors data-driven

### Polish and Future Enhancements

**Phase 2 Enhancements (Future):**
- Advanced training: specialized training courses
- Therapy system: active sanity improvement
- Surgery: permanent stat improvements with risk
- Veteran bonuses: additional perks at high levels
- Unit biography: auto-generated history
- Hall of Fame: memorial for fallen soldiers
- Advanced medals: mission chains, long-term achievements
- Trait development: earn secondary traits through combat
- Transformation upgrades: improve existing transformations
- Recovery minigames: speed up recovery through player interaction

---

## Blockers

**Dependencies:**
- Need base facility system to be functional for bonus aggregation
- Need geoscape craft system to be functional for repair system
- Need battle system to be functional for post-battle processing
- Need save/load system to persist all new data

**Technical Blockers:**
- None currently identified

**Design Blockers:**
- None currently identified

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console
- [ ] All systems integrated with existing codebase
- [ ] UI is grid-aligned (24×24 pixel grid)
- [ ] Save/load works correctly
- [ ] Balance values tested and reasonable
- [ ] Player feedback is clear and helpful

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)

---

## Time Estimates Summary

| Phase | Description | Time |
|-------|-------------|------|
| 1 | Time Management Foundation | 3 hours |
| 2 | Facility Bonus System | 2 hours |
| 3 | Unit Health Recovery System | 4 hours |
| 4 | Sanity System | 3 hours |
| 5 | Craft Repair System | 2 hours |
| 6 | Base Training System | 3 hours |
| 7 | Experience Level System | 4 hours |
| 8 | Unit Trait System | 3 hours |
| 9 | Unit Transformation System | 4 hours |
| 10 | Medal System | 3 hours |
| 11 | Wound System Enhancement | 3 hours |
| 12 | UI Integration | 8 hours |
| 13 | Post-Battle Processing | 4 hours |
| 14 | Data Configuration | 2 hours |
| 15 | Testing | 6 hours |
| **TOTAL** | **All Phases** | **54 hours** |

**Estimated completion time: 6-7 working days (8 hour days)**

---

## Implementation Priority

**Critical Path:**
1. Time Management (enables all other systems)
2. Facility Bonus System (required by recovery systems)
3. Unit Health Recovery (core gameplay)
4. Base Training (core progression)
5. Experience Levels (completes progression)
6. UI Integration (makes systems visible/usable)

**Secondary Features:**
7. Sanity System (adds depth)
8. Trait System (adds variety)
9. Medal System (adds rewards)
10. Wound System (adds consequence)

**Advanced Features:**
11. Transformation System (late-game content)
12. Craft Repair (geoscape integration)

**Can be implemented in parallel:**
- Trait System + Medal System (no dependencies)
- Craft Repair + Wound System (independent)
- UI can be built alongside backend systems

---

## Data Structure Examples

### Unit Extended Data
```lua
unit = {
    -- Existing fields
    id = "unit_001",
    name = "John Doe",
    class = "soldier",
    
    -- New fields for this task
    experience = {
        currentXP = 250,
        level = 1,
        nextLevelXP = 300
    },
    
    health = {
        currentHP = 80,
        maxHP = 100,
        wounds = 1,
        healingRate = 1 -- HP per week
    },
    
    sanity = {
        current = 7,
        max = 10,
        recoveryRate = 1 -- per week
    },
    
    trait = {
        id = "trait_smart",
        name = "Smart",
        description = "Learns 20% faster",
        modifiers = {
            xpMultiplier = 0.8 -- 20% less XP needed
        }
    },
    
    transformation = nil, -- or { id, name, bonuses, penalties }
    
    medals = {
        {id = "medal_marksman_1", name = "Marksman I", xpAwarded = 50, dateEarned = "2025-01-15"},
        {id = "medal_survivor", name = "Survivor", xpAwarded = 75, dateEarned = "2025-02-03"}
    },
    
    recovery = {
        isRecovering = true,
        startDay = 100,
        totalDays = 21, -- 3 weeks
        recoveryType = "wound"
    }
}
```

### Craft Extended Data
```lua
craft = {
    id = "craft_001",
    name = "Skyranger-1",
    type = "transport",
    
    health = {
        currentHP = 600,
        maxHP = 1000,
        repairRate = 200 -- 20% of maxHP per week
    },
    
    repairs = {
        isRepairing = true,
        startDay = 105,
        estimatedCompletionDay = 110
    }
}
```

### Time State
```lua
TimeManager = {
    currentDay = 150,
    currentWeek = 21,
    currentMonth = 5,
    
    timeSpeed = 1, -- 1x, 5x, 30x
    isPaused = false,
    
    -- Callbacks
    dailyCallbacks = {},
    weeklyCallbacks = {},
    monthlyCallbacks = {}
}
```

### Facility Bonus Data
```lua
-- In facility config
{
    id = "fac_medical_bay",
    name = "Medical Bay",
    bonuses = {
        healingBonus = 1, -- +1 HP/week
        woundRecoveryBonus = 0.5 -- -50% wound recovery time
    }
}

{
    id = "fac_training_ground",
    name = "Training Ground",
    bonuses = {
        trainingXPBonus = 5 -- +5 XP per week
    }
}
```
