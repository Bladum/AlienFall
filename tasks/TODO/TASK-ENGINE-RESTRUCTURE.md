# TASK: Engine Folder Restructure for Scalability

**Task ID:** ENGINE-RESTRUCTURE  
**Created:** 2025-10-13  
**Status:** TODO  
**Priority:** HIGH  
**Estimated Time:** 4-6 hours  

---

## Overview and Purpose

The current `engine/` folder structure has grown organically and now requires reorganization to support future expansion of Basescape, Geoscape, Battlescape, Interception systems, and mod support. This restructure will:

1. **Separate concerns** - Each major game mode gets its own dedicated folder
2. **Reduce root clutter** - Move scattered systems into logical groupings
3. **Improve discoverability** - Clear folder names indicate purpose
4. **Support modding** - Better separation makes mod hooks clearer
5. **Scale gracefully** - Structure supports adding new 'scapes' easily

---

## Current Structure Analysis

### Problems Identified

1. **Root-level clutter:**
   - `battle/` folder sits alongside `modules/` but contains battlescape-specific code
   - Test files scattered in root (`test_*.lua`, `run_test.lua`)
   - Run scripts mixed with main code (`run_*.lua`)

2. **Inconsistent organization:**
   - `modules/battlescape/` exists but core battlescape code is in `battle/`
   - `modules/geoscape/` exists and is properly organized
   - `modules/basescape.lua` is a single file, not a folder
   - No folder for interception systems (future need)

3. **Systems folder ambiguity:**
   - Mix of true "core systems" (state_manager, assets) with game-specific systems (weapon_system, equipment_system, team)
   - No clear distinction between shared and mode-specific systems

4. **Testing fragmentation:**
   - Tests in multiple locations: `tests/`, `battle/tests/`, root level
   - No unified test runner location

5. **Mod system unclear:**
   - `mods/` folder in engine (should data be external?)
   - `systems/mod_manager.lua` location unclear if mods are separate

---

## Proposed New Structure

