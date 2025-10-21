# TASK-027 Quick Reference - Unit Recovery & Progression System

## Overview
Complete unit recovery and progression system with base training, healing, sanity management, and character development.

---

## Core Mechanics Summary

### Recovery Rates (Base Values)
| System | Base Rate | Facility Bonus | Max with Facilities |
|--------|-----------|----------------|---------------------|
| HP Healing | 1 HP/week | +1-3 HP/week | 4 HP/week |
| Sanity Recovery | 1/week | +1-2/week | 3/week |
| Craft Repair | 20%/week | +10-30%/week | 50%/week |
| Base Training | 1 XP/day | +5-15 XP/week | ~3 XP/day |
| Wound Recovery | 3 weeks/wound | -50% time | 1.5 weeks/wound |

### Experience Levels
```
Level 0:    0 XP (starting)
Level 1:  100 XP
Level 2:  300 XP
Level 3:  600 XP
Level 4: 1000 XP
Level 5: 1500 XP
Level 6: 2100 XP
Level 7: 2800 XP
```

**XP Sources:**
- Base training: 1/day (30/month, 360/year)
- Combat: Variable (10-100 per mission)
- Medals: 50-150 one-time bonuses

**Level-Up Bonuses (example):**
- +5% HP per level
- +1-2 primary stat per level (class-dependent)
- +1 max sanity per 2 levels
- Class promotion at levels 3 and 5

---

## Unit Systems

### Trait System
**Assignment:** At unit creation (random or class-based)
**Quantity:** One trait per unit (permanent)
**Examples:**
- **Smart**: -20% XP needed for level-up
- **Fast**: +1 AP (total 5 instead of 4)
- **Pack Mule**: +25% carrying capacity
- **Lucky**: +50% critical hit chance
- **Brave**: +2 Will stat
- **Eagle Eye**: +1 Sight range
- **Survivor**: +10% max HP
- **Steady**: +10% accuracy
- **Quick Reflexes**: +1 Reaction stat
- **Strong**: +2 Strength stat

### Transformation System
**Quantity:** One transformation slot per unit
**Requirements:** Facility + Technology + Resources + Time
**Operation Time:** 1-2 weeks
**Recovery Time:** 4-8 weeks (extended wound time)
**Permanent:** Cannot be removed or changed

**Examples:**
- **Cybernetic Enhancement**: +1 AP, -1 Will, 4 weeks recovery
- **Psionic Awakening**: +5 Psi, +2 Sanity, 6 weeks recovery
- **Gene Modification**: +2 Strength, +10% HP, 8 weeks recovery
- **Neural Interface**: +2 Aim, +1 React, 5 weeks recovery
- **Bio-Enhancement**: +20% HP, -1 AP, 4 weeks recovery

### Medal System
**Award Condition:** Complete specific achievement in mission
**XP Bonus:** 50-150 XP (one-time)
**Duplication:** Same medal cannot be earned twice
**Tiered:** Some medals have levels (I, II, III)

**Examples:**
- **Marksman I**: 5 kills in one mission (50 XP)
- **Marksman II**: 10 kills in one mission (100 XP)
- **Marksman III**: 20 kills in one mission (150 XP)
- **Survivor**: Complete mission with <10% HP (75 XP)
- **Protector**: No civilians died (100 XP)
- **First Blood**: First kill in first mission (50 XP)
- **Veteran**: 10 missions completed (150 XP)
- **Hero**: Save 5+ civilians in one mission (100 XP)
- **Fearless**: Never panic in 5 consecutive missions (100 XP)
- **Sniper Elite**: 5 kills at 20+ tile range (100 XP)

### Wound System
**Cause:** Critical hits in combat
**Effect During Battle:** 1 HP loss per turn (bleeding)
**Post-Battle Recovery:** 3 weeks per wound (+ HP recovery time)
**Medical Aid:** Medic action can stabilize (stop bleeding)

**Recovery Formula:**
```
Total Recovery Time = (HP Lost × 1 week) + (Wounds × 3 weeks)
Example: 30 HP lost + 2 wounds = 30 days + 42 days = 72 days (10.3 weeks)
```

### Sanity System
**Range:** 4-12 (starting 6-8 based on class)
**Mission Stress:** 0-3 sanity loss per mission
**Recovery:** 1/week + facility bonuses
**Combat Effect:** Low sanity reduces AP
  - Sanity 3 → 3 AP
  - Sanity 2 → 2 AP
  - Sanity 1 → 1 AP
  - Sanity 0 → 0 AP (unit cannot act)

