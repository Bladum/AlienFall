# Project Restructure Implementation Plan

**Date:** October 14, 2025  
**Status:** PLANNING  
**Priority:** HIGH - Improves maintainability, navigation, and AI agent effectiveness  

---

## 🎯 Objectives

1. **Improve Project Organization** - Clear folder structure with logical grouping
2. **Consolidate Test Files** - All `run_*` files in dedicated test directories
3. **Separate Concerns** - Mods outside engine, clear layer separation
4. **Clean Documentation** - Remove duplicate reports, organize completed tasks
5. **Enhance AI Navigation** - Update system prompt with accurate structure
6. **Maintain Compatibility** - Ensure game still launches and all paths work

---

## 📊 Current State Analysis

### Project Root Issues
```
c:\Users\tombl\Documents\Projects\
├── run_mapblock_test.lua           ❌ Test file at root
├── run_mission_detection_test.lua  ❌ Test file at root
├── simple_test.lua                 ❌ Test file at root
├── test_mapblock_standalone.lua    ❌ Test file at root
└── engine/
    ├── run_* (20+ files)           ❌ Test files mixed with engine code
    ├── test_*.lua (3 files)        ❌ Test files mixed with engine code
    └── mods/                       ❌ Mods inside engine folder
```

### Engine Folder Issues
```
engine/
├── basescape/      ✅ Clear layer
├── battlescape/    ✅ Clear layer
├── geoscape/       ✅ Clear layer
├── interception/   ✅ Clear layer
├── battle/         ⚠️  Overlaps with battlescape?
├── modules/        ⚠️  What's the difference vs layers?
├── systems/        ⚠️  Generic, could be more specific
├── shared/         ⚠️  Overlaps with utils?
├── utils/          ⚠️  Overlaps with shared?
├── core/           ⚠️  What belongs here vs systems?
├── scripts/        ⚠️  What type of scripts?
└── 20+ run_* files ❌ Test files mixed with source
```

### Tasks Folder Issues
```
tasks/TODO/
├── SESSION_SUMMARY_MAP_INTEGRATION.md        ❌ Should be in DONE/
├── TASK-032-PROGRESS-REPORT.md               ❌ Should be in DONE/
├── TASK-032-PHASE-3-4-COMPLETE.md            ❌ Should be in DONE/
├── TASK-032-PHASE-5-6-COMPLETE.md            ❌ Should be in DONE/
├── MAP_GENERATION_STATUS.md                  ❌ Should be in DONE/
├── MISSION_DETECTION_STATUS.md               ❌ Should be in DONE/
└── TASK-032-MAP-INTEGRATION-FIX.md           ❌ Should be in DONE/
```

### Documentation Issues
- Multiple progress reports scattered across TODO/
- Duplicate status tracking documents
- Completed task files not moved to DONE/
- No central navigation guide for project structure
- System prompt (copilot-instructions.md) outdated with structure

---

## 🗂️ Proposed Structure (UPDATED)

