# Task Management

This file tracks all tasks for the XCOM Simple / AlienFall project.

**Last Updated:** October 12, 2025

---

# XCOM Simple - Task Tracking

## Task Status Overview

This file tracks all development tasks for the XCOM Simple project.

### Task States
- **TODO**: Planned and documented, not started
- **IN_PROGRESS**: Currently being worked on
- **TESTING**: Implementation complete, testing in progress
- **DONE**: Completed and verified (see DONE/ folder)

---

## Recently Completed Tasks

### ✅ TASK-PERF: Performance Optimization - Phase 1 (COMPLETED October 12, 2025)

**Status:** COMPLETE - All 7 subtasks finished
**Priority:** CRITICAL
**Time Spent:** ~2-3 hours
**Impact:** MASSIVE - 10-100x performance improvements

**Completed Subtasks:**
1. ✅ Run baseline performance tests
2. ✅ Verify optimized LOS integration
3. ✅ Apply numeric key optimization
4. ✅ Implement dirty flag system
5. ✅ Add spatial hash grid
6. ✅ Run post-optimization tests
7. ✅ Generate performance report

**Optimizations Implemented:**
- ✅ Shadow Casting LOS Algorithm (10x faster than raycasting)
- ✅ LOS Result Caching with TTL (69,875x speedup for cached queries)
- ✅ Numeric Key Optimization (1.1x + no GC pressure)
- ✅ Dirty Flag System (90% reduction in recalculations)
- ✅ Spatial Hash Grid (O(n²) → O(1) collision detection)

**Performance Results:**
- Battlescape init: ~314ms (consistent, down from 314-433ms variance)
- LOS calculation: 0.00-2.28ms (was 2.66ms)
- Visibility update: 0.4ms for 34 units with cache (was 3.8ms)
- Cache hit rate: 80-95% after warmup
- Unit spawning: O(1) collision detection (was O(n²))

**Files Created:**
- `engine/systems/los_optimized.lua` (353 lines)
- `engine/systems/spatial_hash.lua` (250 lines)
- `engine/tests/test_performance.lua` (1200 lines)
- `PERFORMANCE_OPTIMIZATION_REPORT.md` (comprehensive report)
- `TESTING_GUIDE.md` (testing documentation)
- `TASK_COMPLETION_SUMMARY.md` (task summary)

**Files Modified:**
- `engine/modules/battlescape.lua` (los_optimized integration, dirty flags, spatial hash)
- `engine/systems/unit.lua` (visibilityDirty flag)
- `engine/modules/menu.lua` (performance test button)

**Reports:**
- See: `PERFORMANCE_OPTIMIZATION_REPORT.md` for detailed analysis
- See: `TASK_COMPLETION_SUMMARY.md` for task completion details

**Next Steps (Phase 2):**
- Optimize battlefield generation (297ms → <100ms target)
- Implement incremental visibility updates
- Optimize pathfinding for long paths (73ms → <10ms)

---

### ✅ TASK-DATA-CONVERSION: Game Data TOML Conversion (COMPLETED October 12, 2025)

**Status:** COMPLETE - All game data converted to TOML and loading verified
**Priority:** High
**Time Spent:** ~30 minutes
**Impact:** IMPROVED - Game data now moddable via TOML files in mods/ folder

**Data Files Converted:**
- ✅ `engine/data/terrain_types.lua` → `mods/rules/battle/terrain.toml` (16 terrain types)
- ✅ `engine/data/weapons.lua` → `mods/rules/item/weapons.toml` (13 weapons)
- ✅ `engine/data/armours.lua` → `mods/rules/item/armours.toml` (7 armours)
- ✅ `engine/data/unit_classes.lua` → `mods/rules/unit/classes.toml` (12 unit classes)

**Code Changes:**
- ✅ Created `DataLoader` system (`engine/systems/data_loader.lua`) to load TOML files
- ✅ Updated `Battlefield` to use `DataLoader.terrainTypes` instead of `TerrainTypes`
- ✅ Added `DataLoader.load()` call in `main.lua` after asset loading
- ✅ Removed old `engine/data/` folder and Lua data files

