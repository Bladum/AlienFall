# Engine Folder Restructure - Visual Comparison

## Current Structure (BEFORE)

```
engine/
├── main.lua
├── conf.lua
├── test_*.lua (scattered test files)         ❌ ROOT CLUTTER
├── run_*.lua (scattered run scripts)         ❌ ROOT CLUTTER
│
├── systems/ (17 files)                       ⚠️  MIXED PURPOSE
│   ├── state_manager.lua     [CORE]
│   ├── assets.lua            [CORE]
│   ├── data_loader.lua       [CORE]
│   ├── mod_manager.lua       [CORE]
│   ├── pathfinding.lua       [SHARED]
│   ├── team.lua              [SHARED]
│   ├── ui.lua                [SHARED]
│   ├── weapon_system.lua     [BATTLESCAPE]  ❌ WRONG LOCATION
│   ├── equipment_system.lua  [BATTLESCAPE]  ❌ WRONG LOCATION
│   ├── action_system.lua     [BATTLESCAPE]  ❌ WRONG LOCATION
│   ├── los_system.lua        [BATTLESCAPE]  ❌ WRONG LOCATION
│   └── mapblock_validator.lua [TOOL]        ❌ WRONG LOCATION
│
├── battle/ (13 files + 4 folders)           ❌ INCONSISTENT
│   ├── battlefield.lua                       (battlescape logic)
│   ├── turn_manager.lua                      (battlescape logic)
│   ├── camera.lua                            (battlescape render)
│   ├── renderer.lua                          (battlescape render)
│   ├── fire_system.lua                       (battlescape effects)
│   ├── smoke_system.lua                      (battlescape effects)
│   ├── grid_map.lua                          (battlescape map)
│   ├── map_generator.lua                     (battlescape map)
│   ├── components/                           (ECS components)
│   ├── entities/                             (ECS entities)
│   ├── systems/                              (ECS systems)
│   └── tests/                                (battlescape tests)
│
├── modules/                                  ⚠️  INCONSISTENT
│   ├── menu.lua              [SINGLE FILE]
│   ├── basescape.lua         [SINGLE FILE]  ❌ NOT A FOLDER
│   ├── battlescape.lua       [SINGLE FILE]
│   ├── tests_menu.lua        [SINGLE FILE]
│   ├── widget_showcase.lua   [SINGLE FILE]
│   ├── map_editor.lua        [SINGLE FILE]  ❌ SHOULD BE IN TOOLS
│   ├── battlescape/          [FOLDER]       ⚠️  BATTLESCAPE SPLIT
│   │   ├── init.lua
│   │   ├── input.lua
│   │   ├── render.lua
│   │   └── ui.lua
│   └── geoscape/             [FOLDER]       ✅ GOOD STRUCTURE
│       ├── init.lua
│       ├── input.lua
│       ├── render.lua
│       └── data.lua
│
├── tests/ (6 files)                         ⚠️  TESTS SCATTERED
│   └── various test files
│
├── widgets/ (well-organized)                ✅ KEEP AS-IS
├── utils/ (3 files)                         ✅ KEEP AS-IS
├── data/                                    ✅ KEEP AS-IS
├── assets/                                  ✅ KEEP AS-IS
├── libs/                                    ✅ KEEP AS-IS
└── love_definitions/                        ✅ KEEP AS-IS
```

**Problems:**
- ❌ **Root clutter:** 10+ test/run scripts in root
- ❌ **Inconsistent naming:** `battle/` vs `modules/battlescape/`
- ❌ **Wrong locations:** Combat systems in generic `systems/`, validator in `systems/`, editor in `modules/`
- ❌ **Incomplete structure:** Basescape is a single file, no Interception folder
- ⚠️  **Mixed purposes:** `systems/` has core, shared, and mode-specific code
- ⚠️  **Tests scattered:** Root level, `tests/`, `battle/tests/`

---

## Proposed Structure (AFTER)