**Stress Factors:**
- Mission difficulty: 0-1
- Enemy types (horror): 0-1
- Civilian casualties: 0-1
- Unit deaths witnessed: 0-1
- Horror events: 0-1

**Stress Levels:**
- Easy mission, no horror: 0-1 stress
- Normal mission: 1-2 stress
- Hard mission with horror: 2-3 stress
- Nightmare mission: 3 stress

---

## Time Management

### Time Progression
- **1 Turn = 1 Day**
- **1 Week = 7 Days**
- **1 Month = 30 Days**
- **1 Year = 360 Days**

### Event Schedule
- **Daily Tick**: Base training (+1 XP per unit)
- **Weekly Tick**: HP recovery, sanity recovery, craft repairs
- **Monthly Tick**: Salaries, maintenance, monthly report

### Time Speed Options
- **1x**: Real-time (default)
- **5x**: Fast forward (skip waiting)
- **30x**: Very fast (testing/long recovery)
- **Pause**: Stop time progression

---

## Facility Bonuses

### Medical Facilities
- **Basic Medical Bay**: +1 HP/week, -25% wound time
- **Advanced Hospital**: +2 HP/week, -50% wound time
- **Trauma Center**: +3 HP/week, -50% wound time

### Training Facilities
- **Training Ground**: +5 XP/week bonus
- **Combat Simulator**: +10 XP/week bonus
- **Elite Academy**: +15 XP/week bonus

### Support Facilities
- **Recreation Center**: +1 sanity/week
- **Psychological Clinic**: +2 sanity/week

### Repair Facilities
- **Basic Workshop**: +10% craft repair/week
- **Advanced Hangar**: +20% craft repair/week
- **Engineering Bay**: +30% craft repair/week

---

## UI Components

### Unit Roster Panel
- Unit list with status indicators
- Health bars (green), Sanity bars (blue), XP bars (yellow)
- Recovery time display
- Filter: All, Available, Wounded, Training, Transforming
- Sort: Name, Level, Health, Sanity, Recovery Time

### Unit Details Panel
- Full stats display
- Trait icon and description
- Transformation status (if any)
- Medal collection (icons)
- Level and XP progress bar
- Wound count and recovery estimate
- Battle history

### Recovery Tracker
- List of recovering units
- Days remaining for each
- Medical facility bonus indicator
- Estimated completion dates

### Training Panel
- Daily XP gain rate per unit
- Training facility bonuses
- Days to next level for each unit
- Training efficiency stats

### Hangar Panel (Craft Repairs)
- Craft list with health bars
- Repair progress bars
- Time to full repair
- Repair facility bonuses
- Deploy availability indicator

---

## Post-Battle Processing

### Battle Results Analysis
1. **Damage Calculation**: Sum HP lost per unit
2. **Wound Counting**: Count critical hits per unit
3. **Mission Stress**: Calculate stress factors (0-3)
4. **Combat XP**: Award XP based on performance
5. **Medal Check**: Check for medal conditions
6. **Sanity Loss**: Apply mission stress to all units
7. **Recovery Start**: Initialize recovery timers
8. **Report Generation**: Create detailed battle report

### Combat XP Formula
```
Base XP = 10 (mission participation)
Kill XP = kills × 5
Objective XP = objectives × 20
Survival Bonus = 10 if unit survived
Medal Bonus = 50-150 (if medal earned)

Total XP = Base + Kills + Objectives + Survival + Medals
```

---

## Implementation Phases

### Critical Path (Week 1)
1. **Day 1**: Time Management (3h) + Facility Bonuses (2h)
2. **Day 2**: HP Recovery (4h) + Sanity System (3h)
3. **Day 3**: Craft Repair (2h) + Base Training (3h) + Start XP System (1h)
4. **Day 4**: Experience Levels (3h) + Trait System (3h) + Start UI (2h)
5. **Day 5**: UI Integration (6h) + Testing (2h)

### Secondary Features (Week 2)
6. **Day 6**: Transformation System (4h) + Medal System (3h) + Testing (1h)
7. **Day 7**: Wound System (3h) + Post-Battle (4h) + Testing (1h)
8. **Day 8**: UI Polish (4h) + Data Config (2h) + Integration (2h)
9. **Day 9**: Testing & Bug Fixes (8h)
10. **Day 10**: Documentation (4h) + Final Testing (4h)

