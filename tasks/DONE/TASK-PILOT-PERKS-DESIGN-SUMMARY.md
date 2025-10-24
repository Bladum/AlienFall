# PILOT & PERKS SYSTEM - DESIGN & IMPLEMENTATION SUMMARY

**Date:** October 23, 2025  
**Project:** AlienFall - XCOM Simple  
**Task:** Design, Document, Implement PILOT Class & PERKS System  
**Status:** ✅ DESIGNED & DOCUMENTED - READY FOR IMPLEMENTATION

---

## 📑 What Has Been Created

### 1. Master Task Document
**File:** `tasks/TODO/TASK-PILOT-PERKS-SYSTEM.md`
- Complete 9-phase implementation plan
- Requirements analysis mapping to user requests
- Architecture overview for all 9 phases
- Success criteria and testing strategy
- Time breakdown (50-66 hours total)

### 2. Comprehensive Task Breakdown
**File:** `tasks/TODO/TASK-PILOT-PERKS-COMPREHENSIVE-BREAKDOWN.md`
- 20 individual actionable tasks
- Task summary table with dependencies
- Detailed description of each task
- Files to create/modify for each task
- Execution order (5 phases)
- Success criteria checklist

### 3. First Two Detailed Subtasks
**File 1:** `tasks/TODO/TASK-PILOT-001-pilot-class.md`
- Complete implementation guide for PILOT class
- TOML examples for all 4 pilot classes
- Engine integration steps
- Testing checklist

**File 2:** `tasks/TODO/TASK-PILOT-004-perks-system.md`
- Complete Lua module for PerkSystem (300+ lines example)
- TOML configuration for 40+ perks
- Engine integration steps
- Testing checklist

### 4. Todo List
**Tool:** `manage_todo_list` 
- 20 actionable todos created and tracked
- Status: all NOT-STARTED (ready for implementation)
- Clear dependencies between tasks

---

## 🎯 Key Design Decisions

### PILOT Class System
- ✅ **Simple progression:** 3 ranks instead of 7 (Rookie → Veteran → Ace)
- ✅ **Interception-only XP:** Pilots gain experience only during craft combat
- ✅ **Stat focus:** SPEED 8, AIM 7, REACTION 8 (driver-centric)
- ✅ **Specialist variants:** FIGHTER_PILOT, BOMBER_PILOT, HELICOPTER_PILOT
- ✅ **Craft requirements:** 1-6 pilots per craft type with class requirements

### Capacity System
- ✅ **3-tier structure:** PILOT (units as pilots) / CREW (units as troops) / CARGO (items)
- ✅ **Independent tracking:** Each capacity type managed separately
- ✅ **PILOT slots:** 1-6 dedicated pilot positions
- ✅ **CREW slots:** 0-N troop positions
- ✅ **CARGO:** kg-based item storage

### Pilot Bonus System
- ✅ **Stat mapping:** Each pilot stat grants specific craft bonus
- ✅ **Formula:** (pilot_stat - 5) / 100 = % bonus
- ✅ **Examples:**
  - Pilot SPEED 8 → +3% craft speed
  - Pilot AIM 10 → +5% craft accuracy
  - Pilot STRENGTH 7 → +2% craft damage
- ✅ **Multi-pilot stacking:** Multiple pilots' bonuses stack

### PERKS System
- ✅ **Boolean flags:** Simple on/off trait system
- ✅ **40+ standard perks:** Covering all gameplay aspects
- ✅ **Categories:** Basic, Movement, Combat, Senses, Defense, Social, Special
- ✅ **Per-class defaults:** Each unit class gets appropriate perks
- ✅ **Runtime toggle:** Perks can be enabled/disabled dynamically

### Dual-Wield Mechanic
- ✅ **Perk-based:** Requires "two_weapon_proficiency" perk
- ✅ **Same-type check:** Both weapons must be same type
- ✅ **1 AP cost:** Single action point cost (not doubled)
- ✅ **Double energy:** Both weapons' energy consumed
- ✅ **-10% accuracy:** Penalty for using two weapons
- ✅ **UI integration:** "Dual Fire" action shows in menu

---

## 📋 Files to Be Created/Modified

### Configuration Files (6)
1. `mods/core/rules/unit/classes.toml` - Add PILOT, FIGHTER_PILOT, BOMBER_PILOT, HELICOPTER_PILOT
2. `mods/core/rules/content/crafts.toml` - Add pilot requirements, capacity system
3. `mods/core/rules/unit/perks.toml` - **NEW** (40+ perks)
4. `mods/core/rules/unit/pilot_ranks.toml` - **NEW** (rank definitions)