### Target Project Root
```
c:\Users\tombl\Documents\Projects\
├── .github/
│   └── copilot-instructions.md     ✨ Updated with new structure
├── .vscode/
├── engine/                          ✨ Clean, NO tests, NO mods
│   ├── main.lua
│   ├── conf.lua
│   ├── README.md
│   ├── assets/                     ✅ Game assets
│   ├── layers/                     ✨ NEW: Clear layer separation
│   │   ├── geoscape/
│   │   ├── basescape/
│   │   ├── battlescape/
│   │   └── interception/
│   ├── core/                       ✨ Core engine systems
│   │   ├── state_manager.lua
│   │   ├── input_handler.lua
│   │   └── resource_loader.lua
│   ├── shared/                     ✨ Shared game logic
│   │   ├── combat/
│   │   ├── units/
│   │   ├── items/
│   │   └── factions/
│   ├── systems/                    ✨ Cross-layer systems
│   │   ├── calendar/
│   │   ├── relations/
│   │   └── economy/
│   ├── ui/                         ✨ UI framework (widgets moved here)
│   │   ├── widgets/
│   │   └── themes/
│   ├── utils/                      ✅ Utility functions
│   ├── libs/                       ✅ External libraries
│   └── data/                       ✅ Game data files
├── mods/                           ✨ ALL mods at root (engine/mods deleted)
│   ├── core/
│   └── (any content from engine/mods/new/)
├── mock/                           ✨ NEW: Mock data for tests
│   ├── README.md
│   ├── mock_data.lua               ✨ From widgets/core/
│   ├── units.lua                   ✨ Mock unit data
│   ├── items.lua                   ✨ Mock item data
│   ├── missions.lua                ✨ Mock mission data
│   └── maps.lua                    ✨ Mock map data
├── tests/                          ✨ NEW: ALL test files (nothing in engine/)
│   ├── runners/                    ✨ All run_* files
│   │   ├── run_battlescape_test.lua
│   │   ├── run_map_generation_test.lua
│   │   ├── run_map_editor_test.lua
│   │   └── ... (all 24 run_* files)
│   ├── unit/                       ✨ From engine/tests/
│   ├── integration/                ✨ From engine/tests/
│   ├── performance/                ✨ From engine/tests/
│   ├── battlescape/                ✨ From engine/tests/
│   ├── systems/                    ✨ From engine/tests/
│   └── README.md                   ✨ How to run tests
├── tools/                          ✨ NEW: External development tools
│   ├── map_editor/                 ✨ Standalone map editor
│   │   ├── main.lua                ✨ From run_map_editor.lua
│   │   ├── conf.lua
│   │   └── README.md
│   ├── asset_verification/         ✨ Asset validation tool
│   │   ├── main.lua                ✨ From run_asset_verification.lua
│   │   ├── conf.lua
│   │   └── README.md
│   └── README.md                   ✨ Overview of all tools
├── tasks/
│   ├── TODO/                       ✨ Clean, organized
│   │   ├── 01-BATTLESCAPE/
│   │   ├── 02-GEOSCAPE/
│   │   ├── 03-BASESCAPE/
│   │   ├── 04-INTERCEPTION/
│   │   ├── 05-ECONOMY/
│   │   ├── 06-DOCUMENTATION/
│   │   └── MASTER-IMPLEMENTATION-PLAN.md
│   └── DONE/                       ✨ All completed + reports
│       ├── TASK-*.md (completed)
│       ├── SESSION-*.md (all sessions)
│       ├── *-PROGRESS-*.md (all reports)
│       └── *-STATUS-*.md (all status docs)
└── wiki/
    ├── PROJECT_STRUCTURE.md        ✨ NEW: Navigation guide
    ├── API.md
    ├── FAQ.md
    └── DEVELOPMENT.md
```

### Engine Layer Organization
```
engine/layers/
├── geoscape/                       Strategic layer
│   ├── systems/                    Geoscape-specific systems
│   │   ├── world_map.lua
│   │   ├── province_graph.lua
│   │   ├── mission_detection.lua
│   │   └── craft_travel.lua
│   ├── ui/                         Geoscape UI
│   │   ├── world_view.lua
│   │   ├── mission_markers.lua
│   │   └── intel_panel.lua
│   └── logic/                      Game logic
│       ├── missions.lua
│       ├── campaigns.lua
│       └── events.lua
├── basescape/                      Base management layer
│   ├── systems/
│   ├── ui/
│   └── logic/
├── battlescape/                    Tactical combat layer
│   ├── systems/
│   │   ├── combat_system.lua
│   │   ├── cover_system.lua
│   │   ├── los_system.lua
│   │   └── ... (all combat systems)
│   ├── ui/
│   │   ├── combat_hud.lua
│   │   ├── target_selection_ui.lua
│   │   └── ... (all UI systems)
│   ├── ai/
│   │   └── decision_system.lua
│   ├── map/
│   │   ├── generation/
│   │   ├── mapblocks/
│   │   └── tilesets/
│   └── rendering/
│       ├── hex_renderer.lua
│       └── 3d_renderer.lua
└── interception/                   Craft combat layer
    ├── systems/
    └── ui/
```

---

## 📋 Implementation Tasks

### Task 1: Analyze Current Project Structure ✅
**Time Estimate:** 2 hours  
**Status:** IN PROGRESS  

**Actions:**
1. ✅ List all files in project root
2. ✅ List all files in engine/
3. ✅ List all test files (run_*, test_*)
4. ✅ List all tasks in TODO/ and DONE/
5. ✅ Identify completed tasks that need migration
6. ✅ Identify duplicate documentation
7. 🔄 Document current mods/ location
8. 🔄 Create comprehensive file inventory

**Deliverables:**
- Complete file inventory with categorization
- List of files to move/reorganize
- List of completed tasks to migrate

