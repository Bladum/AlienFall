# Detailed File Audit & Migration Guide

## Executive Summary

The project has **10-15 orphaned/duplicated files** that need reorganization:
- **`geoscape/crafts.md`** - Orphan, should move to `design/systems/geoscape/`
- **`docs/` folder** - Mixed architecture docs that should go to `architecture/`
- **`wiki/` folder** - Mixed design + API docs (design→`design/`, API→`api/`)
- **`tests/`** - Already well-organized, minimal changes needed
- **`engine/`** - 95% correct, just needs GUI folder consolidation
- **`mods/`** - Well-organized, no major changes
- **`tools/`** - Well-organized, add some cleanup

---

## Layer 1: DESIGN (Pure Mechanics & Ideas)

### Files to Move FROM:
- `wiki/systems/*.md` (19 files)
- `wiki/architecture/*.md` (3 files)
- `wiki/design/*.md` (likely some files)
- `docs/diagrams/` (entire folder)
- `geoscape/crafts.md` (orphan file)

### Files to KEEP:
- Anything about game mechanics, balance, narrative structure

### Current Status:
```
wiki/systems/       [19 files - THESE ARE DESIGN DOCS]
├── Accessibility.md
├── AI_Systems.md
├── Analytics.md
├── Assets.md
├── Basescape.md     ← Pure design
├── Battlescape.md   ← Pure design
├── Crafts.md        ← Pure design
├── Economy.md       ← Pure design
├── Finance.md
├── GUI.md
├── Geoscape.md      ← Pure design
├── Integration.md
├── Interception.md
├── Items.md
├── Lore.md
├── Politics.md
├── Rendering.md
├── Units.md
└── (and more)
```

**Action:** Move ALL of `wiki/systems/` → `design/systems/`

---

## Layer 2: API (TOML Schema & Specification)

### Files Already in Correct Location:
```
wiki/api/           [30 files - MOSTLY CORRECT]
├── BATTLESCAPE.md
├── CRAFTS.md
├── ECONOMY.md
├── FACILITIES.md
├── FINANCE.md
├── GEOSCAPE.md
├── ITEMS.md
├── INTERCEPTION.md
├── MASTER_INDEX.md
├── POLITICS.md
├── QUICK_REFERENCE.md
├── TOML_SCHEMA_REFERENCE.md
├── UNITS.md
└── (many more)
```

**Action:** Keep `wiki/api/` where it is, OR move to `api/` for cleaner separation.

### Files to Move FROM:
- `docs/mods/toml_schemas/*.md` (13 files)
- Any other TOML documentation

**Current Status:**
```
docs/mods/toml_schemas/     [13 TOML schema files]
├── README.md
├── armors_schema.md
├── campaigns_schema.md
├── (and more)
```

**Action:** Move `docs/mods/toml_schemas/` → `api/` OR merge into `wiki/api/`

---

## Layer 3: ARCHITECTURE (Implementation Guides)

### Files to Move FROM:
```
docs/                       [25+ files - MIXED CONTENT]
├── API-DOCUMENTATION-INDEX.md        [API - belongs in api/]
├── CODE_STANDARDS.md                 [Architecture ✓]
├── COMMENT_STANDARDS.md              [Architecture ✓]
├── DOCUMENTATION_STANDARD.md         [Architecture ✓]
├── Glossary.md                       [Reference - keep here]
├── PERFORMANCE.md                    [Architecture ✓]
├── README.md                         [Architecture ✓]
├── TOML_SCHEMA_SPECIFICATION.md      [API - belongs in api/]
├── developers/
│   ├── DEBUGGING.md                  [Architecture ✓]
│   ├── SETUP_WINDOWS.md              [Architecture ✓]
│   ├── TROUBLESHOOTING.md            [Architecture ✓]
│   └── WORKFLOW.md                   [Architecture ✓]
└── diagrams/
    ├── 01-game-structure.md
    ├── 02-procedural-generation.md
    ├── 03-combat-tactics.md
    ├── 04-base-economy.md
    ├── INTEGRATION_FLOW_DIAGRAMS.md
    └── README.md
```