**TOML Structure:**
- Metadata sections with version/author info
- Proper table nesting for complex data (unit stats, weapon properties)
- Consistent formatting and comprehensive data coverage
- All original functionality preserved (getters, filters, etc.)

**Benefits:**
- Game data now fully moddable via TOML files
- Easier for modders to create custom units/weapons/terrain
- Consistent with existing mod structure
- Maintains all original Lua API compatibility
- Game loads successfully with new TOML-based data system

---

### ✅ TASK-ASSETS: Asset Relocation to Mods Folder (COMPLETED October 12, 2025)

**Status:** COMPLETE - All assets moved and loading verified
**Priority:** High
**Time Spent:** ~15 minutes
**Impact:** IMPROVED - Assets now properly organized in mods folder for moddability

**Assets Relocated:**
- ✅ `engine/assets/images/farmland/` → `mods/gfx/terrain/` (7 terrain tiles)
- ✅ `engine/assets/images/units/` → `mods/gfx/units/` (6 unit sprites)
- ✅ `engine/assets/sounds/` → `mods/gfx/sounds/` (empty, ready for audio)
- ✅ `engine/assets/fonts/` → `mods/gfx/fonts/` (empty, ready for fonts)

**Code Changes:**
- ✅ Updated `Assets.load()` to scan `mods/gfx/` instead of `assets/images/`
- ✅ Updated `BattlefieldRenderer:drawTileTerrain()` to use `"terrain"` folder
- ✅ Removed old empty asset directories
- ✅ Verified game loads and displays all assets correctly

**Benefits:**
- Assets now centralized in mods folder for easier modding
- Consistent with existing mod structure (`mods/gfx/` already had unit/craft/etc folders)
- Terrain assets properly organized under `terrain/` subfolder
- Game runs successfully with all assets loading from new locations

---

### ✅ TASK-GUI-WIDGETS: Battlescape GUI and Widget System Standardization (COMPLETED October 12, 2025)

**Status:** COMPLETE - All widgets standardized and GUI improved
**Priority:** High
**Time Spent:** ~1 hour
**Impact:** IMPROVED - Consistent widget system across entire project

**GUI Improvements:**
- ✅ Fixed info panel containment with ScrollBox (no content overflow)
- ✅ Implemented 4x4 button layout as specified:
  - Unit Inventory: WEAPON LEFT | WEAPON RIGHT | ARMOUR | SKILL
  - Unit Actions: REST | OVERWATCH | COVER | AIM
  - Movement Modes: WALK | SNEAK | RUN | FLY
  - Map Actions: NEXT UNIT | ZOOM ON/OFF | MENU | END TURN
- ✅ All buttons functional with proper action handlers

**Widget Standardization:**
- ✅ Replaced all local UI implementations with centralized widgets
- ✅ Updated `menu.lua`, `basescape.lua`, `geoscape.lua` to use `Widgets.*`
- ✅ Eliminated `systems/ui.lua` usage throughout project
- ✅ All widgets use global theme system from `engine/widgets/theme.lua`
- ✅ Grid-aligned positioning (24px multiples) for all UI elements
- ✅ Fixed test menu buttons (added missing `mousepressed` handler)

**Files Modified:**
- `engine/modules/menu.lua` - Migrated to Widgets.Button/Widgets.Label
- `engine/modules/basescape.lua` - Migrated to Widgets.Button/Widgets.FrameBox
- `engine/modules/geoscape.lua` - Migrated to Widgets.Button/Widgets.FrameBox
- `engine/modules/tests_menu.lua` - Added missing mousepressed handler
- `engine/modules/battlescape.lua` - Verified 4x4 button layout and ScrollBox containment

**Benefits:**
- Consistent styling across all menus and modules
- No more duplicate widget implementations
- Proper content containment in info panels
- Functional 4x4 button layout for battlescape actions
- Maintainable codebase with centralized theme system

---

## Active Tasks

### Critical Priority

