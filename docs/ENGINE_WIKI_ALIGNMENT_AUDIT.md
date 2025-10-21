# Engine/Wiki Structure Alignment Audit

**Date:** October 21, 2025  
**Status:** IN PROGRESS  
**Focus:** Mapping wiki/systems to engine/ folders and identifying misalignments

---

## Executive Summary

**Wiki Systems:** 19 systems documented (+ Glossary, Overview)  
**Engine Folders:** 20 top-level directories  
**Coverage:** 95%+ mapping found, but **structural problems identified**

### Critical Issues Found
1. ✅ **GUI Components Scattered**: scenes/, ui/, widgets/ not unified
2. ✅ **Content Mixed with Core**: items, units, crafts in core/ instead of content/
3. ✅ **No content/ folder**: Need to create dedicated content structure
4. ⚠️ **File Misplacement**: Some files in wrong system folders (needs investigation)

---

## Wiki Systems vs Engine Structure

### Strategic Layer (Geoscape)

| Wiki System | Engine Location | Status | Notes |
|-------------|-----------------|--------|-------|
| Geoscape.md | engine/geoscape/ | ✅ Good | Complete system folder |
| Crafts.md | engine/geoscape/crafts/ or engine/core/crafts/ | ⚠️ Check | May be in wrong folder |
| Interception.md | engine/interception/ | ✅ Good | Dedicated folder exists |
| Politics.md | engine/politics/ | ✅ Good | Relations, factions included |

### Operational Layer (Basescape)

| Wiki System | Engine Location | Status | Notes |
|-------------|-----------------|--------|-------|
| Basescape.md | engine/basescape/ | ✅ Good | Complete system folder |
| Economy.md | engine/economy/ | ✅ Good | Marketplace, suppliers, etc. |
| Finance.md | engine/economy/finance/ | ⚠️ Check | May not exist or be misplaced |
| Items.md | engine/content/items/ (NEEDS MOVE) | ❌ Problem | Currently in engine/core/items/ or scattered |

### Tactical Layer (Battlescape)

| Wiki System | Engine Location | Status | Notes |
|-------------|-----------------|--------|-------|
| Battlescape.md | engine/battlescape/ | ✅ Good | Complete system folder |
| Units.md | engine/content/units/ (NEEDS MOVE) | ❌ Problem | Currently in engine/core/units/ or scattered |
| AI Systems.md | engine/ai/ | ✅ Good | Dedicated AI folder |

### Meta Systems

| Wiki System | Engine Location | Status | Notes |
|-------------|-----------------|--------|-------|
| Gui.md | engine/gui/ (NEEDS CREATION) | ❌ Problem | scenes/, ui/, widgets/ not unified |
| Assets.md | engine/assets/ | ✅ Good | Dedicated assets folder |
| Integration.md | engine/core/ | ✅ Good | State management, integration |
| Analytics.md | engine/analytics/ | ✅ Good | Dedicated analytics folder |
| Lore.md | engine/lore/ | ✅ Good | Dedicated lore folder |
| 3D.md | engine/battlescape/rendering_3d/ | ✅ Good | Part of battlescape |

### Core Systems (Not in Wiki Systems, but in Engine)

| Engine Folder | Purpose | Status | Notes |
|---------------|---------|--------|-------|
| engine/core/ | Core engine systems | ✅ Good | State, data loading, mod management |
| engine/accessibility/ | Accessibility features | ✅ Good | Separate folder |
| engine/localization/ | i18n/translation | ✅ Good | Separate folder |
| engine/network/ | Multiplayer/networking | ✅ Good | Separate folder |
| engine/tutorial/ | Tutorial system | ✅ Good | Separate folder |
| engine/utils/ | Utilities | ⚠️ Check | May need reorganization |
| engine/mods/ | Mod system | ✅ Good | Separate folder |

---

## Critical Alignment Issues

### Issue 1: GUI Components Scattered ❌ CRITICAL

**Current State:**
```
engine/
├── scenes/       (Scene definitions)
├── ui/           (UI screens)
└── widgets/      (Widget components)
```

**Problem:** Three separate folders for GUI-related code

**Wiki Alignment:** `Gui.md` treats all as unified system

**Solution:** Create `engine/gui/` and merge:
```
engine/gui/
├── scenes/       (move from engine/scenes/)
├── ui/           (move from engine/ui/)
└── widgets/      (move from engine/widgets/)
```

**Affected Files:** ~50+ require statements

---

### Issue 2: Content Data Mixed with Core ❌ CRITICAL

**Current State:**
```
engine/
├── core/
│   ├── crafts/    (Content definition)
│   ├── items/     (Content definition)
│   └── units/     (Content definition)
```

**Problem:** Content (gameplay data) mixed with core engine code

**Wiki Alignment:** 
- `Items.md` describes items as content system
- `Units.md` describes units as content system
- `Crafts.md` describes crafts as content system