```
engine/
├── main.lua                        -- Entry point
├── conf.lua                        -- Love2D config
├── README.md                       -- Project documentation
│
├── core/                           -- CORE SYSTEMS (shared across all modes)
│   ├── init.lua                   -- Core system initializer
│   ├── state_manager.lua          -- State/screen management
│   ├── assets.lua                 -- Asset loading/caching
│   ├── data_loader.lua            -- TOML/data file loading
│   ├── mod_manager.lua            -- Mod system
│   └── README.md                  -- Core systems documentation
│
├── shared/                         -- SHARED GAME SYSTEMS (used by multiple modes)
│   ├── init.lua                   -- Shared systems initializer
│   ├── ui.lua                     -- UI management (or move to widgets?)
│   ├── pathfinding.lua            -- Pathfinding (used by multiple modes)
│   ├── spatial_hash.lua           -- Spatial partitioning
│   ├── team.lua                   -- Team/faction system
│   └── README.md                  -- Shared systems documentation
│
├── battlescape/                    -- BATTLESCAPE (tactical combat)
│   ├── init.lua                   -- Battlescape initializer/entry
│   ├── README.md                  -- Battlescape documentation
│   │
│   ├── ui/                        -- UI layer (input/render/HUD)
│   │   ├── init.lua
│   │   ├── input.lua             -- Input handling
│   │   ├── render.lua            -- Rendering
│   │   ├── ui.lua                -- UI widgets/HUD
│   │   └── README.md
│   │
│   ├── logic/                     -- Game logic layer
│   │   ├── battlefield.lua       -- Main battlefield state
│   │   ├── turn_manager.lua      -- Turn-based logic
│   │   ├── unit_selection.lua    -- Unit selection system
│   │   ├── integration.lua       -- Integration with other systems
│   │   └── README.md
│   │
│   ├── systems/                   -- ECS systems (battlescape-specific)
│   │   ├── movement_system.lua
│   │   ├── shooting_system.lua
│   │   ├── accuracy_system.lua
│   │   ├── range_system.lua
│   │   ├── vision_system.lua
│   │   ├── hex_system.lua
│   │   ├── move_mode_system.lua
│   │   └── README.md
│   │
│   ├── components/                -- ECS components
│   │   ├── health.lua
│   │   ├── movement.lua
│   │   ├── team.lua
│   │   ├── transform.lua
│   │   ├── vision.lua
│   │   └── README.md
│   │
│   ├── entities/                  -- Entity factories
│   │   ├── unit_entity.lua
│   │   └── README.md
│   │
│   ├── map/                       -- Map generation and management
│   │   ├── grid_map.lua
│   │   ├── map_generator.lua
│   │   ├── map_saver.lua
│   │   ├── map_block.lua
│   │   ├── mapblock_system.lua
│   │   └── README.md
│   │
│   ├── effects/                   -- Visual/gameplay effects
│   │   ├── animation_system.lua
│   │   ├── fire_system.lua
│   │   ├── smoke_system.lua
│   │   └── README.md
│   │
│   ├── rendering/                 -- Rendering systems
│   │   ├── renderer.lua
│   │   ├── camera.lua
│   │   └── README.md
│   │
│   ├── combat/                    -- Combat mechanics
│   │   ├── weapon_system.lua     -- (moved from systems/)
│   │   ├── equipment_system.lua  -- (moved from systems/)
│   │   ├── action_system.lua     -- (moved from systems/)
│   │   ├── los_system.lua        -- (moved from systems/)
│   │   ├── los_optimized.lua     -- (moved from systems/)
│   │   └── README.md
│   │
│   ├── utils/                     -- Battlescape utilities
│   │   ├── debug.lua
│   │   ├── hex_math.lua
│   │   └── README.md
│   │
│   └── tests/                     -- Battlescape tests
│       ├── test_all_systems.lua
│       ├── test_ecs_components.lua
│       └── README.md
│
├── geoscape/                       -- GEOSCAPE (strategic map)
│   ├── init.lua                   -- Geoscape entry point
│   ├── README.md                  -- Geoscape documentation
│   │
│   ├── ui/                        -- UI layer
│   │   ├── input.lua
│   │   ├── render.lua
│   │   └── README.md
│   │
│   ├── logic/                     -- Game logic
│   │   ├── world_state.lua       -- Global world state
│   │   ├── data.lua              -- Geoscape data
│   │   └── README.md
│   │
│   ├── systems/                   -- Geoscape-specific systems
│   │   ├── province_system.lua   -- Province management
│   │   ├── ufo_tracking.lua      -- UFO detection/tracking
│   │   ├── mission_system.lua    -- Mission generation
│   │   └── README.md
│   │
│   └── tests/                     -- Geoscape tests
│       └── README.md
│
├── basescape/                      -- BASESCAPE (base management)
│   ├── init.lua                   -- Basescape entry point (from modules/basescape.lua)
│   ├── README.md                  -- Basescape documentation
│   │
│   ├── ui/                        -- UI layer
│   │   ├── input.lua
│   │   ├── render.lua
│   │   ├── facility_ui.lua
│   │   └── README.md
│   │
│   ├── logic/                     -- Game logic
│   │   ├── base_state.lua        -- Base state management
│   │   ├── facility_system.lua   -- Facility placement/management
│   │   └── README.md
│   │
│   ├── systems/                   -- Basescape-specific systems
│   │   ├── research_system.lua   -- Research management
│   │   ├── manufacturing_system.lua
│   │   ├── soldier_system.lua    -- Soldier roster
│   │   ├── storage_system.lua    -- Inventory management
│   │   └── README.md
│   │
│   └── tests/                     -- Basescape tests
│       └── README.md
│
├── interception/                   -- INTERCEPTION (craft vs UFO)
│   ├── init.lua                   -- Interception entry point
│   ├── README.md                  -- Interception documentation
│   │
│   ├── ui/                        -- UI layer
│   │   ├── input.lua
│   │   ├── render.lua
│   │   └── README.md
│   │
│   ├── logic/                     -- Game logic
│   │   ├── combat_logic.lua      -- Turn-based interception
│   │   └── README.md
│   │
│   ├── systems/                   -- Interception-specific systems
│   │   ├── craft_system.lua      -- Craft management
│   │   ├── weapon_system.lua     -- Air-to-air weapons
│   │   └── README.md
│   │
│   └── tests/                     -- Interception tests
│       └── README.md
│
├── menu/                           -- MENU SCREENS
│   ├── main_menu.lua              -- Main menu (from modules/menu.lua)
│   ├── tests_menu.lua             -- Test menu (from modules/tests_menu.lua)
│   ├── widget_showcase.lua        -- Widget showcase (from modules/widget_showcase.lua)
│   └── README.md
│
├── tools/                          -- DEVELOPMENT TOOLS
│   ├── map_editor/                -- Map editor (from modules/map_editor.lua)
│   │   ├── init.lua
│   │   ├── editor_ui.lua
│   │   └── README.md
│   │
│   ├── validators/                -- Validation tools
│   │   ├── mapblock_validator.lua -- (moved from systems/)
│   │   ├── asset_verifier.lua    -- (from utils/)
│   │   └── README.md
│   │
│   └── README.md                  -- Tools documentation
│
├── scripts/                        -- UTILITY SCRIPTS
│   ├── run_test.lua               -- Test runner (from root)
│   ├── run_quick_test.lua         -- Quick tests (from root)
│   ├── run_asset_verification.lua -- Asset verification (from root)
│   ├── run_mapblock_validation.lua -- Mapblock validation (from root)
│   ├── run_range_accuracy_tests.lua -- Range tests (from root)
│   └── README.md                  -- Scripts documentation
│
├── tests/                          -- UNIFIED TEST SUITE
│   ├── run_all_tests.lua          -- Master test runner
│   ├── test_runner.lua            -- Test framework
│   ├── README.md                  -- Testing documentation
│   │
│   ├── core/                      -- Core system tests
│   │   └── README.md
│   │
│   ├── battlescape/               -- Battlescape tests (aggregate from battlescape/tests/)
│   │   ├── test_all_systems.lua
│   │   └── README.md
│   │
│   ├── integration/               -- Integration tests
│   │   ├── test_mapblock_integration.lua -- (from tests/)
│   │   ├── test_phase2.lua       -- (from tests/)
│   │   └── README.md
│   │
│   ├── performance/               -- Performance tests
│   │   ├── test_performance.lua  -- (from tests/)
│   │   └── README.md
│   │
│   └── systems/                   -- Specific system tests
│       ├── test_battle_systems.lua -- (from tests/)
│       ├── test_los_fow.lua      -- (from tests/)
│       └── README.md
│
├── widgets/                        -- UI WIDGET LIBRARY (unchanged)
│   ├── init.lua
│   ├── README.md
│   ├── core/
│   ├── buttons/
│   ├── containers/
│   ├── input/
│   ├── display/
│   ├── advanced/
│   ├── navigation/
│   ├── demo/
│   ├── docs/
│   └── tests/
│
├── utils/                          -- GENERAL UTILITIES
│   ├── scaling.lua
│   ├── viewport.lua
│   ├── README.md
│   └── (remove verify_assets.lua - moved to tools/)
│
├── data/                           -- GAME DATA FILES (unchanged)
│   ├── mapgen_config.lua
│   └── README.md
│
├── assets/                         -- GAME ASSETS (unchanged)
│   ├── fonts/
│   ├── images/
│   ├── sounds/
│   └── README.md
│
├── libs/                           -- EXTERNAL LIBRARIES (unchanged)
│   ├── toml.lua
│   └── README.md
│
└── love_definitions/               -- LOVE2D TYPE DEFINITIONS (unchanged)
    └── love.lua
```

