# TASK-027 Implementation Summary

## Quick Overview

**Task:** Unit Recovery, Progression & Base Training System  
**Priority:** High  
**Duration:** 54 hours (6-7 days)  
**Status:** TODO - Ready to implement  
**Files:** 25+ new files, 5 modified files  

---

## What This Task Delivers

### Player-Facing Features

1. **Unit Recovery Management**
   - Wounded soldiers heal over time in base
   - Medical facilities speed up recovery
   - Critical wounds add significant recovery time
   - Clear UI showing recovery progress

2. **Mental Health System**
   - Sanity tracking (4-12 range)
   - Mission stress affects long-term mental health
   - Support facilities help recovery
   - Low sanity reduces combat effectiveness

3. **Experience Progression**
   - Units gain XP from training (1/day) and combat
   - 7 levels with meaningful stat improvements
   - Class promotions at key levels
   - Training facilities accelerate growth

4. **Character Uniqueness**
   - Birth traits make each unit unique
   - Transformations offer powerful late-game choices
   - Medal system rewards achievements
   - Each veteran has their own story

5. **Strategic Depth**
   - Roster rotation required (wounded units)
   - Facility choices matter (medical vs training vs support)
   - Risk/reward in mission selection
   - Long-term investment in veteran soldiers

---

## Core Gameplay Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                        STRATEGIC LAYER                          │
│                                                                 │
│  BASESCAPE                                                      │
│  ├── Build facilities (medical, training, support)             │
│  ├── Manage unit roster                                        │
│  ├── Monitor recovery timers                                   │
│  └── Assign units to missions                                  │
│                                                                 │
│  GEOSCAPE                                                       │
│  ├── Select missions                                           │
│  ├── Deploy available units                                    │
│  └── Balance risk vs reward                                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                        TACTICAL LAYER                           │
│                                                                 │
│  BATTLESCAPE                                                    │
│  ├── Fight tactical combat                                     │
│  ├── Try to minimize casualties                                │
│  ├── Achieve mission objectives                                │
│  └── Earn medals and XP                                        │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CONSEQUENCE LAYER                            │
│                                                                 │
│  POST-BATTLE                                                    │
│  ├── Units wounded → recovery time                             │
│  ├── Sanity lost → need recovery                               │
│  ├── XP gained → progression                                   │
│  └── Medals earned → bonuses                                   │
│                                                                 │
│  TIME PASSES                                                    │
│  ├── Daily: training XP accumulates                            │
│  ├── Weekly: units heal, sanity recovers                       │
│  └── Units become available again                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         └──► RETURN TO STRATEGIC LAYER
```

---

## Integration with Game Systems

### Existing Systems Enhanced

**Battle System (Battlescape)**
- Critical hits now cause wounds
- Battle statistics tracked for medals
- Post-battle processing pipeline

**Base Management (Basescape)**
- Facilities provide recovery/training bonuses
- Unit roster management enhanced
- Strategic facility placement decisions

**Time System (Core)**
- Calendar system with daily/weekly/monthly ticks
- Time progression drives recovery and training

**UI System (Widgets)**
- New panels for unit management
- Recovery progress visualization
- Experience and progression display

### New Systems Created

**Recovery System**
- HP, sanity, craft repair over time
- Facility bonus aggregation
- Recovery timer management

**Progression System**
- XP tracking and level-ups
- Stat improvements
- Class promotions

**Character Development**
- Trait system (birth modifiers)
- Transformation system (base operations)
- Medal system (achievements)

**Wound System**
- Critical wound tracking
- Extended recovery mechanics
- Medical treatment

---

## Balance Philosophy

### Design Goals

1. **Meaningful Consequences**
   - Combat wounds have real impact (weeks of recovery)
   - Difficult missions affect long-term mental health
   - Veterans are valuable but not invincible

2. **Strategic Choices**
   - Medical facilities vs training facilities vs support facilities
   - Which missions to accept (risk vs reward)
   - Which units to deploy (veterans vs rookies)

3. **Progressive Difficulty**
   - Early game: plenty of time to recover
   - Mid game: need roster rotation
   - Late game: facility investment pays off

4. **Long-term Investment**
   - Training provides steady progression (360 XP/year)
   - Facilities compound benefits
   - Veterans worth protecting

### Key Balance Points

**Recovery Times:**
- Minor wounds: 1-2 weeks (manageable)
- Moderate wounds: 5-7 weeks (rotate roster)
- Severe wounds: 10-15 weeks (significant impact)
- Critical wounds: 15-20 weeks (consider replacement)

**XP Progression:**
- Level 1: ~2-3 months (with combat)
- Level 2: ~5-6 months (with combat)
- Level 3: ~10-12 months (veteran status)
- Level 4+: 1.5-2+ years (elite units)

**Sanity Management:**
- Easy missions: negligible impact
- Normal missions: slow drain
- Hard missions: requires facilities
- Nightmare missions: heavy investment needed

**Facility ROI:**
- Basic facilities: payback in 3-6 months
- Advanced facilities: payback in 6-12 months
- Elite facilities: long-term investment (1+ years)

---

## Player Experience

### Early Game (Months 1-3)

**What Player Does:**
- Learns recovery mechanics
- Builds first medical facility
- Starts unit progression system
- Experiences first casualties

**What System Provides:**
- Tutorial-like gentle introduction
- Quick recoveries (small wounds)
- Rapid early levels (Level 0→1)
- First trait experiences

### Mid Game (Months 4-9)

**What Player Does:**
- Manages roster rotation
- Builds training/support facilities
- Makes transformation decisions
- Collects medals

**What System Provides:**
- Roster pressure (wounded units)
- Meaningful facility choices
- First veteran units (Level 3+)
- Character differentiation

### Late Game (Months 10+)

**What Player Does:**
- Optimizes facility setup
- Protects elite veterans
- Pushes transformation system
- Completes medal collections

**What System Provides:**
- Powerful veteran units
- Facility synergies
- Transformation options
- Elite unit capabilities

---

## Technical Architecture

### Component Structure

```lua
-- Core time management
TimeManager = {
    currentDay = 150,
    callbacks = {daily = {}, weekly = {}, monthly = {}}
}