**Solution:** Create `engine/content/` folder:
```
engine/
├── content/
│   ├── items/     (move from core/items/)
│   ├── units/     (move from core/units/)
│   └── crafts/    (move from core/crafts/)
├── core/
│   ├── state_manager.lua
│   ├── data_loader.lua
│   ├── mod_manager.lua
│   ├── assets.lua
│   └── ...
```

**Affected Files:** ~30+ require statements

---

### Issue 3: Missing Content Structure ❌ CRITICAL

**Current State:** No dedicated `engine/content/` folder

**Expected State:** All game content (items, units, crafts, factions, etc.) in content/ folder

**Solution:** Create `engine/content/` with structure:
```
engine/content/
├── items/       (Item definitions and system)
├── units/       (Unit definitions and system)
├── crafts/      (Craft definitions and system)
├── factions/    (Faction definitions) [NEW]
├── weapons/     (Weapon definitions) [NEW]
└── ...
```

---

## Detailed Mapping

### 1. Strategic Layer - Geoscape

**Wiki File:** wiki/systems/Geoscape.md  
**Engine Folder:** engine/geoscape/

**Expected Structure:**
```
engine/geoscape/
├── logic/        (Core logic)
├── ui/           (Geoscape screens)
├── systems/      (Calendar, world, travel, etc.)
├── rendering/    (Map rendering)
└── data/         (Biomes, provinces, etc.)
```

**Status:** ✅ Generally aligned

---

### 2. Strategic Layer - Crafts

**Wiki File:** wiki/systems/Crafts.md  
**Engine Folder:** engine/core/crafts/ → engine/content/crafts/

**Current Location:** engine/core/crafts/  
**Problem:** Should be in content/, not core/  
**Solution:** Move to engine/content/crafts/

---

### 3. Strategic Layer - Interception

**Wiki File:** wiki/systems/Interception.md  
**Engine Folder:** engine/interception/

**Status:** ✅ Good (dedicated folder)

---

### 4. Strategic Layer - Politics

**Wiki File:** wiki/systems/Politics.md  
**Engine Folder:** engine/politics/

**Expected Structure:**
```
engine/politics/
├── relations/     (Country/supplier relations)
├── factions/      (Faction definitions)
└── ...
```

**Status:** ✅ Generally aligned

---

### 5. Operational Layer - Basescape

**Wiki File:** wiki/systems/Basescape.md  
**Engine Folder:** engine/basescape/

**Expected Structure:**
```
engine/basescape/
├── facilities/    (Facility system)
├── logic/         (Base logic)
├── ui/            (Base screens)
├── data/          (Facility definitions)
└── ...
```

**Status:** ✅ Generally aligned

---

### 6. Operational Layer - Economy

**Wiki File:** wiki/systems/Economy.md  
**Engine Folder:** engine/economy/

**Expected Structure:**
```
engine/economy/
├── finance/       (Finance system)
├── marketplace/   (Marketplace/trading)
├── research/      (Research system)
├── manufacturing/ (Manufacturing system)
└── ...
```

**Status:** ⚠️ Verify (research system location)

---

### 7. Operational Layer - Finance

**Wiki File:** wiki/systems/Finance.md  
**Engine Folder:** engine/economy/finance/

**Status:** ⚠️ Need to verify location

---

### 8. Tactical Layer - Battlescape

**Wiki File:** wiki/systems/Battlescape.md  
**Engine Folder:** engine/battlescape/

**Status:** ✅ Good (large system, well-organized)

---

### 9. Tactical Layer - Units

**Wiki File:** wiki/systems/Units.md  
**Engine Folder:** engine/content/units/ (NEEDS MOVE)

**Current Location:** engine/core/units/ or elsewhere  
**Problem:** Should be in content/, not core/  
**Solution:** Move to engine/content/units/

---

### 10. Tactical Layer - AI Systems

**Wiki File:** wiki/systems/AI%20Systems.md  
**Engine Folder:** engine/ai/

**Status:** ✅ Good (dedicated folder)

---

### 11. Meta - GUI

**Wiki File:** wiki/systems/Gui.md  
**Engine Folders:** engine/scenes/, engine/ui/, engine/widgets/ → engine/gui/

**Status:** ❌ CRITICAL - Needs unification

**Current Problems:**
- Three separate folders
- Unclear which goes where
- Requires scattered across files

**Solution:** Create gui/ and merge all three

---

### 12. Meta - Assets

**Wiki File:** wiki/systems/Assets.md  
**Engine Folder:** engine/assets/

**Status:** ✅ Good (dedicated folder)

---

### 13. Meta - Integration

**Wiki File:** wiki/systems/Integration.md  
**Engine Folder:** engine/core/

**Status:** ✅ Good (state management in core/)

---

### 14. Meta - Analytics

**Wiki File:** wiki/systems/Analytics.md  
**Engine Folder:** engine/analytics/