---

### Task 2: Create Restructuring Plan Document
**Time Estimate:** 2 hours  
**Status:** IN PROGRESS (THIS DOCUMENT)  

**Actions:**
1. ✅ Define target structure
2. ✅ Create before/after diagrams
3. ✅ List all file moves
4. ✅ Identify path updates needed
5. 🔄 Create migration checklist
6. 🔄 Define rollback plan

**Deliverables:**
- ✅ This document (PROJECT-RESTRUCTURE-PLAN.md)
- Migration checklist
- Rollback instructions

---

### Task 1: Move ALL Mods Content Outside Engine
**Time Estimate:** 30 minutes  
**Status:** IN PROGRESS  
**Dependencies:** None  
**Priority:** HIGH - Must be done before engine restructure

**Actions:**
1. Check content of `engine/mods/` folder
2. Compare with root `mods/` folder
3. Merge any unique content from `engine/mods/` to root `mods/`
4. Delete `engine/mods/` folder entirely
5. Search for any references to `engine/mods/` in code
6. Update any hardcoded paths
7. Verify mods still load from root location

**Files Found:**
```
engine/mods/
├── new/              ⚠️ Check if unique content
└── README.md         ⚠️ Check if unique content

mods/
└── core/             ✅ Already at root
```

**Search Patterns:**
```bash
# Find references to engine/mods
grep -r "engine/mods" --include="*.lua"
grep -r "engine\.mods" --include="*.lua"
grep -r '"mods' --include="*.lua"
```

**Verification:**
- [ ] No `engine/mods/` folder exists
- [ ] All mod content in root `mods/`
- [ ] Game launches and loads mods
- [ ] No console errors about missing mods

---

### Task 2: Consolidate ALL Test Files to Root tests/
**Time Estimate:** 1.5 hours  
**Status:** NOT STARTED  
**Dependencies:** None  
**Priority:** HIGH - Major cleanup

**Actions:**

**Phase 1: Create test structure**
1. Create `tests/` folder at project root
2. Create subdirectories:
   - `tests/runners/` - All run_* files
   - `tests/unit/` - Unit tests
   - `tests/integration/` - Integration tests
   - `tests/performance/` - Performance tests
   - `tests/battlescape/` - Battlescape-specific tests
   - `tests/systems/` - System tests

**Phase 2: Move test runners (24 files)**
From project root → `tests/runners/`:
- `run_mapblock_test.lua`
- `run_mission_detection_test.lua`
- `simple_test.lua`
- `test_mapblock_standalone.lua`

From `engine/` → `tests/runners/`:
- `run_asset_verification.lua` → Will become tool later
- `run_battlescape_test.lua`
- `run_hex_renderer_test.lua`
- `run_hex_test.lua`
- `run_integration_test.lua`
- `run_map_editor.lua` → Will become tool later
- `run_map_editor_test.lua`
- `run_map_generation_test.lua`
- `run_map_integration_test.lua`
- `run_mapblock_test.lua`
- `run_mapblock_validation.lua`
- `run_mapscript_test.lua`
- `run_quick_test.lua`
- `run_range_accuracy_tests.lua`
- `run_test.lua`
- `run_tileset_test.lua`

From `engine/` → `tests/`:
- `test_fs2.lua`
- `test_mapblock_conf.lua`
- `test_runner.lua`
- `quick_validate.lua`

**Phase 3: Move engine/tests/ content**
Move `engine/tests/` → `tests/`:
- `battle/` → `tests/unit/battle/`
- `battlescape/` → `tests/battlescape/`
- `core/` → `tests/unit/core/`
- `integration/` → `tests/integration/`
- `performance/` → `tests/performance/`
- `systems/` → `tests/systems/`
- All loose .lua files → `tests/unit/`

**Phase 4: Update paths in test files**
1. Update all `require()` statements to use absolute paths from project root
2. Update asset loading paths (e.g., `"mods/core/..."` not `"engine/mods/..."`)
3. Update data file references
4. Test at least 5 test runners work

**Phase 5: Clean up**
1. Delete `engine/tests/` folder
2. Delete all `run_*.lua` from engine/
3. Delete all `test_*.lua` from engine/
4. Verify no test files remain in engine/

**Verification:**
- [ ] No test files in `engine/`
- [ ] All tests in `tests/` folder
- [ ] At least 5 test runners execute successfully
- [ ] Paths resolve correctly

