# AlienFall Project - Comprehensive Workspace Structure Analysis

**Date:** October 25, 2025  
**Scope:** Full project audit - all 249 directories analyzed

---

## Executive Summary

The AlienFall project contains **249 directories** organized across 10+ major subsystems. Analysis reveals:

- **74 minimal folders** (containing ≤2 files with no subdirectories)
- **1 completely empty folder** (`tools/spritesheet_generator/cfg`)
- **Significant structural redundancy** across mods, design, and docs
- **Many placeholder folders** with only README.md files
- **Multiple parallel content hierarchies** (design/mechanics vs mods/core/rules)

### Key Issues Identified

1. **Placeholder/Future-Feature Folders** - Many folders exist only for organizational purposes with no actual implementation
2. **Duplicate Hierarchies** - Content is documented in multiple places (design/mechanics, api/, mods/core/rules/)
3. **Empty Shell Folders** - Asset/content folders are just directories waiting for content
4. **Organizational Bloat** - Too many nested levels for minimal content
5. **Mixed Purposes** - Some folders blur the line between documentation, examples, and active code

---

## Detailed Folder Analysis

### Category 1: EMPTY & COMPLETELY REDUNDANT (Safe to Remove)

#### 1. `tools/spritesheet_generator/cfg/` ❌
- **Status:** Completely empty (0 files, 0 subdirectories)
- **Purpose:** Was meant for sprite generator configuration
- **Action:** **DELETE** - No content, no references
- **Impact:** Low - no dependencies

#### 2. `docs/content/` (Parent - No Files)
- **Status:** Directory exists only as container (0 files, 2 subdirs)
- **Purpose:** Organizational container
- **Action:** **CONSOLIDATE** - Move `unit_systems/perks.md` and `units/pilots.md` up to `docs/`
- **Impact:** Reduces nesting depth

#### 3. `design/gaps/` ⚠️
- **Status:** README.md only - historical cleanup record
- **Current Content:** Documentation that gaps were resolved
- **Purpose:** Historical tracking (now obsolete)
- **Action:** **DELETE** - Task complete, information archived
- **Impact:** Documentation cleanup

---

### Category 2: PLACEHOLDER/FUTURE FEATURES (Not Yet Implemented)

#### 1. `engine/network/` 
- **Files:** README.md only (1 file)
- **Purpose:** "Multiplayer support - Phase 5+ (not yet implemented)"
- **Status:** Placeholder for future feature
- **Reality:** No actual multiplayer code exists
- **Action:** **ARCHIVE** - Move to separate `_FUTURE` directory or mark clearly as placeholder
- **Impact:** Low - no active code

#### 2. `engine/portal/`
- **Files:** README.md only (1 file)
- **Lua Code:** None (should have portal_system.lua according to README)
- **Purpose:** Portal mechanics system
- **Status:** Design documented but no implementation
- **Action:** **IMPLEMENT OR ARCHIVE** - Either add actual code or move to _FUTURE
- **Impact:** Medium - affects late-game mechanics

#### 3. `engine/tutorial/`
- **Purpose:** Tutorial system for onboarding
- **Status:** Structure exists but likely minimal implementation
- **Action:** **REVIEW** - Check if active implementation exists
- **Impact:** Medium - user experience feature

#### 4. `engine/lore/quests/`
- **Files:** README.md only
- **Purpose:** Quest system integration
- **Status:** Placeholder for quest narrative
- **Action:** **IMPLEMENT OR ARCHIVE**
- **Impact:** Low-Medium - optional content

#### 5. `engine/lore/events/`
- **Files:** README.md only (1 file, 0 actual logic)
- **Purpose:** Event narrative system
- **Status:** Placeholder
- **Action:** **CONSOLIDATE** - Could merge with `engine/content/events`
- **Impact:** Low

---

### Category 3: DOCUMENTATION PLACEHOLDERS (README-Only Folders with No Implementation)

These folders exist to document future/aspirational features but have no actual Lua code:

#### Engine Layer (No Code)
```
engine/ai/diplomacy/              - README only (referenced system not implemented)
engine/assets/fonts/              - README only (asset directory, wait for fonts)
engine/assets/sounds/             - README only (asset directory, wait for sounds)
engine/basescape/base/            - README only (should have base.lua)
engine/basescape/data/            - README only (should have basescape data)
engine/basescape/services/        - README only (service utilities)
engine/battlescape/ai/            - README only (combat AI not implemented)
engine/battlescape/battle/        - README only (battle system stub)
engine/core/facilities/           - README only (utilities folder, empty)
engine/core/terrain/              - README only (terrain utilities)
engine/geoscape/data/             - README only (geoscape data configs)
engine/geoscape/portal/           - README only (portal system)
engine/geoscape/screens/          - README only (screen transitions)
engine/politics/diplomacy/        - README only (diplomacy AI stub)
engine/politics/government/       - README only (government system)
```

**Total:** 15 folders documented but not implemented

#### Asset Directories (Awaiting Content)
```
engine/assets/images/missions/    - Asset staging area
engine/assets/systems/            - System asset store
```

---

### Category 4: CONTENT STAGING AREAS (Empty or Near-Empty)

**Mods Content Hierarchy** - Multiple parallel structures:

```
mods/core/tilesets/
  ├── _common/           - README only (tileset commons)
  ├── city/              - README only
  ├── farmland/          - README only
  ├── furnitures/        - README only
  ├── ufo_ship/          - README only
  └── weapons/           - README only

mods/new/
  ├── assets/fonts/      - README only (awaiting fonts)
  ├── assets/sounds/     - README only (awaiting sounds)
  ├── faces/             - 2 files (base template)
  └── rules/
      ├── battle/        - README only
      └── unit/          - README only

mods/examples/complete/
  ├── facilities/        - README only (example template)
  ├── technology/        - README only (example template)
  ├── units/             - README only (example template)
  └── weapons/           - README only (example template)
```

**Status:** These are example templates and await content creation

---

### Category 5: DESIGN DOCUMENTATION (Parallel Hierarchies)

**Issue:** Content documented in multiple places

#### 1. **Design Mechanics vs API**
```
design/mechanics/           - Game mechanics design documents
api/                        - System interfaces and specifications
```

Both document the same systems (Units, Crafts, Missions, etc.)

#### 2. **Design Mechanics vs Mods Rules**
```
design/mechanics/           - Design specs (what we want)
mods/core/rules/           - TOML configurations (what we built)
```

**Example:** Unit system exists in both:
- `design/mechanics/units.md` - Design specification
- `mods/core/rules/units/` - Actual unit definitions
- `api/UNITS.md` - API documentation

**Action:** **STREAMLINE** - Establish single source of truth:
- Move active content to `mods/core/rules/`
- Keep `design/` for aspirational/future designs only
- Keep `api/` for system contracts only

---

### Category 6: DOCUMENTATION FOLDERS (Docs/ Proliferation)

```
docs/ai/                  - 1 file (alien_diplomat.md - should be in engine/ai/)
docs/content/             - Container (0 files)
  ├── unit_systems/       - 1 file (perks.md)
  └── units/              - 1 file (pilots.md)
docs/lore/                - 2 files (narrative docs)
docs/testing/             - 1 file (TEST_FRAMEWORK.md)
```

**Issue:** Documentation scattered across multiple dirs instead of centralized

**Action:** **CONSOLIDATE** - Move to `api/` or maintain in `architecture/`

---

### Category 7: TEST FRAMEWORK DUPLICATION

```
tests/framework/ui_testing/    - 1 file (ui_test_framework.lua)
tests/frameworks/              - 2 files (test_framework.lua, etc.)
```

**Status:** Duplicate test framework structures

**Action:** **MERGE** - Consolidate into single `tests/framework/` with clear separation

---

### Category 8: RESTRUCTURING/TEMPORARY ARTIFACTS

```
engine/restructuring_tools/      - 2 files (all_managers.lua, ...)
docs/ENGINE_RESTRUCTURING_*.md   - Multiple restructuring documentation files
migrate/                         - Migration scripts
tools/structure/                 - Structure audit tools
```

**Status:** These are project maintenance artifacts from restructuring phase

**Action:** **ARCHIVE** - Move to `.git/history/` or `archive/` after restructuring complete

---

### Category 9: LEGITIMATE SYSTEM FOLDERS (KEEP THESE)

These folders are properly organized with real implementation:

#### Engine Systems ✅
```
engine/core/              - Core engine (state, events, assets, data, systems)
engine/battlescape/       - Combat system (well-organized)
engine/geoscape/          - Strategic layer (comprehensive)
engine/basescape/         - Base management
engine/economy/           - Economic systems
engine/politics/          - Political systems
engine/gui/               - UI framework
engine/content/           - Game content (crafts, units, items, missions, events, factions)
```

#### Content Systems ✅
```
mods/core/                - Primary game content
  ├── rules/             - Game rules (TOML)
  ├── missions/          - Mission definitions
  ├── events/            - Event definitions
  ├── factions/          - Faction definitions
  ├── lore/              - Narrative content
```

#### API Documentation ✅
```
api/                      - System interfaces (proper documentation)
architecture/             - Design patterns and system design
```

---

## Recommended Removal/Consolidation Plan

### PHASE 1: Safe Deletions (No Code Dependencies)
✅ **Safe to delete immediately:**

1. `tools/spritesheet_generator/cfg/` - Completely empty
2. `design/gaps/` - Historical cleanup doc (keep README context but can delete)

**Time:** 5 minutes  
**Risk:** None

### PHASE 2: Archive Future Features
⚠️ **Archive (don't delete, but separate from active code):**

1. `engine/network/` - Multiplayer placeholder
2. `engine/portal/` - Portal system placeholder (unless actively developing)
3. Create `_FUTURE/` or mark folders clearly as "NOT YET IMPLEMENTED"

**Time:** 15 minutes  
**Risk:** Low

### PHASE 3: Keep Docs As-Is (Intentional Structure)
📝 **Leave /docs/ folder intact:**

1. `/docs/` folder will be kept as-is for general project documentation
2. Separate from `/api/` which contains system specifications
3. No consolidation or moves needed
4. Keep docs structured as: ai/, content/, lore/, testing/

**Files Affected:** None  
**Time:** 0 minutes (skipped)  
**Risk:** None

### PHASE 4: Test Framework Consolidation
🧪 **Consolidate test frameworks:**

1. Merge `tests/framework/ui_testing/` into `tests/framework/`
2. Consolidate frameworks into single test framework location
3. Update test imports

**Time:** 20 minutes  
**Risk:** Medium (test infrastructure impact)

### PHASE 5: Clean Empty Asset Directories
📁 **Restructure asset staging areas:**

1. Consider consolidating all asset staging into single `engine/assets/` structure
2. Remove or consolidate `engine/assets/images/missions/`, `engine/assets/systems/`

**Time:** 15 minutes  
**Risk:** Low

### PHASE 6: Mod Structure Cleanup
🎮 **Organize mod content:**

1. Clarify purpose of `mods/new/` vs `mods/examples/` vs `mods/core/`
2. Document which are active, which are templates
3. Consider moving examples to `examples/mods/` instead

**Time:** 30 minutes  
**Risk:** Low

### PHASE 7: Document Duplication Resolution
📚 **Eliminate design/mechanics vs api/rules duplication:**

1. Establish rule: `api/` = system contracts & specs
2. Establish rule: `design/mechanics/` = aspirational/future designs
3. Establish rule: `mods/core/rules/` = actual implemented content
4. Audit and consolidate overlapping files

**Time:** 1-2 hours  
**Risk:** Medium (docmentation strategy shift)

---

## Current Stats

| Metric | Count |
|--------|-------|
| Total Directories | 249 |
| Minimal Folders (≤2 files, no subs) | 74 |
| Completely Empty | 1 |
| README-Only Folders | ~40 |
| Placeholder/Future Features | ~15 |
| Legitimate Active Code Folders | ~60 |
| Documentation-Only Folders | ~25 |
| Asset/Staging Areas | ~20 |

---

## Cleanup Opportunity Summary

| Category | Count | Risk | Effort |
|----------|-------|------|--------|
| Delete (completely empty) | 1 | None | 5 min |
| Archive (future features) | 3-5 | Low | 15 min |
| Consolidate (docs) | 5-7 | Low | 45 min |
| Merge (test frameworks) | 2 | Medium | 20 min |
| Clarify (mods structure) | 3-4 | Low | 30 min |
| Resolve (duplication) | 10-15 | Medium | 2 hrs |
| **Total** | **~30 items** | **Low-Med** | **~3.5 hours** |

---

## Before/After Projection

### BEFORE
- 249 directories
- 74 minimal/empty folders
- 40+ README-only folders
- Multiple parallel hierarchies
- Scattered documentation

### AFTER (Post-Cleanup)
- ~220 directories (10% reduction)
- ~20 minimal folders (necessary structure)
- ~5 README-only folders (intentional placeholders)
- Single source of truth per system
- Centralized documentation

---

## Specific Folder Recommendations

### 🗑️ DELETE
```
tools/spritesheet_generator/cfg/              # Completely empty
design/gaps/                                   # Historical, task complete
```

### 📦 ARCHIVE (Move to _FUTURE or separate branch)
```
engine/network/                               # Multiplayer placeholder
engine/portal/                                # Portal system (if not implementing soon)
engine/tutorial/                              # Tutorial (if not active)
```

### 🔀 CONSOLIDATE
```
docs/content/unit_systems/                    # Move to api/ or merge
docs/content/units/                           # Move to api/PILOTS.md
docs/lore/                                    # Move to docs/ or lore/
tests/framework/ui_testing/                   # Merge with tests/framework/
engine/lore/events/                           # Merge with engine/content/events/
engine/lore/quests/                           # Merge with engine/content/
```

### ⚠️ CLARIFY & DOCUMENT
```
mods/new/                                     # Is this a template?
mods/examples/                                # How different from mods/new/?
design/mechanics/ vs api/ vs mods/core/rules/ # Establish hierarchy
engine/assets/systems/                        # Purpose? Usage?
```

### 📋 MARK AS PLACEHOLDER
```
engine/ai/diplomacy/                          # Add [NOT YET IMPLEMENTED]
engine/basescape/data/                        # Add [AWAITING IMPLEMENTATION]
engine/geoscape/portal/                       # Add [PLACEHOLDER]
(and 15+ others)
```

---

## Key Insights

### 1. **Organizational Patterns**
The project has **multiple parallel hierarchies** for the same content:
- Design specifications in `design/mechanics/`
- API contracts in `api/`
- Actual implementation in `engine/` and `mods/core/rules/`
- This creates redundancy and maintenance burden

### 2. **Placeholder Accumulation**
Over 40 folders exist with **only README.md files**. This is intentional for:
- Future feature planning
- Organizational scaffolding
- Documentation-first development

However, it creates clutter. Consider marking clearly.

### 3. **Asset Staging Pattern**
Many asset directories are **empty shells** waiting for content:
- `engine/assets/sounds/` - Awaiting audio
- `engine/assets/fonts/` - Awaiting fonts
- `mods/*/assets/` - Awaiting content

This is normal for live projects.

### 4. **Documentation Proliferation**
Too many places for documentation:
- `/docs/` - General docs
- `/api/` - System APIs
- `/design/` - Design specs
- `/architecture/` - Architecture
- `/lore/` - Lore/narrative
- Various README.md files scattered throughout

Consolidation would improve maintainability.

### 5. **Test Infrastructure Duplication**
Test frameworks exist in multiple locations:
- `tests/framework/`
- `tests/frameworks/` (note pluralization)
- `tests/runners/`

Unification needed.

---

## Maintenance Recommendations

### For the Future
1. **Before creating a new folder**, ask: "Will this have code/content, or is it just documentation?"
2. **Mark placeholder folders** with `[PLACEHOLDER]` or `[NOT YET IMPLEMENTED]` in README
3. **Consolidate related docs** at project boundaries
4. **Use single source of truth** - not multiple documentation of same system
5. **Archive, don't delete** - Use branches or archive/ folders for deprecated structures

### Governance Rules Suggested
- ✅ New feature → create engine/ code + api/ documentation + mods/ content
- ✅ New documentation → add to api/ or architecture/, not scattered docs/
- ✅ New assets → organize under engine/assets/ with clear purpose
- ❌ Don't create "placeholder" folders without README explaining purpose
- ❌ Don't document same system in multiple places without clear hierarchy

---

## References

- **Total Directories Analyzed:** 249
- **Analysis Date:** October 25, 2025
- **Scope:** Full recursive scan including all subdirectories
- **Methodology:** PowerShell-based directory analysis with file counting

---

**Next Steps:**
1. Review this analysis
2. Prioritize cleanup phases
3. Execute Phase 1 (safe deletions) first
4. Gather team feedback before Phases 3-7
5. Update project documentation with new governance rules