**Status:** ✅ Good (dedicated folder)

---

### 15. Meta - Lore

**Wiki File:** wiki/systems/Lore.md  
**Engine Folder:** engine/lore/

**Status:** ✅ Good (dedicated folder)

---

### 16. Meta - 3D

**Wiki File:** wiki/systems/3D.md  
**Engine Folder:** engine/battlescape/rendering_3d/

**Status:** ✅ Good (part of battlescape)

---

## Additional Engine Folders

### Not in Wiki Systems Index

| Folder | Purpose | Wiki Mapping | Status |
|--------|---------|--------------|--------|
| accessibility/ | Accessibility features | None | ✅ Documented in separate docs |
| localization/ | Internationalization | None | ✅ Documented in separate docs |
| network/ | Multiplayer/networking | None | ✅ Documented in separate docs |
| tutorial/ | Tutorial system | None | ✅ Documented in separate docs |
| utils/ | Utility functions | None | ⚠️ Check if should consolidate |
| core/ | Core engine | None (Integration.md related) | ✅ Good |
| mods/ | Mod system | None | ✅ Good |

---

## Investigation Required

### Question 1: Where is Crafts system?

**File to Find:** Look for craft-related code
```bash
grep -r "craft" engine/core/crafts/ 2>/dev/null | head -5
grep -r "craft" engine/geoscape/ 2>/dev/null | head -5
```

**Current Hypothesis:** In engine/core/crafts/  
**Required Move:** To engine/content/crafts/

---

### Question 2: Where is Finance system?

**File to Find:** Look for finance-related code
```bash
grep -r "finance" engine/economy/ 2>/dev/null
```

**Current Hypothesis:** In engine/economy/finance/ (if exists) or not implemented  
**Action:** Verify existence and location

---

### Question 3: Where is Items system?

**File to Find:** Look for item-related code
```bash
find engine -name "*item*" -type f
```

**Current Hypothesis:** In engine/core/items/  
**Required Move:** To engine/content/items/

---

### Question 4: Where is Units system?

**File to Find:** Look for unit-related code
```bash
find engine -name "*unit*" -type f
```

**Current Hypothesis:** Scattered or in engine/core/units/  
**Required Move:** To engine/content/units/

---

### Question 5: What's in engine/utils/?

**Files to Check:**
```bash
ls -la engine/utils/
```

**Decision Needed:** Keep as-is or consolidate into core/?

---

## Misplaced Files to Check

### Research System

**Expected Location:** engine/economy/research/  
**Problem Statement:** "research is in completely wrong folder"

**Search Strategy:**
```bash
find engine -name "*research*" -type f | head -10
grep -r "research" engine/ | grep "require" | head -5
```

**Action:** Locate and move to proper location

---

### Other Potential Misplacements

Check for:
- Salvage system (should be in economy/)
- Marketplace system (should be in economy/marketplace/)
- Supplier system (should be in economy/suppliers/)
- Reputation system (should be in politics/ or core/reputation/)
- Relations system (should be in politics/relations/)

---

## Implementation Roadmap

### Phase 1: Create New Folder Structure (0.5h)
```bash
mkdir engine/content
mkdir engine/gui
```

### Phase 2: Move Content Folders (2h)
```bash
move engine/core/crafts -> engine/content/crafts
move engine/core/items -> engine/content/items
move engine/core/units -> engine/content/units
```

### Phase 3: Merge GUI Components (3h)
```bash
move engine/scenes -> engine/gui/scenes
move engine/ui -> engine/gui/ui
move engine/widgets -> engine/gui/widgets
```

### Phase 4: Find & Fix Misplaced Files (4h)
- Locate research, finance, salvage, marketplace
- Move to appropriate system folders
- Update requires

### Phase 5: Update All Requires (5h)
- Update 100+ require statements
- Test each batch
- Verify no broken requires

### Phase 6: Documentation (2h)
- Update navigation guides
- Create folder structure diagram
- Add migration notes

### Phase 7: Testing (2h)
- Run game and check console
- Verify all systems load
- Test transitions between screens

---

## Success Criteria

- [ ] All 19 wiki systems map to engine folders
- [ ] content/ folder exists with items/, units/, crafts/
- [ ] gui/ folder exists with scenes/, ui/, widgets/
- [ ] No broken require() statements
- [ ] Game runs without console errors
- [ ] All tests pass
- [ ] Navigation.md updated with new structure

---

## Next Steps

1. **Verify Misplaced Files** - Run investigation searches above
2. **Create Task Implementation Plan** - Document exact moves needed
3. **Begin Folder Restructuring** - Follow Phase 1-3 steps
4. **Update Requires** - Systematically fix require paths
5. **Test & Document** - Verify and update navigation

---

**Report Generated:** October 21, 2025  
**Status:** Ready for Implementation Phase  
**Estimated Time:** 16-24 hours total