---

### Task 3: Create Root-Level mock/ Folder with Test Data
**Time Estimate:** 1 hour  
**Status:** NOT STARTED  
**Dependencies:** None  
**Priority:** MEDIUM - Improves test organization

**Actions:**

**Phase 1: Create mock structure**
1. Create `mock/` folder at project root
2. Create `mock/README.md` with purpose and usage

**Phase 2: Move existing mock data**
1. Move `engine/widgets/core/mock_data.lua` → `mock/mock_data.lua`
2. Update `engine/widgets/init.lua` to reference new location
3. Test widgets still load mock data

**Phase 3: Create organized mock data files**
1. Create `mock/units.lua` - Mock unit data
   - Sample soldiers with different classes, ranks, stats
   - Enemy units for testing combat
   
2. Create `mock/items.lua` - Mock item/equipment data
   - Weapons with different stats
   - Armor, grenades, medkits
   - Ammo types
   
3. Create `mock/missions.lua` - Mock mission data
   - Different mission types (SITE, UFO, BASE)
   - Various objectives
   - Different biomes and sizes
   
4. Create `mock/maps.lua` - Mock map data
   - Test mapblocks
   - Tileset references
   - Landing zones

**Phase 4: Create helper functions**
1. Add generator functions to each mock file
   - `generateUnits(count, type)`
   - `generateItems(count, category)`
   - `generateMission(type, difficulty)`
   - `generateMap(size, biome)`

**Phase 5: Update test files**
1. Update test runners to use `mock/` data
2. Update integration tests to use mock data
3. Document mock data usage in tests/README.md

**Example Structure:**
```lua
-- mock/units.lua
local MockUnits = {}

function MockUnits.getSoldier(name, class)
    return {
        name = name or "Test Soldier",
        class = class or "ASSAULT",
        rank = "ROOKIE",
        hp = 100,
        maxHp = 100,
        stats = {strength = 50, accuracy = 60}
    }
end

function MockUnits.generateSquad(count)
    local squad = {}
    for i = 1, count do
        table.insert(squad, MockUnits.getSoldier("Soldier " .. i))
    end
    return squad
end

return MockUnits
```

**Verification:**
- [ ] `mock/` folder exists at root
- [ ] Mock data organized by category
- [ ] Widgets still work with new mock_data path
- [ ] Tests can use mock data
- [ ] README.md documents usage

---

### Task 4: Create tools/ Folder for External Utilities
**Time Estimate:** 2 hours  
**Status:** NOT STARTED  
**Dependencies:** Task 2 (test files moved first)  
**Priority:** HIGH - Clean separation of concerns

**Actions:**

**Phase 1: Create tools structure**
1. Create `tools/` folder at project root
2. Create `tools/README.md` with overview of all tools

**Phase 2: Extract Map Editor**
1. Create `tools/map_editor/` folder
2. Move `engine/run_map_editor.lua` → `tools/map_editor/main.lua`
3. Create `tools/map_editor/conf.lua`:
   ```lua
   function love.conf(t)
       t.title = "XCOM Simple - Map Editor"
       t.window.width = 960
       t.window.height = 720
       t.console = true
   end
   ```
4. Create `tools/map_editor/README.md` with:
   - How to launch: `lovec tools/map_editor`
   - Feature list
   - Keyboard shortcuts
   - Usage guide
5. Update require paths in main.lua to reference engine code
6. Test map editor launches standalone

**Phase 3: Extract Asset Verification Tool**
1. Create `tools/asset_verification/` folder
2. Move `engine/run_asset_verification.lua` → `tools/asset_verification/main.lua`
3. Create `tools/asset_verification/conf.lua`
4. Create `tools/asset_verification/README.md`
5. Test tool launches standalone

**Phase 4: Identify other potential tools**
Check these candidates:
- `run_tileset_test.lua` → Could become tileset viewer tool
- `run_mapblock_validation.lua` → Could become mapblock validator tool
- `run_quick_test.lua` → Keep as test runner or make validation tool?