-- Unit components (extended)
unit.experience = {currentXP, level, nextLevelXP}
unit.health = {currentHP, maxHP, wounds, healingRate}
unit.sanity = {current, max, recoveryRate}
unit.trait = {id, name, modifiers}
unit.transformation = {id, bonuses, penalties} -- optional
unit.medals = {{id, name, xpAwarded, dateEarned}, ...}
unit.recovery = {isRecovering, startDay, totalDays}

-- Systems
UnitRecoverySystem.processWeeklyRecovery()
TrainingSystem.processDailyTraining()
ExperienceSystem.checkLevelUp(unit)
MedalSystem.checkConditions(unit, battleStats)
```

### Event System

```lua
-- Time events
on("dailyTick", function() ... end)
on("weeklyTick", function() ... end)
on("monthlyTick", function() ... end)

-- Unit events
on("levelUp", function(unit, newLevel) ... end)
on("medalAwarded", function(unit, medal) ... end)
on("recoveryComplete", function(unit) ... end)
on("transformationComplete", function(unit) ... end)
```

### Data-Driven Design

All balance values in config files:
- `data/unit_recovery_config.lua` - Recovery rates
- `data/level_config.lua` - XP thresholds, bonuses
- `data/traits_config.lua` - All trait definitions
- `data/transformations_config.lua` - Transformation options
- `data/medals_config.lua` - Medal conditions and rewards
- `data/facility_bonuses_config.lua` - Facility effects

---

## Implementation Roadmap

### Week 1: Core Systems (32 hours)

**Days 1-2: Foundation**
- Time management system
- Facility bonus system
- HP recovery system
- Sanity system

**Days 3-4: Progression**
- Craft repair system
- Base training system
- Experience level system
- Trait system

**Day 5: UI Foundation**
- Unit roster panel
- Recovery tracker
- Basic displays

### Week 2: Advanced Features (22 hours)

**Days 6-7: Character Development**
- Transformation system
- Medal system
- Wound system enhancement
- Post-battle processing

**Days 8-9: Polish**
- UI completion
- Data configuration
- Integration testing
- Bug fixes

**Day 10: Documentation**
- API documentation
- FAQ entries
- Development guide
- Code comments

---

## Success Metrics

### Functional Success
- [ ] All recovery systems work correctly
- [ ] XP progression feels meaningful
- [ ] Traits/transformations provide variety
- [ ] Medals reward achievements
- [ ] UI is clear and informative
- [ ] Save/load preserves all states

### Player Experience Success
- [ ] Recovery creates strategic pressure
- [ ] Progression feels rewarding
- [ ] Facilities provide clear benefits
- [ ] Each unit feels unique
- [ ] Long-term investment pays off
- [ ] System is intuitive to understand

### Technical Success
- [ ] No performance issues
- [ ] No console errors
- [ ] Clean, maintainable code
- [ ] Comprehensive test coverage
- [ ] Good documentation
- [ ] Moddable/configurable

---

## Risk Assessment

### Low Risk
- Time management (straightforward)
- Recovery calculations (simple math)
- UI display (widgets exist)
- Data configuration (established pattern)

### Medium Risk
- Facility bonus aggregation (complexity in edge cases)
- Post-battle integration (multiple systems involved)
- Save/load with extended data (need careful testing)

### Mitigation Strategies
- Incremental implementation
- Test after each phase
- Use existing patterns
- Comprehensive unit tests
- Regular console debugging

---

## Future Expansion Possibilities

### Phase 2 Features (Post-Release)

**Advanced Training:**
- Specialized courses (sniper school, medic training)
- Skill trees within classes
- Training missions (risk-free XP)

**Enhanced Sanity:**
- Active therapy (spend resources for faster recovery)
- Psychological profiles
- Bonding system (units support each other)

**Deeper Character Development:**
- Biography auto-generation
- Unit relationships
- Career milestones
- Hall of Fame for fallen heroes

**Transformation Upgrades:**
- Improve existing transformations
- Hybrid transformations
- Reversal options (with penalty)

**Extended Medal System:**
- Campaign-spanning achievements
- Mission chains
- Unit group medals
- Legendary medals (unique rewards)

---

## Conclusion

This task creates a comprehensive unit management system that:

1. **Adds Strategic Depth** - Recovery and facility management create meaningful choices
2. **Rewards Investment** - Long-term unit development pays off
3. **Creates Stories** - Each unit becomes unique through traits, medals, and transformations
4. **Balances Risk** - Wounds and sanity loss add weight to combat decisions
5. **Enhances Replayability** - Different trait combinations and facility choices each playthrough

The system integrates smoothly with existing game architecture while adding significant depth to the strategic and tactical layers. It's designed to be moddable, configurable, and expandable for future enhancements.

---

**Ready to Implement:** All design work complete, architecture defined, balance values established.  
**Next Steps:** Begin Phase 1 (Time Management Foundation) when development starts.  
**Expected Outcome:** Complete unit recovery and progression system in 6-7 working days.

---

**Document:** TASK-027 Implementation Summary  
**Version:** 1.0  
**Date:** October 13, 2025  
**Author:** AI Development Agent  
**Status:** Planning Complete - Ready for Development