---

## Key Changes Summary

### 1. New Top-Level Folders

| Folder | Purpose |
|--------|---------|
| `core/` | Essential systems used by all modes (state_manager, assets, data_loader, mod_manager) |
| `shared/` | Systems shared between multiple modes but not truly "core" (pathfinding, team, spatial_hash) |
| `battlescape/` | All battlescape code consolidated from `battle/` and `modules/battlescape/` |
| `geoscape/` | Promoted from `modules/geoscape/` to top-level |
| `basescape/` | Promoted from `modules/basescape.lua` to full folder structure |
| `interception/` | New folder for future interception mechanics |
| `menu/` | Menu screens separated from game modes |
| `tools/` | Development tools (map editor, validators) |
| `scripts/` | Utility scripts (run_*, test_*) moved from root |
| `tests/` | Unified test suite with clear organization |

### 2. Files to Move

#### From `battle/` → `battlescape/`
- All files and folders move to new battlescape structure

#### From `modules/` → Various
- `modules/battlescape.lua` → `battlescape/init.lua`
- `modules/battlescape/*` → `battlescape/ui/`
- `modules/geoscape/` → `geoscape/` (top-level)
- `modules/basescape.lua` → `basescape/init.lua` (expand to full structure)
- `modules/menu.lua` → `menu/main_menu.lua`
- `modules/tests_menu.lua` → `menu/tests_menu.lua`
- `modules/widget_showcase.lua` → `menu/widget_showcase.lua`
- `modules/map_editor.lua` → `tools/map_editor/init.lua`