---

## Testing Checklist

### Unit Recovery
- [ ] Unit heals 1 HP per week (base)
- [ ] Medical facility bonus applies correctly
- [ ] Wounded units cannot deploy
- [ ] Recovery completion triggers event
- [ ] Multiple wounds extend recovery time correctly

### Sanity System
- [ ] Mission stress reduces sanity (0-3 range)
- [ ] Weekly recovery works (1 + bonuses)
- [ ] Low sanity reduces AP in combat
- [ ] Sanity increases with level-ups
- [ ] Support facilities accelerate recovery

### Training System
- [ ] Units gain 1 XP per day
- [ ] Training continues for wounded units
- [ ] Training facility bonuses stack
- [ ] XP gain events trigger
- [ ] Training XP separate from combat XP

### Experience System
- [ ] Level-ups occur at correct thresholds
- [ ] Stat bonuses apply correctly
- [ ] Class promotions work
- [ ] XP progress displays correctly
- [ ] Smart trait reduces XP requirements

### Trait System
- [ ] Traits assigned at creation
- [ ] Traits persist through save/load
- [ ] Trait modifiers apply correctly
- [ ] Fast trait grants +1 AP
- [ ] Lucky trait increases crit chance

### Transformation System
- [ ] Requires correct facility + tech + resources
- [ ] Operation time passes correctly
- [ ] Recovery period extends wounds
- [ ] Stat changes permanent
- [ ] Cannot apply second transformation

### Medal System
- [ ] Medal conditions checked post-battle
- [ ] XP bonus awarded once
- [ ] Same medal not awarded twice
- [ ] Tiered medals work (I, II, III)
- [ ] Medals display in UI

### Wound System
- [ ] Critical hits cause wounds
- [ ] Wounds cause 1 HP/turn bleeding
- [ ] Each wound adds 3 weeks recovery
- [ ] Medical aid can stabilize
- [ ] Total recovery time calculated correctly

### Craft Repair
- [ ] Crafts repair 20% per week
- [ ] Repair facility bonuses apply
- [ ] Damaged crafts cannot deploy
- [ ] Repair completion triggers event

### UI
- [ ] All panels display correctly
- [ ] Data updates in real-time
- [ ] Recovery timers count down
- [ ] XP progress bars update
- [ ] Trait/medal/transformation display works
- [ ] Grid alignment (24×24 pixels)

### Integration
- [ ] Time system integrates with calendar
- [ ] Facility bonuses recalculate on changes
- [ ] Post-battle processing works
- [ ] Save/load preserves all states
- [ ] No console errors or warnings

---

## Debug Commands

### Time Control
```lua
TimeManager.setSpeed(30)           -- 30x speed
TimeManager.advanceDays(7)         -- Jump 1 week
TimeManager.pause()                -- Pause time
TimeManager.resume()               -- Resume time
print(TimeManager.getCurrentDay()) -- Check current day
```

### Unit Manipulation
```lua
-- Heal unit
unit.health.currentHP = unit.health.maxHP
unit.health.wounds = 0

-- Add XP
ExperienceSystem.awardXP(unit, 100)

-- Add wound
unit.health.wounds = unit.health.wounds + 1

-- Set sanity
unit.sanity.current = 10

-- Award medal
MedalSystem.awardMedal(unit, "medal_marksman_1")
```

### Facility Bonuses
```lua
local healingBonus = FacilityBonusCalculator.getMedicalBonus(base)
local trainingBonus = FacilityBonusCalculator.getTrainingBonus(base)
local repairBonus = FacilityBonusCalculator.getRepairBonus(base)
print("Healing: " .. healingBonus .. " HP/week")
print("Training: " .. trainingBonus .. " XP/week")
print("Repair: " .. repairBonus .. "% HP/week")
```

---

## Balance Notes

### Recovery Times (Examples)
- **Minor wound** (10 HP, 0 wounds): 10 days (1.4 weeks)
- **Moderate wound** (30 HP, 1 wound): 51 days (7.3 weeks)
- **Severe wound** (50 HP, 2 wounds): 92 days (13.1 weeks)
- **Critical wound** (80 HP, 3 wounds): 143 days (20.4 weeks)