```
engine/
├── main.lua                                 ✅ CLEAN ROOT
├── conf.lua
├── README.md
│
├── core/                                    ✅ ESSENTIAL SYSTEMS
│   ├── init.lua
│   ├── state_manager.lua
│   ├── assets.lua
│   ├── data_loader.lua
│   ├── mod_manager.lua
│   └── README.md
│
├── shared/                                  ✅ MULTI-MODE SYSTEMS
│   ├── init.lua
│   ├── pathfinding.lua
│   ├── spatial_hash.lua
│   ├── team.lua
│   ├── ui.lua
│   └── README.md
│
├── battlescape/                             ✅ CONSOLIDATED & ORGANIZED
│   ├── init.lua
│   ├── README.md
│   │
│   ├── ui/                 (input, render, HUD)
│   │   ├── init.lua
│   │   ├── input.lua
│   │   ├── render.lua
│   │   ├── ui.lua
│   │   └── README.md
│   │
│   ├── logic/              (game state, turns)
│   │   ├── battlefield.lua
│   │   ├── turn_manager.lua
│   │   ├── unit_selection.lua
│   │   └── README.md
│   │
│   ├── systems/            (ECS systems)
│   │   ├── movement_system.lua
│   │   ├── shooting_system.lua
│   │   ├── vision_system.lua
│   │   └── README.md
│   │
│   ├── components/         (ECS components)
│   │   └── README.md
│   │
│   ├── entities/           (Entity factories)
│   │   └── README.md
│   │
│   ├── map/                (Map generation)
│   │   ├── grid_map.lua
│   │   ├── map_generator.lua
│   │   └── README.md
│   │
│   ├── effects/            (Visual effects)
│   │   ├── animation_system.lua
│   │   ├── fire_system.lua
│   │   ├── smoke_system.lua
│   │   └── README.md
│   │
│   ├── rendering/          (Rendering)
│   │   ├── renderer.lua
│   │   ├── camera.lua
│   │   └── README.md
│   │
│   ├── combat/             (Combat mechanics)
│   │   ├── weapon_system.lua      [FROM systems/]
│   │   ├── equipment_system.lua   [FROM systems/]
│   │   ├── action_system.lua      [FROM systems/]
│   │   ├── los_system.lua         [FROM systems/]
│   │   └── README.md
│   │
│   ├── utils/              (Battlescape utilities)
│   │   └── README.md
│   │
│   └── tests/              (Battlescape tests)
│       └── README.md
│
├── geoscape/                                ✅ TOP-LEVEL MODE
│   ├── init.lua
│   ├── README.md
│   ├── ui/
│   ├── logic/
│   ├── systems/
│   └── tests/
│
├── basescape/                               ✅ FULL STRUCTURE
│   ├── init.lua             [FROM modules/basescape.lua]
│   ├── README.md
│   ├── ui/
│   ├── logic/
│   ├── systems/
│   │   ├── research_system.lua
│   │   ├── manufacturing_system.lua
│   │   ├── soldier_system.lua
│   │   └── README.md
│   └── tests/
│
├── interception/                            ✅ NEW FUTURE MODE
│   ├── init.lua
│   ├── README.md
│   ├── ui/
│   ├── logic/
│   ├── systems/
│   │   ├── craft_system.lua
│   │   ├── weapon_system.lua
│   │   └── README.md
│   └── tests/
│
├── menu/                                    ✅ MENU SCREENS
│   ├── main_menu.lua        [FROM modules/menu.lua]
│   ├── tests_menu.lua       [FROM modules/tests_menu.lua]
│   ├── widget_showcase.lua  [FROM modules/widget_showcase.lua]
│   └── README.md
│
├── tools/                                   ✅ DEV TOOLS
│   ├── map_editor/
│   │   ├── init.lua         [FROM modules/map_editor.lua]
│   │   └── README.md
│   ├── validators/
│   │   ├── mapblock_validator.lua [FROM systems/]
│   │   ├── asset_verifier.lua     [FROM utils/]
│   │   └── README.md
│   └── README.md
│
├── scripts/                                 ✅ UTILITY SCRIPTS
│   ├── run_test.lua         [FROM root]
│   ├── run_quick_test.lua   [FROM root]
│   ├── run_asset_verification.lua [FROM root]
│   └── README.md
│
├── tests/                                   ✅ UNIFIED TESTS
│   ├── run_all_tests.lua
│   ├── test_runner.lua
│   ├── README.md
│   ├── core/                (core system tests)
│   ├── battlescape/         (battlescape tests)
│   ├── integration/         (integration tests)
│   ├── performance/         (performance tests)
│   └── systems/             (specific system tests)
│
├── widgets/                                 ✅ UNCHANGED
├── utils/                                   ✅ UNCHANGED
├── data/                                    ✅ UNCHANGED
├── assets/                                  ✅ UNCHANGED
├── libs/                                    ✅ UNCHANGED
└── love_definitions/                        ✅ UNCHANGED
```

---

## Key Improvements Summary

### 1. Clear Hierarchy ✅
```
BEFORE: systems/, battle/, modules/ (mixed purposes)
AFTER:  core/, shared/, [battlescape/geoscape/basescape/interception]/ (clear roles)
```

### 2. Mode Consolidation ✅
```
BEFORE: battle/ + modules/battlescape/ (split)
AFTER:  battlescape/ (unified with clear subfolders)
```

### 3. Consistent Structure ✅
```
All modes follow same pattern:
  ├── init.lua
  ├── ui/
  ├── logic/
  ├── systems/
  └── tests/
```

### 4. Tools Separated ✅
```
BEFORE: map_editor in modules/, validators in systems/
AFTER:  tools/map_editor/, tools/validators/
```

### 5. Clean Root ✅
```
BEFORE: 10+ test/run scripts cluttering root
AFTER:  Only main.lua, conf.lua, README.md in root
```

### 6. Unified Tests ✅
```
BEFORE: Tests scattered across root, tests/, battle/tests/
AFTER:  All tests organized under tests/ with clear hierarchy
```

### 7. Future-Ready ✅
```
- Interception mode ready to develop
- All modes use same structure pattern
- Easy to add new modes (e.g., manufacturing, diplomacy)
```

---

## Migration Effort

| Phase | Description | Time | Risk |
|-------|-------------|------|------|
| 1. Create folders | Make new structure | 30 min | LOW |
| 2. Core systems | Move core/ and shared/ | 45 min | MEDIUM |
| 3. Battlescape | Consolidate battle code | 90 min | HIGH |
| 4. Other modes | Geoscape, Basescape, Menu | 60 min | MEDIUM |
| 5. Tools/Scripts | Move tools and scripts | 30 min | LOW |
| 6. Tests | Reorganize tests | 45 min | MEDIUM |
| 7. Documentation | Update docs | 30 min | LOW |
| 8. Validation | Test everything | 30 min | MEDIUM |
| **TOTAL** | | **5.5 hrs** | **MEDIUM** |

---

## Success Metrics

- ✅ **Zero broken requires** - All imports work
- ✅ **All modes functional** - Menu, Geoscape, Battlescape, Basescape all work
- ✅ **All tests pass** - No regressions
- ✅ **Clean console** - No errors or warnings
- ✅ **Clear structure** - New developers can navigate easily
- ✅ **Documentation updated** - All READMEs and wiki docs reflect new structure