**Action:** 
- Move `docs/developers/*` → `architecture/workflows/` or `architecture/guides/`
- Move `docs/*STANDARDS.md` → `architecture/best_practices/`
- Move `docs/diagrams/` → `design/diagrams/`
- Keep `docs/Glossary.md` as reference (or duplicate in both)

---

## Layer 4: ENGINE (Lua Game Code)

### Current Status (95% Correct):
```
engine/
├── main.lua          ✓ Correct
├── conf.lua          ✓ Correct
├── core/             ✓ Correct
├── geoscape/         ✓ Correct
├── basescape/        ✓ Correct
├── battlescape/      ✓ Correct (large folder, organized)
├── interception/     ✓ Correct
├── economy/          ✓ Correct
├── politics/         ✓ Correct
├── content/          ✓ Correct
├── gui/              ⚠ FRAGMENTED - see below
├── assets/           ✓ Correct
├── utils/            ✓ Correct
├── analytics/        ✓ Correct
├── accessibility/    ✓ Correct
├── localization/     ✓ Correct
├── lore/             ✓ Correct
├── tutorial/         ✓ Correct
└── systems/          ✓ Correct
```

### GUI Folder Issue:
Current state has **3 GUI-related folders**:
- `engine/scenes/` - Scene management
- `engine/ui/` - UI components
- `engine/widgets/` - Widget library

**Should be:** `engine/gui/` (unified) with subfolders:
```
engine/gui/
├── scenes/          [Scene management]
├── ui/              [UI screens]
├── widgets/         [Reusable UI components]
└── systems/         [UI systems: HUD, camera, etc.]
```

**Action:** Consolidate into `engine/gui/` (this is minor - mostly just folder moves)

---

## Layer 5: MODS (Game Content - TOML Data)

### Current Status (Well-Organized):
```
mods/
├── core/            ✓ Correct (default game content)
├── examples/        ✓ Correct (example mods)
└── new/             ⚠ What is this? Unclear purpose
```

**Question:** What is `mods/new/`? Should be:
- `mods/community/` if for user mods
- Merged into `mods/examples/` if example mods
- Delete if temporary/test

**Action:** Clarify and organize `mods/new/` folder

---

## Layer 6: TESTS (Unit & Integration Tests)

### Current Status (Well-Organized):
```
tests/
├── README.md                     ✓
├── mock/                         ✓ Mock data
├── unit/                         ✓ Unit tests
├── integration/                  ✓ Integration tests
├── performance/                  ✓ Performance tests
├── phase5_mock_test/             ⚠ Legacy? Archive?
├── phase5_mods_test/             ⚠ Legacy? Archive?
├── phase5_validation_test/       ⚠ Legacy? Archive?
└── runners/                      ✓ Test runners
```

**Question:** What are `phase5_*` folders? Legacy or active?

**Action:** 
- If legacy: move to `tests/archive/` or delete
- If active: integrate into main test structure

---

## Layer 7: TOOLS (Development Utilities)

### Current Status (Mostly Correct):
```
tools/
├── README.md                     ✓
├── IMPORT_SCANNER.md             ✓
├── validators/                   ✓ Validation tools
├── generators/                   ✓ Generation tools
├── editors/                      ✓ Map/world editors
├── scripts/                      ✓ Utility scripts
├── archive/                      ✓ Old tools (archived)
└── asset_verification/           ✓ Asset validation
```

**Action:** Mostly correct, just ensure old files are in `archive/`

---

## Layer 8: TASKS (Task Management)

### Current Status (Mostly Correct):
```
tasks/
├── tasks.md                      ✓ Master task file
├── TASK_TEMPLATE.md              ✓ Template
├── TODO/                         ✓ Unstarted tasks
├── IN_PROGRESS/                  ⚠ Not clear if used
├── DONE/                         ✓ Completed tasks
└── ANALYSIS/                     ⚠ Not clear if used
```

**Action:** Keep as-is, ensure consistency in usage

---

## Layer 9: TEMP (Temporary Files - NEW)