### Engine Implementation Files (11)
5. `engine/battlescape/systems/perks_system.lua` - **NEW** (300+ lines)
6. `engine/basescape/logic/pilot_progression.lua` - **NEW** (250+ lines)
7. `engine/geoscape/logic/craft_pilot_system.lua` - **NEW** (pilot bonuses)
8. `engine/geoscape/logic/craft_system.lua` - **EXTEND** (requirements, capacity)
9. `engine/basescape/logic/unit_system.lua` - **EXTEND** (pilot creation)
10. `engine/battlescape/systems/weapon_system.lua` - **EXTEND** (dual-wield)
11. `engine/interception/logic/interception_system.lua` - **EXTEND** (pilot XP)

### UI Files (3)
12. `engine/geoscape/ui/craft_pilot_display.lua` - **NEW**
13. `engine/basescape/ui/recruit_pilot_ui.lua` - **NEW**
14. `engine/geoscape/ui/craft_crew_assignment.lua` - **NEW**

### Documentation Files (6)
15. `docs/content/units/pilots.md` - **NEW** (1000+ lines)
16. `docs/content/unit_systems/perks.md` - **NEW** (1000+ lines)
17. `docs/content/crafts/pilot_bonuses.md` - **NEW**
18. `api/UNITS.md` - **UPDATE** (add pilot & perk sections)
19. `api/CRAFTS.md` - **UPDATE** (add pilot & capacity sections)
20. `tasks/TODO/TASK-PILOT-*.md` - Task documents (CREATED ✅)

---

## 🧪 Implementation Phases

### Phase 1: Core Implementation (20 hours)
- Task 1: PILOT Class System
- Task 4: PERKS Framework  
- Task 9: 40+ Standard Perks
- Task 2: Craft Requirements
- Task 3: Capacity Distribution

### Phase 2: Pilot Mechanics (20 hours)
- Task 7: Interception XP Gain
- Task 8: Pilot Ranks
- Task 6: Pilot Bonus Calculation
- Task 5: Dual-Wield System
- Task 10: Update Classes TOML

### Phase 3: UI & Systems (14 hours)
- Task 16: Pilot Recruitment
- Task 17: Pilot Assignment
- Task 11: UI Display
- Task 12-13: Documentation (PILOTS & PERKS)

### Phase 4: Documentation (7 hours)
- Task 14: Update UNITS.md
- Task 15: Update CRAFTS.md

### Phase 5: Testing & Polish (5 hours)
- Task 18: Interception Test
- Task 19: Perks Test
- Task 20: Dual-Wield Test

**Total: 50-66 hours**

---

## 📊 Requirements Mapping

### From User Request → Implementation

| Requirement | Implementation |
|-------------|-----------------|
| "crafty nie maja promocji ani doswiadczenia, za to maja je UNITS" | TASK-008: Pilot ranks/XP system |
| "dodaje zwykla prosta klase PILOT" | TASK-001: PILOT class definition |
| "craft wymaga PILOT" | TASK-002: Pilot requirements |
| "pilot zdobywa expa jak UNIT ale prosciej" | TASK-007: Simpler 3-rank progression |
| "crafty moga wymagac 1-6 pilotow" | TASK-002: 1-6 pilots per craft |
| "crafty maja capacity na PILOT/CREW/CARGO" | TASK-003: 3-tier capacity system |
| "piloci...dostaja experience...podczas interception" | TASK-007: Interception XP gain |
| "crafty nie sa promowane, ale piloci daja bonusy" | TASK-006: Pilot bonus system |
| "moga byc specjalne unit class potrzebne jako piloci" | TASK-001: Specialist pilot classes |
| "craft moze miec wymaganych pilotow specjalnych" | TASK-002: Class requirements |
| "wieksze crafty moga wymagac pilota oficera" | TASK-002: Officer requirement flag |
| "staty unita beda przenosily sie na bonus do statow craftu" | TASK-006: Stat mapping & bonus formula |
| "taki pilot moze miec ekwipunek...normalnie" | TASK-001: Pilot as unit subclass |
| "pilot moze brac udzial w walce jesli statek wyladuje" | TASK-001: Ground deployment support |
| "nowy mechanizm w units to sa perki" | TASK-004: Perks system framework |
| "system perkow to system flag TRUE FALSE" | TASK-004: Boolean flag implementation |
| "can_move, can_run, can_fly, can_breathe" | TASK-009: Basic perks |
| "can_fire_both_weapons" | TASK-005: Dual-wield perk |
| "wymysl jakie rzeczy moga byc oflagowane" | TASK-009: 40+ standard perks |
| "jeden z perkow to dwurczenosc" | TASK-005: Two-weapon proficiency |
| "fire them, 1 AP, 2x energy, -10% accuracy" | TASK-005: Dual-wield mechanics |