**Phase 5: Update tools README**
Create `tools/README.md` with:
```markdown
# Development Tools

External tools for content creation and validation.

## Available Tools

### Map Editor
**Location:** `tools/map_editor/`  
**Launch:** `lovec tools/map_editor`  
**Purpose:** Visual map editing and mapblock creation

### Asset Verification
**Location:** `tools/asset_verification/`  
**Launch:** `lovec tools/asset_verification`  
**Purpose:** Validate game assets (images, data files)

## Running Tools

All tools are standalone Love2D applications:
```bash
lovec tools/<tool_name>
```

## Adding New Tools

1. Create subfolder in `tools/`
2. Add `main.lua` and `conf.lua`
3. Reference engine code with relative paths
4. Update this README
```

**Path Updates:**
Tools need to reference engine code:
```lua
-- In tools/map_editor/main.lua
package.path = package.path .. ";../../engine/?.lua;../../engine/?/init.lua"
local MapEditor = require("battlescape.ui.map_editor")
```

**Verification:**
- [ ] `tools/` folder exists at root
- [ ] Map editor launches: `lovec tools/map_editor`
- [ ] Asset verification launches: `lovec tools/asset_verification`
- [ ] Tools can access engine code
- [ ] README.md documents all tools

---

### Task 5: Reorganize Engine with Layers Structure
**Time Estimate:** 1 hour  
**Status:** NOT STARTED  
**Dependencies:** None  

**Actions:**
1. Create `tests/` folder at project root
2. Create `tests/runners/` subfolder
3. Move all `run_*.lua` files from engine/ to tests/runners/
4. Move all `run_*.lua` files from project root to tests/runners/
5. Move all `test_*.lua` files to tests/
6. Update any hardcoded paths in test files
7. Create `tests/README.md` with test runner documentation

**Files to Move:**
- From project root → tests/runners/:
  - run_mapblock_test.lua
  - run_mission_detection_test.lua
  - simple_test.lua
  - test_mapblock_standalone.lua

- From engine/ → tests/runners/:
  - run_asset_verification.lua
  - run_battlescape_test.lua
  - run_hex_renderer_test.lua
  - run_hex_test.lua
  - run_integration_test.lua
  - run_map_editor.lua
  - run_map_editor_test.lua
  - run_map_generation_test.lua
  - run_map_integration_test.lua
  - run_mapblock_test.lua
  - run_mapblock_validation.lua
  - run_mapscript_test.lua
  - run_quick_test.lua
  - run_range_accuracy_tests.lua
  - run_test.lua
  - run_tileset_test.lua

- From engine/ → tests/:
  - test_fs2.lua
  - test_mapblock_conf.lua
  - test_runner.lua

**Path Updates Needed:**
- Update require() paths in test files to use absolute paths from project root
- Update any asset loading paths
- Update any data file references

---

### Task 4: Relocate Mods Outside Engine
**Time Estimate:** 1 hour  
**Status:** NOT STARTED  
**Dependencies:** None  

**Actions:**
1. Verify `mods/` exists at project root (it does)
2. Check if `engine/mods/` has different content than root `mods/`
3. If different: merge content, resolve conflicts
4. If same: delete `engine/mods/`
5. Search engine code for `require("mods.` or `mods/` references
6. Update all mod loading code to use absolute path from root
7. Test mod loading system

**Path Updates:**
- Before: `require("mods.core.data")`
- After: `require("mods.core.data")` (if already absolute)
- Or: Update mod loader to use correct base path

**Verification:**
- Game launches successfully
- Mods load correctly
- No errors in console about missing mod files

---

### Task 5: Restructure Engine Folder Organization
**Time Estimate:** 3 hours  
**Status:** NOT STARTED  
**Dependencies:** Tasks 3, 4 complete  

**Actions:**

**Phase 1: Create New Structure**
1. Create `engine/layers/` folder
2. Create `engine/ui/` folder (move widgets here)
3. Keep `engine/core/`, `engine/systems/`, `engine/shared/`, `engine/utils/`

**Phase 2: Organize Layers**
1. Move `engine/geoscape/` → `engine/layers/geoscape/`
2. Move `engine/basescape/` → `engine/layers/basescape/`
3. Move `engine/battlescape/` → `engine/layers/battlescape/`
4. Move `engine/interception/` → `engine/layers/interception/`

**Phase 3: Organize UI**
1. Move `engine/widgets/` → `engine/ui/widgets/`
2. Keep theme system in widgets/

**Phase 4: Evaluate Ambiguous Folders**
- `engine/battle/` - Check if duplicate of battlescape, merge or clarify
- `engine/modules/` - Check if duplicate of layers, merge or keep
- `engine/scripts/` - Clarify purpose, possibly merge with tools/
- `engine/shared/` - Keep for cross-layer shared code
- `engine/utils/` - Keep for utility functions