### XP Progression (Examples)
- **Training only** (1/day): 100 days to Level 1, 300 days to Level 2
- **With basic facility** (+5/week): ~85 days to Level 1, ~250 days to Level 2
- **Training + Combat**: ~2-3 months to Level 1, ~4-6 months to Level 2
- **With medals**: Can gain 1-2 levels instantly from high-XP medals

### Sanity Management
- **Easy missions** (0-1 stress): Manageable with base recovery
- **Normal missions** (1-2 stress): Need rotation or facilities
- **Hard missions** (2-3 stress): Heavy facility investment required
- **Nightmare missions** (3 stress): Consider veteran units only

---

## Files Created

### Core Systems
- `engine/core/time_manager.lua`
- `engine/core/calendar.lua`

### Basescape Systems
- `engine/basescape/systems/facility_bonus_calculator.lua`
- `engine/basescape/systems/unit_recovery_system.lua`
- `engine/basescape/systems/sanity_system.lua`
- `engine/basescape/systems/training_system.lua`
- `engine/basescape/systems/experience_system.lua`
- `engine/basescape/systems/trait_system.lua`
- `engine/basescape/systems/transformation_system.lua`
- `engine/basescape/systems/medal_system.lua`
- `engine/basescape/systems/battle_results_analyzer.lua`

### Geoscape Systems
- `engine/geoscape/systems/craft_repair_system.lua`

### Battlescape Systems
- `engine/battlescape/systems/wound_system.lua`

### Data Configuration
- `engine/data/unit_recovery_config.lua`
- `engine/data/level_config.lua`
- `engine/data/traits_config.lua`
- `engine/data/transformations_config.lua`
- `engine/data/medals_config.lua`
- `engine/data/mission_stress_config.lua`
- `engine/data/facility_bonuses_config.lua`

### UI Components
- `engine/basescape/ui/unit_roster_panel.lua`
- `engine/basescape/ui/unit_details_panel.lua`
- `engine/basescape/ui/recovery_tracker.lua`
- `engine/basescape/ui/training_panel.lua`
- `engine/basescape/ui/medal_display.lua`
- `engine/basescape/ui/transformation_facility_ui.lua`

### Tests
- `engine/tests/test_unit_recovery.lua`
- `engine/tests/test_sanity_system.lua`
- `engine/tests/test_craft_repair.lua`
- `engine/tests/test_training_system.lua`
- `engine/tests/test_experience_levels.lua`
- `engine/tests/test_traits.lua`
- `engine/tests/test_transformations.lua`
- `engine/tests/test_medals.lua`
- `engine/tests/test_wounds.lua`

### Modified Files
- `engine/battle/entities/unit_entity.lua` (add XP, sanity, trait, wounds)
- `engine/geoscape/entities/craft.lua` (add repair tracking)
- `engine/battlescape/logic/post_battle_processor.lua` (add processing)
- `engine/battlescape/combat/damage_resolver.lua` (add critical wounds)
- `engine/basescape/ui/hangar_panel.lua` (add repair display)

---

## Integration Points

### With Existing Systems
- **Battle System**: Post-battle processing, wound assignment
- **Facility System**: Bonus aggregation, facility effects
- **Geoscape**: Craft repair, deployment restrictions
- **Save/Load**: Persist all new unit/craft states
- **UI System**: Widget integration, theme application

### Event System
- `onDailyTick`: Training XP awards
- `onWeeklyTick`: Recovery processing
- `onMonthlyTick`: Reports, maintenance
- `onLevelUp`: UI notifications, stat updates
- `onMedalAwarded`: UI notifications, XP bonus
- `onRecoveryComplete`: Unit availability update
- `onTransformationComplete`: Unit stat update

---

## Polish & Future Enhancements

### Phase 2 Ideas
- **Advanced Training**: Specialized courses (sniper, medic, etc.)
- **Active Therapy**: Speed up sanity recovery with resources
- **Surgery System**: Permanent stat improvements with risks
- **Veteran Bonuses**: Special abilities at high levels
- **Biography System**: Auto-generated unit history
- **Hall of Fame**: Memorial for fallen heroes
- **Medal Chains**: Multi-mission achievement paths
- **Secondary Traits**: Earn additional traits through combat
- **Transformation Upgrades**: Improve existing enhancements
- **Recovery Minigames**: Interactive recovery speedup

---

**Last Updated:** October 13, 2025
**Document Version:** 1.0
**Task Status:** TODO
**Estimated Duration:** 54 hours (6-7 days)