---

## ✅ Deliverables

### Immediate (Ready Now)
- ✅ Master task document with full plan
- ✅ Comprehensive 20-task breakdown with dependencies
- ✅ Two detailed subtask guides (PILOT class, PERKS system)
- ✅ Todo list with 20 actionable items
- ✅ Complete design documentation
- ✅ TOML examples for pilots and perks
- ✅ Lua module example code (300+ lines)

### After Implementation (Phase 1-5)
- 📋 PILOT class system fully functional
- 📋 PERKS system with 40+ perks
- 📋 Pilot recruitment and assignment UI
- 📋 Pilot experience and rank progression
- 📋 Dual-wield combat mechanic
- 📋 Comprehensive documentation (4 files)
- 📋 Updated API references
- 📋 Full test coverage

---

## 🚀 How to Get Started

### Step 1: Review Documentation
1. Read `TASK-PILOT-PERKS-SYSTEM.md` for overview
2. Read `TASK-PILOT-PERKS-COMPREHENSIVE-BREAKDOWN.md` for all 20 tasks
3. Read first subtasks for implementation details

### Step 2: Execute Tasks in Order
Phase 1 tasks are independent and can be done in parallel:
- TASK-001, TASK-004, TASK-009 (configuration)
- TASK-002, TASK-003 (craft system)

### Step 3: Integration
Phase 2 tasks require Phase 1 completion:
- TASK-007, TASK-008 (pilot progression)
- TASK-006, TASK-005 (bonuses & dual-wield)

### Step 4: UI & Documentation
Phase 3-4 tasks follow implementation:
- Recruitment/assignment UI
- Comprehensive documentation

### Step 5: Testing
Phase 5 tasks verify everything works:
- Integration tests
- Manual testing in-game

---

## 📞 Questions to Address During Implementation

1. **Pilot stat ranges:** Should pilots be 6-10, or 5-10 like other units?
   - Recommended: 5-10 (like others, but favor SPEED/REACTION)

2. **Interception XP formula:** Should it be HP/10, or something else?
   - Recommended: (total_enemy_HP) / 10, scales with difficulty

3. **Specialist pilots:** How many specialist classes? Just 3, or more?
   - Recommended: Start with 3 (FIGHTER, BOMBER, HELICOPTER), add more later

4. **Perk UI:** Should perks have icons, or just text?
   - Recommended: Start with text, add icons later as enhancement

5. **Pilot deployment:** Can wounded pilots still be assigned to craft?
   - Recommended: Yes, but with warning/penalty

---

## 🎓 Learning Resources

### For Implementation
- Love2D: https://love2d.org/wiki/Main_Page
- Lua: https://www.lua.org/manual/5.1/
- TOML: https://toml.io/
- X-COM Reference: https://www.ufopaedia.org/

### Project-Specific
- `docs/CODE_STANDARDS.md` - Code style guide
- `docs/COMMENT_STANDARDS.md` - Documentation style
- `architecture/README.md` - System architecture
- `engine/README.md` - Engine overview

---

## ✨ Success Indicators

### After All 20 Tasks Complete:
- [ ] Game starts and runs without errors
- [ ] Pilots can be created and recruited
- [ ] Pilots can be assigned to craft
- [ ] Pilots gain XP from interception
- [ ] Pilots rank up and gain stat bonuses
- [ ] Craft bonuses calculated from pilot stats
- [ ] Dual-wield mechanic functional
- [ ] All documentation updated
- [ ] All tests pass
- [ ] No regressions in other systems

---

## 📞 Support & Resources

**If stuck, check:**
1. Task subtask document for phase details
2. Lua module examples in task documents
3. TOML examples in task documents
4. Existing similar systems in codebase
5. Engine README and documentation

**Common Issues:**
- **Perks not loading:** Check DataLoader.loadPerks() called in initialization
- **Pilots not recruiting:** Check unit class exists in TOML
- **XP not gaining:** Check interception system calls PilotProgression.gainXP()
- **UI not showing:** Check canvas size and render coordinates

---

## 🎉 Conclusion

This comprehensive design provides:
- ✅ Clear requirements from user input
- ✅ Detailed implementation plan (20 tasks)
- ✅ Code examples and TOML templates
- ✅ Integration points documented
- ✅ Testing strategy defined
- ✅ Documentation structure ready
- ✅ Todo tracking system in place

**The system is ready for implementation. Start with TASK-001 and follow the task order provided.**

---

**Status:** ✅ COMPLETE - Ready for Implementation  
**Created:** October 23, 2025  
**Total Hours to Complete:** 50-66 hours  
**Complexity:** MEDIUM-HIGH  
**Scope:** LARGE (new system + extensive integration)