**Phase 5: Update Require Paths**
- Find all `require("geoscape.` and update to `require("layers.geoscape.`
- Find all `require("battlescape.` and update to `require("layers.battlescape.`
- Find all `require("widgets.` and update to `require("ui.widgets.`
- Test game launch after each change

**Rollback Plan:**
- Keep backup of original structure
- Document all path changes
- Can revert by moving folders back and restoring old paths

---

### Task 6: Migrate Completed Tasks to DONE
**Time Estimate:** 1 hour  
**Status:** NOT STARTED  
**Dependencies:** None  

**Actions:**
1. Read `tasks/tasks.md` to identify all COMPLETED tasks
2. Cross-reference with files in `tasks/TODO/`
3. Move completed task files from TODO/ to DONE/
4. Move status/progress reports to DONE/
5. Move session summaries to DONE/ (if not already there)
6. Update any cross-references in remaining TODO files
7. Create index file in DONE/ listing all completed tasks

**Files to Move (based on initial scan):**
From `tasks/TODO/`:
- SESSION_SUMMARY_MAP_INTEGRATION.md → DONE/
- TASK-032-PROGRESS-REPORT.md → DONE/
- TASK-032-PHASE-3-4-COMPLETE.md → DONE/
- TASK-032-PHASE-5-6-COMPLETE.md → DONE/
- TASK-032-MAP-INTEGRATION-FIX.md → DONE/ (if complete)
- MAP_GENERATION_STATUS.md → DONE/
- MISSION_DETECTION_STATUS.md → DONE/

**Verification:**
- All completed task files in DONE/
- No duplicate files
- Cross-references updated
- Index file created

---

### Task 7: Clean Up Task Documentation
**Time Estimate:** 2 hours  
**Status:** NOT STARTED  
**Dependencies:** Task 6 complete  

**Actions:**

**Phase 1: Remove Duplicates**
1. Scan tasks/TODO/ for duplicate progress reports
2. Consolidate duplicate status documents
3. Remove outdated planning documents

**Phase 2: Organize Remaining Files**
1. Keep MASTER-IMPLEMENTATION-PLAN.md in TODO/
2. Keep TASK-ORGANIZATION-QUICK-REFERENCE.md in TODO/
3. Keep TASK-FLOW-VISUAL-DIAGRAM.md in TODO/
4. Keep category folders (01-BATTLESCAPE/, 02-GEOSCAPE/, etc.)
5. Move all other organizational docs to TODO/06-DOCUMENTATION/

**Phase 3: Update README**
1. Update tasks/TODO/README.md with current structure
2. List what belongs in TODO vs DONE
3. Document file naming conventions
4. Add quick reference for finding tasks

**Phase 4: Clean tasks.md**
1. Remove duplicate task entries
2. Ensure all COMPLETED tasks have "COMPLETED" status
3. Add summary statistics at top
4. Verify all file links work

**Deliverables:**
- Clean tasks/TODO/ folder
- Updated README.md
- Verified tasks.md
- All organizational docs properly categorized

---

### Task 8: Update System Prompt (copilot-instructions.md)
**Time Estimate:** 2 hours  
**Status:** NOT STARTED  
**Dependencies:** Tasks 3-5 complete  

**Actions:**

**Phase 1: Update Project Structure Section**
1. Replace outdated directory tree with new structure
2. Update file paths for all key directories
3. Add descriptions for new folders (layers/, ui/, tests/)
4. Update engine organization explanation

**Phase 2: Update Navigation Guidelines**
1. Document layer structure (geoscape, basescape, battlescape, interception)
2. Explain where to find different system types
3. Document test file locations and how to run them
4. Update mods location and loading

**Phase 3: Update Key Files Section**
1. Update paths to core files (main.lua, conf.lua)
2. Update paths to system files (now in layers/)
3. Update paths to documentation (wiki/)
4. Add tests/ section

**Phase 4: Add Architecture Overview**
1. Explain layer separation
2. Describe shared code organization
3. Document UI framework location
4. Explain core vs systems vs utils

**Phase 5: Update Examples**
1. Update all file path examples
2. Update require() statement examples
3. Update navigation examples
4. Add examples for new structure

**Verification:**
- All paths accurate
- All examples work
- Clear navigation guidance
- AI can find files easily

---

