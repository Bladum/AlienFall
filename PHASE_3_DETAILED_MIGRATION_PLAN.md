# 📋 PHASE 3: DETAILED MIGRATION PLAN

**Scope:** Complete file-by-file breakdown of what moves where  
**Status:** Ready for Phase 4 (Migration Tools)  
**Timeline:** ~18-27 hours total project time  

---

## ENGINE MIGRATION - DETAILED FILE MOVEMENTS

### Core & Foundation (DO THESE FIRST - No dependencies)

These are utilities and core systems that nothing else depends on heavily:

#### `engine/utils/` → `engine/core/utils/`
**Current files to MOVE:**
- `utils/lua_extensions.lua` → `core/utils/lua_extensions.lua`
- `utils/debug_utils.lua` → `core/utils/debug_utils.lua`
- `utils/file_utils.lua` → `core/utils/file_utils.lua`
- `utils/table_utils.lua` → `core/utils/table_utils.lua`
- `utils/math_utils.lua` → `core/utils/math_utils.lua`
- `utils/string_utils.lua` → `core/utils/string_utils.lua`
- `utils/random_utils.lua` → `core/utils/random_utils.lua`
- `utils/README.md` → `core/utils/README.md`

**Import changes in moved files:** NONE (they're leaf modules, nothing requires them yet)

**Other files that require these:** Check for `require("utils.X")` in remaining files

#### `engine/core/` (CONSOLIDATE - already in right place)
**Current structure - FLATTEN one level:**
```
core/
├── state_manager.lua
├── event_system.lua
└── time_manager.lua
```

**STAYS THE SAME:** No changes needed to core/ itself

---

### Systems Layer Creation

Create `engine/systems/` folder and move game systems there:

#### `engine/ai/` → `engine/systems/ai/`
**Files to MOVE:**
- `ai/tactical.lua` → `systems/ai/tactical.lua`
- `ai/strategic.lua` → `systems/ai/strategic.lua`
- `ai/faction_ai.lua` → `systems/ai/faction_ai.lua`
- `ai/README.md` → `systems/ai/README.md`

#### `engine/economy/` → `engine/systems/economy/`
**Files to MOVE:**
- `economy/funds.lua` → `systems/economy/funds.lua`
- `economy/market.lua` → `systems/economy/market.lua`
- `economy/production.lua` → `systems/economy/production.lua`
- `economy/upkeep.lua` → `systems/economy/upkeep.lua`
- `economy/README.md` → `systems/economy/README.md`

#### `engine/politics/` → `engine/systems/politics/`
**Files to MOVE:**
- `politics/diplomacy.lua` → `systems/politics/diplomacy.lua`
- `politics/relations.lua` → `systems/politics/relations.lua`
- `politics/factions.lua` → `systems/politics/factions.lua`
- `politics/README.md` → `systems/politics/README.md`

#### `engine/analytics/` → `engine/systems/analytics/`
**Files to MOVE:**
- `analytics/metrics.lua` → `systems/analytics/metrics.lua`
- `analytics/tracker.lua` → `systems/analytics/tracker.lua`
- `analytics/reporting.lua` → `systems/analytics/reporting.lua`
- `analytics/README.md` → `systems/analytics/README.md`

#### `engine/content/` → `engine/systems/content/`
**Files to MOVE:**
- `content/loader.lua` → `systems/content/loader.lua`
- `content/registry.lua` → `systems/content/registry.lua`
- `content/validator.lua` → `systems/content/validator.lua`
- `content/README.md` → `systems/content/README.md`

#### `engine/lore/` → `engine/systems/lore/`
**Files to MOVE:**
- `lore/manager.lua` → `systems/lore/manager.lua`
- `lore/events.lua` → `systems/lore/events.lua`
- `lore/README.md` → `systems/lore/README.md`

#### `engine/tutorial/` → `engine/systems/tutorial/`
**Files to MOVE:**
- `tutorial/manager.lua` → `systems/tutorial/manager.lua`
- `tutorial/lessons.lua` → `systems/tutorial/lessons.lua`
- `tutorial/README.md` → `systems/tutorial/README.md`

---

### Layers - Game State Layers

Create `engine/layers/` folder and move layer-specific systems:

#### `engine/geoscape/` → `engine/layers/geoscape/`
**Files to MOVE (entire folder):**
- `geoscape/manager.lua` → `layers/geoscape/manager.lua`
- `geoscape/regions.lua` → `layers/geoscape/regions.lua`
- `geoscape/countries.lua` → `layers/geoscape/countries.lua`
- `geoscape/ufos.lua` → `layers/geoscape/ufos.lua`
- `geoscape/crafts.lua` → `layers/geoscape/crafts.lua`
- `geoscape/renderer.lua` → `layers/geoscape/renderer.lua`
- `geoscape/README.md` → `layers/geoscape/README.md`

#### `engine/basescape/` → `engine/layers/basescape/`
**Files to MOVE (entire folder):**
- `basescape/manager.lua` → `layers/basescape/manager.lua`
- `basescape/grid.lua` → `layers/basescape/grid.lua`
- `basescape/facilities.lua` → `layers/basescape/facilities.lua`
- `basescape/personnel.lua` → `layers/basescape/personnel.lua`
- `basescape/crafts.lua` → `layers/basescape/crafts.lua`
- `basescape/research.lua` → `layers/basescape/research.lua`
- `basescape/manufacturing.lua` → `layers/basescape/manufacturing.lua`
- `basescape/renderer.lua` → `layers/basescape/renderer.lua`
- `basescape/README.md` → `layers/basescape/README.md`

#### `engine/battlescape/` → `engine/layers/battlescape/`
**Files to MOVE (entire folder):**
- `battlescape/manager.lua` → `layers/battlescape/manager.lua`
- `battlescape/map.lua` → `layers/battlescape/map.lua`
- `battlescape/units.lua` → `layers/battlescape/units.lua`
- `battlescape/actions.lua` → `layers/battlescape/actions.lua`
- `battlescape/combat.lua` → `layers/battlescape/combat.lua`
- `battlescape/renderer.lua` → `layers/battlescape/renderer.lua`
- `battlescape/pathfinding.lua` → `layers/battlescape/pathfinding.lua`
- `battlescape/README.md` → `layers/battlescape/README.md`

#### `engine/interception/` → `engine/layers/interception/`
**Files to MOVE (entire folder):**
- `interception/manager.lua` → `layers/interception/manager.lua`
- `interception/combat.lua` → `layers/interception/combat.lua`
- `interception/renderer.lua` → `layers/interception/renderer.lua`
- `interception/README.md` → `layers/interception/README.md`

---

### UI Layer

#### `engine/gui/` → `engine/ui/`
**Files to MOVE (entire folder):**
- `gui/framework.lua` → `ui/framework.lua`
- `gui/elements.lua` → `ui/elements.lua`
- `gui/manager.lua` → `ui/manager.lua`
- `gui/renderer.lua` → `ui/renderer.lua`
- `gui/README.md` → `ui/README.md`

#### `engine/widgets/` → `engine/ui/widgets/`
**Files to MOVE (nested under ui):**
- `widgets/button.lua` → `ui/widgets/button.lua`
- `widgets/panel.lua` → `ui/widgets/panel.lua`
- `widgets/window.lua` → `ui/widgets/window.lua`
- `widgets/label.lua` → `ui/widgets/label.lua`
- `widgets/README.md` → `ui/widgets/README.md`

---

### Portals & Infrastructure

#### `engine/accessibility/` → STAYS (no move needed)
**Current location is correct**

#### `engine/mods/` → STAYS (no move needed)
**Current location is correct**

#### `engine/network/` → STAYS (no move needed)
**Current location is correct**

#### `engine/portal/` → STAYS (no move needed)
**Current location is correct**

#### `engine/assets/` → STAYS (no move needed)
**Current location is correct**

#### `engine/localization/` → STAYS (no move needed)
**Current location is correct**

---

## IMPORT PATH UPDATE - FIND/REPLACE MAPPINGS

**For ALL files in these locations after migration:**

### System Imports (from anywhere)
```
require("ai.                    → require("systems.ai.
require("economy.               → require("systems.economy.
require("politics.              → require("systems.politics.
require("analytics.             → require("systems.analytics.
require("content.               → require("systems.content.
require("lore.                  → require("systems.lore.
require("tutorial.              → require("systems.tutorial.
```

### Layer Imports (from anywhere)
```
require("geoscape.              → require("layers.geoscape.
require("basescape.             → require("layers.basescape.
require("battlescape.           → require("systems.battlescape.
require("interception.          → require("layers.interception.
```

### UI Imports (from anywhere)
```
require("gui.                   → require("ui.
require("widgets.               → require("ui.widgets.
```

### Utils Imports (from anywhere)
```
require("utils.                 → require("core.utils.
```

---

## FILE-BY-FILE MIGRATION CHECKLIST

### Phase 1: Copy New Structure (no deletes yet)

- [ ] Create `engine/systems/` directory
- [ ] Create `engine/layers/` directory  
- [ ] Create `engine/ui/` directory
- [ ] Create `engine/core/utils/` directory
- [ ] Copy all files to new locations (don't delete originals yet)
- [ ] Verify all copied files present

### Phase 2: Update Imports in Moved Files

**AI System files:**
- [ ] `engine/systems/ai/tactical.lua` - update any `require("utils.X")` to `require("core.utils.X")`
- [ ] `engine/systems/ai/strategic.lua` - update any `require("utils.X")` to `require("core.utils.X")`
- [ ] `engine/systems/ai/faction_ai.lua` - update any `require("utils.X")` to `require("core.utils.X")`

**Economy System files:**
- [ ] `engine/systems/economy/funds.lua` - update imports
- [ ] `engine/systems/economy/market.lua` - update imports
- [ ] `engine/systems/economy/production.lua` - update imports
- [ ] `engine/systems/economy/upkeep.lua` - update imports

**Politics System files:**
- [ ] `engine/systems/politics/diplomacy.lua` - update imports
- [ ] `engine/systems/politics/relations.lua` - update imports
- [ ] `engine/systems/politics/factions.lua` - update imports

**Analytics System files:**
- [ ] `engine/systems/analytics/metrics.lua` - update imports
- [ ] `engine/systems/analytics/tracker.lua` - update imports
- [ ] `engine/systems/analytics/reporting.lua` - update imports

**Content System files:**
- [ ] `engine/systems/content/loader.lua` - update imports
- [ ] `engine/systems/content/registry.lua` - update imports
- [ ] `engine/systems/content/validator.lua` - update imports

**Lore System files:**
- [ ] `engine/systems/lore/manager.lua` - update imports
- [ ] `engine/systems/lore/events.lua` - update imports

**Tutorial System files:**
- [ ] `engine/systems/tutorial/manager.lua` - update imports
- [ ] `engine/systems/tutorial/lessons.lua` - update imports

**Geoscape Layer files (40+ files):**
- [ ] `engine/layers/geoscape/manager.lua` - update all system requires (ai.*, economy.*, etc)
- [ ] `engine/layers/geoscape/regions.lua` - update all system requires
- [ ] `engine/layers/geoscape/countries.lua` - update all system requires
- [ ] `engine/layers/geoscape/ufos.lua` - update all system requires
- [ ] `engine/layers/geoscape/crafts.lua` - update all system requires
- [ ] `engine/layers/geoscape/renderer.lua` - update all system requires

**Basescape Layer files (40+ files):**
- [ ] `engine/layers/basescape/manager.lua` - update all system requires
- [ ] `engine/layers/basescape/grid.lua` - update all system requires
- [ ] `engine/layers/basescape/facilities.lua` - update all system requires
- [ ] `engine/layers/basescape/personnel.lua` - update all system requires
- [ ] `engine/layers/basescape/crafts.lua` - update all system requires
- [ ] `engine/layers/basescape/research.lua` - update all system requires
- [ ] `engine/layers/basescape/manufacturing.lua` - update all system requires
- [ ] `engine/layers/basescape/renderer.lua` - update all system requires

**Battlescape Layer files (40+ files):**
- [ ] `engine/layers/battlescape/manager.lua` - update all system requires
- [ ] `engine/layers/battlescape/map.lua` - update all system requires
- [ ] `engine/layers/battlescape/units.lua` - update all system requires
- [ ] `engine/layers/battlescape/actions.lua` - update all system requires
- [ ] `engine/layers/battlescape/combat.lua` - update all system requires
- [ ] `engine/layers/battlescape/renderer.lua` - update all system requires
- [ ] `engine/layers/battlescape/pathfinding.lua` - update all system requires

**Interception Layer files:**
- [ ] `engine/layers/interception/manager.lua` - update all system requires
- [ ] `engine/layers/interception/combat.lua` - update all system requires
- [ ] `engine/layers/interception/renderer.lua` - update all system requires

**UI files:**
- [ ] `engine/ui/framework.lua` - update all system requires
- [ ] `engine/ui/elements.lua` - update all system requires
- [ ] `engine/ui/manager.lua` - update all system requires
- [ ] `engine/ui/renderer.lua` - update all system requires
- [ ] All widget files in `engine/ui/widgets/` - update requires

**Core files (that reference other systems):**
- [ ] `engine/core/state_manager.lua` - update any system requires
- [ ] `engine/core/event_system.lua` - update any system requires
- [ ] `engine/core/time_manager.lua` - update any system requires

**Entry point:**
- [ ] `engine/main.lua` - update all requires to new paths

### Phase 3: Delete Old Directories

- [ ] Delete `engine/ai/` (after verifying copied to `engine/systems/ai/`)
- [ ] Delete `engine/economy/` (after verifying copied to `engine/systems/economy/`)
- [ ] Delete `engine/politics/` (after verifying copied to `engine/systems/politics/`)
- [ ] Delete `engine/analytics/` (after verifying copied to `engine/systems/analytics/`)
- [ ] Delete `engine/content/` (after verifying copied to `engine/systems/content/`)
- [ ] Delete `engine/lore/` (after verifying copied to `engine/systems/lore/`)
- [ ] Delete `engine/tutorial/` (after verifying copied to `engine/systems/tutorial/`)
- [ ] Delete `engine/geoscape/` (after verifying copied to `engine/layers/geoscape/`)
- [ ] Delete `engine/basescape/` (after verifying copied to `engine/layers/basescape/`)
- [ ] Delete `engine/battlescape/` (after verifying copied to `engine/layers/battlescape/`)
- [ ] Delete `engine/interception/` (after verifying copied to `engine/layers/interception/`)
- [ ] Delete `engine/gui/` (after verifying copied to `engine/ui/`)
- [ ] Delete old `engine/utils/` (after verifying moved to `engine/core/utils/`)

---

## TEST FILES REQUIRING IMPORT UPDATES

**Location:** All `.lua` test files across all test subdirectories

### Test Subdirectories Affected (50-60 files total)

```
tests/
├── unit/
│   ├── test_ai_tactical.lua                    ✏️ Update
│   ├── test_economy_system.lua                 ✏️ Update
│   ├── test_politics.lua                       ✏️ Update
│   ├── test_analytics.lua                      ✏️ Update
│   ├── test_content_system.lua                 ✏️ Update
│   └── ... (all other unit tests)              ✏️ Update
│
├── battlescape/
│   ├── test_battlescape_manager.lua            ✏️ Update
│   ├── test_combat_system.lua                  ✏️ Update
│   ├── test_units.lua                          ✏️ Update
│   └── ... (all battlescape tests)             ✏️ Update
│
├── geoscape/
│   ├── test_geoscape_manager.lua               ✏️ Update
│   ├── test_regions.lua                        ✏️ Update
│   ├── test_ufos.lua                           ✏️ Update
│   └── ... (all geoscape tests)                ✏️ Update
│
├── basescape/
│   ├── test_basescape_manager.lua              ✏️ Update
│   ├── test_facilities.lua                     ✏️ Update
│   ├── test_personnel.lua                      ✏️ Update
│   └── ... (all basescape tests)               ✏️ Update
│
├── integration/
│   ├── test_geoscape_integration.lua           ✏️ Update
│   ├── test_basescape_integration.lua          ✏️ Update
│   ├── test_battlescape_integration.lua        ✏️ Update
│   └── ... (all integration tests)             ✏️ Update
│
├── systems/
│   ├── test_ai_system.lua                      ✏️ Update
│   ├── test_economy_system.lua                 ✏️ Update
│   └── ... (all system tests)                  ✏️ Update
│
├── battle/
│   ├── test_combat.lua                         ✏️ Update
│   └── ... (all battle tests)                  ✏️ Update
│
├── widgets/
│   ├── test_ui_buttons.lua                     ✏️ Update (gui → ui)
│   ├── test_ui_panels.lua                      ✏️ Update (gui → ui)
│   └── ... (all widget tests)                  ✏️ Update
│
├── performance/
│   └── ... (all performance tests)             ✏️ Update
│
├── mock/
│   ├── engine/
│   │   ├── ai/ → systems/ai/                   📁 Reorganize
│   │   ├── economy/ → systems/economy/         📁 Reorganize
│   │   ├── geoscape/ → layers/geoscape/        📁 Reorganize
│   │   ├── basescape/ → layers/basescape/      📁 Reorganize
│   │   ├── battlescape/ → layers/battlescape/  📁 Reorganize
│   │   ├── gui/ → ui/                          📁 Reorganize
│   │   └── utils/ → core/utils/                📁 Reorganize
│   └── (all mock data files need new paths)
│
└── framework/
    ├── test_framework.lua                      ✏️ Update (if has requires)
    └── (framework files)                       ✏️ Update
```

---

## DOCUMENTATION FILES REQUIRING UPDATES

### API Folder (15-20 files)

```
api/
├── AI_SYSTEMS.md                               ✏️ Update paths (ai → systems.ai)
├── ANALYTICS.md                                ✏️ Update paths
├── ECONOMY.md                                  ✏️ Update paths
├── POLITICS.md                                 ✏️ Update paths
├── BASESCAPE.md                                ✏️ Update paths
├── BATTLESCAPE.md                              ✏️ Update paths
├── GEOSCAPE.md                                 ✏️ Update paths
├── GEOSCAPE_API.md                             ✏️ Update paths
├── INTEGRATION.md                              ✏️ Update paths (all systems)
├── SYNCHRONIZATION_GUIDE.md                    ✏️ Update paths
├── GUI.md                                      ✏️ Update paths (gui → ui)
├── GAME_API.toml                               ✏️ No change (schema same)
└── ... (other API docs with path refs)         ✏️ Update
```

### Architecture Folder (4-6 files)

```
architecture/
├── README.md                                   ✏️ Update structure description
├── 01-game-structure.md                        ✏️ Update examples + diagrams
├── INTEGRATION_FLOW_DIAGRAMS.md                ✏️ Update example code paths
├── 02-procedural-generation.md                 ✏️ Update code examples
├── 03-combat-tactics.md                        ✏️ Update code examples
└── 04-base-economy.md                          ✏️ Update code examples
```

### Docs Folder (3-5 files)

```
docs/
├── CODE_STANDARDS.md                           ✏️ Update import examples
├── ENGINE_ORGANIZATION_PRINCIPLES.md           ✏️ Verify accuracy
├── IDE_SETUP.md                                ✏️ Update if has examples
└── README.md                                   ✏️ Update if references paths
```

### Github Copilot Instructions (1 file)

```
.github/
├── copilot-instructions.md                     ✏️ Update structure diagram
```

---

## TOOLS REQUIRING UPDATES

### Import Scanner (1-2 hours work)

**File:** `tools/import_scanner/scan_imports.lua`
- [ ] Update engine path patterns to recognize new structure
- [ ] Add patterns for `require("systems.*")`
- [ ] Add patterns for `require("layers.*")`
- [ ] Update expected valid paths list
- [ ] Test scanner on new structure

**File:** `tools/import_scanner/scan_imports.ps1`
- [ ] Update PowerShell path patterns

**File:** `tools/import_scanner/README.md`
- [ ] Update example output showing new paths
- [ ] Update expected valid path patterns

---

## VALIDATION CHECKLIST

After completing migration:

### Engine Structure
- [ ] All files moved to correct locations
- [ ] No duplicate files exist
- [ ] `engine/` root has only 9 directories: `core/`, `systems/`, `layers/`, `ui/`, `accessibility/`, `mods/`, `network/`, `portal/`, `assets/`, `localization/`
- [ ] `engine/main.lua` updated with new requires
- [ ] Game runs without import errors

### Tests
- [ ] All test files have updated import statements
- [ ] `tests/mock/` structure mirrors new `engine/` structure
- [ ] Full test suite runs: `tests/runners`
- [ ] All 50+ test files pass
- [ ] No "module not found" errors

### Documentation
- [ ] All 15-20 api/ files updated with new paths
- [ ] All 4-6 architecture/ files updated with examples
- [ ] All 3-5 docs/ files updated with examples
- [ ] copilot-instructions.md updated
- [ ] No broken cross-references

### Tools
- [ ] Import scanner recognizes all new paths
- [ ] Import scanner correctly validates migrated code
- [ ] Validators still work correctly

---

## ESTIMATED TIME BREAKDOWN

| Phase | Task | Hours | Notes |
|-------|------|-------|-------|
| **Prep** | Create migration automation | 2-3 | Scripts for moving, importing |
| **Phase 1** | Copy files to new structure | 1-2 | Mostly automated |
| **Phase 2a** | Update imports in engine files | 3-4 | Parallel: ~30 files to update |
| **Phase 2b** | Update test files (parallel) | 4-6 | Parallel: ~50 files to update |
| **Phase 2c** | Reorganize tests/mock structure | 1-2 | Parallel: Mirror new structure |
| **Phase 3** | Run & fix test failures | 2-3 | Catch broken imports, fix |
| **Phase 4** | Update documentation | 3-4 | Sequential: API, arch, docs |
| **Phase 5** | Final verification | 1-2 | Check all folders, cross-ref |
| **Phase 6** | Git cleanup & commits | 1 | Proper commit organization |
| **TOTAL** | **Complete migration** | **18-27h** | Depends on automation |

---

## NEXT STEPS

1. ✅ Review this Phase 3 document with team
2. ⏳ Proceed to Phase 4: Create migration automation tools
3. ⏳ Begin actual migration with Phase 5 onwards

**When ready:** See `PHASE_4_MIGRATION_TOOLS.md` (to be created next)
