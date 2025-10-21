# Task Organization Quick Reference

**Created:** October 13, 2025  
**Last Updated:** October 13, 2025

---

## Folder Structure

```
tasks/TODO/
├── 01-BATTLESCAPE/          (10 tasks)
├── 02-GEOSCAPE/             (16 files)
├── 03-BASESCAPE/            (4 tasks)
├── 04-INTERCEPTION/         (1 task)
├── 05-ECONOMY/              (4 tasks)
├── 06-DOCUMENTATION/        (7 docs)
├── MASTER-IMPLEMENTATION-PLAN.md
└── TASK-ORGANIZATION-QUICK-REFERENCE.md (this file)
```

---

## 01-BATTLESCAPE (10 Tasks)

**Focus:** Tactical combat layer with 2D/3D rendering, combat mechanics, and map generation

| Priority | Task ID | Name | Est. Hours | Dependencies |
|----------|---------|------|------------|--------------|
| HIGH | TASK-026 | 3D Core Rendering | 80 | None |
| HIGH | TASK-027 | 3D Unit Interaction | 90 | TASK-026 |
| MEDIUM | TASK-028 | 3D Effects & Advanced | 100 | TASK-027 |
| HIGH | TASK-030 | Battle Objectives | 40 | Map Generation |
| CRITICAL | TASK-031 | Map Generation | 60 | Geoscape Biomes |
| MEDIUM | TASK-017 | Damage Models | 35 | None |
| MEDIUM | TASK-018 | Weapon Modes | 30 | None |
| MEDIUM | TASK-019 | Psionics | 45 | TASK-017 |
| MEDIUM | TASK-020 | Enhanced Crits | 30 | TASK-017 |
| LOW | TASK-016 | Hex Combat Conversion | TBD | Phase 8+ |

**Subtotal:** ~510 hours (not including TASK-016)

---

## 02-GEOSCAPE (7 Tasks + 9 Docs)

**Focus:** Strategic world management, missions, lore, and campaign systems

### Tasks (7)

| Priority | Task ID | Name | Est. Hours | Dependencies |
|----------|---------|------|------------|--------------|
| CRITICAL | TASK-025 | Geoscape Master | 80 | None |
| CRITICAL | TASK-027 | Mission Detection Loop | 45 | TASK-025 |
| HIGH | TASK-029 | Deployment Planning Screen | 35 | TASK-025, Basescape |
| HIGH | TASK-030 | Mission Salvage/Victory | 35 | Battle Objectives |
| MEDIUM | TASK-026 | Relations System | 40 | TASK-025 |
| MEDIUM | TASK-026 | Lore & Campaign | 50 | TASK-025 |
| MEDIUM | TASK-026 | Lore Mission System | TBD | TASK-025 |

**Subtotal:** ~285 hours

### Documentation (9)

- GEOSCAPE-ARCHITECTURE-DIAGRAM.md
- GEOSCAPE-COMPLETE-MASTER-INDEX.md
- GEOSCAPE-IMPLEMENTATION-CHECKLIST.md
- GEOSCAPE-INDEX.md
- GEOSCAPE-QUICK-REFERENCE.md
- LORE-CAMPAIGN-QUICK-REFERENCE.md
- LORE-SYSTEM-QUICK-REFERENCE.md
- MISSION-SYSTEM-FEATURES-SUMMARY.md
- MISSION-SYSTEM-VISUAL-WORKFLOW.md

---

## 03-BASESCAPE (4 Tasks)

**Focus:** Base management, facilities, research, manufacturing, and unit progression

| Priority | Task ID | Name | Est. Hours | Dependencies |
|----------|---------|------|------------|--------------|
| HIGH | TASK-029 | Facility System | 50 | Geoscape Calendar |
| HIGH | TASK-032 | Research System | 40 | TASK-029 |
| MEDIUM | TASK-033 | Manufacturing System | 40 | TASK-029, TASK-032 |
| MEDIUM | TASK-026 | Unit Recovery & Progression | 35 | TASK-029 |