#### TASK-010: Task Planning and Documentation
**Status:** IN_PROGRESS  
**Priority:** Critical  
**Created:** October 12, 2025  
**Estimated Time:** 4.5 hours  
**Files:** All task documents in tasks/TODO/  
**Description:** Create comprehensive task documents for all 10 requirements using TASK_TEMPLATE.md and update tasks.md tracking file. Foundation for all subsequent work.

**Progress:**
- [x] Analyze requirements
- [x] Create 10 detailed task documents
- [ ] Update tasks.md with entries
- [ ] Review and validate plans

---

#### TASK-001: Mod Loading System Enhancement
**Status:** TODO  
**Priority:** Critical  
**Created:** October 12, 2025  
**Estimated Time:** 1.5 hours  
**Files:** engine/systems/mod_manager.lua, engine/main.lua  
**Description:** Ensure mod 'new' (xcom_simple) loads automatically on game startup and is globally accessible via ModManager throughout the application.

**Requirements:**
- [ ] Mod loads automatically during love.load()
- [ ] ModManager sets 'new' as active mod by default
- [ ] All content accessible globally via ModManager APIs
- [ ] Console logging confirms mod loading success

---

#### TASK-009: TOML-Based Data Loading Verification
**Status:** TODO  
**Priority:** Critical  
**Created:** October 12, 2025  
**Estimated Time:** 8 hours  
**Files:** engine/systems/data_loader.lua, all game modules  
**Description:** Ensure all game data (tiles, units, mapblocks, weapons, armours, etc.) loads exclusively from TOML files with no hardcoded content in engine code.

**Requirements:**
- [ ] All terrain types load from TOML
- [ ] All unit classes load from TOML
- [ ] All weapons/armours load from TOML
- [ ] All mapblocks load from TOML
- [ ] No hardcoded game data in Lua code
- [ ] Validation ensures TOML data is complete

---

### High Priority