### Task 9: Create Navigation Documentation
**Time Estimate:** 2 hours  
**Status:** NOT STARTED  
**Dependencies:** Tasks 3-5 complete  

**Actions:**

**Phase 1: Create wiki/PROJECT_STRUCTURE.md**
1. Start with comprehensive folder tree
2. Add descriptions for each major folder
3. Explain purpose of each directory
4. Document file naming conventions

**Phase 2: Add Quick Reference Sections**
1. "Where to Find..." guide (e.g., "Where to find combat systems?")
2. Common navigation patterns
3. Layer-specific organization
4. Test file locations

**Phase 3: Add File Organization Rules**
1. What belongs in each folder
2. When to create new folders
3. Naming conventions for files
4. Module structure guidelines

**Phase 4: Add Visual Diagrams**
1. Folder tree with descriptions
2. Layer architecture diagram
3. Data flow between layers
4. Module dependency diagram

**Phase 5: Cross-Reference Documentation**
1. Link to API.md for API reference
2. Link to DEVELOPMENT.md for workflow
3. Link to FAQ.md for common questions
4. Link to tasks/ for task management

**Deliverables:**
- wiki/PROJECT_STRUCTURE.md (comprehensive guide)
- Clear navigation for developers
- Visual diagrams
- Cross-referenced documentation

---

### Task 10: Verify and Test Restructured Project
**Time Estimate:** 2 hours  
**Status:** NOT STARTED  
**Dependencies:** All previous tasks complete  

**Actions:**

**Phase 1: Basic Verification**
1. ✅ Game launches: `lovec engine`
2. ✅ No console errors on startup
3. ✅ Main menu loads
4. ✅ All screens accessible

**Phase 2: Module Loading**
1. ✅ All require() paths resolve correctly
2. ✅ No missing module errors
3. ✅ All layers load successfully
4. ✅ Mods load from new location

**Phase 3: Test Execution**
1. ✅ Test runners can be found
2. ✅ At least 3 test runners execute successfully
3. ✅ Test results display correctly
4. ✅ No path errors in tests

**Phase 4: Documentation Verification**
1. ✅ All links in markdown files work
2. ✅ All file references are accurate
3. ✅ No broken cross-references
4. ✅ System prompt accurate

**Phase 5: Create Validation Checklist**
1. Document all verification steps
2. Create pass/fail checklist
3. Note any issues found
4. Document workarounds if needed

**Deliverables:**
- Validation checklist
- Test results report
- Issue log (if any)
- Sign-off that restructure is complete

---

## 📊 Detailed File Inventory

### Test Files to Move (24 files)

**From Project Root → tests/runners/ (4 files):**
```
run_mapblock_test.lua
run_mission_detection_test.lua
simple_test.lua
test_mapblock_standalone.lua
```

**From engine/ → tests/runners/ (16 files):**
```
run_asset_verification.lua
run_battlescape_test.lua
run_hex_renderer_test.lua
run_hex_test.lua
run_integration_test.lua
run_map_editor.lua
run_map_editor_test.lua
run_map_generation_test.lua
run_map_integration_test.lua
run_mapblock_test.lua
run_mapblock_validation.lua
run_mapscript_test.lua
run_quick_test.lua
run_range_accuracy_tests.lua
run_test.lua
run_tileset_test.lua
```

**From engine/ → tests/ (3 files):**
```
test_fs2.lua
test_mapblock_conf.lua
test_runner.lua
```

**From engine/tests/ → tests/unit/ (preserve existing):**
```
(Keep existing test structure)
```

---

### Task Files to Move

**From tasks/TODO/ → tasks/DONE/ (7+ files):**
```
SESSION_SUMMARY_MAP_INTEGRATION.md
TASK-032-PROGRESS-REPORT.md
TASK-032-PHASE-3-4-COMPLETE.md
TASK-032-PHASE-5-6-COMPLETE.md
TASK-032-MAP-INTEGRATION-FIX.md
MAP_GENERATION_STATUS.md
MISSION_DETECTION_STATUS.md
```

**To verify from category folders:**
- Check tasks/TODO/01-BATTLESCAPE/ for completed tasks
- Check tasks/TODO/02-GEOSCAPE/ for completed tasks
- Check tasks/TODO/03-BASESCAPE/ for completed tasks
- Check tasks/TODO/04-INTERCEPTION/ for completed tasks
- Check tasks/TODO/05-ECONOMY/ for completed tasks