**Subtotal:** ~165 hours

---

## 04-INTERCEPTION (1 Task)

**Focus:** Turn-based craft vs. craft combat

| Priority | Task ID | Name | Est. Hours | Dependencies |
|----------|---------|------|------------|--------------|
| MEDIUM | TASK-028 | Interception Screen | 30 | Geoscape Crafts |

**Subtotal:** ~30 hours

---

## 05-ECONOMY (3 Tasks + 1 Doc)

**Focus:** Marketplace, black market, and reputation systems

### Tasks (3)

| Priority | Task ID | Name | Est. Hours | Dependencies |
|----------|---------|------|------------|--------------|
| MEDIUM | TASK-034 | Marketplace & Suppliers | 50 | Geoscape, Basescape |
| LOW | TASK-035 | Black Market | 35 | TASK-034 |
| LOW | TASK-036 | Fame/Karma/Reputation | 40 | Mission System |

**Subtotal:** ~125 hours

### Documentation (1)

- ECONOMY-SYSTEMS-MASTER-PLAN.md

---

## 06-DOCUMENTATION (7 Files)

**Focus:** Reference materials, implementation summaries, and guides

### Files

- ENGINE-RESTRUCTURE-QUICK-REFERENCE.md
- ENGINE-RESTRUCTURE-VISUAL-COMPARISON.md
- MAP-GENERATION-ANALYSIS.md
- MAP-GENERATION-DOCUMENTATION-INDEX.md
- MAP-GENERATION-POLISH-SUMMARY.md
- MAP-GENERATION-VISUAL-GUIDE.md
- PLAN-IMPLEMENTACJI-PL.md
- TASK-027-IMPLEMENTATION-SUMMARY.md
- TASK-027-QUICK-REFERENCE.md
- TASK-027-VISUAL-OVERVIEW.md

**Note:** These are reference materials, not actionable tasks.

---

## Total Task Summary

| Category | Task Count | Est. Hours | % of Total |
|----------|------------|------------|------------|
| Battlescape | 10 | ~510 | 45% |
| Geoscape | 7 | ~285 | 25% |
| Basescape | 4 | ~165 | 15% |
| Interception | 1 | ~30 | 3% |
| Economy | 3 | ~125 | 11% |
| Documentation | 17 docs | N/A | N/A |
| **TOTAL** | **25 tasks** | **~1,115 hours** | **100%** |

**Note:** Excludes TASK-016 (Hex Combat) which is deferred to Phase 8+

---

## Implementation Phases (Summary)

1. **PHASE 1: Foundation** (3 weeks, 185h) - Geoscape, Map Gen, Mission Loop
2. **PHASE 2: Basescape** (2 weeks, 125h) - Facilities, Research, Deployment
3. **PHASE 3: Combat Depth** (2 weeks, 105h) - Objectives, Salvage, Weapon Modes
4. **PHASE 4: 3D Battlescape** (3 weeks, 270h) - Core, Units, Effects
5. **PHASE 5: Advanced Combat** (2 weeks, 110h) - Damage, Crits, Psionics
6. **PHASE 6: Economy** (2 weeks, 125h) - Manufacturing, Marketplace, Progression
7. **PHASE 7: Strategic Depth** (2 weeks, 130h) - Relations, Lore, Fame/Karma
8. **PHASE 8: Final Systems** (1+ week, 65h+) - Interception, Black Market, Polish

**Total:** 16-17 weeks (1,115 hours) for feature-complete 1.0 release

---

## Quick Navigation

### By Priority

**CRITICAL (Must Have for MVP):**
- Geoscape Master (TASK-025)
- Map Generation (TASK-031)
- Mission Detection Loop (TASK-027)
- Basescape Facilities (TASK-029)