### Current Status (Non-existent):
Should create: `temp/` folder with `.gitignore` to exclude from git

**Action:** Create `temp/` folder with:
```
temp/
├── .gitignore                    [Exclude all temp files]
├── session_logs/                 [AI session transcripts]
├── generated_reports/            [Analysis reports]
└── mock_data_output/             [Generated test data]
```

---

## Layer 10: LORE (Creative Assets - NEW)

### Current Status (Scattered):
- `engine/lore/` - Code (keep in engine)
- `wiki/story/` - Story content
- `lore/` - Some lore content?

**Action:** Create `lore/` folder with:
```
lore/
├── README.md
├── story/                        [Story ideas, campaigns]
├── concepts/                     [World-building]
├── characters/                   [Character bios]
├── prompts/                      [Image generation prompts]
└── images/                       [Concept art, inspiration]
```

---

## File Movement Summary Table

| # | Current Path | File Type | New Path | Action | Priority |
|---|---|---|---|---|---|
| 1 | `wiki/systems/` | Design | `design/systems/` | Move 19 files | HIGH |
| 2 | `wiki/api/` | API | Keep OR move to `api/` | Evaluate | MEDIUM |
| 3 | `docs/mods/toml_schemas/` | API | Merge into `api/` | Move | MEDIUM |
| 4 | `docs/developers/` | Architecture | `architecture/guides/` | Move | MEDIUM |
| 5 | `docs/*STANDARDS.md` | Architecture | `architecture/best_practices/` | Move | MEDIUM |
| 6 | `docs/diagrams/` | Design | `design/diagrams/` | Move | MEDIUM |
| 7 | `geoscape/crafts.md` | Design | `design/systems/geoscape/` | Move | HIGH |
| 8 | `engine/scenes/` | Engine | `engine/gui/scenes/` | Move | MEDIUM |
| 9 | `engine/ui/` | Engine | `engine/gui/ui/` | Move | MEDIUM |
| 10 | `engine/widgets/` | Engine | `engine/gui/widgets/` | Move | MEDIUM |
| 11 | `engine/lore/` | Engine | Keep in engine | Keep | N/A |
| 12 | `mods/core/` | Mod Content | Keep | Keep | N/A |
| 13 | `mods/examples/` | Mod Content | Keep | Keep | N/A |
| 14 | `mods/new/` | Unknown | Clarify → archive/merge/delete | CLARIFY | HIGH |
| 15 | `tests/phase5_*` | Tests | `tests/archive/` | Archive/Clean | MEDIUM |
| 16 | `tasks/` | Task Mgmt | Keep | Keep | N/A |
| 17 | `tools/` | Tools | Keep | Keep | N/A |
| 18 | (New) | Temp | `temp/` | Create | LOW |
| 19 | (Scattered) | Lore | `lore/` | Create & organize | LOW |

---

## Detailed File Count & Risk Assessment

### High-Risk Moves (Likely to break things):

1. **GUI Consolidation (engine/)** - 50+ files
   - Risk: Requires many `require()` statement updates
   - Impact: HIGH (will break game if not careful)
   - Files affected: Any file importing from `ui/`, `scenes/`, `widgets/`
   - Mitigation: Use search/replace tool to update all `require()` paths

2. **Wiki/Systems Move** - 19 files
   - Risk: Markdown links between files
   - Impact: MEDIUM (documentation only)
   - Files affected: Cross-references in markdown
   - Mitigation: Update internal links during migration

3. **Docs Folder Reorganization** - 25+ files
   - Risk: Documentation links, navigation guides
   - Impact: LOW (documentation only)
   - Files affected: Navigation.md, index files
   - Mitigation: Centralize in new NAVIGATION.md

### Low-Risk Moves:

1. **Geoscape/crafts.md** - 1 file
   - Risk: Minimal
   - Impact: LOW
   - Mitigation: Just move the file

2. **Tests Cleanup** - Archive old phase files
   - Risk: Minimal (just archiving)
   - Impact: LOW
   - Mitigation: Keep originals, just reorganize

