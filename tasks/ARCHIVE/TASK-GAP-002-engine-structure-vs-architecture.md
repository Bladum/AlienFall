# TASK-GAP-002: Compare Engine Folder Structure vs Architecture Documentation

**Status:** TODO
**Priority:** HIGH
**Created:** October 23, 2025
**Estimated Time:** 6-8 hours
**Task Type:** Structural Audit + Fixes

---

## Overview

Compare actual engine folder organization against documented architecture to identify:
1. Components in wrong locations
2. Systems not following architectural patterns
3. Structural issues blocking modularity
4. Folder organization inconsistencies

---

## Scope: TWO SOURCES ONLY

**Source A:** `architecture/` (documentation of intended structure)
**Source B:** `engine/` (actual folder structure)

**Key Comparison Points:**
- Strategic Layer organization
- Operational Layer organization
- Tactical Layer organization
- Core systems placement
- UI component organization

---

## Critical Structural Issues to Resolve

### Issue 1: GUI Components Scattered ❌

**Documented Structure (Should be):**
```
engine/gui/
├── scenes/       (game screens)
├── widgets/      (reusable components)
└── ui/           (system-specific UI)
```

**Actual Structure:**
```
engine/gui/
├── scenes/       ✅
├── widgets/      ✅
engine/gui/ui/    ❌ (Where?? Separate folder?)
engine/ui/        ❌ (Additional UI location!)
engine/scenes/    ❌ (Duplicate location!)
```

**Task:**
- [ ] Map all GUI components to actual locations
- [ ] Consolidate into single `engine/gui/` structure
- [ ] Update 50+ require statements
- [ ] Test all scenes load correctly
- [ ] Verify no circular dependencies

**Effort:** 3-4 hours

---

### Issue 2: Content Mixed with Core ❌

**Documented Structure (Should be):**
```
engine/content/
├── crafts/
├── items/
└── units/
```

**Actual Structure:**
```
engine/core/
├── crafts/       ❌ (Content in core!)
├── items/        ❌ (Content in core!)
└── units/        ❌ (Content in core!)
```

**Task:**
- [ ] Create `engine/content/` folder
- [ ] Move crafts, items, units out of core
- [ ] Update 30+ require statements
- [ ] Verify mod loading still works
- [ ] Test all content loads

**Effort:** 2-3 hours

---

### Issue 3: Research System Location Ambiguous ❌

**Documented Structure (Should be):**
```
engine/basescape/research/
(Research is operational layer system)
```

**Actual Structure:**
```
engine/geoscape/logic/research_*
engine/basescape/research/
engine/economy/research/
(Where is research actually??)
```

**Task:**
- [ ] Determine single source of truth
- [ ] Consolidate all research files
- [ ] Remove duplicates
- [ ] Update 20+ require statements
- [ ] Fix integration points

**Effort:** 4-5 hours

---

## Verification Checklist

### Strategic Layer (Geoscape)
- [ ] `engine/geoscape/` exists
- [ ] Has `world/`, `systems/`, `logic/`, `rendering/`, `ui/`, `screens/`
- [ ] No strategic content in other layers
- [ ] Campaign manager isolated correctly

### Operational Layer (Basescape)
- [ ] `engine/basescape/` exists
- [ ] Has `facilities/`, `research/`, `logic/`, `ui/`, `services/`
- [ ] `engine/economy/` for financial systems only
- [ ] Research system consolidated
- [ ] No operational content in other layers

### Tactical Layer (Battlescape)
- [ ] `engine/battlescape/` exists
- [ ] Has `systems/`, `battle/`, `ai/`, `entities/`, `rendering/`, `ui/`, `map/`
- [ ] No tactical content in other layers
- [ ] Map generation self-contained

### Core Systems
- [ ] `engine/core/` for state, assets, data loading only
- [ ] No game content in core
- [ ] Core systems independent from content

### Support Systems
- [ ] `engine/gui/` - All UI components
- [ ] `engine/analytics/` - All analytics
- [ ] `engine/ai/` - AI systems
- [ ] `engine/accessibility/` - Accessibility features
- [ ] `engine/localization/` - Localization
- [ ] `engine/lore/` - Story/narrative

---

## Deliverables

### Structural Report
**File:** `docs/ENGINE_STRUCTURE_AUDIT.md`

Should contain:
- Current structure (actual)
- Documented structure (intended)
- Differences identified
- Severity assessment
- Repair recommendations
- Time estimates per issue

### Repair Tasks
Create separate tasks for each issue:
- [ ] TASK-GAP-003: Consolidate GUI components
- [ ] TASK-GAP-004: Separate content from core
- [ ] TASK-GAP-005: Consolidate research system

### Updated Documentation
- [ ] Update `architecture/01-game-structure.md` if needed
- [ ] Update `architecture/README.md` with findings
- [ ] Create structure diagram in `architecture/`

---

## Success Criteria

✅ All layers mapped
✅ All structural issues identified
✅ Severity assessed
✅ Repair plans created
✅ Report documented

---

## Related Files

**Compare These:**
- Architecture: `architecture/01-game-structure.md` ↔ Actual: `engine/` folder
- Architecture: `architecture/04-base-economy.md` ↔ Actual: `engine/basescape/` + `engine/economy/`
- Architecture: `architecture/03-combat-tactics.md` ↔ Actual: `engine/battlescape/`

**Reference Report:** `design/gaps/ARCHITECTURE_ALIGNMENT.md` (Use for issues to investigate)

---

**Task ID:** TASK-GAP-002
**Assignee:** [Architect]
**Due:** October 29, 2025
**Complexity:** Medium (structural assessment)