**HIGH (Core Features):**
- 3D Battlescape (TASK-026/027/028)
- Battle Objectives (TASK-030)
- Mission Salvage (TASK-030)
- Research System (TASK-032)

**MEDIUM (Depth & Polish):**
- All combat mechanics (TASK-017/018/019/020)
- Manufacturing (TASK-033)
- Marketplace (TASK-034)
- Relations, Lore, Unit Progression (various TASK-026)
- Interception (TASK-028)

**LOW (Nice to Have):**
- Black Market (TASK-035)
- Fame/Karma (TASK-036)
- Hex Combat (TASK-016) - deferred

### By Game Mode

**Want to work on Tactical Combat?** → 01-BATTLESCAPE/  
**Want to work on Strategic Layer?** → 02-GEOSCAPE/  
**Want to work on Base Building?** → 03-BASESCAPE/  
**Want to work on Economy?** → 05-ECONOMY/  
**Want to implement Interception?** → 04-INTERCEPTION/  

### By Dependencies

**Can Start Now (No Blockers):**
- 3D Core Rendering (TASK-026)
- Damage Models (TASK-017)
- Weapon Modes (TASK-018)

**Needs Geoscape First:**
- Map Generation (TASK-031)
- Mission Loop (TASK-027)
- Deployment Planning (TASK-029)
- Relations (TASK-026)
- Lore (TASK-026)

**Needs Basescape First:**
- Research (TASK-032)
- Manufacturing (TASK-033)
- Unit Recovery (TASK-026)

---

## File Naming Conventions

### Task Files
- Format: `TASK-XXX-description.md`
- Examples:
  - `TASK-025-geoscape-master-implementation.md`
  - `TASK-026-3d-battlescape-core-rendering.md`

### Documentation Files
- Format: `TOPIC-TYPE.md`
- Examples:
  - `GEOSCAPE-QUICK-REFERENCE.md`
  - `MAP-GENERATION-VISUAL-GUIDE.md`
  - `ENGINE-RESTRUCTURE-QUICK-REFERENCE.md`

### Master Planning Files
- `MASTER-IMPLEMENTATION-PLAN.md` - Full roadmap (this folder)
- `TASK-ORGANIZATION-QUICK-REFERENCE.md` - This file
- `../tasks.md` - Active task tracking (parent folder)

---

## How to Use This Organization

### Starting a New Task

1. **Choose task** from appropriate folder (01-06)
2. **Check dependencies** in this reference or MASTER-IMPLEMENTATION-PLAN.md
3. **Move to IN_PROGRESS** folder: `tasks/TODO/XX-CATEGORY/TASK-XXX.md` → `tasks/IN_PROGRESS/`
4. **Update** `tasks/tasks.md` with status change
5. **Create branch** in git: `git checkout -b task-XXX-description`

### Completing a Task

1. **Test thoroughly** with Love2D console enabled (`lovec engine`)
2. **Update documentation** (API.md, FAQ.md, DEVELOPMENT.md)
3. **Move to DONE** folder: `tasks/IN_PROGRESS/TASK-XXX.md` → `tasks/DONE/`
4. **Update** `tasks/tasks.md` with completion date
5. **Merge branch** and close PR

### Finding Related Tasks

1. **Look in same category folder** for related work
2. **Check dependencies** in task file or this reference
3. **Review documentation** in 06-DOCUMENTATION/ for context
4. **Consult MASTER-IMPLEMENTATION-PLAN.md** for optimal order

---

## Maintenance

### Update This File When:
- Tasks are added or removed from TODO
- Task estimates change significantly
- Dependencies are discovered or resolved
- Folder structure is modified

### Keep In Sync With:
- `tasks/tasks.md` - Active task tracking
- `MASTER-IMPLEMENTATION-PLAN.md` - Implementation roadmap
- Individual task files - As priorities shift

---

**Last Updated:** October 13, 2025  
**Next Review:** After Phase 1 completion (Week 3)

---

**END OF QUICK REFERENCE**