#### From `systems/` → `core/`, `shared/`, or mode-specific
- **To `core/`:** state_manager.lua, assets.lua, data_loader.lua, mod_manager.lua
- **To `shared/`:** pathfinding.lua, spatial_hash.lua, team.lua, ui.lua
- **To `battlescape/combat/`:** weapon_system.lua, equipment_system.lua, action_system.lua, los_system.lua, los_optimized.lua
- **To `battlescape/map/`:** battle_tile.lua (actually, this might be used in logic/)
- **To `tools/validators/`:** mapblock_validator.lua

#### From root → `scripts/`
- run_test.lua
- run_quick_test.lua
- run_asset_verification.lua
- run_mapblock_validation.lua
- run_range_accuracy_tests.lua
- test_runner.lua

#### From `utils/` → `tools/validators/`
- verify_assets.lua → asset_verifier.lua

### 3. Unchanged Folders
- `widgets/` - Already well-organized
- `data/` - Small and focused
- `assets/` - Standard structure
- `libs/` - External dependencies
- `love_definitions/` - Type definitions

---

## Benefits

### 1. **Clear Separation of Concerns**
- Each "scape" (Battlescape, Geoscape, Basescape, Interception) is self-contained
- Core systems are clearly identified and separated from game-specific logic
- Shared systems are distinguished from mode-specific systems

### 2. **Improved Discoverability**
- New developers can immediately find battlescape code in `battlescape/`
- Tools and scripts are in obvious locations
- Tests are organized by what they test

### 3. **Better Scalability**
- Adding a new "scape" follows established pattern
- Each mode can grow independently without affecting others
- Clear boundaries prevent feature creep between systems

### 4. **Mod-Friendly Structure**
- Clear separation makes it easier to identify mod hooks
- Mode-specific folders can have dedicated mod APIs
- Core systems remain stable while modes can be modded

### 5. **Easier Testing**
- Test structure mirrors code structure
- Can run tests per-mode or all at once
- Integration tests clearly separate from unit tests

### 6. **Reduced Root Clutter**
- Only essential files in root (main.lua, conf.lua, README.md)
- Scripts and tools in dedicated folders
- Easier to navigate at a glance

---

## Implementation Plan

### Phase 1: Create New Folder Structure (30 minutes)
1. Create all new top-level folders with README.md files
2. Create subfolder structure for each mode
3. Document folder purposes in each README.md

### Phase 2: Move Core Systems (45 minutes)
1. Move core systems to `core/`
2. Move shared systems to `shared/`
3. Update require paths in main.lua
4. Test that game still launches

### Phase 3: Restructure Battlescape (90 minutes)
1. Move `battle/` contents to `battlescape/` with new organization
2. Move `modules/battlescape/` to `battlescape/ui/`
3. Move battlescape-specific systems from `systems/` to `battlescape/combat/`
4. Update all require paths
5. Test battlescape functionality

### Phase 4: Restructure Other Modes (60 minutes)
1. Promote Geoscape to top-level
2. Expand Basescape from single file to folder structure
3. Move menu files to `menu/`
4. Update require paths
5. Test each mode

### Phase 5: Move Tools and Scripts (30 minutes)
1. Move run scripts to `scripts/`
2. Move map editor to `tools/map_editor/`
3. Move validators to `tools/validators/`
4. Update any references