3. **Create New Folders** - temp/, lore/
   - Risk: Minimal
   - Impact: LOW (new structure)
   - Mitigation: Standard folder creation

---

## Validation Steps After Migration

### Step 1: Lua Require Verification
```bash
# Search for all old paths in require statements
grep -r "engine.scenes" engine/
grep -r "engine.ui" engine/
grep -r "engine.widgets" engine/
```

### Step 2: Game Launch Test
```bash
lovec "engine"
# Should run without errors
# Check console for:
#   - Module loading errors
#   - Require path failures
#   - Missing files
```

### Step 3: Markdown Link Validation
```bash
# Use validator to check all .md files
tools/validate_docs_links.ps1
# Should report: 0 broken links
```

### Step 4: Test Suite
```bash
run_tests.bat
# All tests should pass
```

---

## Decision Points Needed

Before starting migration, clarify:

1. **Should `wiki/api/` move to `api/`?**
   - YES: Cleaner structure, easier for modders
   - NO: Keep near other wiki docs

2. **What is `mods/new/`?**
   - Examples: Merge into `mods/examples/`
   - Community: Rename to `mods/community/`
   - Temporary: Delete or archive

3. **Should `docs/Glossary.md` be duplicated?**
   - YES: In both `design/` and `architecture/`
   - NO: Keep only one copy, reference it

4. **Archive old test phases?**
   - YES: Move to `tests/archive/`
   - NO: Keep in main `tests/` directory

5. **Create `temp/` folder?**
   - YES: For agent-generated reports (recommended)
   - NO: Continue using system temp directory

6. **Create `lore/` folder?**
   - YES: Organize creative assets separately (recommended)
   - NO: Keep in `engine/lore/`

---

## Migration Execution Order

### Phase 1: Non-Breaking (Low Risk)
1. Create new folders: `design/`, `architecture/`, `api/`, `temp/`, `lore/`
2. Add README.md files to each layer
3. Move geoscape/crafts.md → design/systems/geoscape/

### Phase 2: Documentation (Medium Risk)
1. Move wiki/systems/ → design/systems/
2. Move docs/diagrams/ → design/diagrams/
3. Move docs/developers/ → architecture/guides/
4. Move docs/*STANDARDS.md → architecture/best_practices/
5. Update all markdown cross-references

### Phase 3: Mod/Test Organization (Low Risk)
1. Archive tests/phase5_* → tests/archive/
2. Clarify mods/new/ (delete/merge/rename as needed)

### Phase 4: Engine Consolidation (High Risk)
1. Create engine/gui/ folder
2. Move engine/scenes/ → engine/gui/scenes/
3. Move engine/ui/ → engine/gui/ui/
4. Move engine/widgets/ → engine/gui/widgets/
5. Update all require() statements (critical!)
6. Test game: `lovec "engine"`

### Phase 5: Cleanup (Low Risk)
1. Delete old empty folders
2. Update top-level README.md
3. Create NAVIGATION.md
4. Verify all tests pass

---

## Estimated Time Investment

| Phase | Task | Time | Risk |
|---|---|---|---|
| 1 | Create folders + README | 0.5 hours | LOW |
| 2 | Move design docs + links | 2-3 hours | MEDIUM |
| 3 | Archive/organize tests | 0.5 hours | LOW |
| 4 | Consolidate GUI (require() updates) | 3-4 hours | HIGH |
| 5 | Cleanup + validation | 1-2 hours | LOW |
| | **TOTAL** | **7-10 hours** | |

---

## Success Criteria

After migration, the project should:

✓ Have clear folder structure with 10 top-level layers
✓ No duplicate files in multiple locations
✓ Game runs without console errors: `lovec "engine"`
✓ All tests pass: `run_tests.bat`
✓ No broken markdown links
✓ Each layer has clear purpose documented in README
✓ Modders can follow `api/` + `mods/` to create content
✓ Developers can follow `architecture/` + `engine/` to add features
✓ Designers can reference `design/` + `api/` for mechanics
✓ Temporary files cleanly separated in `temp/`
✓ Creative assets organized in `lore/`