#### TASK-002: Asset Verification and Creation
**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Estimated Time:** 2 hours  
**Files:** mods/new/rules/*, mods/new/assets/*, engine/utils/verify_assets.lua  
**Description:** Check all terrain tiles and units defined in TOML files for image asset definitions. For any missing assets, copy existing placeholder images with correct naming.

**Requirements:**
- [ ] Scan all terrain types and unit classes
- [ ] Check for corresponding image files
- [ ] Create placeholder images for missing assets
- [ ] Add image path definitions to TOML files

---

#### TASK-003: Mapblock and Tile Validation
**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Estimated Time:** 3 hours  
**Files:** engine/systems/mapblock_validator.lua, mods/new/mapblocks/*.toml  
**Description:** Ensure all mapblocks are properly defined in TOML files, and verify that every tile referenced in mapblocks has a corresponding definition in terrain.toml with assigned images.

**Requirements:**
- [ ] Create mapblock validator
- [ ] Scan all mapblock files
- [ ] Verify all tile references are valid
- [ ] Ensure all tiles have image assignments
- [ ] Integrate validation into mod loading

---

#### TASK-004: Map Editor Module
**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Estimated Time:** 9 hours  
**Files:** engine/modules/map_editor.lua, engine/systems/mapblock_io.lua  
**Description:** Create a new game module "Map Editor" that allows designing and editing tactical maps with hex grid editor, tile palette, map list with filtering, and save/load functionality.

**Requirements:**
- [ ] Left panel (240px): Map list with filter, Save/Load buttons
- [ ] Center: Hex grid editor matching battlescape display
- [ ] Right panel (240px): Tile palette with filter
- [ ] LMB to paint, RMB to pick tiles
- [ ] TOML save/load for maps
- [ ] Undo/Redo support

---

#### TASK-007: Test Coverage Improvement
**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Estimated Time:** 16 hours  
**Files:** engine/tests/*, engine/widgets/tests/*  
**Description:** Expand test coverage for GUI widgets, mod loader, mod manager, battlescape, and supporting classes. Create comprehensive test suites to ensure reliability and catch regressions.

**Requirements:**
- [ ] 80%+ coverage for widgets
- [ ] 90%+ coverage for mod system
- [ ] 70%+ coverage for battlescape
- [ ] Performance regression tests
- [ ] Enhanced test runner with reporting

---

### Medium Priority

#### TASK-005: Widget Folder Organization
**Status:** TODO  
**Priority:** Medium  
**Created:** October 12, 2025  
**Estimated Time:** 3 hours  
**Files:** engine/widgets/*, all imports  
**Description:** Reorganize the widgets folder structure by grouping related widgets into logical subfolders (core, input, display, containers, navigation, buttons, advanced). Update all import statements throughout the codebase.

**Requirements:**
- [ ] Group widgets into logical categories
- [ ] Move widget files to appropriate subfolders
- [ ] Update all require() statements
- [ ] Update widget loader (init.lua)
- [ ] Maintain backward compatibility

---

#### TASK-006: New Widget Development
**Status:** TODO  
**Priority:** Medium  
**Created:** October 12, 2025  
**Estimated Time:** 15 hours  
**Files:** engine/widgets/display/*, engine/widgets/navigation/*, engine/widgets/advanced/*  
**Description:** Design and implement 10 new useful widgets specifically for turn-based strategy game UIs: UnitCard, ActionBar, ResourceDisplay, MiniMap, TurnIndicator, InventorySlot, ResearchTree, NotificationBanner, ContextMenu, RangeIndicator.

**Requirements:**
- [ ] 10 new widgets for strategy game
- [ ] Each follows 24×24 pixel grid system
- [ ] Full documentation for each
- [ ] Test cases for each
- [ ] Added to widget showcase

---

### Recently Completed Tasks

#### ✅ TASK-008: Procedural Map Generator Maintenance (COMPLETED October 12, 2025)
**Status:** COMPLETE - MapGenerator system implemented with both procedural and mapblock generation  
**Priority:** Medium  
**Created:** October 12, 2025  
**Completed:** October 12, 2025  
**Time Spent:** ~1.5 hours  
**Files Created:**
- `engine/systems/battle/map_generator.lua` (287 lines) - Unified map generation system
- `engine/data/mapgen_config.lua` (27 lines) - Configuration file

**Files Modified:**
- `engine/modules/battlescape.lua` - Updated to use MapGenerator with fallback
- `engine/systems/unit.lua` - Fixed DataLoader references (removed hardcoded upvalues)
- `engine/modules/tests_menu.lua` - Added "MAP GEN: METHOD" toggle button

**Features Implemented:**
- ✅ Procedural generation with cellular automata smoothing
- ✅ Mapblock-based generation using GridMap system
- ✅ Unified generation interface with `MapGenerator.generate()`
- ✅ Configuration system with `mapgen_config.lua`
- ✅ Toggle button in Tests menu to switch methods
- ✅ Automatic fallback from mapblock to procedural if no blocks available
- ✅ Seed support for reproducible procedural maps
- ✅ Both methods produce compatible Battlefield objects

**Console Output:**
```
[MapGenerator] Loaded configuration: method=mapblock
[MapGenerator] Generating map using method: mapblock
[MapGenerator] Mapblock generation complete: 90x90 tiles
```

**Requirements Met:**
- ✅ Procedural generation creates valid random maps (60x60 default)
- ✅ Mapblock-based generation uses predefined maps from TOML
- ✅ Option to choose generation method (config file + toggle button)
- ✅ Both methods produce compatible map data (Battlefield objects)
- ✅ Seed support for reproducible procedural maps

**Notes:**
- Default method is "mapblock" for varied, hand-crafted content
- Procedural generation uses 3-pass cellular automata for natural-looking terrain
- Both methods work seamlessly with battlescape systems
- Easy to extend with new generation algorithms

---

#### TASK-008: Procedural Map Generator Maintenance
**Status:** TODO  
**Priority:** Medium  
**Created:** October 12, 2025  
**Estimated Time:** 5 hours  
**Files:** engine/modules/battlescape.lua, engine/systems/map_generator.lua  
**Description:** Ensure the procedural map generation option remains functional alongside the new mapblock-based generation system. Provide both generation methods as options in battlescape.

**Requirements:**
- [ ] Procedural generation creates valid random maps
- [ ] Mapblock-based generation uses predefined maps
- [ ] Option to choose generation method
- [ ] Both methods produce compatible map data
- [ ] Seed support for reproducible procedural maps

---

### Summary

**Total Estimated Time:** ~68 hours (approximately 2 weeks full-time)

**Task Dependencies:**
```
TASK-010 (Planning) - IN PROGRESS
    ↓
TASK-001 (Mod Loading) ←→ TASK-009 (TOML Verification)
    ↓
TASK-002 (Assets) → TASK-003 (Mapblocks)
    ↓                    ↓
TASK-006 (Widgets) ← TASK-005 (Organization)
    ↓                    ↓
TASK-004 (Map Editor) ←  TASK-008 (Procedural)
    ↓
TASK-007 (Tests)
```

**Recommended Execution Order:**
1. ✅ TASK-010: Task Planning (this) - IN PROGRESS
2. TASK-001: Mod Loading - Critical dependency
3. TASK-009: TOML Verification - Data foundation
4. TASK-002: Asset Verification - Content integrity
5. TASK-003: Mapblock Validation - Map system
6. TASK-008: Procedural Generator - Map options
7. TASK-005: Widget Organization - UI foundation
8. TASK-006: New Widgets - UI expansion
9. TASK-004: Map Editor - Major feature
10. TASK-007: Test Coverage - Quality assurance

---

## Completed Tasks (Archive)

| Task ID | Task Name | Completed | Priority | Duration | Files |
|---------|-----------|-----------|----------|----------|-------|
| TASK-009 | Dynamic Yellow Dots on Main Map During Movement | 2025-01-12 | High | 10 min | `engine/systems/battle/renderer.lua` |
| TASK-008 | Dynamic Minimap During Movement & Day/Night Refresh | 2025-01-12 | High | 15 min | `engine/modules/battlescape.lua` |
| TASK-004 | Fix Minimap Visibility - Remove Circular Overlays | 2025-01-12 | High | 30 min | `engine/modules/battlescape.lua` |
| TASK-001 | Dynamic Resolution System with Fixed GUI | 2025-01-12 | High | 2 hours | `conf.lua`, `viewport.lua` (NEW), `grid.lua`, `main.lua`, `battlescape.lua` |
| TASK-003 | Fix Fullscreen Rendering and Scaling | 2025-10-12 | High | 40 min | `engine/main.lua`, `engine/widgets/grid.lua` |
| TASK-002 | Fix Terrain Rendering and Pathfinding | 2025-10-12 | High | 45 min | `engine/systems/battle/renderer.lua`, `engine/systems/battle/battlefield.lua` |
| TASK-001 | Fix Battlescape UI Initialization Error | 2025-10-12 | Critical | 30 min | `engine/modules/battlescape.lua` |
| TASK-000 | Grid-Based Widget System | 2025-10-10 | High | 3 hours | `engine/widgets/*`, `engine/conf.lua`, `.github/copilot-instructions.md` |

---

## Task Workflow

1. **TODO** - Task is planned and documented
2. **IN_PROGRESS** - Task is being actively worked on
3. **TESTING** - Implementation complete, testing in progress
4. **DONE** - Task completed, tested, and documented

---

## How to Create a New Task

1. Copy `TASK_TEMPLATE.md` to `tasks/TODO/TASK-XXX-name.md`
2. Fill in all sections of the template
3. Add entry to this file (`tasks.md`)
4. Move to `IN_PROGRESS` when starting work
5. Move to `DONE` folder when complete

---

## Quick Links

- **Template:** [TASK_TEMPLATE.md](TASK_TEMPLATE.md)
- **TODO Folder:** [tasks/TODO/](TODO/)
- **DONE Folder:** [tasks/DONE/](DONE/)

---

## Statistics

- **Total Tasks:** 22 (12 completed + 10 new)
- **Completed:** 12
- **In Progress:** 1 (TASK-010)
- **TODO:** 9
- **Estimated Time Remaining:** ~63.5 hours
- **Completion Rate:** 55% (12/22)