### Phase 6: Reorganize Tests (45 minutes)
1. Move tests to appropriate locations under `tests/`
2. Create master test runner
3. Update test require paths
4. Run all tests to verify

### Phase 7: Documentation Update (30 minutes)
1. Update wiki/DEVELOPMENT.md with new structure
2. Update wiki/API.md if needed
3. Update main engine/README.md
4. Update this task file with completion notes

### Phase 8: Validation (30 minutes)
1. Run game through all modes
2. Run all tests
3. Check for broken requires
4. Verify Love2D console shows no errors

**Total Estimated Time:** ~5.5 hours

---

## Testing Strategy

### Manual Testing
1. **Launch game** - Run with `lovec engine`, verify no errors in console
2. **Test each mode** - Navigate to Menu → Geoscape, Battlescape, Basescape
3. **Test transitions** - Move between modes to verify state manager works
4. **Test tools** - Open map editor, widget showcase, tests menu
5. **Check scripts** - Run test scripts from `scripts/` folder

### Automated Testing
1. Run master test suite: `love scripts/run_test.lua`
2. Verify all tests pass with new structure
3. Check for import/require errors

### Validation Checklist
- [ ] Game launches without errors
- [ ] Main menu displays correctly
- [ ] Can enter Geoscape
- [ ] Can enter Battlescape (create battle, move units)
- [ ] Can enter Basescape
- [ ] Map editor opens
- [ ] Widget showcase works
- [ ] Tests menu accessible
- [ ] All automated tests pass
- [ ] No "module not found" errors in console

---

## Files Affected

### New Files (README.md for each new folder)
- `engine/core/README.md`
- `engine/shared/README.md`
- `engine/battlescape/README.md` (updated from battle/README.md)
- `engine/geoscape/README.md` (from modules/geoscape/README.md)
- `engine/basescape/README.md` (new)
- `engine/interception/README.md` (new)
- `engine/menu/README.md` (new)
- `engine/tools/README.md` (new)
- `engine/scripts/README.md` (new)
- Plus README.md for all subfolders

### Modified Files
- `engine/main.lua` - Update all require paths
- All files being moved - Update internal require paths
- `wiki/DEVELOPMENT.md` - Update project structure documentation
- `wiki/API.md` - Update if API paths change
- Test files - Update require paths

### Moved Files
- ~50+ files being reorganized (see "Files to Move" section above)

---

## Rollback Plan

If restructure causes issues:

1. **Keep backup branch** - Don't delete old structure until fully validated
2. **Git revert** - Can revert the restructure commit
3. **Keep old paths documented** - Document old→new mappings for reference
4. **Incremental rollback** - Can rollback individual phases if needed

---

## Future Considerations

### Potential Further Improvements
1. **Config folder** - Separate configuration files from data
2. **Localization folder** - For multi-language support
3. **Campaigns folder** - For campaign definitions
4. **Saves folder** - Standardized save game structure
5. **Network folder** - If multiplayer is added

### Mode-Specific Expansion
Each mode folder (`battlescape/`, `geoscape/`, etc.) can independently add:
- `ai/` - AI systems for that mode
- `scenarios/` - Pre-built scenarios
- `tutorials/` - Mode-specific tutorials
- `persistence/` - Save/load for that mode

---

## Acceptance Criteria

- [x] New folder structure created and documented
- [ ] All files moved to appropriate locations
- [ ] All require paths updated
- [ ] Game launches without errors (console clean)
- [ ] All game modes functional (Menu, Geoscape, Battlescape, Basescape)
- [ ] All tools work (Map Editor, Widget Showcase, Tests Menu)
- [ ] All automated tests pass
- [ ] Documentation updated (DEVELOPMENT.md, API.md, README.md)
- [ ] No console warnings or errors
- [ ] Code follows project standards
- [ ] All temporary files in TEMP directory (compliance check)

---

## What Worked Well

(To be filled after completion)

---

## Lessons Learned

(To be filled after completion)

---

## Notes

- This is a **large refactor** - consider breaking into smaller PRs
- **Test frequently** during each phase
- Keep Love2D console open to catch require errors immediately
- Document old→new path mappings for reference
- Consider creating migration script for future similar refactors
- May want to update VS Code workspace settings for new paths