---

### Engine Folders to Reorganize

**Current → Proposed:**
```
engine/geoscape/      → engine/layers/geoscape/
engine/basescape/     → engine/layers/basescape/
engine/battlescape/   → engine/layers/battlescape/
engine/interception/  → engine/layers/interception/
engine/widgets/       → engine/ui/widgets/
engine/mods/          → DELETE (use root mods/)
```

**To Evaluate (keep or merge):**
```
engine/battle/        → Merge with battlescape? Or keep separate?
engine/modules/       → Merge with layers? Or keep for other modules?
engine/scripts/       → Keep or merge with tools/?
engine/shared/        → Keep (cross-layer shared code)
engine/utils/         → Keep (utility functions)
engine/core/          → Keep (core engine systems)
engine/systems/       → Keep (cross-layer systems like calendar, economy)
```

---

## 🔄 Path Update Patterns

### Require Statements to Update

**Layer paths:**
```lua
-- Before:
require("geoscape.systems.world_map")
require("battlescape.systems.combat_system")
require("basescape.systems.research")

-- After:
require("layers.geoscape.systems.world_map")
require("layers.battlescape.systems.combat_system")
require("layers.basescape.systems.research")
```

**UI paths:**
```lua
-- Before:
require("widgets.button")
require("widgets.panel")

-- After:
require("ui.widgets.button")
require("ui.widgets.panel")
```

**Mods paths (if changed):**
```lua
-- Before (if using relative):
require("mods.core.data")

-- After (ensure absolute from root):
require("mods.core.data")
-- OR update mod loader base path
```

---

## ⚠️ Risk Assessment

### High Risk
- **Path Updates:** Extensive require() path changes could break game
  - **Mitigation:** Update incrementally, test after each change
  - **Rollback:** Keep backup, can revert folder moves

### Medium Risk
- **Mod Loading:** Moving mods/ outside engine could break mod system
  - **Mitigation:** Test mod loading thoroughly before proceeding
  - **Rollback:** Can restore engine/mods/ if needed

- **Test Files:** Moving tests could break test execution
  - **Mitigation:** Update paths in test files as they're moved
  - **Rollback:** Tests are isolated, can fix individually

### Low Risk
- **Task File Migration:** Moving completed tasks is safe
  - **Mitigation:** Just file moves, no code impact
  - **Rollback:** Easy to move files back

- **Documentation Updates:** Low risk, high value
  - **Mitigation:** Update incrementally, verify links
  - **Rollback:** Git revert if needed

---

## ✅ Success Criteria

1. **Structure:** Clear, logical folder organization
2. **Functionality:** Game launches and runs without errors
3. **Tests:** Test files consolidated and executable
4. **Mods:** Mods outside engine, loading correctly
5. **Documentation:** Clean tasks/ folder, accurate wiki
6. **Navigation:** Easy to find files, clear organization
7. **AI Effectiveness:** System prompt accurate, AI can navigate easily
8. **No Regressions:** All existing functionality preserved

---

## 📅 Estimated Timeline

- **Task 1:** 2 hours (Analysis) - IN PROGRESS
- **Task 2:** 2 hours (Planning) - IN PROGRESS (THIS DOC)
- **Task 3:** 1 hour (Test files)
- **Task 4:** 1 hour (Mods relocation)
- **Task 5:** 3 hours (Engine restructure)
- **Task 6:** 1 hour (Task migration)
- **Task 7:** 2 hours (Doc cleanup)
- **Task 8:** 2 hours (System prompt update)
- **Task 9:** 2 hours (Navigation docs)
- **Task 10:** 2 hours (Verification)

**Total:** ~18 hours (2-3 days of work)

---

## 🎯 Next Steps

1. ✅ Complete Task 1 (Analysis) - finish file inventory
2. ✅ Complete Task 2 (Planning) - this document
3. Review plan with user, get approval
4. Execute Task 3 (Test files) first - lowest risk, immediate cleanup
5. Execute Task 4 (Mods) second - moderate risk, needed for engine restructure
6. Execute Task 5 (Engine restructure) third - highest risk, most impactful
7. Execute Task 6-7 (Task cleanup) - low risk, can do in parallel
8. Execute Task 8-9 (Documentation) - after structure finalized
9. Execute Task 10 (Verification) - final validation

---

**Status:** PLANNING COMPLETE - Ready for implementation approval

